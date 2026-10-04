--!strict
--[[
Purpose: Validate and persist the Odyssey: Adventure tab choices (no automation reads them yet)
Input: A catalog of valid option names and optional storage/codec dependencies
Output: A settings object: get, set, moveUp, resetOrder and whether changes are saved to file
Dependencies: Config; FileStorage
]]

local FileStorage = require("../../../platform/FileStorage")
local config = require("../Config")
local Settings = {}

local ADVENTURE: any = (config :: any).adventure
local SCHEMA_VERSION = 1
local NONE = "None"
local MAX_TEXT = 64

Settings.NONE = NONE

-- Field kinds: bool, choice (one catalog name), number (clamped integer), set (subset), order (full permutation).
local FIELDS: { [string]: any } = {
    autoJoin = { kind = "bool", default = false },
    character = { kind = "choice", list = "characters" },
    slot1 = { kind = "choice", list = "powers", none = true },
    slot2 = { kind = "choice", list = "powers", none = true },
    secondPriorityFloor = { kind = "number", range = ADVENTURE.secondPriorityFloor },
    floorPriority = { kind = "order", list = "roomKinds", default = ADVENTURE.floorPriority },
    secondFloorPriority = { kind = "order", list = "roomKinds", default = ADVENTURE.secondFloorPriority },
    autoUnitReward = { kind = "bool", default = false },
    autoBuyItches = { kind = "bool", default = false },
    autoCharacterCard = { kind = "bool", default = false },
    autoBasicCard = { kind = "bool", default = false },
    cardPriority = { kind = "order", list = "basicCards" },
    autoStitchesShop = { kind = "bool", default = false },
    buyBasicCards = { kind = "set", list = "basicCards" },
    buyStarterCards = { kind = "set", list = "powers" },
    buyTraits = { kind = "set", list = "traits" },
    buyMemoria = { kind = "set", list = "memoriaRarities" },
    autoCashOut = { kind = "bool", default = false },
    cashOutFloor = { kind = "number", range = ADVENTURE.cashOutFloor },
    autoStartNewRun = { kind = "bool", default = false },
    autoAscension = { kind = "bool", default = false },
    autoMemorized = { kind = "bool", default = false },
    memoria = { kind = "text", default = NONE },
    failsafe = { kind = "bool", default = false },
    failsafeMinutes = { kind = "number", range = ADVENTURE.failsafeMinutes },
}
Settings.FIELDS = FIELDS

local function finite(value: any): boolean
    return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

-- Orders the default list so that known names come first in the given order and the rest keep catalog order.
local function defaultOrder(spec: any, list: { string }): { string }
    local result = {}
    if spec.default then
        for _, name in spec.default do
            if table.find(list, name) then
                table.insert(result, name)
            end
        end
    end
    for _, name in list do
        if not table.find(result, name) then
            table.insert(result, name)
        end
    end
    return result
end

local function defaultValue(spec: any, catalog: any): any
    if spec.kind == "choice" then
        return if spec.none then NONE else catalog.defaultCharacter
    elseif spec.kind == "number" then
        return spec.range.default
    elseif spec.kind == "set" then
        return {}
    elseif spec.kind == "order" then
        return defaultOrder(spec, catalog[spec.list])
    end
    return spec.default
end

-- Returns the validated value or nil; order lists keep unknown names out and append missing ones.
local function validate(spec: any, catalog: any, value: any): any
    if spec.kind == "bool" then
        return if type(value) == "boolean" then value else nil
    elseif spec.kind == "choice" then
        if type(value) ~= "string" then
            return nil
        end
        if spec.none and value == NONE then
            return value
        end
        return if table.find(catalog[spec.list], value) then value else nil
    elseif spec.kind == "number" then
        if not finite(value) then
            return nil
        end
        return math.clamp(math.floor(value), spec.range.min, spec.range.max)
    elseif spec.kind == "text" then
        return if type(value) == "string" and #value > 0 and #value <= MAX_TEXT then value else nil
    elseif type(value) ~= "table" then
        return nil
    end
    local list = catalog[spec.list]
    local result = {}
    for _, name in value do
        if type(name) == "string" and table.find(list, name) and not table.find(result, name) then
            table.insert(result, name)
        end
    end
    if spec.kind == "order" then
        for _, name in defaultOrder(spec, list) do
            if not table.find(result, name) then
                table.insert(result, name)
            end
        end
    end
    return result
end

local function liveDependencies(): any?
    local env: any = getfenv()
    if not env.game then
        return nil
    end
    local http = env.game:GetService("HttpService")
    return {
        storage = FileStorage.new(env, ADVENTURE.storageKey),
        encode = function(value: any): string
            return http:JSONEncode(value)
        end,
        decode = function(text: string): any
            return http:JSONDecode(text)
        end,
    }
end

--- Creates settings for the given catalog and loads the saved file once; injected dependencies support tests.
function Settings.new(catalog: any, injected: any?): any
    local deps = injected or liveDependencies()
    local values: { [string]: any } = {}
    for key, spec in FIELDS do
        values[key] = defaultValue(spec, catalog)
    end
    local storage = if deps then deps.storage else nil

    if storage then
        local body, readError = storage.read()
        if readError then
            -- Unreadable right now: keep the file instead of overwriting it; changes stay for this session.
            storage = nil
        elseif body then
            local ok, data = pcall(deps.decode, body)
            if not ok or type(data) ~= "table" or data.schemaVersion ~= SCHEMA_VERSION then
                storage = nil
            else
                for key, spec in FIELDS do
                    local value = validate(spec, catalog, data[key])
                    if value ~= nil then
                        values[key] = value
                    end
                end
            end
        end
    end

    local self: any = {}

    local function save()
        if not storage or not deps or type(deps.encode) ~= "function" then
            return
        end
        local document: { [string]: any } = { schemaVersion = SCHEMA_VERSION }
        for key, value in values do
            document[key] = value
        end
        local ok, body = pcall(deps.encode, document)
        if ok and type(body) == "string" then
            pcall(storage.write, body)
        end
    end

    --- True when changes are written to the settings file.
    function self.persistent(): boolean
        return storage ~= nil
    end

    --- Returns one value (lists are copies).
    function self.get(key: string): any
        local value = values[key]
        return if type(value) == "table" then table.clone(value) else value
    end

    --- Validates and stores one value; returns true when it was accepted.
    function self.set(key: string, value: any): boolean
        local spec = FIELDS[key]
        if not spec then
            return false
        end
        local valid = validate(spec, catalog, value)
        if valid == nil then
            return false
        end
        values[key] = valid
        save()
        return true
    end

    --- Moves a name one place up in an order list; returns true when it moved.
    function self.moveUp(key: string, name: any): boolean
        local spec = FIELDS[key]
        local order = values[key]
        if not spec or spec.kind ~= "order" or type(name) ~= "string" then
            return false
        end
        local index = table.find(order, name)
        if not index or index == 1 then
            return false
        end
        order[index], order[index - 1] = order[index - 1], order[index]
        save()
        return true
    end

    --- Restores an order list to its default; returns the new order.
    function self.resetOrder(key: string): { string }
        local spec = FIELDS[key]
        if spec and spec.kind == "order" then
            values[key] = defaultOrder(spec, catalog[spec.list])
            save()
        end
        return self.get(key)
    end

    return self
end

return Settings
