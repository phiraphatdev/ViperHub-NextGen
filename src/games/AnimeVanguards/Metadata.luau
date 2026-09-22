--!strict
--[[
Purpose: Describe a placeholder game module
Input: None
Output: Game metadata
Dependencies: types/GameModule
]]

local Types = require("../../types/GameModule")
local VERSION = "0.1.0"
local LAST_UPDATED = "2026-09-22"
local metadata: Types.Metadata = {
    id = "AnimeVanguards",
    name = "Anime Vanguards",
    version = VERSION,
    lastUpdated = LAST_UPDATED,
    placeIds = { 16146832113 },
}
table.freeze(metadata.placeIds)
return table.freeze(metadata)
