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

local FRAME_BUDGET_SECONDS = 0.008
-- Diagnostics: WindUI calls slower than 50 ms while pages draw (bounded), readable as context.slowCalls.
local SLOW_CALLS: { string } = {}

local LAZY_DROPDOWN_VALUES = 10

-- WindUI builds every dropdown option up front (a 74-entry list took about 0.9 s). Long lists start with only the
-- selected entries and get the full list the first time they open.
local function lazyDropdown(create: any, target: any, options: any): any
    local full: any = options.Values
    local copy = table.clone(options)
    local selected: { any } = {}
    if type(options.Value) == "table" then
        for _, item in options.Value do
            table.insert(selected, item)
        end
    elseif options.Value ~= nil then
        table.insert(selected, options.Value)
    end
    if #selected == 0 then
        table.insert(selected, full[1])
    end
    copy.Values = selected
    local element: any = create(target, copy)
    if
        type(element) ~= "table"
        or type(element.Open) ~= "function"
        or type(element.Refresh) ~= "function"
    then
        return element
    end
    local filled = false
    local originalOpen: any = element.Open
    local originalRefresh: any = element.Refresh
    element.Refresh = function(selfArg: any, values: any, ...: any): ...any
        filled = true
        return originalRefresh(selfArg, values, ...)
    end
    element.Open = function(selfArg: any, ...: any): ...any
        if not filled then
            filled = true
            pcall(originalRefresh, element, full)
        end
        return originalOpen(selfArg, ...)
    end
    return element
end

-- Building elements is slow in WindUI (a big page took seconds and froze the game). Pages draw through this proxy:
-- every call on a container (tab, section, group) forwards to WindUI and, once the frame's budget is used, waits a
-- frame, so a page fills in over several frames instead of freezing one. Containers it returns are wrapped too.
local function isContainer(value: any): boolean
    return type(value) == "table" and type(value.Toggle) == "function" and type(value.Paragraph) == "function"
end
local function budgeted(target: any, clock: { started: number }, root: boolean?): any
    local taskApi: any = (getfenv() :: any).task
    local proxy = {}
    setmetatable(proxy, {
        __index = function(_, key: any): any
            local value: any = target[key]
            if type(value) ~= "function" then
                return value
            end
            return function(selfArg: any, ...: any): ...any
                -- Waits only before the tab's own top-level calls, so a section is always filled in the same frame it
                -- was created (waiting right after creating one left WindUI's open section sized empty, live).
                if
                    root ~= false
                    and os.clock() - clock.started > FRAME_BUDGET_SECONDS
                    and type(taskApi) == "table"
                then
                    pcall(taskApi.wait)
                    clock.started = os.clock()
                end
                local callStarted = os.clock()
                local options: any = select(1, ...)
                local results
                if
                    key == "Dropdown"
                    and type(options) == "table"
                    and type(options.Values) == "table"
                    and #options.Values > LAZY_DROPDOWN_VALUES
                then
                    results =
                        table.pack(lazyDropdown(value, if selfArg == proxy then target else selfArg, options))
                else
                    results = table.pack((value :: any)(if selfArg == proxy then target else selfArg, ...))
                end
                local spent = os.clock() - callStarted
                local slow: any = SLOW_CALLS
                if spent > 0.05 and #slow < 30 then
                    local first = select(1, ...)
                    local title = if type(first) == "table" then tostring(first.Title) else ""
                    table.insert(
                        slow,
                        string.format("%s %s %dms", tostring(key), title, math.floor(spent * 1000))
                    )
                end
                for index = 1, results.n do
                    if isContainer(results[index]) then
                        results[index] = budgeted(results[index], clock, false)
                    end
                end
                return table.unpack(results, 1, results.n)
            end
        end,
        __newindex = function(_, key: any, value: any)
            target[key] = value
        end,
    })
    return proxy
end

-- Creates one tab, rendering it in isolation: a broken page must not take the other tabs (or startup) down.
local function mountPage(host: any, window: any, context: any, page: any, later: { () -> () }?)
    local tab = host:Tab({
        Title = page.title,
        Icon = page.icon or "layout-grid",
        IconColor = if page.iconColor then Theme.color(page.iconColor) else nil,
        Desc = page.description,
        ShowTabTitle = true,
    })
    if page.render then
        local render: any = page.render
        local function draw()
            if context.alive == false then
                return
            end
            local started = os.clock()
            local ok =
                pcall(render, if later then budgeted(tab, { started = os.clock() }, false) else tab, window)
            -- Diagnostics: how long each page took to draw (seconds), readable from the session.
            local timings: any = context.pageTimings
            if type(timings) == "table" then
                timings[tostring(page.title)] = os.clock() - started
                timings[tostring(page.title) .. " at"] = started
            end
            if not ok then
                local log: any = context.log
                if type(log) == "function" then
                    (log :: any)("PAGE_RENDER_FAILED")
                end
                pcall(function()
                    tab:Paragraph({ Title = page.title, Desc = "This page could not be shown." })
                end)
            end
        end
        -- Pages after the first are drawn just after the window shows, one per frame, so it opens at once.
        if later then
            table.insert(later, draw)
        else
            draw()
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
    -- Pages without a group are listed under the game's own name, so every game gets a grouped sidebar.
    context.pageTimings = {}
    context.slowCalls = SLOW_CALLS
    local later: { () -> () } = {}
    for index, page in pages or {} do
        local group = page.group or (if page.home then HOME_GROUP else tostring(metadata.name))
        mountPage(host(group), window, context, page, if index == 1 then nil else later)
    end
    Settings.mount(window, store, library, keyCodes, context, host(SYSTEM_GROUP))
    local refreshDiagnostics = Diagnostics.mount(host(SYSTEM_GROUP), buffer)
    window:SelectTab(1)
    local taskApi: any = (getfenv() :: any).task
    local function pagesDone()
        local sharedState: any = (getfenv() :: any).shared
        local active: any = if type(sharedState) == "table" then sharedState.ViperHubNextGen else nil
        if type(active) == "table" and type(active.markLoaded) == "function" then
            pcall(active.markLoaded, "pages")
        end
    end
    if type(taskApi) == "table" and type(taskApi.spawn) == "function" then
        (taskApi.spawn :: any)(function()
            for _, draw in later do
                (taskApi.wait :: any)()
                draw()
            end
            pagesDone()
        end)
    else
        for _, draw in later do
            draw()
        end
        pagesDone()
    end
    return window, refreshDiagnostics
end
return App
