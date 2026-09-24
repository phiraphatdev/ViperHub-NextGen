--!strict
--[[
Purpose: Bind configuration controls through the config store
Input: Window; store; library; key lookup; context
Output: Settings tab
Dependencies: ConfigStore; WindUI keybind; runtime task scheduler
]]

local Settings = {}
local runtimeTask: any = getfenv().task
local function applyToggleKey(window: any, store: any, keyCodes: any, value: any, control: any?)
    local previous = store.get().toggleKey
    store.update("toggleKey", value)
    local selected = store.get().toggleKey
    if selected ~= value then
        store.update("toggleKey", previous)
        selected = previous
        if type(control) == "table" and type(control.Set) == "function" then
            (control.Set :: any)(control, previous)
        end
    end
    window:SetToggleKey(keyCodes[selected])
end
--- Mounts controls; save changes persist only when the storage backend is available.
function Settings.mount(window: any, store: any, library: any, keyCodes: any, context: any?)
    local config = store.get()
    local tab = window:Tab({ Title = "Settings", Icon = "settings" })
    local controls: { [string]: any } = {}
    window.ViperControls = controls
    tab:Paragraph({
        Title = "Storage",
        Desc = if store.persistent
            then "File persistence available"
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
        Values = { "Dark" },
        Value = config.theme,
        Callback = function(value: string)
            store.update("theme", value)
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
                if context.alive and controls.toggleKey.Value ~= store.get().toggleKey then
                    applyToggleKey(window, store, keyCodes, controls.toggleKey.Value, controls.toggleKey)
                end
            end)
        end)
        context.cleanup.add(function()
            connection:Disconnect()
        end)
    end
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
