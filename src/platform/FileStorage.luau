--!strict
--[[
Purpose: Contain filesystem access to a fixed config location
Input: Detected environment and game key
Output: Storage read/write API
Dependencies: Capabilities; Validation
]]

local Capabilities = require("./Capabilities")
local Validation = require("../utils/Validation")
local FileStorage = {}
local ROOT = "ViperHubNextGen"
local MAX_BYTES = 16384
--- Creates storage for a validated key; returns nil when persistence is unavailable.
export type Storage = { read: () -> (string?, string?), write: (string) -> boolean }
function FileStorage.new(env: { [string]: any }, key: string): Storage?
    if not Capabilities.detect(env).persistence or not Validation.identifier(key) then
        return nil
    end
    local filePath = ROOT .. "/" .. key .. ".json"
    return {
        read = function(): (string?, string?)
            local ok, result = pcall(function()
                if not env.isfile(filePath) then
                    return nil
                end
                return env.readfile(filePath)
            end)
            if not ok then
                return nil, "CONFIG_READ_FAILED"
            end
            if result == nil then
                return nil, nil
            end
            if type(result) ~= "string" or #result > MAX_BYTES then
                return nil, "CONFIG_INVALID"
            end
            return result, nil
        end,
        write = function(body: string): boolean
            if #body > MAX_BYTES then
                return false
            end
            local ok = pcall(function()
                if not env.isfolder(ROOT) then
                    env.makefolder(ROOT)
                end
                env.writefile(filePath, body)
                if env.readfile(filePath) ~= body then
                    error("readback")
                end
            end)
            return ok
        end,
    }
end
return FileStorage
