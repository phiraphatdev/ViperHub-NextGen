--!strict
--[[
Purpose: Describe a placeholder game module
Input: None
Output: Game metadata
Dependencies: types/GameModule
]]

local Types = require("../../types/GameModule")
local VERSION = "0.3.0"
local LAST_UPDATED = "2026-10-04"
local metadata: Types.Metadata = {
    id = "AnimeVanguards",
    name = "Anime Vanguards",
    version = VERSION,
    lastUpdated = LAST_UPDATED,
    placeIds = { 16146832113 },
    gameIds = { 5578556129 },
}
table.freeze(metadata.placeIds)
table.freeze(metadata.gameIds :: { number })
return table.freeze(metadata)
