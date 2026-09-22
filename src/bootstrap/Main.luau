--!strict
--[[
Purpose: Coordinate detection, trusted release loading, config and UI
Input: Roblox runtime environment; optional local test artifacts
Output: Session in shared.ViperHubNextGen
Dependencies: core; games; network; platform; config; ui
]]

local Detector = require("../games/Detector")
local Context = require("../core/Context")
local Diagnostics = require("../core/Diagnostics")
local Capabilities = require("../platform/Capabilities")
local FileStorage = require("../platform/FileStorage")
local ConfigStore = require("../config/ConfigStore")
local HttpClient = require("../network/HttpClient")
local ManifestClient = require("../network/ManifestClient")
local ModuleLoader = require("../network/ModuleLoader")
local Version = require("../utils/Version")
local App = require("../ui/App")
local UIAdapter = require("../ui/WindUIAdapter")
local LOADER_VERSION = "0.1.0"
local TIMEOUT_SECONDS = 15
local MAX_METADATA_BYTES = 65536
local MAX_MODULE_BYTES = 4000000
local ENV: { [string]: any } = getfenv()
local gameObject = ENV.game
if not gameObject then
    return { state = "unavailable", code = "ROBLOX_REQUIRED" }
end
local starterGui = gameObject:GetService("StarterGui")
local httpService = gameObject:GetService("HttpService")
local marketplaceService = gameObject:GetService("MarketplaceService")
local runtimeTask = ENV.task
local sharedState = ENV.shared
if type(sharedState) ~= "table" or type(runtimeTask) ~= "table" then
    return { state = "unavailable", code = "RUNTIME_REQUIRED" }
end
local function notify(message: string)
    pcall(function()
        starterGui:SetCore("SendNotification", { Title = "ViperHub NextGen", Text = message, Duration = 8 })
    end)
end
local old = sharedState.ViperHubNextGen
if type(old) == "table" and type(old.destroy) == "function" then
    pcall(old.destroy)
end
local buffer = Diagnostics.new(64)
local context = Context.new(buffer.push)
local session: { [string]: any } =
    { context = context, diagnostics = buffer.snapshot, destroy = context.destroy }
sharedState.ViperHubNextGen = session
local function fail(code: string, message: string)
    buffer.push(code)
    context.destroy()
    context.state = "failed"
    notify(message)
end
local metadata = Detector.detect(gameObject.PlaceId)
if not metadata then
    context.destroy()
    context.state = "unsupported"
    notify("Unsupported game (name unavailable). Place: " .. tostring(gameObject.PlaceId))
    -- A slow metadata request must not delay stopping an unsupported session.
    if type(runtimeTask.spawn) == "function" then
        local requestedAt = os.clock()
        local spawnTask: any = runtimeTask.spawn
        spawnTask(function()
            local ok, info = pcall(function()
                return marketplaceService:GetProductInfo(gameObject.PlaceId)
            end)
            if
                ok
                and type(info) == "table"
                and type(info.Name) == "string"
                and os.clock() - requestedAt < TIMEOUT_SECONDS
                and sharedState.ViperHubNextGen == session
            then
                notify("Unsupported: " .. string.sub(info.Name, 1, 100))
            end
        end)
    end
    return session
end
context.gameId = metadata.id
context.state = "loading"
local caps = Capabilities.detect(ENV)
session.capabilities = caps
local function run()
    if not caps.compile then
        fail("COMPILE_UNAVAILABLE", "This environment cannot load modules.")
        return
    end
    local localArtifacts = ENV.VIPER_DEV_ARTIFACTS
    local exports: { [string]: any } = {}
    local manifest: any
    local function decode(text: string): any
        return httpService:JSONDecode(text)
    end
    if type(localArtifacts) == "table" then
        -- Explicit local test harness only; production loader never fetches these overrides.
        manifest = localArtifacts.manifest
        if type(manifest) ~= "table" or manifest.mode ~= "development" then
            fail("DEV_MANIFEST_INVALID", "Invalid development harness.")
            return
        end
        for _, id in { metadata.id, "ui" } do
            if not context.alive then
                return
            end
            local source = localArtifacts[id]
            local value, code = ModuleLoader.load(
                ENV.loadstring,
                source,
                if type(source) == "string" then #source else 0,
                buffer.push
            )
            if not value then
                fail(code or "MODULE_FAILED", "Could not load development module.")
                return
            end
            exports[id] = value
            if id == "ui" then
                UIAdapter.own(value, context)
            end
        end
    else
        -- Deployment config is supplied by the owner after selecting the actual GitHub repository.
        local repository = ENV.VIPER_REPOSITORY or "phiraphatdev/ViperHub-NextGen"
        if type(repository) ~= "string" or not string.match(repository :: string, "^[%w_-]+/[%w_.-]+$") then
            fail(
                "REPOSITORY_UNCONFIGURED",
                "GitHub repository is not configured. Use the local smoke harness."
            )
            return
        end
        local requester = ENV.request or ENV.http_request
        local client = HttpClient.new(function(url: string): (number, unknown)
            if caps.request then
                local result = requester({ Url = url, Method = "GET" })
                if type(result) ~= "table" then
                    return 0, nil
                end
                return result.StatusCode, result.Body
            end
            return 200, gameObject:HttpGet(url)
        end, { spawn = runtimeTask.spawn, wait = runtimeTask.wait, clock = os.clock })
        local base = "https://raw.githubusercontent.com/" .. repository .. "/"
        local function json(file: string): any
            local body, code = client.get(base .. "main/" .. file, MAX_METADATA_BYTES, TIMEOUT_SECONDS)
            if not body then
                buffer.push(code or "HTTP_FAILED")
                return nil
            end
            local ok, value = pcall(decode, body)
            if not ok then
                buffer.push("JSON_INVALID")
                return nil
            end
            return value
        end
        manifest = ManifestClient.validate(json("manifest.json"), repository)
        if not context.alive then
            return
        end
        if not manifest then
            fail("MANIFEST_INVALID", "Release metadata unavailable or invalid.")
            return
        end
        if (Version.compare(LOADER_VERSION, manifest.minLoaderVersion) or -1) < 0 then
            fail("LOADER_OUTDATED", "Update the ViperHub loader.")
            return
        end
        local status = ManifestClient.status(json("status.json"), metadata.id)
        if not context.alive then
            return
        end
        if status ~= "ready" then
            fail(
                "GAME_UNAVAILABLE",
                if status == "maintenance"
                    then "เกมนี้กำลังอัปเดต กรุณารอ"
                    else "Game module unavailable; status could not be confirmed."
            )
            return
        end
        if (Version.compare(metadata.version, manifest.games[metadata.id].version) or 0) < 0 then
            notify("A newer game module is available; loading the release version.")
        end
        for _, id in { metadata.id, "ui" } do
            local artifact = manifest.artifacts[id]
            local body, code = client.get(
                base .. manifest.artifactRevision .. "/" .. artifact.path,
                MAX_MODULE_BYTES,
                TIMEOUT_SECONDS
            )
            if not context.alive then
                return
            end
            if not body then
                fail(code or "HTTP_FAILED", "Module download failed.")
                return
            end
            local value, loadCode = ModuleLoader.load(ENV.loadstring, body, artifact.bytes, buffer.push)
            if not value then
                fail(loadCode or "MODULE_FAILED", "Module could not start.")
                return
            end
            exports[id] = value
            if id == "ui" then
                UIAdapter.own(value, context)
            end
        end
    end
    if not context.alive then
        return
    end
    local gameModule = exports[metadata.id]
    local expectedVersion = if manifest.games and manifest.games[metadata.id]
        then manifest.games[metadata.id].version
        else metadata.version
    if not ModuleLoader.isGame(gameModule, metadata.id, expectedVersion) then
        fail("GAME_CONTRACT", "Game module version or interface mismatch.")
        return
    end
    local store = ConfigStore.new(FileStorage.new(ENV, metadata.id), decode, function(value: any): string
        return httpService:JSONEncode(value)
    end, buffer.push)
    session.config = store
    session.window = App.mount(exports.ui, context, gameModule.metadata, store, buffer, ENV.Enum.KeyCode)
    context.cleanup.add(gameModule.stop)
    gameModule.start(context)
    if not context.alive then
        return
    end
    context.state = "ready"
    buffer.push("FOUNDATION_READY")
end
local ok = pcall(run)
if not ok then
    fail("STARTUP_FAILED", "ViperHub startup failed. Inspect the private diagnostics buffer.")
end
return session
