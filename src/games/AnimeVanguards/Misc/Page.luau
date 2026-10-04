--!strict
--[[
Purpose: Render the Misc tab: Anti-AFK, Auto Reconnect and re-running the hub after a teleport
Input: WindUI tab handle and the Misc runtime
Output: Mounted controls bound to the runtime's saved toggles
Dependencies: Style
]]

local Style = require("../Style")
local Page = {}

--- Mounts the Misc controls on the given WindUI tab.
function Page.mount(tab: any, runtime: any)
    local status =
        tab:Paragraph({ Title = "Session", Desc = if runtime then runtime.status else "Unavailable" })
    if not runtime then
        return
    end
    runtime.onStatus = function(value: string)
        pcall(status.SetDesc, status, value)
    end
    local settings = runtime.getSettings()

    local session = Style.section(tab, "Session Keeper", "shield", false)
    session:Toggle({
        Title = "Anti-AFK",
        Desc = "Simulates input when Roblox reports you idle, so the 20-minute idle kick does not happen.",
        Value = settings.antiAfk,
        Callback = function(value: boolean)
            runtime.setAntiAfk(value)
        end,
    })
    session:Toggle({
        Title = "Auto Reconnect",
        Desc = "After a real disconnect (lost connection, timeout, server shutdown, Error 256/277) teleports back to the lobby, up to 5 tries. Never after a kick, ban, login elsewhere or maintenance.",
        Value = settings.autoReconnect,
        Callback = function(value: boolean)
            runtime.setAutoReconnect(value)
        end,
    })

    local rerun = Style.section(tab, "Re-run After Teleport", "refresh-cw", false)
    rerun:Toggle({
        Title = "Re-run ViperHub after teleport",
        Desc = if runtime.canRerun()
            then "Queues your loadstring line for the next place, so the hub (joiner, macro, webhook) loads again after every teleport or reconnect."
            else "This executor has no queue_on_teleport; load the hub manually after a teleport.",
        Value = settings.rerunOnTeleport,
        Locked = not runtime.canRerun(),
        Callback = function(value: boolean)
            runtime.setRerun(value)
        end,
    })
    rerun:Input({
        Title = "Loader URL",
        Desc = 'The URL inside your loadstring(game:HttpGet("..."))() line (must end in .lua).',
        Value = settings.loaderUrl,
        Placeholder = "http://127.0.0.1:8766/runtime-smoke.lua",
        Callback = function(text: string)
            if type(text) == "string" and text ~= "" and not runtime.setLoaderUrl(text) then
                pcall(status.SetDesc, status, "Loader URL must be an http(s) URL ending in .lua")
            end
        end,
    })
end

return Page
