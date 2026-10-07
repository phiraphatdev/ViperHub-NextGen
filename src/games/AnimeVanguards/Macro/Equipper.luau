--!strict
--[[
Purpose: Put the units a recorded macro uses on the team, one at a time, in the macro's order
Input: A team adapter (equippedList, ownedUnitList, unequipAll, equipUnit, isReady), a macro document ({units}) and a
       clock; run() also takes the task scheduler
Output: A step() state machine ("working" | "done" | "failed") with a readable message and the missing unit names;
        run() drives it from a task and reports through callbacks
Dependencies: Joiner/MacroEquip (pure unit rules)
]]

local MacroEquip = require("../Joiner/MacroEquip")

local Equipper = {}

local UNEQUIP_WAIT_SECONDS = 3
local EQUIP_WAIT_SECONDS = 2.5
local READY_WAIT_SECONDS = 10
local MAX_TRIES = 3
local MAX_ROUNDS = 2
local POLL_SECONDS = 0.25

export type Result = { state: string, message: string, missing: { string } }

--- Creates an equipper. clock returns seconds (os.clock in the game).
function Equipper.new(adapter: any, clock: () -> number)
    local self: any = {
        state = "idle",
        message = "",
        missing = {} :: { string },
        busy = false,
    }
    local names: { string } = {}
    local phase = "check"
    local sentAt = -math.huge
    local tries = 0
    local round = 0
    local index = 1
    local expected: { string } = {}
    local expectedGuids: { string } = {}
    local startedAt = 0

    local function say(text: string)
        self.message = text
    end

    -- True when the team is exactly the units the player owns from the macro, in the macro's order.
    local function teamMatches(): boolean
        local equipped = adapter.equippedList()
        if #equipped ~= #expected then
            return false
        end
        for position, name in expected do
            if equipped[position].name ~= name then
                return false
            end
        end
        return true
    end

    local function plan()
        local owned = adapter.ownedUnitList()
        local result = MacroEquip.plan(names, {}, owned)
        self.missing = result.missing
        expectedGuids = result.steps
        expected = {}
        for _, guid in expectedGuids do
            for _, unit in owned do
                if unit.guid == guid then
                    table.insert(expected, unit.name)
                    break
                end
            end
        end
    end

    --- Compares the team with a macro without changing anything. Returns { matches, equipped, expected, missing,
    --- extra, summary }: expected = the macro's units the player owns, in macro order; extra = equipped units the
    --- macro does not use; missing = macro units the player does not own.
    function self.check(document: any): any
        local macroNames = MacroEquip.names(if type(document) == "table" then document.units else nil)
        local owned = adapter.ownedUnitList()
        local result = MacroEquip.plan(macroNames, {}, owned)
        local expectedNames: { string } = {}
        for _, guid in result.steps do
            for _, unitInfo in owned do
                if unitInfo.guid == guid then
                    table.insert(expectedNames, unitInfo.name)
                    break
                end
            end
        end
        local equippedNames: { string } = {}
        for _, unitInfo in adapter.equippedList() do
            table.insert(equippedNames, unitInfo.name)
        end
        local extra: { string } = {}
        for _, name in equippedNames do
            if not table.find(macroNames, name) then
                table.insert(extra, name)
            end
        end
        local absent: { string } = {}
        for _, name in expectedNames do
            if not table.find(equippedNames, name) then
                table.insert(absent, name)
            end
        end
        local sameOrder = #equippedNames == #expectedNames
        if sameOrder then
            for position, name in expectedNames do
                if equippedNames[position] ~= name then
                    sameOrder = false
                end
            end
        end
        local summary: string
        if #macroNames == 0 then
            summary = "The macro records no units"
        elseif sameOrder then
            summary = "Team matches the macro (" .. tostring(#expectedNames) .. " units, macro order)"
        elseif #absent == 0 and #extra == 0 then
            summary = "Same units, but not in the macro's order"
        else
            summary = "Team does not match the macro"
        end
        return {
            matches = #macroNames > 0 and sameOrder,
            equipped = equippedNames,
            expected = expectedNames,
            missing = result.missing,
            extra = extra,
            absent = absent,
            summary = summary,
        }
    end

    --- Starts equipping for a macro document; step() then does the work.
    function self.begin(document: any)
        names = MacroEquip.names(if type(document) == "table" then document.units else nil)
        self.state = "working"
        self.missing = {}
        phase = "ready"
        sentAt = -math.huge
        tries = 0
        round = 0
        index = 1
        startedAt = clock()
        say("Equip Macro: reading the macro's units")
    end

    local function fail(text: string)
        self.state = "failed"
        say(text)
    end

    local function finish()
        self.state = "done"
        if #self.missing > 0 then
            say("Team ready; not owned: " .. table.concat(self.missing, ", "))
        else
            say("Team ready: " .. table.concat(expected, ", "))
        end
    end

    --- One small action per call (a request, or waiting for its result); returns the state.
    function self.step(now: number): string
        if self.state ~= "working" then
            return self.state
        end
        if phase == "ready" then
            if not adapter.isReady() then
                if now - startedAt > READY_WAIT_SECONDS then
                    fail("Equip Macro: the game's unit data did not load")
                else
                    say("Equip Macro: waiting for the game's unit data")
                end
                return self.state
            end
            if #names == 0 then
                self.state = "done"
                say("The macro records no units")
                return self.state
            end
            plan()
            if #expected == 0 then
                fail("You own none of the macro's units: " .. table.concat(self.missing, ", "))
                return self.state
            end
            phase = "check"
        end
        if phase == "check" then
            plan()
            if teamMatches() then
                finish()
                return self.state
            end
            round += 1
            if round > MAX_ROUNDS then
                fail("Equip Macro: the team still does not match the macro")
                return self.state
            end
            tries = 0
            if #adapter.equippedList() == 0 then
                phase = "equip"
                index = 1
            else
                phase = "unequip"
            end
            sentAt = -math.huge
            return self.state
        end
        if phase == "unequip" then
            if #adapter.equippedList() == 0 then
                phase = "equip"
                index = 1
                tries = 0
                sentAt = -math.huge
                return self.state
            end
            if now - sentAt < UNEQUIP_WAIT_SECONDS then
                say("Equip Macro: taking the current team off")
                return self.state
            end
            if tries >= MAX_TRIES then
                fail("Equip Macro: could not take the current team off")
                return self.state
            end
            tries += 1
            sentAt = now
            if not adapter.unequipAll() then
                fail("Equip Macro: the unequip request is unavailable")
            else
                say("Equip Macro: taking the current team off")
            end
            return self.state
        end
        if phase == "equip" then
            if index > #expectedGuids then
                phase = "check"
                return self.state
            end
            local equipped = adapter.equippedList()
            local here = equipped[index]
            if here ~= nil and here.guid == expectedGuids[index] then
                index += 1
                tries = 0
                sentAt = -math.huge
                return self.state
            end
            local label = expected[index]
            if now - sentAt < EQUIP_WAIT_SECONDS then
                say(string.format("Equip Macro: putting %s on slot %d", label, index))
                return self.state
            end
            if tries >= MAX_TRIES then
                fail(string.format("Equip Macro: %s did not equip", label))
                return self.state
            end
            tries += 1
            sentAt = now
            if not adapter.equipUnit(expectedGuids[index]) then
                fail("Equip Macro: the equip request is unavailable")
            else
                say(string.format("Equip Macro: putting %s on slot %d", label, index))
            end
            return self.state
        end
        return self.state
    end

    --- Runs begin() and polls step() from a task until it is done or failed. Returns false while already running.
    --- onStatus(text) follows the message; onDone(success, message, missing) is called once at the end.
    function self.run(
        document: any,
        taskApi: any,
        onStatus: ((string) -> ())?,
        onDone: ((boolean, string, { string }) -> ())?
    ): boolean
        if self.busy then
            return false
        end
        if
            type(taskApi) ~= "table"
            or type(taskApi.spawn) ~= "function"
            or type(taskApi.wait) ~= "function"
        then
            return false
        end
        self.busy = true
        self.cancelled = false
        self.begin(document)
        local spawnFn: any = taskApi.spawn
        local waitFn: any = taskApi.wait
        spawnFn(function()
            local last = ""
            while self.state == "working" and not self.cancelled do
                self.step(clock())
                if onStatus and self.message ~= last then
                    last = self.message
                    pcall(onStatus :: any, self.message)
                end
                if self.state == "working" then
                    waitFn(POLL_SECONDS)
                end
            end
            self.busy = false
            if self.cancelled then
                self.state = "failed"
                say("Equip Macro: cancelled")
            end
            if onStatus then
                pcall(onStatus :: any, self.message)
            end
            if onDone then
                pcall(onDone :: any, self.state == "done", self.message, self.missing)
            end
        end)
        return true
    end

    --- Stops a running run() at its next poll.
    function self.cancel()
        self.cancelled = true
    end

    return self
end

return Equipper
