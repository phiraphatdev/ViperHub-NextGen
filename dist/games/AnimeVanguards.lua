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
            local VERSION = '0.1.0'
            local LAST_UPDATED = '2026-09-22'
            local metadata = {
                id = 'AnimeVanguards',
                name = 'Anime Vanguards',
                version = VERSION,
                lastUpdated = LAST_UPDATED,
                placeIds = {16146832113},
            }

            table.freeze(metadata.placeIds)

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
end

local Types = __DARKLUA_BUNDLE_MODULES.a()
local metadata = __DARKLUA_BUNDLE_MODULES.b()
local active = false
local GameModule = {metadata = metadata}

function GameModule.start(context)
    if active or not context.alive then
        return
    end

    active = true

    context.log('PLACEHOLDER_STARTED')
    context.cleanup.add(GameModule.stop)
end
function GameModule.stop()
    active = false
end

return GameModule
