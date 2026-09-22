--!strict
--[[
Purpose: Expose foundation-only lifecycle; no gameplay actions
Input: Game context
Output: GameModule contract
Dependencies: Metadata; types/GameModule
]]

local Types = require("../../types/GameModule")
local metadata = require("./Metadata")
local active = false
local GameModule = { metadata = metadata }
--- Starts the placeholder with context; returns nothing and changes no game objects.
function GameModule.start(context: Types.Context)
    if active or not context.alive then
        return
    end
    active = true
    context.log("PLACEHOLDER_STARTED")
    context.cleanup.add(GameModule.stop)
end
--- Stops the placeholder; safe to repeat, returns nothing.
function GameModule.stop()
    active = false
end
return GameModule
