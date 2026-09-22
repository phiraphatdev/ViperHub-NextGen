--!strict
--[[
Purpose: Lifecycle context contract
Input: None
Output: Types only
Dependencies: None
]]

export type Context = {
    alive: boolean,
    state: string,
    gameId: string?,
    cleanup: { add: (() -> ()) -> (), destroy: () -> (), count: () -> number },
    log: (string) -> (),
    destroy: () -> (),
}
return {}
