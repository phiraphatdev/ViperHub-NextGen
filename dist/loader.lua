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
            local VERSION = '0.3.0'
            local LAST_UPDATED = '2026-10-04'
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
            local VERSION = '0.3.0'
            local LAST_UPDATED = '2026-10-04'
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
                theme = 'Viper',
                toggleKey = 'RightShift',
                openButton = true,
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
            local THEME_VERSION = 2
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
                    themeVersion = THEME_VERSION,
                    toggleKey = Defaults.toggleKey,
                    openButton = Defaults.openButton,
                }

                if type(value) ~= 'table' then
                    return output, false
                end

                local data = value

                if data.schemaVersion ~= 1 then
                    return output, false
                end
                if type(data.openButton) == 'boolean' then
                    output.openButton = data.openButton
                end
                if type(data.notifications) == 'boolean' then
                    output.notifications = data.notifications
                end

                output.uiScale = Validation.number(data.uiScale, 0.8, 1.3, Defaults.uiScale)

                local theme = data.theme

                if type(theme) == 'string' and #theme > 0 and #theme <= 32 and string.match(theme, '^[%w %-]+$') ~= nil and (theme ~= 'Dark' or data.themeVersion == THEME_VERSION) then
                    output.theme = theme
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

                local function save()
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

                        save()
                    end,
                    save = save,
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
                if type(value) ~= 'table' then
                    return false
                end
                if value.pages ~= nil then
                    if type(value.pages) ~= 'table' or #value.pages > 16 then
                        return false
                    end

                    for _, page in value.pages do
                        if type(page) ~= 'table' or type(page.title) ~= 'string' or #page.title == 0 or #page.title > 40 or type(page.description) ~= 'string' or #page.description > 200 or (page.icon ~= nil and (type(page.icon) ~= 'string' or #page.icon > 40)) or (page.render ~= nil and type(page.render) ~= 'function') or (page.group ~= nil and (type(page.group) ~= 'string' or #page.group == 0 or #page.group > 24)) or (page.iconColor ~= nil and (type(page.iconColor) ~= 'string' or #page.iconColor > 16)) or (page.home ~= nil and type(page.home) ~= 'boolean') then
                            return false
                        end
                    end
                end

                return type(value.metadata) == 'table' and value.metadata.id == id and value.metadata.version == version and type(value.start) == 'function' and type(value.stop) == 'function'
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
            local Theme = {}

            Theme.DEFAULT = 'Viper'

            local BACKDROP_TINT = 0.12
            local BACKDROP_ROTATION = 125
            local BACKDROP_STOPS = 10

            Theme.colors = table.freeze({
                primary = '#10b981',
                secondary = '#2dd4bf',
                gold = '#fbbf24',
                blue = '#38bdf8',
                violet = '#a78bfa',
                rose = '#fb7185',
                orange = '#fb923c',
                slate = '#94a3b8',
            })
            Theme.SPECS = table.freeze({
                {
                    name = 'Viper',
                    accent = '#0b3b2e',
                    dialog = '#071a15',
                    outline = '#34d399',
                    text = '#ecfdf5',
                    placeholder = '#6ee7b7',
                    background = {
                        '#030d0b',
                        '#0a231d',
                    },
                    button = {
                        '#059669',
                        '#14b8a6',
                    },
                    icon = '#34d399',
                    element = '#0f2a23',
                },
                {
                    name = 'Sakura',
                    accent = '#4a1530',
                    dialog = '#2a0b1b',
                    outline = '#f9a8d4',
                    text = '#fdf2f8',
                    placeholder = '#f9a8d4',
                    background = {
                        '#14060d',
                        '#2b0d1d',
                    },
                    button = {
                        '#ec4899',
                        '#f472b6',
                    },
                    icon = '#f472b6',
                    element = '#2e1220',
                },
                {
                    name = 'Ocean',
                    accent = '#0c3352',
                    dialog = '#061a2b',
                    outline = '#38bdf8',
                    text = '#e0f2fe',
                    placeholder = '#7dd3fc',
                    background = {
                        '#020b14',
                        '#06223a',
                    },
                    button = {
                        '#0284c7',
                        '#06b6d4',
                    },
                    icon = '#38bdf8',
                    element = '#0b2538',
                },
                {
                    name = 'Sunset',
                    accent = '#4a1d12',
                    dialog = '#2a0f0a',
                    outline = '#fb923c',
                    text = '#fff7ed',
                    placeholder = '#fdba74',
                    background = {
                        '#140805',
                        '#2e0f16',
                    },
                    button = {
                        '#f97316',
                        '#e11d48',
                    },
                    icon = '#fb923c',
                    element = '#2c1612',
                },
                {
                    name = 'Galaxy',
                    accent = '#2e1065',
                    dialog = '#160734',
                    outline = '#a78bfa',
                    text = '#f5f3ff',
                    placeholder = '#c4b5fd',
                    background = {
                        '#07041a',
                        '#1a0b3d',
                    },
                    button = {
                        '#7c3aed',
                        '#4f46e5',
                    },
                    icon = '#a78bfa',
                    element = '#1c1238',
                },
                {
                    name = 'Blood Moon',
                    accent = '#450a0a',
                    dialog = '#1f0505',
                    outline = '#f87171',
                    text = '#fef2f2',
                    placeholder = '#fca5a5',
                    background = {
                        '#0a0202',
                        '#230606',
                    },
                    button = {
                        '#b91c1c',
                        '#ef4444',
                    },
                    icon = '#f87171',
                    element = '#2a0d0d',
                },
                {
                    name = 'Gold Rush',
                    accent = '#3a2a06',
                    dialog = '#1c1404',
                    outline = '#fbbf24',
                    text = '#fffbeb',
                    placeholder = '#fcd34d',
                    background = {
                        '#0a0803',
                        '#1f1706',
                    },
                    button = {
                        '#d97706',
                        '#facc15',
                    },
                    icon = '#fbbf24',
                    element = '#26200f',
                },
                {
                    name = 'Frost',
                    accent = '#16384a',
                    dialog = '#0b1e29',
                    outline = '#a5f3fc',
                    text = '#f0fdff',
                    placeholder = '#a5f3fc',
                    background = {
                        '#06121a',
                        '#0f2a36',
                    },
                    button = {
                        '#22d3ee',
                        '#93c5fd',
                    },
                    icon = '#67e8f9',
                    element = '#13303d',
                },
                {
                    name = 'Matrix',
                    accent = '#052e16',
                    dialog = '#021a0c',
                    outline = '#22c55e',
                    text = '#dcfce7',
                    placeholder = '#4ade80',
                    background = {
                        '#000000',
                        '#03140a',
                    },
                    button = {
                        '#16a34a',
                        '#22c55e',
                    },
                    icon = '#22c55e',
                    element = '#071a0e',
                },
                {
                    name = 'Cyberpunk',
                    accent = '#3b0a45',
                    dialog = '#1d0624',
                    outline = '#facc15',
                    text = '#fefce8',
                    placeholder = '#f0abfc',
                    background = {
                        '#0b0418',
                        '#25082f',
                    },
                    button = {
                        '#d946ef',
                        '#facc15',
                    },
                    icon = '#f0abfc',
                    element = '#22102c',
                },
                {
                    name = 'Lava',
                    accent = '#4a1a04',
                    dialog = '#260c02',
                    outline = '#fb923c',
                    text = '#fff7ed',
                    placeholder = '#fdba74',
                    background = {
                        '#120501',
                        '#2e0d02',
                    },
                    button = {
                        '#dc2626',
                        '#f97316',
                    },
                    icon = '#f97316',
                    element = '#2d1408',
                },
                {
                    name = 'Royal',
                    accent = '#2e1a4a',
                    dialog = '#170c26',
                    outline = '#fbbf24',
                    text = '#faf5ff',
                    placeholder = '#d8b4fe',
                    background = {
                        '#0b0614',
                        '#1e1033',
                    },
                    button = {
                        '#7e22ce',
                        '#d97706',
                    },
                    icon = '#c084fc',
                    element = '#201433',
                },
                {
                    name = 'Toxic',
                    accent = '#283a06',
                    dialog = '#141d03',
                    outline = '#a3e635',
                    text = '#f7fee7',
                    placeholder = '#bef264',
                    background = {
                        '#070a01',
                        '#172206',
                    },
                    button = {
                        '#65a30d',
                        '#a3e635',
                    },
                    icon = '#a3e635',
                    element = '#1a240b',
                },
                {
                    name = 'Shadow',
                    accent = '#1f1f23',
                    dialog = '#111113',
                    outline = '#a1a1aa',
                    text = '#fafafa',
                    placeholder = '#a1a1aa',
                    background = {
                        '#050505',
                        '#141416',
                    },
                    button = {
                        '#3f3f46',
                        '#71717a',
                    },
                    icon = '#d4d4d8',
                    element = '#18181b',
                },
            })

            local BUILT_IN_ORDER = {
                'Dark',
                'Light',
                'Emerald',
                'Midnight',
                'Crimson',
                'Rose',
                'Violet',
                'Indigo',
                'Sky',
                'Amber',
            }

            local function customNames()
                local names = {}

                for _, spec in Theme.SPECS do
                    table.insert(names, spec.name)
                end

                return names
            end

            function Theme.list(library)
                local names = customNames()
                local themes = if type(library) == 'table' and type(library.Themes) == 'table'then library.Themes else nil

                if not themes then
                    table.insert(names, 'Dark')

                    return names
                end

                for _, name in BUILT_IN_ORDER do
                    if themes[name] ~= nil and not table.find(names, name) then
                        table.insert(names, name)
                    end
                end

                local rest = {}

                for name in themes do
                    if type(name) == 'string' and not table.find(names, name) then
                        table.insert(rest, name)
                    end
                end

                table.sort(rest)

                for _, name in rest do
                    table.insert(names, name)
                end

                return names
            end
            function Theme.register(library, preferred)
                local env = getfenv()
                local color3 = env.Color3

                if type(library) ~= 'table' or type(library.AddTheme) ~= 'function' or type(library.Gradient) ~= 'function' or color3 == nil then
                    return 'Dark'
                end

                local lib = library

                local function hex(value)
                    return color3.fromHex(value)
                end
                local function gradient(colors, rotation)
                    return (lib.Gradient)(lib, {
                        ['0'] = {
                            Color = colors[1],
                            Transparency = 0,
                        },
                        ['100'] = {
                            Color = colors[2],
                            Transparency = 0,
                        },
                    }, {Rotation = rotation})
                end
                local function backdrop(spec)
                    local from = hex(spec.background[1])
                    local body = hex(spec.background[2])
                    local tint = body:Lerp(hex(spec.button[1]), BACKDROP_TINT)
                    local stops = {}

                    for step = 0, BACKDROP_STOPS do
                        local t = step / BACKDROP_STOPS
                        local eased = t * t * (3 - 2 * t)
                        local color = if eased < 0.5 then from:Lerp(body, eased * 2)else body:Lerp(tint, (eased - 0.5) * 2)

                        stops[tostring(math.floor(t * 100 + 0.5))] = {
                            Color = color,
                            Transparency = 0,
                        }
                    end

                    return (lib.Gradient)(lib, stops, {Rotation = BACKDROP_ROTATION})
                end

                for _, spec in Theme.SPECS do
                    pcall(function()
                        (lib.AddTheme)(lib, {
                            Name = spec.name,
                            Accent = hex(spec.accent),
                            Dialog = hex(spec.dialog),
                            Outline = hex(spec.outline),
                            Text = hex(spec.text),
                            Placeholder = hex(spec.placeholder),
                            Background = backdrop(spec),
                            Button = gradient(spec.button, 45),
                            Icon = hex(spec.icon),
                            Toggle = gradient(spec.button, 45),
                            Slider = hex(spec.button[1]),
                            Checkbox = gradient(spec.button, 45),
                            Primary = hex(spec.button[1]),
                            SliderIcon = hex(spec.placeholder),
                            PanelBackground = hex('#FFFFFF'),
                            PanelBackgroundTransparency = 0.96,
                            LabelBackground = hex('#000000'),
                            LabelBackgroundTransparency = 0.78,
                            ElementBackground = hex(spec.element),
                            ElementBackgroundTransparency = 0,
                        })
                    end)
                end

                local themes = if type(lib.Themes) == 'table'then lib.Themes else{}

                if preferred and themes[preferred] ~= nil then
                    return preferred
                end

                return if themes[Theme.DEFAULT] ~= nil then Theme.DEFAULT else'Dark'
            end
            function Theme.color(value)
                local env = getfenv()
                local color3 = env.Color3

                if color3 == nil then
                    return nil
                end

                local text = (Theme.colors)[value] or value
                local ok, result = pcall(color3.fromHex, text)

                return if ok then result else nil
            end

            return Theme
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
            local Theme = __DARKLUA_BUNDLE_MODULES.v()
            local ENV = getfenv()
            local MIN_WIDTH = 110
            local MIN_HEIGHT = 26
            local MAX_HEIGHT = 200
            local GLOW_NAME = 'ViperGlow'
            local SCALE_NAME = 'ViperTitleScale'
            local GLOW_ALPHA = 0.8
            local FADE_SECONDS = 0.18
            local CORNER_RADIUS = 14
            local MAX_DEPTH = 8
            local SECTION_RATIO = 1.5
            local EDGE_FADE = 0.55
            local STROKE_ALPHA = 0.35
            local STROKE_THICKNESS = 1.5
            local TITLE_SCALE = 1.06
            local TITLE_SECONDS = 0.16
            local RIPPLE_SECONDS = 0.5
            local RIPPLE_ALPHA = 0.65
            local HoverGlow = {}

            local function isButton(object)
                return object:IsA('TextButton') or object:IsA('ImageButton')
            end
            local function fit(frame, card)
                local pad = card:FindFirstChildOfClass('UIPadding')
                local width = card.AbsoluteSize.X
                local height = card.AbsoluteSize.Y
                local left, top = 0, 0

                if pad then
                    left = pad.PaddingLeft.Scale * width + pad.PaddingLeft.Offset
                    top = pad.PaddingTop.Scale * height + pad.PaddingTop.Offset
                end

                frame.Size = ENV.UDim2.fromOffset(width, height)
                frame.Position = ENV.UDim2.fromOffset(-left, -top)
            end
            local function corner(parent, radius)
                local item = ENV.Instance.new('UICorner')

                item.CornerRadius = radius
                item.Parent = parent
            end
            local function buildGlow(card, color)
                local create = ENV.Instance
                local glow = create.new('Frame')

                glow.Name = GLOW_NAME
                glow.BackgroundColor3 = color
                glow.BackgroundTransparency = 1
                glow.BorderSizePixel = 0
                glow.ZIndex = 1
                glow.Active = false

                corner(glow, ENV.UDim.new(0, CORNER_RADIUS))

                local gradient = create.new('UIGradient')

                gradient.Transparency = ENV.NumberSequence.new({
                    ENV.NumberSequenceKeypoint.new(0, EDGE_FADE),
                    ENV.NumberSequenceKeypoint.new(0.5, 0),
                    ENV.NumberSequenceKeypoint.new(1, EDGE_FADE),
                })
                gradient.Parent = glow

                local stroke = create.new('UIStroke')

                stroke.Name = 'Edge'
                stroke.ApplyStrokeMode = ENV.Enum.ApplyStrokeMode.Border
                stroke.Color = color
                stroke.Thickness = STROKE_THICKNESS
                stroke.Transparency = 1
                stroke.Parent = glow
                glow.Parent = card

                fit(glow, card)

                return glow
            end
            local function themeColor(library)
                local theme = if type(library) == 'table'then library.Theme else nil
                local value = if type(theme) == 'table'then theme.Outline else nil

                if type(value) == 'userdata' or type(value) == 'vector' then
                    return value
                end

                return Theme.color('primary')
            end

            function HoverGlow.attach(library, cleanup)
                local gui = if type(library) == 'table'then library.ScreenGui else nil
                local color = themeColor(library)

                if gui == nil or color == nil or ENV.Instance == nil or ENV.UDim2 == nil or ENV.NumberSequence == nil then
                    return
                end

                local tweenService = nil
                local inputService = nil

                pcall(function()
                    tweenService = (ENV.game):GetService('TweenService')
                    inputService = (ENV.game):GetService('UserInputService')
                end)

                local connections = {}
                local created = {}
                local wired = (setmetatable({}, {
                    __mode = 'k',
                }))

                local function tween(object, seconds, goal, style)
                    if tweenService then
                        pcall(function()
                            local info = ENV.TweenInfo.new(seconds, style or ENV.Enum.EasingStyle.Quad, ENV.Enum.EasingDirection.Out)

                            tweenService:Create(object, info, goal):Play()
                        end)
                    else
                        for key, value in goal do
                            object[key] = value
                        end
                    end
                end
                local function wire(button)
                    if wired[button] then
                        return
                    end

                    wired[button] = true

                    local glow = nil
                    local scale = nil
                    local hovered = false

                    local function card()
                        local node = button

                        for _ = 1, MAX_DEPTH do
                            if node:IsA('ImageButton') and node.AbsoluteSize.X >= MIN_WIDTH then
                                return node
                            end
                            if node:IsA('ImageLabel') and node.AbsoluteSize.X >= MIN_WIDTH then
                                return if node.AbsoluteSize.Y <= button.AbsoluteSize.Y * SECTION_RATIO then node else button
                            end

                            local parent = node.Parent

                            if parent == nil then
                                break
                            end
                            if parent:IsA('ScrollingFrame') then
                                return node
                            end

                            node = parent
                        end

                        return button
                    end
                    local function eligible()
                        local owner = if glow and glow.Parent then glow.Parent else card()

                        return owner.AutomaticSize == ENV.Enum.AutomaticSize.None and button.AutomaticSize == ENV.Enum.AutomaticSize.None and button.AbsoluteSize.X >= MIN_WIDTH and button.AbsoluteSize.Y >= MIN_HEIGHT and button.AbsoluteSize.Y <= MAX_HEIGHT and button:GetAttribute('NoGlow') ~= true
                    end
                    local function follow()
                        if not glow or not inputService then
                            return
                        end

                        local owner = glow.Parent
                        local mouse = inputService:GetMouseLocation()
                        local width = math.max(owner.AbsoluteSize.X, 1)
                        local fraction = math.clamp((mouse.X - owner.AbsolutePosition.X) / width, 0, 1)
                        local gradient = glow:FindFirstChildOfClass('UIGradient')

                        if gradient then
                            gradient.Offset = ENV.Vector2.new(fraction - 0.5, 0)
                        end
                    end

                    local title = nil

                    local function titleIn(root)
                        local best = nil

                        for _, descendant in root:GetDescendants()do
                            local item = descendant

                            if item:IsA('TextLabel') and item.Text ~= '' and item.AbsoluteSize.X > 0 then
                                local inTitle = item.Parent ~= nil and item.Parent.Name == 'TitleFrame'

                                if inTitle then
                                    return item
                                end
                                if not best or item.TextSize > best.TextSize then
                                    best = item
                                end
                            end
                        end

                        return best
                    end
                    local function titleOf(owner)
                        return titleIn(button) or titleIn(owner)
                    end
                    local function grow(target)
                        local owner = glow and glow.Parent

                        if not owner then
                            return
                        end
                        if not title or not title.Parent then
                            title = titleOf(owner)
                            scale = nil
                        end
                        if not title then
                            return
                        end
                        if not scale or scale.Parent ~= title then
                            local existing = title:FindFirstChildOfClass('UIScale')

                            if existing and existing.Name ~= SCALE_NAME then
                                return
                            end

                            scale = existing or ENV.Instance.new('UIScale')
                            scale.Name = SCALE_NAME
                            scale.Parent = title

                            table.insert(created, scale)
                        end

                        tween(scale, TITLE_SECONDS, {Scale = target})
                    end
                    local function ripple()
                        if not glow or not inputService then
                            return
                        end

                        local create = ENV.Instance
                        local group = create.new('CanvasGroup')

                        group.Name = 'Ripple'
                        group.BackgroundTransparency = 1
                        group.Size = ENV.UDim2.fromScale(1, 1)
                        group.Active = false

                        corner(group, ENV.UDim.new(0, CORNER_RADIUS))

                        local mouse = inputService:GetMouseLocation()
                        local inset = nil

                        pcall(function()
                            inset = (ENV.game):GetService('GuiService'):GetGuiInset()
                        end)

                        local origin = glow.AbsolutePosition
                        local x = mouse.X - origin.X - (if inset then inset.X else 0)
                        local y = mouse.Y - origin.Y - (if inset then inset.Y else 0)
                        local circle = create.new('Frame')

                        circle.AnchorPoint = ENV.Vector2.new(0.5, 0.5)
                        circle.Position = ENV.UDim2.fromOffset(x, y)
                        circle.Size = ENV.UDim2.fromOffset(0, 0)
                        circle.BackgroundColor3 = themeColor(library)
                        circle.BackgroundTransparency = RIPPLE_ALPHA
                        circle.BorderSizePixel = 0

                        corner(circle, ENV.UDim.new(0.5, 0))

                        circle.Parent = group
                        group.Parent = glow

                        local reach = math.max(glow.AbsoluteSize.X, glow.AbsoluteSize.Y) * 2.2

                        tween(circle, RIPPLE_SECONDS, {
                            Size = ENV.UDim2.fromOffset(reach, reach),
                            BackgroundTransparency = 1,
                        })

                        local taskApi = ENV.task

                        if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                            (taskApi.delay)(RIPPLE_SECONDS + 0.05, function()
                                group:Destroy()
                            end)
                        end
                    end
                    local function enter()
                        if not eligible() then
                            return
                        end

                        hovered = true

                        if not glow or not glow.Parent then
                            glow = buildGlow(card(), color)

                            table.insert(created, glow)
                        end

                        local accent = themeColor(library)

                        glow.BackgroundColor3 = accent

                        local edge = glow:FindFirstChild('Edge')

                        if edge then
                            edge.Color = accent

                            tween(edge, FADE_SECONDS, {Transparency = STROKE_ALPHA})
                        end

                        fit(glow, glow.Parent)
                        follow()
                        tween(glow, FADE_SECONDS, {BackgroundTransparency = GLOW_ALPHA})
                        grow(TITLE_SCALE)
                    end
                    local function leave()
                        hovered = false

                        if glow then
                            tween(glow, FADE_SECONDS, {BackgroundTransparency = 1})

                            local edge = glow:FindFirstChild('Edge')

                            if edge then
                                tween(edge, FADE_SECONDS, {Transparency = 1})
                            end
                        end

                        grow(1)
                    end

                    table.insert(connections, (button.MouseEnter:Connect(enter)))
                    table.insert(connections, (button.MouseLeave:Connect(leave)))
                    table.insert(connections, (button.MouseMoved:Connect(function(
                    )
                        follow()
                    end)))
                    table.insert(connections, (button.MouseButton1Down:Connect(function(
                    )
                        if glow and hovered then
                            ripple()
                        end
                    end)))
                end

                for _, object in gui:GetDescendants()do
                    if isButton(object) then
                        pcall(wire, object)
                    end
                end

                table.insert(connections, (gui.DescendantAdded:Connect(function(
                    object
                )
                    if isButton(object) then
                        pcall(wire, object)
                    end
                end)))
                cleanup.add(function()
                    for _, connection in connections do
                        pcall(function()
                            connection:Disconnect()
                        end)
                    end
                    for _, item in created do
                        pcall(function()
                            item:Destroy()
                        end)
                    end
                end)
            end

            return HoverGlow
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
            local ENV = getfenv()
            local TILE = 128
            local MAX_ALPHA = 3
            local CORNER_RADIUS = 14
            local LAYER_NAME = 'ViperDither'
            local SEED = 20261004
            local Dither = {}

            local function buildTile()
                local service = (ENV.game):GetService('AssetService')
                local image = service:CreateEditableImage({
                    Size = ENV.Vector2.new(TILE, TILE),
                })
                local bytes = ENV.buffer.create(TILE * TILE * 4)
                local random = ENV.Random.new(SEED)

                for pixel = 0, TILE * TILE - 1 do
                    local value = if random:NextInteger(0, 1) == 1 then 255 else 0
                    local offset = pixel * 4

                    ENV.buffer.writeu8(bytes, offset, value)
                    ENV.buffer.writeu8(bytes, offset + 1, value)
                    ENV.buffer.writeu8(bytes, offset + 2, value)
                    ENV.buffer.writeu8(bytes, offset + 3, random:NextInteger(0, MAX_ALPHA))
                end

                image:WritePixelsBuffer(ENV.Vector2.zero, ENV.Vector2.new(TILE, TILE), bytes)

                return image
            end

            function Dither.attach(gui, cleanup)
                if gui == nil or ENV.Instance == nil or ENV.buffer == nil or ENV.Random == nil or ENV.Content == nil then
                    return
                end

                local function place()
                    local fill = nil

                    for _, object in gui:GetDescendants()do
                        if object.Name == 'Background' and object:IsA('ImageLabel') then
                            fill = object

                            break
                        end
                    end

                    if not fill or fill:FindFirstChild(LAYER_NAME) then
                        return false
                    end

                    local image = buildTile()
                    local layer = ENV.Instance.new('ImageLabel')

                    layer.Name = LAYER_NAME
                    layer.BackgroundTransparency = 1
                    layer.Size = ENV.UDim2.fromScale(1, 1)
                    layer.ImageContent = ENV.Content.fromObject(image)
                    layer.ScaleType = (ENV.Enum).ScaleType.Tile
                    layer.TileSize = ENV.UDim2.fromOffset(TILE, TILE)
                    layer.ZIndex = 1
                    layer.Active = false

                    local corner = ENV.Instance.new('UICorner')

                    corner.CornerRadius = ENV.UDim.new(0, CORNER_RADIUS)
                    corner.Parent = layer
                    layer.Parent = fill

                    cleanup.add(function()
                        pcall(function()
                            layer:Destroy()
                        end)
                        pcall(function()
                            image:Destroy()
                        end)
                    end)

                    return true
                end

                pcall(place)
            end

            return Dither
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
            local Theme = __DARKLUA_BUNDLE_MODULES.v()
            local ENV = getfenv()
            local EDGE_NAME = 'ViperEdge'
            local EDGE_THICKNESS = 1.4
            local EDGE_ALPHA = 0.25
            local EDGE_DEGREES_PER_SECOND = 40
            local DRIFT_SECONDS = 9
            local DRIFT_DEGREES = 18
            local COLOR_REFRESH_SECONDS = 1
            local Ambient = {}

            local function themeColor(library)
                local theme = if type(library) == 'table'then library.Theme else nil
                local value = if type(theme) == 'table'then theme.Outline else nil

                if type(value) == 'userdata' or type(value) == 'vector' then
                    return value
                end

                return Theme.color('primary')
            end
            local function edgeColors(accent)
                local light = accent:Lerp(ENV.Color3.new(1, 1, 1), 0.55)

                return ENV.ColorSequence.new({
                    ENV.ColorSequenceKeypoint.new(0, accent),
                    ENV.ColorSequenceKeypoint.new(0.25, light),
                    ENV.ColorSequenceKeypoint.new(0.5, accent),
                    ENV.ColorSequenceKeypoint.new(0.75, light),
                    ENV.ColorSequenceKeypoint.new(1, accent),
                })
            end

            function Ambient.attach(library, cleanup)
                local gui = if type(library) == 'table'then library.ScreenGui else nil

                if gui == nil or ENV.Instance == nil or ENV.ColorSequence == nil then
                    return
                end

                local fill = nil

                for _, object in gui:GetDescendants()do
                    if object.Name == 'Background' and object:IsA('ImageLabel') then
                        fill = object

                        break
                    end
                end

                local window = fill and fill.Parent

                if not window or not window:IsA('GuiObject') or window:FindFirstChild(EDGE_NAME) then
                    return
                end

                local accent = themeColor(library)
                local stroke = ENV.Instance.new('UIStroke')

                stroke.Name = EDGE_NAME
                stroke.ApplyStrokeMode = ENV.Enum.ApplyStrokeMode.Border
                stroke.Thickness = EDGE_THICKNESS
                stroke.Transparency = EDGE_ALPHA
                stroke.Color = ENV.Color3.new(1, 1, 1)

                local gradient = ENV.Instance.new('UIGradient')

                gradient.Color = edgeColors(accent)
                gradient.Parent = stroke
                stroke.Parent = window

                local runService = (ENV.game):GetService('RunService')
                local lastColorCheck = 0
                local heartbeat = runService.Heartbeat:Connect(function(delta)
                    gradient.Rotation = (gradient.Rotation + EDGE_DEGREES_PER_SECOND * delta) % 360

                    lastColorCheck += delta

                    if lastColorCheck >= COLOR_REFRESH_SECONDS then
                        lastColorCheck = 0

                        local current = themeColor(library)

                        if current ~= accent then
                            accent = current
                            gradient.Color = edgeColors(accent)
                        end
                    end
                end)
                local drift = nil
                local backdrop = fill:FindFirstChildOfClass('UIGradient')

                if backdrop then
                    pcall(function()
                        local tweenService = (ENV.game):GetService('TweenService')
                        local info = ENV.TweenInfo.new(DRIFT_SECONDS, ENV.Enum.EasingStyle.Sine, ENV.Enum.EasingDirection.InOut,
-1, true)

                        drift = tweenService:Create(backdrop, info, {
                            Rotation = backdrop.Rotation + DRIFT_DEGREES,
                        })

                        drift:Play()
                    end)
                end

                cleanup.add(function()
                    pcall(function()
                        heartbeat:Disconnect()
                    end)

                    if drift then
                        pcall(function()
                            drift:Cancel()
                        end)
                    end

                    pcall(function()
                        stroke:Destroy()
                    end)
                end)
            end

            local GHOST_SECONDS = 0.32
            local PILL_HOVER_SCALE = 1.07
            local PILL_POP_FROM = 0.6
            local PILL_HALO_ALPHA = 0.82
            local PILL_HALO_PULSE_ALPHA = 0.68
            local PILL_HALO_PULSE_SECONDS = 1.4

            local function tweenOf(object, seconds, goal, style, direction)
                local ok, result = pcall(function()
                    local tweenService = (ENV.game):GetService('TweenService')

                    return tweenService:Create(object, ENV.TweenInfo.new(seconds, style, direction), goal)
                end)

                if ok and result then
                    result:Play()

                    return result
                end

                return nil
            end
            local function isColor(value)
                return type(value) == 'userdata' or type(value) == 'vector'
            end

            function Ambient.window(window, library, cleanup)
                if type(window) ~= 'table' or ENV.Instance == nil then
                    return
                end

                local elements = window.UIElements
                local frame = if type(elements) == 'table'then elements.Main else nil
                local scaleObj = frame and frame:FindFirstChildOfClass('UIScale')
                local edge = frame and frame:FindFirstChild(EDGE_NAME)
                local originalClose = window.Close
                local originalOpen = window.Open
                local quint = ENV.Enum.EasingStyle.Quint
                local quad = ENV.Enum.EasingStyle.Quad
                local back = ENV.Enum.EasingStyle.Back
                local inDir = ENV.Enum.EasingDirection.In
                local outDir = ENV.Enum.EasingDirection.Out
                local gui = if type(library) == 'table'then library.ScreenGui else nil
                local savedSize = frame and frame.Size

                local function pillRect()
                    local openMain = window.OpenButtonMain
                    local button = if type(openMain) == 'table'then openMain.Button else nil

                    if window.IsOpenButtonEnabled ~= false and button and button.AbsoluteSize.X > 0 then
                        return button.AbsolutePosition, button.AbsoluteSize
                    end

                    local origin = gui.AbsolutePosition
                    local area = gui.AbsoluteSize
                    local size = ENV.Vector2.new(120, 80)

                    return origin + area / 2 - size / 2, size
                end
                local function makeGhost(position, size)
                    local ghost = ENV.Instance.new('Frame')

                    ghost.Name = 'ViperGhost'
                    ghost.BorderSizePixel = 0
                    ghost.ZIndex = 500
                    ghost.Active = false
                    ghost.BackgroundColor3 = ENV.Color3.new(1, 1, 1)

                    local origin = gui.AbsolutePosition

                    ghost.Position = ENV.UDim2.fromOffset(position.X - origin.X, position.Y - origin.Y)
                    ghost.Size = ENV.UDim2.fromOffset(size.X, size.Y)

                    local cornerItem = ENV.Instance.new('UICorner')

                    cornerItem.CornerRadius = ENV.UDim.new(0, 16)
                    cornerItem.Parent = ghost

                    local backdrop = nil

                    for _, object in gui:GetDescendants()do
                        if object.Name == 'Background' and object:IsA('ImageLabel') then
                            backdrop = object:FindFirstChildOfClass('UIGradient')

                            break
                        end
                    end

                    local fillGradient = ENV.Instance.new('UIGradient')

                    if backdrop then
                        fillGradient.Color = backdrop.Color
                        fillGradient.Rotation = backdrop.Rotation
                    else
                        fillGradient.Color = ENV.ColorSequence.new(ENV.Color3.fromRGB(8, 14, 12), ENV.Color3.fromRGB(14, 32, 26))
                    end

                    fillGradient.Parent = ghost

                    local ghostStroke = ENV.Instance.new('UIStroke')

                    ghostStroke.ApplyStrokeMode = ENV.Enum.ApplyStrokeMode.Border
                    ghostStroke.Thickness = 1.5
                    ghostStroke.Color = themeColor(library)
                    ghostStroke.Parent = ghost
                    ghost.Parent = gui

                    return ghost, ghostStroke
                end
                local function fly(
                    ghost,
                    stroke,
                    position,
                    size,
                    seconds,
                    fadeOut
                )
                    local origin = gui.AbsolutePosition
                    local goal = {
                        Position = ENV.UDim2.fromOffset(position.X - origin.X, position.Y - origin.Y),
                        Size = ENV.UDim2.fromOffset(size.X, size.Y),
                    }

                    tweenOf(ghost, seconds, goal, quint, ENV.Enum.EasingDirection.InOut)

                    if fadeOut then
                        tweenOf(ghost, seconds, {BackgroundTransparency = 1}, quad, inDir)
                        tweenOf(stroke, seconds, {Transparency = 1}, quad, inDir)
                    end
                end

                local busy = false
                local firstOpen = true

                if type(originalClose) == 'function' and type(originalOpen) == 'function' and frame and gui then
                    window.Close = function(...)
                        if window.Closed or busy then
                            return (originalClose)(...)
                        end

                        savedSize = frame.Size

                        local fromPos, fromSize = frame.AbsolutePosition, frame.AbsoluteSize
                        local ghost, ghostStroke = makeGhost(fromPos, fromSize)
                        local result = (originalClose)(...)

                        frame.Visible = false

                        local toPos, toSize = pillRect()

                        fly(ghost, ghostStroke, toPos, toSize, GHOST_SECONDS, true)

                        local taskApi = ENV.task

                        taskApi.delay(GHOST_SECONDS + 0.05, function()
                            ghost:Destroy()
                        end)

                        return result
                    end
                    window.Open = function(...)
                        if firstOpen or not window.Closed or busy then
                            firstOpen = false

                            return (originalOpen)(...)
                        end

                        busy = true

                        local args = table.pack(...)
                        local fromPos, fromSize = pillRect()
                        local ghost, ghostStroke = makeGhost(fromPos, fromSize)

                        ghost.BackgroundTransparency = 0.4
                        ghostStroke.Transparency = 0.2

                        local toSize = ENV.Vector2.new(savedSize.X.Offset, savedSize.Y.Offset) * (if scaleObj then scaleObj.Scale else 1)
                        local toPos = frame.AbsolutePosition - ENV.Vector2.new(0, (toSize.Y - frame.AbsoluteSize.Y) * frame.AnchorPoint.Y) - ENV.Vector2.new((toSize.X - frame.AbsoluteSize.X) * frame.AnchorPoint.X, 0)

                        fly(ghost, ghostStroke, toPos, toSize, GHOST_SECONDS, false)
                        tweenOf(ghost, GHOST_SECONDS, {BackgroundTransparency = 0}, quad, outDir)

                        local taskApi = ENV.task
                        local result = nil

                        taskApi.delay(GHOST_SECONDS, function()
                            result = (originalOpen)(table.unpack(args, 1, args.n))

                            taskApi.delay(0.1, function()
                                tweenOf(frame, 0.05, {Size = savedSize}, quad, outDir)
                                tweenOf(ghost, 0.18, {BackgroundTransparency = 1}, quad, outDir)
                                tweenOf(ghostStroke, 0.18, {Transparency = 1}, quad, outDir)

                                if edge then
                                    tweenOf(edge, 0.3, {Transparency = EDGE_ALPHA}, quad, outDir)
                                end

                                taskApi.delay(0.2, function()
                                    ghost:Destroy()

                                    busy = false
                                end)
                            end)
                        end)

                        return result
                    end

                    cleanup.add(function()
                        window.Close = originalClose
                        window.Open = originalOpen
                    end)
                end

                local openMain = window.OpenButtonMain
                local pill = if type(openMain) == 'table'then openMain.Button else nil
                local holder = pill and pill.Parent

                if not pill or not holder then
                    return
                end

                local accent = themeColor(library)
                local theme = if type(library) == 'table'then library.Theme else nil
                local dark = if type(theme) == 'table' and isColor(theme.Dialog)then theme.Dialog else ENV.Color3.fromRGB(12, 16, 20)

                pill.BackgroundColor3 = dark
                pill.BackgroundTransparency = 0.06

                local fill = ENV.Instance.new('UIGradient')

                fill.Name = 'ViperFill'
                fill.Rotation = 90
                fill.Color = ENV.ColorSequence.new(dark:Lerp(accent, 0.18), dark)
                fill.Parent = pill

                local ring = pill:FindFirstChildOfClass('UIStroke')
                local ringGradient = ring and ring:FindFirstChildOfClass('UIGradient')

                if ring then
                    ring.Thickness = 1.6
                    ring.Transparency = 0.1
                end
                if ringGradient then
                    ringGradient.Color = edgeColors(accent)
                end

                local halo = ENV.Instance.new('Frame')

                halo.Name = 'ViperHalo'
                halo.AnchorPoint = ENV.Vector2.new(0.5, 0.5)
                halo.Position = ENV.UDim2.fromScale(0.5, 0.5)
                halo.Size = ENV.UDim2.new(1, 12, 1, 12)
                halo.BackgroundColor3 = accent
                halo.BackgroundTransparency = PILL_HALO_ALPHA
                halo.BorderSizePixel = 0
                halo.ZIndex = math.max((tonumber(pill.ZIndex) or 1) - 1, 0)
                halo.Active = false

                local haloCorner = ENV.Instance.new('UICorner')

                haloCorner.CornerRadius = ENV.UDim.new(1, 0)
                haloCorner.Parent = halo
                halo.Parent = holder

                local pulse = nil

                pcall(function()
                    local tweenService = (ENV.game):GetService('TweenService')
                    local info = ENV.TweenInfo.new(PILL_HALO_PULSE_SECONDS, ENV.Enum.EasingStyle.Sine, ENV.Enum.EasingDirection.InOut,
-1, true)

                    pulse = tweenService:Create(halo, info, {BackgroundTransparency = PILL_HALO_PULSE_ALPHA})

                    pulse:Play()
                end)

                local pillScale = pill:FindFirstChildOfClass('UIScale')
                local connections = {}
                local button = pill:FindFirstChildWhichIsA('TextButton')

                if pillScale and button then
                    table.insert(connections, (button.MouseEnter:Connect(function(
                    )
                        tweenOf(pillScale, 0.18, {Scale = PILL_HOVER_SCALE}, back, outDir)
                    end)))
                    table.insert(connections, (button.MouseLeave:Connect(function(
                    )
                        tweenOf(pillScale, 0.18, {Scale = 1}, quad, outDir)
                    end)))
                    table.insert(connections, (holder:GetPropertyChangedSignal('Visible'):Connect(function(
                    )
                        if holder.Visible then
                            pillScale.Scale = PILL_POP_FROM

                            tweenOf(pillScale, 0.4, {Scale = 1}, back, outDir)
                        end
                    end)))
                end

                local runService = (ENV.game):GetService('RunService')

                table.insert(connections, (runService.Heartbeat:Connect(function(
                    delta
                )
                    if holder.Visible and ringGradient then
                        ringGradient.Rotation = (ringGradient.Rotation + EDGE_DEGREES_PER_SECOND * 1.5 * delta) % 360
                    end
                end)))
                cleanup.add(function()
                    for _, connection in connections do
                        pcall(function()
                            connection:Disconnect()
                        end)
                    end

                    if pulse then
                        pcall(function()
                            pulse:Cancel()
                        end)
                    end

                    pcall(function()
                        halo:Destroy()
                        fill:Destroy()
                    end)
                end)
            end

            return Ambient
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
            local Types = __DARKLUA_BUNDLE_MODULES.i()
            local Theme = __DARKLUA_BUNDLE_MODULES.v()
            local HoverGlow = __DARKLUA_BUNDLE_MODULES.w()
            local Dither = __DARKLUA_BUNDLE_MODULES.x()
            local Ambient = __DARKLUA_BUNDLE_MODULES.y()
            local ENV = getfenv()
            local WINDOW_WIDTH = 600
            local WINDOW_HEIGHT = 400
            local SIDEBAR_WIDTH = 180
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

            local function tagLayers(library, tags)
                local gameObject = ENV.game

                if not gameObject or type(tags) ~= 'table' or #tags == 0 then
                    return
                end

                local ok, tagService = pcall(function()
                    return (gameObject):GetService('CollectionService')
                end)

                if not ok or not tagService then
                    return
                end

                for _, key in {
                    'ScreenGui',
                    'NotificationGui',
                    'DropdownGui',
                    'TooltipGui',
                }do
                    local gui = library[key]

                    if gui then
                        for _, tag in tags do
                            if type(tag) == 'string' and #tag > 0 and #tag <= 64 then
                                pcall(function()
                                    tagService:AddTag(gui, tag)
                                end)
                            end
                        end
                    end
                end
            end

            function WindUIAdapter.create(
                library,
                context,
                config,
                windowTags,
                author
            )
                tagLayers(library, windowTags)

                local theme = Theme.register(library, config.theme)
                local window = (library.CreateWindow)(library, {
                    Title = 'ViperHub NextGen',
                    Author = author or 'ViperHub NextGen',
                    Folder = 'ViperHubNextGen',
                    Icon = 'zap',
                    IconThemed = true,
                    Theme = theme,
                    NewElements = false,
                    Acrylic = false,
                    Size = if ENV.UDim2 then(ENV.UDim2).fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT)else nil,
                    SideBarWidth = SIDEBAR_WIDTH,
                    ShadowTransparency = 0.45,
                    User = {
                        Enabled = true,
                        Anonymous = false,
                    },
                    AutoScale = false,
                    OpenButton = {
                        Title = 'ViperHub',
                        Icon = 'zap',
                        Enabled = true,
                        OnlyMobile = false,
                        Position = if ENV.UDim2 then(ENV.UDim2).new(0.5, 0, 0, 96)else nil,
                        Color = if ENV.ColorSequence and Theme.color('primary')then(ENV.ColorSequence).new(Theme.color('primary'), Theme.color('secondary'))else nil,
                    },
                })
                local BASE_DISPLAY_ORDER = 100

                if library.ScreenGui then
                    pcall(HoverGlow.attach, library, context.cleanup)
                    pcall(Dither.attach, library.ScreenGui, context.cleanup)
                    pcall(Ambient.attach, library, context.cleanup)
                end
                if library.ScreenGui then
                    pcall(function()
                        (library.ScreenGui).DisplayOrder = BASE_DISPLAY_ORDER
                    end)
                end
                if library.DropdownGui then
                    pcall(function()
                        (library.DropdownGui).DisplayOrder = BASE_DISPLAY_ORDER + 10
                    end)
                end
                if library.TooltipGui then
                    pcall(function()
                        (library.TooltipGui).DisplayOrder = BASE_DISPLAY_ORDER + 20
                    end)
                end
                if library.NotificationGui then
                    pcall(function()
                        (library.NotificationGui).DisplayOrder = BASE_DISPLAY_ORDER + 30
                    end)
                end

                pcall(Ambient.window, window, library, context.cleanup)

                if window.SetUIScale then
                    (window.SetUIScale)(window, config.uiScale)
                end
                if window.OnDestroy then
                    (window.OnDestroy)(window, context.destroy)
                end

                context.cleanup.add(function()
                    if window and not window.Destroyed and type(window.Destroy) == 'function' then
                        pcall(window.Destroy, window)
                    end
                end)

                return window
            end

            return WindUIAdapter
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
    do
        local function __modImpl()
            local Overview = {}

            function Overview.mount(window, metadata)
                local tab = window:Tab({
                    Title = 'Overview',
                    Icon = 'house',
                    ShowTabTitle = true,
                })

                tab:Paragraph({
                    Title = metadata.name,
                    Desc = 'Game detected. Features are in the tabs on the left.',
                    Image = 'gamepad-2',
                    ImageSize = 26,
                })
                tab:Paragraph({
                    Title = 'Module ' .. metadata.version,
                    Desc = 'Last updated: ' .. metadata.lastUpdated,
                    Image = 'zap',
                    ImageSize = 22,
                })
            end

            return Overview
        end

        function __DARKLUA_BUNDLE_MODULES.A()
            local v = __DARKLUA_BUNDLE_MODULES.cache.A

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.A = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Theme = __DARKLUA_BUNDLE_MODULES.v()
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

            function Settings.mount(
                window,
                store,
                library,
                keyCodes,
                context,
                tabHost
            )
                local config = store.get()
                local tab = (tabHost or window):Tab({
                    Title = 'Settings',
                    Icon = 'settings',
                    ShowTabTitle = true,
                })
                local controls = {}

                window.ViperControls = controls

                tab:Paragraph({
                    Title = 'Storage',
                    Desc = if store.persistent then
[[Autosave available; Save settings is an optional manual check]]else'Session only: filesystem APIs unavailable',
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
                    Desc =
[[ViperHub themes first, then the library's own. Changes apply instantly.]],
                    Values = Theme.list(library),
                    Value = config.theme,
                    Callback = function(value)
                        store.update('theme', value)

                        if type(library) == 'table' and type(library.SetTheme) == 'function' then
                            pcall(library.SetTheme, library, store.get().theme)
                        end
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
                            local tk = controls.toggleKey

                            if context.alive and type(tk) == 'table' and tk.Value ~= store.get().toggleKey then
                                applyToggleKey(window, store, keyCodes, tk.Value, tk)
                            end
                        end)
                    end)

                    context.cleanup.add(function()
                        connection:Disconnect()
                    end)
                end

                local function applyOpenButton(show)
                    local keyboard = true

                    pcall(function()
                        keyboard = ((getfenv())).game:GetService('UserInputService').KeyboardEnabled
                    end)

                    local visible = show or not keyboard

                    window.IsOpenButtonEnabled = visible

                    local openMain = window.OpenButtonMain

                    if type(openMain) == 'table' and type(openMain.Visible) == 'function' then
                        pcall(openMain.Visible, openMain, visible and window.Closed == true)
                    end
                end

                applyOpenButton(config.openButton)

                controls.openButton = tab:Toggle({
                    Title = 'Show Open Button',
                    Desc =
[[The ViperHub button shown while the window is hidden. Off: use the Toggle UI key (always shown without a keyboard).]],
                    Value = config.openButton,
                    Callback = function(value)
                        store.update('openButton', value)
                        applyOpenButton(store.get().openButton)
                    end,
                })
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

        function __DARKLUA_BUNDLE_MODULES.B()
            local v = __DARKLUA_BUNDLE_MODULES.cache.B

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.B = v
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
                    ShowTabTitle = true,
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

        function __DARKLUA_BUNDLE_MODULES.C()
            local v = __DARKLUA_BUNDLE_MODULES.cache.C

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.C = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Adapter = __DARKLUA_BUNDLE_MODULES.z()
            local Theme = __DARKLUA_BUNDLE_MODULES.v()
            local Overview = __DARKLUA_BUNDLE_MODULES.A()
            local Settings = __DARKLUA_BUNDLE_MODULES.B()
            local Diagnostics = __DARKLUA_BUNDLE_MODULES.C()
            local App = {}
            local HOME_GROUP = 'Home'
            local SYSTEM_GROUP = 'System'

            local function mountPage(host, window, context, page)
                local tab = host:Tab({
                    Title = page.title,
                    Icon = page.icon or 'layout-grid',
                    IconColor = if page.iconColor then Theme.color(page.iconColor)else nil,
                    Desc = page.description,
                    ShowTabTitle = true,
                })

                if page.render then
                    local render = page.render
                    local ok = pcall(render, tab, window)

                    if not ok then
                        local log = context.log

                        if type(log) == 'function' then
                            (log)('PAGE_RENDER_FAILED')
                        end

                        pcall(function()
                            tab:Paragraph({
                                Title = page.title,
                                Desc = 'This page could not be shown.',
                            })
                        end)
                    end
                else
                    tab:Paragraph({
                        Title = page.title,
                        Desc = page.description,
                    })
                end
            end

            function App.mount(
                library,
                context,
                metadata,
                store,
                buffer,
                keyCodes,
                pages,
                windowTags
            )
                local window = Adapter.create(library, context, store.get(), windowTags, tostring(metadata.name) .. ' \u{2022} v' .. tostring(metadata.version))

                if type(window.Tag) == 'function' then
                    pcall(window.Tag, window, {
                        Title = tostring(metadata.name),
                        Icon = 'gamepad-2',
                        Color = Theme.color('primary'),
                    })
                    pcall(window.Tag, window, {
                        Title = 'v' .. tostring(metadata.version),
                        Icon = 'zap',
                        Color = Theme.color('gold'),
                    })
                end

                local sections = {}

                local function host(group)
                    if not group or type(window.Section) ~= 'function' then
                        return window
                    end
                    if not sections[group] then
                        local ok, section = pcall(window.Section, window, {
                            Title = group,
                            Opened = true,
                        })

                        sections[group] = if ok and section then section else window
                    end

                    return sections[group]
                end

                local hasHome = false

                for _, page in pages or {}do
                    if page.home == true then
                        hasHome = true
                    end
                end

                if not hasHome then
                    Overview.mount(host(HOME_GROUP), metadata)
                end

                for _, page in pages or {}do
                    local group = page.group or (if page.home then HOME_GROUP else tostring(metadata.name))

                    mountPage(host(group), window, context, page)
                end

                Settings.mount(window, store, library, keyCodes, context, host(SYSTEM_GROUP))

                local refreshDiagnostics = Diagnostics.mount(host(SYSTEM_GROUP), buffer)

                window:SelectTab(1)

                return window, refreshDiagnostics
            end

            return App
        end

        function __DARKLUA_BUNDLE_MODULES.D()
            local v = __DARKLUA_BUNDLE_MODULES.cache.D

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.D = v
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
local App = __DARKLUA_BUNDLE_MODULES.D()
local UIAdapter = __DARKLUA_BUNDLE_MODULES.z()
local LOADER_VERSION = '0.3.0'
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
    if type(gameObject.IsLoaded) == 'function' and not gameObject:IsLoaded() then
        pcall(function()
            gameObject.Loaded:Wait()
        end)
    end

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

    local window, refreshDiagnostics = App.mount(exports.ui, context, gameModule.metadata, store, buffer, ENV.Enum.KeyCode, gameModule.pages, gameModule.windowTags)

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
