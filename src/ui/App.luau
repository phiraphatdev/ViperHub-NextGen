--!strict
--[[
Purpose: Compose the foundation UI without gameplay coupling
Input: Library; context; metadata; config store; diagnostics; keys; optional game pages
Output: Window and diagnostics refresh callback
Dependencies: WindUIAdapter; pages
]]

local Adapter = require("./WindUIAdapter")
local Overview = require("./pages/Overview")
local Settings = require("./pages/Settings")
local Diagnostics = require("./pages/Diagnostics")
local App = {}
--- Creates all pages; returns the window and a diagnostics refresh callback owned by context.
function App.mount(
    library: any,
    context: any,
    metadata: any,
    store: any,
    buffer: any,
    keyCodes: any,
    pages: { any }?,
    windowTags: { string }?
): (any, () -> ())
    local window = Adapter.create(library, context, store.get(), windowTags)
    Overview.mount(window, metadata)
    if pages then
        for _, page in pages do
            local tab = window:Tab({ Title = page.title, Icon = page.icon or "layout-grid" })
            if page.render then
                -- A broken page must not take the other tabs (or startup) down with it.
                local render: any = page.render
                local ok = pcall(render, tab, window)
                if not ok then
                    local log: any = context.log
                    if type(log) == "function" then
                        (log :: any)("PAGE_RENDER_FAILED")
                    end
                    pcall(function()
                        tab:Paragraph({ Title = page.title, Desc = "This page could not be shown." })
                    end)
                end
            else
                tab:Paragraph({ Title = page.title, Desc = page.description })
            end
        end
    end
    Settings.mount(window, store, library, keyCodes, context)
    local refreshDiagnostics = Diagnostics.mount(window, buffer)
    window:SelectTab(1)
    return window, refreshDiagnostics
end
return App
