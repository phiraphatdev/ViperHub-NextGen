local __DARKLUA_BUNDLE_MODULES = {cache = {}}

do
    do
        local function __modImpl()
            return {}
        end

        function __DARKLUA_BUNDLE_MODULES.a()
            local v = __DARKLUA_BUNDLE_MODULES.cache.a

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.a = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Types = __DARKLUA_BUNDLE_MODULES.a()
            local VERSION = '0.2.0'
            local LAST_UPDATED = '2026-09-24'
            local metadata = {
                id = 'AnimeVanguards',
                name = 'Anime Vanguards',
                version = VERSION,
                lastUpdated = LAST_UPDATED,
                placeIds = {16146832113},
                gameIds = {5578556129},
            }

            table.freeze(metadata.placeIds)
            table.freeze(metadata.gameIds)

            return table.freeze(metadata)
        end

        function __DARKLUA_BUNDLE_MODULES.b()
            local v = __DARKLUA_BUNDLE_MODULES.cache.b

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.b = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            return table.freeze({
                instancePaths = table.freeze({}),
                remoteNames = table.freeze({}),
            })
        end

        function __DARKLUA_BUNDLE_MODULES.c()
            local v = __DARKLUA_BUNDLE_MODULES.cache.c

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.c = v
            end

            return v.c
        end
    end
end

local Types = __DARKLUA_BUNDLE_MODULES.a()
local metadata = __DARKLUA_BUNDLE_MODULES.b()
local config = __DARKLUA_BUNDLE_MODULES.c()
local active = false
local GameModule = {
    metadata = metadata,
    config = config,
}

function GameModule.start(context)
    if active or not context.alive then
        return
    end

    active = true

    context.log('PLACEHOLDER_STARTED')
end
function GameModule.stop()
    active = false
end

return GameModule
