--!strict
--[[
Purpose: Match verified places or their verified Roblox universe
Input: Unknown PlaceId and optional GameId
Output: Metadata or nil
Dependencies: Registry; Validation; types/GameModule
]]

local Registry = require("./Registry")
local Validation = require("../utils/Validation")
local Types = require("../types/GameModule")
local Detector = {}
--- Returns registered metadata for a verified place or universe, otherwise nil.
function Detector.detect(placeId: unknown, gameId: unknown?): Types.Metadata?
    local function valid(value: unknown): boolean
        return Validation.isFinite(value) and (value :: number) > 0 and (value :: number) % 1 == 0
    end
    local function copy(metadata: any): Types.Metadata
        return {
            id = metadata.id,
            name = metadata.name,
            version = metadata.version,
            lastUpdated = metadata.lastUpdated,
            placeIds = table.clone(metadata.placeIds),
            gameIds = if metadata.gameIds then table.clone(metadata.gameIds) else nil,
        }
    end
    if valid(placeId) then
        for _, metadata in Registry do
            for _, supported in metadata.placeIds do
                if placeId == supported then
                    -- A known place with a conflicting universe is not this game.
                    if
                        valid(gameId)
                        and metadata.gameIds
                        and not table.find(metadata.gameIds, gameId :: number)
                    then
                        return nil
                    end
                    return copy(metadata)
                end
            end
        end
    end
    if not valid(gameId) then
        return nil
    end
    for _, metadata in Registry do
        for _, supported in metadata.gameIds or {} do
            if gameId == supported then
                return copy(metadata)
            end
        end
    end
    return nil
end
return Detector
