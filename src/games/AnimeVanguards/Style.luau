--!strict
--[[
Purpose: Anime Vanguards page style: the shared ViperHub style plus the icon and priority tag of each Joiner row
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
    ["Odyssey Adventure"] = "compass",
}

-- Mode type shown as a tag in the Auto Join Priority list (text, ui/Theme color name).
local JOINER_TAGS: { [string]: { text: string, color: string } } = {
    Stage = { text = "Stage", color = "blue" },
    ["Legend Stage"] = { text = "Stage", color = "blue" },
    Raid = { text = "Stage", color = "blue" },
    Dungeon = { text = "Stage", color = "blue" },
    ["Boss Event"] = { text = "Event", color = "gold" },
    Worldline = { text = "Event", color = "gold" },
    ["Elemental Towers"] = { text = "Event", color = "gold" },
    Portal = { text = "Event", color = "gold" },
    ["Boss Bounties"] = { text = "Bounty", color = "orange" },
    ["Regular Challenge"] = { text = "Challenge", color = "violet" },
    ["Daily Challenge"] = { text = "Challenge", color = "violet" },
    ["Weekly Challenge"] = { text = "Challenge", color = "violet" },
    Rift = { text = "Hourly", color = "rose" },
    ["Odyssey Adventure"] = { text = "Adventure", color = "secondary" },
}

Style.section = Base.section
Style.sub = Base.sub
Style.card = Base.card

--- Creates the main section of a Joiner row ("<name> Joiner") with that row's icon.
function Style.joiner(host: any, name: string, opened: boolean?): any
    return Base.section(host, name .. " Joiner", JOINER_ICONS[name], opened)
end

--- Returns the tag of every Joiner row for the priority list (a copy).
function Style.joinerTags(): { [string]: { text: string, color: string } }
    return table.clone(JOINER_TAGS)
end

return Style
