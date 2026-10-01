--!strict
--[[
Purpose: Render game-owned macro file, playback and unit-control guidance
Input: WindUI tab and macro runtime
Output: Validated UI callbacks and status
Dependencies: Storage; Runtime
]]
local Style = require("../Style")
local Storage = require("./Storage")
local Document = require("./Document")
local Page = {}

local function humanError(code: any): string
    local s = tostring(code)
    if s == "MACRO_NAME_INVALID" then
        return "Invalid macro name (use alphanumeric, _, or -)"
    elseif s == "MACRO_EXISTS" then
        return "A macro with this name already exists"
    elseif s == "MACRO_MISSING" then
        return "Macro file not found on disk"
    elseif s == "MACRO_BUSY" then
        return "Macro is busy (recording or playing)"
    elseif s == "MACRO_MATCH_UNAVAILABLE" then
        return "Match not available: enter a match first"
    elseif s == "MACRO_ADAPTER_UNAVAILABLE" then
        return "Game modules are still loading..."
    elseif s == "MACRO_JSON_INVALID" then
        return "Macro JSON is invalid or corrupted"
    elseif s == "MACRO_SCHEMA_UNSUPPORTED" then
        return "Macro version is unsupported"
    elseif s == "AUTOPLAY_ACTIVE" then
        return "Cannot play macro while Auto play - ingame is active. Turn it off first."
    end
    return s
end

--- Mounts macro controls and returns nothing.
function Page.mount(tab: any, runtime: any, window: any?, autoPlay: any?)
    local env: any = getfenv()
    local codec = env.game:GetService("HttpService")
    local storage = Storage.new(env, codec)
    local selected = ""
    local entered = ""
    local deletePending = ""
    local status: any = nil
    tab:Paragraph({
        Title = "Macro Studio",
        Desc = "Record confirmed game actions; replay requires a live match. Advanced features are planned.",
    })
    local files = Style.section(tab, "Macro Files", "folder", true)
    if not storage then
        files:Paragraph({
            Title = "Storage",
            Desc = "Executor listfiles/delfile/readfile/writefile APIs are required.",
        })
        return
    end
    runtime.setStorage(storage)
    files:Paragraph({ Title = "Folder", Desc = "workspace/ViperHubNextGen/macro/AnimeVanguards" })
    local choices = storage.list()
    if #choices == 0 then
        choices = { "(none)" }
    end
    selected = choices[1] ~= "(none)" and choices[1] or ""
    local picker = files:Dropdown({
        Title = "Select macro",
        Values = choices,
        Value = choices[1],
        Callback = function(value: string)
            selected = if value == "(none)" then "" else value
            deletePending = ""
        end,
    })
    local function refresh()
        local values = storage.list()
        if #values == 0 then
            values = { "(none)" }
        end
        picker:Refresh(values)
        local chosen = if table.find(values, selected) then selected else values[1]
        selected = chosen ~= "(none)" and chosen or ""
        picker:Select(chosen)
    end
    files:Input({
        Title = "New macro name",
        Placeholder = "e.g. Story_Stage14",
        Callback = function(value: string)
            entered = value:match("^%s*(.-)%s*$") or value
        end,
    })
    files:Button({
        Title = "Create macro",
        Callback = function()
            if runtime.mode ~= "idle" then
                status:SetDesc("Stop Record or Play before editing files")
                return
            end
            if entered == "" then
                status:SetDesc("Enter a valid macro name first")
                return
            end
            local ok, err = storage.write(entered, Document.empty(entered), false)
            status:SetDesc(if ok then "Created " .. entered else humanError(err))
            if ok then
                selected = entered
                refresh()
            end
        end,
    })
    files:Button({ Title = "Refresh files", Callback = refresh })
    files:Button({
        Title = "Delete macro",
        Callback = function()
            if runtime.mode ~= "idle" then
                status:SetDesc("Stop Record or Play before editing files")
                return
            end
            if selected == "" then
                status:SetDesc("Select a macro first")
                return
            end
            local name = selected
            if window and window.Dialog then
                (window :: any):Dialog({
                    Title = "Delete " .. name .. "?",
                    Content = "This permanently removes the selected macro JSON.",
                    Buttons = {
                        { Title = "Cancel" },
                        {
                            Title = "Delete",
                            Callback = function()
                                local ok, err = storage.delete(name)
                                status:SetDesc(if ok then "Deleted " .. name else humanError(err))
                                refresh()
                            end,
                        },
                    },
                })
            elseif deletePending ~= name then
                deletePending = name
                status:SetDesc("Press Delete macro again to confirm: " .. name)
            else
                local ok, err = storage.delete(name)
                status:SetDesc(if ok then "Deleted " .. name else humanError(err))
                deletePending = ""
                refresh()
            end
        end,
    })
    local operations = Style.section(tab, "Record & Play", "circle-play", true)
    status = operations:Paragraph({ Title = "Macro status", Desc = runtime.status })
    runtime.onStatus = function(value: string)
        status:SetDesc(value)
    end
    local syncing = false
    local recordToggle: any = nil
    local playToggle: any = nil
    runtime.onMode = function(value: string)
        syncing = true
        if value == "idle" then
            picker:Unlock()
        else
            picker:Lock()
        end
        if recordToggle then
            recordToggle:Set(value == "record", false)
        end
        if playToggle then
            playToggle:Set(value == "play", false)
        end
        syncing = false
    end
    runtime.onSaved = function()
        refresh()
    end
    recordToggle = operations:Toggle({
        Title = "Record macro",
        Desc = "Starting clears the selected file. Turning off saves automatically.",
        Value = runtime.mode == "record",
        Callback = function(enabled: boolean)
            if syncing then
                return
            end
            if not enabled then
                if runtime.mode == "record" and not runtime.finishRecord() then
                    recordToggle:Set(true, false)
                end
                return
            end
            if selected == "" then
                status:SetDesc("Create or select a macro first")
                recordToggle:Set(false, false)
                return
            end
            local ok, err = runtime.record(selected)
            if not ok then
                status:SetDesc(humanError(err))
                recordToggle:Set(false, false)
            end
        end,
    })
    playToggle = operations:Toggle({
        Title = "Play macro",
        Desc = "Votes to start when offered, then plays the selected file.",
        Value = runtime.mode == "play",
        Callback = function(enabled: boolean)
            if syncing then
                return
            end
            if not enabled then
                runtime.stopPlayback()
                return
            end
            if autoPlay and type(autoPlay.isEnabled) == "function" and (autoPlay.isEnabled :: any)() then
                status:SetDesc("Cannot play macro while Auto play - ingame is active. Turn it off first.")
                playToggle:Set(false, false)
                return
            end
            if selected == "" then
                status:SetDesc("Select a macro first")
                playToggle:Set(false, false)
                return
            end
            local document, err = storage.read(selected)
            if not document then
                status:SetDesc(humanError(err))
                playToggle:Set(false, false)
                return
            end
            local ok, playError = runtime.play(document)
            if not ok then
                status:SetDesc(humanError(playError))
                playToggle:Set(false, false)
            end
        end,
    })
    local function updatePlayMacroLock()
        if not playToggle then
            return
        end
        local isAutoPlayActive = autoPlay
            and type(autoPlay.isEnabled) == "function"
            and (autoPlay.isEnabled :: any)()
        if isAutoPlayActive then
            if type(playToggle.Lock) == "function" then
                pcall(playToggle.Lock :: any, playToggle)
            end
        else
            if type(playToggle.Unlock) == "function" then
                pcall(playToggle.Unlock :: any, playToggle)
            end
        end
    end

    if playToggle then
        updatePlayMacroLock()
    end

    if autoPlay and type((autoPlay :: any).onEnabledChange) == "function" then
        (autoPlay :: any).onEnabledChange(function(_en: boolean)
            updatePlayMacroLock()
        end)
    end
    runtime.onMode(runtime.mode)
    local config = Style.section(tab, "Play Macro Config", "sliders-horizontal", true)
    config:Toggle({
        Title = "Ignore Timing",
        Desc = "Use wave and live action price first; ability timing is retained.",
        Value = runtime.settings.ignoreTiming,
        Callback = function(value: boolean)
            runtime.settings.ignoreTiming = value
        end,
    })
    config:Toggle({
        Title = "No Ignore Sell Timing",
        Desc = "Keep the recorded sell timing.",
        Value = runtime.settings.noIgnoreSellTiming,
        Callback = function(value: boolean)
            runtime.settings.noIgnoreSellTiming = value
        end,
    })
    config:Slider({
        Title = "Macro Retry Limit",
        Desc = "Total attempts including the original position (1-10). Placement retries move up to 2 studs.",
        Step = 1,
        Value = { Min = 1, Max = 10, Default = runtime.settings.retryLimit },
        Callback = function(value: number)
            runtime.settings.retryLimit = value
        end,
    })
    config:Dropdown({
        Title = "After placement failure",
        Desc = "Action after all placement attempts fail; Stop is the default.",
        Values = { "Restart", "Stop", "None", "Return to Lobby" },
        Value = runtime.settings.placementFailure,
        Callback = function(value: string)
            runtime.settings.placementFailure = value
        end,
    })
    local misc = Style.section(tab, "Misc", "wrench", false)
    misc:Button({
        Title = "Check Macro's Unit",
        Callback = function()
            if runtime.mode ~= "idle" then
                return
            end
            if selected == "" then
                status:SetDesc("Select a macro first")
                return
            end
            local document, err = storage.read(selected)
            if not document then
                status:SetDesc(tostring(err))
                return
            end
            local team = if runtime.adapter and runtime.adapter.teamUnits
                then (runtime.adapter.teamUnits :: any)()
                else {}
            local missing = {}
            for _, name in document.units do
                if not table.find(team, name) then
                    table.insert(missing, name)
                end
            end
            status:SetDesc(
                if #document.units == 0
                    then "No units recorded"
                    else if #missing == 0
                        then "All macro units are in the current team"
                        else "Missing or team unavailable: " .. table.concat(missing, ", ")
            )
        end,
    })
    misc:Button({
        Title = "Equip Macro's Units",
        Locked = true,
        Desc = "Planned: lobby equip readback required.",
    })
    misc:Toggle({
        Title = "Auto Equip Macro's Units",
        Locked = true,
        Value = false,
        Desc = "Planned: disabled in V1.",
    })
    misc:Paragraph({
        Title = "Recorded unit controls",
        Desc = "Auto Upgrade, its priority, and Auto Ability toggles are recorded from confirmed game updates and replayed in order. Placement remains direct-only.",
    })
end
return Page
