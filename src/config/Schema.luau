--!strict
--[[
Purpose: Validate and migrate configuration before UI use
Input: Untrusted decoded data
Output: Safe config and validity
Dependencies: Defaults; Validation
]]

local Defaults = require("./Defaults")
local Validation = require("../utils/Validation")
local Schema = {}
export type Config = {
    schemaVersion: number,
    notifications: boolean,
    uiScale: number,
    theme: string,
    toggleKey: string,
}
local KEYS = {
    RightShift = true,
    RightControl = true,
    LeftControl = true,
    Insert = true,
    Delete = true,
    Home = true,
    End = true,
    F1 = true,
    F2 = true,
    F3 = true,
    F4 = true,
    F5 = true,
    F6 = true,
    F7 = true,
    F8 = true,
    F9 = true,
    F10 = true,
    F11 = true,
    F12 = true,
}
--- Sanitizes input; rejects unknown schema versions and returns fresh defaults plus false.
function Schema.decode(value: unknown): (Config, boolean)
    local output: Config = {
        schemaVersion = Defaults.schemaVersion,
        notifications = Defaults.notifications,
        uiScale = Defaults.uiScale,
        theme = Defaults.theme,
        toggleKey = Defaults.toggleKey,
    }
    if type(value) ~= "table" then
        return output, false
    end
    local data = value :: { [string]: any }
    if data.schemaVersion ~= 1 then
        return output, false
    end
    if type(data.notifications) == "boolean" then
        output.notifications = data.notifications
    end
    output.uiScale = Validation.number(data.uiScale, 0.8, 1.3, Defaults.uiScale)
    if data.theme == "Dark" then
        output.theme = data.theme
    end
    if type(data.toggleKey) == "string" and (KEYS :: { [string]: boolean })[data.toggleKey] then
        output.toggleKey = data.toggleKey
    end
    return output, true
end
return Schema
