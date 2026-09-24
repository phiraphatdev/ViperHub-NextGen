--!strict
--[[
Purpose: Release metadata contract
Input: None
Output: Types only
Dependencies: None
]]

export type Artifact = { path: string, sha256: string?, bytes: number? }
export type Manifest = {
    schemaVersion: number,
    version: string,
    loaderVersion: string,
    minLoaderVersion: string,
    sourceCommit: string?,
    mode: string,
    repository: string?,
    artifactRevision: string?,
    artifacts: { [string]: Artifact },
    games: {
        [string]: {
            version: string,
            lastUpdated: string,
            name: string,
            placeIds: { number },
            gameIds: { number }?,
        },
    },
}
return {}
