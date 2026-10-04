--!strict
--[[
Purpose: Odyssey: Adventure lobby adapter: read the game's Adventure state, validate the chosen character and power
         slots against it and start a run through the game's own remotes
Input: Special events client (lobby remotes), Adventure settings/catalog and optional character data; all injectable
Output: plan() -> validated start plan or a reason; start(plan) -> whether the request was sent; connect()/stop()
Dependencies: Config; Adventure/Catalog; Adventure/Settings
]]

local config = require("../Config")
local Catalog = require("./Catalog")
local Settings = require("./Settings")
local Adapter = {}

local REMOTES: any = (config :: any).remoteNames
local RETRY_SECONDS: number = (config :: any).thresholds.adventureStateRetrySeconds
local MAX_AGE_SECONDS: number = (config :: any).thresholds.adventureStateMaxAgeSeconds

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
    local replicated = env.game:GetService("ReplicatedStorage")
    local paths: any = config.instancePaths
    return {
        task = env.task,
        clock = os.clock,
        specialEvents = optionalModule(replicated, paths.specialEventsClient),
        characters = optionalModule(replicated, paths.adventureCharacters),
    }
end

-- Decodes the game's full-state payload: characters by name, with their unlocked power ids as a set.
local function decodeState(payload: any): any?
    if type(payload) ~= "table" or type(payload.Characters) ~= "table" then
        return nil
    end
    local characters: { [string]: any } = {}
    local owns = payload.OwnsLoadoutSlot2 == true
    local global: { [number]: boolean } = {}
    if type(payload.UnlockedPowerIds) == "table" then
        for _, id in payload.UnlockedPowerIds do
            if type(id) == "number" then
                global[id] = true
            end
        end
    end
    for _, entry in payload.Characters do
        if type(entry) == "table" and type(entry.CharacterName) == "string" then
            local unlocked: { [number]: boolean } = {}
            if type(entry.UnlockedPowerIds) == "table" then
                for _, id in entry.UnlockedPowerIds do
                    if type(id) == "number" then
                        unlocked[id] = true
                    end
                end
            end
            local loadout: any = if type(entry.Loadout) == "table" then entry.Loadout else {}
            characters[entry.CharacterName] = {
                unlocked = unlocked,
                slot1 = if type(loadout.Slot1) == "number" then loadout.Slot1 else nil,
                slot2 = if type(loadout.Slot2) == "number" then loadout.Slot2 else nil,
                ownsSlot2 = entry.OwnsLoadoutSlot2 == true,
            }
            owns = owns or entry.OwnsLoadoutSlot2 == true
        end
    end
    return { characters = characters, global = global, ownsSlot2 = owns }
end

--- Creates a stopped adapter; injected dependencies (specialEvents, characters, clock, catalog, settings) support tests.
function Adapter.new(injected: any?): any
    local deps: any = injected
    local self: any = { state = nil, stateAt = 0, lastRequest = -math.huge }
    local disconnect: (() -> ())? = nil
    local catalog: any = if injected then injected.catalog else nil
    local settings: any = if injected then injected.settings else nil
    local clock: () -> number = if injected and injected.clock then injected.clock else os.clock

    -- Live modules are read on first use: the adapter is created when the hub loads, before the game is ready.
    local function dependencies(): any
        if not deps then
            deps = liveDependencies()
        end
        return deps
    end

    --- The catalog of option names, read from the game once.
    function self.getCatalog(): any
        if not catalog then
            catalog = Catalog.read()
        end
        return catalog
    end

    --- The saved Adventure choices (one shared instance for the page and the joiner).
    function self.getSettings(): any
        if not settings then
            settings = Settings.new(self.getCatalog())
        end
        return settings
    end

    local function remote(name: string): any
        local events: any = dependencies().specialEvents
        local entry = if type(events) == "table" then events[REMOTES[name]] else nil
        return if type(entry) == "table" then entry else nil
    end

    local function fire(name: string, payload: any?): boolean
        local entry = remote(name)
        if not entry or type(entry.Fire) ~= "function" then
            return false
        end
        local fireFn: any = entry.Fire
        return (pcall(fireFn, payload))
    end

    --- Subscribes to the game's Adventure state; safe to repeat. Returns whether the subscription exists.
    function self.connect(): boolean
        if disconnect then
            return true
        end
        local entry = remote("adventureState")
        if not entry or type(entry.On) ~= "function" then
            return false
        end
        local onFn: any = entry.On
        local ok, result = pcall(onFn, function(payload: any)
            local decoded = decodeState(payload)
            if decoded then
                self.state = decoded
                self.stateAt = clock()
            end
        end)
        if not ok then
            return false
        end
        disconnect = if type(result) == "function" then result else function() end
        return true
    end

    --- Asks the game for the full state (rate limited); the reply arrives through the subscription.
    function self.requestState()
        local now = clock()
        if now - self.lastRequest < RETRY_SECONDS then
            return
        end
        self.lastRequest = now
        fire("requestAdventureState", nil)
    end

    local function characterAvailable(name: string): boolean
        local module: any = dependencies().characters
        if type(module) ~= "table" or type(module.IsCharacterAvailable) ~= "function" then
            return true
        end
        local ok, available = pcall(module.IsCharacterAvailable, name)
        return not ok or available ~= false
    end

    -- A slot's power id when the player owns it, else nil with the reason appended to notes.
    local function slotId(
        label: string,
        powerName: string,
        owned: (number) -> boolean,
        notes: { string }
    ): number?
        if powerName == Settings.NONE then
            return nil
        end
        local id = self.getCatalog().powerIds[powerName]
        if id == nil then
            table.insert(notes, label .. ": unknown power " .. powerName)
            return nil
        end
        if not owned(id) then
            table.insert(notes, label .. ": " .. powerName .. " is not unlocked")
            return nil
        end
        return id
    end

    --- Builds the start plan from the saved choices and the game's state, or returns nil and the reason.
    function self.plan(): (any?, string?)
        self.connect()
        local state = self.state
        if not state or clock() - self.stateAt > MAX_AGE_SECONDS then
            self.requestState()
            return nil, "waiting for Adventure data from the game"
        end
        local saved = self.getSettings()
        local character: string = saved.get("character")
        local entry = state.characters[character]
        if not entry then
            return nil, character .. " is not available on this account"
        end
        if not characterAvailable(character) then
            return nil, character .. " is not available yet"
        end
        local notes: { string } = {}
        local function owned(id: number): boolean
            return entry.unlocked[id] == true or state.global[id] == true
        end
        local slot1 = slotId("Slot 1", saved.get("slot1"), owned, notes)
        local slot2: number? = nil
        if saved.get("slot2") ~= Settings.NONE then
            if state.ownsSlot2 or entry.ownsSlot2 then
                slot2 = slotId("Slot 2", saved.get("slot2"), owned, notes)
            else
                table.insert(notes, "Slot 2: Loadout Slot 2 is not owned")
            end
        end
        return { character = character, slot1 = slot1, slot2 = slot2, notes = notes, saved = entry }, nil
    end

    --- Sends the loadout (only when it changed) and the start request; returns whether the start was sent.
    function self.start(plan: any): boolean
        if type(plan) ~= "table" then
            return false
        end
        local saved: any = plan.saved
        if type(saved) == "table" and (saved.slot1 ~= plan.slot1 or saved.slot2 ~= plan.slot2) then
            fire(
                "setAdventureLoadout",
                { CharacterName = plan.character, Slot1 = plan.slot1, Slot2 = plan.slot2 }
            )
        end
        return fire("startOdysseyAdventure", {
            LoadoutProvided = true,
            CharacterName = plan.character,
            Slot1 = plan.slot1,
            Slot2 = plan.slot2,
        })
    end

    --- Drops the subscription; safe to repeat.
    function self.stop()
        local undo = disconnect
        disconnect = nil
        if undo then
            pcall(undo)
        end
    end

    return self
end

return Adapter
