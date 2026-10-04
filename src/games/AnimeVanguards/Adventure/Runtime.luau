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
local CHEST_TELEPORT_DELAY_SECONDS: number = (config :: any).thresholds.adventureChestTeleportDelaySeconds
    or 0.3
local CHEST_GAP_SECONDS: number = (config :: any).thresholds.adventureChestGapSeconds or 0.8
local SHOP_GAP_SECONDS: number = (config :: any).thresholds.adventureShopGapSeconds
local SHOP_WATCH_SECONDS: number = (config :: any).thresholds.adventureShopWatchSeconds
local SHOP_ASK_SECONDS: number = (config :: any).thresholds.adventureShopAskSeconds
local SHOP_UI_GRACE_SECONDS: number = (config :: any).thresholds.adventureShopUiGraceSeconds
local HISTORY_LIMIT = 40
local END_SCREEN_SECONDS = 1
local LOBBY_RETRY_SECONDS = 20
local NEW_RUN_FALLBACK_SECONDS = 40
local TASK_WAIT_SECONDS: number = (config :: any).thresholds.adventureTaskWaitSeconds
local TASK_WAIT_RETRY_SECONDS: number = (config :: any).thresholds.adventureTaskWaitRetrySeconds
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
        -- Closes the Route Atlas window when it is open: presses its Close control (signals on the control and on any
        -- button inside it), then a real click with the GUI inset. It never makes the window visible itself.
        closeMap = function()
            local players: any = env.game:GetService("Players")
            local gui: any = players.LocalPlayer and players.LocalPlayer:FindFirstChild("PlayerGui")
            local hud: any = gui and gui:FindFirstChild("AdventureHUD")
            local root: any = hud and hud:FindFirstChild("AdventureMapRoot")
            if not root or not root.Visible then
                return
            end
            local closeControl: any = root:FindFirstChild("Close", true)
            if not closeControl or closeControl.AbsoluteSize.X <= 0 then
                return
            end
            local firesignal: any = (getfenv() :: any).firesignal
            if firesignal then
                local targets: { any } = { closeControl }
                for _, descendant in closeControl:GetDescendants() do
                    local item: any = descendant
                    if item:IsA("GuiButton") then
                        table.insert(targets, item)
                    end
                end
                for _, target in targets do
                    local item: any = target
                    if item:IsA("GuiButton") then
                        pcall(firesignal, item.Activated)
                        pcall(firesignal, item.MouseButton1Click)
                    end
                end
            end
            -- Still open: a real click on the control.
            local vim: any = env.game:GetService("VirtualInputManager")
            local inset: any = env.game:GetService("GuiService"):GetGuiInset()
            local tApi: any = env.task
            local function stillOpen(): boolean
                return root.Visible and closeControl.Parent ~= nil and closeControl.AbsoluteSize.X > 0
            end
            if tApi and type(tApi.wait) == "function" then
                (tApi.wait :: any)(0.2)
            end
            if stillOpen() then
                local pos = closeControl.AbsolutePosition + closeControl.AbsoluteSize / 2 + inset
                pcall(function()
                    vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, env.game, 1)
                    vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, env.game, 1)
                end)
            end
        end,
        -- Leaves a Stitches' Shop window that is still on screen: the X only hides it, the floor ends with the
        -- "Leave Shop" button (observed live). Tries its signals, then a real click, last hides the window.
        -- Returns true when a window was visible and an attempt was made.
        closeShopUi = (function(): () -> boolean
            local attempts = 0
            return function(): boolean
                local players: any = env.game:GetService("Players")
                local gui: any = players.LocalPlayer and players.LocalPlayer:FindFirstChild("PlayerGui")
                local hud: any = gui and gui:FindFirstChild("AdventureHUD")
                if not hud then
                    return false
                end
                for _, object in hud:GetDescendants() do
                    local item: any = object
                    if
                        string.find(item.Name, "Shop_Export", 1, true) ~= nil
                        and item:IsA("GuiObject")
                        and item.Visible
                        and item.AbsoluteSize.X > 0
                    then
                        attempts += 1
                        local bottom: any = item:FindFirstChild("BottomFrame", true)
                        local leave: any = bottom and bottom:FindFirstChild("Clickable", true)
                        local firesignal: any = (getfenv() :: any).firesignal
                        if attempts == 1 and leave and firesignal then
                            pcall(firesignal, leave.Activated)
                            pcall(firesignal, leave.MouseButton1Click)
                        elseif attempts == 2 and leave and leave.AbsoluteSize.X > 0 then
                            local vim: any = env.game:GetService("VirtualInputManager")
                            local inset: any = env.game:GetService("GuiService"):GetGuiInset()
                            local pos = leave.AbsolutePosition + leave.AbsoluteSize / 2 + inset
                            pcall(function()
                                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, env.game, 1)
                                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, env.game, 1)
                            end)
                        else
                            item.Visible = false
                        end
                        return true
                    end
                end
                attempts = 0
                return false
            end
        end)(),
        -- True while the match end screen is shown (observed: PlayerGui.EndScreen.Holder; a failed run shows it).
        endScreenShown = function(): boolean
            local players: any = env.game:GetService("Players")
            local gui: any = players.LocalPlayer and players.LocalPlayer:FindFirstChild("PlayerGui")
            local screen: any = gui and gui:FindFirstChild("EndScreen")
            local holder: any = screen and screen:FindFirstChild("Holder")
            return screen ~= nil
                and screen.Enabled == true
                and holder ~= nil
                and holder.Visible == true
                and holder.AbsoluteSize.X > 0
        end,
        -- The end screen's "New Run" button (a solo failed Adventure run) casts the retry vote
        -- (observed in EndScreen.VoteHandler: SendVote(GameEndScreenClient.CastRetryVote.Fire)).
        newRun = function(): boolean
            local endClient: any = optionalModule(replicated, paths.endScreenClient)
            local vote = if type(endClient) == "table" then endClient.CastRetryVote else nil
            if type(vote) == "table" and type(vote.Fire) == "function" then
                return (pcall(vote.Fire))
            end
            return false
        end,
        returnToLobby = function(): boolean
            local lobby: any = optionalModule(replicated, paths.lobbyReturnClient)
            local request = if type(lobby) == "table" then lobby.RequestTeleportToLobby else nil
            if type(request) == "table" and type(request.Fire) == "function" then
                return (pcall(request.Fire))
            end
            return false
        end,
        roomKind = function(): string?
            local data = if handler then handler.GameData else nil
            return if type(data) == "table" and type(data.AdventureRoomKind) == "string"
                then data.AdventureRoomKind
                else nil
        end,
        -- Identifies the current run: a new run in the same server gets new game events, so the subscriptions of the
        -- previous run go silent (observed live: no card pick and no vote after a run ended and another began).
        runSeed = function(): string?
            local data = if handler then handler.GameData else nil
            return if type(data) == "table" and type(data.AdventureRunSeed) == "string"
                then data.AdventureRunSeed
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
        -- Ends the run like the End Run button (observed in the Adventure client): FireServer("RequestPreview"),
        -- the server answers "Preview" {Token, FloorsCleared}, then FireServer("Confirm", Token) -> "Completed";
        -- FireServer("Replay") then starts a new run.
        endRun = (function(): any
            local networking = replicated:FindFirstChild("Networking")
            local odyssey = networking and networking:FindFirstChild("Odyssey")
            local adventure = odyssey and odyssey:FindFirstChild("Adventure")
            return adventure and adventure:FindFirstChild("EndRunEvent")
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
                    and (name == nil or unit.Name == name)
                    and type(unit.UniqueIdentifier) == "string"
                then
                    return unit.UniqueIdentifier
                end
            end
            return nil
        end,
        mapRelay = optionalModule(env.game:GetService("StarterPlayer"), paths.adventureMapRelay),
        events = optionalModule(replicated, paths.gameOdysseyClient),
        teleportTo = function(chestCFrame: any): boolean
            local players: any = env.game and env.game:GetService("Players")
            local lp: any = players and players.LocalPlayer
            local char: any = lp and lp.Character
            local hrp: any = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and chestCFrame ~= nil then
                local ok = pcall(function()
                    local cfGlobal: any = (getfenv() :: any).CFrame
                    local offset = if cfGlobal then cfGlobal.new(0, 3, 0) else nil
                    hrp.CFrame = if offset then chestCFrame * offset else chestCFrame
                    local v3Global: any = (getfenv() :: any).Vector3
                    if v3Global and type(v3Global.new) == "function" then
                        local zero = (v3Global.new :: any)(0, 0, 0)
                        hrp.AssemblyLinearVelocity = zero
                        hrp.AssemblyAngularVelocity = zero
                    end
                end)
                return ok
            end
            return false
        end,
        getUnopenedChests = function(): { { id: string, cframe: any } }
            local workspaceService: any = env.game:GetService("Workspace")
            local ignore: any = workspaceService and workspaceService:FindFirstChild("Ignore")
            local list: { { id: string, cframe: any } } = {}
            if ignore then
                for _, child in ipairs(ignore:GetChildren()) do
                    local ch: any = child
                    if ch:IsA("Model") and string.sub(ch.Name, 1, 13) == "OdysseyChest_" then
                        local id = ch:GetAttribute("Id")
                        local hl = ch:FindFirstChild("OdysseyChestHighlight")
                        if hl and type(id) == "string" then
                            local part: any = ch:FindFirstChild("Cylinder.001")
                                or ch.PrimaryPart
                                or ch:FindFirstChildWhichIsA("BasePart")
                            local cf = if part then part.CFrame else nil
                            table.insert(list, { id = id, cframe = cf })
                        end
                    end
                end
            end
            return list
        end,
        openChestRequest = function(chestId: string): boolean
            local stageMechanics: any = optionalModule(replicated, paths.stageMechanicsClient)
            local req = if stageMechanics then stageMechanics.OdysseyChestOpenRequest else nil
            if type(req) == "table" and type(req.Fire) == "function" then
                local ok = pcall(req.Fire, chestId)
                local pickReq = stageMechanics.OdysseyChestPickUpItemRequest
                if type(pickReq) == "table" and type(pickReq.Fire) == "function" then
                    pcall(pickReq.Fire, chestId)
                end
                return ok
            end
            return false
        end,
        readActiveCardOffer = function(): { Options: { any } }?
            local players: any = env.game and env.game:GetService("Players")
            local lp: any = players and players.LocalPlayer
            local pgui: any = lp and lp:FindFirstChild("PlayerGui")
            local ah: any = pgui and pgui:FindFirstChild("AdventureHUD")
            local cc: any = ah and ah:FindFirstChild("ChooseCard", true)
            if not cc or not cc.Visible then
                return nil
            end
            local frame: any = cc:FindFirstChild("ScrollIndicatorFrame", true)
            if not frame then
                return nil
            end
            local options = {}
            for _, ch in ipairs(frame:GetChildren()) do
                local btn: any = ch
                if btn:IsA("ImageButton") then
                    local title: any = btn:FindFirstChild("Title", true)
                    local rarity: any = btn:FindFirstChild("Rarity", true)
                    if title and title:IsA("TextLabel") and title.Text ~= "" then
                        table.insert(options, {
                            CardName = title.Text,
                            Rarity = if rarity and rarity:IsA("TextLabel") then rarity.Text else "Rare",
                        })
                    end
                end
            end
            if #options > 0 then
                return { Options = options }
            end
            return nil
        end,
        dismissCardUI = function(index: number)
            local players: any = env.game and env.game:GetService("Players")
            local lp: any = players and players.LocalPlayer
            local pgui: any = lp and lp:FindFirstChild("PlayerGui")
            local ah: any = pgui and pgui:FindFirstChild("AdventureHUD")
            local cc: any = ah and ah:FindFirstChild("ChooseCard", true)
            if cc and cc.Visible then
                local frame: any = cc:FindFirstChild("ScrollIndicatorFrame", true)
                local buttons: { any } = {}
                if frame then
                    for _, ch in ipairs(frame:GetChildren()) do
                        local btn: any = ch
                        if btn:IsA("ImageButton") then
                            table.insert(buttons, btn)
                        end
                    end
                end
                local targetBtn: any = buttons[index]
                if targetBtn then
                    local firesignal: any = (getfenv() :: any).firesignal
                    if firesignal and targetBtn.Activated then
                        pcall(firesignal, targetBtn.Activated)
                    end
                end
                pcall(function()
                    cc.Visible = false
                end)
            end
        end,
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
        history = {},
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
        -- A short bounded log of what the runtime did (readable from the session for diagnostics).
        local history: { string } = self.history
        local clockFn: any = if deps then deps.clock else nil
        local stamp: number = if type(clockFn) == "function" then (clockFn :: any)() else 0
        table.insert(history, string.format("%.0f %s", stamp, text))
        if #history > HISTORY_LIMIT then
            table.remove(history, 1)
        end
        if self.onStatus then
            pcall(self.onStatus, text)
        end
    end

    local voteOpen = false
    local voteAttempts = 0
    local lastOffer: any = nil
    local guardedRetry: (any) -> ()

    local shopHandled = false
    local shopClosedAt = -math.huge
    -- What the current floor still needs done (shop left, card chosen, unit/character/boss reward answered,
    -- chests opened): name -> when it began. Auto Route Atlas does not vote until all are done (or time out).
    local floorTasks: { [string]: number } = {}
    local function beginTask(name: string)
        floorTasks[name] = deps.clock()
    end
    local function endTask(name: string)
        floorTasks[name] = nil
    end
    local function waitingFor(): string?
        local now = deps.clock()
        for name, since in floorTasks do
            if now - since < TASK_WAIT_SECONDS then
                return name
            end
        end
        local readOffer: any = deps.readActiveCardOffer
        if type(readOffer) == "function" and getSettings().get("autoBasicCard") == true then
            local okRead, activeOffer = pcall(readOffer)
            if okRead and type(activeOffer) == "table" then
                return "card"
            end
        end
        return nil
    end
    local lastShopKey = ""
    local lastShopAt = -math.huge
    local lastRoomKey = ""
    local lastRoomAt = -math.huge

    local function sendPick(index: number): boolean
        local entry = if deps.events then deps.events.CardPickPick else nil
        local ok = false
        if type(entry) == "table" and type(entry.Fire) == "function" then
            local fireFn: any = entry.Fire
            ok = (pcall(fireFn, { Choice = index }))
        end
        local dismissFn: any = deps.dismissCardUI
        if type(dismissFn) == "function" then
            pcall(dismissFn, index)
            ok = true
        end
        return ok
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
        beginTask("card")
        local function pick()
            if not self.active or getSettings().get("autoBasicCard") ~= true then
                return
            end
            endTask("card")
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

    -- Closes the Route Atlas shortly after a vote (and again when the vote ends); there is no switch for it.
    local function closeMapNow()
        if self.active and type(deps.closeMap) == "function" then
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
        -- The next room is voted only when the floor's own steps are done: the card chosen, the shop left, the unit,
        -- character or boss reward answered and the chests opened (each waits at most TASK_WAIT_SECONDS).
        local waiting = waitingFor()
        if waiting then
            setStatus("Auto Route Atlas: waiting for " .. waiting)
            local waitTask: any = deps.task
            if type(waitTask) == "table" and type(waitTask.delay) == "function" then
                (waitTask.delay :: any)(TASK_WAIT_RETRY_SECONDS, function()
                    if self.active and voteOpen and lastOffer == offer then
                        onRoomOffer(offer, true)
                    end
                end)
            end
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
        local key = "room:" .. tostring(floor) .. ":" .. #options .. ":" .. index
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
        beginTask("character card")
        local function answer()
            endTask("character card")
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
            local dismissFn: any = deps.dismissCardUI
            if type(dismissFn) == "function" and index then
                pcall(dismissFn, index)
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
        beginTask("shop")
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
        -- Leaves the shop the way the player does: the Leave Shop button (the X only hides the window), then the
        -- ShopClose request as a backup. Nothing wanted or nothing selected: this runs at once.
        local function leave()
            local events: any = deps.events
            local entry = if events then events.ShopClose else nil
            if
                not self.active or (saved.get("leaveShop") ~= true and saved.get("autoStitchesShop") ~= true)
            then
                return
            end
            local pressFn: any = deps.closeShopUi
            if type(pressFn) == "function" then
                pcall(pressFn)
            end
            local sent = false
            if type(entry) == "table" and type(entry.Fire) == "function" then
                local fireFn: any = entry.Fire
                sent = (pcall(fireFn))
            end
            shopClosedAt = deps.clock()
            endTask("shop")
            setStatus(
                if #plan > 0
                    then "Shop: bought " .. tostring(#plan) .. " item(s), left the shop"
                    else "Left the shop without buying" .. (if sent then "" else " (button only)")
            )
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

    local treasureHandling = false
    local lastTreasureFloor: number? = nil

    -- A Treasure floor ends once the picks are used (observed: 6 chests, 3 picks; TreasureOpenChest({ChestIndex})).
    -- The chests are opened strictly one after the other: move the character next to the chest (when the 3D chest
    -- is found), wait, open it, wait, then the next. All at once desynchronised the floor.
    local function runOpenChests(info: any?)
        if
            treasureHandling
            or not self.active
            or getSettings().get("openTreasure") ~= true
            or not deps.isAdventure()
        then
            return
        end
        treasureHandling = true
        beginTask("treasure")
        setStatus("Treasure floor: opening chests")
        local taskApi: any = deps.task
        local function later(seconds: number, action: () -> ())
            if type(taskApi) == "table" and type(taskApi.delay) == "function" then
                (taskApi.delay :: any)(seconds, action)
            else
                action()
            end
        end
        local function finish()
            treasureHandling = false
            endTask("treasure")
        end
        local total = if type(info) == "table" and type(info.TotalChests) == "number"
            then info.TotalChests
            else 6
        local picks = if type(info) == "table" and type(info.PicksRemaining) == "number"
            then info.PicksRemaining
            else 3
        local opened: { [number]: boolean } = {}
        if type(info) == "table" and type(info.OpenedChests) == "table" then
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
        if #order == 0 then
            finish()
            return
        end
        local getChestsFn: any = deps.getUnopenedChests
        local physical: any = if type(getChestsFn) == "function" then (getChestsFn :: any)() else nil
        local function step(position: number)
            if not self.active or getSettings().get("openTreasure") ~= true or position > #order then
                finish()
                return
            end
            local chestIndex = order[position]
            setStatus(
                string.format("Treasure floor: moving to chest %s/%s", tostring(position), tostring(#order))
            )
            local chest: any = if type(physical) == "table" then physical[position] else nil
            local tpFn: any = deps.teleportTo
            if type(tpFn) == "function" and type(chest) == "table" and chest.cframe then
                pcall(tpFn, chest.cframe)
            end
            later(CHEST_TELEPORT_DELAY_SECONDS, function()
                if not self.active or getSettings().get("openTreasure") ~= true then
                    finish()
                    return
                end
                local events: any = deps.events
                local entry = if events then events.TreasureOpenChest else nil
                if type(entry) == "table" and type(entry.Fire) == "function" then
                    local fireFn: any = entry.Fire
                    if pcall(fireFn, { ChestIndex = chestIndex }) then
                        self.chests += 1
                        setStatus("Opened treasure chest " .. tostring(position) .. "/" .. tostring(#order))
                    end
                end
                later(CHEST_GAP_SECONDS, function()
                    step(position + 1)
                end)
            end)
        end
        step(1)
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
        runOpenChests(info)
    end

    -- After an Elite floor the game may offer one unit of the starting loadout (UnitRewardEvent: "Offer", answered
    -- with FireServer("Pick", index); the server then sends "Close"). The run waits for the answer.
    local function onUnitReward(kind: any, data: any)
        if kind == "Close" then
            endTask("unit reward")
            return
        end
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
        if remote == nil then
            setStatus("Auto Choose Unit Reward: reward remote missing")
            return
        end
        beginTask("unit reward")
        local function answer()
            if not self.active or getSettings().get("autoUnitReward") ~= true then
                endTask("unit reward")
                return
            end
            -- Observed in the game's own panel: ("Pick", optionIndex) takes a unit, ("Skip", nil) declines the offer.
            local okFire = pcall(function()
                if index then
                    remote:FireServer("Pick", index)
                else
                    remote:FireServer("Skip", nil)
                end
            end)
            if okFire then
                if index then
                    self.units += 1
                end
                setStatus(
                    if index
                        then "Auto Choose Unit Reward: picked unit option " .. tostring(index)
                        else "Auto Choose Unit Reward: no unit to pick, skipped"
                )
            end
            -- The server sends "Close" once it accepted the answer; do not wait on it for ever.
            endTask("unit reward")
        end
        local taskApi: any = deps.task
        if type(taskApi) == "table" and type(taskApi.delay) == "function" then
            (taskApi.delay :: any)(PICK_DELAY_SECONDS, answer)
        else
            answer()
        end
    end

    -- A boss floor offers a Memoria or a Familiar for one unit (BossRewardOffer {Options {Kind, Rarity, Name}}):
    -- claim the rarest kind on a placed unit of the run's character, else skip (BossRewardSkip).
    local function onBossOffer(offer: any)
        if not self.active or getSettings().get("autoBossReward") ~= true or not deps.isAdventure() then
            return
        end
        local options: any = if type(offer) == "table" then offer.Options else nil
        local kind = Choice.pickBossReward(options)
        beginTask("boss reward")
        local function answer()
            endTask("boss reward")
            if not self.active or getSettings().get("autoBossReward") ~= true then
                return
            end
            local events: any = deps.events
            local guidOf: any = deps.placedUnitGuid
            local guid: any = nil
            if kind and type(guidOf) == "function" then
                guid = (guidOf :: any)(getSettings().get("character")) or (guidOf :: any)(nil)
            end
            local remoteName = if kind and guid then "BossRewardPick" else "BossRewardSkip"
            local entry = if events then events[remoteName] else nil
            if type(entry) ~= "table" or type(entry.Fire) ~= "function" then
                setStatus("Auto Boss Reward: remote missing")
                return
            end
            local fireFn: any = entry.Fire
            local ok = if remoteName == "BossRewardPick"
                then pcall(fireFn, { Kind = kind, TargetUnitGUID = guid })
                else pcall(fireFn)
            if ok then
                setStatus(
                    if remoteName == "BossRewardPick"
                        then "Auto Boss Reward: claimed a " .. tostring(kind)
                        else "Auto Boss Reward: skipped (nothing to claim)"
                )
            else
                setStatus("Auto Boss Reward: request failed")
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
    local lastSeed: string? = nil
    local failsafeFloor: any = nil
    local failsafeSince = 0
    local endSince: number? = nil
    local lastLobbyAt = -math.huge
    local lastNewRunAt = -math.huge
    local lastEndRunAt = -math.huge
    local function watchShop()
        local taskApi: any = deps.task
        if not self.active or type(taskApi) ~= "table" or type(taskApi.delay) ~= "function" then
            return
        end
        -- A new run: subscribe to its events again (stop and start restart this watcher).
        local seedOf: any = deps.runSeed
        local seed: string? = if type(seedOf) == "function" then (seedOf :: any)() else nil
        if seed ~= nil and lastSeed ~= nil and seed ~= lastSeed then
            lastSeed = seed
            self.stop()
            if self.start() then
                setStatus("New Adventure run: subscribed to its events again")
            end
            return
        end
        if seed ~= nil then
            lastSeed = seed
        end
        -- The run is over (end screen) or a floor runs too long: go back to the lobby; Auto Join starts the next run.
        local now0 = deps.clock()
        local floorDep: any = deps.floor
        local floorNow: any = if type(floorDep) == "function" then (floorDep :: any)() else nil
        if floorNow ~= failsafeFloor then
            failsafeFloor = floorNow
            failsafeSince = now0
        end
        local endShown: any = deps.endScreenShown
        local isEnd = type(endShown) == "function" and (endShown :: any)() == true
        if isEnd then
            endSince = if endSince then endSince else now0
        else
            endSince = nil
        end
        local saved0 = getSettings()
        local reason: string? = nil
        if
            isEnd
            and saved0.get("autoStartNewRun") == true
            and now0 - (endSince :: number) >= END_SCREEN_SECONDS
        then
            reason = "the run ended"
        elseif
            saved0.get("failsafe") == true
            and now0 - failsafeSince >= (tonumber(saved0.get("failsafeMinutes")) or 30) * 60
        then
            reason = "floor " .. tostring(floorNow) .. " ran too long"
        end
        -- Auto End Run: once the cleared floors reach the target, ask for the end-run preview (confirmed on reply).
        local endRemote: any = deps.endRun
        local target = tonumber(saved0.get("cashOutFloor"))
        if
            endRemote ~= nil
            and saved0.get("autoCashOut") == true
            and target ~= nil
            and type(floorNow) == "number"
            and floorNow - 1 >= target
            and not isEnd
            and now0 - lastEndRunAt >= LOBBY_RETRY_SECONDS
        then
            lastEndRunAt = now0
            if
                pcall(function()
                    endRemote:FireServer("RequestPreview", nil)
                end)
            then
                setStatus(
                    "Auto End Run: floor " .. tostring(floorNow - 1) .. " cleared, asking to end the run"
                )
            end
        end
        -- A finished run starts again in place with New Run; the lobby is the fallback when that does not move on.
        if
            isEnd
            and saved0.get("autoStartNewRun") == true
            and now0 - (endSince :: number) >= END_SCREEN_SECONDS
            and now0 - (endSince :: number) < END_SCREEN_SECONDS + NEW_RUN_FALLBACK_SECONDS
        then
            reason = nil
            if now0 - lastNewRunAt >= LOBBY_RETRY_SECONDS then
                local newRunFn: any = deps.newRun
                if type(newRunFn) == "function" and (newRunFn :: any)() then
                    lastNewRunAt = now0
                    setStatus("Run ended: voted New Run")
                end
            end
        end
        if reason and now0 - lastLobbyAt >= LOBBY_RETRY_SECONDS then
            local backFn: any = deps.returnToLobby
            if type(backFn) == "function" and (backFn :: any)() then
                lastLobbyAt = now0
                setStatus("Returning to the lobby: " .. reason)
            end
        end
        local ok = pcall(function()
            local floorOf: any = deps.floor
            local floor = if type(floorOf) == "function" then (floorOf :: any)() else nil
            if floor ~= lastFloorSeen then
                lastFloorSeen = floor
                shopHandled = false
                floorTasks = {}
                treasureHandling = false
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
            -- The shop window can stay on screen after the shop closed; it blocks the next room vote.
            local closeShopFn: any = deps.closeShopUi
            if wanted and type(closeShopFn) == "function" and deps.isAdventure() then
                local inShop = type(roomKindOf) == "function" and (roomKindOf :: any)() == "Shop"
                local closedLongAgo = shopClosedAt > -math.huge
                    and now - shopClosedAt >= SHOP_UI_GRACE_SECONDS
                if (not inShop or closedLongAgo) and (closeShopFn :: any)() == true then
                    setStatus("Closed the Stitches' Shop window left open")
                end
            end
            if saved.get("openTreasure") == true and not treasureHandling and deps.isAdventure() then
                local kind = if type(roomKindOf) == "function" then (roomKindOf :: any)() else nil
                local getChestsFn: any = deps.getUnopenedChests
                local physical = if type(getChestsFn) == "function" then (getChestsFn :: any)() else nil
                if kind == "Treasure" or (type(physical) == "table" and #physical > 0) then
                    if floor ~= lastTreasureFloor then
                        lastTreasureFloor = floor
                        runOpenChests()
                    end
                end
            end
            if saved.get("autoBasicCard") == true and deps.isAdventure() then
                local readOfferFn: any = deps.readActiveCardOffer
                if type(readOfferFn) == "function" then
                    local activeOffer = (readOfferFn :: any)()
                    if
                        type(activeOffer) == "table"
                        and type(activeOffer.Options) == "table"
                        and #activeOffer.Options > 0
                    then
                        onBasicOffer(activeOffer)
                    end
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
            BossRewardOffer = onBossOffer,
            -- Hub loaded while a shop was already open: its first stock update stands in for the opening.
            ShopStockUpdated = function(info: any)
                if not shopHandled then
                    onShopOpened(info)
                end
            end,
            ShopClosed = function()
                shopHandled = false
                endTask("shop")
                shopClosedAt = deps.clock()
            end,
            VoteEnded = function()
                voteOpen = false
                voteAttempts = 0
                closeMapLater()
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
        local endRemote: any = deps.endRun
        if endRemote ~= nil then
            local okEnd, endConnection = pcall(function()
                return endRemote.OnClientEvent:Connect(function(kind: any, data: any)
                    local saved = getSettings()
                    if not self.active or saved.get("autoCashOut") ~= true then
                        return
                    end
                    local target = tonumber(saved.get("cashOutFloor")) or math.huge
                    if kind == "Preview" and type(data) == "table" and data.Token ~= nil then
                        local cleared = tonumber(data.FloorsCleared) or 0
                        if cleared >= target then
                            pcall(function()
                                endRemote:FireServer("Confirm", data.Token)
                            end)
                            setStatus("Auto End Run: ending the run at " .. tostring(cleared) .. " floors")
                        end
                    elseif kind == "Completed" then
                        setStatus("Auto End Run: run ended")
                        if saved.get("autoStartNewRun") == true then
                            local replayTask: any = deps.task
                            local function replay()
                                if self.active then
                                    pcall(function()
                                        endRemote:FireServer("Replay", nil)
                                    end)
                                    setStatus("Auto End Run: started a new run")
                                end
                            end
                            if type(replayTask) == "table" and type(replayTask.delay) == "function" then
                                (replayTask.delay :: any)(END_SCREEN_SECONDS, replay)
                            else
                                replay()
                            end
                        end
                    elseif kind == "Rejected" then
                        setStatus("Auto End Run: the game refused to end the run now")
                    end
                end)
            end)
            if okEnd and endConnection then
                table.insert(disconnects, function()
                    endConnection:Disconnect()
                end)
            end
        end
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
        return true
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
