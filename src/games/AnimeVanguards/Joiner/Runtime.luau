--!strict
--[[
Purpose: Request one lobby for the highest-priority enabled joiner, then start only its confirmed hosted match
Input: Joiner selections, context lifetime, and game-owned matchmaking modules
Output: Bounded join/start attempts and confirmation/teleport status
Dependencies: Settings; replicated matchmaking, challenge and stage-progress modules
]]

local Settings = require("./Settings")
local ActivityState = require("./ActivityState")
local metadata = require("../Metadata")
local config = require("../Config")
local Runtime = {}
local LOBBY_PLACE_ID = metadata.placeIds[1]
local RETRY_SECONDS = 30
local POLL_SECONDS = 1
local RIFT_POLL_SECONDS = 2
local ACK_TIMEOUT_SECONDS = 10
local START_TIMEOUT_SECONDS = 15
local MODES = { Stage = "Story", ["Legend Stage"] = "LegendStage", Raid = "Raid", Dungeon = "Dungeon" }
local CHALLENGES = {
    ["Regular Challenge"] = "Regular",
    ["Daily Challenge"] = "Daily",
    ["Weekly Challenge"] = "Weekly",
}

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

local function requestLobbyReturn(deps: any): boolean
    local client = deps.lobbyReturn
    if not client and deps.game then
        local ok, replicated = pcall(deps.game.GetService, deps.game, "ReplicatedStorage")
        if ok then
            client = optionalModule(replicated, config.instancePaths.lobbyReturnClient)
        end
    end
    local remote = client and client[config.remoteNames.requestTeleportToLobby]
    if not remote or type(remote.Fire) ~= "function" then
        return false
    end
    -- The game's own Leave control calls this generated client as .Fire(), not :Fire().
    return pcall(remote.Fire)
end

local function liveDependencies(): any
    local env: any = getfenv()
    local gameObject = env.game
    local replicated = gameObject:GetService("ReplicatedStorage")
    local starterPlayer = gameObject:GetService("StarterPlayer")
    local base = starterPlayer.Modules.Interface.Loader.Gameplay.LobbyHandler
    local isLobby = gameObject.PlaceId == LOBBY_PLACE_ID
    return {
        game = gameObject,
        task = env.task,
        clock = os.time,
        userId = gameObject:GetService("Players").LocalPlayer.UserId,
        localPlayer = gameObject:GetService("Players").LocalPlayer,
        network = if isLobby then optionalModule(replicated, "NetworkCode.LobbyMatchmakingClient") else nil,
        lobby = if isLobby then optionalModule(base, "LobbyHandler") else nil,
        progress = if isLobby then optionalModule(base, "PlayerLobbyDataHandler") else nil,
        challengeNetwork = if isLobby
            then optionalModule(replicated, "NetworkCode.LobbyChallengesClient")
            else nil,
        challengeData = optionalModule(replicated, "Modules.Data.Challenges.ChallengesData"),
        challengeStages = if isLobby
            then optionalModule(starterPlayer, "Modules.Gameplay.Challenges.ChallengesDataHandler")
            else nil,
        challengeAttempts = optionalModule(
            starterPlayer,
            "Modules.Gameplay.Challenges.ChallengesAttemptsHandler"
        ),
        bountyData = optionalModule(replicated, config.instancePaths.bountyData),
        bountyState = if isLobby
            then optionalModule(starterPlayer, config.instancePaths.bountyState)
            else nil,
        worldlines = optionalModule(replicated, config.instancePaths.worldlinesData),
        worldlineNetwork = if isLobby
            then optionalModule(replicated, config.instancePaths.worldlinesClient)
            else nil,
        bossRotation = optionalModule(replicated, config.instancePaths.bossRotation),
        bossEvents = optionalModule(replicated, config.instancePaths.bossEventNames),
        bossNetwork = if isLobby
            then optionalModule(replicated, config.instancePaths.bossEventsClient)
            else nil,
        specialEvents = if isLobby
            then optionalModule(replicated, config.instancePaths.specialEventsClient)
            else nil,
        riftsData = optionalModule(starterPlayer, config.instancePaths.riftsData),
        activityState = ActivityState.new(env, gameObject:GetService("Players").LocalPlayer.UserId),
        gameHandler = if not isLobby
            then optionalModule(replicated, config.instancePaths.gameHandler)
            else nil,
        lobbyReturn = if not isLobby
            then optionalModule(replicated, config.instancePaths.lobbyReturnClient)
            else nil,
    }
end

--- Creates a joiner; injected dependencies are for isolated tests. Returns a stopped controller.
function Runtime.new(dependencies: any?): any
    local self: any = {
        dependencies = dependencies,
        context = nil,
        enabled = {},
        selection = {},
        pending = nil,
        lastAttempt = -math.huge,
        status = "Idle",
        onStatus = nil,
        disconnect = nil,
        teleportConnection = nil,
        matchEndConnection = nil,
        confirmed = nil,
        currentJoinedName = nil,
        teleportingToLobby = nil,
        returnAttempts = 0,
        lastActivityRead = -math.huge,
        returnOnMatchEnd = false,
        macro = nil,
        gameSettings = nil,
    }
    local function setStatus(value: string)
        self.status = value
        if self.onStatus then
            pcall(self.onStatus, value)
        end
    end

    function self.setMacro(m: any)
        self.macro = m
    end

    function self.setGameSettings(gs: any)
        self.gameSettings = gs
    end

    function self.setSelection(name: string, stage: string, act: string, difficulty: string)
        if MODES[name] and type(stage) == "string" and type(act) == "string" then
            self.selection[name] = { stage = stage, act = act, difficulty = difficulty }
            Settings.setSelection(name, self.selection[name])
        end
    end

    function self.setChallenge(name: string, challengeName: string)
        if CHALLENGES[name] and type(challengeName) == "string" and #challengeName > 0 then
            local existing = Settings.get().selection[name]
            local merged: any = if type(existing) == "table" then table.clone(existing) else {}
            merged.challengeName = challengeName
            self.selection[name] = merged
            Settings.setSelection(name, merged)
        end
    end

    function self.setWorldline(worldlineId: string, traitsType: string)
        if
            type(worldlineId) == "string"
            and #worldlineId > 0
            and (traitsType == "Traits" or traitsType == "NoTraits")
        then
            self.selection.Worldline = { worldlineId = worldlineId, traitsType = traitsType }
            Settings.setSelection("Worldline", self.selection.Worldline)
        end
    end

    --- Stores the difficulty used for the daily Boss Bounty match ("Normal" or "Nightmare").
    function self.setBounty(difficulty: string)
        if difficulty == "Normal" or difficulty == "Nightmare" then
            self.selection["Boss Bounties"] = { difficulty = difficulty }
            Settings.setSelection("Boss Bounties", self.selection["Boss Bounties"])
        end
    end

    --- Reads today's bounty from the game: {mode, stage, act, boss, left} or nil when unavailable.
    function self.readBounty(): any
        local deps = self.dependencies
        if not deps or not deps.bountyData or not deps.bountyState then
            return nil
        end
        local okSeed, seed = pcall(deps.bountyState.GetSeed)
        local okLeft, left = pcall(deps.bountyState.GetBountiesLeft)
        if not okSeed or not okLeft or type(seed) ~= "number" or type(left) ~= "number" then
            return nil
        end
        local okData, bounty = pcall(deps.bountyData.GetBountyFromSeed, seed)
        if
            not okData
            or type(bounty) ~= "table"
            or type(bounty.StageType) ~= "string"
            or type(bounty.Stage) ~= "string"
            or type(bounty.Act) ~= "string"
        then
            return nil
        end
        return {
            mode = bounty.StageType,
            stage = bounty.Stage,
            act = bounty.Act,
            boss = if type(bounty.BossName) == "string" then bounty.BossName else nil,
            left = left,
        }
    end

    --- Reads Worldline progress: {room, worlds = {{id, room, completed}}} or nil when not ready.
    function self.readWorldlineProgress(): any
        local deps = self.dependencies
        local remote = deps
            and deps.worldlineNetwork
            and deps.worldlineNetwork[config.remoteNames.worldlineProgress]
        if not remote or type(remote.Invoke) ~= "function" then
            return nil
        end
        local ok, progress = pcall(remote.Invoke)
        if not ok or type(progress) ~= "table" or progress.Ready ~= true then
            return nil
        end
        local worlds: { any } = {}
        if type(progress.AltWorldlines) == "table" then
            for _, entry in progress.AltWorldlines do
                if type(entry) == "table" and type(entry.WorldlineId) == "string" then
                    table.insert(worlds, {
                        id = entry.WorldlineId,
                        room = if type(entry.CurrentRoom) == "number" then entry.CurrentRoom else nil,
                        completed = entry.Completed == true,
                    })
                end
            end
        end
        return {
            room = if type(progress.CurrentRoom) == "number" then progress.CurrentRoom else nil,
            worlds = worlds,
        }
    end

    function self.setBossEvent(eventName: string, difficulty: string)
        if
            type(eventName) == "string"
            and #eventName > 0
            and (difficulty == "Normal" or difficulty == "Elite")
        then
            self.selection["Boss Event"] = { eventName = eventName, difficulty = difficulty }
            Settings.setSelection("Boss Event", self.selection["Boss Event"])
        end
    end

    function self.setEnabled(name: string, value: boolean)
        if
            (
                MODES[name]
                or CHALLENGES[name]
                or name == "Worldline"
                or name == "Boss Event"
                or name == "Boss Bounties"
                or name == "Rift"
            ) and type(value) == "boolean"
        then
            self.enabled[name] = value
            Settings.setEnabled(name, value)
            setStatus(if value then "Enabled: " .. name else "Disabled: " .. name)
        end
    end

    function self.stepInMatch(now: number)
        local deps = self.dependencies
        local settings = Settings.get()
        if settings.paused then
            self.teleportingToLobby = nil
            self.returnOnMatchEnd = false
            return
        end

        -- Wait until game data has replicated in the match place
        if deps.gameHandler and not deps.gameHandler.IsGameLoaded then
            return
        end

        local matchData = deps.gameHandler and deps.gameHandler.GameData
        local currentChallenge = type(matchData) == "table"
                and (matchData.ChallengeType or matchData.Challenge)
            or nil
        local currentRift = type(matchData) == "table"
            and (matchData.Rift ~= nil or matchData.IsBossRift == true or matchData.StageType == "Rift")
        local isAnyChallenge = currentChallenge ~= nil
            or (type(matchData) == "table" and matchData.StageType == "Challenge")

        -- Never interrupt while actively playing ANY Challenge or Rift match!
        if isAnyChallenge or currentRift then
            return
        end

        -- Never interrupt if the joiner confirmed entry into a Challenge or Rift!
        if
            self.currentJoinedName
            and (CHALLENGES[self.currentJoinedName] or self.currentJoinedName == "Rift")
        then
            return
        end

        if self.teleportingToLobby then
            if
                now - self.teleportingToLobby >= config.thresholds.returnRetrySeconds
                and self.returnAttempts < config.thresholds.returnRetryLimit
            then
                self.returnAttempts += 1
                self.teleportingToLobby = now
                setStatus(
                    if requestLobbyReturn(deps)
                        then "Lobby return requested again"
                        else "Lobby return request failed"
                )
            end
            return
        end

        local snapshot = deps.activityState and deps.activityState.load(now, deps.challengeData)
        local states = if snapshot and type(snapshot.states) == "table" then snapshot.states else {}
        local ws: any = deps.game and deps.game:GetService("Workspace")
        local isRiftOpenAttr = nil
        if ws and ws.GetAttribute then
            local okAttr, attrVal = pcall(ws.GetAttribute, ws, config.attributes.riftOpen)
            if okAttr and type(attrVal) == "boolean" then
                isRiftOpenAttr = attrVal
            end
        end
        if isRiftOpenAttr == true then
            states.Rift = { status = "available" }
        end
        for _, name in settings.priority do
            local choice = settings.selection[name]
            local state = states[CHALLENGES[name] or name]
            if
                settings.enabled[name]
                and choice
                and choice.backToLobby
                and type(state) == "table"
                and state.status == "available"
                and not (name == "Rift" and currentRift)
                and not (CHALLENGES[name] and currentChallenge == CHALLENGES[name])
            then
                local reason = if name == "Rift" then "Rift is open!" else (name .. ": available")
                if choice.returnMode == "Wait Match End" then
                    if not self.returnOnMatchEnd then
                        self.returnOnMatchEnd = true
                        setStatus(reason .. "; returning after match end")
                    end
                else
                    if self.macro and type(self.macro.suspend) == "function" then
                        pcall(self.macro.suspend :: any)
                    end
                    self.returnAttempts = 1
                    self.teleportingToLobby = now
                    setStatus(
                        if requestLobbyReturn(deps)
                            then reason .. " Returning to lobby..."
                            else name .. ": lobby return request failed"
                    )
                end
                return
            end
        end
    end

    function self.step(now: number)
        local context = self.context
        local deps = self.dependencies
        if not context or not context.alive or not deps then
            return
        end
        if deps.game and deps.game.PlaceId ~= LOBBY_PLACE_ID then
            self.stepInMatch(now)
            return
        end
        if deps.activityState and now - self.lastActivityRead >= RIFT_POLL_SECONDS then
            local states: { [string]: any } = {}
            local challengeSeeds: { [string]: number } = {}
            for _, kind in { "Regular", "Daily", "Weekly" } do
                local status, period =
                    ActivityState.challenge(deps.challengeAttempts, deps.challengeData, kind)
                if status ~= "unknown" and period ~= nil then
                    states[kind] = { status = status, period = period }
                end
                if deps.challengeAttempts and type(deps.challengeAttempts.GetChallengeSeed) == "function" then
                    local okSeed, seedVal = pcall(deps.challengeAttempts.GetChallengeSeed :: any, kind)
                    if okSeed and type(seedVal) == "number" then
                        challengeSeeds[kind] = seedVal
                    end
                end
            end
            local riftStatus = ActivityState.rift(deps.game, deps.specialEvents)
            if riftStatus == "available" then
                states.Rift = { status = riftStatus, observedAt = now }
            end
            local riftInfo = nil
            if deps.specialEvents and deps.specialEvents[config.remoteNames.getRiftAttempts] then
                local remote = deps.specialEvents[config.remoteNames.getRiftAttempts]
                if type(remote.Invoke) == "function" then
                    local ok, res = pcall(remote.Invoke)
                    if
                        ok
                        and type(res) == "table"
                        and res.Ready
                        and type(res.AttemptsRemaining) == "number"
                    then
                        riftInfo = { attempts = res.AttemptsRemaining, hour = math.floor(now / 3600) }
                    end
                end
            end
            deps.activityState.save(now, states, challengeSeeds, riftInfo)
            self.lastActivityRead = now
        end
        if self.confirmed then
            local confirmed = self.confirmed
            if not confirmed.startSent and (Settings.get().paused or not self.enabled[confirmed.name]) then
                self.confirmed = nil
                setStatus(confirmed.name .. ": Start cancelled")
                return
            end
            if deps.game.PlaceId ~= LOBBY_PLACE_ID then
                self.currentJoinedName = confirmed.name
                self.confirmed = nil
                setStatus(confirmed.name .. ": entered match")
                return
            end
            if confirmed.startSent then
                if now - confirmed.startSent >= START_TIMEOUT_SECONDS then
                    self.confirmed = nil
                    setStatus(confirmed.name .. ": Start sent; teleport not confirmed")
                end
                return
            end
            if confirmed.mode == "Rift" then
                -- Direct remote join without manual hosting
                return
            end
            if not deps.lobby.IsHosting then
                if now - confirmed.confirmedAt >= ACK_TIMEOUT_SECONDS then
                    self.confirmed = nil
                    setStatus(confirmed.name .. ": host state not ready")
                end
                return
            end
            if
                not deps.network
                or not deps.network.StartMatch
                or type(deps.network.StartMatch.Fire) ~= "function"
            then
                self.confirmed = nil
                setStatus(confirmed.name .. ": Start network unavailable")
                return
            end
            confirmed.startSent = now
            local ok = pcall(deps.network.StartMatch.Fire)
            if ok then
                setStatus(confirmed.name .. ": Start sent; waiting for teleport")
            else
                self.confirmed = nil
                setStatus(confirmed.name .. ": Start request failed")
            end
            return
        end
        if Settings.get().paused then
            return
        end
        if self.pending then
            if now - self.pending.started >= ACK_TIMEOUT_SECONDS then
                self.pending = nil
                setStatus("No server confirmation; retry delayed")
            else
                return
            end
        end
        if
            not deps.lobby
            or deps.game.PlaceId ~= LOBBY_PLACE_ID
            or deps.lobby.IsHosting
            or deps.lobby.IsInLobby
        then
            return
        end
        local cooldownActive = now - self.lastAttempt < math.max(Settings.get().cooldown, RETRY_SECONDS)
        for _, name in Settings.get().priority do
            local mode = MODES[name]
            local choice = self.selection[name]
            -- Rift polling bypasses the general cooldown (it holds on full rooms at 1-2s intervals)
            if name == "Rift" and self.enabled[name] and deps.specialEvents and deps.riftsData then
                local currentHour = math.floor(now / 3600)
                if self.lastCompletedRiftHour == currentHour then
                    -- Already completed this hour, fall through to next priority
                else
                    local ws: any = deps.game:GetService("Workspace")
                    local isRiftOpenAttr = nil
                    if ws and ws.GetAttribute then
                        local okAttr, attrVal = pcall(ws.GetAttribute, ws, "IsRiftOpen")
                        if okAttr then
                            isRiftOpenAttr = attrVal
                        end
                    end
                    local isOpen = if isRiftOpenAttr ~= nil
                        then (isRiftOpenAttr == true)
                        else (now % 3600 < 600)
                    if not isOpen then
                        -- Rift not open, fall through
                    else
                        local okAtt, attRes = pcall(function()
                            return deps.specialEvents[config.remoteNames.getRiftAttempts]
                                and deps.specialEvents[config.remoteNames.getRiftAttempts].Invoke()
                        end)
                        if
                            okAtt
                            and type(attRes) == "table"
                            and attRes.Ready
                            and (attRes.AttemptsRemaining or 0) <= 0
                        then
                            self.lastCompletedRiftHour = currentHour
                            -- No attempts remaining, fall through
                        elseif
                            okAtt
                            and type(attRes) == "table"
                            and attRes.Ready
                            and (attRes.AttemptsRemaining or 0) > 0
                        then
                            local rifts = if type(deps.riftsData.GetRifts) == "function"
                                then (deps.riftsData.GetRifts :: any)()
                                else nil
                            local targetGuid = nil
                            if type(rifts) == "table" then
                                for guid, room in pairs(rifts) do
                                    if
                                        type(room) == "table"
                                        and type(room.Players) == "table"
                                        and #room.Players < 6
                                    then
                                        targetGuid = guid
                                        break
                                    end
                                end
                            end
                            if targetGuid then
                                self.confirmed = {
                                    name = name,
                                    mode = "Rift",
                                    guid = targetGuid,
                                    confirmedAt = now,
                                    startSent = now,
                                }
                                self.lastAttempt = now
                                if
                                    deps.specialEvents[config.remoteNames.joinRift]
                                    and type(deps.specialEvents[config.remoteNames.joinRift].Fire)
                                        == "function"
                                then
                                    pcall(
                                        deps.specialEvents[config.remoteNames.joinRift].Fire,
                                        { RiftGUID = targetGuid }
                                    )
                                end
                                setStatus("Rift: joining open room...")
                                return
                            else
                                -- All rooms full (6/6) or none yet: hold and poll 1-2s throughout the 10m window! Do NOT fall through!
                                setStatus("Rift: all rooms full (6/6); waiting for open slot...")
                                return
                            end
                        end
                    end
                end
            end
            if cooldownActive then
                return
            end
            if
                name == "Boss Event"
                and self.enabled[name]
                and choice
                and deps.bossRotation
                and deps.bossNetwork
            then
                local okCurrent, current = pcall(deps.bossRotation.GetCurrentBossEvent)
                if
                    okCurrent
                    and current == choice.eventName
                    and type(deps.bossNetwork[config.remoteNames.bossEventStart]) == "table"
                then
                    self.pending = { name = name, mode = "BossEvent", stage = current, started = now }
                    self.lastAttempt = now
                    local ok = pcall(
                        deps.bossNetwork[config.remoteNames.bossEventStart].Fire,
                        { EventName = current, Difficulty = choice.difficulty }
                    )
                    if not ok then
                        self.pending = nil
                    end
                    setStatus(
                        if ok
                            then "Boss Event: waiting for server confirmation"
                            else "Boss Event: request failed"
                    )
                    return
                end
                setStatus("Boss Event: selected boss is not current")
            end
            if
                name == "Worldline"
                and self.enabled[name]
                and choice
                and deps.worldlines
                and deps.worldlineNetwork
            then
                local okList, all = pcall(deps.worldlines.GetAll)
                if okList and type(all) == "table" and type(all[choice.worldlineId]) == "table" then
                    local progressRemote = deps.worldlineNetwork[config.remoteNames.worldlineProgress]
                    local teleportRemote = deps.worldlineNetwork[config.remoteNames.worldlineTeleport]
                    if
                        progressRemote
                        and teleportRemote
                        and type(progressRemote.Invoke) == "function"
                        and type(teleportRemote.Fire) == "function"
                    then
                        local okProgress, progress = pcall(progressRemote.Invoke)
                        local completed = false
                        if
                            okProgress
                            and type(progress) == "table"
                            and type(progress.AltWorldlines) == "table"
                        then
                            for _, entry in progress.AltWorldlines do
                                if
                                    type(entry) == "table"
                                    and entry.WorldlineId == choice.worldlineId
                                    and entry.Completed == true
                                then
                                    completed = true
                                end
                            end
                        end
                        if completed then
                            setStatus("Worldline: selected worldline already completed")
                        elseif okProgress and type(progress) == "table" and progress.Ready == true then
                            self.lastAttempt = now
                            local ok = pcall(
                                teleportRemote.Fire,
                                { WorldlineId = choice.worldlineId, TraitsType = choice.traitsType }
                            )
                            self.worldlineRequest = { id = choice.worldlineId, at = now }
                            setStatus(
                                if ok then "Worldline: teleport request sent" else "Worldline: request failed"
                            )
                            return
                        else
                            setStatus("Worldline: selection or progress unavailable")
                        end
                    else
                        setStatus("Worldline: selection or progress unavailable")
                    end
                else
                    setStatus("Worldline: selection or progress unavailable")
                end
            end
            if
                name == "Boss Bounties"
                and self.enabled[name]
                and deps.network
                and deps.network.CreateMatch
            then
                local bounty = self.readBounty()
                if not bounty then
                    setStatus("Boss Bounties: today's bounty unavailable")
                elseif bounty.left <= 0 then
                    setStatus("Boss Bounties: none left today")
                elseif deps.progress and type(deps.progress.GetActData) == "function" then
                    local okProgress, unlocked =
                        pcall(deps.progress.GetActData, bounty.mode, bounty.stage, bounty.act)
                    if okProgress and unlocked ~= nil then
                        local difficulty = if choice and choice.difficulty == "Nightmare"
                            then "Nightmare"
                            else "Normal"
                        self.pending = {
                            name = name,
                            mode = bounty.mode,
                            stage = bounty.stage,
                            act = bounty.act,
                            started = now,
                        }
                        self.lastAttempt = now
                        local ok = pcall(deps.network.CreateMatch.Fire, {
                            Public = false,
                            StageType = bounty.mode,
                            Stage = bounty.stage,
                            Act = bounty.act,
                            Difficulty = difficulty,
                            FriendsOnly = true,
                        })
                        if not ok then
                            self.pending = nil
                            setStatus("Boss Bounties: request failed")
                        else
                            setStatus("Boss Bounties: waiting for server confirmation")
                        end
                        return
                    end
                    setStatus("Boss Bounties: stage/act locked or progress unavailable")
                end
            end
            if CHALLENGES[name] and self.enabled[name] and choice then
                local kind = CHALLENGES[name]
                local availability = ActivityState.challenge(deps.challengeAttempts, deps.challengeData, kind)
                if availability ~= "available" then
                    -- Missing or already-used game-recorded period data cannot authorize a join.
                else
                    local targetChallengeName = choice.challengeName or name
                    local rewardMap: { [string]: string } = (Settings.REGULAR_REWARD_MAP :: any) or {}
                    if
                        name == "Regular Challenge"
                        and choice.rewardChoice
                        and rewardMap[choice.rewardChoice]
                    then
                        targetChallengeName = rewardMap[choice.rewardChoice]
                    end
                    local found = true
                    if deps.challengeData and type(deps.challengeData.GetChallengesOfType) == "function" then
                        local okList, candidates = pcall(deps.challengeData.GetChallengesOfType, kind)
                        if okList and type(candidates) == "table" then
                            local anyFound = false
                            for _, candidate in candidates do
                                if type(candidate) == "table" and candidate.Name == targetChallengeName then
                                    anyFound = true
                                    break
                                end
                            end
                            found = anyFound
                        end
                    end
                    if
                        not found
                        or not deps.challengeStages
                        or type(deps.challengeStages.GetChallengeStage) ~= "function"
                    then
                        setStatus(name .. ": current challenge data unavailable")
                    else
                        local okStage, stage =
                            pcall(deps.challengeStages.GetChallengeStage, targetChallengeName)
                        if
                            okStage
                            and type(stage) == "table"
                            and type(stage.StageType) == "string"
                            and type(stage.Stage) == "string"
                            and type(stage.Act) == "string"
                        then
                            self.pending = {
                                name = name,
                                challengeName = targetChallengeName,
                                mode = stage.StageType,
                                stage = stage.Stage,
                                act = stage.Act,
                                started = now,
                            }
                            self.lastAttempt = now
                            if
                                not deps.challengeNetwork
                                or not deps.challengeNetwork.StartChallenge
                                or type(deps.challengeNetwork.StartChallenge.Fire) ~= "function"
                            then
                                self.pending = nil
                                setStatus(name .. ": challenge network unavailable")
                            else
                                local ok = pcall(
                                    deps.challengeNetwork.StartChallenge.Fire,
                                    { Name = targetChallengeName }
                                )
                                if not ok then
                                    self.pending = nil
                                    setStatus(name .. ": request failed")
                                else
                                    setStatus(name .. ": waiting for server confirmation")
                                end
                            end
                            return
                        end
                        setStatus(name .. ": current challenge data unavailable")
                    end
                end
            end
            if
                mode
                and self.enabled[name]
                and choice
                and deps.progress
                and type(deps.progress.GetActData) == "function"
            then
                local okProgress, unlocked = pcall(deps.progress.GetActData, mode, choice.stage, choice.act)
                if okProgress and unlocked ~= nil then
                    local pending = {
                        name = name,
                        mode = mode,
                        stage = choice.stage,
                        act = choice.act,
                        started = now,
                    }
                    self.pending = pending
                    self.lastAttempt = now
                    local ok = pcall(deps.network.CreateMatch.Fire, {
                        Public = false,
                        StageType = mode,
                        Stage = choice.stage,
                        Act = choice.act,
                        Difficulty = choice.difficulty,
                        FriendsOnly = true,
                    })
                    if not ok then
                        self.pending = nil
                        setStatus(name .. ": request failed")
                    else
                        setStatus(name .. ": waiting for server confirmation")
                    end
                    return
                end
                setStatus(name .. ": stage/act locked or progress unavailable")
            end
        end
    end

    function self.start(context: any)
        if self.context then
            return
        end
        self.context = context
        pcall(function()
            Settings.init(getfenv())
        end)
        local saved = Settings.get()
        self.enabled = table.clone(saved.enabled)
        self.selection = table.clone(saved.selection)
        local function bindMatchConfirmed(deps: any)
            if self.disconnect then
                pcall(function()
                    (self.disconnect :: any)()
                end)
                self.disconnect = nil
            end
            if
                deps.network
                and deps.network.MatchConfirmed
                and type(deps.network.MatchConfirmed.On) == "function"
            then
                self.disconnect = (deps.network.MatchConfirmed.On :: any)(function(payload: any)
                    local pending = self.pending
                    if
                        pending
                        and context.alive
                        and type(payload) == "table"
                        and payload.StageType == pending.mode
                        and payload.Stage == pending.stage
                        and (pending.act == nil or payload.Act == pending.act)
                        and (not pending.challengeName or payload.ChallengeType == pending.challengeName or payload.Name == pending.challengeName or payload.Challenge == pending.challengeName)
                        and (payload.HostUserId == deps.userId or tonumber(payload.HostUserId) == deps.userId)
                        and type(payload.GUID) == "string"
                        and #payload.GUID > 0
                    then
                        self.pending = nil
                        pending.confirmedAt = deps.clock()
                        self.confirmed = pending
                        setStatus(pending.name .. ": confirmed by server")
                    end
                end)
            end
            if self.teleportConnection then
                pcall(function()
                    self.teleportConnection:Disconnect()
                end)
                self.teleportConnection = nil
            end
            local localPlayer = deps.localPlayer
            if localPlayer and localPlayer.OnTeleport then
                local env: any = getfenv()
                local teleportEnum = env.Enum and env.Enum.TeleportState and env.Enum.TeleportState.Started
                self.teleportConnection = localPlayer.OnTeleport:Connect(function(state: any)
                    if
                        self.confirmed
                        and (
                            (teleportEnum ~= nil and state == teleportEnum)
                            or tostring(state):find("Started") ~= nil
                        )
                    then
                        setStatus(self.confirmed.name .. ": teleport started")
                    end
                end)
            end
            if deps.game.PlaceId ~= LOBBY_PLACE_ID then
                local ghMod = deps.gameHandler
                if ghMod and ghMod.MatchEnded and type(ghMod.MatchEnded.Connect) == "function" then
                    self.matchEndConnection = (ghMod.MatchEnded.Connect :: any)(ghMod.MatchEnded, function()
                        if self.returnOnMatchEnd then
                            if self.gameSettings and type(self.gameSettings.set) == "function" then
                                pcall(self.gameSettings.set :: any, "AutoReplay", false)
                                pcall(self.gameSettings.set :: any, "AutoNext", false)
                            end
                            setStatus("Match ended; waiting 2.5s for rewards...")
                            local taskApi = (
                                if self.dependencies and self.dependencies.task
                                    then self.dependencies.task
                                    else nil
                            )
                                or (getfenv() :: any).task
                            if
                                taskApi
                                and type(taskApi.spawn) == "function"
                                and type(taskApi.wait) == "function"
                            then
                                (taskApi :: any).spawn(function()
                                    (taskApi :: any).wait(2.5)
                                    self.returnAttempts = 1
                                    self.teleportingToLobby = deps.clock()
                                    setStatus(
                                        if requestLobbyReturn(deps)
                                            then "Match ended: lobby return requested"
                                            else "Match ended: lobby return request failed"
                                    )
                                end)
                            end
                        end
                    end)
                end
            end
        end

        local function ensureDeps(): boolean
            if self.dependencies then
                return true
            end
            local ok, result = pcall(liveDependencies)
            if ok and result then
                if result.game.PlaceId == LOBBY_PLACE_ID then
                    if result.network and result.lobby then
                        self.dependencies = result
                        bindMatchConfirmed(result)
                        return true
                    end
                else
                    self.dependencies = result
                    bindMatchConfirmed(result)
                    return true
                end
            end
            return false
        end

        if self.dependencies then
            bindMatchConfirmed(self.dependencies)
        elseif not ensureDeps() then
            setStatus("Awaiting lobby matchmaking...")
        end

        local taskApi = (if self.dependencies and self.dependencies.task then self.dependencies.task else nil)
            or (getfenv() :: any).task
        if
            type(taskApi) ~= "table"
            or type(taskApi.spawn) ~= "function"
            or type(taskApi.wait) ~= "function"
        then
            setStatus("Task scheduler unavailable")
            return
        end
        (taskApi :: any).spawn(function()
            while context.alive and self.context == context do
                if not self.dependencies then
                    if ensureDeps() then
                        setStatus("Idle")
                    end
                end
                if self.dependencies then
                    self.step(self.dependencies.clock())
                end
                (taskApi :: any).wait(POLL_SECONDS)
            end
        end)
    end

    function self.stop()
        if self.disconnect then
            pcall(function()
                (self.disconnect :: any)()
            end)
            self.disconnect = nil
        end
        if self.teleportConnection then
            pcall(function()
                self.teleportConnection:Disconnect()
            end)
            self.teleportConnection = nil
        end
        if self.matchEndConnection then
            pcall(function()
                self.matchEndConnection:Disconnect()
            end)
            self.matchEndConnection = nil
        end
        if not dependencies then
            self.dependencies = nil
        end
        self.context = nil
        self.pending = nil
        self.confirmed = nil
        self.onStatus = nil
        self.teleportingToLobby = nil
        self.returnOnMatchEnd = false
    end
    return self
end

return Runtime
