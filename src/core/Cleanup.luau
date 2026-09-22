--!strict
--[[
Purpose: Own and release resources once in reverse acquisition order
Input: Cleanup callbacks
Output: Cleanup scope
Dependencies: None
]]

local Cleanup = {}
--- Creates a scope; onError receives a sanitized code, returns add/destroy/count methods.
function Cleanup.new(onError: (string) -> ())
    local callbacks: { () -> () } = {}
    local destroyed = false
    local function run(callback: () -> ())
        local ok = pcall(callback)
        if not ok then
            onError("CLEANUP_FAILED")
        end
    end
    return {
        add = function(callback: () -> ())
            if destroyed then
                run(callback)
            else
                table.insert(callbacks, callback)
            end
        end,
        destroy = function()
            if destroyed then
                return
            end
            destroyed = true
            for index = #callbacks, 1, -1 do
                run(callbacks[index])
            end
            table.clear(callbacks)
        end,
        count = function(): number
            return #callbacks
        end,
    }
end
return Cleanup
