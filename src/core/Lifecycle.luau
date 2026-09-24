--!strict
--[[
Purpose: Enforce foundation lifecycle transitions
Input: Current and next state
Output: Transition validity
Dependencies: None
]]

local Lifecycle = {}
local ALLOWED: { [string]: { [string]: boolean } } = {
    created = { loading = true, unsupported = true, failed = true, stopped = true },
    loading = { ready = true, failed = true, stopped = true },
    ready = { stopped = true, failed = true },
    failed = { stopped = true },
    unsupported = { stopped = true },
    stopped = {},
}
--- Returns whether a requested state transition is legal.
function Lifecycle.canTransition(current: string, nextState: string): boolean
    local transitions = ALLOWED[current]
    return transitions ~= nil and transitions[nextState] == true
end
return Lifecycle
