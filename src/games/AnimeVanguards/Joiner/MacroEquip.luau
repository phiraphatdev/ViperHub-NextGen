--!strict
--[[
Purpose: Pure Macro Equipper rules: pick the best owned unit per macro unit name and plan the equip steps
Input: Macro unit names, equipped units ({guid, name}) and owned units ({guid, name, level, subTrait, ascensions, takedowns})
Output: A plan (state, ordered unit GUIDs to equip, missing names) and valid macro file names
Dependencies: None
]]

local MacroEquip = {}

local MAX_UNITS = 6

export type Owned = {
    guid: string,
    name: string,
    level: number,
    subTrait: string,
    ascensions: number,
    takedowns: number,
}
export type Plan = { state: string, steps: { string }, missing: { string } }

--- Returns true for a macro file name the macro store accepts.
function MacroEquip.validName(name: any): boolean
    return type(name) == "string" and #name > 0 and #name <= 64 and string.match(name, "^[%w_%-]+$") ~= nil
end

local function hasSubTrait(unit: Owned): number
    return if unit.subTrait ~= "" and unit.subTrait ~= "None" then 1 else 0
end

-- True when a is better than b: higher level, then a sub-trait, more ascensions, more takedowns, then GUID order.
local function better(a: Owned, b: Owned): boolean
    if a.level ~= b.level then
        return a.level > b.level
    end
    if hasSubTrait(a) ~= hasSubTrait(b) then
        return hasSubTrait(a) > hasSubTrait(b)
    end
    if a.ascensions ~= b.ascensions then
        return a.ascensions > b.ascensions
    end
    if a.takedowns ~= b.takedowns then
        return a.takedowns > b.takedowns
    end
    return a.guid < b.guid
end

--- Returns the best owned unit with the given name, or nil when the player has none.
function MacroEquip.best(owned: { Owned }, name: string): Owned?
    local winner: Owned? = nil
    for _, unit in owned do
        if unit.name == name and (winner == nil or better(unit, winner)) then
            winner = unit
        end
    end
    return winner
end

--- Reduces macro unit names to at most six unique names in order (a team cannot hold the same unit twice).
function MacroEquip.names(units: any): { string }
    local result: { string } = {}
    local seen: { [string]: boolean } = {}
    if type(units) == "table" then
        for _, name in units do
            if type(name) == "string" and name ~= "" and not seen[name] and #result < MAX_UNITS then
                seen[name] = true
                table.insert(result, name)
            end
        end
    end
    return result
end

--- Plans the equip: "match" when every macro unit the player owns is already equipped (any level, any slot),
--- otherwise "equip" with the best unit GUID per owned macro unit in macro order. Names the player lacks are missing.
function MacroEquip.plan(
    names: { string },
    equipped: { { guid: string, name: string } },
    owned: { Owned }
): Plan
    local equippedNames: { [string]: boolean } = {}
    for _, unit in equipped do
        equippedNames[unit.name] = true
    end
    local steps: { string } = {}
    local missing: { string } = {}
    local complete = true
    for _, name in names do
        local best = MacroEquip.best(owned, name)
        if best == nil then
            table.insert(missing, name)
        else
            table.insert(steps, best.guid)
            if not equippedNames[name] then
                complete = false
            end
        end
    end
    local state = if #steps == 0 or complete then "match" else "equip"
    return { state = state, steps = steps, missing = missing }
end

return MacroEquip
