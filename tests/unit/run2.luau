--!strict
-- Purpose: webhook, activity, joiner report, change stage and misc scenarios (split from run.luau so each file stays within the type checker limits); Input: pure modules; Output: assertion summary; Dependencies: src.
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
    assert(string.find(report, "⏳ Rift — on", 1, true) ~= nil)
    assert(string.find(report, "❌ Daily Challenge — off", 1, true) ~= nil)
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
local WEBHOOK_SUMMARY: any = nil
test("Webhook match embed shows the game's Unit Contribution rows", function()
    assert(WebhookEmbed.parseAmount("19.09M") == 19090000 and WebhookEmbed.parseAmount("48.77K") == 48770)
    -- Row shape observed live on the game's Summary page; nested under an unknown key on purpose.
    local summary: any = {
        Status = "Finished",
        Stats = {
            Players = {
                {
                    Units = {
                        {
                            DisplayName = "Iscanur (Pride)",
                            Rarity = "Vanguard",
                            Damage = 5752468,
                            Takedowns = 235,
                            PlacementCount = 1,
                            TimeDeployed = 297.49,
                            YenSpent = 0,
                        },
                        {
                            DisplayName = "Wrath (Assault)",
                            Rarity = "Exclusive",
                            Damage = 6079957,
                            Takedowns = 62,
                            PlacementCount = 10,
                            TimeDeployed = 329.4,
                            YenSpent = 0,
                        },
                    },
                },
            },
        },
    }
    local rows = WebhookRuntime.contributionRows(summary)
    assert(#rows == 2 and rows[1].name == "Wrath (Assault)", "sorted by damage")
    assert(#WebhookRuntime.contributionRows({ Status = "Finished" }) == 0)
    WEBHOOK_SUMMARY = summary
end)
test("Webhook Unit Contribution field layout and removed DPS lines", function()
    local summary: any = WEBHOOK_SUMMARY
    local h = newWebhook()
    local rt = h.runtime
    rt.setUrl(HOOK_URL)
    rt.setEnabled(true)
    rt.onEndSummary("Finished", summary)
    rt.onMatchEnded()
    local embed = h.sent[1].embeds[1]
    local field: any = nil
    for _, f in embed.fields do
        if string.find(f.name, "Unit Contribution", 1, true) then
            field = f.value
        end
    end
    assert(field, "contribution field present")
    assert(string.find(field, "👑 **Wrath (Assault)** `x10`", 1, true) ~= nil, field)
    assert(
        string.find(field, "**51.4%**", 1, true) ~= nil and string.find(field, "18.5K/s", 1, true) ~= nil,
        field
    )
    assert(
        string.find(field, "**48.6%**", 1, true) ~= nil and string.find(field, "`235`", 1, true) ~= nil,
        field
    )
    assert(string.find(field, "Match total", 1, true) ~= nil)
    assert(string.find(embed.description or "", "DPS", 1, true) == nil, "player DPS line removed")
    assert(string.find(embed.description or "", "Kills/min", 1, true) == nil, "kills per minute removed")
end)
test("Settings of every key live in one profile file per game and player; old files move into it", function()
    local files: { [string]: string } = {}
    -- A tiny JSON stand-in: tables are kept in a registry and referred to by text.
    local registry: { [string]: any } = {}
    local count = 0
    local http = {
        JSONEncode = function(_self: any, value: any): string
            count += 1
            local id = "json#" .. tostring(count)
            registry[id] = value
            return id
        end,
        JSONDecode = function(_self: any, text: string): any
            local value = registry[text]
            if value == nil then
                error("bad json")
            end
            return value
        end,
    }
    local env: any = {
        isfolder = function()
            return true
        end,
        makefolder = function() end,
        isfile = function(p: string)
            return files[p] ~= nil
        end,
        writefile = function(p: string, s: string)
            files[p] = s
        end,
        readfile = function(p: string)
            return files[p]
        end,
        delfile = function(p: string)
            files[p] = nil
        end,
        game = {
            GetService = function(_self: any, name: string): any
                if name == "Players" then
                    return { LocalPlayer = { Name = "iMZulie" } }
                end
                return http
            end,
        },
    }
    files["ViperHubNextGen/AnimeVanguardsJoiner.json"] = http:JSONEncode({ paused = false })
    assert(FileStorage.useProfile(env, "AnimeVanguards") == "ViperHubNextGen/AnimeVanguards_iMZulie.json")
    local joiner = assert(FileStorage.new(env, "AnimeVanguardsJoiner"))
    local misc = assert(FileStorage.new(env, "AnimeVanguardsMisc"))
    local body = assert(joiner.read())
    assert(http:JSONDecode(body).paused == false, "an old per-key file is read until it is saved")
    assert(misc.read() == nil, "a key with no file and no section is empty")
    assert(joiner.write(http:JSONEncode({ paused = true })))
    assert(misc.write(http:JSONEncode({ fps = 30 })))
    assert(files["ViperHubNextGen/AnimeVanguardsJoiner.json"] == nil, "the old file is removed once moved")
    local document = http:JSONDecode(files["ViperHubNextGen/AnimeVanguards_iMZulie.json"])
    assert(document.sections.AnimeVanguardsJoiner.paused == true, "both keys live in the one file")
    assert(document.sections.AnimeVanguardsMisc.fps == 30)
    assert(http:JSONDecode(assert(joiner.read())).paused == true, "a key reads its own section back")
    files["ViperHubNextGen/AnimeVanguards_iMZulie.json"] = "not json"
    local _, readError = joiner.read()
    assert(readError ~= nil, "a damaged profile is reported, not read as empty")
    assert(not misc.write(http:JSONEncode({ fps = 1 })), "and never overwritten")
end)
print(string.format("PASS: %d unit scenarios (part 2)", passed))
