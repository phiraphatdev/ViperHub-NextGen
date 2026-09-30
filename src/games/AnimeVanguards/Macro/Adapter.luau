--!strict
--[[
Purpose: Isolate patch-sensitive match modules, confirmed broadcasts and requests
Input: Live replicated game modules
Output: Read-only observation, state and bounded action request functions
Dependencies: Config; Roblox replicated modules
]]
local config = require("../Config")
local Document = require("./Document")
local Adapter = {}
local Vector3: any = (getfenv() :: any).Vector3
local task: any = (getfenv() :: any).task
local function position(value: any): any?
    local ok, result = pcall(function()
        local point = if value.X ~= nil then value else value.Position
        return { x = point.X, y = point.Y, z = point.Z }
    end)
    if ok then
        return result
    end
    return nil
end
local function priorityName(priorities: any, unit: any): string?
    local data = unit.Data or unit.UnitData
    local value = data and data.Priority
    if type(value) == "number" then
        return priorities[value]
    end
    if type(value) == "string" and table.find(priorities, value) then
        return value
    end
    return nil
end
--- Maps a unit's numeric Data.Priority to the game's targeting label, or nil.
Adapter.priorityName = priorityName
local function activeSnapshot(units: any, autoUpgrade: any, priorities: any, localPlayer: any): any
    local snapshot = {}
    local prioritiesMap = if autoUpgrade and type((autoUpgrade :: any).GetPriorities) == "function"
        then (autoUpgrade :: any).GetPriorities()
        else nil
    for guid, unit in units._ActiveUnits do
        if type(unit) == "table" and unit.Player == localPlayer then
            snapshot[guid] = {
                name = unit.Name,
                level = (unit.Data or unit.UnitData or {}).CurrentUpgrade or 0,
                priority = priorityName(priorities, unit),
                position = position(unit.UnitPosition or unit.Position),
                rotation = unit.RotationValue or unit.Rotation or 0,
                autoUpgrade = autoUpgrade.IsToggled(guid) == true,
                upgradePriority = prioritiesMap and prioritiesMap[guid],
                autoAbilities = if type(unit.AutoUseAbilities) == "table"
                    then table.clone(unit.AutoUseAbilities)
                    else {},
            }
        end
    end
    return snapshot
end
--- Binds only the game's public client modules and returns a match adapter.
function Adapter.new(): any
    local env: any = getfenv()
    local gameObject = env.game
    local replicated = gameObject:GetService("ReplicatedStorage")
    local starter = gameObject:GetService("StarterPlayer")
    local localPlayer = gameObject:GetService("Players").LocalPlayer
    local placement = (require :: any)(replicated.NetworkCode[config.remoteNames.macroPlacementClient])
    local abilities = (require :: any)(replicated.NetworkCode[config.remoteNames.macroAbilityClient])
    local gameUnits = (require :: any)(replicated.NetworkCode[config.remoteNames.macroUnitsClient])
    local unitState = (require :: any)(replicated.NetworkCode[config.remoteNames.macroUnitStateClient])
    local codec = (require :: any)(replicated.Modules.Shared.UnitSnapshotCodec)
    local DEFAULT_PRIORITIES = table.freeze({
        "First",
        "Closest",
        "Last",
        "Strongest",
        "Weakest",
        "Bosses",
    })
    local priorities = DEFAULT_PRIORITIES
    pcall(function()
        local ph = replicated:FindFirstChild("Modules")
            and replicated.Modules:FindFirstChild("Gameplay")
            and replicated.Modules.Gameplay:FindFirstChild("PriorityHandler")
        if ph then
            local mod = (require :: any)(ph)
            if mod and mod.PRIORITIES then
                priorities = mod.PRIORITIES
            end
        end
    end)
    local units = (require :: any)(starter.Modules.Gameplay.Units.ClientUnitHandler)
    local yen = (require :: any)(starter.Modules.Gameplay.PlayerYenHandler)
    local waves = (require :: any)(starter.Modules.Interface.Loader.HUD.Waves)
    local hudUnits = (require :: any)(starter.Modules.Interface.Loader.HUD.Units)
    local gameHandler = (require :: any)(replicated.Modules.Gameplay.GameHandler)
    local wavesClient = (require :: any)(replicated.NetworkCode.GameWavesClient)
    local endScreenClient = (require :: any)(replicated.NetworkCode.GameEndScreenClient)
    local endScreenCodec = (require :: any)(replicated.Modules.Shared.EndScreenNetworkCodec)
    local unitData = (require :: any)(replicated.Modules.Data.Entities.Units)
    local upgradeButtons = (require :: any)(
        starter.Modules.Gameplay.Units.UnitUpgradeHandler.Managers.ButtonsManager
    )
    local autoUpgrade = (require :: any)(
        starter.Modules.Gameplay.UnitManager.AutoUpgrade.AutoUpgradeDataHandler
    )
    local matchFlow = (require :: any)(replicated.NetworkCode.GameMatchFlowClient)
    local lobbyReturn = (require :: any)(replicated.NetworkCode.GameTeleportLobbyReturnClient)
    local clientAbilityHandler = nil
    pcall(function()
        local mod = starter:FindFirstChild("Modules")
            and starter.Modules:FindFirstChild("Gameplay")
            and starter.Modules.Gameplay:FindFirstChild("ClientAbilityHandler")
        if mod then
            clientAbilityHandler = (require :: any)(mod)
        end
    end)
    local self: any = {}
    local abilityVersion = 0
    local abilityEvents: { [string]: number } = {}
    self.abilityBaselines = {}
    local lastPrompt: any = nil
    local promptShownConn: any = nil
    local promptClosedConn: any = nil
    if
        wavesClient
        and wavesClient.WaveSkipPromptShown
        and type((wavesClient.WaveSkipPromptShown :: any).On) == "function"
    then
        promptShownConn = (wavesClient.WaveSkipPromptShown :: any).On(function(payload: any)
            lastPrompt = payload
        end)
    end
    if
        wavesClient
        and wavesClient.WaveSkipPromptClosed
        and type((wavesClient.WaveSkipPromptClosed :: any).On) == "function"
    then
        promptClosedConn = (wavesClient.WaveSkipPromptClosed :: any).On(function()
            lastPrompt = nil
        end)
    end
    local abilityConnection = nil
    if
        clientAbilityHandler
        and clientAbilityHandler.AbilityCooldownAdded
        and type(clientAbilityHandler.AbilityCooldownAdded.Connect) == "function"
    then
        abilityConnection = clientAbilityHandler.AbilityCooldownAdded:Connect(
            function(unitGuid: any, abilityName: any)
                if type(unitGuid) == "string" and type(abilityName) == "string" then
                    abilityVersion += 1
                    local key = unitGuid .. ":" .. abilityName
                    abilityEvents[key] = abilityVersion
                end
            end
        )
    elseif
        abilities
        and abilities.AbilityLifecycleUpdated
        and type((abilities.AbilityLifecycleUpdated :: any).On) == "function"
    then
        abilityConnection = (abilities.AbilityLifecycleUpdated :: any).On(function(payload: any)
            if
                type(payload) == "table"
                and payload.State == "AbilityStarted"
                and type(payload.Payload) == "table"
                and type(payload.Payload.AbilityName) == "string"
            then
                abilityVersion += 1
                local key = tostring(payload.UnitGUID) .. ":" .. payload.Payload.AbilityName
                abilityEvents[key] = abilityVersion
            end
        end)
    end
    function self.close()
        if abilityConnection then
            local c: any = abilityConnection
            local ok = pcall(function()
                c:Disconnect()
            end)
            if not ok then
                pcall(function()
                    c()
                end)
            end
            abilityConnection = nil
        end
        if promptShownConn then
            (promptShownConn :: any)()
            promptShownConn = nil
        end
        if promptClosedConn then
            (promptClosedConn :: any)()
            promptClosedConn = nil
        end
        table.clear(abilityEvents)
        table.clear(self.abilityBaselines)
    end
    function self.state(): any?
        if type(gameHandler.GameData) ~= "table" or not gameHandler.IsMatchStarted then
            return nil
        end
        return {
            wave = tonumber(waves.CurrentWave) or 0,
            yen = tonumber(yen.GetYen()) or 0,
            match = {
                mode = gameHandler.GameData.StageType,
            },
            units = activeSnapshot(units, autoUpgrade, priorities, localPlayer),
        }
    end
    function self.matchStarted(): boolean
        return gameHandler.IsMatchStarted == true
    end
    function self.getGameSetting(name: string): boolean?
        local ok, value = pcall(function()
            local stateMod = starter:FindFirstChild("Modules")
                and starter.Modules:FindFirstChild("Gameplay")
                and starter.Modules.Gameplay:FindFirstChild("SettingsHandler")
                and starter.Modules.Gameplay.SettingsHandler:FindFirstChild("SettingsState")
            if stateMod then
                local settingsState = (require :: any)(stateMod)
                return settingsState:GetSetting(name)
            end
            return nil
        end)
        if ok and type(value) == "boolean" then
            return value
        end
        return nil
    end
    function self.preMatchState(): any?
        if type(gameHandler.GameData) ~= "table" or gameHandler.IsMatchStarted then
            return nil
        end
        return {
            wave = 0,
            yen = tonumber(yen.GetYen()) or 0,
            match = { mode = gameHandler.GameData.StageType },
        }
    end
    function self.currentStartPrompt(): any?
        if gameHandler.IsMatchStarted then
            return nil
        end
        if lastPrompt and type(lastPrompt) == "table" and lastPrompt.Context == "Start" then
            return lastPrompt
        end
        local prompt = localPlayer
            and localPlayer.PlayerGui
            and localPlayer.PlayerGui:FindFirstChild("SkipWave")
        local holder = prompt and prompt:FindFirstChild("Holder")
        local yes = holder and holder:FindFirstChild("Yes")
        if holder and yes and not gameHandler.IsMatchStarted then
            return { Context = "Start", StartTime = "visible" }
        end
        return nil
    end
    function self.castStartVote(): boolean
        return pcall(wavesClient.CastWaveSkipVote.Fire)
    end
    function self.castRestartVote(): boolean
        local data = gameHandler.GameData
        if
            type(data) ~= "table"
            or data.PortalData ~= nil
            or data.StageType == "GuildWar"
            or data.StageType == "Gauntlet"
            or data.StageType == "Odyssey"
        then
            return false
        end
        return pcall(matchFlow.CastRestartVote.Fire)
    end
    function self.returnToLobby(): boolean
        return pcall(lobbyReturn.RequestTeleportToLobby.Fire)
    end
    function self.teamUnits(): { string }
        local names = {}
        if type(hudUnits.FrameData) == "table" then
            for _, unit in hudUnits.FrameData do
                if type(unit) == "table" and type(unit.Name) == "string" then
                    table.insert(names, unit.Name)
                end
            end
        end
        return names
    end
    function self.cost(action: any, refs: any): number?
        local ok, price = pcall(function(): any
            if action.kind == "place" then
                local slot = hudUnits.FrameData[action.slotIndex]
                if not slot or not slot.Unit or slot.Name ~= action.unitName then
                    if type(hudUnits.FrameData) == "table" then
                        for _, candidate in hudUnits.FrameData do
                            if
                                type(candidate) == "table"
                                and candidate.Name == action.unitName
                                and candidate.Unit
                            then
                                slot = candidate
                                break
                            end
                        end
                    end
                end
                if not slot or not slot.Unit or slot.Name ~= action.unitName then
                    return nil
                end
                local data = unitData:GetUnitDataFromID(slot.Unit.Identifier)
                return yen:GetPlacementAffordability(data, slot.Unit).Price
            end
            if action.kind == "upgrade" then
                local unit = units._ActiveUnits[refs[action.unitRef]]
                local data = unit and (unit.Data or unit.UnitData)
                if not data or type(data.CurrentUpgrade) ~= "number" then
                    return nil
                end
                return upgradeButtons.GetUpgradePrice(unit, data.CurrentUpgrade + 1)
            end
            return 0
        end)
        local numericPrice = tonumber(price)
        if
            ok
            and type(numericPrice) == "number"
            and numericPrice >= 0
            and numericPrice < math.huge
            and numericPrice == numericPrice
        then
            return numericPrice
        end
        if action.kind == "place" then
            local slot = hudUnits.FrameData[action.slotIndex]
            if not slot or slot.Name ~= action.unitName then
                if type(hudUnits.FrameData) == "table" then
                    for _, candidate in hudUnits.FrameData do
                        if
                            type(candidate) == "table"
                            and candidate.Name == action.unitName
                            and candidate.Frame
                        then
                            slot = candidate
                            break
                        end
                    end
                end
            end
            if slot and slot.Name == action.unitName and slot.Frame then
                local container = slot.Frame:FindFirstChild("Container")
                local holder = container and container:FindFirstChild("Holder")
                local main = holder and holder:FindFirstChild("Main")
                local label = main and main:FindFirstChild("Price")
                local digits = label and tostring(label.Text):match("([%d,]+)")
                local displayed = digits and tonumber((digits:gsub(",", "")))
                if displayed then
                    return displayed
                end
            end
        end
        return nil
    end
    function self.observe(kind: string, callback: (any) -> ()): any?
        if kind == "restart" then
            return gameHandler.MatchRestarted:Connect(callback)
        end
        if kind == "matchEnd" then
            return gameHandler.MatchEnded:Connect(callback)
        end
        if kind == "matchStart" then
            return gameHandler.MatchStarted:Connect(callback)
        end
        if kind == "votePrompt" then
            return wavesClient.WaveSkipPromptShown.On(callback)
        end
        if kind == "voteClicked" then
            local cleanups: { any } = {}
            local function bindButton(prompt: any)
                local holder = prompt and prompt:FindFirstChild("Holder")
                local yes = holder and holder:FindFirstChild("Yes")
                local button = yes and (yes:FindFirstChild("Button") or yes)
                if button and (button:IsA("GuiButton") or button.Activated) then
                    local clickedConn = button.Activated:Connect(function()
                        if
                            not gameHandler.IsMatchStarted or (lastPrompt and lastPrompt.Context == "Start")
                        then
                            callback({ Context = "Start" })
                        end
                    end)
                    table.insert(cleanups, clickedConn)
                end
            end

            local existing = localPlayer
                and localPlayer.PlayerGui
                and localPlayer.PlayerGui:FindFirstChild("SkipWave")
            if existing then
                bindButton(existing)
            end

            if localPlayer and localPlayer.PlayerGui then
                local addedConn = localPlayer.PlayerGui.ChildAdded:Connect(function(child: any)
                    if child and child.Name == "SkipWave" then
                        task.defer(bindButton, child)
                    end
                end)
                table.insert(cleanups, addedConn)
            end

            if
                wavesClient
                and wavesClient.CastWaveSkipVote
                and type(wavesClient.CastWaveSkipVote.Fire) == "function"
            then
                local origFire = wavesClient.CastWaveSkipVote.Fire
                local wrapped
                wrapped = function(...)
                    if not gameHandler.IsMatchStarted or (lastPrompt and lastPrompt.Context == "Start") then
                        pcall(callback, { Context = "Start" })
                    end
                    return (origFire :: any)(...)
                end
                wavesClient.CastWaveSkipVote.Fire = wrapped
                table.insert(cleanups, function()
                    if wavesClient.CastWaveSkipVote.Fire == wrapped then
                        wavesClient.CastWaveSkipVote.Fire = origFire
                    end
                end)
            end

            return function()
                for _, cleanup in cleanups do
                    pcall(function()
                        if type(cleanup) == "function" then
                            (cleanup :: any)()
                        else
                            cleanup:Disconnect()
                        end
                    end)
                end
                table.clear(cleanups)
            end
        end
        if kind == "voteClosed" then
            return wavesClient.WaveSkipPromptClosed.On(callback)
        end
        if kind == "result" then
            return endScreenClient.ShowEndScreen.On(function(payload: any)
                local ok, summary = pcall(endScreenCodec.DecodeMatchEndSummary, payload)
                if ok and type(summary) == "table" and not summary.IsFakeEndScreen then
                    callback(summary.Status)
                end
            end)
        end
        if kind == "place" then
            return placement.UnitPlaced.On(function(payload: any)
                local ok, decoded = pcall(function()
                    return type(payload) == "table" and codec.DecodeUnitEnvelope(payload.Snapshot) or nil
                end)
                local unit = if ok then decoded else nil
                if type(unit) ~= "table" or unit.Player ~= localPlayer then
                    return
                end
                local pos = position(unit.UnitPosition or unit.Position)
                if pos then
                    local slotIndex = unit.SlotIndex
                    if type(slotIndex) ~= "number" and type(hudUnits.FrameData) == "table" then
                        for index, equipped in hudUnits.FrameData do
                            if type(equipped) == "table" and equipped.Name == unit.Name then
                                slotIndex = tonumber(index)
                                break
                            end
                        end
                    end
                    if type(slotIndex) ~= "number" or slotIndex < 1 then
                        return
                    end
                    callback({
                        guid = unit.UniqueIdentifier,
                        unitName = unit.Name,
                        position = pos,
                        rotation = unit.RotationValue or unit.Rotation or 0,
                        slotIndex = slotIndex,
                        level = (unit.Data or unit.UnitData or {}).CurrentUpgrade or 0,
                        priorityName = priorityName(priorities, unit),
                        autoAbilities = table.clone(unit.AutoUseAbilities or {}),
                    })
                end
            end)
        elseif kind == "upgrade" then
            return placement.UnitUpgraded.On(function(payload: any)
                if type(payload) == "table" then
                    local current = units._ActiveUnits[payload.UnitGUID]
                    local ok, decoded = pcall(function()
                        return current and codec.DecodeUnitUpgradeEnvelope(payload, current)
                    end)
                    local changed = if ok then decoded else nil
                    local data = changed and (changed.Data or changed.UnitData)
                    local level = data and data.CurrentUpgrade
                    if type(level) == "number" then
                        callback({ guid = payload.UnitGUID, level = level })
                    end
                end
            end)
        elseif kind == "sell" then
            return placement.UnitRemoved.On(function(payload: any)
                if type(payload) == "table" then
                    callback({ guid = payload.UnitGUID })
                end
            end)
        elseif kind == "priority" then
            return units.OnUnitPriorityChanged:Connect(function(unit: any)
                if type(unit) == "table" and unit.Player == localPlayer then
                    local name = priorityName(priorities, unit)
                    if name then
                        callback({ guid = unit.UniqueIdentifier, priorityName = name })
                    end
                end
            end)
        elseif kind == "ability" then
            if
                clientAbilityHandler
                and clientAbilityHandler.AbilityCooldownAdded
                and type(clientAbilityHandler.AbilityCooldownAdded.Connect) == "function"
            then
                local conn = clientAbilityHandler.AbilityCooldownAdded:Connect(
                    function(guid: any, abilityName: any)
                        callback({ guid = tostring(guid), abilityName = tostring(abilityName) })
                    end
                )
                return function()
                    pcall(function()
                        conn:Disconnect()
                    end)
                end
            elseif
                abilities
                and abilities.AbilityLifecycleUpdated
                and type((abilities.AbilityLifecycleUpdated :: any).On) == "function"
            then
                return (abilities.AbilityLifecycleUpdated :: any).On(function(payload: any)
                    if
                        type(payload) == "table"
                        and payload.State == "AbilityStarted"
                        and type(payload.Payload) == "table"
                    then
                        callback({ guid = payload.UnitGUID, abilityName = payload.Payload.AbilityName })
                    end
                end)
            end
        elseif kind == "autoUpgrade" then
            return gameUnits.AutoUpgradeToggled.On(function(payload: any)
                if type(payload) == "table" and type(payload.Toggle) == "boolean" then
                    callback({ guid = payload.UnitGUID, enabled = payload.Toggle })
                end
            end)
        elseif kind == "upgradePriority" then
            return gameUnits.AutoUpgradePriorityUpdated.On(function(payload: any)
                if type(payload) == "table" and type(payload.Priority) == "number" then
                    callback({ guid = payload.UnitGUID, upgradePriority = payload.Priority })
                end
            end)
        elseif kind == "autoAbility" then
            return unitState.AutoAbilityToggled.On(function(payload: any)
                if
                    type(payload) == "table"
                    and type(payload.Enabled) == "boolean"
                    and type(payload.AbilityName) == "string"
                then
                    callback({
                        guid = payload.UnitGUID,
                        abilityName = payload.AbilityName,
                        enabled = payload.Enabled,
                    })
                end
            end)
        end
        return nil
    end
    function self.request(action: any, refs: any): boolean
        if action.kind == "voteStart" then
            return self.currentStartPrompt() ~= nil and self.castStartVote()
        end
        local guid = refs[action.unitRef]
        local placementPosition, placementRotation = Document.toPose(action.cframe)
        if action.kind == "ability" and guid then
            local key = guid .. ":" .. tostring(action.abilityName)
            self.abilityBaselines[key] = abilityEvents[key] or abilityVersion
        end
        local ok = pcall(function()
            if action.kind == "place" then
                if not placementPosition or not placementRotation then
                    error("invalid CFrame")
                end
                local slotIndex = action.slotIndex
                if type(hudUnits.FrameData) == "table" then
                    local currentSlot = hudUnits.FrameData[slotIndex]
                    if not currentSlot or currentSlot.Name ~= action.unitName then
                        for index, candidate in hudUnits.FrameData do
                            if type(candidate) == "table" and candidate.Name == action.unitName then
                                slotIndex = tonumber(index) or slotIndex
                                break
                            end
                        end
                    end
                end
                placement.RequestPlaceUnit.Fire({
                    UnitName = action.unitName,
                    Position = Vector3.new(placementPosition.x, placementPosition.y, placementPosition.z),
                    Rotation = placementRotation,
                    SlotIndex = slotIndex,
                })
            elseif action.kind == "upgrade" and guid then
                placement.RequestUpgradeUnit.Fire({ UnitGUID = guid })
            elseif action.kind == "sell" and guid then
                placement.RequestSellUnit.Fire({ UnitGUID = guid })
            elseif action.kind == "priority" and guid then
                placement.RequestChangeUnitPriority.Fire({
                    UnitGUID = guid,
                    PriorityName = action.priorityName,
                })
            elseif action.kind == "ability" and guid then
                abilities.RequestAbilityActivation.Fire({ UnitGUID = guid, AbilityName = action.abilityName })
            elseif action.kind == "autoUpgrade" and guid then
                if (autoUpgrade.IsToggled(guid) == true) ~= action.enabled then
                    gameUnits.RequestAutoUpgradeToggle.Fire({ UnitGUIDs = { guid } })
                end
            elseif action.kind == "upgradePriority" and guid then
                if autoUpgrade.GetPriorities()[guid] ~= action.upgradePriority then
                    gameUnits.RequestAutoUpgradeChangePriority.Fire({ UnitGUID = guid })
                end
            elseif action.kind == "autoAbility" and guid then
                local unit = units._ActiveUnits[guid]
                if not unit then
                    error("unit unavailable")
                end
                local autoAbilities = unit.AutoUseAbilities or {}
                if (table.find(autoAbilities, action.abilityName) ~= nil) ~= action.enabled then
                    unitState.RequestAutoAbilityToggle.Fire({
                        UnitGUID = guid,
                        AbilityName = action.abilityName,
                    })
                end
            else
                error("missing unit reference")
            end
        end)
        return ok
    end
    function self.satisfied(action: any, refs: any): boolean
        local current = self.state()
        local guid = refs[action.unitRef]
        if action.kind == "sell" then
            return guid ~= nil and current ~= nil and current.units[guid] == nil
        end
        local unit = current and guid and current.units[guid]
        if not unit then
            return false
        end
        if action.kind == "upgrade" then
            return type(action.level) == "number"
                and tonumber(unit.level) ~= nil
                and unit.level >= action.level
        end
        if action.kind == "priority" then
            return unit.priority == action.priorityName
        end
        if action.kind == "autoUpgrade" then
            return unit.autoUpgrade == action.enabled
        end
        if action.kind == "upgradePriority" then
            return unit.upgradePriority == action.upgradePriority
        end
        if action.kind == "autoAbility" then
            return type(unit.autoAbilities) == "table"
                and (table.find(unit.autoAbilities, action.abilityName) ~= nil) == action.enabled
        end
        if action.kind == "ability" then
            return type(unit.autoAbilities) == "table"
                and table.find(unit.autoAbilities, action.abilityName) ~= nil
        end
        return false
    end
    function self.confirm(action: any, before: any, refs: any): (boolean, string?)
        local after = self.state()
        if not after then
            return false, nil
        end
        if action.kind == "place" then
            local placementPosition = Document.toPose(action.cframe)
            if not placementPosition then
                return false, nil
            end
            for guid, unit in after.units do
                if not before.units[guid] and unit.name == action.unitName then
                    local p = unit.position
                    if p then
                        local dx = p.x - placementPosition.x
                        local dy = p.y - placementPosition.y
                        local dz = p.z - placementPosition.z
                        local horizontal = dx * dx + dz * dz
                        if horizontal < 10 and math.abs(dy) < 5 then
                            return true, guid
                        end
                    end
                end
            end
            return false, nil
        end
        local guid = refs[action.unitRef]
        if not guid then
            return false, nil
        end
        local old, new = before.units[guid], after.units[guid]
        if action.kind == "sell" then
            return new == nil, nil
        end
        if not old or not new then
            return false, nil
        end
        if action.kind == "upgrade" then
            return type(action.level) == "number" and tonumber(new.level) ~= nil and new.level >= action.level,
                nil
        end
        if action.kind == "priority" then
            return new.priority == action.priorityName, nil
        end
        if action.kind == "ability" then
            local key = guid .. ":" .. tostring(action.abilityName)
            local recordedVer = abilityEvents[key] or 0
            local baseline = self.abilityBaselines and self.abilityBaselines[key] or 0
            return recordedVer > baseline, nil
        end
        if action.kind == "autoUpgrade" then
            return new.autoUpgrade == action.enabled, nil
        end
        if action.kind == "upgradePriority" then
            return new.upgradePriority == action.upgradePriority, nil
        end
        if action.kind == "autoAbility" then
            return type(new.autoAbilities) == "table"
                and (table.find(new.autoAbilities, action.abilityName) ~= nil) == action.enabled,
                nil
        end
        return false, nil
    end
    return self
end
return Adapter
