--!strict
--[[
Purpose: Keep a farming session alive: Anti-AFK on the idle signal, Auto Reconnect after real disconnects and
         re-running the hub after a teleport
Input: LocalPlayer.Idled, VirtualUser, GuiService error state, TeleportService, executor queue_on_teleport and file storage
Output: Saved toggles, a status line and bounded reconnect attempts to the lobby place
Dependencies: Config; Metadata; FileStorage
]]

local FileStorage = require("../../../platform/FileStorage")
local config = require("../Config")
local metadata = require("../Metadata")
local Runtime = {}

local STORAGE_KEY = "AnimeVanguardsMisc"
local SCHEMA_VERSION = 1
local MISC: any = (config :: any).misc

--- Returns true for a loader URL that can be embedded safely in the queued loadstring line.
function Runtime.validLoaderUrl(url: any): boolean
    return type(url) == "string"
        and #url <= 300
        and string.match(url, "^https?://[%w%.%-]+[:%d]*/[%w%./%-_]*%.lua$") ~= nil
end

--- The line queued for the next place: the same loadstring command the player uses.
function Runtime.loaderLine(url: string): string
    return string.format('loadstring(game:HttpGet("%s"))()', url)
end

local function liveDependencies(): any?
    local env: any = getfenv()
    local gameObject = env.game
    if not gameObject then
        return nil
    end
    local players = gameObject:GetService("Players")
    local virtualUser = gameObject:GetService("VirtualUser")
    local guiService = gameObject:GetService("GuiService")
    local teleportService = gameObject:GetService("TeleportService")
    local http = gameObject:GetService("HttpService")
    local queue: any = env.queue_on_teleport or env.queueonteleport
    local vector2: any = env.Vector2
    return {
        task = env.task,
        clock = os.clock,
        encode = function(value: any): string
            return http:JSONEncode(value)
        end,
        decode = function(text: string): any
            return http:JSONDecode(text)
        end,
        storage = FileStorage.new(env, STORAGE_KEY),
        idled = players.LocalPlayer.Idled,
        nudge = function()
            virtualUser:CaptureController()
            virtualUser:ClickButton2(vector2.new())
        end,
        errorChanged = guiService.ErrorMessageChanged,
        errorCode = function(): string?
            local ok, code = pcall(guiService.GetErrorCode, guiService)
            return if ok and code then code.Name else nil
        end,
        teleport = function(placeId: number): boolean
            return (pcall(teleportService.Teleport, teleportService, placeId, players.LocalPlayer))
        end,
        queue = if type(queue) == "function" then queue else nil,
    }
end

--- Creates a stopped controller; injected dependencies support isolated tests.
function Runtime.new(injected: any?): any
    local self: any = {
        deps = injected,
        settings = {
            antiAfk = true,
            autoReconnect = false,
            rerunOnTeleport = false,
            loaderUrl = MISC.defaultLoaderUrl,
        },
        status = "Idle",
        onStatus = nil,
        context = nil,
        connections = {} :: { any },
        afkCount = 0,
        reconnecting = false,
        queued = false,
        storage = nil,
    }

    local function setStatus(value: string)
        self.status = value
        if self.onStatus then
            pcall(self.onStatus, value)
        end
    end

    local function save()
        local d = self.deps
        if not self.storage or not d or not d.encode then
            return
        end
        local ok, body = pcall(d.encode, {
            schemaVersion = SCHEMA_VERSION,
            antiAfk = self.settings.antiAfk,
            autoReconnect = self.settings.autoReconnect,
            rerunOnTeleport = self.settings.rerunOnTeleport,
            loaderUrl = self.settings.loaderUrl,
        })
        if ok and type(body) == "string" then
            pcall(self.storage.write, body)
        end
    end

    -- Queues the loader for the next place; each new session queues again, so it covers every teleport.
    local function queueRerun()
        local d = self.deps
        if not self.settings.rerunOnTeleport or self.queued or not d or type(d.queue) ~= "function" then
            return
        end
        if not Runtime.validLoaderUrl(self.settings.loaderUrl) then
            setStatus("Re-run after teleport: loader URL is not valid")
            return
        end
        local queueFn: any = d.queue
        if pcall(queueFn, Runtime.loaderLine(self.settings.loaderUrl)) then
            self.queued = true
        end
    end

    --- Returns a copy of the saved toggles.
    function self.getSettings(): any
        return table.clone(self.settings)
    end

    --- True when the executor can queue code for the next place.
    function self.canRerun(): boolean
        return self.deps ~= nil and type(self.deps.queue) == "function"
    end

    function self.setAntiAfk(value: boolean): boolean
        if type(value) ~= "boolean" then
            return false
        end
        self.settings.antiAfk = value
        save()
        return true
    end

    function self.setAutoReconnect(value: boolean): boolean
        if type(value) ~= "boolean" then
            return false
        end
        self.settings.autoReconnect = value
        save()
        return true
    end

    function self.setRerun(value: boolean): boolean
        if type(value) ~= "boolean" then
            return false
        end
        self.settings.rerunOnTeleport = value
        save()
        if value then
            queueRerun()
        end
        return true
    end

    --- Stores the loader URL used by re-run after teleport; returns false for an unsafe or malformed URL.
    function self.setLoaderUrl(value: any): boolean
        local trimmed = if type(value) == "string" then string.match(value, "^%s*(.-)%s*$") else nil
        if not Runtime.validLoaderUrl(trimmed) then
            return false
        end
        self.settings.loaderUrl = trimmed
        save()
        return true
    end

    --- Idle signal from Roblox (about 20 minutes without input): simulate input so the idle kick does not happen.
    function self.onIdle()
        local d = self.deps
        if not self.settings.antiAfk or not d or type(d.nudge) ~= "function" then
            return
        end
        if pcall(d.nudge) then
            self.afkCount += 1
            setStatus(string.format("Anti-AFK: kept the session active (%d)", self.afkCount))
        end
    end

    --- Error prompt changed: reconnect to the lobby only for real disconnects (never kicks, bans or logins elsewhere).
    function self.onDisconnect()
        local d = self.deps
        if not self.settings.autoReconnect or self.reconnecting or not d then
            return
        end
        local errorCodeFn: any = d.errorCode
        local code: any = if type(errorCodeFn) == "function" then (errorCodeFn :: any)() else nil
        if type(code) ~= "string" or table.find(MISC.reconnectErrors, code) == nil then
            return
        end
        self.reconnecting = true
        local ctx = self.context
        local taskApi: any = d.task
        local function run()
            local waitTask: any = if taskApi then taskApi.wait else nil
            if type(waitTask) == "function" then
                (waitTask :: any)(MISC.reconnectDelaySeconds)
            end
            -- The next place should load the hub again even when re-run was not queued yet.
            queueRerun()
            for attempt = 1, MISC.reconnectAttempts do
                if ctx ~= self.context then
                    return
                end
                setStatus(
                    string.format(
                        "Reconnecting after %s (%d/%d)",
                        code :: string,
                        attempt,
                        MISC.reconnectAttempts
                    )
                )
                local teleportFn: any = d.teleport
                pcall(teleportFn, metadata.placeIds[1])
                if type(waitTask) == "function" then
                    (waitTask :: any)(MISC.reconnectRetrySeconds)
                end
            end
            setStatus("Auto Reconnect gave up; reconnect manually")
        end
        local spawnTask: any = if taskApi then taskApi.spawn else nil
        if type(spawnTask) == "function" then
            (spawnTask :: any)(run)
        else
            run()
        end
    end

    --- Loads saved toggles, connects the idle and error signals and queues the re-run when enabled.
    function self.start(ctx: any)
        self.context = ctx
        if not self.deps then
            local ok, live = pcall(liveDependencies)
            self.deps = if ok then live else nil
        end
        local d = self.deps
        if not d then
            setStatus("Unavailable in this environment")
            return
        end
        self.storage = d.storage
        if self.storage and d.decode then
            local body = self.storage.read()
            if body then
                local ok, data = pcall(d.decode, body)
                if ok and type(data) == "table" and data.schemaVersion == SCHEMA_VERSION then
                    for _, key in { "antiAfk", "autoReconnect", "rerunOnTeleport" } do
                        if type(data[key]) == "boolean" then
                            self.settings[key] = data[key]
                        end
                    end
                    if Runtime.validLoaderUrl(data.loaderUrl) then
                        self.settings.loaderUrl = data.loaderUrl
                    end
                end
            end
        end
        for _, pair in
            {
                { signal = d.idled, handler = self.onIdle },
                { signal = d.errorChanged, handler = self.onDisconnect },
            } :: { any }
        do
            local signal: any = pair.signal
            local handler: any = pair.handler
            if signal and type(signal.Connect) == "function" then
                local ok, connection = pcall(signal.Connect, signal, function()
                    handler()
                end)
                if ok and connection then
                    table.insert(self.connections, connection)
                end
            end
        end
        queueRerun()
        setStatus(
            string.format(
                "Anti-AFK %s • Auto Reconnect %s • Re-run %s",
                if self.settings.antiAfk then "on" else "off",
                if self.settings.autoReconnect then "on" else "off",
                if self.settings.rerunOnTeleport then (if self.queued then "queued" else "on") else "off"
            )
        )
    end

    --- Disconnects signals; a pending reconnect stops at its next attempt.
    function self.stop()
        for _, connection in self.connections do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(self.connections)
        self.context = nil
        self.reconnecting = false
    end

    return self
end

return Runtime
