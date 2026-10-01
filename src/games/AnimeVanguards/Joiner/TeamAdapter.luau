--!strict
--[[
Purpose: Read the player's saved teams and equipped units and ask the game to load a saved team
Input: Game modules (OwnedUnitsHandler, TeamsDataHandler, lobby and match team networks); optional injected test doubles
Output: Team adapter with getTeams, isSlotOwned, ownsUnit, getEquipped, onChanged, loadTeam and unit equip helpers
Dependencies: Config; TeamEquip
]]

local config = require("../Config")
local TeamEquip = require("./TeamEquip")
local Adapter = {}

local function resolve(root: any, path: string): any
    local value = root
    for part in string.gmatch(path, "[^%.]+") do
        if not value then
            return nil
        end
        local ok, child = pcall(function()
            local v: any = value
            if type(v) == "userdata" then
                return v:FindFirstChild(part)
            else
                return v[part]
            end
        end)
        value = if ok then child else nil
    end
    return value
end

local function optionalModule(root: any, path: string): any
    local ok, result = pcall(function()
        return (require :: any)(resolve(root, path))
    end)
    return if ok then result else nil
end

local function liveDependencies(): any?
    local env: any = getfenv()
    local gameObject = env.game
    if not gameObject then
        return nil
    end
    local replicated = gameObject:GetService("ReplicatedStorage")
    local starter = gameObject:GetService("StarterPlayer")
    return {
        ownedUnits = optionalModule(starter, config.instancePaths.ownedUnits),
        teamsData = optionalModule(starter, config.instancePaths.teamsData),
        lobbyTeams = optionalModule(replicated, config.instancePaths.lobbyTeamsClient),
        gameUnits = optionalModule(replicated, config.instancePaths.gameUnitsClient),
        unitActions = optionalModule(replicated, config.instancePaths.lobbyUnitActionsClient),
        popupHandler = optionalModule(starter, config.instancePaths.popupHandler),
        notifications = optionalModule(starter, config.instancePaths.notifications),
    }
end

--- Creates a team adapter; injected dependencies support isolated tests. inMatch selects the match network.
function Adapter.new(injected: any?, inMatch: boolean?): any
    local self: any = { dependencies = injected }
    local SUPPRESS_SECONDS = 15
    local suppressUntil = -math.huge
    local guards: { any } = {}

    local function now(): number
        local injectedClock = self.dependencies and self.dependencies.clock
        return if type(injectedClock) == "function" then (injectedClock :: any)() else os.clock()
    end

    local function isLoadedMessage(value: any): boolean
        local text = if type(value) == "table" then value.Text else value
        return type(text) == "string" and string.find(text, "^Successfully ") ~= nil
    end

    -- Wraps a game UI function so that, only while this script has just asked for a team, the game's own
    -- "Successfully ..." popup or toast (loaded team, unequipped familiar, ...) is dropped. Everything else, including the player's own loads
    -- outside that window, reaches the original function unchanged.
    local function guard(target: any, name: string)
        if type(target) ~= "table" or type(target[name]) ~= "function" then
            return
        end
        for _, entry in guards do
            if entry.target == target and entry.name == name then
                return
            end
        end
        local original = target[name]
        local function wrapper(...)
            if now() < suppressUntil then
                local args = table.pack(...)
                for index = 2, args.n do
                    if isLoadedMessage(args[index]) then
                        return nil
                    end
                end
            end
            return original(...)
        end
        local ok = pcall(function()
            target[name] = wrapper
        end)
        if ok then
            table.insert(guards, { target = target, name = name, original = original, wrapper = wrapper })
        end
    end

    --- Restores the game's UI functions that were wrapped to hide the "Successfully loaded" messages.
    function self.stop()
        for _, entry in guards do
            if entry.target[entry.name] == entry.wrapper then
                pcall(function()
                    entry.target[entry.name] = entry.original
                end)
            end
        end
        table.clear(guards)
        suppressUntil = -math.huge
    end

    local function deps(): any
        if not self.dependencies then
            local ok, result = pcall(liveDependencies)
            if ok then
                self.dependencies = result
            end
        end
        return self.dependencies
    end

    --- True once the game has loaded both the saved teams and the owned team slots.
    function self.isReady(): boolean
        local d = deps()
        local data = d and d.teamsData
        if not data or type(data.GetTeams) ~= "function" then
            return false
        end
        if data.Loaded == false then
            return false
        end
        if type(data.GetOwnedSlots) == "function" then
            local ok, slots = pcall(data.GetOwnedSlots)
            if not ok or type(slots) ~= "table" then
                return false
            end
        end
        return true
    end

    --- Returns the saved teams table (TeamN -> {Name, Units}), or nil until the game has loaded it.
    function self.getTeams(): any
        local d = deps()
        local data = d and d.teamsData
        if not data or type(data.GetTeams) ~= "function" or not self.isReady() then
            return nil
        end
        local ok, teams = pcall(data.GetTeams)
        return if ok and type(teams) == "table" then teams else nil
    end

    --- Returns true when the player owns the team slot (1-12 base, purchased slots above).
    function self.isSlotOwned(number: number): boolean
        local d = deps()
        local data = d and d.teamsData
        if not data or type(data.IsSlotOwned) ~= "function" then
            return false
        end
        local ok, owned = pcall(data.IsSlotOwned, number)
        return ok and owned == true
    end

    --- Returns true when a unit GUID still exists in the player's inventory.
    function self.ownsUnit(guid: string): boolean
        local d = deps()
        local owned = d and d.ownedUnits
        if not owned or type(owned.GetUnitObject) ~= "function" then
            return false
        end
        local ok, unit = pcall(owned.GetUnitObject, guid)
        return ok and unit ~= nil
    end

    --- Returns the equipped unit GUIDs by slot (1-6), or an empty table when unavailable.
    function self.getEquipped(): any
        local d = deps()
        local owned = d and d.ownedUnits
        if not owned or type(owned.GetEquippedUnits) ~= "function" then
            return {}
        end
        local ok, equipped = pcall(owned.GetEquippedUnits)
        return if ok and type(equipped) == "table" then equipped else {}
    end

    --- Registers a callback for team or slot changes; returns a function that removes it (nil when unsupported).
    function self.onChanged(callback: () -> ()): (() -> ())?
        local d = deps()
        local data = d and d.teamsData
        if not data then
            return nil
        end
        local connections: { any } = {}
        for _, name in { "TeamUpdated", "SlotPurchased", "TeamsLoaded" } do
            local signal = data[name]
            if type(signal) == "table" and type(signal.Connect) == "function" then
                local ok, connection = pcall(signal.Connect, signal, callback)
                if ok and connection then
                    table.insert(connections, connection)
                end
            end
        end
        return function()
            for _, connection in connections do
                pcall(function()
                    (connection :: any):Disconnect()
                end)
            end
            table.clear(connections)
        end
    end

    --- Returns every owned unit as {guid, name, level, subTrait, ascensions, takedowns}.
    function self.ownedUnitList(): { any }
        local d = deps()
        local owned = d and d.ownedUnits
        if
            not owned
            or type(owned.GetOwnedUnits) ~= "function"
            or type(owned.GetUnitObject) ~= "function"
        then
            return {}
        end
        local ok, all = pcall(owned.GetOwnedUnits)
        if not ok or type(all) ~= "table" then
            return {}
        end
        local list: { any } = {}
        for guid in all do
            local okUnit, unit = pcall(owned.GetUnitObject, guid)
            if okUnit and type(unit) == "table" and type(unit.UnitData) == "table" then
                local name = unit.UnitData.Name
                if type(guid) == "string" and type(name) == "string" then
                    table.insert(list, {
                        guid = guid,
                        name = name,
                        level = if type(unit.Level) == "number" then unit.Level else 0,
                        subTrait = if type(unit.SubTrait) == "string" then unit.SubTrait else "None",
                        ascensions = if type(unit.Ascensions) == "number" then unit.Ascensions else 0,
                        takedowns = if type(unit.Takedowns) == "number" then unit.Takedowns else 0,
                    })
                end
            end
        end
        return list
    end

    --- Returns the equipped units in slot order as {guid, name}.
    function self.equippedList(): { any }
        local d = deps()
        local owned = d and d.ownedUnits
        local equipped = self.getEquipped()
        local list: { any } = {}
        for slot = 1, 6 do
            local guid = equipped[slot]
            if type(guid) == "string" and owned and type(owned.GetUnitObject) == "function" then
                local ok, unit = pcall(owned.GetUnitObject, guid)
                if
                    ok
                    and type(unit) == "table"
                    and type(unit.UnitData) == "table"
                    and type(unit.UnitData.Name) == "string"
                then
                    table.insert(list, { guid = guid, name = unit.UnitData.Name })
                end
            end
        end
        return list
    end

    --- Unequips every unit (observed payload {NonFarmsOnly = false}); confirmation is a later readback.
    function self.unequipAll(): boolean
        local d = deps()
        local remote = d and d.unitActions and d.unitActions[config.remoteNames.unequipAllUnits]
        if not remote or type(remote.Fire) ~= "function" then
            return false
        end
        return (pcall(remote.Fire, { NonFarmsOnly = false }))
    end

    --- Equips a unit into the first free slot (observed payload {UnitGUID = guid}); ignored by the game when full.
    function self.equipUnit(guid: string): boolean
        if type(guid) ~= "string" or guid == "" then
            return false
        end
        local d = deps()
        local remote = d and d.unitActions and d.unitActions[config.remoteNames.equipUnit]
        if not remote or type(remote.Fire) ~= "function" then
            return false
        end
        return (pcall(remote.Fire, { UnitGUID = guid }))
    end

    --- Asks the game to load a saved team (observed payload {TeamKey = "TeamN"}); confirmation is a later readback.
    function self.loadTeam(key: string): boolean
        if not TeamEquip.validKey(key) then
            return false
        end
        local d = deps()
        local remote = if inMatch
            then (d and d.gameUnits and d.gameUnits[config.remoteNames.requestLoadTeam])
            else (d and d.lobbyTeams and d.lobbyTeams[config.remoteNames.loadTeam])
        if not remote or type(remote.Fire) ~= "function" then
            return false
        end
        local d2 = deps()
        guard(d2 and d2.popupHandler, "ShowPopup")
        guard(d2 and d2.notifications, "CreateNotification")
        suppressUntil = now() + SUPPRESS_SECONDS
        return (pcall(remote.Fire, { TeamKey = key }))
    end

    return self
end

return Adapter
