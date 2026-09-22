--!strict
--[[
Purpose: Bind configuration controls through the config store
Input: Window; store; library; key lookup
Output: Settings tab
Dependencies: None
]]

local Settings = {}
--- Mounts controls; save changes persist only when the storage backend is available.
function Settings.mount(window: any, store: any, library: any, keyCodes: any)
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
        Title = "Toggle UI (RightShift / LeftAlt / F4)",
        Value = config.toggleKey,
        Callback = function(value: string)
            store.update("toggleKey", value)
            window:SetToggleKey(keyCodes[store.get().toggleKey])
        end,
    })
    controls.save = tab:Button({
        Title = "Save settings",
        Callback = function()
            -- WindUI's picker updates Value; Callback fires on key press, not selection.
            store.update("toggleKey", controls.toggleKey.Value)
            controls.toggleKey:Set(store.get().toggleKey)
            window:SetToggleKey(keyCodes[store.get().toggleKey])
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
