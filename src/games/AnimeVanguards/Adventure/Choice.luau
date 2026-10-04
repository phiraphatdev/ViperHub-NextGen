--!strict
--[[
Purpose: Pure choice rules for Odyssey: Adventure offers: which basic card and which next room to pick by the saved priorities
Input: An offer's options as the game sends them and the saved name -> priority number map
Output: The 1-based option index to pick, or nil when nothing valid is offered
Dependencies: None
]]

local Choice = {}

--- Picks the offered basic card with the highest priority number; equal numbers keep the game's option order.
--- Options are the game's `CardPickBasicOffer.Options` entries ({CardName, Rarity, OfferedLevel, ...}, observed live).
--- A card missing from the priorities ranks 0. Returns nil for an empty or malformed offer.
function Choice.pickBasicCard(options: any, ranks: { [string]: number }): number?
    if type(options) ~= "table" then
        return nil
    end
    local best: number? = nil
    local bestRank = -math.huge
    for index = 1, #options do
        local option = options[index]
        if type(option) == "table" and type(option.CardName) == "string" then
            local rank = ranks[option.CardName]
            local value = if type(rank) == "number" then rank else 0
            if value > bestRank then
                best = index
                bestRank = value
            end
        end
    end
    return best
end

--- Picks the offered room whose kind ranks highest. Options are the game's room selection entries ({Index,
--- AdventureRoomKind, AdventureFloor, ...}, observed live). From secondPriorityFloor on, the second ranks apply.
--- When reachable (option Index = lane -> true) is given, only those rooms may be chosen.
--- Unknown kinds (e.g. Challenge) rank below every listed kind. Returns the option's Index (sent as VoteCast OptionIndex).
function Choice.pickRoom(
    options: any,
    first: { [string]: number },
    second: { [string]: number },
    secondFromFloor: number,
    reachable: { [number]: boolean }?
): number?
    if type(options) ~= "table" then
        return nil
    end
    local best: number? = nil
    local bestRank = -math.huge
    for position = 1, #options do
        local option = options[position]
        if type(option) == "table" and type(option.AdventureRoomKind) == "string" then
            -- Boss rooms carry the boss's name as their kind (observed: "LichSovereign") with BossRoom = true.
            local kind: string = if option.BossRoom == true then "Boss" else option.AdventureRoomKind
            local floor = if type(option.AdventureFloor) == "number" then option.AdventureFloor else 0
            local ranks = if floor >= secondFromFloor then second else first
            local rank = ranks[kind]
            local value = if type(rank) == "number" then rank else -1
            local index = if type(option.Index) == "number" then option.Index else position
            if (reachable == nil or reachable[index] == true) and value > bestRank then
                best = index
                bestRank = value
            end
        end
    end
    return best
end

local CHARACTER_RARITY = { Mythic = 4, Legendary = 3, Epic = 2, Rare = 1 }

--- Picks the offered character card of the highest rarity (the first one on a tie). Options are the game's
--- CardPickCharacterOffer entries ({CharacterName, CardId, Rarity, RankRequirement}, observed live).
function Choice.pickCharacterCard(options: any): number?
    if type(options) ~= "table" then
        return nil
    end
    local best: number? = nil
    local bestRank = -math.huge
    for index = 1, #options do
        local option = options[index]
        if type(option) == "table" and type(option.Rarity) == "string" then
            local rank = CHARACTER_RARITY[option.Rarity] or 0
            if rank > bestRank then
                best = index
                bestRank = rank
            end
        end
    end
    return best
end

local ROMAN = { "I", "II", "III", "IV", "V" }
local MEMORIA_RARITY = { Vanguard = 6, Secret = 5, Mythic = 4, Legendary = 3, Epic = 2, Rare = 1 }
local KIND_ORDER = { Power = 1, BasicCard = 2, Trait = 3, Memoria = 4 }

--- The display name of a shop trait as listed in settings ("Swift III"; tierless traits keep their name).
function Choice.traitLabel(item: any): string?
    if type(item) ~= "table" or type(item.TraitName) ~= "string" then
        return nil
    end
    local tier = if type(item.TraitIndex) == "number" then ROMAN[item.TraitIndex] else nil
    return if tier then item.TraitName .. " " .. tier else item.TraitName
end

--- Chooses what to buy from a Stitches Shop stock ({Index, Cost, Purchased, Kind, ...}, observed live). Wants:
--- basic (set of basic card names), starters (set of power names), traits (set of trait labels), memoria (set of
--- names), character (the run's character; a Memoria needs that unit's GUID, found on a trait offered for it, else
--- fallbackGuid, a placed unit of that character) and
--- rank (basic card name -> priority number). Items are bought by kind (powers, basic cards by rank, traits, Memoria
--- by rarity) while the budget lasts. Returns { {index, cost, name, guid?} } in buying order.
function Choice.shopPurchases(stock: any, budget: number, wants: any): { any }
    local plan: { any } = {}
    if type(stock) ~= "table" or type(budget) ~= "number" then
        return plan
    end
    local mainGuid: string? = if type(wants.fallbackGuid) == "string" then wants.fallbackGuid else nil
    for _, item in stock do
        if type(item) == "table" and item.Kind == "Trait" and item.TraitUnitName == wants.character then
            if type(item.TraitUnitGUID) == "string" then
                mainGuid = item.TraitUnitGUID
            end
        end
    end
    local candidates: { any } = {}
    for _, item in stock do
        if
            type(item) == "table"
            and item.Purchased ~= true
            and type(item.Index) == "number"
            and type(item.Cost) == "number"
        then
            local entry: any = nil
            if item.Kind == "BasicCard" and wants.basic[item.BasicCardName] then
                entry = { name = item.BasicCardName, rank = wants.rank[item.BasicCardName] or 0 }
            elseif item.Kind == "Power" and wants.starters[item.PowerName or item.Name] then
                entry = { name = item.PowerName or item.Name, rank = 0 }
            elseif item.Kind == "Trait" then
                local label = Choice.traitLabel(item)
                if label and wants.traits[label] and type(item.TraitUnitGUID) == "string" then
                    entry = { name = label, rank = 0, guid = item.TraitUnitGUID }
                end
            elseif item.Kind == "Memoria" and type(item.MemoriaOption) == "table" then
                local rarity = item.MemoriaOption.Rarity
                local memoriaName = item.MemoriaOption.Name
                if type(memoriaName) == "string" and wants.memoria[memoriaName] and mainGuid then
                    entry = {
                        name = tostring(item.MemoriaOption.Name),
                        rank = if type(rarity) == "string" then MEMORIA_RARITY[rarity] or 0 else 0,
                        guid = mainGuid,
                    }
                end
            end
            if entry then
                entry.index = item.Index
                entry.cost = item.Cost
                entry.order = KIND_ORDER[item.Kind] or 9
                table.insert(candidates, entry)
            end
        end
    end
    table.sort(candidates, function(a: any, b: any): boolean
        if a.order ~= b.order then
            return a.order < b.order
        end
        if a.rank ~= b.rank then
            return a.rank > b.rank
        end
        return a.index < b.index
    end)
    local left = budget
    for _, entry in candidates do
        if entry.cost <= left then
            left -= entry.cost
            table.insert(
                plan,
                { index = entry.index, cost = entry.cost, name = entry.name, guid = entry.guid }
            )
        end
    end
    return plan
end

local UNIT_RARITY = {
    Vanguard = 9,
    Exclusive = 8,
    Secret = 7,
    Mythic = 6,
    Legendary = 5,
    Epic = 4,
    Rare = 3,
    Uncommon = 2,
    Common = 1,
}

--- Picks the offered reward unit of the highest rarity (the first on a tie; the first when no rarity is readable).
--- The offer is the UnitRewardEvent "Offer" data; its exact shape is not yet observed, so options are read from
--- `Options`, `Units` or the data itself when it is a list, and each option's rarity from `Rarity` or `UnitRarity`.
--- Returns the 1-based index, or nil when there is nothing to pick.
function Choice.pickUnitReward(data: any): number?
    if type(data) ~= "table" then
        return nil
    end
    local options: any = data.Options or data.Units or data.Choices or data
    if type(options) ~= "table" or #options == 0 then
        return nil
    end
    local best: number = 1
    local bestRank = -math.huge
    for index = 1, #options do
        local option = options[index]
        local rarity = if type(option) == "table" then option.Rarity or option.UnitRarity else nil
        local rank = if type(rarity) == "string" then UNIT_RARITY[rarity] or 0 else 0
        if rank > bestRank then
            best = index
            bestRank = rank
        end
    end
    return best
end

--- Chooses the boss reward kind to claim ("Memoria" or "Familiar"): the option of the highest rarity (the game's
--- BossRewardPick takes only the kind and a target unit, not an option); a tie keeps the first. Nil when nothing valid
--- is offered.
function Choice.pickBossReward(options: any): string?
    if type(options) ~= "table" then
        return nil
    end
    local best: string? = nil
    local bestRank = -math.huge
    for index = 1, #options do
        local option = options[index]
        if type(option) == "table" and (option.Kind == "Memoria" or option.Kind == "Familiar") then
            local rank = if type(option.Rarity) == "string" then UNIT_RARITY[option.Rarity] or 0 else 0
            if rank > bestRank then
                best = option.Kind
                bestRank = rank
            end
        end
    end
    return best
end

return Choice
