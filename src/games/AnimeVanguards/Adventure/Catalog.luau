--!strict
--[[
Purpose: Build the Odyssey: Adventure option lists (characters, powers, basic cards, room kinds, traits, memoria
         rarities) from the game's replicated data, falling back to the observed lists in Config
Input: Untrusted exports of CharactersData, PowersData, BasicCardPool and OdysseyTraitPool (any may be nil)
Output: A catalog of string lists; every list is non-empty
Dependencies: Config
]]

local config = require("../Config")
local Catalog = {}

local ADVENTURE: any = (config :: any).adventure
local ROMAN = { "I", "II", "III", "IV", "V" }
local MAX_NAME = 64

export type Data = {
    characters: { string },
    defaultCharacter: string,
    powers: { string },
    powerIds: { [string]: number },
    basicCards: { string },
    basicCardRarity: { [string]: string },
    roomKinds: { string },
    traits: { string },
    memoriaRarities: { string },
}

local function validName(value: any): boolean
    return type(value) == "string" and #value > 0 and #value <= MAX_NAME
end

local function copy(list: any): { string }
    local result = {}
    for _, name in list do
        table.insert(result, name)
    end
    return result
end

-- Character names from CharactersData.GetAllCharacters (a map keyed by name), sorted for a stable list.
local function readCharacters(module: any): { string }
    local result = {}
    if type(module) == "table" and type(module.GetAllCharacters) == "function" then
        local ok, all = pcall(module.GetAllCharacters)
        if ok and type(all) == "table" then
            for key, entry in all do
                local item: any = entry
                local name = if type(item) == "table" then item.Name else nil
                name = if validName(name) then name else key
                if validName(name) and not table.find(result, name) then
                    table.insert(result, name)
                end
            end
        end
    end
    table.sort(result)
    return result
end

-- Power names from PowersData.POWERS (an array ordered by id).
local function readPowers(module: any): { string }
    local result = {}
    if type(module) == "table" and type(module.POWERS) == "table" then
        for _, power in ipairs(module.POWERS) do
            local item: any = power
            if type(item) == "table" and validName(item.Name) and not table.find(result, item.Name) then
                table.insert(result, item.Name)
            end
        end
    end
    return result
end

-- Power ids by name from PowersData.POWERS (the lobby remotes take ids, not names).
local function readPowerIds(module: any): { [string]: number }
    local result: { [string]: number } = {}
    if type(module) == "table" and type(module.POWERS) == "table" then
        for _, power in ipairs(module.POWERS) do
            local item: any = power
            if type(item) == "table" and validName(item.Name) and type(item.Id) == "number" then
                result[item.Name] = item.Id
            end
        end
    end
    return result
end

-- Basic card names from BasicCardPool.CardsByRarity, highest rarity first, game order inside a rarity; fills rarity.
local function readBasicCards(module: any, rarityOf: { [string]: string }): { string }
    local result = {}
    local byRarity = if type(module) == "table" then module.CardsByRarity else nil
    if type(byRarity) ~= "table" then
        return result
    end
    for _, rarity in ADVENTURE.basicCardRarities do
        local list = byRarity[rarity]
        if type(list) == "table" then
            for _, card in ipairs(list) do
                local item: any = card
                local name = if type(item) == "table" then item.Name else item
                if validName(name) and not table.find(result, name) then
                    table.insert(result, name)
                    rarityOf[name] = rarity
                end
            end
        end
    end
    return result
end

-- Trait names from OdysseyTraitPool; traits with Tiers become "<name> I/II/III". Sorted by drop chance, common first.
local function readTraits(module: any): { string }
    local rows = {}
    if type(module) ~= "table" then
        return {}
    end
    for name, entry in module do
        if validName(name) and type(entry) == "table" then
            local chance = if type(entry.Chance) == "number" then entry.Chance else 0
            table.insert(rows, { name = name, chance = chance, tiers = entry.Tiers })
        end
    end
    table.sort(rows, function(a: any, b: any): boolean
        if a.chance ~= b.chance then
            return a.chance > b.chance
        end
        return a.name < b.name
    end)
    local result = {}
    for _, row in rows do
        if type(row.tiers) == "table" and #row.tiers > 0 then
            for index = 1, math.min(#row.tiers, #ROMAN) do
                table.insert(result, row.name .. " " .. ROMAN[index])
            end
        else
            table.insert(result, row.name)
        end
    end
    return result
end

local function pick(live: { string }, fallback: any): { string }
    return if #live > 0 then live else copy(fallback)
end

local function fallbackBasicCards(rarityOf: { [string]: string }): { string }
    local result = {}
    for _, rarity in ADVENTURE.basicCardRarities do
        for _, name in ADVENTURE.basicCards[rarity] do
            table.insert(result, name)
            rarityOf[name] = rarity
        end
    end
    return result
end

--- Builds the catalog from already-required game modules (fields may be nil); returns lists that are never empty.
function Catalog.fromModules(modules: any): Data
    local m = if type(modules) == "table" then modules else {}
    local characters = pick(readCharacters(m.characters), ADVENTURE.characters)
    local defaultCharacter: string = ADVENTURE.defaultCharacter
    if type(m.characters) == "table" and type(m.characters.GetDefaultCharacterName) == "function" then
        local ok, name = pcall(m.characters.GetDefaultCharacterName)
        if ok and validName(name) and table.find(characters, name) then
            defaultCharacter = name
        end
    end
    if not table.find(characters, defaultCharacter) then
        defaultCharacter = characters[1]
    end
    local powerIds = readPowerIds(m.powers)
    if next(powerIds) == nil then
        -- Observed: ids 1-14 follow the order of the config list.
        for index, name in ADVENTURE.powers do
            powerIds[name] = index
        end
    end
    local rarityOf: { [string]: string } = {}
    local basicCards = readBasicCards(m.basicCards, rarityOf)
    if #basicCards == 0 then
        rarityOf = {}
        basicCards = fallbackBasicCards(rarityOf)
    end
    local data: Data = {
        characters = characters,
        defaultCharacter = defaultCharacter,
        powers = pick(readPowers(m.powers), ADVENTURE.powers),
        powerIds = powerIds,
        basicCards = basicCards,
        basicCardRarity = rarityOf,
        roomKinds = copy(ADVENTURE.roomKinds),
        traits = pick(readTraits(m.traits), ADVENTURE.traits),
        memoriaRarities = copy(ADVENTURE.memoriaRarities),
    }
    return data
end

local function resolve(root: any, path: string): any
    local value: any = root
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

--- Reads the live catalog from ReplicatedStorage; any missing or failing module falls back to Config.
function Catalog.read(): Data
    local env: any = getfenv()
    local modules: any = {}
    pcall(function()
        local rep = env.game:GetService("ReplicatedStorage")
        local paths = config.instancePaths
        local wanted: { [string]: string } = {
            characters = paths.adventureCharacters,
            powers = paths.adventurePowers,
            basicCards = paths.adventureBasicCards,
            traits = paths.odysseyTraitPool,
        }
        for key, path in wanted do
            local object = resolve(rep, path)
            if object then
                local ok, result = pcall(require :: any, object)
                if ok then
                    modules[key] = result
                end
            end
        end
    end)
    return Catalog.fromModules(modules)
end

return Catalog
