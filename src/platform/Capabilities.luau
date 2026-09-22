--!strict
--[[
Purpose: Inspect APIs without inferring support from executor names
Input: Environment table
Output: Capability flags
Dependencies: None
]]

local Capabilities = {}
--- Returns callable API flags from env; no API is invoked during detection.
function Capabilities.detect(env: { [string]: any })
    local function callable(name: string): boolean
        return type(env[name]) == "function"
    end
    return {
        compile = callable("loadstring"),
        request = callable("request") or callable("http_request"),
        persistence = callable("readfile") and callable("writefile") and callable("isfile") and callable(
            "isfolder"
        ) and callable("makefolder"),
    }
end
return Capabilities
