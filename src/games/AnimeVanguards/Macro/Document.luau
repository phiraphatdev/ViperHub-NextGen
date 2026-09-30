--!strict
--[[
Purpose: Validate versioned macro JSON and normalize older action positions to CFrame components
Input: Decoded JSON or legacy Marco_Data values
Output: Canonical schema-v2 document or error code
Dependencies: None
]]
local Document = {}
local KINDS = {
    voteStart = true,
    place = true,
    upgrade = true,
    sell = true,
    ability = true,
    priority = true,
    autoUpgrade = true,
    autoAbility = true,
    upgradePriority = true,
}
local MAX_ACTIONS = 2000
local function rounded(value: number): number
    local result = math.floor(value * 1000000 + 0.5) / 1000000
    return if result == 0 then 0 else result
end
local function finite(value: any): boolean
    return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end
local function short(value: any, limit: number): boolean
    return type(value) == "string" and #value > 0 and #value <= limit
end
local function validCFrame(value: any): boolean
    if type(value) ~= "table" or #value ~= 12 then
        return false
    end
    for index = 1, 12 do
        if not finite(value[index]) then
            return false
        end
    end
    return true
end
--- Builds JSON-safe CFrame components from observed position and yaw degrees.
function Document.fromPose(position: any, rotation: any): { number }?
    if
        type(position) ~= "table"
        or not finite(position.x)
        or not finite(position.y)
        or not finite(position.z)
        or not finite(rotation)
    then
        return nil
    end
    local yaw = math.rad(rotation)
    local cosine, sine = math.cos(yaw), math.sin(yaw)
    return {
        rounded(position.x),
        rounded(position.y),
        rounded(position.z),
        rounded(cosine),
        0,
        rounded(sine),
        0,
        1,
        0,
        rounded(-sine),
        0,
        rounded(cosine),
    }
end
--- Extracts the game's Vector3 position and yaw from canonical components.
function Document.toPose(components: any): (any?, number?)
    if not validCFrame(components) then
        return nil, nil
    end
    local yaw = math.deg(math.atan2(components[6], components[4])) % 360
    return { x = components[1], y = components[2], z = components[3] }, yaw
end
--- Creates an empty schema-v2 macro.
function Document.empty(name: string): any
    return { schemaVersion = 2, name = name, game = "AnimeVanguards", match = {}, units = {}, actions = {} }
end
--- Returns a normalized v2 copy, accepting v1 without rewriting its source file.
function Document.validate(data: any): (any?, string?)
    if
        type(data) ~= "table"
        or (data.schemaVersion ~= 1 and data.schemaVersion ~= 2)
        or data.game ~= "AnimeVanguards"
    then
        return nil, "MACRO_SCHEMA_UNSUPPORTED"
    end
    if
        not short(data.name, 64)
        or type(data.match) ~= "table"
        or type(data.units) ~= "table"
        or type(data.actions) ~= "table"
        or #data.actions > MAX_ACTIONS
    then
        return nil, "MACRO_INVALID"
    end
    local result = Document.empty(data.name)
    if short(data.match.mode, 100) then
        result.match.mode = data.match.mode
    end
    if short(data.match.map, 100) then
        result.match.map = data.match.map
    end
    for _, unitName in data.units do
        if not short(unitName, 100) then
            return nil, "MACRO_INVALID"
        end
        table.insert(result.units, unitName)
    end
    local levelsByRef: { [string]: number } = {}
    for index, action in data.actions do
        if
            type(action) ~= "table"
            or not KINDS[action.kind]
            or action.index ~= index
            or not finite(action.wave)
            or action.wave < 0
            or not finite(action.yen)
            or action.yen < 0
            or not finite(action.time)
            or action.time < 0
            or (action.kind ~= "voteStart" and not short(action.unitRef, 100))
        then
            return nil, "MACRO_ACTION_INVALID"
        end
        local normalized: any = {
            index = index,
            kind = action.kind,
            wave = action.wave,
            yen = action.yen,
            time = action.time,
            unitRef = if action.kind == "voteStart" then nil else action.unitRef,
        }
        if action.kind == "place" then
            local components = action.cframe
            if data.schemaVersion == 1 then
                components = Document.fromPose(action.position, action.rotation)
            end
            if
                not short(action.unitName, 100)
                or not validCFrame(components)
                or not finite(action.slotIndex)
                or action.slotIndex < 1
                or action.slotIndex > 8
                or action.slotIndex % 1 ~= 0
            then
                return nil, "MACRO_ACTION_INVALID"
            end
            normalized.unitName = action.unitName
            normalized.cframe = table.clone(components)
            normalized.slotIndex = action.slotIndex
            local initialLevel = action.initialLevel
            if initialLevel == nil then
                initialLevel = 0
            end
            if
                not finite(initialLevel)
                or initialLevel % 1 ~= 0
                or initialLevel < 0
                or initialLevel > 2000
            then
                return nil, "MACRO_ACTION_INVALID"
            end
            normalized.initialLevel = initialLevel
            levelsByRef[action.unitRef] = initialLevel
        elseif action.kind == "upgrade" then
            local previousLevel = levelsByRef[action.unitRef] or 0
            local level = action.level
            if level == nil then
                level = previousLevel + 1
            end
            if not finite(level) or level % 1 ~= 0 or level <= previousLevel or level > 2000 then
                return nil, "MACRO_ACTION_INVALID"
            end
            normalized.level = level
            levelsByRef[action.unitRef] = level
        elseif action.kind == "ability" then
            if not short(action.abilityName, 100) then
                return nil, "MACRO_ACTION_INVALID"
            end
            normalized.abilityName = action.abilityName
        elseif action.kind == "priority" then
            if
                not table.find(
                    { "First", "Closest", "Last", "Strongest", "Weakest", "Bosses" },
                    action.priorityName
                )
            then
                return nil, "MACRO_ACTION_INVALID"
            end
            normalized.priorityName = action.priorityName
        elseif action.kind == "autoUpgrade" then
            if type(action.enabled) ~= "boolean" then
                return nil, "MACRO_ACTION_INVALID"
            end
            normalized.enabled = action.enabled
        elseif action.kind == "autoAbility" then
            if type(action.enabled) ~= "boolean" or not short(action.abilityName, 100) then
                return nil, "MACRO_ACTION_INVALID"
            end
            normalized.enabled = action.enabled
            normalized.abilityName = action.abilityName
        elseif action.kind == "upgradePriority" then
            if
                not finite(action.upgradePriority)
                or action.upgradePriority % 1 ~= 0
                or action.upgradePriority < 1
                or action.upgradePriority > 6
            then
                return nil, "MACRO_ACTION_INVALID"
            end
            normalized.upgradePriority = action.upgradePriority
        end
        table.insert(result.actions, normalized)
    end
    return result, nil
end
--- Converts a Marco_Data example without mutating the supplied data.
function Document.importLegacy(data: any, name: string): (any?, string?)
    if type(data) ~= "table" or type(data.Marco_Data) ~= "table" then
        return nil, "MACRO_LEGACY_INVALID"
    end
    local result = Document.empty(name)
    result.match = { map = data.Map, mode = data.Mode }
    for _, row in data.Marco_Data do
        if type(row) == "table" then
            local kind = if row.Method == "SpawnTower"
                then "place"
                else if row.Method == "UpgradeTower"
                    then "upgrade"
                    else if row.Method == "SellTower"
                        then "sell"
                        else if row.Method == "Use Ability" then "ability" else nil
            if kind then
                local action: any = {
                    index = #result.actions + 1,
                    kind = kind,
                    wave = tonumber(row.Wave) or 0,
                    yen = 0,
                    time = tonumber(row.Time) or 0,
                    unitRef = tostring(row.UnitValue or ""),
                }
                if kind == "place" then
                    local x, y, z = tostring(row.Position):match(
                        "^%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*$"
                    )
                    action.unitName = tostring(row.Unit or "")
                    action.cframe = Document.fromPose(
                        { x = tonumber(x), y = tonumber(y), z = tonumber(z) },
                        tonumber(row.Rotation) or 0
                    )
                    local slot = tonumber(row.Slot) or tonumber(row.SlotIndex) or tonumber(row.UnitValue) or 1
                    action.slotIndex = if slot >= 1 and slot <= 8 then slot else ((slot - 1) % 6 + 1)
                elseif kind == "ability" then
                    action.abilityName = tostring(row.Ability or "")
                end
                table.insert(result.actions, action)
            end
        end
    end
    return Document.validate(result)
end
return Document
