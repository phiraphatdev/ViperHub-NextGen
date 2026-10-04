--!strict
--[[
Purpose: Home page: player card, live status of every feature and the player's balances at a glance
Input: WindUI tab handle and the game's runtimes (joiner, auto play, macro, webhook, misc)
Output: Mounted cards refreshed every few seconds while the context is alive
Dependencies: Style; Config; Metadata
]]

local Style = require("../Style")
local config = require("../Config")
local metadata = require("../Metadata")
local Page = {}

local REFRESH_SECONDS = 2
local STARTUP_WAIT_TICKS = 60

local function setDesc(card: any, text: string)
    if card and type(card.SetDesc) == "function" then
        pcall(card.SetDesc, card, text)
    end
end

local function commas(value: number): string
    local text = tostring(math.floor(value + 0.5))
    local out = text
    while true do
        local replaced, count = string.gsub(out, "^(-?%d+)(%d%d%d)", "%1,%2")
        out = replaced
        if count == 0 then
            break
        end
    end
    return out
end

--- Mounts the dashboard; runtimes is a table {joiner, autoPlay, macro, webhook, misc} (any may be missing).
function Page.mount(tab: any, runtimes: any)
    local env: any = getfenv()
    local gameObject = env.game
    local player = gameObject and gameObject:GetService("Players").LocalPlayer
    local isLobby = gameObject ~= nil and gameObject.PlaceId == metadata.placeIds[1]

    -- Player card with avatar headshot (rbxthumb is resolved by Roblox, no HTTP needed).
    local level = if player then player:GetAttribute((config :: any).webhook.levelAttribute) else nil
    tab:Paragraph({
        Title = if player then "Welcome, " .. player.DisplayName else "Welcome",
        Desc = string.format(
            "@%s%s • %s",
            if player then tostring(player.Name) else "player",
            if type(level) == "number" then " • Lv. " .. tostring(math.floor(level :: number)) else "",
            if isLobby then "In the lobby" else "In a match"
        ),
        Image = if player
            then string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", player.UserId)
            else "user",
        ImageSize = 52,
    })

    local live = Style.section(tab, "Live Status", "activity", false)
    local cards: { [string]: any } = {}
    local rows = {
        { key = "joiner", title = "Joiner", icon = "users" },
        { key = "autoPlay", title = "Auto Play", icon = "play" },
        { key = "macro", title = "Macro", icon = "list" },
        { key = "webhook", title = "Webhook", icon = "bell" },
        { key = "misc", title = "Session", icon = "shield-check" },
    }
    for _, row in rows do
        cards[row.key] = live:Paragraph({ Title = row.title, Desc = "…", Image = row.icon, ImageSize = 20 })
    end

    local wallet = Style.section(tab, "Balances", "gem", false)
    local balanceCards: { [string]: any } = {}
    for _, currency in (config :: any).webhook.currencies do
        balanceCards[currency.key] =
            wallet:Paragraph({ Title = currency.emoji .. " " .. currency.label, Desc = "…" })
    end

    local function statusOf(key: string): string
        local runtime = runtimes and runtimes[key]
        if type(runtime) ~= "table" then
            return "Unavailable"
        end
        if key == "webhook" and type(runtime.getStatus) == "function" then
            local ok, text = pcall(runtime.getStatus)
            return if ok and type(text) == "string" then text else "Unavailable"
        end
        return if type(runtime.status) == "string" then runtime.status else "Idle"
    end

    local function refresh()
        for _, row in rows do
            setDesc(cards[row.key], statusOf(row.key))
        end
        if player then
            for _, currency in (config :: any).webhook.currencies do
                local value = player:GetAttribute(currency.key)
                setDesc(balanceCards[currency.key], if type(value) == "number" then commas(value) else "—")
            end
        end
    end
    pcall(refresh)

    local taskApi: any = env.task
    if type(taskApi) ~= "table" or type(taskApi.spawn) ~= "function" or type(taskApi.wait) ~= "function" then
        return
    end
    local spawnTask: any = taskApi.spawn
    local waitTask: any = taskApi.wait
    spawnTask(function()
        -- The page is built before the runtimes start: wait for the joiner's context, stop when it ends.
        local joiner = runtimes and runtimes.joiner
        local mounted: any = nil
        local idle = 0
        while true do
            local current: any = if type(joiner) == "table" then joiner.context else nil
            if mounted == nil then
                if current ~= nil and current.alive == true then
                    mounted = current
                else
                    idle += 1
                    if idle > STARTUP_WAIT_TICKS then
                        return
                    end
                end
            elseif mounted.alive ~= true or joiner.context ~= mounted then
                return
            end
            pcall(refresh)
            waitTask(REFRESH_SECONDS)
        end
    end)
end

return Page
