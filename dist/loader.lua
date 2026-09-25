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
            local VERSION = '0.2.2'
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
            local Types = __DARKLUA_BUNDLE_MODULES.a()
            local VERSION = '0.2.2'
            local LAST_UPDATED = '2026-09-24'
            local metadata = {
                id = 'AnimeExpeditions',
                name = 'Anime Expeditions',
                version = VERSION,
                lastUpdated = LAST_UPDATED,
                placeIds = {84515722934860},
                gameIds = {7613921865},
            }

            table.freeze(metadata.placeIds)
            table.freeze(metadata.gameIds)

            return table.freeze(metadata)
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
    do
        local function __modImpl()
            return table.freeze({
                __DARKLUA_BUNDLE_MODULES.b(),
                __DARKLUA_BUNDLE_MODULES.c(),
            })
        end

        function __DARKLUA_BUNDLE_MODULES.d()
            local v = __DARKLUA_BUNDLE_MODULES.cache.d

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.d = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Validation = {}

            function Validation.isFinite(value)
                return type(value) == 'number' and value == value and value > -math.huge and value < math.huge
            end
            function Validation.number(value, minimum, maximum, fallback)
                if not Validation.isFinite(value) then
                    return fallback
                end

                return math.clamp(value, minimum, maximum)
            end
            function Validation.identifier(value)
                return type(value) == 'string' and #value > 0 and #value <= 64 and value:match('^[%w_-]+$') ~= nil
            end
            function Validation.sha(value)
                return type(value) == 'string' and #value == 40 and value:match('^[a-f0-9]+$') ~= nil
            end
            function Validation.artifactPath(value)
                return type(value) == 'string' and #value <= 160 and value:match('^dist/[%w_/-]+%.lua$') ~= nil and not string.find(value, '//', 1, true)
            end

            return Validation
        end

        function __DARKLUA_BUNDLE_MODULES.e()
            local v = __DARKLUA_BUNDLE_MODULES.cache.e

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.e = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Registry = __DARKLUA_BUNDLE_MODULES.d()
            local Validation = __DARKLUA_BUNDLE_MODULES.e()
            local Types = __DARKLUA_BUNDLE_MODULES.a()
            local Detector = {}

            function Detector.detect(placeId, gameId)
                local function valid(value)
                    return Validation.isFinite(value) and (value) > 0 and (value) % 1 == 0
                end
                local function copy(metadata)
                    return {
                        id = metadata.id,
                        name = metadata.name,
                        version = metadata.version,
                        lastUpdated = metadata.lastUpdated,
                        placeIds = table.clone(metadata.placeIds),
                        gameIds = if metadata.gameIds then table.clone(metadata.gameIds)else nil,
                    }
                end

                if valid(placeId) then
                    for _, metadata in Registry do
                        for _, supported in metadata.placeIds do
                            if placeId == supported then
                                if valid(gameId) and metadata.gameIds and not table.find(metadata.gameIds, gameId) then
                                    return nil
                                end

                                return copy(metadata)
                            end
                        end
                    end
                end
                if not valid(gameId) then
                    return nil
                end

                for _, metadata in Registry do
                    for _, supported in metadata.gameIds or {}do
                        if gameId == supported then
                            return copy(metadata)
                        end
                    end
                end

                return nil
            end

            return Detector
        end

        function __DARKLUA_BUNDLE_MODULES.f()
            local v = __DARKLUA_BUNDLE_MODULES.cache.f

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.f = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Cleanup = {}

            function Cleanup.new(onError)
                local callbacks = {}
                local destroyed = false

                local function run(callback)
                    local ok = pcall(callback)

                    if not ok then
                        onError('CLEANUP_FAILED')
                    end
                end

                return {
                    add = function(callback)
                        if destroyed then
                            run(callback)
                        else
                            table.insert(callbacks, callback)
                        end
                    end,
                    destroy = function()
                        if destroyed then
                            return
                        end

                        destroyed = true

                        for index = #callbacks, 1, -1 do
                            run(callbacks[index])
                        end

                        table.clear(callbacks)
                    end,
                    count = function()
                        return #callbacks
                    end,
                }
            end

            return Cleanup
        end

        function __DARKLUA_BUNDLE_MODULES.g()
            local v = __DARKLUA_BUNDLE_MODULES.cache.g

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.g = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Lifecycle = {}
            local ALLOWED = {
                created = {
                    loading = true,
                    unsupported = true,
                    failed = true,
                    stopped = true,
                },
                loading = {
                    ready = true,
                    failed = true,
                    stopped = true,
                },
                ready = {
                    stopped = true,
                    failed = true,
                },
                failed = {stopped = true},
                unsupported = {stopped = true},
                stopped = {},
            }

            function Lifecycle.canTransition(current, nextState)
                local transitions = ALLOWED[current]

                return transitions ~= nil and transitions[nextState] == true
            end

            return Lifecycle
        end

        function __DARKLUA_BUNDLE_MODULES.h()
            local v = __DARKLUA_BUNDLE_MODULES.cache.h

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.h = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            return {}
        end

        function __DARKLUA_BUNDLE_MODULES.i()
            local v = __DARKLUA_BUNDLE_MODULES.cache.i

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.i = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Cleanup = __DARKLUA_BUNDLE_MODULES.g()
            local Lifecycle = __DARKLUA_BUNDLE_MODULES.h()
            local Types = __DARKLUA_BUNDLE_MODULES.i()
            local Context = {}

            function Context.new(log)
                local scope = Cleanup.new(log)
                local context = {
                    alive = true,
                    state = 'created',
                    gameId = nil,
                    cleanup = scope,
                    log = log,
                    destroy = function() end,
                    transition = function()
                        return false
                    end,
                }

                context.transition = function(nextState)
                    if not Lifecycle.canTransition(context.state, nextState) then
                        return false
                    end

                    context.state = nextState

                    return true
                end
                context.destroy = function(finalState)
                    if not context.alive then
                        return
                    end

                    context.alive = false

                    if finalState == 'failed' or finalState == 'unsupported' then
                        if not context.transition(finalState) then
                            context.transition('stopped')
                        end
                    else
                        context.transition('stopped')
                    end

                    scope.destroy()
                end

                return context
            end

            return Context
        end

        function __DARKLUA_BUNDLE_MODULES.j()
            local v = __DARKLUA_BUNDLE_MODULES.cache.j

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.j = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Diagnostics = {}

            function Diagnostics.new(capacity)
                local limit = math.clamp(math.floor(capacity), 1, 256)
                local entries = {}

                return {
                    push = function(code)
                        if not code:match('^[A-Z0-9_]+$') or #code > 64 then
                            code = 'INVALID_DIAGNOSTIC'
                        end
                        if #entries == limit then
                            table.remove(entries, 1)
                        end

                        table.insert(entries, code)
                    end,
                    snapshot = function()
                        return table.clone(entries)
                    end,
                }
            end

            return Diagnostics
        end

        function __DARKLUA_BUNDLE_MODULES.k()
            local v = __DARKLUA_BUNDLE_MODULES.cache.k

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.k = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Capabilities = {}

            function Capabilities.detect(env)
                local function callable(name)
                    return type(env[name]) == 'function'
                end

                return {
                    compile = callable('loadstring'),
                    request = callable('request') or callable('http_request'),
                    persistence = callable('readfile') and callable('writefile') and callable('isfile') and callable('isfolder') and callable('makefolder'),
                }
            end

            return Capabilities
        end

        function __DARKLUA_BUNDLE_MODULES.l()
            local v = __DARKLUA_BUNDLE_MODULES.cache.l

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.l = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Capabilities = __DARKLUA_BUNDLE_MODULES.l()
            local Validation = __DARKLUA_BUNDLE_MODULES.e()
            local FileStorage = {}
            local ROOT = 'ViperHubNextGen'
            local MAX_BYTES = 16384

            function FileStorage.new(env, key)
                if not Capabilities.detect(env).persistence or not Validation.identifier(key) then
                    return nil
                end

                local filePath = ROOT .. '/' .. key .. '.json'

                return {
                    read = function()
                        local ok, result = pcall(function()
                            if not env.isfile(filePath) then
                                return nil
                            end

                            return env.readfile(filePath)
                        end)

                        if not ok then
                            return nil, 'CONFIG_READ_FAILED'
                        end
                        if result == nil then
                            return nil, nil
                        end
                        if type(result) ~= 'string' or #result > MAX_BYTES then
                            return nil, 'CONFIG_INVALID'
                        end

                        return result, nil
                    end,
                    write = function(body)
                        if #body > MAX_BYTES then
                            return false
                        end

                        local ok = pcall(function()
                            if not env.isfolder(ROOT) then
                                env.makefolder(ROOT)
                            end

                            env.writefile(filePath, body)

                            if env.readfile(filePath) ~= body then
                                error('readback')
                            end
                        end)

                        return ok
                    end,
                }
            end

            return FileStorage
        end

        function __DARKLUA_BUNDLE_MODULES.m()
            local v = __DARKLUA_BUNDLE_MODULES.cache.m

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.m = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            return table.freeze({
                schemaVersion = 1,
                notifications = true,
                uiScale = 1,
                theme = 'Dark',
                toggleKey = 'RightShift',
            })
        end

        function __DARKLUA_BUNDLE_MODULES.n()
            local v = __DARKLUA_BUNDLE_MODULES.cache.n

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.n = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Defaults = __DARKLUA_BUNDLE_MODULES.n()
            local Validation = __DARKLUA_BUNDLE_MODULES.e()
            local Schema = {}
            local KEYS = {
                RightShift = true,
                RightControl = true,
                LeftControl = true,
                Insert = true,
                Delete = true,
                Home = true,
                End = true,
                F1 = true,
                F2 = true,
                F3 = true,
                F4 = true,
                F5 = true,
                F6 = true,
                F7 = true,
                F8 = true,
                F9 = true,
                F10 = true,
                F11 = true,
                F12 = true,
            }

            function Schema.decode(value)
                local output = {
                    schemaVersion = Defaults.schemaVersion,
                    notifications = Defaults.notifications,
                    uiScale = Defaults.uiScale,
                    theme = Defaults.theme,
                    toggleKey = Defaults.toggleKey,
                }

                if type(value) ~= 'table' then
                    return output, false
                end

                local data = value

                if data.schemaVersion ~= 1 then
                    return output, false
                end
                if type(data.notifications) == 'boolean' then
                    output.notifications = data.notifications
                end

                output.uiScale = Validation.number(data.uiScale, 0.8, 1.3, Defaults.uiScale)

                if data.theme == 'Dark' then
                    output.theme = data.theme
                end
                if type(data.toggleKey) == 'string' and (KEYS)[data.toggleKey] then
                    output.toggleKey = data.toggleKey
                end

                return output, true
            end

            return Schema
        end

        function __DARKLUA_BUNDLE_MODULES.o()
            local v = __DARKLUA_BUNDLE_MODULES.cache.o

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.o = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Schema = __DARKLUA_BUNDLE_MODULES.o()
            local ConfigStore = {}

            function ConfigStore.new(storage, decode, encode, log)
                local current = Schema.decode(nil)

                if storage then
                    local text, code = storage.read()

                    if code then
                        log(code)
                    end
                    if text then
                        local ok, data = pcall(decode, text)
                        local config, valid = Schema.decode(if ok then data else nil)

                        current = config

                        if not valid then
                            log('CONFIG_INVALID')
                        end
                    end
                end

                return {
                    persistent = storage ~= nil,
                    get = function()
                        return table.clone(current)
                    end,
                    update = function(key, value)
                        local candidate = (table.clone(current))

                        candidate[key] = value

                        local sanitized = Schema.decode(candidate)

                        if key == 'toggleKey' and sanitized.toggleKey ~= value then
                            return
                        end

                        current = sanitized
                    end,
                    save = function()
                        if not storage then
                            log('CONFIG_SESSION_ONLY')

                            return false
                        end

                        local ok, text = pcall(encode, current)

                        if not ok or type(text) ~= 'string' then
                            log('CONFIG_ENCODE_FAILED')

                            return false
                        end

                        local saved = storage.write(text)

                        if not saved then
                            log('CONFIG_WRITE_FAILED')
                        end

                        return saved
                    end,
                }
            end

            return ConfigStore
        end

        function __DARKLUA_BUNDLE_MODULES.p()
            local v = __DARKLUA_BUNDLE_MODULES.cache.p

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.p = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local HttpClient = {}

            function HttpClient.new(transport, scheduler)
                return {
                    get = function(url, maxBytes, timeout)
                        if not url:match('^https://raw%.githubusercontent%.com/') then
                            return nil, 'URL_REJECTED'
                        end
                        if type(scheduler.spawn) ~= 'function' or type(scheduler.wait) ~= 'function' or type(scheduler.clock) ~= 'function' then
                            return nil, 'HTTP_SCHEDULER'
                        end

                        local finished, expired = false, false
                        local response = nil
                        local failure = nil
                        local scheduled = pcall(scheduler.spawn, function()
                            local ok, status, body = pcall(transport, url)

                            if expired then
                                return
                            end
                            if not ok then
                                failure = 'HTTP_FAILED'
                            elseif status ~= 200 then
                                failure = 'HTTP_STATUS'
                            elseif type(body) ~= 'string' or #body == 0 or #body > maxBytes then
                                failure = 'HTTP_BODY'
                            else
                                response = body
                            end

                            finished = true
                        end)

                        if not scheduled then
                            return nil, 'HTTP_SCHEDULER'
                        end

                        local started = scheduler.clock()

                        while not finished and scheduler.clock() - started < timeout do
                            local waited = pcall(scheduler.wait, 0.05)

                            if not waited then
                                expired = true

                                return nil, 'HTTP_SCHEDULER'
                            end
                        end

                        if not finished then
                            expired = true

                            return nil, 'HTTP_TIMEOUT'
                        end

                        return response, failure
                    end,
                }
            end

            return HttpClient
        end

        function __DARKLUA_BUNDLE_MODULES.q()
            local v = __DARKLUA_BUNDLE_MODULES.cache.q

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.q = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Version = {}

            function Version.parse(value)
                if type(value) ~= 'string' or #value > 32 then
                    return nil
                end

                local major, minor, patch = value:match('^(%d+)%.(%d+)%.(%d+)$')

                if not major then
                    return nil
                end

                return {
                    (tonumber(major)),
                    (tonumber(minor)),
                    (tonumber(patch)),
                }
            end
            function Version.compare(left, right)
                local a, b = Version.parse(left), Version.parse(right)

                if not a or not b then
                    return nil
                end

                for index = 1, 3 do
                    if a[index] < b[index] then
                        return -1
                    end
                    if a[index] > b[index] then
                        return 1
                    end
                end

                return 0
            end

            return Version
        end

        function __DARKLUA_BUNDLE_MODULES.r()
            local v = __DARKLUA_BUNDLE_MODULES.cache.r

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.r = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            return {}
        end

        function __DARKLUA_BUNDLE_MODULES.s()
            local v = __DARKLUA_BUNDLE_MODULES.cache.s

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.s = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Validation = __DARKLUA_BUNDLE_MODULES.e()
            local Version = __DARKLUA_BUNDLE_MODULES.r()
            local Types = __DARKLUA_BUNDLE_MODULES.s()
            local ManifestClient = {}

            function ManifestClient.validate(value, repository, targetGameId)
                if type(value) ~= 'table' then
                    return nil
                end

                local data = value

                if data.schemaVersion ~= 1 or (data.mode ~= 'release' and data.mode ~= 'development') or data.repository ~= repository or (data.sourceCommit ~= nil and (type(data.sourceCommit) ~= 'string' or #data.sourceCommit > 128)) or (data.artifactRevision ~= nil and (type(data.artifactRevision) ~= 'string' or #data.artifactRevision > 128)) or not Version.parse(data.version) or not Version.parse(data.loaderVersion) or not Version.parse(data.minLoaderVersion) or type(data.artifacts) ~= 'table' or type(data.games) ~= 'table' then
                    return nil
                end

                local artifacts = data.artifacts
                local games = data.games

                if targetGameId ~= nil and not Validation.identifier(targetGameId) then
                    return nil
                end

                local selected = if targetGameId then{
                    'ui',
                    targetGameId,
                }else{
                    'ui',
                }

                for _, key in selected do
                    local rawArtifact = artifacts[key]

                    if type(rawArtifact) ~= 'table' then
                        return nil
                    end

                    local artifact = rawArtifact
                    local sha = artifact.sha256

                    if not Validation.artifactPath(artifact.path) or (data.mode == 'release' and (sha == nil or artifact.bytes == nil)) or (sha ~= nil and (type(sha) ~= 'string' or #sha ~= 64 or not string.match(sha, '^[a-f0-9]+$'))) or (artifact.bytes ~= nil and (not Validation.isFinite(artifact.bytes) or artifact.bytes % 1 ~= 0 or artifact.bytes <= 0 or artifact.bytes > 4000000)) then
                        return nil
                    end
                end

                if targetGameId then
                    local entry = games[targetGameId]

                    if type(entry) ~= 'table' or not Version.parse(entry.version) or type(entry.lastUpdated) ~= 'string' or not string.match(entry.lastUpdated, '^%d%d%d%d%-%d%d%-%d%d$') or type(entry.name) ~= 'string' or #entry.name == 0 or type(entry.placeIds) ~= 'table' or #entry.placeIds == 0 or (entry.gameIds ~= nil and (type(entry.gameIds) ~= 'table' or #entry.gameIds == 0)) then
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

                return data
            end
            function ManifestClient.status(value, gameId)
                if type(value) ~= 'table' then
                    return nil
                end

                local data = value

                if data.schemaVersion ~= 1 or type(data.games) ~= 'table' then
                    return nil
                end

                local games = data.games
                local entry = games[gameId]

                if type(entry) ~= 'table' then
                    return nil
                end

                local state = entry.state

                if state == 'ready' or state == 'maintenance' or state == 'disabled' then
                    return state
                end

                return nil
            end

            return ManifestClient
        end

        function __DARKLUA_BUNDLE_MODULES.t()
            local v = __DARKLUA_BUNDLE_MODULES.cache.t

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.t = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local ModuleLoader = {}

            function ModuleLoader.load(compile, source, argument)
                if type(compile) ~= 'function' or type(source) ~= 'string' or #source == 0 then
                    return nil, 'MODULE_INPUT'
                end

                local compiled, chunk = pcall(compile, source, 'ViperHubModule')

                if not compiled or type(chunk) ~= 'function' then
                    return nil, 'MODULE_COMPILE'
                end

                local ok, result = pcall(chunk, argument)

                if not ok or type(result) ~= 'table' then
                    return nil, 'MODULE_EXECUTION'
                end

                return result, nil
            end
            function ModuleLoader.isGame(value, id, version)
                return type(value) == 'table' and type(value.metadata) == 'table' and value.metadata.id == id and value.metadata.version == version and type(value.start) == 'function' and type(value.stop) == 'function'
            end

            return ModuleLoader
        end

        function __DARKLUA_BUNDLE_MODULES.u()
            local v = __DARKLUA_BUNDLE_MODULES.cache.u

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.u = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Types = __DARKLUA_BUNDLE_MODULES.i()
            local ENV = getfenv()
            local WINDOW_WIDTH = 600
            local WINDOW_HEIGHT = 400
            local WindUIAdapter = {}

            function WindUIAdapter.own(library, context)
                assert(type(library) == 'table' and type(library.CreateWindow) == 'function', 'UI_CONTRACT')
                context.cleanup.add(function()
                    if library.Creator and library.Creator.DisconnectAll then
                        pcall(library.Creator.DisconnectAll)
                    end

                    local signals = library.Creator and library.Creator.Signals

                    if type(signals) == 'table' then
                        for _, connection in signals do
                            pcall(function()
                                (connection):Disconnect()
                            end)
                        end

                        table.clear(signals)
                    end

                    for _, key in {
                        'ScreenGui',
                        'NotificationGui',
                        'DropdownGui',
                        'TooltipGui',
                    }do
                        local gui = library[key]

                        if gui then
                            pcall(function()
                                gui:Destroy()
                            end)
                        end
                    end
                end)
            end
            function WindUIAdapter.create(library, context, config)
                local window = (library.CreateWindow)(library, {
                    Title = 'ViperHub NextGen',
                    Author = 'Foundation 0.2.2',
                    Theme = 'Dark',
                    NewElements = true,
                    Acrylic = false,
                    Size = if ENV.UDim2 then(ENV.UDim2).fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT)else nil,
                    AutoScale = false,
                    OpenButton = {
                        Title = 'ViperHub',
                        Enabled = true,
                        OnlyMobile = false,
                    },
                })

                if window.SetUIScale then
                    (window.SetUIScale)(window, config.uiScale)
                end
                if window.OnDestroy then
                    (window.OnDestroy)(window, context.destroy)
                end

                return window
            end

            return WindUIAdapter
        end

        function __DARKLUA_BUNDLE_MODULES.v()
            local v = __DARKLUA_BUNDLE_MODULES.cache.v

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.v = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Overview = {}

            function Overview.mount(window, metadata)
                local tab = window:Tab({
                    Title = 'Overview',
                    Icon = 'info',
                })

                tab:Paragraph({
                    Title = metadata.name,
                    Desc = 'Game detected. Foundation only; no gameplay features.',
                })
                tab:Paragraph({
                    Title = 'Module ' .. metadata.version,
                    Desc = 'Last updated: ' .. metadata.lastUpdated,
                })
            end

            return Overview
        end

        function __DARKLUA_BUNDLE_MODULES.w()
            local v = __DARKLUA_BUNDLE_MODULES.cache.w

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.w = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Settings = {}
            local runtimeTask = getfenv().task

            local function applyToggleKey(
                window,
                store,
                keyCodes,
                value,
                control
            )
                local previous = store.get().toggleKey

                store.update('toggleKey', value)

                local selected = store.get().toggleKey

                if selected ~= value and type(control) == 'table' and type(control.Set) == 'function' then
                    (control.Set)(control, previous)
                end

                window:SetToggleKey(keyCodes[selected])
            end

            function Settings.mount(window, store, library, keyCodes, context)
                local config = store.get()
                local tab = window:Tab({
                    Title = 'Settings',
                    Icon = 'settings',
                })
                local controls = {}

                window.ViperControls = controls

                tab:Paragraph({
                    Title = 'Storage',
                    Desc = if store.persistent then'File persistence available'else'Session only: filesystem APIs unavailable',
                })

                controls.notifications = tab:Toggle({
                    Title = 'Notifications',
                    Value = config.notifications,
                    Callback = function(value)
                        store.update('notifications', value)
                    end,
                })
                controls.uiScale = tab:Slider({
                    Title = 'UI scale',
                    Step = 0.05,
                    Value = {
                        Min = 0.8,
                        Max = 1.3,
                        Default = config.uiScale,
                    },
                    Callback = function(value)
                        store.update('uiScale', value)

                        if window.SetUIScale then
                            (window.SetUIScale)(window, store.get().uiScale)
                        end
                    end,
                })
                controls.theme = tab:Dropdown({
                    Title = 'Theme',
                    Values = {
                        'Dark',
                    },
                    Value = config.theme,
                    Callback = function(value)
                        store.update('theme', value)
                    end,
                })

                window:SetToggleKey(keyCodes[config.toggleKey])

                controls.toggleKey = tab:Keybind({
                    Title = 'Toggle UI key',
                    Value = config.toggleKey,
                    Callback = function(value)
                        applyToggleKey(window, store, keyCodes, value, controls.toggleKey)
                    end,
                })

                local keyUi = controls.toggleKey and controls.toggleKey.UIElements and controls.toggleKey.UIElements.Keybind
                local keyFrame = keyUi and keyUi.Frame and keyUi.Frame.Frame
                local keyLabel = keyFrame and keyFrame.TextLabel

                if context and keyLabel and type(keyLabel.GetPropertyChangedSignal) == 'function' and type(runtimeTask) == 'table' and type(runtimeTask.defer) == 'function' then
                    local connection = keyLabel:GetPropertyChangedSignal('Text'):Connect(function(
                    )
                        runtimeTask.defer(function()
                            if context.alive and controls.toggleKey.Value ~= store.get().toggleKey then
                                applyToggleKey(window, store, keyCodes, controls.toggleKey.Value, controls.toggleKey)
                            end
                        end)
                    end)

                    context.cleanup.add(function()
                        connection:Disconnect()
                    end)
                end

                controls.save = tab:Button({
                    Title = 'Save settings',
                    Callback = function()
                        applyToggleKey(window, store, keyCodes, controls.toggleKey.Value, controls.toggleKey)
                        controls.toggleKey:Set(store.get().toggleKey)

                        local saved = store.save()

                        if saved and not store.get().notifications then
                            return
                        end

                        library:Notify({
                            Title = 'Settings',
                            Content = if saved then'Saved and read back'else'Not saved; inspect Diagnostics',
                            Duration = 4,
                        })
                    end,
                })
            end

            return Settings
        end

        function __DARKLUA_BUNDLE_MODULES.x()
            local v = __DARKLUA_BUNDLE_MODULES.cache.x

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.x = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Diagnostics = {}

            function Diagnostics.mount(window, buffer)
                local tab = window:Tab({
                    Title = 'Diagnostics',
                    Icon = 'activity',
                })
                local paragraph = tab:Paragraph({
                    Title = 'Status codes',
                    Desc = table.concat(buffer.snapshot(), '\n'),
                })

                local function refresh()
                    paragraph:SetDesc(table.concat(buffer.snapshot(), '\n'))
                end

                tab:Button({
                    Title = 'Refresh',
                    Callback = refresh,
                })

                return refresh
            end

            return Diagnostics
        end

        function __DARKLUA_BUNDLE_MODULES.y()
            local v = __DARKLUA_BUNDLE_MODULES.cache.y

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.y = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Adapter = __DARKLUA_BUNDLE_MODULES.v()
            local Overview = __DARKLUA_BUNDLE_MODULES.w()
            local Settings = __DARKLUA_BUNDLE_MODULES.x()
            local Diagnostics = __DARKLUA_BUNDLE_MODULES.y()
            local App = {}

            function App.mount(
                library,
                context,
                metadata,
                store,
                buffer,
                keyCodes
            )
                local window = Adapter.create(library, context, store.get())

                Overview.mount(window, metadata)
                Settings.mount(window, store, library, keyCodes, context)

                local refreshDiagnostics = Diagnostics.mount(window, buffer)

                window:SelectTab(1)

                return window, refreshDiagnostics
            end

            return App
        end

        function __DARKLUA_BUNDLE_MODULES.z()
            local v = __DARKLUA_BUNDLE_MODULES.cache.z

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.z = v
            end

            return v.c
        end
    end
end

local Detector = __DARKLUA_BUNDLE_MODULES.f()
local Context = __DARKLUA_BUNDLE_MODULES.j()
local Diagnostics = __DARKLUA_BUNDLE_MODULES.k()
local Capabilities = __DARKLUA_BUNDLE_MODULES.l()
local FileStorage = __DARKLUA_BUNDLE_MODULES.m()
local ConfigStore = __DARKLUA_BUNDLE_MODULES.p()
local HttpClient = __DARKLUA_BUNDLE_MODULES.q()
local ManifestClient = __DARKLUA_BUNDLE_MODULES.t()
local ModuleLoader = __DARKLUA_BUNDLE_MODULES.u()
local Version = __DARKLUA_BUNDLE_MODULES.r()
local Validation = __DARKLUA_BUNDLE_MODULES.e()
local App = __DARKLUA_BUNDLE_MODULES.z()
local UIAdapter = __DARKLUA_BUNDLE_MODULES.v()
local LOADER_VERSION = '0.2.2'
local TIMEOUT_SECONDS = 15
local NOTIFY_RETRY_SECONDS = 0.2
local NOTIFY_MAX_ATTEMPTS = 5
local MAX_METADATA_BYTES = 65536
local MAX_MODULE_BYTES = 4000000
local ENV = getfenv()
local gameObject = ENV.game

if not gameObject then
    return {
        state = 'unavailable',
        code = 'ROBLOX_REQUIRED',
    }
end

local starterGui = gameObject:GetService('StarterGui')
local httpService = gameObject:GetService('HttpService')
local runtimeTask = ENV.task
local sharedState = ENV.shared

if type(sharedState) ~= 'table' or type(runtimeTask) ~= 'table' then
    return {
        state = 'unavailable',
        code = 'RUNTIME_REQUIRED',
    }
end

local session = {}

local function notify(message, critical)
    if critical ~= true then
        local config = session.config

        if config ~= nil and config.get().notifications == false then
            return
        end
    end

    local function send()
        local ok = pcall(function()
            starterGui:SetCore('SendNotification', {
                Title = 'ViperHub NextGen',
                Text = message,
                Duration = 8,
            })
        end)

        return ok
    end

    if send() or critical ~= true then
        return
    end
    if type(runtimeTask.spawn) == 'function' and type(runtimeTask.wait) == 'function' then
        pcall(runtimeTask.spawn, function()
            for _ = 2, NOTIFY_MAX_ATTEMPTS do
                runtimeTask.wait(NOTIFY_RETRY_SECONDS)

                if sharedState.ViperHubNextGen ~= session or send() then
                    return
                end
            end
        end)
    end
end

local old = sharedState.ViperHubNextGen

if type(old) == 'table' and type(old.destroy) == 'function' then
    pcall(old.destroy)
end

local buffer = Diagnostics.new(64)
local context = Context.new(buffer.push)

session = {
    context = context,
    diagnostics = buffer.snapshot,
    destroy = context.destroy,
}
sharedState.ViperHubNextGen = session

local function fail(code, message)
    buffer.push(code)
    context.destroy('failed')
    notify(message, true)
end

local metadata = Detector.detect(gameObject.PlaceId, gameObject.GameId)

if not metadata then
    context.destroy('unsupported')
    notify('Unsupported game. Place: ' .. tostring(gameObject.PlaceId), true)

    return session
end

context.gameId = metadata.id

assert(context.transition('loading'))

local caps = Capabilities.detect(ENV)

session.capabilities = caps

local function decode(text)
    return httpService:JSONDecode(text)
end
local function run()
    local store = ConfigStore.new(FileStorage.new(ENV, metadata.id), decode, function(
        value
    )
        return httpService:JSONEncode(value)
    end, buffer.push)

    session.config = store

    if not caps.compile then
        fail('COMPILE_UNAVAILABLE', 'This environment cannot load modules.')

        return
    end

    local localArtifacts = ENV.VIPER_DEV_ARTIFACTS
    local exports = {}
    local manifest

    if type(localArtifacts) == 'table' then
        manifest = localArtifacts.manifest

        if type(manifest) ~= 'table' or manifest.mode ~= 'development' then
            fail('DEV_MANIFEST_INVALID', 'Invalid development harness.')

            return
        end

        for _, id in {
            metadata.id,
            'ui',
        }do
            if not context.alive then
                return
            end

            local source = localArtifacts[id]
            local value, code = ModuleLoader.load(ENV.loadstring, source, buffer.push)

            if not value then
                fail(code or 'MODULE_FAILED', 'Could not load development module.')

                return
            end

            exports[id] = value

            if id == 'ui' then
                UIAdapter.own(value, context)
            end
        end
    else
        local repository = ENV.VIPER_REPOSITORY or 'phiraphatdev/ViperHub-NextGen'

        if type(repository) ~= 'string' or not string.match(repository, '^[%w_-]+/[%w_.-]+$') then
            fail('REPOSITORY_UNCONFIGURED', 
[[GitHub repository is not configured. Use the local smoke harness.]])

            return
        end

        local requester = if type(ENV.request) == 'function'then ENV.request else ENV.http_request
        local client = HttpClient.new(function(url)
            if caps.request then
                local options = {
                    Url = url,
                    Method = 'GET',
                }
                local ok, result = pcall(requester, options)

                if (not ok or type(result) ~= 'table') and requester ~= ENV.http_request and type(ENV.http_request) == 'function' then
                    ok, result = pcall(ENV.http_request, options)
                end
                if not ok then
                    return 0, nil
                end
                if type(result) ~= 'table' then
                    return 0, nil
                end

                return result.StatusCode, result.Body
            end

            return 200, gameObject:HttpGet(url)
        end, {
            spawn = runtimeTask.spawn,
            wait = runtimeTask.wait,
            clock = os.clock,
        })
        local base = 'https://raw.githubusercontent.com/' .. repository .. '/'

        local function json(file)
            local body, code = client.get(base .. 'main/' .. file, MAX_METADATA_BYTES, TIMEOUT_SECONDS)

            if not body then
                buffer.push(code or 'HTTP_FAILED')

                return nil
            end

            local ok, value = pcall(decode, body)

            if not ok then
                buffer.push('JSON_INVALID')

                return nil
            end

            return value
        end

        manifest = ManifestClient.validate(json('manifest.json'), repository, metadata.id)

        if not context.alive then
            return
        end
        if not manifest then
            fail('MANIFEST_INVALID', 'Release metadata unavailable or invalid.')

            return
        end
        if manifest.mode ~= 'release' then
            fail('MANIFEST_INVALID', 'Development metadata cannot be loaded as a release.')

            return
        end

        local publishedGame = manifest.games[metadata.id]
        local localPlace = table.find(metadata.placeIds, gameObject.PlaceId) ~= nil
        local publishedPlace = table.find(publishedGame.placeIds, gameObject.PlaceId) ~= nil

        if localPlace ~= publishedPlace then
            fail('REGISTRY_MISMATCH', 'Published game registry differs from this loader.')

            return
        end
        if not localPlace then
            local releaseUniverses = publishedGame.gameIds

            if not releaseUniverses or not table.find(releaseUniverses, gameObject.GameId) then
                fail('GAME_UNAVAILABLE', 'This match place is not in the published game registry.')

                return
            end
        end
        if (Version.compare(LOADER_VERSION, manifest.minLoaderVersion) or -1) < 0 then
            fail('LOADER_OUTDATED', 'Update the ViperHub loader.')

            return
        end

        local status = ManifestClient.status(json('status.json'), metadata.id)

        if not context.alive then
            return
        end
        if status ~= 'ready' then
            fail('GAME_UNAVAILABLE', if status == 'maintenance'then'\u{e40}\u{e01}\u{e21}\u{e19}\u{e35}\u{e49}\u{e01}\u{e33}\u{e25}\u{e31}\u{e07}\u{e2d}\u{e31}\u{e1b}\u{e40}\u{e14}\u{e15} \u{e01}\u{e23}\u{e38}\u{e13}\u{e32}\u{e23}\u{e2d}'else'Game module unavailable; status could not be confirmed.')

            return
        end
        if (Version.compare(metadata.version, manifest.games[metadata.id].version) or 0) < 0 then
            notify(
[[A newer game module is available; loading the release version.]])
        end

        for _, id in {
            metadata.id,
            'ui',
        }do
            local artifact = manifest.artifacts[id]
            local revision = if Validation.sha(manifest.artifactRevision)then manifest.artifactRevision else'main'
            local body, code = client.get(base .. revision .. '/' .. artifact.path, MAX_MODULE_BYTES, TIMEOUT_SECONDS)

            if not context.alive then
                return
            end
            if not body then
                fail(code or 'HTTP_FAILED', 'Module download failed.')

                return
            end
            if type(artifact.bytes) ~= 'number' or #body ~= artifact.bytes then
                fail('ARTIFACT_SIZE_MISMATCH', 'Downloaded module size does not match release metadata.')

                return
            end

            local crypto = ENV.crypt

            if type(crypto) ~= 'table' or type(crypto.hash) ~= 'function' then
                fail('HASH_UNAVAILABLE', 'This environment cannot verify release modules.')

                return
            end

            local hashOk, digest = pcall(crypto.hash, body, 'sha256')

            if not hashOk or type(digest) ~= 'string' or string.lower(digest) ~= artifact.sha256 then
                fail('ARTIFACT_HASH_MISMATCH', 'Downloaded module failed integrity verification.')

                return
            end

            local value, loadCode = ModuleLoader.load(ENV.loadstring, body, buffer.push)

            if not value then
                fail(loadCode or 'MODULE_FAILED', 'Module could not start.')

                return
            end

            exports[id] = value

            if id == 'ui' then
                UIAdapter.own(value, context)
            end
        end
    end
    if not context.alive then
        return
    end

    local gameModule = exports[metadata.id]
    local expectedVersion = if manifest.games and manifest.games[metadata.id]then manifest.games[metadata.id].version else metadata.version

    if not ModuleLoader.isGame(gameModule, metadata.id, expectedVersion) then
        fail('GAME_CONTRACT', 'Game module version or interface mismatch.')

        return
    end

    local window, refreshDiagnostics = App.mount(exports.ui, context, gameModule.metadata, store, buffer, ENV.Enum.KeyCode)

    session.window = window

    context.cleanup.add(gameModule.stop)
    gameModule.start(context)

    if not context.alive then
        return
    end

    assert(context.transition('ready'))
    buffer.push('FOUNDATION_READY')
    refreshDiagnostics()
end

local ok, err = pcall(run)

if not ok then
    if type(err) == 'string' then
        if string.find(err, 'UI_CONTRACT', 1, true) then
            buffer.push('UI_CONTRACT')
        end
    end

    fail('STARTUP_FAILED', 
[[ViperHub startup failed. Inspect the private diagnostics buffer.]])
end

return session
