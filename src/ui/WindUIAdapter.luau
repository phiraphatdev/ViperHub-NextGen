--!strict
--[[
Purpose: Isolate the pinned UI API from application modules
Input: WindUI export; config; context
Output: Window
Dependencies: types/Context
]]

local Types = require("../types/Context")
local Theme = require("./Theme")
local HoverGlow = require("./HoverGlow")
local Dither = require("./Dither")
local Ambient = require("./Ambient")
local ENV: { [string]: any } = getfenv()
local WINDOW_WIDTH = 600
local WINDOW_HEIGHT = 400
local SIDEBAR_WIDTH = 180
local WindUIAdapter = {}
--- Owns library resources for context; registers teardown and returns nothing.
function WindUIAdapter.own(library: any, context: Types.Context)
    assert(type(library) == "table" and type(library.CreateWindow) == "function", "UI_CONTRACT")
    -- Register before CreateWindow so a partial construction is still cleaned up.
    context.cleanup.add(function()
        if library.Creator and library.Creator.DisconnectAll then
            pcall(library.Creator.DisconnectAll :: any)
        end
        -- Some upstream revisions remove entries while iterating; drain any survivors.
        local signals = library.Creator and library.Creator.Signals
        if type(signals) == "table" then
            for _, connection in signals do
                pcall(function()
                    (connection :: any):Disconnect()
                end)
            end
            table.clear(signals)
        end
        for _, key in { "ScreenGui", "NotificationGui", "DropdownGui", "TooltipGui" } do
            local gui = library[key]
            if gui then
                pcall(function()
                    gui:Destroy()
                end)
            end
        end
    end)
end
--- Applies game-supplied CollectionService tags to every WindUI layer; ignores missing services and bad tags.
local function tagLayers(library: any, tags: { string }?)
    local gameObject = ENV.game
    if not gameObject or type(tags) ~= "table" or #tags == 0 then
        return
    end
    local ok, tagService = pcall(function()
        return (gameObject :: any):GetService("CollectionService")
    end)
    if not ok or not tagService then
        return
    end
    for _, key in { "ScreenGui", "NotificationGui", "DropdownGui", "TooltipGui" } do
        local gui = library[key]
        if gui then
            for _, tag in tags do
                if type(tag) == "string" and #tag > 0 and #tag <= 64 then
                    pcall(function()
                        tagService:AddTag(gui, tag)
                    end)
                end
            end
        end
    end
end

--- Creates a window for an already-owned library; returns its UI handle.
--- author is the small line under the title (for example the module version).
function WindUIAdapter.create(
    library: any,
    context: Types.Context,
    config: any,
    windowTags: { string }?,
    author: string?
): any
    tagLayers(library, windowTags)
    local theme = Theme.register(library, config.theme)
    local window = (library.CreateWindow :: any)(library, {
        Title = "ViperHub NextGen",
        Author = author or "ViperHub NextGen",
        Folder = "ViperHubNextGen",
        Icon = "zap",
        IconThemed = true,
        Theme = theme,
        NewElements = false,
        Acrylic = false,
        Size = if ENV.UDim2 then (ENV.UDim2 :: any).fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT) else nil,
        SideBarWidth = SIDEBAR_WIDTH,
        ShadowTransparency = 0.45,
        -- Player card (avatar, display name) at the bottom of the sidebar.
        User = { Enabled = true, Anonymous = false },
        AutoScale = false,
        OpenButton = {
            Title = "ViperHub",
            Icon = "zap",
            Enabled = true,
            OnlyMobile = false,
            Color = if ENV.ColorSequence and Theme.color("primary")
                then (ENV.ColorSequence :: any).new(Theme.color("primary"), Theme.color("secondary"))
                else nil,
        },
    })
    local BASE_DISPLAY_ORDER = 100
    if library.ScreenGui then
        pcall(HoverGlow.attach, library, context.cleanup)
        pcall(Dither.attach, library.ScreenGui, context.cleanup)
        pcall(Ambient.attach, library, context.cleanup)
    end
    if library.ScreenGui then
        pcall(function()
            (library.ScreenGui :: any).DisplayOrder = BASE_DISPLAY_ORDER
        end)
    end
    if library.DropdownGui then
        pcall(function()
            (library.DropdownGui :: any).DisplayOrder = BASE_DISPLAY_ORDER + 10
        end)
    end
    if library.TooltipGui then
        pcall(function()
            (library.TooltipGui :: any).DisplayOrder = BASE_DISPLAY_ORDER + 20
        end)
    end
    if library.NotificationGui then
        pcall(function()
            (library.NotificationGui :: any).DisplayOrder = BASE_DISPLAY_ORDER + 30
        end)
    end
    if window.SetUIScale then
        (window.SetUIScale :: any)(window, config.uiScale)
    end
    if window.OnDestroy then
        (window.OnDestroy :: any)(window, context.destroy)
    end
    context.cleanup.add(function()
        if window and not window.Destroyed and type(window.Destroy) == "function" then
            pcall(window.Destroy, window)
        end
    end)
    return window
end
return WindUIAdapter
