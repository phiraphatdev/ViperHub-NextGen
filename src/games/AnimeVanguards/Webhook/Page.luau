--!strict
--[[
Purpose: Render the Discord webhook tab: connection, appearance, unit drop threshold and per-event switches
Input: WindUI tab handle and the Webhook runtime
Output: Mounted WindUI controls; the webhook URL is never shown or kept in a control after it is entered
Dependencies: Style; Events; Config
]]

local Style = require("../Style")
local Events = require("./Events")
local config = require("../Config")
local Page = {}

local WEBHOOK: any = (config :: any).webhook

local ERRORS: { [string]: string } = {
    INVALID_URL = "That is not a Discord webhook URL (https://discord.com/api/webhooks/<id>/<token>).",
    NO_URL = "Paste a webhook URL first.",
    NOT_SENT = "The message could not be queued; check the status above.",
}

--- Mounts the Webhook controls on the given WindUI tab.
function Page.mount(tab: any, runtime: any)
    local status = tab:Paragraph({
        Title = "Discord Webhook",
        Desc = if runtime then runtime.getStatus() else "Unavailable",
    })
    if not runtime then
        return
    end
    local function show(text: string)
        pcall(status.SetDesc, status, text)
    end
    runtime.onStatus = show

    local settings = runtime.getSettings()
    local connection = Style.section(tab, "Connection", "link", true)
    local urlInput: any
    urlInput = connection:Input({
        Title = "Webhook URL",
        Desc = "Channel settings → Integrations → Webhooks. The URL is stored on this device only and is never shown again after you enter it.",
        Value = "",
        Placeholder = if settings.hasUrl then settings.urlMasked else "https://discord.com/api/webhooks/…",
        Callback = function(text: string)
            if type(text) ~= "string" or text == "" then
                return
            end
            local ok, err = runtime.setUrl(text)
            if not ok then
                show(ERRORS[err or ""] or "Webhook URL rejected.")
            end
            -- Clear the box so the secret does not stay on screen, and show the masked form as the placeholder.
            if type(urlInput.Set) == "function" then
                pcall(urlInput.Set :: any, urlInput, "", false)
            end
            if ok and type(urlInput.SetPlaceholder) == "function" then
                pcall(urlInput.SetPlaceholder :: any, urlInput, runtime.getSettings().urlMasked)
            end
        end,
    })
    connection:Toggle({
        Title = "Send notifications",
        Desc = "Master switch. Nothing is sent while this is off.",
        Value = settings.enabled,
        Callback = function(value: boolean)
            runtime.setEnabled(value)
        end,
    })
    connection:Button({
        Title = "Send test message",
        Desc = "Posts a connection check so you can see the look of the embeds.",
        Callback = function()
            local ok, err = runtime.sendTest()
            show(if ok then "Test message queued" else (ERRORS[err or ""] or "Test message failed"))
        end,
    })
    connection:Button({
        Title = "Forget webhook URL",
        Desc = "Removes the saved URL from this device.",
        Callback = function()
            runtime.clearUrl()
            if type(urlInput.SetPlaceholder) == "function" then
                pcall(urlInput.SetPlaceholder :: any, urlInput, "https://discord.com/api/webhooks/…")
            end
        end,
    })

    local appearance = Style.section(tab, "Appearance", "palette", false)
    appearance:Input({
        Title = "Bot name",
        Desc = "Shown as the sender in Discord. Empty uses ViperHub.",
        Value = settings.username,
        Placeholder = WEBHOOK.defaultUsername,
        Callback = function(text: string)
            runtime.setUsername(text)
        end,
    })
    appearance:Input({
        Title = "Bot avatar URL",
        Desc = "Optional https image link. Empty uses the webhook's own avatar.",
        Value = settings.avatarUrl,
        Placeholder = "https://…",
        Callback = function(text: string)
            if not runtime.setAvatar(text) then
                show("Avatar must be an https link.")
            end
        end,
    })
    appearance:Toggle({
        Title = "Show my Roblox name and avatar",
        Desc = "Adds your name and headshot to the top of every embed. Turn off to keep the account private in shared channels.",
        Value = settings.showPlayer,
        Callback = function(value: boolean)
            runtime.setShowPlayer(value)
        end,
    })
    appearance:Input({
        Title = "Ping my Discord user ID",
        Desc = "Optional numeric ID (Discord → Developer Mode → Copy User ID). Used only for rare unit drops, joiner problems and warnings.",
        Value = settings.pingUserId,
        Placeholder = "e.g. 123456789012345678",
        Callback = function(text: string)
            if not runtime.setPingUser(text) then
                show("Discord user ID must be 15 to 25 digits.")
            end
        end,
    })

    local drops = Style.section(tab, "Unit drops", "gem", false)
    drops:Toggle({
        Title = "Ping @everyone on rare drops",
        Desc = "Adds @everyone to Secret and higher unit drops. The webhook must be allowed to mention everyone in that channel.",
        Value = settings.pingEveryone,
        Callback = function(value: boolean)
            runtime.setPingEveryone(value)
        end,
    })
    drops:Dropdown({
        Title = "Minimum rarity to announce",
        Desc = "New units below this rarity are ignored. Secret and above can ping you.",
        Values = WEBHOOK.rarityOrder,
        Value = settings.minRarity,
        Callback = function(value: string)
            runtime.setMinRarity(value)
        end,
    })

    local events = Style.section(tab, "Events", "list-checks", false)
    for _, kind in Events.kinds do
        events:Toggle({
            Title = kind.label,
            Desc = kind.desc,
            Value = settings.events[kind.id] == true,
            Callback = function(value: boolean)
                runtime.setEvent(kind.id, value)
            end,
        })
    end
end

return Page
