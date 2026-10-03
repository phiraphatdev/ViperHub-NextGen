--!strict
--[[
Purpose: Validate and automatically persist Joiner controls
Input: Pause, cooldown, priority, enabled modes and selections
Output: Safe state and reset operations
Dependencies: Definitions; FileStorage
]]

local definitions = require("./Definitions")
local TeamEquip = require("./TeamEquip")
local MacroEquip = require("./MacroEquip")
local FileStorage = require("../../../platform/FileStorage")
local Settings = {}
local DEFAULT_COOLDOWN = 0
local MAX_COOLDOWN = 300
local REGULAR_REWARD_MAP: any = table.freeze({
    ["Trait Rerolls"] = "Trait Reroll Challenge",
    ["Stat Chips"] = "Stat Chip Challenge",
    ["Memoria Shards"] = "Memoria Shard Challenge",
    ["Green Essence Stone"] = "Essence Stone Challenge (Green)",
    ["Legendary Essence Stone"] = "Essence Stone Challenge (Legendary)",
    ["Mythic Essence Stone"] = "Essence Stone Challenge (Mythic)",
})
Settings.REGULAR_REWARD_MAP = REGULAR_REWARD_MAP

-- Only the first four positions are visible in the reference UI; remaining entries use our stable category order.
local FIRST_PRIORITY = { "Rift", "Weekly Challenge", "Daily Challenge", "Regular Challenge" }
local function defaultPriority(): { string }
    local result = table.clone(FIRST_PRIORITY)
    for _, name in definitions do
        if not table.find(result, name) then
            table.insert(result, name)
        end
    end
    return result
end
local paused = true
local cooldown = DEFAULT_COOLDOWN
local priority = defaultPriority()
local enabled: { [string]: boolean } = {}
local selection: { [string]: any } = {}
local changeStageInMatch = true
local teamEquipEnabled = false
local teamEquipTeams: { [string]: string } = {}
local macroEquipEnabled = false
local macroEquipMacros: { [string]: string } = {}
local bountyRun: any = nil
local joinerRun: any = nil
local storage: FileStorage.Storage? = nil
local encode: ((any) -> string)? = nil

local function known(name: string): boolean
    return table.find(definitions, name) ~= nil
end

local function save()
    local activeStorage = storage
    local codec = encode
    if not activeStorage or not codec then
        return
    end
    local ok, body = pcall(codec, {
        schemaVersion = 1,
        paused = paused,
        cooldown = cooldown,
        priority = priority,
        enabled = enabled,
        selection = selection,
        changeStageInMatch = changeStageInMatch,
        bountyRun = bountyRun,
        joinerRun = joinerRun,
        teamEquip = { enabled = teamEquipEnabled, teams = teamEquipTeams },
        macroEquip = { enabled = macroEquipEnabled, macros = macroEquipMacros },
    })
    if ok and type(body) == "string" then
        activeStorage.write(body)
    end
end

--- Loads validated Joiner preferences once from the optional executor filesystem.
function Settings.init(env: any)
    storage = FileStorage.new(env, "AnimeVanguardsJoiner")
    local activeStorage = storage
    if not activeStorage then
        return
    end
    local http = env.game:GetService("HttpService")
    local body, readError = activeStorage.read()
    if readError then
        -- Unreadable right now: keep the file as it is (session-only changes) instead of overwriting it.
        storage = nil
        return
    end
    encode = function(value: any): string
        return http:JSONEncode(value)
    end
    if not body then
        return
    end
    local ok, data = pcall(function()
        return http:JSONDecode(body)
    end)
    if not ok or type(data) ~= "table" or data.schemaVersion ~= 1 then
        storage = nil
        encode = nil
        return
    end
    if type(data.paused) == "boolean" then
        paused = data.paused
    end
    if
        type(data.cooldown) == "number"
        and data.cooldown == data.cooldown
        and data.cooldown ~= math.huge
        and data.cooldown ~= -math.huge
    then
        cooldown = math.clamp(math.floor(data.cooldown), DEFAULT_COOLDOWN, MAX_COOLDOWN)
    end
    if type(data.priority) == "table" then
        local seen: { [string]: boolean } = {}
        local valid = true
        local retained = {}
        for _, name in data.priority do
            if type(name) ~= "string" or seen[name] then
                valid = false
                break
            end
            seen[name] = true
            if known(name) then
                table.insert(retained, name)
            end
        end
        if valid then
            for _, defName in definitions do
                if not table.find(retained, defName) then
                    table.insert(retained, defName)
                end
            end
            priority = retained
        end
    end
    if
        type(data.joinerRun) == "table"
        and type(data.joinerRun.mode) == "string"
        and type(data.joinerRun.stage) == "string"
        and type(data.joinerRun.act) == "string"
        and type(data.joinerRun.at) == "number"
    then
        joinerRun = {
            mode = data.joinerRun.mode,
            stage = data.joinerRun.stage,
            act = data.joinerRun.act,
            at = data.joinerRun.at,
        }
    end
    if type(data.teamEquip) == "table" then
        if type(data.teamEquip.enabled) == "boolean" then
            teamEquipEnabled = data.teamEquip.enabled
        end
        if type(data.teamEquip.teams) == "table" then
            for name, key in data.teamEquip.teams do
                if type(name) == "string" and known(name) and TeamEquip.validKey(key) then
                    teamEquipTeams[name] = key :: string
                end
            end
        end
    end
    if type(data.macroEquip) == "table" then
        if type(data.macroEquip.enabled) == "boolean" then
            macroEquipEnabled = data.macroEquip.enabled
        end
        if type(data.macroEquip.macros) == "table" then
            for name, file in data.macroEquip.macros do
                if type(name) == "string" and known(name) and MacroEquip.validName(file) then
                    macroEquipMacros[name] = file :: string
                end
            end
        end
    end
    if type(data.changeStageInMatch) == "boolean" then
        changeStageInMatch = data.changeStageInMatch
    end
    if
        type(data.bountyRun) == "table"
        and type(data.bountyRun.mode) == "string"
        and type(data.bountyRun.stage) == "string"
        and type(data.bountyRun.act) == "string"
        and type(data.bountyRun.at) == "number"
    then
        bountyRun = {
            mode = data.bountyRun.mode,
            stage = data.bountyRun.stage,
            act = data.bountyRun.act,
            at = data.bountyRun.at,
        }
    end
    if type(data.enabled) == "table" then
        for name, value in data.enabled do
            if type(name) == "string" and known(name) and type(value) == "boolean" then
                enabled[name] = value
            end
        end
    end
    if type(data.selection) == "table" then
        for name, value in data.selection do
            if
                type(name) == "string"
                and known(name)
                and type(value) == "table"
                and type(value.stage) == "string"
                and type(value.act) == "string"
                and type(value.difficulty) == "string"
                and #value.stage <= 80
                and #value.act <= 80
            then
                selection[name] = { stage = value.stage, act = value.act, difficulty = value.difficulty }
            elseif type(name) == "string" and name == "Rift" and type(value) == "table" then
                local backToLobby = value.backToLobby == true
                local returnMode = if value.returnMode == "Wait Match End"
                    then "Wait Match End"
                    else "Immediate"
                selection.Rift = { backToLobby = backToLobby, returnMode = returnMode }
            elseif type(name) == "string" and name == "Regular Challenge" and type(value) == "table" then
                local reward = if type(value.rewardChoice) == "string"
                        and REGULAR_REWARD_MAP[value.rewardChoice]
                    then value.rewardChoice
                    else "Trait Rerolls"
                local challengeName = REGULAR_REWARD_MAP[reward] or "Trait Reroll Challenge"
                local backToLobby = value.backToLobby == true
                local returnMode = if value.returnMode == "Wait Match End"
                    then "Wait Match End"
                    else "Immediate"
                selection["Regular Challenge"] = {
                    rewardChoice = reward,
                    challengeName = challengeName,
                    backToLobby = backToLobby,
                    returnMode = returnMode,
                }
            elseif
                type(name) == "string"
                and (name == "Daily Challenge" or name == "Weekly Challenge")
                and type(value) == "table"
            then
                local challengeName = if type(value.challengeName) == "string"
                        and #value.challengeName <= 80
                    then value.challengeName
                    else name
                local backToLobby = value.backToLobby == true
                local returnMode = if value.returnMode == "Wait Match End"
                    then "Wait Match End"
                    else "Immediate"
                selection[name] = {
                    challengeName = challengeName,
                    backToLobby = backToLobby,
                    returnMode = returnMode,
                }
            elseif
                type(name) == "string"
                and known(name)
                and type(value) == "table"
                and type(value.challengeName) == "string"
                and #value.challengeName <= 80
            then
                selection[name] = { challengeName = value.challengeName }
            elseif
                type(name) == "string"
                and name == "Worldline"
                and type(value) == "table"
                and type(value.worldlineId) == "string"
                and #value.worldlineId <= 80
                and (value.traitsType == "Traits" or value.traitsType == "NoTraits")
            then
                selection[name] = { worldlineId = value.worldlineId, traitsType = value.traitsType }
            elseif
                type(name) == "string"
                and name == "Boss Event"
                and type(value) == "table"
                and type(value.eventName) == "string"
                and #value.eventName <= 80
                and (value.difficulty == "Normal" or value.difficulty == "Elite")
            then
                selection[name] = { eventName = value.eventName, difficulty = value.difficulty }
            end
        end
    end
end

--- Returns a copy of Joiner preferences; callers cannot mutate stored priority.
function Settings.get()
    return {
        paused = paused,
        cooldown = cooldown,
        priority = table.clone(priority),
        enabled = table.clone(enabled),
        selection = table.clone(selection),
        changeStageInMatch = changeStageInMatch,
        bountyRun = bountyRun,
        joinerRun = joinerRun,
        teamEquip = { enabled = teamEquipEnabled, teams = table.clone(teamEquipTeams) },
        macroEquip = { enabled = macroEquipEnabled, macros = table.clone(macroEquipMacros) },
        persistent = storage ~= nil,
    }
end

--- Turns the Team Equipper on or off (it also needs a team chosen for the joiner).
function Settings.setTeamEquipEnabled(value: boolean): boolean
    if type(value) ~= "boolean" then
        return false
    end
    teamEquipEnabled = value
    save()
    return true
end

--- Turns the Macro Equipper on or off (it also needs a macro file chosen for the joiner).
function Settings.setMacroEquipEnabled(value: boolean): boolean
    if type(value) ~= "boolean" then
        return false
    end
    macroEquipEnabled = value
    save()
    return true
end

--- Chooses the macro file whose units are equipped before joining; file nil clears it (None).
function Settings.setMacroForJoiner(name: string, file: string?): boolean
    if type(name) ~= "string" or not known(name) then
        return false
    end
    if file == nil then
        macroEquipMacros[name] = nil
    elseif MacroEquip.validName(file) then
        macroEquipMacros[name] = file
    else
        return false
    end
    save()
    return true
end

--- Chooses the saved team ("TeamN") to equip before joining; key nil clears it (None). Returns false when invalid.
function Settings.setTeamForJoiner(name: string, key: string?): boolean
    if type(name) ~= "string" or not known(name) then
        return false
    end
    if key == nil then
        teamEquipTeams[name] = nil
    elseif TeamEquip.validKey(key) then
        teamEquipTeams[name] = key
    else
        return false
    end
    save()
    return true
end

--- Enables or disables changing the stage inside a match before Vote Start.
function Settings.setChangeStageInMatch(value: boolean): boolean
    if type(value) ~= "boolean" then
        return false
    end
    changeStageInMatch = value
    save()
    return true
end

--- Records (or clears with nil) the match this joiner created, so only joiner-created matches are switched in the match.
function Settings.setJoinerRun(run: any): boolean
    if run == nil then
        joinerRun = nil
    elseif
        type(run) == "table"
        and type(run.mode) == "string"
        and type(run.stage) == "string"
        and type(run.act) == "string"
        and type(run.at) == "number"
    then
        joinerRun = { mode = run.mode, stage = run.stage, act = run.act, at = run.at }
    else
        return false
    end
    save()
    return true
end

--- Records (or clears with nil) the Boss Bounty match the joiner entered, so the match place can recognise it.
function Settings.setBountyRun(run: any): boolean
    if run == nil then
        bountyRun = nil
    elseif
        type(run) == "table"
        and type(run.mode) == "string"
        and type(run.stage) == "string"
        and type(run.act) == "string"
        and type(run.at) == "number"
    then
        bountyRun = { mode = run.mode, stage = run.stage, act = run.act, at = run.at }
    else
        return false
    end
    save()
    return true
end

--- Stores a supported mode toggle and writes it immediately when storage exists.
function Settings.setEnabled(name: string, value: boolean)
    if not known(name) or type(value) ~= "boolean" then
        return false
    end
    enabled[name] = value
    save()
    return true
end

--- Stores a validated current selection and writes it immediately.
function Settings.setSelection(name: string, value: any)
    if not known(name) or type(value) ~= "table" then
        return false
    end
    selection[name] = table.clone(value)
    save()
    return true
end

--- Updates the in-match return-to-lobby preferences for a mode.
function Settings.setBackToLobby(name: string, backToLobby: boolean, returnMode: string): boolean
    if type(name) ~= "string" or not known(name) or type(backToLobby) ~= "boolean" then
        return false
    end
    local mode = if returnMode == "Wait Match End" then "Wait Match End" else "Immediate"
    local current = selection[name] or {}
    local updated = table.clone(current)
    updated.backToLobby = backToLobby
    updated.returnMode = mode
    selection[name] = updated
    save()
    return true
end

--- Updates Regular Challenge target reward item and maps to challenge stage name.
function Settings.setRegularReward(rewardChoice: string): boolean
    local challengeName = REGULAR_REWARD_MAP[rewardChoice]
    if not challengeName then
        return false
    end
    local current = selection["Regular Challenge"] or {}
    local updated = table.clone(current)
    updated.rewardChoice = rewardChoice
    updated.challengeName = challengeName
    selection["Regular Challenge"] = updated
    save()
    return true
end

--- Sets the global pause flag; returns true only for a valid boolean.
function Settings.setPaused(value: unknown): boolean
    if type(value) ~= "boolean" then
        return false
    end
    paused = value
    save()
    return true
end

--- Sets lobby cooldown in whole seconds, clamped to the supported range.
function Settings.setCooldown(value: unknown): boolean
    if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
        return false
    end
    cooldown = math.clamp(math.floor(value), DEFAULT_COOLDOWN, MAX_COOLDOWN)
    save()
    return true
end

--- Moves a known Joiner one place toward the front; returns whether it moved.
function Settings.moveUp(name: unknown): boolean
    if type(name) ~= "string" then
        return false
    end
    for index, value in priority do
        if value == name then
            if index == 1 then
                return false
            end
            priority[index], priority[index - 1] = priority[index - 1], priority[index]
            save()
            return true
        end
    end
    return false
end

--- Restores the default priority only; returns the resulting order.
function Settings.resetPriority(): { string }
    priority = defaultPriority()
    save()
    return table.clone(priority)
end

return Settings
