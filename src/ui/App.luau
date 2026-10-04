--!strict
--[[
Purpose: Compose the foundation UI without gameplay coupling
Input: Library; context; metadata; config store; diagnostics; keys; optional game pages
Output: Window and diagnostics refresh callback
Dependencies: WindUIAdapter; Theme; pages
]]

local Adapter = require("./WindUIAdapter")
local Theme = require("./Theme")
local Overview = require("./pages/Overview")
local Settings = require("./pages/Settings")
local Diagnostics = require("./pages/Diagnostics")
local App = {}

local HOME_GROUP = "Home"
local SYSTEM_GROUP = "System"

-- Creates one tab, rendering it in isolation: a broken page must not take the other tabs (or startup) down.
local function mountPage(host: any, window: any, context: any, page: any)
    local tab = host:Tab({
        Title = page.title,
        Icon = page.icon or "layout-grid",
        IconColor = if page.iconColor then Theme.color(page.iconColor) else nil,
        Desc = page.description,
        ShowTabTitle = true,
    })
    if page.render then
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

--- Creates all pages; returns the window and a diagnostics refresh callback owned by context.
--- Game pages may set group (sidebar section), iconColor (brand color name or hex) and home (replaces Overview).
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
    local window = Adapter.create(
        library,
        context,
        store.get(),
        windowTags,
        tostring(metadata.name) .. " • v" .. tostring(metadata.version)
    )
    -- Title-bar tags: game and module version.
    if type(window.Tag) == "function" then
        pcall(
            window.Tag,
            window,
            { Title = tostring(metadata.name), Icon = "gamepad-2", Color = Theme.color("primary") }
        )
        pcall(
            window.Tag,
            window,
            { Title = "v" .. tostring(metadata.version), Icon = "zap", Color = Theme.color("gold") }
        )
    end

    -- Sidebar sections by group name, created on first use; without Section support every tab sits on the window.
    local sections: { [string]: any } = {}
    local function host(group: string?): any
        if not group or type(window.Section) ~= "function" then
            return window
        end
        if not sections[group] then
            local ok, section = pcall(window.Section, window, { Title = group, Opened = true })
            sections[group] = if ok and section then section else window
        end
        return sections[group]
    end

    local hasHome = false
    for _, page in pages or {} do
        if page.home == true then
            hasHome = true
        end
    end
    if not hasHome then
        Overview.mount(host(HOME_GROUP), metadata)
    end
    for _, page in pages or {} do
        mountPage(host(page.group or (if page.home then HOME_GROUP else nil)), window, context, page)
    end
    Settings.mount(window, store, library, keyCodes, context, host(SYSTEM_GROUP))
    local refreshDiagnostics = Diagnostics.mount(host(SYSTEM_GROUP), buffer)
    window:SelectTab(1)
    return window, refreshDiagnostics
end
return App
