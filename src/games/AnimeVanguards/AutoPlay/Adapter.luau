--!strict
--[[
Purpose: Interface with in-game native Auto Play controls and match-start signals
Input: ReplicatedStorage and StarterPlayer modules
Output: Query and trigger native Auto Play, vote start, stage presets and observe state changes
Dependencies: Config; Rules
]]

local config = require("../Config")
local Rules = require("./Rules")
local Adapter = {}

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

local function optionalRequire(module: any): any
    if not module then
        return nil
    end
    local ok, result = pcall(function()
        return (require :: any)(module)
    end)
    return if ok then result else nil
end

local function liveDependencies(): any?
    local env: any = getfenv()
    local gameObject = env.game
    if not gameObject then
        return nil
    end
    local replicated = gameObject:GetService("ReplicatedStorage")
    local starter = gameObject:GetService("StarterPlayer")
    local autoPlayClientMod = resolve(replicated, config.instancePaths.autoPlayClient)
    local autoPlayHandlerMod = resolve(starter, config.instancePaths.autoPlayHandler)
    local gameHandlerMod = resolve(replicated, config.instancePaths.gameHandler)
    local wavesClientMod = resolve(replicated, config.instancePaths.wavesClient)
    local blocklistMod = resolve(replicated, config.instancePaths.autoPlayModeBlocklist)
    local stagesDataMod = resolve(replicated, config.instancePaths.stagesData)

    if not autoPlayClientMod or not autoPlayHandlerMod or not gameHandlerMod then
        return nil
    end

    local ok, result = pcall(function()
        return {
            autoPlayClient = (require :: any)(autoPlayClientMod),
            autoPlayHandler = (require :: any)(autoPlayHandlerMod),
            gameHandler = (require :: any)(gameHandlerMod),
            wavesClient = if wavesClientMod then (require :: any)(wavesClientMod) else nil,
            blocklist = optionalRequire(blocklistMod),
            stagesData = optionalRequire(stagesDataMod),
        }
    end)
    return if ok then result else nil
end

--- Creates an adapter for native Auto Play; injected dependencies support isolated tests.
function Adapter.new(injectedDeps: any?): any
    local self: any = {
        dependencies = injectedDeps,
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

    function self.isAutoPlaying(): boolean?
        local deps = getDeps()
        if not deps or not deps.autoPlayHandler or type(deps.autoPlayHandler.IsAutoPlaying) ~= "function" then
            return nil
        end
        local ok, val = pcall(deps.autoPlayHandler.IsAutoPlaying)
        return if ok and type(val) == "boolean" then val else nil
    end

    function self.toggle(): boolean
        local deps = getDeps()
        if not deps or not deps.autoPlayClient then
            return false
        end
        local remote = deps.autoPlayClient[config.remoteNames.toggleAutoPlay]
        if not remote or type(remote.Fire) ~= "function" then
            return false
        end
        local ok = pcall(remote.Fire)
        return ok
    end

    function self.isMatchStarted(): boolean?
        local deps = getDeps()
        if not deps or not deps.gameHandler or deps.gameHandler.IsGameLoaded ~= true then
            return nil
        end
        if type(deps.gameHandler.IsMatchStarted) ~= "boolean" then
            return nil
        end
        return deps.gameHandler.IsMatchStarted
    end

    function self.hasStartPrompt(): boolean
        local deps = getDeps()
        if not deps or not deps.gameHandler or deps.gameHandler.IsGameLoaded ~= true then
            return false
        end
        local env: any = getfenv()
        local gameObject = env.game
        if not gameObject then
            return false
        end
        local ok, visible = pcall(function()
            local player = gameObject:GetService("Players").LocalPlayer
            local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
            local prompt = playerGui and playerGui:FindFirstChild("SkipWave")
            local holder = prompt and prompt:FindFirstChild("Holder")
            local description = holder and holder:FindFirstChild("Description")
            local yes = holder and holder:FindFirstChild("Yes")
            return holder ~= nil
                and holder.Visible == true
                and yes ~= nil
                and description ~= nil
                and type(description.Text) == "string"
                and string.find(string.lower(description.Text), "vote start", 1, true) ~= nil
        end)
        return ok and visible == true
    end

    function self.castStartVote(): boolean
        local deps = getDeps()
        if not deps or not deps.wavesClient then
            return false
        end
        local remote = deps.wavesClient[config.remoteNames.castWaveSkipVote]
        if not remote or type(remote.Fire) ~= "function" then
            return false
        end
        local ok = pcall(remote.Fire)
        return ok
    end

    local presets: Rules.Presets? = nil
    local presetListeners: { (Rules.Presets) -> () } = {}
    local presetUnsubscribe: any = nil
    local presetAlive = false

    --- Asks the game to resend its Auto Play data (read-only); presets arrive through the update event.
    function self.requestPresets(): boolean
        local deps = getDeps()
        local client = deps and deps.autoPlayClient
        local remote = client and client[config.remoteNames.requestAutoPlayData]
        if not remote or type(remote.Fire) ~= "function" then
            return false
        end
        return (pcall(remote.Fire))
    end

    --- Subscribes once to the game's preset updates and requests the current list; true while tracking.
    function self.trackPresets(): boolean
        if presetAlive then
            return true
        end
        local deps = getDeps()
        local client = deps and deps.autoPlayClient
        local event = client and client[config.remoteNames.autoPlayPresetsUpdated]
        if not event or type(event.On) ~= "function" then
            return false
        end
        local ok, unsubscribe = pcall(event.On, function(payload: any)
            if not presetAlive then
                return
            end
            local snapshot = Rules.readPresets(payload)
            if not snapshot then
                return
            end
            presets = snapshot
            for _, listener in presetListeners do
                pcall(listener, snapshot)
            end
        end)
        if not ok then
            return false
        end
        presetUnsubscribe = unsubscribe
        presetAlive = true
        self.requestPresets()
        return true
    end

    --- Stops preset tracking and forgets the cached list and listeners.
    function self.untrackPresets()
        presetAlive = false
        presets = nil
        table.clear(presetListeners)
        if type(presetUnsubscribe) == "function" then
            pcall(presetUnsubscribe)
        end
        presetUnsubscribe = nil
    end

    --- Returns the latest presets snapshot (active id, ordered ids, names), or nil until the game reports it.
    function self.getPresets(): Rules.Presets?
        return presets
    end

    --- Registers a callback for preset snapshots; returns a function that removes it.
    function self.onPresetsUpdated(callback: (Rules.Presets) -> ()): () -> ()
        table.insert(presetListeners, callback)
        return function()
            local index = table.find(presetListeners, callback)
            if index then
                table.remove(presetListeners, index)
            end
        end
    end

    --- Asks the game to make a saved preset active; success is confirmed only by a later snapshot.
    function self.switchPreset(id: string): boolean
        if type(id) ~= "string" or id == "" then
            return false
        end
        local deps = getDeps()
        local client = deps and deps.autoPlayClient
        local remote = client and client[config.remoteNames.switchAutoPlayPreset]
        if not remote or type(remote.Fire) ~= "function" then
            return false
        end
        return (pcall(remote.Fire, { PresetId = id }))
    end

    --- Reads the current mode (StageType) and Stage from the game; nil until game data is loaded.
    function self.getGameData(): { mode: string, stage: string }?
        local deps = getDeps()
        local handler = deps and deps.gameHandler
        if not handler or handler.IsGameLoaded ~= true or type(handler.GetGameData) ~= "function" then
            return nil
        end
        local ok, data = pcall(handler.GetGameData, handler)
        if
            not ok
            or type(data) ~= "table"
            or type(data.StageType) ~= "string"
            or type(data.Stage) ~= "string"
        then
            return nil
        end
        return { mode = data.StageType, stage = data.Stage }
    end

    --- Lists modes Auto Play supports (some stage is not blocklisted) from StagesData; Story first, nil if unavailable.
    function self.getModes(): { string }?
        local deps = getDeps()
        local data = deps and deps.stagesData
        if
            not data
            or type(data.GetAllStageTypeNames) ~= "function"
            or type(data.GetAllStageNameAndIndex) ~= "function"
        then
            return nil
        end
        local okTypes, typeNames = pcall(data.GetAllStageTypeNames)
        if not okTypes or type(typeNames) ~= "table" then
            return nil
        end
        local blocklist = deps.blocklist
        local modes: { string } = {}
        local seen: { [string]: boolean } = {}
        for _, mode in typeNames do
            if type(mode) == "string" and not seen[mode] and not (config :: any).hiddenModes[mode] then
                seen[mode] = true
                local okStages, stageMap = pcall(data.GetAllStageNameAndIndex, mode)
                local supported = false
                if okStages and type(stageMap) == "table" then
                    for _, stageId in stageMap do
                        local blocked = false
                        if
                            type(stageId) == "string"
                            and blocklist
                            and type(blocklist.IsBlocked) == "function"
                        then
                            local okBlock, result =
                                pcall(blocklist.IsBlocked, { StageType = mode, Stage = stageId })
                            blocked = not okBlock or result == true
                        end
                        if type(stageId) == "string" and not blocked then
                            supported = true
                            break
                        end
                    end
                end
                if supported then
                    table.insert(modes, mode)
                end
            end
        end
        for _, extra in (config :: any).extraModes do
            local blocked = false
            if blocklist and type(blocklist.IsBlocked) == "function" then
                local okBlock, result = pcall(blocklist.IsBlocked, { StageType = extra, Stage = extra })
                blocked = not okBlock or result == true
            end
            if not seen[extra] and not blocked and not (config :: any).hiddenModes[extra] then
                seen[extra] = true
                table.insert(modes, extra)
            end
        end
        table.sort(modes, function(a: string, b: string)
            if a == "Story" or b == "Story" then
                return a == "Story" and b ~= "Story"
            end
            return a < b
        end)
        return modes
    end

    function self.observe(kind: string, callback: (any) -> ()): (() -> ())?
        local deps = getDeps()
        if not deps or type(callback) ~= "function" then
            return nil
        end
        if kind == "autoPlayToggled" and deps.autoPlayHandler and deps.autoPlayHandler.AutoPlayToggled then
            local ev = deps.autoPlayHandler.AutoPlayToggled
            if type(ev.Connect) == "function" then
                local conn = ev:Connect(callback)
                return function()
                    pcall(function()
                        conn:Disconnect()
                    end)
                end
            end
        elseif kind == "matchStarted" and deps.gameHandler and deps.gameHandler.MatchStarted then
            local sig = deps.gameHandler.MatchStarted
            if type(sig.Connect) == "function" then
                local conn = sig:Connect(callback)
                return function()
                    pcall(function()
                        conn:Disconnect()
                    end)
                end
            end
        elseif kind == "matchRestarted" and deps.gameHandler and deps.gameHandler.MatchRestarted then
            local sig = deps.gameHandler.MatchRestarted
            if type(sig.Connect) == "function" then
                local conn = sig:Connect(callback)
                return function()
                    pcall(function()
                        conn:Disconnect()
                    end)
                end
            end
        end
        return nil
    end

    return self
end

return Adapter
