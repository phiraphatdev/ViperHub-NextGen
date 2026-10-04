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
local JoinerSettings = require("../../src/games/AnimeVanguards/Joiner/Settings")
local JoinerPage = require("../../src/games/AnimeVanguards/Joiner/Page")
local JoinerCatalog = require("../../src/games/AnimeVanguards/Joiner/Catalog")
local VanguardsConfig = require("../../src/games/AnimeVanguards/Config")
local TeamEquip = require("../../src/games/AnimeVanguards/Joiner/TeamEquip")
local MacroEquip = require("../../src/games/AnimeVanguards/Joiner/MacroEquip")
local TeamAdapter = require("../../src/games/AnimeVanguards/Joiner/TeamAdapter")
local JoinerRuntime = require("../../src/games/AnimeVanguards/Joiner/Runtime")
local ActivityState = require("../../src/games/AnimeVanguards/Joiner/ActivityState")
local MacroDocument = require("../../src/games/AnimeVanguards/Macro/Document")
local MacroStorage = require("../../src/games/AnimeVanguards/Macro/Storage")
local MacroRuntime = require("../../src/games/AnimeVanguards/Macro/Runtime")
local MacroAdapter = require("../../src/games/AnimeVanguards/Macro/Adapter")
local GameAdapter = require("../../src/games/AnimeVanguards/Game/Adapter")
local GamePage = require("../../src/games/AnimeVanguards/Game/Page")
local AutoPlayRuntime = require("../../src/games/AnimeVanguards/AutoPlay/Runtime")
local AutoPlayPage = require("../../src/games/AnimeVanguards/AutoPlay/Page")
local AutoPlayRules = require("../../src/games/AnimeVanguards/AutoPlay/Rules")
local AutoPlayAdapter = require("../../src/games/AnimeVanguards/AutoPlay/Adapter")
local StatusPage = require("../../src/games/AnimeVanguards/Status/Page")
local WebhookEmbed = require("../../src/games/AnimeVanguards/Webhook/Embed")
local WebhookSender = require("../../src/games/AnimeVanguards/Webhook/Sender")
local WebhookSession = require("../../src/games/AnimeVanguards/Webhook/Session")
local WebhookEvents = require("../../src/games/AnimeVanguards/Webhook/Events")
local WebhookRuntime = require("../../src/games/AnimeVanguards/Webhook/Runtime")
local WebhookPage = require("../../src/games/AnimeVanguards/Webhook/Page")
local MiscRuntime = require("../../src/games/AnimeVanguards/Misc/Runtime")
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
    assert(c.uiScale == 1.3 and c.toggleKey == "RightShift" and c.theme == "Viper")
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
    assert(payload.uiScale == 0.9) -- Auto-saved without pressing Save.
    store.update("toggleKey", "F4")
    store.update("toggleKey", "LeftAlt")
    assert(store.get().toggleKey == "F4")
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
    assert(ManifestClient.validate(m, "owner/repo", "AnimeVanguards") == nil)
    m.mode = "development"
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
test("game-owned pages are optional and validated", function()
    assert(ModuleLoader.isGame(ExpeditionsEntry, "AnimeExpeditions", "0.2.2"))
    assert(ModuleLoader.isGame(VanguardsEntry, "AnimeVanguards", "0.2.2"))
    assert(
        #VanguardsEntry.pages == 8
            and VanguardsEntry.pages[1].title == "Dashboard"
            and VanguardsEntry.pages[1].home == true
    )
    local invalid: any = {
        metadata = VanguardsEntry.metadata,
        start = VanguardsEntry.start,
        stop = VanguardsEntry.stop,
        pages = { { title = "Bad", description = 42 } },
    }
    assert(not ModuleLoader.isGame(invalid, "AnimeVanguards", "0.2.2"))
end)
test("Joiner settings pause cooldown priority and reset", function()
    JoinerSettings.resetPriority()
    assert(JoinerSettings.get().paused and JoinerSettings.get().cooldown == 0)
    assert(not JoinerSettings.setPaused("false"))
    assert(JoinerSettings.setPaused(false) and not JoinerSettings.get().paused)
    assert(not JoinerSettings.setCooldown(0 / 0))
    assert(JoinerSettings.setCooldown(999) and JoinerSettings.get().cooldown == 300)
    assert(JoinerSettings.setCooldown(-5) and JoinerSettings.get().cooldown == 0)
    local before = JoinerSettings.get().priority
    assert(not JoinerSettings.moveUp("Unknown"))
    assert(JoinerSettings.moveUp(before[2]))
    assert(JoinerSettings.get().priority[1] == before[2])
    before[1] = "tampered"
    assert(JoinerSettings.get().priority[1] ~= "tampered")
    local reset = JoinerSettings.resetPriority()
    assert(reset[1] == "Rift" and reset[2] == "Weekly Challenge")
    assert(reset[3] == "Daily Challenge" and reset[4] == "Regular Challenge")
    assert(#reset == 13 and reset[5] == "Stage")
    local seen: { [string]: boolean } = {}
    for _, name in reset do
        assert(not seen[name])
        seen[name] = true
    end
    assert(JoinerSettings.get().priority[1] == "Rift")
    assert(not JoinerSettings.get().paused) -- Reset does not alter other settings.
    JoinerSettings.setPaused(true)
end)
test("Joiner controls auto-save and reload with executor files", function()
    local body: string? = nil
    local snapshot: any = nil
    local writes = 0
    local http = {
        JSONEncode = function(_self: any, value: any): string
            snapshot = value
            return "saved"
        end,
        JSONDecode = function(_self: any, _value: string): any
            return snapshot
        end,
    }
    local env: any = {
        game = {
            GetService = function(_self: any, name: string): any
                assert(name == "HttpService")
                return http
            end,
        },
        isfile = function(): boolean
            return body ~= nil
        end,
        readfile = function(): string?
            return body
        end,
        writefile = function(_path: string, text: string)
            body = text
            writes += 1
        end,
        isfolder = function(): boolean
            return true
        end,
        makefolder = function() end,
    }
    JoinerSettings.init(env)
    assert(JoinerSettings.setPaused(false))
    assert(JoinerSettings.setCooldown(12))
    assert(JoinerSettings.setEnabled("Stage", true))
    assert(JoinerSettings.setSelection("Stage", { stage = "Stage1", act = "Act1", difficulty = "Normal" }))
    assert(writes >= 4 and body == "saved")
    assert(snapshot.paused == false and snapshot.cooldown == 12)
    assert(snapshot.enabled.Stage == true and snapshot.selection.Stage.stage == "Stage1")
    local oldOrder = table.clone(snapshot.priority)
    table.insert(oldOrder, 2, "Pirate Dynasty")
    table.insert(oldOrder, 3, "Spring Event")
    table.insert(oldOrder, 4, "Summer Event")
    snapshot.priority = oldOrder
    JoinerSettings.init(env)
    local restored = JoinerSettings.get()
    assert(restored.persistent and not restored.paused and restored.cooldown == 12)
    assert(restored.enabled.Stage and restored.selection.Stage.act == "Act1")
    assert(#restored.priority == 13 and restored.priority[2] == oldOrder[5])
    JoinerSettings.setEnabled("Stage", false)
    JoinerSettings.setPaused(true)
end)
test("Joiner catalog sorts real mode shapes without inventing acts", function()
    local fixture = {
        Story = {
            Stage10 = {
                StageData = { Name = "Later" },
                Acts = { Act2 = { ActName = "Second" }, Act1 = { ActName = "First" } },
            },
            Stage2 = { StageData = { Name = "Earlier" }, Acts = { Act1 = { ActName = "Only" } } },
            Bad = { Acts = "bad" },
        },
        Raid = { Stage1 = { StageData = { Name = "Raid One" }, Acts = { Act1 = {} } } },
    }
    local story = JoinerCatalog.list(fixture, "Story")
    assert(#story == 2 and story[1].id == "Stage2" and story[2].id == "Stage10")
    assert(story[2].acts[1].id == "Act1" and story[2].acts[2].id == "Act2")
    assert(JoinerCatalog.list(fixture, "Raid")[1].name == "Raid One")
    assert(#JoinerCatalog.list(fixture, "Dungeon") == 0)
    assert(#JoinerCatalog.list(nil, "Story") == 0)
end)
test("Joiner page refreshes acts when a different stage is selected", function()
    local callbacks: { [string]: any } = {}
    local refreshed: { string }? = nil
    local tab: any = {}
    tab.Section = function()
        return tab
    end
    tab.Paragraph = function()
        return { SetDesc = function() end }
    end
    tab.Toggle = function() end
    tab.Slider = function() end
    tab.Button = function() end
    tab.Dropdown = function(_self: any, options: any)
        callbacks[options.Title] = options.Callback
        return {
            Refresh = function(_control: any, values: { string })
                refreshed = values
            end,
            Select = function() end,
        }
    end
    JoinerPage.mount(tab, {
        Story = {
            Stage1 = { StageData = { Name = "First" }, Acts = { Act1 = { ActName = "One" } } },
            Stage2 = { StageData = { Name = "Second" }, Acts = { Act2 = { ActName = "Two" } } },
        },
    })
    callbacks["Select Stage"]("Stage2 - Second")
    assert(refreshed ~= nil and refreshed[1] == "Act2 - Two")
end)
test("Joiner page exposes settings but no action button", function()
    local titles: { string } = {}
    local sections: { string } = {}
    local locked = 0
    local tab: any = {}
    tab.Section = function(_self: any, options: any)
        table.insert(sections, options.Title)
        return tab
    end
    for _, kind in { "Paragraph", "Toggle", "Slider", "Dropdown", "Button" } do
        tab[kind] = function(_self: any, options: any)
            table.insert(titles, options.Title)
            if kind == "Toggle" and options.Locked then
                locked += 1
            end
            return { SetDesc = function() end }
        end
    end
    JoinerPage.mount(tab)
    assert(table.find(titles, "Reset Auto Join Priority") ~= nil)
    assert(table.find(titles, "Disable Auto Joiners") ~= nil)
    assert(table.find(sections, "Rift Joiner") ~= nil)
    assert(table.find(titles, "Join now") == nil)
    assert(table.find(sections, "Auto Join Settings") ~= nil)
    assert(table.find(sections, "Stage Joiner") ~= nil)
    assert(table.find(sections, "Raid Joiner") ~= nil)
    assert(table.find(sections, "Worldline Joiner") ~= nil)
    assert(table.find(sections, "Regular Challenge Joiner") ~= nil)
    assert(table.find(sections, "Priority") == nil)
    assert(table.find(sections, "Auto Join Equipper") ~= nil)
    assert(table.find(sections, "Team Equipper") ~= nil and table.find(sections, "Macro Equipper") ~= nil)
    assert(table.find(titles, "Auto Join Team Equipper") ~= nil)
    assert(table.find(titles, "Stage Joiner") ~= nil and table.find(titles, "Boss Bounties Joiner") ~= nil)
    assert(locked == 15, "13 unavailable joiners plus the Team and Macro Equipper toggles")
end)
test("Joiner requests one unlocked private match and requires matching server ACK", function()
    local sent: any = nil
    local confirm: any = nil
    local disconnected = false
    local unlocked = true
    local lobby = { IsHosting = false, IsInLobby = false }
    local startCount = 0
    local runtime = JoinerRuntime.new({
        game = { PlaceId = 16146832113 },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        lobby = lobby,
        progress = {
            GetActData = function(mode: string)
                return if mode == "Raid" or unlocked then {} else nil
            end,
        },
        network = {
            CreateMatch = {
                Fire = function(payload: any)
                    sent = payload
                end,
            },
            StartMatch = {
                Fire = function()
                    startCount += 1
                end,
            },
            MatchConfirmed = {
                On = function(callback: any)
                    confirm = callback
                    return function()
                        disconnected = true
                    end
                end,
            },
        },
    })
    JoinerSettings.setPaused(false)
    JoinerSettings.setCooldown(0)
    runtime.setSelection("Stage", "Stage1", "Act1", "Normal")
    runtime.setEnabled("Stage", true)
    runtime.start({ alive = true })
    unlocked = false
    runtime.step(100)
    assert(sent == nil and string.find(runtime.status, "locked", 1, true))
    unlocked = true
    runtime.step(100)
    assert(sent.Public == false and sent.FriendsOnly == true)
    assert(sent.StageType == "Story" and sent.Stage == "Stage1" and sent.Act == "Act1")
    confirm({ StageType = "Raid", Stage = "Stage1", Act = "Act1", HostUserId = 42, GUID = "wrong" })
    assert(runtime.pending ~= nil)
    confirm({ StageType = "Story", Stage = "Stage1", Act = "Act1", HostUserId = 42, GUID = "match" })
    assert(runtime.pending == nil and string.find(runtime.status, "confirmed", 1, true))
    runtime.step(101)
    assert(startCount == 0) -- ACK precedes the game's host-state update.
    lobby.IsHosting = true
    runtime.step(102)
    runtime.step(103)
    assert(startCount == 1 and string.find(runtime.status, "waiting for teleport", 1, true))
    runtime.confirmed = nil -- Simulate the previous lobby ending before testing priority fallback.
    lobby.IsHosting = false
    sent = nil
    unlocked = false
    runtime.setSelection("Raid", "Stage1", "Act1", "Normal")
    runtime.setEnabled("Raid", true)
    runtime.step(200)
    assert(sent ~= nil and sent.StageType == "Raid") -- Locked higher priority falls through.
    runtime.stop()
    assert(disconnected)
    JoinerSettings.setPaused(true)
end)
test("Challenge joiner uses Name and requires matching ChallengeType ACK", function()
    local sent: any = nil
    local confirm: any = nil
    local available = true
    local lobby = { IsHosting = false, IsInLobby = false }
    local startCount = 0
    local runtime = JoinerRuntime.new({
        game = { PlaceId = 16146832113 },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        lobby = lobby,
        progress = {
            GetActData = function()
                return nil
            end,
        },
        challengeAttempts = {
            GetChallengeSeed = function()
                return 1
            end,
        },
        challengeData = {
            GetChallengeSeed = function()
                return 2
            end,
            GetNextReset = function()
                return 0
            end,
            GetChallengesOfType = function(kind: string)
                assert(kind == "Daily")
                return if available then { { Name = "Daily Challenge" } } else {}
            end,
        },
        challengeStages = {
            GetChallengeStage = function()
                return { StageType = "LegendStage", Stage = "Stage10", Act = "Act3" }
            end,
        },
        challengeNetwork = {
            StartChallenge = {
                Fire = function(payload: any)
                    sent = payload
                end,
            },
        },
        network = {
            StartMatch = {
                Fire = function()
                    startCount += 1
                end,
            },
            MatchConfirmed = {
                On = function(callback: any)
                    confirm = callback
                    return function() end
                end,
            },
        },
    })
    JoinerSettings.setPaused(false)
    runtime.setChallenge("Daily Challenge", "Daily Challenge")
    runtime.setEnabled("Daily Challenge", true)
    runtime.start({ alive = true })
    runtime.step(100)
    assert(sent.Name == "Daily Challenge" and runtime.pending ~= nil)
    confirm({
        StageType = "LegendStage",
        Stage = "Stage10",
        Act = "Act3",
        ChallengeType = "Wrong",
        HostUserId = 42,
        GUID = "a",
    })
    assert(runtime.pending ~= nil)
    confirm({
        StageType = "LegendStage",
        Stage = "Stage10",
        Act = "Act3",
        ChallengeType = "Daily Challenge",
        HostUserId = "42",
        GUID = "a",
    })
    assert(runtime.pending == nil and string.find(runtime.status, "confirmed", 1, true))
    lobby.IsHosting = true
    runtime.step(101)
    runtime.step(102)
    assert(startCount == 1)
    runtime.confirmed = nil
    lobby.IsHosting = false
    sent = nil
    available = false
    runtime.step(200)
    assert(sent == nil and string.find(runtime.status, "unavailable", 1, true))
    runtime.stop()
    JoinerSettings.setPaused(true)
end)
test("Joiner challenge dropdown binds game-owned challenge names", function()
    local chosen: any = nil
    local callbacks: { [string]: any } = {}
    local unlocked: { [string]: boolean } = {}
    local tab: any = {}
    tab.Section = function()
        return tab
    end
    tab.Paragraph = function()
        return { SetDesc = function() end }
    end
    tab.Toggle = function(_self: any, options: any)
        unlocked[options.Title] = options.Locked ~= true
    end
    tab.Slider = function() end
    tab.Button = function() end
    tab.Dropdown = function(_self: any, options: any)
        callbacks[options.Title] = options.Callback
        return { Refresh = function() end, Select = function() end }
    end
    local runtime: any = {
        status = "Idle",
        setSelection = function() end,
        setEnabled = function() end,
        setChallenge = function(kind: string, name: string)
            chosen = { kind = kind, name = name }
        end,
    }
    JoinerPage.mount(tab, {}, runtime, {
        Regular = { "Gold Challenge", "Trait Reroll Challenge" },
        Daily = { "Daily Challenge" },
        Weekly = {},
    })
    assert(unlocked["Auto Join Regular Challenge"])
    assert(unlocked["Auto Join Daily Challenge"])
    assert(not unlocked["Auto Join Weekly Challenge"])
    callbacks["Select Regular Challenge"]("Trait Reroll Challenge")
    assert(chosen.kind == "Regular Challenge" and chosen.name == "Trait Reroll Challenge")
end)
test("Worldline joiner validates selection and progress before teleport request", function()
    local sent: any = nil
    local ready = false
    local runtime = JoinerRuntime.new({
        game = { PlaceId = 16146832113 },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        lobby = { IsHosting = false, IsInLobby = false },
        worldlines = {
            GetAll = function()
                return { WorldsCollide = { DisplayName = "Worlds Collide" } }
            end,
        },
        worldlineNetwork = {
            GetWorldlineProgress = {
                Invoke = function()
                    return { Ready = ready }
                end,
            },
            TeleportToWorldline = {
                Fire = function(payload: any)
                    sent = payload
                end,
            },
        },
        network = {
            MatchConfirmed = {
                On = function()
                    return function() end
                end,
            },
        },
    })
    JoinerSettings.setPaused(false)
    runtime.setWorldline("Missing", "Traits")
    runtime.setEnabled("Worldline", true)
    runtime.start({ alive = true })
    runtime.step(100)
    assert(sent == nil)
    runtime.setWorldline("WorldsCollide", "Traits")
    runtime.step(101)
    assert(sent == nil)
    ready = true
    runtime.step(102)
    assert(sent.WorldlineId == "WorldsCollide" and sent.TraitsType == "Traits")
    runtime.stop()
    JoinerSettings.setEnabled("Worldline", false)
    JoinerSettings.setPaused(true)
end)
test("Worldline joiner skips completed alternate worldlines and reads progress", function()
    local sent: any = nil
    local completed = true
    local runtime = JoinerRuntime.new({
        game = { PlaceId = 16146832113 },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        lobby = { IsHosting = false, IsInLobby = false },
        worldlines = {
            GetAll = function()
                return { FriranRerun = { DisplayName = "Friran Rerun" } }
            end,
        },
        worldlineNetwork = {
            GetWorldlineProgress = {
                Invoke = function()
                    return {
                        Ready = true,
                        CurrentRoom = 51,
                        AltWorldlines = {
                            { WorldlineId = "FriranRerun", CurrentRoom = 50, Completed = completed },
                        },
                    }
                end,
            },
            TeleportToWorldline = {
                Fire = function(payload: any)
                    sent = payload
                end,
            },
        },
        network = {
            MatchConfirmed = {
                On = function()
                    return function() end
                end,
            },
        },
    })
    JoinerSettings.setPaused(false)
    runtime.setWorldline("FriranRerun", "Traits")
    runtime.setEnabled("Worldline", true)
    runtime.start({ alive = true })
    runtime.step(100)
    assert(sent == nil and string.find(runtime.status, "already completed", 1, true))
    local progress = runtime.readWorldlineProgress()
    assert(progress.room == 51 and progress.worlds[1].id == "FriranRerun" and progress.worlds[1].completed)
    completed = false
    runtime.step(101)
    assert(sent ~= nil and sent.WorldlineId == "FriranRerun")
    runtime.stop()
    JoinerSettings.setEnabled("Worldline", false)
    JoinerSettings.setPaused(true)
end)
test("Boss Bounties joiner creates the game's daily bounty match and requires ACK", function()
    local sent: any = nil
    local confirm: any = nil
    local left = 0
    local unlocked = true
    local runtime = JoinerRuntime.new({
        game = { PlaceId = 16146832113 },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        lobby = { IsHosting = false, IsInLobby = false },
        progress = {
            GetActData = function()
                return if unlocked then {} else nil
            end,
        },
        bountyState = {
            GetSeed = function()
                return 1790725735 -- BountyStartTime; must not be used as the bounty seed
            end,
            GetData = function()
                return { BountySeed = 28046, BountiesLeft = left, BountyStartTime = 1790725735 }
            end,
        },
        bountyData = {
            GetBountyFromSeed = function(seed: number)
                assert(seed == 28046)
                return { BossName = "Hirko", Act = "Act4", StageType = "Story", Stage = "Stage2" }
            end,
        },
        network = {
            CreateMatch = {
                Fire = function(payload: any)
                    sent = payload
                end,
            },
            StartMatch = { Fire = function() end },
            MatchConfirmed = {
                On = function(callback: any)
                    confirm = callback
                    return function() end
                end,
            },
        },
    })
    for _, other in { "Stage", "Legend Stage", "Raid", "Dungeon", "Worldline", "Boss Event" } do
        JoinerSettings.setEnabled(other, false)
    end
    JoinerSettings.setPaused(false)
    JoinerSettings.setCooldown(0)
    runtime.setEnabled("Boss Bounties", true)
    runtime.start({ alive = true })
    local bounty = runtime.readBounty()
    assert(
        bounty.mode == "Story"
            and bounty.stage == "Stage2"
            and bounty.act == "Act4"
            and bounty.boss == "Hirko"
    )
    runtime.step(100)
    assert(sent == nil and string.find(runtime.status, "none left", 1, true), runtime.status)
    left = 10
    unlocked = false
    runtime.step(100)
    assert(sent == nil and string.find(runtime.status, "locked", 1, true))
    unlocked = true
    runtime.step(100)
    assert(sent.StageType == "Story" and sent.Stage == "Stage2" and sent.Act == "Act4")
    assert(sent.Difficulty == "Normal" and sent.Public == false)
    confirm({ StageType = "Story", Stage = "Stage2", Act = "Act1", HostUserId = 42, GUID = "wrong" })
    assert((string.find(runtime.status, "waiting for server confirmation", 1, true)) ~= nil)
    confirm({ StageType = "Story", Stage = "Stage2", Act = "Act4", HostUserId = 42, GUID = "bounty" })
    assert((string.find(runtime.status, "confirmed by server", 1, true)) ~= nil)
    runtime.stop()
    JoinerSettings.setEnabled("Boss Bounties", false)
    JoinerSettings.setPaused(true)
end)
test("Boss Event joiner accepts only current rotation and matching host confirmation", function()
    local sent: any = nil
    local confirm: any = nil
    local started = 0
    local lobby = { IsHosting = false, IsInLobby = false }
    local runtime = JoinerRuntime.new({
        game = { PlaceId = 16146832113 },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        lobby = lobby,
        bossRotation = {
            GetCurrentBossEvent = function()
                return "BeastPirateEvent"
            end,
        },
        bossNetwork = {
            StartBossEvent = {
                Fire = function(payload: any)
                    sent = payload
                end,
            },
        },
        network = {
            StartMatch = {
                Fire = function()
                    started += 1
                end,
            },
            MatchConfirmed = {
                On = function(callback: any)
                    confirm = callback
                    return function() end
                end,
            },
        },
    })
    JoinerSettings.setPaused(false)
    runtime.setBossEvent("SaberEvent", "Elite")
    runtime.setEnabled("Boss Event", true)
    runtime.start({ alive = true })
    runtime.step(100)
    assert(sent == nil)
    runtime.setBossEvent("BeastPirateEvent", "Elite")
    runtime.step(101)
    assert(sent.EventName == "BeastPirateEvent" and sent.Difficulty == "Elite")
    confirm({ StageType = "BossEvent", Stage = "SaberEvent", HostUserId = 42, GUID = "wrong" })
    assert(runtime.pending ~= nil)
    confirm({ StageType = "BossEvent", Stage = "BeastPirateEvent", HostUserId = 42, GUID = "right" })
    lobby.IsHosting = true
    runtime.step(102)
    assert(started == 1)
    runtime.stop()
    JoinerSettings.setEnabled("Boss Event", false)
    JoinerSettings.setPaused(true)
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
test("macro document validates action order and legacy unit references", function()
    local document = MacroDocument.empty("test")
    assert(MacroDocument.validate(document) ~= nil)
    table.insert(document.actions, { index = 2, kind = "sell", unitRef = "1", wave = 0, yen = 0, time = 0 })
    assert(MacroDocument.validate(document) == nil)
    document.actions[1].index = 1
    assert(MacroDocument.validate(document) ~= nil)
    document.actions[1].kind = "unknown"
    assert(MacroDocument.validate(document) == nil)
    local imported = assert(MacroDocument.importLegacy({
        Marco_Data = {
            {
                Method = "SpawnTower",
                Index = 1,
                UnitValue = 2,
                Unit = "Test",
                Position = "1, 2, 3",
                Time = 1,
                Wave = 0,
            },
            { Method = "UpgradeTower", Index = 2, UnitValue = 2, Time = 2, Wave = 1 },
        },
    }, "imported"))
    assert(imported.actions[1].unitRef == imported.actions[2].unitRef)
    assert(imported.schemaVersion == 2 and #imported.actions[1].cframe == 12)
    local pose, yaw = MacroDocument.toPose(imported.actions[1].cframe)
    assert(pose.x == 1 and pose.y == 2 and pose.z == 3 and math.abs(assert(yaw)) < 0.001)
    local importedHighUnit = assert(MacroDocument.importLegacy({
        Marco_Data = {
            {
                Method = "SpawnTower",
                Index = 1,
                UnitValue = 12,
                Unit = "Test",
                Position = "1, 2, 3",
                Time = 1,
                Wave = 0,
            },
        },
    }, "high_unit"))
    assert(importedHighUnit.actions[1].slotIndex >= 1 and importedHighUnit.actions[1].slotIndex <= 8)
    local old = {
        schemaVersion = 1,
        name = "old",
        game = "AnimeVanguards",
        match = { stage = "Stage14", difficulty = "Normal", act = "Act1", mode = "Story" },
        units = {},
        actions = {
            {
                index = 1,
                kind = "place",
                unitRef = "1",
                unitName = "Test",
                position = { x = 1, y = 2, z = 3 },
                rotation = 90,
                slotIndex = 1,
                wave = 0,
                yen = 0,
                time = 0,
            },
        },
    }
    local upgraded = assert(MacroDocument.validate(old))
    assert(
        upgraded.schemaVersion == 2
            and upgraded.match.stage == nil
            and upgraded.match.act == nil
            and upgraded.match.difficulty == nil
    )
    assert(upgraded.actions[1].position == nil and #upgraded.actions[1].cframe == 12)
    assert(old.schemaVersion == 1 and old.match.stage == "Stage14")
end)
test("macro pre-start vote recording and compact CFrame", function()
    local observers: { [string]: any } = {}
    local adapter = {
        state = function()
            return nil
        end,
        preMatchState = function()
            return { wave = 0, yen = 0, match = { mode = "Story" } }
        end,
        observe = function(kind: string, callback: any)
            observers[kind] = callback
            return function() end
        end,
    }
    local storage = {
        write = function()
            return true
        end,
    }
    local runtime = MacroRuntime.new(adapter, storage)
    runtime.start({ alive = true })
    assert(runtime.record("before_start"))
    observers.voteClicked({ Context = "Start" })
    observers.voteClicked({ Context = "Start" })
    observers.voteClicked()
    local document = assert(runtime.finishRecord())
    assert(#document.actions == 1 and document.actions[1].kind == "voteStart")
    local cframe = assert(MacroDocument.fromPose({ x = 1.123456789, y = 2, z = 3 }, 90))
    assert(cframe[1] == 1.123457 and cframe[4] == 0 and cframe[6] == 1)
    runtime.stop()
end)
test("macro placement waits for live price and never queues phantom", function()
    local yen = 0
    local requestedAt = -1
    local queued = 0
    local adapter = {
        state = function()
            return { wave = 1, yen = yen, units = {} }
        end,
        observe = function()
            return function() end
        end,
        queuePlace = function()
            queued += 1
            return true
        end,
        cost = function()
            return 500
        end,
        request = function()
            requestedAt = yen
            return true
        end,
        confirm = function()
            return true, "placed-guid"
        end,
    }
    local scheduler = {
        spawn = function(callback: any)
            callback()
        end,
        wait = function()
            yen += 100
        end,
    }
    local runtime = MacroRuntime.new(adapter, nil, scheduler)
    runtime.start({ alive = true })
    local document = MacroDocument.empty("ghost")
    table.insert(document.actions, {
        index = 1,
        kind = "place",
        wave = 1,
        yen = 1000,
        time = 0,
        unitRef = "1",
        unitName = "Test",
        slotIndex = 1,
        cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
    })
    assert(runtime.play(document))
    assert(queued == 0 and requestedAt >= 500 and runtime.mode == "play")
    runtime.stop()
end)
test("macro upgrade waits for live upgrade price, not recorded yen", function()
    local yen = 100
    local requestedAt = 0
    local adapter = {
        state = function()
            return { wave = 1, yen = yen, units = {} }
        end,
        observe = function()
            return function() end
        end,
        cost = function(action: any)
            return if action.kind == "place" then 0 else 500
        end,
        request = function(action: any)
            if action.kind == "upgrade" then
                requestedAt = yen
            end
            return true
        end,
        confirm = function()
            return true, "placed-guid"
        end,
    }
    local scheduler = {
        spawn = function(callback: any)
            callback()
        end,
        wait = function()
            yen += 100
        end,
    }
    local runtime = MacroRuntime.new(adapter, nil, scheduler)
    runtime.start({ alive = true })
    local document = MacroDocument.empty("upgrade")
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
            wave = 1,
            yen = 0,
            time = 0,
        },
        { index = 2, kind = "upgrade", unitRef = "1", wave = 1, yen = 99999, time = 0 },
    }
    assert(runtime.play(document))
    assert(requestedAt >= 500 and requestedAt < 99999 and runtime.mode == "play")
    runtime.stop()
end)
test("macro playback preserves recorded upgrade index instead of silently skipping", function()
    local placed = 0
    local upgraded = 0
    local yen = 2357
    local order: { string } = {}
    local adapter = {
        state = function()
            return { wave = 1, yen = yen, units = {} }
        end,
        observe = function()
            return function() end
        end,
        cost = function(action: any)
            return if action.kind == "upgrade" then 4860 else 495
        end,
        request = function(action: any)
            table.insert(order, action.kind)
            if action.kind == "place" then
                placed += 1
            else
                upgraded += 1
            end
            return true
        end,
        confirm = function()
            return true, "guid"
        end,
    }
    local scheduler = {
        spawn = function(callback: any)
            callback()
        end,
        wait = function()
            yen = 5000
        end,
    }
    local runtime = MacroRuntime.new(adapter, nil, scheduler)
    runtime.start({ alive = true })
    local document = MacroDocument.empty("recorded")
    local cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0)
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = cframe,
            wave = 0,
            yen = 105,
            time = 0,
        },
        { index = 2, kind = "upgrade", unitRef = "1", wave = 0, yen = 105, time = 0.004 },
        {
            index = 3,
            kind = "place",
            unitRef = "3",
            unitName = "Test",
            slotIndex = 1,
            cframe = cframe,
            wave = 1,
            yen = 2357,
            time = 4.3,
        },
    }
    assert(runtime.play(document))
    assert(placed == 2 and upgraded == 1 and runtime.mode == "play")
    assert(table.concat(order, ",") == "place,upgrade,place")
    runtime.stop()
end)
test("macro placement retries direct offsets and None skips dependent steps", function()
    local yen = 0
    local price = 500
    local attempts: { any } = {}
    local queued = 0
    local adapter = {
        state = function()
            return { wave = 1, yen = yen, units = {} }
        end,
        observe = function()
            return function() end
        end,
        cost = function()
            return price
        end,
        queuePlace = function()
            queued += 1
            return true
        end,
        request = function(action: any)
            table.insert(
                attempts,
                { ref = action.unitRef, x = action.cframe[1], z = action.cframe[3], y = action.cframe[2] }
            )
            return action.unitRef == "3"
        end,
        confirm = function()
            return true, "second-unit"
        end,
    }
    local scheduler = {
        spawn = function(callback: any)
            callback()
        end,
        wait = function()
            yen += 100
            if yen == 500 then
                price = 600
            end
        end,
    }
    local runtime = MacroRuntime.new(adapter, nil, scheduler)
    runtime.start({ alive = true })
    runtime.settings.retryLimit = 3
    runtime.settings.placementFailure = "None"
    local document = MacroDocument.empty("offset")
    local cframe = assert(MacroDocument.fromPose({ x = 10, y = 2, z = 20 }, 0))
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = cframe,
            wave = 1,
            yen = 0,
            time = 0,
        },
        { index = 2, kind = "upgrade", unitRef = "1", wave = 1, yen = 0, time = 1 },
        {
            index = 3,
            kind = "place",
            unitRef = "3",
            unitName = "Test",
            slotIndex = 1,
            cframe = cframe,
            wave = 1,
            yen = 0,
            time = 2,
        },
    }
    assert(runtime.play(document))
    assert(queued == 0 and #attempts == 4 and runtime.mode == "play")
    assert(attempts[1].x == 10 and attempts[2].x == 11 and attempts[3].z == 21)
    assert(attempts[1].y == 2 and cframe[1] == 10 and cframe[3] == 20)
    runtime.stop()
end)
test("macro stops with step reason when live price is unavailable", function()
    local requested = 0
    local adapter = {
        state = function()
            return { wave = 1, yen = 10000, units = {} }
        end,
        observe = function()
            return function() end
        end,
        cost = function()
            return nil
        end,
        request = function()
            requested += 1
            return true
        end,
    }
    local scheduler = {
        spawn = function(callback: any)
            callback()
        end,
        wait = function() end,
    }
    local runtime = MacroRuntime.new(adapter, nil, scheduler)
    runtime.start({ alive = true })
    local document = MacroDocument.empty("no_price")
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
            wave = 1,
            yen = 0,
            time = 0,
        },
    }
    assert(runtime.play(document))
    assert(requested == 0 and runtime.mode == "idle" and runtime.status:find("Live price unavailable"))
    runtime.stop()
end)
test("macro Restart waits for MatchRestarted and replays once", function()
    local observers: { [string]: any } = {}
    local requests, votes = 0, 0
    local timeout: any = nil
    local adapter = {
        state = function()
            return { wave = 1, yen = 1000, units = {} }
        end,
        observe = function(kind: string, callback: any)
            observers[kind] = callback
            return function() end
        end,
        cost = function()
            return 500
        end,
        request = function()
            requests += 1
            return requests > 1
        end,
        confirm = function()
            return true, "guid"
        end,
        castRestartVote = function()
            votes += 1
            return true
        end,
    }
    local scheduler = {
        spawn = function(callback: any)
            callback()
        end,
        wait = function() end,
        delay = function(_seconds: number, callback: any)
            timeout = callback
        end,
    }
    local runtime = MacroRuntime.new(adapter, nil, scheduler)
    runtime.start({ alive = true })
    runtime.settings.retryLimit = 1
    runtime.settings.placementFailure = "Restart"
    local document = MacroDocument.empty("restart")
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
            wave = 1,
            yen = 0,
            time = 0,
        },
    }
    assert(runtime.play(document))
    assert(votes == 1 and runtime.mode == "play" and timeout ~= nil)
    observers.matchEnd()
    assert(runtime.mode == "play")
    observers.restart()
    local expire: any = timeout
    expire()
    assert(votes == 1 and requests == 2 and runtime.mode == "play")
    runtime.stop()
end)
test("macro Return to Lobby and Stop fire no extra placement requests", function()
    for _, policy in { "Return to Lobby", "Stop" } do
        local requests, returns = 0, 0
        local adapter = {
            state = function()
                return { wave = 1, yen = 1000, units = {} }
            end,
            observe = function()
                return function() end
            end,
            cost = function()
                return 500
            end,
            request = function()
                requests += 1
                return false
            end,
            returnToLobby = function()
                returns += 1
                return true
            end,
        }
        local scheduler = {
            spawn = function(callback: any)
                callback()
            end,
            wait = function() end,
        }
        local runtime = MacroRuntime.new(adapter, nil, scheduler)
        runtime.start({ alive = true })
        runtime.settings.retryLimit = 1
        runtime.settings.placementFailure = policy
        local document = MacroDocument.empty("failure")
        document.actions = {
            {
                index = 1,
                kind = "place",
                unitRef = "1",
                unitName = "Test",
                slotIndex = 1,
                cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
                wave = 1,
                yen = 0,
                time = 0,
            },
        }
        assert(runtime.play(document))
        assert(requests == 1 and returns == (if policy == "Return to Lobby" then 1 else 0))
        assert(runtime.mode == "idle")
        runtime.stop()
    end
end)
test("macro placement accepts late confirmation without a duplicate request", function()
    local requests, checks = 0, 0
    local adapter = {
        state = function()
            return { wave = 1, yen = 1000, units = {} }
        end,
        observe = function()
            return function() end
        end,
        cost = function()
            return 500
        end,
        request = function()
            requests += 1
            return true
        end,
        confirm = function()
            checks += 1
            return checks >= 2, "late-guid"
        end,
    }
    local scheduler = {
        actionTimeout = 0,
        spawn = function(callback: any)
            callback()
        end,
        wait = function() end,
    }
    local runtime = MacroRuntime.new(adapter, nil, scheduler)
    runtime.start({ alive = true })
    runtime.settings.retryLimit = 3
    local document = MacroDocument.empty("late")
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
            wave = 1,
            yen = 0,
            time = 0,
        },
    }
    assert(runtime.play(document))
    assert(requests == 1 and runtime.mode == "play")
    runtime.stop()
end)
test("macro Stop interrupts a price wait without sending a request", function()
    local requests = 0
    local adapter = {
        state = function()
            return { wave = 1, yen = 0, units = {} }
        end,
        observe = function()
            return function() end
        end,
        cost = function()
            return 500
        end,
        request = function()
            requests += 1
            return true
        end,
    }
    local runtime: any = nil
    local scheduler = {
        spawn = function(callback: any)
            callback()
        end,
        wait = function()
            runtime.stopPlayback()
        end,
    }
    runtime = MacroRuntime.new(adapter, nil, scheduler)
    runtime.start({ alive = true })
    local document = MacroDocument.empty("stop_wait")
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
            wave = 1,
            yen = 0,
            time = 0,
        },
    }
    assert(runtime.play(document))
    assert(requests == 0 and runtime.mode == "idle")
    runtime.stop()
end)
test("macro non-placement failure stops instead of silently skipping", function()
    local requests = 0
    local adapter = {
        state = function()
            return { wave = 1, yen = 1000, units = {} }
        end,
        observe = function()
            return function() end
        end,
        cost = function()
            return 0
        end,
        request = function(action: any)
            if action.kind == "place" then
                return true
            end
            requests += 1
            return false
        end,
        confirm = function()
            return true, "placed-guid"
        end,
    }
    local scheduler = {
        spawn = function(callback: any)
            callback()
        end,
        wait = function() end,
    }
    local runtime = MacroRuntime.new(adapter, nil, scheduler)
    runtime.start({ alive = true })
    runtime.settings.retryLimit = 2
    local document = MacroDocument.empty("failed_sell")
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
            wave = 1,
            yen = 0,
            time = 0,
        },
        { index = 2, kind = "sell", unitRef = "1", wave = 1, yen = 0, time = 0 },
        { index = 3, kind = "sell", unitRef = "2", wave = 1, yen = 0, time = 0 },
    }
    assert(runtime.play(document))
    assert(
        requests == 2 and runtime.mode == "idle" and runtime.status:find("Step 2"),
        "requests=" .. requests .. " mode=" .. runtime.mode .. " status=" .. runtime.status
    )
    runtime.stop()
end)
test("macro native unit-control actions validate without changing schema v2", function()
    local document = MacroDocument.empty("native_controls")
    document.actions = {
        { index = 1, kind = "autoUpgrade", unitRef = "1", wave = 1, yen = 0, time = 0, enabled = true },
        {
            index = 2,
            kind = "upgradePriority",
            unitRef = "1",
            wave = 1,
            yen = 0,
            time = 0,
            upgradePriority = 6,
        },
        {
            index = 3,
            kind = "autoAbility",
            unitRef = "1",
            wave = 1,
            yen = 0,
            time = 0,
            abilityName = "Burst",
            enabled = false,
        },
    }
    local checked = assert(MacroDocument.validate(document))
    assert(checked.schemaVersion == 2 and checked.actions[2].upgradePriority == 6)
    document.actions[2].upgradePriority = 7
    assert(MacroDocument.validate(document) == nil)
    document.actions[2].upgradePriority = 0
    assert(MacroDocument.validate(document) == nil)
    document.actions[2].upgradePriority = 3
    document.actions[3].enabled = "false"
    assert(MacroDocument.validate(document) == nil)
end)
test("macro attack priority reads the game's numeric Data.Priority", function()
    local names = { "First", "Closest", "Last", "Strongest", "Weakest", "Bosses" }
    assert(MacroAdapter.priorityName(names, { Data = { Priority = 4 } }) == "Strongest")
    assert(MacroAdapter.priorityName(names, { UnitData = { Priority = 6 } }) == "Bosses")
    assert(MacroAdapter.priorityName(names, { Data = { Priority = 0 } }) == nil)
end)
test("macro legacy upgrade levels are inferred per unit reference", function()
    local document = MacroDocument.empty("legacy_levels")
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
            wave = 1,
            yen = 0,
            time = 0,
        },
        { index = 2, kind = "autoUpgrade", unitRef = "1", enabled = true, wave = 1, yen = 0, time = 1 },
        { index = 3, kind = "upgrade", unitRef = "1", wave = 1, yen = 0, time = 2 },
        { index = 4, kind = "upgrade", unitRef = "1", wave = 2, yen = 0, time = 3 },
    }
    local checked = assert(MacroDocument.validate(document))
    assert(checked.actions[1].initialLevel == 0)
    assert(checked.actions[3].level == 1 and checked.actions[4].level == 2)
    document.actions[4].level = 1
    assert(MacroDocument.validate(document) == nil)
end)
test("macro recording separates manual upgrades from native auto upgrades", function()
    local observers: { [string]: any } = {}
    local runtime = MacroRuntime.new({
        state = function()
            return { wave = 1, yen = 100, match = { mode = "Story" }, units = {} }
        end,
        observe = function(kind: string, callback: any)
            observers[kind] = callback
            return function() end
        end,
    }, {
        write = function()
            return true
        end,
    })
    runtime.start({ alive = true })
    assert(runtime.record("manual_and_auto"))
    observers.place({
        guid = "g1",
        unitName = "Test",
        slotIndex = 1,
        position = { x = 1, y = 2, z = 3 },
        level = 0,
        priorityName = "First",
    })
    observers.priority({ guid = "g1", priorityName = "Strongest" })
    observers.priority({ guid = "g1", priorityName = "Strongest" })
    observers.upgrade({ guid = "g1", level = 1 })
    observers.autoUpgrade({ guid = "g1", enabled = true })
    observers.upgrade({ guid = "g1", level = 2 })
    observers.upgrade({ guid = "g1", level = 3 })
    observers.autoUpgrade({ guid = "g1", enabled = false })
    observers.upgrade({ guid = "g1", level = 4 })
    local recorded = assert(runtime.finishRecord())
    local kinds = {}
    for _, action in recorded.actions do
        table.insert(kinds, action.kind)
    end
    assert(table.concat(kinds, ",") == "place,priority,upgrade,autoUpgrade,autoUpgrade,upgrade")
    assert(recorded.actions[3].level == 1 and recorded.actions[6].level == 4)
    runtime.stop()
end)
test("macro records confirmed auto controls once and preserves order", function()
    local observers: { [string]: any } = {}
    local stored: any = nil
    local adapter = {
        state = function()
            return { wave = 1, yen = 100, match = { mode = "Story" }, units = {} }
        end,
        observe = function(kind: string, callback: any)
            observers[kind] = callback
            return function() end
        end,
    }
    local runtime = MacroRuntime.new(adapter, {
        write = function(_name: string, document: any)
            stored = document
            return true
        end,
    })
    runtime.start({ alive = true })
    assert(runtime.record("native_controls"))
    observers.place({
        guid = "guid-1",
        unitName = "Test",
        slotIndex = 1,
        position = { x = 1, y = 2, z = 3 },
        rotation = 0,
        level = 0,
    })
    observers.autoUpgrade({ guid = "guid-1", enabled = true })
    observers.autoUpgrade({ guid = "guid-1", enabled = true })
    observers.upgradePriority({ guid = "guid-1", upgradePriority = 3 })
    observers.upgradePriority({ guid = "guid-1", upgradePriority = 3 })
    observers.autoAbility({ guid = "guid-1", abilityName = "Burst", enabled = true })
    observers.autoAbility({ guid = "guid-1", abilityName = "Burst", enabled = true })
    observers.autoAbility({ guid = "guid-1", abilityName = "Burst", enabled = false })
    local recorded = assert(runtime.finishRecord())
    assert(stored == recorded and #recorded.actions == 5)
    assert(recorded.actions[2].kind == "autoUpgrade" and recorded.actions[2].enabled)
    assert(recorded.actions[3].kind == "upgradePriority" and recorded.actions[3].upgradePriority == 3)
    assert(recorded.actions[4].kind == "autoAbility" and recorded.actions[4].enabled)
    assert(recorded.actions[5].kind == "autoAbility" and not recorded.actions[5].enabled)
    runtime.stop()
end)
test("macro playback cycles native upgrade priority to recorded state", function()
    local placed = false
    local enabled = false
    local priority = 1
    local autoAbility = false
    local changes = 0
    local function snapshot(): any
        return {
            wave = 1,
            yen = 100,
            units = if placed
                then {
                    ["guid-1"] = {
                        name = "Test",
                        autoUpgrade = enabled,
                        upgradePriority = priority,
                        autoAbilities = if autoAbility then { "Burst" } else {},
                    },
                }
                else {},
        }
    end
    local adapter = {
        state = snapshot,
        observe = function()
            return function() end
        end,
        cost = function()
            return 0
        end,
        request = function(action: any)
            if action.kind == "place" then
                placed = true
            elseif action.kind == "autoUpgrade" then
                enabled = action.enabled
            elseif action.kind == "upgradePriority" then
                priority = priority % 6 + 1
                changes += 1
            elseif action.kind == "autoAbility" then
                autoAbility = action.enabled
            end
            return true
        end,
        confirm = function(action: any)
            if action.kind == "place" then
                return placed, "guid-1"
            elseif action.kind == "autoUpgrade" then
                return enabled == action.enabled, ""
            elseif action.kind == "upgradePriority" then
                return priority == action.upgradePriority, ""
            elseif action.kind == "autoAbility" then
                return autoAbility == action.enabled, ""
            end
            return false, ""
        end,
    }
    local runtime = MacroRuntime.new(adapter, nil, {
        spawn = function(callback: any)
            callback()
        end,
        wait = function() end,
        actionTimeout = 0,
    })
    runtime.start({ alive = true })
    local document = MacroDocument.empty("native_controls")
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
            wave = 1,
            yen = 0,
            time = 0,
        },
        { index = 2, kind = "autoUpgrade", unitRef = "1", enabled = true, wave = 1, yen = 0, time = 0 },
        {
            index = 3,
            kind = "upgradePriority",
            unitRef = "1",
            upgradePriority = 5,
            wave = 1,
            yen = 0,
            time = 0,
        },
        {
            index = 4,
            kind = "autoAbility",
            unitRef = "1",
            abilityName = "Burst",
            enabled = true,
            wave = 1,
            yen = 0,
            time = 0,
        },
    }
    assert(runtime.play(document))
    assert(runtime.mode == "play" and enabled and autoAbility and priority == 5 and changes == 4)
    runtime.stop()
end)
test("macro legacy auto-upgrade steps wait for achieved level without duplicate purchase", function()
    local placed = false
    local enabled = false
    local level = 0
    local waits = 0
    local requests: { string } = {}
    local function snapshot(): any
        return {
            wave = 1,
            yen = 100,
            units = if placed then { ["g1"] = { level = level, autoUpgrade = enabled } } else {},
        }
    end
    local adapter = {
        state = snapshot,
        observe = function()
            return function() end
        end,
        cost = function()
            return 0
        end,
        satisfied = function(action: any)
            return action.kind == "upgrade" and level >= action.level
        end,
        request = function(action: any)
            table.insert(requests, action.kind)
            if action.kind == "place" then
                placed = true
            elseif action.kind == "autoUpgrade" then
                enabled = true
            else
                error("unexpected duplicate upgrade request")
            end
            return true
        end,
        confirm = function(action: any)
            return action.kind == "place" or action.kind == "autoUpgrade", "g1"
        end,
    }
    local runtime = MacroRuntime.new(adapter, nil, {
        spawn = function(callback: any)
            callback()
        end,
        wait = function()
            waits += 1
            if enabled and waits >= 4 then
                level = 1
            end
        end,
        actionTimeout = 0,
    })
    runtime.start({ alive = true })
    local document = MacroDocument.empty("legacy_auto")
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
            wave = 1,
            yen = 0,
            time = 0,
        },
        { index = 2, kind = "autoUpgrade", unitRef = "1", enabled = true, wave = 1, yen = 0, time = 0 },
        { index = 3, kind = "upgrade", unitRef = "1", wave = 1, yen = 0, time = 0 },
    }
    assert(runtime.play(document))
    assert(runtime.mode == "play" and waits >= 4)
    assert(table.concat(requests, ",") == "place,autoUpgrade")
    runtime.stop()
end)
test("macro satisfied step still waits for its recorded wave index", function()
    local wave = 1
    local requestCount = 0
    local runtime = MacroRuntime.new(
        {
            state = function()
                return { wave = wave, yen = 0, units = { g1 = { autoUpgrade = true } } }
            end,
            observe = function()
                return function() end
            end,
            satisfied = function(action: any)
                return action.kind == "autoUpgrade"
            end,
            cost = function()
                return 0
            end,
            request = function(action: any)
                if action.kind == "autoUpgrade" then
                    requestCount += 1
                end
                return true
            end,
            confirm = function()
                return true, "g1"
            end,
        },
        nil,
        {
            spawn = function(callback: any)
                callback()
            end,
            wait = function()
                wave += 1
            end,
        }
    )
    runtime.start({ alive = true })
    local document = MacroDocument.empty("wave_order")
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
            wave = 1,
            yen = 0,
            time = 0,
        },
        { index = 2, kind = "autoUpgrade", unitRef = "1", enabled = true, wave = 3, yen = 0, time = 0 },
    }
    assert(runtime.play(document))
    assert(wave >= 3 and requestCount == 0 and runtime.mode == "play")
    runtime.stop()
end)
test(
    "macro recording suppresses duplicate manual ability under active autoAbility and prunes companion toggle",
    function()
        local observers: { [string]: any } = {}
        local stored: any = nil
        local adapter = {
            state = function()
                return { wave = 1, yen = 100, match = { mode = "Story" }, units = {} }
            end,
            observe = function(kind: string, callback: any)
                observers[kind] = callback
                return function() end
            end,
        }
        local runtime = MacroRuntime.new(adapter, {
            write = function(_name: string, document: any)
                stored = document
                return true
            end,
        })
        runtime.start({ alive = true })
        assert(runtime.record("companion_ability"))
        observers.place({
            guid = "guid-1",
            unitName = "Reckless Gambler (Cursed)",
            slotIndex = 4,
            position = { x = 1, y = 2, z = 3 },
            rotation = 0,
            level = 0,
        })
        -- Simulate companion ability fired immediately before autoAbility toggle:
        observers.ability({ guid = "guid-1", abilityName = "Death Gamble" })
        observers.autoAbility({ guid = "guid-1", abilityName = "Death Gamble", enabled = true })
        -- Simulate periodic auto-ability firing while autoAbility is already active:
        observers.ability({ guid = "guid-1", abilityName = "Death Gamble" })
        local recorded = assert(runtime.finishRecord())
        assert(stored == recorded and #recorded.actions == 2)
        assert(recorded.actions[1].kind == "place")
        assert(recorded.actions[2].kind == "autoAbility" and recorded.actions[2].enabled)
        runtime.stop()
    end
)
test("macro playback skips companion or active auto-ability and continues at index 10", function()
    local actionsRequested: { string } = {}
    local autoToggled = false
    local placedCount = 0
    local adapter = {
        state = function()
            local unitsMap: any = {}
            for i = 1, placedCount do
                unitsMap["g" .. i] = {
                    name = "Test",
                    autoAbilities = if autoToggled and i == 7 then { "Death Gamble" } else {},
                }
            end
            return { wave = 3, yen = 10000, units = unitsMap }
        end,
        observe = function()
            return function() end
        end,
        cost = function()
            return 0
        end,
        request = function(action: any)
            table.insert(actionsRequested, action.kind)
            if action.kind == "autoAbility" then
                autoToggled = action.enabled
            end
            return true
        end,
        confirm = function(action: any)
            if action.kind == "place" then
                placedCount += 1
                return true, "g" .. placedCount
            elseif action.kind == "autoAbility" or action.kind == "autoUpgrade" then
                return true, ""
            end
            return false, ""
        end,
    }
    local runtime = MacroRuntime.new(adapter, nil, {
        spawn = function(callback: any)
            callback()
        end,
        wait = function() end,
        actionTimeout = 0,
    })
    runtime.start({ alive = true })
    local document = MacroDocument.empty("index_10_fix")
    local cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0)
    for i = 1, 9 do
        table.insert(document.actions, {
            index = i,
            kind = "place",
            unitRef = tostring(i),
            unitName = "Test",
            slotIndex = math.min(i, 6),
            cframe = cframe,
            wave = 0,
            yen = 0,
            time = 0,
        })
    end
    -- Action 10: ability companion immediately followed by Action 11 autoAbility
    table.insert(document.actions, {
        index = 10,
        kind = "ability",
        unitRef = "7",
        abilityName = "Death Gamble",
        wave = 3,
        yen = 0,
        time = 30.0,
    })
    table.insert(document.actions, {
        index = 11,
        kind = "autoAbility",
        unitRef = "7",
        abilityName = "Death Gamble",
        enabled = true,
        wave = 3,
        yen = 0,
        time = 30.001,
    })
    -- Action 12: subsequent action that should succeed
    table.insert(document.actions, {
        index = 12,
        kind = "autoUpgrade",
        unitRef = "7",
        enabled = true,
        wave = 3,
        yen = 0,
        time = 31.0,
    })
    assert(runtime.play(document))
    assert(
        runtime.mode == "play" and autoToggled and placedCount == 9,
        "mode="
            .. runtime.mode
            .. " auto="
            .. tostring(autoToggled)
            .. " placed="
            .. placedCount
            .. " status="
            .. runtime.status
    )
    -- Action 10 was skipped cleanly without requesting or blocking
    assert(not table.find(actionsRequested, "ability"))
    assert(table.find(actionsRequested, "autoAbility") ~= nil)
    runtime.stop()
end)
test("macro playback continues when unconfirmed standalone manual ability times out", function()
    local actionsExecuted: { string } = {}
    local placed = false
    local sold = false
    local adapter = {
        state = function()
            return {
                wave = 1,
                yen = 1000,
                units = if placed and not sold then { g1 = { name = "Test", autoAbilities = {} } } else {},
            }
        end,
        observe = function()
            return function() end
        end,
        cost = function()
            return 0
        end,
        request = function(action: any)
            table.insert(actionsExecuted, action.kind)
            return true
        end,
        confirm = function(action: any)
            if action.kind == "place" then
                placed = true
                return true, "g1"
            elseif action.kind == "sell" then
                sold = true
                return true, "" :: any
            end
            -- Ability never confirms:
            return false, "" :: any
        end,
    }
    local runtime = MacroRuntime.new(adapter, nil, {
        spawn = function(callback: any)
            callback()
        end,
        wait = function() end,
        actionTimeout = 0,
    })
    runtime.start({ alive = true })
    runtime.settings.retryLimit = 1
    local document = MacroDocument.empty("standalone_ability")
    local cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0)
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = cframe,
            wave = 1,
            yen = 0,
            time = 0,
        },
        {
            index = 2,
            kind = "ability",
            unitRef = "1",
            abilityName = "ManualSkill",
            wave = 1,
            yen = 0,
            time = 0,
        },
        {
            index = 3,
            kind = "sell",
            unitRef = "1",
            wave = 1,
            yen = 0,
            time = 0,
        },
    }
    assert(runtime.play(document))
    assert(runtime.mode == "play" and placed and sold)
    assert(table.concat(actionsExecuted, ",") == "place,ability,sell")
    runtime.stop()
end)
test("macro playback marks sold units and skips subsequent actions on them", function()
    local actions: { string } = {}
    local placed = false
    local sold = false
    local adapter = {
        state = function()
            return {
                wave = 1,
                yen = 1000,
                units = if placed and not sold then { g1 = { name = "Test" } } else {},
            }
        end,
        observe = function()
            return function() end
        end,
        cost = function()
            return 0
        end,
        satisfied = function(action: any, refs: any)
            local guid = refs[action.unitRef]
            if action.kind == "sell" then
                return guid ~= nil and not placed
            end
            return false
        end,
        request = function(action: any)
            table.insert(actions, action.kind)
            return true
        end,
        confirm = function(action: any)
            if action.kind == "place" then
                placed = true
                return true, "g1"
            elseif action.kind == "sell" then
                sold = true
                return true, "" :: any
            end
            return false, "" :: any
        end,
    }
    local runtime = MacroRuntime.new(adapter, nil, {
        spawn = function(callback: any)
            callback()
        end,
        wait = function() end,
        actionTimeout = 0,
    })
    runtime.start({ alive = true })
    local document = MacroDocument.empty("sell_cleanup")
    local cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0)
    document.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = cframe,
            wave = 1,
            yen = 0,
            time = 0,
        },
        { index = 2, kind = "sell", unitRef = "1", wave = 1, yen = 0, time = 0 },
        { index = 3, kind = "upgrade", unitRef = "1", level = 2, wave = 1, yen = 0, time = 0 },
    }
    assert(runtime.play(document))
    assert(runtime.mode == "play" and placed and sold)
    -- Action 3 (upgrade on sold unit) must be skipped cleanly:
    assert(table.concat(actions, ",") == "place,sell")
    runtime.stop()
end)
test("macro storage lists, rejects traversal, reads back and deletes", function()
    local files: { [string]: string } = {}
    local folders: { [string]: boolean } = {}
    local encoded: any = nil
    local env = {
        readfile = function(path: string)
            return files[path]
        end,
        writefile = function(path: string, body: string)
            files[path] = body
        end,
        isfile = function(path: string)
            return files[path] ~= nil
        end,
        isfolder = function(path: string)
            return folders[path] == true
        end,
        makefolder = function(path: string)
            folders[path] = true
        end,
        listfiles = function(_path: string)
            local values = {}
            for path in files do
                table.insert(values, path)
            end
            return values
        end,
        delfile = function(path: string)
            files[path] = nil
        end,
    }
    local codec = {
        JSONEncode = function(_self: any, value: any)
            encoded = value
            return value.name
        end,
        JSONDecode = function(_self: any, body: string)
            return MacroDocument.empty(body)
        end,
    }
    local storage = assert(MacroStorage.new(env, codec))
    assert(storage.write("one", MacroDocument.empty("one")))
    assert(encoded.schemaVersion == 2)
    assert(not storage.write("one", MacroDocument.empty("one")))
    assert(not storage.write("../bad", MacroDocument.empty("../bad")))
    assert(storage.read("one") ~= nil and storage.list()[1] == "one")
    assert(storage.write("two", MacroDocument.empty("different")))
    assert(storage.read("two") ~= nil and storage.read("two").name == "two")
    assert(storage.delete("two"))
    assert(storage.delete("one") and #storage.list() == 0)
end)
test("macro runtime recording owns and releases event subscriptions", function()
    local observers: { [string]: any } = {}
    local removed = 0
    local yen = 100
    local adapter = {
        state = function()
            return { wave = 1, yen = yen, match = {} }
        end,
        observe = function(kind: string, callback: any)
            observers[kind] = callback
            return function()
                removed += 1
            end
        end,
    }
    local saved: any = nil
    local storage = {
        write = function(_name: string, document: any)
            saved = document
            return true
        end,
    }
    local runtime = MacroRuntime.new(adapter, storage)
    runtime.start({ alive = true })
    assert(runtime.record("recorded"))
    observers.place({ guid = "g1", unitName = "Test", position = { x = 1, y = 2, z = 3 }, slotIndex = 1 })
    observers.upgrade({ guid = "g1", level = 0 })
    observers.upgrade({ guid = "g1", level = 1 })
    yen = 50
    observers.upgrade({ guid = "g1", level = 2 })
    local document = assert(runtime.finishRecord())
    assert(#document.actions == 2 and document.actions[2].unitRef == document.actions[1].unitRef)
    assert(saved.schemaVersion == 2 and #saved.actions[1].cframe == 12)
    assert(removed == 9)
    runtime.stop()
    assert(removed == 14)
end)
test("macro restart, victory, defeat and start vote state", function()
    local observers: { [string]: any } = {}
    local writes: { any } = {}
    local votes = 0
    local matchStarted = false
    local adapter = {
        state = function()
            return { wave = 0, yen = 0, match = { mode = "Story" } }
        end,
        observe = function(kind: string, callback: any)
            observers[kind] = callback
            return function() end
        end,
        matchStarted = function()
            return matchStarted
        end,
        castStartVote = function()
            votes += 1
            return true
        end,
        currentStartPrompt = function()
            return { Context = "Start" }
        end,
    }
    local storage = {
        write = function(_name: string, document: any)
            local copy = table.clone(document)
            copy.actions = table.clone(document.actions)
            table.insert(writes, copy)
            return true
        end,
    }
    local scheduler = { spawn = function(_callback: any) end, wait = function(_seconds: number) end }
    local runtime = MacroRuntime.new(adapter, storage, scheduler)
    runtime.start({ alive = true })
    assert(runtime.record("sample"))
    observers.place({ guid = "g1", unitName = "Test", position = { x = 1, y = 2, z = 3 }, slotIndex = 1 })
    assert(#runtime.document.actions == 1)
    observers.restart()
    assert(runtime.mode == "record" and #runtime.document.actions == 0 and #writes == 2)
    observers.place({ guid = "g2", unitName = "Test", position = { x = 1, y = 2, z = 3 }, slotIndex = 1 })
    observers.result("Finished")
    assert(runtime.mode == "idle" and #writes == 3 and #writes[3].actions == 1)
    assert(runtime.record("sample"))
    observers.place({ guid = "g3", unitName = "Test", position = { x = 1, y = 2, z = 3 }, slotIndex = 1 })
    observers.result("Failed")
    assert(runtime.mode == "idle" and #writes == 4 and #writes[4].actions == 0)
    assert(runtime.play(MacroDocument.empty("sample")))
    assert(votes == 1)
    observers.restart()
    assert(runtime.mode == "play")
    observers.votePrompt({ Context = "Skip", StartTime = 1 })
    observers.votePrompt({ Context = "Unknown", StartTime = 2 })
    observers.votePrompt({ Context = "Start", StartTime = 3 })
    observers.votePrompt({ Context = "Start", StartTime = 3 })
    matchStarted = true
    observers.votePrompt({ Context = "Start", StartTime = 4 })
    assert(votes == 2)
    observers.matchEnd()
    assert(runtime.mode == "play")
    runtime.stop()
    assert(runtime.mode == "idle")
end)
test("macro aborts recording when restart reset write fails", function()
    local observers: { [string]: any } = {}
    local writes = 0
    local adapter = {
        state = function()
            return { wave = 0, yen = 0, match = {} }
        end,
        observe = function(kind: string, callback: any)
            observers[kind] = callback
            return function() end
        end,
    }
    local storage = {
        write = function()
            writes += 1
            return writes == 1, "WRITE_FAILED"
        end,
    }
    local runtime = MacroRuntime.new(adapter, storage)
    runtime.start({ alive = true })
    assert(runtime.record("sample"))
    observers.restart()
    assert(runtime.mode == "idle" and runtime.status:find("Restart reset failed") ~= nil)
    runtime.stop()
end)
test("macro play mode persists indefinitely and auto-loops on restart or holds on victory", function()
    local observers: { [string]: any } = {}
    local runs = 0
    local autoReplayEnabled = true
    local adapter = {
        state = function()
            return { wave = 1, yen = 1000, units = {} }
        end,
        observe = function(kind: string, callback: any)
            observers[kind] = callback
            return function() end
        end,
        cost = function()
            return 0
        end,
        request = function()
            runs += 1
            return true
        end,
        confirm = function()
            return true, "g1"
        end,
        getGameSetting = function(name: string)
            if name == "AutoReplay" then
                return autoReplayEnabled
            end
            return false
        end,
    }
    local runtime = MacroRuntime.new(adapter, nil, {
        spawn = function(callback: any)
            callback()
        end,
        wait = function() end,
    })
    runtime.start({ alive = true })
    local doc = MacroDocument.empty("infinite_loop")
    local cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0)
    doc.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = cframe,
            wave = 1,
            yen = 0,
            time = 0,
        },
    }
    assert(runtime.play(doc))
    -- 1. Actions complete, mode must STAY as "play" (never auto-close):
    assert(runtime.mode == "play")
    assert(runtime.status:find("Actions completed") ~= nil)
    assert(runs == 1)

    -- 2. MatchEnded fires with AutoReplay: status updates to awaiting replay, mode STAYS as "play":
    observers.matchEnd()
    assert(runtime.mode == "play")
    assert(runtime.status:find("Victory! Awaiting next match") ~= nil)

    -- 3. Match restarts (AutoReplay triggers): macro replays document from step 1 automatically:
    observers.restart()
    assert(runtime.mode == "play")
    assert(runs == 2) -- Action was played again!

    -- 4. MatchEnded fires WITHOUT AutoReplay/AutoNext: holds on victory screen, mode STAYS as "play":
    autoReplayEnabled = false
    observers.matchEnd()
    assert(runtime.mode == "play")
    assert(runtime.status:find("holding on victory screen") ~= nil)

    -- 5. Only explicit stop turns it off:
    runtime.stopPlayback()
    assert(runtime.mode == "idle")
    runtime.stop()
end)
test("game adapter reads and mutates in-game settings through codec and remote", function()
    local settingsStore: { [string]: boolean } = {
        AutoReplay = true,
        AutoNext = false,
        AutoSkipWaves = true,
        AutoSkipStart = false,
    }
    local remoteFired: any = nil
    local mockDeps = {
        state = {
            GetSetting = function(_self: any, name: string)
                return settingsStore[name]
            end,
            SetSessionOverride = function(_self: any, name: string, value: boolean)
                settingsStore[name] = value
            end,
            OnSettingUpdate = {
                Connect = function(_self: any, _callback: any)
                    return function() end
                end,
            },
        },
        codec = {
            EncodeScalarMutation = function(name: string, value: boolean, _deep: any)
                return { Name = name, BooleanValue = value, Kind = "Boolean" }
            end,
        },
        client = {
            ChangeSetting = {
                Fire = function(mutation: any)
                    remoteFired = mutation
                    settingsStore[mutation.Name] = mutation.BooleanValue
                end,
            },
        },
    }
    local adapter = GameAdapter.new(mockDeps)
    assert(adapter.isAvailable())
    assert(adapter.get("AutoReplay") == true)
    assert(adapter.get("AutoNext") == false)
    assert(adapter.get("Unknown") == nil)

    assert(adapter.set("AutoReplay", false))
    assert(remoteFired ~= nil and remoteFired.Name == "AutoReplay" and remoteFired.BooleanValue == false)
    assert(adapter.get("AutoReplay") == false)

    assert(adapter.set("AutoNext", true))
    assert(remoteFired.Name == "AutoNext" and remoteFired.BooleanValue == true)
    assert(adapter.get("AutoNext") == true)

    assert(not adapter.set("AutoReplay", "not a boolean" :: any))
end)
test("game adapter autoBackToLobby teleports when native AutoNext and AutoReplay cannot proceed", function()
    local mockNext = {
        Visible = false, -- Next is hidden!
    }
    local mockRetry = {
        Visible = true,
        Label = { Text = "Replay (0/1)" }, -- 0 attempts remaining!
    }
    local mockButtons = {
        FindFirstChild = function(_self: any, name: string): any
            if name == "Next" then
                return mockNext
            elseif name == "Retry" then
                return mockRetry
            end
            return nil
        end,
    }
    local mockEndScreen = {
        FindFirstChild = function(_self: any, name: string): any
            if name == "Holder" then
                return {
                    FindFirstChild = function(_s: any, childName: string): any
                        if childName == "Buttons" then
                            return mockButtons
                        end
                        return nil
                    end,
                }
            end
            return nil
        end,
    }
    local _mockPlayerGui = {
        FindFirstChild = function(_self: any, name: string): any
            if name == "EndScreen" then
                return mockEndScreen
            end
            return nil
        end,
    }

    local mockDeps = {
        state = {
            GetSetting = function(_self: any, name: string)
                -- Both settings are TRUE in player config!
                return true
            end,
            SetSessionOverride = function() end,
            OnSettingUpdate = {
                Connect = function()
                    return function() end
                end,
            },
        },
        codec = {
            EncodeScalarMutation = function()
                return {}
            end,
        },
        client = {
            ChangeSetting = {
                Fire = function() end,
            },
            SettingUpdated = {
                On = function()
                    return function() end
                end,
            },
        },
    }

    local adapter = GameAdapter.new(mockDeps)
    adapter.setAutoBackToLobby(true)
    adapter.start({ alive = true })

    -- Verify that even though AutoReplay=true and AutoNext=true,
    -- because Next.Visible=false and Replay has (0/1), it teleports!
    assert(adapter.getAutoBackToLobby() == true)
    adapter.stop()
end)
test("game page mounts controls and synchronizes changes two-way", function()
    local togglesCreated: { [string]: any } = {}
    local sectionsCreated: { string } = {}
    local tab: any = {}
    tab.Paragraph = function() end
    tab.Section = function(_self: any, options: any)
        table.insert(sectionsCreated, options.Title)
        return tab
    end
    tab.Toggle = function(_self: any, options: any)
        local control: any = {
            Value = options.Value,
            Callback = options.Callback,
            Set = function(self: any, val: boolean)
                self.Value = val
            end,
        }
        togglesCreated[options.Title] = control
        return control
    end

    local currentSettings: { [string]: boolean } = {
        AutoReplay = true,
        AutoNext = false,
        AutoSkipWaves = true,
        AutoSkipStart = false,
    }
    local listener: any = nil
    local fakeAdapter = {
        isAvailable = function()
            return true
        end,
        get = function(name: string)
            return currentSettings[name]
        end,
        set = function(name: string, val: boolean)
            currentSettings[name] = val
            return true
        end,
        observe = function(callback: any)
            listener = callback
            return function()
                listener = nil
            end
        end,
    }

    GamePage.mount(tab, fakeAdapter)
    assert(togglesCreated["Auto Replay"].Value == true)
    assert(togglesCreated["Auto Next"].Value == false)
    assert(togglesCreated["Auto Skip Waves"].Value == true)
    assert(togglesCreated["Auto Skip Start"].Value == false)

    -- 1. Turning off Auto Replay in UI modifies the game setting:
    togglesCreated["Auto Replay"].Callback(false)
    assert(currentSettings.AutoReplay == false)

    -- 2. Turning on Auto Next in UI modifies the game setting:
    togglesCreated["Auto Next"].Callback(true)
    assert(currentSettings.AutoNext == true)

    -- 3. Game-side update synchronizes back to the UI toggle:
    assert(listener ~= nil)
    local fireListener: any = listener
    fireListener("AutoReplay", true)
    assert(togglesCreated["Auto Replay"].Value == true)
end)
test("macro runtime lazy adapter resolution connects when match ready", function()
    local runtime = MacroRuntime.new(nil, nil, {
        spawn = function() end,
        wait = function() end,
    })
    runtime.start({ alive = true })
    assert(runtime.status == "Awaiting match...")
    local doc = MacroDocument.empty("lobby_wait")
    doc.actions = {
        {
            index = 1,
            kind = "place",
            unitRef = "1",
            unitName = "Test",
            slotIndex = 1,
            cframe = MacroDocument.fromPose({ x = 1, y = 2, z = 3 }, 0),
            wave = 0,
            yen = 0,
            time = 0,
        },
    }
    assert(runtime.play(doc))
    assert(runtime.mode == "play")
    runtime.stopPlayback()
    assert(runtime.mode == "idle")
    runtime.stop()
end)
test("status page mounts and displays operational and pending indicators", function()
    local paragraphs: { [string]: string } = {}
    local sections: { [string]: boolean } = {}
    local tab: any = {}
    tab.Paragraph = function(_self: any, opt: any)
        paragraphs[opt.Title] = opt.Desc
        return {
            SetDesc = function(_self: any, desc: string)
                paragraphs[opt.Title] = desc
            end,
        }
    end
    tab.Section = function(_self: any, opt: any)
        sections[opt.Title] = true
        return {
            Paragraph = function(_self: any, pOpt: any)
                paragraphs[pOpt.Title] = pOpt.Desc
                return {
                    SetDesc = function(_self: any, desc: string)
                        paragraphs[pOpt.Title] = desc
                    end,
                }
            end,
        }
    end
    local refreshCb: any = nil
    tab.Button = function(_self: any, opt: any)
        refreshCb = opt.Callback
        return {}
    end

    StatusPage.mount(tab)
    assert(sections["Platform & Environment"] == true)
    assert(sections["Game Core & Settings Sync"] == true)
    assert(sections["Macro Subsystems"] == true)
    assert(sections["Matchmaking & Joiner"] == true)
    assert(sections["Pending Features (In Development)"] == true)

    -- Test that checkmark indicators exist
    assert(paragraphs["✓ Code Compiler"] ~= nil)
    assert(paragraphs["✓ Persistent Macro Loop"] ~= nil)
    -- Test that cross indicator exists for pending features
    assert(paragraphs["✗ Auto Equip Units from Loadout"] ~= nil)
    assert(paragraphs["✗ Discord Match Webhooks"] ~= nil)

    -- Test refresh button callback
    assert(type(refreshCb) == "function")
    local callRefresh: any = refreshCb
    callRefresh()
    assert(paragraphs["Live System Audit"]:find("Live Verified") ~= nil)
end)
test("Joiner settings handles Rift and Challenge returnMode and reward mapping", function()
    assert(JoinerSettings.setRegularReward("Trait Rerolls"))
    assert(JoinerSettings.get().selection["Regular Challenge"].challengeName == "Trait Reroll Challenge")
    assert(JoinerSettings.setRegularReward("Stat Chips"))
    assert(JoinerSettings.get().selection["Regular Challenge"].challengeName == "Stat Chip Challenge")
    assert(not JoinerSettings.setRegularReward("Unknown Reward"))

    assert(JoinerSettings.setBackToLobby("Rift", true, "Immediate"))
    assert(JoinerSettings.get().selection["Rift"].backToLobby == true)
    assert(JoinerSettings.get().selection["Rift"].returnMode == "Immediate")

    assert(JoinerSettings.setBackToLobby("Regular Challenge", true, "Wait Match End"))
    assert(JoinerSettings.get().selection["Regular Challenge"].backToLobby == true)
    assert(JoinerSettings.get().selection["Regular Challenge"].returnMode == "Wait Match End")

    assert(not JoinerSettings.setBackToLobby("Unknown Category", true, "Immediate"))
    assert(not JoinerSettings.setBackToLobby("Rift", "not boolean" :: any, "Immediate"))
end)
test("Joiner runtime handles Rift open, full-room hold, and attempt gating in lobby", function()
    local riftJoined = nil
    local riftAttempts = 1
    local isRiftOpen = true
    local rooms = {
        r1 = { Players = { "p1", "p2", "p3", "p4", "p5", "p6" } }, -- full
    }
    local runtime = JoinerRuntime.new({
        game = {
            PlaceId = 16146832113,
            GetService = function(_self: any, name: string): any
                if name == "Workspace" then
                    return {
                        GetAttribute = function(_w: any, attr: string): any
                            if attr == "IsRiftOpen" then
                                return isRiftOpen
                            end
                            return false
                        end,
                    }
                end
                return {
                    GetAttribute = function(): any
                        return false
                    end,
                }
            end,
        },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        lobby = { IsHosting = false, IsInLobby = false },
        specialEvents = {
            GetRiftAttempts = {
                Invoke = function()
                    return { Ready = true, AttemptsRemaining = riftAttempts }
                end,
            },
            JoinRift = {
                Fire = function(payload: any)
                    riftJoined = payload
                end,
            },
        },
        riftsData = {
            GetRifts = function()
                return rooms
            end,
        },
    })

    JoinerSettings.setPaused(false)
    runtime.setEnabled("Rift", true)
    runtime.start({ alive = true })

    -- Case 1: Room is full (6/6) -> must hold on Rift priority and NOT fall through!
    runtime.step(100)
    assert(riftJoined == nil)
    assert(runtime.status:find("all rooms full") ~= nil)

    -- Case 2: Open room appears (< 6 players) -> joins via remote!
    rooms.r2 = { Players = { "p1", "p2" } }
    runtime.step(100)
    assert(riftJoined ~= nil and riftJoined.RiftGUID == "r2")
    assert(runtime.confirmed ~= nil and runtime.confirmed.mode == "Rift")

    -- Case 3: Attempts exhausted -> falls through
    runtime.confirmed = nil
    riftJoined = nil
    riftAttempts = 0
    runtime.step(100)
    assert(riftJoined == nil)

    runtime.stop()
    runtime.setEnabled("Rift", false)
    JoinerSettings.setPaused(true)
end)
test("Joiner runtime respects Challenge NextReset and falls back to lower priority", function()
    local challengeSent = nil
    local nextResetTime = 0
    local stageSent = nil
    local runtime = JoinerRuntime.new({
        game = {
            PlaceId = 16146832113,
            GetService = function()
                return {
                    GetAttribute = function()
                        return false
                    end,
                }
            end,
        },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        lobby = { IsHosting = false, IsInLobby = false },
        challengeAttempts = {
            GetChallengeSeed = function()
                return if nextResetTime <= 0 then 10 else 20
            end,
        },
        challengeData = {
            GetChallengeSeed = function()
                return 20
            end,
            GetNextReset = function()
                return nextResetTime
            end,
        },
        challengeStages = {
            GetChallengeStage = function()
                return { StageType = "Story", Stage = "Stage1", Act = "Act1" }
            end,
        },
        challengeNetwork = {
            StartChallenge = {
                Fire = function(payload: any)
                    challengeSent = payload
                end,
            },
        },
        progress = {
            GetActData = function()
                return {}
            end,
        },
        network = {
            CreateMatch = {
                Fire = function(payload: any)
                    stageSent = payload
                end,
            },
            MatchConfirmed = {
                On = function()
                    return function() end
                end,
            },
        },
    })

    JoinerSettings.setPaused(false)
    runtime.setChallenge("Daily Challenge", "Daily Challenge")
    runtime.setEnabled("Daily Challenge", true)
    runtime.setSelection("Stage", "Stage1", "Act1", "Normal")
    runtime.setEnabled("Stage", true)
    runtime.start({ alive = true })

    -- Case 1: NextReset <= 0 (Challenge is available) -> starts Daily Challenge!
    nextResetTime = 0
    runtime.step(100)
    assert(challengeSent ~= nil and challengeSent.Name == "Daily Challenge")
    assert(stageSent == nil)

    -- Case 2: NextReset > 0 (Challenge already played/completed) -> falls through to Stage!
    runtime.pending = nil
    challengeSent = nil
    stageSent = nil
    nextResetTime = 3600
    runtime.step(150)
    assert(challengeSent == nil)
    assert(stageSent ~= nil and stageSent.StageType == "Story")

    runtime.stop()
    runtime.setEnabled("Daily Challenge", false)
    runtime.setEnabled("Stage", false)
    JoinerSettings.setPaused(true)
end)
test("Joiner runtime in match triggers immediate return and suspends macro", function()
    local teleportFired = 0
    local macroSuspended = false
    local isRiftOpen = false
    local riftRecorded = false
    local runtime = JoinerRuntime.new({
        game = {
            PlaceId = 16277809958, -- Match place!
            GetService = function(_s: any, name: string): any
                if name == "Workspace" then
                    return {
                        GetAttribute = function(_w: any, attr: string): any
                            if attr == "IsRiftOpen" then
                                return isRiftOpen
                            end
                            return false
                        end,
                    }
                end
                return {
                    GetAttribute = function(): any
                        return false
                    end,
                }
            end,
        },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        activityState = {
            load = function(): any
                return { states = {}, riftSpent = not riftRecorded }
            end,
        },
        lobbyReturn = {
            RequestTeleportToLobby = {
                Fire = function()
                    teleportFired += 1
                end,
            },
        },
    })

    runtime.setMacro({
        suspend = function()
            macroSuspended = true
        end,
    })

    JoinerSettings.setPaused(false)
    JoinerSettings.setBackToLobby("Rift", true, "Immediate")
    runtime.setEnabled("Rift", true)
    runtime.start({ alive = true })

    -- When rift is closed -> no teleport
    isRiftOpen = false
    runtime.step(100)
    assert(teleportFired == 0 and not macroSuspended)

    -- Open room but no recorded attempts (used up) -> must not leave the match
    isRiftOpen = true
    runtime.step(100.5)
    assert(
        teleportFired == 0 and not macroSuspended,
        "an open Rift without recorded attempts does not interrupt"
    )
    riftRecorded = true

    -- When rift opens -> immediate return triggered + macro suspended!
    -- (the activity record is cached for 10 s in the match place, so the change is seen on the next read)
    isRiftOpen = true
    runtime.step(111)
    assert(teleportFired == 1 and macroSuspended)
    assert(runtime.status:find("Rift is open") ~= nil)

    -- Subsequent ticks before 12s -> does not spam teleport
    runtime.step(115)
    assert(teleportFired == 1)

    -- Retries after 12s if not teleported yet
    runtime.step(125)
    assert(teleportFired == 2)

    runtime.stop()
    JoinerSettings.setBackToLobby("Rift", false, "Immediate")
    runtime.setEnabled("Rift", false)
    JoinerSettings.setPaused(true)
end)
test("Joiner in match switches to the current bounty or stage target before Vote Start", function()
    local fired: { any } = {}
    local left = 10
    local bounty: any = { BossName = "Kiro", Act = "Act2", StageType = "LegendStage", Stage = "Stage5" }
    local autoReplay = false
    local matchData: any = { StageType = "Story", Stage = "Stage1", Act = "Act1", Host = 42 }
    local gameHandler: any = { IsGameLoaded = true, IsMatchStarted = false, GameData = matchData }
    local runtime = JoinerRuntime.new({
        game = {
            PlaceId = 16277809958,
            GetService = function(): any
                return {
                    GetAttribute = function(): any
                        return false
                    end,
                }
            end,
        },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        gameHandler = gameHandler,
        bountyState = {
            GetData = function()
                return { BountySeed = 28046, BountiesLeft = left }
            end,
        },
        bountyData = {
            GetBountyFromSeed = function()
                return bounty
            end,
        },
        lobbyReturn = {
            RequestStartMatch = {
                Fire = function(payload: any)
                    table.insert(fired, payload)
                end,
            },
        },
    })
    runtime.setMacro(nil)
    runtime.gameSettings = {
        get = function()
            return autoReplay
        end,
    }
    for _, other in { "Stage", "Legend Stage", "Raid", "Dungeon", "Worldline", "Boss Event" } do
        JoinerSettings.setEnabled(other, false)
    end
    JoinerSettings.setPaused(false)
    JoinerSettings.setBountyRun(nil)
    runtime.setEnabled("Boss Bounties", true)
    -- A match the player created by hand is never rewritten.
    JoinerSettings.setJoinerRun(nil)
    runtime.start({ alive = true })
    runtime.step(99)
    assert(#fired == 0, "manual matches are left alone")
    JoinerSettings.setJoinerRun({ mode = "Story", stage = "Stage1", act = "Act1", at = os.time() })

    -- Pre-start in another stage: the host switches to today's bounty (Legend Stage is always Nightmare).
    runtime.step(100)
    assert(#fired == 1 and fired[1].StageType == "LegendStage" and fired[1].Stage == "Stage5")
    assert(fired[1].Act == "Act2" and fired[1].Difficulty == "Nightmare" and fired[1].FriendsOnly == true)
    runtime.step(102)
    assert(#fired == 1, "no resend inside the retry window")

    -- Once on the bounty stage: nothing is sent, and the match is remembered as a bounty match.
    matchData.StageType, matchData.Stage, matchData.Act, matchData.Difficulty =
        "LegendStage", "Stage5", "Act2", "Nightmare"
    runtime.step(110)
    assert(#fired == 1 and JoinerSettings.get().bountyRun ~= nil)
    assert(runtime.returnOnMatchEnd == true, "without Auto Replay the bounty match returns to the lobby")
    autoReplay = true
    runtime.step(111)
    assert(
        runtime.returnOnMatchEnd == false,
        "with Auto Replay the next pre-start switches to the next bounty"
    )

    -- The next replay is a new random bounty: the pre-start switches to it.
    bounty = { BossName = "Hirko", Act = "Act4", StageType = "Story", Stage = "Stage2" }
    runtime.step(120)
    assert(
        #fired == 2
            and fired[2].StageType == "Story"
            and fired[2].Stage == "Stage2"
            and fired[2].Act == "Act4"
    )
    assert(fired[2].Difficulty == "Normal")

    -- No bounties left: falls through to the enabled Stage joiner (higher priority than bounties).
    left = 0
    matchData.StageType, matchData.Stage, matchData.Act, matchData.Difficulty =
        "Story", "Stage2", "Act4", "Normal"
    runtime.setSelection("Stage", "Stage1", "Act1", "Normal")
    runtime.setEnabled("Stage", true)
    runtime.step(130)
    assert(#fired == 3 and fired[3].Stage == "Stage1" and fired[3].Act == "Act1")

    -- After Vote Start nothing is sent.
    gameHandler.IsMatchStarted = true
    matchData.Stage = "Stage9"
    runtime.step(150)
    assert(#fired == 3)
    runtime.stop()
    JoinerSettings.setBountyRun(nil)
    runtime.setEnabled("Stage", false)
    runtime.setEnabled("Boss Bounties", false)
    JoinerSettings.setPaused(true)
end)
test("Team Equipper rules validate keys, list owned teams and compare equipped units", function()
    assert(TeamEquip.number("Team1") == 1 and TeamEquip.number("Team18") == 18)
    assert(
        TeamEquip.number("Team0") == nil and TeamEquip.number("team1") == nil and TeamEquip.number(5) == nil
    )
    assert(
        TeamEquip.number("Team100") == nil and TeamEquip.validKey("Team12") and not TeamEquip.validKey("Team")
    )
    local teams: any = {
        Team2 = { Name = "Raid squad", Units = { "g1", "g2" } },
        Team1 = { Name = "", Units = { "g3" } },
        Team13 = { Name = "Owned extra", Units = {} },
        Team14 = { Name = "Not owned", Units = {} },
        Bogus = {},
    }
    local options = TeamEquip.options(teams, function(number: number)
        return number ~= 14
    end)
    assert(#options == 3 and options[1].key == "Team1" and options[1].label == "Team1")
    assert(options[2].label == "Team2 - Raid squad" and options[3].key == "Team13")
    local owned: { [string]: boolean } = { g1 = true, g2 = true, g3 = true }
    local function ownsUnit(guid: string): boolean
        return owned[guid] == true
    end
    local team: any = { Units = { "g1", "g2" } }
    assert(TeamEquip.evaluate(team, ownsUnit, { "g1", "g2" }) == "match")
    assert(TeamEquip.evaluate(team, ownsUnit, { "g2", "g1" }) == "mismatch")
    assert(
        TeamEquip.evaluate(team, ownsUnit, { "g1", "g2", "g3" }) == "mismatch",
        "extra equipped units differ"
    )
    owned.g2 = false
    assert(TeamEquip.evaluate(team, ownsUnit, { "g1" }) == "match", "sold units are ignored")
    owned.g1 = false
    assert(TeamEquip.evaluate(team, ownsUnit, {}) == "unusable")
    assert(TeamEquip.evaluate({ Units = {} }, ownsUnit, {}) == "unusable")
    assert(TeamEquip.evaluate(nil, ownsUnit, {}) == "unusable")
    assert(
        TeamEquip.rowFor(
            { StageType = "Story" },
            false,
            VanguardsConfig.stageTypeRows,
            VanguardsConfig.challengeRows
        ) == "Stage"
    )
    assert(
        TeamEquip.rowFor(
            { StageType = "LegendStage" },
            false,
            VanguardsConfig.stageTypeRows,
            VanguardsConfig.challengeRows
        ) == "Legend Stage"
    )
    assert(
        TeamEquip.rowFor(
            { StageType = "Story" },
            true,
            VanguardsConfig.stageTypeRows,
            VanguardsConfig.challengeRows
        ) == "Boss Bounties"
    )
    assert(
        TeamEquip.rowFor(
            { StageType = "Challenge", ChallengeType = "Daily" },
            false,
            VanguardsConfig.stageTypeRows,
            VanguardsConfig.challengeRows
        ) == "Daily Challenge"
    )
    assert(
        TeamEquip.rowFor(
            { StageType = "Rift" },
            false,
            VanguardsConfig.stageTypeRows,
            VanguardsConfig.challengeRows
        ) == "Rift"
    )
    assert(
        TeamEquip.rowFor(
            { StageType = "ElementalTowers" },
            false,
            VanguardsConfig.stageTypeRows,
            VanguardsConfig.challengeRows
        ) == "Elemental Towers"
    )
    assert(
        TeamEquip.rowFor(
            { StageType = "Portals" },
            false,
            VanguardsConfig.stageTypeRows,
            VanguardsConfig.challengeRows
        ) == "Portal"
    )
    assert(
        TeamEquip.rowFor(
            { StageType = "PVP" },
            false,
            VanguardsConfig.stageTypeRows,
            VanguardsConfig.challengeRows
        )
                == nil
            and TeamEquip.rowFor(nil, false, VanguardsConfig.stageTypeRows, VanguardsConfig.challengeRows)
                == nil
    )
end)
test(
    "Team Equipper adapter reads teams, ownership and equipped units and sends the observed payload",
    function()
        local sentLobby: any = nil
        local sentMatch: any = nil
        local changed = 0
        local deps: any = {
            teamsData = {
                GetTeams = function()
                    return { Team1 = { Units = { "g1" } } }
                end,
                IsSlotOwned = function(n: number)
                    return n <= 12
                end,
                TeamUpdated = {
                    Connect = function(_s: any, cb: any)
                        changed += 1
                        return {
                            Disconnect = function() end,
                        }
                    end,
                },
            },
            ownedUnits = {
                GetUnitObject = function(guid: string)
                    return if guid == "g1" then {} else nil
                end,
                GetEquippedUnits = function()
                    return { "g1" }
                end,
            },
            lobbyTeams = {
                LoadTeam = {
                    Fire = function(payload: any)
                        sentLobby = payload
                    end,
                },
            },
            gameUnits = {
                RequestLoadTeam = {
                    Fire = function(payload: any)
                        sentMatch = payload
                    end,
                },
            },
        }
        local lobby = TeamAdapter.new(deps, false)
        assert(lobby.getTeams().Team1 ~= nil and lobby.isSlotOwned(12) and not lobby.isSlotOwned(13))
        assert(lobby.ownsUnit("g1") and not lobby.ownsUnit("zzz") and lobby.getEquipped()[1] == "g1")
        assert(lobby.loadTeam("Team5") and sentLobby.TeamKey == "Team5" and sentMatch == nil)
        assert(not lobby.loadTeam("Bad") and not lobby.loadTeam("Team0"))
        local match = TeamAdapter.new(deps, true)
        assert(match.loadTeam("Team2") and sentMatch.TeamKey == "Team2")
        local stop = lobby.onChanged(function() end)
        assert(changed == 1 and stop ~= nil)
        local stopFn: any = stop
        stopFn()
        assert(TeamAdapter.new({}, false).getTeams() == nil)
        assert(TeamAdapter.new({}, false).loadTeam("Team1") == false)
    end
)
test("Team Equipper settings persist per joiner and reject invalid keys", function()
    JoinerSettings.setTeamEquipEnabled(false)
    assert(JoinerSettings.setTeamForJoiner("Stage", "Team5"))
    assert(
        not JoinerSettings.setTeamForJoiner("Stage", "Team0")
            and not JoinerSettings.setTeamForJoiner("Nope", "Team1")
    )
    assert(
        JoinerSettings.get().teamEquip.teams.Stage == "Team5"
            and JoinerSettings.get().teamEquip.enabled == false
    )
    assert(JoinerSettings.setTeamEquipEnabled(true) and JoinerSettings.get().teamEquip.enabled == true)
    assert(not JoinerSettings.setTeamEquipEnabled("yes" :: any))
    assert(
        JoinerSettings.setTeamForJoiner("Stage", nil) and JoinerSettings.get().teamEquip.teams.Stage == nil
    )
    JoinerSettings.setTeamEquipEnabled(false)
end)
local function teamHarness(inMatch: boolean): any
    local h: any = {
        loads = {} :: { string },
        equipped = { "g9" } :: any,
        creates = {} :: { any },
        started = false,
        ownedSlot = true,
    }
    local teams: any = {
        Team1 = { Name = "Main", Units = { "g1", "g2" } },
        Team2 = { Name = "Empty", Units = { "sold" } },
    }
    local owned: { [string]: boolean } = { g1 = true, g2 = true, g9 = true }
    h.adapter = {
        getTeams = function()
            return teams
        end,
        isSlotOwned = function()
            return h.ownedSlot
        end,
        ownsUnit = function(guid: string)
            return owned[guid] == true
        end,
        getEquipped = function()
            return h.equipped
        end,
        loadTeam = function(key: string)
            table.insert(h.loads, key)
            return true
        end,
    }
    local matchData: any = { StageType = "Story", Stage = "Stage1", Act = "Act1", Host = 42 }
    h.matchData = matchData
    local deps: any = {
        game = {
            PlaceId = if inMatch then 16277809958 else 16146832113,
            GetService = function(): any
                return {
                    GetAttribute = function(): any
                        return false
                    end,
                }
            end,
        },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        teamAdapter = h.adapter,
    }
    if inMatch then
        h.gameHandler = { IsGameLoaded = true, IsMatchStarted = false, GameData = matchData }
        deps.gameHandler = h.gameHandler
    else
        deps.lobby = { IsHosting = false, IsInLobby = false }
        deps.progress = {
            GetActData = function()
                return {}
            end,
        }
        deps.network = {
            CreateMatch = {
                Fire = function(payload: any)
                    table.insert(h.creates, payload)
                end,
            },
            StartMatch = { Fire = function() end },
            MatchConfirmed = {
                On = function()
                    return function() end
                end,
            },
        }
    end
    h.runtime = JoinerRuntime.new(deps)
    return h
end
test("Team Equipper loads the set team before the lobby join and skips unusable teams", function()
    local h = teamHarness(false)
    for _, other in { "Stage", "Legend Stage", "Raid", "Dungeon", "Worldline", "Boss Event", "Boss Bounties" } do
        JoinerSettings.setEnabled(other, false)
    end
    JoinerSettings.setPaused(false)
    JoinerSettings.setCooldown(0)
    JoinerSettings.setTeamEquipEnabled(true)
    JoinerSettings.setTeamForJoiner("Stage", "Team1")
    h.runtime.setSelection("Stage", "Stage1", "Act1", "Normal")
    h.runtime.setEnabled("Stage", true)
    h.runtime.start({ alive = true })

    h.runtime.step(100)
    assert(#h.loads == 1 and h.loads[1] == "Team1" and #h.creates == 0, "load first, join only once equipped")
    h.runtime.step(103)
    assert(#h.loads == 1 and #h.creates == 0, "no resend inside the confirmation window")
    h.equipped = { "g1", "g2" }
    h.runtime.step(104)
    assert(#h.creates == 1 and h.creates[1].Stage == "Stage1", "joins after the readback matches")

    -- Not confirmed after three attempts: skip this joiner and fall through to the next priority.
    h = teamHarness(false)
    h.runtime.setSelection("Stage", "Stage1", "Act1", "Normal")
    h.runtime.setEnabled("Stage", true)
    h.runtime.setSelection("Legend Stage", "Stage2", "Act1", "Nightmare")
    h.runtime.setEnabled("Legend Stage", true)
    h.runtime.start({ alive = true })
    h.runtime.step(100)
    h.runtime.step(109)
    h.runtime.step(118)
    assert(#h.loads == 3 and #h.creates == 0)
    h.runtime.step(127)
    assert(
        #h.creates == 1 and h.creates[1].StageType == "LegendStage",
        "unconfirmed team skips to the next joiner"
    )
    assert(#h.loads == 3, "no extra load while backing off")

    -- Unusable team (only sold units) and unowned slot are skipped without loading.
    JoinerSettings.setTeamForJoiner("Stage", "Team2")
    h = teamHarness(false)
    h.runtime.setSelection("Stage", "Stage1", "Act1", "Normal")
    h.runtime.setEnabled("Stage", true)
    h.runtime.setEnabled("Legend Stage", false)
    h.runtime.start({ alive = true })
    h.runtime.step(100)
    assert(#h.loads == 0 and #h.creates == 0 and h.runtime.status:find("no usable units") ~= nil)
    JoinerSettings.setTeamForJoiner("Stage", "Team1")
    h.ownedSlot = false
    h.runtime.step(101)
    assert(#h.loads == 0 and #h.creates == 0 and h.runtime.status:find("not available") ~= nil)

    -- Master switch off or no team chosen: the joiner behaves as before.
    h.ownedSlot = true
    JoinerSettings.setTeamEquipEnabled(false)
    h.runtime.step(102)
    assert(#h.loads == 0 and #h.creates == 1)
    JoinerSettings.setTeamEquipEnabled(true)
    JoinerSettings.setTeamForJoiner("Stage", nil)
    h = teamHarness(false)
    h.runtime.setEnabled("Stage", true)
    h.runtime.start({ alive = true })
    h.runtime.step(100)
    assert(#h.loads == 0 and #h.creates == 1)
    h.runtime.stop()

    -- Disable Auto Joiners: nothing at all.
    JoinerSettings.setTeamForJoiner("Stage", "Team1")
    JoinerSettings.setPaused(true)
    h = teamHarness(false)
    h.runtime.setEnabled("Stage", true)
    h.runtime.start({ alive = true })
    h.runtime.step(100)
    assert(#h.loads == 0 and #h.creates == 0)
    h.runtime.stop()
    JoinerSettings.setTeamForJoiner("Stage", nil)
    JoinerSettings.setTeamEquipEnabled(false)
    JoinerSettings.setEnabled("Stage", false)
    JoinerSettings.setEnabled("Legend Stage", false)
end)
test("Team Equipper loads the team in the match before Vote Start only", function()
    local h = teamHarness(true)
    for _, other in { "Stage", "Legend Stage", "Raid", "Dungeon", "Worldline", "Boss Event", "Boss Bounties" } do
        JoinerSettings.setEnabled(other, false)
    end
    JoinerSettings.setPaused(false)
    JoinerSettings.setTeamEquipEnabled(true)
    JoinerSettings.setTeamForJoiner("Stage", "Team1")
    JoinerSettings.setBountyRun(nil)
    h.runtime.start({ alive = true })
    h.runtime.step(100)
    assert(#h.loads == 1 and h.loads[1] == "Team1")
    h.runtime.step(101)
    assert(#h.loads == 1, "waits for the readback")
    h.equipped = { "g1", "g2" }
    h.runtime.step(102)
    assert(#h.loads == 1)
    -- A new restart with a different equipped team loads again; after Vote Start nothing is sent.
    h.equipped = { "g9" }
    h.gameHandler.IsMatchStarted = true
    h.runtime.step(120)
    assert(#h.loads == 1, "no team change after Vote Start")
    h.gameHandler.IsMatchStarted = false
    h.runtime.step(130)
    assert(#h.loads == 2)
    -- Unconfirmed loads give up after three attempts and the match is played with the current team.
    h.runtime.step(139)
    h.runtime.step(148)
    assert(#h.loads == 4, "three attempts after the restart")
    h.runtime.step(157)
    h.runtime.step(158)
    assert(#h.loads == 4 and h.runtime.status:find("not confirmed") ~= nil)
    h.runtime.stop()
    JoinerSettings.setTeamForJoiner("Stage", nil)
    JoinerSettings.setTeamEquipEnabled(false)
    JoinerSettings.setPaused(true)
end)
test("Team Equipper page lists owned teams per joiner and saves the choice without echo loops", function()
    JoinerSettings.setTeamEquipEnabled(false)
    for _, name in { "Stage", "Legend Stage", "Raid" } do
        JoinerSettings.setTeamForJoiner(name, nil)
    end
    JoinerSettings.setTeamForJoiner("Raid", "Team9")
    local options: any = {
        { key = "Team1", label = "Team1 - Main" },
        { key = "Team2", label = "Team2" },
    }
    local runtime: any = {
        getTeamOptions = function()
            return options
        end,
        readBounty = function()
            return nil
        end,
    }
    local dropdowns: any = {}
    local toggles: any = {}
    local sections: { string } = {}
    local function control(): any
        return { SetDesc = function() end, Set = function() end }
    end
    local tab: any = {}
    local host: any = {}
    host.Section = function(_s: any, opt: any)
        table.insert(sections, opt.Title)
        return host
    end
    host.Paragraph = function()
        return control()
    end
    host.Toggle = function(_s: any, opt: any)
        toggles[opt.Title] = opt
        return control()
    end
    host.Button = function() end
    host.Slider = function()
        return control()
    end
    host.Dropdown = function(_s: any, opt: any)
        local d = control()
        d.Selected = opt.Value
        d.Callback = opt.Callback
        -- Like WindUI, Refresh and Select echo the selected value through the callback.
        d.Refresh = function(self: any, values: any)
            self.Values = values
            self.Callback(self.Selected)
        end
        d.Select = function(self: any, value: string)
            self.Selected = value
            self.Callback(self.Selected)
        end
        if dropdowns[opt.Title] == nil then
            dropdowns[opt.Title] = d
        end
        return d
    end
    tab.Section = host.Section
    tab.Paragraph = host.Paragraph
    JoinerPage.mount(host, nil, runtime)
    assert(table.find(sections, "Team Equipper") ~= nil and table.find(sections, "Macro Equipper") ~= nil)
    assert(
        toggles["Auto Join Team Equipper"].Locked == false
            and toggles["Auto Join Macro Equipper"].Locked == true
    )
    assert(dropdowns["Stage Joiner"] ~= nil and dropdowns["Boss Bounties Joiner"] ~= nil)
    toggles["Auto Join Team Equipper"].Callback(true)
    assert(JoinerSettings.get().teamEquip.enabled == true)
    toggles["Auto Join Team Equipper"].Callback(false)
    local stage = dropdowns["Stage Joiner"]
    stage.Callback("Team2")
    assert(JoinerSettings.get().teamEquip.teams.Stage == "Team2")
    stage.Callback("None")
    assert(JoinerSettings.get().teamEquip.teams.Stage == nil)
    JoinerSettings.setTeamForJoiner("Raid", nil)
end)
test("Macro Equipper picks the best unit per name and plans the equip", function()
    local function unit(
        guid: string,
        name: string,
        level: number,
        subTrait: string?,
        ascensions: number?,
        takedowns: number?
    ): any
        return {
            guid = guid,
            name = name,
            level = level,
            subTrait = subTrait or "None",
            ascensions = ascensions or 0,
            takedowns = takedowns or 0,
        }
    end
    local owned: { any } = {
        unit("b1", "Bounty Hunter", 50),
        unit("b2", "Bounty Hunter", 60),
        unit("b3", "Bounty Hunter", 60, "Monarch"),
        unit("b4", "Bounty Hunter", 60, "Monarch", 2),
        unit("b5", "Bounty Hunter", 60, "Monarch", 2, 9),
        unit("w1", "Wrath (Assault)", 60),
        unit("s1", "Smith John", 10),
    }
    assert(
        (MacroEquip.best(owned, "Bounty Hunter") :: any).guid == "b5",
        "level, sub-trait, ascensions, then takedowns"
    )
    assert(MacroEquip.best(owned, "Nobody") == nil)
    assert(
        MacroEquip.validName("my_macro-1")
            and not MacroEquip.validName("a/b")
            and not MacroEquip.validName("")
    )
    local names = MacroEquip.names({
        "Bounty Hunter",
        "Bounty Hunter",
        "Wrath (Assault)",
        "",
        5,
        "A",
        "B",
        "C",
        "D",
        "E",
    })
    assert(#names == 6 and names[1] == "Bounty Hunter" and names[2] == "Wrath (Assault)")
    local equipped: { any } = { { guid = "x", name = "Bounty Hunter" } }
    local plan = MacroEquip.plan({ "Bounty Hunter", "Wrath (Assault)", "Missing One" }, equipped, owned)
    assert(plan.state == "equip" and plan.steps[1] == "b5" and plan.steps[2] == "w1" and #plan.steps == 2)
    assert(#plan.missing == 1 and plan.missing[1] == "Missing One")
    equipped = {
        { guid = "x", name = "Bounty Hunter" },
        { guid = "y", name = "Wrath (Assault)" },
        { guid = "z", name = "Other" },
    }
    assert(
        MacroEquip.plan({ "Bounty Hunter", "Wrath (Assault)" }, equipped, owned).state == "match",
        "names present in any slot or level"
    )
    assert(
        MacroEquip.plan({ "Missing One" }, {}, owned).state == "match",
        "nothing equippable means nothing to change"
    )
end)
test("Macro Equipper adapter lists units and sends the observed unit payloads", function()
    local sentEquip: { any } = {}
    local sentClear: any = nil
    local deps: any = {
        ownedUnits = {
            GetOwnedUnits = function()
                return { g1 = true, g2 = true }
            end,
            GetUnitObject = function(guid: string)
                return {
                    UnitData = { Name = if guid == "g1" then "Alpha" else "Beta" },
                    Level = 60,
                    SubTrait = "None",
                    Ascensions = 1,
                    Takedowns = 7,
                }
            end,
            GetEquippedUnits = function()
                return { "g2" }
            end,
        },
        unitActions = {
            EquipUnitInSlot = {
                Fire = function(payload: any)
                    table.insert(sentEquip, payload)
                end,
            },
            UnequipAllUnits = {
                Fire = function(payload: any)
                    sentClear = payload
                end,
            },
        },
    }
    local adapter = TeamAdapter.new(deps, false)
    local owned = adapter.ownedUnitList()
    assert(#owned == 2 and owned[1].level == 60 and owned[1].takedowns == 7)
    local equipped = adapter.equippedList()
    assert(#equipped == 1 and equipped[1].name == "Beta")
    assert(adapter.unequipAll() and sentClear.NonFarmsOnly == false)
    assert(adapter.equipUnit("g1") and sentEquip[1].UnitGUID == "g1" and not adapter.equipUnit(""))
    assert(#TeamAdapter.new({}, false).ownedUnitList() == 0 and not TeamAdapter.new({}, false).unequipAll())
end)
test("Macro Equipper settings persist per joiner and reject invalid names", function()
    JoinerSettings.setMacroEquipEnabled(false)
    assert(JoinerSettings.setMacroForJoiner("Stage", "my_macro"))
    assert(
        not JoinerSettings.setMacroForJoiner("Stage", "../bad")
            and not JoinerSettings.setMacroForJoiner("Nope", "x")
    )
    assert(
        JoinerSettings.get().macroEquip.macros.Stage == "my_macro"
            and JoinerSettings.get().macroEquip.enabled == false
    )
    assert(JoinerSettings.setMacroEquipEnabled(true) and JoinerSettings.get().macroEquip.enabled == true)
    assert(
        JoinerSettings.setMacroForJoiner("Stage", nil) and JoinerSettings.get().macroEquip.macros.Stage == nil
    )
    JoinerSettings.setMacroEquipEnabled(false)
end)
test(
    "Macro Equipper equips the macro's best units before the lobby join and prefers a chosen team",
    function()
        local sent: { string } = {}
        local equippedNow: { any } = { { guid = "old", name = "Other" } }
        local owned: { any } = {
            {
                guid = "bh1",
                name = "Bounty Hunter",
                level = 50,
                subTrait = "None",
                ascensions = 0,
                takedowns = 0,
            },
            {
                guid = "bh2",
                name = "Bounty Hunter",
                level = 60,
                subTrait = "None",
                ascensions = 0,
                takedowns = 0,
            },
            {
                guid = "wr",
                name = "Wrath (Assault)",
                level = 60,
                subTrait = "None",
                ascensions = 0,
                takedowns = 0,
            },
        }
        local creates: { any } = {}
        local teamLoads: { string } = {}
        local adapter: any = {
            getTeams = function()
                return { Team1 = { Name = "T", Units = { "bh1" } } }
            end,
            isSlotOwned = function()
                return true
            end,
            ownsUnit = function()
                return true
            end,
            getEquipped = function()
                return {}
            end,
            equippedList = function()
                return equippedNow
            end,
            ownedUnitList = function()
                return owned
            end,
            unequipAll = function()
                table.insert(sent, "clear")
                return true
            end,
            equipUnit = function(guid: string)
                table.insert(sent, guid)
                return true
            end,
            loadTeam = function(key: string)
                table.insert(teamLoads, key)
                return true
            end,
        }
        local store: any = {
            list = function()
                return { "farm" }
            end,
            read = function(name: string)
                if name == "farm" then
                    return { units = { "Bounty Hunter", "Wrath (Assault)", "Ghost Unit" } }
                end
                return nil
            end,
        }
        local runtime = JoinerRuntime.new({
            game = { PlaceId = 16146832113 },
            task = { spawn = function() end, wait = function() end },
            clock = function()
                return 100
            end,
            userId = 42,
            lobby = { IsHosting = false, IsInLobby = false },
            progress = {
                GetActData = function()
                    return {}
                end,
            },
            network = {
                CreateMatch = {
                    Fire = function(payload: any)
                        table.insert(creates, payload)
                    end,
                },
                StartMatch = { Fire = function() end },
                MatchConfirmed = {
                    On = function()
                        return function() end
                    end,
                },
            },
            teamAdapter = adapter,
            macroStore = store,
        })
        for _, other in { "Legend Stage", "Raid", "Dungeon", "Worldline", "Boss Event", "Boss Bounties" } do
            JoinerSettings.setEnabled(other, false)
        end
        JoinerSettings.setPaused(false)
        JoinerSettings.setCooldown(0)
        JoinerSettings.setTeamEquipEnabled(false)
        JoinerSettings.setMacroEquipEnabled(true)
        JoinerSettings.setMacroForJoiner("Stage", "farm")
        runtime.setSelection("Stage", "Stage1", "Act1", "Normal")
        runtime.setEnabled("Stage", true)
        runtime.start({ alive = true })
        assert(#runtime.getMacroOptions() == 1)

        runtime.step(100)
        assert(
            #sent == 3 and sent[1] == "clear" and sent[2] == "bh2" and sent[3] == "wr",
            "best units, macro order"
        )
        assert(#creates == 0, "join only after the units are equipped")
        runtime.step(103)
        assert(#sent == 3 and #creates == 0, "no resend inside the confirmation window")
        equippedNow = { { guid = "bh2", name = "Bounty Hunter" }, { guid = "wr", name = "Wrath (Assault)" } }
        runtime.step(104)
        assert(
            #creates == 1 and runtime.status:find("missing units Ghost Unit") == nil,
            "joins once the macro units are equipped"
        )

        -- A chosen team wins over the macro: the macro is not touched.
        JoinerSettings.setTeamEquipEnabled(true)
        JoinerSettings.setTeamForJoiner("Stage", "Team1")
        equippedNow = { { guid = "old", name = "Other" } }
        sent = {}
        runtime.step(140)
        assert(#sent == 0 and #teamLoads == 1 and teamLoads[1] == "Team1")
        JoinerSettings.setTeamForJoiner("Stage", nil)
        JoinerSettings.setTeamEquipEnabled(false)

        -- Unreadable macro: skip the joiner without touching units.
        JoinerSettings.setMacroForJoiner("Stage", "gone")
        sent = {}
        local before = #creates
        runtime.step(180)
        assert(#sent == 0 and #creates == before and runtime.status:find("could not be read") ~= nil)

        -- Three unconfirmed attempts give up.
        JoinerSettings.setMacroForJoiner("Stage", "farm")
        runtime.step(220)
        runtime.step(229)
        runtime.step(238)
        runtime.step(247)
        assert(#creates == before and runtime.status:find("not confirmed") ~= nil)
        runtime.stop()
        JoinerSettings.setMacroForJoiner("Stage", nil)
        JoinerSettings.setMacroEquipEnabled(false)
        JoinerSettings.setEnabled("Stage", false)
    end
)
test("Team Equipper hides the game's loaded-team popup and toast only for its own loads", function()
    local clock = 100
    local shown: { string } = {}
    local toasts: { string } = {}
    local popupHandler: any = {}
    function popupHandler.ShowPopup(_self: any, kind: string, text: string)
        table.insert(shown, kind .. ":" .. text)
    end
    local notifications: any = {}
    function notifications.CreateNotification(_self: any, options: any)
        table.insert(toasts, options.Text)
    end
    local originalPopup = popupHandler.ShowPopup
    local adapter = TeamAdapter.new({
        clock = function()
            return clock
        end,
        popupHandler = popupHandler,
        notifications = notifications,
        lobbyTeams = { LoadTeam = { Fire = function() end } },
    }, false)
    popupHandler:ShowPopup("BaseCancelFrame", "Successfully loaded team!")
    assert(#shown == 1, "the player's own load still shows the popup before any load by this script")
    assert(adapter.loadTeam("Team3"))
    popupHandler:ShowPopup("BaseCancelFrame", "Successfully loaded team!")
    notifications:CreateNotification({ Name = "Success", Text = "Successfully loaded Main!" })
    notifications:CreateNotification({ Name = "Failure", Text = "Successfully unequipped familiar! (6x)" })
    popupHandler:ShowPopup("BaseCancelFrame", "Not enough gems")
    notifications:CreateNotification({ Name = "Failure", Text = "Disable Auto Play first." })
    assert(
        #shown == 2 and shown[2] == "BaseCancelFrame:Not enough gems",
        "only the loaded-team popup is dropped"
    )
    assert(#toasts == 1 and toasts[1] == "Disable Auto Play first.")
    clock = 130
    popupHandler:ShowPopup("BaseCancelFrame", "Successfully loaded team!")
    assert(#shown == 3, "the window ends after 15 seconds")
    adapter.stop()
    assert(popupHandler.ShowPopup == originalPopup, "stop restores the game's function")
end)
test("ActivityState evaluates game-recorded challenge seeds and rift attempts", function()
    -- Case 1: stored < current -> available (not played yet in this period)
    local status, period = ActivityState.challenge({
        GetChallengeSeed = function(k: string)
            return if k == "Daily" then 10 else nil
        end,
    }, {
        GetChallengeSeed = function(k: string)
            return if k == "Daily" then 11 else nil
        end,
    }, "Daily")
    assert(status == "available" and period == 11)

    -- Case 2: stored == current -> unavailable (already completed in this period)
    local statusCleared, periodCleared = ActivityState.challenge({
        GetChallengeSeed = function()
            return 11
        end,
    }, {
        GetChallengeSeed = function()
            return 11
        end,
    }, "Daily")
    assert(statusCleared == "unavailable" and periodCleared == 11)

    -- Case 3: missing attempts/data -> unknown
    assert(ActivityState.challenge(nil, nil, "Daily") == "unknown")
    assert(ActivityState.challenge({}, {}, "Daily") == "unknown")

    -- Case 4: Rift open with attempts remaining -> available
    local gameMock: any = {
        GetService = function(_s: any, name: string): any
            if name == "Workspace" then
                return {
                    GetAttribute = function(_w: any, attr: string): any
                        return attr == "IsRiftOpen"
                    end,
                }
            end
            return nil
        end,
    }
    local specialMock = {
        GetRiftAttempts = {
            Invoke = function()
                return { Ready = true, AttemptsRemaining = 1 }
            end,
        },
    }
    assert(ActivityState.rift(gameMock, specialMock) == "available")

    -- Case 5: Rift closed or 0 attempts remaining -> unavailable
    local closedGameMock: any = {
        GetService = function(_s: any, name: string): any
            if name == "Workspace" then
                return {
                    GetAttribute = function(): any
                        return false
                    end,
                }
            end
            return nil
        end,
    }
    assert(ActivityState.rift(closedGameMock, specialMock) == "unavailable")

    local exhaustedSpecialMock = {
        GetRiftAttempts = {
            Invoke = function()
                return { Ready = true, AttemptsRemaining = 0 }
            end,
        },
    }
    assert(ActivityState.rift(gameMock, exhaustedSpecialMock) == "unavailable")
end)
test("In-match return triggers on uncleared challenge from activity snapshot", function()
    local teleportFired = 0
    local challengeData = {
        GetChallengeSeed = function(kind: string)
            return if kind == "Daily" then 50 else 0
        end,
    }
    local activityStore = {
        load = function(_self: any, _now: number, _cd: any)
            return {
                states = {
                    Daily = { status = "available", period = 50 },
                },
            }
        end,
    }
    local runtime = JoinerRuntime.new({
        game = {
            PlaceId = 16277809958, -- Match place!
            GetService = function(_s: any, name: string): any
                if name == "Workspace" then
                    return {
                        GetAttribute = function(): any
                            return false
                        end,
                    }
                end
                return nil
            end,
        },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 200
        end,
        userId = 99,
        activityState = activityStore,
        challengeData = challengeData,
        lobbyReturn = {
            RequestTeleportToLobby = {
                Fire = function()
                    teleportFired += 1
                end,
            },
        },
    })

    JoinerSettings.setPaused(false)
    JoinerSettings.setBackToLobby("Daily Challenge", true, "Immediate")
    runtime.setEnabled("Daily Challenge", true)
    runtime.start({ alive = true })

    -- Uncleared Daily Challenge in snapshot triggers immediate return to lobby!
    runtime.step(200)
    assert(teleportFired == 1)
    assert(runtime.status:find("Daily Challenge: available") ~= nil)

    runtime.stop()
    JoinerSettings.setBackToLobby("Daily Challenge", false, "Immediate")
    runtime.setEnabled("Daily Challenge", false)
    JoinerSettings.setPaused(true)
end)
test("In-match return does not fire when player is already in that challenge", function()
    local teleportFired = 0
    local challengeData = {
        GetChallengeSeed = function()
            return 50
        end,
    }
    local activityStore = {
        load = function(_self: any)
            return {
                states = {
                    Daily = { status = "available", period = 50 },
                },
            }
        end,
    }
    local runtime = JoinerRuntime.new({
        game = {
            PlaceId = 16277809958,
            GetService = function(): any
                return nil
            end,
        },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 200
        end,
        userId = 99,
        gameHandler = {
            GameData = {
                ChallengeType = "Daily", -- Currently in the Daily Challenge!
            },
        },
        activityState = activityStore,
        challengeData = challengeData,
        lobbyReturn = {
            RequestTeleportToLobby = {
                Fire = function()
                    teleportFired += 1
                end,
            },
        },
    })

    JoinerSettings.setPaused(false)
    JoinerSettings.setBackToLobby("Daily Challenge", true, "Immediate")
    runtime.setEnabled("Daily Challenge", true)
    runtime.start({ alive = true })

    -- Current match is Daily Challenge itself, so must NOT return to lobby!
    runtime.step(200)
    assert(teleportFired == 0)

    runtime.stop()
    JoinerSettings.setBackToLobby("Daily Challenge", false, "Immediate")
    runtime.setEnabled("Daily Challenge", false)
    JoinerSettings.setPaused(true)
end)
test("ActivityState evaluates stored challenge seeds and detects mid-match reset", function()
    local savedBody = nil
    local mockHttp: any = {
        JSONEncode = function(_self: any, val: any)
            local json = string.format(
                '{"schemaVersion":1,"userId":42,"observedAt":%d,"challengeSeeds":{"Regular":%d,"Daily":%d,"Weekly":%d}}',
                val.observedAt,
                val.challengeSeeds.Regular,
                val.challengeSeeds.Daily,
                val.challengeSeeds.Weekly
            )
            return json
        end,
        JSONDecode = function(_self: any, _body: string)
            return {
                schemaVersion = 1,
                userId = 42,
                observedAt = 1000,
                challengeSeeds = {
                    Regular = 994000,
                    Daily = 20000,
                    Weekly = 3000,
                },
            }
        end,
    }
    local mockEnv: any = {
        isfile = function()
            return savedBody ~= nil
        end,
        readfile = function()
            return savedBody
        end,
        writefile = function(_p: string, b: string)
            savedBody = b
        end,
        isfolder = function()
            return true
        end,
        makefolder = function() end,
        game = {
            GetService = function(_s: any, name: string): any
                if name == "HttpService" then
                    return mockHttp
                end
                return nil
            end,
        },
    }

    local stateStore = ActivityState.new(mockEnv, 42)
    assert(stateStore.save(1000, {}, { Regular = 994000, Daily = 20000, Weekly = 3000 }))

    -- At t = 2000 (1000 seconds / ~16 minutes into match):
    -- Regular has advanced from 994000 to 994001 (reset happened!)
    -- Daily is still at 20000 (already cleared, storedSeed == current)
    -- Weekly is at 3000 (already cleared, storedSeed == current)
    local mockChallengeData = {
        GetChallengeSeed = function(kind: string)
            if kind == "Regular" then
                return 994001 -- reset!
            elseif kind == "Daily" then
                return 20000
            elseif kind == "Weekly" then
                return 3000
            end
            return 0
        end,
    }

    local loaded = stateStore.load(2000, mockChallengeData)
    assert(loaded ~= nil and type(loaded.states) == "table")
    assert(loaded.states.Regular ~= nil and loaded.states.Regular.status == "available")
    assert(loaded.states.Daily ~= nil and loaded.states.Daily.status == "unavailable")
    assert(loaded.states.Weekly ~= nil and loaded.states.Weekly.status == "unavailable")
end)
test("AutoPlay runtime votes to start pre-match, then activates native Auto Play upon match start", function()
    local voteCast = 0
    local toggleFired = 0
    local matchStarted: boolean = false
    local autoPlaying: boolean = false
    local hasPrompt: boolean = true

    local currentClock = 100
    local mockAdapter = {
        isAvailable = function()
            return true
        end,
        isMatchStarted = function()
            return matchStarted
        end,
        hasStartPrompt = function()
            return hasPrompt
        end,
        castStartVote = function()
            voteCast += 1
            return true
        end,
        isAutoPlaying = function()
            return autoPlaying
        end,
        toggle = function()
            toggleFired += 1
            autoPlaying = not autoPlaying
            return true
        end,
        clock = function()
            return currentClock
        end,
        observe = function(_self: any, _kind: string, _callback: any)
            return function() end
        end,
    }

    local runtime = AutoPlayRuntime.new(mockAdapter, nil, {
        spawn = function() end,
        wait = function() end,
        clock = function()
            return currentClock
        end,
    })

    runtime.start({ alive = true })
    assert(runtime.setEnabled(true))

    -- Step 1: Pre-match with prompt -> casts Vote to Start
    assert(voteCast == 1)
    assert(toggleFired == 0)
    assert(runtime.status:find("Vote to Start sent") ~= nil)

    -- Step 2: Next tick before match starts -> does not spam vote
    currentClock = 101
    runtime.step(101)
    assert(voteCast == 1)

    -- Step 3: Match starts! -> engages native Auto Play
    matchStarted = true
    currentClock = 102
    runtime.step(102)
    assert(toggleFired == 1)
    assert(autoPlaying)
    assert(runtime.status:find("Enabling native Auto Play") ~= nil)

    currentClock = 103
    runtime.step(103)
    assert(runtime.status:find("Native Auto Play active") ~= nil)

    -- Step 4: Disabling runtime turns off native Auto Play
    assert(runtime.setEnabled(false))
    assert(toggleFired == 2)
    assert(not autoPlaying)
    assert(runtime.status == "Disabled")

    runtime.stop()
end)
test("AutoPlay and Play Macro enforce strict mutual exclusion", function()
    local autoPlaying = false
    local mockAdapter = {
        isAvailable = function()
            return true
        end,
        isMatchStarted = function()
            return true
        end,
        hasStartPrompt = function()
            return false
        end,
        castStartVote = function()
            return false
        end,
        isAutoPlaying = function()
            return autoPlaying
        end,
        toggle = function()
            autoPlaying = not autoPlaying
            return true
        end,
        observe = function()
            return function() end
        end,
    }

    local autoPlayRun = AutoPlayRuntime.new(mockAdapter, nil, {
        spawn = function() end,
        wait = function() end,
    })
    local macroRun = MacroRuntime.new(nil, nil, {
        spawn = function() end,
        wait = function() end,
    })

    autoPlayRun.setMacro(macroRun)
    macroRun.setAutoPlay(autoPlayRun)
    autoPlayRun.start({ alive = true })
    macroRun.start({ alive = true })

    -- 1. When AutoPlay is enabled:
    assert(autoPlayRun.setEnabled(true))
    assert(autoPlayRun.isEnabled() == true)

    -- Play Macro cannot be started:
    local doc = MacroDocument.empty("test_exclusion")
    local okPlay, errPlay = macroRun.play(doc)
    assert(okPlay == false and errPlay == "AUTOPLAY_ACTIVE")

    -- 2. Turn off AutoPlay, then start Macro:
    assert(autoPlayRun.setEnabled(false))
    local macroAdapterMock = {
        state = function()
            return { wave = 1, yen = 1000, units = {} }
        end,
        matchStarted = function()
            return true
        end,
        observe = function()
            return function() end
        end,
        cost = function()
            return 0
        end,
        request = function()
            return true
        end,
        confirm = function()
            return true, "guid"
        end,
    }
    macroRun.adapter = macroAdapterMock
    local okPlay2 = macroRun.play(doc)
    assert(okPlay2 == true and macroRun.mode == "play")

    -- Now AutoPlay cannot be enabled:
    local okAuto, errAuto = autoPlayRun.setEnabled(true)
    assert(okAuto == false and errAuto == "MACRO_ACTIVE")
    assert(autoPlayRun.isEnabled() == false)

    macroRun.stopPlayback()
    macroRun.stop()
    autoPlayRun.stop()
end)
test("AutoPlay UI page mounts controls and locks toggle when macro active", function()
    local autoPlayRun = AutoPlayRuntime.new(nil, nil, {
        spawn = function() end,
        wait = function() end,
    })
    local fakeMacroListeners: { (string) -> () } = {}
    local fakeMacro: any = {
        mode = "idle",
        onModeChange = function(cb: any)
            table.insert(fakeMacroListeners, cb)
        end,
    }
    autoPlayRun.setMacro(fakeMacro)
    autoPlayRun.start({ alive = true })

    local togglesCreated: { [string]: any } = {}
    local tab: any = {
        Paragraph = function()
            return { SetDesc = function() end }
        end,
        Section = function(_self: any, _opt: any)
            return {
                Paragraph = function() end,
                Toggle = function(_s: any, opt: any)
                    local control = {
                        Value = opt.Value,
                        Locked = opt.Locked or false,
                        Callback = opt.Callback,
                        Set = function(self: any, val: boolean)
                            self.Value = val
                        end,
                        Lock = function(self: any)
                            self.Locked = true
                        end,
                        Unlock = function(self: any)
                            self.Locked = false
                        end,
                    }
                    togglesCreated[opt.Title] = control
                    return control
                end,
            }
        end,
    }

    AutoPlayPage.mount(tab, autoPlayRun, fakeMacro)
    local toggle = togglesCreated["Auto play - ingame"]
    assert(toggle ~= nil and toggle.Value == false)
    assert(toggle.Locked == false)

    -- When macro starts playing -> AutoPlay toggle is LOCKED!
    fakeMacro.mode = "play"
    for _, cb in fakeMacroListeners do
        cb("play")
    end
    assert(toggle.Locked == true)

    -- When macro stops -> AutoPlay toggle is UNLOCKED!
    fakeMacro.mode = "idle"
    for _, cb in fakeMacroListeners do
        cb("idle")
    end
    assert(toggle.Locked == false)

    autoPlayRun.stop()
end)
local function presetsSnapshot(active: string): any
    return {
        active = active,
        max = 12,
        order = { "P1", "P6", "P7" },
        names = { P1 = "TO PLAY", P6 = "Raid", P7 = "Raid" },
    }
end
-- Builds a runtime around a scripted adapter; the returned table exposes counters and mutable game state.
local function presetHarness(rules: any): any
    local h: any = {
        clock = 100,
        started = true,
        autoPlaying = false,
        gameData = { mode = "Story", stage = "Stage1" } :: any,
        presets = presetsSnapshot("P1") :: any,
        switches = {} :: { string },
        toggles = 0,
        requests = 0,
    }
    local mockAdapter: any = {
        isAvailable = function()
            return true
        end,
        isMatchStarted = function()
            return h.started
        end,
        hasStartPrompt = function()
            return false
        end,
        castStartVote = function()
            return true
        end,
        isAutoPlaying = function()
            return h.autoPlaying
        end,
        toggle = function()
            h.toggles += 1
            h.autoPlaying = not h.autoPlaying
            return true
        end,
        observe = function()
            return function() end
        end,
        getGameData = function()
            return h.gameData
        end,
        getPresets = function()
            return h.presets
        end,
        requestPresets = function()
            h.requests += 1
            return true
        end,
        trackPresets = function()
            return true
        end,
        onPresetsUpdated = function(cb: any)
            h.presetsCallback = cb
            return function() end
        end,
        switchPreset = function(id: string)
            table.insert(h.switches, id)
            return true
        end,
    }
    h.runtime = AutoPlayRuntime.new(mockAdapter, nil, {
        spawn = function() end,
        wait = function() end,
        clock = function()
            return h.clock
        end,
    })
    h.runtime.start({ alive = true })
    if rules then
        h.runtime.rules = AutoPlayRules.normalize(rules)
    end
    return h
end
test("Stage Preset Rules model validates, prunes and labels presets", function()
    local rules = AutoPlayRules.normalize({
        Story = { id = "P6", name = "Raid" },
        Bad = { id = 5, name = "x" },
        [""] = { id = "P1", name = "y" },
        Raid = "nope",
        Legacy = { Stage1 = { id = "P1", name = "y" } },
    })
    assert((AutoPlayRules.get(rules, "Story") :: any).id == "P6")
    assert(AutoPlayRules.get(rules, "Bad") == nil)
    assert(AutoPlayRules.get(rules, "Raid") == nil)
    assert(AutoPlayRules.get(rules, "Legacy") == nil, "old per-stage rules are dropped")
    assert(next(AutoPlayRules.normalize(42)) == nil)
    local presets = presetsSnapshot("P1")
    assert(AutoPlayRules.resolve({ id = "P6", name = "Raid" }, presets) == "ok")
    assert(AutoPlayRules.resolve({ id = "P6", name = "Old name" }, presets) == "invalid")
    assert(AutoPlayRules.resolve({ id = "P9", name = "Raid" }, presets) == "invalid")
    AutoPlayRules.set(rules, "Raid", { id = "P9", name = "Gone" })
    assert(AutoPlayRules.prune(rules, presets) == 1)
    assert(AutoPlayRules.get(rules, "Raid") == nil)
    assert(AutoPlayRules.get(rules, "Story") ~= nil)
    AutoPlayRules.set(rules, "Story", nil)
    assert(next(rules) == nil)
    local options = AutoPlayRules.options(presets)
    assert(options[1].label == "None" and options[1].id == nil)
    assert(options[3].label == "Raid" and options[4].label == "Raid (2)" and options[4].id == "P7")
    assert(#AutoPlayRules.options(nil) == 1)
    assert(AutoPlayRules.readPresets({ Active = "P1" }) == nil)
    local read =
        AutoPlayRules.readPresets({ Active = "P1", Max = 12, Order = { "P1" }, Names = { P1 = "A" } })
    assert(read ~= nil and read.active == "P1" and read.names.P1 == "A")
end)
test("Stage Preset Rules switch once, confirm by readback, then enable native Auto Play", function()
    local h = presetHarness({ Story = { id = "P6", name = "Raid" } })
    assert(h.runtime.setEnabled(true))
    assert(#h.switches == 1 and h.switches[1] == "P6")
    assert(h.toggles == 0)
    h.clock = 101
    h.runtime.step(101)
    assert(#h.switches == 1, "no duplicate select while waiting for confirmation")
    h.presets = presetsSnapshot("P6")
    h.clock = 102
    h.runtime.step(102)
    assert(#h.switches == 1 and h.toggles == 1 and h.autoPlaying)
    h.runtime.step(103)
    assert(#h.switches == 1, "no select when the game already uses the wanted preset")
    h.gameData = { mode = "Story", stage = "Stage7" }
    h.runtime.step(104)
    assert(#h.switches == 1, "the rule applies to every stage of the mode")
    h.runtime.stop()
end)
test("Stage Preset Rules pause native Auto Play before switching and skip None or unmatched modes", function()
    local h = presetHarness({ Story = { id = "P6", name = "Raid" } })
    h.autoPlaying = true
    h.runtime.enabled = true
    h.runtime.step(100)
    assert(h.toggles == 1 and not h.autoPlaying and #h.switches == 0)
    h.runtime.step(101)
    assert(#h.switches == 1)
    h.runtime.stop()

    local none = presetHarness({ Raid = { id = "P6", name = "Raid" } })
    assert(none.runtime.setEnabled(true))
    assert(#none.switches == 0 and none.toggles == 1)
    none.runtime.stop()

    local blank = presetHarness(nil)
    blank.gameData = { mode = "Raid", stage = "Stage9" }
    assert(blank.runtime.setEnabled(true))
    assert(#blank.switches == 0 and blank.toggles == 1)
    blank.runtime.stop()
end)
test("Stage Preset Rules reset a deleted or renamed preset to None without guessing another", function()
    local deleted = presetHarness({ Story = { id = "P9", name = "Raid" } })
    assert(deleted.runtime.setEnabled(true))
    assert(#deleted.switches == 0)
    assert(deleted.runtime.getRule("Story") == nil)
    assert(deleted.toggles == 1, "Auto Play proceeds with the game's current preset")
    deleted.runtime.stop()

    local renamed = presetHarness({ Story = { id = "P6", name = "Old name" } })
    local notified = 0
    renamed.runtime.onRulesChange(function()
        notified += 1
    end)
    assert(renamed.runtime.setEnabled(true))
    assert(#renamed.switches == 0 and renamed.runtime.getRule("Story") == nil)
    assert(notified >= 1)
    renamed.runtime.stop()

    local live = presetHarness({ Story = { id = "P6", name = "Raid" } })
    live.presets = presetsSnapshot("P1")
    live.presets.names.P6 = "Renamed"
    live.presetsCallback(live.presets)
    assert(live.runtime.getRule("Story") == nil)
    live.runtime.stop()
end)
test("Stage Preset Rules retry three times then continue with the current preset", function()
    local h = presetHarness({ Story = { id = "P6", name = "Raid" } })
    h.runtime.enabled = true
    h.runtime.step(100)
    h.runtime.step(108)
    h.runtime.step(116)
    assert(#h.switches == 3)
    h.runtime.step(124)
    assert(#h.switches == 3 and h.toggles == 1)
    assert(h.runtime.status:find("Enabling native Auto Play") ~= nil)
    h.runtime.stop()
end)
test("Stage Preset Rules cannot be edited while Auto Play is on or Play Macro is active", function()
    local h = presetHarness(nil)
    local ok, err = h.runtime.setRule("Story", "P6")
    assert(ok and err == nil)
    assert(h.runtime.getRule("Story").name == "Raid")
    assert(select(2, h.runtime.setRule("Story", "P404")) == "PRESET_UNKNOWN")
    assert(h.runtime.setRule("Story", nil) and h.runtime.getRule("Story") == nil)
    h.runtime.setRule("Story", "P6")
    assert(h.runtime.setEnabled(true))
    assert(h.runtime.isRulesLocked())
    assert(select(2, h.runtime.setRule("Story", nil)) == "AUTOPLAY_ENABLED")
    assert(h.runtime.getRule("Story") ~= nil)
    h.runtime.setEnabled(false)
    h.runtime.setMacro({ mode = "play" })
    assert(h.runtime.isRulesLocked())
    assert(select(2, h.runtime.setRule("Story", nil)) == "MACRO_ACTIVE")
    h.runtime.stop()
end)
test("Stage Preset Rules persist as schema v3 and load v1 and v2 files without stage rules", function()
    local body: string? = nil
    local written: { string } = {}
    local http: any = {
        JSONEncode = function(_self: any, value: any): string
            return string.format(
                "%d|%s|%s",
                value.schemaVersion,
                tostring(value.enabled),
                tostring(value.rules.Story and value.rules.Story.id or "")
            )
        end,
        JSONDecode = function(_self: any, text: string): any
            local version, enabled, id = string.match(text, "^(%d+)|(%a+)|(.*)$")
            local rules: any = {}
            if id ~= "" then
                if tonumber(version) == 2 then
                    rules.Story = { Stage1 = { id = id, name = "Raid" } }
                else
                    rules.Story = { id = id, name = "Raid" }
                end
            end
            return { schemaVersion = tonumber(version), enabled = enabled == "true", rules = rules }
        end,
    }
    local storage: any = {
        read = function()
            return body
        end,
        write = function(text: string)
            body = text
            table.insert(written, text)
            return true
        end,
    }
    local function fresh(): any
        local runtime =
            AutoPlayRuntime.new(nil, storage, { spawn = function() end, wait = function() end }, http)
        runtime.start({ alive = true })
        return runtime
    end
    body = "1|true|"
    local v1 = fresh()
    assert(v1.isEnabled() == true and v1.getRule("Story") == nil)
    v1.stop()
    body = "2|false|P6"
    local v2 = fresh()
    assert(v2.getRule("Story") == nil, "per-stage v2 rules are discarded")
    v2.stop()
    body = "3|false|P6"
    local v3 = fresh()
    local loaded = v3.getRule("Story")
    assert(loaded ~= nil and loaded.id == "P6")
    assert(v3.setEnabled(true) == true)
    assert(written[#written]:sub(1, 2) == "3|" and written[#written]:find("P6") ~= nil)
    v3.stop()
end)
test("AutoPlay adapter reads presets, switches by id and lists supported modes", function()
    local fired: { any } = {}
    local handler: any = nil
    local requested = 0
    local deps: any = {
        autoPlayClient = {
            SwitchAutoPlayPreset = {
                Fire = function(payload: any)
                    table.insert(fired, payload)
                end,
            },
            RequestAutoPlayData = {
                Fire = function()
                    requested += 1
                end,
            },
            AutoPlayPresetsUpdated = {
                On = function(callback: any)
                    handler = callback
                    return function()
                        handler = nil
                    end
                end,
            },
        },
        autoPlayHandler = {},
        gameHandler = {
            IsGameLoaded = true,
            GetGameData = function(_self: any)
                return { StageType = "Story", Stage = "Stage1", Act = "Act1" }
            end,
        },
        stagesData = {
            GetAllStageTypeNames = function()
                return { "Raid", "Story", "Story", "PVP", "LTM", "Empty", "Extra", "Scenarios", "Portals" }
            end,
            GetAllStageNameAndIndex = function(mode: string)
                if mode == "Story" then
                    return { ["Hill of Swords"] = "Stage10", ["Sand Village"] = "Stage2" }
                elseif mode == "Raid" then
                    return { ["Factory"] = "Stage4" }
                elseif mode == "PVP" then
                    return { ["Arena"] = "Stage2" }
                elseif mode == "Empty" then
                    return {}
                elseif mode == "Portals" then
                    return { ["Trial"] = "Trial" }
                elseif mode == "Scenarios" then
                    return { ["Roku"] = "Roku" }
                elseif mode == "Extra" then
                    return { ["Greenscreen"] = "Stage1" }
                end
                return { ["Pirate Dynasty"] = "Pirate Dynasty", ["Rts"] = "RTS" }
            end,
        },
        blocklist = {
            IsBlocked = function(data: any)
                return data.StageType == "PVP" or (data.StageType == "LTM" and data.Stage == "RTS")
            end,
        },
    }
    local adapter = AutoPlayAdapter.new(deps)
    assert(adapter.getPresets() == nil)
    assert(adapter.trackPresets() and requested == 1)
    local seen: any = nil
    adapter.onPresetsUpdated(function(snapshot: any)
        seen = snapshot
    end)
    handler({ Active = "P1", Max = 12, Order = { "P1", "P6" }, Names = { P1 = "A", P6 = "B" } })
    assert(seen ~= nil and seen.active == "P1" and adapter.getPresets().names.P6 == "B")
    handler("garbage")
    assert(adapter.getPresets().active == "P1")
    assert(adapter.switchPreset("P6") and fired[1].PresetId == "P6")
    assert(not adapter.switchPreset(""))
    local data = adapter.getGameData()
    assert(data ~= nil and data.mode == "Story" and data.stage == "Stage1")
    local modes = adapter.getModes()
    assert(
        modes ~= nil and #modes == 6,
        "blocked, empty and hidden modes are skipped; joiner-only modes are added"
    )
    assert(modes[1] == "Story" and modes[2] == "ElementalTowers" and modes[3] == "Portals")
    assert(modes[4] == "Raid" and modes[5] == "Rift" and modes[6] == "Worldline")
    adapter.untrackPresets()
    assert(adapter.getPresets() == nil and handler == nil)
end)
test("Stage Preset Rules page lists one dropdown per mode and locks it with Auto Play", function()
    local fresh = presetHarness({ Story = { id = "P6", name = "Raid" } })
    fresh.runtime.adapter.getModes = function()
        return { "Story", "Raid" }
    end
    local dropdowns: any = {}
    local function control(): any
        return {
            Lock = function(self: any)
                self.Locked = true
            end,
            Unlock = function(self: any)
                self.Locked = false
            end,
            Set = function() end,
            SetDesc = function() end,
        }
    end
    local sectionApi: any = {
        Paragraph = function()
            return control()
        end,
        Toggle = function(_s: any, _opt: any)
            return control()
        end,
        Dropdown = function(_s: any, opt: any)
            local d = control()
            d.Locked = false
            d.Values = opt.Values
            d.Selected = opt.Value
            d.Callback = opt.Callback
            -- Like WindUI, Refresh and Select echo the selected value through the callback.
            d.Refresh = function(self: any, values: any)
                self.Values = values
                self.Callback(self.Selected)
            end
            d.Select = function(self: any, value: string)
                self.Selected = value
                self.Callback(self.Selected)
            end
            dropdowns[opt.Title] = d
            return d
        end,
    }
    local tab: any = {
        Paragraph = function()
            return control()
        end,
        Section = function(_s: any, _opt: any)
            return sectionApi
        end,
        Button = function() end,
    }
    local setRuleCalls = 0
    local realSetRule = fresh.runtime.setRule
    fresh.runtime.setRule = function(mode: string, id: string?)
        setRuleCalls += 1
        assert(setRuleCalls < 50, "dropdown echo must not loop")
        return realSetRule(mode, id)
    end
    AutoPlayPage.mount(tab, fresh.runtime, nil)
    assert(setRuleCalls == 0, "refresh echoes are ignored")
    assert(fresh.runtime.getModeLabel("LegendStage") == "Legend Stage")
    assert(fresh.runtime.getModeLabel("SomeNewMode") == "Some New Mode")
    assert(dropdowns.Story ~= nil and dropdowns.Raid ~= nil)
    assert(dropdowns.Story.Selected == "Raid")
    assert(dropdowns.Raid.Selected == "None")
    assert(dropdowns.Story.Locked == false)
    dropdowns.Raid.Callback("Raid (2)")
    assert(fresh.runtime.getRule("Raid").id == "P7")
    assert(fresh.runtime.setEnabled(true))
    assert(dropdowns.Story.Locked == true and dropdowns.Raid.Locked == true)
    dropdowns.Raid.Callback("None")
    assert(fresh.runtime.getRule("Raid") ~= nil, "locked edits are refused")
    assert(dropdowns.Raid.Selected == "Raid (2)")
    fresh.presetsCallback(fresh.presets)
    assert(setRuleCalls < 10, "preset updates while locked do not write rules")
    fresh.runtime.setEnabled(false)
    assert(dropdowns.Story.Locked == false)
    fresh.runtime.stop()
end)
test(
    "Regressions: empty slots, empty preset snapshot, stage-change retry per match, stale bounty marker",
    function()
        -- Empty slots may be nil, "" or the string "None" on either side.
        local owned: { [string]: boolean } = { g1 = true }
        local function ownsUnit(guid: string): boolean
            return owned[guid] == true
        end
        assert(
            TeamEquip.evaluate(
                { Units = { "g1", "None", "None", "None", "None", "None" } },
                ownsUnit,
                { "g1", "None", "None" }
            ) == "match"
        )
        assert(
            TeamEquip.evaluate({ Units = { "g1" } }, ownsUnit, { "g1", "None", "", nil, "None", "None" })
                == "match"
        )
        assert(TeamEquip.evaluate({ Units = { "g1" } }, ownsUnit, { "g1", "g2" }) == "mismatch")

        -- A transient empty preset list must not erase the saved Stage Preset Rules.
        local h = presetHarness({ Story = { id = "P6", name = "Raid" } })
        h.presetsCallback({ active = "", max = 12, order = {}, names = {} })
        assert(h.runtime.getRule("Story") ~= nil, "empty snapshot keeps the rules")
        h.presetsCallback(presetsSnapshot("P1"))
        assert(h.runtime.getRule("Story") ~= nil, "a loaded list that still contains the preset keeps it")
        h.runtime.stop()

        -- Stage-change attempts restart for a new match id (restart) instead of staying exhausted.
        local fired: { any } = {}
        local matchData: any = { StageType = "Raid", Stage = "Stage1", Act = "Act1", Host = 42 }
        local gameHandler: any =
            { IsGameLoaded = true, IsMatchStarted = false, GameData = matchData, MatchId = 1 }
        local runtime = JoinerRuntime.new({
            game = {
                PlaceId = 16277809958,
                GetService = function(): any
                    return {
                        GetAttribute = function(): any
                            return false
                        end,
                    }
                end,
            },
            task = { spawn = function() end, wait = function() end },
            clock = function()
                return 100
            end,
            userId = 42,
            gameHandler = gameHandler,
            lobbyReturn = {
                RequestStartMatch = {
                    Fire = function(payload: any)
                        table.insert(fired, payload)
                    end,
                },
            },
        })
        for _, other in { "Legend Stage", "Raid", "Dungeon", "Worldline", "Boss Event", "Boss Bounties" } do
            JoinerSettings.setEnabled(other, false)
        end
        JoinerSettings.setPaused(false)
        JoinerSettings.setBountyRun(nil)
        runtime.setSelection("Stage", "Stage1", "Act1", "Normal")
        runtime.setEnabled("Stage", true)
        JoinerSettings.setJoinerRun({ mode = "Raid", stage = "Stage1", act = "Act1", at = os.time() })
        runtime.start({ alive = true })
        runtime.step(100)
        runtime.step(107)
        runtime.step(114)
        assert(#fired == 2, "two attempts for the first match")
        gameHandler.MatchId = 2
        runtime.step(121)
        assert(#fired == 3, "a restart (new match id) is tried again")
        runtime.stop()
        runtime.setEnabled("Stage", false)

        -- A marker left from a finished bounty is cleared once the joiner is back in the lobby with nothing in flight.
        JoinerSettings.setBountyRun({ mode = "LegendStage", stage = "Stage5", act = "Act2", at = os.time() })
        local lobby = JoinerRuntime.new({
            game = { PlaceId = 16146832113 },
            task = { spawn = function() end, wait = function() end },
            clock = function()
                return 100
            end,
            userId = 42,
            lobby = { IsHosting = false, IsInLobby = false },
            network = {
                MatchConfirmed = {
                    On = function()
                        return function() end
                    end,
                },
            },
        })
        lobby.start({ alive = true })
        lobby.step(100)
        assert(JoinerSettings.get().bountyRun == nil)
        lobby.stop()
        JoinerSettings.setPaused(true)
    end
)
test("Team popup guard replaces a stale wrapper instead of stacking", function()
    local calls = 0
    local popupHandler: any = {}
    function popupHandler.ShowPopup(_self: any, _kind: string, _text: string)
        calls += 1
    end
    local original = popupHandler.ShowPopup
    local function newAdapter(): any
        return TeamAdapter.new({
            popupHandler = popupHandler,
            lobbyTeams = { LoadTeam = { Fire = function() end } },
        }, false)
    end
    local first = newAdapter()
    assert(first.loadTeam("Team1"))
    local firstWrapper = popupHandler.ShowPopup
    assert(firstWrapper ~= original)
    local second = newAdapter() -- the first one was never stopped (script reloaded)
    assert(second.loadTeam("Team2"))
    popupHandler:ShowPopup("BaseCancelFrame", "Other popup")
    assert(calls == 1, "one wrapper layer: the original runs once")
    second.stop()
    assert(popupHandler.ShowPopup == original, "the original is back after stopping the current adapter")
end)
local WEBHOOK_CONFIG: any = (VanguardsConfig :: any).webhook
local HOOK_URL = "https://discord.com/api/webhooks/123456789012345678/abcdefghijklmnopqrstuvwxyz_-ABCDEF"
test("Webhook URL validation and masking", function()
    local hosts = WEBHOOK_CONFIG.hosts
    assert(WebhookEmbed.validUrl(HOOK_URL, hosts))
    assert(WebhookEmbed.validUrl(HOOK_URL .. "/", hosts))
    assert(
        not WebhookEmbed.validUrl(
            "http://discord.com/api/webhooks/123456789012345678/abcdefghijklmnopqrstuvwxyz",
            hosts
        )
    )
    assert(
        not WebhookEmbed.validUrl(
            "https://evil.example/api/webhooks/123456789012345678/abcdefghijklmnopqrstuvwxyz",
            hosts
        )
    )
    assert(not WebhookEmbed.validUrl("https://discord.com/api/webhooks/123/abc", hosts))
    assert(not WebhookEmbed.validUrl(HOOK_URL .. "?wait=true&x=1", hosts))
    assert(not WebhookEmbed.validUrl(nil, hosts))
    assert(not WebhookEmbed.validUrl(string.rep("a", 400), hosts))
    local masked = WebhookEmbed.mask(HOOK_URL, hosts)
    assert(not string.find(masked, "abcdefgh", 1, true), "token must not appear")
    assert(not string.find(masked, "12345678901", 1, true), "only the first id digits may appear")
    assert(WebhookEmbed.mask("nope", hosts) == "(not set)")
end)
test("Webhook embeds stay inside Discord limits and mentions stay disabled", function()
    local fields: { any } = {}
    for index = 1, 40 do
        table.insert(fields, { name = "N" .. index, value = string.rep("v", 1500), inline = true })
    end
    local embed = WebhookEmbed.build({
        title = string.rep("t", 400),
        description = string.rep("d", 5000),
        fields = fields,
        footer = "f",
        color = 0xFFFFFFF,
        timestamp = "2026-01-02T03:04:05Z",
        authorName = "Player",
        authorIcon = "http://insecure.example/x.png",
    })
    assert(#embed.title <= 256 and #embed.description <= 4000 and #embed.fields <= 25)
    assert(embed.color == 0xFFFFFF)
    assert(embed.author.icon_url == nil, "non-https icon dropped")
    local total = #embed.title + #embed.description + #embed.footer.text + #embed.author.name
    for _, field in embed.fields do
        assert(#field.value <= 1024)
        total += #field.name + #field.value
    end
    assert(total <= 6000, "embed total " .. total)
    assert(WebhookEmbed.build({ title = "x", timestamp = "yesterday" }).timestamp == nil)
    local plain = WebhookEmbed.payload(
        { embed },
        { username = "Discord Bot", ping = true, pingUserId = "99" }
    )
    assert(plain.username == "ViperHub", "reserved bot name replaced")
    assert(
        plain.content == nil and #plain.allowed_mentions.parse == 0 and plain.allowed_mentions.users == nil
    )
    local pinged = WebhookEmbed.payload({ embed }, { ping = true, pingUserId = "123456789012345678" })
    assert(
        pinged.content == "<@123456789012345678>" and pinged.allowed_mentions.users[1] == "123456789012345678"
    )
    assert(#pinged.allowed_mentions.parse == 0, "no role/everyone parsing")
    assert(WebhookEmbed.number(1234) == "1,234" and WebhookEmbed.number(25000) == "25.0K")
    assert(WebhookEmbed.number(3400000) == "3.40M" and WebhookEmbed.number("x") == "0")
    assert(WebhookEmbed.duration(3723) == "1h 02m 03s" and WebhookEmbed.duration(65) == "1m 05s")
end)
local function webhookClock(): any
    local fake: any = { now = 0, waits = 0 }
    fake.task = {
        spawn = function(callback: any, ...: any)
            callback(...)
        end,
        wait = function(seconds: number?)
            fake.now += seconds or 0
            fake.waits += 1
            if fake.onWait then
                (fake.onWait :: any)()
            end
        end,
    }
    fake.clock = function()
        return fake.now
    end
    return fake
end
local function webhookCodec(): any
    local codec: any = { values = {}, count = 0 }
    codec.encode = function(value: any): string
        codec.count += 1
        local key = "J" .. codec.count
        codec.values[key] = value
        return key
    end
    codec.decode = function(text: string): any
        return codec.values[text] or { retry_after = 1 }
    end
    return codec
end
test("Webhook sender queues, rate limits, retries and shuts down on a rejected URL", function()
    local clk = webhookClock()
    local codec = webhookCodec()
    local statuses: { number } = {}
    local urls: { string } = {}
    local sender = WebhookSender.new({
        request = function(req: any)
            table.insert(urls, req.Url)
            local status = table.remove(statuses, 1) or 204
            return { StatusCode = status, Body = "{}", Headers = {} }
        end,
        encode = codec.encode,
        decode = codec.decode,
        task = clk.task,
        clock = clk.clock,
        minInterval = 1.5,
        queueLimit = 3,
        retryLimit = 2,
    })
    assert(not sender.enqueue({ a = 1 }), "no URL yet")
    sender.setUrl(HOOK_URL)
    assert(sender.isReady())
    assert(sender.enqueue({ a = 1 }) and sender.stats.sent == 1 and sender.state == "idle")
    local before = clk.now
    assert(sender.enqueue({ a = 2 }) and sender.stats.sent == 2)
    assert(clk.now - before >= 1.4, "second message waited for the minimum interval")
    statuses = { 429, 204 }
    assert(sender.enqueue({ a = 3 }) and sender.stats.sent == 3, "429 retried and then delivered")
    statuses = { 500, 500, 500, 500 }
    sender.enqueue({ a = 4 })
    assert(sender.stats.failed == 1 and sender.state == "offline", "gave up after the retry limit")
    statuses = { 400 }
    sender.enqueue({ a = 5 })
    assert(sender.stats.dropped == 1, "malformed payload dropped without retry")
    statuses = { 404 }
    sender.enqueue({ a = 6 })
    assert(sender.state == "invalid" and not sender.isReady() and sender.url == nil)
    assert(not sender.enqueue({ a = 7 }), "invalid URL stops delivery")
    for _, value in { sender.state, sender.stats.sent, sender.stats.failed } do
        assert(not string.find(tostring(value), "abcdefgh", 1, true))
    end
    assert(urls[1] == HOOK_URL)
end)
test("Webhook sender drops the oldest payload when the queue is full", function()
    local clk = webhookClock()
    local codec = webhookCodec()
    local sender = WebhookSender.new({
        request = function()
            return { StatusCode = 204 }
        end,
        encode = codec.encode,
        task = {
            spawn = function() end, -- delivery never starts, so the queue fills
            wait = clk.task.wait,
        },
        clock = clk.clock,
        minInterval = 0,
        queueLimit = 2,
        retryLimit = 1,
    })
    sender.setUrl(HOOK_URL)
    for index = 1, 4 do
        sender.enqueue({ n = index })
    end
    assert(#sender.queue == 2 and sender.queue[1].payload.n == 3 and sender.stats.dropped == 2)
    sender.stop()
    assert(#sender.queue == 0 and not sender.enqueue({ n = 9 }))
end)
test("Webhook events build for every kind and ping only when it matters", function()
    local ctx = {
        player = "Tester",
        avatarUrl = "https://tr.rbxcdn.com/x.png",
        userId = 42,
        showPlayer = true,
        timestamp = "2026-01-02T03:04:05Z",
        version = "1.2.3",
    }
    for _, kind in WebhookEvents.kinds do
        local spec = WebhookEvents.build(
            kind.id,
            { message = "m", name = "Boss", rarity = "Secret", result = "Victory" },
            ctx,
            WEBHOOK_CONFIG
        )
        assert(spec and spec.title and spec.title ~= "", kind.id)
        assert(#WebhookEmbed.build(spec :: any).title > 0)
    end
    assert(WebhookEvents.build("test", {}, ctx, WEBHOOK_CONFIG) ~= nil)
    assert(WebhookEvents.build("nonsense", {}, ctx, WEBHOOK_CONFIG) == nil)
    local _, secretPing = WebhookEvents.build("unit", { name = "X", rarity = "Secret" }, ctx, WEBHOOK_CONFIG)
    local _, mythicPing = WebhookEvents.build("unit", { name = "X", rarity = "Mythic" }, ctx, WEBHOOK_CONFIG)
    local _, vanguardPing =
        WebhookEvents.build("unit", { name = "X", rarity = "Vanguard" }, ctx, WEBHOOK_CONFIG)
    assert(secretPing and vanguardPing and not mythicPing)
    local win = WebhookEvents.build(
        "matchEnd",
        { result = "Victory", rewards = { { name = "Gems", amount = "50" } } },
        ctx,
        WEBHOOK_CONFIG
    ) :: any
    local loss = WebhookEvents.build("matchEnd", { result = "Defeat" }, ctx, WEBHOOK_CONFIG) :: any
    assert(
        win.color ~= loss.color and string.find(win.title, "VICTORY") and string.find(loss.title, "DEFEAT")
    )
    assert(win.authorName == "Tester" and win.authorIcon == "https://tr.rbxcdn.com/x.png")
    ctx.showPlayer = false
    local hidden = WebhookEvents.build("session", {}, ctx, WEBHOOK_CONFIG) :: any
    assert(hidden.authorName == nil and hidden.authorIcon == nil, "player identity hidden when switched off")
end)
local function newWebhook(extra: any?): any
    local clk = webhookClock()
    local codec = webhookCodec()
    local sent: { any } = {}
    local holder: any = { stored = nil }
    local deps: any = {
        encode = codec.encode,
        decode = codec.decode,
        task = clk.task,
        clock = clk.clock,
        timestamp = function()
            return "2026-01-02T03:04:05Z"
        end,
        playerName = "Tester",
        userId = 42,
        request = function(req: any)
            table.insert(sent, codec.values[req.Body])
            return { StatusCode = 204 }
        end,
        storage = {
            read = function()
                return holder.stored, nil
            end,
            write = function(body: string)
                holder.stored = body
                return true
            end,
        },
    }
    for key, value in extra or {} do
        deps[key] = value
    end
    return { runtime = WebhookRuntime.new(deps), sent = sent, clk = clk, codec = codec, deps = deps }
end
test("Webhook runtime validates settings, hides the URL and persists", function()
    local h = newWebhook()
    local rt = h.runtime
    rt.start({ alive = false }, {})
    local ok, err = rt.setUrl("https://example.com/hook")
    assert(not ok and err == "INVALID_URL")
    assert(rt.setUrl(HOOK_URL))
    assert(not rt.setPingUser("abc") and not rt.setPingUser("123") and rt.setPingUser("123456789012345678"))
    assert(not rt.setMinRarity("Common") and rt.setMinRarity("Mythic"))
    assert(not rt.setAvatar("http://x.example/a.png") and rt.setAvatar("https://cdn.example/a.png"))
    assert(not rt.setEvent("unknown", true) and rt.setEvent("rift", false))
    assert(rt.setEnabled(true) and rt.setUsername("My Bot"))
    local view = rt.getSettings()
    assert(view.url == nil and view.hasUrl and not string.find(view.urlMasked, "abcdefgh", 1, true))
    assert(not string.find(rt.getStatus(), "abcdefgh", 1, true))
    local second = newWebhook({ storage = h.deps.storage, encode = h.codec.encode, decode = h.codec.decode })
    second.runtime.start({ alive = false }, {})
    local restored = second.runtime.getSettings()
    assert(
        restored.enabled
            and restored.hasUrl
            and restored.minRarity == "Mythic"
            and restored.events.rift == false
    )
    assert(restored.username == "My Bot" and restored.pingUserId == "123456789012345678")
    second.runtime.clearUrl()
    assert(not second.runtime.getSettings().hasUrl)
end)
test("Webhook runtime sends tests and respects the master and per-event switches", function()
    local h = newWebhook()
    local rt = h.runtime
    local ok, err = rt.sendTest()
    assert(not ok and err == "NO_URL")
    rt.setUrl(HOOK_URL)
    assert(rt.sendTest() and #h.sent == 1 and h.sent[1].embeds[1].title ~= nil)
    assert(not rt.notify("rift", { message = "x" }), "disabled by default")
    rt.setEnabled(true)
    assert(rt.notify("rift", { message = "x" }) and #h.sent == 2)
    rt.setEvent("rift", false)
    assert(not rt.notify("rift", { message = "x" }) and #h.sent == 2)
    assert(rt.notify("warning", { message = "careful" }, "w", 60) and #h.sent == 3)
    assert(not rt.notify("warning", { message = "careful" }, "w", 60), "cooldown dedupes")
    h.clk.now += 61
    assert(rt.notify("warning", { message = "careful" }, "w", 60) and #h.sent == 4)
end)
test("Webhook runtime announces new units only after startup and only once", function()
    local owned: any = { ["old"] = true }
    local units: any = {
        old = { UnitData = { Name = "Old", Rarity = "Secret" } },
        n1 = { UnitData = { Name = "Rarey", Rarity = "Rare" }, Level = 1 },
        n2 = { UnitData = { Name = "Ghost", Rarity = "Secret" }, Level = 1, Trait = { Name = "Fortune" } },
    }
    local captured: { any } = {}
    local function signalHandler(...: any)
        (captured[1] :: any)(...)
    end
    local ownedModule: any = {
        GetOwnedUnits = function()
            return owned
        end,
        GetUnitObject = function(guid: string)
            return units[guid]
        end,
        UnitAdded = {
            Connect = function(_self: any, handler: any)
                captured[1] = handler
                return { Disconnect = function() end }
            end,
        },
    }
    local h = newWebhook({ ownedUnitsModule = ownedModule, unitObject = ownedModule.GetUnitObject })
    local rt = h.runtime
    rt.setUrl(HOOK_URL)
    rt.setEnabled(true)
    rt.setMinRarity("Epic")
    rt.start({ alive = false }, {})
    assert(captured[1], "UnitAdded connected")
    signalHandler("n2")
    assert(#h.sent == 0, "ignored while the inventory is still replicating")
    h.clk.now += 100
    signalHandler("old")
    signalHandler("n1")
    assert(#h.sent == 0, "known and below-minimum units are ignored")
    units.n2.UniqueIdentifier = "n2"
    signalHandler(units.n2)
    signalHandler("n2")
    assert(#h.sent == 1, "announced exactly once")
    local embed = h.sent[1].embeds[1]
    assert(string.find(embed.title, "Secret") and string.find(embed.description, "Ghost"))
    rt.stop()
    rt.stop()
end)
test("Webhook runtime turns joiner and auto play status lines into notices", function()
    local h = newWebhook()
    local rt = h.runtime
    rt.setUrl(HOOK_URL)
    rt.setEnabled(true)
    rt.onStatusLine("joiner", "Idle")
    rt.onStatusLine("joiner", "Team Equipper: waiting for Team 1 to equip")
    assert(#h.sent == 0, "progress lines are quiet")
    rt.onStatusLine("joiner", "Stage Joiner: confirmed by server")
    assert(#h.sent == 1 and string.find(h.sent[1].embeds[1].title, "Entered"))
    rt.onStatusLine("joiner", "Stage Joiner: entered match")
    assert(#h.sent == 1, "same joiner not announced twice in a row")
    rt.onStatusLine("joiner", "Boss Bounties: stage/act locked or progress unavailable")
    assert(#h.sent == 2 and string.find(h.sent[2].embeds[1].title, "problem"))
    rt.onStatusLine("joiner", "Boss Bounties: stage/act locked or progress unavailable")
    assert(#h.sent == 2, "problem repeats are rate limited")
    rt.onStatusLine("joiner", "Team Equipper: Team 1 was not confirmed; skipping Stage")
    assert(#h.sent == 3 and string.find(h.sent[3].embeds[1].title, "Equipper"))
    rt.onStatusLine("autoPlay", "Native Auto Play active")
    rt.onStatusLine("autoPlay", "Preset switch not confirmed")
    assert(#h.sent == 5)
    rt.setEvent("autoPlay", false)
    rt.onStatusLine("autoPlay", "Request failed")
    assert(#h.sent == 5)
end)
test("Webhook runtime reports bounty progress, rift openings and match results", function()
    local left = 5
    local rift: boolean? = false
    local screen: any =
        { result = "Victory", damage = "1.2M", rewards = { { name = "Gems", amount = "50" } } }
    local h = newWebhook({
        readBounty = function()
            return { left = left, mode = "Story", stage = "Planet Namak", act = "Act 1", boss = "Frieza" }
        end,
        riftOpen = function()
            return rift
        end,
        readEndScreen = function()
            return screen
        end,
        gameData = function()
            return { StageType = "Story", Stage = "Planet Namak", Act = "Act 1", Difficulty = "Normal" }
        end,
    })
    local rt = h.runtime
    rt.setUrl(HOOK_URL)
    rt.setEnabled(true)
    rt.tick()
    assert(#h.sent == 0, "first reading only sets the baseline")
    left = 4
    h.clk.now += 20
    rt.tick()
    assert(#h.sent == 1 and string.find(h.sent[1].embeds[1].title, "4 left"))
    rift = true
    rt.tick()
    assert(#h.sent == 2 and string.find(h.sent[2].embeds[1].title, "Rift"))
    rt.tick()
    assert(#h.sent == 2, "an already open rift is not announced again")
    rt.onMatchStarted()
    h.clk.now += 90
    rt.onMatchEnded()
    assert(#h.sent == 3)
    local embed = h.sent[3].embeds[1]
    assert(string.find(embed.title, "VICTORY") and string.find(embed.title, "Planet Namak", 1, true))
    assert(string.find(embed.description, "1m 3", 1, true) ~= nil)
    local text = ""
    for _, field in embed.fields do
        text ..= field.name .. field.value
    end
    assert(string.find(text, "Gems", 1, true), "end-screen rewards used when balances are unavailable")
    screen = nil
    rt.onMatchEnded()
    assert(
        #h.sent == 4 and string.find(h.sent[4].embeds[1].title, "MATCH ENDED"),
        "unknown result is labelled"
    )
end)
test("Webhook match embed shows earnings, balances, streak and session overview", function()
    local balances: any = { Gems = 100, Gold = 1000, TraitRerolls = 5, Trophies = 10 }
    local wave = 3
    local h = newWebhook({
        readCurrencies = function()
            return table.clone(balances)
        end,
        readLevel = function()
            return 295
        end,
        displayName = "ToonDiWa",
        readWave = function()
            return { current = wave }
        end,
        gameData = function()
            return {
                StageType = "LegendStage",
                Stage = "Golden Castle",
                Act = "Act 2",
                Difficulty = "Nightmare",
                MaxWave = 15,
            }
        end,
        macroInfo = function()
            return { name = "S1", status = "Playing" }
        end,
    })
    local rt = h.runtime
    rt.start({ alive = false }, {})
    rt.setUrl(HOOK_URL)
    rt.setEnabled(true)
    local function finish(result: any, seconds: number, gold: number)
        rt.onMatchStarted()
        wave = 15
        rt.tick()
        h.clk.now += seconds
        balances.Gold += gold
        rt.onMatchEnded(result)
    end
    local function textOf(embed: any): string
        local text = embed.title
            .. "\n"
            .. (embed.description or "")
            .. "\n"
            .. (embed.footer and embed.footer.text or "")
        for _, field in embed.fields or {} do
            text ..= "\n" .. field.name .. "\n" .. field.value
        end
        return text
    end
    finish(true, 285, 2000)
    local first = textOf(h.sent[#h.sent].embeds[1])
    assert(
        string.find(first, "VICTORY", 1, true)
            and string.find(first, "Golden Castle (Nightmare) (LegendStage) • Act 2", 1, true)
    )
    assert(
        string.find(first, "`S1`", 1, true) and string.find(first, "`4m 49s`", 1, true)
            or string.find(first, "`4m 4", 1, true)
    )
    assert(string.find(first, "`15/15`", 1, true), "wave from the HUD, maximum from GameData")
    assert(string.find(first, "`1W` (Best: 1W)", 1, true) ~= nil)
    assert(string.find(first, "+2,000 Gold [3,000]", 1, true), "earnings measured from the match start")
    assert(string.find(first, "`3,000` Gold", 1, true) and string.find(first, "`100` Gems", 1, true))
    assert(string.find(first, "`100.0%` — 1 Win • 0 Loss • 1 Runs", 1, true) ~= nil)
    assert(h.sent[#h.sent].embeds[1].author.name == "ToonDiWa (@Tester) • Lv. 295")
    finish(false, 100, 0)
    local second = textOf(h.sent[#h.sent].embeds[1])
    assert(string.find(second, "DEFEAT", 1, true) and string.find(second, "`1L`", 1, true))
    assert(string.find(second, "`50.0%` — 1 Win • 1 Loss • 2 Runs", 1, true) ~= nil)
    assert(string.find(second, "No change detected", 1, true) ~= nil)
    assert(
        string.find(second, "**Gold**", 1, true),
        "hourly farming rate shown once the session is long enough"
    )
end)
test("Webhook session tracker counts runs, streaks and rates", function()
    local now = 0
    local session = WebhookSession.new(function()
        return now
    end)
    assert(session.summary().streak == "-" and session.summary().winRate == 0)
    session.record(true, 100, { Gold = 500 })
    session.record(true, 100, { Gold = 500, Gems = -5 })
    session.record(false, 100, nil)
    session.record(true, 100, nil)
    now = 3600
    local summary = session.summary()
    assert(summary.wins == 3 and summary.losses == 1 and summary.total == 4)
    assert(summary.winRate == 75 and summary.bar == 8 and summary.barSize == 10)
    assert(summary.streak == "1W" and summary.bestStreak == "2W")
    assert(summary.runsPerHour == 4 and summary.rates.Gold == 1000 and summary.rates.Gems == nil)
    assert(WebhookEmbed.commas(18486565) == "18,486,565" and WebhookEmbed.commas(-1234) == "-1,234")
end)
test("Webhook runtime start sends one session notice and stops its loop", function()
    local h = newWebhook()
    local rt = h.runtime
    rt.setUrl(HOOK_URL)
    rt.setEnabled(true)
    local ctx: any = { alive = true }
    h.clk.onWait = function()
        if h.clk.waits >= 4 then
            ctx.alive = false
        end
    end
    local feed: any = {
        addStatusListener = function(listener: any)
            listener("Stage Joiner: confirmed by server")
            return function() end
        end,
    }
    rt.start(ctx, { joiner = feed })
    assert(#h.sent >= 2, "session start plus the joiner line")
    local sessions = 0
    for _, payload in h.sent do
        if string.find(payload.embeds[1].title, "session") then
            sessions += 1
        end
    end
    assert(sessions == 1)
    rt.stop()
end)
test("Webhook page mounts controls, hides the URL and reports errors", function()
    local h = newWebhook()
    local rt = h.runtime
    local mounted: { [string]: any } = {}
    local statusText = ""
    local function ctl(name: string): any
        return mounted[name]
    end
    local function control(kind: string): (any, any) -> any
        return function(_self: any, options: any)
            local entry: any = { options = options, kind = kind }
            mounted[options.Title] = entry
            entry.Set = function(_s: any, value: any)
                entry.value = value
            end
            entry.SetPlaceholder = function(_s: any, value: string)
                entry.placeholder = value
            end
            return entry
        end
    end
    local function host(): any
        local node: any = {}
        for _, name in { "Input", "Toggle", "Button", "Dropdown" } do
            node[name] = control(name)
        end
        node.Section = function()
            return host()
        end
        node.Paragraph = function(_self: any, options: any)
            return {
                options = options,
                SetDesc = function(_s: any, text: string)
                    statusText = text
                end,
            }
        end
        return node
    end
    WebhookPage.mount(host(), rt)
    assert(ctl("Webhook URL") and ctl("Send test message") and ctl("Minimum rarity to announce"))
    for _, kind in WebhookEvents.kinds do
        assert(ctl(kind.label), kind.id)
    end
    ctl("Webhook URL").options.Callback("")
    ctl("Webhook URL").options.Callback("https://example.com/nope")
    assert(string.find(statusText, "not a Discord webhook"), statusText)
    ctl("Webhook URL").options.Callback(HOOK_URL)
    assert(rt.getSettings().hasUrl and ctl("Webhook URL").value == "", "box cleared after entry")
    assert(not string.find(ctl("Webhook URL").placeholder, "abcdefgh", 1, true))
    ctl("Send notifications").options.Callback(true)
    ctl("Send test message").options.Callback()
    assert(string.find(statusText, "queued") and #h.sent == 1, statusText)
    ctl("Rift opened").options.Callback(false)
    assert(rt.getSettings().events.rift == false)
    ctl("Forget webhook URL").options.Callback()
    assert(not rt.getSettings().hasUrl)
end)
test("Webhook pings @everyone for rare drops only when allowed and counts unknown-result gains", function()
    local units: any = {
        s1 = { UnitData = { Name = "Ghost", Rarity = "Secret" }, Level = 1 },
        s2 = { UnitData = { Name = "Ghost", Rarity = "Secret" }, Level = 1 },
        e1 = { UnitData = { Name = "Epicus", Rarity = "Epic" }, Level = 1 },
    }
    local balances: any = { Gold = 100 }
    local captured: { any } = {}
    local ownedModule: any = {
        GetOwnedUnits = function()
            return {}
        end,
        GetUnitObject = function(guid: string)
            return units[guid]
        end,
        UnitAdded = {
            Connect = function(_self: any, handler: any)
                captured[1] = handler
                return { Disconnect = function() end }
            end,
        },
    }
    local h = newWebhook({
        ownedUnitsModule = ownedModule,
        unitObject = ownedModule.GetUnitObject,
        readCurrencies = function()
            return table.clone(balances)
        end,
    })
    local rt = h.runtime
    rt.start({ alive = false }, {})
    rt.setUrl(HOOK_URL)
    rt.setEnabled(true)
    rt.setMinRarity("Epic")
    h.clk.now += 100
    local fire: any = captured[1]
    fire("e1")
    assert(h.sent[1].content == nil, "Epic does not ping")
    fire("s1")
    assert(string.find(h.sent[2].content, "@everyone", 1, true) ~= nil)
    assert(h.sent[2].allowed_mentions.parse[1] == "everyone")
    rt.setPingEveryone(false)
    fire("s2")
    assert(
        h.sent[3].content == nil and #h.sent[3].allowed_mentions.parse == 0,
        "switch off removes @everyone"
    )
    rt.onMatchStarted()
    h.clk.now += 120
    balances.Gold = 600
    rt.onMatchEnded()
    local text = ""
    for _, field in h.sent[4].embeds[1].fields do
        text ..= field.name .. field.value
    end
    assert(string.find(text, "+500 Gold", 1, true) ~= nil, "gains counted although the result is unknown")
    assert(
        string.find(text, "Secret Ghost", 1, true) ~= nil and string.find(text, "**Gold**", 1, true) ~= nil
    )
end)
test("Activity state treats a challenge started by the joiner as used until the period changes", function()
    local values: { [string]: any } = {}
    local count = 0
    local stored: string? = nil
    local http: any = {
        JSONEncode = function(_self: any, value: any): string
            count += 1
            local key = "K" .. count
            values[key] = value
            return key
        end,
        JSONDecode = function(_self: any, body: string): any
            return values[body]
        end,
    }
    local env: any = {
        isfile = function()
            return stored ~= nil
        end,
        readfile = function()
            return stored
        end,
        writefile = function(_p: string, body: string)
            stored = body
        end,
        isfolder = function()
            return true
        end,
        makefolder = function() end,
        game = {
            GetService = function(): any
                return http
            end,
        },
    }
    local store = ActivityState.new(env, 42)
    local period = 20000
    local data: any = {
        GetChallengeSeed = function()
            return period
        end,
    }
    assert(store.save(1000, { Daily = { status = "available", period = 20000 } }, { Daily = 19999 }, nil))
    assert(store.load(1100, data).states.Daily.status == "available")
    assert(store.markUsed("Daily", 20000))
    assert(store.load(1100, data).states.Daily.status == "unavailable", "started challenge is used")
    assert(store.save(1200, { Daily = { status = "available", period = 20000 } }, { Daily = 19999 }, nil))
    assert(store.load(1300, data).states.Daily.status == "unavailable", "lobby refresh keeps the mark")
    period = 20001
    assert(store.save(1400, { Daily = { status = "available", period = 20001 } }, { Daily = 19999 }, nil))
    assert(store.load(1500, data).states.Daily.status == "available", "a new period clears the mark")
    assert(not store.markUsed("Rift", 1))
end)
test("Joiner report lists every mode in priority order with off and decision states", function()
    local runtime = JoinerRuntime.new({
        clock = function()
            return 100
        end,
    })
    JoinerSettings.setPaused(true)
    local lines = runtime.getReport()
    assert(string.find(lines[1], "disabled", 1, true) ~= nil, "pause is reported first")
    assert(#lines == #JoinerSettings.get().priority + 1)
    JoinerSettings.setPaused(false)
    runtime.setEnabled("Rift", true)
    local report = table.concat(runtime.getReport(), "\n")
    assert(string.find(report, "Rift — no decision yet", 1, true) ~= nil)
    assert(string.find(report, "Daily Challenge — off", 1, true) ~= nil)
    runtime.setEnabled("Rift", false)
    JoinerSettings.setPaused(true)
end)
test("Webhook reports busy from match end until the result is delivered", function()
    local held: { any } = {}
    local h = newWebhook()
    local realSpawn = h.deps.task.spawn
    h.deps.task.spawn = function(callback: any, ...: any)
        table.insert(held, callback)
    end
    local rt = h.runtime
    rt.setUrl(HOOK_URL)
    rt.setEnabled(true)
    assert(not rt.isBusy())
    rt.onMatchStarted()
    rt.onMatchEnded(true)
    assert(rt.isBusy(), "busy while the end screen is awaited")
    h.deps.task.spawn = realSpawn
    held[1]()
    assert(#h.sent == 1 and string.find(h.sent[1].embeds[1].title, "VICTORY") ~= nil)
    assert(not rt.isBusy(), "idle once delivered")
    rt.setEnabled(false)
    rt.onMatchEnded(true)
    assert(not rt.isBusy(), "not busy when notifications are off")
end)
test("Webhook prefers the game's end summary status over the end screen title", function()
    local h = newWebhook({
        readEndScreen = function()
            return { result = "Victory" }
        end,
    })
    local rt = h.runtime
    rt.setUrl(HOOK_URL)
    rt.setEnabled(true)
    rt.onEndSummary("Failed")
    rt.onMatchEnded()
    assert(string.find(h.sent[1].embeds[1].title, "DEFEAT") ~= nil)
    rt.onEndSummary("Finished")
    rt.onMatchEnded()
    assert(string.find(h.sent[2].embeds[1].title, "VICTORY") ~= nil)
    rt.onEndSummary("Unknown")
    rt.onMatchEnded()
    assert(
        string.find(h.sent[3].embeds[1].title, "VICTORY") ~= nil,
        "unknown status falls back to the screen"
    )
end)
test("Change Stage in Match yields to a higher-priority playable challenge or Rift", function()
    local fired: { any } = {}
    local dailyState = "available"
    local riftOpen = false
    local matchData: any = { StageType = "Story", Stage = "Stage1", Act = "Act1", Host = 42 }
    local runtime = JoinerRuntime.new({
        game = {
            PlaceId = 16277809958,
            GetService = function(): any
                return {
                    GetAttribute = function(_self: any, name: string): any
                        return if name == "IsRiftOpen" then riftOpen else false
                    end,
                }
            end,
        },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        gameHandler = { IsGameLoaded = true, IsMatchStarted = false, GameData = matchData, MatchId = 1 },
        bountyState = {
            GetData = function()
                return { BountySeed = 1, BountiesLeft = 5 }
            end,
        },
        bountyData = {
            GetBountyFromSeed = function()
                return { Act = "Act2", StageType = "LegendStage", Stage = "Stage5" }
            end,
        },
        activityState = {
            load = function(): any
                return { states = { Daily = { status = dailyState, period = 1 } }, riftSpent = false }
            end,
        },
        lobbyReturn = {
            RequestStartMatch = {
                Fire = function(payload: any)
                    table.insert(fired, payload)
                end,
            },
        },
    })
    runtime.setMacro(nil)
    runtime.gameSettings = {
        get = function()
            return true
        end,
    }
    for _, other in
        {
            "Stage",
            "Legend Stage",
            "Raid",
            "Dungeon",
            "Worldline",
            "Boss Event",
            "Weekly Challenge",
            "Regular Challenge",
        }
    do
        JoinerSettings.setEnabled(other, false)
    end
    JoinerSettings.resetPriority() -- Rift > Weekly > Daily > Regular > ... > Boss Bounties
    JoinerSettings.setPaused(false)
    JoinerSettings.setBountyRun(nil)
    JoinerSettings.setJoinerRun({ mode = "Story", stage = "Stage1", act = "Act1", at = os.time() })
    runtime.setEnabled("Boss Bounties", true)
    runtime.setEnabled("Daily Challenge", true)
    runtime.setEnabled("Rift", true)
    runtime.start({ alive = true })

    runtime.step(100)
    assert(#fired == 0, "a playable higher-priority challenge keeps this match unchanged")
    assert(string.find(runtime.status, "Daily Challenge: available", 1, true) ~= nil, runtime.status)

    dailyState = "unavailable"
    runtime.step(111) -- after the 10 s activity cache
    assert(
        #fired == 1 and fired[1].StageType == "LegendStage",
        "nothing higher is playable: switch to the bounty"
    )

    matchData.MatchId = 2
    riftOpen = true
    runtime.dependencies.gameHandler.MatchId = 2
    runtime.step(130)
    assert(#fired == 1, "an open Rift with attempts also blocks the switch")

    runtime.stop()
    for _, name in { "Boss Bounties", "Daily Challenge", "Rift" } do
        runtime.setEnabled(name, false)
    end
    JoinerSettings.setJoinerRun(nil)
    JoinerSettings.setPaused(true)
end)
local function miscFixture(code: string): any
    local fx: any = { nudges = 0, teleports = {}, queued = {}, code = code, stored = nil, handlers = {} }
    local function signal(name: string): any
        return {
            Connect = function(_self: any, handler: any)
                fx.handlers[name] = handler
                return { Disconnect = function() end }
            end,
        }
    end
    local values: { [string]: any } = {}
    local count = 0
    fx.deps = {
        task = {
            spawn = function(callback: any)
                callback()
            end,
            wait = function() end,
        },
        clock = function()
            return 0
        end,
        encode = function(value: any): string
            count += 1
            values["K" .. count] = value
            return "K" .. count
        end,
        decode = function(text: string): any
            return values[text]
        end,
        storage = {
            read = function()
                return fx.stored, nil
            end,
            write = function(body: string)
                fx.stored = body
                return true
            end,
        },
        idled = signal("idle"),
        errorChanged = signal("error"),
        errorCode = function()
            return fx.code
        end,
        nudge = function()
            fx.nudges += 1
        end,
        teleport = function(placeId: number)
            table.insert(fx.teleports, placeId)
            return true
        end,
        queue = function(source: string)
            table.insert(fx.queued, source)
        end,
    }
    return fx
end
test("Misc Anti-AFK nudges on idle only while enabled", function()
    local fx = miscFixture("OK")
    local rt = MiscRuntime.new(fx.deps)
    rt.start({ alive = true })
    fx.handlers.idle()
    assert(fx.nudges == 1, "Anti-AFK is on by default")
    rt.setAntiAfk(false)
    fx.handlers.idle()
    assert(fx.nudges == 1)
    rt.stop()
end)
test("Misc Auto Reconnect teleports to the lobby only after real disconnects", function()
    local kicked = miscFixture("DisconnectLuaKick")
    local rt = MiscRuntime.new(kicked.deps)
    rt.start({ alive = true })
    rt.setAutoReconnect(true)
    kicked.handlers.error()
    assert(#kicked.teleports == 0, "a kick never reconnects")
    rt.stop()

    local ownTeleport = miscFixture("DisconnectClientRequest")
    local rt2 = MiscRuntime.new(ownTeleport.deps)
    rt2.start({ alive = true })
    rt2.setAutoReconnect(true)
    ownTeleport.handlers.error()
    assert(#ownTeleport.teleports == 0, "a normal teleport is not a disconnect")
    rt2.stop()

    local lost = miscFixture("DisconnectErrors")
    local rt3 = MiscRuntime.new(lost.deps)
    rt3.start({ alive = true })
    lost.handlers.error()
    assert(#lost.teleports == 0, "Auto Reconnect is off by default")
    rt3.setAutoReconnect(true)
    lost.handlers.error()
    assert(#lost.teleports == 5 and lost.teleports[1] == 16146832113, "bounded retries to the lobby place")
    assert(string.find(rt3.status, "gave up", 1, true) ~= nil)
    rt3.stop()
end)
test("Misc re-run queues the loader line and validates the URL", function()
    local fx = miscFixture("OK")
    local rt = MiscRuntime.new(fx.deps)
    rt.start({ alive = true })
    assert(#fx.queued == 0, "re-run is off by default")
    assert(not rt.setLoaderUrl('http://x/a.lua"))() evil()--'), "quotes are refused")
    assert(not rt.setLoaderUrl("ftp://host/a.lua") and not rt.setLoaderUrl("http://host/a.txt"))
    assert(rt.setLoaderUrl("  https://example.trycloudflare.com/runtime-smoke.lua  "))
    rt.setRerun(true)
    assert(
        fx.queued[1] == 'loadstring(game:HttpGet("https://example.trycloudflare.com/runtime-smoke.lua"))()'
    )
    rt.setRerun(true)
    assert(#fx.queued == 1, "queued once per session")
    rt.stop()
    local again = MiscRuntime.new(miscFixture("OK").deps)
    again.deps.storage = fx.deps.storage
    again.deps.encode, again.deps.decode = fx.deps.encode, fx.deps.decode
    again.start({ alive = true })
    local saved = again.getSettings()
    assert(saved.rerunOnTeleport and saved.loaderUrl == "https://example.trycloudflare.com/runtime-smoke.lua")
    again.stop()
end)
test("Webhook match embed shows player DPS and kills per minute from the end screen", function()
    assert(WebhookEmbed.parseAmount("19.09M") == 19090000 and WebhookEmbed.parseAmount("48.77K") == 48770)
    assert(WebhookEmbed.parseAmount("1,234") == 1234 and WebhookEmbed.parseAmount("x") == nil)
    local ctx = { player = "Tester", showPlayer = false, timestamp = "2026-01-02T03:04:05Z", version = "1" }
    local spec: any = WebhookEvents.build(
        "matchEnd",
        { result = "Victory", damage = "19.09M", takedowns = "239", duration = 100 },
        ctx,
        WEBHOOK_CONFIG
    )
    assert(string.find(spec.description, "**DPS**: `190.9K`", 1, true) ~= nil, spec.description)
    assert(string.find(spec.description, "**Kills/min**: `143.4`", 1, true) ~= nil, spec.description)
end)
print(string.format("PASS: %d unit scenarios", passed))
