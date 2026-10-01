--!strict
--[[
Purpose: Own Discord webhook settings, persistence and the event sources that feed notifications
Input: Joiner and Auto Play runtimes (status text), game modules (units, match, bounty), executor request API and context lifetime
Output: Queued Discord embeds for match results, new units, joiner/bounty/rift/equipper/autoplay notices and a test message
Dependencies: Config; Embed; Events; Sender; Session; FileStorage
]]

local FileStorage = require("../../../platform/FileStorage")
local config = require("../Config")
local metadata = require("../Metadata")
local Embed = require("./Embed")
local Events = require("./Events")
local Sender = require("./Sender")
local Session = require("./Session")
local Runtime = {}

local STORAGE_KEY = "AnimeVanguardsWebhook"
local SCHEMA_VERSION = 1
local WEBHOOK: any = (config :: any).webhook
local THRESHOLDS: any = (config :: any).thresholds
local TICK_SECONDS = 1
local SESSION_DELAY_SECONDS = 5
local END_SCREEN_DELAY_SECONDS = 1.5
local UNIT_DEDUP_LIMIT = 4000

local function resolve(root: any, path: string): any
    local value = root
    for part in string.gmatch(path, "[^%.]+") do
        if not value then
            return nil
        end
        local ok, child = pcall(function()
            local v: any = value
            if type(v) == "userdata" then
                return v:FindFirstChild(part)
            else
                return v[part]
            end
        end)
        value = if ok then child else nil
    end
    return value
end

local function optionalModule(root: any, path: string): any
    local ok, result = pcall(function()
        return (require :: any)(resolve(root, path))
    end)
    return if ok then result else nil
end

local function defaults(): any
    local events: { [string]: boolean } = {}
    for _, kind in Events.kinds do
        events[kind.id] = kind.default
    end
    return {
        enabled = false,
        url = nil,
        username = "",
        avatarUrl = "",
        showPlayer = true,
        pingUserId = "",
        minRarity = WEBHOOK.rarityOrder[1],
        events = events,
    }
end

-- Reads the match end screen (best effort): result text, stat rows ("Key:" label next to its value) and reward tiles.
local function readEndScreen(gameObject: any): any
    local ok, result = pcall(function(): any
        local players = gameObject:GetService("Players")
        local playerGui = players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local screen = playerGui and playerGui:FindFirstChild("EndScreen")
        if not screen then
            return nil
        end
        local data: any = { rewards = {} }
        local keys: { [string]: string } = {
            ["Units Placed:"] = "units",
            ["Total Damage:"] = "damage",
            ["Play Time:"] = "time",
            ["Money Earned:"] = "money",
            ["Takedowns:"] = "takedowns",
            ["Waves Completed:"] = "waves",
        }
        for _, label in screen:GetDescendants() do
            if label:IsA("TextLabel") then
                local text = label.Text
                local lower = string.lower(text)
                if data.result == nil and (lower == "victory" or lower == "defeat") then
                    data.result = if lower == "victory" then "Victory" else "Defeat"
                end
                local key = keys[text]
                if key and label.Parent then
                    for _, sibling in label.Parent:GetChildren() do
                        if sibling ~= label and sibling:IsA("TextLabel") and sibling.Text ~= text then
                            data[key] = sibling.Text
                        end
                    end
                end
                if string.match(text, "^[xX]%d[%d,%.]*[KMB]?$") and label.Parent and #data.rewards < 12 then
                    for _, sibling in label.Parent:GetChildren() do
                        if
                            sibling ~= label
                            and sibling:IsA("TextLabel")
                            and not string.match(sibling.Text, "^[xX]?%d")
                        then
                            table.insert(
                                data.rewards,
                                { name = sibling.Text, amount = string.gsub(text, "^[xX]", "") }
                            )
                            break
                        end
                    end
                end
            end
        end
        return data
    end)
    return if ok then result else nil
end

--- Creates the webhook controller; injected dependencies support isolated tests.
function Runtime.new(injected: any?): any
    local self: any = {
        deps = injected,
        settings = defaults(),
        sender = nil,
        context = nil,
        loaded = false,
        status = "Not configured",
        onStatus = nil,
        storage = nil,
        cooldowns = {} :: { [string]: number },
        seenUnits = {} :: { [string]: boolean },
        seenCount = 0,
        unitReadyAt = math.huge,
        bountyLeft = nil,
        bountyChecked = -math.huge,
        riftWasOpen = nil,
        matchStartedAt = nil,
        connections = {} :: { any },
        sources = {} :: { any },
    }

    local function deps(): any
        return self.deps or {}
    end

    -- Calls an injected function by name; returns nil when it is not provided.
    local function call(name: string, ...: any): any
        local fn: any = deps()[name]
        if type(fn) == "function" then
            return (fn :: any)(...)
        end
        return nil
    end

    local function has(name: string): boolean
        return type(deps()[name]) == "function"
    end

    local function clock(): number
        local value = call("clock")
        return if type(value) == "number" then value else os.clock()
    end

    local function setStatus(value: string)
        self.status = value
        if self.onStatus then
            pcall(self.onStatus, value)
        end
    end

    local function describeState(): string
        local sender = self.sender
        if not Embed.validUrl(self.settings.url, WEBHOOK.hosts) then
            return "Not configured: paste a Discord webhook URL"
        end
        if sender and sender.state == "invalid" then
            return "Discord rejected the webhook URL (deleted or wrong); set it again"
        end
        if not self.settings.enabled then
            return "Configured; notifications are off"
        end
        local stats = if sender then sender.stats else { sent = 0, failed = 0, dropped = 0 }
        return string.format(
            "On • %s • sent %d, failed %d, dropped %d",
            if sender then sender.state else "idle",
            stats.sent,
            stats.failed,
            stats.dropped
        )
    end

    local function refreshStatus()
        setStatus(describeState())
    end

    local function save()
        local storage = self.storage
        local d = deps()
        if not storage or not d.encode then
            return
        end
        local ok, body = pcall(d.encode, {
            schemaVersion = SCHEMA_VERSION,
            enabled = self.settings.enabled,
            url = self.settings.url,
            username = self.settings.username,
            avatarUrl = self.settings.avatarUrl,
            showPlayer = self.settings.showPlayer,
            pingUserId = self.settings.pingUserId,
            minRarity = self.settings.minRarity,
            events = self.settings.events,
        })
        if ok and type(body) == "string" then
            pcall(storage.write, body)
        end
    end

    local function ensureSender()
        if self.sender then
            return
        end
        local d = deps()
        if not d.request or not d.encode or not d.task then
            return
        end
        local sender = Sender.new({
            request = d.request,
            encode = d.encode,
            decode = d.decode,
            task = d.task,
            clock = clock,
            minInterval = THRESHOLDS.webhookMinIntervalSeconds,
            queueLimit = THRESHOLDS.webhookQueueLimit,
            retryLimit = THRESHOLDS.webhookRetryLimit,
        })
        sender.onState = function()
            refreshStatus()
        end
        if Embed.validUrl(self.settings.url, WEBHOOK.hosts) then
            sender.setUrl(self.settings.url)
        end
        self.sender = sender
    end

    local function context(): any
        local d = deps()
        return {
            player = d.playerName,
            displayName = d.displayName,
            level = call("readLevel"),
            avatarUrl = self.avatarUrl,
            userId = d.userId,
            showPlayer = self.settings.showPlayer,
            timestamp = if has("timestamp") then call("timestamp") else os.date("!%Y-%m-%dT%H:%M:%SZ"),
            version = metadata.version,
        }
    end

    local function dispatch(kind: string, data: any): boolean
        ensureSender()
        local sender = self.sender
        if not sender or not sender.isReady() then
            return false
        end
        local spec, ping = Events.build(kind, data, context(), WEBHOOK)
        if not spec then
            return false
        end
        local embed = Embed.build(spec)
        local payload = Embed.payload({ embed }, {
            username = if self.settings.username ~= ""
                then self.settings.username
                else WEBHOOK.defaultUsername,
            avatarUrl = if self.settings.avatarUrl ~= "" then self.settings.avatarUrl else nil,
            pingUserId = self.settings.pingUserId,
            ping = ping,
        })
        return sender.enqueue(payload)
    end

    --- Returns a copy of the settings for the page (the URL is replaced by a masked description).
    function self.getSettings(): any
        local copy = table.clone(self.settings)
        copy.events = table.clone(self.settings.events)
        copy.urlMasked = Embed.mask(self.settings.url, WEBHOOK.hosts)
        copy.hasUrl = Embed.validUrl(self.settings.url, WEBHOOK.hosts)
        copy.url = nil
        return copy
    end

    --- Returns the current delivery status text.
    function self.getStatus(): string
        return self.status
    end

    --- Turns notifications on or off.
    function self.setEnabled(value: boolean): boolean
        if type(value) ~= "boolean" then
            return false
        end
        self.settings.enabled = value
        save()
        refreshStatus()
        return true
    end

    --- Stores a webhook URL after validating the host and shape; returns ok and an error code.
    function self.setUrl(url: any): (boolean, string?)
        if not Embed.validUrl(url, WEBHOOK.hosts) then
            return false, "INVALID_URL"
        end
        self.settings.url = url
        ensureSender()
        if self.sender then
            self.sender.setUrl(url)
        end
        save()
        refreshStatus()
        return true, nil
    end

    --- Forgets the stored webhook URL.
    function self.clearUrl()
        self.settings.url = nil
        if self.sender then
            self.sender.setUrl(nil)
        end
        save()
        refreshStatus()
    end

    --- Sets the bot name shown in Discord (empty uses the default).
    function self.setUsername(value: any): boolean
        if type(value) ~= "string" then
            return false
        end
        self.settings.username = if value == "" then "" else Embed.username(value, WEBHOOK.defaultUsername)
        save()
        return true
    end

    --- Sets the bot avatar image URL (https only; empty clears it).
    function self.setAvatar(value: any): boolean
        if type(value) ~= "string" then
            return false
        end
        local trimmed = string.match(value, "^%s*(.-)%s*$") or ""
        if trimmed ~= "" and string.match(trimmed, "^https://[%w%.%-]+/") == nil then
            return false
        end
        self.settings.avatarUrl = Embed.clip(trimmed, 512)
        save()
        return true
    end

    --- Includes (or hides) the player's name and avatar on every embed.
    function self.setShowPlayer(value: boolean): boolean
        if type(value) ~= "boolean" then
            return false
        end
        self.settings.showPlayer = value
        save()
        return true
    end

    --- Sets the Discord user id to ping for rare units and problems (digits only; empty disables pings).
    function self.setPingUser(value: any): boolean
        if type(value) ~= "string" then
            return false
        end
        local trimmed = string.match(value, "^%s*(.-)%s*$") or ""
        if trimmed ~= "" and (string.match(trimmed, "^%d+$") == nil or #trimmed < 15 or #trimmed > 25) then
            return false
        end
        self.settings.pingUserId = trimmed
        save()
        return true
    end

    --- Sets the lowest unit rarity that triggers a new-unit notification.
    function self.setMinRarity(value: any): boolean
        if type(value) ~= "string" or table.find(WEBHOOK.rarityOrder, value) == nil then
            return false
        end
        self.settings.minRarity = value
        save()
        return true
    end

    --- Turns one event kind on or off.
    function self.setEvent(kind: any, value: boolean): boolean
        if type(kind) ~= "string" or type(value) ~= "boolean" or self.settings.events[kind] == nil then
            return false
        end
        self.settings.events[kind] = value
        save()
        return true
    end

    --- Queues an event when notifications are on and that event is enabled; key and cooldown (seconds) dedupe repeats.
    function self.notify(kind: string, data: any, key: string?, cooldown: number?): boolean
        if not self.settings.enabled or self.settings.events[kind] ~= true then
            return false
        end
        if key then
            local now = clock()
            local last = self.cooldowns[key]
            if last and now - last < (cooldown or 0) then
                return false
            end
            self.cooldowns[key] = now
        end
        return dispatch(kind, data)
    end

    --- Sends a test message regardless of event switches; returns ok and an error code.
    function self.sendTest(): (boolean, string?)
        if not Embed.validUrl(self.settings.url, WEBHOOK.hosts) then
            return false, "NO_URL"
        end
        local count = 0
        for _, value in self.settings.events do
            if value then
                count += 1
            end
        end
        if not dispatch("test", { enabledCount = count }) then
            return false, "NOT_SENT"
        end
        return true, nil
    end

    -- New unit: ignored while the inventory is still replicating and for units that were already owned.
    function self.onUnitAdded(argument: any)
        if clock() < self.unitReadyAt then
            return
        end
        local guid: string? = nil
        local unit: any = nil
        if type(argument) == "string" then
            guid = argument
            unit = call("unitObject", argument)
        elseif type(argument) == "table" then
            unit = argument
            guid = argument.UniqueIdentifier
        end
        if type(guid) ~= "string" or self.seenUnits[guid] then
            return
        end
        if self.seenCount >= UNIT_DEDUP_LIMIT then
            table.clear(self.seenUnits)
            self.seenCount = 0
        end
        self.seenUnits[guid] = true
        self.seenCount += 1
        if type(unit) ~= "table" or type(unit.UnitData) ~= "table" then
            return
        end
        local rarity = unit.UnitData.Rarity
        if
            Events.rarityRank(rarity, WEBHOOK.rarityOrder)
            < Events.rarityRank(self.settings.minRarity, WEBHOOK.rarityOrder)
        then
            return
        end
        local trait = nil
        if type(unit.Trait) == "table" and type(unit.Trait.Name) == "string" then
            trait = unit.Trait.Name
        end
        self.notify("unit", {
            name = unit.UnitData.Name,
            rarity = rarity,
            level = unit.Level,
            trait = trait,
            subTrait = unit.SubTrait,
        })
    end

    -- Classifies a status line from the Joiner or Auto Play runtime into an event, or nil to ignore it.
    local function classify(source: string, text: string): (string?, string?, any?)
        local lower = string.lower(text)
        local function has(...: string): boolean
            for _, needle in { ... } do
                if string.find(lower, needle, 1, true) then
                    return true
                end
            end
            return false
        end
        if source == "joiner" then
            if string.find(text, "^Team Equipper:") or string.find(text, "^Macro Equipper:") then
                if has("not available", "no usable", "not confirmed", "could not", "not loaded") then
                    return "equipper", "equipper:" .. text, { message = text }
                end
                return nil, nil, nil
            end
            if has("confirmed by server", "entered match") then
                local name = string.match(text, "^([^:]+):") or "Joiner"
                return "join", "join:" .. name, { name = name, message = text }
            end
            if has("none left today") then
                return "bounty", "bounty-none", { left = 0, message = text }
            end
            if
                has(
                    "no server confirmation",
                    "request failed",
                    "locked or progress unavailable",
                    "host state not ready",
                    "start network unavailable",
                    "teleport not confirmed"
                )
            then
                return "joinProblem", "joinProblem:" .. text, { message = text }
            end
            return nil, nil, nil
        end
        if
            has(
                "preset rule cleared",
                "preset switch not confirmed",
                "request failed",
                "timed out",
                "auto play unavailable"
            )
        then
            return "autoPlay", "autoPlay-problem:" .. text, { message = text }
        end
        if has("native auto play active") then
            return "autoPlay", "autoPlay-active", { message = text }
        end
        return nil, nil, nil
    end

    -- Status lines arrive from the Joiner and Auto Play runtimes as they change; repeats are rate limited per key.
    local function watchStatus(source: string, text: any)
        if type(text) ~= "string" or text == "" then
            return
        end
        local kind, key, data = classify(source, text)
        if kind and key then
            local cooldown = THRESHOLDS.webhookProblemCooldownSeconds
            if kind == "join" then
                cooldown = 20
            elseif key == "autoPlay-active" then
                cooldown = 600
            end
            self.notify(kind, data, key, cooldown)
        end
    end

    --- Feeds one status line from a source ("joiner" or "autoPlay") into the classifier.
    function self.onStatusLine(source: string, text: any)
        watchStatus(source, text)
    end

    local function watchBounty(now: number)
        if not has("readBounty") or now - self.bountyChecked < THRESHOLDS.webhookBountyPollSeconds then
            return
        end
        self.bountyChecked = now
        local target: any = call("readBounty")
        if type(target) ~= "table" or type(target.left) ~= "number" then
            return
        end
        local left: number = target.left
        local previous: any = self.bountyLeft
        self.bountyLeft = left
        if previous ~= nil and left < previous then
            self.notify("bounty", {
                left = left,
                mode = target.mode,
                stage = target.stage,
                act = target.act,
                boss = target.boss,
                message = string.format(
                    "A Boss Bounty was cleared (%s → %s).",
                    tostring(previous),
                    tostring(left)
                ),
            })
        end
    end

    local function watchRift()
        local open: any = call("riftOpen")
        if type(open) ~= "boolean" then
            return
        end
        if open and self.riftWasOpen == false then
            self.notify("rift", { message = "The hourly Rift event just opened." }, "rift", 600)
        end
        self.riftWasOpen = open
    end

    --- One polling step: bounty count, rift state and the match wave (called every second while running).
    function self.tick()
        local d = deps()
        watchBounty(clock())
        watchRift()
        if self.matchStartedAt then
            local wave: any = call("readWave")
            if type(wave) == "table" and type(wave.current) == "number" then
                if wave.current > (self.lastWave or 0) then
                    self.lastWave = wave.current
                end
                if type(wave.max) == "number" then
                    self.maxWave = wave.max
                end
            end
        end
        if d.afterTick then
            pcall(d.afterTick)
        end
    end

    -- Reads every configured currency into {key = amount}; nil when the game does not expose them yet.
    local function balances(): { [string]: number }?
        local value: any = call("readCurrencies")
        return if type(value) == "table" then value else nil
    end

    --- Records the match start: the time and the currency balances the earnings are measured against.
    function self.onMatchStarted()
        self.matchStartedAt = clock()
        self.matchBalances = balances()
        self.lastWave = nil
        self.maxWave = nil
    end

    -- Result from the MatchEnded arguments (a boolean, "Victory"/"Defeat" or a table with a flag), or nil when unknown.
    local function resultFromArguments(arguments: { any }): string?
        for _, value in arguments do
            if type(value) == "boolean" then
                return if value then "Victory" else "Defeat"
            elseif type(value) == "string" then
                local lower = string.lower(value)
                if lower == "victory" or lower == "win" or lower == "won" then
                    return "Victory"
                elseif lower == "defeat" or lower == "loss" or lower == "lose" or lower == "lost" then
                    return "Defeat"
                end
            elseif type(value) == "table" then
                for _, key in WEBHOOK.resultKeys do
                    local flag = value[key]
                    if type(flag) == "boolean" then
                        return if flag then "Victory" else "Defeat"
                    elseif type(flag) == "string" then
                        local lower = string.lower(flag)
                        if lower == "victory" or lower == "win" or lower == "won" then
                            return "Victory"
                        elseif lower == "defeat" or lower == "loss" or lower == "lose" or lower == "lost" then
                            return "Defeat"
                        end
                    end
                end
            end
        end
        return nil
    end

    -- Builds the per-currency earnings and balance rows (labels and emoji come from the game config).
    local function currencyRows(before: { [string]: number }?, after: { [string]: number }?): (any, any, any)
        local earnings: { any } = {}
        local rows: { any } = {}
        local gains: { [string]: number } = {}
        for _, currency in WEBHOOK.currencies do
            local now = after and after[currency.key]
            if type(now) == "number" then
                table.insert(
                    rows,
                    { key = currency.key, label = currency.label, emoji = currency.emoji, value = now }
                )
                local was = before and before[currency.key]
                if type(was) == "number" and now > was then
                    gains[currency.key] = now - was
                    table.insert(earnings, { label = currency.label, amount = now - was, balance = now })
                end
            end
        end
        return earnings, rows, gains
    end

    --- Sends the match result from the MatchEnded arguments, the end screen and the match data.
    function self.onMatchEnded(...: any)
        local d = deps()
        local startedAt = self.matchStartedAt
        local before = self.matchBalances or self.balanceBaseline
        local wave, maxWave = self.lastWave, self.maxWave
        local argumentResult = resultFromArguments({ ... })
        self.matchStartedAt = nil
        self.matchBalances = nil
        local function send()
            local screen: any = call("readEndScreen")
            local game: any = call("gameData")
            local info: any = { rewards = {}, currencies = WEBHOOK.currencies }
            if type(game) == "table" then
                info.stageType = game.StageType
                info.stage = game.Stage
                info.act = game.Act
                info.difficulty = game.Difficulty
                for _, key in WEBHOOK.waveMaxKeys do
                    if type(game[key]) == "number" then
                        maxWave = maxWave or game[key]
                        break
                    end
                end
            end
            if type(screen) == "table" then
                info.result = screen.result
                info.damage = screen.damage
                info.takedowns = screen.takedowns
                info.rewards = screen.rewards
                info.durationText = screen.time
            end
            info.result = argumentResult or info.result
            if wave then
                info.wave = wave
                info.maxWave = maxWave
            end
            if startedAt then
                info.duration = clock() - startedAt
            end
            local after = balances()
            local earnings, rows, gains = currencyRows(before, after)
            info.earnings = earnings
            info.balances = rows
            if after then
                self.balanceBaseline = after
            end
            local macro: any = call("macroInfo")
            if type(macro) == "table" then
                info.macro = macro
            end
            if info.result == nil then
                info.unknownResult = true
                info.result = "Defeat"
            elseif self.session then
                self.session.record(info.result == "Victory", info.duration, gains)
            end
            if self.session then
                info.session = self.session.summary()
            end
            self.notify("matchEnd", info)
        end
        local taskApi: any = d.task
        if
            type(taskApi) == "table"
            and type(taskApi.spawn) == "function"
            and type(taskApi.wait) == "function"
        then
            local spawnTask: any = taskApi.spawn
            local waitTask: any = taskApi.wait
            spawnTask(function()
                waitTask(END_SCREEN_DELAY_SECONDS)
                send()
            end)
        else
            send()
        end
    end

    --- Starts delivery, loads saved settings, seeds the known-unit set and connects the game event sources.
    function self.start(ctx: any, sources: any?)
        self.context = ctx
        self.sources = sources or {}
        local env: any = getfenv()
        local d = deps()
        if not self.deps then
            d = {}
            local gameObject = env.game
            if gameObject then
                local players = gameObject:GetService("Players")
                local replicated = gameObject:GetService("ReplicatedStorage")
                local starter = gameObject:GetService("StarterPlayer")
                local http = gameObject:GetService("HttpService")
                local requestFn = env.request or env.http_request
                local isLobby = gameObject.PlaceId == metadata.placeIds[1]
                local ownedUnits = optionalModule(starter, config.instancePaths.ownedUnits)
                local gameHandler = optionalModule(replicated, config.instancePaths.gameHandler)
                local wavesHud = optionalModule(starter, config.instancePaths.wavesHud)
                d = {
                    encode = function(value: any): string
                        return http:JSONEncode(value)
                    end,
                    decode = function(text: string): any
                        return http:JSONDecode(text)
                    end,
                    request = requestFn,
                    task = env.task,
                    playerName = players.LocalPlayer.Name,
                    displayName = players.LocalPlayer.DisplayName,
                    fetchAvatar = function(): string?
                        local ok, response = pcall(requestFn, {
                            Url = string.format(
                                "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=150x150&format=Png",
                                players.LocalPlayer.UserId
                            ),
                            Method = "GET",
                        })
                        if not ok or type(response) ~= "table" or type(response.Body) ~= "string" then
                            return nil
                        end
                        local okJson, data = pcall(http.JSONDecode, http, response.Body)
                        local row = if okJson
                                and type(data) == "table"
                                and type(data.data) == "table"
                            then data.data[1]
                            else nil
                        local url = if type(row) == "table" then row.imageUrl else nil
                        return if type(url) == "string" and string.match(url, "^https://[%w%.%-]+/")
                            then url
                            else nil
                    end,
                    readCurrencies = function(): { [string]: number }?
                        local values: { [string]: number } = {}
                        for _, currency in WEBHOOK.currencies do
                            local ok, value =
                                pcall(players.LocalPlayer.GetAttribute, players.LocalPlayer, currency.key)
                            if ok and type(value) == "number" then
                                values[currency.key] = value
                            end
                        end
                        return if next(values) then values else nil
                    end,
                    readLevel = function(): number?
                        local ok, value = pcall(
                            players.LocalPlayer.GetAttribute,
                            players.LocalPlayer,
                            WEBHOOK.levelAttribute
                        )
                        return if ok and type(value) == "number" then value else nil
                    end,
                    readWave = function(): any
                        local current = if wavesHud then wavesHud.CurrentWave else nil
                        local number = tonumber(current)
                        return if number then { current = number } else nil
                    end,
                    macroInfo = function(): any
                        local macro = self.sources.macro
                        local document = if type(macro) == "table" then macro.activeDocument else nil
                        if
                            type(document) == "table"
                            and macro.mode == "play"
                            and type(document.name) == "string"
                        then
                            return { name = document.name, status = "Playing" }
                        end
                        return nil
                    end,
                    userId = players.LocalPlayer.UserId,
                    unitObject = if ownedUnits and ownedUnits.GetUnitObject
                        then function(guid: string): any
                            local ok, unit = pcall(ownedUnits.GetUnitObject, guid)
                            return if ok then unit else nil
                        end
                        else nil,
                    gameData = if gameHandler and gameHandler.GetGameData
                        then function(): any
                            if gameHandler.IsGameLoaded ~= true then
                                return nil
                            end
                            local ok, value = pcall(gameHandler.GetGameData, gameHandler)
                            return if ok then value else nil
                        end
                        else nil,
                    readEndScreen = function(): any
                        return readEndScreen(gameObject)
                    end,
                    readBounty = function(): any
                        local joiner = self.sources.joiner
                        if joiner and type(joiner.readBounty) == "function" then
                            return (joiner.readBounty :: any)()
                        end
                        return nil
                    end,
                    riftOpen = function(): boolean?
                        local ws: any = gameObject:GetService("Workspace")
                        local ok, value = pcall(ws.GetAttribute, ws, config.attributes.riftOpen)
                        return if ok and type(value) == "boolean" then value else nil
                    end,
                    ownedUnitsModule = ownedUnits,
                    gameHandlerModule = gameHandler,
                    isLobby = isLobby,
                }
            end
            self.deps = d
        end
        if not self.storage and d.storage then
            self.storage = d.storage
        end
        if not self.storage and env.game then
            pcall(function()
                self.storage = FileStorage.new(env, STORAGE_KEY)
            end)
        end
        local storage = self.storage
        if storage and d.decode then
            local body = storage.read()
            if body then
                local ok, data = pcall(d.decode, body)
                if ok and type(data) == "table" and data.schemaVersion == SCHEMA_VERSION then
                    local settings = self.settings
                    if type(data.enabled) == "boolean" then
                        settings.enabled = data.enabled
                    end
                    if Embed.validUrl(data.url, WEBHOOK.hosts) then
                        settings.url = data.url
                    end
                    if type(data.username) == "string" then
                        settings.username = Embed.clip(data.username, 80)
                    end
                    if
                        type(data.avatarUrl) == "string"
                        and string.match(data.avatarUrl, "^https://[%w%.%-]+/")
                    then
                        settings.avatarUrl = Embed.clip(data.avatarUrl, 512)
                    end
                    if type(data.showPlayer) == "boolean" then
                        settings.showPlayer = data.showPlayer
                    end
                    if
                        type(data.pingUserId) == "string"
                        and (data.pingUserId == "" or string.match(data.pingUserId, "^%d+$"))
                    then
                        settings.pingUserId = Embed.clip(data.pingUserId, 25)
                    end
                    if
                        type(data.minRarity) == "string" and table.find(WEBHOOK.rarityOrder, data.minRarity)
                    then
                        settings.minRarity = data.minRarity
                    end
                    if type(data.events) == "table" then
                        for kind, value in data.events do
                            if settings.events[kind] ~= nil and type(value) == "boolean" then
                                settings.events[kind] = value
                            end
                        end
                    end
                end
            end
        end
        self.loaded = true
        self.session = Session.new(clock)
        self.balanceBaseline = balances()
        ensureSender()
        refreshStatus()

        -- Units that already exist are never announced; units added after the inventory settles are.
        if d.ownedUnitsModule and type(d.ownedUnitsModule.GetOwnedUnits) == "function" then
            local ok, owned = pcall(d.ownedUnitsModule.GetOwnedUnits)
            if ok and type(owned) == "table" then
                for guid in owned do
                    if type(guid) == "string" then
                        self.seenUnits[guid] = true
                        self.seenCount += 1
                    end
                end
            end
            local signal = d.ownedUnitsModule.UnitAdded
            if type(signal) == "table" and type(signal.Connect) == "function" then
                local okConnect, connection = pcall(signal.Connect, signal, function(argument: any)
                    self.onUnitAdded(argument)
                end)
                if okConnect and connection then
                    table.insert(self.connections, connection)
                end
            end
        end
        self.unitReadyAt = clock() + THRESHOLDS.webhookUnitIgnoreSeconds
        if d.gameHandlerModule and not d.isLobby then
            for name, handler in
                { MatchStarted = self.onMatchStarted, MatchEnded = self.onMatchEnded } :: { [string]: any }
            do
                local signal = d.gameHandlerModule[name]
                if type(signal) == "table" and type(signal.Connect) == "function" then
                    local fire: any = handler
                    local okConnect, connection = pcall(signal.Connect, signal, function(...: any)
                        fire(...)
                    end)
                    if okConnect and connection then
                        table.insert(self.connections, connection)
                    end
                end
            end
        end

        for source, runtime in
            { joiner = self.sources.joiner, autoPlay = self.sources.autoPlay } :: { [string]: any }
        do
            if type(runtime) == "table" and type(runtime.addStatusListener) == "function" then
                local subscribe: any = runtime.addStatusListener
                local remove = subscribe(function(text: string)
                    self.onStatusLine(source, text)
                end)
                table.insert(self.connections, remove)
            end
        end

        local taskApi = d.task
        if
            type(taskApi) == "table"
            and type(taskApi.spawn) == "function"
            and type(taskApi.wait) == "function"
        then
            local spawnTask: any = taskApi.spawn
            local waitTask: any = taskApi.wait
            spawnTask(function()
                -- Discord cannot load Roblox redirect links, so ask the thumbnails API for the real image URL once.
                local fetched: any = call("fetchAvatar")
                if type(fetched) == "string" then
                    self.avatarUrl = fetched
                end
                waitTask(SESSION_DELAY_SECONDS)
                if self.context == ctx and ctx.alive then
                    self.notify("session", {
                        place = if d.isLobby then "Lobby" else "Match",
                        placeName = if env.game then tostring(env.game.PlaceId) else nil,
                    })
                end
                while self.context == ctx and ctx.alive do
                    pcall(self.tick)
                    waitTask(TICK_SECONDS)
                end
            end)
        end
    end

    --- Disconnects game events and stops delivery; safe to repeat.
    function self.stop()
        for _, connection in self.connections do
            local conn: any = connection
            local ok = pcall(function()
                conn:Disconnect()
            end)
            if not ok then
                pcall(conn)
            end
        end
        table.clear(self.connections)
        if self.sender then
            self.sender.stop()
            self.sender = nil
        end
        self.context = nil
    end

    return self
end

return Runtime
