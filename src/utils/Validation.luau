--!strict
--[[
Purpose: Validate untrusted values before boundary use
Input: Unknown values
Output: Validated values or nil
Dependencies: None
]]

local Validation = {}
--- Returns true only for finite numbers; value may be any input.
function Validation.isFinite(value: unknown): boolean
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end
--- Returns a finite clamped number, or fallback for invalid value.
function Validation.number(value: unknown, minimum: number, maximum: number, fallback: number): number
    if not Validation.isFinite(value) then
        return fallback
    end
    return math.clamp(value :: number, minimum, maximum)
end
--- Returns true for a bounded identifier; value is never coerced.
function Validation.identifier(value: unknown): boolean
    return type(value) == "string" and #value > 0 and #value <= 64 and value:match("^[%w_-]+$") ~= nil
end
--- Returns true for an exact 40-character hexadecimal commit SHA.
function Validation.sha(value: unknown): boolean
    return type(value) == "string" and #value == 40 and value:match("^[a-f0-9]+$") ~= nil
end
--- Returns true for an artifact path below dist without traversal.
function Validation.artifactPath(value: unknown): boolean
    return type(value) == "string"
        and #value <= 160
        and value:match("^dist/[%w_/-]+%.lua$") ~= nil
        and not string.find(value, "//", 1, true)
end
return Validation
