--!strict
-- Purpose: exercise failure boundaries; Input: pure modules; Output: assertion summary; Dependencies: src.
local Validation = require("../../src/utils/Validation")
local Version = require("../../src/utils/Version")
local Detector = require("../../src/games/Detector")
local Cleanup = require("../../src/core/Cleanup")
local Context = require("../../src/core/Context")
local Diagnostics = require("../../src/core/Diagnostics")
local Lifecycle = require("../../src/core/Lifecycle")
local Schema = require("../../src/config/Schema")
local ConfigStore = require("../../src/config/ConfigStore")
local Capabilities = require("../../src/platform/Capabilities")
local FileStorage = require("../../src/platform/FileStorage")
local HttpClient = require("../../src/network/HttpClient")
local ManifestClient = require("../../src/network/ManifestClient")
local ModuleLoader = require("../../src/network/ModuleLoader")
local Settings = require("../../src/ui/pages/Settings")
local DiagnosticsPage = require("../../src/ui/pages/Diagnostics")
local VanguardsEntry = require("../../src/games/AnimeVanguards/Entry")
local ExpeditionsEntry = require("../../src/games/AnimeExpeditions/Entry")
local passed = 0
local function test(name: string, callback: () -> ())
    local ok, message = pcall(callback)
    assert(ok, name .. ": " .. tostring(message))
    passed += 1
end
test("numbers reject NaN/infinity/types and clamp", function()
    for _, value in { 0 / 0, math.huge, -math.huge, "3", false } do
        assert(not Validation.isFinite(value))
        assert(Validation.number(value, 0, 10, 5) == 5)
    end
    assert(Validation.number(nil, 0, 10, 5) == 5)
    assert(Validation.number(20, 0, 10, 5) == 10)
    assert(Validation.number(-20, 0, 10, 5) == 0)
end)
test("version compares numerically", function()
    assert(Version.compare("1.10.0", "1.9.0") == 1)
    assert(Version.compare("0.1.0", "0.1.0") == 0)
    assert(Version.compare("0.1.0", "0.2.0") == -1)
    assert(Version.compare(nil, "0.2.0") == nil)
    assert(Version.parse("v1.0.0") == nil)
end)
test("registry exact match and isolation", function()
    local a = assert(Detector.detect(16146832113))
    assert(a.id == "AnimeVanguards")
    assert(assert(Detector.detect(84515722934860)).id == "AnimeExpeditions")
    a.placeIds[1] = 42
    assert(Detector.detect(42) == nil)
    assert(Detector.detect(16146832113) ~= nil)
    assert(Detector.detect(nil) == nil and Detector.detect("16146832113") == nil)
    assert(Detector.detect(0 / 0) == nil and Detector.detect(-1) == nil and Detector.detect(1.5) == nil)
    assert(assert(Detector.detect(999, 5578556129)).id == "AnimeVanguards")
    assert(assert(Detector.detect(999, 7613921865)).id == "AnimeExpeditions")
    assert(Detector.detect(999, 999) == nil)
    assert(Detector.detect(16146832113, 7613921865) == nil)
    assert(Detector.detect(nil, "5578556129") == nil)
end)
test("cleanup reverse order, repeat and failed callback", function()
    local order: { number } = {}
    local errors = 0
    local scope = Cleanup.new(function()
        errors += 1
    end)
    scope.add(function()
        table.insert(order, 1)
    end)
    scope.add(function()
        error("intentional")
    end)
    scope.add(function()
        table.insert(order, 3)
    end)
    scope.destroy()
    scope.destroy()
    assert(order[1] == 3 and order[2] == 1 and errors == 1 and scope.count() == 0)
    scope.add(function()
        table.insert(order, 4)
    end)
    assert(order[3] == 4)
end)
test("context and state transitions", function()
    local c = Context.new(function() end)
    assert(c.transition("loading"))
    assert(c.transition("ready"))
    assert(not c.transition("unsupported"))
    c.destroy()
    c.destroy()
    assert(not c.alive and c.state == "stopped")
    assert(Lifecycle.canTransition("created", "loading"))
    assert(Lifecycle.canTransition("created", "unsupported"))
    assert(Lifecycle.canTransition("created", "failed"))
    assert(not Lifecycle.canTransition("stopped", "ready"))
    local unsupported = Context.new(function() end)
    unsupported.destroy("unsupported")
    assert(unsupported.state == "unsupported" and not unsupported.alive)
    local failed = Context.new(function() end)
    assert(failed.transition("loading"))
    failed.destroy("failed")
    assert(failed.state == "failed" and not failed.alive)
    local callback = Context.new(function() end)
    callback:destroy()
    assert(callback.state == "stopped" and not callback.alive)
    local signal = Context.new(function() end)
    signal.destroy({ unexpected = "window" })
    assert(signal.state == "stopped" and not signal.alive)
end)
test("diagnostics are bounded and copied", function()
    local d = Diagnostics.new(2)
    d.push("ONE")
    d.push("TWO")
    d.push("THREE")
    local copy = d.snapshot()
    copy[1] = "CHANGED"
    assert(d.snapshot()[1] == "TWO")
    d.push("private payload: secret")
    assert(d.snapshot()[2] == "INVALID_DIAGNOSTIC")
end)
test("config rejects future schema and sanitizes fields", function()
    local _, valid = Schema.decode({ schemaVersion = 2 })
    assert(not valid)
    local c = Schema.decode({ schemaVersion = 1, uiScale = 99, toggleKey = "../file", theme = false })
    assert(c.uiScale == 1.3 and c.toggleKey == "RightShift" and c.theme == "Dark")
    assert(Schema.decode(nil).uiScale == 1)
    for _, key in
        { "RightShift", "RightControl", "LeftControl", "Insert", "Delete", "Home", "End", "F1", "F4", "F12" }
    do
        assert(Schema.decode({ schemaVersion = 1, toggleKey = key }).toggleKey == key)
    end
    assert(Schema.decode({ schemaVersion = 1, toggleKey = "LeftAlt" }).toggleKey == "RightShift")
end)
test("filesystem capability requires the complete API set", function()
    assert(not Capabilities.detect({ writefile = function() end }).persistence)
    assert(FileStorage.new({}, "AnimeVanguards") == nil)
end)
test("filesystem writes read back and reject bad keys", function()
    local data: { [string]: string } = {}
    local env = {
        isfolder = function()
            return true
        end,
        makefolder = function() end,
        isfile = function(p: string)
            return data[p] ~= nil
        end,
        writefile = function(p: string, s: string)
            data[p] = s
        end,
        readfile = function(p: string)
            return data[p]
        end,
    }
    assert(FileStorage.new(env, "../../bad") == nil)
    local storage = assert(FileStorage.new(env, "AnimeVanguards"))
    assert(storage.read() == nil)
    assert(storage.write("hello"))
    assert(assert(FileStorage.new(env, "AnimeVanguards")).read() == "hello")
    env.writefile = function() end
    assert(not storage.write("different"))
end)
test("config malformed JSON and reopened store", function()
    local payload: any = { schemaVersion = 1, uiScale = 1.2 }
    local body = "valid"
    local storage = {
        read = function(): (string?, string?)
            return body, nil
        end,
        write = function(s: string): boolean
            body = s
            return true
        end,
    }
    local decode = function(s: string): any
        if s == "bad" then
            error("invalid json")
        end
        return payload
    end
    local encode = function(v: any): string
        payload = table.clone(v)
        return "valid"
    end
    local codes: { string } = {}
    local logger = function(s: string)
        table.insert(codes, s)
    end
    local store = ConfigStore.new(storage, decode, encode, logger)
    store.update("uiScale", 0.9)
    assert(store.save())
    assert(ConfigStore.new(storage, decode, encode, logger).get().uiScale == 0.9)
    body = "bad"
    assert(ConfigStore.new(storage, decode, encode, logger).get().uiScale == 1)
    assert(codes[#codes] == "CONFIG_INVALID")
    assert(not ConfigStore.new(nil, decode, encode, logger).save())
end)
test("HTTP failures, limits and logical timeout", function()
    local time = 0
    local scheduler = {
        spawn = function(fn: () -> ())
            fn()
        end,
        wait = function(delta: number)
            time += delta
        end,
        clock = function()
            return time
        end,
    }
    local function request(status: number, body: unknown)
        return HttpClient.new(function()
            return status, body
        end, scheduler)
    end
    local url = "https://raw.githubusercontent.com/owner/repo/main/status.json"
    assert(request(200, "ok").get(url, 3, 1) == "ok")
    local _, status = request(404, "no").get(url, 3, 1)
    assert(status == "HTTP_STATUS")
    local _, size = request(200, "oversized").get(url, 3, 1)
    assert(size == "HTTP_BODY")
    local _, invalid = request(200, {}).get(url, 3, 1)
    assert(invalid == "HTTP_BODY")
    local _, domain = request(200, "ok").get("https://evil.test", 3, 1)
    assert(domain == "URL_REJECTED")
    local client = HttpClient.new(function()
        error("offline")
    end, scheduler)
    local _, offline = client.get(url, 3, 1)
    assert(offline == "HTTP_FAILED")
    local delayed: (() -> ())? = nil
    scheduler.spawn = function(fn: () -> ())
        delayed = fn
    end
    local _, timeout = request(200, "ok").get(url, 3, 0.1)
    assert(timeout == "HTTP_TIMEOUT")
    assert(delayed)()
    local _, noScheduler = HttpClient.new(function()
        return 200, "ok"
    end, {} :: any).get(url, 3, 1)
    assert(noScheduler == "HTTP_SCHEDULER")
    local _, brokenSpawn = HttpClient.new(function()
        return 200, "ok"
    end, {
        spawn = function()
            error("broken")
        end,
        wait = function() end,
        clock = function()
            return 0
        end,
    }).get(url, 3, 1)
    assert(brokenSpawn == "HTTP_SCHEDULER")
end)
local function validManifest(): any
    local artifacts = {}
    for _, id in { "ui", "loader", "AnimeVanguards", "AnimeExpeditions" } do
        artifacts[id] = { path = "dist/" .. id .. ".lua", sha256 = string.rep("a", 64), bytes = 100 }
    end
    return {
        schemaVersion = 1,
        mode = "release",
        repository = "owner/repo",
        sourceCommit = string.rep("a", 40),
        artifactRevision = string.rep("b", 40),
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
end
test("manifest validates only the selected game and bounded artifact paths", function()
    assert(ManifestClient.validate(validManifest(), "owner/repo", "AnimeVanguards") ~= nil)
    assert(ManifestClient.validate(nil, "owner/repo", "AnimeVanguards") == nil)
    local m = validManifest()
    m.artifacts.ui.path = "dist/../secret.lua"
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") == nil)
    m = validManifest()
    m.artifacts.ui = nil
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") == nil)
    m = validManifest()
    m.artifacts.AnimeVanguards = nil
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") == nil)
    m = validManifest()
    m.artifacts.AnimeExpeditions = nil
    m.games.AnimeExpeditions = nil
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") ~= nil)
    assert(ManifestClient.validate(m, "owner/repo", "AnimeExpeditions") == nil)
    m = validManifest()
    m.artifacts.AnimeExpeditions.path = "dist/../secret.lua"
    m.games.AnimeExpeditions.version = "invalid"
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") ~= nil)
    assert(ManifestClient.validate(m, "owner/repo", "AnimeExpeditions") == nil)
    m = validManifest()
    m.sourceCommit = "main"
    m.artifactRevision = nil
    m.mode = "development"
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") ~= nil)
    m.artifactRevision = "working-branch"
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") ~= nil)
    m = validManifest()
    m.artifacts.ui.bytes = 0 / 0
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") == nil)
    m = validManifest()
    m.artifacts.ui.bytes = nil
    m.artifacts.ui.sha256 = nil
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") ~= nil)
    m.artifacts.ui.sha256 = "bad"
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") == nil)
    m = validManifest()
    m.games.AnimeVanguards.gameIds = { 5578556129 }
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") ~= nil)
    m.games.AnimeVanguards.gameIds = { "bad" }
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") == nil)
    assert(ManifestClient.validate(validManifest(), "other/repo", "AnimeVanguards") == nil)
end)
test("maintenance state does not default to ready", function()
    assert(ManifestClient.status({}, "AnimeVanguards") == nil)
    assert(
        ManifestClient.status(
            { schemaVersion = 1, games = { AnimeVanguards = { state = "maintenance" } } },
            "AnimeVanguards"
        ) == "maintenance"
    )
end)
test("module compiler errors and export mismatch", function()
    local _, code = ModuleLoader.load(function()
        return nil
    end, "abc", nil)
    assert(code == "MODULE_COMPILE")
    local accepted, mismatch = ModuleLoader.load(function()
        return function()
            return {}
        end
    end, "abc", nil)
    assert(type(accepted) == "table" and mismatch == nil)
    local _, empty = ModuleLoader.load(function()
        return function()
            return {}
        end
    end, "", nil)
    assert(empty == "MODULE_INPUT")
    local _, failure = ModuleLoader.load(function()
        return function()
            error("secret")
        end
    end, "abc", nil)
    assert(failure == "MODULE_EXECUTION")
    assert(not ModuleLoader.isGame({}, "AnimeVanguards", "0.1.0"))
end)
test("save captures keybind selection without a keypress callback", function()
    local payload: any = nil
    local storage = {
        read = function(): (string?, string?)
            return nil, nil
        end,
        write = function(_body: string): boolean
            return true
        end,
    }
    local store = ConfigStore.new(storage, function()
        return nil
    end, function(value: any): string
        payload = value
        return "saved"
    end, function() end)
    local function element(_self: any, options: any): any
        options.Set = function(self: any, value: any)
            self.Value = value
        end
        return options
    end
    local tab = {
        Paragraph = element,
        Toggle = element,
        Slider = element,
        Dropdown = element,
        Keybind = element,
        Button = element,
    }
    local activeKey = ""
    local window: any = {
        Tab = function()
            return tab
        end,
        SetToggleKey = function(_self: any, key: string)
            activeKey = key
        end,
    }
    Settings.mount(window, store, { Notify = function() end }, { RightShift = "RightShift", F4 = "F4" })
    window.ViperControls.toggleKey.Callback("F4")
    assert(store.get().toggleKey == "F4" and activeKey == "F4")
    window.ViperControls.toggleKey.Callback("LeftAlt")
    assert(store.get().toggleKey == "F4" and activeKey == "F4")
    assert(window.ViperControls.toggleKey.Value == "F4")
    window.ViperControls.toggleKey.Callback("RightShift")
    window.ViperControls.toggleKey:Set("F4")
    assert(store.get().toggleKey == "RightShift")
    window.ViperControls.save.Callback()
    assert(payload.toggleKey == "F4" and store.get().toggleKey == "F4")
end)
test("game configs are exported without duplicate stop registration", function()
    for _, entry in { VanguardsEntry, ExpeditionsEntry } do
        local game: any = entry
        assert(type(entry.config) == "table" and type(entry.config.instancePaths) == "table")
        local context = Context.new(function() end)
        game.start(context)
        assert(context.cleanup.count() == 0)
        game.stop()
    end
end)
test("diagnostics shows existing codes at mount", function()
    local initial = ""
    local options: any = nil
    local tab = {
        Paragraph = function(_self: any, value: any)
            initial = value.Desc
            return {
                SetDesc = function(_s: any, text: string)
                    initial = text
                end,
            }
        end,
        Button = function(_self: any, value: any)
            options = value
        end,
    }
    DiagnosticsPage.mount({
        Tab = function()
            return tab
        end,
    }, {
        snapshot = function()
            return { "FIRST" }
        end,
    })
    assert(initial == "FIRST")
    options.Callback()
    assert(initial == "FIRST")
end)
print(string.format("PASS: %d unit scenarios", passed))
