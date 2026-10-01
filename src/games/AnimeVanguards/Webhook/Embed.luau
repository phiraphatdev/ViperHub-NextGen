--!strict
--[[
Purpose: Pure Discord webhook helpers: URL validation and masking, embed building within Discord's limits, payload shaping
Input: Webhook URLs, embed specs (title, description, fields, ...) and delivery options
Output: Validated URLs, masked display text, size-bounded embeds and mention-safe payload tables
Dependencies: None
]]

local Embed = {}

local MAX_TITLE = 256
local MAX_DESCRIPTION = 4000
local MAX_FIELDS = 25
local MAX_FIELD_NAME = 256
local MAX_FIELD_VALUE = 1024
local MAX_FOOTER = 2048
local MAX_AUTHOR = 256
local MAX_TOTAL = 5800
local MAX_CONTENT = 2000
local MAX_USERNAME = 80
local MAX_EMBEDS = 10

export type Field = { name: string, value: string, inline: boolean? }
export type Spec = {
    title: string?,
    description: string?,
    color: number?,
    url: string?,
    fields: { Field }?,
    footer: string?,
    timestamp: string?,
    authorName: string?,
    authorIcon: string?,
    thumbnail: string?,
    image: string?,
}

--- Truncates text to at most max characters, ending with an ellipsis when cut.
function Embed.clip(text: any, max: number): string
    local value = if type(text) == "string" then text else tostring(text)
    if #value <= max then
        return value
    end
    return string.sub(value, 1, math.max(0, max - 3)) .. "..."
end

--- Returns true for an https Discord webhook URL on one of the allowed hosts (id and token shape checked).
function Embed.validUrl(url: any, hosts: { string }): boolean
    if type(url) ~= "string" or #url > 300 then
        return false
    end
    local host, id, token = string.match(url, "^https://([%w%.%-]+)/api/webhooks/(%d+)/([%w_%-]+)/?$")
    if not host or not id or not token or #id < 15 or #id > 25 or #token < 20 then
        return false
    end
    return table.find(hosts, string.lower(host)) ~= nil
end

--- Returns display text that never reveals the webhook token (host and the start of the id only).
function Embed.mask(url: any, hosts: { string }): string
    if not Embed.validUrl(url, hosts) then
        return "(not set)"
    end
    local host, id = string.match(url :: string, "^https://([%w%.%-]+)/api/webhooks/(%d+)/")
    return string.format(
        "https://%s/api/webhooks/%s…/••••••••",
        host or "discord.com",
        string.sub(id or "", 1, 4)
    )
end

local function isHttps(url: any): boolean
    return type(url) == "string"
        and #url <= 512
        and string.match(url, "^https://[%w%.%-]+/[%w%./%-_%%%?&=:,~+@!*'()]*$") ~= nil
end

--- Compact number text: 1.2K, 3.4M, 1,234 for small values.
function Embed.number(value: any): string
    local n = tonumber(value)
    if n == nil or n ~= n then
        return "0"
    end
    local abs = math.abs(n)
    if abs >= 1e9 then
        return string.format("%.2fB", n / 1e9)
    elseif abs >= 1e6 then
        return string.format("%.2fM", n / 1e6)
    elseif abs >= 1e4 then
        return string.format("%.1fK", n / 1e3)
    end
    local whole = math.floor(n + 0.5)
    local text = tostring(whole)
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

--- Whole number with thousands separators: 18,486,565.
function Embed.commas(value: any): string
    local n = tonumber(value)
    if n == nil or n ~= n or math.abs(n) == math.huge then
        return "0"
    end
    local text = tostring(math.floor(math.abs(n) + 0.5))
    local out = text
    while true do
        local replaced, count = string.gsub(out, "^(%d+)(%d%d%d)", "%1,%2")
        out = replaced
        if count == 0 then
            break
        end
    end
    return (if n < 0 then "-" else "") .. out
end

--- Formats seconds as 1h 02m 03s / 4m 05s / 6s.
function Embed.duration(seconds: any): string
    local total = math.max(0, math.floor(tonumber(seconds) or 0))
    local h = total // 3600
    local m = (total % 3600) // 60
    local s = total % 60
    if h > 0 then
        return string.format("%dh %02dm %02ds", h, m, s)
    elseif m > 0 then
        return string.format("%dm %02ds", m, s)
    end
    return string.format("%ds", s)
end

--- Builds one embed table from a spec, trimming every part to Discord's limits (total below 6000 characters).
function Embed.build(spec: Spec): { [string]: any }
    local embed: { [string]: any } = {}
    local budget = MAX_TOTAL
    local function take(text: string): string
        local clipped = Embed.clip(text, math.max(0, budget))
        budget -= #clipped
        return clipped
    end
    if spec.title and spec.title ~= "" then
        embed.title = take(Embed.clip(spec.title, MAX_TITLE))
    end
    if spec.description and spec.description ~= "" then
        embed.description = take(Embed.clip(spec.description, MAX_DESCRIPTION))
    end
    if type(spec.color) == "number" then
        embed.color = math.clamp(math.floor(spec.color), 0, 0xFFFFFF)
    end
    if spec.url and isHttps(spec.url) then
        embed.url = spec.url
    end
    if spec.authorName and spec.authorName ~= "" then
        local author: { [string]: any } = { name = take(Embed.clip(spec.authorName, MAX_AUTHOR)) }
        if spec.authorIcon and isHttps(spec.authorIcon) then
            author.icon_url = spec.authorIcon
        end
        embed.author = author
    end
    if spec.thumbnail and isHttps(spec.thumbnail) then
        embed.thumbnail = { url = spec.thumbnail }
    end
    if spec.image and isHttps(spec.image) then
        embed.image = { url = spec.image }
    end
    if spec.fields then
        local fields: { any } = {}
        for _, field in spec.fields do
            if #fields >= MAX_FIELDS or budget <= 0 then
                break
            end
            local name = Embed.clip(field.name, MAX_FIELD_NAME)
            local value = Embed.clip(field.value, MAX_FIELD_VALUE)
            if name ~= "" and value ~= "" then
                table.insert(fields, {
                    name = take(name),
                    value = take(value),
                    inline = field.inline == true,
                })
            end
        end
        if #fields > 0 then
            embed.fields = fields
        end
    end
    if spec.footer and spec.footer ~= "" then
        embed.footer = { text = take(Embed.clip(spec.footer, MAX_FOOTER)) }
    end
    if spec.timestamp and string.match(spec.timestamp, "^%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%dZ$") then
        embed.timestamp = spec.timestamp
    end
    return embed
end

--- Returns a bot name Discord accepts (1 to 80 characters, without the words Discord or Clyde).
function Embed.username(name: any, fallback: string): string
    local value = if type(name) == "string" then string.gsub(name, "[%c]", "") else ""
    value = string.match(value, "^%s*(.-)%s*$") or ""
    local lower = string.lower(value)
    if value == "" or string.find(lower, "discord", 1, true) or string.find(lower, "clyde", 1, true) then
        return fallback
    end
    return Embed.clip(value, MAX_USERNAME)
end

--- Shapes the request body: embeds are capped, mentions are disabled except one optionally allowed user id.
function Embed.payload(
    embeds: { any },
    options: { username: string?, avatarUrl: string?, pingUserId: string?, ping: boolean? }
): { [string]: any }
    local capped: { any } = {}
    for index, embed in embeds do
        if index > MAX_EMBEDS then
            break
        end
        table.insert(capped, embed)
    end
    local payload: { [string]: any } = { embeds = capped, allowed_mentions = { parse = {} } }
    if options.username and options.username ~= "" then
        payload.username = Embed.username(options.username, "ViperHub")
    end
    if options.avatarUrl and isHttps(options.avatarUrl) then
        payload.avatar_url = options.avatarUrl
    end
    local ping = options.pingUserId
    if
        options.ping
        and type(ping) == "string"
        and string.match(ping, "^%d+$")
        and #ping >= 15
        and #ping <= 25
    then
        payload.content = Embed.clip("<@" .. ping .. ">", MAX_CONTENT)
        payload.allowed_mentions = { parse = {}, users = { ping } }
    end
    return payload
end

return Embed
