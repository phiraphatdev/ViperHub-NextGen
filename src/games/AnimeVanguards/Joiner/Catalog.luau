--!strict
--[[
Purpose: Read valid stage and act choices from replicated game data
Input: Untrusted StagesData export and a supported mode
Output: Sorted choices for modes with stage and act selectors
Dependencies: None
]]

local Catalog = {}
local SUPPORTED = { Story = true, LegendStage = true, Raid = true, Dungeon = true }
local function naturalLess(left: string, right: string): boolean
    local a = tonumber(left:match("%d+$"))
    local b = tonumber(right:match("%d+$"))
    if a and b and a ~= b then
        return a < b
    end
    return left < right
end

--- Returns validated stage rows; malformed or absent data yields an empty list.
function Catalog.list(data: any, mode: string): { any }
    if not SUPPORTED[mode] or type(data) ~= "table" or type(data[mode]) ~= "table" then
        return {}
    end
    local stages = {}
    for id, stage in data[mode] do
        if type(id) == "string" and type(stage) == "table" and type(stage.Acts) == "table" then
            local acts = {}
            for actId, act in stage.Acts do
                if type(actId) == "string" and type(act) == "table" then
                    table.insert(
                        acts,
                        { id = actId, name = if type(act.ActName) == "string" then act.ActName else actId }
                    )
                end
            end
            table.sort(acts, function(a, b)
                return naturalLess(a.id, b.id)
            end)
            if #acts > 0 then
                local rawName = stage.StageData and stage.StageData.Name
                table.insert(
                    stages,
                    { id = id, name = if type(rawName) == "string" then rawName else id, acts = acts }
                )
            end
        end
    end
    table.sort(stages, function(a, b)
        return naturalLess(a.id, b.id)
    end)
    return stages
end

return Catalog
