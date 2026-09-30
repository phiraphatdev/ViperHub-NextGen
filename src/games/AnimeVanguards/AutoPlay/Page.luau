--!strict
--[[
Purpose: Render Auto Play tab controls with mutual exclusion and dynamic status
Input: WindUI tab handle, AutoPlay runtime and Macro runtime
Output: Mounted WindUI controls for native in-game Auto Play
Dependencies: Runtime
]]

local Page = {}

local RULES_ERRORS: { [string]: string } = {
    AUTOPLAY_ENABLED = "Turn off Auto play - ingame before changing presets.",
    MACRO_ACTIVE = "Stop Play Macro before changing presets.",
    PRESET_UNKNOWN = "That preset is not in the game's preset list.",
    INVALID_RULE = "That rule could not be saved.",
}

-- Mounts one dropdown per supported mode; dropdowns lock while Auto Play or Play Macro is active.
local function mountRules(tab: any, runtime: any, macro: any?)
    local modes = runtime.getCatalog()
    tab:Paragraph({
        Title = "Stage Preset Rules",
        Desc = "Choose a saved Auto Play preset per game mode. None leaves the game's current preset untouched. Rules apply only while Auto play - ingame is on and can be edited only while it is off.",
    })
    if not modes then
        tab:Paragraph({
            Title = "Mode list unavailable",
            Desc = "The game's mode data could not be read yet.",
        })
        return
    end

    local rows: { any } = {}
    local syncing = false

    local function labelFor(row: any, options: { any }): string
        local entry = runtime.getRule(row.mode)
        if not entry then
            return "None"
        end
        for _, option in options do
            if option.id == entry.id then
                return option.label
            end
        end
        return entry.name
    end

    local function refreshRow(row: any)
        local options = runtime.getPresetOptions()
        local labels: { string } = {}
        local byLabel: { [string]: string? } = {}
        for _, option in options do
            table.insert(labels, option.label)
            byLabel[option.label] = option.id
        end
        local current = labelFor(row, options)
        if not table.find(labels, current) then
            table.insert(labels, current)
        end
        row.byLabel = byLabel
        local signature = current .. "|" .. table.concat(labels, "|")
        if row.signature == signature then
            return
        end
        row.signature = signature
        -- WindUI calls the dropdown callback from Refresh/Select, so mark the value as current first
        -- and ignore echoes; otherwise a refused edit would refresh, echo and loop forever.
        row.current = current
        syncing = true
        local dropdown = row.dropdown
        if type(dropdown.Select) == "function" then
            pcall(dropdown.Select :: any, dropdown, current)
        end
        if type(dropdown.Refresh) == "function" then
            pcall(dropdown.Refresh :: any, dropdown, labels)
        end
        syncing = false
    end

    local function applyLock()
        local locked = runtime.isRulesLocked()
        for _, row in rows do
            local dropdown = row.dropdown
            local method = if locked then dropdown.Lock else dropdown.Unlock
            if type(method) == "function" then
                pcall(method :: any, dropdown)
            end
        end
    end

    local function refreshAll()
        for _, row in rows do
            refreshRow(row)
        end
        applyLock()
    end

    local section = tab:Section({ Title = "Preset per mode", Opened = true })
    for _, mode in modes do
        local row: any = { mode = mode, byLabel = {} }
        row.dropdown = section:Dropdown({
            Title = mode,
            Values = { "None" },
            Value = "None",
            Callback = function(label: string)
                if syncing or label == row.current then
                    return
                end
                local ok, err = runtime.setRule(row.mode, row.byLabel[label])
                if ok then
                    row.current = label
                    row.signature = nil
                else
                    pcall(function()
                        runtime.onStatus(RULES_ERRORS[err or ""] or ("Error: " .. tostring(err)))
                    end)
                    row.signature = nil
                    refreshRow(row)
                end
            end,
        })
        table.insert(rows, row)
    end

    tab:Button({
        Title = "Refresh preset list",
        Desc = "Asks the game to resend your saved Auto Play presets.",
        Callback = function()
            runtime.refreshPresets()
        end,
    })

    runtime.onRulesChange(refreshAll)
    runtime.onEnabledChange(function()
        applyLock()
    end)
    if macro and type((macro :: any).onModeChange) == "function" then
        (macro :: any).onModeChange(function()
            applyLock()
        end)
    end
    refreshAll()
end

--- Mounts the Auto Play page controls on the given WindUI tab.
function Page.mount(tab: any, runtime: any, macro: any?)
    tab:Paragraph({
        Title = "Auto Play",
        Desc = "In-game automation controls for Anime Vanguards native Auto Play.",
    })

    local status = tab:Paragraph({
        Title = "Auto Play Status",
        Desc = if runtime then runtime.status else "Unavailable",
    })

    if runtime then
        runtime.onStatus = function(val: string)
            pcall(status.SetDesc, status, val)
        end
    end

    local section = tab:Section({ Title = "In-Game Automation", Opened = true })

    section:Paragraph({
        Title = "Native Auto Play",
        Desc = "Directly engages the game's built-in Auto Play feature. If the match hasn't started yet, automatically votes to start before activating Auto Play.",
    })

    local autoPlayToggle: any
    autoPlayToggle = section:Toggle({
        Title = "Auto play - ingame",
        Desc = "Activates native in-game Auto Play across matches. Mutually exclusive with Play Macro.",
        Value = if runtime then runtime.isEnabled() else false,
        Callback = function(enabled: boolean)
            if not runtime then
                return
            end
            local ok, err = runtime.setEnabled(enabled)
            if not ok then
                if err == "MACRO_ACTIVE" then
                    status:SetDesc("Cannot enable: Play Macro is currently active. Stop macro first.")
                else
                    status:SetDesc("Error: " .. tostring(err))
                end
                if autoPlayToggle and type(autoPlayToggle.Set) == "function" then
                    (autoPlayToggle.Set :: any)(autoPlayToggle, false, false)
                end
            end
        end,
    })
    local function updateAutoPlayLock()
        if not autoPlayToggle then
            return
        end
        local isMacroPlaying = macro and (macro.mode == "play")
        if isMacroPlaying then
            if type(autoPlayToggle.Lock) == "function" then
                pcall(autoPlayToggle.Lock :: any, autoPlayToggle)
            end
        else
            if type(autoPlayToggle.Unlock) == "function" then
                pcall(autoPlayToggle.Unlock :: any, autoPlayToggle)
            end
        end
    end

    if autoPlayToggle then
        updateAutoPlayLock()
    end

    if macro and type((macro :: any).onModeChange) == "function" then
        (macro :: any).onModeChange(function(_m: string)
            updateAutoPlayLock()
        end)
    end

    if runtime then
        runtime.onEnabled = function(enabled: boolean)
            if autoPlayToggle and type(autoPlayToggle.Set) == "function" then
                pcall(autoPlayToggle.Set :: any, autoPlayToggle, enabled, false)
            end
        end
        mountRules(tab, runtime, macro)
    end
end

return Page
