--!strict
--[[
Purpose: Render the Odyssey Adventure tab: auto join, character and powers, Route Atlas priorities, card and shop
         choices, run completion, Memorized memoria and the stage failsafe (settings only; automation is pending)
Input: WindUI tab handle, an optional catalog and an optional settings object (built from live game data when absent)
Output: Mounted controls bound to saved Adventure settings
Dependencies: Style; Config; ui/PriorityList; Adventure/Catalog; Adventure/Settings
]]

local Style = require("../Style")
local Catalog = require("./Catalog")
local Settings = require("./Settings")
local PriorityList = require("../../../ui/PriorityList")
local config = require("../Config")
local Page = {}

-- The Adventure automation is not built yet: every control is locked (values stay visible).
local LOCKED = true

local ADVENTURE: any = (config :: any).adventure

local PENDING = "Coming soon: the Adventure automation is not built yet, so every control is locked."

local function setDesc(control: any, text: string)
    if type(control) == "table" and type(control.SetDesc) == "function" then
        pcall(control.SetDesc, control, text)
    end
end

-- A priority list like the reference hub, in its own collapsible sub-section: drag a row onto another to swap them;
-- Reset restores the default order.
local function priorityEditor(host: any, settings: any, key: string, title: string, desc: string, tags: any)
    local section = Style.sub(host, title, "list-ordered", false)
    local list = PriorityList.mount(section, {
        title = title,
        desc = desc,
        order = settings.order(key),
        tags = tags,
        locked = LOCKED,
        onSwap = function(first: string, second: string): { string }?
            return if settings.swap(key, first, second) then settings.order(key) else nil
        end,
    })
    section:Button({
        Title = "Reset " .. title,
        Locked = LOCKED,
        Desc = "Restore the default order.",
        Icon = "rotate-ccw",
        Callback = function()
            list.refresh(settings.resetOrder(key))
        end,
    })
end

-- Rarity tags for basic cards.
local function cardTags(catalog: any): { [string]: any }
    local tags = {}
    for name, rarity in catalog.basicCardRarity do
        tags[name] = { text = rarity, color = ADVENTURE.rarityColors[rarity] or "slate" }
    end
    return tags
end

local function toggle(host: any, settings: any, key: string, title: string, desc: string)
    host:Toggle({
        Title = title,
        Locked = LOCKED,
        Desc = desc,
        Value = settings.get(key),
        Callback = function(value: boolean)
            settings.set(key, value)
        end,
    })
end

local function slider(host: any, settings: any, key: string, title: string, desc: string)
    local range = Settings.FIELDS[key].range
    host:Slider({
        Title = title,
        Locked = LOCKED,
        Desc = desc,
        Step = 1,
        Value = { Min = range.min, Max = range.max, Default = settings.get(key) },
        Callback = function(value: any)
            settings.set(key, tonumber(value))
        end,
    })
end

local function choice(host: any, settings: any, key: string, title: string, desc: string, values: { string })
    host:Dropdown({
        Title = title,
        Locked = LOCKED,
        Desc = desc,
        Values = values,
        Value = settings.get(key),
        Callback = function(value: any)
            settings.set(key, value)
        end,
    })
end

local function multi(host: any, settings: any, key: string, title: string, desc: string, values: { string })
    host:Dropdown({
        Title = title,
        Locked = LOCKED,
        Desc = desc,
        Values = values,
        Value = settings.get(key),
        Multi = true,
        AllowNone = true,
        Callback = function(value: any)
            settings.set(key, value)
        end,
    })
end

--- Mounts the Adventure controls on the given WindUI tab; returns the settings object it is bound to.
function Page.mount(tab: any, catalogOverride: any?, settingsOverride: any?): any
    local catalog = catalogOverride or Catalog.read()
    local settings = settingsOverride or Settings.new(catalog)
    local withNone = function(list: { string }): { string }
        local result = { Settings.NONE }
        for _, name in list do
            table.insert(result, name)
        end
        return result
    end

    local status = tab:Paragraph({
        Title = "Status",
        Desc = PENDING .. "\n" .. (if settings.persistent()
            then "Autosaved to file"
            else "Session only: file APIs unavailable"),
    })
    toggle(
        tab,
        settings,
        "autoJoin",
        "Auto Join Odyssey Adventure",
        "From the lobby, start an Odyssey: Adventure run with the character and powers below."
    )

    local character = Style.section(tab, "Character", "user-round", false)
    choice(
        character,
        settings,
        "character",
        "Select Character",
        "The run's character (takes your first unit slot, free to place).",
        catalog.characters
    )
    choice(
        character,
        settings,
        "slot1",
        "Slot 1",
        "Run-start power card. None leaves the slot empty.",
        withNone(catalog.powers)
    )
    choice(
        character,
        settings,
        "slot2",
        "Slot 2",
        "Second power card; needs Loadout Slot 2 (bought in the Stitches Shop).",
        withNone(catalog.powers)
    )

    local misc = Style.section(tab, "Miscellaneous", "wrench", false)
    local route = Style.sub(misc, "Auto Route Atlas", "route")
    slider(
        route,
        settings,
        "secondPriorityFloor",
        "Use Second Prioritize after Floor",
        "From this floor on, the Second Floor Prioritize order is used."
    )
    priorityEditor(
        route,
        settings,
        "floorPriority",
        "Floor Prioritize",
        "Next room to pick on the Route Atlas; the highest number is preferred. Drag a row onto another to swap them.",
        ADVENTURE.roomTags
    )
    priorityEditor(
        route,
        settings,
        "secondFloorPriority",
        "Second Floor Prioritize",
        "Used instead after the floor above. Drag a row onto another to swap them.",
        ADVENTURE.roomTags
    )
    toggle(
        misc,
        settings,
        "autoUnitReward",
        "Auto Choose Unit Reward",
        "After an Elite floor, take the highest-rarity unit offered; skipped when off."
    )
    toggle(
        misc,
        settings,
        "autoBuyItches",
        "Auto Buy Itches",
        "Buy from the Stitches NPC when it appears on the map and you have enough Yen."
    )

    local characterCard = Style.section(tab, "Auto Character Card", "id-card", false)
    toggle(
        characterCard,
        settings,
        "autoCharacterCard",
        "Auto Character Card",
        "After an Elite floor, pick the character (unit) card; skipped when off."
    )

    local basicCard = Style.section(tab, "Auto Basic Card", "layers", false)
    toggle(
        basicCard,
        settings,
        "autoBasicCard",
        "Auto Basic Card",
        "After each floor, pick a basic card by the priority below; skipped when off."
    )
    priorityEditor(
        basicCard,
        settings,
        "cardPriority",
        "Card Priority",
        "Basic card (Odyssey modifier) to pick; the highest number is preferred. Drag a row onto another to swap them.",
        cardTags(catalog)
    )

    local shop = Style.section(tab, "Auto Stitches Shop", "store", false)
    toggle(
        shop,
        settings,
        "autoStitchesShop",
        "Auto Stitches Shop",
        "On a Shop floor, buy the items selected below with Odyssey Coins; skipped when off."
    )
    multi(shop, settings, "buyBasicCards", "Buy Basic Card", "Basic cards to buy.", catalog.basicCards)
    multi(shop, settings, "buyStarterCards", "Buy Starter Card", "Power cards to unlock.", catalog.powers)
    multi(
        shop,
        settings,
        "buyTraits",
        "Buy Unit Trait",
        "Traits to buy for a unit without one.",
        catalog.traits
    )
    multi(
        shop,
        settings,
        "buyMemoria",
        "Buy Unit Memoria",
        "Memoria rarities to buy for your first-slot unit.",
        catalog.memoriaRarities
    )

    local completion = Style.section(tab, "Run Completion", "flag", false)
    toggle(
        completion,
        settings,
        "autoCashOut",
        "Auto Cash Out",
        "Cash out between floors once the floor below is cleared."
    )
    slider(completion, settings, "cashOutFloor", "Cash out at floor", "Cleared floors before cashing out.")
    toggle(
        completion,
        settings,
        "autoStartNewRun",
        "Auto Start New Run",
        "Start another Adventure run after cashing out."
    )
    toggle(
        completion,
        settings,
        "autoAscension",
        "Auto Ascension",
        "Ascend in the lobby once Level Tree level 100 is reached and the game allows it."
    )

    local memorized = Style.section(tab, "Memorized Modifier", "brain", false)
    toggle(
        memorized,
        settings,
        "autoMemorized",
        "Auto Select Memorized Memoria",
        "When the Memorized power offers a pick at run start, choose the memoria below."
    )
    local saved = settings.get("memoria")
    memorized:Dropdown({
        Title = "Memoria",
        Locked = LOCKED,
        Desc = "Owned memoria to equip on your character for the run.",
        Values = if saved == Settings.NONE then { Settings.NONE } else { Settings.NONE, saved },
        Value = saved,
        Callback = function(value: any)
            settings.set("memoria", value)
        end,
    })
    memorized:Button({
        Title = "Refresh Inventory",
        Locked = LOCKED,
        Desc = "Reload your owned memoria into the list.",
        Callback = function()
            setDesc(status, "Refresh Inventory: reading your memoria is not built yet (runtime pending).")
        end,
    })

    local failsafe = Style.section(tab, "Stage Failsafe", "timer", false)
    toggle(
        failsafe,
        settings,
        "failsafe",
        "Teleport Lobby if Stage not Finished",
        "Go back to the lobby when a floor runs longer than the time below (stuck or bugged floors)."
    )
    slider(
        failsafe,
        settings,
        "failsafeMinutes",
        "Failsafe Time (minute)",
        "Minutes before the failsafe acts."
    )
    return settings
end

return Page
