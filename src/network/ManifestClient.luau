--!strict
--[[
Purpose: Validate remote manifest and operational status before loading code
Input: Untrusted decoded metadata
Output: Validated manifest/status
Dependencies: Validation; Version; types/Manifest
]]

local Validation = require("../utils/Validation")
local Version = require("../utils/Version")
local Types = require("../types/Manifest")
local ManifestClient = {}
--- Returns a validated manifest for the selected game, or nil; repository must match trusted config.
function ManifestClient.validate(value: unknown, repository: string, targetGameId: string?): Types.Manifest?
    if type(value) ~= "table" then
        return nil
    end
    local data = value :: { [string]: any }
    if
        data.schemaVersion ~= 1
        or (data.mode ~= "release" and data.mode ~= "development")
        or data.repository ~= repository
        or (data.sourceCommit ~= nil and (type(data.sourceCommit) ~= "string" or #data.sourceCommit > 128))
        or (data.artifactRevision ~= nil and (type(data.artifactRevision) ~= "string" or #data.artifactRevision > 128))
        or not Version.parse(data.version)
        or not Version.parse(data.loaderVersion)
        or not Version.parse(data.minLoaderVersion)
        or type(data.artifacts) ~= "table"
        or type(data.games) ~= "table"
    then
        return nil
    end
    local artifacts: { [string]: any } = data.artifacts :: any
    local games: { [string]: any } = data.games :: any
    if targetGameId ~= nil and not Validation.identifier(targetGameId) then
        return nil
    end
    local selected = if targetGameId then { "ui", targetGameId } else { "ui" }
    for _, key in selected do
        local rawArtifact = artifacts[key]
        if type(rawArtifact) ~= "table" then
            return nil
        end
        local artifact: { [string]: any } = rawArtifact :: any
        local sha: any = artifact.sha256
        if
            not Validation.artifactPath(artifact.path)
            or (data.mode == "release" and (sha == nil or artifact.bytes == nil))
            or (sha ~= nil and (type(sha) ~= "string" or #sha ~= 64 or not string.match(
                sha :: string,
                "^[a-f0-9]+$"
            )))
            or (
                artifact.bytes ~= nil
                and (
                    not Validation.isFinite(artifact.bytes)
                    or artifact.bytes % 1 ~= 0
                    or artifact.bytes <= 0
                    or artifact.bytes > 4000000
                )
            )
        then
            return nil
        end
    end
    if targetGameId then
        local entry: any = games[targetGameId]
        if
            type(entry) ~= "table"
            or not Version.parse(entry.version)
            or type(entry.lastUpdated) ~= "string"
            or not string.match(entry.lastUpdated :: string, "^%d%d%d%d%-%d%d%-%d%d$")
            or type(entry.name) ~= "string"
            or #entry.name == 0
            or type(entry.placeIds) ~= "table"
            or #entry.placeIds == 0
            or (entry.gameIds ~= nil and (type(entry.gameIds) ~= "table" or #entry.gameIds == 0))
        then
            return nil
        end
        for _, placeId in entry.placeIds do
            if not Validation.isFinite(placeId) or placeId % 1 ~= 0 or placeId <= 0 then
                return nil
            end
        end
        if entry.gameIds then
            for _, gameId in entry.gameIds do
                if not Validation.isFinite(gameId) or gameId % 1 ~= 0 or gameId <= 0 then
                    return nil
                end
            end
        end
    end
    return data :: any
end
--- Returns operational state for gameId; missing/malformed status never implies readiness.
function ManifestClient.status(value: unknown, gameId: string): string?
    if type(value) ~= "table" then
        return nil
    end
    local data = value :: { [string]: any }
    if data.schemaVersion ~= 1 or type(data.games) ~= "table" then
        return nil
    end
    local games: { [string]: any } = data.games :: any
    local entry: any = games[gameId]
    if type(entry) ~= "table" then
        return nil
    end
    local state = entry.state
    if state == "ready" or state == "maintenance" or state == "disabled" then
        return state
    end
    return nil
end
return ManifestClient
