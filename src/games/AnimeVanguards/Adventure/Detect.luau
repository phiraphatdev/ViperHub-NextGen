--!strict
--[[
Purpose: Recognize an Odyssey: Adventure match from the match place's game data so other features leave it alone
Input: The match place's GameHandler.GameData (untrusted, may be nil)
Output: true when the data describes an Adventure match
Dependencies: None
]]

local Detect = {}

--- True when the game data belongs to an Adventure run. Observed live (2026-10-04): an Adventure match has
--- StageType "Odyssey" (shared with the other Odyssey modes) with SubMode "Adventure" (the game's own check), plus
--- AdventureFloor, AdventureRoomKind and AdventureData.
function Detect.isAdventureMatch(matchData: any): boolean
    if type(matchData) ~= "table" then
        return false
    end
    return (matchData.StageType == "Odyssey" and matchData.SubMode == "Adventure")
        or matchData.AdventureFloor ~= nil
        or matchData.AdventureRoomKind ~= nil
        or matchData.AdventureData ~= nil
end

return Detect
