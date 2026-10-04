--!strict
--[[
Purpose: Validate and persist the Odyssey: Adventure tab choices (no automation reads them yet)
Input: A catalog of valid option names and optional storage/codec dependencies
Output: A settings object: get, set, swap, order, resetOrder and whether changes are saved to file
Dependencies: Config; FileStorage
]]

local FileStorage = require("../../../platform/FileStorage")
local config = require("../Config")
local Settings = {}

local ADVENTURE: any = (config :: any).adventure
local SCHEMA_VERSION = 1
local NONE = "None"
local MAX_TEXT = 64
local MAX_RANK = 999

Settings.NONE = NONE
Settings.MAX_RANK = MAX_RANK

-- Field kinds: bool, choice (one catalog name), number (clamped integer), set (subset), ranks (name -> priority
-- number; the highest number comes first, like the reference UI).
local FIELDS: { [string]: any } = {
    autoJoin = { kind = "bool", default = false },
    character = { kind = "choice", list = "characters" },
    slot1 = { kind = "choice", list = "powers", none = true },
    slot2 = { kind = "choice", list = "powers", none = true },
    autoRoute = { kind = "bool", default = false },
    leaveShop = { kind = "bool", default = true },
    openTreasure = { kind = "bool", default = true },
    closeMap = { kind = "bool", default = true },
    autoStartFloors = { kind = "bool", default = true },
    secondPriorityFloor = { kind = "number", range = ADVENTURE.secondPriorityFloor },
    floorPriority = { kind = "ranks", list = "roomKinds", default = ADVENTURE.floorPriority },
    secondFloorPriority = { kind = "ranks", list = "roomKinds", default = ADVENTURE.secondFloorPriority },
    autoUnitReward = { kind = "bool", default = false },
    autoBuyItches = { kind = "bool", default = false },
    autoCharacterCard = { kind = "bool", default = false },
    autoBasicCard = { kind = "bool", default = false },
    cardPriority = { kind = "ranks", list = "basicCards" },
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

-- The default order: names from the spec default first, then the rest in catalog order.
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

-- Default ranks: the first name of the default order gets the highest number, the last gets 1.
local function defaultRanks(spec: any, list: { string }): { [string]: number }
    local order = defaultOrder(spec, list)
    local ranks: { [string]: number } = {}
    for index, name in order do
        ranks[name] = #order - index + 1
    end
    return ranks
end

-- Names sorted by rank, highest first; equal ranks keep the default order.
local function rankedOrder(spec: any, list: { string }, ranks: { [string]: number }): { string }
    local order = defaultOrder(spec, list)
    local position: { [string]: number } = {}
    for index, name in order do
        position[name] = index
    end
    table.sort(order, function(a: string, b: string): boolean
        local left, right = ranks[a] or 0, ranks[b] or 0
        if left ~= right then
            return left > right
        end
        return position[a] < position[b]
    end)
    return order
end

local function validRank(value: any): number?
    if not finite(value) then
        return nil
    end
    return math.clamp(math.floor(value), 0, MAX_RANK)
end

local function defaultValue(spec: any, catalog: any): any
    if spec.kind == "choice" then
        return if spec.none then NONE else catalog.defaultCharacter
    elseif spec.kind == "number" then
        return spec.range.default
    elseif spec.kind == "set" then
        return {}
    elseif spec.kind == "ranks" then
        return defaultRanks(spec, catalog[spec.list])
    end
    return spec.default
end

-- Returns the validated value or nil. Ranks keep known names only (missing ones rank 0); an array is read as an
-- order list (first = highest), the format saved before ranks existed.
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
    if spec.kind == "ranks" then
        local ranks: { [string]: number } = {}
        if value[1] ~= nil then
            local order = {}
            for _, name in value do
                if type(name) == "string" and table.find(list, name) and not table.find(order, name) then
                    table.insert(order, name)
                end
            end
            for _, name in defaultOrder(spec, list) do
                if not table.find(order, name) then
                    table.insert(order, name)
                end
            end
            for index, name in order do
                ranks[name] = #order - index + 1
            end
            return ranks
        end
        for _, name in list do
            ranks[name] = validRank(value[name]) or 0
        end
        return ranks
    end
    local result = {}
    for _, name in value do
        if type(name) == "string" and table.find(list, name) and not table.find(result, name) then
            table.insert(result, name)
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

    --- Returns one value (tables are copies).
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

    --- Swaps two names in a ranks field's order and renumbers the list (first = highest number); returns true when
    --- both names exist and differ.
    function self.swap(key: string, first: any, second: any): boolean
        local spec = FIELDS[key]
        if not spec or spec.kind ~= "ranks" or type(first) ~= "string" or type(second) ~= "string" then
            return false
        end
        local order = rankedOrder(spec, catalog[spec.list], values[key])
        local a, b = table.find(order, first), table.find(order, second)
        if not a or not b or a == b then
            return false
        end
        order[a], order[b] = order[b], order[a]
        local ranks: { [string]: number } = {}
        for position, entry in order do
            ranks[entry] = #order - position + 1
        end
        values[key] = ranks
        save()
        return true
    end

    --- Returns a ranks field as names sorted highest number first (empty for other fields).
    function self.order(key: string): { string }
        local spec = FIELDS[key]
        if not spec or spec.kind ~= "ranks" then
            return {}
        end
        return rankedOrder(spec, catalog[spec.list], values[key])
    end

    --- Restores a ranks field to its default numbers; returns the resulting order.
    function self.resetOrder(key: string): { string }
        local spec = FIELDS[key]
        if spec and spec.kind == "ranks" then
            values[key] = defaultRanks(spec, catalog[spec.list])
            save()
        end
        return self.order(key)
    end

    return self
end

return Settings
