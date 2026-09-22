--!strict
--[[
Purpose: Bounded private diagnostics without payloads or public printing
Input: Capacity
Output: Buffer API
Dependencies: None
]]

local Diagnostics = {}
--- Creates a bounded buffer; returns push(code) and snapshot() with copied entries.
function Diagnostics.new(capacity: number)
    local limit = math.clamp(math.floor(capacity), 1, 256)
    local entries: { string } = {}
    return {
        push = function(code: string)
            if not code:match("^[A-Z0-9_]+$") or #code > 64 then
                code = "INVALID_DIAGNOSTIC"
            end
            if #entries == limit then
                table.remove(entries, 1)
            end
            table.insert(entries, code)
        end,
        snapshot = function(): { string }
            return table.clone(entries)
        end,
    }
end
return Diagnostics
