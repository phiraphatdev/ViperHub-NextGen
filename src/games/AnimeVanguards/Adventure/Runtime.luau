--!strict
--[[
Purpose: Odyssey: Adventure in-match automation: Auto Basic Card (pick the offered basic card by priority) and Auto
         Route Atlas (pick the next room by the floor priorities)
Input: The match's GameOdysseyClient events, GameHandler game data and the saved Adventure settings
Output: CardPickPick requests, a status line and counters; nothing outside Adventure matches or when the switch is off
Dependencies: Config; Adventure/Detect; Adventure/Choice; Adventure/Adapter (shared settings)
]]

local config = require("../Config")
local Detect = require("./Detect")
local Choice = require("./Choice")
local Runtime = {}

local PICK_DELAY_SECONDS: number = (config :: any).thresholds.adventurePickDelaySeconds
local REPEAT_SECONDS: number = (config :: any).thresholds.adventureRepeatSeconds
local CHEST_GAP_SECONDS: number = (config :: any).thresholds.adventureChestGapSeconds
local SHOP_GAP_SECONDS: number = (config :: any).thresholds.adventureShopGapSeconds
local SHOP_WATCH_SECONDS: number = (config :: any).thresholds.adventureShopWatchSeconds
local SHOP_ASK_SECONDS: number = (config :: any).thresholds.adventureShopAskSeconds
local VOTE_RETRY_SECONDS: number = (config :: any).thresholds.adventureVoteRetrySeconds
local VOTE_ATTEMPTS: number = (config :: any).thresholds.adventureVoteAttempts

local function resolve(root: any, path: string): any
    local value = root
    for part in string.gmatch(path, "[^%.]+") do
        if not value then
            return nil
        end
        local current: any = value
        local ok, child = pcall(function()
            return current:FindFirstChild(part)
        end)
        value = if ok then child else nil
    end
    return value
end

local function optionalModule(root: any, path: string): any
    local ok, result = pcall(function()
        local object = resolve(root, path)
        return if object then (require :: any)(object) else nil
    end)
    return if ok then result else nil
end

local function liveDependencies(): any
    local env: any = getfenv()
    if not env.game then
        return {
            task = env.task,
            clock = os.clock,
            isAdventure = function(): boolean
                return false
            end,
        }
    end
    local replicated = env.game:GetService("ReplicatedStorage")
    local paths: any = config.instancePaths
    local handler: any = optionalModule(replicated, paths.gameHandler)
    return {
        task = env.task,
        clock = os.clock,
        -- Hides the Route Atlas window (the game opens it for every vote and leaves it open).
        closeMap = function()
            local players = env.game:GetService("Players")
            local gui = players.LocalPlayer and players.LocalPlayer:FindFirstChild("PlayerGui")
            local hud = gui and gui:FindFirstChild("AdventureHUD")
            local root = hud and hud:FindFirstChild("AdventureMapRoot")
            if root and root.Visible then
                root.Visible = false
            end
        end,
        roomKind = function(): string?
            local data = if handler then handler.GameData else nil
            return if type(data) == "table" and type(data.AdventureRoomKind) == "string"
                then data.AdventureRoomKind
                else nil
        end,
        floor = function(): number?
            local data = if handler then handler.GameData else nil
            return if type(data) == "table" and type(data.AdventureFloor) == "number"
                then data.AdventureFloor
                else nil
        end,
        unitReward = (function(): any
            local networking = replicated:FindFirstChild("Networking")
            local odyssey = networking and networking:FindFirstChild("Odyssey")
            local adventure = odyssey and odyssey:FindFirstChild("Adventure")
            return adventure and adventure:FindFirstChild("UnitRewardEvent")
        end)(),
        placedUnitGuid = function(name: any): string?
            local handler = optionalModule(env.game:GetService("StarterPlayer"), paths.clientUnitHandler)
            if type(handler) ~= "table" or type(handler.GetAllPlacedUnits) ~= "function" then
                return nil
            end
            local listPlaced: any = handler.GetAllPlacedUnits
            for _, unit in listPlaced() do
                if
                    type(unit) == "table"
                    and unit.Name == name
                    and type(unit.UniqueIdentifier) == "string"
                then
                    return unit.UniqueIdentifier
                end
            end
            return nil
        end,
        mapRelay = optionalModule(env.game:GetService("StarterPlayer"), paths.adventureMapRelay),
        events = optionalModule(replicated, paths.gameOdysseyClient),
        isAdventure = function(): boolean
            return handler ~= nil and Detect.isAdventureMatch(handler.GameData)
        end,
    }
end

--- Creates a stopped controller; getSettings returns the shared Adventure settings (read lazily); deps are injectable.
function Runtime.new(getSettings: () -> any, injected: any?): any
    local self: any = {
        status = "Idle",
        picked = 0,
        routed = 0,
        cards = 0,
        chests = 0,
        bought = 0,
        units = 0,
        onStatus = nil,
    }
    local deps: any = injected
    local disconnects: { () -> () } = {}
    local lastKey = ""
    local lastAt = -math.huge
    local snapshot: any = nil
    local pendingRooms: any = nil
    local onRoomOffer: (any, boolean?) -> ()
    local closeMapLater: () -> ()
    local function setStatus(text: string)
        self.status = text
        if self.onStatus then
            pcall(self.onStatus, text)
        end
    end

    local voteOpen = false
    local voteAttempts = 0
    local lastOffer: any = nil
    local gameSettings: any = nil
    local guardedRetry: (any) -> ()

    -- The game's own Auto Skip Start starts every floor without a click; an Adventure run stalls on a floor start
    -- vote while it is off, so it is switched on when this feature is on (a game setting, left on afterwards).
    local function ensureStart()
        if not self.active or getSettings().get("autoStartFloors") ~= true then
            return
        end
        local gs: any = gameSettings
        if type(gs) == "table" and type(gs.get) == "function" and type(gs.set) == "function" then
            local ok, current = pcall(gs.get, "AutoSkipStart")
            if ok and current == false and pcall(gs.set, "AutoSkipStart", true) then
                setStatus("Turned on the game's Auto Skip Start")
            end
        end
    end
    local shopHandled = false
    local lastShopKey = ""
    local lastShopAt = -math.huge
    local lastRoomKey = ""
    local lastRoomAt = -math.huge

    local function sendPick(index: number): boolean
        local entry = if deps.events then deps.events.CardPickPick else nil
        if type(entry) ~= "table" or type(entry.Fire) ~= "function" then
            return false
        end
        local fireFn: any = entry.Fire
        return (pcall(fireFn, { Choice = index }))
    end

    -- A basic card offer: pick by priority after a short delay, once per offer (repeats only after REPEAT_SECONDS).
    local function onBasicOffer(offer: any)
        if not self.active or getSettings().get("autoBasicCard") ~= true or not deps.isAdventure() then
            return
        end
        local options: any = if type(offer) == "table" then offer.Options else nil
        local index = Choice.pickBasicCard(options, getSettings().get("cardPriority"))
        if not index then
            setStatus("Auto Basic Card: no valid card offered")
            return
        end
        local name: string = options[index].CardName
        local key = #options .. ":" .. name
        local now = deps.clock()
        if key == lastKey and now - lastAt < REPEAT_SECONDS then
            return
        end
        lastKey, lastAt = key, now
        local function pick()
            if not self.active or getSettings().get("autoBasicCard") ~= true then
                return
            end
            if sendPick(index) then
                self.picked += 1
                setStatus(
                    string.format("Auto Basic Card: picked %s (#%s)", tostring(name), tostring(self.picked))
                )
            else
                setStatus("Auto Basic Card: pick request failed")
            end
        end
        local taskApi: any = deps.task
        if type(taskApi) == "table" and type(taskApi.delay) == "function" then
            (taskApi.delay :: any)(PICK_DELAY_SECONDS, pick)
        else
            pick()
        end
    end

    -- Closes the Route Atlas shortly after a vote (and again when the vote ends), when the switch is on.
    local function closeMapNow()
        if self.active and getSettings().get("closeMap") == true and type(deps.closeMap) == "function" then
            pcall(deps.closeMap)
        end
    end
    closeMapLater = function()
        local taskApi: any = deps.task
        if type(taskApi) == "table" and type(taskApi.delay) == "function" then
            (taskApi.delay :: any)(1.5, closeMapNow)
        else
            closeMapNow()
        end
    end

    -- A room selection: pick the next room by the floor priorities (the second list from the chosen floor on).
    onRoomOffer = function(offer: any, retry: boolean?)
        local saved = getSettings()
        ensureStart()
        if retry ~= true then
            voteAttempts = 0
        end
        lastOffer = offer
        voteOpen = true
        if self.active and saved.get("autoRoute") == true then
            setStatus("Auto Route Atlas: room offer received")
        end
        if not self.active or saved.get("autoRoute") ~= true or not deps.isAdventure() then
            return
        end
        local options: any = if type(offer) == "table" then offer.Options else nil
        -- Only rooms the Route Atlas connects to the current floor can be voted (observed: offers also list
        -- unreachable rooms); the map snapshot marks them IsSelectable, and an option's Index is its lane.
        local reachable: { [number]: boolean } = {}
        local floor = if type(options) == "table" and type(options[1]) == "table"
            then options[1].AdventureFloor
            else nil
        local known = false
        -- The snapshot must belong to the floor just cleared: IsSelectable is relative to its CurrentFloor.
        if
            type(snapshot) == "table"
            and type(snapshot.Nodes) == "table"
            and type(floor) == "number"
            and snapshot.CurrentFloor == floor - 1
        then
            known = true
            -- Reachable lanes come from the map connections (current node -> next floor); IsSelectable is only set once
            -- the vote has started, so it is used just when the snapshot has no connections.
            local from = "F" .. tostring(snapshot.CurrentFloor) .. "_L" .. tostring(snapshot.CurrentLane)
            local prefix = "F" .. tostring(floor) .. "_L"
            local connected = false
            if type(snapshot.Connections) == "table" then
                for _, connection in snapshot.Connections do
                    if
                        type(connection) == "table"
                        and connection.From == from
                        and type(connection.To) == "string"
                    then
                        local toId: string = connection.To
                        local captured = string.match(toId, "^" .. prefix .. "(%d+)$")
                        local lane = if captured then tonumber(captured) else nil
                        if lane then
                            reachable[lane] = true
                            connected = true
                        end
                    end
                end
            end
            if not connected then
                for _, node in snapshot.Nodes do
                    if
                        type(node) == "table"
                        and node.Floor == floor
                        and node.IsSelectable == true
                        and type(node.Lane) == "number"
                    then
                        reachable[node.Lane] = true
                    end
                end
            end
        end
        if not known then
            -- The snapshot may not have arrived yet (or the hub loaded mid-run): ask for it and decide when it comes.
            pendingRooms = offer
            local ask = if deps.events then deps.events.MapRequestSnapshot else nil
            if type(ask) == "table" and type(ask.Fire) == "function" then
                local askFire: any = ask.Fire
                pcall(askFire)
            end
            setStatus("Auto Route Atlas: waiting for the map data")
            return
        end
        pendingRooms = nil
        local index = Choice.pickRoom(
            options,
            saved.get("floorPriority"),
            saved.get("secondFloorPriority"),
            saved.get("secondPriorityFloor"),
            reachable
        )
        if not index and type(options) == "table" then
            -- No room matched the priorities: still move on, to the first reachable room, so the run never stalls.
            for _, option in options do
                if type(option) == "table" and type(option.Index) == "number" and reachable[option.Index] then
                    if index == nil or option.Index < index then
                        index = option.Index
                    end
                end
            end
        end
        if not index then
            setStatus("Auto Route Atlas: no reachable room offered")
            return
        end
        local now = deps.clock()
        local key = "room:" .. #options .. ":" .. index
        if retry ~= true and key == lastRoomKey and now - lastRoomAt < REPEAT_SECONDS then
            return
        end
        lastRoomKey, lastRoomAt = key, now
        local function go()
            -- Observed live: in Adventure the game ignores SelectRoomChoose (its own room UI returns early for
            -- SubMode Adventure); the next room is chosen by voting on the map's next row with VoteCast. INFERENCE:
            -- OptionIndex is the offered option's Index.
            local entry = if deps.events then deps.events.VoteCast else nil
            if
                not self.active
                or saved.get("autoRoute") ~= true
                or type(entry) ~= "table"
                or type(entry.Fire) ~= "function"
            then
                return
            end
            local fireFn: any = entry.Fire
            if pcall(fireFn, { OptionIndex = index }) then
                closeMapLater()
                -- A vote that is not accepted would stall the run: vote again if it is still open after a while.
                local taskApi2: any = deps.task
                if type(taskApi2) == "table" and type(taskApi2.delay) == "function" then
                    (taskApi2.delay :: any)(VOTE_RETRY_SECONDS, function()
                        if self.active and voteOpen and voteAttempts < VOTE_ATTEMPTS and lastOffer ~= nil then
                            voteAttempts += 1
                            guardedRetry(lastOffer)
                        end
                    end)
                end
                self.routed += 1
                local kind = "?"
                for _, option in options do
                    if type(option) == "table" and option.Index == index then
                        kind = tostring(option.AdventureRoomKind)
                    end
                end
                setStatus(
                    string.format("Auto Route Atlas: chose a %s room (#%s)", kind, tostring(self.routed))
                )
            else
                setStatus("Auto Route Atlas: choose request failed")
            end
        end
        local taskApi: any = deps.task
        if type(taskApi) == "table" and type(taskApi.delay) == "function" then
            (taskApi.delay :: any)(PICK_DELAY_SECONDS, go)
        else
            go()
        end
    end

    -- A character card offer (after an Elite floor): the highest rarity; a full hand (AtCap) is skipped, because
    -- replacing a card is a choice for the player.
    local function onCharacterOffer(offer: any)
        if not self.active or getSettings().get("autoCharacterCard") ~= true or not deps.isAdventure() then
            return
        end
        local options: any = if type(offer) == "table" then offer.Options else nil
        local atCap = type(offer) == "table" and offer.AtCap == true
        local index = if atCap then nil else Choice.pickCharacterCard(options)
        local function answer()
            if not self.active or getSettings().get("autoCharacterCard") ~= true then
                return
            end
            local events: any = deps.events
            local remoteName = if index then "CardPickPick" else "CardPickSkip"
            local entry = if events then events[remoteName] else nil
            if type(entry) ~= "table" or type(entry.Fire) ~= "function" then
                return
            end
            local fireFn: any = entry.Fire
            local ok = if index then pcall(fireFn, { Choice = index }) else pcall(fireFn)
            if ok then
                self.cards += 1
                setStatus(
                    if index
                        then "Auto Character Card: picked option " .. tostring(index)
                        else "Auto Character Card: skipped (hand full)"
                )
            end
        end
        local taskApi: any = deps.task
        if type(taskApi) == "table" and type(taskApi.delay) == "function" then
            (taskApi.delay :: any)(PICK_DELAY_SECONDS, answer)
        else
            answer()
        end
    end

    -- A Shop floor ends when the shop is closed; this build never buys, so it closes the shop to keep the run going.
    local function toSet(list: any): { [string]: boolean }
        local set: { [string]: boolean } = {}
        if type(list) == "table" then
            for _, name in list do
                if type(name) == "string" then
                    set[name] = true
                end
            end
        end
        return set
    end

    -- A placed unit of the run character (its GUID), used for a Memoria when the shop offers no trait for that unit.
    local function placedGuid(name: any): string?
        local lookup: any = deps.placedUnitGuid
        if type(lookup) ~= "function" then
            return nil
        end
        local ok, guid = pcall(lookup, name)
        return if ok and type(guid) == "string" then guid else nil
    end

    local function onShopOpened(info: any)
        local saved = getSettings()
        local buying = saved.get("autoStitchesShop") == true
        if not self.active or not deps.isAdventure() or (not buying and saved.get("leaveShop") ~= true) then
            return
        end
        shopHandled = true
        setStatus("Shop: opened, planning purchases")
        -- The shop can announce itself more than once: act on one opening at a time.
        local stock: any = if type(info) == "table" then info.Stock else nil
        local now = deps.clock()
        local key = "shop:"
            .. tostring(if type(info) == "table" then info.Budget else nil)
            .. ":"
            .. tostring(type(stock) == "table" and #stock or 0)
        if key == lastShopKey and now - lastShopAt < REPEAT_SECONDS then
            return
        end
        lastShopKey, lastShopAt = key, now
        local plan: { any } = {}
        if buying and type(info) == "table" then
            plan = Choice.shopPurchases(
                stock,
                (if type(info.Budget) == "number" then info.Budget else 0)
                    - (if type(info.Spent) == "number" then info.Spent else 0),
                {
                    basic = toSet(saved.get("buyBasicCards")),
                    starters = toSet(saved.get("buyStarterCards")),
                    traits = toSet(saved.get("buyTraits")),
                    memoria = toSet(saved.get("buyMemoria")),
                    character = saved.get("character"),
                    fallbackGuid = placedGuid(saved.get("character")),
                    rank = saved.get("cardPriority"),
                }
            )
        end
        setStatus(
            "Shop: "
                .. tostring(#plan)
                .. " item(s) to buy (budget "
                .. tostring(if type(info) == "table" then info.Budget else nil)
                .. ")"
        )
        local taskApi: any = deps.task
        local function later(seconds: number, action: () -> ())
            if type(taskApi) == "table" and type(taskApi.delay) == "function" then
                (taskApi.delay :: any)(seconds, action)
            else
                action()
            end
        end
        local function leave()
            local events: any = deps.events
            local entry = if events then events.ShopClose else nil
            if
                self.active
                and saved.get("leaveShop") == true
                and type(entry) == "table"
                and type(entry.Fire) == "function"
            then
                local fireFn: any = entry.Fire
                if pcall(fireFn) then
                    setStatus(
                        if #plan > 0
                            then "Shop: bought " .. tostring(#plan) .. " item(s), left the shop"
                            else "Left the shop without buying"
                    )
                end
            end
        end
        for position, item in plan do
            later(PICK_DELAY_SECONDS + SHOP_GAP_SECONDS * (position - 1), function()
                local events: any = deps.events
                local entry = if events then events.ShopPurchase else nil
                if not self.active or type(entry) ~= "table" or type(entry.Fire) ~= "function" then
                    return
                end
                local payload: any = { StockIndex = item.index }
                if item.guid then
                    payload.TargetUnitGUID = item.guid
                end
                local fireFn: any = entry.Fire
                if pcall(fireFn, payload) then
                    self.bought += 1
                    setStatus("Shop: bought " .. tostring(item.name) .. " for " .. tostring(item.cost))
                end
            end)
        end
        later(PICK_DELAY_SECONDS + SHOP_GAP_SECONDS * #plan, leave)
    end

    -- A Treasure floor ends once the allowed picks are used: open the first unopened chests one by one
    -- (observed: TreasureBegin {TotalChests = 6, PicksRemaining = 3, OpenedChests}; TreasureOpenChest({ChestIndex})).
    local function onTreasureBegin(info: any)
        if not self.active or type(info) ~= "table" then
            return
        end
        if getSettings().get("openTreasure") ~= true then
            setStatus("Treasure floor: Open Treasure Chests is off")
            return
        end
        if not deps.isAdventure() then
            setStatus("Treasure floor: not recognized as an Adventure match")
            return
        end
        setStatus("Treasure floor: opening chests")
        local total = if type(info.TotalChests) == "number" then info.TotalChests else 6
        local picks = if type(info.PicksRemaining) == "number" then info.PicksRemaining else 3
        local opened: { [number]: boolean } = {}
        if type(info.OpenedChests) == "table" then
            for key, value in info.OpenedChests do
                if type(key) == "number" and value then
                    opened[key] = true
                end
                if type(value) == "number" then
                    opened[value] = true
                end
            end
        end
        local order: { number } = {}
        for index = 1, total do
            if not opened[index] and #order < picks then
                table.insert(order, index)
            end
        end
        local taskApi: any = deps.task
        for position, chest in order do
            local function open()
                local events: any = deps.events
                local entry = if events then events.TreasureOpenChest else nil
                if not self.active or type(entry) ~= "table" or type(entry.Fire) ~= "function" then
                    return
                end
                local fireFn: any = entry.Fire
                if pcall(fireFn, { ChestIndex = chest }) then
                    self.chests += 1
                    setStatus("Opened treasure chest " .. tostring(chest))
                end
            end
            if type(taskApi) == "table" and type(taskApi.delay) == "function" then
                (taskApi.delay :: any)(
                    PICK_DELAY_SECONDS * position + CHEST_GAP_SECONDS * (position - 1),
                    open
                )
            else
                open()
            end
        end
    end

    -- After an Elite floor the game may offer one unit of the starting loadout (UnitRewardEvent: "Offer", answered
    -- with FireServer("Pick", index); the server then sends "Close"). The run waits for the answer.
    local function onUnitReward(kind: any, data: any)
        if
            kind ~= "Offer"
            or not self.active
            or getSettings().get("autoUnitReward") ~= true
            or not deps.isAdventure()
        then
            return
        end
        local index = Choice.pickUnitReward(data)
        local remote: any = deps.unitReward
        if not index or remote == nil then
            setStatus("Auto Choose Unit Reward: no unit offered")
            return
        end
        local function answer()
            if not self.active or getSettings().get("autoUnitReward") ~= true then
                return
            end
            local okFire = pcall(function()
                remote:FireServer("Pick", index)
            end)
            if okFire then
                self.units += 1
                setStatus("Auto Choose Unit Reward: picked unit option " .. tostring(index))
            end
        end
        local taskApi: any = deps.task
        if type(taskApi) == "table" and type(taskApi.delay) == "function" then
            (taskApi.delay :: any)(PICK_DELAY_SECONDS, answer)
        else
            answer()
        end
    end

    -- Event handlers run inside the game's signal code, where an error would vanish: report it in the status instead.
    local function guarded(name: string, handler: (any) -> ()): (any) -> ()
        return function(payload: any)
            local ok, err = pcall(handler, payload)
            if not ok then
                setStatus("Adventure " .. name .. " failed: " .. string.sub(tostring(err), 1, 90))
            end
        end
    end

    -- The shop's opening event can come before the hub is ready (or be missed): while the current room is a Shop and
    -- this shop was not handled, ask the game for its state (its reply is handled like an opening).
    local lastFloorSeen: number? = nil
    local lastShopAsk = -math.huge
    local function watchShop()
        local taskApi: any = deps.task
        if not self.active or type(taskApi) ~= "table" or type(taskApi.delay) ~= "function" then
            return
        end
        local ok = pcall(function()
            local floorOf: any = deps.floor
            local floor = if type(floorOf) == "function" then (floorOf :: any)() else nil
            if floor ~= lastFloorSeen then
                lastFloorSeen = floor
                shopHandled = false
            end
            local roomKindOf: any = deps.roomKind
            local saved = getSettings()
            local wanted = saved.get("autoStitchesShop") == true or saved.get("leaveShop") == true
            local now = deps.clock()
            if
                wanted
                and not shopHandled
                and type(roomKindOf) == "function"
                and (roomKindOf :: any)() == "Shop"
                and now - lastShopAsk >= SHOP_ASK_SECONDS
            then
                lastShopAsk = now
                local events: any = deps.events
                local ask = if events then events.ShopRequestState else nil
                if type(ask) == "table" and type(ask.Fire) == "function" then
                    local askFire: any = ask.Fire
                    pcall(askFire)
                end
            end
        end)
        if not ok then
            setStatus("Shop watcher failed")
        end
        (taskApi.delay :: any)(SHOP_WATCH_SECONDS, watchShop)
    end

    --- Starts listening for offers; returns whether the match events exist (false in the lobby). Safe to repeat.
    function self.start(): boolean
        if self.active then
            return true
        end
        deps = deps or liveDependencies()
        local events: any = deps.events
        local entry = if type(events) == "table" then events.CardPickBasicOffer else nil
        if type(entry) ~= "table" or type(entry.On) ~= "function" then
            setStatus("Idle (not in an Adventure match)")
            return false
        end
        local onFn: any = entry.On
        local ok, undo = pcall(onFn, guarded("card offer", onBasicOffer))
        if not ok then
            setStatus("Auto Basic Card: could not subscribe")
            return false
        end
        if type(undo) == "function" then
            table.insert(disconnects, undo)
        end
        local extras: { [string]: any } = {
            CardPickCharacterOffer = onCharacterOffer,
            ShopOpened = onShopOpened,
            TreasureBegin = onTreasureBegin,
            -- Hub loaded while a shop was already open: its first stock update stands in for the opening.
            ShopStockUpdated = function(info: any)
                if not shopHandled then
                    onShopOpened(info)
                end
            end,
            ShopClosed = function()
                shopHandled = false
            end,
            VoteEnded = function()
                voteOpen = false
                voteAttempts = 0
                closeMapLater()
                ensureStart()
            end,
        }
        for eventName, handler in extras do
            local extra = events[eventName]
            if type(extra) == "table" and type(extra.On) == "function" then
                local extraOn: any = extra.On
                local okExtra, undoExtra = pcall(extraOn, guarded(eventName, handler))
                if okExtra and type(undoExtra) == "function" then
                    table.insert(disconnects, undoExtra)
                end
            end
        end
        local relay: any = deps.mapRelay
        if type(relay) == "table" and type(relay.OnSnapshot) == "function" then
            local okRelay, undoRelay = pcall(relay.OnSnapshot, function(data: any)
                snapshot = data
                local waiting = pendingRooms
                if waiting ~= nil then
                    guarded("room offer", onRoomOffer)(waiting)
                end
            end)
            if okRelay and type(undoRelay) == "function" then
                table.insert(disconnects, undoRelay)
            end
        end
        local roomEntry = if type(events) == "table" then events.SelectRoomSelectionStarted else nil
        if type(roomEntry) == "table" and type(roomEntry.On) == "function" then
            local roomOn: any = roomEntry.On
            local okRoom, undoRoom = pcall(roomOn, guarded("room offer", onRoomOffer))
            if okRoom and type(undoRoom) == "function" then
                table.insert(disconnects, undoRoom)
            end
        end
        guardedRetry = function(offer: any)
            guarded("room offer", function(payload: any)
                onRoomOffer(payload, true)
            end)(offer)
        end
        self.active = true
        setStatus("Listening for card and room offers")
        local rewardRemote: any = deps.unitReward
        if rewardRemote ~= nil then
            local okReward, connection = pcall(function()
                return rewardRemote.OnClientEvent:Connect(function(kind: any, data: any)
                    local okHandler, err = pcall(onUnitReward, kind, data)
                    if not okHandler then
                        setStatus("Adventure unit reward failed: " .. string.sub(tostring(err), 1, 90))
                    end
                end)
            end)
            if okReward and connection then
                table.insert(disconnects, function()
                    connection:Disconnect()
                end)
            end
        end
        local roomKindDep: any = deps.roomKind
        if type(roomKindDep) == "function" then
            watchShop()
        end
        local startTask: any = deps.task
        if type(startTask) == "table" and type(startTask.delay) == "function" then
            (startTask.delay :: any)(10, ensureStart)
        else
            ensureStart()
        end
        return true
    end

    --- Gives the runtime the game-settings adapter (get/set by game setting name) used to keep Auto Skip Start on.
    function self.setGameSettings(settings: any)
        gameSettings = settings
    end

    --- Stops listening; safe to repeat.
    function self.stop()
        self.active = false
        for _, undo in disconnects do
            pcall(undo)
        end
        disconnects = {}
    end

    return self
end

return Runtime
