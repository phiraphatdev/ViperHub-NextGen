--!strict
--[[
Purpose: Give every Anime Vanguards page the same heading look: boxed, iconed main sections and dimmer sub-headings
Input: A WindUI tab or section handle, a title, an icon name and whether it starts opened
Output: The created section handle
Dependencies: None
]]

local Style = {}

local HEADING_SIZE = 18
local SUB_HEADING_SIZE = 15
local SUB_HEADING_DIM = 0.35

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

--- Creates a main section: boxed with a border, an icon and a larger bright title.
function Style.section(host: any, title: string, icon: string?, opened: boolean?, size: number?): any
    return host:Section({
        Title = title,
        Icon = icon,
        Box = true,
        BoxBorder = true,
        TextSize = size or HEADING_SIZE,
        TextTransparency = 0,
        Opened = opened == true,
    })
end

--- Creates a sub-heading inside a main section: no box, smaller, dimmer; falls back to the host without Section support.
function Style.sub(host: any, title: string, icon: string?, opened: boolean?): any
    if type(host.Section) ~= "function" then
        return host
    end
    return (host.Section :: any)(host, {
        Title = title,
        Icon = icon,
        TextSize = SUB_HEADING_SIZE,
        TextTransparency = SUB_HEADING_DIM,
        Opened = opened ~= false,
    })
end

--- Creates the main section of a Joiner row ("<name> Joiner") with that row's icon.
function Style.joiner(host: any, name: string, opened: boolean?): any
    return Style.section(host, name .. " Joiner", JOINER_ICONS[name], opened)
end

return Style
