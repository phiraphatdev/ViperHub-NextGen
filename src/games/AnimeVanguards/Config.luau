--!strict
--[[
Purpose: Keep patch-sensitive paths separate from behavior
Input: None
Output: Empty placeholder config
Dependencies: None
]]

-- Paths stay empty until observed and documented; guessed remotes must never ship.
return table.freeze({ instancePaths = table.freeze({}), remoteNames = table.freeze({}) })
