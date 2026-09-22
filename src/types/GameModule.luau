--!strict
--[[
Purpose: Shared game module contract
Input: None
Output: Types only
Dependencies: None
]]

export type Metadata =
    { id: string, name: string, version: string, lastUpdated: string, placeIds: { number } }
export type Context =
    { alive: boolean, state: string, log: (string) -> (), cleanup: { add: (() -> ()) -> () } }
export type GameModule = { metadata: Metadata, start: (Context) -> (), stop: () -> () }
return {}
