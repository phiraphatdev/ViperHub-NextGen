--!strict
--[[
Purpose: Shared ViperHub heading and card style for every game's pages (the UI base): boxed iconed sections,
         dimmer sub-headings and icon cards
Input: A WindUI tab or section handle, a title, an optional icon (bundled icon name) and options
Output: The created section or paragraph handle
Dependencies: None
]]

local Style = {}

local HEADING_SIZE = 18
local SUB_HEADING_SIZE = 15
local SUB_HEADING_DIM = 0.35
local CARD_ICON_SIZE = 20

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

--- Creates an information card with an icon; returns the paragraph (call SetDesc to update it).
function Style.card(host: any, title: string, desc: string, icon: string?): any
    return host:Paragraph({ Title = title, Desc = desc, Image = icon, ImageSize = CARD_ICON_SIZE })
end

return Style
