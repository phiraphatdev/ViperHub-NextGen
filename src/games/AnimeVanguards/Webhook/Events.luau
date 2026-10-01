--!strict
--[[
Purpose: Define the webhook event catalog and turn event data into styled Discord embed specs
Input: Event kind, event data, delivery context (player, time, place) and the game config's webhook styling
Output: Embed specs plus whether the event should ping, and the catalog used by the settings page
Dependencies: Embed
]]

local Embed = require("./Embed")
local Events = {}

local GREEN = 0x2ECC71
local RED = 0xE74C3C
local BLUE = 0x3498DB
local ORANGE = 0xE67E22
local TEAL = 0x1ABC9C
local PURPLE = 0x9B59B6

export type Kind = { id: string, label: string, desc: string, default: boolean }

--- Event kinds shown on the Webhook page, in display order.
Events.kinds = table.freeze({
    {
        id = "matchEnd",
        label = "Match result",
        desc = "Victory or defeat with stage, time, waves, damage and rewards.",
        default = true,
    },
    {
        id = "unit",
        label = "New unit obtained",
        desc = "Every new unit at or above the minimum rarity (Secret, Exclusive and Vanguard can ping you).",
        default = true,
    },
    {
        id = "join",
        label = "Joiner entered a stage",
        desc = "A joiner created or entered a stage, challenge, rift or bounty.",
        default = true,
    },
    {
        id = "joinProblem",
        label = "Joiner problems",
        desc = "No server confirmation, locked stages and failed requests.",
        default = true,
    },
    {
        id = "bounty",
        label = "Boss Bounty progress",
        desc = "Remaining Boss Bounties and today's target.",
        default = true,
    },
    { id = "rift", label = "Rift opened", desc = "The hourly Rift event opened.", default = true },
    {
        id = "equipper",
        label = "Team and Macro Equipper",
        desc = "Missing units, unavailable teams and equip failures.",
        default = true,
    },
    {
        id = "autoPlay",
        label = "Auto Play notices",
        desc = "Native Auto Play enabled, preset switched or unavailable.",
        default = true,
    },
    {
        id = "warning",
        label = "Warnings and errors",
        desc = "Anything the script flags as a problem.",
        default = true,
    },
    { id = "session", label = "Session started", desc = "Sent once when ViperHub loads.", default = true },
}) :: { Kind }

--- Returns the index of a rarity in the config's order (0 when unknown).
function Events.rarityRank(rarity: any, order: { string }): number
    if type(rarity) ~= "string" then
        return 0
    end
    return table.find(order, rarity) or 0
end

local function field(name: string, value: any, inline: boolean?): Embed.Field?
    local text = if type(value) == "string" then value else tostring(value)
    if text == "" or text == "nil" then
        return nil
    end
    return { name = name, value = text, inline = inline ~= false }
end

local function addField(fields: { Embed.Field }, name: string, value: any, inline: boolean?)
    local entry = field(name, value, inline)
    if entry then
        table.insert(fields, entry)
    end
end

local function modeText(data: any): string
    local parts: { string } = {}
    for _, key in { "stageType", "stage", "act" } do
        if type(data[key]) == "string" and data[key] ~= "" then
            table.insert(parts, data[key])
        end
    end
    if type(data.difficulty) == "string" and data.difficulty ~= "" then
        table.insert(parts, "(" .. data.difficulty .. ")")
    end
    return table.concat(parts, " ")
end

local function rewardLines(rewards: any): string
    local lines: { string } = {}
    if type(rewards) == "table" then
        for _, reward in rewards do
            if type(reward) == "table" and type(reward.name) == "string" then
                local amount = if reward.amount ~= nil then " ×" .. tostring(reward.amount) else ""
                table.insert(lines, "• " .. reward.name .. amount)
            end
            if #lines >= 12 then
                break
            end
        end
    end
    return table.concat(lines, "\n")
end

--- Builds the embed spec for an event; returns the spec and whether the event should ping the configured user.
--- ctx: {player, userId, showPlayer, timestamp, version}; config: the game config's webhook table.
function Events.build(kind: string, data: any, ctx: any, config: any): (Embed.Spec?, boolean)
    local info: any = if type(data) == "table" then data else {}
    local fields: { Embed.Field } = {}
    local spec: Embed.Spec = {
        color = BLUE,
        footer = config.footer,
        timestamp = ctx.timestamp,
    }
    local ping = false
    if ctx.showPlayer and type(ctx.player) == "string" and ctx.player ~= "" then
        spec.authorName = ctx.player
        if type(ctx.userId) == "number" then
            spec.authorIcon = string.format(
                "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png",
                ctx.userId
            )
        end
    end

    if kind == "matchEnd" then
        local victory = info.result == "Victory"
        local mode = modeText(info)
        spec.title = (if victory then "🏆 Victory" else "💀 Defeat")
            .. (
                if type(info.stageName) == "string" and info.stageName ~= ""
                    then " — " .. info.stageName
                    else ""
            )
        spec.color = if victory then GREEN else RED
        spec.description = if mode ~= "" then "`" .. mode .. "`" else nil
        addField(fields, "⏱️ Time", if info.duration then Embed.duration(info.duration) else nil)
        addField(
            fields,
            "🌊 Waves",
            if info.waves
                then string.format("%s/%s", tostring(info.waves), tostring(info.maxWaves or info.waves))
                else nil
        )
        addField(fields, "💥 Damage", if info.damage then Embed.number(info.damage) else nil)
        addField(fields, "💀 Takedowns", if info.takedowns then Embed.number(info.takedowns) else nil)
        addField(fields, "🪙 Money", if info.money then Embed.number(info.money) else nil)
        addField(fields, "🧩 Units placed", info.units)
        local lines = rewardLines(info.rewards)
        addField(fields, "🎁 Rewards", lines, false)
    elseif kind == "unit" then
        local style = config.rarityStyle[info.rarity] or { emoji = "🆕", color = TEAL }
        spec.title = string.format("%s New %s unit obtained!", style.emoji, tostring(info.rarity or "unit"))
        spec.description = "**" .. tostring(info.name or "Unknown unit") .. "**"
        spec.color = style.color
        addField(fields, "Rarity", string.format("%s %s", style.emoji, tostring(info.rarity or "?")))
        addField(fields, "Level", info.level)
        addField(fields, "Trait", info.trait)
        if info.subTrait and info.subTrait ~= "None" then
            addField(fields, "Sub-trait", info.subTrait)
        end
        local rank = Events.rarityRank(info.rarity, config.rarityOrder)
        ping = rank > 0 and rank >= Events.rarityRank(config.pingMinRarity, config.rarityOrder)
    elseif kind == "join" then
        spec.title = "🚪 " .. tostring(info.name or "Joiner") .. " — entered"
        spec.description = modeText(info)
        spec.color = TEAL
        addField(fields, "Mode", info.name)
        addField(fields, "Status", info.message, false)
    elseif kind == "joinProblem" then
        spec.title = "⚠️ Joiner problem"
        spec.description = tostring(info.message or "A joiner request did not complete.")
        spec.color = ORANGE
        ping = true
    elseif kind == "bounty" then
        spec.title = string.format("🎯 Boss Bounties: %s left today", tostring(info.left or "?"))
        spec.color = PURPLE
        local target = modeText({ stageType = info.mode, stage = info.stage, act = info.act })
        spec.description = if target ~= ""
            then "Current target `" .. target .. "`" .. (if info.boss
                then " — **" .. tostring(info.boss) .. "**"
                else "")
            else nil
        addField(fields, "Remaining", info.left)
        addField(fields, "Message", info.message, false)
    elseif kind == "rift" then
        spec.title = "🌀 Rift is open"
        spec.description = tostring(info.message or "The hourly Rift event just opened.")
        spec.color = PURPLE
    elseif kind == "equipper" then
        spec.title = "🧩 Equipper notice"
        spec.description = tostring(info.message or "")
        spec.color = ORANGE
    elseif kind == "autoPlay" then
        spec.title = "🤖 Auto Play"
        spec.description = tostring(info.message or "")
        spec.color = BLUE
    elseif kind == "warning" then
        spec.title = "🚨 Warning"
        spec.description = tostring(info.message or "")
        spec.color = RED
        ping = true
    elseif kind == "session" then
        spec.title = "🟢 ViperHub session started"
        spec.description = string.format("Running in the **%s**.", tostring(info.place or "game"))
        spec.color = GREEN
        addField(fields, "Version", ctx.version)
        addField(fields, "Place", info.placeName)
    elseif kind == "test" then
        spec.title = "✅ Webhook connected"
        spec.description =
            "ViperHub can post to this channel. Event notifications you enabled will appear here."
        spec.color = GREEN
        addField(fields, "Enabled events", info.enabledCount)
        addField(fields, "Version", ctx.version)
    else
        return nil, false
    end
    if #fields > 0 then
        spec.fields = fields
    end
    return spec, ping
end

return Events
