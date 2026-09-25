--!strict
--[[
Purpose: Isolate the pinned UI API from application modules
Input: WindUI export; config; context
Output: Window
Dependencies: types/Context
]]

local Types = require("../types/Context")
local ENV: { [string]: any } = getfenv()
local WINDOW_WIDTH = 600
local WINDOW_HEIGHT = 400
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
--- Creates a window for an already-owned library; returns its UI handle.
function WindUIAdapter.create(library: any, context: Types.Context, config: any): any
    local window = (library.CreateWindow :: any)(library, {
        Title = "ViperHub NextGen",
        Author = "Foundation 0.2.2",
        Theme = "Dark",
        NewElements = true,
        Acrylic = false,
        Size = if ENV.UDim2 then (ENV.UDim2 :: any).fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT) else nil,
        AutoScale = false,
        OpenButton = { Title = "ViperHub", Enabled = true, OnlyMobile = false },
    })
    if window.SetUIScale then
        (window.SetUIScale :: any)(window, config.uiScale)
    end
    if window.OnDestroy then
        (window.OnDestroy :: any)(window, context.destroy)
    end
    return window
end
return WindUIAdapter
