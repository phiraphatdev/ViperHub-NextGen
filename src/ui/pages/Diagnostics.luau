--!strict
--[[
Purpose: Display sanitized diagnostics only on explicit user request
Input: Window; buffer
Output: Diagnostics refresh callback
Dependencies: None
]]

local Diagnostics = {}
--- Mounts a snapshot and returns a refresh callback for later startup events.
function Diagnostics.mount(window: any, buffer: any): () -> ()
    local tab = window:Tab({ Title = "Diagnostics", Icon = "activity" })
    local paragraph = tab:Paragraph({ Title = "Status codes", Desc = table.concat(buffer.snapshot(), "\n") })
    local function refresh()
        paragraph:SetDesc(table.concat(buffer.snapshot(), "\n"))
    end
    tab:Button({
        Title = "Refresh",
        Callback = refresh,
    })
    return refresh
end
return Diagnostics
