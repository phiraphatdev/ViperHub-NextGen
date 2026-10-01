--!strict
--[[
Purpose: Deliver Discord webhook payloads from a bounded queue with rate limiting, 429/5xx retry and invalid-webhook shutdown
Input: Executor request function, JSON codec, task API, clock and limits; webhook URL and payload tables
Output: Fire-and-forget enqueue plus a sanitized status and counters; the URL is never exposed in status or errors
Dependencies: None
]]

local Sender = {}

local SUCCESS_STATUSES = { [200] = true, [204] = true }
local MAX_RETRY_WAIT_SECONDS = 30

export type Options = {
    request: (any) -> any,
    encode: (any) -> string,
    decode: ((string) -> any)?,
    task: any,
    clock: () -> number,
    minInterval: number,
    queueLimit: number,
    retryLimit: number,
}

--- Creates a sender. State values: "idle", "sending", "rate limited", "retrying", "invalid", "offline".
function Sender.new(options: Options): any
    local self: any = {
        url = nil,
        state = "idle",
        queue = {} :: { any },
        running = false,
        lastSent = -math.huge,
        stats = { sent = 0, failed = 0, dropped = 0 },
        onState = nil,
        stopped = false,
    }

    local function setState(value: string)
        self.state = value
        if self.onState then
            pcall(self.onState, value)
        end
    end

    local function header(headers: any, name: string): any
        if type(headers) ~= "table" then
            return nil
        end
        for key, value in headers do
            if type(key) == "string" and string.lower(key) == name then
                return value
            end
        end
        return nil
    end

    local function retryAfter(response: any): number
        local waitSeconds: number? = nil
        if options.decode and type(response.Body) == "string" and #response.Body < 4096 then
            local ok, decoded = pcall(options.decode :: any, response.Body)
            if ok and type(decoded) == "table" and type(decoded.retry_after) == "number" then
                waitSeconds = decoded.retry_after
            end
        end
        if waitSeconds == nil then
            waitSeconds = tonumber(header(response.Headers, "retry-after"))
        end
        return math.clamp(waitSeconds or 2, 0.5, MAX_RETRY_WAIT_SECONDS)
    end

    -- Sends one payload; returns "ok", "retry" (with seconds), "drop" or "invalid".
    local function deliver(payload: any): (string, number?)
        local okBody, body = pcall(options.encode, payload)
        if not okBody or type(body) ~= "string" or #body > 100000 then
            return "drop", nil
        end
        local ok, response = pcall(options.request, {
            Url = self.url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body,
        })
        if not ok or type(response) ~= "table" then
            return "retry", 5
        end
        local status = response.StatusCode
        if type(status) ~= "number" then
            status = response.Status
        end
        if SUCCESS_STATUSES[status] then
            return "ok", nil
        elseif status == 429 then
            return "retry", retryAfter(response)
        elseif type(status) == "number" and status >= 500 then
            return "retry", 4
        elseif status == 401 or status == 403 or status == 404 then
            return "invalid", nil
        end
        return "drop", nil
    end

    local function pump()
        while not self.stopped and #self.queue > 0 and self.url do
            local item = self.queue[1]
            local sinceLast = options.clock() - self.lastSent
            if sinceLast < options.minInterval then
                options.task.wait(options.minInterval - sinceLast)
            end
            if self.stopped or not self.url then
                break
            end
            setState("sending")
            local verdict, waitSeconds = deliver(item.payload)
            self.lastSent = options.clock()
            if verdict == "ok" then
                table.remove(self.queue, 1)
                self.stats.sent += 1
                setState("idle")
            elseif verdict == "retry" then
                item.attempts += 1
                if item.attempts > options.retryLimit then
                    table.remove(self.queue, 1)
                    self.stats.failed += 1
                    setState("offline")
                else
                    setState(if waitSeconds and waitSeconds >= 5 then "rate limited" else "retrying")
                    options.task.wait(waitSeconds or 2)
                end
            elseif verdict == "invalid" then
                table.clear(self.queue)
                self.stats.failed += 1
                self.url = nil
                setState("invalid")
            else
                table.remove(self.queue, 1)
                self.stats.dropped += 1
                setState("idle")
            end
        end
        self.running = false
        if #self.queue == 0 and self.state ~= "invalid" and self.state ~= "offline" then
            setState("idle")
        end
    end

    --- Sets (or clears with nil) the webhook URL and resets an "invalid" or "offline" state.
    function self.setUrl(url: string?)
        self.url = url
        table.clear(self.queue)
        setState("idle")
    end

    --- True when a URL is configured and the sender is not shut down by Discord rejecting it.
    function self.isReady(): boolean
        return self.url ~= nil and self.state ~= "invalid"
    end

    --- Queues a payload for delivery; the oldest queued payload is dropped when the queue is full.
    function self.enqueue(payload: any): boolean
        if not self.url or self.stopped then
            return false
        end
        if #self.queue >= options.queueLimit then
            table.remove(self.queue, 1)
            self.stats.dropped += 1
        end
        table.insert(self.queue, { payload = payload, attempts = 0 })
        if not self.running then
            self.running = true
            local spawn = options.task.spawn
            local started = pcall(spawn, pump)
            if not started then
                self.running = false
                return false
            end
        end
        return true
    end

    --- Stops delivery and clears the queue; safe to repeat.
    function self.stop()
        self.stopped = true
        table.clear(self.queue)
    end

    return self
end

return Sender
