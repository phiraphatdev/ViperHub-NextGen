--!strict
--[[
Purpose: Pure Team Equipper rules: valid team keys, dropdown options, equipped-unit comparison and match-to-joiner mapping
Input: Team tables from the game (TeamN = {Name, Units}), ownership predicates and equipped GUID slots
Output: Options, "match"/"mismatch"/"unusable" verdicts and joiner row names
Dependencies: None
]]

local TeamEquip = {}

local SLOT_COUNT = 6
local MAX_TEAM_NUMBER = 99

export type Option = { key: string, label: string }

--- Returns the team number of a "TeamN" key, or nil when the key is malformed or out of range.
function TeamEquip.number(key: any): number?
    if type(key) ~= "string" or #key > 8 then
        return nil
    end
    local digits = string.match(key, "^Team(%d+)$")
    local value = if digits then tonumber(digits) else nil
    if value == nil or value < 1 or value > MAX_TEAM_NUMBER then
        return nil
    end
    return value
end

--- Returns true for a well-formed "TeamN" key.
function TeamEquip.validKey(key: any): boolean
    return TeamEquip.number(key) ~= nil
end

--- Builds dropdown options (owned teams only, ordered by number); label is "TeamN - name" or "TeamN".
function TeamEquip.options(teams: any, isOwned: (number) -> boolean): { Option }
    local numbers: { number } = {}
    if type(teams) == "table" then
        for key in teams do
            local number = TeamEquip.number(key)
            if number and isOwned(number) then
                table.insert(numbers, number)
            end
        end
    end
    table.sort(numbers)
    local options: { Option } = {}
    for _, number in numbers do
        local key = "Team" .. number
        local team = (teams :: any)[key]
        local name = if type(team) == "table" then team.Name else nil
        local label = if type(name) == "string" and name ~= "" then key .. " - " .. name else key
        table.insert(options, { key = key, label = label })
    end
    return options
end

--- Compares equipped unit GUIDs with a team: "unusable" when it holds no unit the player still owns,
--- "match" when every owned slot (and every empty slot) agrees, otherwise "mismatch".
--- Slots whose GUID is no longer owned are ignored so partly lost teams can still be played.
-- The game reports an empty slot as nil, "" or the string "None".
local function isEmptySlot(value: any): boolean
    return value == nil or value == "" or value == "None"
end

function TeamEquip.evaluate(team: any, ownsUnit: (string) -> boolean, equipped: any): string
    if type(team) ~= "table" or type(team.Units) ~= "table" then
        return "unusable"
    end
    local usable = 0
    local mismatch = false
    for slot = 1, SLOT_COUNT do
        local guid = team.Units[slot]
        local current = if type(equipped) == "table" then equipped[slot] else nil
        if type(guid) == "string" and not isEmptySlot(guid) then
            if ownsUnit(guid) then
                usable += 1
                if current ~= guid then
                    mismatch = true
                end
            end
        elseif not isEmptySlot(current) then
            mismatch = true
        end
    end
    if usable == 0 then
        return "unusable"
    end
    return if mismatch then "mismatch" else "match"
end

--- Maps the current match (GameData) to the Joiner row whose team applies; nil when unknown.
--- stageTypeRows and challengeRows come from the game config (StageType / ChallengeType to row name).
function TeamEquip.rowFor(
    matchData: any,
    isBountyMatch: boolean,
    stageTypeRows: any,
    challengeRows: any
): string?
    if type(matchData) ~= "table" or type(stageTypeRows) ~= "table" or type(challengeRows) ~= "table" then
        return nil
    end
    local challenge = matchData.ChallengeType or matchData.Challenge
    if type(challenge) == "string" and challengeRows[challenge] then
        return challengeRows[challenge]
    end
    if matchData.Rift ~= nil or matchData.StageType == "Rift" then
        return stageTypeRows.Rift
    end
    if isBountyMatch then
        return "Boss Bounties"
    end
    local stageType = matchData.StageType
    return if type(stageType) == "string" then stageTypeRows[stageType] else nil
end

return TeamEquip
