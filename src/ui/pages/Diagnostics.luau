--!strict
--[[
Purpose: Display sanitized diagnostics only on explicit user request
Input: Window; buffer
Output: Diagnostics tab
Dependencies: None
]]

local Diagnostics = {}
--- Mounts a user-triggered buffer snapshot; returns nothing.
function Diagnostics.mount(window: any, buffer: any)
    local tab = window:Tab({ Title = "Diagnostics", Icon = "activity" })
    local paragraph =
        tab:Paragraph({ Title = "Status codes", Desc = "Press Refresh to inspect this session." })
    tab:Button({
        Title = "Refresh",
        Callback = function()
            paragraph:SetDesc(table.concat(buffer.snapshot(), "\n"))
        end,
    })
end
return Diagnostics
