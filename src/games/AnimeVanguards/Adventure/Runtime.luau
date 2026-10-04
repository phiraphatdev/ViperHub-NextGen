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
        mapRelay = optionalModule(env.game:GetService("StarterPlayer"), paths.adventureMapRelay),
        events = optionalModule(replicated, paths.gameOdysseyClient),
        isAdventure = function(): boolean
            return handler ~= nil and Detect.isAdventureMatch(handler.GameData)
        end,
    }
end

--- Creates a stopped controller; getSettings returns the shared Adventure settings (read lazily); deps are injectable.
function Runtime.new(getSettings: () -> any, injected: any?): any
    local self: any = { status = "Idle", picked = 0, routed = 0, onStatus = nil }
    local deps: any = injected
    local disconnects: { () -> () } = {}
    local lastKey = ""
    local lastAt = -math.huge
    local snapshot: any = nil
    local pendingRooms: any = nil
    local onRoomOffer: (any) -> ()
    local lastRoomKey = ""
    local lastRoomAt = -math.huge

    local function setStatus(text: string)
        self.status = text
        if self.onStatus then
            pcall(self.onStatus, text)
        end
    end

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

    -- A room selection: pick the next room by the floor priorities (the second list from the chosen floor on).
    onRoomOffer = function(offer: any)
        local saved = getSettings()
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
        if not index then
            setStatus("Auto Route Atlas: no valid room offered")
            return
        end
        local now = deps.clock()
        local key = "room:" .. #options .. ":" .. index
        if key == lastRoomKey and now - lastRoomAt < REPEAT_SECONDS then
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
        local ok, undo = pcall(onFn, onBasicOffer)
        if not ok then
            setStatus("Auto Basic Card: could not subscribe")
            return false
        end
        if type(undo) == "function" then
            table.insert(disconnects, undo)
        end
        local relay: any = deps.mapRelay
        if type(relay) == "table" and type(relay.OnSnapshot) == "function" then
            local okRelay, undoRelay = pcall(relay.OnSnapshot, function(data: any)
                snapshot = data
                local waiting = pendingRooms
                if waiting ~= nil then
                    onRoomOffer(waiting)
                end
            end)
            if okRelay and type(undoRelay) == "function" then
                table.insert(disconnects, undoRelay)
            end
        end
        local roomEntry = if type(events) == "table" then events.SelectRoomSelectionStarted else nil
        if type(roomEntry) == "table" and type(roomEntry.On) == "function" then
            local roomOn: any = roomEntry.On
            local okRoom, undoRoom = pcall(roomOn, onRoomOffer)
            if okRoom and type(undoRoom) == "function" then
                table.insert(disconnects, undoRoom)
            end
        end
        self.active = true
        setStatus("Listening for card and room offers")
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
