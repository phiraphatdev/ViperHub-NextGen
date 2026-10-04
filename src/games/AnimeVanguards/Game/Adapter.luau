--!strict
--[[
Purpose: Interface with in-game gameplay settings via SharedSettingsClient and SettingsState
Input: ReplicatedStorage and StarterPlayer modules, setting mutations
Output: Read, mutate and observe in-game settings (AutoReplay, AutoNext, AutoSkipWaves, AutoSkipStart)
Dependencies: Config; Adventure/Detect
]]

local config = require("../Config")
local AdventureDetect = require("../Adventure/Detect")
local FileStorage = require("../../../platform/FileStorage")
local Adapter = {}
local SETTINGS_STORAGE_KEY = "AnimeVanguardsGameSettings"
local SCHEMA_VERSION = 1

local function resolve(root: any, path: string): any
    local value = root
    for part in string.gmatch(path, "[^%.]+") do
        if not value then
            return nil
        end
        local ok, child = pcall(function()
            local v: any = value
            if type(v) == "userdata" then
                return v:FindFirstChild(part)
            else
                return v[part]
            end
        end)
        value = if ok then child else nil
    end
    return value
end

local function liveDependencies(): any
    local env: any = getfenv()
    local gameObject = env.game
    if not gameObject then
        return nil
    end
    local replicated = gameObject:GetService("ReplicatedStorage")
    local starter = gameObject:GetService("StarterPlayer")
    local codecMod = resolve(replicated, config.instancePaths.settingsCodec)
    local clientMod = resolve(replicated, config.instancePaths.sharedSettingsClient)
    local stateMod = resolve(starter, config.instancePaths.settingsState)
    if not codecMod or not clientMod or not stateMod then
        return nil
    end
    local ok, result = pcall(function()
        return {
            codec = (require :: any)(codecMod),
            client = (require :: any)(clientMod),
            state = (require :: any)(stateMod),
        }
    end)
    return if ok then result else nil
end

--- Creates an adapter for in-game settings; injected dependencies support isolated tests.
function Adapter.new(injectedDeps: any?): any
    local self: any = {
        dependencies = injectedDeps,
        context = nil,
        observers = {},
        stateConnection = nil,
        matchEndConnection = nil,
        autoBackToLobby = false,
        teleportCancelled = false,
        lastKnownValues = {},
    }

    local function getDeps(): any?
        if self.dependencies then
            return self.dependencies
        end
        local deps = liveDependencies()
        if deps then
            self.dependencies = deps
        end
        return self.dependencies
    end

    function self.isAvailable(): boolean
        return getDeps() ~= nil
    end

    function self.get(name: string): boolean?
        local deps = getDeps()
        if not deps or not deps.state then
            return nil
        end
        local ok, value = pcall(deps.state.GetSetting, deps.state, name)
        if ok and type(value) == "boolean" then
            return value
        end
        return nil
    end

    function self.set(name: string, value: boolean): boolean
        if type(name) ~= "string" or type(value) ~= "boolean" then
            return false
        end
        local deps = getDeps()
        if not deps or not deps.codec or not deps.client then
            return false
        end
        local okEncode, mutation = pcall(deps.codec.EncodeScalarMutation, name, value, nil)
        if not okEncode or not mutation then
            return false
        end
        local remote = deps.client[config.remoteNames.changeSetting]
        if not remote or type(remote.Fire) ~= "function" then
            return false
        end
        local okFire = pcall(remote.Fire, mutation)
        if okFire and deps.state then
            if type(deps.state.UpdateSetting) == "function" then
                pcall(deps.state.UpdateSetting, deps.state, name, value)
            elseif type(deps.state.SetSessionOverride) == "function" then
                pcall(deps.state.SetSessionOverride, deps.state, name, value)
            end
        end
        self.lastKnownValues[name] = value
        for _, observer in self.observers do
            pcall(observer, name, value)
        end
        return okFire
    end

    function self.sync()
        local deps = getDeps()
        if not deps or not deps.state then
            return
        end
        for _, name in { "AutoReplay", "AutoNext", "AutoSkipWaves", "AutoSkipStart" } do
            local val = self.get(name)
            if val ~= nil and self.lastKnownValues[name] ~= val then
                self.lastKnownValues[name] = val
                for _, observer in self.observers do
                    pcall(observer, name, val)
                end
            end
        end
    end

    local storage: FileStorage.Storage? = nil
    local httpService: any = nil

    local function saveSettings()
        if not storage or not httpService then
            return
        end
        local ok, body = pcall(httpService.JSONEncode, httpService, {
            schemaVersion = SCHEMA_VERSION,
            autoBackToLobby = self.autoBackToLobby == true,
        })
        if ok and type(body) == "string" then
            pcall(storage.write, body)
        end
    end

    -- Loads the saved Auto Back to Lobby value once; the Game page is built before start() runs.
    local loadedSaved = false
    local function loadSaved()
        if loadedSaved then
            return
        end
        loadedSaved = true
        local env: any = getfenv()
        pcall(function()
            storage = FileStorage.new(env, SETTINGS_STORAGE_KEY)
            httpService = env.game and env.game:GetService("HttpService")
            if storage and httpService then
                local body = storage.read()
                if body then
                    local ok, data = pcall(httpService.JSONDecode, httpService, body)
                    if ok and type(data) == "table" and data.schemaVersion == SCHEMA_VERSION then
                        if type(data.autoBackToLobby) == "boolean" then
                            self.autoBackToLobby = data.autoBackToLobby
                        end
                    end
                end
            end
        end)
    end

    function self.getAutoBackToLobby(): boolean
        loadSaved()
        return self.autoBackToLobby == true
    end

    function self.setAutoBackToLobby(val: boolean)
        loadSaved()
        self.autoBackToLobby = val == true
        saveSettings()
    end

    function self.observe(callback: (name: string, value: boolean) -> ()): (() -> ())?
        if type(callback) ~= "function" then
            return nil
        end
        table.insert(self.observers, callback)
        return function()
            local index = table.find(self.observers, callback)
            if index then
                table.remove(self.observers, index)
            end
        end
    end

    function self.start(context: any)
        self.context = context
        self.teleportCancelled = false
        local env: any = getfenv()
        loadSaved()
        local deps = getDeps()
        if
            deps
            and deps.state
            and deps.state.OnSettingUpdate
            and type(deps.state.OnSettingUpdate.Connect) == "function"
        then
            local ok, conn = pcall(
                deps.state.OnSettingUpdate.Connect,
                deps.state.OnSettingUpdate,
                function(name: any, val: any)
                    if type(name) == "string" and type(val) == "boolean" then
                        self.lastKnownValues[name] = val
                        for _, observer in self.observers do
                            pcall(observer, name, val)
                        end
                    end
                end
            )
            if ok then
                self.stateConnection = conn
            end
        end
        self.sync()
        local taskApi = env.task
        if
            type(taskApi) == "table"
            and type(taskApi.spawn) == "function"
            and type(taskApi.wait) == "function"
        then
            (taskApi.spawn :: any)(function()
                while self.context == context and context.alive do
                    self.sync()
                    local waitFn: any = taskApi.wait
                    waitFn(1.0)
                end
            end)
        end
        local gameObject = env.game
        local replicated = gameObject and gameObject:GetService("ReplicatedStorage")
        local function canNativeProceed(localPlayer: any): boolean
            local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
            local endScreen = playerGui and playerGui:FindFirstChild("EndScreen")
            local buttons: any = endScreen
                and endScreen:FindFirstChild("Holder")
                and endScreen.Holder:FindFirstChild("Buttons")
            if not buttons then
                local autoReplay = self.get("AutoReplay") == true
                local autoNext = self.get("AutoNext") == true
                return autoReplay or autoNext
            end

            local autoNext = self.get("AutoNext") == true
            local autoReplay = self.get("AutoReplay") == true

            local nextFrame: any = buttons:FindFirstChild("Next")
            local nextPossible = autoNext and nextFrame ~= nil and nextFrame.Visible == true

            local retryFrame: any = buttons:FindFirstChild("Retry")
            local retryPossible = false
            if autoReplay and retryFrame and retryFrame.Visible == true then
                local retryLabel: any = retryFrame:FindFirstChild("Label")
                    or retryFrame:FindFirstChildWhichIsA("TextLabel")
                local retryText = retryLabel and retryLabel.Text or ""
                local zeroAttempts = string.find(retryText, "%(0/") ~= nil
                retryPossible = not zeroAttempts
            end

            return nextPossible or retryPossible
        end

        local gameHandlerMod = resolve(replicated, config.instancePaths.gameHandler)
        if gameHandlerMod then
            local okGh, gh = pcall(require, gameHandlerMod)
            if okGh and gh and gh.MatchEnded and type(gh.MatchEnded.Connect) == "function" then
                self.matchEndConnection = (gh.MatchEnded.Connect :: any)(gh.MatchEnded, function()
                    -- An Odyssey: Adventure run is owned by the Adventure features, never sent back from here.
                    if self.autoBackToLobby and not AdventureDetect.isAdventureMatch(gh.GameData) then
                        local taskApi = env.task
                        local function doTeleport(held: number?)
                            if self.teleportCancelled or not self.context or not self.context.alive then
                                return
                            end
                            -- Let a pending webhook message finish before the teleport can cut it off.
                            local gate: any = self.returnGate
                            local waited: number = held or 0
                            if
                                type(gate) == "function"
                                and waited < config.thresholds.returnGateMaxSeconds
                                and type(taskApi) == "table"
                                and type(taskApi.delay) == "function"
                            then
                                local okGate, busy = pcall(gate)
                                if okGate and busy == true then
                                    (taskApi.delay :: any)(0.5, function()
                                        doTeleport(waited + 0.5)
                                    end)
                                    return
                                end
                            end
                            local lr = resolve(replicated, config.instancePaths.lobbyReturnClient)
                            if lr then
                                local mod = (require :: any)(lr)
                                local remote = mod and mod[config.remoteNames.requestTeleportToLobby]
                                if remote and type(remote.Fire) == "function" then
                                    pcall(remote.Fire)
                                end
                            end
                        end

                        local function checkAndTeleport()
                            if self.teleportCancelled or not self.context or not self.context.alive then
                                return
                            end
                            local players = gameObject:GetService("Players")
                            local localPlayer = players and players.LocalPlayer
                            if not canNativeProceed(localPlayer) then
                                doTeleport()
                            end
                        end

                        if type(taskApi) == "table" and type(taskApi.delay) == "function" then
                            local delayTask: any = taskApi.delay
                            delayTask(2.5, checkAndTeleport)
                            delayTask(7.0, checkAndTeleport)
                        else
                            checkAndTeleport()
                        end
                    end
                end)
            end
        end
    end

    --- Registers a function that returns true while another feature still needs this match (the webhook sending).
    function self.setReturnGate(gate: () -> boolean)
        self.returnGate = gate
    end

    function self.stop()
        self.teleportCancelled = true
        if self.matchEndConnection then
            pcall(function()
                if type(self.matchEndConnection) == "function" then
                    (self.matchEndConnection :: any)()
                else
                    self.matchEndConnection:Disconnect()
                end
            end)
            self.matchEndConnection = nil
        end
        if self.stateConnection then
            pcall(function()
                if type(self.stateConnection) == "function" then
                    (self.stateConnection :: any)()
                else
                    self.stateConnection:Disconnect()
                end
            end)
            self.stateConnection = nil
        end
        if self.clientConnection then
            pcall(function()
                if type(self.clientConnection) == "function" then
                    (self.clientConnection :: any)()
                else
                    self.clientConnection:Disconnect()
                end
            end)
            self.clientConnection = nil
        end
        table.clear(self.observers)
        self.context = nil
    end

    return self
end

return Adapter
