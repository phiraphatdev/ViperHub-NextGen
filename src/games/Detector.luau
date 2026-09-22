--!strict
--[[
Purpose: Match exact places only; never infer multi-map support
Input: Unknown PlaceId
Output: Metadata or nil
Dependencies: Registry; Validation; types/GameModule
]]

local Registry = require("./Registry")
local Validation = require("../utils/Validation")
local Types = require("../types/GameModule")
local Detector = {}
--- Returns registered metadata for a positive integral placeId, otherwise nil.
function Detector.detect(placeId: unknown): Types.Metadata?
    if not Validation.isFinite(placeId) then
        return nil
    end
    local id = placeId :: number
    if id <= 0 or id % 1 ~= 0 then
        return nil
    end
    for _, metadata in Registry do
        for _, supported in metadata.placeIds do
            if id == supported then
                return {
                    id = metadata.id,
                    name = metadata.name,
                    version = metadata.version,
                    lastUpdated = metadata.lastUpdated,
                    placeIds = table.clone(metadata.placeIds),
                }
            end
        end
    end
    return nil
end
return Detector
