--!strict
--[[
Purpose: Expose game-owned navigation and lifecycle for verified stage joining
Input: Game context
Output: GameModule contract
Dependencies: Metadata; Config; types/GameModule; Webhook
]]

local Types = require("../../types/GameModule")
local metadata = require("./Metadata")
local config = require("./Config")
local JoinerPage = require("./Joiner/Page")
local JoinerRuntime = require("./Joiner/Runtime")
local MacroPage = require("./Macro/Page")
local MacroRuntime = require("./Macro/Runtime")
local GamePage = require("./Game/Page")
local GameAdapter = require("./Game/Adapter")
local AutoPlayPage = require("./AutoPlay/Page")
local AutoPlayRuntime = require("./AutoPlay/Runtime")
local StatusPage = require("./Status/Page")
local DashboardPage = require("./Dashboard/Page")
local WebhookPage = require("./Webhook/Page")
local WebhookRuntime = require("./Webhook/Runtime")
local MiscPage = require("./Misc/Page")
local MiscRuntime = require("./Misc/Runtime")
local active = false
local joiner = JoinerRuntime.new()
local macro = MacroRuntime.new()
local gameSettings = GameAdapter.new()
local autoPlay = AutoPlayRuntime.new()
local webhook = WebhookRuntime.new()
local misc = MiscRuntime.new()
local pages: { Types.PageDefinition } = {
    {
        title = "Dashboard",
        icon = "layout-dashboard",
        description = "Your player card, live status of every feature and your balances.",
        group = "Home",
        iconColor = "primary",
        home = true,
        render = function(tab: any)
            DashboardPage.mount(
                tab,
                { joiner = joiner, autoPlay = autoPlay, macro = macro, webhook = webhook, misc = misc }
            )
        end,
    },
    {
        title = "Joiner",
        icon = "users",
        description = "Auto join stages, challenges, Rift, bounties and Worldline by priority.",
        group = "Farming",
        iconColor = "primary",
        render = function(tab: any)
            JoinerPage.mount(tab, nil, joiner)
        end,
    },
    {
        title = "Auto Play",
        icon = "play",
        description = "Native in-game Auto Play, vote start and stage preset rules.",
        group = "Farming",
        iconColor = "blue",
        render = function(tab: any)
            AutoPlayPage.mount(tab, autoPlay, macro)
        end,
    },
    {
        title = "Macro",
        icon = "list",
        description = "Record and replay match actions.",
        group = "Farming",
        iconColor = "violet",
        render = function(tab: any, window: any?)
            MacroPage.mount(tab, macro, window, autoPlay)
        end,
    },
    {
        title = "Game",
        icon = "gamepad-2",
        description = "Auto Replay, Auto Next, wave skip and Auto Back to Lobby.",
        group = "Farming",
        iconColor = "orange",
        render = function(tab: any)
            GamePage.mount(tab, gameSettings)
        end,
    },
    {
        title = "Webhook",
        icon = "bell",
        description = "Discord notifications for matches, units, joiner and bounty events.",
        group = "Tools",
        iconColor = "gold",
        render = function(tab: any)
            WebhookPage.mount(tab, webhook)
        end,
    },
    {
        title = "Misc",
        icon = "shield-check",
        description = "Anti-AFK, Auto Reconnect and re-running the hub after a teleport.",
        group = "Tools",
        iconColor = "rose",
        render = function(tab: any)
            MiscPage.mount(tab, misc)
        end,
    },
    {
        title = "Status",
        icon = "activity",
        description = "Live checks of the game modules the hub depends on.",
        group = "System",
        iconColor = "slate",
        render = function(tab: any)
            StatusPage.mount(tab)
        end,
    },
}
local GameModule = { metadata = metadata, config = config, pages = pages, windowTags = config.windowTags }
--- Starts the Joiner runtime with context; returns nothing until a joiner is enabled.
function GameModule.start(context: Types.Context)
    if active or not context.alive then
        return
    end
    active = true
    joiner.setMacro(macro)
    joiner.setReturnGate(webhook.isBusy)
    gameSettings.setReturnGate(webhook.isBusy)
    joiner.setGameSettings(gameSettings)
    autoPlay.setMacro(macro)
    macro.setAutoPlay(autoPlay)

    local env: any = getfenv()
    local gameObject = env.game
    local taskApi = env.task

    local function initModule()
        if not context.alive or not active then
            return
        end
        if gameObject and type(gameObject.IsLoaded) == "function" and not (gameObject :: any):IsLoaded() then
            pcall(function()
                (gameObject :: any).Loaded:Wait()
            end)
        end
        if type(taskApi) == "table" and type(taskApi.wait) == "function" then
            (taskApi :: any).wait(config.thresholds.startDelaySeconds)
        end
        if gameObject and gameObject.PlaceId ~= metadata.placeIds[1] then
            pcall(function()
                local rep = gameObject:GetService("ReplicatedStorage")
                local ghMod = rep:FindFirstChild("Modules")
                    and rep.Modules:FindFirstChild("Gameplay")
                    and rep.Modules.Gameplay:FindFirstChild("GameHandler")
                if ghMod then
                    local gh = (require :: any)(ghMod)
                    if
                        gh
                        and not gh.IsGameLoaded
                        and gh.GameLoaded
                        and type(gh.GameLoaded.Wait) == "function"
                    then
                        (gh.GameLoaded :: any):Wait()
                    end
                end
            end)
            if type(taskApi) == "table" and type(taskApi.wait) == "function" then
                (taskApi :: any).wait(1.0)
            end
        end
        if not context.alive or not active then
            return
        end
        joiner.start(context)
        macro.start(context)
        gameSettings.start(context)
        autoPlay.start(context)
        webhook.start(context, { joiner = joiner, autoPlay = autoPlay, macro = macro })
        misc.start(context)
        context.log("GAME_STARTED")
    end

    if type(taskApi) == "table" and type(taskApi.spawn) == "function" then
        (taskApi :: any).spawn(initModule)
    else
        initModule()
    end
end
--- Stops all owned Joiner callbacks and tasks; safe to repeat.
function GameModule.stop()
    joiner.stop()
    macro.stop()
    gameSettings.stop()
    autoPlay.stop()
    webhook.stop()
    misc.stop()
    active = false
end
return GameModule
