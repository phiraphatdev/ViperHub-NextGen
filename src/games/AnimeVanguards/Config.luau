--!strict
--[[
Purpose: Keep patch-sensitive paths separate from behavior
Input: None
Output: Empty placeholder config
Dependencies: None
]]

return table.freeze({
    instancePaths = table.freeze({
        worldlinesData = "Modules.Data.WorldlinesData",
        worldlinesClient = "NetworkCode.LobbyWorldlinesClient",
        bossRotation = "Modules.Shared.BossRushDataHandler",
        bossEventsClient = "NetworkCode.LobbyBossEventsClient",
        bossEventNames = "Modules.Data.BossEvent.BossEventShopData",
        sharedSettingsClient = "NetworkCode.SharedSettingsClient",
        settingsCodec = "Modules.Shared.SettingsNetworkCodec",
        settingsState = "Modules.Gameplay.SettingsHandler.SettingsState",
        specialEventsClient = "NetworkCode.LobbySpecialEventsClient",
        riftsData = "Modules.Gameplay.Rifts.RiftsDataHandler",
        challengeAttempts = "Modules.Gameplay.Challenges.ChallengesAttemptsHandler",
        lobbyReturnClient = "NetworkCode.GameTeleportLobbyReturnClient",
        gameHandler = "Modules.Gameplay.GameHandler",
        autoPlayHandler = "Modules.Gameplay.AutoPlay.AutoPlayHandler",
        autoPlayClient = "NetworkCode.GameAutoPlayClient",
        wavesClient = "NetworkCode.GameWavesClient",
        wavesHud = "Modules.Interface.Loader.HUD.Waves",
        endScreenClient = "NetworkCode.GameEndScreenClient",
        endScreenCodec = "Modules.Shared.EndScreenNetworkCodec",
        -- Match modules used by the macro recorder/player (ReplicatedStorage unless noted).
        unitSnapshotCodec = "Modules.Shared.UnitSnapshotCodec",
        priorityHandler = "Modules.Gameplay.PriorityHandler",
        unitsData = "Modules.Data.Entities.Units",
        matchFlowClient = "NetworkCode.GameMatchFlowClient",
        clientUnitHandler = "Modules.Gameplay.Units.ClientUnitHandler", -- StarterPlayer
        playerYenHandler = "Modules.Gameplay.PlayerYenHandler", -- StarterPlayer
        hudUnits = "Modules.Interface.Loader.HUD.Units", -- StarterPlayer
        upgradeButtons = "Modules.Gameplay.Units.UnitUpgradeHandler.Managers.ButtonsManager", -- StarterPlayer
        autoUpgradeData = "Modules.Gameplay.UnitManager.AutoUpgrade.AutoUpgradeDataHandler", -- StarterPlayer
        clientAbilityHandler = "Modules.Gameplay.ClientAbilityHandler", -- StarterPlayer
        -- Lobby joiner modules.
        lobbyHandlerBase = "Modules.Interface.Loader.Gameplay.LobbyHandler", -- StarterPlayer
        lobbyMatchmakingClient = "NetworkCode.LobbyMatchmakingClient",
        lobbyChallengesClient = "NetworkCode.LobbyChallengesClient",
        challengesData = "Modules.Data.Challenges.ChallengesData",
        challengesDataHandler = "Modules.Gameplay.Challenges.ChallengesDataHandler", -- StarterPlayer
        stagesData = "Modules.Data.StagesData",
        bountyData = "Modules.Data.BountyData",
        ownedUnits = "Modules.Gameplay.Units.OwnedUnitsHandler",
        teamsData = "Modules.Interface.Loader.Gameplay.Teams.TeamsDataHandler",
        lobbyTeamsClient = "NetworkCode.LobbyTeamsClient",
        gameUnitsClient = "NetworkCode.GameUnitsClient",
        lobbyUnitActionsClient = "NetworkCode.LobbyUnitActionsClient",
        popupHandler = "Modules.Interface.Loader.Misc.PopupHandler",
        notifications = "Modules.Interface.Loader.Notifications",
        bountyState = "Modules.Gameplay.Bounty.PlayerBountyDataHandler",
        bountyStateMatch = "Modules.Gameplay.Bounties.PlayerBountyDataHandler",
        autoPlayModeBlocklist = "Modules.Shared.AutoPlayModeBlocklist",
    }),
    modeLabels = table.freeze({
        Story = "Story",
        LegendStage = "Legend Stage",
        BossEvent = "Boss Event",
        UnitTrial = "Unit Trial",
        Portals = "Portals",
        Challenge = "Challenge",
        Dungeon = "Dungeon",
        Raid = "Raid",
        Worldline = "Worldline",
        ElementalTowers = "Elemental Towers",
        Rift = "Rift",
    }),
    -- Joiner modes whose StageType is not listed by StagesData (verified in game scripts: GameData.StageType).
    extraModes = table.freeze({ "Worldline", "ElementalTowers", "Rift" }),
    -- Modes left out of Stage Preset Rules by request.
    hiddenModes = table.freeze({
        Extra = true,
        GuildWar = true,
        LTM = true,
        Rememberance = true,
        Scenarios = true,
    }),
    -- The game tags every PlayerGui button for hover/press effects unless the UI layer carries these opt-out tags.
    windowTags = table.freeze({ "ButtonEffects_Ignore", "NoButtonEffects" }),
    -- Match types (GameData.StageType) a host may switch before Vote Start.
    switchableStageTypes = table.freeze({ Story = true, LegendStage = true, Raid = true, Dungeon = true }),
    -- GameData.StageType to Joiner row name, used to pick the Team Equipper row for the current match.
    stageTypeRows = table.freeze({
        Story = "Stage",
        LegendStage = "Legend Stage",
        Raid = "Raid",
        Dungeon = "Dungeon",
        ElementalTowers = "Elemental Towers",
        BossEvent = "Boss Event",
        Worldline = "Worldline",
        Portals = "Portal",
        Rift = "Rift",
    }),
    -- GameData.ChallengeType to Joiner row name.
    challengeRows = table.freeze({
        Regular = "Regular Challenge",
        Daily = "Daily Challenge",
        Weekly = "Weekly Challenge",
    }),
    -- Game UI messages starting with this text are dropped right after this script loads a team.
    teamLoadMessagePrefix = "^Successfully ",
    -- Discord webhook delivery and embed styling.
    webhook = table.freeze({
        hosts = table.freeze({ "discord.com", "discordapp.com", "ptb.discord.com", "canary.discord.com" }),
        rarityOrder = table.freeze({
            "Rare",
            "Epic",
            "Legendary",
            "Mythic",
            "Secret",
            "Exclusive",
            "Vanguard",
        }),
        -- Unicode emoji (the game's own custom emoji cannot be used in Discord) and embed colors per unit rarity.
        rarityStyle = table.freeze({
            Rare = table.freeze({ emoji = "🔹", color = 0x3498DB }),
            Epic = table.freeze({ emoji = "🟣", color = 0x9B59B6 }),
            Legendary = table.freeze({ emoji = "🟠", color = 0xE67E22 }),
            Mythic = table.freeze({ emoji = "🔴", color = 0xE74C3C }),
            Secret = table.freeze({ emoji = "🕶️", color = 0x6C3483 }),
            Exclusive = table.freeze({ emoji = "💎", color = 0x1ABC9C }),
            Vanguard = table.freeze({ emoji = "👑", color = 0xF1C40F }),
        }),
        footer = "ViperHub NextGen • Anime Vanguards",
        defaultUsername = "ViperHub",
        pingMinRarity = "Secret",
        -- Drops at or above this rarity can also @everyone (when the setting is on).
        everyoneMinRarity = "Secret",
        -- Player attributes holding balances, shown in match embeds (key, label, emoji).
        currencies = table.freeze({
            table.freeze({ key = "Gems", label = "Gems", emoji = "💎" }),
            table.freeze({ key = "Gold", label = "Gold", emoji = "🪙" }),
            table.freeze({ key = "TraitRerolls", label = "Rerolls", emoji = "🎲" }),
            table.freeze({ key = "Trophies", label = "Trophies", emoji = "🏆" }),
        }),
        levelAttribute = "Level",
        -- Match end screen layout (PlayerGui.EndScreen), read live: text labels by child path from the screen.
        endScreen = table.freeze({
            gui = "EndScreen",
            title = "Holder.Title.Label",
            stage = "Holder.Main.StageInfo.Main.StageName",
            act = "Holder.Main.StageInfo.Main.ActName",
            difficulty = "Holder.Main.StageInfo.Main.Difficulty",
            units = "Holder.Main.StageStatistics.UnitsPlaced.Amount",
            damage = "Holder.Main.StageStatistics.TotalDamage.Amount",
            playTime = "Holder.Main.StageStatistics.PlayTime.Amount",
            money = "Holder.Main.StageStatistics.MoneyEarned.Amount",
            takedowns = "Holder.Main.StageStatistics.Takedowns.Amount",
            waves = "Holder.Main.StageStatistics.WavesCompleted.Amount",
            rewards = "Holder.Main.StageRewards.Main",
            rewardName = "Holder.Main.ItemName",
            rewardAmount = "Holder.Main.Amount",
        }),
        -- Possible GameData fields for the stage's wave count, tried in order.
        waveMaxKeys = table.freeze({ "MaxWave", "WaveCount", "TotalWaves", "Waves" }),
        -- Possible fields in a MatchEnded argument table that say whether the match was won.
        resultKeys = table.freeze({ "Victory", "Won", "Win", "Success", "Result" }),
        -- Match end summary Status (decoded ShowEndScreen payload, same source the macro recorder uses).
        resultStatus = table.freeze({ Finished = "Victory", Failed = "Defeat" }),
    }),
    attributes = table.freeze({ riftOpen = "IsRiftOpen" }),
    -- Misc tab: Anti-AFK, Auto Reconnect and re-run after teleport.
    misc = table.freeze({
        -- Enum.ConnectionError names that mean a lost session (never kicks, bans, duplicate logins or maintenance).
        reconnectErrors = table.freeze({
            "DisconnectErrors",
            "DisconnectReceivePacketError",
            "DisconnectReceivePacketStreamError",
            "DisconnectSendPacketError",
            "DisconnectTimeout",
            "DisconnectPlayerless",
            "DisconnectConnectionLost",
            "DisconnectIdle",
            "DisconnectRaknetErrors",
            "DisconnectClientFailure",
            "DisconnectRejoin",
            "ServerShutdown",
            "ReplicatorTimeout",
        }),
        reconnectDelaySeconds = 5,
        reconnectRetrySeconds = 20,
        reconnectAttempts = 5,
        defaultLoaderUrl = "http://127.0.0.1:8766/runtime-smoke.lua",
    }),
    thresholds = table.freeze({
        activitySnapshotSeconds = 7200,
        riftSnapshotSeconds = 600,
        returnRetrySeconds = 12,
        returnRetryLimit = 3,
        presetSwitchAttempts = 3,
        teamLoadAttempts = 3,
        teamLoadTimeoutSeconds = 8,
        teamMessageSuppressSeconds = 15,
        webhookMinIntervalSeconds = 1.5,
        webhookQueueLimit = 40,
        webhookRetryLimit = 3,
        webhookUnitIgnoreSeconds = 20,
        webhookBountyPollSeconds = 15,
        webhookProblemCooldownSeconds = 300,
        changeStageRetrySeconds = 6,
        changeStageAttempts = 2,
        joinerRunMaxAgeSeconds = 10800,
        macroListCacheSeconds = 5,
        presetSwitchTimeoutSeconds = 8,
        presetRequestSeconds = 8,
        -- Wait after the game reports loaded before any feature starts (keeps early network traffic away from the join).
        startDelaySeconds = 6,
        -- Rift open but the attempt count not reported yet (seen right after loading): hold this long before skipping.
        riftAttemptWaitSeconds = 45,
        -- After the reward wait, the joiner holds its lobby return while another feature (the webhook) is still sending.
        returnGateMaxSeconds = 8,
    }),
    remoteNames = table.freeze({
        worldlineProgress = "GetWorldlineProgress",
        worldlineTeleport = "TeleportToWorldline",
        bossEventStart = "StartBossEvent",
        macroPlacementClient = "GameUnitPlacementClient",
        macroAbilityClient = "GameUnitAbilitiesClient",
        macroUnitsClient = "GameUnitsClient",
        macroUnitStateClient = "GameUnitClientStateClient",
        changeSetting = "ChangeSetting",
        toggleSetting = "ToggleSetting",
        joinRift = "JoinRift",
        getRiftAttempts = "GetRiftAttempts",
        requestTeleportToLobby = "RequestTeleportToLobby",
        toggleAutoPlay = "ToggleAutoPlay",
        castWaveSkipVote = "CastWaveSkipVote",
        switchAutoPlayPreset = "SwitchAutoPlayPreset",
        loadTeam = "LoadTeam",
        equipUnit = "EquipUnitInSlot",
        unequipAllUnits = "UnequipAllUnits",
        requestLoadTeam = "RequestLoadTeam",
        requestAutoPlayData = "RequestAutoPlayData",
        autoPlayPresetsUpdated = "AutoPlayPresetsUpdated",
        showEndScreen = "ShowEndScreen",
    }),
})
