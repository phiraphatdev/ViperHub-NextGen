--!strict
--[[
Purpose: Store individual macro JSON documents beneath the executor workspace
Input: Executor file APIs, JSON codec, validated macro names
Output: Listed, read, written and deleted macro files
Dependencies: Document
]]
local Document = require("./Document")
local Storage = {}
local ROOT = "ViperHubNextGen/macro/AnimeVanguards"
local MAX_BYTES = 1024 * 1024
local function validName(name: any): boolean
    return type(name) == "string"
        and #name > 0
        and #name <= 64
        and (name :: string):match("^[%w_%-]+$") ~= nil
end
--- Creates a game-owned multi-file store; returns nil when required APIs are missing.
function Storage.new(env: any, codec: any): any?
    for _, key in { "readfile", "writefile", "isfile", "isfolder", "makefolder", "listfiles", "delfile" } do
        if type(env[key]) ~= "function" then
            return nil
        end
    end
    local self: any = {}
    local function path(name: string): string
        return ROOT .. "/" .. name .. ".json"
    end
    local function folders(): boolean
        local ok = pcall(function()
            for _, folder in { "ViperHubNextGen", "ViperHubNextGen/macro", ROOT } do
                if not env.isfolder(folder) then
                    env.makefolder(folder)
                end
            end
        end)
        return ok
    end
    function self.list(): { string }
        if not folders() then
            return {}
        end
        local ok, files = pcall(env.listfiles, ROOT)
        if not ok or type(files) ~= "table" then
            return {}
        end
        local names = {}
        for _, file in files do
            if type(file) == "string" then
                local name = file:gsub("\\", "/"):match("([^/]+)%.[jJ][sS][oO][nN]$")
                if validName(name) then
                    table.insert(names, name)
                end
            end
        end
        table.sort(names)
        return names
    end
    function self.read(name: string): (any?, string?)
        if not validName(name) then
            return nil, "MACRO_NAME_INVALID"
        end
        local ok, body = pcall(env.readfile, path(name))
        if not ok or type(body) ~= "string" or #body > MAX_BYTES then
            return nil, "MACRO_READ_FAILED"
        end
        local decoded, data = pcall(codec.JSONDecode, codec, body)
        if not decoded then
            return nil, "MACRO_JSON_INVALID"
        end
        local document, err = Document.validate(data)
        if document and document.name ~= name then
            document.name = name
        end
        return document, err
    end
    function self.write(name: string, document: any, overwrite: boolean?): (boolean, string?)
        if not validName(name) then
            return false, "MACRO_NAME_INVALID"
        end
        local candidate = document
        if type(document) == "table" and document.name ~= name then
            candidate = table.clone(document)
            candidate.name = name
        end
        local checked, err = Document.validate(candidate)
        if not checked then
            return false, err
        end
        if not folders() then
            return false, "MACRO_FOLDER_FAILED"
        end
        if not overwrite and env.isfile(path(name)) then
            return false, "MACRO_EXISTS"
        end
        local ok, body = pcall(codec.JSONEncode, codec, checked)
        if not ok or type(body) ~= "string" or #body > MAX_BYTES then
            return false, "MACRO_SIZE_INVALID"
        end
        local wrote = pcall(env.writefile, path(name), body)
        if not wrote then
            return false, "MACRO_WRITE_FAILED"
        end
        local readback = self.read(name)
        if not readback then
            return false, "MACRO_READBACK_FAILED"
        end
        return true, nil
    end
    function self.delete(name: string): (boolean, string?)
        if not validName(name) then
            return false, "MACRO_NAME_INVALID"
        end
        if not env.isfile(path(name)) then
            return false, "MACRO_MISSING"
        end
        local ok = pcall(env.delfile, path(name))
        return ok and not env.isfile(path(name)), if ok then nil else "MACRO_DELETE_FAILED"
    end
    return self
end
return Storage
