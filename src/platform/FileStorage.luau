--!strict
--[[
Purpose: Contain filesystem access to a fixed config location. With a profile (game and player), every settings key
         is a section of ONE file, ViperHubNextGen/<Game>_<Player>.json; legacy per-key files are migrated into it
Input: Detected environment and game key; optionally a profile set once at start-up (useProfile)
Output: Storage read/write API (each key reads and writes its own section as a JSON text)
Dependencies: Capabilities; Validation
]]

local Capabilities = require("./Capabilities")
local Validation = require("../utils/Validation")
local FileStorage = {}
local ROOT = "ViperHubNextGen"
local MAX_BYTES = 16384 -- one section (or one legacy file)
local MAX_PROFILE_BYTES = 524288 -- the whole profile file
local PROFILE_SCHEMA = 1

export type Storage = { read: () -> (string?, string?), write: (string) -> boolean }

-- The active profile: the combined file and the JSON codec (HttpService), or nil for per-key files.
local profile: { path: string, encode: (any) -> string, decode: (string) -> any }? = nil

local function cleanName(value: any): string?
    if type(value) ~= "string" then
        return nil
    end
    local cleaned = string.gsub(value, "[^%w_]", "")
    return if #cleaned > 0 and #cleaned <= 64 then cleaned else nil
end

--- Routes every storage key to one file per game and player (<Game>_<Player>.json). Returns the file path, or nil
--- (then per-key files stay in use) when the player name or the JSON codec is unavailable.
function FileStorage.useProfile(env: { [string]: any }, gameId: string): string?
    local okName, playerName = pcall(function()
        return env.game:GetService("Players").LocalPlayer.Name
    end)
    local game = cleanName(gameId)
    local player = if okName then cleanName(playerName) else nil
    local okHttp, http = pcall(function()
        return env.game:GetService("HttpService")
    end)
    if not game or not player or not okHttp or not http then
        return nil
    end
    local httpService: any = http
    profile = {
        path = ROOT .. "/" .. game .. "_" .. player .. ".json",
        encode = function(value: any): string
            return httpService:JSONEncode(value)
        end,
        decode = function(text: string): any
            return httpService:JSONDecode(text)
        end,
    }
    FileStorage.migrate(env, game)
    return profile.path
end

local function legacyStorage(env: { [string]: any }, filePath: string): Storage
    return {
        read = function(): (string?, string?)
            local ok, result = pcall(function()
                if not env.isfile(filePath) then
                    return nil
                end
                return env.readfile(filePath)
            end)
            if not ok then
                return nil, "CONFIG_READ_FAILED"
            end
            if result == nil then
                return nil, nil
            end
            if type(result) ~= "string" or #result > MAX_BYTES then
                return nil, "CONFIG_INVALID"
            end
            return result, nil
        end,
        write = function(body: string): boolean
            if #body > MAX_BYTES then
                return false
            end
            local ok = pcall(function()
                if not env.isfolder(ROOT) then
                    env.makefolder(ROOT)
                end
                env.writefile(filePath, body)
                if env.readfile(filePath) ~= body then
                    error("readback")
                end
            end)
            return ok
        end,
    }
end

-- Reads the whole profile document: the table, or nil plus an error code. A missing file is an empty document.
local function readProfile(env: { [string]: any }, active: any): (any, string?)
    local ok, text = pcall(function()
        if not env.isfile(active.path) then
            return nil
        end
        return env.readfile(active.path)
    end)
    if not ok then
        return nil, "CONFIG_READ_FAILED"
    end
    if text == nil then
        return { schemaVersion = PROFILE_SCHEMA, sections = {} }, nil
    end
    if type(text) ~= "string" or #text > MAX_PROFILE_BYTES then
        return nil, "CONFIG_INVALID"
    end
    local okDecode, document = pcall(active.decode, text)
    if not okDecode or type(document) ~= "table" or type(document.sections) ~= "table" then
        return nil, "CONFIG_INVALID"
    end
    return document, nil
end

--- Moves every old per-key settings file of this game (ViperHubNextGen/<Game>*.json) into the profile at once, so
--- one file holds everything; a file that cannot be read or decoded is left where it is.
function FileStorage.migrate(env: { [string]: any }, game: string)
    local active = profile
    if not active or type(env.listfiles) ~= "function" then
        return
    end
    local document, readError = readProfile(env, active)
    if readError then
        return
    end
    local before: { string } = {}
    for key in document.sections do
        table.insert(before, key)
    end
    local okList, paths = pcall(env.listfiles :: any, ROOT)
    if not okList or type(paths) ~= "table" then
        return
    end
    local moved: { string } = {}
    for _, entry in paths do
        local path = string.gsub(tostring(entry), "\\", "/")
        local key = string.match(path, "([%w]+)%.json$")
        if
            key
            and string.sub(key, 1, #game) == game
            and Validation.identifier(key)
            and not string.find(path, "_", 1, true)
        then
            if document.sections[key] ~= nil then
                -- Already in the profile (an old hub copy wrote its old file again): the profile wins.
                table.insert(moved, path)
                continue
            end
            local okRead, text = pcall(env.readfile, path)
            if okRead and type(text) == "string" and #text <= MAX_BYTES then
                local okDecode, data = pcall(active.decode, text)
                if okDecode and type(data) == "table" then
                    document.sections[key] = data
                    table.insert(moved, path)
                end
            end
        end
    end
    if #moved == 0 then
        return
    end
    -- Only the stale duplicates: nothing to write, just remove them.
    local anyNew = false
    for key in document.sections do
        if not table.find(before, key) then
            anyNew = true
        end
    end
    if not anyNew then
        if type(env.delfile) == "function" then
            for _, path in moved do
                pcall(env.delfile :: any, path)
            end
        end
        return
    end
    document.schemaVersion = PROFILE_SCHEMA
    local okEncode, text = pcall(active.encode, document)
    if not okEncode or type(text) ~= "string" or #text > MAX_PROFILE_BYTES then
        return
    end
    local wrote = pcall(function()
        if not env.isfolder(ROOT) then
            env.makefolder(ROOT)
        end
        env.writefile(active.path, text)
        if env.readfile(active.path) ~= text then
            error("readback")
        end
    end)
    if wrote and type(env.delfile) == "function" then
        for _, path in moved do
            pcall(env.delfile :: any, path)
        end
    end
end

local function profileStorage(env: { [string]: any }, key: string, active: any): Storage
    local legacyPath = ROOT .. "/" .. key .. ".json"
    local legacy = legacyStorage(env, legacyPath)
    return {
        read = function(): (string?, string?)
            local document, readError = readProfile(env, active)
            if readError then
                return nil, readError
            end
            local section = document.sections[key]
            if section ~= nil then
                local okEncode, text = pcall(active.encode, section)
                return if okEncode then text else nil, if okEncode then nil else "CONFIG_INVALID"
            end
            -- Not in the profile yet: the old per-key file (moved into the profile on the next save).
            return legacy.read()
        end,
        write = function(body: string): boolean
            if #body > MAX_BYTES then
                return false
            end
            -- Read-modify-write: other keys' sections are kept exactly as they are on disk.
            local document, readError = readProfile(env, active)
            if readError then
                return false
            end
            local okDecode, section = pcall(active.decode, body)
            if not okDecode then
                return false
            end
            document.schemaVersion = PROFILE_SCHEMA
            document.sections[key] = section
            local okEncode, text = pcall(active.encode, document)
            if not okEncode or type(text) ~= "string" or #text > MAX_PROFILE_BYTES then
                return false
            end
            local ok = pcall(function()
                if not env.isfolder(ROOT) then
                    env.makefolder(ROOT)
                end
                env.writefile(active.path, text)
                if env.readfile(active.path) ~= text then
                    error("readback")
                end
            end)
            if ok and type(env.delfile) == "function" then
                -- The key now lives in the profile: remove its old file so there is one settings file.
                pcall(function()
                    if env.isfile(legacyPath) then
                        env.delfile(legacyPath)
                    end
                end)
            end
            return ok
        end,
    }
end

--- Creates storage for a validated key; returns nil when persistence is unavailable.
function FileStorage.new(env: { [string]: any }, key: string): Storage?
    if not Capabilities.detect(env).persistence or not Validation.identifier(key) then
        return nil
    end
    -- Each loaded bundle has its own copy of this module: take the profile from the running session (its game id).
    if profile == nil then
        local okSession, gameId = pcall(function()
            local session = env.shared and env.shared.ViperHubNextGen
            return session and session.context and session.context.gameId
        end)
        if okSession and type(gameId) == "string" then
            FileStorage.useProfile(env, gameId)
        end
    end
    local active = profile
    if active then
        return profileStorage(env, key, active)
    end
    return legacyStorage(env, ROOT .. "/" .. key .. ".json")
end
return FileStorage
