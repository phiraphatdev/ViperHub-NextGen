--!strict
--[[
Purpose: Recognize an Odyssey: Adventure match from the match place's game data so other features leave it alone
Input: The match place's GameHandler.GameData (untrusted, may be nil)
Output: true when the data describes an Adventure match
Dependencies: None
]]

local Detect = {}

--- True when the game data marks an Adventure match. INFERENCE: the exact field is not yet observed in a live run
--- (docs/games/AnimeVanguards/README.md, Phase 0), so any Adventure/Odyssey marker counts; wrongly true only means
--- the joiner and Auto Back to Lobby stay out of that match.
function Detect.isAdventureMatch(matchData: any): boolean
    if type(matchData) ~= "table" then
        return false
    end
    if matchData.Adventure ~= nil or matchData.IsAdventure == true then
        return true
    end
    local stageType = matchData.StageType
    return type(stageType) == "string"
        and (
            string.find(stageType, "Adventure", 1, true) ~= nil
            or string.find(stageType, "Odyssey", 1, true) ~= nil
        )
end

return Detect
