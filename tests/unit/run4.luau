--!strict
-- Purpose: Odyssey Adventure adapter and joiner integration scenarios; Input: pure modules with mocks; Output: assertion summary; Dependencies: src.
local AdventureAdapter = require("../../src/games/AnimeVanguards/Adventure/Adapter")
local AdventureCatalog = require("../../src/games/AnimeVanguards/Adventure/Catalog")
local AdventureDetect = require("../../src/games/AnimeVanguards/Adventure/Detect")
local AdventureChoice = require("../../src/games/AnimeVanguards/Adventure/Choice")
local AdventureRuntime = require("../../src/games/AnimeVanguards/Adventure/Runtime")
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
            Fire = function(...: any)
                -- Like the game: RequestAdventureState takes no arguments at all, not even nil.
                if name == "RequestAdventureState" and select("#", ...) > 0 then
                    error("[AV-Blink] too many arguments")
                end
                table.insert(fx.fired, { name = name, payload = (...) })
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
    assert(
        not AdventureDetect.isAdventureMatch({ StageType = "Odyssey" }),
        "regular Odyssey is not Adventure"
    )
    assert(not AdventureDetect.isAdventureMatch({ StageType = "Odyssey", SubMode = "Limitless" }))
    assert(AdventureDetect.isAdventureMatch({ StageType = "Odyssey", SubMode = "Adventure" }))
    assert(AdventureDetect.isAdventureMatch({
        StageType = "Odyssey",
        AdventureFloor = 2,
        AdventureRoomKind = "Elite",
    }))
    assert(AdventureDetect.isAdventureMatch({ AdventureData = {} }))
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
    local pressed: { any } = {}
    local hosting: any = { IsHosting = false, IsInLobby = false }
    local runtime = JoinerRuntime.new({
        game = lobbyGame(),
        task = { spawn = function() end, wait = function() end },
        clock = function()
            return 100
        end,
        userId = 42,
        lobby = hosting,
        network = {
            StartMatch = {
                Fire = function()
                    table.insert(pressed, true)
                end,
            },
        },
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
    assert(string.find(runtime.status, "Odyssey Adventure: room requested", 1, true) ~= nil, runtime.status)
    assert(runtime.confirmed.startSent == nil, "Start is pressed only once the host room exists")

    runtime.step(101)
    assert(count(fx, "StartOdysseyAdventure") == 1, "no second start while the first is in flight")
    runtime.step(130)
    assert(runtime.confirmed ~= nil, "still waiting for the host room after 30 s")
    assert(#pressed == 0, "Start is not pressed before the room exists")
    hosting.IsHosting = true
    runtime.step(131)
    assert(#pressed == 1 and runtime.confirmed.startSent ~= nil, "Start is pressed once the room exists")
    assert(string.find(runtime.status, "Start sent", 1, true) ~= nil, runtime.status)

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

    local matchData: any = { StageType = "Odyssey", AdventureFloor = 2 }
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

test("Adventure picks the offered basic card with the highest priority number", function()
    local offer: any = {
        { CardName = "Slayer Rounds", Rarity = "Rare", OfferedLevel = 1 },
        { CardName = "Adrenaline Shot", Rarity = "Rare", OfferedLevel = 3 },
        { CardName = "Boxing Gloves", Rarity = "Rare", OfferedLevel = 3 },
    }
    local catalog = AdventureCatalog.fromModules(nil)
    local ranks = AdventureSettings.new(catalog, {}).get("cardPriority")
    assert(
        AdventureChoice.pickBasicCard(offer, ranks) == 2,
        "default order: Adrenaline Shot before Boxing Gloves"
    )
    assert(AdventureChoice.pickBasicCard(offer, { ["Boxing Gloves"] = 9, ["Slayer Rounds"] = 5 }) == 3)
    assert(AdventureChoice.pickBasicCard(offer, { ["Slayer Rounds"] = 50 }) == 1)
    assert(AdventureChoice.pickBasicCard(offer, {}) == 1, "unknown cards tie at 0 and keep the game's order")
    assert(
        AdventureChoice.pickBasicCard({}, ranks) == nil and AdventureChoice.pickBasicCard(nil, ranks) == nil
    )
    assert(AdventureChoice.pickBasicCard({ "bad", { CardName = 5 }, { CardName = "Ambush" } }, ranks) == 3)
end)

test("Adventure runtime picks the basic card only in Adventure matches with the switch on", function()
    local catalog = AdventureCatalog.fromModules(nil)
    local settings = AdventureSettings.new(catalog, {})
    local now = 100
    local inAdventure = true
    local box: any = {}
    local function call(offerPayload: any)
        local callback: any = box.handler
        callback(offerPayload)
    end
    local picks: { any } = {}
    local delayed: { any } = {}
    local disconnected = 0
    local runtime = AdventureRuntime.new(function()
        return settings
    end, {
        clock = function()
            return now
        end,
        task = {
            delay = function(_seconds: number, callback: any)
                table.insert(delayed, callback)
            end,
        },
        isAdventure = function()
            return inAdventure
        end,
        events = {
            CardPickBasicOffer = {
                On = function(callback: any)
                    box.handler = callback
                    return function()
                        disconnected += 1
                    end
                end,
            },
            CardPickPick = {
                Fire = function(payload: any)
                    table.insert(picks, payload)
                end,
            },
        },
    })
    local function run()
        for _, callback in delayed do
            local pending: any = callback
            pending()
        end
        delayed = {}
    end
    local offer: any = {
        Options = {
            { CardName = "Slayer Rounds", Rarity = "Rare" },
            { CardName = "Adrenaline Shot", Rarity = "Rare" },
            { CardName = "Boxing Gloves", Rarity = "Rare" },
        },
    }
    assert(runtime.start() and box.handler ~= nil)

    call(offer)
    run()
    assert(#picks == 0, "switch is off: the player picks")
    settings.set("autoBasicCard", true)
    inAdventure = false
    call(offer)
    run()
    assert(#picks == 0, "outside an Adventure match nothing is picked")
    inAdventure = true
    call(offer)
    assert(#picks == 0, "the pick waits a moment first")
    run()
    assert(#picks == 1 and picks[1].Choice == 2, "default priority: Adrenaline Shot")
    assert(
        runtime.picked == 1 and string.find(runtime.status, "picked Adrenaline Shot", 1, true) ~= nil,
        runtime.status
    )

    call(offer)
    run()
    assert(#picks == 1, "an identical offer right away is ignored")
    now = 110
    settings.swap("cardPriority", "Boxing Gloves", "Adrenaline Shot")
    call(offer)
    run()
    assert(#picks == 2 and picks[2].Choice == 3, "later offers follow the saved priority")
    call({ Options = {} })
    assert(string.find(runtime.status, "no valid card", 1, true) ~= nil)

    runtime.stop()
    runtime.stop()
    assert(disconnected == 1)
    call(offer)
    run()
    assert(#picks == 2, "stopped: nothing is picked")
    assert(not AdventureRuntime.new(function()
        return settings
    end, { events = {} }).start(), "no match events (lobby): not started")
end)

test(
    "Adventure picks the next room by the floor priorities and switches lists at the chosen floor",
    function()
        local offer: any = {
            { Index = 1, AdventureRoomKind = "Battle", AdventureFloor = 12 },
            { Index = 2, AdventureRoomKind = "Elite", AdventureFloor = 12 },
            { Index = 3, AdventureRoomKind = "Challenge", AdventureFloor = 12 },
        }
        local first: any = { Treasure = 5, Elite = 4, Shop = 3, Battle = 2, Boss = 1 }
        local second: any = { Battle = 5, Elite = 1 }
        assert(AdventureChoice.pickRoom(offer, first, second, 30) == 2, "first list: Elite over Battle")
        assert(
            AdventureChoice.pickRoom(offer, first, second, 12) == 1,
            "from the chosen floor the second list applies"
        )
        assert(
            AdventureChoice.pickRoom({ { Index = 7, AdventureRoomKind = "Challenge" } }, first, second, 30)
                == 7
        )
        assert(AdventureChoice.pickRoom(nil, first, second, 30) == nil)
        local bossOffer: any = {
            { Index = 1, AdventureRoomKind = "LichSovereign", BossRoom = true, AdventureFloor = 30 },
            { Index = 2, AdventureRoomKind = "Battle", AdventureFloor = 30 },
        }
        assert(
            AdventureChoice.pickRoom(bossOffer, { Boss = 9, Battle = 1 }, second, 99) == 1,
            "a boss room counts as Boss"
        )
        assert(AdventureChoice.pickRoom(bossOffer, { Boss = 0, Battle = 1 }, second, 99) == 2)
        local withTreasure: any = {
            { Index = 1, AdventureRoomKind = "Treasure", AdventureFloor = 17 },
            { Index = 2, AdventureRoomKind = "Battle", AdventureFloor = 17 },
            { Index = 3, AdventureRoomKind = "Elite", AdventureFloor = 17 },
            { Index = 4, AdventureRoomKind = "Battle", AdventureFloor = 17 },
        }
        assert(AdventureChoice.pickRoom(withTreasure, first, second, 99) == 1, "unfiltered: Treasure")
        assert(
            AdventureChoice.pickRoom(withTreasure, first, second, 99, { [2] = true, [3] = true }) == 3,
            "only reachable rooms"
        )
        assert(AdventureChoice.pickRoom(withTreasure, first, second, 99, {}) == nil, "nothing reachable")
        assert(AdventureChoice.pickRoom(nil, first, second, 30) == nil)
        local defaults = AdventureSettings.new(AdventureCatalog.fromModules(nil), {})
        assert(
            AdventureChoice.pickRoom(
                offer,
                defaults.get("floorPriority"),
                defaults.get("secondFloorPriority"),
                defaults.get("secondPriorityFloor")
            ) == 2
        )
    end
)

test("Adventure runtime chooses the next room only in Adventure matches with Auto Route Atlas on", function()
    local settings = AdventureSettings.new(AdventureCatalog.fromModules(nil), {})
    local box: any = {}
    local chosen: { any } = {}
    local pending: { any } = {}
    local runtime = AdventureRuntime.new(function()
        return settings
    end, {
        clock = function()
            return 50
        end,
        task = {
            delay = function(_seconds: number, callback: any)
                table.insert(pending, callback)
            end,
        },
        isAdventure = function()
            return true
        end,
        closeMap = function()
            box.closed = (box.closed or 0) + 1
        end,
        mapRelay = {
            OnSnapshot = function(callback: any)
                box.snapshot = callback
                return function() end
            end,
        },
        events = {
            CardPickBasicOffer = { On = function() end },
            SelectRoomSelectionStarted = {
                On = function(callback: any)
                    box.room = callback
                    return function() end
                end,
            },
            VoteCast = {
                Fire = function(payload: any)
                    table.insert(chosen, payload)
                end,
            },
            MapRequestSnapshot = {
                Fire = function(...: any)
                    box.requested = (box.requested or 0) + select("#", ...) + 1000
                end,
            },
        },
    })
    local function flush()
        for _, callback in pending do
            local run: any = callback
            run()
        end
        pending = {}
    end
    local function offerRooms()
        local callback: any = box.room
        callback({
            Options = {
                { Index = 1, AdventureRoomKind = "Treasure", AdventureFloor = 12 },
                { Index = 2, AdventureRoomKind = "Battle", AdventureFloor = 12 },
                { Index = 3, AdventureRoomKind = "Elite", AdventureFloor = 12 },
            },
        })
    end
    assert(runtime.start() and box.room ~= nil)
    offerRooms()
    flush()
    assert(#chosen == 0, "switch is off: the player routes")
    settings.set("autoRoute", true)
    offerRooms()
    flush()
    assert(#chosen == 0 and string.find(runtime.status, "waiting for the map data", 1, true) ~= nil)
    assert(box.requested == 1000, "asked the game for the map, with no arguments")
    local snap: any = box.snapshot
    snap({ CurrentFloor = 10, Nodes = { { Floor = 12, Lane = 3, Kind = "Elite", IsSelectable = true } } })
    flush()
    assert(#chosen == 0, "a snapshot of an older floor is not trusted")
    snap({
        CurrentFloor = 11,
        CurrentLane = 2,
        -- IsSelectable is not set yet when the offer arrives: the connections decide.
        Connections = {
            { From = "F11_L2", To = "F12_L2" },
            { From = "F11_L2", To = "F12_L3" },
            { From = "F11_L1", To = "F12_L1" },
        },
        Nodes = {
            { Floor = 12, Lane = 1, Kind = "Battle", IsSelectable = false },
            { Floor = 12, Lane = 2, Kind = "Battle", IsSelectable = false },
            { Floor = 12, Lane = 3, Kind = "Elite", IsSelectable = false },
        },
    })
    offerRooms()
    assert(#chosen == 0, "the choice waits a moment")
    flush()
    assert(
        #chosen == 1 and chosen[1].OptionIndex == 3 and runtime.routed == 1,
        "Treasure is unreachable: Elite outranks Battle"
    )
    assert(string.find(runtime.status, "chose a Elite room", 1, true) ~= nil, runtime.status)
    flush()
    assert(box.closed == 1, "Close Map After Voting (default on) hid the Route Atlas")
    offerRooms()
    flush()
    assert(#chosen == 1, "an identical selection right away is ignored")
    runtime.stop()
end)

test("Adventure picks the highest rarity character card; a full hand is skipped; shops are left", function()
    assert(
        AdventureChoice.pickCharacterCard({ { Rarity = "Rare" }, { Rarity = "Epic" }, { Rarity = "Epic" } })
            == 2
    )
    assert(AdventureChoice.pickCharacterCard({ { Rarity = "Legendary" }, { Rarity = "Mythic" } }) == 2)
    assert(AdventureChoice.pickCharacterCard({ { Rarity = "Odd" }, { Rarity = "Rare" } }) == 2)
    assert(AdventureChoice.pickCharacterCard({}) == nil and AdventureChoice.pickCharacterCard(nil) == nil)

    local settings = AdventureSettings.new(AdventureCatalog.fromModules(nil), {})
    local box: any = {}
    local fired: { string } = {}
    local pending: { any } = {}
    local runtime = AdventureRuntime.new(function()
        return settings
    end, {
        clock = function()
            return 10
        end,
        task = {
            delay = function(_seconds: number, callback: any)
                table.insert(pending, callback)
            end,
        },
        isAdventure = function()
            return true
        end,
        events = {
            CardPickBasicOffer = { On = function() end },
            CardPickCharacterOffer = {
                On = function(callback: any)
                    box.character = callback
                    return function() end
                end,
            },
            ShopOpened = {
                On = function(callback: any)
                    box.shop = callback
                    return function() end
                end,
            },
            CardPickPick = {
                Fire = function(payload: any)
                    table.insert(fired, "pick" .. payload.Choice)
                end,
            },
            CardPickSkip = {
                Fire = function()
                    table.insert(fired, "skip")
                end,
            },
            ShopClose = {
                Fire = function()
                    table.insert(fired, "close")
                end,
            },
        },
    })
    local function flush()
        for _, callback in pending do
            local run: any = callback
            run()
        end
        pending = {}
    end
    assert(runtime.start())
    local offer: any = box.character
    local opened: any = box.shop
    local options: any = { { Rarity = "Rare" }, { Rarity = "Epic" } }
    offer({ Options = options, AtCap = false })
    flush()
    assert(#fired == 0, "Auto Character Card is off")
    settings.set("autoCharacterCard", true)
    offer({ Options = options, AtCap = false })
    flush()
    assert(fired[1] == "pick2" and runtime.cards == 1)
    offer({ Options = options, AtCap = true })
    flush()
    assert(fired[2] == "skip", "a full hand is skipped, not replaced")
    opened()
    flush()
    assert(fired[3] == "close", "the shop is left (default on)")
    settings.set("leaveShop", false)
    opened()
    flush()
    assert(#fired == 3, "Leave Shop Rooms off: the player decides")
    runtime.stop()
end)

test("Adventure opens the allowed treasure chests one by one", function()
    local settings = AdventureSettings.new(AdventureCatalog.fromModules(nil), {})
    local box: any = {}
    local opened: { number } = {}
    local pending: { any } = {}
    local runtime = AdventureRuntime.new(function()
        return settings
    end, {
        clock = function()
            return 5
        end,
        task = {
            delay = function(_seconds: number, callback: any)
                table.insert(pending, callback)
            end,
        },
        isAdventure = function()
            return true
        end,
        events = {
            CardPickBasicOffer = { On = function() end },
            TreasureBegin = {
                On = function(callback: any)
                    box.begin = callback
                    return function() end
                end,
            },
            TreasureOpenChest = {
                Fire = function(payload: any)
                    table.insert(opened, payload.ChestIndex)
                end,
            },
        },
    })
    local function flush()
        for _, callback in pending do
            local run: any = callback
            run()
        end
        pending = {}
    end
    assert(runtime.start())
    local begin: any = box.begin
    begin({ TotalChests = 6, PicksRemaining = 3, OpenedChests = {} })
    assert(#opened == 0, "chests open after a short wait")
    flush()
    assert(table.concat(opened, ",") == "1,2,3" and runtime.chests == 3)
    opened = {}
    begin({ TotalChests = 6, PicksRemaining = 2, OpenedChests = { 1, 2, 3 } })
    flush()
    assert(table.concat(opened, ",") == "4,5", "already opened chests are skipped")
    opened = {}
    settings.set("openTreasure", false)
    begin({ TotalChests = 6, PicksRemaining = 3, OpenedChests = {} })
    flush()
    assert(#opened == 0, "switch off: the player opens them")
    runtime.stop()
end)

print(string.format("PASS: %d unit scenarios (part 4)", passed))
