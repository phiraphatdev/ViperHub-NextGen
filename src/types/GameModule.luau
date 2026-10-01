--!strict
--[[
Purpose: Shared game module contract
Input: None
Output: Types only
Dependencies: None
]]

export type Metadata = {
    id: string,
    name: string,
    version: string,
    lastUpdated: string,
    placeIds: { number },
    gameIds: { number }?,
}
export type Context =
    { alive: boolean, state: string, log: (string) -> (), cleanup: { add: (() -> ()) -> () } }
export type PageDefinition =
    { title: string, icon: string?, description: string, render: ((any, any?) -> ())? }
export type GameModule = {
    metadata: Metadata,
    pages: { PageDefinition }?,
    -- Optional: CollectionService tags applied to every UI layer (for example to opt out of a game's own button effects).
    windowTags: { string }?,
    start: (Context) -> (),
    stop: () -> (),
}
return {}
