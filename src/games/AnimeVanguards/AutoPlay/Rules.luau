--!strict
--[[
Purpose: Pure Stage Preset Rules model keyed by game mode, validated against live presets
Input: Raw persisted rules, mode strings and a presets snapshot from the game
Output: Normalized rules, lookups, resolution results and dropdown option labels
Dependencies: None
]]

local Rules = {}

local MAX_KEY_LENGTH = 96
local MAX_ID_LENGTH = 24
local MAX_NAME_LENGTH = 96
local MAX_RULES = 400
local NONE_LABEL = "None"

export type Entry = { id: string, name: string }
export type RuleSet = { [string]: Entry }
export type Presets = { active: string, max: number, order: { string }, names: { [string]: string } }
export type Option = { id: string?, name: string?, label: string }

Rules.NONE_LABEL = NONE_LABEL

local function validText(value: any, limit: number): boolean
    return type(value) == "string" and #value > 0 and #value <= limit
end

--- Returns an empty rule set.
function Rules.empty(): RuleSet
    return {}
end

--- Validates untrusted persisted data; returns a fresh, bounded rule set and drops malformed entries.
function Rules.normalize(raw: any): RuleSet
    local result: RuleSet = {}
    if type(raw) ~= "table" then
        return result
    end
    local count = 0
    for mode, entry in raw do
        if
            count < MAX_RULES
            and validText(mode, MAX_KEY_LENGTH)
            and type(entry) == "table"
            and validText(entry.id, MAX_ID_LENGTH)
            and validText(entry.name, MAX_NAME_LENGTH)
        then
            result[mode :: string] = { id = entry.id :: string, name = entry.name :: string }
            count += 1
        end
    end
    return result
end

--- Returns the stored entry for a mode, or nil when the mode has no preset chosen (None).
function Rules.get(rules: RuleSet, mode: string): Entry?
    return rules[mode]
end

--- Stores or clears (entry nil) a rule in place; returns false for invalid keys.
function Rules.set(rules: RuleSet, mode: string, entry: Entry?): boolean
    if not validText(mode, MAX_KEY_LENGTH) then
        return false
    end
    if entry == nil then
        rules[mode] = nil
        return true
    end
    if not validText(entry.id, MAX_ID_LENGTH) or not validText(entry.name, MAX_NAME_LENGTH) then
        return false
    end
    rules[mode] = { id = entry.id, name = entry.name }
    return true
end

--- Checks a stored entry against live presets: "ok" only when the id exists with the same name.
function Rules.resolve(entry: Entry, presets: Presets): string
    local liveName = presets.names[entry.id]
    if type(liveName) == "string" and liveName == entry.name then
        return "ok"
    end
    return "invalid"
end

--- Clears every rule whose preset was deleted or renamed; returns the number of cleared rules.
function Rules.prune(rules: RuleSet, presets: Presets): number
    local doomed: { string } = {}
    for mode, entry in rules do
        if Rules.resolve(entry, presets) ~= "ok" then
            table.insert(doomed, mode)
        end
    end
    for _, mode in doomed do
        rules[mode] = nil
    end
    return #doomed
end

--- Builds dropdown options: None first, then one per preset in game order; duplicate names get a suffix.
function Rules.options(presets: Presets?): { Option }
    local options: { Option } = { { label = NONE_LABEL } }
    if not presets then
        return options
    end
    local seen: { [string]: number } = {}
    for _, id in presets.order do
        local name = presets.names[id]
        if type(name) == "string" then
            local count = (seen[name] or 0) + 1
            seen[name] = count
            local label = if count > 1 then string.format("%s (%d)", name, count) else name
            table.insert(options, { id = id, name = name, label = label })
        end
    end
    return options
end

--- Copies and validates a presets payload from the game; returns nil when the shape is unexpected.
function Rules.readPresets(payload: any): Presets?
    if type(payload) ~= "table" or type(payload.Order) ~= "table" or type(payload.Names) ~= "table" then
        return nil
    end
    local order: { string } = {}
    local names: { [string]: string } = {}
    for _, id in payload.Order do
        local name = payload.Names[id]
        if type(id) == "string" and type(name) == "string" and #order < 64 then
            table.insert(order, id)
            names[id] = name
        end
    end
    return {
        active = if type(payload.Active) == "string" then payload.Active else "",
        max = if type(payload.Max) == "number" then payload.Max else #order,
        order = order,
        names = names,
    }
end

return Rules
