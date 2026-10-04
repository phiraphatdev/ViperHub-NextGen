--!strict
--[[
Purpose: Listen to a game network event without taking it away from the game. The game's generated network modules
         keep ONE listener per event (`On` stores the callback in a slot, replacing the previous one; observed in
         GameOdysseyClient: `u40.Reliable[39] = callback`), so a plain `On` from the hub silenced the game's own UI
         (shop and card windows) and the game's next `On` (a new run) silenced the hub.
Input: An event entry ({On = function}) and a handler
Output: A subscription {check, undo}: the handler runs after the game's own listener; check() re-attaches when the
        game replaced the slot; undo() restores the game's listener
Dependencies: None (uses the executor's debug.getupvalue when present; falls back to a plain On)
]]

local Listen = {}

export type Subscription = { check: () -> (), undo: () -> () }

-- The listener registry the On function closes over: a table with Reliable (and maybe Unreliable) slot maps.
local function registryOf(onFn: any): any
    local env: any = getfenv()
    local debugLib: any = env.debug
    local getUpvalue: any = if type(debugLib) == "table" then debugLib.getupvalue else nil
    if type(getUpvalue) ~= "function" then
        return nil
    end
    for index = 1, 8 do
        local ok, a, b = pcall(getUpvalue, onFn, index)
        if not ok then
            break
        end
        -- Executors return either the value or (name, value).
        local value: any = if b ~= nil then b else a
        if type(value) == "table" and type(value.Reliable) == "table" then
            return value
        end
    end
    return nil
end

--- Subscribes handler to entry next to the game's listener. Returns nil when entry has no On.
function Listen.chain(entry: any, handler: (...any) -> ()): Subscription?
    if type(entry) ~= "table" or type(entry.On) ~= "function" then
        return nil
    end
    local onFn: any = entry.On
    local registry = registryOf(onFn)
    if registry == nil then
        -- Unknown module shape: a plain subscription (may replace the game's listener).
        local ok, undo = pcall(onFn, handler)
        return {
            check = function() end,
            undo = function()
                if ok and type(undo) == "function" then
                    pcall(undo)
                end
            end,
        }
    end
    local before: { [any]: { [any]: any } } = {}
    for kind, slots in registry do
        if type(slots) == "table" then
            before[kind] = table.clone(slots)
        end
    end
    local function probe() end
    pcall(onFn, probe)
    local slotKind: any, slotId: any = nil, nil
    for kind, slots in registry do
        if type(slots) == "table" then
            for id, value in slots do
                if value == probe then
                    slotKind, slotId = kind, id
                end
            end
        end
    end
    if slotKind == nil then
        local ok, undo = pcall(onFn, handler)
        return {
            check = function() end,
            undo = function()
                if ok and type(undo) == "function" then
                    pcall(undo)
                end
            end,
        }
    end
    local slots: any = registry[slotKind]
    local previous: any = before[slotKind] and before[slotKind][slotId]
    local function wrapper(...: any)
        if type(previous) == "function" then
            pcall(previous, ...)
        end
        handler(...)
    end
    slots[slotId] = wrapper
    return {
        check = function()
            local current = slots[slotId]
            if current ~= wrapper then
                -- The game subscribed again (a new run): keep its listener and run after it.
                previous = current
                slots[slotId] = wrapper
            end
        end,
        undo = function()
            if slots[slotId] == wrapper then
                slots[slotId] = previous
            end
        end,
    }
end

return Listen
