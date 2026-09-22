--!strict
--[[
Purpose: Bound HTTP requests with deadline and response size checks
Input: Transport; scheduler; URL
Output: Response text or sanitized code
Dependencies: None
]]

local HttpClient = {}
type Scheduler = { spawn: (() -> ()) -> any, wait: (number) -> (), clock: () -> number }
--- Creates a client; transport returns status/body, requests terminate logically at timeout.
function HttpClient.new(transport: (string) -> (number, unknown), scheduler: Scheduler)
    return {
        get = function(url: string, maxBytes: number, timeout: number): (string?, string?)
            if not url:match("^https://raw%.githubusercontent%.com/") then
                return nil, "URL_REJECTED"
            end
            local finished, expired = false, false
            local response: string? = nil
            local failure: string? = nil
            scheduler.spawn(function()
                local ok, status, body = pcall(transport, url)
                if expired then
                    return
                end
                if not ok then
                    failure = "HTTP_FAILED"
                elseif status ~= 200 then
                    failure = "HTTP_STATUS"
                elseif type(body) ~= "string" or #body == 0 or #body > maxBytes then
                    failure = "HTTP_BODY"
                else
                    response = body
                end
                finished = true
            end)
            local started = scheduler.clock()
            while not finished and scheduler.clock() - started < timeout do
                scheduler.wait(0.05)
            end
            if not finished then
                expired = true
                return nil, "HTTP_TIMEOUT"
            end
            return response, failure
        end,
    }
end
return HttpClient
