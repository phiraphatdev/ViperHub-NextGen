--!strict
--[[
Purpose: Read game-recorded activity availability and carry a bounded lobby observation across places
Input: Game-owned Challenge/Rift modules, player identity and optional executor filesystem
Output: Available, unavailable or unknown activity observations
Dependencies: Config; platform/FileStorage
]]

local FileStorage = require("../../../platform/FileStorage")
local config = require("../Config")
local ActivityState = {}
local STORAGE_KEY = "AnimeVanguardsActivityState"
local SCHEMA_VERSION = 1
local CHALLENGES = { Regular = true, Daily = true, Weekly = true }

local function finite(value: any): boolean
    return type(value) == "number" and value == value and math.abs(value) ~= math.huge
end

--- Reads the player's recorded seed against the current period; returns unknown on missing data.
function ActivityState.challenge(attempts: any, data: any, kind: string): (string, number?)
    if
        not CHALLENGES[kind]
        or not attempts
        or not data
        or type(attempts.GetChallengeSeed) ~= "function"
        or type(data.GetChallengeSeed) ~= "function"
    then
        return "unknown", nil
    end
    local okStored, stored = pcall(attempts.GetChallengeSeed, kind)
    local okCurrent, current = pcall(data.GetChallengeSeed, kind)
    if not okStored or not okCurrent or not finite(stored) or not finite(current) then
        return "unknown", nil
    end
    if stored < current then
        return "available", current
    end
    if stored == current then
        return "unavailable", current
    end
    return "unknown", nil
end

--- Reads the Rift's open flag and server-reported remaining attempts; zero means unavailable, not cleared.
function ActivityState.rift(gameObject: any, specialEvents: any): string
    local okOpen, open = pcall(function()
        return gameObject:GetService("Workspace"):GetAttribute(config.attributes.riftOpen)
    end)
    if not okOpen or type(open) ~= "boolean" then
        return "unknown"
    end
    if not open then
        return "unavailable"
    end
    local remote = specialEvents and specialEvents[config.remoteNames.getRiftAttempts]
    if not remote or type(remote.Invoke) ~= "function" then
        return "unknown"
    end
    local ok, response = pcall(remote.Invoke)
    if
        not ok
        or type(response) ~= "table"
        or response.Ready ~= true
        or not finite(response.AttemptsRemaining)
    then
        return "unknown"
    end
    return if response.AttemptsRemaining > 0 then "available" else "unavailable"
end

--- Creates per-player storage; reads return nil unless schema, identity, age and period remain valid.
function ActivityState.new(env: any, userId: number): any
    local storage = FileStorage.new(env, STORAGE_KEY)
    local http = env.game and env.game:GetService("HttpService")
    local self = {}

    function self.save(
        now: number,
        states: { [string]: any },
        challengeSeeds: { [string]: number }?,
        riftInfo: any?
    ): boolean
        if not storage or not http or not finite(now) or not finite(userId) then
            return false
        end
        local ok, body = pcall(http.JSONEncode, http, {
            schemaVersion = SCHEMA_VERSION,
            userId = userId,
            observedAt = now,
            states = states,
            challengeSeeds = challengeSeeds,
            riftInfo = riftInfo,
        })
        return ok and type(body) == "string" and storage.write(body)
    end

    function self.load(now: number, challengeData: any): any?
        if not storage or not http or not finite(now) then
            return nil
        end
        local body = storage.read()
        if not body then
            return nil
        end
        local ok, value = pcall(http.JSONDecode, http, body)
        if not ok or type(value) ~= "table" then
            return nil
        end
        local observedAt = value.observedAt
        local maxAge = config.thresholds.activitySnapshotSeconds or 7200
        if
            value.schemaVersion ~= SCHEMA_VERSION
            or value.userId ~= userId
            or not finite(observedAt)
            or (observedAt :: number) > now
            or now - (observedAt :: number) > maxAge
        then
            return nil
        end
        local states = {}
        -- 1. Compare stored challenge seeds against live challengeData.GetChallengeSeed
        if
            type(value.challengeSeeds) == "table"
            and challengeData
            and type(challengeData.GetChallengeSeed) == "function"
        then
            for _, kind in { "Regular", "Daily", "Weekly" } do
                local storedSeed = value.challengeSeeds[kind]
                if finite(storedSeed) then
                    local okPeriod, currentPeriod = pcall(challengeData.GetChallengeSeed, kind)
                    if okPeriod and finite(currentPeriod) then
                        if (storedSeed :: number) < (currentPeriod :: number) then
                            states[kind] = { status = "available", period = currentPeriod }
                        else
                            states[kind] = { status = "unavailable", period = currentPeriod }
                        end
                    end
                end
            end
        end
        -- 2. Fallback to stored states if not yet set by seeds
        if type(value.states) == "table" then
            for _, kind in { "Regular", "Daily", "Weekly" } do
                if not states[kind] then
                    local entry = value.states[kind]
                    if
                        type(entry) == "table"
                        and (entry.status == "available" or entry.status == "unavailable")
                        and finite(entry.period)
                        and challengeData
                        and type(challengeData.GetChallengeSeed) == "function"
                    then
                        local okPeriod, period = pcall(challengeData.GetChallengeSeed, kind)
                        if okPeriod and finite(period) then
                            if
                                (period :: number) > (entry.period :: number)
                                or entry.status == "available"
                            then
                                states[kind] = { status = "available", period = period }
                            else
                                states[kind] = { status = "unavailable", period = period }
                            end
                        end
                    end
                end
            end
        end
        -- 3. Rift handling: open on the hour (0-10m) unless confirmed cleared in this exact hour
        local currentHour = math.floor(now / 3600)
        local isOpenWindow = (now % 3600 < (config.thresholds.riftSnapshotSeconds or 600))
        if isOpenWindow then
            local alreadyCompletedThisHour = false
            local rInfo = value.riftInfo
            if type(rInfo) == "table" and finite(rInfo.attempts) and finite(rInfo.hour) then
                if rInfo.attempts == 0 and rInfo.hour == currentHour then
                    alreadyCompletedThisHour = true
                end
            end
            if not alreadyCompletedThisHour then
                states.Rift = { status = "available" }
            else
                states.Rift = { status = "unavailable" }
            end
        else
            states.Rift = { status = "unavailable" }
        end
        return {
            states = states,
        }
    end

    return self
end

return ActivityState
