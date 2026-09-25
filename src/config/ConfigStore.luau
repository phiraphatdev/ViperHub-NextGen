--!strict
--[[
Purpose: Load/save config through injected storage and JSON functions
Input: Storage; codec; diagnostics
Output: Stateful config store
Dependencies: Schema
]]

local Schema = require("./Schema")
local ConfigStore = {}
type Storage = { read: () -> (string?, string?), write: (string) -> boolean }
--- Creates a store; codec errors are contained, returns get/update/save methods.
function ConfigStore.new(
    storage: Storage?,
    decode: (string) -> any,
    encode: (any) -> string,
    log: (string) -> ()
)
    local current = Schema.decode(nil)
    if storage then
        local text, code = storage.read()
        if code then
            log(code)
        end
        if text then
            local ok, data = pcall(decode, text)
            local config, valid = Schema.decode(if ok then data else nil)
            current = config
            if not valid then
                log("CONFIG_INVALID")
            end
        end
    end
    return {
        persistent = storage ~= nil,
        get = function(): Schema.Config
            return table.clone(current)
        end,
        update = function(key: string, value: unknown)
            local candidate: { [string]: any } = table.clone(current) :: any
            candidate[key] = value
            local sanitized = Schema.decode(candidate)
            -- An invalid picker value must not replace a previously valid shortcut with the default.
            if key == "toggleKey" and sanitized.toggleKey ~= value then
                return
            end
            current = sanitized
        end,
        save = function(): boolean
            if not storage then
                log("CONFIG_SESSION_ONLY")
                return false
            end
            local ok, text = pcall(encode, current)
            if not ok or type(text) ~= "string" then
                log("CONFIG_ENCODE_FAILED")
                return false
            end
            local saved = storage.write(text)
            if not saved then
                log("CONFIG_WRITE_FAILED")
            end
            return saved
        end,
    }
end
return ConfigStore
