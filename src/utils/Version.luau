--!strict
--[[
Purpose: Compare stable three-part versions without lexical mistakes
Input: Version strings
Output: Ordering or nil
Dependencies: None
]]

local Version = {}
--- Parses a stable x.y.z version; returns nil when the format is unsupported.
function Version.parse(value: unknown): { number }?
    if type(value) ~= "string" or #value > 32 then
        return nil
    end
    local major, minor, patch = value:match("^(%d+)%.(%d+)%.(%d+)$")
    if not major then
        return nil
    end
    return { tonumber(major) :: number, tonumber(minor) :: number, tonumber(patch) :: number }
end
--- Compares left against right, returning -1/0/1, or nil for malformed versions.
function Version.compare(left: unknown, right: unknown): number?
    local a, b = Version.parse(left), Version.parse(right)
    if not a or not b then
        return nil
    end
    for index = 1, 3 do
        if a[index] < b[index] then
            return -1
        end
        if a[index] > b[index] then
            return 1
        end
    end
    return 0
end
return Version
