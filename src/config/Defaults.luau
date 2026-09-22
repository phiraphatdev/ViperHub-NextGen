--!strict
--[[
Purpose: Define persisted UI defaults
Input: None
Output: Immutable defaults
Dependencies: None
]]

return table.freeze({
    schemaVersion = 1,
    notifications = true,
    uiScale = 1,
    theme = "Dark",
    toggleKey = "RightShift",
})
