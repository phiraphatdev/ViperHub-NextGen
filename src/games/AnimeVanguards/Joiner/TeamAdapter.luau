--!strict
--[[
Purpose: Read the player's saved teams and equipped units and ask the game to load a saved team
Input: Game modules (OwnedUnitsHandler, TeamsDataHandler, lobby and match team networks); optional injected test doubles
Output: Team adapter with getTeams, isSlotOwned, ownsUnit, getEquipped, onChanged and loadTeam
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
    }
end

--- Creates a team adapter; injected dependencies support isolated tests. inMatch selects the match network.
function Adapter.new(injected: any?, inMatch: boolean?): any
    local self: any = { dependencies = injected }

    local function deps(): any
        if not self.dependencies then
            local ok, result = pcall(liveDependencies)
            if ok then
                self.dependencies = result
            end
        end
        return self.dependencies
    end

    --- Returns the saved teams table (TeamN -> {Name, Units}), or nil until the game has loaded it.
    function self.getTeams(): any
        local d = deps()
        local data = d and d.teamsData
        if not data or type(data.GetTeams) ~= "function" then
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
        return (pcall(remote.Fire, { TeamKey = key }))
    end

    return self
end

return Adapter
