--!strict
--[[
Purpose: Anime Vanguards page style: the shared ViperHub style plus the icon of each Joiner row
Input: A WindUI tab or section handle, a title, an icon name and whether it starts opened
Output: The created section handle
Dependencies: ui/Style
]]

local Base = require("../../ui/Style")
local Style = {}

-- Icon per Joiner row (names exist in the bundled icon tables).
local JOINER_ICONS: { [string]: string } = {
    Stage = "map",
    ["Legend Stage"] = "crown",
    Raid = "swords",
    Dungeon = "skull",
    ["Boss Event"] = "flame",
    Worldline = "globe",
    ["Elemental Towers"] = "castle",
    Portal = "door-open",
    ["Boss Bounties"] = "target",
    ["Regular Challenge"] = "trophy",
    ["Daily Challenge"] = "calendar",
    ["Weekly Challenge"] = "clock",
    Rift = "zap",
}

Style.section = Base.section
Style.sub = Base.sub
Style.card = Base.card

--- Creates the main section of a Joiner row ("<name> Joiner") with that row's icon.
function Style.joiner(host: any, name: string, opened: boolean?): any
    return Base.section(host, name .. " Joiner", JOINER_ICONS[name], opened)
end

return Style
