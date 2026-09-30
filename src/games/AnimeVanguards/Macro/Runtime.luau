--!strict
--[[
Purpose: Own macro recording, persistence, match lifecycle, start vote and bounded playback
Input: Validated document, executor store, game adapter and context
Output: Synchronized mode/status callbacks and confirmed actions
Dependencies: Document; Adapter
]]
local Document = require("./Document")
local Adapter = require("./Adapter")
local Runtime = {}
local POLL_SECONDS = 0.2
local ACTION_TIMEOUT = 12
local REQUEST_GAP = 0.35
local RESTART_TIMEOUT = 30
local PLACEMENT_OFFSETS = {
    { 0, 0 },
    { 1, 0 },
    { 0, 1 },
    { -1, 0 },
    { 0, -1 },
    { 1, 1 },
    { -1, 1 },
    { -1, -1 },
    { 1, -1 },
    { 2, 0 },
}
local function finitePrice(value: any): boolean
    return type(value) == "number" and value >= 0 and value < math.huge and value == value
end
local function placementAttempt(action: any, number: number): any
    local offset: any = PLACEMENT_OFFSETS[number] or PLACEMENT_OFFSETS[#PLACEMENT_OFFSETS]
    local attempt = table.clone(action)
    attempt.cframe = table.clone(action.cframe)
    attempt.cframe[1] += offset[1]
    attempt.cframe[3] += offset[2]
    return attempt
end
local function clearConnections(connections: { any })
    for _, connection in connections do
        pcall(function()
            if type(connection) == "function" then
                (connection :: any)()
            else
                connection:Disconnect()
            end
        end)
    end
    table.clear(connections)
end
--- Creates a stopped controller; adapter/store injection supports isolated tests.
function Runtime.new(injectedAdapter: any?, injectedStorage: any?, injectedTask: any?): any
    local self: any = {
        adapter = injectedAdapter,
        storage = injectedStorage,
        context = nil,
        mode = "idle",
        status = "Idle",
        onStatus = nil,
        onMode = nil,
        onSaved = nil,
        document = nil,
        settings = {
            ignoreTiming = true,
            noIgnoreSellTiming = true,
            retryLimit = 3,
            placementFailure = "Stop",
        },
        lifecycleConnections = {},
        recordConnections = {},
        refs = {},
        levels = {},
        attackPriorities = {},
        autoStates = {},
        generation = 0,
        startVoteSent = false,
        pendingRestart = nil,
        activeDocument = nil,
        suspended = false,
        autoPlay = nil,
        modeListeners = {},
    }
    local function status(value: string)
        if self.status == value then
            return
        end
        self.status = value
        if self.onStatus then
            pcall(self.onStatus, value)
        end
    end
    local function mode(value: string)
        self.mode = value
        if self.onMode then
            pcall(self.onMode, value)
        end
        for _, cb in self.modeListeners do
            pcall(cb, value)
        end
    end
    local function emptyFor(name: string): any
        local document = Document.empty(name)
        local previous = self.document
        if previous and previous.match then
            document.match = { mode = previous.match.mode, map = previous.match.map }
        end
        return document
    end
    local function append(kind: string, fields: any)
        if self.mode ~= "record" or not self.document then
            return
        end
        local state = self.adapter.state() or (self.adapter.preMatchState and self.adapter.preMatchState())
        if not state then
            if kind == "voteStart" then
                state = { wave = 0, yen = 0 }
            else
                return
            end
        end
        if kind ~= "voteStart" and self.recordBeforeMatch then
            self.recordStarted = os.clock()
            self.recordBeforeMatch = false
        end
        if #self.document.actions >= 2000 then
            status("Recording limit reached")
            self.finishRecord()
            return
        end
        local action: any = {
            index = #self.document.actions + 1,
            kind = kind,
            wave = state.wave or 0,
            yen = state.yen or 0,
            time = math.max(0, os.clock() - self.recordStarted),
        }
        for key, value in fields do
            action[key] = value
        end
        table.insert(self.document.actions, action)
        if kind == "place" and not table.find(self.document.units, action.unitName) then
            table.insert(self.document.units, action.unitName)
        end
        status("Recording: " .. #self.document.actions .. " actions")
    end
    local function voteForStart(prompt: any)
        if
            self.mode ~= "play"
            or self.startVoteSent
            or type(prompt) ~= "table"
            or prompt.Context ~= "Start"
        then
            return
        end
        if self.adapter.matchStarted and self.adapter.matchStarted() then
            return
        end
        self.startVoteSent = true
        if self.adapter.castStartVote and self.adapter.castStartVote() then
            status("Vote to Start sent; awaiting match")
        else
            status("Vote to Start failed")
        end
    end
    function self.setStorage(storage: any)
        self.storage = storage
    end
    function self.setAutoPlay(ap: any)
        self.autoPlay = ap
    end
    function self.onModeChange(callback: (string) -> ())
        if type(callback) == "function" then
            table.insert(self.modeListeners, callback)
        end
    end
    local function hookLifecycle()
        if not self.adapter or #self.lifecycleConnections > 0 then
            return
        end
        local function own(kind: string, callback: (any) -> ())
            local connection = self.adapter.observe(kind, callback)
            if connection then
                table.insert(self.lifecycleConnections, connection)
            end
        end
        own("restart", function()
            if self.mode == "play" then
                self.playbackActive = false
                local replay = self.activeDocument or self.pendingRestart
                self.pendingRestart = nil
                self.generation += 1
                if replay then
                    status("Match restarted; replaying macro")
                    self.play(replay)
                else
                    status("Match restarted; awaiting match")
                end
                return
            end
            if self.mode ~= "record" or not self.storage then
                return
            end
            local fresh = emptyFor(self.document.name)
            local ok, err = self.storage.write(fresh.name, fresh, true)
            if not ok then
                clearConnections(self.recordConnections)
                mode("idle")
                status("Restart reset failed: " .. tostring(err))
                return
            end
            self.document = fresh
            self.refs = {}
            self.levels = {}
            self.attackPriorities = {}
            self.autoStates = {}
            self.recordStarted = os.clock()
            self.recordBeforeMatch = self.adapter.state() == nil
            status("Recording restarted: 0 actions")
        end)
        own("result", function(result: any)
            if self.mode ~= "record" then
                return
            end
            if result == "Finished" then
                self.finishRecord()
            elseif result == "Failed" then
                self.document = nil
                clearConnections(self.recordConnections)
                mode("idle")
                status("Defeat: recording discarded")
            end
        end)
        own("matchEnd", function()
            if self.mode == "play" then
                self.playbackActive = false
                local autoReplay = self.adapter
                    and self.adapter.getGameSetting
                    and self.adapter.getGameSetting("AutoReplay") == true
                local autoNext = self.adapter
                    and self.adapter.getGameSetting
                    and self.adapter.getGameSetting("AutoNext") == true
                if autoReplay or autoNext then
                    status("Victory! Awaiting next match / replay...")
                else
                    status("Match ended; holding on victory screen")
                end
            end
        end)
        own("matchStart", function()
            if self.mode == "play" and self.activeDocument and not self.playbackActive then
                self.startVoteSent = false
                self.play(self.activeDocument)
            end
        end)
        own("votePrompt", voteForStart)
    end
    local function ensureAdapter(): boolean
        if self.adapter then
            return true
        end
        local ok, adapter = pcall(Adapter.new)
        if ok and adapter then
            self.adapter = adapter
            hookLifecycle()
            return true
        end
        return false
    end
    function self.start(context: any)
        self.context = context
        if injectedAdapter then
            self.adapter = injectedAdapter
            hookLifecycle()
        else
            if ensureAdapter() then
                status("Idle")
            else
                status("Awaiting match...")
            end
        end
    end
    function self.stop()
        self.generation += 1
        self.pendingRestart = nil
        self.activeDocument = nil
        self.playbackActive = false
        clearConnections(self.recordConnections)
        clearConnections(self.lifecycleConnections)
        mode("idle")
        if self.adapter and self.adapter.close then
            (self.adapter.close :: any)()
        end
        if not injectedAdapter then
            self.adapter = nil
        end
        self.context = nil
        status("Stopped")
    end
    function self.record(name: string): (boolean, string?)
        if not self.context or not self.context.alive or not self.storage then
            return false, "MACRO_ADAPTER_UNAVAILABLE"
        end
        if not ensureAdapter() then
            return false, "MACRO_ADAPTER_UNAVAILABLE"
        end
        if self.mode ~= "idle" then
            return false, "MACRO_BUSY"
        end
        local liveState = self.adapter.state()
        local state = liveState or (self.adapter.preMatchState and self.adapter.preMatchState())
        if not state then
            return false, "MACRO_MATCH_UNAVAILABLE"
        end
        local fresh = Document.empty(name)
        fresh.match = { mode = state.match and state.match.mode }
        local wrote, err = self.storage.write(name, fresh, true)
        if not wrote then
            return false, err
        end
        self.document = fresh
        self.refs = {}
        self.levels = {}
        self.attackPriorities = {}
        self.autoStates = {}
        self.recordStarted = os.clock()
        self.recordBeforeMatch = liveState == nil
        local function own(kind: string, callback: (any) -> ())
            local connection = self.adapter.observe(kind, callback)
            if connection then
                table.insert(self.recordConnections, connection)
            end
        end
        own("place", function(event: any)
            if self.mode ~= "record" or not event or not event.guid or not event.unitName then
                return
            end
            local cframe = Document.fromPose(event.position, event.rotation or 0)
            if not cframe then
                return
            end
            local ref = tostring(#self.document.actions + 1)
            self.refs[event.guid] = ref
            self.levels[event.guid] = tonumber(event.level) or 0
            self.attackPriorities[event.guid] = event.priorityName
            self.autoStates[event.guid] = {
                autoUpgrade = false,
                upgradePriority = nil,
                autoAbilities = {},
            }
            if type(event.autoAbilities) == "table" then
                for _, abilityName in event.autoAbilities do
                    if type(abilityName) == "string" then
                        self.autoStates[event.guid].autoAbilities[abilityName] = true
                    end
                end
            end
            append("place", {
                unitRef = ref,
                unitName = event.unitName,
                cframe = cframe,
                slotIndex = event.slotIndex,
                initialLevel = self.levels[event.guid],
            })
        end)
        own("voteClicked", function(event: any)
            if
                self.mode == "record" and (event == nil or event.Context == "Start" or event.Context == nil)
            then
                for _, action in self.document.actions do
                    if action.kind == "voteStart" then
                        return
                    end
                end
                append("voteStart", {})
            end
        end)
        for _, kind in
            {
                "upgrade",
                "sell",
                "priority",
                "ability",
                "autoUpgrade",
                "autoAbility",
                "upgradePriority",
            }
        do
            own(kind, function(event: any)
                if self.mode ~= "record" or not event or not event.guid then
                    return
                end
                local ref = self.refs[event.guid]
                if not ref then
                    return
                end
                local autoState = self.autoStates[event.guid]
                if kind == "autoUpgrade" then
                    if
                        not autoState
                        or type(event.enabled) ~= "boolean"
                        or autoState.autoUpgrade == event.enabled
                    then
                        return
                    end
                    autoState.autoUpgrade = event.enabled
                    if not event.enabled then
                        autoState.upgradePriority = nil
                    end
                elseif kind == "upgradePriority" then
                    local priority = event.upgradePriority
                    if
                        not autoState
                        or type(priority) ~= "number"
                        or priority % 1 ~= 0
                        or priority < 1
                        or priority > 6
                        or autoState.upgradePriority == priority
                    then
                        return
                    end
                    autoState.upgradePriority = priority
                elseif kind == "autoAbility" then
                    if
                        not autoState
                        or type(event.abilityName) ~= "string"
                        or type(event.enabled) ~= "boolean"
                        or (autoState.autoAbilities[event.abilityName] == true) == event.enabled
                    then
                        return
                    end
                    autoState.autoAbilities[event.abilityName] = event.enabled
                    if event.enabled == true then
                        local previous = self.document.actions[#self.document.actions]
                        if
                            previous
                            and previous.kind == "ability"
                            and previous.unitRef == ref
                            and previous.abilityName == event.abilityName
                            and math.abs((os.clock() - self.recordStarted) - previous.time) <= 0.5
                        then
                            table.remove(self.document.actions)
                        end
                    end
                elseif kind == "priority" then
                    if
                        type(event.priorityName) ~= "string"
                        or self.attackPriorities[event.guid] == event.priorityName
                    then
                        return
                    end
                    self.attackPriorities[event.guid] = event.priorityName
                end
                if kind == "ability" then
                    if autoState and autoState.autoAbilities[event.abilityName] == true then
                        -- Native Auto Ability uses automatic server-side activations; do not duplicate them as manual steps.
                        return
                    end
                end
                if kind == "upgrade" then
                    local level = tonumber(event.level)
                    if not level or level <= (self.levels[event.guid] or 0) then
                        return
                    end
                    local previous = self.document.actions[#self.document.actions]
                    local live = self.adapter.state()
                    if
                        previous
                        and previous.kind == "place"
                        and previous.unitRef == ref
                        and live
                        and previous.yen == live.yen
                        and os.clock() - self.recordStarted - previous.time <= 0.1
                    then
                        self.levels[event.guid] = level
                        return
                    end
                    self.levels[event.guid] = level
                    if autoState and autoState.autoUpgrade then
                        -- Native Auto Upgrade uses server-side purchases; do not duplicate them as manual steps.
                        return
                    end
                end
                local fields: any = { unitRef = ref }
                if kind == "upgrade" then
                    fields.level = self.levels[event.guid]
                end
                if kind == "priority" then
                    fields.priorityName = event.priorityName
                end
                if kind == "ability" then
                    fields.abilityName = event.abilityName
                end
                if kind == "autoUpgrade" or kind == "autoAbility" then
                    fields.enabled = event.enabled
                end
                if kind == "autoAbility" then
                    fields.abilityName = event.abilityName
                end
                if kind == "upgradePriority" then
                    fields.upgradePriority = event.upgradePriority
                end
                append(kind, fields)
            end)
        end
        mode("record")
        status("Recording: 0 actions")
        return true, nil
    end
    function self.finishRecord(): any?
        if self.mode ~= "record" or not self.document or not self.storage then
            return nil
        end
        local canonical, validationError = Document.validate(self.document)
        if not canonical then
            clearConnections(self.recordConnections)
            mode("idle")
            status("Save failed: " .. tostring(validationError))
            return nil
        end
        local ok, err = self.storage.write(canonical.name, canonical, true)
        if not ok then
            clearConnections(self.recordConnections)
            mode("idle")
            status("Save failed: " .. tostring(err))
            return nil
        end
        self.document = canonical
        clearConnections(self.recordConnections)
        mode("idle")
        status("Saved " .. canonical.name .. " (" .. #canonical.actions .. " actions)")
        if self.onSaved then
            pcall(self.onSaved, canonical.name)
        end
        return canonical
    end
    function self.play(document: any): (boolean, string?)
        local checked, err = Document.validate(document)
        if not checked then
            return false, err
        end
        if not self.context or not self.context.alive then
            return false, "MACRO_ADAPTER_UNAVAILABLE"
        end
        if self.mode ~= "idle" and self.mode ~= "play" then
            return false, "MACRO_BUSY"
        end
        if
            self.autoPlay
            and type((self.autoPlay :: any).isEnabled) == "function"
            and (self.autoPlay :: any).isEnabled()
        then
            return false, "AUTOPLAY_ACTIVE"
        end
        self.activeDocument = checked
        self.suspended = false
        self.generation += 1
        local generation = self.generation
        self.pendingRestart = nil
        self.startVoteSent = false
        mode("play")
        status("Waiting for match / Vote to Start")
        if self.adapter and type((self.adapter :: any).currentStartPrompt) == "function" then
            voteForStart((self.adapter :: any).currentStartPrompt())
        end
        local taskApi: any = injectedTask or (getfenv() :: any).task
        local function active(): boolean
            return self.mode == "play"
                and generation == self.generation
                and self.context ~= nil
                and self.context.alive == true
        end
        local function waitSuspended(): boolean
            while active() and self.suspended do
                taskApi.wait(POLL_SECONDS)
            end
            return active()
        end
        local function waitReady(action: any, index: number, started: number, refs: any): any?
            local priceFails = 0
            local maxPriceFails = if injectedTask then 1 else 15
            while active() do
                if not waitSuspended() then
                    return nil
                end
                local ad = self.adapter
                local state: any = if ad and ad.state then (ad.state :: any)() else nil
                if not state then
                    if ad and ad.matchStarted and not (ad.matchStarted :: any)() then
                        local autoReplay = ad.getGameSetting
                            and (ad.getGameSetting :: any)("AutoReplay") == true
                        local autoNext = ad.getGameSetting and (ad.getGameSetting :: any)("AutoNext") == true
                        if autoReplay or autoNext then
                            status("Match ended; awaiting Auto Next / Auto Replay")
                        else
                            status("Match ended; holding on victory screen")
                        end
                    end
                    return nil
                end
                local satisfied = ad and ad.satisfied and (ad.satisfied :: any)(action, refs) == true
                local price = 0
                if not satisfied and (action.kind == "place" or action.kind == "upgrade") then
                    price = if ad and ad.cost then (ad.cost :: any)(action, refs) else nil
                    if not finitePrice(price) then
                        priceFails += 1
                        if priceFails >= maxPriceFails then
                            if injectedTask then
                                mode("idle")
                            end
                            status("Live price unavailable at step " .. index .. ": " .. action.kind)
                            return nil
                        end
                        status("Waiting for live price at step " .. index .. ": " .. action.kind)
                        taskApi.wait(POLL_SECONDS)
                        continue
                    else
                        priceFails = 0
                    end
                end
                local needsTime = action.kind == "ability"
                    or (action.kind == "sell" and self.settings.noIgnoreSellTiming)
                    or not self.settings.ignoreTiming
                local elapsed = os.clock() - started
                local requiredTime = if needsTime then action.time else 0
                if state.wave >= action.wave and elapsed >= requiredTime and state.yen >= price then
                    return state
                end
                status(
                    "Waiting "
                        .. index
                        .. "/"
                        .. #checked.actions
                        .. ": wave "
                        .. tostring(state.wave)
                        .. "/"
                        .. tostring(action.wave)
                        .. ", time "
                        .. tostring(math.floor(elapsed))
                        .. "/"
                        .. tostring(requiredTime)
                        .. ", yen "
                        .. tostring(state.yen)
                        .. "/"
                        .. tostring(price)
                )
                taskApi.wait(POLL_SECONDS)
            end
            return nil
        end
        local function exhaustedPlacement(action: any, index: number, refs: any): boolean
            local policy = self.settings.placementFailure
            local ad: any = self.adapter
            if policy == "None" then
                refs[action.unitRef] = false
                status("Skipped placement " .. index .. "; dependent steps will be skipped")
                return true
            end
            if policy == "Restart" then
                self.pendingRestart = checked
                local castRestart = ad and ad.castRestartVote
                if not castRestart or not (castRestart :: any)() then
                    self.pendingRestart = nil
                    mode("idle")
                    status("Restart vote unavailable after placement " .. index)
                    return false
                end
                status("Restart vote sent; awaiting MatchRestarted")
                local function timeout()
                    if active() and self.pendingRestart == checked then
                        self.pendingRestart = nil
                        status("Restart was not confirmed")
                    end
                end
                if taskApi.delay then
                    (taskApi.delay :: any)(RESTART_TIMEOUT, timeout)
                else
                    taskApi.spawn(function()
                        taskApi.wait(RESTART_TIMEOUT)
                        timeout()
                    end)
                end
                return false
            end
            if policy == "Return to Lobby" then
                local returnLobby = ad and ad.returnToLobby
                local sent = returnLobby and (returnLobby :: any)()
                mode("idle")
                status(if sent then "Return to Lobby requested" else "Return to Lobby request failed")
                return false
            end
            mode("idle")
            status("Placement " .. index .. " failed after retry limit")
            return false
        end
        taskApi.spawn(function()
            while active() and not ensureAdapter() do
                taskApi.wait(POLL_SECONDS)
            end
            if not active() then
                return
            end

            if self.adapter and type((self.adapter :: any).currentStartPrompt) == "function" then
                voteForStart((self.adapter :: any).currentStartPrompt())
            end

            while active() and not (self.adapter :: any).state() do
                if
                    not self.startVoteSent
                    and self.adapter
                    and type((self.adapter :: any).currentStartPrompt) == "function"
                then
                    local prompt = (self.adapter :: any).currentStartPrompt()
                    if prompt then
                        voteForStart(prompt)
                    end
                end
                taskApi.wait(POLL_SECONDS)
            end
            if not active() then
                return
            end
            self.playbackActive = true
            local started = os.clock()
            local refs: any = {}
            for index = 1, #checked.actions do
                if not waitSuspended() then
                    self.playbackActive = false
                    return
                end
                local action = checked.actions[index]
                status("Playing " .. index .. "/" .. #checked.actions .. ": " .. action.kind)
                if action.kind == "voteStart" then
                    if
                        not self.startVoteSent
                        and self.adapter
                        and type((self.adapter :: any).currentStartPrompt) == "function"
                    then
                        voteForStart((self.adapter :: any).currentStartPrompt())
                    end
                    continue
                end
                if
                    action.kind ~= "place" and (refs[action.unitRef] == false or refs[action.unitRef] == nil)
                then
                    status("Skipped dependent step " .. index .. ": " .. tostring(action.unitRef))
                    continue
                end
                if action.kind == "ability" then
                    local nextAction = checked.actions[index + 1]
                    local isAutoCompanion = nextAction
                        and nextAction.kind == "autoAbility"
                        and nextAction.unitRef == action.unitRef
                        and nextAction.abilityName == action.abilityName
                        and nextAction.enabled == true
                        and nextAction.wave == action.wave
                        and math.abs(nextAction.time - action.time) <= 1.0
                    local state = if self.adapter and type((self.adapter :: any).state) == "function"
                        then (self.adapter :: any).state()
                        else nil
                    local guid = refs[action.unitRef]
                    local unit = state and guid and state.units[guid]
                    local isAlreadyAuto = unit
                        and type(unit.autoAbilities) == "table"
                        and table.find(unit.autoAbilities, action.abilityName) ~= nil
                    if isAutoCompanion or isAlreadyAuto then
                        status("Skipped redundant ability " .. index .. ": native auto-ability active")
                        continue
                    end
                end
                if action.kind == "upgrade" then
                    while active() do
                        if
                            self.adapter
                            and type((self.adapter :: any).satisfied) == "function"
                            and (self.adapter :: any).satisfied(action, refs)
                        then
                            break
                        end
                        local state = if self.adapter
                                and type((self.adapter :: any).state) == "function"
                            then (self.adapter :: any).state()
                            else nil
                        local guid = refs[action.unitRef]
                        local unit = state and guid and state.units[guid]
                        if not unit or not unit.autoUpgrade then
                            break
                        end
                        status(
                            "Waiting "
                                .. index
                                .. "/"
                                .. #checked.actions
                                .. ": native auto-upgrade level "
                                .. tostring(unit.level)
                                .. "/"
                                .. tostring(action.level)
                        )
                        taskApi.wait(POLL_SECONDS)
                    end
                end
                if not active() then
                    return
                end
                local limit = math.clamp(math.floor(tonumber(self.settings.retryLimit) or 3), 1, 10)
                if action.kind == "upgradePriority" then
                    -- The game's request advances one priority at a time; all six states plus retries may be needed.
                    limit = math.max(limit, 8)
                end
                local firstBefore: any = nil
                local attempted: { any } = {}
                local completed = false
                local function confirmPlacement(): (boolean, string?)
                    if not firstBefore or not self.adapter then
                        return false, nil
                    end
                    for _, candidate in attempted do
                        local confirmed, guid = (self.adapter :: any).confirm(candidate, firstBefore, refs)
                        if confirmed then
                            return true, guid
                        end
                    end
                    return false, nil
                end
                for attemptNumber = 1, limit do
                    local before = waitReady(action, index, started, refs)
                    if not before or not active() then
                        return
                    end
                    if
                        self.adapter
                        and type((self.adapter :: any).satisfied) == "function"
                        and (self.adapter :: any).satisfied(action, refs)
                    then
                        completed = true
                        break
                    end
                    if action.kind == "place" then
                        local confirmed, guid = confirmPlacement()
                        if confirmed then
                            refs[action.unitRef] = guid
                            completed = true
                            break
                        end
                    end
                    local candidate = if action.kind == "place"
                        then placementAttempt(action, attemptNumber)
                        else action
                    firstBefore = firstBefore or before
                    local sent = self.adapter
                        and type((self.adapter :: any).request) == "function"
                        and (self.adapter :: any).request(candidate, refs) == true
                    if sent and action.kind == "place" then
                        table.insert(attempted, candidate)
                    end
                    if sent then
                        status(
                            "Waiting for game confirmation: step "
                                .. index
                                .. ", attempt "
                                .. attemptNumber
                                .. "/"
                                .. limit
                        )
                        local deadline = os.clock()
                            + (
                                if injectedTask and injectedTask.actionTimeout ~= nil
                                    then injectedTask.actionTimeout
                                    else ACTION_TIMEOUT
                            )
                        repeat
                            taskApi.wait(POLL_SECONDS)
                            if not active() then
                                return
                            end
                            local confirmed, guid
                            if action.kind == "place" then
                                confirmed, guid = confirmPlacement()
                            else
                                confirmed, guid =
                                    if self.adapter
                                            and type((self.adapter :: any).confirm) == "function"
                                        then (self.adapter :: any).confirm(action, before, refs)
                                        else false,
                                    nil
                            end
                            if confirmed then
                                if action.kind == "place" then
                                    refs[action.unitRef] = guid
                                end
                                completed = true
                                break
                            end
                        until os.clock() >= deadline
                    end
                    if completed then
                        break
                    end
                    taskApi.wait(REQUEST_GAP)
                    if not active() then
                        return
                    end
                    if action.kind == "place" then
                        local confirmed, guid = confirmPlacement()
                        if confirmed then
                            refs[action.unitRef] = guid
                            completed = true
                            break
                        end
                    end
                end
                if not completed then
                    if action.kind == "ability" then
                        status(
                            "Ability "
                                .. index
                                .. " ("
                                .. tostring(action.abilityName)
                                .. ") not confirmed; continuing"
                        )
                    elseif action.kind ~= "place" then
                        if injectedTask then
                            mode("idle")
                        end
                        status("Step " .. index .. " not confirmed after retry limit")
                        return
                    elseif not exhaustedPlacement(action, index, refs) then
                        return
                    end
                end
                if completed and action.kind == "sell" then
                    refs[action.unitRef] = false
                end
                taskApi.wait(REQUEST_GAP)
            end
            self.playbackActive = false
            if active() then
                local ad = self.adapter
                local autoReplay = ad
                    and ad.getGameSetting
                    and (ad.getGameSetting :: any)("AutoReplay") == true
                local autoNext = ad and ad.getGameSetting and (ad.getGameSetting :: any)("AutoNext") == true
                if autoReplay or autoNext then
                    status("Actions completed; awaiting Auto Next / Auto Replay")
                else
                    status("Actions completed; holding on victory screen")
                end
            end
        end)
        return true, nil
    end
    function self.stopPlayback()
        if self.mode == "play" then
            self.generation += 1
            self.pendingRestart = nil
            self.activeDocument = nil
            self.suspended = false
            mode("idle")
            status("Playback stopped")
        end
    end
    function self.suspend()
        if self.mode == "play" then
            self.suspended = true
            status("Macro suspended (teleporting)")
        end
    end
    function self.resume()
        if self.mode == "play" then
            self.suspended = false
            status("Macro resumed")
        end
    end
    return self
end
return Runtime
