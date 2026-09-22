--!strict
--[[
Purpose: Keep verified places separate from module behavior
Input: None
Output: Read-only metadata list
Dependencies: Game metadata modules
]]

return table.freeze({
    require("./AnimeVanguards/Metadata"),
    require("./AnimeExpeditions/Metadata"),
})
