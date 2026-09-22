--!strict
--[[
Purpose: Give each run its own lifetime and cleanup scope
Input: Diagnostic sink
Output: Context
Dependencies: Cleanup; types/Context
]]

local Cleanup = require("./Cleanup")
local Types = require("../types/Context")
local Context = {}
--- Creates a context; log accepts sanitized codes, return value owns all resources.
function Context.new(log: (string) -> ()): Types.Context
    local scope = Cleanup.new(log)
    local context: Types.Context = {
        alive = true,
        state = "created",
        gameId = nil,
        cleanup = scope,
        log = log,
        destroy = function() end,
    }
    context.destroy = function()
        if not context.alive then
            return
        end
        context.alive = false
        context.state = "stopped"
        scope.destroy()
    end
    return context
end
return Context
