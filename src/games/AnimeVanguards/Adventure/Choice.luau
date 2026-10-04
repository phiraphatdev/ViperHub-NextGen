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
--- Unknown kinds (e.g. Challenge) rank below every listed kind. Returns the option's Index (sent as VoteCast OptionIndex).
function Choice.pickRoom(
    options: any,
    first: { [string]: number },
    second: { [string]: number },
    secondFromFloor: number
): number?
    if type(options) ~= "table" then
        return nil
    end
    local best: number? = nil
    local bestRank = -math.huge
    for position = 1, #options do
        local option = options[position]
        if type(option) == "table" and type(option.AdventureRoomKind) == "string" then
            local floor = if type(option.AdventureFloor) == "number" then option.AdventureFloor else 0
            local ranks = if floor >= secondFromFloor then second else first
            local rank = ranks[option.AdventureRoomKind]
            local value = if type(rank) == "number" then rank else -1
            local index = if type(option.Index) == "number" then option.Index else position
            if value > bestRank then
                best = index
                bestRank = value
            end
        end
    end
    return best
end

return Choice
