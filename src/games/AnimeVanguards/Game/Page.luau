--!strict
--[[
Purpose: Render in-game gameplay settings controls with two-way game synchronization
Input: WindUI tab handle and game settings adapter
Output: Mounted WindUI controls
Dependencies: Adapter
]]

local Page = {}

type SettingSpec = {
    key: string,
    title: string,
    desc: string,
}

local SETTINGS: { SettingSpec } = {
    {
        key = "AutoReplay",
        title = "Auto Replay",
        desc = "Automatically replays the match upon completion.",
    },
    {
        key = "AutoNext",
        title = "Auto Next",
        desc = "Automatically proceeds to the next stage upon victory.",
    },
    {
        key = "AutoSkipWaves",
        title = "Auto Skip Waves",
        desc = "Automatically votes to skip waves as soon as possible.",
    },
    {
        key = "AutoSkipStart",
        title = "Auto Skip Start",
        desc = "Automatically votes to start the match immediately.",
    },
}

--- Mounts the Game settings page on the given WindUI tab.
function Page.mount(tab: any, adapter: any)
    tab:Paragraph({
        Title = "Game Settings",
        Desc = "Synchronized controls for Anime Vanguards in-game automation and match settings.",
    })

    local section = tab:Section({ Title = "Match Automation", Opened = true })

    if not adapter or not adapter.isAvailable() then
        section:Paragraph({
            Title = "Status",
            Desc = "Game settings modules are not yet loaded. Controls will synchronize in a match.",
        })
    end

    local toggles: { [string]: any } = {}
    local syncing = false

    for _, spec in SETTINGS do
        local currentValue = if adapter then ((adapter :: any).get(spec.key) == true) else false
        local toggle = section:Toggle({
            Title = spec.title,
            Desc = spec.desc,
            Value = currentValue,
            Callback = function(enabled: boolean)
                if syncing then
                    return
                end
                if adapter and type((adapter :: any).set) == "function" then
                    (adapter :: any).set(spec.key, enabled)
                end
            end,
        })
        toggles[spec.key] = toggle
    end

    local autoBackValue = if adapter and type((adapter :: any).getAutoBackToLobby) == "function"
        then (adapter :: any).getAutoBackToLobby()
        else false
    section:Toggle({
        Title = "Auto Back to Lobby",
        Desc = "Returns to lobby when match ends and Auto Replay / Auto Next cannot proceed.",
        Value = autoBackValue,
        Callback = function(enabled: boolean)
            if adapter and type((adapter :: any).setAutoBackToLobby) == "function" then
                (adapter :: any).setAutoBackToLobby(enabled)
            end
        end,
    })

    local function syncAll()
        if not adapter or type((adapter :: any).get) ~= "function" then
            return
        end
        for _, spec in SETTINGS do
            local val = (adapter :: any).get(spec.key)
            if val ~= nil then
                local toggle = toggles[spec.key]
                if toggle and type(toggle.Set) == "function" and toggle.Value ~= val then
                    syncing = true
                    pcall(toggle.Set :: any, toggle, val, false)
                    syncing = false
                end
            end
        end
    end

    syncAll()

    if adapter and type((adapter :: any).observe) == "function" then
        (adapter :: any).observe(function(name: string, value: boolean)
            local toggle = toggles[name]
            if toggle and type(toggle.Set) == "function" and toggle.Value ~= value then
                syncing = true
                pcall(toggle.Set :: any, toggle, value, false)
                syncing = false
            end
        end)
    end

    local env: any = getfenv()
    local taskApi = env.task
    if
        type(taskApi) == "table"
        and type(taskApi.spawn) == "function"
        and type(taskApi.wait) == "function"
    then
        (taskApi.spawn :: any)(function()
            for _ = 1, 10 do
                (taskApi.wait :: any)(1.0)
                syncAll()
            end
        end)
    end
end

return Page
