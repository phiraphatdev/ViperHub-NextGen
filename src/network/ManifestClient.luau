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
--- Returns a validated published manifest or nil; repository must match trusted config.
function ManifestClient.validate(value: unknown, repository: string): Types.Manifest?
    if type(value) ~= "table" then
        return nil
    end
    local data = value :: { [string]: any }
    if
        data.schemaVersion ~= 1
        or data.mode ~= "release"
        or data.repository ~= repository
        or not Validation.sha(data.sourceCommit)
        or not Validation.sha(data.artifactRevision)
        or not Version.parse(data.version)
        or not Version.parse(data.loaderVersion)
        or not Version.parse(data.minLoaderVersion)
        or type(data.artifacts) ~= "table"
        or type(data.games) ~= "table"
    then
        return nil
    end
    local count = 0
    local artifacts: { [string]: any } = data.artifacts :: any
    local games: { [string]: any } = data.games :: any
    for key, rawArtifact in artifacts do
        if type(rawArtifact) ~= "table" then
            return nil
        end
        local artifact: { [string]: any } = rawArtifact :: any
        count += 1
        if
            count > 16
            or not Validation.identifier(key)
            or type(artifact) ~= "table"
            or not Validation.artifactPath(artifact.path)
            or type(artifact.sha256) ~= "string"
            or #artifact.sha256 ~= 64
            or not artifact.sha256:match("^[a-f0-9]+$")
            or not Validation.isFinite(artifact.bytes)
            or artifact.bytes % 1 ~= 0
            or artifact.bytes <= 0
            or artifact.bytes > 4000000
        then
            return nil
        end
    end
    for _, key in { "ui", "loader", "AnimeVanguards", "AnimeExpeditions" } do
        if not artifacts[key] then
            return nil
        end
    end
    for _, key in { "AnimeVanguards", "AnimeExpeditions" } do
        local entry: any = games[key]
        if
            type(entry) ~= "table"
            or not Version.parse(entry.version)
            or type(entry.lastUpdated) ~= "string"
            or not string.match(entry.lastUpdated :: string, "^%d%d%d%d%-%d%d%-%d%d$")
        then
            return nil
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
