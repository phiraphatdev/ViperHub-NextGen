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
        stagesData = "Modules.Data.StagesData",
        bountyData = "Modules.Data.BountyData",
        bountyState = "Modules.Gameplay.Bounty.PlayerBountyDataHandler",
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
    }),
    -- Modes left out of Stage Preset Rules by request.
    hiddenModes = table.freeze({
        Extra = true,
        GuildWar = true,
        LTM = true,
        Rememberance = true,
        Scenarios = true,
    }),
    attributes = table.freeze({ riftOpen = "IsRiftOpen" }),
    thresholds = table.freeze({
        activitySnapshotSeconds = 7200,
        riftSnapshotSeconds = 600,
        returnRetrySeconds = 12,
        returnRetryLimit = 3,
        presetSwitchAttempts = 3,
        presetSwitchTimeoutSeconds = 8,
        presetRequestSeconds = 8,
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
        requestAutoPlayData = "RequestAutoPlayData",
        autoPlayPresetsUpdated = "AutoPlayPresetsUpdated",
    }),
})
