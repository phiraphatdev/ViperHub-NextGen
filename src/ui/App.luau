--!strict
--[[
Purpose: Compose the foundation UI without gameplay coupling
Input: Library; context; metadata; config store; diagnostics; keys
Output: Window
Dependencies: WindUIAdapter; pages
]]

local Adapter = require("./WindUIAdapter")
local Overview = require("./pages/Overview")
local Settings = require("./pages/Settings")
local Diagnostics = require("./pages/Diagnostics")
local App = {}
--- Creates all pages and returns the window; resources belong to context.
function App.mount(library: any, context: any, metadata: any, store: any, buffer: any, keyCodes: any): any
    local window = Adapter.create(library, context, store.get())
    Overview.mount(window, metadata)
    Settings.mount(window, store, library, keyCodes)
    Diagnostics.mount(window, buffer)
    window:SelectTab(1)
    return window
end
return App
