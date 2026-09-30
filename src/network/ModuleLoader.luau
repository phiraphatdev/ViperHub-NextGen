--!strict
--[[
Purpose: Compile only fetched artifacts selected by validated manifest
Input: Compiler; nonempty source; optional argument
Output: Module export or error code
Dependencies: None
]]

local ModuleLoader = {}
--- Compiles and invokes a nonempty source; returns a sanitized failure code.
function ModuleLoader.load(compile: any, source: unknown, argument: any): (any, string?)
    if type(compile) ~= "function" or type(source) ~= "string" or #source == 0 then
        return nil, "MODULE_INPUT"
    end
    local compiled, chunk = pcall(compile, source, "ViperHubModule")
    if not compiled or type(chunk) ~= "function" then
        return nil, "MODULE_COMPILE"
    end
    local ok, result = pcall(chunk, argument)
    if not ok or type(result) ~= "table" then
        return nil, "MODULE_EXECUTION"
    end
    return result, nil
end
--- Verifies a game export before invoking its lifecycle functions.
function ModuleLoader.isGame(value: any, id: string, version: string): boolean
    if type(value) ~= "table" then
        return false
    end
    if value.pages ~= nil then
        if type(value.pages) ~= "table" or #value.pages > 16 then
            return false
        end
        for _, page in value.pages do
            if
                type(page) ~= "table"
                or type(page.title) ~= "string"
                or #page.title == 0
                or #page.title > 40
                or type(page.description) ~= "string"
                or #page.description > 200
                or (page.icon ~= nil and (type(page.icon) ~= "string" or #page.icon > 40))
                or (page.render ~= nil and type(page.render) ~= "function")
            then
                return false
            end
        end
    end
    return type(value.metadata) == "table"
        and value.metadata.id == id
        and value.metadata.version == version
        and type(value.start) == "function"
        and type(value.stop) == "function"
end
return ModuleLoader
