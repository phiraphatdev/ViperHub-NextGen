--!strict
--[[
Purpose: Render Joiner controls and verified stage join actions
Input: WindUI tab handle; optional test stage/challenge data and game-owned runtime
Output: UI controls and validated selection callbacks
Dependencies: Catalog; Definitions; Settings; replicated StagesData
]]

local Catalog = require("./Catalog")
local definitions = require("./Definitions")
local Settings = require("./Settings")
local config = require("../Config")
local Page = {}
local function orderText(): string
    return table.concat(Settings.get().priority, " > ")
end

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
        local obj = resolve(root, path)
        return if obj then (require :: any)(obj) else nil
    end)
    return if ok then result else nil
end

local function readStageData(): any
    local env: any = getfenv()
    local ok, result = pcall(function()
        local rep = env.game and env.game:GetService("ReplicatedStorage")
        return optionalModule(rep, "Modules.Data.StagesData")
    end)
    return if ok then result else nil
end

local function readChallengeChoices(): any
    local env: any = getfenv()
    local ok, result = pcall(function()
        local gameObject = env.game
        local rep = gameObject and gameObject:GetService("ReplicatedStorage")
        local definitions = optionalModule(rep, "Modules.Data.Challenges.ChallengesData")
        local rows = {}
        for _, kind in { "Regular", "Daily", "Weekly" } do
            rows[kind] = {}
            if definitions and type(definitions.GetChallengesOfType) == "function" then
                local okList, list = pcall(definitions.GetChallengesOfType, kind)
                if okList and type(list) == "table" then
                    for _, challenge in list do
                        if type(challenge) == "table" and type(challenge.Name) == "string" then
                            table.insert(rows[kind], challenge.Name)
                        end
                    end
                end
            end
            table.sort(rows[kind])
        end
        return rows
    end)
    return if ok and type(result) == "table" then result else { Regular = {}, Daily = {}, Weekly = {} }
end

local function readSpecialChoices(): any
    local env: any = getfenv()
    local ok, result = pcall(function()
        local replicated = env.game and env.game:GetService("ReplicatedStorage")
        local worldlines = optionalModule(replicated, config.instancePaths.worldlinesData)
        local rotation = optionalModule(replicated, config.instancePaths.bossRotation)
        local shops = optionalModule(replicated, config.instancePaths.bossEventNames)
        local currentBoss = nil
        if rotation and type(rotation.GetCurrentBossEvent) == "function" then
            pcall(function()
                currentBoss = (rotation.GetCurrentBossEvent :: any)()
            end)
        end
        local rows = { worldlines = {}, bosses = {}, currentBoss = currentBoss }
        if worldlines and type(worldlines.GetAll) == "function" then
            pcall(function()
                for id, value in (worldlines.GetAll :: any)() do
                    if
                        type(id) == "string"
                        and type(value) == "table"
                        and type(value.DisplayName) == "string"
                    then
                        table.insert(rows.worldlines, { id = id, name = value.DisplayName })
                    end
                end
            end)
        end
        table.sort(rows.worldlines, function(a: any, b: any)
            return (a.name :: string) < (b.name :: string)
        end)
        if shops and type(shops.GetAllEventNames) == "function" then
            pcall(function()
                for _, name in (shops.GetAllEventNames :: any)() do
                    if type(name) == "string" then
                        table.insert(rows.bosses, name)
                    end
                end
            end)
        end
        table.sort(rows.bosses)
        return rows
    end)
    return if ok and type(result) == "table"
        then result
        else { worldlines = {}, bosses = {}, currentBoss = nil }
end

local function addSpecial(tab: any, name: string, rows: any, runtime: any?)
    local section = tab:Section({ Title = name .. " Joiner", Opened = false })
    local worldline = name == "Worldline"
    local entries = if type(rows) == "table"
        then (if worldline then rows.worldlines else rows.bosses)
        else nil
    local values = {}
    local ids = {}
    if type(entries) == "table" then
        for _, entry in entries do
            local id = if worldline then entry.id else entry
            local label = if worldline then entry.name .. " (" .. entry.id .. ")" else entry
            if type(id) == "string" and type(label) == "string" then
                table.insert(values, label)
                table.insert(ids, id)
            end
        end
    end
    local saved = Settings.get()
    local previous = saved.selection[name]
    local preferred = if worldline
        then (previous and previous.worldlineId)
        else (previous and previous.eventName)
    local index = if type(preferred) == "string" then table.find(ids, preferred) else nil
    if not worldline and type(rows) == "table" and rows.currentBoss then
        index = table.find(ids, rows.currentBoss)
    end
    index = index or 1
    local selected = ids[index]
    local option = if worldline then "Traits" else (previous and previous.difficulty) or "Normal"
    local function update()
        if not runtime or not selected then
            return
        end
        if worldline then
            runtime.setWorldline(selected, option)
        else
            runtime.setBossEvent(selected, option)
        end
    end
    update()
    section:Toggle({
        Title = "Auto Join " .. name,
        Value = saved.enabled[name] == true and #values > 0,
        Locked = runtime == nil or #values == 0,
        Desc = if worldline
            then "Teleports to the selected Worldline."
            else "Starts only the currently rotating boss event.",
        Callback = function(value: boolean)
            if runtime then
                runtime.setEnabled(name, value)
            end
        end,
    })
    if runtime and saved.enabled[name] == true then
        runtime.setEnabled(name, true)
    end
    if #values == 0 then
        section:Paragraph({ Title = "Availability", Desc = "Current game data is unavailable." })
        return
    end
    if not worldline then
        section:Paragraph({ Title = "Current weekly boss", Desc = tostring(rows.currentBoss) })
    end
    section:Dropdown({
        Title = if worldline then "Select Worldline" else "Select Boss Event",
        Values = values,
        Value = values[index],
        Callback = function(value: string)
            local found = table.find(values, value)
            if found then
                selected = ids[found]
                update()
            end
        end,
    })
    if not worldline then
        section:Dropdown({
            Title = "Difficulty",
            Values = { "Normal", "Elite" },
            Value = option,
            Callback = function(value: string)
                option = value
                update()
            end,
        })
    end
end

local function addStageSelector(tab: any, data: any, mode: string, title: string, runtime: any?)
    local stages = Catalog.list(data, mode)
    local saved = Settings.get()
    local previous = saved.selection[title]
    local selected = stages[1]
    if selected and type(previous) == "table" then
        for _, candidate in stages do
            if candidate.id == previous.stage then
                selected = candidate
                break
            end
        end
    end
    tab:Toggle({
        Title = "Auto Join " .. title,
        Value = saved.enabled[title] == true and #stages > 0,
        Locked = runtime == nil or #stages == 0,
        Desc = "Creates a private lobby, then starts it after server confirmation and host readback.",
        Callback = function(value: boolean)
            if runtime then
                runtime.setEnabled(title, value)
            end
        end,
    })
    if #stages == 0 then
        tab:Paragraph({ Title = title, Desc = "Unavailable: stage data not replicated in this place." })
        return
    end
    if runtime and saved.enabled[title] == true then
        runtime.setEnabled(title, true)
    end
    local labels = {}
    for _, stage in stages do
        table.insert(labels, stage.id .. " - " .. stage.name)
    end
    local selectedAct = selected.acts[1].id
    if type(previous) == "table" then
        for _, act in selected.acts do
            if act.id == previous.act then
                selectedAct = act.id
                break
            end
        end
    end
    local difficulty = if mode == "LegendStage"
        then "Nightmare"
        else if mode == "Story"
                and type(previous) == "table"
                and previous.difficulty == "Nightmare"
            then "Nightmare"
            else "Normal"
    local function updateSelection()
        if runtime then
            runtime.setSelection(title, selected.id, selectedAct, difficulty)
        end
    end
    updateSelection()
    local actLabels = {}
    local function refreshActs(stage: any)
        actLabels = {}
        for _, act in stage.acts do
            table.insert(actLabels, act.id .. " - " .. act.name)
        end
    end
    refreshActs(selected)
    local selectedActLabel = actLabels[1]
    for index, act in selected.acts do
        if act.id == selectedAct then
            selectedActLabel = actLabels[index]
            break
        end
    end
    tab:Paragraph({
        Title = title,
        Desc = "Only an unlocked Stage/Act can be requested. Server ACK is required.",
    })
    local actDropdown: any
    tab:Dropdown({
        Title = "Select " .. title,
        Values = labels,
        Value = labels[table.find(stages, selected) or 1],
        Callback = function(value: string)
            local index = table.find(labels, value)
            if index then
                selected = stages[index]
                refreshActs(selected)
                selectedAct = selected.acts[1].id
                updateSelection()
                if actDropdown and actDropdown.Refresh and actDropdown.Select then
                    local refresh = actDropdown.Refresh :: any
                    local selectValue = actDropdown.Select :: any
                    refresh(actDropdown, actLabels)
                    selectValue(actDropdown, actLabels[1])
                end
            end
        end,
    })
    actDropdown = tab:Dropdown({
        Title = "Select " .. title .. " Act",
        Values = actLabels,
        Value = selectedActLabel,
        Callback = function(value: string)
            local index = table.find(actLabels, value)
            if index then
                selectedAct = selected.acts[index].id
                updateSelection()
            end
        end,
    })
    if mode == "Story" then
        tab:Dropdown({
            Title = "Difficulty",
            Values = { "Normal", "Nightmare" },
            Value = difficulty,
            Callback = function(value: string)
                if value == "Normal" or value == "Nightmare" then
                    difficulty = value
                    updateSelection()
                end
            end,
        })
    elseif mode == "LegendStage" then
        tab:Paragraph({
            Title = "Difficulty",
            Desc = "Legend Stage is Nightmare-only; no difficulty selector.",
        })
    end
end

local function formatHMS(seconds: number): string
    if seconds <= 0 then
        return "00:00"
    end
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    if d > 0 then
        return string.format("%dd %02dh %02dm", d, h, m)
    elseif h > 0 then
        return string.format("%02d:%02d:%02d", h, m, s)
    else
        return string.format("%02d:%02d", m, s)
    end
end

local function addRift(tab: any, runtime: any?): any
    local section = tab:Section({ Title = "Rift Joiner", Opened = false })
    local saved = Settings.get()
    local previous = saved.selection["Rift"] or {}
    local backToLobby = previous.backToLobby == true
    local returnMode = previous.returnMode or "Immediate"

    section:Toggle({
        Title = "Auto Join Rift",
        Value = saved.enabled["Rift"] == true,
        Locked = runtime == nil,
        Desc = "Automatically joins open Rift events via remote execution without walking.",
        Callback = function(value: boolean)
            if runtime then
                runtime.setEnabled("Rift", value)
            end
        end,
    })

    local timerPara = section:Paragraph({
        Title = "Rift Event Status",
        Desc = "Checking schedule...",
    })

    section:Toggle({
        Title = "Back to Lobby when Rift Opens",
        Value = backToLobby,
        Desc = "Returns from active match to lobby when Rift event opens.",
        Callback = function(value: boolean)
            backToLobby = value
            Settings.setBackToLobby("Rift", backToLobby, returnMode)
        end,
    })

    section:Dropdown({
        Title = "Return Mode",
        Values = { "Immediate", "Wait Match End" },
        Value = returnMode,
        Callback = function(value: string)
            returnMode = value
            Settings.setBackToLobby("Rift", backToLobby, returnMode)
        end,
    })

    return timerPara
end

local function addUnavailable(tab: any, name: string, description: string)
    local section = tab:Section({ Title = name .. " Joiner", Opened = false })
    section:Toggle({
        Title = "Auto Join " .. name,
        Value = false,
        Locked = true,
        Desc = "Unavailable until joining is verified.",
    })
    section:Paragraph({ Title = "Options", Desc = description })
end

local function addBounty(tab: any, runtime: any?): () -> ()
    local section = tab:Section({ Title = "Boss Bounties Joiner", Opened = false })
    local saved = Settings.get()
    section:Toggle({
        Title = "Auto Join Boss Bounties",
        Value = saved.enabled["Boss Bounties"] == true,
        Locked = runtime == nil or type(runtime.readBounty) ~= "function",
        Desc = "Creates a private lobby for the current bounty stage while bounties remain.",
        Callback = function(value: boolean)
            if runtime then
                runtime.setEnabled("Boss Bounties", value)
            end
        end,
    })
    if runtime and saved.enabled["Boss Bounties"] == true then
        runtime.setEnabled("Boss Bounties", true)
    end
    local info = section:Paragraph({
        Title = "Current bounty",
        Desc = "Waiting for bounty data...",
    })
    -- Bounty data replicates after the page mounts, so the text is refreshed by the page loop.
    return function()
        local bounty: any = if runtime and type(runtime.readBounty) == "function"
            then (runtime.readBounty :: any)()
            else nil
        local text = if bounty
            then string.format(
                "%s %s %s%s - %d left today",
                bounty.mode,
                bounty.stage,
                bounty.act,
                if bounty.boss then " (" .. bounty.boss .. ")" else "",
                bounty.left
            )
            else "Unavailable: bounty data is not replicated in this place."
        pcall(info.SetDesc, info, text)
    end
end

local function addChallenge(tab: any, kind: string, choices: any, runtime: any?): any
    local name = kind .. " Challenge"
    local section = tab:Section({ Title = name .. " Joiner", Opened = false })
    local values = if type(choices) == "table" and type(choices[kind]) == "table" then choices[kind] else {}
    local saved = Settings.get()
    local previous = saved.selection[name] or {}
    local backToLobby = previous.backToLobby == true
    local returnMode = previous.returnMode or "Immediate"

    section:Toggle({
        Title = "Auto Join " .. name,
        Value = saved.enabled[name] == true and #values > 0,
        Locked = runtime == nil or #values == 0,
        Desc = "Starts challenge and continues automatically after server confirmation.",
        Callback = function(value: boolean)
            if runtime then
                runtime.setEnabled(name, value)
            end
        end,
    })

    local timerPara = section:Paragraph({
        Title = "Challenge Reset Timer",
        Desc = "Checking reset timer...",
    })

    if #values == 0 then
        section:Paragraph({ Title = "Availability", Desc = "Current challenge data is unavailable." })
        return timerPara
    end

    local selected = if type(previous) == "table" and table.find(values, previous.challengeName)
        then previous.challengeName
        else values[1]
    if runtime then
        runtime.setChallenge(name, selected)
    end
    section:Dropdown({
        Title = "Select " .. name,
        Values = values,
        Value = selected,
        Callback = function(value: string)
            if runtime and table.find(values, value) then
                runtime.setChallenge(name, value)
            end
        end,
    })

    if kind == "Regular" then
        local rewardChoices = {
            "Trait Rerolls",
            "Stat Chips",
            "Memoria Shards",
            "Green Essence Stone",
            "Legendary Essence Stone",
            "Mythic Essence Stone",
        }
        local currentReward = if previous.rewardChoice
                and table.find(rewardChoices, previous.rewardChoice)
            then previous.rewardChoice
            else "Trait Rerolls"
        Settings.setRegularReward(currentReward)

        section:Dropdown({
            Title = "Reward Focus",
            Values = rewardChoices,
            Value = currentReward,
            Callback = function(value: string)
                Settings.setRegularReward(value)
            end,
        })
    end

    section:Toggle({
        Title = "Back to Lobby when Challenge Resets",
        Value = backToLobby,
        Desc = "Returns from active match to lobby when this challenge resets.",
        Callback = function(value: boolean)
            backToLobby = value
            Settings.setBackToLobby(name, backToLobby, returnMode)
        end,
    })

    section:Dropdown({
        Title = "Return Mode",
        Values = { "Immediate", "Wait Match End" },
        Value = returnMode,
        Callback = function(value: string)
            returnMode = value
            Settings.setBackToLobby(name, backToLobby, returnMode)
        end,
    })

    return timerPara
end

--- Mounts Joiner settings and supported stage actions; returns nothing.
function Page.mount(tab: any, stageDataOverride: any?, runtime: any?, challengeChoicesOverride: any?)
    Settings.init(getfenv())
    local state = Settings.get()
    local stageData = stageDataOverride or readStageData()
    local challengeChoices = challengeChoicesOverride or readChallengeChoices()
    local specialChoices = readSpecialChoices()
    tab:Paragraph({
        Title = "Status",
        Desc = "Choose a mode below. Worldline and Boss Event use current game data.",
    })
    if runtime then
        local status = tab:Paragraph({ Title = "Join status", Desc = runtime.status })
        runtime.onStatus = function(value: string)
            status:SetDesc(value)
        end
    end
    local settings = tab:Section({ Title = "Auto Join Settings", Opened = true })
    settings:Paragraph({
        Title = "Storage",
        Desc = if state.persistent then "Autosaved to file" else "Session only: file APIs unavailable",
    })
    settings:Toggle({ Title = "Disable Auto Joiners", Value = state.paused, Callback = Settings.setPaused })
    settings:Toggle({
        Title = "Change Stage in Match",
        Desc = "As host before Vote Start, switch the match to the highest-priority enabled stage joiner's stage instead of returning to the lobby.",
        Value = state.changeStageInMatch ~= false,
        Callback = Settings.setChangeStageInMatch,
    })
    settings:Slider({
        Title = "Joiner Cooldown (seconds)",
        Step = 1,
        Value = { Min = 0, Max = 300, Default = state.cooldown },
        Callback = Settings.setCooldown,
    })
    local priorityLabel = settings:Paragraph({ Title = "Auto Join Priority", Desc = orderText() })
    local selected = state.priority[1]
    settings:Dropdown({
        Title = "Join Priority: select item to move up",
        Values = definitions,
        Value = selected,
        Callback = function(value: string)
            selected = value
        end,
    })
    settings:Button({
        Title = "Move selected up",
        Callback = function()
            if Settings.moveUp(selected) then
                priorityLabel:SetDesc(orderText())
            end
        end,
    })
    settings:Button({
        Title = "Reset Auto Join Priority",
        Callback = function()
            Settings.resetPriority()
            priorityLabel:SetDesc(orderText())
        end,
    })
    addStageSelector(
        tab:Section({ Title = "Stage Joiner", Opened = true }),
        stageData,
        "Story",
        "Stage",
        runtime
    )
    addStageSelector(
        tab:Section({ Title = "Legend Stage Joiner", Opened = false }),
        stageData,
        "LegendStage",
        "Legend Stage",
        runtime
    )
    addStageSelector(
        tab:Section({ Title = "Raid Joiner", Opened = false }),
        stageData,
        "Raid",
        "Raid",
        runtime
    )
    addStageSelector(
        tab:Section({ Title = "Dungeon Joiner", Opened = false }),
        stageData,
        "Dungeon",
        "Dungeon",
        runtime
    )
    addSpecial(tab, "Boss Event", specialChoices, runtime)
    addSpecial(tab, "Worldline", specialChoices, runtime)
    local updateBounty = addBounty(tab, runtime)
    local riftTimer = addRift(tab, runtime)
    local regTimer = addChallenge(tab, "Regular", challengeChoices, runtime)
    local dailyTimer = addChallenge(tab, "Daily", challengeChoices, runtime)
    local weeklyTimer = addChallenge(tab, "Weekly", challengeChoices, runtime)
    for _, name in
        {
            "Elemental Towers",
            "Portal",
        }
    do
        addUnavailable(tab, name, "Mode-specific choices are not verified yet.")
    end

    local env: any = getfenv()
    local taskApi = env.task
    if
        type(taskApi) == "table"
        and type(taskApi.spawn) == "function"
        and type(taskApi.wait) == "function"
    then
        (taskApi.spawn :: any)(function()
            local gameObject = env.game
            local rep = gameObject and gameObject:GetService("ReplicatedStorage")
            local starterPlayer = gameObject and gameObject:GetService("StarterPlayer")
            local cd = if rep then optionalModule(rep, "Modules.Data.Challenges.ChallengesData") else nil
            local cah = if starterPlayer
                then optionalModule(starterPlayer, "Modules.Gameplay.Challenges.ChallengesAttemptsHandler")
                else nil
            local mountedContext = runtime and runtime.context
            local function alive(): boolean
                return mountedContext ~= nil
                    and mountedContext.alive == true
                    and runtime.context == mountedContext
            end
            while alive() do
                local now = os.time()
                -- Update Rift Timer
                if riftTimer then
                    pcall(function()
                        local ws = gameObject and gameObject:GetService("Workspace")
                        local isRiftOpenAttr = nil
                        if ws and ws.GetAttribute then
                            local okA, a = pcall(ws.GetAttribute, ws, "IsRiftOpen")
                            if okA then
                                isRiftOpenAttr = a
                            end
                        end
                        local isOpen = if isRiftOpenAttr ~= nil
                            then (isRiftOpenAttr == true)
                            else (now % 3600 < 600)
                        if isOpen then
                            local closeLeft = 600 - (now % 3600)
                            riftTimer:SetDesc("[OPEN NOW] Closes in: " .. formatHMS(closeLeft))
                        else
                            local openLeft = 3600 - (now % 3600)
                            riftTimer:SetDesc("Opens in: " .. formatHMS(openLeft))
                        end
                    end)
                end

                -- Update Challenge Timers
                if
                    cd
                    and cah
                    and type(cd.GetNextReset) == "function"
                    and type(cah.GetChallengeSeed) == "function"
                then
                    local function updateTimer(timerObj: any, kindName: string)
                        if timerObj then
                            pcall(function()
                                local okSeed, seed = pcall(cah.GetChallengeSeed :: any, kindName)
                                local nextReset = 1
                                if okSeed and seed ~= nil then
                                    local okReset, resetVal = pcall(cd.GetNextReset :: any, kindName, seed)
                                    if okReset and type(resetVal) == "number" then
                                        nextReset = resetVal
                                    end
                                end
                                if nextReset <= 0 then
                                    timerObj:SetDesc("[AVAILABLE]")
                                else
                                    timerObj:SetDesc("Resets in: " .. formatHMS(nextReset))
                                end
                            end)
                        end
                    end
                    updateTimer(regTimer, "Regular")
                    updateTimer(dailyTimer, "Daily")
                    updateTimer(weeklyTimer, "Weekly")
                end
                pcall(updateBounty)
                local waitFn: any = taskApi.wait
                waitFn(1)
            end
        end)
    end
end

return Page
