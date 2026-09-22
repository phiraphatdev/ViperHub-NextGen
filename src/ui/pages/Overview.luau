--!strict
--[[
Purpose: Show verified detection and foundation limits
Input: Window; game metadata
Output: Overview tab
Dependencies: None
]]

local Overview = {}
--- Mounts read-only detection details; returns nothing.
function Overview.mount(window: any, metadata: any)
    local tab = window:Tab({ Title = "Overview", Icon = "info" })
    tab:Paragraph({ Title = metadata.name, Desc = "Game detected. Foundation only; no gameplay features." })
    tab:Paragraph({ Title = "Module " .. metadata.version, Desc = "Last updated: " .. metadata.lastUpdated })
end
return Overview
