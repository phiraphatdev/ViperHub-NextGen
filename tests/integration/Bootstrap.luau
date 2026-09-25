--!strict
-- Purpose: test bundled startup through isolated fake runtime; Input: bundle text; Output: assertions; Dependencies: none.
return function(source: string)
    local passed = 0
    local function environment(placeId: number, gameId: number?): any
        local notifications: { string } = {}
        local env: any = setmetatable(
            { shared = {}, task = {}, Enum = { KeyCode = { RightShift = "RightShift" } } },
            { __index = getfenv() }
        )
        env.game = {
            PlaceId = placeId,
            GameId = gameId,
            GetService = function(_self: any, service: string): any
                if service == "StarterGui" then
                    return {
                        SetCore = function(_s: any, _name: string, data: any)
                            table.insert(notifications, data.Text)
                        end,
                    }
                end
                return {
                    JSONEncode = function()
                        return "{}"
                    end,
                    JSONDecode = function()
                        return {}
                    end,
                }
            end,
        }
        env.notifications = notifications
        env.loadstring = function(text: string): any
            local chunk = assert(loadstring(text))
            setfenv(chunk, env)
            return chunk
        end
        return env
    end
    local function run(env: any): any
        return env.loadstring(source)()
    end
    local env = environment(42)
    local unsupported = run(env)
    assert(unsupported.context.state == "unsupported" and not unsupported.context.alive)
    assert(#env.notifications == 1)
    passed += 1
    env = environment(42)
    local attempts = 0
    env.task = {
        spawn = function(callback: () -> ())
            callback()
        end,
        wait = function() end,
    }
    local firstService = env.game.GetService
    env.game.GetService = function(self: any, service: string): any
        if service == "StarterGui" then
            return {
                SetCore = function(_self: any, _name: string, data: any)
                    attempts += 1
                    if attempts == 1 then
                        error("not registered yet")
                    end
                    table.insert(env.notifications, data.Text)
                end,
            }
        end
        return firstService(self, service)
    end
    local retried = run(env)
    assert(retried.context.state == "unsupported" and attempts == 2 and #env.notifications == 1)
    passed += 1
    env = environment(16146832113)
    env.VIPER_REPOSITORY = "invalid repository"
    local missing = run(env)
    assert(missing.context.state == "failed")
    assert(missing.diagnostics()[1] == "REPOSITORY_UNCONFIGURED")
    passed += 1
    env = environment(16146832113)
    env.VIPER_REPOSITORY = "invalid repository"
    env.isfile = function()
        return true
    end
    env.readfile = function()
        return "saved-config"
    end
    env.isfolder = function()
        return true
    end
    env.makefolder = function() end
    env.writefile = function() end
    local serviceForMuted = env.game.GetService
    env.game.GetService = function(self: any, name: string): any
        if name == "HttpService" then
            return {
                JSONDecode = function()
                    return { schemaVersion = 1, notifications = false }
                end,
                JSONEncode = function()
                    return "{}"
                end,
            }
        end
        return serviceForMuted(self, name)
    end
    local mutedEarlyFailure = run(env)
    assert(mutedEarlyFailure.context.state == "failed" and #env.notifications == 1)
    passed += 1
    local uiSource = [=[
        local tab={ Paragraph=function(_,value) if value.Title=="Status codes" then shared.diagnosticText=value.Desc end return {SetDesc=function(_,text)shared.diagnosticText=text end}end, Toggle=function()end, Slider=function()end, Dropdown=function()end, Keybind=function()end, Button=function()end }
        local window={Tab=function()return tab end,SelectTab=function()end,SetToggleKey=function()end,OnDestroy=function()end,SetUIScale=function()end}
        return {CreateWindow=function()return window end,Notify=function()end,Creator={DisconnectAll=function()shared.disconnected=(shared.disconnected or 0)+1 end},ScreenGui={Destroy=function()shared.destroyed=(shared.destroyed or 0)+1 end}}
    ]=]
    local gameSource =
        [=[return {metadata={id="AnimeVanguards",name="Anime Vanguards",version="0.2.2",lastUpdated="2026-09-24"},start=function(context)context.log("PLACEHOLDER_STARTED") shared.started=(shared.started or 0)+1 end,stop=function()shared.stopped=(shared.stopped or 0)+1 end}]=]
    env = environment(16146832113)
    env.VIPER_DEV_ARTIFACTS =
        { manifest = { mode = "development" }, ui = uiSource, AnimeVanguards = gameSource }
    local first = run(env)
    assert(first.context.state == "ready" and first.context.alive)
    assert(env.shared.started == 1)
    assert(env.shared.diagnosticText:find("PLACEHOLDER_STARTED", 1, true) ~= nil)
    assert(env.shared.diagnosticText:find("FOUNDATION_READY", 1, true) ~= nil)
    local second = run(env)
    assert(not first.context.alive and second.context.alive)
    assert(env.shared.destroyed == 1 and env.shared.disconnected == 1)
    second.destroy()
    second.destroy()
    assert(env.shared.destroyed == 2 and env.shared.stopped == 2)
    passed += 1
    env = environment(999, 5578556129)
    env.VIPER_DEV_ARTIFACTS =
        { manifest = { mode = "development" }, ui = uiSource, AnimeVanguards = gameSource }
    local vanguardMatch = run(env)
    assert(vanguardMatch.context.state == "ready" and vanguardMatch.context.gameId == "AnimeVanguards")
    vanguardMatch.destroy()
    passed += 1
    env = environment(999, 7613921865)
    env.VIPER_DEV_ARTIFACTS = {
        manifest = { mode = "development" },
        ui = uiSource,
        AnimeExpeditions = gameSource:gsub("AnimeVanguards", "AnimeExpeditions"),
    }
    local expeditionMatch = run(env)
    assert(expeditionMatch.context.state == "ready" and expeditionMatch.context.gameId == "AnimeExpeditions")
    expeditionMatch.destroy()
    passed += 1
    env = environment(16146832113)
    env.Enum.KeyCode.F4 = "F4"
    local deferred: { () -> () } = {}
    env.task.defer = function(callback: () -> ())
        table.insert(deferred, callback)
    end
    local pickerUI = uiSource
        :gsub(
            "Keybind=function%(%)end",
            [=[Keybind=function()
        local label={GetPropertyChangedSignal=function()return {Connect=function(_, callback)shared.pickerChanged=callback return {Disconnect=function()shared.pickerDisconnected=true end}end}end}
        local control={Value="RightShift",UIElements={Keybind={Frame={Frame={TextLabel=label}}}}}
        control.Set=function(_, value)control.Value=value end
        shared.pickerControl=control
        return control
    end]=]
        )
        :gsub("SetToggleKey=function%(%)end", "SetToggleKey=function(_,key)shared.activeKey=key end")
    env.VIPER_DEV_ARTIFACTS =
        { manifest = { mode = "development" }, ui = pickerUI, AnimeVanguards = gameSource }
    local pickerSession = run(env)
    assert(pickerSession.context.state == "ready" and env.shared.activeKey == "RightShift")
    env.shared.pickerChanged() -- WindUI signals before Value is updated.
    env.shared.pickerControl.Value = "F4"
    for _, callback in deferred do
        callback()
    end
    assert(env.shared.activeKey == "F4" and pickerSession.config.get().toggleKey == "F4")
    pickerSession.destroy()
    assert(env.shared.pickerDisconnected == true)
    passed += 1
    env = environment(16146832113)
    env.VIPER_DEV_ARTIFACTS =
        { manifest = { mode = "development" }, ui = uiSource, AnimeVanguards = "return {}" }
    local malformed = run(env)
    assert(malformed.context.state == "failed" and not malformed.context.alive)
    assert(env.shared.destroyed == 1)
    passed += 1
    env = environment(16146832113)
    env.VIPER_DEV_ARTIFACTS = {
        manifest = { mode = "development" },
        ui = "return {}",
        AnimeVanguards = gameSource,
    }
    local contractFailure = run(env)
    assert(contractFailure.context.state == "failed")
    assert(
        table.concat(contractFailure.diagnostics(), ","):find("UI_CONTRACT", 1, true) ~= nil,
        table.concat(contractFailure.diagnostics(), ",")
    )
    assert(table.concat(contractFailure.diagnostics(), ","):find("STARTUP_FAILED", 1, true) ~= nil)
    passed += 1
    env = environment(16146832113)
    env.VIPER_DEV_ARTIFACTS = {
        manifest = { mode = "development" },
        ui = uiSource,
        AnimeVanguards = gameSource:gsub(
            "start=function%(context%)",
            "start=function(context) error('SECRET_PAYLOAD') "
        ),
    }
    local privateError = run(env)
    assert(privateError.context.state == "failed")
    assert(table.concat(privateError.diagnostics(), ","):find("SECRET_PAYLOAD", 1, true) == nil)
    passed += 1
    env = environment(16146832113)
    env.VIPER_DEV_ARTIFACTS = {
        manifest = { mode = "development" },
        ui = uiSource,
        AnimeVanguards = gameSource:gsub(
            "start=function%(context%)",
            "start=function(context) error('startup failed') "
        ),
    }
    env.isfile = function()
        return true
    end
    env.readfile = function()
        return "saved-config"
    end
    env.isfolder = function()
        return true
    end
    env.makefolder = function() end
    env.writefile = function() end
    local originalService = env.game.GetService
    env.game.GetService = function(self: any, name: string): any
        if name == "HttpService" then
            return {
                JSONDecode = function()
                    return { schemaVersion = 1, notifications = false }
                end,
                JSONEncode = function()
                    return "{}"
                end,
            }
        end
        return originalService(self, name)
    end
    local mutedFailure = run(env)
    assert(mutedFailure.context.state == "failed")
    assert(#env.notifications == 1, "Critical startup failure must remain visible")
    passed += 1
    env = environment(16146832113)
    local failingCleanupUI = uiSource:gsub(
        "DisconnectAll=function%(%)shared.disconnected=%(shared.disconnected or 0%)+1 end",
        'DisconnectAll=function() error("cleanup failure") end'
    )
    env.VIPER_DEV_ARTIFACTS =
        { manifest = { mode = "development" }, ui = failingCleanupUI, AnimeVanguards = gameSource }
    local cleanupFailure = run(env)
    assert(cleanupFailure.context.state == "ready")
    cleanupFailure.destroy()
    assert(env.shared.destroyed == 1, "Failed upstream cleanup must not skip GUI destruction")
    passed += 1

    env = environment(84515722934860)
    env.VIPER_DEV_ARTIFACTS = {
        manifest = { mode = "development" },
        ui = uiSource,
        AnimeExpeditions = gameSource:gsub("AnimeVanguards", "AnimeExpeditions"),
    }
    local expeditions = run(env)
    assert(expeditions.context.state == "ready" and expeditions.context.gameId == "AnimeExpeditions")
    expeditions.destroy()
    passed += 1

    local revision = string.rep("b", 40)
    local function production(
        status: string,
        brokenJson: boolean,
        mutable: boolean?,
        placeId: number?,
        gameId: number?
    ): any
        local runtime = environment(placeId or 16146832113, gameId)
        runtime.VIPER_REPOSITORY = "owner/repo"
        runtime.crypt = {
            hash = function(_body: string, algorithm: string): string
                assert(algorithm == "sha256")
                return string.rep("a", 64)
            end,
        }
        runtime.task = {
            spawn = function(fn: () -> ())
                fn()
            end,
            wait = function() end,
        }
        local artifacts: any = {}
        local texts: { [string]: string } =
            { ui = uiSource, loader = "unused", AnimeVanguards = gameSource, AnimeExpeditions = "unused" }
        for id, text in texts do
            artifacts[id] = { path = "dist/" .. id .. ".lua", bytes = #text, sha256 = string.rep("a", 64) }
        end
        local manifest: any = {
            schemaVersion = 1,
            mode = "release",
            repository = "owner/repo",
            sourceCommit = string.rep("a", 40),
            artifactRevision = if mutable then nil else revision,
            version = "0.2.2",
            loaderVersion = "0.2.2",
            minLoaderVersion = "0.2.2",
            artifacts = artifacts,
            games = {
                AnimeVanguards = {
                    version = "0.2.2",
                    lastUpdated = "2026-09-24",
                    name = "Anime Vanguards",
                    placeIds = { 16146832113 },
                    gameIds = { 5578556129 },
                },
                AnimeExpeditions = {
                    version = "0.2.2",
                    lastUpdated = "2026-09-24",
                    name = "Anime Expeditions",
                    placeIds = { 84515722934860 },
                    gameIds = { 7613921865 },
                },
            },
        }
        if mutable then
            manifest.sourceCommit = nil
            manifest.artifacts.AnimeExpeditions = nil
            manifest.games.AnimeExpeditions = nil
        end
        runtime.manifest = manifest
        local getService = runtime.game.GetService
        runtime.game.GetService = function(self: any, name: string): any
            if name ~= "HttpService" then
                return getService(self, name)
            end
            return {
                JSONEncode = function()
                    return "{}"
                end,
                JSONDecode = function(_self: any, text: string): any
                    if brokenJson then
                        error("malformed JSON")
                    end
                    if text == "manifest" then
                        return manifest
                    end
                    return { schemaVersion = 1, games = { AnimeVanguards = { state = status } } }
                end,
            }
        end
        runtime.downloads = {}
        runtime.request = function(options: any): any
            local url: string = options.Url
            table.insert(runtime.downloads, url)
            if url:find("/main/manifest.json", 1, true) then
                return { StatusCode = 200, Body = "manifest" }
            end
            if url:find("/main/status.json", 1, true) then
                return { StatusCode = 200, Body = "status" }
            end
            local prefix = if mutable then "/main/dist/" else "/" .. revision .. "/dist/"
            assert(url:find(prefix, 1, true), "Code must use selected artifact revision or main")
            return { StatusCode = 200, Body = if url:find("/ui.lua", 1, true) then uiSource else gameSource }
        end
        return runtime
    end
    env = production("ready", false)
    local released = run(env)
    assert(
        released.context.state == "ready" and #env.downloads == 4,
        table.concat(released.diagnostics(), ",") .. "; " .. table.concat(env.notifications, ",")
    )
    released.destroy()
    passed += 1
    env = production("ready", false)
    env.crypt.hash = function()
        return string.rep("b", 64)
    end
    local badHash = run(env)
    assert(badHash.context.state == "failed" and #env.downloads == 3)
    assert(table.concat(badHash.diagnostics(), ","):find("ARTIFACT_HASH_MISMATCH", 1, true) ~= nil)
    passed += 1
    env = production("ready", false)
    env.crypt = nil
    local noHash = run(env)
    assert(noHash.context.state == "failed" and #env.downloads == 3)
    assert(table.concat(noHash.diagnostics(), ","):find("HASH_UNAVAILABLE", 1, true) ~= nil)
    passed += 1
    env = production("ready", false)
    env.manifest.artifacts.AnimeVanguards.bytes += 1
    local badSize = run(env)
    assert(badSize.context.state == "failed" and #env.downloads == 3)
    assert(table.concat(badSize.diagnostics(), ","):find("ARTIFACT_SIZE_MISMATCH", 1, true) ~= nil)
    passed += 1
    env = production("ready", false, false, 999, 5578556129)
    local publishedMatch = run(env)
    assert(publishedMatch.context.state == "ready" and #env.downloads == 4)
    publishedMatch.destroy()
    passed += 1
    env = production("ready", false, false, 999, 5578556129)
    env.manifest.games.AnimeVanguards.gameIds = nil
    local staleRegistry = run(env)
    assert(staleRegistry.context.state == "failed" and #env.downloads == 1)
    passed += 1
    env = production("ready", false)
    env.manifest.games.AnimeVanguards.placeIds = { 99 }
    local placeMismatch = run(env)
    assert(placeMismatch.context.state == "failed" and #env.downloads == 1)
    assert(table.concat(placeMismatch.diagnostics(), ","):find("REGISTRY_MISMATCH", 1, true) ~= nil)
    passed += 1
    env = production("ready", false, true)
    local mutableRelease = run(env)
    assert(mutableRelease.context.state == "ready" and #env.downloads == 4)
    assert(env.downloads[3]:find("/main/dist/", 1, true) ~= nil)
    mutableRelease.destroy()
    passed += 1
    env = production("ready", false)
    env.manifest.mode = "development"
    local unpublished = run(env)
    assert(unpublished.context.state == "failed" and #env.downloads == 1)
    assert(unpublished.diagnostics()[#unpublished.diagnostics()] == "MANIFEST_INVALID")
    passed += 1
    env = production("ready", false)
    env.http_request = env.request
    env.request = "not callable"
    local fallbackRequest = run(env)
    assert(fallbackRequest.context.state == "ready" and #env.downloads == 4)
    fallbackRequest.destroy()
    passed += 1
    env = production("ready", false)
    env.http_request = env.request
    env.request = function()
        error("broken primary")
    end
    local failedPrimary = run(env)
    assert(failedPrimary.context.state == "ready" and #env.downloads == 4)
    failedPrimary.destroy()
    passed += 1
    env = production("maintenance", false)
    local maintenance = run(env)
    assert(maintenance.context.state == "failed" and #env.downloads == 2)
    assert(env.shared.started == nil)
    passed += 1
    env = production("ready", true)
    local badJson = run(env)
    assert(badJson.context.state == "failed" and #env.downloads == 1)
    assert(env.shared.started == nil)
    passed += 1
    print(string.format("PASS: %d bundled bootstrap scenarios (mock runtime, not Roblox)", passed))
end
