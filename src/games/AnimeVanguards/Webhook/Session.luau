--!strict
--[[
Purpose: Track this session's match results, win/loss streaks and earnings for webhook summaries
Input: Clock function, then one record per finished match (result, duration, per-currency gains)
Output: Summary table with totals, win rate, streaks, uptime, run pace, hourly rates and a progress bar
Dependencies: None
]]

local Session = {}

local BAR_SEGMENTS = 10
local MIN_RATE_SECONDS = 60

--- Creates a session tracker whose uptime starts at the first clock reading.
function Session.new(clock: () -> number): any
    local self: any = {
        startedAt = clock(),
        wins = 0,
        losses = 0,
        streakKind = "",
        streakCount = 0,
        bestWinStreak = 0,
        runSeconds = 0,
        gains = {} :: { [string]: number },
    }

    --- Adds a finished match; gains maps currency key to the amount earned (negative values are ignored).
    function self.record(won: boolean, duration: number?, gains: { [string]: number }?)
        if won then
            self.wins += 1
        else
            self.losses += 1
        end
        local kind = if won then "W" else "L"
        if self.streakKind == kind then
            self.streakCount += 1
        else
            self.streakKind = kind
            self.streakCount = 1
        end
        if won and self.streakCount > self.bestWinStreak then
            self.bestWinStreak = self.streakCount
        end
        if type(duration) == "number" and duration > 0 then
            self.runSeconds += duration
        end
        for key, amount in gains or {} do
            if type(amount) == "number" and amount > 0 then
                self.gains[key] = (self.gains[key] or 0) + amount
            end
        end
    end

    --- Returns the current totals and derived figures.
    function self.summary(): any
        local total = self.wins + self.losses
        local uptime = math.max(0, clock() - self.startedAt)
        local winRate = if total > 0 then self.wins / total * 100 else 0
        local filled = math.floor(winRate / 100 * BAR_SEGMENTS + 0.5)
        local rates: { [string]: number } = {}
        if uptime >= MIN_RATE_SECONDS then
            for key, amount in self.gains do
                rates[key] = amount / uptime * 3600
            end
        end
        return {
            wins = self.wins,
            losses = self.losses,
            total = total,
            winRate = winRate,
            bar = filled,
            barSize = BAR_SEGMENTS,
            streak = if self.streakCount > 0 then tostring(self.streakCount) .. self.streakKind else "-",
            bestStreak = if self.bestWinStreak > 0 then tostring(self.bestWinStreak) .. "W" else "-",
            uptime = uptime,
            averageRun = if total > 0 then uptime / total else 0,
            runsPerHour = if total > 0 and uptime >= MIN_RATE_SECONDS then total / uptime * 3600 else 0,
            gains = table.clone(self.gains),
            rates = rates,
        }
    end

    return self
end

return Session
