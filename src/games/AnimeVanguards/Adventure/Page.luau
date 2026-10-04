--!strict
--[[
Purpose: Render the Odyssey Adventure tab: auto join, character and powers, Route Atlas priorities, card and shop
         choices, run completion, Memorized memoria and the stage failsafe (settings only; automation is pending)
Input: WindUI tab handle, an optional catalog and an optional settings object (built from live game data when absent)
Output: Mounted controls bound to saved Adventure settings
Dependencies: Style; Adventure/Catalog; Adventure/Settings
]]

local Style = require("../Style")
local Catalog = require("./Catalog")
local Settings = require("./Settings")
local Page = {}

local SUMMARY_ENTRIES = 10
local PENDING =
    "Settings only for now: the Adventure automation is not built yet, so these choices are saved but nothing runs."

-- The order summary lists the first SUMMARY_ENTRIES names, then how many follow.
local function orderText(order: { string }): string
    if #order <= SUMMARY_ENTRIES then
        return table.concat(order, " > ")
    end
    return table.concat(order, " > ", 1, SUMMARY_ENTRIES)
        .. string.format(" > … (+%d)", #order - SUMMARY_ENTRIES)
end

local function setDesc(control: any, text: string)
    if type(control) == "table" and type(control.SetDesc) == "function" then
        pcall(control.SetDesc, control, text)
    end
end

local function numbered(order: { string }): { string }
    local labels = {}
    for index, name in order do
        table.insert(labels, index .. ". " .. name)
    end
    return labels
end

-- "3. Golden Age" -> "Golden Age"
local function unnumbered(label: any): string?
    if type(label) ~= "string" then
        return nil
    end
    return string.match(label, "^%d+%. (.+)$") or label
end

-- A priority list moved with the mouse: a numbered dropdown to pick an entry, then Up / Down / Top / Reset buttons
-- on one row. The picked entry stays selected, so repeated clicks keep moving it.
local function priorityEditor(host: any, settings: any, key: string, title: string, desc: string)
    local order = settings.order(key)
    local selected: string = order[1]
    local dropdown: any
    local function refresh()
        local current = settings.order(key)
        setDesc(dropdown, desc .. "\n" .. orderText(current))
        local position = table.find(current, selected) or 1
        if type(dropdown) == "table" and type(dropdown.Refresh) == "function" then
            pcall(dropdown.Refresh, dropdown, numbered(current))
            if type(dropdown.Select) == "function" then
                pcall(dropdown.Select, dropdown, position .. ". " .. selected)
            end
        end
    end
    dropdown = host:Dropdown({
        Title = title,
        Desc = desc .. "\n" .. orderText(order),
        Values = numbered(order),
        Value = "1. " .. selected,
        Callback = function(value: any)
            local name = unnumbered(value)
            if name and table.find(settings.order(key), name) then
                selected = name
            end
        end,
    })
    local row: any = if type(host.Group) == "function" then (host.Group :: any)(host, {}) else host
    local function button(label: string, icon: string, action: () -> boolean)
        row:Button({
            Title = label,
            Icon = icon,
            Callback = function()
                if action() then
                    refresh()
                end
            end,
        })
    end
    button("Up", "arrow-up", function(): boolean
        return settings.move(key, selected, -1)
    end)
    button("Down", "arrow-down", function(): boolean
        return settings.move(key, selected, 1)
    end)
    button("Top", "arrow-up-to-line", function(): boolean
        return settings.move(key, selected, -#settings.order(key))
    end)
    button("Reset", "rotate-ccw", function(): boolean
        settings.resetOrder(key)
        return true
    end)
end

local function toggle(host: any, settings: any, key: string, title: string, desc: string)
    host:Toggle({
        Title = title,
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
        "Next room to pick on the Route Atlas; the highest number is preferred."
    )
    priorityEditor(
        route,
        settings,
        "secondFloorPriority",
        "Second Floor Prioritize",
        "Used instead after the floor above."
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
        "Basic card (Odyssey modifier) to pick; the highest number is preferred."
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
        Desc = "Owned memoria to equip on your character for the run.",
        Values = if saved == Settings.NONE then { Settings.NONE } else { Settings.NONE, saved },
        Value = saved,
        Callback = function(value: any)
            settings.set("memoria", value)
        end,
    })
    memorized:Button({
        Title = "Refresh Inventory",
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
