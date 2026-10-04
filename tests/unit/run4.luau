--!strict
-- Purpose: Odyssey Adventure adapter and joiner integration scenarios; Input: pure modules with mocks; Output: assertion summary; Dependencies: src.
local AdventureAdapter = require("../../src/games/AnimeVanguards/Adventure/Adapter")
local AdventureCatalog = require("../../src/games/AnimeVanguards/Adventure/Catalog")
local AdventureDetect = require("../../src/games/AnimeVanguards/Adventure/Detect")
local AdventureSettings = require("../../src/games/AnimeVanguards/Adventure/Settings")
local JoinerRuntime = require("../../src/games/AnimeVanguards/Joiner/Runtime")
local JoinerSettings = require("../../src/games/AnimeVanguards/Joiner/Settings")
local passed = 0
local function test(name: string, callback: () -> ())
    local ok, message = pcall(callback)
    assert(ok, name .. ": " .. tostring(message))
    passed += 1
end

-- A fake special events client: remotes record what was fired and let the test push the Adventure state.
local function fixture(): any
    local fx: any = { fired = {}, handler = nil, disconnected = 0, now = 100 }
    local function remote(name: string): any
        return {
            Fire = function(payload: any)
                table.insert(fx.fired, { name = name, payload = payload })
            end,
        }
    end
    fx.events = {
        RequestAdventureState = remote("RequestAdventureState"),
        SetAdventureLoadout = remote("SetAdventureLoadout"),
        StartOdysseyAdventure = remote("StartOdysseyAdventure"),
        AdventureFullStateChanged = {
            On = function(handler: any)
                fx.handler = handler
                return function()
                    fx.disconnected += 1
                end
            end,
        },
    }
    local catalog = AdventureCatalog.fromModules(nil)
    fx.settings = AdventureSettings.new(catalog, {})
    fx.adapter = AdventureAdapter.new({
        specialEvents = fx.events,
        catalog = catalog,
        settings = fx.settings,
        clock = function()
            return fx.now
        end,
    })
    fx.push = function(characters: any, owns: boolean?)
        fx.handler({ Characters = characters, OwnsLoadoutSlot2 = owns == true })
    end
    return fx
end

local function count(fx: any, name: string): number
    local n = 0
    for _, call in fx.fired do
        if call.name == name then
            n += 1
        end
    end
    return n
end

local ISCANUR = { CharacterName = "Iscanur (Pride)", UnlockedPowerIds = { 1, 12 }, Loadout = { Slot1 = 1 } }

test("Adventure catalog maps power names to the game's ids", function()
    local catalog = AdventureCatalog.fromModules(nil)
    assert(
        catalog.powerIds["Full Deck"] == 1
            and catalog.powerIds.Memorized == 12
            and catalog.powerIds["Power Trip"] == 14
    )
    local live = AdventureCatalog.fromModules({
        powers = { POWERS = { { Name = "Full Deck", Id = 7 }, { Name = "Flight" } } },
    })
    assert(live.powerIds["Full Deck"] == 7 and live.powerIds.Flight == nil and live.powers[1] == "Full Deck")
end)

test("Adventure detect recognizes Adventure match data only", function()
    assert(not AdventureDetect.isAdventureMatch(nil) and not AdventureDetect.isAdventureMatch("x"))
    assert(not AdventureDetect.isAdventureMatch({ StageType = "Story" }))
    assert(AdventureDetect.isAdventureMatch({ StageType = "OdysseyAdventure" }))
    assert(
        AdventureDetect.isAdventureMatch({ Adventure = {} })
            and AdventureDetect.isAdventureMatch({ IsAdventure = true })
    )
end)

test("Adventure adapter waits for the game's state, then plans a validated start", function()
    local fx = fixture()
    local plan, reason = fx.adapter.plan()
    assert(plan == nil and string.find(reason or "", "waiting", 1, true) ~= nil)
    assert(
        fx.handler ~= nil and count(fx, "RequestAdventureState") == 1,
        "subscribed and asked for the state"
    )
    fx.adapter.plan()
    assert(count(fx, "RequestAdventureState") == 1, "the request is rate limited")
    fx.now = 110
    fx.adapter.plan()
    assert(count(fx, "RequestAdventureState") == 2)

    fx.push({ ISCANUR })
    fx.settings.set("slot1", "Full Deck")
    fx.settings.set("slot2", "Memorized")
    local ready = fx.adapter.plan()
    assert(ready and ready.character == "Iscanur (Pride)" and ready.slot1 == 1 and ready.slot2 == nil)
    assert(#ready.notes == 1 and string.find(ready.notes[1], "Loadout Slot 2 is not owned", 1, true) ~= nil)

    fx.push({ ISCANUR }, true)
    local both = fx.adapter.plan()
    assert(both and both.slot1 == 1 and both.slot2 == 12 and #both.notes == 0)

    fx.settings.set("slot1", "Jack Pot")
    local locked = fx.adapter.plan()
    assert(
        locked
            and locked.slot1 == nil
            and string.find(locked.notes[1], "Jack Pot is not unlocked", 1, true) ~= nil
    )

    fx.settings.set("character", "Luce (Hacker)")
    local missing, why = fx.adapter.plan()
    assert(missing == nil and string.find(why or "", "not available on this account", 1, true) ~= nil)
end)

test("Adventure adapter sends the loadout only when it changed, then starts with it", function()
    local fx = fixture()
    fx.adapter.connect()
    fx.push({ ISCANUR }, true)
    fx.settings.set("slot1", "Full Deck")
    fx.settings.set("slot2", "None")
    local same = fx.adapter.plan()
    assert(same and fx.adapter.start(same))
    assert(count(fx, "SetAdventureLoadout") == 0 and count(fx, "StartOdysseyAdventure") == 1)
    local start = fx.fired[#fx.fired].payload
    assert(
        start.LoadoutProvided == true
            and start.CharacterName == "Iscanur (Pride)"
            and start.Slot1 == 1
            and start.Slot2 == nil
    )

    fx.settings.set("slot2", "Memorized")
    local changed = fx.adapter.plan()
    assert(changed and fx.adapter.start(changed))
    assert(count(fx, "SetAdventureLoadout") == 1 and count(fx, "StartOdysseyAdventure") == 2)
    assert(fx.fired[#fx.fired - 1].payload.Slot2 == 12, "the loadout is sent right before the start")
    assert(not fx.adapter.start(nil))

    fx.adapter.stop()
    fx.adapter.stop()
    assert(fx.disconnected == 1, "stop disconnects once")
end)

local function lobbyGame(): any
    return {
        PlaceId = 16146832113,
        GetService = function(): any
            return {
                GetAttribute = function(): any
                    return false
                end,
            }
        end,
    }
end

test("Joiner starts Odyssey Adventure from the lobby through the adapter and respects priority", function()
    local fx = fixture()
    fx.adapter.connect()
    fx.push({ ISCANUR })
    local runtime = JoinerRuntime.new({
        game = lobbyGame(),
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        lobby = { IsHosting = false, IsInLobby = false },
    })
    runtime.setAdventure(fx.adapter)
    for _, name in { "Rift", "Boss Bounties", "Stage" } do
        JoinerSettings.setEnabled(name, false)
    end
    JoinerSettings.resetPriority()
    assert(JoinerSettings.get().priority[14] == "Odyssey Adventure", "last by default")
    JoinerSettings.setPaused(false)
    assert(not runtime.isEnabled("Odyssey Adventure"))
    runtime.setEnabled("Odyssey Adventure", true)
    assert(
        runtime.isEnabled("Odyssey Adventure") and JoinerSettings.get().enabled["Odyssey Adventure"] == true
    )
    runtime.start({ alive = true })

    runtime.step(100)
    assert(count(fx, "StartOdysseyAdventure") == 1, runtime.status)
    assert(runtime.confirmed ~= nil and runtime.confirmed.mode == "OdysseyAdventure")
    assert(string.find(runtime.status, "Odyssey Adventure: start sent", 1, true) ~= nil, runtime.status)

    runtime.step(101)
    assert(count(fx, "StartOdysseyAdventure") == 1, "no second start while the first is in flight")

    runtime.stop()
    runtime.setEnabled("Odyssey Adventure", false)
    JoinerSettings.setPaused(true)
end)

test("Joiner reports why Odyssey Adventure is not started and stays out of Adventure matches", function()
    local fx = fixture()
    local runtime = JoinerRuntime.new({
        game = lobbyGame(),
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        lobby = { IsHosting = false, IsInLobby = false },
    })
    JoinerSettings.setPaused(false)
    runtime.setEnabled("Odyssey Adventure", true)
    runtime.start({ alive = true })
    runtime.step(100)
    assert(runtime.confirmed == nil and count(fx, "StartOdysseyAdventure") == 0, "no adapter: nothing starts")
    runtime.setAdventure(fx.adapter)
    runtime.step(200)
    assert(
        runtime.confirmed == nil and count(fx, "StartOdysseyAdventure") == 0,
        "no state yet: nothing starts"
    )
    runtime.stop()
    runtime.setEnabled("Odyssey Adventure", false)

    local matchData: any = { StageType = "OdysseyAdventure" }
    local inMatch = JoinerRuntime.new({
        game = { PlaceId = 16277809958, GetService = lobbyGame().GetService },
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        gameHandler = { IsGameLoaded = true, GameData = matchData },
    })
    inMatch.start({ alive = true })
    inMatch.returnOnMatchEnd = true
    inMatch.step(100)
    assert(inMatch.returnOnMatchEnd == false, "the joiner never sends an Adventure match back to the lobby")
    inMatch.stop()
    JoinerSettings.setPaused(true)
end)

print(string.format("PASS: %d unit scenarios (part 4)", passed))
