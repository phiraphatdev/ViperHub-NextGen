--!strict
-- Purpose: Odyssey Adventure tab scenarios (catalog, settings, page); Input: pure modules with mocks; Output: assertion summary; Dependencies: src.
local AdventureCatalog = require("../../src/games/AnimeVanguards/Adventure/Catalog")
local AdventureSettings = require("../../src/games/AnimeVanguards/Adventure/Settings")
local AdventurePage = require("../../src/games/AnimeVanguards/Adventure/Page")
local VanguardsConfig = require("../../src/games/AnimeVanguards/Config")
local PriorityList = require("../../src/ui/PriorityList")
local passed = 0
local function test(name: string, callback: () -> ())
    local ok, message = pcall(callback)
    assert(ok, name .. ": " .. tostring(message))
    passed += 1
end
local ADVENTURE: any = (VanguardsConfig :: any).adventure

-- A fake JSON codec: the document is kept in a table and the body is a token for it.
local function fakeStore(initial: any?, readError: string?): any
    local store: any = { document = initial, writes = 0 }
    store.storage = {
        read = function(): (string?, string?)
            if readError then
                return nil, readError
            end
            return if store.document then "body" else nil, nil
        end,
        write = function(_body: string): boolean
            store.writes += 1
            return true
        end,
    }
    store.deps = {
        storage = store.storage,
        encode = function(value: any): string
            store.document = table.clone(value)
            return "body"
        end,
        decode = function(_text: string): any
            return store.document
        end,
    }
    return store
end

test("Adventure catalog falls back to the observed config lists", function()
    local catalog = AdventureCatalog.fromModules(nil)
    assert(#catalog.characters == #ADVENTURE.characters and catalog.defaultCharacter == "Iscanur (Pride)")
    assert(#catalog.powers == 14 and catalog.powers[12] == "Memorized")
    assert(#catalog.basicCards == 33 and catalog.basicCards[1] == "Limit Break")
    assert(
        catalog.basicCardRarity["Limit Break"] == "Mythic"
            and catalog.basicCardRarity["Military Training"] == "Rare"
    )
    assert(catalog.basicCards[33] == "Military Training")
    assert(table.concat(catalog.roomKinds, ",") == "Battle,Elite,Shop,Treasure,Boss")
    assert(catalog.traits[1] == "Vigor I" and #catalog.memoriaRarities == 6)
end)

test("Adventure catalog reads live-shaped game modules and ignores malformed entries", function()
    local catalog = AdventureCatalog.fromModules({
        characters = {
            GetAllCharacters = function(): any
                return {
                    ["Zed (New)"] = { Name = "Zed (New)" },
                    ["Abe (Old)"] = { Name = "Abe (Old)" },
                    Broken = 42,
                }
            end,
            GetDefaultCharacterName = function(): string
                return "Zed (New)"
            end,
        },
        powers = { POWERS = { { Name = "Full Deck" }, { Name = "" }, { Name = "Flight" }, "bad" } },
        basicCards = {
            CardsByRarity = { Rare = { "Ambush", { Name = "Ambush" } }, Mythic = { { Name = "Golden Age" } } },
        },
        traits = {
            Vigor = { Chance = 29, Tiers = { {}, {}, {} } },
            Blitz = { Chance = 1.85 },
            Note = "not a trait",
        },
    })
    assert(
        table.concat(catalog.characters, ",") == "Abe (Old),Broken,Zed (New)",
        table.concat(catalog.characters, ",")
    )
    assert(catalog.defaultCharacter == "Zed (New)")
    assert(table.concat(catalog.powers, ",") == "Full Deck,Flight")
    assert(table.concat(catalog.basicCards, ",") == "Golden Age,Ambush")
    assert(catalog.basicCardRarity["Golden Age"] == "Mythic" and catalog.basicCardRarity.Ambush == "Rare")
    assert(table.concat(catalog.traits, ",") == "Vigor I,Vigor II,Vigor III,Blitz")
    local failing = AdventureCatalog.fromModules({
        characters = {
            GetAllCharacters = function(): any
                error("boom")
            end,
        },
    })
    assert(#failing.characters == #ADVENTURE.characters)
end)

test("Adventure settings validate every field kind", function()
    local catalog = AdventureCatalog.fromModules(nil)
    local s = AdventureSettings.new(catalog, {})
    assert(
        s.get("autoJoin") == false and s.get("character") == "Iscanur (Pride)" and s.get("slot1") == "None"
    )
    assert(
        s.get("secondPriorityFloor") == 30 and s.get("cashOutFloor") == 30 and s.get("failsafeMinutes") == 10
    )
    assert(table.concat(s.order("floorPriority"), ",") == "Treasure,Elite,Shop,Battle,Boss")
    assert(s.get("floorPriority").Treasure == 5 and s.get("floorPriority").Boss == 1)
    assert(#s.order("cardPriority") == 33 and s.get("cardPriority")["Limit Break"] == 33)
    assert(#s.get("buyBasicCards") == 0 and #s.order("autoJoin") == 0)
    assert(not s.set("autoJoin", "yes") and s.set("autoJoin", true) and s.get("autoJoin"))
    assert(not s.set("character", "Nobody") and s.set("character", "Luce (Hacker)"))
    assert(not s.set("character", "None") and s.set("slot2", "None") and s.set("slot1", "Flight"))
    assert(not s.set("cashOutFloor", 0 / 0) and s.set("cashOutFloor", 500) and s.get("cashOutFloor") == 100)
    assert(s.set("failsafeMinutes", -3) and s.get("failsafeMinutes") == 1)
    assert(s.set("buyTraits", { "Blitz", "Blitz", "Fake", "Solar" }))
    assert(table.concat(s.get("buyTraits"), ",") == "Blitz,Solar")
    -- An order list (the earlier saved format) becomes numbers; a map keeps known names, missing ones rank 0.
    assert(s.set("floorPriority", { "Boss", "Fake" }) and s.order("floorPriority")[1] == "Boss")
    assert(s.get("floorPriority").Boss == 5 and s.get("floorPriority").Treasure == 4)
    assert(s.set("floorPriority", { Shop = 50.7, Elite = -4, Fake = 9, Battle = 1e9 }))
    assert(table.concat(s.order("floorPriority"), ",") == "Battle,Shop,Treasure,Elite,Boss")
    assert(s.get("floorPriority").Battle == 999 and s.get("floorPriority").Shop == 50)
    assert(s.get("floorPriority").Fake == nil and s.get("floorPriority").Elite == 0)
    assert(not s.set("memoria", "") and s.set("memoria", "Power Surge"))
    assert(not s.set("unknownKey", true))
    local copy = s.get("floorPriority")
    copy.Boss = 500
    assert(s.get("floorPriority").Boss == 0)
end)

test("Adventure settings swap priority entries and renumber them", function()
    local s = AdventureSettings.new(AdventureCatalog.fromModules(nil), {})
    assert(not s.swap("floorPriority", "Nope", "Elite") and not s.swap("autoJoin", "Elite", "Shop"))
    assert(not s.swap("floorPriority", "Elite", "Elite") and not s.swap("floorPriority", "Elite", 3))
    assert(s.swap("floorPriority", "Treasure", "Boss"))
    assert(table.concat(s.order("floorPriority"), ",") == "Boss,Elite,Shop,Battle,Treasure")
    assert(
        s.get("floorPriority").Boss == 5 and s.get("floorPriority").Treasure == 1,
        "renumbered from the top"
    )
    assert(s.swap("cardPriority", "Limit Break", "Military Training"))
    assert(s.order("cardPriority")[1] == "Military Training" and s.order("cardPriority")[33] == "Limit Break")
    -- Equal saved numbers keep the default order, then swap like any other order.
    assert(s.set("secondFloorPriority", { Treasure = 1, Battle = 1, Shop = 1, Elite = 1, Boss = 1 }))
    assert(s.swap("secondFloorPriority", "Shop", "Treasure") and s.order("secondFloorPriority")[1] == "Shop")
    assert(s.resetOrder("floorPriority")[1] == "Treasure" and s.get("floorPriority").Boss == 1)
end)

test("Priority list labels, summary and row hit test", function()
    local labels = PriorityList.labels({ "Treasure", "Elite", "Boss" })
    assert(table.concat(labels, "|") == "3. Treasure|2. Elite|1. Boss")
    assert(PriorityList.summary({ "A", "B" }) == "A > B")
    assert(
        PriorityList.summary({ "A", "B", "C", "D", "E", "F", "G", "H" }) == "A > B > C > D > E > F > … (+2)"
    )
    local offsets = PriorityList.offsets(3)
    assert(offsets[1] == 0 and offsets[2] == 36 and offsets[3] == 72, "32px rows with a 4px gap")
    local tops = { 100, 134, 168 }
    assert(PriorityList.rowAt(tops, 30, 100) == 1 and PriorityList.rowAt(tops, 30, 150) == 2)
    assert(PriorityList.rowAt(tops, 30, 131) == nil, "the gap between rows is not a row")
    assert(PriorityList.rowAt(tops, 30, 197) == 3 and PriorityList.rowAt(tops, 30, 198) == nil)
    assert(PriorityList.rowAt({ -math.huge, 134 }, 30, 140) == 2, "rows outside horizontally are skipped")
end)

test("Adventure settings persist, reload and never overwrite an unreadable file", function()
    local catalog = AdventureCatalog.fromModules(nil)
    local store = fakeStore()
    local first = AdventureSettings.new(catalog, store.deps)
    assert(first.persistent())
    first.set("autoCashOut", true)
    first.set("character", "Tuji (Sorcerer Killer)")
    first.swap("secondFloorPriority", "Boss", "Treasure")
    assert(store.writes == 3 and store.document.schemaVersion == 1)
    local second = AdventureSettings.new(catalog, store.deps)
    assert(second.get("autoCashOut") and second.get("character") == "Tuji (Sorcerer Killer)")
    assert(second.order("secondFloorPriority")[1] == "Boss" and second.get("secondFloorPriority").Boss == 5)

    local tampered =
        fakeStore({ schemaVersion = 1, character = "Ghost", cashOutFloor = 1e9, autoJoin = "true" })
    local third = AdventureSettings.new(catalog, tampered.deps)
    assert(third.get("character") == "Iscanur (Pride)" and third.get("cashOutFloor") == 100)
    assert(third.get("autoJoin") == false)

    local broken = fakeStore(nil, "CONFIG_READ_FAILED")
    local fourth = AdventureSettings.new(catalog, broken.deps)
    fourth.set("autoJoin", true)
    assert(not fourth.persistent() and broken.writes == 0 and fourth.get("autoJoin"))

    local future = fakeStore({ schemaVersion = 99, autoJoin = true })
    local fifth = AdventureSettings.new(catalog, future.deps)
    fifth.set("failsafe", true)
    assert(not fifth.persistent() and future.writes == 0 and fifth.get("autoJoin") == false)
end)

test("Adventure page mounts the requested layout and binds every control", function()
    local catalog = AdventureCatalog.fromModules(nil)
    local settings = AdventureSettings.new(catalog, {})
    local controls: { [string]: any } = {}
    local sections: { string } = {}
    local statusText = ""
    local buttons: { [string]: any } = {}
    local function host(path: string): any
        local node: any = {}
        for _, kind in { "Toggle", "Dropdown", "Slider", "Button", "Paragraph" } do
            node[kind] = function(_self: any, options: any): any
                local entry: any = { kind = kind, options = options, path = path, desc = options.Desc }
                entry.SetDesc = function(_s: any, text: string)
                    entry.desc = text
                    if options.Title == "Status" then
                        statusText = text
                    end
                end
                -- Like WindUI: Refresh replaces the values, Select sets the value without the callback.
                entry.Refresh = function(_s: any, values: any)
                    entry.values = values
                end
                entry.Select = function(_s: any, value: any)
                    entry.value = value
                end
                if options.Title == "Status" then
                    statusText = options.Desc
                end
                if kind == "Button" then
                    buttons[path .. options.Title] = entry
                end
                controls[options.Title] = entry
                return entry
            end
        end
        node.Section = function(_self: any, options: any): any
            table.insert(sections, path .. options.Title)
            return host(path .. options.Title .. "/")
        end
        return node
    end
    assert(AdventurePage.mount(host(""), catalog, settings) == settings)
    assert(string.find(statusText, "Coming soon", 1, true), statusText)
    for _, title in
        {
            "Auto Join Odyssey Adventure",
            "Select Character",
            "Slot 1",
            "Slot 2",
            "Auto Basic Card",
            "Card Priority",
        }
    do
        assert(controls[title].options.Locked ~= true, title .. " is live")
    end
    for _, title in
        {
            "Auto Cash Out",
            "Buy Unit Trait",
            "Memoria",
            "Refresh Inventory",
            "Cash out at floor",
        }
    do
        assert(controls[title].options.Locked == true, title .. " stays locked")
    end
    assert(
        table.concat(sections, "|")
            == "Character|Miscellaneous|Miscellaneous/Auto Route Atlas|Miscellaneous/Auto Route Atlas/Floor Prioritize|Miscellaneous/Auto Route Atlas/Second Floor Prioritize|Auto Character Card|Auto Basic Card|Auto Basic Card/Card Priority|Auto Stitches Shop|Run Completion|Memorized Modifier|Stage Failsafe",
        table.concat(sections, "|")
    )
    local expected: { [string]: string } = {
        ["Auto Join Odyssey Adventure"] = "",
        ["Select Character"] = "Character/",
        ["Slot 1"] = "Character/",
        ["Slot 2"] = "Character/",
        ["Use Second Prioritize after Floor"] = "Miscellaneous/Auto Route Atlas/",
        ["Floor Prioritize"] = "Miscellaneous/Auto Route Atlas/Floor Prioritize/",
        ["Second Floor Prioritize"] = "Miscellaneous/Auto Route Atlas/Second Floor Prioritize/",
        ["Auto Choose Unit Reward"] = "Miscellaneous/",
        ["Auto Buy Itches"] = "Miscellaneous/",
        ["Auto Character Card"] = "Auto Character Card/",
        ["Auto Basic Card"] = "Auto Basic Card/",
        ["Card Priority"] = "Auto Basic Card/Card Priority/",
        ["Auto Stitches Shop"] = "Auto Stitches Shop/",
        ["Leave Shop Rooms"] = "Auto Stitches Shop/",
        ["Buy Basic Card"] = "Auto Stitches Shop/",
        ["Buy Starter Card"] = "Auto Stitches Shop/",
        ["Buy Unit Trait"] = "Auto Stitches Shop/",
        ["Buy Unit Memoria"] = "Auto Stitches Shop/",
        ["Auto Cash Out"] = "Run Completion/",
        ["Cash out at floor"] = "Run Completion/",
        ["Auto Start New Run"] = "Run Completion/",
        ["Auto Ascension"] = "Run Completion/",
        ["Auto Select Memorized Memoria"] = "Memorized Modifier/",
        ["Memoria"] = "Memorized Modifier/",
        ["Refresh Inventory"] = "Memorized Modifier/",
        ["Teleport Lobby if Stage not Finished"] = "Stage Failsafe/",
        ["Failsafe Time (minute)"] = "Stage Failsafe/",
    }
    for title, path in expected do
        assert(controls[title] and controls[title].path == path, title)
    end
    local slider = controls["Use Second Prioritize after Floor"].options.Value
    assert(slider.Min == 1 and slider.Max == 200)
    assert(controls["Cash out at floor"].options.Value.Max == 100)
    assert(controls["Failsafe Time (minute)"].options.Value.Max == 30)
    assert(controls["Buy Unit Trait"].options.Multi == true)
    assert(controls["Slot 1"].options.Values[1] == "None")

    controls["Auto Join Odyssey Adventure"].options.Callback(true)
    controls["Select Character"].options.Callback("Luce (Hacker)")
    controls["Cash out at floor"].options.Callback(45)
    controls["Buy Unit Memoria"].options.Callback({ "Secret", "Vanguard" })
    assert(settings.get("autoJoin") and settings.get("character") == "Luce (Hacker)")
    assert(settings.get("cashOutFloor") == 45 and #settings.get("buyMemoria") == 2)

    -- Priority lists: a drag-to-swap card (text-only here: the mock has no WindUI paragraph container) and Reset.
    local floor = controls["Floor Prioritize"]
    assert(floor.kind == "Paragraph" and string.find(floor.desc, "Treasure > Elite > Shop", 1, true) ~= nil)
    local card = controls["Card Priority"]
    assert(string.find(card.desc, "Limit Break > Golden Age", 1, true) ~= nil)
    assert(string.find(card.desc, "(+27)", 1, true) ~= nil, card.desc)
    assert(buttons["Miscellaneous/Auto Route Atlas/Floor Prioritize/Reset Floor Prioritize"])
    assert(buttons["Miscellaneous/Auto Route Atlas/Second Floor Prioritize/Reset Second Floor Prioritize"])
    assert(settings.swap("floorPriority", "Treasure", "Boss"))
    buttons["Miscellaneous/Auto Route Atlas/Floor Prioritize/Reset Floor Prioritize"].options.Callback()
    assert(settings.order("floorPriority")[1] == "Treasure")
    assert(string.find(floor.desc, "Treasure > Elite", 1, true) ~= nil)
    assert(settings.swap("cardPriority", "Limit Break", "Ambush"))
    buttons["Auto Basic Card/Card Priority/Reset Card Priority"].options.Callback()
    assert(
        settings.order("cardPriority")[1] == "Limit Break"
            and string.find(card.desc, "Limit Break >", 1, true) ~= nil
    )

    controls["Refresh Inventory"].options.Callback()
    assert(string.find(statusText, "runtime pending", 1, true), statusText)
end)

print(string.format("PASS: %d unit scenarios (part 3)", passed))
