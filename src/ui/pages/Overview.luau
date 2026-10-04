--!strict
--[[
Purpose: Show verified detection and module version when the game provides no home page
Input: Window or sidebar section; game metadata
Output: Overview tab
Dependencies: None
]]

local Overview = {}
--- Mounts read-only detection details; returns nothing.
function Overview.mount(window: any, metadata: any)
    local tab = window:Tab({ Title = "Overview", Icon = "house", ShowTabTitle = true })
    tab:Paragraph({
        Title = metadata.name,
        Desc = "Game detected. Features are in the tabs on the left.",
        Image = "gamepad-2",
        ImageSize = 26,
    })
    tab:Paragraph({
        Title = "Module " .. metadata.version,
        Desc = "Last updated: " .. metadata.lastUpdated,
        Image = "zap",
        ImageSize = 22,
    })
end
return Overview
