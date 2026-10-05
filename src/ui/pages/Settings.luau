--!strict
--[[
Purpose: Bind configuration controls through the config store
Input: Window; store; library; key lookup; context
Output: Settings tab
Dependencies: ConfigStore; WindUI keybind; runtime task scheduler
]]

local Theme = require("../Theme")
local Settings = {}
local runtimeTask: any = getfenv().task
local function applyToggleKey(window: any, store: any, keyCodes: any, value: any, control: any?)
    local previous = store.get().toggleKey
    store.update("toggleKey", value)
    local selected = store.get().toggleKey
    if selected ~= value and type(control) == "table" and type(control.Set) == "function" then
        (control.Set :: any)(control, previous)
    end
    window:SetToggleKey(keyCodes[selected])
end
--- Mounts controls; valid changes autosave when the storage backend is available.
--- tabHost (optional) is the sidebar section that receives the tab; window still owns the toggle key.
function Settings.mount(window: any, store: any, library: any, keyCodes: any, context: any?, tabHost: any?)
    local config = store.get()
    local tab = (tabHost or window):Tab({ Title = "Settings", Icon = "settings", ShowTabTitle = true })
    local controls: { [string]: any } = {}
    window.ViperControls = controls
    tab:Paragraph({
        Title = "Storage",
        Desc = if store.persistent
            then "Autosave available; Save settings is an optional manual check"
            else "Session only: filesystem APIs unavailable",
    })
    controls.notifications = tab:Toggle({
        Title = "Notifications",
        Value = config.notifications,
        Callback = function(value: boolean)
            store.update("notifications", value)
        end,
    })
    controls.uiScale = tab:Slider({
        Title = "UI scale",
        Step = 0.05,
        Value = { Min = 0.8, Max = 1.3, Default = config.uiScale },
        Callback = function(value: number)
            store.update("uiScale", value)
            if window.SetUIScale then
                (window.SetUIScale :: any)(window, store.get().uiScale)
            end
        end,
    })
    controls.theme = tab:Dropdown({
        Title = "Theme",
        Desc = "ViperHub themes first, then the library's own. Changes apply instantly.",
        Values = Theme.list(library),
        Value = config.theme,
        Callback = function(value: string)
            store.update("theme", value)
            if type(library) == "table" and type(library.SetTheme) == "function" then
                pcall(library.SetTheme, library, store.get().theme)
            end
        end,
    })
    window:SetToggleKey(keyCodes[config.toggleKey])
    controls.toggleKey = tab:Keybind({
        Title = "Toggle UI key",
        Value = config.toggleKey,
        Callback = function(value: string)
            applyToggleKey(window, store, keyCodes, value, controls.toggleKey)
        end,
    })
    -- The pinned WindUI picker changes Value after its label Text, without firing Callback.
    local keyUi = controls.toggleKey
        and controls.toggleKey.UIElements
        and controls.toggleKey.UIElements.Keybind
    local keyFrame = keyUi and keyUi.Frame and keyUi.Frame.Frame
    local keyLabel = keyFrame and keyFrame.TextLabel
    if
        context
        and keyLabel
        and type(keyLabel.GetPropertyChangedSignal) == "function"
        and type(runtimeTask) == "table"
        and type(runtimeTask.defer) == "function"
    then
        local connection = keyLabel:GetPropertyChangedSignal("Text"):Connect(function()
            runtimeTask.defer(function()
                local tk: any = controls.toggleKey
                if context.alive and type(tk) == "table" and tk.Value ~= store.get().toggleKey then
                    applyToggleKey(window, store, keyCodes, tk.Value, tk)
                end
            end)
        end)
        context.cleanup.add(function()
            connection:Disconnect()
        end)
    end
    -- The floating ViperHub button shown while the window is hidden. PC players can hide it and use the toggle key;
    -- on a device without a keyboard it always shows, so the window can always be reopened.
    local function applyOpenButton(show: boolean)
        local keyboard = true
        pcall(function()
            keyboard = (getfenv() :: any).game:GetService("UserInputService").KeyboardEnabled
        end)
        local visible = show or not keyboard
        window.IsOpenButtonEnabled = visible
        local openMain: any = window.OpenButtonMain
        if type(openMain) == "table" and type(openMain.Visible) == "function" then
            pcall(openMain.Visible, openMain, visible and window.Closed == true)
        end
    end
    applyOpenButton(config.openButton)
    controls.openButton = tab:Toggle({
        Title = "Show Open Button",
        Desc = "The ViperHub button shown while the window is hidden. Off: use the Toggle UI key (always shown without a keyboard).",
        Value = config.openButton,
        Callback = function(value: boolean)
            store.update("openButton", value)
            applyOpenButton(store.get().openButton)
        end,
    })
    controls.save = tab:Button({
        Title = "Save settings",
        Callback = function()
            -- WindUI's picker updates Value; Callback fires on key press, not selection.
            applyToggleKey(window, store, keyCodes, controls.toggleKey.Value, controls.toggleKey)
            controls.toggleKey:Set(store.get().toggleKey)
            local saved = store.save()
            if saved and not store.get().notifications then
                return
            end
            library:Notify({
                Title = "Settings",
                Content = if saved then "Saved and read back" else "Not saved; inspect Diagnostics",
                Duration = 4,
            })
        end,
    })
end
return Settings
