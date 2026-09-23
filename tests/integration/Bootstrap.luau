--!strict
-- Purpose: test bundled startup through isolated fake runtime; Input: bundle text; Output: assertions; Dependencies: none.
return function(source: string)
    local passed = 0
    local function environment(placeId: number): any
        local notifications: { string } = {}
        local env: any = setmetatable(
            { shared = {}, task = {}, Enum = { KeyCode = { RightShift = "RightShift" } } },
            { __index = getfenv() }
        )
        env.game = {
            PlaceId = placeId,
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
    env = environment(16146832113)
    env.VIPER_REPOSITORY = "invalid repository"
    local missing = run(env)
    assert(missing.context.state == "failed")
    assert(missing.diagnostics()[1] == "REPOSITORY_UNCONFIGURED")
    passed += 1
    local uiSource = [=[
        local tab={ Paragraph=function()return {SetDesc=function()end}end, Toggle=function()end, Slider=function()end, Dropdown=function()end, Keybind=function()end, Button=function()end }
        local window={Tab=function()return tab end,SelectTab=function()end,SetToggleKey=function()end,OnDestroy=function()end,SetUIScale=function()end}
        return {CreateWindow=function()return window end,Notify=function()end,Creator={DisconnectAll=function()shared.disconnected=(shared.disconnected or 0)+1 end},ScreenGui={Destroy=function()shared.destroyed=(shared.destroyed or 0)+1 end}}
    ]=]
    local gameSource =
        [=[return {metadata={id="AnimeVanguards",name="Anime Vanguards",version="0.1.0",lastUpdated="2026-09-22"},start=function()shared.started=(shared.started or 0)+1 end,stop=function()shared.stopped=(shared.stopped or 0)+1 end}]=]
    env = environment(16146832113)
    env.VIPER_DEV_ARTIFACTS =
        { manifest = { mode = "development" }, ui = uiSource, AnimeVanguards = gameSource }
    local first = run(env)
    assert(first.context.state == "ready" and first.context.alive)
    assert(env.shared.started == 1)
    local second = run(env)
    assert(not first.context.alive and second.context.alive)
    assert(env.shared.destroyed == 1 and env.shared.disconnected == 1)
    second.destroy()
    second.destroy()
    assert(env.shared.destroyed == 2 and env.shared.stopped == 2)
    passed += 1
    env = environment(16146832113)
    env.VIPER_DEV_ARTIFACTS =
        { manifest = { mode = "development" }, ui = uiSource, AnimeVanguards = "return {}" }
    local malformed = run(env)
    assert(malformed.context.state == "failed" and not malformed.context.alive)
    assert(env.shared.destroyed == 1)
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
    local function production(status: string, brokenJson: boolean): any
        local runtime = environment(16146832113)
        runtime.VIPER_REPOSITORY = "owner/repo"
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
        local manifest = {
            schemaVersion = 1,
            mode = "release",
            repository = "owner/repo",
            sourceCommit = string.rep("a", 40),
            artifactRevision = revision,
            version = "0.1.0",
            loaderVersion = "0.1.0",
            minLoaderVersion = "0.1.0",
            artifacts = artifacts,
            games = {
                AnimeVanguards = {
                    version = "0.1.0",
                    lastUpdated = "2026-09-22",
                    name = "Anime Vanguards",
                    placeIds = { 16146832113 },
                },
                AnimeExpeditions = {
                    version = "0.1.0",
                    lastUpdated = "2026-09-22",
                    name = "Anime Expeditions",
                    placeIds = { 84515722934860 },
                },
            },
        }
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
            assert(
                url:find("/" .. revision .. "/dist/", 1, true),
                "Code must use immutable artifact revision"
            )
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
