--!strict
--[[
Purpose: Manage state, persistence and automation loop for native in-game Auto Play
Input: AutoPlay Adapter, Macro Runtime and context lifetime
Output: Automatic vote-to-start, Stage Preset Rules and native Auto Play activation across matches
Dependencies: FileStorage; Adapter; Rules; Config
]]

local FileStorage = require("../../../platform/FileStorage")
local config = require("../Config")
local Adapter = require("./Adapter")
local Rules = require("./Rules")
local Runtime = {}
local STORAGE_KEY = "AnimeVanguardsAutoPlay"
local SCHEMA_VERSION = 3
local POLL_SECONDS = 1
local RETRY_SECONDS = 8
local PRESET_ATTEMPTS: number = (config :: any).thresholds.presetSwitchAttempts
local PRESET_TIMEOUT_SECONDS: number = (config :: any).thresholds.presetSwitchTimeoutSeconds
local PRESET_REQUEST_SECONDS: number = (config :: any).thresholds.presetRequestSeconds

--- Creates a runtime controller; injected dependencies support isolated unit tests.
function Runtime.new(
    injectedAdapter: any?,
    injectedStorage: any?,
    injectedTask: any?,
    injectedHttp: any?
): any
    local self: any = {
        adapter = injectedAdapter,
        storage = injectedStorage,
        task = injectedTask,
        http = injectedHttp,
        context = nil,
        enabled = false,
        status = "Disabled",
        onStatus = nil,
        onEnabled = nil,
        enabledListeners = {},
        macro = nil,
        connections = {},
        startVoteSent = false,
        lastVoteRequest = -math.huge,
        lastToggleRequest = -math.huge,
        pendingToggle = false,
        loaded = false,
        rules = Rules.empty(),
        rulesListeners = {},
        presetAttempt = nil,
        lastPresetRequest = -math.huge,
        catalog = nil,
        unsubscribePresets = nil,
    }

    local function setStatus(value: string)
        self.status = value
        if self.onStatus then
            pcall(self.onStatus, value)
        end
    end

    local function getAdapter(): any
        if not self.adapter then
            local ok, ad = pcall(Adapter.new)
            if ok and ad then
                self.adapter = ad
            end
        end
        return self.adapter
    end

    local function save()
        local s = self.storage
        if not s then
            return
        end
        local env: any = getfenv()
        local http = self.http or (env.game and env.game:GetService("HttpService"))
        if not http then
            return
        end
        local ok, body = pcall(http.JSONEncode, http, {
            schemaVersion = SCHEMA_VERSION,
            enabled = self.enabled == true,
            rules = self.rules,
        })
        if ok and type(body) == "string" then
            pcall(s.write, body)
        end
    end

    local function notifyEnabled(val: boolean)
        if self.onEnabled then
            pcall(self.onEnabled, val)
        end
        for _, cb in self.enabledListeners do
            pcall(cb, val)
        end
    end

    local function notifyRules()
        for _, cb in self.rulesListeners do
            pcall(cb)
        end
    end

    --- Registers a callback fired when stored Stage Preset Rules change (for example cleared as unavailable).
    function self.onRulesChange(callback: () -> ())
        if type(callback) == "function" then
            table.insert(self.rulesListeners, callback)
        end
    end

    --- Returns true while rule edits are refused (Auto Play enabled or Play Macro active).
    function self.isRulesLocked(): boolean
        return self.enabled == true or (self.macro ~= nil and self.macro.mode == "play")
    end

    --- Returns the stored rule entry ({id, name}) for a mode, or nil for None.
    function self.getRule(mode: string): any
        return Rules.get(self.rules, mode)
    end

    --- Returns the familiar display name for a game mode id (config table, else spaced CamelCase).
    function self.getModeLabel(mode: string): string
        local known = (config :: any).modeLabels[mode]
        if type(known) == "string" then
            return known
        end
        return (string.gsub(mode, "(%l)(%u)", "%1 %2"))
    end

    --- Returns the latest game presets snapshot, or nil when the game has not reported any yet.
    function self.getPresets(): any
        local ad = getAdapter()
        return if ad and type(ad.getPresets) == "function" then (ad.getPresets :: any)() else nil
    end

    --- Returns dropdown options (None first, then live presets); presets unknown yields only None.
    function self.getPresetOptions(): { Rules.Option }
        return Rules.options(self.getPresets())
    end

    --- Returns the modes Auto Play supports, cached after the first successful read; nil if unavailable.
    function self.getCatalog(): any
        if not self.catalog then
            local ad = getAdapter()
            if ad and type(ad.getModes) == "function" then
                local ok, result = pcall(ad.getModes)
                if ok and type(result) == "table" then
                    self.catalog = result
                end
            end
        end
        return self.catalog
    end

    --- Asks the game to resend its presets (read-only); returns whether the request was sent.
    function self.refreshPresets(): boolean
        local ad = getAdapter()
        if ad and type(ad.trackPresets) == "function" then
            (ad.trackPresets :: any)()
        end
        return ad ~= nil and type(ad.requestPresets) == "function" and (ad.requestPresets :: any)() == true
    end

    --- Sets or clears (id nil = None) the preset for a mode; returns ok and an error code.
    function self.setRule(mode: string, id: string?): (boolean, string?)
        if self.enabled then
            return false, "AUTOPLAY_ENABLED"
        end
        if self.macro and self.macro.mode == "play" then
            return false, "MACRO_ACTIVE"
        end
        if id == nil then
            Rules.set(self.rules, mode, nil)
        else
            local presets = self.getPresets()
            local name = presets and presets.names[id]
            if type(name) ~= "string" then
                return false, "PRESET_UNKNOWN"
            end
            if not Rules.set(self.rules, mode, { id = id, name = name }) then
                return false, "INVALID_RULE"
            end
        end
        save()
        return true, nil
    end

    local function onPresetsSnapshot(snapshot: Rules.Presets)
        if Rules.prune(self.rules, snapshot) > 0 then
            save()
            setStatus("Stage preset rule cleared: preset was deleted or renamed")
        end
        notifyRules()
        if self.enabled then
            self.step()
        end
    end

    -- Applies the Stage Preset Rule for the current mode before Auto Play is engaged.
    -- Returns true when Auto Play handling may continue, false while a preset change is pending.
    local function ensurePreset(ad: any, current: number): boolean
        if type(ad.getGameData) ~= "function" or type(ad.getPresets) ~= "function" then
            return true
        end
        if self.macro and self.macro.mode == "play" then
            return true
        end
        local data = (ad.getGameData :: any)()
        if not data then
            setStatus("Waiting for game data")
            return false
        end
        local entry = Rules.get(self.rules, data.mode)
        if not entry then
            self.presetAttempt = nil
            return true
        end
        local presets = (ad.getPresets :: any)()
        if not presets then
            if type(ad.trackPresets) == "function" then
                (ad.trackPresets :: any)()
            end
            if current - self.lastPresetRequest >= PRESET_REQUEST_SECONDS then
                self.lastPresetRequest = current
                if type(ad.requestPresets) == "function" then
                    (ad.requestPresets :: any)()
                end
            end
            setStatus("Waiting for preset list")
            return false
        end
        if Rules.resolve(entry, presets) ~= "ok" then
            Rules.set(self.rules, data.mode, nil)
            self.presetAttempt = nil
            save()
            notifyRules()
            setStatus("Stage preset rule cleared: preset was deleted or renamed")
            return true
        end
        if presets.active == entry.id then
            self.presetAttempt = nil
            return true
        end
        local key = data.mode .. "/" .. entry.id
        local attempt: any = self.presetAttempt
        if not attempt or attempt.key ~= key then
            attempt = { key = key, sent = 0, last = -math.huge, lastPause = -math.huge, gaveUp = false }
            self.presetAttempt = attempt
        end
        if attempt.gaveUp then
            return true
        end
        if ad.isAutoPlaying() == true then
            if current - attempt.lastPause >= RETRY_SECONDS then
                attempt.lastPause = current
                ad.toggle()
            end
            setStatus("Pausing native Auto Play to switch preset")
            return false
        end
        if attempt.sent > 0 and current - attempt.last < PRESET_TIMEOUT_SECONDS then
            setStatus("Waiting for preset switch confirmation")
            return false
        end
        if attempt.sent >= PRESET_ATTEMPTS then
            attempt.gaveUp = true
            setStatus("Preset switch not confirmed; continuing with current preset")
            return true
        end
        attempt.sent += 1
        attempt.last = current
        if ad.switchPreset(entry.id) then
            setStatus(string.format("Switching preset (%d/%d)", attempt.sent :: any, PRESET_ATTEMPTS))
        else
            setStatus("Preset switch request failed")
        end
        return false
    end

    function self.onEnabledChange(callback: (boolean) -> ())
        if type(callback) == "function" then
            table.insert(self.enabledListeners, callback)
        end
    end

    function self.setMacro(m: any)
        self.macro = m
    end

    function self.isEnabled(): boolean
        return self.enabled == true
    end

    function self.setEnabled(value: boolean): (boolean, string?)
        if type(value) ~= "boolean" then
            return false, "INVALID_VALUE"
        end
        if value and self.macro and self.macro.mode == "play" then
            return false, "MACRO_ACTIVE"
        end
        if self.enabled == value then
            return true, nil
        end
        self.enabled = value
        self.startVoteSent = false
        self.presetAttempt = nil
        notifyEnabled(value)
        save()
        if value then
            setStatus("Enabled: waiting for match")
            self.step()
        else
            local ad = getAdapter()
            local state = ad and ad.isAutoPlaying()
            if state == true and not self.pendingToggle then
                self.pendingToggle = ad.toggle() == true
            end
            setStatus("Disabled")
        end
        return true, nil
    end

    function self.step(now: number?)
        if not self.enabled or not self.context or not self.context.alive then
            return
        end
        local ad = getAdapter()
        if not ad or not ad.isAvailable() then
            setStatus("Auto Play unavailable (not in match)")
            return
        end
        local clockFn = (self.task and self.task.clock) or (ad and ad.clock) or os.clock
        local current = now or (if type(clockFn) == "function" then (clockFn :: any)() else os.clock())
        local started = ad.isMatchStarted()
        if started == nil then
            setStatus("Waiting for game data")
            return
        end
        if not ensurePreset(ad, current) then
            return
        end
        if not started then
            self.pendingToggle = false
            if ad.hasStartPrompt() and current - self.lastVoteRequest >= RETRY_SECONDS then
                self.lastVoteRequest = current
                if ad.castStartVote() then
                    self.startVoteSent = true
                    setStatus("Vote to Start sent; awaiting match")
                else
                    setStatus("Vote to Start request failed")
                end
            else
                setStatus(
                    if self.startVoteSent then "Awaiting match start..." else "Awaiting Vote to Start prompt"
                )
            end
            return
        end
        local state = ad.isAutoPlaying()
        if state == nil then
            setStatus("Waiting for native Auto Play state")
        elseif state then
            self.pendingToggle = false
            setStatus("Native Auto Play active")
        elseif not self.pendingToggle and current - self.lastToggleRequest >= RETRY_SECONDS then
            self.lastToggleRequest = current
            self.pendingToggle = ad.toggle() == true
            setStatus(
                if self.pendingToggle then "Enabling native Auto Play..." else "Auto Play request failed"
            )
        elseif self.pendingToggle and current - self.lastToggleRequest >= RETRY_SECONDS then
            self.pendingToggle = false
            setStatus("Auto Play confirmation timed out; retrying")
        end
    end

    function self.start(context: any)
        self.context = context
        local env: any = getfenv()
        if not self.storage then
            pcall(function()
                self.storage = FileStorage.new(env, STORAGE_KEY)
            end)
        end
        if self.storage then
            pcall(function()
                local body = self.storage.read()
                local http = self.http or (env.game and env.game:GetService("HttpService"))
                if body and http then
                    local ok, data = pcall(http.JSONDecode, http, body)
                    if
                        ok
                        and type(data) == "table"
                        and (
                            data.schemaVersion == SCHEMA_VERSION
                            or data.schemaVersion == 2
                            or data.schemaVersion == 1
                        )
                    then
                        if type(data.enabled) == "boolean" then
                            self.enabled = data.enabled
                        end
                        self.rules = Rules.normalize(data.rules)
                    end
                end
            end)
        end

        if self.enabled and self.macro and self.macro.mode == "play" then
            self.enabled = false
            save()
            setStatus("Play Macro active; native Auto Play disabled")
        end
        notifyEnabled(self.enabled)
        self.loaded = true
        local ad = getAdapter()
        if ad and type(ad.observe) == "function" then
            local connRestart = (ad.observe :: any)("matchRestarted", function()
                self.presetAttempt = nil
                self.startVoteSent = false
                self.pendingToggle = false
                self.lastVoteRequest = -math.huge
                self.lastToggleRequest = -math.huge
                if self.enabled then
                    self.step()
                end
            end)
            if connRestart then
                table.insert(self.connections, connRestart)
            end
            local connStart = (ad.observe :: any)("matchStarted", function()
                if self.enabled then
                    self.step()
                end
            end)
            if connStart then
                table.insert(self.connections, connStart)
            end
            local connToggled = (ad.observe :: any)("autoPlayToggled", function(toggled: boolean)
                self.pendingToggle = false
                if self.enabled then
                    setStatus(
                        if toggled
                            then "Native Auto Play active"
                            else "Native Auto Play was turned off in-game"
                    )
                end
            end)
            if connToggled then
                table.insert(self.connections, connToggled)
            end
        end

        local function trackPresets()
            if
                not self.unsubscribePresets
                and ad
                and type(ad.trackPresets) == "function"
                and type(ad.onPresetsUpdated) == "function"
                and (ad.trackPresets :: any)()
            then
                self.unsubscribePresets = (ad.onPresetsUpdated :: any)(onPresetsSnapshot)
            end
        end
        trackPresets()

        if self.enabled then
            setStatus("Enabled")
            self.step()
        else
            setStatus("Disabled")
        end

        local taskApi = (if self.task then self.task else nil) or env.task
        if
            type(taskApi) == "table"
            and type(taskApi.spawn) == "function"
            and type(taskApi.wait) == "function"
        then
            (taskApi.spawn :: any)(function()
                while self.context == context and context.alive do
                    trackPresets()
                    if self.enabled then
                        self.step()
                    end
                    (taskApi.wait :: any)(POLL_SECONDS)
                end
            end)
        end
    end

    function self.stop()
        for _, connection in self.connections do
            local conn: any = connection
            local ok = pcall(function()
                conn:Disconnect()
            end)
            if not ok then
                pcall(function()
                    conn()
                end)
            end
        end
        table.clear(self.connections)
        if type(self.unsubscribePresets) == "function" then
            pcall(self.unsubscribePresets)
        end
        self.unsubscribePresets = nil
        local ad = self.adapter
        if ad and type(ad.untrackPresets) == "function" then
            pcall(ad.untrackPresets)
        end
        self.presetAttempt = nil
        self.context = nil
        self.startVoteSent = false
        self.pendingToggle = false
        self.loaded = false
    end

    return self
end

return Runtime
