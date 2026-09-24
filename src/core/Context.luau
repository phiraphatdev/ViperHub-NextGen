--!strict
--[[
Purpose: Give each run its own lifetime and cleanup scope
Input: Diagnostic sink
Output: Context
Dependencies: Cleanup; types/Context
]]

local Cleanup = require("./Cleanup")
local Lifecycle = require("./Lifecycle")
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
        transition = function()
            return false
        end,
    }
    context.transition = function(nextState: string): boolean
        if not Lifecycle.canTransition(context.state, nextState) then
            return false
        end
        context.state = nextState
        return true
    end
    context.destroy = function(finalState: unknown?)
        if not context.alive then
            return
        end
        context.alive = false
        if finalState == "failed" or finalState == "unsupported" then
            if not context.transition(finalState) then
                context.transition("stopped")
            end
        else
            context.transition("stopped")
        end
        scope.destroy()
    end
    return context
end
return Context
