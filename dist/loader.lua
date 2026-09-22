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
    do
        local function __modImpl()
            local Types = __DARKLUA_BUNDLE_MODULES.a()
            local VERSION = '0.1.0'
            local LAST_UPDATED = '2026-09-22'
            local metadata = {
                id = 'AnimeExpeditions',
                name = 'Anime Expeditions',
                version = VERSION,
                lastUpdated = LAST_UPDATED,
                placeIds = {84515722934860},
            }

            table.freeze(metadata.placeIds)

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

            function Detector.detect(placeId)
                if not Validation.isFinite(placeId) then
                    return nil
                end

                local id = placeId

                if id <= 0 or id % 1 ~= 0 then
                    return nil
                end

                for _, metadata in Registry do
                    for _, supported in metadata.placeIds do
                        if id == supported then
                            return {
                                id = metadata.id,
                                name = metadata.name,
                                version = metadata.version,
                                lastUpdated = metadata.lastUpdated,
                                placeIds = table.clone(metadata.placeIds),
                            }
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
            return {}
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
            local Cleanup = __DARKLUA_BUNDLE_MODULES.g()
            local Types = __DARKLUA_BUNDLE_MODULES.h()
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
                }

                context.destroy = function()
                    if not context.alive then
                        return
                    end

                    context.alive = false
                    context.state = 'stopped'

                    scope.destroy()
                end

                return context
            end

            return Context
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
            local Capabilities = __DARKLUA_BUNDLE_MODULES.k()
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
            return table.freeze({
                schemaVersion = 1,
                notifications = true,
                uiScale = 1,
                theme = 'Dark',
                toggleKey = 'RightShift',
            })
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
            local Defaults = __DARKLUA_BUNDLE_MODULES.m()
            local Validation = __DARKLUA_BUNDLE_MODULES.e()
            local Schema = {}
            local KEYS = {
                RightShift = true,
                LeftAlt = true,
                F4 = true,
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
            local Schema = __DARKLUA_BUNDLE_MODULES.n()
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
                        current = Schema.decode(candidate)
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
            local HttpClient = {}

            function HttpClient.new(transport, scheduler)
                return {
                    get = function(url, maxBytes, timeout)
                        if not url:match('^https://raw%.githubusercontent%.com/') then
                            return nil, 'URL_REJECTED'
                        end

                        local finished, expired = false, false
                        local response = nil
                        local failure = nil

                        scheduler.spawn(function()
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

                        local started = scheduler.clock()

                        while not finished and scheduler.clock() - started < timeout do
                            scheduler.wait(0.05)
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
            return {}
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
            local Validation = __DARKLUA_BUNDLE_MODULES.e()
            local Version = __DARKLUA_BUNDLE_MODULES.q()
            local Types = __DARKLUA_BUNDLE_MODULES.r()
            local ManifestClient = {}

            function ManifestClient.validate(value, repository)
                if type(value) ~= 'table' then
                    return nil
                end

                local data = value

                if data.schemaVersion ~= 1 or data.mode ~= 'release' or data.repository ~= repository or not Validation.sha(data.sourceCommit) or not Validation.sha(data.artifactRevision) or not Version.parse(data.version) or not Version.parse(data.loaderVersion) or not Version.parse(data.minLoaderVersion) or type(data.artifacts) ~= 'table' or type(data.games) ~= 'table' then
                    return nil
                end

                local count = 0
                local artifacts = data.artifacts
                local games = data.games

                for key, rawArtifact in artifacts do
                    if type(rawArtifact) ~= 'table' then
                        return nil
                    end

                    local artifact = rawArtifact

                    count += 1

                    if count > 16 or not Validation.identifier(key) or type(artifact) ~= 'table' or not Validation.artifactPath(artifact.path) or type(artifact.sha256) ~= 'string' or #artifact.sha256 ~= 64 or not artifact.sha256:match('^[a-f0-9]+$') or not Validation.isFinite(artifact.bytes) or artifact.bytes % 1 ~= 0 or artifact.bytes <= 0 or artifact.bytes > 4000000 then
                        return nil
                    end
                end
                for _, key in {
                    'ui',
                    'loader',
                    'AnimeVanguards',
                    'AnimeExpeditions',
                }do
                    if not artifacts[key] then
                        return nil
                    end
                end
                for _, key in {
                    'AnimeVanguards',
                    'AnimeExpeditions',
                }do
                    local entry = games[key]

                    if type(entry) ~= 'table' or not Version.parse(entry.version) or type(entry.lastUpdated) ~= 'string' or not string.match(entry.lastUpdated, '^%d%d%d%d%-%d%d%-%d%d$') then
                        return nil
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
            local ModuleLoader = {}

            function ModuleLoader.load(compile, source, bytes, argument)
                if type(compile) ~= 'function' or type(source) ~= 'string' or #source ~= bytes then
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
            local Types = __DARKLUA_BUNDLE_MODULES.h()
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
                    Author = 'Foundation 0.1.0',
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
            local Settings = {}

            function Settings.mount(window, store, library, keyCodes)
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
                    Title = 'Toggle UI (RightShift / LeftAlt / F4)',
                    Value = config.toggleKey,
                    Callback = function(value)
                        store.update('toggleKey', value)
                        window:SetToggleKey(keyCodes[store.get().toggleKey])
                    end,
                })
                controls.save = tab:Button({
                    Title = 'Save settings',
                    Callback = function()
                        store.update('toggleKey', controls.toggleKey.Value)
                        controls.toggleKey:Set(store.get().toggleKey)
                        window:SetToggleKey(keyCodes[store.get().toggleKey])

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
            local Diagnostics = {}

            function Diagnostics.mount(window, buffer)
                local tab = window:Tab({
                    Title = 'Diagnostics',
                    Icon = 'activity',
                })
                local paragraph = tab:Paragraph({
                    Title = 'Status codes',
                    Desc = 'Press Refresh to inspect this session.',
                })

                tab:Button({
                    Title = 'Refresh',
                    Callback = function()
                        paragraph:SetDesc(table.concat(buffer.snapshot(), '\n'))
                    end,
                })
            end

            return Diagnostics
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
            local Adapter = __DARKLUA_BUNDLE_MODULES.u()
            local Overview = __DARKLUA_BUNDLE_MODULES.v()
            local Settings = __DARKLUA_BUNDLE_MODULES.w()
            local Diagnostics = __DARKLUA_BUNDLE_MODULES.x()
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
                Settings.mount(window, store, library, keyCodes)
                Diagnostics.mount(window, buffer)
                window:SelectTab(1)

                return window
            end

            return App
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
end

local Detector = __DARKLUA_BUNDLE_MODULES.f()
local Context = __DARKLUA_BUNDLE_MODULES.i()
local Diagnostics = __DARKLUA_BUNDLE_MODULES.j()
local Capabilities = __DARKLUA_BUNDLE_MODULES.k()
local FileStorage = __DARKLUA_BUNDLE_MODULES.l()
local ConfigStore = __DARKLUA_BUNDLE_MODULES.o()
local HttpClient = __DARKLUA_BUNDLE_MODULES.p()
local ManifestClient = __DARKLUA_BUNDLE_MODULES.s()
local ModuleLoader = __DARKLUA_BUNDLE_MODULES.t()
local Version = __DARKLUA_BUNDLE_MODULES.q()
local App = __DARKLUA_BUNDLE_MODULES.y()
local UIAdapter = __DARKLUA_BUNDLE_MODULES.u()
local LOADER_VERSION = '0.1.0'
local TIMEOUT_SECONDS = 15
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
local marketplaceService = gameObject:GetService('MarketplaceService')
local runtimeTask = ENV.task
local sharedState = ENV.shared

if type(sharedState) ~= 'table' or type(runtimeTask) ~= 'table' then
    return {
        state = 'unavailable',
        code = 'RUNTIME_REQUIRED',
    }
end

local function notify(message)
    pcall(function()
        starterGui:SetCore('SendNotification', {
            Title = 'ViperHub NextGen',
            Text = message,
            Duration = 8,
        })
    end)
end

local old = sharedState.ViperHubNextGen

if type(old) == 'table' and type(old.destroy) == 'function' then
    pcall(old.destroy)
end

local buffer = Diagnostics.new(64)
local context = Context.new(buffer.push)
local session = {
    context = context,
    diagnostics = buffer.snapshot,
    destroy = context.destroy,
}

sharedState.ViperHubNextGen = session

local function fail(code, message)
    buffer.push(code)
    context.destroy()

    context.state = 'failed'

    notify(message)
end

local metadata = Detector.detect(gameObject.PlaceId)

if not metadata then
    context.destroy()

    context.state = 'unsupported'

    notify('Unsupported game (name unavailable). Place: ' .. tostring(gameObject.PlaceId))

    if type(runtimeTask.spawn) == 'function' then
        local requestedAt = os.clock()
        local spawnTask = runtimeTask.spawn

        spawnTask(function()
            local ok, info = pcall(function()
                return marketplaceService:GetProductInfo(gameObject.PlaceId)
            end)

            if ok and type(info) == 'table' and type(info.Name) == 'string' and os.clock() - requestedAt < TIMEOUT_SECONDS and sharedState.ViperHubNextGen == session then
                notify('Unsupported: ' .. string.sub(info.Name, 1, 100))
            end
        end)
    end

    return session
end

context.gameId = metadata.id
context.state = 'loading'

local caps = Capabilities.detect(ENV)

session.capabilities = caps

local function run()
    if not caps.compile then
        fail('COMPILE_UNAVAILABLE', 'This environment cannot load modules.')

        return
    end

    local localArtifacts = ENV.VIPER_DEV_ARTIFACTS
    local exports = {}
    local manifest

    local function decode(text)
        return httpService:JSONDecode(text)
    end

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
            local value, code = ModuleLoader.load(ENV.loadstring, source, if type(source) == 'string'then#source else 0, buffer.push)

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

        local requester = ENV.request or ENV.http_request
        local client = HttpClient.new(function(url)
            if caps.request then
                local result = requester({
                    Url = url,
                    Method = 'GET',
                })

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

        manifest = ManifestClient.validate(json('manifest.json'), repository)

        if not context.alive then
            return
        end
        if not manifest then
            fail('MANIFEST_INVALID', 'Release metadata unavailable or invalid.')

            return
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
            local body, code = client.get(base .. manifest.artifactRevision .. '/' .. artifact.path, MAX_MODULE_BYTES, TIMEOUT_SECONDS)

            if not context.alive then
                return
            end
            if not body then
                fail(code or 'HTTP_FAILED', 'Module download failed.')

                return
            end

            local value, loadCode = ModuleLoader.load(ENV.loadstring, body, artifact.bytes, buffer.push)

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

    local store = ConfigStore.new(FileStorage.new(ENV, metadata.id), decode, function(
        value
    )
        return httpService:JSONEncode(value)
    end, buffer.push)

    session.config = store
    session.window = App.mount(exports.ui, context, gameModule.metadata, store, buffer, ENV.Enum.KeyCode)

    context.cleanup.add(gameModule.stop)
    gameModule.start(context)

    if not context.alive then
        return
    end

    context.state = 'ready'

    buffer.push('FOUNDATION_READY')
end

local ok = pcall(run)

if not ok then
    fail('STARTUP_FAILED', 
[[ViperHub startup failed. Inspect the private diagnostics buffer.]])
end

return session
