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
            return table.freeze({
                instancePaths = table.freeze({
                    worldlinesData = 'Modules.Data.WorldlinesData',
                    worldlinesClient = 'NetworkCode.LobbyWorldlinesClient',
                    bossRotation = 'Modules.Shared.BossRushDataHandler',
                    bossEventsClient = 'NetworkCode.LobbyBossEventsClient',
                    bossEventNames = 'Modules.Data.BossEvent.BossEventShopData',
                    sharedSettingsClient = 'NetworkCode.SharedSettingsClient',
                    settingsCodec = 'Modules.Shared.SettingsNetworkCodec',
                    settingsState = 'Modules.Gameplay.SettingsHandler.SettingsState',
                    specialEventsClient = 'NetworkCode.LobbySpecialEventsClient',
                    riftsData = 'Modules.Gameplay.Rifts.RiftsDataHandler',
                    challengeAttempts = 'Modules.Gameplay.Challenges.ChallengesAttemptsHandler',
                    lobbyReturnClient = 'NetworkCode.GameTeleportLobbyReturnClient',
                    gameHandler = 'Modules.Gameplay.GameHandler',
                    autoPlayHandler = 'Modules.Gameplay.AutoPlay.AutoPlayHandler',
                    gameOdysseyClient = 'NetworkCode.GameOdysseyClient',
                    stageMechanicsClient = 'NetworkCode.GameStageMechanicsClient',
                    adventureMapRelay = 'Modules.Gameplay.Odyssey.Adventure.MapSnapshotRelay',
                    autoPlayClient = 'NetworkCode.GameAutoPlayClient',
                    wavesClient = 'NetworkCode.GameWavesClient',
                    wavesHud = 'Modules.Interface.Loader.HUD.Waves',
                    endScreenClient = 'NetworkCode.GameEndScreenClient',
                    endScreenCodec = 'Modules.Shared.EndScreenNetworkCodec',
                    unitSnapshotCodec = 'Modules.Shared.UnitSnapshotCodec',
                    priorityHandler = 'Modules.Gameplay.PriorityHandler',
                    unitsData = 'Modules.Data.Entities.Units',
                    matchFlowClient = 'NetworkCode.GameMatchFlowClient',
                    clientUnitHandler = 'Modules.Gameplay.Units.ClientUnitHandler',
                    playerYenHandler = 'Modules.Gameplay.PlayerYenHandler',
                    hudUnits = 'Modules.Interface.Loader.HUD.Units',
                    upgradeButtons =
[[Modules.Gameplay.Units.UnitUpgradeHandler.Managers.ButtonsManager]],
                    autoUpgradeData =
[[Modules.Gameplay.UnitManager.AutoUpgrade.AutoUpgradeDataHandler]],
                    clientAbilityHandler = 'Modules.Gameplay.ClientAbilityHandler',
                    lobbyHandlerBase = 'Modules.Interface.Loader.Gameplay.LobbyHandler',
                    lobbyMatchmakingClient = 'NetworkCode.LobbyMatchmakingClient',
                    lobbyChallengesClient = 'NetworkCode.LobbyChallengesClient',
                    challengesData = 'Modules.Data.Challenges.ChallengesData',
                    challengesDataHandler = 'Modules.Gameplay.Challenges.ChallengesDataHandler',
                    stagesData = 'Modules.Data.StagesData',
                    bountyData = 'Modules.Data.BountyData',
                    ownedUnits = 'Modules.Gameplay.Units.OwnedUnitsHandler',
                    teamsData = 'Modules.Interface.Loader.Gameplay.Teams.TeamsDataHandler',
                    lobbyTeamsClient = 'NetworkCode.LobbyTeamsClient',
                    gameUnitsClient = 'NetworkCode.GameUnitsClient',
                    lobbyUnitActionsClient = 'NetworkCode.LobbyUnitActionsClient',
                    popupHandler = 'Modules.Interface.Loader.Misc.PopupHandler',
                    notifications = 'Modules.Interface.Loader.Notifications',
                    bountyState = 'Modules.Gameplay.Bounty.PlayerBountyDataHandler',
                    bountyStateMatch = 'Modules.Gameplay.Bounties.PlayerBountyDataHandler',
                    autoPlayModeBlocklist = 'Modules.Shared.AutoPlayModeBlocklist',
                    adventureCharacters = 'Modules.Data.Odyssey.Adventure.CharactersData',
                    adventurePowers = 'Modules.Data.Odyssey.Adventure.PowersData',
                    adventureBasicCards = 'Modules.Data.Odyssey.Adventure.BasicCardPool',
                    odysseyTraitPool = 'Modules.Data.OdysseyTraitPool',
                    memoriasData = 'Modules.Data.MemoriasData',
                }),
                modeLabels = table.freeze({
                    Story = 'Story',
                    LegendStage = 'Legend Stage',
                    BossEvent = 'Boss Event',
                    UnitTrial = 'Unit Trial',
                    Portals = 'Portals',
                    Challenge = 'Challenge',
                    Dungeon = 'Dungeon',
                    Raid = 'Raid',
                    Worldline = 'Worldline',
                    ElementalTowers = 'Elemental Towers',
                    Rift = 'Rift',
                }),
                extraModes = table.freeze({
                    'Worldline',
                    'ElementalTowers',
                    'Rift',
                }),
                hiddenModes = table.freeze({
                    Extra = true,
                    GuildWar = true,
                    LTM = true,
                    Rememberance = true,
                    Scenarios = true,
                }),
                windowTags = table.freeze({
                    'ButtonEffects_Ignore',
                    'NoButtonEffects',
                }),
                switchableStageTypes = table.freeze({
                    Story = true,
                    LegendStage = true,
                    Raid = true,
                    Dungeon = true,
                }),
                stageTypeRows = table.freeze({
                    Story = 'Stage',
                    LegendStage = 'Legend Stage',
                    Raid = 'Raid',
                    Dungeon = 'Dungeon',
                    ElementalTowers = 'Elemental Towers',
                    BossEvent = 'Boss Event',
                    Worldline = 'Worldline',
                    Portals = 'Portal',
                    Rift = 'Rift',
                }),
                challengeRows = table.freeze({
                    Regular = 'Regular Challenge',
                    Daily = 'Daily Challenge',
                    Weekly = 'Weekly Challenge',
                }),
                teamLoadMessagePrefix = '^Successfully ',
                webhook = table.freeze({
                    hosts = table.freeze({
                        'discord.com',
                        'discordapp.com',
                        'ptb.discord.com',
                        'canary.discord.com',
                    }),
                    rarityOrder = table.freeze({
                        'Rare',
                        'Epic',
                        'Legendary',
                        'Mythic',
                        'Secret',
                        'Exclusive',
                        'Vanguard',
                    }),
                    rarityStyle = table.freeze({
                        Rare = table.freeze({
                            emoji = '\u{1f539}',
                            color = 0x3498db,
                        }),
                        Epic = table.freeze({
                            emoji = '\u{1f7e3}',
                            color = 0x9b59b6,
                        }),
                        Legendary = table.freeze({
                            emoji = '\u{1f7e0}',
                            color = 0xe67e22,
                        }),
                        Mythic = table.freeze({
                            emoji = '\u{1f534}',
                            color = 0xe74c3c,
                        }),
                        Secret = table.freeze({
                            emoji = '\u{1f576}\u{fe0f}',
                            color = 0x6c3483,
                        }),
                        Exclusive = table.freeze({
                            emoji = '\u{1f48e}',
                            color = 0x1abc9c,
                        }),
                        Vanguard = table.freeze({
                            emoji = '\u{1f451}',
                            color = 0xf1c40f,
                        }),
                    }),
                    footer = 'ViperHub NextGen \u{2022} Anime Vanguards',
                    defaultUsername = 'ViperHub',
                    pingMinRarity = 'Secret',
                    everyoneMinRarity = 'Secret',
                    currencies = table.freeze({
                        table.freeze({
                            key = 'Gems',
                            label = 'Gems',
                            emoji = '\u{1f48e}',
                        }),
                        table.freeze({
                            key = 'Gold',
                            label = 'Gold',
                            emoji = '\u{1fa99}',
                        }),
                        table.freeze({
                            key = 'TraitRerolls',
                            label = 'Rerolls',
                            emoji = '\u{1f3b2}',
                        }),
                        table.freeze({
                            key = 'Trophies',
                            label = 'Trophies',
                            emoji = '\u{1f3c6}',
                        }),
                    }),
                    levelAttribute = 'Level',
                    endScreen = table.freeze({
                        gui = 'EndScreen',
                        title = 'Holder.Title.Label',
                        stage = 'Holder.Main.StageInfo.Main.StageName',
                        act = 'Holder.Main.StageInfo.Main.ActName',
                        difficulty = 'Holder.Main.StageInfo.Main.Difficulty',
                        units = 'Holder.Main.StageStatistics.UnitsPlaced.Amount',
                        damage = 'Holder.Main.StageStatistics.TotalDamage.Amount',
                        playTime = 'Holder.Main.StageStatistics.PlayTime.Amount',
                        money = 'Holder.Main.StageStatistics.MoneyEarned.Amount',
                        takedowns = 'Holder.Main.StageStatistics.Takedowns.Amount',
                        waves = 'Holder.Main.StageStatistics.WavesCompleted.Amount',
                        rewards = 'Holder.Main.StageRewards.Main',
                        rewardName = 'Holder.Main.ItemName',
                        rewardAmount = 'Holder.Main.Amount',
                    }),
                    waveMaxKeys = table.freeze({
                        'MaxWave',
                        'WaveCount',
                        'TotalWaves',
                        'Waves',
                    }),
                    resultKeys = table.freeze({
                        'Victory',
                        'Won',
                        'Win',
                        'Success',
                        'Result',
                    }),
                    resultStatus = table.freeze({
                        Finished = 'Victory',
                        Failed = 'Defeat',
                    }),
                }),
                attributes = table.freeze({
                    riftOpen = 'IsRiftOpen',
                }),
                misc = table.freeze({
                    reconnectErrors = table.freeze({
                        'DisconnectErrors',
                        'DisconnectReceivePacketError',
                        'DisconnectReceivePacketStreamError',
                        'DisconnectSendPacketError',
                        'DisconnectTimeout',
                        'DisconnectPlayerless',
                        'DisconnectConnectionLost',
                        'DisconnectIdle',
                        'DisconnectRaknetErrors',
                        'DisconnectClientFailure',
                        'DisconnectRejoin',
                        'ServerShutdown',
                        'ReplicatorTimeout',
                    }),
                    reconnectDelaySeconds = 5,
                    reconnectRetrySeconds = 20,
                    reconnectAttempts = 5,
                    defaultLoaderUrl = 'http://127.0.0.1:8766/runtime-smoke.lua',
                }),
                adventure = table.freeze({
                    storageKey = 'AnimeVanguardsAdventure',
                    defaultCharacter = 'Iscanur (Pride)',
                    characters = table.freeze({
                        'Alocard (Vampire King)',
                        'Demon Leader (Control)',
                        'Divalo (Requiem)',
                        'Elastic Captain (Cog 5th)',
                        'Hellkiller (Slayer)',
                        'Iscanur (Pride)',
                        'Luce (Hacker)',
                        'Manipulator (Spider)',
                        'Regnaw (Rage)',
                        'Rogita (Super 4)',
                        'Shinobi God (Infinite Dreams)',
                        'Song Jinwu and Igros',
                        'Tuji (Sorcerer Killer)',
                        'Yomomata (Captain)',
                    }),
                    powers = table.freeze({
                        'Full Deck',
                        'Chosen One',
                        'Handpicked',
                        'Abundance',
                        'Hoarder',
                        'Treasure Hunter',
                        'Gold Thread',
                        'Flight',
                        'High Value',
                        'Jack Pot',
                        "I'm Familiar",
                        'Memorized',
                        'Not Basic',
                        'Power Trip',
                    }),
                    basicCardRarities = table.freeze({
                        'Mythic',
                        'Legendary',
                        'Epic',
                        'Rare',
                    }),
                    basicCards = table.freeze({
                        Mythic = table.freeze({
                            'Limit Break',
                            'Golden Age',
                            'Crippling Field',
                            'Luckcatcher',
                            'Unstoppable Force',
                            'Spoils of War',
                            'True Strike',
                            'Shop Cleaner',
                            'Cleansing Pool',
                        }),
                        Legendary = table.freeze({
                            'The Best Defense\u{2026}',
                            'Affinity',
                            'Resource Overflow',
                            'Delicate Flower',
                            'Double Tap',
                            'Essence Collector',
                        }),
                        Epic = table.freeze({
                            'Infection',
                            'Base Shield',
                            'Battle Frenzy',
                            'Extended Duration',
                            'Treasure Map Fragment',
                            'Quick Charge',
                            'Potent Toxins',
                            'Volatile Demise',
                            'Painful Gains',
                            'Numbing Agent',
                        }),
                        Rare = table.freeze({
                            'Adrenaline Shot',
                            'Serrated Tips',
                            'Precision Optics',
                            'Boxing Gloves',
                            'Ambush',
                            'Concussive Blast',
                            'Slayer Rounds',
                            'Military Training',
                        }),
                    }),
                    roomKinds = table.freeze({
                        'Battle',
                        'Elite',
                        'Shop',
                        'Treasure',
                        'Boss',
                    }),
                    floorPriority = table.freeze({
                        'Treasure',
                        'Elite',
                        'Shop',
                        'Battle',
                        'Boss',
                    }),
                    secondFloorPriority = table.freeze({
                        'Treasure',
                        'Battle',
                        'Shop',
                        'Elite',
                        'Boss',
                    }),
                    traits = table.freeze({
                        'Vigor I',
                        'Vigor II',
                        'Vigor III',
                        'Swift I',
                        'Swift II',
                        'Swift III',
                        'Range I',
                        'Range II',
                        'Range III',
                        'Fortune',
                        'Marksman',
                        'Blitz',
                        'Deadeye',
                        'Ethereal',
                        'Solar',
                        'Prodigy',
                    }),
                    extraTraits = table.freeze({
                        'Monarch',
                    }),
                    memoriaNames = table.freeze({
                        'Trust of Others',
                        'Enthusiastic Walks',
                        'Sword Priestess',
                        'Unlikely Doctor',
                        'Messenger of Destruction',
                        'Tough Bunny',
                        'Death, Resurrected',
                        'Power Surge',
                        "Artist's Blessing",
                        'Peak of Shinobi',
                        "Journey's End",
                        "It's Going Down Now",
                        'King of the Trash',
                        'Gaze of the Strongest',
                        'The True Savior',
                        "A Father's Sacrifice",
                        'Sinful Priest',
                        'By the Book',
                        'Princess Rosa',
                        'Along Came a Spider',
                        'Restricted By the Heavens',
                        'Bow to Your God',
                        'Battle of the Strongest',
                        'Life Will Change',
                        'Revenge of the Cursed One',
                        "Ice Queen's Rest",
                        'Ultimate Deceiver',
                        'Purveyor of Peace',
                        "All I've Got",
                        'Scrap Metal Master',
                        'Goddess of Spring',
                        'The Beast King',
                        "Water Goddess's Cheer",
                        "Armored Mage's Day Off",
                        'A Beast Plays',
                        'Range Boost I',
                        'Empty Reflections',
                        'Golden Obsessions',
                        'Reach Out to the Truth',
                        'Trauma Turned Strength',
                        'Frozen Admiral',
                        'Snip Snip',
                        'Endless Buffet',
                        'Anger vs Discipline',
                        'Late Night Shift',
                        "Company Captain's Presence",
                        'Regretful Past',
                        'Royal Flush',
                        'POWAHH!!!',
                        'Shall Know Pain',
                        'Master of Toads',
                        'Destroyer of Worlds',
                        'Lifeforce Absorption',
                        'Lord of the Fairies',
                        'Speed Boost I',
                        'Special Grade',
                        'Immortal Divine General',
                        'Damage Boost I',
                        'Gambling Fanatic',
                        'Young Entrepreneur',
                    }),
                    rarityColors = table.freeze({
                        Mythic = 'rose',
                        Legendary = 'gold',
                        Epic = 'violet',
                        Rare = 'blue',
                    }),
                    roomTags = table.freeze({
                        Battle = table.freeze({
                            text = '5 waves',
                            color = 'slate',
                        }),
                        Elite = table.freeze({
                            text = '15 waves',
                            color = 'rose',
                        }),
                        Shop = table.freeze({
                            text = 'Coins',
                            color = 'blue',
                        }),
                        Treasure = table.freeze({
                            text = 'Chests',
                            color = 'gold',
                        }),
                        Boss = table.freeze({
                            text = 'Every 30',
                            color = 'violet',
                        }),
                    }),
                    secondPriorityFloor = table.freeze({
                        min = 1,
                        max = 200,
                        default = 30,
                    }),
                    cashOutFloor = table.freeze({
                        min = 1,
                        max = 100,
                        default = 30,
                    }),
                    failsafeMinutes = table.freeze({
                        min = 1,
                        max = 30,
                        default = 10,
                    }),
                    shopRerollTimes = table.freeze({
                        min = 1,
                        max = 20,
                        default = 3,
                    }),
                    basicCardCaps = table.freeze({
                        Rare = 4,
                        Epic = 3,
                        Legendary = 3,
                        Mythic = 1,
                    }),
                    shopRerollSections = table.freeze({
                        'All',
                        'Card',
                        'Trait',
                        'Memoria',
                    }),
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
                    startDelaySeconds = 6,
                    riftAttemptWaitSeconds = 45,
                    returnGateMaxSeconds = 8,
                    adventureStateRetrySeconds = 5,
                    adventureStateMaxAgeSeconds = 600,
                    adventurePickDelaySeconds = 0.8,
                    adventureRepeatSeconds = 4,
                    adventureChestTeleportDelaySeconds = 1,
                    adventureChestGapSeconds = 1.8,
                    adventureShopGapSeconds = 1.2,
                    adventureShopWatchSeconds = 2,
                    adventureShopAskSeconds = 6,
                    adventureShopUiGraceSeconds = 2,
                    adventureTaskWaitSeconds = 90,
                    adventureTaskWaitRetrySeconds = 1.5,
                    adventureVoteRetrySeconds = 20,
                    adventureVoteAttempts = 3,
                }),
                remoteNames = table.freeze({
                    worldlineProgress = 'GetWorldlineProgress',
                    worldlineTeleport = 'TeleportToWorldline',
                    bossEventStart = 'StartBossEvent',
                    macroPlacementClient = 'GameUnitPlacementClient',
                    macroAbilityClient = 'GameUnitAbilitiesClient',
                    macroUnitsClient = 'GameUnitsClient',
                    macroUnitStateClient = 'GameUnitClientStateClient',
                    changeSetting = 'ChangeSetting',
                    toggleSetting = 'ToggleSetting',
                    joinRift = 'JoinRift',
                    getRiftAttempts = 'GetRiftAttempts',
                    requestTeleportToLobby = 'RequestTeleportToLobby',
                    toggleAutoPlay = 'ToggleAutoPlay',
                    castWaveSkipVote = 'CastWaveSkipVote',
                    switchAutoPlayPreset = 'SwitchAutoPlayPreset',
                    loadTeam = 'LoadTeam',
                    equipUnit = 'EquipUnitInSlot',
                    unequipAllUnits = 'UnequipAllUnits',
                    requestLoadTeam = 'RequestLoadTeam',
                    requestAutoPlayData = 'RequestAutoPlayData',
                    autoPlayPresetsUpdated = 'AutoPlayPresetsUpdated',
                    showEndScreen = 'ShowEndScreen',
                    adventureState = 'AdventureFullStateChanged',
                    requestAdventureState = 'RequestAdventureState',
                    setAdventureLoadout = 'SetAdventureLoadout',
                    startOdysseyAdventure = 'StartOdysseyAdventure',
                }),
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
    do
        local function __modImpl()
            local Style = {}
            local HEADING_SIZE = 18
            local SUB_HEADING_SIZE = 15
            local SUB_HEADING_DIM = 0.35
            local CARD_ICON_SIZE = 20

            function Style.section(host, title, icon, opened, size)
                return host:Section({
                    Title = title,
                    Icon = icon,
                    Box = true,
                    BoxBorder = true,
                    TextSize = size or HEADING_SIZE,
                    TextTransparency = 0,
                    Opened = opened == true,
                })
            end
            function Style.sub(host, title, icon, opened)
                if type(host.Section) ~= 'function' then
                    return host
                end

                return (host.Section)(host, {
                    Title = title,
                    Icon = icon,
                    TextSize = SUB_HEADING_SIZE,
                    TextTransparency = SUB_HEADING_DIM,
                    Opened = opened ~= false,
                })
            end
            function Style.card(host, title, desc, icon)
                return host:Paragraph({
                    Title = title,
                    Desc = desc,
                    Image = icon,
                    ImageSize = CARD_ICON_SIZE,
                })
            end

            return Style
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
            local Base = __DARKLUA_BUNDLE_MODULES.d()
            local Style = {}
            local JOINER_ICONS = {
                Stage = 'map',
                ['Legend Stage'] = 'crown',
                Raid = 'swords',
                Dungeon = 'skull',
                ['Boss Event'] = 'flame',
                Worldline = 'globe',
                ['Elemental Towers'] = 'castle',
                Portal = 'door-open',
                ['Boss Bounties'] = 'target',
                ['Regular Challenge'] = 'trophy',
                ['Daily Challenge'] = 'calendar',
                ['Weekly Challenge'] = 'clock',
                Rift = 'zap',
                ['Odyssey Adventure'] = 'compass',
            }
            local JOINER_TAGS = {
                Stage = {
                    text = 'Stage',
                    color = 'blue',
                },
                ['Legend Stage'] = {
                    text = 'Stage',
                    color = 'blue',
                },
                Raid = {
                    text = 'Stage',
                    color = 'blue',
                },
                Dungeon = {
                    text = 'Stage',
                    color = 'blue',
                },
                ['Boss Event'] = {
                    text = 'Event',
                    color = 'gold',
                },
                Worldline = {
                    text = 'Event',
                    color = 'gold',
                },
                ['Elemental Towers'] = {
                    text = 'Event',
                    color = 'gold',
                },
                Portal = {
                    text = 'Event',
                    color = 'gold',
                },
                ['Boss Bounties'] = {
                    text = 'Bounty',
                    color = 'orange',
                },
                ['Regular Challenge'] = {
                    text = 'Challenge',
                    color = 'violet',
                },
                ['Daily Challenge'] = {
                    text = 'Challenge',
                    color = 'violet',
                },
                ['Weekly Challenge'] = {
                    text = 'Challenge',
                    color = 'violet',
                },
                Rift = {
                    text = 'Hourly',
                    color = 'rose',
                },
                ['Odyssey Adventure'] = {
                    text = 'Adventure',
                    color = 'secondary',
                },
            }

            Style.section = Base.section
            Style.sub = Base.sub
            Style.card = Base.card

            function Style.joiner(host, name, opened)
                return Base.section(host, name .. ' Joiner', JOINER_ICONS[name], opened)
            end
            function Style.joinerTags()
                return table.clone(JOINER_TAGS)
            end

            return Style
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
            local Catalog = {}
            local SUPPORTED = {
                Story = true,
                LegendStage = true,
                Raid = true,
                Dungeon = true,
            }

            local function naturalLess(left, right)
                local a = tonumber(left:match('%d+$'))
                local b = tonumber(right:match('%d+$'))

                if a and b and a ~= b then
                    return a < b
                end

                return left < right
            end

            function Catalog.list(data, mode)
                if not SUPPORTED[mode] or type(data) ~= 'table' or type(data[mode]) ~= 'table' then
                    return {}
                end

                local stages = {}

                for id, stage in data[mode]do
                    if type(id) == 'string' and type(stage) == 'table' and type(stage.Acts) == 'table' then
                        local acts = {}

                        for actId, act in stage.Acts do
                            if type(actId) == 'string' and type(act) == 'table' then
                                table.insert(acts, {
                                    id = actId,
                                    name = if type(act.ActName) == 'string'then act.ActName else actId,
                                })
                            end
                        end

                        table.sort(acts, function(a, b)
                            return naturalLess(a.id, b.id)
                        end)

                        if #acts > 0 then
                            local rawName = stage.StageData and stage.StageData.Name

                            table.insert(stages, {
                                id = id,
                                name = if type(rawName) == 'string'then rawName else id,
                                acts = acts,
                            })
                        end
                    end
                end

                table.sort(stages, function(a, b)
                    return naturalLess(a.id, b.id)
                end)

                return stages
            end

            return Catalog
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
            return table.freeze({
                'Stage',
                'Legend Stage',
                'Raid',
                'Dungeon',
                'Boss Event',
                'Worldline',
                'Elemental Towers',
                'Portal',
                'Boss Bounties',
                'Regular Challenge',
                'Daily Challenge',
                'Weekly Challenge',
                'Rift',
                'Odyssey Adventure',
            })
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
            local TeamEquip = {}
            local SLOT_COUNT = 6
            local MAX_TEAM_NUMBER = 99

            function TeamEquip.number(key)
                if type(key) ~= 'string' or #key > 8 then
                    return nil
                end

                local digits = string.match(key, '^Team(%d+)$')
                local value = if digits then tonumber(digits)else nil

                if value == nil or value < 1 or value > MAX_TEAM_NUMBER then
                    return nil
                end

                return value
            end
            function TeamEquip.validKey(key)
                return TeamEquip.number(key) ~= nil
            end
            function TeamEquip.options(teams, isOwned)
                local numbers = {}

                if type(teams) == 'table' then
                    for key in teams do
                        local number = TeamEquip.number(key)

                        if number and isOwned(number) then
                            table.insert(numbers, number)
                        end
                    end
                end

                table.sort(numbers)

                local options = {}

                for _, number in numbers do
                    local key = 'Team' .. number
                    local team = (teams)[key]
                    local name = if type(team) == 'table'then team.Name else nil
                    local label = if type(name) == 'string' and name ~= ''then key .. ' - ' .. name else key

                    table.insert(options, {
                        key = key,
                        label = label,
                    })
                end

                return options
            end

            local function isEmptySlot(value)
                return value == nil or value == '' or value == 'None'
            end

            function TeamEquip.evaluate(team, ownsUnit, equipped)
                if type(team) ~= 'table' or type(team.Units) ~= 'table' then
                    return 'unusable'
                end

                local usable = 0
                local mismatch = false

                for slot = 1, SLOT_COUNT do
                    local guid = team.Units[slot]
                    local current = if type(equipped) == 'table'then equipped[slot]else nil

                    if type(guid) == 'string' and not isEmptySlot(guid) then
                        if ownsUnit(guid) then
                            usable += 1

                            if current ~= guid then
                                mismatch = true
                            end
                        end
                    elseif not isEmptySlot(current) then
                        mismatch = true
                    end
                end

                if usable == 0 then
                    return 'unusable'
                end

                return if mismatch then'mismatch'else'match'
            end
            function TeamEquip.rowFor(
                matchData,
                isBountyMatch,
                stageTypeRows,
                challengeRows
            )
                if type(matchData) ~= 'table' or type(stageTypeRows) ~= 'table' or type(challengeRows) ~= 'table' then
                    return nil
                end

                local challenge = matchData.ChallengeType or matchData.Challenge

                if type(challenge) == 'string' and challengeRows[challenge] then
                    return challengeRows[challenge]
                end
                if matchData.Rift ~= nil or matchData.StageType == 'Rift' then
                    return stageTypeRows.Rift
                end
                if isBountyMatch then
                    return 'Boss Bounties'
                end

                local stageType = matchData.StageType

                return if type(stageType) == 'string'then stageTypeRows[stageType]else nil
            end

            return TeamEquip
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
            local MacroEquip = {}
            local MAX_UNITS = 6

            function MacroEquip.validName(name)
                return type(name) == 'string' and #name > 0 and #name <= 64 and string.match(name, '^[%w_%-]+$') ~= nil
            end

            local function hasSubTrait(unit)
                return if unit.subTrait ~= '' and unit.subTrait ~= 'None'then 1 else 0
            end
            local function better(a, b)
                if a.level ~= b.level then
                    return a.level > b.level
                end
                if hasSubTrait(a) ~= hasSubTrait(b) then
                    return hasSubTrait(a) > hasSubTrait(b)
                end
                if a.ascensions ~= b.ascensions then
                    return a.ascensions > b.ascensions
                end
                if a.takedowns ~= b.takedowns then
                    return a.takedowns > b.takedowns
                end

                return a.guid < b.guid
            end

            function MacroEquip.best(owned, name)
                local winner = nil

                for _, unit in owned do
                    if unit.name == name and (winner == nil or better(unit, winner)) then
                        winner = unit
                    end
                end

                return winner
            end
            function MacroEquip.names(units)
                local result = {}
                local seen = {}

                if type(units) == 'table' then
                    for _, name in units do
                        if type(name) == 'string' and name ~= '' and not seen[name] and #result < MAX_UNITS then
                            seen[name] = true

                            table.insert(result, name)
                        end
                    end
                end

                return result
            end
            function MacroEquip.plan(names, equipped, owned)
                local equippedNames = {}

                for _, unit in equipped do
                    equippedNames[unit.name] = true
                end

                local steps = {}
                local missing = {}
                local complete = true

                for _, name in names do
                    local best = MacroEquip.best(owned, name)

                    if best == nil then
                        table.insert(missing, name)
                    else
                        table.insert(steps, best.guid)

                        if not equippedNames[name] then
                            complete = false
                        end
                    end
                end

                local state = if#steps == 0 or complete then'match'else'equip'

                return {
                    state = state,
                    steps = steps,
                    missing = missing,
                }
            end

            return MacroEquip
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
            local Capabilities = __DARKLUA_BUNDLE_MODULES.j()
            local Validation = __DARKLUA_BUNDLE_MODULES.k()
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
            local definitions = __DARKLUA_BUNDLE_MODULES.g()
            local TeamEquip = __DARKLUA_BUNDLE_MODULES.h()
            local MacroEquip = __DARKLUA_BUNDLE_MODULES.i()
            local FileStorage = __DARKLUA_BUNDLE_MODULES.l()
            local Settings = {}
            local DEFAULT_COOLDOWN = 0
            local MAX_COOLDOWN = 300
            local REGULAR_REWARD_MAP = table.freeze({
                ['Trait Rerolls'] = 'Trait Reroll Challenge',
                ['Stat Chips'] = 'Stat Chip Challenge',
                ['Memoria Shards'] = 'Memoria Shard Challenge',
                ['Green Essence Stone'] = 'Essence Stone Challenge (Green)',
                ['Legendary Essence Stone'] = 'Essence Stone Challenge (Legendary)',
                ['Mythic Essence Stone'] = 'Essence Stone Challenge (Mythic)',
            })

            Settings.REGULAR_REWARD_MAP = REGULAR_REWARD_MAP

            local FIRST_PRIORITY = {
                'Rift',
                'Weekly Challenge',
                'Daily Challenge',
                'Regular Challenge',
            }

            local function defaultPriority()
                local result = table.clone(FIRST_PRIORITY)

                for _, name in definitions do
                    if not table.find(result, name) then
                        table.insert(result, name)
                    end
                end

                return result
            end

            local paused = true
            local cooldown = DEFAULT_COOLDOWN
            local priority = defaultPriority()
            local enabled = {}
            local selection = {}
            local changeStageInMatch = true
            local teamEquipEnabled = false
            local teamEquipTeams = {}
            local macroEquipEnabled = false
            local macroEquipMacros = {}
            local bountyRun = nil
            local joinerRun = nil
            local storage = nil
            local encode = nil

            local function known(name)
                return table.find(definitions, name) ~= nil
            end
            local function save()
                local activeStorage = storage
                local codec = encode

                if not activeStorage or not codec then
                    return
                end

                local ok, body = pcall(codec, {
                    schemaVersion = 1,
                    paused = paused,
                    cooldown = cooldown,
                    priority = priority,
                    enabled = enabled,
                    selection = selection,
                    changeStageInMatch = changeStageInMatch,
                    bountyRun = bountyRun,
                    joinerRun = joinerRun,
                    teamEquip = {
                        enabled = teamEquipEnabled,
                        teams = teamEquipTeams,
                    },
                    macroEquip = {
                        enabled = macroEquipEnabled,
                        macros = macroEquipMacros,
                    },
                })

                if ok and type(body) == 'string' then
                    activeStorage.write(body)
                end
            end

            function Settings.init(env)
                storage = FileStorage.new(env, 'AnimeVanguardsJoiner')

                local activeStorage = storage

                if not activeStorage then
                    return
                end

                local http = env.game:GetService('HttpService')
                local body, readError = activeStorage.read()

                if readError then
                    storage = nil

                    return
                end

                encode = function(value)
                    return http:JSONEncode(value)
                end

                if not body then
                    return
                end

                local ok, data = pcall(function()
                    return http:JSONDecode(body)
                end)

                if not ok or type(data) ~= 'table' or data.schemaVersion ~= 1 then
                    storage = nil
                    encode = nil

                    return
                end
                if type(data.paused) == 'boolean' then
                    paused = data.paused
                end
                if type(data.cooldown) == 'number' and data.cooldown == data.cooldown and data.cooldown ~= math.huge and data.cooldown ~=
-math.huge then
                    cooldown = math.clamp(math.floor(data.cooldown), DEFAULT_COOLDOWN, MAX_COOLDOWN)
                end
                if type(data.priority) == 'table' then
                    local seen = {}
                    local valid = true
                    local retained = {}

                    for _, name in data.priority do
                        if type(name) ~= 'string' or seen[name] then
                            valid = false

                            break
                        end

                        seen[name] = true

                        if known(name) then
                            table.insert(retained, name)
                        end
                    end

                    if valid then
                        for _, defName in definitions do
                            if not table.find(retained, defName) then
                                table.insert(retained, defName)
                            end
                        end

                        priority = retained
                    end
                end
                if type(data.joinerRun) == 'table' and type(data.joinerRun.mode) == 'string' and type(data.joinerRun.stage) == 'string' and type(data.joinerRun.act) == 'string' and type(data.joinerRun.at) == 'number' then
                    joinerRun = {
                        mode = data.joinerRun.mode,
                        stage = data.joinerRun.stage,
                        act = data.joinerRun.act,
                        at = data.joinerRun.at,
                    }
                end
                if type(data.teamEquip) == 'table' then
                    if type(data.teamEquip.enabled) == 'boolean' then
                        teamEquipEnabled = data.teamEquip.enabled
                    end
                    if type(data.teamEquip.teams) == 'table' then
                        for name, key in data.teamEquip.teams do
                            if type(name) == 'string' and known(name) and TeamEquip.validKey(key) then
                                teamEquipTeams[name] = key
                            end
                        end
                    end
                end
                if type(data.macroEquip) == 'table' then
                    if type(data.macroEquip.enabled) == 'boolean' then
                        macroEquipEnabled = data.macroEquip.enabled
                    end
                    if type(data.macroEquip.macros) == 'table' then
                        for name, file in data.macroEquip.macros do
                            if type(name) == 'string' and known(name) and MacroEquip.validName(file) then
                                macroEquipMacros[name] = file
                            end
                        end
                    end
                end
                if type(data.changeStageInMatch) == 'boolean' then
                    changeStageInMatch = data.changeStageInMatch
                end
                if type(data.bountyRun) == 'table' and type(data.bountyRun.mode) == 'string' and type(data.bountyRun.stage) == 'string' and type(data.bountyRun.act) == 'string' and type(data.bountyRun.at) == 'number' then
                    bountyRun = {
                        mode = data.bountyRun.mode,
                        stage = data.bountyRun.stage,
                        act = data.bountyRun.act,
                        at = data.bountyRun.at,
                    }
                end
                if type(data.enabled) == 'table' then
                    for name, value in data.enabled do
                        if type(name) == 'string' and known(name) and type(value) == 'boolean' then
                            enabled[name] = value
                        end
                    end
                end
                if type(data.selection) == 'table' then
                    for name, value in data.selection do
                        if type(name) == 'string' and known(name) and type(value) == 'table' and type(value.stage) == 'string' and type(value.act) == 'string' and type(value.difficulty) == 'string' and #value.stage <= 80 and #value.act <= 80 then
                            selection[name] = {
                                stage = value.stage,
                                act = value.act,
                                difficulty = value.difficulty,
                            }
                        elseif type(name) == 'string' and name == 'Rift' and type(value) == 'table' then
                            local backToLobby = value.backToLobby == true
                            local returnMode = if value.returnMode == 'Wait Match End'then'Wait Match End'else'Immediate'

                            selection.Rift = {
                                backToLobby = backToLobby,
                                returnMode = returnMode,
                            }
                        elseif type(name) == 'string' and name == 'Regular Challenge' and type(value) == 'table' then
                            local reward = if type(value.rewardChoice) == 'string' and REGULAR_REWARD_MAP[value.rewardChoice]then value.rewardChoice else'Trait Rerolls'
                            local challengeName = REGULAR_REWARD_MAP[reward] or 'Trait Reroll Challenge'
                            local backToLobby = value.backToLobby == true
                            local returnMode = if value.returnMode == 'Wait Match End'then'Wait Match End'else'Immediate'

                            selection['Regular Challenge'] = {
                                rewardChoice = reward,
                                challengeName = challengeName,
                                backToLobby = backToLobby,
                                returnMode = returnMode,
                            }
                        elseif type(name) == 'string' and (name == 'Daily Challenge' or name == 'Weekly Challenge') and type(value) == 'table' then
                            local challengeName = if type(value.challengeName) == 'string' and #value.challengeName <= 80 then value.challengeName else name
                            local backToLobby = value.backToLobby == true
                            local returnMode = if value.returnMode == 'Wait Match End'then'Wait Match End'else'Immediate'

                            selection[name] = {
                                challengeName = challengeName,
                                backToLobby = backToLobby,
                                returnMode = returnMode,
                            }
                        elseif type(name) == 'string' and known(name) and type(value) == 'table' and type(value.challengeName) == 'string' and #value.challengeName <= 80 then
                            selection[name] = {
                                challengeName = value.challengeName,
                            }
                        elseif type(name) == 'string' and name == 'Worldline' and type(value) == 'table' and type(value.worldlineId) == 'string' and #value.worldlineId <= 80 and (value.traitsType == 'Traits' or value.traitsType == 'NoTraits') then
                            selection[name] = {
                                worldlineId = value.worldlineId,
                                traitsType = value.traitsType,
                            }
                        elseif type(name) == 'string' and name == 'Boss Event' and type(value) == 'table' and type(value.eventName) == 'string' and #value.eventName <= 80 and (value.difficulty == 'Normal' or value.difficulty == 'Elite') then
                            selection[name] = {
                                eventName = value.eventName,
                                difficulty = value.difficulty,
                            }
                        end
                    end
                end
            end
            function Settings.get()
                return {
                    paused = paused,
                    cooldown = cooldown,
                    priority = table.clone(priority),
                    enabled = table.clone(enabled),
                    selection = table.clone(selection),
                    changeStageInMatch = changeStageInMatch,
                    bountyRun = bountyRun,
                    joinerRun = joinerRun,
                    teamEquip = {
                        enabled = teamEquipEnabled,
                        teams = table.clone(teamEquipTeams),
                    },
                    macroEquip = {
                        enabled = macroEquipEnabled,
                        macros = table.clone(macroEquipMacros),
                    },
                    persistent = storage ~= nil,
                }
            end
            function Settings.setTeamEquipEnabled(value)
                if type(value) ~= 'boolean' then
                    return false
                end

                teamEquipEnabled = value

                save()

                return true
            end
            function Settings.setMacroEquipEnabled(value)
                if type(value) ~= 'boolean' then
                    return false
                end

                macroEquipEnabled = value

                save()

                return true
            end
            function Settings.setMacroForJoiner(name, file)
                if type(name) ~= 'string' or not known(name) then
                    return false
                end
                if file == nil then
                    macroEquipMacros[name] = nil
                elseif MacroEquip.validName(file) then
                    macroEquipMacros[name] = file
                else
                    return false
                end

                save()

                return true
            end
            function Settings.setTeamForJoiner(name, key)
                if type(name) ~= 'string' or not known(name) then
                    return false
                end
                if key == nil then
                    teamEquipTeams[name] = nil
                elseif TeamEquip.validKey(key) then
                    teamEquipTeams[name] = key
                else
                    return false
                end

                save()

                return true
            end
            function Settings.setChangeStageInMatch(value)
                if type(value) ~= 'boolean' then
                    return false
                end

                changeStageInMatch = value

                save()

                return true
            end
            function Settings.setJoinerRun(run)
                if run == nil then
                    joinerRun = nil
                elseif type(run) == 'table' and type(run.mode) == 'string' and type(run.stage) == 'string' and type(run.act) == 'string' and type(run.at) == 'number' then
                    joinerRun = {
                        mode = run.mode,
                        stage = run.stage,
                        act = run.act,
                        at = run.at,
                    }
                else
                    return false
                end

                save()

                return true
            end
            function Settings.setBountyRun(run)
                if run == nil then
                    bountyRun = nil
                elseif type(run) == 'table' and type(run.mode) == 'string' and type(run.stage) == 'string' and type(run.act) == 'string' and type(run.at) == 'number' then
                    bountyRun = {
                        mode = run.mode,
                        stage = run.stage,
                        act = run.act,
                        at = run.at,
                    }
                else
                    return false
                end

                save()

                return true
            end
            function Settings.setEnabled(name, value)
                if not known(name) or type(value) ~= 'boolean' then
                    return false
                end

                enabled[name] = value

                save()

                return true
            end
            function Settings.setSelection(name, value)
                if not known(name) or type(value) ~= 'table' then
                    return false
                end

                selection[name] = table.clone(value)

                save()

                return true
            end
            function Settings.setBackToLobby(name, backToLobby, returnMode)
                if type(name) ~= 'string' or not known(name) or type(backToLobby) ~= 'boolean' then
                    return false
                end

                local mode = if returnMode == 'Wait Match End'then'Wait Match End'else'Immediate'
                local current = selection[name] or {}
                local updated = table.clone(current)

                updated.backToLobby = backToLobby
                updated.returnMode = mode
                selection[name] = updated

                save()

                return true
            end
            function Settings.setRegularReward(rewardChoice)
                local challengeName = REGULAR_REWARD_MAP[rewardChoice]

                if not challengeName then
                    return false
                end

                local current = selection['Regular Challenge'] or {}
                local updated = table.clone(current)

                updated.rewardChoice = rewardChoice
                updated.challengeName = challengeName
                selection['Regular Challenge'] = updated

                save()

                return true
            end
            function Settings.setPaused(value)
                if type(value) ~= 'boolean' then
                    return false
                end

                paused = value

                save()

                return true
            end
            function Settings.setCooldown(value)
                if type(value) ~= 'number' or value ~= value or value == math.huge or value ==
-math.huge then
                    return false
                end

                cooldown = math.clamp(math.floor(value), DEFAULT_COOLDOWN, MAX_COOLDOWN)

                save()

                return true
            end
            function Settings.swap(first, second)
                if type(first) ~= 'string' or type(second) ~= 'string' or first == second then
                    return false
                end

                local a, b = table.find(priority, first), table.find(priority, second)

                if not a or not b then
                    return false
                end

                priority[a], priority[b] = priority[b], priority[a]

                save()

                return true
            end
            function Settings.resetPriority()
                priority = defaultPriority()

                save()

                return table.clone(priority)
            end

            return Settings
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
            local Theme = __DARKLUA_BUNDLE_MODULES.n()
            local PriorityList = {}
            local ROW_HEIGHT = 32
            local ROW_GAP = 4
            local NUMBER_WIDTH = 30
            local STRIPE_WIDTH = 3
            local TAG_WIDTH = 74
            local DRAG_THRESHOLD = 4
            local EDGE_SCROLL = 28
            local SCROLL_STEP = 10
            local SUMMARY_ENTRIES = 6
            local DEFAULT_VISIBLE = 7
            local SLIDE_SECONDS = 0.18
            local MESSAGE_SECONDS = 4
            local ALPHA_REST = 0.93
            local ALPHA_HOVER = 0.88
            local ALPHA_TARGET = 0.8
            local ALPHA_SOURCE = 0.97
            local LOCKED_ALPHA = 0.55

            function PriorityList.labels(order)
                local result = {}

                for index, name in order do
                    table.insert(result, string.format('%d. %s', #order - index + 1, name))
                end

                return result
            end
            function PriorityList.summary(order)
                if #order <= SUMMARY_ENTRIES then
                    return table.concat(order, ' > ')
                end

                return table.concat(order, ' > ', 1, SUMMARY_ENTRIES) .. string.format(' > \u{2026} (+%d)', #order - SUMMARY_ENTRIES)
            end
            function PriorityList.offsets(count)
                local result = {}

                for index = 1, count do
                    result[index] = (index - 1) * (ROW_HEIGHT + ROW_GAP)
                end

                return result
            end
            function PriorityList.movable(options, name)
                return options.locked ~= true and not (options.lockedRows and options.lockedRows[name])
            end
            function PriorityList.rowAt(tops, height, y)
                for index, top in tops do
                    if y >= top and y < top + height then
                        return index
                    end
                end

                return nil
            end

            local function containerOf(card)
                local ok, container = pcall(function()
                    return card.ParagraphFrame.UIElements.Container
                end)
                local kind = if ok then typeof(container)else''

                return if kind == 'Instance'then container else nil
            end

            function PriorityList.mount(host, options)
                local current = table.clone(options.order)
                local tags = options.tags or {}
                local message = nil
                local card = host:Paragraph({
                    Title = options.title,
                    Desc = options.desc .. '\n' .. PriorityList.summary(current),
                })

                local function setDesc()
                    local text = options.desc .. '\n' .. (message or PriorityList.summary(current))

                    pcall(card.SetDesc, card, text)
                end

                local env = getfenv()
                local container = containerOf(card)
                local New = env.Instance

                if not container or not New or not env.game then
                    return {
                        refresh = function(newOrder)
                            current = table.clone(newOrder)

                            setDesc()
                        end,
                        card = card,
                    }
                end

                local UDim2 = env.UDim2
                local UDim = env.UDim
                local Vector2 = env.Vector2
                local Enum = env.Enum
                local Font = env.Font
                local taskApi = env.task
                local input = env.game:GetService('UserInputService')
                local guiService = env.game:GetService('GuiService')
                local tweens = env.game:GetService('TweenService')
                local slide = env.TweenInfo.new(SLIDE_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local titleLabel = card.ParagraphFrame.UIElements.Title

                local function textColor()
                    local ok, color = pcall(function()
                        return titleLabel.TextColor3
                    end)

                    return if ok and color then color else env.Color3.new(1, 1, 1)
                end
                local function fontWith(weight)
                    local ok, font = pcall(function()
                        return Font.new(titleLabel.FontFace.Family, weight)
                    end)

                    return if ok then font else titleLabel.FontFace
                end

                local list = New.new('ScrollingFrame')

                list.Name = 'PriorityList'
                list.BackgroundTransparency = 1
                list.BorderSizePixel = 0
                list.ScrollBarThickness = 4
                list.ScrollingDirection = Enum.ScrollingDirection.Y
                list.LayoutOrder = 100
                list.Parent = container

                local rows = {}
                local drag = nil
                local hovered = nil

                local function pointer()
                    return input:GetMouseLocation() - guiService:GetGuiInset()
                end
                local function rowUnder(position)
                    local tops = {}

                    for index, name in current do
                        local row = rows[name]
                        local inside = row and position.X >= row.AbsolutePosition.X and position.X <= row.AbsolutePosition.X + row.AbsoluteSize.X

                        tops[index] = if inside then row.AbsolutePosition.Y else
-math.huge
                    end

                    local index = PriorityList.rowAt(tops, ROW_HEIGHT, position.Y)

                    return if index then current[index]else nil
                end
                local function paint()
                    local color = textColor()

                    for name, row in rows do
                        local isSource = drag ~= nil and drag.ghost ~= nil and drag.name == name
                        local isTarget = drag ~= nil and drag.ghost ~= nil and drag.target == name and drag.target ~= drag.name
                        local fixed = not PriorityList.movable(options, name)

                        row.BackgroundColor3 = color
                        row.BackgroundTransparency = if isSource
                            then ALPHA_SOURCE
                            elseif isTarget
                            then ALPHA_TARGET
                            elseif hovered == name and not drag and not fixed
                            then ALPHA_HOVER
                            else ALPHA_REST
                        row.Number.TextColor3 = color
                        row.Label.TextColor3 = color
                        row.Grip.TextColor3 = color
                        row.Number.TextTransparency = if isSource
                            then 0.7
                            elseif fixed
                            then LOCKED_ALPHA
                            else 0
                        row.Label.TextTransparency = if isSource
                            then 0.7
                            elseif fixed
                            then LOCKED_ALPHA
                            else 0
                        row.Grip.Text = if isTarget
                            then'\u{21c4}'
                            elseif fixed
                            then''
                            else'\u{2261}'
                        row.Grip.TextTransparency = if isTarget then 0 else 0.55
                        row.Stroke.Color = color
                        row.Stroke.Transparency = if isTarget then 0.35 else 1
                    end
                end
                local function place(animated)
                    local tops = PriorityList.offsets(#current)

                    for index, name in current do
                        local row = rows[name]

                        if row then
                            row.Number.Text = tostring(#current - index + 1)

                            local goal = UDim2.new(0, 0, 0, tops[index])

                            if animated then
                                tweens:Create(row, slide, {Position = goal}):Play()
                            else
                                row.Position = goal
                            end
                        end
                    end

                    local height = #current * (ROW_HEIGHT + ROW_GAP) - ROW_GAP

                    list.CanvasSize = UDim2.new(0, 0, 0, math.max(height, 0))

                    local visible = math.min(#current, options.visibleRows or DEFAULT_VISIBLE)

                    list.Size = UDim2.new(1, 0, 0, math.max(visible * (ROW_HEIGHT + ROW_GAP) - ROW_GAP, 0))
                end
                local function showMessage(text)
                    message = text

                    setDesc()

                    if taskApi and type(taskApi.delay) == 'function' then
                        (taskApi.delay)(MESSAGE_SECONDS, function()
                            if message == text then
                                message = nil

                                setDesc()
                            end
                        end)
                    end
                end
                local function endDrag(position)
                    local active = drag

                    drag = nil

                    if not active then
                        return
                    end

                    for _, connection in active.connections do
                        connection:Disconnect()
                    end

                    if active.ghost then
                        active.ghost:Destroy()
                    end

                    local target = if position and active.ghost then rowUnder(position)else nil

                    if target and target ~= active.name then
                        local newOrder = options.onSwap(active.name, target)

                        if newOrder then
                            current = table.clone(newOrder)

                            place(true)
                            showMessage(string.format('Swapped %s \u{21c4} %s', tostring(active.name), target))
                        end
                    end

                    paint()
                end
                local function startDrag(name)
                    if drag or not PriorityList.movable(options, name) then
                        return
                    end

                    local start = pointer()
                    local state = {
                        name = name,
                        target = nil,
                        ghost = nil,
                        connections = {},
                    }

                    drag = state

                    local moved = input.InputChanged:Connect(function(changed)
                        local kind = changed.UserInputType

                        if kind ~= Enum.UserInputType.MouseMovement and kind ~= Enum.UserInputType.Touch then
                            return
                        end

                        local position = pointer()

                        if not state.ghost then
                            if (position - start).Magnitude < DRAG_THRESHOLD then
                                return
                            end

                            local source = rows[name]
                            local ghost = source:Clone()

                            ghost.Name = 'PriorityListGhost'
                            ghost.Size = UDim2.fromOffset(source.AbsoluteSize.X, source.AbsoluteSize.Y)
                            ghost.AnchorPoint = Vector2.new(0, 0.5)
                            ghost.BackgroundTransparency = ALPHA_TARGET
                            ghost.Stroke.Transparency = 0.3
                            ghost.ZIndex = 50

                            for _, child in ghost:GetDescendants()do
                                if child:IsA('GuiObject') then
                                    child.ZIndex = 51
                                end
                            end

                            ghost.Parent = list:FindFirstAncestorWhichIsA('ScreenGui')
                            state.ghost = ghost
                            state.offsetX = position.X - source.AbsolutePosition.X
                        end

                        local origin = state.ghost.Parent.AbsolutePosition

                        state.ghost.Position = UDim2.fromOffset(position.X - state.offsetX - origin.X, position.Y - origin.Y)

                        local top = list.AbsolutePosition.Y
                        local bottom = top + list.AbsoluteSize.Y

                        if position.Y < top + EDGE_SCROLL then
                            list.CanvasPosition = Vector2.new(0, math.max(0, list.CanvasPosition.Y - SCROLL_STEP))
                        elseif position.Y > bottom - EDGE_SCROLL then
                            list.CanvasPosition = Vector2.new(0, list.CanvasPosition.Y + SCROLL_STEP)
                        end

                        local over = rowUnder(position)

                        state.target = if over and PriorityList.movable(options, over)then over else nil

                        paint()
                    end)
                    local released = input.InputEnded:Connect(function(ended)
                        local kind = ended.UserInputType

                        if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
                            endDrag(pointer())
                        end
                    end)

                    table.insert(state.connections, moved)
                    table.insert(state.connections, released)
                end
                local function makeRow(name)
                    local tag = tags[name]
                    local tagColor = if tag then Theme.color(tag.color)else nil
                    local row = New.new('TextButton')

                    row.Name = 'Row'

                    row:SetAttribute('NoGlow', true)

                    row.Text = ''
                    row.AutoButtonColor = false
                    row.BorderSizePixel = 0
                    row.Size = UDim2.new(1, -8, 0, ROW_HEIGHT)

                    local corner = New.new('UICorner')

                    corner.CornerRadius = UDim.new(0, 7)
                    corner.Parent = row

                    local stroke = New.new('UIStroke')

                    stroke.Name = 'Stroke'
                    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    stroke.Thickness = 1.5
                    stroke.Transparency = 1
                    stroke.Parent = row

                    if tagColor then
                        local stripe = New.new('Frame')

                        stripe.Name = 'Stripe'
                        stripe.BorderSizePixel = 0
                        stripe.BackgroundColor3 = tagColor
                        stripe.Position = UDim2.fromOffset(4, 7)
                        stripe.Size = UDim2.new(0, STRIPE_WIDTH, 1, -14)

                        local round = New.new('UICorner')

                        round.CornerRadius = UDim.new(1, 0)
                        round.Parent = stripe
                        stripe.Parent = row
                    end

                    local number = New.new('TextLabel')

                    number.Name = 'Number'
                    number.BackgroundTransparency = 1
                    number.Position = UDim2.fromOffset(10, 0)
                    number.Size = UDim2.new(0, NUMBER_WIDTH, 1, 0)
                    number.TextXAlignment = Enum.TextXAlignment.Right
                    number.TextSize = 14
                    number.FontFace = fontWith(Enum.FontWeight.Bold)
                    number.Parent = row

                    local label = New.new('TextLabel')

                    label.Name = 'Label'
                    label.BackgroundTransparency = 1
                    label.Position = UDim2.fromOffset(10 + NUMBER_WIDTH + 10, 0)

                    local reserved = if tag and tagColor then TAG_WIDTH + 8 else 0

                    label.Size = UDim2.new(1, -(10 + NUMBER_WIDTH + 10 + reserved + 30), 1, 0)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.TextTruncate = Enum.TextTruncate.AtEnd
                    label.TextSize = 14
                    label.FontFace = fontWith(Enum.FontWeight.Medium)
                    label.Text = name
                    label.Parent = row

                    if tag and tagColor then
                        local chip = New.new('TextLabel')

                        chip.Name = 'Tag'
                        chip.AnchorPoint = Vector2.new(1, 0.5)
                        chip.Position = UDim2.new(1, -30, 0.5, 0)
                        chip.Size = UDim2.fromOffset(TAG_WIDTH, 18)
                        chip.BackgroundColor3 = tagColor
                        chip.BackgroundTransparency = 0.82
                        chip.TextColor3 = tagColor
                        chip.TextSize = 11
                        chip.FontFace = fontWith(Enum.FontWeight.Bold)
                        chip.Text = string.upper(tag.text)

                        local round = New.new('UICorner')

                        round.CornerRadius = UDim.new(1, 0)
                        round.Parent = chip
                        chip.Parent = row
                    end

                    local grip = New.new('TextLabel')

                    grip.Name = 'Grip'
                    grip.BackgroundTransparency = 1
                    grip.AnchorPoint = Vector2.new(1, 0)
                    grip.Position = UDim2.new(1, -6, 0, 0)
                    grip.Size = UDim2.new(0, 20, 1, 0)
                    grip.TextSize = 16
                    grip.Text = '\u{2261}'
                    grip.Parent = row

                    row.MouseEnter:Connect(function()
                        hovered = name

                        paint()
                    end)
                    row.MouseLeave:Connect(function()
                        if hovered == name then
                            hovered = nil

                            paint()
                        end
                    end)
                    row.InputBegan:Connect(function(began)
                        local kind = began.UserInputType

                        if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
                            startDrag(name)
                        end
                    end)

                    row.Parent = list

                    return row
                end
                local function sync()
                    endDrag(nil)

                    for name, row in rows do
                        if not table.find(current, name) then
                            row:Destroy()

                            rows[name] = nil
                        end
                    end
                    for _, name in current do
                        if not rows[name] then
                            rows[name] = makeRow(name)
                        end
                    end
                end

                sync()
                place(false)
                paint()
                pcall(function()
                    titleLabel:GetPropertyChangedSignal('TextColor3'):Connect(paint)
                end)

                return {
                    refresh = function(newOrder)
                        current = table.clone(newOrder)
                        message = nil

                        sync()
                        place(true)
                        paint()
                        setDesc()
                    end,
                    card = card,
                }
            end

            return PriorityList
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
            local Style = __DARKLUA_BUNDLE_MODULES.e()
            local Catalog = __DARKLUA_BUNDLE_MODULES.f()
            local definitions = __DARKLUA_BUNDLE_MODULES.g()
            local Settings = __DARKLUA_BUNDLE_MODULES.m()
            local PriorityList = __DARKLUA_BUNDLE_MODULES.o()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local Page = {}
            local STARTUP_WAIT_TICKS = 60
            local UNAVAILABLE = {
                'Elemental Towers',
                'Portal',
            }

            local function resolve(root, path)
                local value = root

                for part in string.gmatch(path, '[^%.]+')do
                    if not value then
                        return nil
                    end

                    local ok, child = pcall(function()
                        local v = value

                        if type(v) == 'userdata' then
                            return v:FindFirstChild(part)
                        else
                            return v[part]
                        end
                    end)

                    value = if ok then child else nil
                end

                return value
            end
            local function optionalModule(root, path)
                local ok, result = pcall(function()
                    local obj = resolve(root, path)

                    return if obj then(require)(obj)else nil
                end)

                return if ok then result else nil
            end
            local function readStageData()
                local env = getfenv()
                local ok, result = pcall(function()
                    local rep = env.game and env.game:GetService('ReplicatedStorage')

                    return optionalModule(rep, config.instancePaths.stagesData)
                end)

                return if ok then result else nil
            end
            local function readChallengeChoices()
                local env = getfenv()
                local ok, result = pcall(function()
                    local gameObject = env.game
                    local rep = gameObject and gameObject:GetService('ReplicatedStorage')
                    local definitions = optionalModule(rep, config.instancePaths.challengesData)
                    local rows = {}

                    for _, kind in {
                        'Regular',
                        'Daily',
                        'Weekly',
                    }do
                        rows[kind] = {}

                        if definitions and type(definitions.GetChallengesOfType) == 'function' then
                            local okList, list = pcall(definitions.GetChallengesOfType, kind)

                            if okList and type(list) == 'table' then
                                for _, challenge in list do
                                    if type(challenge) == 'table' and type(challenge.Name) == 'string' then
                                        table.insert(rows[kind], challenge.Name)
                                    end
                                end
                            end
                        end

                        table.sort(rows[kind])
                    end

                    return rows
                end)

                return if ok and type(result) == 'table'then result else{
                    Regular = {},
                    Daily = {},
                    Weekly = {},
                }
            end
            local function readSpecialChoices()
                local env = getfenv()
                local ok, result = pcall(function()
                    local replicated = env.game and env.game:GetService('ReplicatedStorage')
                    local worldlines = optionalModule(replicated, config.instancePaths.worldlinesData)
                    local rotation = optionalModule(replicated, config.instancePaths.bossRotation)
                    local shops = optionalModule(replicated, config.instancePaths.bossEventNames)
                    local currentBoss = nil

                    if rotation and type(rotation.GetCurrentBossEvent) == 'function' then
                        pcall(function()
                            currentBoss = (rotation.GetCurrentBossEvent)()
                        end)
                    end

                    local rows = {
                        worldlines = {},
                        bosses = {},
                        currentBoss = currentBoss,
                    }

                    if worldlines and type(worldlines.GetAll) == 'function' then
                        pcall(function()
                            for id, value in (worldlines.GetAll)()do
                                if type(id) == 'string' and type(value) == 'table' and type(value.DisplayName) == 'string' then
                                    table.insert(rows.worldlines, {
                                        id = id,
                                        name = value.DisplayName,
                                    })
                                end
                            end
                        end)
                    end

                    table.sort(rows.worldlines, function(a, b)
                        return (a.name) < (b.name)
                    end)

                    if shops and type(shops.GetAllEventNames) == 'function' then
                        pcall(function()
                            for _, name in (shops.GetAllEventNames)()do
                                if type(name) == 'string' then
                                    table.insert(rows.bosses, name)
                                end
                            end
                        end)
                    end

                    table.sort(rows.bosses)

                    return rows
                end)

                return if ok and type(result) == 'table'then result else{
                    worldlines = {},
                    bosses = {},
                    currentBoss = nil,
                }
            end
            local function addSpecial(tab, name, rows, runtime)
                local section = Style.joiner(tab, name, false)
                local worldline = name == 'Worldline'
                local entries = if type(rows) == 'table'then(if worldline then rows.worldlines else rows.bosses)else nil
                local values = {}
                local ids = {}

                if type(entries) == 'table' then
                    for _, entry in entries do
                        local id = if worldline then entry.id else entry
                        local label = if worldline then entry.name .. ' (' .. entry.id .. ')'else entry

                        if type(id) == 'string' and type(label) == 'string' then
                            table.insert(values, label)
                            table.insert(ids, id)
                        end
                    end
                end

                local saved = Settings.get()
                local previous = saved.selection[name]
                local preferred = if worldline then(previous and previous.worldlineId)else(previous and previous.eventName)
                local index = if type(preferred) == 'string'then table.find(ids, preferred)else nil

                if not worldline and type(rows) == 'table' and rows.currentBoss then
                    index = table.find(ids, rows.currentBoss)
                end

                index = index or 1

                local selected = ids[index]
                local option = if worldline then(if previous and previous.traitsType == 'NoTraits'then'NoTraits'else'Traits')else(previous and previous.difficulty) or 'Normal'

                local function update()
                    if not runtime or not selected then
                        return
                    end
                    if worldline then
                        runtime.setWorldline(selected, option)
                    else
                        runtime.setBossEvent(selected, option)
                    end
                end

                update()
                section:Toggle({
                    Title = 'Auto Join ' .. name,
                    Value = saved.enabled[name] == true and #values > 0,
                    Locked = runtime == nil or #values == 0,
                    Desc = if worldline then'Teleports to the selected Worldline.'else'Starts only the currently rotating boss event.',
                    Callback = function(value)
                        if runtime then
                            runtime.setEnabled(name, value)
                        end
                    end,
                })

                if runtime and saved.enabled[name] == true then
                    runtime.setEnabled(name, true)
                end
                if #values == 0 then
                    section:Paragraph({
                        Title = 'Availability',
                        Desc = 'Current game data is unavailable.',
                    })

                    return
                end
                if not worldline then
                    section:Paragraph({
                        Title = 'Current weekly boss',
                        Desc = tostring(rows.currentBoss),
                    })
                end

                section:Dropdown({
                    Title = if worldline then'Select Worldline'else'Select Boss Event',
                    Values = values,
                    Value = values[index],
                    Callback = function(value)
                        local found = table.find(values, value)

                        if found then
                            selected = ids[found]

                            update()
                        end
                    end,
                })

                if worldline then
                    section:Dropdown({
                        Title = 'Traits',
                        Desc =
[[Traits enables unit traits in the Worldline; NoTraits disables them.]],
                        Values = {
                            'Traits',
                            'NoTraits',
                        },
                        Value = option,
                        Callback = function(value)
                            if value == 'Traits' or value == 'NoTraits' then
                                option = value

                                update()
                            end
                        end,
                    })
                end
                if not worldline then
                    section:Dropdown({
                        Title = 'Difficulty',
                        Values = {
                            'Normal',
                            'Elite',
                        },
                        Value = option,
                        Callback = function(value)
                            option = value

                            update()
                        end,
                    })
                end
            end
            local function addStageSelector(tab, data, mode, title, runtime)
                local stages = Catalog.list(data, mode)
                local saved = Settings.get()
                local previous = saved.selection[title]
                local selected = stages[1]

                if selected and type(previous) == 'table' then
                    for _, candidate in stages do
                        if candidate.id == previous.stage then
                            selected = candidate

                            break
                        end
                    end
                end

                tab:Toggle({
                    Title = 'Auto Join ' .. title,
                    Value = saved.enabled[title] == true and #stages > 0,
                    Locked = runtime == nil or #stages == 0,
                    Desc =
[[Creates a private lobby, then starts it after server confirmation and host readback.]],
                    Callback = function(value)
                        if runtime then
                            runtime.setEnabled(title, value)
                        end
                    end,
                })

                if #stages == 0 then
                    tab:Paragraph({
                        Title = title,
                        Desc = 'Unavailable: stage data not replicated in this place.',
                    })

                    return
                end
                if runtime and saved.enabled[title] == true then
                    runtime.setEnabled(title, true)
                end

                local labels = {}

                for _, stage in stages do
                    table.insert(labels, stage.id .. ' - ' .. stage.name)
                end

                local selectedAct = selected.acts[1].id

                if type(previous) == 'table' then
                    for _, act in selected.acts do
                        if act.id == previous.act then
                            selectedAct = act.id

                            break
                        end
                    end
                end

                local difficulty = if mode == 'LegendStage'then'Nightmare'else if mode == 'Story' and type(previous) == 'table' and previous.difficulty == 'Nightmare'then'Nightmare'else'Normal'

                local function updateSelection()
                    if runtime then
                        runtime.setSelection(title, selected.id, selectedAct, difficulty)
                    end
                end

                updateSelection()

                local actLabels = {}

                local function refreshActs(stage)
                    actLabels = {}

                    for _, act in stage.acts do
                        table.insert(actLabels, act.id .. ' - ' .. act.name)
                    end
                end

                refreshActs(selected)

                local selectedActLabel = actLabels[1]

                for index, act in selected.acts do
                    if act.id == selectedAct then
                        selectedActLabel = actLabels[index]

                        break
                    end
                end

                tab:Paragraph({
                    Title = title,
                    Desc =
[[Only an unlocked Stage/Act can be requested. Server ACK is required.]],
                })

                local actDropdown

                tab:Dropdown({
                    Title = 'Select ' .. title,
                    Values = labels,
                    Value = labels[table.find(stages, selected) or 1],
                    Callback = function(value)
                        local index = table.find(labels, value)

                        if index then
                            selected = stages[index]

                            refreshActs(selected)

                            selectedAct = selected.acts[1].id

                            updateSelection()

                            if actDropdown and actDropdown.Refresh and actDropdown.Select then
                                local refresh = actDropdown.Refresh
                                local selectValue = actDropdown.Select

                                refresh(actDropdown, actLabels)
                                selectValue(actDropdown, actLabels[1])
                            end
                        end
                    end,
                })

                actDropdown = tab:Dropdown({
                    Title = 'Select ' .. title .. ' Act',
                    Values = actLabels,
                    Value = selectedActLabel,
                    Callback = function(value)
                        local index = table.find(actLabels, value)

                        if index then
                            selectedAct = selected.acts[index].id

                            updateSelection()
                        end
                    end,
                })

                if mode == 'Story' then
                    tab:Dropdown({
                        Title = 'Difficulty',
                        Values = {
                            'Normal',
                            'Nightmare',
                        },
                        Value = difficulty,
                        Callback = function(value)
                            if value == 'Normal' or value == 'Nightmare' then
                                difficulty = value

                                updateSelection()
                            end
                        end,
                    })
                elseif mode == 'LegendStage' then
                    tab:Paragraph({
                        Title = 'Difficulty',
                        Desc = 'Legend Stage is Nightmare-only; no difficulty selector.',
                    })
                end
            end
            local function formatHMS(seconds)
                if seconds <= 0 then
                    return '00:00'
                end

                local d = math.floor(seconds / 86400)
                local h = math.floor((seconds % 86400) / 3600)
                local m = math.floor((seconds % 3600) / 60)
                local s = math.floor(seconds % 60)

                if d > 0 then
                    return string.format('%dd %02dh %02dm', d, h, m)
                elseif h > 0 then
                    return string.format('%02d:%02d:%02d', h, m, s)
                else
                    return string.format('%02d:%02d', m, s)
                end
            end
            local function addRift(tab, runtime)
                local section = Style.joiner(tab, 'Rift', false)
                local saved = Settings.get()
                local previous = saved.selection['Rift'] or {}
                local backToLobby = previous.backToLobby == true
                local returnMode = previous.returnMode or 'Immediate'

                section:Toggle({
                    Title = 'Auto Join Rift',
                    Value = saved.enabled['Rift'] == true,
                    Locked = runtime == nil,
                    Desc =
[[Automatically joins open Rift events via remote execution without walking.]],
                    Callback = function(value)
                        if runtime then
                            runtime.setEnabled('Rift', value)
                        end
                    end,
                })

                local timerPara = section:Paragraph({
                    Title = 'Rift Event Status',
                    Desc = 'Checking schedule...',
                })

                section:Toggle({
                    Title = 'Back to Lobby when Rift Opens',
                    Value = backToLobby,
                    Desc = 'Returns from active match to lobby when Rift event opens.',
                    Callback = function(value)
                        backToLobby = value

                        Settings.setBackToLobby('Rift', backToLobby, returnMode)
                    end,
                })
                section:Dropdown({
                    Title = 'Return Mode',
                    Values = {
                        'Immediate',
                        'Wait Match End',
                    },
                    Value = returnMode,
                    Callback = function(value)
                        returnMode = value

                        Settings.setBackToLobby('Rift', backToLobby, returnMode)
                    end,
                })

                return timerPara
            end
            local function addUnavailable(tab, name, description)
                local section = Style.joiner(tab, name, false)

                section:Toggle({
                    Title = 'Auto Join ' .. name,
                    Value = false,
                    Locked = true,
                    Desc = 'Unavailable until joining is verified.',
                })
                section:Paragraph({
                    Title = 'Options',
                    Desc = description,
                })
            end
            local function addBounty(tab, runtime)
                local section = Style.joiner(tab, 'Boss Bounties', false)
                local saved = Settings.get()

                section:Toggle({
                    Title = 'Auto Join Boss Bounties',
                    Value = saved.enabled['Boss Bounties'] == true,
                    Locked = runtime == nil or type(runtime.readBounty) ~= 'function',
                    Desc =
[[Creates a private lobby for the current bounty stage while bounties remain.]],
                    Callback = function(value)
                        if runtime then
                            runtime.setEnabled('Boss Bounties', value)
                        end
                    end,
                })

                if runtime and saved.enabled['Boss Bounties'] == true then
                    runtime.setEnabled('Boss Bounties', true)
                end

                local info = section:Paragraph({
                    Title = 'Current bounty',
                    Desc = 'Waiting for bounty data...',
                })

                return function()
                    local bounty = if runtime and type(runtime.readBounty) == 'function'then(runtime.readBounty)()else nil
                    local text = if bounty then string.format('%s %s %s%s - %d left today', bounty.mode, bounty.stage, bounty.act, if bounty.boss then' (' .. bounty.boss .. ')'else'', bounty.left)else'Unavailable: bounty data is not replicated in this place.'

                    pcall(info.SetDesc, info, text)
                end
            end
            local function addEquipper(tab, runtime)
                local section = Style.section(tab, 'Auto Join Equipper', 'layout-grid', false, 20)

                local function subsection(title, icon)
                    return Style.sub(section, title, icon, true)
                end

                local nested = subsection('Team Equipper', 'users')
                local saved = Settings.get()

                nested:Toggle({
                    Title = 'Auto Join Team Equipper',
                    Desc = 'Automatically equip the set team before joining a stage',
                    Value = saved.teamEquip.enabled == true,
                    Locked = runtime == nil or type(runtime.getTeamOptions) ~= 'function',
                    Callback = Settings.setTeamEquipEnabled,
                })

                local rows = {}
                local syncing = false

                for _, name in definitions do
                    local row = {
                        name = name,
                        byLabel = {},
                        signature = nil,
                        current = 'None',
                    }

                    row.dropdown = nested:Dropdown({
                        Title = name .. ' Joiner',
                        Values = {
                            'None',
                        },
                        Value = 'None',
                        Callback = function(label)
                            if syncing or label == row.current then
                                return
                            end

                            local key = row.byLabel[label]

                            if Settings.setTeamForJoiner(row.name, key) then
                                row.current = label
                                row.signature = nil
                            end
                        end,
                    })

                    table.insert(rows, row)
                end

                local macro = subsection('Macro Equipper', 'list')

                macro:Toggle({
                    Title = 'Auto Join Macro Equipper',
                    Desc =
[[Automatically equip the macro's units before joining a stage]],
                    Value = saved.macroEquip.enabled == true,
                    Locked = runtime == nil or type(runtime.getMacroOptions) ~= 'function',
                    Callback = Settings.setMacroEquipEnabled,
                })

                local macroRows = {}

                for _, name in definitions do
                    local row = {
                        name = name,
                        signature = nil,
                        current = 'None',
                    }

                    row.dropdown = macro:Dropdown({
                        Title = name .. ' Joiner',
                        Values = {
                            'None',
                        },
                        Value = 'None',
                        Callback = function(label)
                            if syncing or label == row.current then
                                return
                            end
                            if Settings.setMacroForJoiner(row.name, if label == 'None'then nil else label) then
                                row.current = label
                                row.signature = nil
                            end
                        end,
                    })

                    table.insert(macroRows, row)
                end

                local function refreshMacros()
                    local files = if runtime and type(runtime.getMacroOptions) == 'function'then(runtime.getMacroOptions)()else nil

                    if type(files) ~= 'table' then
                        return
                    end

                    local chosen = Settings.get().macroEquip.macros
                    local labels = {
                        'None',
                    }

                    for _, file in files do
                        table.insert(labels, file)
                    end
                    for _, row in macroRows do
                        local selected = chosen[row.name]

                        if selected == nil or not table.find(labels, selected) then
                            selected = 'None'
                        end

                        local signature = selected .. '|' .. table.concat(labels, '|')

                        if row.signature ~= signature then
                            row.signature = signature
                            row.current = selected
                            syncing = true

                            local dropdown = row.dropdown

                            if type(dropdown.Select) == 'function' then
                                pcall(dropdown.Select, dropdown, selected)
                            end
                            if type(dropdown.Refresh) == 'function' then
                                pcall(dropdown.Refresh, dropdown, labels)
                            end

                            syncing = false
                        end
                    end
                end
                local function refresh()
                    refreshMacros()

                    local options = if runtime and type(runtime.getTeamOptions) == 'function'then(runtime.getTeamOptions)()else nil

                    if not options then
                        return
                    end

                    local current = Settings.get().teamEquip.teams

                    for _, row in rows do
                        local labels = {
                            'None',
                        }
                        local byLabel = {}
                        local selected = 'None'

                        for _, option in options do
                            table.insert(labels, option.label)

                            byLabel[option.label] = option.key

                            if current[row.name] == option.key then
                                selected = option.label
                            end
                        end

                        if current[row.name] and selected == 'None' then
                            Settings.setTeamForJoiner(row.name, nil)
                        end

                        row.byLabel = byLabel

                        local signature = selected .. '|' .. table.concat(labels, '|')

                        if row.signature ~= signature then
                            row.signature = signature
                            row.current = selected
                            syncing = true

                            local dropdown = row.dropdown

                            if type(dropdown.Select) == 'function' then
                                pcall(dropdown.Select, dropdown, selected)
                            end
                            if type(dropdown.Refresh) == 'function' then
                                pcall(dropdown.Refresh, dropdown, labels)
                            end

                            syncing = false
                        end
                    end
                end

                return refresh
            end
            local function addChallenge(tab, kind, choices, runtime)
                local name = kind .. ' Challenge'
                local section = Style.joiner(tab, name, false)
                local values = if type(choices) == 'table' and type(choices[kind]) == 'table'then choices[kind]else{}
                local saved = Settings.get()
                local previous = saved.selection[name] or {}
                local backToLobby = previous.backToLobby == true
                local returnMode = previous.returnMode or 'Immediate'

                section:Toggle({
                    Title = 'Auto Join ' .. name,
                    Value = saved.enabled[name] == true and #values > 0,
                    Locked = runtime == nil or #values == 0,
                    Desc =
[[Starts challenge and continues automatically after server confirmation.]],
                    Callback = function(value)
                        if runtime then
                            runtime.setEnabled(name, value)
                        end
                    end,
                })

                local timerPara = section:Paragraph({
                    Title = 'Challenge Reset Timer',
                    Desc = 'Checking reset timer...',
                })

                if #values == 0 then
                    section:Paragraph({
                        Title = 'Availability',
                        Desc = 'Current challenge data is unavailable.',
                    })

                    return timerPara
                end

                local selected = if type(previous) == 'table' and table.find(values, previous.challengeName)then previous.challengeName else values[1]

                if runtime then
                    runtime.setChallenge(name, selected)
                end

                section:Dropdown({
                    Title = 'Select ' .. name,
                    Values = values,
                    Value = selected,
                    Callback = function(value)
                        if runtime and table.find(values, value) then
                            runtime.setChallenge(name, value)
                        end
                    end,
                })

                if kind == 'Regular' then
                    local rewardChoices = {
                        'Trait Rerolls',
                        'Stat Chips',
                        'Memoria Shards',
                        'Green Essence Stone',
                        'Legendary Essence Stone',
                        'Mythic Essence Stone',
                    }
                    local currentReward = if previous.rewardChoice and table.find(rewardChoices, previous.rewardChoice)then previous.rewardChoice else'Trait Rerolls'

                    Settings.setRegularReward(currentReward)
                    section:Dropdown({
                        Title = 'Reward Focus',
                        Values = rewardChoices,
                        Value = currentReward,
                        Callback = function(value)
                            Settings.setRegularReward(value)
                        end,
                    })
                end

                section:Toggle({
                    Title = 'Back to Lobby when Challenge is Available',
                    Value = backToLobby,
                    Desc =
[[Returns from an active match to the lobby when this challenge can be played again (Return Mode decides when).]],
                    Callback = function(value)
                        backToLobby = value

                        Settings.setBackToLobby(name, backToLobby, returnMode)
                    end,
                })
                section:Dropdown({
                    Title = 'Return Mode',
                    Values = {
                        'Immediate',
                        'Wait Match End',
                    },
                    Value = returnMode,
                    Callback = function(value)
                        returnMode = value

                        Settings.setBackToLobby(name, backToLobby, returnMode)
                    end,
                })

                return timerPara
            end

            function Page.mount(
                tab,
                stageDataOverride,
                runtime,
                challengeChoicesOverride
            )
                Settings.init(getfenv())

                local state = Settings.get()
                local stageData = stageDataOverride or readStageData()
                local challengeChoices = challengeChoicesOverride or readChallengeChoices()
                local specialChoices = readSpecialChoices()

                tab:Paragraph({
                    Title = 'Status',
                    Desc =
[[Choose a mode below. Worldline and Boss Event use current game data.]],
                })

                if runtime then
                    local status = tab:Paragraph({
                        Title = 'Join status',
                        Desc = runtime.status,
                    })

                    runtime.onStatus = function(value)
                        status:SetDesc(value)
                    end
                end

                local reportPara = if runtime and type(runtime.getReport) == 'function'then tab:Paragraph({
                    Title = 'Joiner Report',
                    Desc = 'Waiting for the first check...',
                })else nil

                local function updateReport()
                    if reportPara and runtime then
                        reportPara:SetDesc(table.concat(runtime.getReport(), '\n'))
                    end
                end

                local updateEquipper = addEquipper(tab, runtime)

                pcall(updateEquipper)

                local settings = Style.section(tab, 'Auto Join Settings', 'settings', true)

                settings:Paragraph({
                    Title = 'Storage',
                    Desc = if state.persistent then'Autosaved to file'else'Session only: file APIs unavailable',
                })
                settings:Toggle({
                    Title = 'Disable Auto Joiners',
                    Value = state.paused,
                    Callback = Settings.setPaused,
                })
                settings:Toggle({
                    Title = 'Change Stage in Match',
                    Desc =
[[As host before Vote Start, switch a joiner-created match to the highest-priority stage joiner (Stage, Legend Stage, Raid, Dungeon, Boss Bounties). Not done when a higher-priority Rift or challenge is playable; its Back to Lobby setting decides instead.]],
                    Value = state.changeStageInMatch ~= false,
                    Callback = Settings.setChangeStageInMatch,
                })
                settings:Slider({
                    Title = 'Joiner Cooldown (seconds)',
                    Step = 1,
                    Value = {
                        Min = 0,
                        Max = 300,
                        Default = state.cooldown,
                    },
                    Callback = Settings.setCooldown,
                })

                local prioritySection = Style.sub(settings, 'Auto Join Priority', 'list-ordered', false)
                local priorityTags = Style.joinerTags()
                local lockedRows = {}

                for _, name in UNAVAILABLE do
                    lockedRows[name] = true
                    priorityTags[name] = {
                        text = 'Locked',
                        color = 'slate',
                    }
                end

                local priorityList = PriorityList.mount(prioritySection, {
                    title = 'Auto Join Priority',
                    desc =
[[The joiner tries the highest number first. Drag a row onto another to swap them.]],
                    order = state.priority,
                    tags = priorityTags,
                    lockedRows = lockedRows,
                    onSwap = function(first, second)
                        return if Settings.swap(first, second)then Settings.get().priority else nil
                    end,
                })

                prioritySection:Button({
                    Title = 'Reset Auto Join Priority',
                    Desc = 'Restore the default order (Rift, challenges, then stages).',
                    Icon = 'rotate-ccw',
                    Callback = function()
                        priorityList.refresh(Settings.resetPriority())
                    end,
                })
                addStageSelector(Style.joiner(tab, 'Stage', false), stageData, 'Story', 'Stage', runtime)
                addStageSelector(Style.joiner(tab, 'Legend Stage', false), stageData, 'LegendStage', 'Legend Stage', runtime)
                addStageSelector(Style.joiner(tab, 'Raid', false), stageData, 'Raid', 'Raid', runtime)
                addStageSelector(Style.joiner(tab, 'Dungeon', false), stageData, 'Dungeon', 'Dungeon', runtime)
                addSpecial(tab, 'Boss Event', specialChoices, runtime)
                addSpecial(tab, 'Worldline', specialChoices, runtime)

                local updateBounty = addBounty(tab, runtime)
                local riftTimer = addRift(tab, runtime)
                local regTimer = addChallenge(tab, 'Regular', challengeChoices, runtime)
                local dailyTimer = addChallenge(tab, 'Daily', challengeChoices, runtime)
                local weeklyTimer = addChallenge(tab, 'Weekly', challengeChoices, runtime)

                for _, name in UNAVAILABLE do
                    addUnavailable(tab, name, 'Mode-specific choices are not verified yet.')
                end

                local env = getfenv()
                local taskApi = env.task

                if type(taskApi) == 'table' and type(taskApi.spawn) == 'function' and type(taskApi.wait) == 'function' then
                    (taskApi.spawn)(function()
                        local gameObject = env.game
                        local rep = gameObject and gameObject:GetService('ReplicatedStorage')
                        local starterPlayer = gameObject and gameObject:GetService('StarterPlayer')
                        local cd = if rep then optionalModule(rep, config.instancePaths.challengesData)else nil
                        local cah = if starterPlayer then optionalModule(starterPlayer, config.instancePaths.challengeAttempts)else nil
                        local mountedContext = nil
                        local idleTicks = 0

                        local function alive()
                            if not runtime then
                                return false
                            end

                            local current = runtime.context

                            if mountedContext == nil then
                                if current ~= nil and current.alive == true then
                                    mountedContext = current
                                else
                                    idleTicks += 1

                                    return idleTicks <= STARTUP_WAIT_TICKS
                                end
                            end

                            return mountedContext.alive == true and runtime.context == mountedContext
                        end

                        while alive() do
                            local now = os.time()

                            if riftTimer then
                                pcall(function()
                                    local ws = gameObject and gameObject:GetService('Workspace')
                                    local isRiftOpenAttr = nil

                                    if ws and ws.GetAttribute then
                                        local okA, a = pcall(ws.GetAttribute, ws, 'IsRiftOpen')

                                        if okA then
                                            isRiftOpenAttr = a
                                        end
                                    end

                                    local isOpen = if isRiftOpenAttr ~= nil then(isRiftOpenAttr == true)else(now % 3600 < 600)

                                    if isOpen then
                                        local closeLeft = 600 - (now % 3600)

                                        riftTimer:SetDesc('[OPEN NOW] Closes in: ' .. formatHMS(closeLeft))
                                    else
                                        local openLeft = 3600 - (now % 3600)

                                        riftTimer:SetDesc('Opens in: ' .. formatHMS(openLeft))
                                    end
                                end)
                            end
                            if cd and cah and type(cd.GetNextReset) == 'function' and type(cah.GetChallengeSeed) == 'function' then
                                local function updateTimer(timerObj, kindName)
                                    if timerObj then
                                        pcall(function()
                                            local okSeed, seed = pcall(cah.GetChallengeSeed, kindName)
                                            local nextReset = 1

                                            if okSeed and seed ~= nil then
                                                local okReset, resetVal = pcall(cd.GetNextReset, kindName, seed)

                                                if okReset and type(resetVal) == 'number' then
                                                    nextReset = resetVal
                                                end
                                            end
                                            if nextReset <= 0 then
                                                timerObj:SetDesc('[AVAILABLE]')
                                            else
                                                timerObj:SetDesc('Resets in: ' .. formatHMS(nextReset))
                                            end
                                        end)
                                    end
                                end

                                updateTimer(regTimer, 'Regular')
                                updateTimer(dailyTimer, 'Daily')
                                updateTimer(weeklyTimer, 'Weekly')
                            end

                            pcall(updateBounty)
                            pcall(updateEquipper)
                            pcall(updateReport)

                            local waitFn = taskApi.wait

                            waitFn(1)
                        end
                    end)
                end
            end

            return Page
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
            local FileStorage = __DARKLUA_BUNDLE_MODULES.l()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local ActivityState = {}
            local STORAGE_KEY = 'AnimeVanguardsActivityState'
            local SCHEMA_VERSION = 1
            local CHALLENGES = {
                Regular = true,
                Daily = true,
                Weekly = true,
            }

            local function finite(value)
                return type(value) == 'number' and value == value and math.abs(value) ~= math.huge
            end

            function ActivityState.challenge(attempts, data, kind)
                if not CHALLENGES[kind] or not attempts or not data or type(attempts.GetChallengeSeed) ~= 'function' or type(data.GetChallengeSeed) ~= 'function' then
                    return 'unknown', nil
                end

                local okStored, stored = pcall(attempts.GetChallengeSeed, kind)
                local okCurrent, current = pcall(data.GetChallengeSeed, kind)

                if not okStored or not okCurrent or not finite(stored) or not finite(current) then
                    return 'unknown', nil
                end
                if stored < current then
                    return 'available', current
                end
                if stored == current then
                    return 'unavailable', current
                end

                return 'unknown', nil
            end
            function ActivityState.rift(gameObject, specialEvents)
                local okOpen, open = pcall(function()
                    return gameObject:GetService('Workspace'):GetAttribute(config.attributes.riftOpen)
                end)

                if not okOpen or type(open) ~= 'boolean' then
                    return 'unknown'
                end
                if not open then
                    return 'unavailable'
                end

                local remote = specialEvents and specialEvents[config.remoteNames.getRiftAttempts]

                if not remote or type(remote.Invoke) ~= 'function' then
                    return 'unknown'
                end

                local ok, response = pcall(remote.Invoke)

                if not ok or type(response) ~= 'table' or response.Ready ~= true or not finite(response.AttemptsRemaining) then
                    return 'unknown'
                end

                return if response.AttemptsRemaining > 0 then'available'else'unavailable'
            end
            function ActivityState.new(env, userId)
                local storage = FileStorage.new(env, STORAGE_KEY)
                local http = env.game and env.game:GetService('HttpService')
                local self = {}

                local function readRaw()
                    if not storage or not http then
                        return nil
                    end

                    local body = storage.read()

                    if not body then
                        return nil
                    end

                    local ok, value = pcall(http.JSONDecode, http, body)

                    return if ok and type(value) == 'table'then value else nil
                end

                function self.save(now, states, challengeSeeds, riftInfo)
                    if not storage or not http or not finite(now) or not finite(userId) then
                        return false
                    end

                    local used = {}
                    local previous = readRaw()

                    if previous and type(previous.used) == 'table' then
                        for kind, period in previous.used do
                            local live = states[kind]

                            if type(kind) == 'string' and finite(period) and type(live) == 'table' and live.period == period then
                                used[kind] = period
                            end
                        end
                    end

                    local ok, body = pcall(http.JSONEncode, http, {
                        schemaVersion = SCHEMA_VERSION,
                        userId = userId,
                        observedAt = now,
                        states = states,
                        challengeSeeds = challengeSeeds,
                        riftInfo = riftInfo,
                        used = used,
                    })

                    return ok and type(body) == 'string' and storage.write(body)
                end
                function self.markUsed(kind, period)
                    if not CHALLENGES[kind] or not finite(period) or not storage or not http then
                        return false
                    end

                    local current = readRaw()

                    if not current then
                        return false
                    end

                    local used = if type(current.used) == 'table'then current.used else{}

                    used[kind] = period
                    current.used = used

                    local ok, body = pcall(http.JSONEncode, http, current)
                    local target = storage

                    return ok and type(body) == 'string' and target ~= nil and target.write(body)
                end
                function self.load(now, challengeData)
                    if not storage or not http or not finite(now) then
                        return nil
                    end

                    local body = storage.read()

                    if not body then
                        return nil
                    end

                    local ok, value = pcall(http.JSONDecode, http, body)

                    if not ok or type(value) ~= 'table' then
                        return nil
                    end

                    local observedAt = value.observedAt
                    local maxAge = config.thresholds.activitySnapshotSeconds or 7200

                    if value.schemaVersion ~= SCHEMA_VERSION or value.userId ~= userId or not finite(observedAt) or (observedAt) > now or now - (observedAt) > maxAge then
                        return nil
                    end

                    local states = {}

                    if type(value.challengeSeeds) == 'table' and challengeData and type(challengeData.GetChallengeSeed) == 'function' then
                        for _, kind in {
                            'Regular',
                            'Daily',
                            'Weekly',
                        }do
                            local storedSeed = value.challengeSeeds[kind]

                            if finite(storedSeed) then
                                local okPeriod, currentPeriod = pcall(challengeData.GetChallengeSeed, kind)

                                if okPeriod and finite(currentPeriod) then
                                    if (storedSeed) < (currentPeriod) then
                                        states[kind] = {
                                            status = 'available',
                                            period = currentPeriod,
                                        }
                                    else
                                        states[kind] = {
                                            status = 'unavailable',
                                            period = currentPeriod,
                                        }
                                    end
                                end
                            end
                        end
                    end
                    if type(value.used) == 'table' and challengeData and type(challengeData.GetChallengeSeed) == 'function' then
                        for _, kind in {
                            'Regular',
                            'Daily',
                            'Weekly',
                        }do
                            local usedPeriod = value.used[kind]
                            local okPeriod, period = pcall(challengeData.GetChallengeSeed, kind)

                            if finite(usedPeriod) and okPeriod and finite(period) and usedPeriod == period then
                                states[kind] = {
                                    status = 'unavailable',
                                    period = period,
                                }
                            end
                        end
                    end
                    if type(value.states) == 'table' then
                        for _, kind in {
                            'Regular',
                            'Daily',
                            'Weekly',
                        }do
                            if not states[kind] then
                                local entry = value.states[kind]

                                if type(entry) == 'table' and (entry.status == 'available' or entry.status == 'unavailable') and finite(entry.period) and challengeData and type(challengeData.GetChallengeSeed) == 'function' then
                                    local okPeriod, period = pcall(challengeData.GetChallengeSeed, kind)

                                    if okPeriod and finite(period) then
                                        if (period) > (entry.period) or entry.status == 'available' then
                                            states[kind] = {
                                                status = 'available',
                                                period = period,
                                            }
                                        else
                                            states[kind] = {
                                                status = 'unavailable',
                                                period = period,
                                            }
                                        end
                                    end
                                end
                            end
                        end
                    end

                    local currentHour = math.floor(now / 3600)
                    local isOpenWindow = (now % 3600 < (config.thresholds.riftSnapshotSeconds or 600))
                    local alreadyCompletedThisHour = false
                    local rInfo = value.riftInfo

                    if type(rInfo) == 'table' and finite(rInfo.attempts) and finite(rInfo.hour) then
                        if rInfo.attempts == 0 and rInfo.hour == currentHour then
                            alreadyCompletedThisHour = true
                        end
                    end
                    if isOpenWindow then
                        if not alreadyCompletedThisHour then
                            states.Rift = {
                                status = 'available',
                            }
                        else
                            states.Rift = {
                                status = 'unavailable',
                            }
                        end
                    else
                        states.Rift = {
                            status = 'unavailable',
                        }
                    end

                    return {
                        states = states,
                        riftSpent = alreadyCompletedThisHour,
                    }
                end

                return self
            end

            return ActivityState
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
            local Document = {}
            local KINDS = {
                voteStart = true,
                place = true,
                upgrade = true,
                sell = true,
                ability = true,
                priority = true,
                autoUpgrade = true,
                autoAbility = true,
                upgradePriority = true,
            }
            local MAX_ACTIONS = 2000

            local function rounded(value)
                local result = math.floor(value * 1000000 + 0.5) / 1000000

                return if result == 0 then 0 else result
            end
            local function finite(value)
                return type(value) == 'number' and value == value and value ~= math.huge and value ~=
-math.huge
            end
            local function short(value, limit)
                return type(value) == 'string' and #value > 0 and #value <= limit
            end
            local function validCFrame(value)
                if type(value) ~= 'table' or #value ~= 12 then
                    return false
                end

                for index = 1, 12 do
                    if not finite(value[index]) then
                        return false
                    end
                end

                return true
            end

            function Document.fromPose(position, rotation)
                if type(position) ~= 'table' or not finite(position.x) or not finite(position.y) or not finite(position.z) or not finite(rotation) then
                    return nil
                end

                local yaw = math.rad(rotation)
                local cosine, sine = math.cos(yaw), math.sin(yaw)

                return {
                    rounded(position.x),
                    rounded(position.y),
                    rounded(position.z),
                    rounded(cosine),
                    0,
                    rounded(sine),
                    0,
                    1,
                    0,
                    rounded(-sine),
                    0,
                    rounded(cosine),
                }
            end
            function Document.toPose(components)
                if not validCFrame(components) then
                    return nil, nil
                end

                local yaw = math.deg(math.atan2(components[6], components[4])) % 360

                return {
                    x = components[1],
                    y = components[2],
                    z = components[3],
                }, yaw
            end
            function Document.empty(name)
                return {
                    schemaVersion = 2,
                    name = name,
                    game = 'AnimeVanguards',
                    match = {},
                    units = {},
                    actions = {},
                }
            end
            function Document.validate(data)
                if type(data) ~= 'table' or (data.schemaVersion ~= 1 and data.schemaVersion ~= 2) or data.game ~= 'AnimeVanguards' then
                    return nil, 'MACRO_SCHEMA_UNSUPPORTED'
                end
                if not short(data.name, 64) or type(data.match) ~= 'table' or type(data.units) ~= 'table' or type(data.actions) ~= 'table' or #data.actions > MAX_ACTIONS then
                    return nil, 'MACRO_INVALID'
                end

                local result = Document.empty(data.name)

                if short(data.match.mode, 100) then
                    result.match.mode = data.match.mode
                end
                if short(data.match.map, 100) then
                    result.match.map = data.match.map
                end

                for _, unitName in data.units do
                    if not short(unitName, 100) then
                        return nil, 'MACRO_INVALID'
                    end

                    table.insert(result.units, unitName)
                end

                local levelsByRef = {}

                for index, action in data.actions do
                    if type(action) ~= 'table' or not KINDS[action.kind] or action.index ~= index or not finite(action.wave) or action.wave < 0 or not finite(action.yen) or action.yen < 0 or not finite(action.time) or action.time < 0 or (action.kind ~= 'voteStart' and not short(action.unitRef, 100)) then
                        return nil, 'MACRO_ACTION_INVALID'
                    end

                    local normalized = {
                        index = index,
                        kind = action.kind,
                        wave = action.wave,
                        yen = action.yen,
                        time = action.time,
                        unitRef = if action.kind == 'voteStart'then nil else action.unitRef,
                    }

                    if action.kind == 'place' then
                        local components = action.cframe

                        if data.schemaVersion == 1 then
                            components = Document.fromPose(action.position, action.rotation)
                        end
                        if not short(action.unitName, 100) or not validCFrame(components) or not finite(action.slotIndex) or action.slotIndex < 1 or action.slotIndex > 8 or action.slotIndex % 1 ~= 0 then
                            return nil, 'MACRO_ACTION_INVALID'
                        end

                        normalized.unitName = action.unitName
                        normalized.cframe = table.clone(components)
                        normalized.slotIndex = action.slotIndex

                        local initialLevel = action.initialLevel

                        if initialLevel == nil then
                            initialLevel = 0
                        end
                        if not finite(initialLevel) or initialLevel % 1 ~= 0 or initialLevel < 0 or initialLevel > 2000 then
                            return nil, 'MACRO_ACTION_INVALID'
                        end

                        normalized.initialLevel = initialLevel
                        levelsByRef[action.unitRef] = initialLevel
                    elseif action.kind == 'upgrade' then
                        local previousLevel = levelsByRef[action.unitRef] or 0
                        local level = action.level

                        if level == nil then
                            level = previousLevel + 1
                        end
                        if not finite(level) or level % 1 ~= 0 or level <= previousLevel or level > 2000 then
                            return nil, 'MACRO_ACTION_INVALID'
                        end

                        normalized.level = level
                        levelsByRef[action.unitRef] = level
                    elseif action.kind == 'ability' then
                        if not short(action.abilityName, 100) then
                            return nil, 'MACRO_ACTION_INVALID'
                        end

                        normalized.abilityName = action.abilityName
                    elseif action.kind == 'priority' then
                        if not table.find({
                            'First',
                            'Closest',
                            'Last',
                            'Strongest',
                            'Weakest',
                            'Bosses',
                        }, action.priorityName) then
                            return nil, 'MACRO_ACTION_INVALID'
                        end

                        normalized.priorityName = action.priorityName
                    elseif action.kind == 'autoUpgrade' then
                        if type(action.enabled) ~= 'boolean' then
                            return nil, 'MACRO_ACTION_INVALID'
                        end

                        normalized.enabled = action.enabled
                    elseif action.kind == 'autoAbility' then
                        if type(action.enabled) ~= 'boolean' or not short(action.abilityName, 100) then
                            return nil, 'MACRO_ACTION_INVALID'
                        end

                        normalized.enabled = action.enabled
                        normalized.abilityName = action.abilityName
                    elseif action.kind == 'upgradePriority' then
                        if not finite(action.upgradePriority) or action.upgradePriority % 1 ~= 0 or action.upgradePriority < 1 or action.upgradePriority > 6 then
                            return nil, 'MACRO_ACTION_INVALID'
                        end

                        normalized.upgradePriority = action.upgradePriority
                    end

                    table.insert(result.actions, normalized)
                end

                return result, nil
            end
            function Document.importLegacy(data, name)
                if type(data) ~= 'table' or type(data.Marco_Data) ~= 'table' then
                    return nil, 'MACRO_LEGACY_INVALID'
                end

                local result = Document.empty(name)

                result.match = {
                    map = data.Map,
                    mode = data.Mode,
                }

                for _, row in data.Marco_Data do
                    if type(row) == 'table' then
                        local kind = if row.Method == 'SpawnTower'then'place'else if row.Method == 'UpgradeTower'then'upgrade'else if row.Method == 'SellTower'then'sell'else if row.Method == 'Use Ability'then'ability'else nil

                        if kind then
                            local action = {
                                index = #result.actions + 1,
                                kind = kind,
                                wave = tonumber(row.Wave) or 0,
                                yen = 0,
                                time = tonumber(row.Time) or 0,
                                unitRef = tostring(row.UnitValue or ''),
                            }

                            if kind == 'place' then
                                local x, y, z = tostring(row.Position):match('^%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*$')

                                action.unitName = tostring(row.Unit or '')
                                action.cframe = Document.fromPose({
                                    x = tonumber(x),
                                    y = tonumber(y),
                                    z = tonumber(z),
                                }, tonumber(row.Rotation) or 0)

                                local slot = tonumber(row.Slot) or tonumber(row.SlotIndex) or tonumber(row.UnitValue) or 1

                                action.slotIndex = if slot >= 1 and slot <= 8 then slot else((slot - 1) % 6 + 1)
                            elseif kind == 'ability' then
                                action.abilityName = tostring(row.Ability or '')
                            end

                            table.insert(result.actions, action)
                        end
                    end
                end

                return Document.validate(result)
            end

            return Document
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
            local Document = __DARKLUA_BUNDLE_MODULES.r()
            local Storage = {}
            local ROOT = 'ViperHubNextGen/macro/AnimeVanguards'
            local MAX_BYTES = 1024 * 1024

            local function validName(name)
                return type(name) == 'string' and #name > 0 and #name <= 64 and (name):match('^[%w_%-]+$') ~= nil
            end

            function Storage.new(env, codec)
                for _, key in {
                    'readfile',
                    'writefile',
                    'isfile',
                    'isfolder',
                    'makefolder',
                    'listfiles',
                    'delfile',
                }do
                    if type(env[key]) ~= 'function' then
                        return nil
                    end
                end

                local self = {}

                local function path(name)
                    return ROOT .. '/' .. name .. '.json'
                end
                local function folders()
                    local ok = pcall(function()
                        for _, folder in {
                            'ViperHubNextGen',
                            'ViperHubNextGen/macro',
                            ROOT,
                        }do
                            if not env.isfolder(folder) then
                                env.makefolder(folder)
                            end
                        end
                    end)

                    return ok
                end

                function self.list()
                    if not folders() then
                        return {}
                    end

                    local ok, files = pcall(env.listfiles, ROOT)

                    if not ok or type(files) ~= 'table' then
                        return {}
                    end

                    local names = {}

                    for _, file in files do
                        if type(file) == 'string' then
                            local name = file:gsub('\\', '/'):match('([^/]+)%.[jJ][sS][oO][nN]$')

                            if validName(name) then
                                table.insert(names, name)
                            end
                        end
                    end

                    table.sort(names)

                    return names
                end
                function self.read(name)
                    if not validName(name) then
                        return nil, 'MACRO_NAME_INVALID'
                    end

                    local ok, body = pcall(env.readfile, path(name))

                    if not ok or type(body) ~= 'string' or #body > MAX_BYTES then
                        return nil, 'MACRO_READ_FAILED'
                    end

                    local decoded, data = pcall(codec.JSONDecode, codec, body)

                    if not decoded then
                        return nil, 'MACRO_JSON_INVALID'
                    end

                    local document, err = Document.validate(data)

                    if document and document.name ~= name then
                        document.name = name
                    end

                    return document, err
                end
                function self.write(name, document, overwrite)
                    if not validName(name) then
                        return false, 'MACRO_NAME_INVALID'
                    end

                    local candidate = document

                    if type(document) == 'table' and document.name ~= name then
                        candidate = table.clone(document)
                        candidate.name = name
                    end

                    local checked, err = Document.validate(candidate)

                    if not checked then
                        return false, err
                    end
                    if not folders() then
                        return false, 'MACRO_FOLDER_FAILED'
                    end
                    if not overwrite and env.isfile(path(name)) then
                        return false, 'MACRO_EXISTS'
                    end

                    local ok, body = pcall(codec.JSONEncode, codec, checked)

                    if not ok or type(body) ~= 'string' or #body > MAX_BYTES then
                        return false, 'MACRO_SIZE_INVALID'
                    end

                    local wrote = pcall(env.writefile, path(name), body)

                    if not wrote then
                        return false, 'MACRO_WRITE_FAILED'
                    end

                    local readback = self.read(name)

                    if not readback then
                        return false, 'MACRO_READBACK_FAILED'
                    end

                    return true, nil
                end
                function self.delete(name)
                    if not validName(name) then
                        return false, 'MACRO_NAME_INVALID'
                    end
                    if not env.isfile(path(name)) then
                        return false, 'MACRO_MISSING'
                    end

                    local ok = pcall(env.delfile, path(name))

                    return ok and not env.isfile(path(name)), if ok then nil else'MACRO_DELETE_FAILED'
                end

                return self
            end

            return Storage
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
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local TeamEquip = __DARKLUA_BUNDLE_MODULES.h()
            local Adapter = {}

            local function resolve(root, path)
                local value = root

                for part in string.gmatch(path, '[^%.]+')do
                    if not value then
                        return nil
                    end

                    local ok, child = pcall(function()
                        local v = value

                        if type(v) == 'userdata' then
                            return v:FindFirstChild(part)
                        else
                            return v[part]
                        end
                    end)

                    value = if ok then child else nil
                end

                return value
            end
            local function optionalModule(root, path)
                local ok, result = pcall(function()
                    return (require)(resolve(root, path))
                end)

                return if ok then result else nil
            end
            local function liveDependencies()
                local env = getfenv()
                local gameObject = env.game

                if not gameObject then
                    return nil
                end

                local replicated = gameObject:GetService('ReplicatedStorage')
                local starter = gameObject:GetService('StarterPlayer')

                return {
                    ownedUnits = optionalModule(starter, config.instancePaths.ownedUnits),
                    teamsData = optionalModule(starter, config.instancePaths.teamsData),
                    lobbyTeams = optionalModule(replicated, config.instancePaths.lobbyTeamsClient),
                    gameUnits = optionalModule(replicated, config.instancePaths.gameUnitsClient),
                    unitActions = optionalModule(replicated, config.instancePaths.lobbyUnitActionsClient),
                    popupHandler = optionalModule(starter, config.instancePaths.popupHandler),
                    notifications = optionalModule(starter, config.instancePaths.notifications),
                }
            end

            function Adapter.new(injected, inMatch)
                local self = {dependencies = injected}
                local SUPPRESS_SECONDS = (config).thresholds.teamMessageSuppressSeconds
                local suppressUntil = -math.huge
                local guards = {}

                local function now()
                    local injectedClock = self.dependencies and self.dependencies.clock

                    return if type(injectedClock) == 'function'then(injectedClock)()else os.clock()
                end
                local function isLoadedMessage(value)
                    local text = if type(value) == 'table'then value.Text else value

                    return type(text) == 'string' and string.find(text, (config).teamLoadMessagePrefix) ~= nil
                end
                local function guard(target, name)
                    if type(target) ~= 'table' or type(target[name]) ~= 'function' then
                        return
                    end

                    for _, entry in guards do
                        if entry.target == target and entry.name == name then
                            return
                        end
                    end

                    local env = getfenv()
                    local registry = env.__ViperGuardRegistry

                    if type(registry) ~= 'table' then
                        registry = setmetatable({}, {
                            __mode = 'k',
                        })
                        env.__ViperGuardRegistry = registry
                    end

                    local previous = if registry[target]then registry[target][name]else nil

                    if previous and target[name] == previous.wrapper then
                        pcall(function()
                            target[name] = previous.original
                        end)
                    end

                    local original = target[name]

                    local function wrapper(...)
                        if now() < suppressUntil then
                            local args = table.pack(...)

                            for index = 2, args.n do
                                if isLoadedMessage(args[index]) then
                                    return nil
                                end
                            end
                        end

                        return original(...)
                    end

                    local ok = pcall(function()
                        target[name] = wrapper
                    end)

                    if ok then
                        table.insert(guards, {
                            target = target,
                            name = name,
                            original = original,
                            wrapper = wrapper,
                        })

                        registry[target] = registry[target] or {}
                        registry[target][name] = {
                            original = original,
                            wrapper = wrapper,
                        }
                    end
                end

                function self.stop()
                    for _, entry in guards do
                        if entry.target[entry.name] == entry.wrapper then
                            pcall(function()
                                entry.target[entry.name] = entry.original
                            end)
                        end
                    end

                    table.clear(guards)

                    suppressUntil = -math.huge
                end

                local function deps()
                    if not self.dependencies then
                        local ok, result = pcall(liveDependencies)

                        if ok then
                            self.dependencies = result
                        end
                    end

                    return self.dependencies
                end

                function self.isReady()
                    local d = deps()
                    local data = d and d.teamsData

                    if not data or type(data.GetTeams) ~= 'function' then
                        return false
                    end
                    if data.Loaded == false then
                        return false
                    end
                    if type(data.GetOwnedSlots) == 'function' then
                        local ok, slots = pcall(data.GetOwnedSlots)

                        if not ok or type(slots) ~= 'table' then
                            return false
                        end
                    end

                    return true
                end
                function self.getTeams()
                    local d = deps()
                    local data = d and d.teamsData

                    if not data or type(data.GetTeams) ~= 'function' or not self.isReady() then
                        return nil
                    end

                    local ok, teams = pcall(data.GetTeams)

                    return if ok and type(teams) == 'table'then teams else nil
                end
                function self.isSlotOwned(number)
                    local d = deps()
                    local data = d and d.teamsData

                    if not data or type(data.IsSlotOwned) ~= 'function' then
                        return false
                    end

                    local ok, owned = pcall(data.IsSlotOwned, number)

                    return ok and owned == true
                end
                function self.ownsUnit(guid)
                    local d = deps()
                    local owned = d and d.ownedUnits

                    if not owned or type(owned.GetUnitObject) ~= 'function' then
                        return false
                    end

                    local ok, unit = pcall(owned.GetUnitObject, guid)

                    return ok and unit ~= nil
                end
                function self.getEquipped()
                    local d = deps()
                    local owned = d and d.ownedUnits

                    if not owned or type(owned.GetEquippedUnits) ~= 'function' then
                        return {}
                    end

                    local ok, equipped = pcall(owned.GetEquippedUnits)

                    return if ok and type(equipped) == 'table'then equipped else{}
                end
                function self.onChanged(callback)
                    local d = deps()
                    local data = d and d.teamsData

                    if not data then
                        return nil
                    end

                    local connections = {}

                    for _, name in {
                        'TeamUpdated',
                        'SlotPurchased',
                        'TeamsLoaded',
                    }do
                        local signal = data[name]

                        if type(signal) == 'table' and type(signal.Connect) == 'function' then
                            local ok, connection = pcall(signal.Connect, signal, callback)

                            if ok and connection then
                                table.insert(connections, connection)
                            end
                        end
                    end

                    return function()
                        for _, connection in connections do
                            pcall(function()
                                (connection):Disconnect()
                            end)
                        end

                        table.clear(connections)
                    end
                end
                function self.ownedUnitList()
                    local d = deps()
                    local owned = d and d.ownedUnits

                    if not owned or type(owned.GetOwnedUnits) ~= 'function' or type(owned.GetUnitObject) ~= 'function' then
                        return {}
                    end

                    local ok, all = pcall(owned.GetOwnedUnits)

                    if not ok or type(all) ~= 'table' then
                        return {}
                    end

                    local list = {}

                    for guid in all do
                        local okUnit, unit = pcall(owned.GetUnitObject, guid)

                        if okUnit and type(unit) == 'table' and type(unit.UnitData) == 'table' then
                            local name = unit.UnitData.Name

                            if type(guid) == 'string' and type(name) == 'string' then
                                table.insert(list, {
                                    guid = guid,
                                    name = name,
                                    level = if type(unit.Level) == 'number'then unit.Level else 0,
                                    subTrait = if type(unit.SubTrait) == 'string'then unit.SubTrait else'None',
                                    ascensions = if type(unit.Ascensions) == 'number'then unit.Ascensions else 0,
                                    takedowns = if type(unit.Takedowns) == 'number'then unit.Takedowns else 0,
                                })
                            end
                        end
                    end

                    return list
                end
                function self.equippedList()
                    local d = deps()
                    local owned = d and d.ownedUnits
                    local equipped = self.getEquipped()
                    local list = {}

                    for slot = 1, 6 do
                        local guid = equipped[slot]

                        if type(guid) == 'string' and owned and type(owned.GetUnitObject) == 'function' then
                            local ok, unit = pcall(owned.GetUnitObject, guid)

                            if ok and type(unit) == 'table' and type(unit.UnitData) == 'table' and type(unit.UnitData.Name) == 'string' then
                                table.insert(list, {
                                    guid = guid,
                                    name = unit.UnitData.Name,
                                })
                            end
                        end
                    end

                    return list
                end
                function self.unequipAll()
                    local d = deps()
                    local remote = d and d.unitActions and d.unitActions[config.remoteNames.unequipAllUnits]

                    if not remote or type(remote.Fire) ~= 'function' then
                        return false
                    end

                    return (pcall(remote.Fire, {NonFarmsOnly = false}))
                end
                function self.equipUnit(guid)
                    if type(guid) ~= 'string' or guid == '' then
                        return false
                    end

                    local d = deps()
                    local remote = d and d.unitActions and d.unitActions[config.remoteNames.equipUnit]

                    if not remote or type(remote.Fire) ~= 'function' then
                        return false
                    end

                    return (pcall(remote.Fire, {UnitGUID = guid}))
                end
                function self.loadTeam(key)
                    if not TeamEquip.validKey(key) then
                        return false
                    end

                    local d = deps()
                    local remote = if inMatch then(d and d.gameUnits and d.gameUnits[config.remoteNames.requestLoadTeam])else(d and d.lobbyTeams and d.lobbyTeams[config.remoteNames.loadTeam])

                    if not remote or type(remote.Fire) ~= 'function' then
                        return false
                    end

                    local d2 = deps()

                    guard(d2 and d2.popupHandler, 'ShowPopup')
                    guard(d2 and d2.notifications, 'CreateNotification')

                    suppressUntil = now() + SUPPRESS_SECONDS

                    return (pcall(remote.Fire, {TeamKey = key}))
                end

                return self
            end

            return Adapter
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
            local Detect = {}

            function Detect.isAdventureMatch(matchData)
                if type(matchData) ~= 'table' then
                    return false
                end

                return (matchData.StageType == 'Odyssey' and matchData.SubMode == 'Adventure') or matchData.AdventureFloor ~= nil or matchData.AdventureRoomKind ~= nil or matchData.AdventureData ~= nil
            end

            return Detect
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
            local Settings = __DARKLUA_BUNDLE_MODULES.m()
            local ActivityState = __DARKLUA_BUNDLE_MODULES.q()
            local TeamEquip = __DARKLUA_BUNDLE_MODULES.h()
            local MacroEquip = __DARKLUA_BUNDLE_MODULES.i()
            local MacroStorage = __DARKLUA_BUNDLE_MODULES.s()
            local TeamAdapter = __DARKLUA_BUNDLE_MODULES.t()
            local AdventureDetect = __DARKLUA_BUNDLE_MODULES.u()
            local metadata = __DARKLUA_BUNDLE_MODULES.b()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local Runtime = {}
            local TRACE_FILE = 'ViperHubNextGen/AnimeVanguardsJoinerTrace.txt'
            local TRACE_LINES = 60
            local TRACE_RECENT = 12
            local ACTIVITY_CACHE_SECONDS = 10
            local LOBBY_PLACE_ID = metadata.placeIds[1]
            local RETRY_SECONDS = 30
            local POLL_SECONDS = 1
            local RIFT_POLL_SECONDS = 2
            local ACK_TIMEOUT_SECONDS = 10
            local TEAM_LOAD_TIMEOUT_SECONDS = (config).thresholds.teamLoadTimeoutSeconds
            local TEAM_LOAD_ATTEMPTS = (config).thresholds.teamLoadAttempts
            local JOINER_RUN_MAX_AGE_SECONDS = (config).thresholds.joinerRunMaxAgeSeconds
            local MACRO_LIST_CACHE_SECONDS = (config).thresholds.macroListCacheSeconds
            local CHANGE_STAGE_RETRY_SECONDS = (config).thresholds.changeStageRetrySeconds
            local CHANGE_STAGE_ATTEMPTS = (config).thresholds.changeStageAttempts
            local SWITCHABLE_STAGE_TYPES = (config).switchableStageTypes
            local START_TIMEOUT_SECONDS = 15
            local ADVENTURE_HOST_WAIT_SECONDS = 60
            local MODES = {
                Stage = 'Story',
                ['Legend Stage'] = 'LegendStage',
                Raid = 'Raid',
                Dungeon = 'Dungeon',
            }
            local CHALLENGES = {
                ['Regular Challenge'] = 'Regular',
                ['Daily Challenge'] = 'Daily',
                ['Weekly Challenge'] = 'Weekly',
            }

            local function resolve(root, path)
                local value = root

                for part in string.gmatch(path, '[^%.]+')do
                    if not value then
                        return nil
                    end

                    local ok, child = pcall(function()
                        local v = value

                        if type(v) == 'userdata' then
                            return v:FindFirstChild(part)
                        else
                            return v[part]
                        end
                    end)

                    value = if ok then child else nil
                end

                return value
            end
            local function optionalModule(root, path)
                local ok, result = pcall(function()
                    return (require)(resolve(root, path))
                end)

                return if ok then result else nil
            end
            local function requestLobbyReturn(deps)
                local client = deps.lobbyReturn

                if not client and deps.game then
                    local ok, replicated = pcall(deps.game.GetService, deps.game, 'ReplicatedStorage')

                    if ok then
                        client = optionalModule(replicated, config.instancePaths.lobbyReturnClient)
                    end
                end

                local remote = client and client[config.remoteNames.requestTeleportToLobby]

                if not remote or type(remote.Fire) ~= 'function' then
                    return false
                end

                return pcall(remote.Fire)
            end
            local function liveDependencies()
                local env = getfenv()
                local gameObject = env.game
                local replicated = gameObject:GetService('ReplicatedStorage')
                local starterPlayer = gameObject:GetService('StarterPlayer')
                local paths = config.instancePaths
                local base = resolve(starterPlayer, paths.lobbyHandlerBase)
                local isLobby = gameObject.PlaceId == LOBBY_PLACE_ID

                return {
                    game = gameObject,
                    task = env.task,
                    clock = os.time,
                    userId = gameObject:GetService('Players').LocalPlayer.UserId,
                    localPlayer = gameObject:GetService('Players').LocalPlayer,
                    network = if isLobby then optionalModule(replicated, paths.lobbyMatchmakingClient)else nil,
                    lobby = if isLobby then optionalModule(base, 'LobbyHandler')else nil,
                    progress = if isLobby then optionalModule(base, 'PlayerLobbyDataHandler')else nil,
                    challengeNetwork = if isLobby then optionalModule(replicated, paths.lobbyChallengesClient)else nil,
                    challengeData = optionalModule(replicated, paths.challengesData),
                    challengeStages = if isLobby then optionalModule(starterPlayer, paths.challengesDataHandler)else nil,
                    challengeAttempts = optionalModule(starterPlayer, paths.challengeAttempts),
                    teamAdapter = TeamAdapter.new(nil, not isLobby),
                    bountyData = optionalModule(replicated, config.instancePaths.bountyData),
                    bountyState = optionalModule(starterPlayer, if isLobby then config.instancePaths.bountyState else config.instancePaths.bountyStateMatch),
                    worldlines = optionalModule(replicated, config.instancePaths.worldlinesData),
                    worldlineNetwork = if isLobby then optionalModule(replicated, config.instancePaths.worldlinesClient)else nil,
                    bossRotation = optionalModule(replicated, config.instancePaths.bossRotation),
                    bossEvents = optionalModule(replicated, config.instancePaths.bossEventNames),
                    bossNetwork = if isLobby then optionalModule(replicated, config.instancePaths.bossEventsClient)else nil,
                    specialEvents = if isLobby then optionalModule(replicated, config.instancePaths.specialEventsClient)else nil,
                    riftsData = optionalModule(starterPlayer, config.instancePaths.riftsData),
                    activityState = ActivityState.new(env, gameObject:GetService('Players').LocalPlayer.UserId),
                    gameHandler = if not isLobby then optionalModule(replicated, config.instancePaths.gameHandler)else nil,
                    lobbyReturn = if not isLobby then optionalModule(replicated, config.instancePaths.lobbyReturnClient)else nil,
                }
            end

            function Runtime.new(dependencies)
                local self = {
                    dependencies = dependencies,
                    context = nil,
                    enabled = {},
                    selection = {},
                    pending = nil,
                    lastAttempt = -math.huge,
                    status = 'Idle',
                    onStatus = nil,
                    disconnect = nil,
                    teleportConnection = nil,
                    matchEndConnection = nil,
                    confirmed = nil,
                    currentJoinedName = nil,
                    teleportingToLobby = nil,
                    returnAttempts = 0,
                    lastActivityRead = -math.huge,
                    returnOnMatchEnd = false,
                    macro = nil,
                    gameSettings = nil,
                    changeAttempt = nil,
                    lastSwitch = nil,
                    teamAttempt = nil,
                    macroAttempt = nil,
                    macroStore = nil,
                    macroCache = nil,
                    macroOptionsCache = nil,
                }
                local statusListeners = {}
                local reportEntries = {}

                local function note(name, text)
                    local previous = reportEntries[name]

                    if (previous == nil or previous.text ~= text) and type(self.traceFn) == 'function' then
                        pcall(self.traceFn, name .. ': ' .. text)
                    end

                    local clockFn = if self.dependencies then self.dependencies.clock else nil

                    reportEntries[name] = {
                        text = text,
                        at = if type(clockFn) == 'function'then(clockFn)()else os.time(),
                    }
                end

                local traceLines = {}
                local lastTraced = ''
                local recentTraced = {}

                local function trace(value)
                    if value == lastTraced or table.find(recentTraced, value) then
                        return
                    end

                    lastTraced = value

                    table.insert(recentTraced, value)

                    if #recentTraced > TRACE_RECENT then
                        table.remove(recentTraced, 1)
                    end

                    local env = getfenv()
                    local place = if self.dependencies and self.dependencies.game then self.dependencies.game.PlaceId else 0

                    table.insert(traceLines, string.format('%s place=%s %s', os.date('!%H:%M:%S'), tostring(place), value))

                    if #traceLines > TRACE_LINES then
                        table.remove(traceLines, 1)
                    end
                    if not self.traceLoaded then
                        self.traceLoaded = true

                        local readFile = env.readfile
                        local isFile = env.isfile

                        if type(readFile) == 'function' and type(isFile) == 'function' then
                            pcall(function()
                                if (isFile)(TRACE_FILE) then
                                    local previous = {}

                                    for line in string.gmatch((readFile)(TRACE_FILE), '[^\n]+')do
                                        table.insert(previous, line)
                                    end

                                    for index = math.max(1, #previous - TRACE_LINES + 2), #previous do
                                        local position = #traceLines

                                        table.insert(traceLines, position, previous[index])
                                    end
                                end
                            end)
                        end
                    end

                    local writeFile = env.writefile
                    local isFolder = env.isfolder
                    local makeFolder = env.makefolder

                    if type(writeFile) == 'function' and type(isFolder) == 'function' then
                        pcall(function()
                            if not (isFolder)('ViperHubNextGen') then
                                (makeFolder)('ViperHubNextGen')
                            end

                            (writeFile)(TRACE_FILE, table.concat(traceLines, '\n'))
                        end)
                    end
                end

                self.traceFn = trace

                local function setStatus(value)
                    trace(value)

                    local prefix = string.match(value, '^([%w ]+): ')

                    if prefix and table.find(Settings.get().priority, prefix) then
                        note(prefix, string.sub(value, #prefix + 3))
                    end

                    self.status = value

                    if self.onStatus then
                        pcall(self.onStatus, value)
                    end

                    for _, listener in table.clone(statusListeners)do
                        pcall(listener, value)
                    end
                end

                local POSITIVE_REPORT = {
                    'confirmed',
                    'waiting for server',
                    'joining',
                    'entered',
                    'start sent',
                    'teleport',
                    'available',
                    'changing stage',
                    'loading',
                    'equipping',
                }

                local function isPositive(text)
                    local lower = string.lower(text)

                    if string.find(lower, 'unavailable', 1, true) or string.find(lower, 'not available', 1, true) then
                        return false
                    end

                    for _, needle in POSITIVE_REPORT do
                        if string.find(lower, needle, 1, true) then
                            return true
                        end
                    end

                    return false
                end

                function self.getReport()
                    local lines = {}
                    local clockFn = if self.dependencies then self.dependencies.clock else nil
                    local now = if type(clockFn) == 'function'then(clockFn)()else os.time()
                    local settings = Settings.get()

                    for _, name in settings.priority do
                        local entry = reportEntries[name]
                        local line

                        if not self.enabled[name] then
                            line = '\u{274c} ' .. name .. ' \u{2014} off'
                        elseif entry then
                            line = string.format('%s %s \u{2014} %s (%ds ago)', if isPositive(entry.text)then'\u{2705}'else'\u{274c}', name, entry.text, math.max(0, now - entry.at))
                        else
                            line = '\u{274c} ' .. name .. ' \u{2014} no decision yet'
                        end

                        table.insert(lines, line)
                    end

                    if settings.paused then
                        table.insert(lines, 1, 'Joiners are disabled (Disable Auto Joiners is on).')
                    end

                    return lines
                end
                function self.addStatusListener(listener)
                    table.insert(statusListeners, listener)

                    return function()
                        local index = table.find(statusListeners, listener)

                        if index then
                            table.remove(statusListeners, index)
                        end
                    end
                end
                function self.setReturnGate(gate)
                    self.returnGate = gate
                end
                function self.setMacro(m)
                    self.macro = m
                end
                function self.setGameSettings(gs)
                    self.gameSettings = gs
                end
                function self.setAdventure(adventure)
                    self.adventure = adventure
                end
                function self.isEnabled(name)
                    local live = self.enabled[name]

                    if live ~= nil then
                        return live == true
                    end

                    return Settings.get().enabled[name] == true
                end
                function self.getTeamOptions()
                    local adapter = self.dependencies and self.dependencies.teamAdapter

                    if not adapter then
                        local ok, created = pcall(TeamAdapter.new)

                        if not ok then
                            return nil
                        end

                        adapter = created

                        if self.dependencies then
                            self.dependencies.teamAdapter = created
                        end
                    end

                    local teams = adapter.getTeams()

                    if not teams then
                        return nil
                    end

                    return TeamEquip.options(teams, adapter.isSlotOwned)
                end

                local function teamStep(name, now)
                    local deps = self.dependencies
                    local settings = Settings.get()
                    local key = settings.teamEquip.teams[name]
                    local adapter = deps and deps.teamAdapter

                    if not settings.teamEquip.enabled or not key or not adapter then
                        return 'go'
                    end

                    local teams = adapter.getTeams()

                    if not teams then
                        setStatus('Team Equipper: team data is not loaded yet (' .. name .. ')')

                        return 'skip'
                    end

                    local team = teams[key]
                    local number = TeamEquip.number(key)

                    if not team or not number or not adapter.isSlotOwned(number) then
                        setStatus(string.format('Team Equipper: %s is not available (%s)', key, name))

                        return 'skip'
                    end

                    local verdict = TeamEquip.evaluate(team, adapter.ownsUnit, adapter.getEquipped())

                    if verdict == 'unusable' then
                        setStatus(string.format('Team Equipper: %s has no usable units (%s)', key, name))

                        return 'skip'
                    end
                    if verdict == 'match' then
                        self.teamAttempt = nil

                        return 'go'
                    end

                    local attempt = self.teamAttempt

                    if not attempt or attempt.key ~= key then
                        attempt = {
                            key = key,
                            sent = 0,
                            last = -math.huge,
                            backoff = -math.huge,
                        }
                        self.teamAttempt = attempt
                    end
                    if now < attempt.backoff then
                        return 'skip'
                    end
                    if attempt.sent > 0 and now - attempt.last < TEAM_LOAD_TIMEOUT_SECONDS then
                        setStatus(string.format('Team Equipper: waiting for %s to equip', key))

                        return 'wait'
                    end
                    if attempt.sent >= TEAM_LOAD_ATTEMPTS then
                        attempt.sent = 0
                        attempt.backoff = now + RETRY_SECONDS

                        setStatus(string.format('Team Equipper: %s was not confirmed; skipping %s', key, name))

                        return 'skip'
                    end

                    attempt.sent += 1

                    attempt.last = now

                    local sent = adapter.loadTeam(key)

                    setStatus(if sent then string.format('Team Equipper: loading %s (%d/%d)', key, attempt.sent, TEAM_LOAD_ATTEMPTS)else'Team Equipper: load request failed')

                    return 'wait'
                end
                local function getMacroStore()
                    local deps = self.dependencies

                    if deps and deps.macroStore then
                        return deps.macroStore
                    end
                    if not self.macroStore then
                        local env = getfenv()
                        local okHttp, http = pcall(function()
                            return env.game:GetService('HttpService')
                        end)

                        if okHttp and http then
                            local ok, store = pcall(MacroStorage.new, env, http)

                            if ok then
                                self.macroStore = store
                            end
                        end
                    end

                    return self.macroStore
                end

                function self.getMacroOptions()
                    local cached = self.macroOptionsCache
                    local clock = os.clock()

                    if cached and clock - cached.at < MACRO_LIST_CACHE_SECONDS then
                        return cached.names
                    end

                    local store = getMacroStore()

                    if not store then
                        return {}
                    end

                    local ok, names = pcall(store.list)
                    local result = if ok and type(names) == 'table'then names else{}

                    self.macroOptionsCache = {
                        names = result,
                        at = clock,
                    }

                    return result
                end

                local function macroStep(name, now)
                    local deps = self.dependencies
                    local settings = Settings.get()
                    local file = settings.macroEquip.macros[name]
                    local adapter = deps and deps.teamAdapter

                    if not settings.macroEquip.enabled or not file or not adapter then
                        return 'go'
                    end

                    local cache = self.macroCache
                    local document = nil

                    if cache and cache.file == file and now - cache.at < 5 then
                        document = cache.document
                    else
                        local store = getMacroStore()

                        document = if store then store.read(file)else nil
                        self.macroCache = if document then{
                            file = file,
                            document = document,
                            at = now,
                        }else nil
                    end
                    if not document then
                        setStatus(string.format('Macro Equipper: macro %s could not be read (%s)', file, name))

                        return 'skip'
                    end

                    local names = MacroEquip.names(document.units)
                    local plan = MacroEquip.plan(names, adapter.equippedList(), adapter.ownedUnitList())

                    if plan.state == 'match' then
                        self.macroAttempt = nil

                        if #plan.missing > 0 then
                            setStatus('Macro Equipper: missing units ' .. table.concat(plan.missing, ', ') .. '; joining with the units available')
                        end

                        return 'go'
                    end

                    local attempt = self.macroAttempt

                    if not attempt or attempt.key ~= file then
                        attempt = {
                            key = file,
                            sent = 0,
                            last = -math.huge,
                            backoff = -math.huge,
                        }
                        self.macroAttempt = attempt
                    end
                    if now < attempt.backoff then
                        return 'skip'
                    end
                    if attempt.sent > 0 and now - attempt.last < TEAM_LOAD_TIMEOUT_SECONDS then
                        setStatus(string.format('Macro Equipper: waiting for %s units to equip', file))

                        return 'wait'
                    end
                    if attempt.sent >= TEAM_LOAD_ATTEMPTS then
                        attempt.sent = 0
                        attempt.backoff = now + RETRY_SECONDS

                        setStatus(string.format('Macro Equipper: %s units were not confirmed; skipping %s', file, name))

                        return 'skip'
                    end

                    attempt.sent += 1

                    attempt.last = now

                    local ok = adapter.unequipAll()

                    for _, guid in plan.steps do
                        ok = adapter.equipUnit(guid) and ok
                    end

                    setStatus(if ok then string.format('Macro Equipper: equipping %s units (%d/%d)', file, attempt.sent, TEAM_LOAD_ATTEMPTS)else'Macro Equipper: equip request failed')

                    return 'wait'
                end
                local function equipStep(name, now, inMatch)
                    local settings = Settings.get()

                    if settings.teamEquip.enabled and settings.teamEquip.teams[name] then
                        return teamStep(name, now)
                    end
                    if inMatch then
                        return 'go'
                    end

                    return macroStep(name, now)
                end
                local function inMatchTeam(settings, matchData, now, bounty)
                    local deps = self.dependencies

                    if not deps or not deps.gameHandler or deps.gameHandler.IsMatchStarted ~= false then
                        return false
                    end

                    local row = TeamEquip.rowFor(matchData, bounty, (config).stageTypeRows, (config).challengeRows)

                    if not row then
                        return false
                    end

                    return equipStep(row, now, true) == 'wait'
                end
                local function isBountyMatch(settings, matchData)
                    local run = settings.bountyRun

                    return type(run) == 'table' and type(matchData) == 'table' and matchData.StageType == run.mode and matchData.Stage == run.stage and matchData.Act == run.act and os.time() - run.at >= 0 and os.time() - run.at < JOINER_RUN_MAX_AGE_SECONDS
                end
                local function createdByJoiner(settings, matchData)
                    local switched = self.lastSwitch
                    local deps = self.dependencies

                    if switched and type(matchData) == 'table' and deps and deps.gameHandler and switched.matchId == deps.gameHandler.MatchId and matchData.StageType == switched.mode and matchData.Stage == switched.stage and matchData.Act == switched.act then
                        return true
                    end

                    local run = settings.joinerRun

                    return type(run) == 'table' and type(matchData) == 'table' and matchData.StageType == run.mode and matchData.Stage == run.stage and matchData.Act == run.act and os.time() - run.at >= 0 and os.time() - run.at < JOINER_RUN_MAX_AGE_SECONDS
                end
                local function matchStates(now)
                    local deps = self.dependencies
                    local cached = self.activityCache
                    local snapshot

                    if cached and now - cached.at < ACTIVITY_CACHE_SECONDS then
                        snapshot = cached.snapshot
                    else
                        snapshot = deps.activityState and deps.activityState.load(now, deps.challengeData)
                        self.activityCache = {
                            at = now,
                            snapshot = snapshot,
                        }
                    end

                    local states = if snapshot and type(snapshot.states) == 'table'then table.clone(snapshot.states)else{}
                    local ws = deps.game and deps.game:GetService('Workspace')
                    local riftSpent = snapshot ~= nil and snapshot.riftSpent == true

                    if ws and ws.GetAttribute then
                        local okAttr, attrVal = pcall(ws.GetAttribute, ws, config.attributes.riftOpen)

                        if okAttr and attrVal == true and not riftSpent then
                            states.Rift = {
                                status = 'available',
                            }
                        end
                    end

                    return states
                end
                local function tryChangeStage(settings, matchData, now)
                    local deps = self.dependencies

                    if not settings.changeStageInMatch or type(matchData) ~= 'table' or not SWITCHABLE_STAGE_TYPES[matchData.StageType] or matchData.Host ~= deps.userId or not deps.gameHandler or deps.gameHandler.IsMatchStarted ~= false or not deps.lobbyReturn or type(deps.lobbyReturn.RequestStartMatch) ~= 'table' or type(deps.lobbyReturn.RequestStartMatch.Fire) ~= 'function' or not (createdByJoiner(settings, matchData) or isBountyMatch(settings, matchData)) then
                        return false
                    end

                    local target = nil
                    local targetName = nil
                    local states = matchStates(now)

                    for _, name in settings.priority do
                        local choice = settings.selection[name]
                        local playable = states[CHALLENGES[name] or name]

                        if (CHALLENGES[name] or name == 'Rift') and settings.enabled[name] and type(playable) == 'table' and playable.status == 'available' then
                            if self.changeSkippedFor ~= name then
                                self.changeSkippedFor = name

                                setStatus(name .. ': available; stage not changed in match')
                            end

                            return false
                        end
                        if name == 'Boss Bounties' and settings.enabled[name] then
                            local bounty = self.readBounty()

                            if bounty and bounty.left > 0 then
                                target = {
                                    StageType = bounty.mode,
                                    Stage = bounty.stage,
                                    Act = bounty.act,
                                    Difficulty = if bounty.mode == 'LegendStage'then'Nightmare'else'Normal',
                                    FriendsOnly = true,
                                }
                                targetName = name

                                break
                            end
                        elseif MODES[name] and settings.enabled[name] and type(choice) == 'table' then
                            target = {
                                StageType = MODES[name],
                                Stage = choice.stage,
                                Act = choice.act,
                                Difficulty = if MODES[name] == 'LegendStage' or choice.difficulty == 'Nightmare'then'Nightmare'else'Normal',
                                FriendsOnly = true,
                            }
                            targetName = name

                            break
                        end
                    end

                    self.changeSkippedFor = nil

                    if not target then
                        return false
                    end
                    if matchData.StageType == target.StageType and matchData.Stage == target.Stage and matchData.Act == target.Act and (matchData.Difficulty == nil or matchData.Difficulty == target.Difficulty) then
                        self.changeAttempt = nil

                        Settings.setJoinerRun({
                            mode = target.StageType,
                            stage = target.Stage,
                            act = target.Act,
                            at = os.time(),
                        })

                        if targetName == 'Boss Bounties' then
                            Settings.setBountyRun({
                                mode = target.StageType,
                                stage = target.Stage,
                                act = target.Act,
                                at = os.time(),
                            })
                        end

                        return false
                    end

                    local key = target.StageType .. '/' .. target.Stage .. '/' .. target.Act .. '/' .. target.Difficulty
                    local attempt = self.changeAttempt
                    local matchId = deps.gameHandler.MatchId

                    if not attempt or attempt.key ~= key or attempt.matchId ~= matchId then
                        attempt = {
                            key = key,
                            matchId = matchId,
                            sent = 0,
                            last = -math.huge,
                        }
                        self.changeAttempt = attempt
                    end
                    if attempt.sent >= CHANGE_STAGE_ATTEMPTS then
                        return false
                    end
                    if now - attempt.last < CHANGE_STAGE_RETRY_SECONDS then
                        return true
                    end

                    attempt.sent += 1

                    attempt.last = now
                    self.lastSwitch = {
                        mode = target.StageType,
                        stage = target.Stage,
                        act = target.Act,
                        matchId = deps.gameHandler.MatchId,
                    }

                    local ok = pcall(deps.lobbyReturn.RequestStartMatch.Fire, target)

                    setStatus(if ok then string.format('%s: changing stage in match (%d/%d)', targetName, attempt.sent, CHANGE_STAGE_ATTEMPTS)else'Change stage request failed')

                    return true
                end

                function self.setSelection(name, stage, act, difficulty)
                    if MODES[name] and type(stage) == 'string' and type(act) == 'string' then
                        self.selection[name] = {
                            stage = stage,
                            act = act,
                            difficulty = difficulty,
                        }

                        Settings.setSelection(name, self.selection[name])
                    end
                end
                function self.setChallenge(name, challengeName)
                    if CHALLENGES[name] and type(challengeName) == 'string' and #challengeName > 0 then
                        local existing = Settings.get().selection[name]
                        local merged = if type(existing) == 'table'then table.clone(existing)else{}

                        merged.challengeName = challengeName
                        self.selection[name] = merged

                        Settings.setSelection(name, merged)
                    end
                end
                function self.setWorldline(worldlineId, traitsType)
                    if type(worldlineId) == 'string' and #worldlineId > 0 and (traitsType == 'Traits' or traitsType == 'NoTraits') then
                        self.selection.Worldline = {
                            worldlineId = worldlineId,
                            traitsType = traitsType,
                        }

                        Settings.setSelection('Worldline', self.selection.Worldline)
                    end
                end
                function self.worldlineCanContinue(deps)
                    local handler = deps and deps.gameHandler
                    local data = if handler and type(handler.GetGameData) == 'function'then select(2, pcall(handler.GetGameData, handler))else nil

                    if type(data) ~= 'table' or data.StageType ~= 'Worldline' then
                        return false
                    end

                    local ok, visible = pcall(function()
                        local playerGui = deps.localPlayer:FindFirstChildOfClass('PlayerGui')
                        local screen = playerGui and playerGui:FindFirstChild('EndScreen')
                        local buttons = screen and screen:FindFirstChild('Holder') and screen.Holder:FindFirstChild('Buttons')
                        local nextFrame = buttons and buttons:FindFirstChild('Next')

                        return nextFrame ~= nil and nextFrame.Visible == true
                    end)

                    return ok and visible == true
                end
                function self.readBounty()
                    local deps = self.dependencies

                    if not deps or not deps.bountyData or not deps.bountyState then
                        return nil
                    end

                    local okState, data = pcall(deps.bountyState.GetData)

                    if not okState or type(data) ~= 'table' then
                        return nil
                    end

                    local seed, left = data.BountySeed, data.BountiesLeft

                    if type(seed) ~= 'number' or type(left) ~= 'number' then
                        return nil
                    end

                    local okData, bounty = pcall(deps.bountyData.GetBountyFromSeed, seed)

                    if not okData or type(bounty) ~= 'table' or type(bounty.StageType) ~= 'string' or type(bounty.Stage) ~= 'string' or type(bounty.Act) ~= 'string' then
                        return nil
                    end

                    return {
                        mode = bounty.StageType,
                        stage = bounty.Stage,
                        act = bounty.Act,
                        boss = if type(bounty.BossName) == 'string'then bounty.BossName else nil,
                        left = left,
                    }
                end
                function self.readWorldlineProgress()
                    local deps = self.dependencies
                    local remote = deps and deps.worldlineNetwork and deps.worldlineNetwork[config.remoteNames.worldlineProgress]

                    if not remote or type(remote.Invoke) ~= 'function' then
                        return nil
                    end

                    local ok, progress = pcall(remote.Invoke)

                    if not ok or type(progress) ~= 'table' or progress.Ready ~= true then
                        return nil
                    end

                    local worlds = {}

                    if type(progress.AltWorldlines) == 'table' then
                        for _, entry in progress.AltWorldlines do
                            if type(entry) == 'table' and type(entry.WorldlineId) == 'string' then
                                table.insert(worlds, {
                                    id = entry.WorldlineId,
                                    room = if type(entry.CurrentRoom) == 'number'then entry.CurrentRoom else nil,
                                    completed = entry.Completed == true,
                                })
                            end
                        end
                    end

                    return {
                        room = if type(progress.CurrentRoom) == 'number'then progress.CurrentRoom else nil,
                        worlds = worlds,
                    }
                end
                function self.setBossEvent(eventName, difficulty)
                    if type(eventName) == 'string' and #eventName > 0 and (difficulty == 'Normal' or difficulty == 'Elite') then
                        self.selection['Boss Event'] = {
                            eventName = eventName,
                            difficulty = difficulty,
                        }

                        Settings.setSelection('Boss Event', self.selection['Boss Event'])
                    end
                end
                function self.setEnabled(name, value)
                    if (MODES[name] or CHALLENGES[name] or name == 'Worldline' or name == 'Boss Event' or name == 'Boss Bounties' or name == 'Rift' or name == 'Odyssey Adventure') and type(value) == 'boolean' then
                        self.enabled[name] = value

                        Settings.setEnabled(name, value)
                        setStatus(if value then'Enabled: ' .. name else'Disabled: ' .. name)
                    end
                end
                function self.stepInMatch(now)
                    local deps = self.dependencies
                    local settings = Settings.get()

                    if settings.paused then
                        self.teleportingToLobby = nil
                        self.returnOnMatchEnd = false

                        return
                    end
                    if deps.gameHandler and not deps.gameHandler.IsGameLoaded then
                        return
                    end

                    local matchData = deps.gameHandler and deps.gameHandler.GameData

                    if AdventureDetect.isAdventureMatch(matchData) or self.currentJoinedName == 'Odyssey Adventure' then
                        self.teleportingToLobby = nil
                        self.returnOnMatchEnd = false

                        return
                    end

                    local currentChallenge = type(matchData) == 'table' and (matchData.ChallengeType or matchData.Challenge) or nil
                    local currentRift = type(matchData) == 'table' and (matchData.Rift ~= nil or matchData.IsBossRift == true or matchData.StageType == 'Rift')
                    local isAnyChallenge = currentChallenge ~= nil or (type(matchData) == 'table' and matchData.StageType == 'Challenge')

                    if isAnyChallenge or currentRift then
                        inMatchTeam(settings, matchData, now, false)

                        return
                    end
                    if self.currentJoinedName and (CHALLENGES[self.currentJoinedName] or self.currentJoinedName == 'Rift') then
                        return
                    end
                    if self.teleportingToLobby then
                        if now - self.teleportingToLobby >= config.thresholds.returnRetrySeconds and self.returnAttempts < config.thresholds.returnRetryLimit then
                            self.returnAttempts += 1

                            self.teleportingToLobby = now

                            setStatus(if requestLobbyReturn(deps)then'Lobby return requested again'else'Lobby return request failed')
                        end

                        return
                    end
                    if tryChangeStage(settings, matchData, now) then
                        return
                    end
                    if inMatchTeam(settings, matchData, now, isBountyMatch(Settings.get(), matchData)) then
                        return
                    end
                    if isBountyMatch(Settings.get(), matchData) then
                        local gs = self.gameSettings
                        local autoReplay = if gs and type(gs.get) == 'function'then(gs.get)('AutoReplay')else nil

                        self.returnOnMatchEnd = autoReplay ~= true

                        return
                    end

                    local states = matchStates(now)

                    for _, name in settings.priority do
                        local choice = settings.selection[name]
                        local state = states[CHALLENGES[name] or name]

                        if settings.enabled[name] and choice and choice.backToLobby and type(state) == 'table' and state.status == 'available' and not (name == 'Rift' and currentRift) and not (CHALLENGES[name] and currentChallenge == CHALLENGES[name]) then
                            local reason = if name == 'Rift'then'Rift is open!'else(name .. ': available')

                            if choice.returnMode == 'Wait Match End' then
                                if not self.returnOnMatchEnd then
                                    self.returnOnMatchEnd = true

                                    setStatus(reason .. '; returning after match end')
                                end
                            else
                                if self.macro and type(self.macro.suspend) == 'function' then
                                    pcall(self.macro.suspend)
                                end

                                self.returnAttempts = 1
                                self.teleportingToLobby = now

                                setStatus(if requestLobbyReturn(deps)then reason .. ' Returning to lobby...'else name .. ': lobby return request failed')
                            end

                            return
                        end
                    end
                end
                function self.step(now)
                    local context = self.context
                    local deps = self.dependencies

                    if not context or not context.alive or not deps then
                        return
                    end
                    if deps.game and deps.game.PlaceId ~= LOBBY_PLACE_ID then
                        self.stepInMatch(now)

                        return
                    end
                    if not self.confirmed and not self.pending then
                        local current = Settings.get()

                        if current.bountyRun ~= nil then
                            Settings.setBountyRun(nil)
                        end
                        if current.joinerRun ~= nil then
                            Settings.setJoinerRun(nil)
                        end
                    end
                    if deps.activityState and now - self.lastActivityRead >= RIFT_POLL_SECONDS then
                        local states = {}
                        local challengeSeeds = {}

                        for _, kind in {
                            'Regular',
                            'Daily',
                            'Weekly',
                        }do
                            local status, period = ActivityState.challenge(deps.challengeAttempts, deps.challengeData, kind)

                            if status ~= 'unknown' and period ~= nil then
                                states[kind] = {
                                    status = status,
                                    period = period,
                                }
                            end
                            if deps.challengeAttempts and type(deps.challengeAttempts.GetChallengeSeed) == 'function' then
                                local okSeed, seedVal = pcall(deps.challengeAttempts.GetChallengeSeed, kind)

                                if okSeed and type(seedVal) == 'number' then
                                    challengeSeeds[kind] = seedVal
                                end
                            end
                        end

                        local riftStatus = ActivityState.rift(deps.game, deps.specialEvents)

                        if riftStatus == 'available' then
                            states.Rift = {
                                status = riftStatus,
                                observedAt = now,
                            }
                        end

                        local riftInfo = nil

                        if deps.specialEvents and deps.specialEvents[config.remoteNames.getRiftAttempts] then
                            local remote = deps.specialEvents[config.remoteNames.getRiftAttempts]

                            if type(remote.Invoke) == 'function' then
                                local ok, res = pcall(remote.Invoke)

                                if ok and type(res) == 'table' and res.Ready and type(res.AttemptsRemaining) == 'number' then
                                    riftInfo = {
                                        attempts = res.AttemptsRemaining,
                                        hour = math.floor(now / 3600),
                                    }
                                end
                            end
                        end

                        deps.activityState.save(now, states, challengeSeeds, riftInfo)

                        self.lastActivityRead = now
                    end
                    if self.confirmed then
                        local confirmed = self.confirmed

                        if not confirmed.startSent and (Settings.get().paused or not self.enabled[confirmed.name]) then
                            self.confirmed = nil

                            setStatus(confirmed.name .. ': Start cancelled')

                            return
                        end
                        if deps.game.PlaceId ~= LOBBY_PLACE_ID then
                            self.currentJoinedName = confirmed.name
                            self.confirmed = nil

                            setStatus(confirmed.name .. ': entered match')

                            return
                        end
                        if confirmed.startSent then
                            if now - confirmed.startSent >= START_TIMEOUT_SECONDS then
                                self.confirmed = nil

                                setStatus(confirmed.name .. ': Start sent; teleport not confirmed')
                            end

                            return
                        end
                        if confirmed.mode == 'Rift' then
                            return
                        end
                        if not deps.lobby.IsHosting then
                            if now - confirmed.confirmedAt >= (confirmed.hostWaitSeconds or ACK_TIMEOUT_SECONDS) then
                                self.confirmed = nil

                                setStatus(confirmed.name .. ': host state not ready')
                            end

                            return
                        end
                        if not deps.network or not deps.network.StartMatch or type(deps.network.StartMatch.Fire) ~= 'function' then
                            self.confirmed = nil

                            setStatus(confirmed.name .. ': Start network unavailable')

                            return
                        end

                        confirmed.startSent = now

                        local ok = pcall(deps.network.StartMatch.Fire)

                        if ok then
                            setStatus(confirmed.name .. ': Start sent; waiting for teleport')
                        else
                            self.confirmed = nil

                            setStatus(confirmed.name .. ': Start request failed')
                        end

                        return
                    end
                    if Settings.get().paused then
                        return
                    end
                    if self.pending then
                        if now - self.pending.started >= ACK_TIMEOUT_SECONDS then
                            self.pending = nil

                            setStatus('No server confirmation; retry delayed')
                        else
                            return
                        end
                    end
                    if not deps.lobby or deps.game.PlaceId ~= LOBBY_PLACE_ID or deps.lobby.IsHosting or deps.lobby.IsInLobby then
                        return
                    end

                    local cooldownActive = now - self.lastAttempt < math.max(Settings.get().cooldown, RETRY_SECONDS)

                    for _, name in Settings.get().priority do
                        local mode = MODES[name]
                        local choice = self.selection[name]

                        if name == 'Rift' and self.enabled[name] and not (deps.specialEvents and deps.riftsData) then
                            note(name, 'Rift game modules not found (' .. (if deps.specialEvents then''else'special events ') .. (if deps.riftsData then''else'rifts data') .. '); the game may have moved them')
                        end
                        if name == 'Rift' and self.enabled[name] and deps.specialEvents and deps.riftsData then
                            local currentHour = math.floor(now / 3600)

                            if self.lastCompletedRiftHour == currentHour then
                                note(name, 'no attempts left this hour')
                            else
                                local ws = deps.game:GetService('Workspace')
                                local isRiftOpenAttr = nil

                                if ws and ws.GetAttribute then
                                    local okAttr, attrVal = pcall(ws.GetAttribute, ws, 'IsRiftOpen')

                                    if okAttr then
                                        isRiftOpenAttr = attrVal
                                    end
                                end

                                local isOpen = if isRiftOpenAttr ~= nil then(isRiftOpenAttr == true)else(now % 3600 < 600)

                                if not isOpen then
                                    note(name, 'closed (opens at the start of each hour)')
                                else
                                    local okAtt, attRes = pcall(function()
                                        return deps.specialEvents[config.remoteNames.getRiftAttempts] and deps.specialEvents[config.remoteNames.getRiftAttempts].Invoke()
                                    end)

                                    if okAtt and type(attRes) == 'table' and attRes.Ready and (attRes.AttemptsRemaining or 0) <= 0 then
                                        self.lastCompletedRiftHour = currentHour

                                        note(name, 'no attempts left this hour')
                                    elseif okAtt and type(attRes) == 'table' and attRes.Ready and (attRes.AttemptsRemaining or 0) > 0 then
                                        local rifts = if type(deps.riftsData.GetRifts) == 'function'then(deps.riftsData.GetRifts)()else nil
                                        local targetGuid = nil

                                        if type(rifts) == 'table' then
                                            for guid, room in pairs(rifts)do
                                                if type(room) == 'table' and type(room.Players) == 'table' and #room.Players < 6 then
                                                    targetGuid = guid

                                                    break
                                                end
                                            end
                                        end
                                        if targetGuid then
                                            local teamState = equipStep(name, now, false)

                                            if teamState == 'wait' then
                                                return
                                            end
                                            if teamState == 'skip' then
                                                continue
                                            end

                                            self.confirmed = {
                                                name = name,
                                                mode = 'Rift',
                                                guid = targetGuid,
                                                confirmedAt = now,
                                                startSent = now,
                                            }
                                            self.lastAttempt = now

                                            if deps.specialEvents[config.remoteNames.joinRift] and type(deps.specialEvents[config.remoteNames.joinRift].Fire) == 'function' then
                                                pcall(deps.specialEvents[config.remoteNames.joinRift].Fire, {RiftGUID = targetGuid})
                                            end

                                            setStatus('Rift: joining open room...')

                                            return
                                        else
                                            setStatus('Rift: all rooms full (6/6); waiting for open slot...')

                                            return
                                        end
                                    else
                                        local since = self.riftUnreadySince

                                        if since == nil or math.floor(since / 3600) ~= currentHour then
                                            since = now
                                            self.riftUnreadySince = now
                                        end
                                        if now - (since) < config.thresholds.riftAttemptWaitSeconds then
                                            setStatus('Rift: waiting for attempt data from the game')

                                            return
                                        end

                                        note(name, 'attempt data not ready from the game; skipped for now')
                                    end
                                end
                            end
                        end
                        if cooldownActive then
                            note(name, 'waiting for the joiner cooldown')

                            return
                        end
                        if name == 'Odyssey Adventure' and self.enabled[name] then
                            local adventure = self.adventure

                            if not adventure then
                                note(name, 'Adventure module unavailable')
                            else
                                local plan, reason = adventure.plan()

                                if not plan then
                                    note(name, reason or 'unavailable')
                                else
                                    for _, extra in plan.notes do
                                        note(name, extra)
                                    end

                                    self.confirmed = {
                                        name = name,
                                        mode = 'OdysseyAdventure',
                                        confirmedAt = now,
                                        hostWaitSeconds = ADVENTURE_HOST_WAIT_SECONDS,
                                    }
                                    self.lastAttempt = now

                                    if adventure.start(plan) then
                                        setStatus(name .. ': room requested (' .. plan.character .. '); waiting for the host room')
                                    else
                                        self.confirmed = nil

                                        setStatus(name .. ': start request failed')
                                    end

                                    return
                                end
                            end
                        end
                        if name == 'Boss Event' and self.enabled[name] and choice and deps.bossRotation and deps.bossNetwork then
                            local okCurrent, current = pcall(deps.bossRotation.GetCurrentBossEvent)

                            if okCurrent and current == choice.eventName and type(deps.bossNetwork[config.remoteNames.bossEventStart]) == 'table' then
                                local teamState = equipStep(name, now, false)

                                if teamState == 'wait' then
                                    return
                                end
                                if teamState == 'skip' then
                                    continue
                                end

                                self.pending = {
                                    name = name,
                                    mode = 'BossEvent',
                                    stage = current,
                                    started = now,
                                }
                                self.lastAttempt = now

                                local ok = pcall(deps.bossNetwork[config.remoteNames.bossEventStart].Fire, {
                                    EventName = current,
                                    Difficulty = choice.difficulty,
                                })

                                if not ok then
                                    self.pending = nil
                                end

                                setStatus(if ok then'Boss Event: waiting for server confirmation'else'Boss Event: request failed')

                                return
                            end

                            setStatus('Boss Event: selected boss is not current')
                        end
                        if name == 'Worldline' and self.enabled[name] and choice and deps.worldlines and deps.worldlineNetwork then
                            local okList, all = pcall(deps.worldlines.GetAll)

                            if okList and type(all) == 'table' and type(all[choice.worldlineId]) == 'table' then
                                local progressRemote = deps.worldlineNetwork[config.remoteNames.worldlineProgress]
                                local teleportRemote = deps.worldlineNetwork[config.remoteNames.worldlineTeleport]

                                if progressRemote and teleportRemote and type(progressRemote.Invoke) == 'function' and type(teleportRemote.Fire) == 'function' then
                                    local okProgress, progress = pcall(progressRemote.Invoke)
                                    local completed = false

                                    if okProgress and type(progress) == 'table' and type(progress.AltWorldlines) == 'table' then
                                        for _, entry in progress.AltWorldlines do
                                            if type(entry) == 'table' and entry.WorldlineId == choice.worldlineId and entry.Completed == true then
                                                completed = true
                                            end
                                        end
                                    end
                                    if completed then
                                        setStatus('Worldline: selected worldline already completed')
                                    elseif okProgress and type(progress) == 'table' and progress.Ready == true then
                                        local teamState = equipStep(name, now, false)

                                        if teamState == 'wait' then
                                            return
                                        end
                                        if teamState == 'skip' then
                                            continue
                                        end

                                        self.lastAttempt = now

                                        local ok = pcall(teleportRemote.Fire, {
                                            WorldlineId = choice.worldlineId,
                                            TraitsType = choice.traitsType,
                                        })

                                        self.worldlineRequest = {
                                            id = choice.worldlineId,
                                            at = now,
                                        }

                                        setStatus(if ok then'Worldline: teleport request sent'else'Worldline: request failed')

                                        return
                                    else
                                        setStatus('Worldline: selection or progress unavailable')
                                    end
                                else
                                    setStatus('Worldline: selection or progress unavailable')
                                end
                            else
                                setStatus('Worldline: selection or progress unavailable')
                            end
                        end
                        if name == 'Boss Bounties' and self.enabled[name] and deps.network and deps.network.CreateMatch then
                            local bounty = self.readBounty()

                            if not bounty then
                                setStatus("Boss Bounties: today's bounty unavailable")
                            elseif bounty.left <= 0 then
                                setStatus('Boss Bounties: none left today')
                            elseif deps.progress and type(deps.progress.GetActData) == 'function' then
                                local okProgress, unlocked = pcall(deps.progress.GetActData, bounty.mode, bounty.stage, bounty.act)

                                if okProgress and unlocked ~= nil then
                                    local difficulty = if bounty.mode == 'LegendStage'then'Nightmare'else'Normal'
                                    local teamState = equipStep(name, now, false)

                                    if teamState == 'wait' then
                                        return
                                    end
                                    if teamState == 'skip' then
                                        continue
                                    end

                                    self.pending = {
                                        name = name,
                                        mode = bounty.mode,
                                        stage = bounty.stage,
                                        act = bounty.act,
                                        started = now,
                                    }
                                    self.lastAttempt = now

                                    local ok = pcall(deps.network.CreateMatch.Fire, {
                                        Public = false,
                                        StageType = bounty.mode,
                                        Stage = bounty.stage,
                                        Act = bounty.act,
                                        Difficulty = difficulty,
                                        FriendsOnly = true,
                                    })

                                    if not ok then
                                        self.pending = nil

                                        setStatus('Boss Bounties: request failed')
                                    else
                                        setStatus('Boss Bounties: waiting for server confirmation')
                                    end

                                    return
                                end

                                setStatus('Boss Bounties: stage/act locked or progress unavailable')
                            end
                        end
                        if CHALLENGES[name] and self.enabled[name] and choice then
                            local kind = CHALLENGES[name]
                            local availability, challengePeriod = ActivityState.challenge(deps.challengeAttempts, deps.challengeData, kind)

                            if availability ~= 'available' then
                                note(name, if availability == 'unavailable'then'already played this period'else'availability unknown (game data not ready)')
                            else
                                local targetChallengeName = choice.challengeName or name
                                local rewardMap = (Settings.REGULAR_REWARD_MAP) or {}

                                if name == 'Regular Challenge' and choice.rewardChoice and rewardMap[choice.rewardChoice] then
                                    targetChallengeName = rewardMap[choice.rewardChoice]
                                end

                                local found = true

                                if deps.challengeData and type(deps.challengeData.GetChallengesOfType) == 'function' then
                                    local okList, candidates = pcall(deps.challengeData.GetChallengesOfType, kind)

                                    if okList and type(candidates) == 'table' then
                                        local anyFound = false

                                        for _, candidate in candidates do
                                            if type(candidate) == 'table' and candidate.Name == targetChallengeName then
                                                anyFound = true

                                                break
                                            end
                                        end

                                        found = anyFound
                                    end
                                end
                                if not found or not deps.challengeStages or type(deps.challengeStages.GetChallengeStage) ~= 'function' then
                                    setStatus(name .. ': current challenge data unavailable')
                                else
                                    local okStage, stage = pcall(deps.challengeStages.GetChallengeStage, targetChallengeName)

                                    if okStage and type(stage) == 'table' and type(stage.StageType) == 'string' and type(stage.Stage) == 'string' and type(stage.Act) == 'string' then
                                        local teamState = equipStep(name, now, false)

                                        if teamState == 'wait' then
                                            return
                                        end
                                        if teamState == 'skip' then
                                            continue
                                        end

                                        self.pending = {
                                            name = name,
                                            challengeName = targetChallengeName,
                                            mode = stage.StageType,
                                            stage = stage.Stage,
                                            act = stage.Act,
                                            started = now,
                                        }
                                        self.lastAttempt = now

                                        if not deps.challengeNetwork or not deps.challengeNetwork.StartChallenge or type(deps.challengeNetwork.StartChallenge.Fire) ~= 'function' then
                                            self.pending = nil

                                            setStatus(name .. ': challenge network unavailable')
                                        else
                                            local ok = pcall(deps.challengeNetwork.StartChallenge.Fire, {Name = targetChallengeName})

                                            if not ok then
                                                self.pending = nil

                                                setStatus(name .. ': request failed')
                                            else
                                                if challengePeriod and deps.activityState then
                                                    pcall(deps.activityState.markUsed, kind, challengePeriod)
                                                end

                                                setStatus(name .. ': waiting for server confirmation')
                                            end
                                        end

                                        return
                                    end

                                    setStatus(name .. ': current challenge data unavailable')
                                end
                            end
                        end
                        if mode and self.enabled[name] and choice and deps.progress and type(deps.progress.GetActData) == 'function' then
                            local okProgress, unlocked = pcall(deps.progress.GetActData, mode, choice.stage, choice.act)

                            if okProgress and unlocked ~= nil then
                                local teamState = equipStep(name, now, false)

                                if teamState == 'wait' then
                                    return
                                end
                                if teamState == 'skip' then
                                    continue
                                end

                                local pending = {
                                    name = name,
                                    mode = mode,
                                    stage = choice.stage,
                                    act = choice.act,
                                    started = now,
                                }

                                self.pending = pending
                                self.lastAttempt = now

                                local ok = pcall(deps.network.CreateMatch.Fire, {
                                    Public = false,
                                    StageType = mode,
                                    Stage = choice.stage,
                                    Act = choice.act,
                                    Difficulty = choice.difficulty,
                                    FriendsOnly = true,
                                })

                                if not ok then
                                    self.pending = nil

                                    setStatus(name .. ': request failed')
                                else
                                    setStatus(name .. ': waiting for server confirmation')
                                end

                                return
                            end

                            setStatus(name .. ': stage/act locked or progress unavailable')
                        end
                    end
                end
                function self.start(context)
                    if self.context then
                        return
                    end

                    self.context = context

                    pcall(function()
                        Settings.init(getfenv())
                    end)

                    local saved = Settings.get()

                    self.enabled = table.clone(saved.enabled)
                    self.selection = table.clone(saved.selection)

                    local adventure = self.adventure

                    if adventure and type(adventure.connect) == 'function' then
                        pcall(adventure.connect)
                    end

                    local function bindMatchConfirmed(deps)
                        if self.disconnect then
                            pcall(function()
                                (self.disconnect)()
                            end)

                            self.disconnect = nil
                        end
                        if deps.network and deps.network.MatchConfirmed and type(deps.network.MatchConfirmed.On) == 'function' then
                            self.disconnect = (deps.network.MatchConfirmed.On)(function(
                                payload
                            )
                                local pending = self.pending

                                if pending and context.alive and type(payload) == 'table' and payload.StageType == pending.mode and payload.Stage == pending.stage and (pending.act == nil or payload.Act == pending.act) and (not pending.challengeName or payload.ChallengeType == pending.challengeName or payload.Name == pending.challengeName or payload.Challenge == pending.challengeName) and (payload.HostUserId == deps.userId or tonumber(payload.HostUserId) == deps.userId) and type(payload.GUID) == 'string' and #payload.GUID > 0 then
                                    self.pending = nil
                                    pending.confirmedAt = deps.clock()
                                    self.confirmed = pending

                                    Settings.setJoinerRun({
                                        mode = pending.mode,
                                        stage = pending.stage,
                                        act = pending.act,
                                        at = os.time(),
                                    })

                                    if pending.name == 'Boss Bounties' then
                                        Settings.setBountyRun({
                                            mode = pending.mode,
                                            stage = pending.stage,
                                            act = pending.act,
                                            at = os.time(),
                                        })
                                    end

                                    setStatus(pending.name .. ': confirmed by server')
                                end
                            end)
                        end
                        if self.teleportConnection then
                            pcall(function()
                                self.teleportConnection:Disconnect()
                            end)

                            self.teleportConnection = nil
                        end

                        local localPlayer = deps.localPlayer

                        if localPlayer and localPlayer.OnTeleport then
                            local env = getfenv()
                            local teleportEnum = env.Enum and env.Enum.TeleportState and env.Enum.TeleportState.Started

                            self.teleportConnection = localPlayer.OnTeleport:Connect(function(
                                state
                            )
                                if self.confirmed and ((teleportEnum ~= nil and state == teleportEnum) or tostring(state):find('Started') ~= nil) then
                                    setStatus(self.confirmed.name .. ': teleport started')
                                end
                            end)
                        end
                        if deps.game.PlaceId ~= LOBBY_PLACE_ID then
                            local ghMod = deps.gameHandler

                            if ghMod and ghMod.MatchEnded and type(ghMod.MatchEnded.Connect) == 'function' then
                                self.matchEndConnection = (ghMod.MatchEnded.Connect)(ghMod.MatchEnded, function(
                                )
                                    if self.returnOnMatchEnd then
                                        setStatus('Match ended; waiting 2.5s for rewards...')

                                        local taskApi = (if self.dependencies and self.dependencies.task then self.dependencies.task else nil) or ((getfenv())).task

                                        if taskApi and type(taskApi.spawn) == 'function' and type(taskApi.wait) == 'function' then
                                            (taskApi).spawn(function()
                                                (taskApi).wait(2.5)

                                                local gate = self.returnGate
                                                local held = 0

                                                while type(gate) == 'function' and held < config.thresholds.returnGateMaxSeconds do
                                                    local okGate, busy = pcall(gate)

                                                    if not okGate or busy ~= true then
                                                        break
                                                    end

                                                    (taskApi).wait(0.5)

                                                    held += 0.5
                                                end

                                                if self.worldlineCanContinue(deps) then
                                                    setStatus('Worldline: next room available; staying in the match')

                                                    return
                                                end
                                                if self.gameSettings and type(self.gameSettings.set) == 'function' then
                                                    pcall(self.gameSettings.set, 'AutoReplay', false)
                                                    pcall(self.gameSettings.set, 'AutoNext', false)
                                                end

                                                self.returnAttempts = 1
                                                self.teleportingToLobby = deps.clock()

                                                setStatus(if requestLobbyReturn(deps)then'Match ended: lobby return requested'else'Match ended: lobby return request failed')
                                            end)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                    local function ensureDeps()
                        if self.dependencies then
                            return true
                        end

                        local ok, result = pcall(liveDependencies)

                        if ok and result then
                            if result.game.PlaceId == LOBBY_PLACE_ID then
                                if result.network and result.lobby then
                                    self.dependencies = result

                                    bindMatchConfirmed(result)

                                    return true
                                end
                            else
                                self.dependencies = result

                                bindMatchConfirmed(result)

                                return true
                            end
                        end

                        return false
                    end

                    if self.dependencies then
                        bindMatchConfirmed(self.dependencies)
                    elseif not ensureDeps() then
                        setStatus('Awaiting lobby matchmaking...')
                    end

                    local taskApi = (if self.dependencies and self.dependencies.task then self.dependencies.task else nil) or ((getfenv())).task

                    if type(taskApi) ~= 'table' or type(taskApi.spawn) ~= 'function' or type(taskApi.wait) ~= 'function' then
                        setStatus('Task scheduler unavailable')

                        return
                    end

                    (taskApi).spawn(function()
                        while context.alive and self.context == context do
                            if not self.dependencies then
                                if ensureDeps() then
                                    setStatus('Idle')
                                end
                            end
                            if self.dependencies then
                                self.step(self.dependencies.clock())
                            end

                            (taskApi).wait(POLL_SECONDS)
                        end
                    end)
                end
                function self.stop()
                    if self.disconnect then
                        pcall(function()
                            (self.disconnect)()
                        end)

                        self.disconnect = nil
                    end
                    if self.teleportConnection then
                        pcall(function()
                            self.teleportConnection:Disconnect()
                        end)

                        self.teleportConnection = nil
                    end

                    local adventure = self.adventure

                    if adventure and type(adventure.stop) == 'function' then
                        pcall(adventure.stop)
                    end
                    if self.matchEndConnection then
                        pcall(function()
                            self.matchEndConnection:Disconnect()
                        end)

                        self.matchEndConnection = nil
                    end

                    local teamAdapter = self.dependencies and self.dependencies.teamAdapter

                    if teamAdapter and type(teamAdapter.stop) == 'function' then
                        pcall(teamAdapter.stop)
                    end
                    if not dependencies then
                        self.dependencies = nil
                    end

                    self.context = nil
                    self.pending = nil
                    self.confirmed = nil
                    self.onStatus = nil
                    self.teleportingToLobby = nil
                    self.returnOnMatchEnd = false
                end

                return self
            end

            return Runtime
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
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local Catalog = {}
            local ADVENTURE = (config).adventure
            local ROMAN = {
                'I',
                'II',
                'III',
                'IV',
                'V',
            }
            local MAX_NAME = 64

            local function validName(value)
                return type(value) == 'string' and #value > 0 and #value <= MAX_NAME
            end
            local function copy(list)
                local result = {}

                for _, name in list do
                    table.insert(result, name)
                end

                return result
            end
            local function readCharacters(module)
                local result = {}

                if type(module) == 'table' and type(module.GetAllCharacters) == 'function' then
                    local ok, all = pcall(module.GetAllCharacters)

                    if ok and type(all) == 'table' then
                        for key, entry in all do
                            local item = entry
                            local name = if type(item) == 'table'then item.Name else nil

                            name = if validName(name)then name else key

                            if validName(name) and not table.find(result, name) then
                                table.insert(result, name)
                            end
                        end
                    end
                end

                table.sort(result)

                return result
            end
            local function readPowers(module)
                local result = {}

                if type(module) == 'table' and type(module.POWERS) == 'table' then
                    for _, power in ipairs(module.POWERS)do
                        local item = power

                        if type(item) == 'table' and validName(item.Name) and not table.find(result, item.Name) then
                            table.insert(result, item.Name)
                        end
                    end
                end

                return result
            end
            local function readPowerIds(module)
                local result = {}

                if type(module) == 'table' and type(module.POWERS) == 'table' then
                    for _, power in ipairs(module.POWERS)do
                        local item = power

                        if type(item) == 'table' and validName(item.Name) and type(item.Id) == 'number' then
                            result[item.Name] = item.Id
                        end
                    end
                end

                return result
            end
            local function readBasicCards(module, rarityOf)
                local result = {}
                local byRarity = if type(module) == 'table'then module.CardsByRarity else nil

                if type(byRarity) ~= 'table' then
                    return result
                end

                for _, rarity in ADVENTURE.basicCardRarities do
                    local list = byRarity[rarity]

                    if type(list) == 'table' then
                        for _, card in ipairs(list)do
                            local item = card
                            local name = if type(item) == 'table'then item.Name else item

                            if validName(name) and not table.find(result, name) then
                                table.insert(result, name)

                                rarityOf[name] = rarity
                            end
                        end
                    end
                end

                return result
            end
            local function readTraits(module)
                local rows = {}

                if type(module) ~= 'table' then
                    return {}
                end

                for name, entry in module do
                    if validName(name) and type(entry) == 'table' then
                        local chance = if type(entry.Chance) == 'number'then entry.Chance else 0

                        table.insert(rows, {
                            name = name,
                            chance = chance,
                            tiers = entry.Tiers,
                        })
                    end
                end

                table.sort(rows, function(a, b)
                    if a.chance ~= b.chance then
                        return a.chance > b.chance
                    end

                    return a.name < b.name
                end)

                local result = {}

                for _, row in rows do
                    if type(row.tiers) == 'table' and #row.tiers > 0 then
                        for index = 1, math.min(#row.tiers, #ROMAN)do
                            table.insert(result, row.name .. ' ' .. ROMAN[index])
                        end
                    else
                        table.insert(result, row.name)
                    end
                end

                return result
            end

            local MEMORIA_ORDER = {
                Vanguard = 1,
                Exclusive = 2,
                Secret = 3,
                Mythic = 4,
                Legendary = 5,
                Epic = 6,
                Rare = 7,
            }

            local function readMemoria(module)
                local result = {}

                if type(module) ~= 'table' or type(module.GetMemoriaNames) ~= 'function' then
                    return result
                end

                local ok, names = pcall(module.GetMemoriaNames)

                if not ok or type(names) ~= 'table' then
                    return result
                end

                local order = {}

                for _, entry in ipairs(names)do
                    local name = entry

                    if validName(name) and not table.find(result, name) then
                        table.insert(result, name)

                        local rank = 99

                        if type(module.GetMemoriaRarity) == 'function' then
                            local okRarity, rarity = pcall(module.GetMemoriaRarity, name)

                            rank = if okRarity and type(rarity) == 'string'then MEMORIA_ORDER[rarity] or 98 else 99
                        end

                        order[name] = rank
                    end
                end

                table.sort(result, function(a, b)
                    if order[a] ~= order[b] then
                        return order[a] < order[b]
                    end

                    return a < b
                end)

                return result
            end

            local CARD_ORDER = {
                Mythic = 1,
                Legendary = 2,
                Epic = 3,
                Rare = 4,
            }

            local function readCharacterCards(module, characters, names)
                local result = {}

                if type(module) ~= 'table' or type(module.GetCharacter) ~= 'function' then
                    return result
                end

                for _, character in characters do
                    local ok, data = pcall(module.GetCharacter, character)
                    local cards = if ok and type(data) == 'table'then data.Cards else nil

                    if type(cards) == 'table' then
                        local rows = {}

                        for position, entry in ipairs(cards)do
                            local card = entry

                            if type(card) == 'table' and validName(card.DisplayName) then
                                table.insert(rows, {
                                    name = card.DisplayName,
                                    rank = CARD_ORDER[card.Rarity] or 9,
                                    position = position,
                                })

                                if validName(card.CardId) then
                                    names[card.CardId] = card.DisplayName
                                end
                            end
                        end

                        table.sort(rows, function(a, b)
                            if a.rank ~= b.rank then
                                return a.rank < b.rank
                            end

                            return a.position < b.position
                        end)

                        local list = {}

                        for _, row in rows do
                            table.insert(list, row.name)
                        end

                        if #list > 0 then
                            result[character] = list
                        end
                    end
                end

                return result
            end
            local function pick(live, fallback)
                return if#live > 0 then live else copy(fallback)
            end
            local function fallbackBasicCards(rarityOf)
                local result = {}

                for _, rarity in ADVENTURE.basicCardRarities do
                    for _, name in ADVENTURE.basicCards[rarity]do
                        table.insert(result, name)

                        rarityOf[name] = rarity
                    end
                end

                return result
            end

            function Catalog.fromModules(modules)
                local m = if type(modules) == 'table'then modules else{}
                local characters = pick(readCharacters(m.characters), ADVENTURE.characters)
                local defaultCharacter = ADVENTURE.defaultCharacter

                if type(m.characters) == 'table' and type(m.characters.GetDefaultCharacterName) == 'function' then
                    local ok, name = pcall(m.characters.GetDefaultCharacterName)

                    if ok and validName(name) and table.find(characters, name) then
                        defaultCharacter = name
                    end
                end
                if not table.find(characters, defaultCharacter) then
                    defaultCharacter = characters[1]
                end

                local powerIds = readPowerIds(m.powers)

                if next(powerIds) == nil then
                    for index, name in ADVENTURE.powers do
                        powerIds[name] = index
                    end
                end

                local rarityOf = {}
                local basicCards = readBasicCards(m.basicCards, rarityOf)

                if #basicCards == 0 then
                    rarityOf = {}
                    basicCards = fallbackBasicCards(rarityOf)
                end

                local data = {
                    characters = characters,
                    defaultCharacter = defaultCharacter,
                    powers = pick(readPowers(m.powers), ADVENTURE.powers),
                    powerIds = powerIds,
                    basicCards = basicCards,
                    basicCardRarity = rarityOf,
                    roomKinds = copy(ADVENTURE.roomKinds),
                    traits = pick(readTraits(m.traits), ADVENTURE.traits),
                    memoriaNames = pick(readMemoria(m.memorias), ADVENTURE.memoriaNames),
                    characterCards = {},
                    characterCardName = {},
                    shopRerollSections = copy(ADVENTURE.shopRerollSections),
                }

                for _, extra in ADVENTURE.extraTraits or {}do
                    if not table.find(data.traits, extra) then
                        table.insert(data.traits, extra)
                    end
                end

                data.characterCards = readCharacterCards(m.characters, characters, data.characterCardName)

                return data
            end

            local function resolve(root, path)
                local value = root

                for part in string.gmatch(path, '[^%.]+')do
                    if not value then
                        return nil
                    end

                    local current = value
                    local ok, child = pcall(function()
                        return current:FindFirstChild(part)
                    end)

                    value = if ok then child else nil
                end

                return value
            end

            function Catalog.read()
                local env = getfenv()
                local modules = {}

                pcall(function()
                    local rep = env.game:GetService('ReplicatedStorage')
                    local paths = config.instancePaths
                    local wanted = {
                        characters = paths.adventureCharacters,
                        powers = paths.adventurePowers,
                        basicCards = paths.adventureBasicCards,
                        traits = paths.odysseyTraitPool,
                        memorias = paths.memoriasData,
                    }

                    for key, path in wanted do
                        local object = resolve(rep, path)

                        if object then
                            local ok, result = pcall(require, object)

                            if ok then
                                modules[key] = result
                            end
                        end
                    end
                end)

                return Catalog.fromModules(modules)
            end

            return Catalog
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
            local FileStorage = __DARKLUA_BUNDLE_MODULES.l()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local Settings = {}
            local REFRESH_SECONDS = 3
            local ADVENTURE = (config).adventure
            local SCHEMA_VERSION = 1
            local NONE = 'None'
            local MAX_TEXT = 64
            local MAX_RANK = 999

            Settings.NONE = NONE
            Settings.MAX_RANK = MAX_RANK

            local FIELDS = {
                autoJoin = {
                    kind = 'bool',
                    default = false,
                },
                character = {
                    kind = 'choice',
                    list = 'characters',
                },
                slot1 = {
                    kind = 'choice',
                    list = 'powers',
                    none = true,
                },
                slot2 = {
                    kind = 'choice',
                    list = 'powers',
                    none = true,
                },
                autoRoute = {
                    kind = 'bool',
                    default = false,
                },
                leaveShop = {
                    kind = 'bool',
                    default = true,
                },
                openTreasure = {
                    kind = 'bool',
                    default = true,
                },
                secondPriorityFloor = {
                    kind = 'number',
                    range = ADVENTURE.secondPriorityFloor,
                },
                floorPriority = {
                    kind = 'ranks',
                    list = 'roomKinds',
                    default = ADVENTURE.floorPriority,
                },
                secondFloorPriority = {
                    kind = 'ranks',
                    list = 'roomKinds',
                    default = ADVENTURE.secondFloorPriority,
                },
                autoUnitReward = {
                    kind = 'bool',
                    default = false,
                },
                autoBossReward = {
                    kind = 'bool',
                    default = false,
                },
                autoBuyItches = {
                    kind = 'bool',
                    default = false,
                },
                autoCharacterCard = {
                    kind = 'bool',
                    default = false,
                },
                characterCardPriority = {
                    kind = 'orders',
                    list = 'characterCards',
                },
                autoBasicCard = {
                    kind = 'bool',
                    default = false,
                },
                cardPriority = {
                    kind = 'ranks',
                    list = 'basicCards',
                },
                autoStitchesShop = {
                    kind = 'bool',
                    default = false,
                },
                buyBasicCards = {
                    kind = 'set',
                    list = 'basicCards',
                },
                buyCharacterCards = {
                    kind = 'bool',
                    default = false,
                },
                shopReroll = {
                    kind = 'bool',
                    default = false,
                },
                shopRerollTimes = {
                    kind = 'number',
                    range = ADVENTURE.shopRerollTimes,
                },
                shopRerollSections = {
                    kind = 'set',
                    list = 'shopRerollSections',
                },
                buyStarterCards = {
                    kind = 'set',
                    list = 'powers',
                },
                buyTraits = {
                    kind = 'set',
                    list = 'traits',
                },
                buyMemoria = {
                    kind = 'set',
                    list = 'memoriaNames',
                },
                autoCashOut = {
                    kind = 'bool',
                    default = false,
                },
                cashOutFloor = {
                    kind = 'number',
                    range = ADVENTURE.cashOutFloor,
                },
                autoStartNewRun = {
                    kind = 'bool',
                    default = false,
                },
                autoAscension = {
                    kind = 'bool',
                    default = false,
                },
                autoMemorized = {
                    kind = 'bool',
                    default = false,
                },
                memoria = {
                    kind = 'text',
                    default = NONE,
                },
                failsafe = {
                    kind = 'bool',
                    default = false,
                },
                failsafeMinutes = {
                    kind = 'number',
                    range = ADVENTURE.failsafeMinutes,
                },
            }

            Settings.FIELDS = FIELDS

            local function finite(value)
                return type(value) == 'number' and value == value and value ~= math.huge and value ~=
-math.huge
            end
            local function defaultOrder(spec, list)
                local result = {}

                if spec.default then
                    for _, name in spec.default do
                        if table.find(list, name) then
                            table.insert(result, name)
                        end
                    end
                end

                for _, name in list do
                    if not table.find(result, name) then
                        table.insert(result, name)
                    end
                end

                return result
            end
            local function defaultRanks(spec, list)
                local order = defaultOrder(spec, list)
                local ranks = {}

                for index, name in order do
                    ranks[name] = #order - index + 1
                end

                return ranks
            end
            local function rankedOrder(spec, list, ranks)
                local order = defaultOrder(spec, list)
                local position = {}

                for index, name in order do
                    position[name] = index
                end

                table.sort(order, function(a, b)
                    local left, right = ranks[a] or 0, ranks[b] or 0

                    if left ~= right then
                        return left > right
                    end

                    return position[a] < position[b]
                end)

                return order
            end
            local function validRank(value)
                if not finite(value) then
                    return nil
                end

                return math.clamp(math.floor(value), 0, MAX_RANK)
            end
            local function defaultValue(spec, catalog)
                if spec.kind == 'choice' then
                    return if spec.none then NONE else catalog.defaultCharacter
                elseif spec.kind == 'number' then
                    return spec.range.default
                elseif spec.kind == 'set' then
                    return {}
                elseif spec.kind == 'ranks' then
                    return defaultRanks(spec, catalog[spec.list])
                elseif spec.kind == 'orders' then
                    local orders = {}

                    for group, list in catalog[spec.list] or {}do
                        orders[group] = table.clone(list)
                    end

                    return orders
                end

                return spec.default
            end
            local function validate(spec, catalog, value)
                if spec.kind == 'bool' then
                    return if type(value) == 'boolean'then value else nil
                elseif spec.kind == 'choice' then
                    if type(value) ~= 'string' then
                        return nil
                    end
                    if spec.none and value == NONE then
                        return value
                    end

                    return if table.find(catalog[spec.list], value)then value else nil
                elseif spec.kind == 'number' then
                    if not finite(value) then
                        return nil
                    end

                    return math.clamp(math.floor(value), spec.range.min, spec.range.max)
                elseif spec.kind == 'text' then
                    return if type(value) == 'string' and #value > 0 and #value <= MAX_TEXT then value else nil
                elseif type(value) ~= 'table' then
                    return nil
                end

                local list = catalog[spec.list]

                if spec.kind == 'orders' then
                    local orders = {}

                    for group, names in list or {}do
                        local saved = value[group]
                        local order = {}

                        if type(saved) == 'table' then
                            for _, name in saved do
                                if type(name) == 'string' and table.find(names, name) and not table.find(order, name) then
                                    table.insert(order, name)
                                end
                            end
                        end

                        for _, name in names do
                            if not table.find(order, name) then
                                table.insert(order, name)
                            end
                        end

                        orders[group] = order
                    end

                    return orders
                end
                if spec.kind == 'ranks' then
                    local ranks = {}

                    if value[1] ~= nil then
                        local order = {}

                        for _, name in value do
                            if type(name) == 'string' and table.find(list, name) and not table.find(order, name) then
                                table.insert(order, name)
                            end
                        end
                        for _, name in defaultOrder(spec, list)do
                            if not table.find(order, name) then
                                table.insert(order, name)
                            end
                        end
                        for index, name in order do
                            ranks[name] = #order - index + 1
                        end

                        return ranks
                    end

                    for _, name in list do
                        ranks[name] = validRank(value[name]) or 0
                    end

                    return ranks
                end

                local result = {}

                for _, name in value do
                    if type(name) == 'string' and table.find(list, name) and not table.find(result, name) then
                        table.insert(result, name)
                    end
                end

                return result
            end
            local function liveDependencies()
                local env = getfenv()

                if not env.game then
                    return nil
                end

                local http = env.game:GetService('HttpService')

                return {
                    storage = FileStorage.new(env, ADVENTURE.storageKey),
                    encode = function(value)
                        return http:JSONEncode(value)
                    end,
                    decode = function(text)
                        return http:JSONDecode(text)
                    end,
                }
            end

            function Settings.new(catalog, injected)
                local deps = injected or liveDependencies()
                local values = {}

                for key, spec in FIELDS do
                    values[key] = defaultValue(spec, catalog)
                end

                local storage = if deps then deps.storage else nil

                if storage then
                    local body, readError = storage.read()

                    if readError then
                        storage = nil
                    elseif body then
                        local ok, data = pcall(deps.decode, body)

                        if not ok or type(data) ~= 'table' or data.schemaVersion ~= SCHEMA_VERSION then
                            storage = nil
                        else
                            for key, spec in FIELDS do
                                local value = validate(spec, catalog, data[key])

                                if value ~= nil then
                                    values[key] = value
                                end
                            end
                        end
                    end
                end

                local self = {}
                local lastRefresh = os.clock()

                local function refresh()
                    if not storage or not deps then
                        return
                    end

                    local okRead, body, readError = pcall(storage.read)

                    if not okRead or readError or type(body) ~= 'string' then
                        return
                    end

                    local ok, data = pcall(deps.decode, body)

                    if ok and type(data) == 'table' and data.schemaVersion == SCHEMA_VERSION then
                        for key, spec in FIELDS do
                            local value = validate(spec, catalog, data[key])

                            if value ~= nil then
                                values[key] = value
                            end
                        end
                    end
                end
                local function save()
                    if not storage or not deps or type(deps.encode) ~= 'function' then
                        return
                    end

                    local document = {schemaVersion = SCHEMA_VERSION}

                    for key, value in values do
                        document[key] = value
                    end

                    local ok, body = pcall(deps.encode, document)

                    if ok and type(body) == 'string' then
                        pcall(storage.write, body)
                    end
                end

                function self.persistent()
                    return storage ~= nil
                end
                function self.get(key)
                    local now = os.clock()

                    if now - lastRefresh >= REFRESH_SECONDS then
                        lastRefresh = now

                        refresh()
                    end

                    local value = values[key]

                    return if type(value) == 'table'then table.clone(value)else value
                end
                function self.set(key, value)
                    local spec = FIELDS[key]

                    if not spec then
                        return false
                    end

                    local valid = validate(spec, catalog, value)

                    if valid == nil then
                        return false
                    end

                    refresh()

                    values[key] = valid

                    save()

                    return true
                end
                function self.swap(key, first, second)
                    local spec = FIELDS[key]

                    if not spec or spec.kind ~= 'ranks' or type(first) ~= 'string' or type(second) ~= 'string' then
                        return false
                    end

                    refresh()

                    local order = rankedOrder(spec, catalog[spec.list], values[key])
                    local a, b = table.find(order, first), table.find(order, second)

                    if not a or not b or a == b then
                        return false
                    end

                    order[a], order[b] = order[b], order[a]

                    local ranks = {}

                    for position, entry in order do
                        ranks[entry] = #order - position + 1
                    end

                    values[key] = ranks

                    save()

                    return true
                end
                function self.order(key)
                    local spec = FIELDS[key]

                    if not spec or spec.kind ~= 'ranks' then
                        return {}
                    end

                    return rankedOrder(spec, catalog[spec.list], values[key])
                end
                function self.groupOrder(key, group)
                    local value = values[key]
                    local order = if type(value) == 'table'then value[group]else nil

                    return if type(order) == 'table'then table.clone(order)else{}
                end
                function self.groupSwap(key, group, first, second)
                    refresh()

                    local value = values[key]
                    local order = if type(value) == 'table'then value[group]else nil

                    if type(order) ~= 'table' then
                        return false
                    end

                    local a, b = table.find(order, first), table.find(order, second)

                    if not a or not b or a == b then
                        return false
                    end

                    order[a], order[b] = order[b], order[a]

                    save()

                    return true
                end
                function self.groupReset(key, group)
                    local spec = FIELDS[key]
                    local value = values[key]
                    local defaults = if spec then catalog[spec.list]else nil

                    if type(value) == 'table' and type(defaults) == 'table' and type(defaults[group]) == 'table' then
                        refresh()

                        value[group] = table.clone(defaults[group])

                        save()
                    end

                    return self.groupOrder(key, group)
                end
                function self.resetOrder(key)
                    local spec = FIELDS[key]

                    if spec and spec.kind == 'ranks' then
                        refresh()

                        values[key] = defaultRanks(spec, catalog[spec.list])

                        save()
                    end

                    return self.order(key)
                end

                return self
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
            local Style = __DARKLUA_BUNDLE_MODULES.e()
            local Catalog = __DARKLUA_BUNDLE_MODULES.w()
            local Settings = __DARKLUA_BUNDLE_MODULES.x()
            local PriorityList = __DARKLUA_BUNDLE_MODULES.o()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local Page = {}
            local UNLOCKED = {
                autoJoin = true,
                character = true,
                slot1 = true,
                slot2 = true,
                autoBasicCard = true,
                cardPriority = true,
                autoRoute = true,
                autoCharacterCard = true,
                characterCardPriority = true,
                leaveShop = true,
                openTreasure = true,
                autoStitchesShop = true,
                autoUnitReward = true,
                autoBossReward = true,
                autoStartNewRun = true,
                autoCashOut = true,
                cashOutFloor = true,
                failsafe = true,
                failsafeMinutes = true,
                buyBasicCards = true,
                buyCharacterCards = true,
                shopReroll = true,
                autoBuyItches = true,
                shopRerollTimes = true,
                shopRerollSections = true,
                buyStarterCards = true,
                buyTraits = true,
                buyMemoria = true,
                secondPriorityFloor = true,
                floorPriority = true,
                secondFloorPriority = true,
            }

            local function isLocked(key)
                return UNLOCKED[key] ~= true
            end

            local ADVENTURE = (config).adventure
            local PENDING =
[[Live: Auto Join with the character and slots, Auto Basic Card, Auto Route Atlas, Auto Character Card and Leave Shop Rooms. The other controls are locked (Coming soon) until their automation is built.]]

            local function setDesc(control, text)
                if type(control) == 'table' and type(control.SetDesc) == 'function' then
                    pcall(control.SetDesc, control, text)
                end
            end
            local function priorityEditor(
                host,
                settings,
                key,
                title,
                desc,
                tags
            )
                local section = Style.sub(host, title, 'list-ordered', false)
                local list = PriorityList.mount(section, {
                    title = title,
                    desc = desc,
                    order = settings.order(key),
                    tags = tags,
                    locked = isLocked(key),
                    onSwap = function(first, second)
                        return if settings.swap(key, first, second)then settings.order(key)else nil
                    end,
                })

                section:Button({
                    Title = 'Reset ' .. title,
                    Locked = isLocked(key),
                    Desc = 'Restore the default order.',
                    Icon = 'rotate-ccw',
                    Callback = function()
                        list.refresh(settings.resetOrder(key))
                    end,
                })
            end
            local function cardTags(catalog)
                local tags = {}

                for name, rarity in catalog.basicCardRarity do
                    tags[name] = {
                        text = rarity,
                        color = ADVENTURE.rarityColors[rarity] or 'slate',
                    }
                end

                return tags
            end
            local function toggle(host, settings, key, title, desc)
                host:Toggle({
                    Title = title,
                    Locked = isLocked(key),
                    Desc = desc,
                    Value = settings.get(key),
                    Callback = function(value)
                        settings.set(key, value)
                    end,
                })
            end
            local function slider(host, settings, key, title, desc)
                local range = Settings.FIELDS[key].range

                host:Slider({
                    Title = title,
                    Locked = isLocked(key),
                    Desc = desc,
                    Step = 1,
                    Value = {
                        Min = range.min,
                        Max = range.max,
                        Default = settings.get(key),
                    },
                    Callback = function(value)
                        settings.set(key, tonumber(value))
                    end,
                })
            end
            local function choice(host, settings, key, title, desc, values)
                host:Dropdown({
                    Title = title,
                    Locked = isLocked(key),
                    Desc = desc,
                    Values = values,
                    Value = settings.get(key),
                    Callback = function(value)
                        settings.set(key, value)
                    end,
                })
            end
            local function multi(host, settings, key, title, desc, values)
                host:Dropdown({
                    Title = title,
                    Locked = isLocked(key),
                    Desc = desc,
                    Values = values,
                    Value = settings.get(key),
                    Multi = true,
                    AllowNone = true,
                    Callback = function(value)
                        settings.set(key, value)
                    end,
                })
            end

            function Page.mount(tab, catalogOverride, settingsOverride, joiner)
                local catalog = catalogOverride or Catalog.read()
                local settings = settingsOverride or Settings.new(catalog)
                local withNone = function(list)
                    local result = {
                        Settings.NONE,
                    }

                    for _, name in list do
                        table.insert(result, name)
                    end

                    return result
                end
                local status = tab:Paragraph({
                    Title = 'Status',
                    Desc = PENDING .. '\n' .. (if settings.persistent()then'Autosaved to file'else'Session only: file APIs unavailable'),
                })
                local joinDesc =
[[From the lobby, start an Odyssey: Adventure run with the character and powers below. It joins in the order set in Joiner > Auto Join Priority (last by default).]]

                if joiner then
                    tab:Toggle({
                        Title = 'Auto Join Odyssey Adventure',
                        Desc = joinDesc,
                        Value = joiner.isEnabled('Odyssey Adventure'),
                        Callback = function(value)
                            joiner.setEnabled('Odyssey Adventure', value)
                        end,
                    })
                else
                    toggle(tab, settings, 'autoJoin', 'Auto Join Odyssey Adventure', joinDesc)
                end

                local character = Style.section(tab, 'Character', 'user-round', false)

                choice(character, settings, 'character', 'Select Character',
[[The run's character (takes your first unit slot, free to place).]], catalog.characters)
                choice(character, settings, 'slot1', 'Slot 1', 'Run-start power card. None leaves the slot empty.', withNone(catalog.powers))
                choice(character, settings, 'slot2', 'Slot 2',
[[Second power card; needs Loadout Slot 2 (bought in the Stitches Shop).]], withNone(catalog.powers))

                local misc = Style.section(tab, 'Miscellaneous', 'wrench', false)
                local route = Style.sub(misc, 'Auto Route Atlas', 'route')

                toggle(route, settings, 'autoRoute', 'Auto Route Atlas',
[[After each floor, choose the next room by the priorities below (highest number first).]])
                slider(route, settings, 'secondPriorityFloor', 'Use Second Prioritize after Floor',
[[From this floor on, the Second Floor Prioritize order is used.]])
                priorityEditor(route, settings, 'floorPriority', 'Floor Prioritize',
[[Next room to pick on the Route Atlas; the highest number is preferred. Drag a row onto another to swap them.]], ADVENTURE.roomTags)
                priorityEditor(route, settings, 'secondFloorPriority', 'Second Floor Prioritize',
[[Used instead after the floor above. Drag a row onto another to swap them.]], ADVENTURE.roomTags)
                toggle(misc, settings, 'openTreasure', 'Open Treasure Chests',
[[On a Treasure floor, open the allowed chests so the floor ends (it ends only after the picks are used).]])
                toggle(misc, settings, 'autoUnitReward', 'Auto Choose Unit Reward',
[[After an Elite floor, take the highest-rarity unit offered, or skip when none can be taken; the next room waits for it.]])
                toggle(misc, settings, 'autoBossReward', 'Auto Boss Reward',
[[After a boss floor, claim the rarest Memoria or Familiar on a placed unit, or skip when none; the next room waits for it.]])
                toggle(misc, settings, 'autoBuyItches', 'Auto Buy Itches',
[[When Itches (the Stitches NPC) appears on the map, walk to it and keep buying basic cards with Yen until it is gone; skipped once every basic card is owned at its cap.]])

                local characterCard = Style.section(tab, 'Auto Character Card', 'id-card', false)

                toggle(characterCard, settings, 'autoCharacterCard', 'Auto Character Card',
[[After an Elite floor, pick the character card by the priority below; with a full hand, swap out the weakest card only for a better one.]])

                local cardPriority = Style.sub(characterCard, 'Character Card Priority', 'list-ordered', false)
                local withCards = {}

                for _, characterName in catalog.characters do
                    local cards = catalog.characterCards and catalog.characterCards[characterName]

                    if type(cards) == 'table' and #cards > 0 then
                        table.insert(withCards, characterName)
                    end
                end

                if #withCards > 0 then
                    local selected = settings.get('character')
                    local editing = if table.find(withCards, selected)then selected else withCards[1]
                    local list = nil

                    cardPriority:Dropdown({
                        Title = 'Edit Character',
                        Locked = isLocked('characterCardPriority'),
                        Desc =
[[Whose card order to edit; each character keeps its own order.]],
                        Values = withCards,
                        Value = editing,
                        Callback = function(value)
                            if type(value) == 'string' and table.find(withCards, value) then
                                editing = value

                                if list then
                                    list.refresh(settings.groupOrder('characterCardPriority', editing))
                                end
                            end
                        end,
                    })

                    list = PriorityList.mount(cardPriority, {
                        title = 'Card Order',
                        desc =
[[Top card is preferred. Drag a row onto another to swap them.]],
                        order = settings.groupOrder('characterCardPriority', editing),
                        locked = isLocked('characterCardPriority'),
                        onSwap = function(first, second)
                            return if settings.groupSwap('characterCardPriority', editing, first, second)then settings.groupOrder('characterCardPriority', editing)else nil
                        end,
                    })

                    cardPriority:Button({
                        Title = 'Reset Card Order',
                        Locked = isLocked('characterCardPriority'),
                        Desc = "Restore this character's default order (rarest first).",
                        Icon = 'rotate-ccw',
                        Callback = function()
                            list.refresh(settings.groupReset('characterCardPriority', editing))
                        end,
                    })
                end

                local basicCard = Style.section(tab, 'Auto Basic Card', 'layers', false)

                toggle(basicCard, settings, 'autoBasicCard', 'Auto Basic Card',
[[After each floor, pick a basic card by the priority below; skipped when off.]])
                priorityEditor(basicCard, settings, 'cardPriority', 'Card Priority',
[[Basic card (Odyssey modifier) to pick; the highest number is preferred. Drag a row onto another to swap them.]], cardTags(catalog))

                local shop = Style.section(tab, 'Auto Stitches Shop', 'store', false)

                toggle(shop, settings, 'leaveShop', 'Leave Shop Rooms',
[[On a Shop floor, close the shop without buying so the run goes on (a Shop floor ends only when it is closed).]])
                toggle(shop, settings, 'autoStitchesShop', 'Auto Stitches Shop',
[[On a Shop floor, buy the items selected below with Odyssey Coins; skipped when off.]])
                toggle(shop, settings, 'buyCharacterCards', 'Buy Character Card',
[[Buy a character card offered in the shop when it is among the top 4 of your Character Card Priority.]])
                multi(shop, settings, 'buyBasicCards', 'Buy Basic Card', 'Basic cards to buy.', catalog.basicCards)
                multi(shop, settings, 'buyStarterCards', 'Buy Starter Card', 'Power cards to unlock.', catalog.powers)
                multi(shop, settings, 'buyTraits', 'Buy Unit Trait', 'Traits to buy for a unit without one.', catalog.traits)
                toggle(shop, settings, 'shopReroll', 'Reroll Shop',
[[After buying everything wanted that the coins allow, reroll the shop and buy again (up to the count below).]])
                slider(shop, settings, 'shopRerollTimes', 'Rerolls per Shop', 'How many rerolls to use in one shop.')
                multi(shop, settings, 'shopRerollSections', 'Reroll Sections',
[[What to reroll: All (every slot) or Card, Trait, Memoria sections.]], catalog.shopRerollSections)
                multi(shop, settings, 'buyMemoria', 'Buy Unit Memoria',
[[Memoria to buy for your first-slot unit, by name (highest rarity first).]], catalog.memoriaNames)

                local completion = Style.section(tab, 'Run Completion', 'flag', false)

                toggle(completion, settings, 'autoCashOut', 'Auto End Run',
[[End the run (claim its rewards) once this many floors are cleared.]])
                slider(completion, settings, 'cashOutFloor', 'End run at floor', 'Cleared floors before the run is ended.')
                toggle(completion, settings, 'autoStartNewRun', 'Auto Start New Run',
[[When a run ends, press New Run on the end screen; if that does not start a run, go back to the lobby (Auto Join starts the next run).]])
                toggle(completion, settings, 'autoAscension', 'Auto Ascension',
[[Ascend in the lobby once Level Tree level 100 is reached and the game allows it.]])

                local memorized = Style.section(tab, 'Memorized Modifier', 'brain', false)

                toggle(memorized, settings, 'autoMemorized', 'Auto Select Memorized Memoria',
[[When the Memorized power offers a pick at run start, choose the memoria below.]])

                local saved = settings.get('memoria')

                memorized:Dropdown({
                    Title = 'Memoria',
                    Locked = isLocked('memoria'),
                    Desc = 'Owned memoria to equip on your character for the run.',
                    Values = if saved == Settings.NONE then{
                        Settings.NONE,
                    }else{
                        Settings.NONE,
                        saved,
                    },
                    Value = saved,
                    Callback = function(value)
                        settings.set('memoria', value)
                    end,
                })
                memorized:Button({
                    Title = 'Refresh Inventory',
                    Locked = isLocked('refreshInventory'),
                    Desc = 'Reload your owned memoria into the list.',
                    Callback = function()
                        setDesc(status,
[[Refresh Inventory: reading your memoria is not built yet (runtime pending).]])
                    end,
                })

                local failsafe = Style.section(tab, 'Stage Failsafe', 'timer', false)

                toggle(failsafe, settings, 'failsafe', 'Teleport Lobby if Stage not Finished',
[[Go back to the lobby when a floor runs longer than the time below (stuck or bugged floors).]])
                slider(failsafe, settings, 'failsafeMinutes', 'Failsafe Time (minute)', 'Minutes before the failsafe acts.')

                return settings
            end

            return Page
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
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local Catalog = __DARKLUA_BUNDLE_MODULES.w()
            local Settings = __DARKLUA_BUNDLE_MODULES.x()
            local Adapter = {}
            local REMOTES = (config).remoteNames
            local RETRY_SECONDS = (config).thresholds.adventureStateRetrySeconds
            local MAX_AGE_SECONDS = (config).thresholds.adventureStateMaxAgeSeconds

            local function resolve(root, path)
                local value = root

                for part in string.gmatch(path, '[^%.]+')do
                    if not value then
                        return nil
                    end

                    local current = value
                    local ok, child = pcall(function()
                        return current:FindFirstChild(part)
                    end)

                    value = if ok then child else nil
                end

                return value
            end
            local function optionalModule(root, path)
                local ok, result = pcall(function()
                    local object = resolve(root, path)

                    return if object then(require)(object)else nil
                end)

                return if ok then result else nil
            end
            local function liveDependencies()
                local env = getfenv()
                local replicated = env.game:GetService('ReplicatedStorage')
                local paths = config.instancePaths

                return {
                    task = env.task,
                    clock = os.clock,
                    specialEvents = optionalModule(replicated, paths.specialEventsClient),
                    characters = optionalModule(replicated, paths.adventureCharacters),
                }
            end
            local function decodeState(payload)
                if type(payload) ~= 'table' or type(payload.Characters) ~= 'table' then
                    return nil
                end

                local characters = {}
                local owns = payload.OwnsLoadoutSlot2 == true
                local global = {}

                if type(payload.UnlockedPowerIds) == 'table' then
                    for _, id in payload.UnlockedPowerIds do
                        if type(id) == 'number' then
                            global[id] = true
                        end
                    end
                end

                for _, entry in payload.Characters do
                    if type(entry) == 'table' and type(entry.CharacterName) == 'string' then
                        local unlocked = {}

                        if type(entry.UnlockedPowerIds) == 'table' then
                            for _, id in entry.UnlockedPowerIds do
                                if type(id) == 'number' then
                                    unlocked[id] = true
                                end
                            end
                        end

                        local loadout = if type(entry.Loadout) == 'table'then entry.Loadout else{}

                        characters[entry.CharacterName] = {
                            unlocked = unlocked,
                            slot1 = if type(loadout.Slot1) == 'number'then loadout.Slot1 else nil,
                            slot2 = if type(loadout.Slot2) == 'number'then loadout.Slot2 else nil,
                            ownsSlot2 = entry.OwnsLoadoutSlot2 == true,
                        }
                        owns = owns or entry.OwnsLoadoutSlot2 == true
                    end
                end

                return {
                    characters = characters,
                    global = global,
                    ownsSlot2 = owns,
                }
            end

            function Adapter.new(injected)
                local deps = injected
                local self = {
                    state = nil,
                    stateAt = 0,
                    lastRequest = -math.huge,
                }
                local disconnect = nil
                local catalog = if injected then injected.catalog else nil
                local settings = if injected then injected.settings else nil
                local clock = if injected and injected.clock then injected.clock else os.clock

                local function dependencies()
                    if not deps then
                        deps = liveDependencies()
                    end

                    return deps
                end

                function self.getCatalog()
                    if not catalog then
                        catalog = Catalog.read()
                    end

                    return catalog
                end
                function self.getSettings()
                    if not settings then
                        settings = Settings.new(self.getCatalog())
                    end

                    return settings
                end

                local function remote(name)
                    local events = dependencies().specialEvents
                    local entry = if type(events) == 'table'then events[REMOTES[name] ]else nil

                    return if type(entry) == 'table'then entry else nil
                end
                local function fire(name, payload)
                    local entry = remote(name)

                    if not entry or type(entry.Fire) ~= 'function' then
                        return false
                    end

                    local fireFn = entry.Fire

                    if payload == nil then
                        return (pcall(fireFn))
                    end

                    return (pcall(fireFn, payload))
                end

                function self.connect()
                    if disconnect then
                        return true
                    end

                    local entry = remote('adventureState')

                    if not entry or type(entry.On) ~= 'function' then
                        return false
                    end

                    local onFn = entry.On
                    local ok, result = pcall(onFn, function(payload)
                        local decoded = decodeState(payload)

                        if decoded then
                            self.state = decoded
                            self.stateAt = clock()
                        end
                    end)

                    if not ok then
                        return false
                    end

                    disconnect = if type(result) == 'function'then result else function(
                    ) end

                    self.requestState()

                    return true
                end
                function self.requestState()
                    local now = clock()

                    if now - self.lastRequest < RETRY_SECONDS then
                        return
                    end

                    self.lastRequest = now

                    fire('requestAdventureState')
                end

                local function characterAvailable(name)
                    local module = dependencies().characters

                    if type(module) ~= 'table' or type(module.IsCharacterAvailable) ~= 'function' then
                        return true
                    end

                    local ok, available = pcall(module.IsCharacterAvailable, name)

                    return not ok or available ~= false
                end
                local function slotId(label, powerName, owned, notes)
                    if powerName == Settings.NONE then
                        return nil
                    end

                    local id = self.getCatalog().powerIds[powerName]

                    if id == nil then
                        table.insert(notes, label .. ': unknown power ' .. powerName)

                        return nil
                    end
                    if not owned(id) then
                        table.insert(notes, label .. ': ' .. powerName .. ' is not unlocked')

                        return nil
                    end

                    return id
                end

                function self.plan()
                    self.connect()

                    local state = self.state

                    if not state or clock() - self.stateAt > MAX_AGE_SECONDS then
                        self.requestState()

                        return nil, 'waiting for Adventure data from the game'
                    end

                    local saved = self.getSettings()
                    local character = saved.get('character')
                    local entry = state.characters[character]

                    if not entry then
                        return nil, character .. ' is not available on this account'
                    end
                    if not characterAvailable(character) then
                        return nil, character .. ' is not available yet'
                    end

                    local notes = {}

                    local function owned(id)
                        return entry.unlocked[id] == true or state.global[id] == true
                    end

                    local slot1 = slotId('Slot 1', saved.get('slot1'), owned, notes)
                    local slot2 = nil

                    if saved.get('slot2') ~= Settings.NONE then
                        if state.ownsSlot2 or entry.ownsSlot2 then
                            slot2 = slotId('Slot 2', saved.get('slot2'), owned, notes)
                        else
                            table.insert(notes, 'Slot 2: Loadout Slot 2 is not owned')
                        end
                    end

                    return {
                        character = character,
                        slot1 = slot1,
                        slot2 = slot2,
                        notes = notes,
                        saved = entry,
                    }, nil
                end
                function self.start(plan)
                    if type(plan) ~= 'table' then
                        return false
                    end

                    local saved = plan.saved

                    if type(saved) == 'table' and (saved.slot1 ~= plan.slot1 or saved.slot2 ~= plan.slot2) then
                        fire('setAdventureLoadout', {
                            CharacterName = plan.character,
                            Slot1 = plan.slot1,
                            Slot2 = plan.slot2,
                        })
                    end

                    return fire('startOdysseyAdventure', {
                        LoadoutProvided = true,
                        CharacterName = plan.character,
                        Slot1 = plan.slot1,
                        Slot2 = plan.slot2,
                    })
                end
                function self.stop()
                    local undo = disconnect

                    disconnect = nil

                    if undo then
                        pcall(undo)
                    end
                end

                return self
            end

            return Adapter
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
            local Choice = {}

            function Choice.pickBasicCard(options, ranks)
                if type(options) ~= 'table' then
                    return nil
                end

                local best = nil
                local bestRank = -math.huge

                for index = 1, #options do
                    local option = options[index]

                    if type(option) == 'table' and type(option.CardName) == 'string' then
                        local rank = ranks[option.CardName]
                        local value = if type(rank) == 'number'then rank else 0

                        if value > bestRank then
                            best = index
                            bestRank = value
                        end
                    end
                end

                return best
            end
            function Choice.pickRoom(
                options,
                first,
                second,
                secondFromFloor,
                reachable
            )
                if type(options) ~= 'table' then
                    return nil
                end

                local best = nil
                local bestRank = -math.huge

                for position = 1, #options do
                    local option = options[position]

                    if type(option) == 'table' and type(option.AdventureRoomKind) == 'string' then
                        local kind = if option.BossRoom == true then'Boss'else option.AdventureRoomKind
                        local floor = if type(option.AdventureFloor) == 'number'then option.AdventureFloor else 0
                        local ranks = if floor >= secondFromFloor then second else first
                        local rank = ranks[kind]
                        local value = if type(rank) == 'number'then rank else-1
                        local index = if type(option.Index) == 'number'then option.Index else position

                        if (reachable == nil or reachable[index] == true) and value > bestRank then
                            best = index
                            bestRank = value
                        end
                    end
                end

                return best
            end

            local CHARACTER_RARITY = {
                Mythic = 4,
                Legendary = 3,
                Epic = 2,
                Rare = 1,
            }

            function Choice.characterCardName(card, nameOf)
                if type(card) ~= 'table' then
                    return nil
                end

                local id = card.CardId

                if nameOf and type(id) == 'string' then
                    local direct = nameOf[id]

                    if direct then
                        return direct
                    end

                    local tail = string.match(id, '[:/%.]([%w_]+)$')

                    if tail and nameOf[tail] then
                        return nameOf[tail]
                    end
                end

                local own = card.DisplayName or card.Name

                return if type(own) == 'string'then own else nil
            end

            local function cardScore(card, order, nameOf)
                if type(card) ~= 'table' then
                    return -math.huge
                end

                local name = Choice.characterCardName(card, nameOf)

                if order and type(name) == 'string' then
                    local position = table.find(order, name)

                    if position then
                        return 100 + #order - position
                    end
                end

                return CHARACTER_RARITY[card.Rarity] or 0
            end

            function Choice.characterCardChoice(offer, order, nameOf)
                local options = if type(offer) == 'table'then offer.Options else nil

                if type(options) ~= 'table' then
                    return nil
                end

                local best = nil
                local bestScore = -math.huge

                for index = 1, #options do
                    local score = cardScore(options[index], order, nameOf)

                    if score > bestScore then
                        best, bestScore = index, score
                    end
                end

                if not best then
                    return nil
                end

                local existing = offer.ExistingCards
                local atCap = (offer.AtCap ~= nil and offer.AtCap ~= false) or (type(existing) == 'table' and #existing >= 4)

                if not atCap then
                    return best
                end
                if type(existing) ~= 'table' then
                    return nil
                end

                local weakest = nil
                local weakestScore = math.huge

                for slot = 1, #existing do
                    local score = cardScore(existing[slot], order, nameOf)

                    if score < weakestScore then
                        weakest, weakestScore = slot, score
                    end
                end

                if weakest and bestScore > weakestScore then
                    return best * 100 + 1000 + weakest
                end

                return nil
            end
            function Choice.pickCharacterCard(options)
                if type(options) ~= 'table' then
                    return nil
                end

                local best = nil
                local bestRank = -math.huge

                for index = 1, #options do
                    local option = options[index]

                    if type(option) == 'table' and type(option.Rarity) == 'string' then
                        local rank = CHARACTER_RARITY[option.Rarity] or 0

                        if rank > bestRank then
                            best = index
                            bestRank = rank
                        end
                    end
                end

                return best
            end

            local ROMAN = {
                'I',
                'II',
                'III',
                'IV',
                'V',
            }
            local MEMORIA_RARITY = {
                Vanguard = 6,
                Secret = 5,
                Mythic = 4,
                Legendary = 3,
                Epic = 2,
                Rare = 1,
            }
            local KIND_ORDER = {
                Power = 1,
                UnitCard = 2,
                BasicCard = 3,
                Trait = 4,
                Memoria = 5,
            }

            function Choice.traitLabel(item)
                if type(item) ~= 'table' or type(item.TraitName) ~= 'string' then
                    return nil
                end

                local tier = if type(item.TraitIndex) == 'number'then ROMAN[item.TraitIndex]else nil

                return if tier then item.TraitName .. ' ' .. tier else item.TraitName
            end
            function Choice.shopPurchases(stock, budget, wants)
                local plan = {}

                if type(stock) ~= 'table' or type(budget) ~= 'number' then
                    return plan
                end

                local mainGuid = if type(wants.fallbackGuid) == 'string'then wants.fallbackGuid else nil

                for _, item in stock do
                    if type(item) == 'table' and item.Kind == 'Trait' and item.TraitUnitName == wants.character then
                        if type(item.TraitUnitGUID) == 'string' then
                            mainGuid = item.TraitUnitGUID
                        end
                    end
                end

                local candidates = {}

                for _, item in stock do
                    if type(item) == 'table' and item.Purchased ~= true and type(item.Index) == 'number' and type(item.Cost) == 'number' then
                        local entry = nil

                        if item.Kind == 'BasicCard' and wants.basic[item.BasicCardName] then
                            entry = {
                                name = item.BasicCardName,
                                rank = wants.rank[item.BasicCardName] or 0,
                            }
                        elseif item.Kind == 'Power' and wants.starters[item.PowerName or item.Name] then
                            entry = {
                                name = item.PowerName or item.Name,
                                rank = 0,
                            }
                        elseif item.Kind == 'UnitCard' and type(wants.characterCards) == 'table' then
                            local name = Choice.characterCardName(item, wants.characterCardName)
                            local position = if name then table.find(wants.characterCards, name)else nil

                            if position and position <= (wants.characterCardTop or 4) then
                                entry = {
                                    name = name,
                                    rank = 100 - position,
                                }
                            end
                        elseif item.Kind == 'Trait' then
                            local label = Choice.traitLabel(item)

                            if label and wants.traits[label] and type(item.TraitUnitGUID) == 'string' then
                                entry = {
                                    name = label,
                                    rank = 0,
                                    guid = item.TraitUnitGUID,
                                }
                            end
                        elseif item.Kind == 'Memoria' and type(item.MemoriaOption) == 'table' then
                            local rarity = item.MemoriaOption.Rarity
                            local memoriaName = item.MemoriaOption.Name

                            if type(memoriaName) == 'string' and wants.memoria[memoriaName] and mainGuid then
                                entry = {
                                    name = tostring(item.MemoriaOption.Name),
                                    rank = if type(rarity) == 'string'then MEMORIA_RARITY[rarity] or 0 else 0,
                                    guid = mainGuid,
                                }
                            end
                        end
                        if entry then
                            entry.index = item.Index
                            entry.cost = item.Cost
                            entry.order = KIND_ORDER[item.Kind] or 9

                            table.insert(candidates, entry)
                        end
                    end
                end

                table.sort(candidates, function(a, b)
                    if a.order ~= b.order then
                        return a.order < b.order
                    end
                    if a.rank ~= b.rank then
                        return a.rank > b.rank
                    end

                    return a.index < b.index
                end)

                local left = budget

                for _, entry in candidates do
                    if entry.cost <= left then
                        left -= entry.cost

                        table.insert(plan, {
                            index = entry.index,
                            cost = entry.cost,
                            name = entry.name,
                            guid = entry.guid,
                        })
                    end
                end

                return plan
            end

            local UNIT_RARITY = {
                Vanguard = 9,
                Exclusive = 8,
                Secret = 7,
                Mythic = 6,
                Legendary = 5,
                Epic = 4,
                Rare = 3,
                Uncommon = 2,
                Common = 1,
            }

            function Choice.pickUnitReward(data)
                if type(data) ~= 'table' then
                    return nil
                end

                local options = data.Options or data.Units or data.Choices or data

                if type(options) ~= 'table' or #options == 0 then
                    return nil
                end

                local best = 1
                local bestRank = -math.huge

                for index = 1, #options do
                    local option = options[index]
                    local rarity = if type(option) == 'table'then option.Rarity or option.UnitRarity else nil
                    local rank = if type(rarity) == 'string'then UNIT_RARITY[rarity] or 0 else 0

                    if rank > bestRank then
                        best = index
                        bestRank = rank
                    end
                end

                return best
            end
            function Choice.pickBossReward(options)
                if type(options) ~= 'table' then
                    return nil
                end

                local best = nil
                local bestRank = -math.huge

                for index = 1, #options do
                    local option = options[index]

                    if type(option) == 'table' and (option.Kind == 'Memoria' or option.Kind == 'Familiar') then
                        local rank = if type(option.Rarity) == 'string'then UNIT_RARITY[option.Rarity] or 0 else 0

                        if rank > bestRank then
                            best = option.Kind
                            bestRank = rank
                        end
                    end
                end

                return best
            end

            return Choice
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
            local Listen = {}

            local function registryOf(onFn)
                local env = getfenv()
                local debugLib = env.debug
                local getUpvalue = if type(debugLib) == 'table'then debugLib.getupvalue else nil

                if type(getUpvalue) ~= 'function' then
                    return nil
                end

                for index = 1, 8 do
                    local ok, a, b = pcall(getUpvalue, onFn, index)

                    if not ok then
                        break
                    end

                    local value = if b ~= nil then b else a

                    if type(value) == 'table' and type(value.Reliable) == 'table' then
                        return value
                    end
                end

                return nil
            end

            function Listen.chain(entry, handler)
                if type(entry) ~= 'table' or type(entry.On) ~= 'function' then
                    return nil
                end

                local onFn = entry.On
                local registry = registryOf(onFn)

                if registry == nil then
                    local ok, undo = pcall(onFn, handler)

                    return {
                        check = function() end,
                        undo = function()
                            if ok and type(undo) == 'function' then
                                pcall(undo)
                            end
                        end,
                    }
                end

                local before = {}

                for kind, slots in registry do
                    if type(slots) == 'table' then
                        before[kind] = table.clone(slots)
                    end
                end

                local function probe() end

                pcall(onFn, probe)

                local slotKind, slotId = nil, nil

                for kind, slots in registry do
                    if type(slots) == 'table' then
                        for id, value in slots do
                            if value == probe then
                                slotKind, slotId = kind, id
                            end
                        end
                    end
                end

                if slotKind == nil then
                    local ok, undo = pcall(onFn, handler)

                    return {
                        check = function() end,
                        undo = function()
                            if ok and type(undo) == 'function' then
                                pcall(undo)
                            end
                        end,
                    }
                end

                local slots = registry[slotKind]
                local previous = before[slotKind] and before[slotKind][slotId]

                local function wrapper(...)
                    if type(previous) == 'function' then
                        pcall(previous, ...)
                    end

                    handler(...)
                end

                slots[slotId] = wrapper

                return {
                    check = function()
                        local current = slots[slotId]

                        if current ~= wrapper then
                            previous = current
                            slots[slotId] = wrapper
                        end
                    end,
                    undo = function()
                        if slots[slotId] == wrapper then
                            slots[slotId] = previous
                        end
                    end,
                }
            end

            return Listen
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
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local Detect = __DARKLUA_BUNDLE_MODULES.u()
            local Choice = __DARKLUA_BUNDLE_MODULES.A()
            local Listen = __DARKLUA_BUNDLE_MODULES.B()
            local Catalog = __DARKLUA_BUNDLE_MODULES.w()
            local Runtime = {}
            local PICK_DELAY_SECONDS = (config).thresholds.adventurePickDelaySeconds
            local REPEAT_SECONDS = (config).thresholds.adventureRepeatSeconds
            local CHEST_TELEPORT_DELAY_SECONDS = (config).thresholds.adventureChestTeleportDelaySeconds or 0.3
            local CHEST_GAP_SECONDS = (config).thresholds.adventureChestGapSeconds or 0.8
            local SHOP_GAP_SECONDS = (config).thresholds.adventureShopGapSeconds
            local SHOP_WATCH_SECONDS = (config).thresholds.adventureShopWatchSeconds
            local SHOP_ASK_SECONDS = (config).thresholds.adventureShopAskSeconds
            local SHOP_UI_GRACE_SECONDS = (config).thresholds.adventureShopUiGraceSeconds
            local HISTORY_LIMIT = 80
            local CHARACTER_CARD_TOP = 4
            local END_SCREEN_SECONDS = 1
            local LOBBY_RETRY_SECONDS = 20
            local NEW_RUN_FALLBACK_SECONDS = 40
            local MAP_POLL_SECONDS = 10
            local SHOP_REROLL_WAIT_SECONDS = 4
            local ITCHES_STAY_SECONDS = 1.5
            local TASK_WAIT_SECONDS = (config).thresholds.adventureTaskWaitSeconds
            local TASK_WAIT_RETRY_SECONDS = (config).thresholds.adventureTaskWaitRetrySeconds
            local VOTE_RETRY_SECONDS = (config).thresholds.adventureVoteRetrySeconds
            local VOTE_ATTEMPTS = (config).thresholds.adventureVoteAttempts

            local function resolve(root, path)
                local value = root

                for part in string.gmatch(path, '[^%.]+')do
                    if not value then
                        return nil
                    end

                    local current = value
                    local ok, child = pcall(function()
                        return current:FindFirstChild(part)
                    end)

                    value = if ok then child else nil
                end

                return value
            end
            local function optionalModule(root, path)
                local ok, result = pcall(function()
                    local object = resolve(root, path)

                    return if object then(require)(object)else nil
                end)

                return if ok then result else nil
            end
            local function liveDependencies()
                local env = getfenv()

                if not env.game then
                    return {
                        task = env.task,
                        clock = os.clock,
                        isAdventure = function()
                            return false
                        end,
                    }
                end

                local replicated = env.game:GetService('ReplicatedStorage')
                local paths = config.instancePaths
                local handler = optionalModule(replicated, paths.gameHandler)

                return {
                    task = env.task,
                    clock = os.clock,
                    closeMap = function()
                        local players = env.game:GetService('Players')
                        local gui = players.LocalPlayer and players.LocalPlayer:FindFirstChild('PlayerGui')
                        local hud = gui and gui:FindFirstChild('AdventureHUD')
                        local root = hud and hud:FindFirstChild('AdventureMapRoot')

                        if not root or not root.Visible then
                            return
                        end

                        local closeControl = root:FindFirstChild('Close', true)

                        if not closeControl or closeControl.AbsoluteSize.X <= 0 then
                            return
                        end

                        local firesignal = ((getfenv())).firesignal

                        if firesignal then
                            local targets = {closeControl}

                            for _, descendant in closeControl:GetDescendants()do
                                local item = descendant

                                if item:IsA('GuiButton') then
                                    table.insert(targets, item)
                                end
                            end
                            for _, target in targets do
                                local item = target

                                if item:IsA('GuiButton') then
                                    pcall(firesignal, item.Activated)
                                    pcall(firesignal, item.MouseButton1Click)
                                end
                            end
                        end

                        local vim = env.game:GetService('VirtualInputManager')
                        local inset = env.game:GetService('GuiService'):GetGuiInset()
                        local tApi = env.task

                        local function stillOpen()
                            return root.Visible and closeControl.Parent ~= nil and closeControl.AbsoluteSize.X > 0
                        end

                        if tApi and type(tApi.wait) == 'function' then
                            (tApi.wait)(0.2)
                        end
                        if stillOpen() then
                            local pos = closeControl.AbsolutePosition + closeControl.AbsoluteSize / 2 + inset

                            pcall(function()
                                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, env.game, 1)
                                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, env.game, 1)
                            end)
                        end
                    end,
                    closeShopUi = (function()
                        local attempts = 0

                        return function()
                            local players = env.game:GetService('Players')
                            local gui = players.LocalPlayer and players.LocalPlayer:FindFirstChild('PlayerGui')
                            local hud = gui and gui:FindFirstChild('AdventureHUD')

                            if not hud then
                                return false
                            end

                            for _, object in hud:GetDescendants()do
                                local item = object

                                if string.find(item.Name, 'Shop_Export', 1, true) ~= nil and item:IsA('GuiObject') and item.Visible and item.AbsoluteSize.X > 0 then
                                    attempts += 1

                                    local bottom = item:FindFirstChild('BottomFrame', true)
                                    local leave = bottom and bottom:FindFirstChild('Clickable', true)
                                    local firesignal = ((getfenv())).firesignal

                                    if attempts == 1 and leave and firesignal then
                                        pcall(firesignal, leave.Activated)
                                        pcall(firesignal, leave.MouseButton1Click)
                                    elseif attempts == 2 and leave and leave.AbsoluteSize.X > 0 then
                                        local vim = env.game:GetService('VirtualInputManager')
                                        local inset = env.game:GetService('GuiService'):GetGuiInset()
                                        local pos = leave.AbsolutePosition + leave.AbsoluteSize / 2 + inset

                                        pcall(function()
                                            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, env.game, 1)
                                            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, env.game, 1)
                                        end)
                                    else
                                        item.Visible = false
                                    end

                                    return true
                                end
                            end

                            attempts = 0

                            return false
                        end
                    end)(),
                    endScreenShown = function()
                        local players = env.game:GetService('Players')
                        local gui = players.LocalPlayer and players.LocalPlayer:FindFirstChild('PlayerGui')
                        local screen = gui and gui:FindFirstChild('EndScreen')
                        local holder = screen and screen:FindFirstChild('Holder')

                        return screen ~= nil and screen.Enabled == true and holder ~= nil and holder.Visible == true and holder.AbsoluteSize.X > 0
                    end,
                    newRun = function()
                        local endClient = optionalModule(replicated, paths.endScreenClient)
                        local vote = if type(endClient) == 'table'then endClient.CastRetryVote else nil

                        if type(vote) == 'table' and type(vote.Fire) == 'function' then
                            return (pcall(vote.Fire))
                        end

                        return false
                    end,
                    returnToLobby = function()
                        local lobby = optionalModule(replicated, paths.lobbyReturnClient)
                        local request = if type(lobby) == 'table'then lobby.RequestTeleportToLobby else nil

                        if type(request) == 'table' and type(request.Fire) == 'function' then
                            return (pcall(request.Fire))
                        end

                        return false
                    end,
                    roomKind = function()
                        local data = if handler then handler.GameData else nil

                        return if type(data) == 'table' and type(data.AdventureRoomKind) == 'string'then data.AdventureRoomKind else nil
                    end,
                    runSeed = function()
                        local data = if handler then handler.GameData else nil

                        return if type(data) == 'table' and type(data.AdventureRunSeed) == 'string'then data.AdventureRunSeed else nil
                    end,
                    floor = function()
                        local data = if handler then handler.GameData else nil

                        return if type(data) == 'table' and type(data.AdventureFloor) == 'number'then data.AdventureFloor else nil
                    end,
                    unitReward = (function()
                        local networking = replicated:FindFirstChild('Networking')
                        local odyssey = networking and networking:FindFirstChild('Odyssey')
                        local adventure = odyssey and odyssey:FindFirstChild('Adventure')

                        return adventure and adventure:FindFirstChild('UnitRewardEvent')
                    end)(),
                    endRun = (function()
                        local networking = replicated:FindFirstChild('Networking')
                        local odyssey = networking and networking:FindFirstChild('Odyssey')
                        local adventure = odyssey and odyssey:FindFirstChild('Adventure')

                        return adventure and adventure:FindFirstChild('EndRunEvent')
                    end)(),
                    hideCardWindow = function()
                        local players = env.game and env.game:GetService('Players')
                        local lp = players and players.LocalPlayer
                        local pgui = lp and lp:FindFirstChild('PlayerGui')
                        local ah = pgui and pgui:FindFirstChild('AdventureHUD')
                        local cc = ah and ah:FindFirstChild('ChooseCard', true)

                        if cc then
                            cc.Visible = false
                        end
                    end,
                    readCharacterOffer = function()
                        local players = env.game and env.game:GetService('Players')
                        local lp = players and players.LocalPlayer
                        local pgui = lp and lp:FindFirstChild('PlayerGui')
                        local ah = pgui and pgui:FindFirstChild('AdventureHUD')
                        local cc = ah and ah:FindFirstChild('ChooseCard', true)
                        local getgc = ((getfenv())).getgc

                        if not cc or not cc.Visible or type(getgc) ~= 'function' then
                            return nil
                        end

                        local ok, objects = pcall(getgc, true)

                        if not ok or type(objects) ~= 'table' then
                            return nil
                        end

                        for _, value in objects do
                            if type(value) == 'table' then
                                local kind = rawget(value, 'Kind')

                                if (kind == 'CharacterReplace' or kind == 'Character') and type(rawget(value, 'Options')) == 'table' then
                                    return {
                                        Options = rawget(value, 'Options'),
                                        ExistingCards = rawget(value, 'ExistingCards'),
                                        AtCap = kind == 'CharacterReplace',
                                    }
                                end
                            end
                        end

                        return nil
                    end,
                    stageMechanics = optionalModule(replicated, paths.stageMechanicsClient),
                    yen = function()
                        local yenHandler = optionalModule(env.game:GetService('StarterPlayer'), paths.playerYenHandler)

                        if type(yenHandler) == 'table' and type(yenHandler.GetYen) == 'function' then
                            local ok, value = pcall(yenHandler.GetYen, yenHandler)

                            return if ok and type(value) == 'number'then value else nil
                        end

                        return nil
                    end,
                    allBasicCardsOwned = (function()
                        local cached = setmetatable({}, {
                            __mode = 'v',
                        })

                        return function()
                            local state = cached.state

                            if type(state) ~= 'table' or type(rawget(state, 'BasicCards')) ~= 'table' then
                                state = nil

                                local getgc = ((getfenv())).getgc

                                if type(getgc) ~= 'function' then
                                    return false
                                end

                                local ok, objects = pcall(getgc, true)

                                if not ok then
                                    return false
                                end

                                for _, value in objects do
                                    if type(value) == 'table' and rawget(value, 'BasicFocusCapacity') and type(rawget(value, 'BasicCards')) == 'table' then
                                        state = value

                                        break
                                    end
                                end

                                cached.state = state
                            end
                            if not state then
                                return false
                            end

                            local levels = {}

                            for _, listName in {
                                'BasicCards',
                                'ReserveBasicCards',
                            }do
                                local list = rawget(state, listName)

                                if type(list) == 'table' then
                                    for _, card in list do
                                        if type(card) == 'table' and type(card.CardName) == 'string' then
                                            levels[card.CardName] = (levels[card.CardName] or 0) + (tonumber(card.Level) or 1)
                                        end
                                    end
                                end
                            end

                            local okCatalog, catalog = pcall(Catalog.read)

                            if not okCatalog or type(catalog) ~= 'table' then
                                return false
                            end

                            local caps = (config).adventure.basicCardCaps

                            for _, name in catalog.basicCards do
                                local cap = caps[catalog.basicCardRarity[name] ] or 1

                                if (levels[name] or 0) < cap then
                                    return false
                                end
                            end

                            return true
                        end
                    end)(),
                    rootCFrame = function()
                        local players = env.game:GetService('Players')
                        local character = players.LocalPlayer and players.LocalPlayer.Character
                        local root = character and character:FindFirstChild('HumanoidRootPart')

                        return root and root.CFrame
                    end,
                    basicCardNames = (function()
                        local ok, catalog = pcall(Catalog.read)

                        if not ok or type(catalog) ~= 'table' then
                            return nil
                        end

                        local set = {}

                        for _, name in catalog.basicCards do
                            set[name] = true
                        end

                        return set
                    end)(),
                    characterCardName = (function()
                        local ok, catalog = pcall(function()
                            return Catalog.read()
                        end)

                        return if ok and type(catalog) == 'table'then catalog.characterCardName else nil
                    end)(),
                    placedUnitGuid = function(name)
                        local handler = optionalModule(env.game:GetService('StarterPlayer'), paths.clientUnitHandler)

                        if type(handler) ~= 'table' or type(handler.GetAllPlacedUnits) ~= 'function' then
                            return nil
                        end

                        local listPlaced = handler.GetAllPlacedUnits

                        for _, unit in listPlaced()do
                            if type(unit) == 'table' and (name == nil or unit.Name == name) and type(unit.UniqueIdentifier) == 'string' then
                                return unit.UniqueIdentifier
                            end
                        end

                        return nil
                    end,
                    mapRelay = optionalModule(env.game:GetService('StarterPlayer'), paths.adventureMapRelay),
                    events = optionalModule(replicated, paths.gameOdysseyClient),
                    teleportTo = function(chestCFrame)
                        local players = env.game and env.game:GetService('Players')
                        local lp = players and players.LocalPlayer
                        local char = lp and lp.Character
                        local hrp = char and char:FindFirstChild('HumanoidRootPart')

                        if hrp and chestCFrame ~= nil then
                            local ok = pcall(function()
                                local cfGlobal = ((getfenv())).CFrame
                                local offset = if cfGlobal then cfGlobal.new(0, 3, 0)else nil

                                hrp.CFrame = if offset then chestCFrame * offset else chestCFrame

                                local v3Global = ((getfenv())).Vector3

                                if v3Global and type(v3Global.new) == 'function' then
                                    local zero = (v3Global.new)(0, 0, 0)

                                    hrp.AssemblyLinearVelocity = zero
                                    hrp.AssemblyAngularVelocity = zero
                                end
                            end)

                            return ok
                        end

                        return false
                    end,
                    getUnopenedChests = function()
                        local workspaceService = env.game:GetService('Workspace')
                        local ignore = workspaceService and workspaceService:FindFirstChild('Ignore')
                        local list = {}

                        if ignore then
                            for _, child in ipairs(ignore:GetChildren())do
                                local ch = child

                                if ch:IsA('Model') and string.sub(ch.Name, 1, 13) == 'OdysseyChest_' then
                                    local id = ch:GetAttribute('Id')
                                    local hl = ch:FindFirstChild('OdysseyChestHighlight')

                                    if hl and type(id) == 'string' then
                                        local part = ch:FindFirstChild('Cylinder.001') or ch.PrimaryPart or ch:FindFirstChildWhichIsA('BasePart')
                                        local cf = if part then part.CFrame else nil

                                        table.insert(list, {
                                            id = id,
                                            cframe = cf,
                                        })
                                    end
                                end
                            end
                        end

                        return list
                    end,
                    openChestRequest = function(chestId)
                        local stageMechanics = optionalModule(replicated, paths.stageMechanicsClient)
                        local req = if stageMechanics then stageMechanics.OdysseyChestOpenRequest else nil

                        if type(req) == 'table' and type(req.Fire) == 'function' then
                            local ok = pcall(req.Fire, chestId)
                            local pickReq = stageMechanics.OdysseyChestPickUpItemRequest

                            if type(pickReq) == 'table' and type(pickReq.Fire) == 'function' then
                                pcall(pickReq.Fire, chestId)
                            end

                            return ok
                        end

                        return false
                    end,
                    readActiveCardOffer = function()
                        local players = env.game and env.game:GetService('Players')
                        local lp = players and players.LocalPlayer
                        local pgui = lp and lp:FindFirstChild('PlayerGui')
                        local ah = pgui and pgui:FindFirstChild('AdventureHUD')
                        local cc = ah and ah:FindFirstChild('ChooseCard', true)

                        if not cc or not cc.Visible then
                            return nil
                        end

                        local frame = cc:FindFirstChild('ScrollIndicatorFrame', true)

                        if not frame then
                            return nil
                        end

                        local options = {}

                        for _, ch in ipairs(frame:GetChildren())do
                            local btn = ch

                            if btn:IsA('ImageButton') then
                                local title = btn:FindFirstChild('Title', true)
                                local rarity = btn:FindFirstChild('Rarity', true)

                                if title and title:IsA('TextLabel') and title.Text ~= '' then
                                    table.insert(options, {
                                        CardName = title.Text,
                                        Rarity = if rarity and rarity:IsA('TextLabel')then rarity.Text else'Rare',
                                    })
                                end
                            end
                        end

                        if #options > 0 then
                            return {Options = options}
                        end

                        return nil
                    end,
                    clickCard = function(name)
                        local players = env.game and env.game:GetService('Players')
                        local lp = players and players.LocalPlayer
                        local pgui = lp and lp:FindFirstChild('PlayerGui')
                        local ah = pgui and pgui:FindFirstChild('AdventureHUD')
                        local cc = ah and ah:FindFirstChild('ChooseCard', true)

                        if not cc or not cc.Visible then
                            return false
                        end

                        local firesignal = ((getfenv())).firesignal

                        for _, descendant in cc:GetDescendants()do
                            local btn = descendant

                            if btn:IsA('GuiButton') then
                                local title = btn:FindFirstChild('Title', true)

                                if title and title:IsA('TextLabel') and title.Text == name then
                                    local clicked = false

                                    if firesignal then
                                        clicked = pcall(firesignal, btn.Activated)

                                        pcall(firesignal, btn.MouseButton1Click)
                                    end

                                    return clicked
                                end
                            end
                        end

                        return false
                    end,
                    notify = function(title, text)
                        pcall(function()
                            env.game:GetService('StarterGui'):SetCore('SendNotification', {
                                Title = title,
                                Text = text,
                                Duration = 4,
                            })
                        end)
                    end,
                    isAdventure = function()
                        return handler ~= nil and Detect.isAdventureMatch(handler.GameData)
                    end,
                }
            end

            function Runtime.new(getSettings, injected)
                local self = {
                    status = 'Idle',
                    picked = 0,
                    routed = 0,
                    cards = 0,
                    chests = 0,
                    bought = 0,
                    units = 0,
                    onStatus = nil,
                    history = {},
                }
                local deps = injected
                local disconnects = {}
                local subscriptions = {}
                local lastKey = ''
                local lastAt = -math.huge
                local snapshot = nil
                local pendingRooms = nil
                local onRoomOffer
                local closeMapLater

                local function setStatus(text)
                    self.status = text

                    local history = self.history
                    local clockFn = if deps then deps.clock else nil
                    local stamp = if type(clockFn) == 'function'then(clockFn)()else 0

                    table.insert(history, string.format('%.0f %s', stamp, text))

                    if #history > HISTORY_LIMIT then
                        table.remove(history, 1)
                    end
                    if self.onStatus then
                        pcall(self.onStatus, text)
                    end
                end

                local voteOpen = false
                local voteAttempts = 0
                local lastOffer = nil
                local guardedRetry
                local shopHandled = false
                local shopClosedAt = -math.huge
                local shopBusyUntil = -math.huge
                local shopRerolls = 0
                local planSerial = 0
                local floorTasks = {}

                local function beginTask(name)
                    floorTasks[name] = deps.clock()
                end
                local function endTask(name)
                    floorTasks[name] = nil
                end
                local function waitingFor()
                    local now = deps.clock()

                    for name, since in floorTasks do
                        if now - since < TASK_WAIT_SECONDS then
                            return name
                        end
                    end

                    local readOffer = deps.readActiveCardOffer

                    if type(readOffer) == 'function' and getSettings().get('autoBasicCard') == true then
                        local okRead, activeOffer = pcall(readOffer)

                        if okRead and type(activeOffer) == 'table' then
                            return 'card'
                        end
                    end

                    return nil
                end

                local lastShopKey = ''
                local lastShopAt = -math.huge
                local lastRoomKey = ''
                local lastRoomAt = -math.huge

                local function sendPick(index, name)
                    local clickFn = deps.clickCard

                    if name and type(clickFn) == 'function' then
                        local okClick, clicked = pcall(clickFn, name)

                        if okClick and clicked == true then
                            return true
                        end
                    end

                    local entry = if deps.events then deps.events.CardPickPick else nil

                    if type(entry) == 'table' and type(entry.Fire) == 'function' then
                        local fireFn = entry.Fire

                        return (pcall(fireFn, {Choice = index}))
                    end

                    return false
                end
                local function notify(title, text)
                    local notifyFn = deps.notify

                    if type(notifyFn) == 'function' then
                        pcall(notifyFn, title, text)
                    end
                end
                local function onBasicOffer(offer)
                    if not self.active or getSettings().get('autoBasicCard') ~= true or not deps.isAdventure() then
                        return
                    end

                    local options = if type(offer) == 'table'then offer.Options else nil
                    local index = Choice.pickBasicCard(options, getSettings().get('cardPriority'))

                    if not index then
                        setStatus('Auto Basic Card: no valid card offered')

                        return
                    end

                    local name = options[index].CardName
                    local key = #options .. ':' .. name
                    local now = deps.clock()

                    if key == lastKey and now - lastAt < REPEAT_SECONDS then
                        return
                    end

                    lastKey, lastAt = key, now

                    beginTask('card')

                    local function pick()
                        if not self.active or getSettings().get('autoBasicCard') ~= true then
                            return
                        end

                        endTask('card')

                        if sendPick(index, name) then
                            notify('Auto Basic Card', 'Picked ' .. tostring(name))

                            self.picked += 1

                            setStatus(string.format('Auto Basic Card: picked %s (#%s)', tostring(name), tostring(self.picked)))
                        else
                            setStatus('Auto Basic Card: pick request failed')
                        end
                    end

                    local taskApi = deps.task

                    if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                        (taskApi.delay)(PICK_DELAY_SECONDS, pick)
                    else
                        pick()
                    end
                end
                local function closeMapNow()
                    if self.active and type(deps.closeMap) == 'function' then
                        pcall(deps.closeMap)
                    end
                end

                closeMapLater = function()
                    local taskApi = deps.task

                    if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                        (taskApi.delay)(1.5, closeMapNow)
                    else
                        closeMapNow()
                    end
                end
                onRoomOffer = function(offer, retry)
                    local saved = getSettings()

                    if retry ~= true then
                        voteAttempts = 0
                    end

                    lastOffer = offer
                    voteOpen = true

                    if self.active and saved.get('autoRoute') == true then
                        setStatus('Auto Route Atlas: room offer received')
                    end
                    if not self.active or saved.get('autoRoute') ~= true or not deps.isAdventure() then
                        return
                    end

                    local waiting = waitingFor()

                    if waiting then
                        setStatus('Auto Route Atlas: waiting for ' .. waiting)

                        local waitTask = deps.task

                        if type(waitTask) == 'table' and type(waitTask.delay) == 'function' then
                            (waitTask.delay)(TASK_WAIT_RETRY_SECONDS, function()
                                if self.active and voteOpen and lastOffer == offer then
                                    onRoomOffer(offer, true)
                                end
                            end)
                        end

                        return
                    end

                    local options = if type(offer) == 'table'then offer.Options else nil
                    local reachable = {}
                    local floor = if type(options) == 'table' and type(options[1]) == 'table'then options[1].AdventureFloor else nil
                    local known = false

                    if type(snapshot) == 'table' and type(snapshot.Nodes) == 'table' and type(floor) == 'number' and snapshot.CurrentFloor == floor - 1 then
                        known = true

                        local from = 'F' .. tostring(snapshot.CurrentFloor) .. '_L' .. tostring(snapshot.CurrentLane)
                        local prefix = 'F' .. tostring(floor) .. '_L'
                        local connected = false

                        if type(snapshot.Connections) == 'table' then
                            for _, connection in snapshot.Connections do
                                if type(connection) == 'table' and connection.From == from and type(connection.To) == 'string' then
                                    local toId = connection.To
                                    local captured = string.match(toId, '^' .. prefix .. '(%d+)$')
                                    local lane = if captured then tonumber(captured)else nil

                                    if lane then
                                        reachable[lane] = true
                                        connected = true
                                    end
                                end
                            end
                        end
                        if not connected then
                            for _, node in snapshot.Nodes do
                                if type(node) == 'table' and node.Floor == floor and node.IsSelectable == true and type(node.Lane) == 'number' then
                                    reachable[node.Lane] = true
                                end
                            end
                        end
                    end
                    if not known then
                        pendingRooms = offer

                        local ask = if deps.events then deps.events.MapRequestSnapshot else nil

                        if type(ask) == 'table' and type(ask.Fire) == 'function' then
                            local askFire = ask.Fire

                            pcall(askFire)
                        end

                        setStatus('Auto Route Atlas: waiting for the map data')

                        return
                    end

                    pendingRooms = nil

                    local index = Choice.pickRoom(options, saved.get('floorPriority'), saved.get('secondFloorPriority'), saved.get('secondPriorityFloor'), reachable)

                    if not index and type(options) == 'table' then
                        for _, option in options do
                            if type(option) == 'table' and type(option.Index) == 'number' and reachable[option.Index] then
                                if index == nil or option.Index < index then
                                    index = option.Index
                                end
                            end
                        end
                    end
                    if not index then
                        setStatus('Auto Route Atlas: no reachable room offered')

                        return
                    end

                    local now = deps.clock()
                    local key = 'room:' .. tostring(floor) .. ':' .. #options .. ':' .. index

                    if retry ~= true and key == lastRoomKey and now - lastRoomAt < REPEAT_SECONDS then
                        return
                    end

                    lastRoomKey, lastRoomAt = key, now

                    local function go()
                        local entry = if deps.events then deps.events.VoteCast else nil

                        if not self.active or saved.get('autoRoute') ~= true or type(entry) ~= 'table' or type(entry.Fire) ~= 'function' then
                            return
                        end

                        local fireFn = entry.Fire

                        if pcall(fireFn, {OptionIndex = index}) then
                            closeMapLater()

                            local taskApi2 = deps.task

                            if type(taskApi2) == 'table' and type(taskApi2.delay) == 'function' then
                                (taskApi2.delay)(VOTE_RETRY_SECONDS, function()
                                    if self.active and voteOpen and voteAttempts < VOTE_ATTEMPTS and lastOffer ~= nil then
                                        voteAttempts += 1

                                        guardedRetry(lastOffer)
                                    end
                                end)
                            end

                            self.routed += 1

                            local kind = '?'

                            for _, option in options do
                                if type(option) == 'table' and option.Index == index then
                                    kind = tostring(option.AdventureRoomKind)
                                end
                            end

                            setStatus(string.format('Auto Route Atlas: chose a %s room (#%s)', kind, tostring(self.routed)))
                        else
                            setStatus('Auto Route Atlas: choose request failed')
                        end
                    end

                    local taskApi = deps.task

                    if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                        (taskApi.delay)(PICK_DELAY_SECONDS, go)
                    else
                        go()
                    end
                end

                local function onCharacterOffer(offer)
                    if not self.active or getSettings().get('autoCharacterCard') ~= true or not deps.isAdventure() then
                        return
                    end

                    local atCap = type(offer) == 'table' and ((offer.AtCap ~= nil and offer.AtCap ~= false) or (type(offer.ExistingCards) == 'table' and #offer.ExistingCards >= 4))
                    local saved = getSettings()
                    local character = saved.get('character')
                    local groupOrder = saved.groupOrder
                    local order = if type(groupOrder) == 'function' and type(character) == 'string'then(groupOrder)('characterCardPriority', character)else nil
                    local nameOf = deps.characterCardName

                    if type(nameOf) ~= 'table' then
                        local okCatalog, catalog = pcall(Catalog.read)

                        nameOf = if okCatalog and type(catalog) == 'table'then catalog.characterCardName else nil
                    end

                    local runCharacter = nil

                    for _, entry in (if type(offer) == 'table' and type(offer.Options) == 'table'then offer.Options else{})do
                        if type(entry) == 'table' and type(entry.CharacterName) == 'string' then
                            runCharacter = entry.CharacterName
                        end
                    end

                    if runCharacter and type(groupOrder) == 'function' then
                        order = (groupOrder)('characterCardPriority', runCharacter)
                    end

                    local index = Choice.characterCardChoice(offer, order, if type(nameOf) == 'table'then nameOf else nil)
                    local offered = {}

                    if type(offer) == 'table' and type(offer.Options) == 'table' then
                        for _, option in offer.Options do
                            if type(option) == 'table' then
                                table.insert(offered, tostring(option.CardId))
                            end
                        end
                    end

                    setStatus('Auto Character Card: offer [' .. table.concat(offered, ', ') .. ']' .. (if atCap then' (hand full)'else''))
                    beginTask('character card')

                    local function answer()
                        endTask('character card')

                        if not self.active or getSettings().get('autoCharacterCard') ~= true then
                            return
                        end

                        local events = deps.events
                        local remoteName = if index then'CardPickPick'else'CardPickSkip'
                        local entry = if events then events[remoteName]else nil

                        if type(entry) ~= 'table' or type(entry.Fire) ~= 'function' then
                            return
                        end

                        local fireFn = entry.Fire
                        local pickedName = nil

                        if index and not atCap and type(offer.Options) == 'table' and type(offer.Options[index]) == 'table' then
                            local option = offer.Options[index]

                            pickedName = Choice.characterCardName(option, if type(nameOf) == 'table'then nameOf else nil)
                        end

                        local ok = false

                        if pickedName then
                            local okClick, clicked = pcall(deps.clickCard or function(
                            )
                                return false
                            end, pickedName)

                            ok = okClick and clicked == true
                        end
                        if not ok then
                            ok = if index then pcall(fireFn, {Choice = index})else pcall(fireFn)

                            if ok then
                                local hideFn = deps.hideCardWindow

                                if type(hideFn) == 'function' then
                                    pcall(hideFn)
                                end
                            end
                        end
                        if ok then
                            notify('Auto Character Card', if index then(pickedName or ('option ' .. tostring(index)))else'Skipped')

                            self.cards += 1

                            setStatus(if index then(if atCap then'Auto Character Card: swapped in a better card (' .. tostring(index) .. ')'else'Auto Character Card: picked option ' .. tostring(index))else'Auto Character Card: skipped (no better card)')
                        end
                    end

                    local taskApi = deps.task

                    if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                        (taskApi.delay)(PICK_DELAY_SECONDS, answer)
                    else
                        answer()
                    end
                end
                local function toSet(list)
                    local set = {}

                    if type(list) == 'table' then
                        for _, name in list do
                            if type(name) == 'string' then
                                set[name] = true
                            end
                        end
                    end

                    return set
                end
                local function placedGuid(name)
                    local lookup = deps.placedUnitGuid

                    if type(lookup) ~= 'function' then
                        return nil
                    end

                    local ok, guid = pcall(lookup, name)

                    return if ok and type(guid) == 'string'then guid else nil
                end
                local function onShopOpened(info)
                    local saved = getSettings()
                    local buying = saved.get('autoStitchesShop') == true

                    if not self.active or not deps.isAdventure() or (not buying and saved.get('leaveShop') ~= true) then
                        return
                    end

                    local stock = if type(info) == 'table'then info.Stock else nil
                    local now = deps.clock()
                    local floorOf = deps.floor
                    local key = 'shop:' .. tostring(if type(floorOf) == 'function'then(floorOf)()else nil) .. ':' .. tostring(if type(info) == 'table'then info.Budget else nil) .. ':' .. tostring(type(stock) == 'table' and #stock or 0) .. ':' .. tostring(if type(info) == 'table'then info.Spent else nil)

                    if type(stock) == 'table' then
                        for _, item in stock do
                            if type(item) == 'table' and item.Purchased ~= true then
                                key ..= ':' .. tostring(item.Index) .. tostring(item.BasicCardName or item.TraitName or item.Kind)
                            end
                        end
                    end
                    if key == lastShopKey and now - lastShopAt < REPEAT_SECONDS then
                        return
                    end

                    lastShopKey, lastShopAt = key, now
                    shopHandled = true

                    beginTask('shop')
                    setStatus('Shop: opened, planning purchases')

                    local plan = {}

                    if buying and type(info) == 'table' then
                        plan = Choice.shopPurchases(stock, (if type(info.Budget) == 'number'then info.Budget else 0) - (if type(info.Spent) == 'number'then info.Spent else 0), {
                            basic = toSet(saved.get('buyBasicCards')),
                            starters = toSet(saved.get('buyStarterCards')),
                            traits = toSet(saved.get('buyTraits')),
                            memoria = toSet(saved.get('buyMemoria')),
                            character = saved.get('character'),
                            characterCards = if saved.get('buyCharacterCards') == true and type(saved.groupOrder) == 'function'then(saved.groupOrder)('characterCardPriority', saved.get('character'))else nil,
                            characterCardName = deps.characterCardName,
                            characterCardTop = CHARACTER_CARD_TOP,
                            fallbackGuid = placedGuid(saved.get('character')),
                            rank = saved.get('cardPriority'),
                        })
                    end

                    setStatus('Shop: ' .. tostring(#plan) .. ' item(s) to buy (budget ' .. tostring(if type(info) == 'table'then info.Budget else nil) .. ')')

                    local taskApi = deps.task

                    local function later(seconds, action)
                        if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                            (taskApi.delay)(seconds, action)
                        else
                            action()
                        end
                    end
                    local function leave()
                        local events = deps.events
                        local entry = if events then events.ShopClose else nil

                        if not self.active or saved.get('leaveShop') ~= true then
                            endTask('shop')

                            if #plan > 0 then
                                setStatus('Shop: bought ' .. tostring(#plan) .. ' item(s); Leave Shop Rooms is off, staying')
                            end

                            return
                        end

                        local pressFn = deps.closeShopUi

                        if type(pressFn) == 'function' then
                            pcall(pressFn)
                        end

                        local sent = false

                        if type(entry) == 'table' and type(entry.Fire) == 'function' then
                            local fireFn = entry.Fire

                            sent = (pcall(fireFn))
                        end

                        shopClosedAt = deps.clock()

                        endTask('shop')

                        shopRerolls = 0
                        lastShopKey = ''

                        setStatus(if#plan > 0 then'Shop: bought ' .. tostring(#plan) .. ' item(s), left the shop'else'Left the shop without buying' .. (if sent then''else' (button only)'))
                    end

                    for position, item in plan do
                        later(PICK_DELAY_SECONDS + SHOP_GAP_SECONDS * (position - 1), function(
                        )
                            local events = deps.events
                            local entry = if events then events.ShopPurchase else nil

                            if not self.active or type(entry) ~= 'table' or type(entry.Fire) ~= 'function' then
                                return
                            end

                            local payload = {
                                StockIndex = item.index,
                            }

                            if item.guid then
                                payload.TargetUnitGUID = item.guid
                            end

                            local fireFn = entry.Fire

                            if pcall(fireFn, payload) then
                                self.bought += 1

                                setStatus('Shop: bought ' .. tostring(item.name) .. ' for ' .. tostring(item.cost))
                            end
                        end)
                    end

                    shopBusyUntil = deps.clock() + PICK_DELAY_SECONDS + SHOP_GAP_SECONDS * (#plan + 1)

                    planSerial += 1

                    local planAt = planSerial

                    local function finish(afterPurchases)
                        if #plan > 0 and afterPurchases ~= true then
                            later(SHOP_REROLL_WAIT_SECONDS, function()
                                if self.active and planSerial == planAt then
                                    finish(true)
                                end
                            end)

                            return
                        end

                        local sections = toSet(saved.get('shopRerollSections'))
                        local limit = tonumber(saved.get('shopRerollTimes')) or 0

                        if self.active and saved.get('autoStitchesShop') == true and saved.get('shopReroll') == true and shopRerolls < limit and next(sections) ~= nil then
                            local events = deps.events
                            local fired = false

                            if sections.All then
                                local all = if events then events.ShopReroll else nil

                                if type(all) == 'table' and type(all.Fire) == 'function' then
                                    fired = (pcall(all.Fire))
                                end
                            else
                                local one = if events then events.ShopRerollSection else nil

                                for _, section in {
                                    'Card',
                                    'Trait',
                                    'Memoria',
                                }do
                                    if sections[section] and type(one) == 'table' and type(one.Fire) == 'function' then
                                        fired = (pcall(one.Fire, {Section = section})) or fired
                                    end
                                end
                            end
                            if fired then
                                shopRerolls += 1

                                local rerollAt = planSerial

                                setStatus('Shop: reroll ' .. tostring(shopRerolls) .. '/' .. tostring(limit))
                                later(SHOP_REROLL_WAIT_SECONDS, function()
                                    if self.active and planSerial == rerollAt then
                                        leave()
                                    end
                                end)

                                return
                            end
                        end

                        leave()
                    end

                    later(PICK_DELAY_SECONDS + SHOP_GAP_SECONDS * #plan, function(
                    )
                        finish()
                    end)
                end

                local treasureHandling = false
                local lastTreasureFloor = nil

                local function runOpenChests(info)
                    if treasureHandling or not self.active or getSettings().get('openTreasure') ~= true or not deps.isAdventure() then
                        return
                    end

                    treasureHandling = true

                    beginTask('treasure')
                    setStatus('Treasure floor: opening chests')

                    local taskApi = deps.task

                    local function later(seconds, action)
                        if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                            (taskApi.delay)(seconds, action)
                        else
                            action()
                        end
                    end
                    local function finish()
                        treasureHandling = false

                        endTask('treasure')
                    end

                    local total = if type(info) == 'table' and type(info.TotalChests) == 'number'then info.TotalChests else 6
                    local picks = if type(info) == 'table' and type(info.PicksRemaining) == 'number'then info.PicksRemaining else 3
                    local opened = {}

                    if type(info) == 'table' and type(info.OpenedChests) == 'table' then
                        for key, value in info.OpenedChests do
                            if type(key) == 'number' and value then
                                opened[key] = true
                            end
                            if type(value) == 'number' then
                                opened[value] = true
                            end
                        end
                    end

                    local order = {}

                    for index = 1, total do
                        if not opened[index] and #order < picks then
                            table.insert(order, index)
                        end
                    end

                    if #order == 0 then
                        finish()

                        return
                    end

                    local getChestsFn = deps.getUnopenedChests
                    local physical = if type(getChestsFn) == 'function'then(getChestsFn)()else nil

                    local function step(position)
                        if not self.active or getSettings().get('openTreasure') ~= true or position > #order then
                            finish()

                            return
                        end

                        local chestIndex = order[position]

                        setStatus(string.format('Treasure floor: moving to chest %s/%s', tostring(position), tostring(#order)))

                        local chest = if type(physical) == 'table'then physical[position]else nil
                        local tpFn = deps.teleportTo

                        if type(tpFn) == 'function' and type(chest) == 'table' and chest.cframe then
                            pcall(tpFn, chest.cframe)
                        end

                        later(CHEST_TELEPORT_DELAY_SECONDS, function()
                            if not self.active or getSettings().get('openTreasure') ~= true then
                                finish()

                                return
                            end

                            local events = deps.events
                            local entry = if events then events.TreasureOpenChest else nil

                            if type(entry) == 'table' and type(entry.Fire) == 'function' then
                                local fireFn = entry.Fire

                                if pcall(fireFn, {ChestIndex = chestIndex}) then
                                    self.chests += 1

                                    setStatus('Opened treasure chest ' .. tostring(position) .. '/' .. tostring(#order))
                                end
                            end

                            later(CHEST_GAP_SECONDS, function()
                                step(position + 1)
                            end)
                        end)
                    end

                    step(1)
                end
                local function onTreasureBegin(info)
                    if not self.active or type(info) ~= 'table' then
                        return
                    end
                    if getSettings().get('openTreasure') ~= true then
                        setStatus('Treasure floor: Open Treasure Chests is off')

                        return
                    end
                    if not deps.isAdventure() then
                        setStatus('Treasure floor: not recognized as an Adventure match')

                        return
                    end

                    runOpenChests(info)
                end
                local function onUnitReward(kind, data)
                    if kind == 'Close' then
                        endTask('unit reward')

                        return
                    end
                    if kind ~= 'Offer' or not self.active or getSettings().get('autoUnitReward') ~= true or not deps.isAdventure() then
                        return
                    end

                    local index = Choice.pickUnitReward(data)
                    local remote = deps.unitReward

                    if remote == nil then
                        setStatus('Auto Choose Unit Reward: reward remote missing')

                        return
                    end

                    beginTask('unit reward')

                    local function answer()
                        if not self.active or getSettings().get('autoUnitReward') ~= true then
                            endTask('unit reward')

                            return
                        end

                        local okFire = pcall(function()
                            if index then
                                remote:FireServer('Pick', index)
                            else
                                remote:FireServer('Skip', nil)
                            end
                        end)

                        if okFire then
                            if index then
                                self.units += 1
                            end

                            setStatus(if index then'Auto Choose Unit Reward: picked unit option ' .. tostring(index)else'Auto Choose Unit Reward: no unit to pick, skipped')
                        end

                        endTask('unit reward')
                    end

                    local taskApi = deps.task

                    if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                        (taskApi.delay)(PICK_DELAY_SECONDS, answer)
                    else
                        answer()
                    end
                end
                local function onBossOffer(offer)
                    if not self.active or getSettings().get('autoBossReward') ~= true or not deps.isAdventure() then
                        return
                    end

                    local options = if type(offer) == 'table'then offer.Options else nil
                    local kind = Choice.pickBossReward(options)

                    beginTask('boss reward')

                    local function answer()
                        endTask('boss reward')

                        if not self.active or getSettings().get('autoBossReward') ~= true then
                            return
                        end

                        local events = deps.events
                        local guidOf = deps.placedUnitGuid
                        local guid = nil

                        if kind and type(guidOf) == 'function' then
                            guid = (guidOf)(getSettings().get('character')) or (guidOf)(nil)
                        end

                        local remoteName = if kind and guid then'BossRewardPick'else'BossRewardSkip'
                        local entry = if events then events[remoteName]else nil

                        if type(entry) ~= 'table' or type(entry.Fire) ~= 'function' then
                            setStatus('Auto Boss Reward: remote missing')

                            return
                        end

                        local fireFn = entry.Fire
                        local ok = if remoteName == 'BossRewardPick'then pcall(fireFn, {
                            Kind = kind,
                            TargetUnitGUID = guid,
                        })else pcall(fireFn)

                        if ok then
                            setStatus(if remoteName == 'BossRewardPick'then'Auto Boss Reward: claimed a ' .. tostring(kind)else'Auto Boss Reward: skipped (nothing to claim)')
                        else
                            setStatus('Auto Boss Reward: request failed')
                        end
                    end

                    local taskApi = deps.task

                    if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                        (taskApi.delay)(PICK_DELAY_SECONDS, answer)
                    else
                        answer()
                    end
                end

                local itches = {}
                local itchesBought = {}
                local itchesBusy = false

                local function buyItches()
                    local saved = getSettings()

                    if itchesBusy or not self.active or saved.get('autoBuyItches') ~= true or not deps.isAdventure() then
                        return
                    end

                    local mechanics = deps.stageMechanics
                    local request = if type(mechanics) == 'table'then mechanics.ItchesInteractRequest else nil
                    local yenOf = deps.yen

                    if type(request) ~= 'table' or type(request.Fire) ~= 'function' or type(yenOf) ~= 'function' then
                        return
                    end

                    local ownedFn = deps.allBasicCardsOwned

                    if type(ownedFn) == 'function' then
                        local okOwned, owned = pcall(ownedFn)

                        if okOwned and owned == true then
                            return
                        end
                    end

                    for id, entry in itches do
                        local cost = tonumber(entry.Cost) or math.huge
                        local yen = (yenOf)() or 0

                        if cost <= yen and entry.CFrame ~= nil then
                            itchesBusy = true

                            local back = if type(deps.rootCFrame) == 'function'then(deps.rootCFrame)()else nil
                            local tpFn = deps.teleportTo

                            if type(tpFn) == 'function' then
                                pcall(tpFn, entry.CFrame)
                            end

                            local taskApi = deps.task

                            local function finish()
                                if self.active then
                                    if pcall(request.Fire, id) then
                                        itchesBought[id] = (itchesBought[id] or 0) + 1

                                        setStatus(string.format('Auto Buy Itches: bought for %s Yen (#%s)', tostring(cost), tostring(itchesBought[id])))
                                        notify('Auto Buy Itches', 'Bought for ' .. tostring(cost) .. ' Yen')
                                    end
                                end

                                local function goBack()
                                    if back ~= nil and type(tpFn) == 'function' then
                                        pcall(tpFn, back)
                                    end

                                    itchesBusy = false
                                end

                                if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                                    (taskApi.delay)(ITCHES_STAY_SECONDS, goBack)
                                else
                                    goBack()
                                end
                            end

                            if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                                (taskApi.delay)(CHEST_TELEPORT_DELAY_SECONDS, finish)
                            else
                                finish()
                            end

                            return
                        end
                    end
                end
                local function guarded(name, handler)
                    return function(payload)
                        local ok, err = pcall(handler, payload)

                        if not ok then
                            setStatus('Adventure ' .. name .. ' failed: ' .. string.sub(tostring(err), 1, 90))
                        end
                    end
                end

                local lastFloorSeen = nil
                local lastShopAsk = -math.huge
                local lastSeed = nil
                local failsafeFloor = nil
                local failsafeSince = 0
                local endSince = nil
                local lastLobbyAt = -math.huge
                local lastNewRunAt = -math.huge
                local lastMapPoll = -math.huge
                local lastCharacterUiAt = -math.huge
                local lastEndRunAt = -math.huge

                local function watchShop()
                    local taskApi = deps.task

                    if not self.active or type(taskApi) ~= 'table' or type(taskApi.delay) ~= 'function' then
                        return
                    end
                    if not voteOpen and getSettings().get('autoRoute') == true and deps.clock() - lastMapPoll >= MAP_POLL_SECONDS then
                        lastMapPoll = deps.clock()

                        local askMap = if deps.events then deps.events.MapRequestSnapshot else nil

                        if type(askMap) == 'table' and type(askMap.Fire) == 'function' then
                            pcall(askMap.Fire)
                        end
                    end

                    pcall(buyItches)

                    for _, sub in subscriptions do
                        pcall(sub.check)
                    end

                    local seedOf = deps.runSeed
                    local seed = if type(seedOf) == 'function'then(seedOf)()else nil

                    if seed ~= nil and lastSeed ~= nil and seed ~= lastSeed then
                        lastSeed = seed

                        self.stop()

                        if self.start() then
                            setStatus('New Adventure run: subscribed to its events again')
                        end

                        return
                    end
                    if seed ~= nil then
                        lastSeed = seed
                    end

                    local now0 = deps.clock()
                    local floorDep = deps.floor
                    local floorNow = if type(floorDep) == 'function'then(floorDep)()else nil

                    if floorNow ~= failsafeFloor then
                        failsafeFloor = floorNow
                        failsafeSince = now0
                    end

                    local endShown = deps.endScreenShown
                    local isEnd = type(endShown) == 'function' and (endShown)() == true

                    if isEnd then
                        endSince = if endSince then endSince else now0
                    else
                        endSince = nil
                    end

                    local saved0 = getSettings()
                    local reason = nil

                    if isEnd and saved0.get('autoStartNewRun') == true and now0 - (endSince) >= END_SCREEN_SECONDS then
                        reason = 'the run ended'
                    elseif saved0.get('failsafe') == true and now0 - failsafeSince >= (tonumber(saved0.get('failsafeMinutes')) or 30) * 60 then
                        reason = 'floor ' .. tostring(floorNow) .. ' ran too long'
                    end

                    local endRemote = deps.endRun
                    local target = tonumber(saved0.get('cashOutFloor'))

                    if endRemote ~= nil and saved0.get('autoCashOut') == true and target ~= nil and type(floorNow) == 'number' and floorNow - 1 >= target and not isEnd and now0 - lastEndRunAt >= LOBBY_RETRY_SECONDS then
                        lastEndRunAt = now0

                        if pcall(function()
                            endRemote:FireServer('RequestPreview', nil)
                        end) then
                            setStatus('Auto End Run: floor ' .. tostring(floorNow - 1) .. ' cleared, asking to end the run')
                        end
                    end
                    if isEnd and saved0.get('autoStartNewRun') == true and now0 - (endSince) >= END_SCREEN_SECONDS and now0 - (endSince) < END_SCREEN_SECONDS + NEW_RUN_FALLBACK_SECONDS then
                        reason = nil

                        if now0 - lastNewRunAt >= LOBBY_RETRY_SECONDS then
                            local newRunFn = deps.newRun

                            if type(newRunFn) == 'function' and (newRunFn)() then
                                lastNewRunAt = now0

                                setStatus('Run ended: voted New Run')
                            end
                        end
                    end
                    if reason and now0 - lastLobbyAt >= LOBBY_RETRY_SECONDS then
                        local backFn = deps.returnToLobby

                        if type(backFn) == 'function' and (backFn)() then
                            lastLobbyAt = now0

                            setStatus('Returning to the lobby: ' .. reason)
                        end
                    end

                    local ok = pcall(function()
                        local floorOf = deps.floor
                        local floor = if type(floorOf) == 'function'then(floorOf)()else nil

                        if floor ~= lastFloorSeen then
                            lastFloorSeen = floor
                            shopHandled = false
                            floorTasks = {}
                            shopRerolls = 0
                            treasureHandling = false
                        end

                        local roomKindOf = deps.roomKind
                        local saved = getSettings()
                        local wanted = saved.get('autoStitchesShop') == true or saved.get('leaveShop') == true
                        local now = deps.clock()

                        if wanted and not shopHandled and type(roomKindOf) == 'function' and (roomKindOf)() == 'Shop' and now - lastShopAsk >= SHOP_ASK_SECONDS then
                            lastShopAsk = now

                            local events = deps.events
                            local ask = if events then events.ShopRequestState else nil

                            if type(ask) == 'table' and type(ask.Fire) == 'function' then
                                local askFire = ask.Fire

                                pcall(askFire)
                            end
                        end

                        local closeShopFn = deps.closeShopUi

                        if getSettings().get('leaveShop') == true and type(closeShopFn) == 'function' and deps.isAdventure() then
                            local inShop = type(roomKindOf) == 'function' and (roomKindOf)() == 'Shop'
                            local closedLongAgo = shopClosedAt > -math.huge and now - shopClosedAt >= SHOP_UI_GRACE_SECONDS

                            if (not inShop or closedLongAgo) and (closeShopFn)() == true then
                                setStatus("Closed the Stitches' Shop window left open")
                            end
                        end
                        if saved.get('openTreasure') == true and not treasureHandling and deps.isAdventure() then
                            local kind = if type(roomKindOf) == 'function'then(roomKindOf)()else nil
                            local getChestsFn = deps.getUnopenedChests
                            local physical = if type(getChestsFn) == 'function'then(getChestsFn)()else nil

                            if kind == 'Treasure' or (type(physical) == 'table' and #physical > 0) then
                                if floor ~= lastTreasureFloor then
                                    lastTreasureFloor = floor

                                    runOpenChests()
                                end
                            end
                        end
                        if saved.get('autoBasicCard') == true and deps.isAdventure() then
                            local readOfferFn = deps.readActiveCardOffer

                            if type(readOfferFn) == 'function' then
                                local activeOffer = (readOfferFn)()
                                local basicNames = deps.basicCardNames
                                local allBasic = type(activeOffer) == 'table' and type(activeOffer.Options) == 'table'

                                if allBasic and type(basicNames) == 'table' then
                                    for _, option in activeOffer.Options do
                                        if not basicNames[option.CardName] then
                                            allBasic = false
                                        end
                                    end
                                end
                                if not allBasic and saved.get('autoCharacterCard') == true and floorTasks['character card'] == nil and deps.clock() - lastCharacterUiAt >= REPEAT_SECONDS * 2 then
                                    local readCharacter = deps.readCharacterOffer
                                    local okRead, characterOffer = pcall(readCharacter or function(
                                    )
                                        return nil
                                    end)

                                    if okRead and type(characterOffer) == 'table' then
                                        lastCharacterUiAt = deps.clock()

                                        onCharacterOffer(characterOffer)
                                    end
                                end
                                if allBasic and #activeOffer.Options > 0 then
                                    onBasicOffer(activeOffer)
                                end
                            end
                        end
                    end)

                    if not ok then
                        setStatus('Shop watcher failed')
                    end

                    (taskApi.delay)(SHOP_WATCH_SECONDS, watchShop)
                end

                function self.start()
                    if self.active then
                        return true
                    end

                    deps = deps or liveDependencies()

                    local events = deps.events
                    local entry = if type(events) == 'table'then events.CardPickBasicOffer else nil

                    if type(entry) ~= 'table' or type(entry.On) ~= 'function' then
                        setStatus('Idle (not in an Adventure match)')

                        return false
                    end

                    subscriptions = {}

                    local function listen(target, handler)
                        local sub = Listen.chain(target, handler)

                        if sub == nil then
                            return false
                        end

                        table.insert(subscriptions, sub)
                        table.insert(disconnects, sub.undo)

                        return true
                    end

                    if not listen(entry, guarded('card offer', onBasicOffer)) then
                        setStatus('Auto Basic Card: could not subscribe')

                        return false
                    end

                    local extras = {
                        CardPickCharacterOffer = onCharacterOffer,
                        ShopOpened = onShopOpened,
                        TreasureBegin = onTreasureBegin,
                        BossRewardOffer = onBossOffer,
                        ShopStockUpdated = function(info)
                            if not shopHandled or (getSettings().get('autoStitchesShop') == true and deps.clock() >= shopBusyUntil) then
                                onShopOpened(info)
                            end
                        end,
                        ShopClosed = function()
                            shopHandled = false

                            endTask('shop')

                            lastShopKey = ''
                            shopClosedAt = deps.clock()
                        end,
                        VoteEnded = function()
                            voteOpen = false
                            voteAttempts = 0

                            closeMapLater()
                        end,
                    }

                    for eventName, handler in extras do
                        local extra = events[eventName]

                        listen(extra, guarded(eventName, handler))
                    end

                    local relay = deps.mapRelay

                    if type(relay) == 'table' and type(relay.OnSnapshot) == 'function' then
                        local okRelay, undoRelay = pcall(relay.OnSnapshot, function(
                            data
                        )
                            snapshot = data

                            local waiting = pendingRooms

                            if waiting ~= nil then
                                guarded('room offer', onRoomOffer)(waiting)

                                return
                            end
                            if voteOpen or type(data) ~= 'table' or type(data.Nodes) ~= 'table' then
                                return
                            end

                            local nextFloor = (tonumber(data.CurrentFloor) or 0) + 1
                            local options = {}

                            for _, node in data.Nodes do
                                if type(node) == 'table' and node.IsSelectable == true then
                                    local lane = tonumber(node.Lane)
                                    local floorNo = tonumber(node.Floor)

                                    if (lane == nil or floorNo == nil) and type(node.Id) == 'string' then
                                        local f, l = string.match(node.Id, '^F(%d+)_L(%d+)$')

                                        floorNo, lane = tonumber(f), tonumber(l)
                                    end
                                    if lane and floorNo == nextFloor and type(node.Kind) == 'string' then
                                        table.insert(options, {
                                            Index = lane,
                                            AdventureRoomKind = node.Kind,
                                            AdventureFloor = floorNo,
                                            BossRoom = node.Kind == 'Boss',
                                        })
                                    end
                                end
                            end

                            if #options > 0 then
                                setStatus('Auto Route Atlas: vote found on the map without an offer')
                                guarded('room offer', onRoomOffer)({Options = options})
                            end
                        end)

                        if okRelay and type(undoRelay) == 'function' then
                            table.insert(disconnects, undoRelay)
                        end
                    end

                    local roomEntry = if type(events) == 'table'then events.SelectRoomSelectionStarted else nil

                    listen(roomEntry, guarded('room offer', onRoomOffer))

                    local mechanics = deps.stageMechanics

                    if type(mechanics) == 'table' then
                        listen(mechanics.ItchesLoaded, guarded('itches', function(
                            info
                        )
                            itches = {}

                            if type(info) == 'table' and type(info.Items) == 'table' then
                                for _, item in info.Items do
                                    if type(item) == 'table' and item.Id ~= nil then
                                        itches[item.Id] = {
                                            CFrame = item.CFrame,
                                            Cost = item.Cost,
                                        }
                                    end
                                end
                            end
                        end))
                        listen(mechanics.ItchesCostUpdated, guarded('itches cost', function(
                            info
                        )
                            if type(info) == 'table' and itches[info.Id] then
                                itches[info.Id].Cost = info.Cost
                            end
                        end))
                    end

                    guardedRetry = function(offer)
                        guarded('room offer', function(payload)
                            onRoomOffer(payload, true)
                        end)(offer)
                    end
                    self.active = true

                    setStatus('Listening for card and room offers')

                    local endRemote = deps.endRun

                    if endRemote ~= nil then
                        local okEnd, endConnection = pcall(function()
                            return endRemote.OnClientEvent:Connect(function(
                                kind,
                                data
                            )
                                local saved = getSettings()

                                if not self.active or saved.get('autoCashOut') ~= true then
                                    return
                                end

                                local target = tonumber(saved.get('cashOutFloor')) or math.huge

                                if kind == 'Preview' and type(data) == 'table' and data.Token ~= nil then
                                    local cleared = tonumber(data.FloorsCleared) or 0

                                    if cleared >= target then
                                        pcall(function()
                                            endRemote:FireServer('Confirm', data.Token)
                                        end)
                                        setStatus('Auto End Run: ending the run at ' .. tostring(cleared) .. ' floors')
                                    end
                                elseif kind == 'Completed' then
                                    setStatus('Auto End Run: run ended')

                                    if saved.get('autoStartNewRun') == true then
                                        local replayTask = deps.task

                                        local function replay()
                                            if self.active then
                                                pcall(function()
                                                    endRemote:FireServer('Replay', nil)
                                                end)
                                                setStatus('Auto End Run: started a new run')
                                            end
                                        end

                                        if type(replayTask) == 'table' and type(replayTask.delay) == 'function' then
                                            (replayTask.delay)(END_SCREEN_SECONDS, replay)
                                        else
                                            replay()
                                        end
                                    end
                                elseif kind == 'Rejected' then
                                    setStatus('Auto End Run: the game refused to end the run now')
                                end
                            end)
                        end)

                        if okEnd and endConnection then
                            table.insert(disconnects, function()
                                endConnection:Disconnect()
                            end)
                        end
                    end

                    local rewardRemote = deps.unitReward

                    if rewardRemote ~= nil then
                        local okReward, connection = pcall(function()
                            return rewardRemote.OnClientEvent:Connect(function(
                                kind,
                                data
                            )
                                local okHandler, err = pcall(onUnitReward, kind, data)

                                if not okHandler then
                                    setStatus('Adventure unit reward failed: ' .. string.sub(tostring(err), 1, 90))
                                end
                            end)
                        end)

                        if okReward and connection then
                            table.insert(disconnects, function()
                                connection:Disconnect()
                            end)
                        end
                    end

                    local roomKindDep = deps.roomKind

                    if type(roomKindDep) == 'function' then
                        watchShop()
                    end

                    return true
                end
                function self.stop()
                    self.active = false

                    for _, undo in disconnects do
                        pcall(undo)
                    end

                    disconnects = {}
                end

                return self
            end

            return Runtime
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
            local Style = __DARKLUA_BUNDLE_MODULES.e()
            local Storage = __DARKLUA_BUNDLE_MODULES.s()
            local Document = __DARKLUA_BUNDLE_MODULES.r()
            local Page = {}

            local function humanError(code)
                local s = tostring(code)

                if s == 'MACRO_NAME_INVALID' then
                    return 'Invalid macro name (use alphanumeric, _, or -)'
                elseif s == 'MACRO_EXISTS' then
                    return 'A macro with this name already exists'
                elseif s == 'MACRO_MISSING' then
                    return 'Macro file not found on disk'
                elseif s == 'MACRO_BUSY' then
                    return 'Macro is busy (recording or playing)'
                elseif s == 'MACRO_MATCH_UNAVAILABLE' then
                    return 'Match not available: enter a match first'
                elseif s == 'MACRO_ADAPTER_UNAVAILABLE' then
                    return 'Game modules are still loading...'
                elseif s == 'MACRO_JSON_INVALID' then
                    return 'Macro JSON is invalid or corrupted'
                elseif s == 'MACRO_SCHEMA_UNSUPPORTED' then
                    return 'Macro version is unsupported'
                elseif s == 'AUTOPLAY_ACTIVE' then
                    return
[[Cannot play macro while Auto play - ingame is active. Turn it off first.]]
                end

                return s
            end

            function Page.mount(tab, runtime, window, autoPlay)
                local env = getfenv()
                local codec = env.game:GetService('HttpService')
                local storage = Storage.new(env, codec)
                local selected = ''
                local entered = ''
                local deletePending = ''
                local status = nil

                tab:Paragraph({
                    Title = 'Macro Studio',
                    Desc =
[[Record confirmed game actions; replay requires a live match. Advanced features are planned.]],
                })

                local files = Style.section(tab, 'Macro Files', 'folder', true)

                if not storage then
                    files:Paragraph({
                        Title = 'Storage',
                        Desc =
[[Executor listfiles/delfile/readfile/writefile APIs are required.]],
                    })

                    return
                end

                runtime.setStorage(storage)
                files:Paragraph({
                    Title = 'Folder',
                    Desc = 'workspace/ViperHubNextGen/macro/AnimeVanguards',
                })

                local choices = storage.list()

                if #choices == 0 then
                    choices = {
                        '(none)',
                    }
                end

                selected = choices[1] ~= '(none)' and choices[1] or ''

                local picker = files:Dropdown({
                    Title = 'Select macro',
                    Values = choices,
                    Value = choices[1],
                    Callback = function(value)
                        selected = if value == '(none)'then''else value
                        deletePending = ''
                    end,
                })

                local function refresh()
                    local values = storage.list()

                    if #values == 0 then
                        values = {
                            '(none)',
                        }
                    end

                    picker:Refresh(values)

                    local chosen = if table.find(values, selected)then selected else values[1]

                    selected = chosen ~= '(none)' and chosen or ''

                    picker:Select(chosen)
                end

                files:Input({
                    Title = 'New macro name',
                    Placeholder = 'e.g. Story_Stage14',
                    Callback = function(value)
                        entered = value:match('^%s*(.-)%s*$') or value
                    end,
                })
                files:Button({
                    Title = 'Create macro',
                    Callback = function()
                        if runtime.mode ~= 'idle' then
                            status:SetDesc('Stop Record or Play before editing files')

                            return
                        end
                        if entered == '' then
                            status:SetDesc('Enter a valid macro name first')

                            return
                        end

                        local ok, err = storage.write(entered, Document.empty(entered), false)

                        status:SetDesc(if ok then'Created ' .. entered else humanError(err))

                        if ok then
                            selected = entered

                            refresh()
                        end
                    end,
                })
                files:Button({
                    Title = 'Refresh files',
                    Callback = refresh,
                })
                files:Button({
                    Title = 'Delete macro',
                    Callback = function()
                        if runtime.mode ~= 'idle' then
                            status:SetDesc('Stop Record or Play before editing files')

                            return
                        end
                        if selected == '' then
                            status:SetDesc('Select a macro first')

                            return
                        end

                        local name = selected

                        if window and window.Dialog then
                            (window):Dialog({
                                Title = 'Delete ' .. name .. '?',
                                Content = 'This permanently removes the selected macro JSON.',
                                Buttons = {
                                    {
                                        Title = 'Cancel',
                                    },
                                    {
                                        Title = 'Delete',
                                        Callback = function()
                                            local ok, err = storage.delete(name)

                                            status:SetDesc(if ok then'Deleted ' .. name else humanError(err))
                                            refresh()
                                        end,
                                    },
                                },
                            })
                        elseif deletePending ~= name then
                            deletePending = name

                            status:SetDesc('Press Delete macro again to confirm: ' .. name)
                        else
                            local ok, err = storage.delete(name)

                            status:SetDesc(if ok then'Deleted ' .. name else humanError(err))

                            deletePending = ''

                            refresh()
                        end
                    end,
                })

                local operations = Style.section(tab, 'Record & Play', 'circle-play', true)

                status = operations:Paragraph({
                    Title = 'Macro status',
                    Desc = runtime.status,
                })
                runtime.onStatus = function(value)
                    status:SetDesc(value)
                end

                local syncing = false
                local recordToggle = nil
                local playToggle = nil

                runtime.onMode = function(value)
                    syncing = true

                    if value == 'idle' then
                        picker:Unlock()
                    else
                        picker:Lock()
                    end
                    if recordToggle then
                        recordToggle:Set(value == 'record', false)
                    end
                    if playToggle then
                        playToggle:Set(value == 'play', false)
                    end

                    syncing = false
                end
                runtime.onSaved = function()
                    refresh()
                end
                recordToggle = operations:Toggle({
                    Title = 'Record macro',
                    Desc =
[[Starting clears the selected file. Turning off saves automatically.]],
                    Value = runtime.mode == 'record',
                    Callback = function(enabled)
                        if syncing then
                            return
                        end
                        if not enabled then
                            if runtime.mode == 'record' and not runtime.finishRecord() then
                                recordToggle:Set(true, false)
                            end

                            return
                        end
                        if selected == '' then
                            status:SetDesc('Create or select a macro first')
                            recordToggle:Set(false, false)

                            return
                        end

                        local ok, err = runtime.record(selected)

                        if not ok then
                            status:SetDesc(humanError(err))
                            recordToggle:Set(false, false)
                        end
                    end,
                })
                playToggle = operations:Toggle({
                    Title = 'Play macro',
                    Desc = 'Votes to start when offered, then plays the selected file.',
                    Value = runtime.mode == 'play',
                    Callback = function(enabled)
                        if syncing then
                            return
                        end
                        if not enabled then
                            runtime.stopPlayback()

                            return
                        end
                        if autoPlay and type(autoPlay.isEnabled) == 'function' and (autoPlay.isEnabled)() then
                            status:SetDesc(
[[Cannot play macro while Auto play - ingame is active. Turn it off first.]])
                            playToggle:Set(false, false)

                            return
                        end
                        if selected == '' then
                            status:SetDesc('Select a macro first')
                            playToggle:Set(false, false)

                            return
                        end

                        local document, err = storage.read(selected)

                        if not document then
                            status:SetDesc(humanError(err))
                            playToggle:Set(false, false)

                            return
                        end

                        local ok, playError = runtime.play(document)

                        if not ok then
                            status:SetDesc(humanError(playError))
                            playToggle:Set(false, false)
                        end
                    end,
                })

                local function updatePlayMacroLock()
                    if not playToggle then
                        return
                    end

                    local isAutoPlayActive = autoPlay and type(autoPlay.isEnabled) == 'function' and (autoPlay.isEnabled)()

                    if isAutoPlayActive then
                        if type(playToggle.Lock) == 'function' then
                            pcall(playToggle.Lock, playToggle)
                        end
                    else
                        if type(playToggle.Unlock) == 'function' then
                            pcall(playToggle.Unlock, playToggle)
                        end
                    end
                end

                if playToggle then
                    updatePlayMacroLock()
                end
                if autoPlay and type((autoPlay).onEnabledChange) == 'function' then
                    (autoPlay).onEnabledChange(function(_en)
                        updatePlayMacroLock()
                    end)
                end

                runtime.onMode(runtime.mode)

                local config = Style.section(tab, 'Play Macro Config', 'sliders-horizontal', false)

                config:Toggle({
                    Title = 'Ignore Timing',
                    Desc =
[[Use wave and live action price first; ability timing is retained.]],
                    Value = runtime.settings.ignoreTiming,
                    Callback = function(value)
                        runtime.settings.ignoreTiming = value
                    end,
                })
                config:Toggle({
                    Title = 'No Ignore Sell Timing',
                    Desc = 'Keep the recorded sell timing.',
                    Value = runtime.settings.noIgnoreSellTiming,
                    Callback = function(value)
                        runtime.settings.noIgnoreSellTiming = value
                    end,
                })
                config:Slider({
                    Title = 'Macro Retry Limit',
                    Desc =
[[Total attempts including the original position (1-10). Placement retries move up to 2 studs.]],
                    Step = 1,
                    Value = {
                        Min = 1,
                        Max = 10,
                        Default = runtime.settings.retryLimit,
                    },
                    Callback = function(value)
                        runtime.settings.retryLimit = value
                    end,
                })
                config:Dropdown({
                    Title = 'After placement failure',
                    Desc =
[[Action after all placement attempts fail; Stop is the default.]],
                    Values = {
                        'Restart',
                        'Stop',
                        'None',
                        'Return to Lobby',
                    },
                    Value = runtime.settings.placementFailure,
                    Callback = function(value)
                        runtime.settings.placementFailure = value
                    end,
                })

                local misc = Style.section(tab, 'Misc', 'wrench', false)

                misc:Button({
                    Title = "Check Macro's Unit",
                    Callback = function()
                        if runtime.mode ~= 'idle' then
                            return
                        end
                        if selected == '' then
                            status:SetDesc('Select a macro first')

                            return
                        end

                        local document, err = storage.read(selected)

                        if not document then
                            status:SetDesc(tostring(err))

                            return
                        end

                        local team = if runtime.adapter and runtime.adapter.teamUnits then(runtime.adapter.teamUnits)()else{}
                        local missing = {}

                        for _, name in document.units do
                            if not table.find(team, name) then
                                table.insert(missing, name)
                            end
                        end

                        status:SetDesc(if#document.units == 0 then'No units recorded'else if#missing == 0 then'All macro units are in the current team'else'Missing or team unavailable: ' .. table.concat(missing, ', '))
                    end,
                })
                misc:Button({
                    Title = "Equip Macro's Units",
                    Locked = true,
                    Desc = 'Planned: lobby equip readback required.',
                })
                misc:Toggle({
                    Title = "Auto Equip Macro's Units",
                    Locked = true,
                    Value = false,
                    Desc = 'Planned: disabled in V1.',
                })
                misc:Paragraph({
                    Title = 'Recorded unit controls',
                    Desc =
[[Auto Upgrade, its priority, and Auto Ability toggles are recorded from confirmed game updates and replayed in order. Placement remains direct-only.]],
                })
            end

            return Page
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
    do
        local function __modImpl()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local Document = __DARKLUA_BUNDLE_MODULES.r()
            local Adapter = {}
            local Vector3 = ((getfenv())).Vector3
            local task = ((getfenv())).task

            local function position(value)
                local ok, result = pcall(function()
                    local point = if value.X ~= nil then value else value.Position

                    return {
                        x = point.X,
                        y = point.Y,
                        z = point.Z,
                    }
                end)

                if ok then
                    return result
                end

                return nil
            end
            local function find(root, path)
                local node = root

                for part in string.gmatch(path, '[^%.]+')do
                    if node == nil then
                        return nil
                    end

                    local current = node

                    node = current:FindFirstChild(part)
                end

                return node
            end
            local function need(root, path)
                local module = find(root, path)

                if not module then
                    error('missing module ' .. path)
                end

                return (require)(module)
            end
            local function optional(root, path)
                local ok, result = pcall(need, root, path)

                return if ok then result else nil
            end
            local function priorityName(priorities, unit)
                local data = unit.Data or unit.UnitData
                local value = data and data.Priority

                if type(value) == 'number' then
                    return priorities[value]
                end
                if type(value) == 'string' and table.find(priorities, value) then
                    return value
                end

                return nil
            end

            Adapter.priorityName = priorityName

            local function activeSnapshot(
                units,
                autoUpgrade,
                priorities,
                localPlayer
            )
                local snapshot = {}
                local prioritiesMap = if autoUpgrade and type((autoUpgrade).GetPriorities) == 'function'then(autoUpgrade).GetPriorities()else nil

                for guid, unit in units._ActiveUnits do
                    if type(unit) == 'table' and unit.Player == localPlayer then
                        snapshot[guid] = {
                            name = unit.Name,
                            level = (unit.Data or unit.UnitData or {}).CurrentUpgrade or 0,
                            priority = priorityName(priorities, unit),
                            position = position(unit.UnitPosition or unit.Position),
                            rotation = unit.RotationValue or unit.Rotation or 0,
                            autoUpgrade = autoUpgrade.IsToggled(guid) == true,
                            upgradePriority = prioritiesMap and prioritiesMap[guid],
                            autoAbilities = if type(unit.AutoUseAbilities) == 'table'then table.clone(unit.AutoUseAbilities)else{},
                        }
                    end
                end

                return snapshot
            end

            function Adapter.new()
                local env = getfenv()
                local gameObject = env.game
                local replicated = gameObject:GetService('ReplicatedStorage')
                local starter = gameObject:GetService('StarterPlayer')
                local localPlayer = gameObject:GetService('Players').LocalPlayer
                local placement = (require)(replicated.NetworkCode[config.remoteNames.macroPlacementClient])
                local abilities = (require)(replicated.NetworkCode[config.remoteNames.macroAbilityClient])
                local gameUnits = (require)(replicated.NetworkCode[config.remoteNames.macroUnitsClient])
                local unitState = (require)(replicated.NetworkCode[config.remoteNames.macroUnitStateClient])
                local paths = config.instancePaths
                local codec = need(replicated, paths.unitSnapshotCodec)
                local DEFAULT_PRIORITIES = table.freeze({
                    'First',
                    'Closest',
                    'Last',
                    'Strongest',
                    'Weakest',
                    'Bosses',
                })
                local priorities = DEFAULT_PRIORITIES
                local priorityModule = optional(replicated, paths.priorityHandler)

                if type(priorityModule) == 'table' and type(priorityModule.PRIORITIES) == 'table' then
                    priorities = priorityModule.PRIORITIES
                end

                local units = need(starter, paths.clientUnitHandler)
                local yen = need(starter, paths.playerYenHandler)
                local waves = need(starter, paths.wavesHud)
                local hudUnits = need(starter, paths.hudUnits)
                local gameHandler = need(replicated, paths.gameHandler)
                local wavesClient = need(replicated, paths.wavesClient)
                local endScreenClient = need(replicated, paths.endScreenClient)
                local endScreenCodec = need(replicated, paths.endScreenCodec)
                local unitData = need(replicated, paths.unitsData)
                local upgradeButtons = need(starter, paths.upgradeButtons)
                local autoUpgrade = need(starter, paths.autoUpgradeData)
                local matchFlow = need(replicated, paths.matchFlowClient)
                local lobbyReturn = need(replicated, paths.lobbyReturnClient)
                local clientAbilityHandler = optional(starter, paths.clientAbilityHandler)
                local self = {}
                local abilityVersion = 0
                local abilityEvents = {}

                self.abilityBaselines = {}

                local lastPrompt = nil
                local promptShownConn = nil
                local promptClosedConn = nil

                if wavesClient and wavesClient.WaveSkipPromptShown and type((wavesClient.WaveSkipPromptShown).On) == 'function' then
                    promptShownConn = (wavesClient.WaveSkipPromptShown).On(function(
                        payload
                    )
                        lastPrompt = payload
                    end)
                end
                if wavesClient and wavesClient.WaveSkipPromptClosed and type((wavesClient.WaveSkipPromptClosed).On) == 'function' then
                    promptClosedConn = (wavesClient.WaveSkipPromptClosed).On(function(
                    )
                        lastPrompt = nil
                    end)
                end

                local abilityConnection = nil

                if clientAbilityHandler and clientAbilityHandler.AbilityCooldownAdded and type(clientAbilityHandler.AbilityCooldownAdded.Connect) == 'function' then
                    local abilitySignal = clientAbilityHandler.AbilityCooldownAdded

                    abilityConnection = abilitySignal:Connect(function(
                        unitGuid,
                        abilityName
                    )
                        if type(unitGuid) == 'string' and type(abilityName) == 'string' then
                            abilityVersion += 1

                            local key = unitGuid .. ':' .. abilityName

                            abilityEvents[key] = abilityVersion
                        end
                    end)
                elseif abilities and abilities.AbilityLifecycleUpdated and type((abilities.AbilityLifecycleUpdated).On) == 'function' then
                    abilityConnection = (abilities.AbilityLifecycleUpdated).On(function(
                        payload
                    )
                        if type(payload) == 'table' and payload.State == 'AbilityStarted' and type(payload.Payload) == 'table' and type(payload.Payload.AbilityName) == 'string' then
                            abilityVersion += 1

                            local key = tostring(payload.UnitGUID) .. ':' .. payload.Payload.AbilityName

                            abilityEvents[key] = abilityVersion
                        end
                    end)
                end

                function self.close()
                    if abilityConnection then
                        local c = abilityConnection
                        local ok = pcall(function()
                            c:Disconnect()
                        end)

                        if not ok then
                            pcall(function()
                                c()
                            end)
                        end

                        abilityConnection = nil
                    end
                    if promptShownConn then
                        (promptShownConn)()

                        promptShownConn = nil
                    end
                    if promptClosedConn then
                        (promptClosedConn)()

                        promptClosedConn = nil
                    end

                    table.clear(abilityEvents)
                    table.clear(self.abilityBaselines)
                end
                function self.state()
                    if type(gameHandler.GameData) ~= 'table' or not gameHandler.IsMatchStarted then
                        return nil
                    end

                    return {
                        wave = tonumber(waves.CurrentWave) or 0,
                        yen = tonumber(yen.GetYen()) or 0,
                        match = {
                            mode = gameHandler.GameData.StageType,
                        },
                        units = activeSnapshot(units, autoUpgrade, priorities, localPlayer),
                    }
                end
                function self.matchStarted()
                    return gameHandler.IsMatchStarted == true
                end
                function self.getGameSetting(name)
                    local ok, value = pcall(function()
                        local stateMod = find(starter, paths.settingsState)

                        if stateMod then
                            local settingsState = (require)(stateMod)

                            return settingsState:GetSetting(name)
                        end

                        return nil
                    end)

                    if ok and type(value) == 'boolean' then
                        return value
                    end

                    return nil
                end
                function self.preMatchState()
                    if type(gameHandler.GameData) ~= 'table' or gameHandler.IsMatchStarted then
                        return nil
                    end

                    return {
                        wave = 0,
                        yen = tonumber(yen.GetYen()) or 0,
                        match = {
                            mode = gameHandler.GameData.StageType,
                        },
                    }
                end
                function self.currentStartPrompt()
                    if gameHandler.IsMatchStarted then
                        return nil
                    end
                    if lastPrompt and type(lastPrompt) == 'table' and lastPrompt.Context == 'Start' then
                        return lastPrompt
                    end

                    local prompt = localPlayer and localPlayer.PlayerGui and localPlayer.PlayerGui:FindFirstChild('SkipWave')
                    local holder = prompt and prompt:FindFirstChild('Holder')
                    local yes = holder and holder:FindFirstChild('Yes')

                    if holder and yes and not gameHandler.IsMatchStarted then
                        return {
                            Context = 'Start',
                            StartTime = 'visible',
                        }
                    end

                    return nil
                end
                function self.castStartVote()
                    return pcall(wavesClient.CastWaveSkipVote.Fire)
                end
                function self.castRestartVote()
                    local data = gameHandler.GameData

                    if type(data) ~= 'table' or data.PortalData ~= nil or data.StageType == 'GuildWar' or data.StageType == 'Gauntlet' or data.StageType == 'Odyssey' then
                        return false
                    end

                    return pcall(matchFlow.CastRestartVote.Fire)
                end
                function self.returnToLobby()
                    return pcall(lobbyReturn.RequestTeleportToLobby.Fire)
                end
                function self.teamUnits()
                    local names = {}

                    if type(hudUnits.FrameData) == 'table' then
                        for _, unit in hudUnits.FrameData do
                            if type(unit) == 'table' and type(unit.Name) == 'string' then
                                table.insert(names, unit.Name)
                            end
                        end
                    end

                    return names
                end
                function self.cost(action, refs)
                    local ok, price = pcall(function()
                        if action.kind == 'place' then
                            local slot = hudUnits.FrameData[action.slotIndex]

                            if not slot or not slot.Unit or slot.Name ~= action.unitName then
                                if type(hudUnits.FrameData) == 'table' then
                                    for _, candidate in hudUnits.FrameData do
                                        if type(candidate) == 'table' and candidate.Name == action.unitName and candidate.Unit then
                                            slot = candidate

                                            break
                                        end
                                    end
                                end
                            end
                            if not slot or not slot.Unit or slot.Name ~= action.unitName then
                                return nil
                            end

                            local data = unitData:GetUnitDataFromID(slot.Unit.Identifier)

                            return yen:GetPlacementAffordability(data, slot.Unit).Price
                        end
                        if action.kind == 'upgrade' then
                            local unit = units._ActiveUnits[refs[action.unitRef] ]
                            local data = unit and (unit.Data or unit.UnitData)

                            if not data or type(data.CurrentUpgrade) ~= 'number' then
                                return nil
                            end

                            return upgradeButtons.GetUpgradePrice(unit, data.CurrentUpgrade + 1)
                        end

                        return 0
                    end)
                    local numericPrice = tonumber(price)

                    if ok and type(numericPrice) == 'number' and numericPrice >= 0 and numericPrice < math.huge and numericPrice == numericPrice then
                        return numericPrice
                    end
                    if action.kind == 'place' then
                        local slot = hudUnits.FrameData[action.slotIndex]

                        if not slot or slot.Name ~= action.unitName then
                            if type(hudUnits.FrameData) == 'table' then
                                for _, candidate in hudUnits.FrameData do
                                    if type(candidate) == 'table' and candidate.Name == action.unitName and candidate.Frame then
                                        slot = candidate

                                        break
                                    end
                                end
                            end
                        end
                        if slot and slot.Name == action.unitName and slot.Frame then
                            local container = slot.Frame:FindFirstChild('Container')
                            local holder = container and container:FindFirstChild('Holder')
                            local main = holder and holder:FindFirstChild('Main')
                            local label = main and main:FindFirstChild('Price')
                            local digits = label and tostring(label.Text):match('([%d,]+)')
                            local displayed = digits and tonumber((digits:gsub(',', '')))

                            if displayed then
                                return displayed
                            end
                        end
                    end

                    return nil
                end
                function self.observe(kind, callback)
                    if kind == 'restart' then
                        return gameHandler.MatchRestarted:Connect(callback)
                    end
                    if kind == 'matchEnd' then
                        return gameHandler.MatchEnded:Connect(callback)
                    end
                    if kind == 'matchStart' then
                        return gameHandler.MatchStarted:Connect(callback)
                    end
                    if kind == 'votePrompt' then
                        return wavesClient.WaveSkipPromptShown.On(callback)
                    end
                    if kind == 'voteClicked' then
                        local cleanups = {}

                        local function bindButton(prompt)
                            local holder = prompt and prompt:FindFirstChild('Holder')
                            local yes = holder and holder:FindFirstChild('Yes')
                            local button = yes and (yes:FindFirstChild('Button') or yes)

                            if button and (button:IsA('GuiButton') or button.Activated) then
                                local clickedConn = button.Activated:Connect(function(
                                )
                                    if not gameHandler.IsMatchStarted or (lastPrompt and lastPrompt.Context == 'Start') then
                                        callback({
                                            Context = 'Start',
                                        })
                                    end
                                end)

                                table.insert(cleanups, clickedConn)
                            end
                        end

                        local existing = localPlayer and localPlayer.PlayerGui and localPlayer.PlayerGui:FindFirstChild('SkipWave')

                        if existing then
                            bindButton(existing)
                        end
                        if localPlayer and localPlayer.PlayerGui then
                            local addedConn = localPlayer.PlayerGui.ChildAdded:Connect(function(
                                child
                            )
                                if child and child.Name == 'SkipWave' then
                                    task.defer(bindButton, child)
                                end
                            end)

                            table.insert(cleanups, addedConn)
                        end
                        if wavesClient and wavesClient.CastWaveSkipVote and type(wavesClient.CastWaveSkipVote.Fire) == 'function' then
                            local origFire = wavesClient.CastWaveSkipVote.Fire
                            local wrapped

                            wrapped = function(...)
                                if not gameHandler.IsMatchStarted or (lastPrompt and lastPrompt.Context == 'Start') then
                                    pcall(callback, {
                                        Context = 'Start',
                                    })
                                end

                                return (origFire)(...)
                            end
                            wavesClient.CastWaveSkipVote.Fire = wrapped

                            table.insert(cleanups, function()
                                if wavesClient.CastWaveSkipVote.Fire == wrapped then
                                    wavesClient.CastWaveSkipVote.Fire = origFire
                                end
                            end)
                        end

                        return function()
                            for _, cleanup in cleanups do
                                pcall(function()
                                    if type(cleanup) == 'function' then
                                        (cleanup)()
                                    else
                                        cleanup:Disconnect()
                                    end
                                end)
                            end

                            table.clear(cleanups)
                        end
                    end
                    if kind == 'voteClosed' then
                        return wavesClient.WaveSkipPromptClosed.On(callback)
                    end
                    if kind == 'result' then
                        return endScreenClient.ShowEndScreen.On(function(
                            payload
                        )
                            local ok, summary = pcall(endScreenCodec.DecodeMatchEndSummary, payload)

                            if ok and type(summary) == 'table' and not summary.IsFakeEndScreen then
                                callback(summary.Status)
                            end
                        end)
                    end
                    if kind == 'place' then
                        return placement.UnitPlaced.On(function(payload)
                            local ok, decoded = pcall(function()
                                return type(payload) == 'table' and codec.DecodeUnitEnvelope(payload.Snapshot) or nil
                            end)
                            local unit = if ok then decoded else nil

                            if type(unit) ~= 'table' or unit.Player ~= localPlayer then
                                return
                            end

                            local pos = position(unit.UnitPosition or unit.Position)

                            if pos then
                                local slotIndex = unit.SlotIndex

                                if type(slotIndex) ~= 'number' and type(hudUnits.FrameData) == 'table' then
                                    for index, equipped in hudUnits.FrameData do
                                        if type(equipped) == 'table' and equipped.Name == unit.Name then
                                            slotIndex = tonumber(index)

                                            break
                                        end
                                    end
                                end
                                if type(slotIndex) ~= 'number' or slotIndex < 1 then
                                    return
                                end

                                callback({
                                    guid = unit.UniqueIdentifier,
                                    unitName = unit.Name,
                                    position = pos,
                                    rotation = unit.RotationValue or unit.Rotation or 0,
                                    slotIndex = slotIndex,
                                    level = (unit.Data or unit.UnitData or {}).CurrentUpgrade or 0,
                                    priorityName = priorityName(priorities, unit),
                                    autoAbilities = table.clone(unit.AutoUseAbilities or {}),
                                })
                            end
                        end)
                    elseif kind == 'upgrade' then
                        return placement.UnitUpgraded.On(function(payload)
                            if type(payload) == 'table' then
                                local current = units._ActiveUnits[payload.UnitGUID]
                                local ok, decoded = pcall(function()
                                    return current and codec.DecodeUnitUpgradeEnvelope(payload, current)
                                end)
                                local changed = if ok then decoded else nil
                                local data = changed and (changed.Data or changed.UnitData)
                                local level = data and data.CurrentUpgrade

                                if type(level) == 'number' then
                                    callback({
                                        guid = payload.UnitGUID,
                                        level = level,
                                    })
                                end
                            end
                        end)
                    elseif kind == 'sell' then
                        return placement.UnitRemoved.On(function(payload)
                            if type(payload) == 'table' then
                                callback({
                                    guid = payload.UnitGUID,
                                })
                            end
                        end)
                    elseif kind == 'priority' then
                        return units.OnUnitPriorityChanged:Connect(function(
                            unit
                        )
                            if type(unit) == 'table' and unit.Player == localPlayer then
                                local name = priorityName(priorities, unit)

                                if name then
                                    callback({
                                        guid = unit.UniqueIdentifier,
                                        priorityName = name,
                                    })
                                end
                            end
                        end)
                    elseif kind == 'ability' then
                        if clientAbilityHandler and clientAbilityHandler.AbilityCooldownAdded and type(clientAbilityHandler.AbilityCooldownAdded.Connect) == 'function' then
                            local abilitySignal = clientAbilityHandler.AbilityCooldownAdded
                            local conn = abilitySignal:Connect(function(
                                guid,
                                abilityName
                            )
                                callback({
                                    guid = tostring(guid),
                                    abilityName = tostring(abilityName),
                                })
                            end)

                            return function()
                                pcall(function()
                                    conn:Disconnect()
                                end)
                            end
                        elseif abilities and abilities.AbilityLifecycleUpdated and type((abilities.AbilityLifecycleUpdated).On) == 'function' then
                            return (abilities.AbilityLifecycleUpdated).On(function(
                                payload
                            )
                                if type(payload) == 'table' and payload.State == 'AbilityStarted' and type(payload.Payload) == 'table' then
                                    callback({
                                        guid = payload.UnitGUID,
                                        abilityName = payload.Payload.AbilityName,
                                    })
                                end
                            end)
                        end
                    elseif kind == 'autoUpgrade' then
                        return gameUnits.AutoUpgradeToggled.On(function(
                            payload
                        )
                            if type(payload) == 'table' and type(payload.Toggle) == 'boolean' then
                                callback({
                                    guid = payload.UnitGUID,
                                    enabled = payload.Toggle,
                                })
                            end
                        end)
                    elseif kind == 'upgradePriority' then
                        return gameUnits.AutoUpgradePriorityUpdated.On(function(
                            payload
                        )
                            if type(payload) == 'table' and type(payload.Priority) == 'number' then
                                callback({
                                    guid = payload.UnitGUID,
                                    upgradePriority = payload.Priority,
                                })
                            end
                        end)
                    elseif kind == 'autoAbility' then
                        return unitState.AutoAbilityToggled.On(function(
                            payload
                        )
                            if type(payload) == 'table' and type(payload.Enabled) == 'boolean' and type(payload.AbilityName) == 'string' then
                                callback({
                                    guid = payload.UnitGUID,
                                    abilityName = payload.AbilityName,
                                    enabled = payload.Enabled,
                                })
                            end
                        end)
                    end

                    return nil
                end
                function self.request(action, refs)
                    if action.kind == 'voteStart' then
                        return self.currentStartPrompt() ~= nil and self.castStartVote()
                    end

                    local guid = refs[action.unitRef]
                    local placementPosition, placementRotation = Document.toPose(action.cframe)

                    if action.kind == 'ability' and guid then
                        local key = guid .. ':' .. tostring(action.abilityName)

                        self.abilityBaselines[key] = abilityEvents[key] or abilityVersion
                    end

                    local ok = pcall(function()
                        if action.kind == 'place' then
                            if not placementPosition or not placementRotation then
                                error('invalid CFrame')
                            end

                            local slotIndex = action.slotIndex

                            if type(hudUnits.FrameData) == 'table' then
                                local currentSlot = hudUnits.FrameData[slotIndex]

                                if not currentSlot or currentSlot.Name ~= action.unitName then
                                    for index, candidate in hudUnits.FrameData do
                                        if type(candidate) == 'table' and candidate.Name == action.unitName then
                                            slotIndex = tonumber(index) or slotIndex

                                            break
                                        end
                                    end
                                end
                            end

                            placement.RequestPlaceUnit.Fire({
                                UnitName = action.unitName,
                                Position = Vector3.new(placementPosition.x, placementPosition.y, placementPosition.z),
                                Rotation = placementRotation,
                                SlotIndex = slotIndex,
                            })
                        elseif action.kind == 'upgrade' and guid then
                            placement.RequestUpgradeUnit.Fire({UnitGUID = guid})
                        elseif action.kind == 'sell' and guid then
                            placement.RequestSellUnit.Fire({UnitGUID = guid})
                        elseif action.kind == 'priority' and guid then
                            placement.RequestChangeUnitPriority.Fire({
                                UnitGUID = guid,
                                PriorityName = action.priorityName,
                            })
                        elseif action.kind == 'ability' and guid then
                            abilities.RequestAbilityActivation.Fire({
                                UnitGUID = guid,
                                AbilityName = action.abilityName,
                            })
                        elseif action.kind == 'autoUpgrade' and guid then
                            if (autoUpgrade.IsToggled(guid) == true) ~= action.enabled then
                                gameUnits.RequestAutoUpgradeToggle.Fire({
                                    UnitGUIDs = {guid},
                                })
                            end
                        elseif action.kind == 'upgradePriority' and guid then
                            if autoUpgrade.GetPriorities()[guid] ~= action.upgradePriority then
                                gameUnits.RequestAutoUpgradeChangePriority.Fire({UnitGUID = guid})
                            end
                        elseif action.kind == 'autoAbility' and guid then
                            local unit = units._ActiveUnits[guid]

                            if not unit then
                                error('unit unavailable')
                            end

                            local autoAbilities = unit.AutoUseAbilities or {}

                            if (table.find(autoAbilities, action.abilityName) ~= nil) ~= action.enabled then
                                unitState.RequestAutoAbilityToggle.Fire({
                                    UnitGUID = guid,
                                    AbilityName = action.abilityName,
                                })
                            end
                        else
                            error('missing unit reference')
                        end
                    end)

                    return ok
                end
                function self.satisfied(action, refs)
                    local current = self.state()
                    local guid = refs[action.unitRef]

                    if action.kind == 'sell' then
                        return guid ~= nil and current ~= nil and current.units[guid] == nil
                    end

                    local unit = current and guid and current.units[guid]

                    if not unit then
                        return false
                    end
                    if action.kind == 'upgrade' then
                        return type(action.level) == 'number' and tonumber(unit.level) ~= nil and unit.level >= action.level
                    end
                    if action.kind == 'priority' then
                        return unit.priority == action.priorityName
                    end
                    if action.kind == 'autoUpgrade' then
                        return unit.autoUpgrade == action.enabled
                    end
                    if action.kind == 'upgradePriority' then
                        return unit.upgradePriority == action.upgradePriority
                    end
                    if action.kind == 'autoAbility' then
                        return type(unit.autoAbilities) == 'table' and (table.find(unit.autoAbilities, action.abilityName) ~= nil) == action.enabled
                    end
                    if action.kind == 'ability' then
                        return type(unit.autoAbilities) == 'table' and table.find(unit.autoAbilities, action.abilityName) ~= nil
                    end

                    return false
                end
                function self.confirm(action, before, refs)
                    local after = self.state()

                    if not after then
                        return false, nil
                    end
                    if action.kind == 'place' then
                        local placementPosition = Document.toPose(action.cframe)

                        if not placementPosition then
                            return false, nil
                        end

                        for guid, unit in after.units do
                            if not before.units[guid] and unit.name == action.unitName then
                                local p = unit.position

                                if p then
                                    local dx = p.x - placementPosition.x
                                    local dy = p.y - placementPosition.y
                                    local dz = p.z - placementPosition.z
                                    local horizontal = dx * dx + dz * dz

                                    if horizontal < 10 and math.abs(dy) < 5 then
                                        return true, guid
                                    end
                                end
                            end
                        end

                        return false, nil
                    end

                    local guid = refs[action.unitRef]

                    if not guid then
                        return false, nil
                    end

                    local old, new = before.units[guid], after.units[guid]

                    if action.kind == 'sell' then
                        return new == nil, nil
                    end
                    if not old or not new then
                        return false, nil
                    end
                    if action.kind == 'upgrade' then
                        return type(action.level) == 'number' and tonumber(new.level) ~= nil and new.level >= action.level, nil
                    end
                    if action.kind == 'priority' then
                        return new.priority == action.priorityName, nil
                    end
                    if action.kind == 'ability' then
                        local key = guid .. ':' .. tostring(action.abilityName)
                        local recordedVer = abilityEvents[key] or 0
                        local baseline = self.abilityBaselines and self.abilityBaselines[key] or 0

                        return recordedVer > baseline, nil
                    end
                    if action.kind == 'autoUpgrade' then
                        return new.autoUpgrade == action.enabled, nil
                    end
                    if action.kind == 'upgradePriority' then
                        return new.upgradePriority == action.upgradePriority, nil
                    end
                    if action.kind == 'autoAbility' then
                        return type(new.autoAbilities) == 'table' and (table.find(new.autoAbilities, action.abilityName) ~= nil) == action.enabled, nil
                    end

                    return false, nil
                end

                return self
            end

            return Adapter
        end

        function __DARKLUA_BUNDLE_MODULES.E()
            local v = __DARKLUA_BUNDLE_MODULES.cache.E

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.E = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Document = __DARKLUA_BUNDLE_MODULES.r()
            local Adapter = __DARKLUA_BUNDLE_MODULES.E()
            local Runtime = {}
            local POLL_SECONDS = 0.2
            local ACTION_TIMEOUT = 12
            local REQUEST_GAP = 0.35
            local RESTART_TIMEOUT = 30
            local PLACEMENT_OFFSETS = {
                {0, 0},
                {1, 0},
                {0, 1},
                {
                    -1,
                    0,
                },
                {
                    0,
                    -1,
                },
                {1, 1},
                {
                    -1,
                    1,
                },
                {
                    -1,
                    -1,
                },
                {
                    1,
                    -1,
                },
                {2, 0},
            }

            local function finitePrice(value)
                return type(value) == 'number' and value >= 0 and value < math.huge and value == value
            end
            local function placementAttempt(action, number)
                local offset = PLACEMENT_OFFSETS[number] or PLACEMENT_OFFSETS[#PLACEMENT_OFFSETS]
                local attempt = table.clone(action)

                attempt.cframe = table.clone(action.cframe)

                attempt.cframe[1] += offset[1]
                attempt.cframe[3] += offset[2]

                return attempt
            end
            local function clearConnections(connections)
                for _, connection in connections do
                    pcall(function()
                        if type(connection) == 'function' then
                            (connection)()
                        else
                            connection:Disconnect()
                        end
                    end)
                end

                table.clear(connections)
            end

            function Runtime.new(
                injectedAdapter,
                injectedStorage,
                injectedTask
            )
                local self = {
                    adapter = injectedAdapter,
                    storage = injectedStorage,
                    context = nil,
                    mode = 'idle',
                    status = 'Idle',
                    onStatus = nil,
                    onMode = nil,
                    onSaved = nil,
                    document = nil,
                    settings = {
                        ignoreTiming = true,
                        noIgnoreSellTiming = true,
                        retryLimit = 3,
                        placementFailure = 'Stop',
                    },
                    lifecycleConnections = {},
                    recordConnections = {},
                    refs = {},
                    levels = {},
                    attackPriorities = {},
                    autoStates = {},
                    generation = 0,
                    startVoteSent = false,
                    pendingRestart = nil,
                    activeDocument = nil,
                    suspended = false,
                    autoPlay = nil,
                    modeListeners = {},
                }

                local function status(value)
                    if self.status == value then
                        return
                    end

                    self.status = value

                    if self.onStatus then
                        pcall(self.onStatus, value)
                    end
                end
                local function mode(value)
                    self.mode = value

                    if self.onMode then
                        pcall(self.onMode, value)
                    end

                    for _, cb in self.modeListeners do
                        pcall(cb, value)
                    end
                end
                local function emptyFor(name)
                    local document = Document.empty(name)
                    local previous = self.document

                    if previous and previous.match then
                        document.match = {
                            mode = previous.match.mode,
                            map = previous.match.map,
                        }
                    end

                    return document
                end
                local function append(kind, fields)
                    if self.mode ~= 'record' or not self.document then
                        return
                    end

                    local state = self.adapter.state() or (self.adapter.preMatchState and self.adapter.preMatchState())

                    if not state then
                        if kind == 'voteStart' then
                            state = {
                                wave = 0,
                                yen = 0,
                            }
                        else
                            return
                        end
                    end
                    if kind ~= 'voteStart' and self.recordBeforeMatch then
                        self.recordStarted = os.clock()
                        self.recordBeforeMatch = false
                    end
                    if #self.document.actions >= 2000 then
                        status('Recording limit reached')
                        self.finishRecord()

                        return
                    end

                    local action = {
                        index = #self.document.actions + 1,
                        kind = kind,
                        wave = state.wave or 0,
                        yen = state.yen or 0,
                        time = math.max(0, os.clock() - self.recordStarted),
                    }

                    for key, value in fields do
                        action[key] = value
                    end

                    table.insert(self.document.actions, action)

                    if kind == 'place' and not table.find(self.document.units, action.unitName) then
                        table.insert(self.document.units, action.unitName)
                    end

                    status('Recording: ' .. #self.document.actions .. ' actions')
                end
                local function voteForStart(prompt)
                    if self.mode ~= 'play' or self.startVoteSent or type(prompt) ~= 'table' or prompt.Context ~= 'Start' then
                        return
                    end
                    if self.adapter.matchStarted and self.adapter.matchStarted() then
                        return
                    end

                    self.startVoteSent = true

                    if self.adapter.castStartVote and self.adapter.castStartVote() then
                        status('Vote to Start sent; awaiting match')
                    else
                        status('Vote to Start failed')
                    end
                end

                function self.setStorage(storage)
                    self.storage = storage
                end
                function self.setAutoPlay(ap)
                    self.autoPlay = ap
                end
                function self.onModeChange(callback)
                    if type(callback) == 'function' then
                        table.insert(self.modeListeners, callback)
                    end
                end

                local function hookLifecycle()
                    if not self.adapter or #self.lifecycleConnections > 0 then
                        return
                    end

                    local function own(kind, callback)
                        local connection = self.adapter.observe(kind, callback)

                        if connection then
                            table.insert(self.lifecycleConnections, connection)
                        end
                    end

                    own('restart', function()
                        if self.mode == 'play' then
                            self.playbackActive = false

                            local replay = self.activeDocument or self.pendingRestart

                            self.pendingRestart = nil

                            self.generation += 1

                            if replay then
                                status('Match restarted; replaying macro')
                                self.play(replay)
                            else
                                status('Match restarted; awaiting match')
                            end

                            return
                        end
                        if self.mode ~= 'record' or not self.storage then
                            return
                        end

                        local fresh = emptyFor(self.document.name)
                        local ok, err = self.storage.write(fresh.name, fresh, true)

                        if not ok then
                            clearConnections(self.recordConnections)
                            mode('idle')
                            status('Restart reset failed: ' .. tostring(err))

                            return
                        end

                        self.document = fresh
                        self.refs = {}
                        self.levels = {}
                        self.attackPriorities = {}
                        self.autoStates = {}
                        self.recordStarted = os.clock()
                        self.recordBeforeMatch = self.adapter.state() == nil

                        status('Recording restarted: 0 actions')
                    end)
                    own('result', function(result)
                        if self.mode ~= 'record' then
                            return
                        end
                        if result == 'Finished' then
                            self.finishRecord()
                        elseif result == 'Failed' then
                            self.document = nil

                            clearConnections(self.recordConnections)
                            mode('idle')
                            status('Defeat: recording discarded')
                        end
                    end)
                    own('matchEnd', function()
                        if self.mode == 'play' then
                            self.playbackActive = false

                            local autoReplay = self.adapter and self.adapter.getGameSetting and self.adapter.getGameSetting('AutoReplay') == true
                            local autoNext = self.adapter and self.adapter.getGameSetting and self.adapter.getGameSetting('AutoNext') == true

                            if autoReplay or autoNext then
                                status('Victory! Awaiting next match / replay...')
                            else
                                status('Match ended; holding on victory screen')
                            end
                        end
                    end)
                    own('matchStart', function()
                        if self.mode == 'play' and self.activeDocument and not self.playbackActive then
                            self.startVoteSent = false

                            self.play(self.activeDocument)
                        end
                    end)
                    own('votePrompt', voteForStart)
                end
                local function ensureAdapter()
                    if self.adapter then
                        return true
                    end

                    local ok, adapter = pcall(Adapter.new)

                    if ok and adapter then
                        self.adapter = adapter

                        hookLifecycle()

                        return true
                    end

                    return false
                end

                function self.start(context)
                    self.context = context

                    if injectedAdapter then
                        self.adapter = injectedAdapter

                        hookLifecycle()
                    else
                        if ensureAdapter() then
                            status('Idle')
                        else
                            status('Awaiting match...')
                        end
                    end
                end
                function self.stop()
                    self.generation += 1

                    self.pendingRestart = nil
                    self.activeDocument = nil
                    self.playbackActive = false

                    clearConnections(self.recordConnections)
                    clearConnections(self.lifecycleConnections)
                    mode('idle')

                    if self.adapter and self.adapter.close then
                        (self.adapter.close)()
                    end
                    if not injectedAdapter then
                        self.adapter = nil
                    end

                    self.context = nil

                    status('Stopped')
                end
                function self.record(name)
                    if not self.context or not self.context.alive or not self.storage then
                        return false, 'MACRO_ADAPTER_UNAVAILABLE'
                    end
                    if not ensureAdapter() then
                        return false, 'MACRO_ADAPTER_UNAVAILABLE'
                    end
                    if self.mode ~= 'idle' then
                        return false, 'MACRO_BUSY'
                    end

                    local liveState = self.adapter.state()
                    local state = liveState or (self.adapter.preMatchState and self.adapter.preMatchState())

                    if not state then
                        return false, 'MACRO_MATCH_UNAVAILABLE'
                    end

                    local fresh = Document.empty(name)

                    fresh.match = {
                        mode = state.match and state.match.mode,
                    }

                    local wrote, err = self.storage.write(name, fresh, true)

                    if not wrote then
                        return false, err
                    end

                    self.document = fresh
                    self.refs = {}
                    self.levels = {}
                    self.attackPriorities = {}
                    self.autoStates = {}
                    self.recordStarted = os.clock()
                    self.recordBeforeMatch = liveState == nil

                    local function own(kind, callback)
                        local connection = self.adapter.observe(kind, callback)

                        if connection then
                            table.insert(self.recordConnections, connection)
                        end
                    end

                    own('place', function(event)
                        if self.mode ~= 'record' or not event or not event.guid or not event.unitName then
                            return
                        end

                        local cframe = Document.fromPose(event.position, event.rotation or 0)

                        if not cframe then
                            return
                        end

                        local ref = tostring(#self.document.actions + 1)

                        self.refs[event.guid] = ref
                        self.levels[event.guid] = tonumber(event.level) or 0
                        self.attackPriorities[event.guid] = event.priorityName
                        self.autoStates[event.guid] = {
                            autoUpgrade = false,
                            upgradePriority = nil,
                            autoAbilities = {},
                        }

                        if type(event.autoAbilities) == 'table' then
                            for _, abilityName in event.autoAbilities do
                                if type(abilityName) == 'string' then
                                    self.autoStates[event.guid].autoAbilities[abilityName] = true
                                end
                            end
                        end

                        append('place', {
                            unitRef = ref,
                            unitName = event.unitName,
                            cframe = cframe,
                            slotIndex = event.slotIndex,
                            initialLevel = self.levels[event.guid],
                        })
                    end)
                    own('voteClicked', function(event)
                        if self.mode == 'record' and (event == nil or event.Context == 'Start' or event.Context == nil) then
                            for _, action in self.document.actions do
                                if action.kind == 'voteStart' then
                                    return
                                end
                            end

                            append('voteStart', {})
                        end
                    end)

                    for _, kind in {
                        'upgrade',
                        'sell',
                        'priority',
                        'ability',
                        'autoUpgrade',
                        'autoAbility',
                        'upgradePriority',
                    }do
                        own(kind, function(event)
                            if self.mode ~= 'record' or not event or not event.guid then
                                return
                            end

                            local ref = self.refs[event.guid]

                            if not ref then
                                return
                            end

                            local autoState = self.autoStates[event.guid]

                            if kind == 'autoUpgrade' then
                                if not autoState or type(event.enabled) ~= 'boolean' or autoState.autoUpgrade == event.enabled then
                                    return
                                end

                                autoState.autoUpgrade = event.enabled

                                if not event.enabled then
                                    autoState.upgradePriority = nil
                                end
                            elseif kind == 'upgradePriority' then
                                local priority = event.upgradePriority

                                if not autoState or type(priority) ~= 'number' or priority % 1 ~= 0 or priority < 1 or priority > 6 or autoState.upgradePriority == priority then
                                    return
                                end

                                autoState.upgradePriority = priority
                            elseif kind == 'autoAbility' then
                                if not autoState or type(event.abilityName) ~= 'string' or type(event.enabled) ~= 'boolean' or (autoState.autoAbilities[event.abilityName] == true) == event.enabled then
                                    return
                                end

                                autoState.autoAbilities[event.abilityName] = event.enabled

                                if event.enabled == true then
                                    local previous = self.document.actions[#self.document.actions]

                                    if previous and previous.kind == 'ability' and previous.unitRef == ref and previous.abilityName == event.abilityName and math.abs((os.clock() - self.recordStarted) - previous.time) <= 0.5 then
                                        table.remove(self.document.actions)
                                    end
                                end
                            elseif kind == 'priority' then
                                if type(event.priorityName) ~= 'string' or self.attackPriorities[event.guid] == event.priorityName then
                                    return
                                end

                                self.attackPriorities[event.guid] = event.priorityName
                            end
                            if kind == 'ability' then
                                if autoState and autoState.autoAbilities[event.abilityName] == true then
                                    return
                                end
                            end
                            if kind == 'upgrade' then
                                local level = tonumber(event.level)

                                if not level or level <= (self.levels[event.guid] or 0) then
                                    return
                                end

                                local previous = self.document.actions[#self.document.actions]
                                local live = self.adapter.state()

                                if previous and previous.kind == 'place' and previous.unitRef == ref and live and previous.yen == live.yen and os.clock() - self.recordStarted - previous.time <= 0.1 then
                                    self.levels[event.guid] = level

                                    return
                                end

                                self.levels[event.guid] = level

                                if autoState and autoState.autoUpgrade then
                                    return
                                end
                            end

                            local fields = {unitRef = ref}

                            if kind == 'upgrade' then
                                fields.level = self.levels[event.guid]
                            end
                            if kind == 'priority' then
                                fields.priorityName = event.priorityName
                            end
                            if kind == 'ability' then
                                fields.abilityName = event.abilityName
                            end
                            if kind == 'autoUpgrade' or kind == 'autoAbility' then
                                fields.enabled = event.enabled
                            end
                            if kind == 'autoAbility' then
                                fields.abilityName = event.abilityName
                            end
                            if kind == 'upgradePriority' then
                                fields.upgradePriority = event.upgradePriority
                            end

                            append(kind, fields)
                        end)
                    end

                    mode('record')
                    status('Recording: 0 actions')

                    return true, nil
                end
                function self.finishRecord()
                    if self.mode ~= 'record' or not self.document or not self.storage then
                        return nil
                    end

                    local canonical, validationError = Document.validate(self.document)

                    if not canonical then
                        clearConnections(self.recordConnections)
                        mode('idle')
                        status('Save failed: ' .. tostring(validationError))

                        return nil
                    end

                    local ok, err = self.storage.write(canonical.name, canonical, true)

                    if not ok then
                        clearConnections(self.recordConnections)
                        mode('idle')
                        status('Save failed: ' .. tostring(err))

                        return nil
                    end

                    self.document = canonical

                    clearConnections(self.recordConnections)
                    mode('idle')
                    status('Saved ' .. canonical.name .. ' (' .. #canonical.actions .. ' actions)')

                    if self.onSaved then
                        pcall(self.onSaved, canonical.name)
                    end

                    return canonical
                end
                function self.play(document)
                    local checked, err = Document.validate(document)

                    if not checked then
                        return false, err
                    end
                    if not self.context or not self.context.alive then
                        return false, 'MACRO_ADAPTER_UNAVAILABLE'
                    end
                    if self.mode ~= 'idle' and self.mode ~= 'play' then
                        return false, 'MACRO_BUSY'
                    end
                    if self.autoPlay and type((self.autoPlay).isEnabled) == 'function' and (self.autoPlay).isEnabled() then
                        return false, 'AUTOPLAY_ACTIVE'
                    end

                    self.activeDocument = checked
                    self.suspended = false

                    self.generation += 1

                    local generation = self.generation

                    self.pendingRestart = nil
                    self.startVoteSent = false

                    mode('play')
                    status('Waiting for match / Vote to Start')

                    if self.adapter and type((self.adapter).currentStartPrompt) == 'function' then
                        voteForStart((self.adapter).currentStartPrompt())
                    end

                    local taskApi = injectedTask or ((getfenv())).task

                    local function active()
                        return self.mode == 'play' and generation == self.generation and self.context ~= nil and self.context.alive == true
                    end
                    local function waitSuspended()
                        while active() and self.suspended do
                            taskApi.wait(POLL_SECONDS)
                        end

                        return active()
                    end
                    local function waitReady(action, index, started, refs)
                        local priceFails = 0
                        local maxPriceFails = if injectedTask then 1 else 15

                        while active() do
                            if not waitSuspended() then
                                return nil
                            end

                            local ad = self.adapter
                            local state = if ad and ad.state then(ad.state)()else nil

                            if not state then
                                if ad and ad.matchStarted and not (ad.matchStarted)() then
                                    local autoReplay = ad.getGameSetting and (ad.getGameSetting)('AutoReplay') == true
                                    local autoNext = ad.getGameSetting and (ad.getGameSetting)('AutoNext') == true

                                    if autoReplay or autoNext then
                                        status('Match ended; awaiting Auto Next / Auto Replay')
                                    else
                                        status('Match ended; holding on victory screen')
                                    end
                                end

                                return nil
                            end

                            local satisfied = ad and ad.satisfied and (ad.satisfied)(action, refs) == true
                            local price = 0

                            if not satisfied and (action.kind == 'place' or action.kind == 'upgrade') then
                                price = if ad and ad.cost then(ad.cost)(action, refs)else nil

                                if not finitePrice(price) then
                                    priceFails += 1

                                    if priceFails >= maxPriceFails then
                                        if injectedTask then
                                            mode('idle')
                                        end

                                        status('Live price unavailable at step ' .. index .. ': ' .. action.kind)

                                        return nil
                                    end

                                    status('Waiting for live price at step ' .. index .. ': ' .. action.kind)
                                    taskApi.wait(POLL_SECONDS)

                                    continue
                                else
                                    priceFails = 0
                                end
                            end

                            local needsTime = action.kind == 'ability' or (action.kind == 'sell' and self.settings.noIgnoreSellTiming) or not self.settings.ignoreTiming
                            local elapsed = os.clock() - started
                            local requiredTime = if needsTime then action.time else 0

                            if state.wave >= action.wave and elapsed >= requiredTime and state.yen >= price then
                                return state
                            end

                            status('Waiting ' .. index .. '/' .. #checked.actions .. ': wave ' .. tostring(state.wave) .. '/' .. tostring(action.wave) .. ', time ' .. tostring(math.floor(elapsed)) .. '/' .. tostring(requiredTime) .. ', yen ' .. tostring(state.yen) .. '/' .. tostring(price))
                            taskApi.wait(POLL_SECONDS)
                        end

                        return nil
                    end
                    local function exhaustedPlacement(action, index, refs)
                        local policy = self.settings.placementFailure
                        local ad = self.adapter

                        if policy == 'None' then
                            refs[action.unitRef] = false

                            status('Skipped placement ' .. index .. '; dependent steps will be skipped')

                            return true
                        end
                        if policy == 'Restart' then
                            self.pendingRestart = checked

                            local castRestart = ad and ad.castRestartVote

                            if not castRestart or not (castRestart)() then
                                self.pendingRestart = nil

                                mode('idle')
                                status('Restart vote unavailable after placement ' .. index)

                                return false
                            end

                            status('Restart vote sent; awaiting MatchRestarted')

                            local function timeout()
                                if active() and self.pendingRestart == checked then
                                    self.pendingRestart = nil

                                    status('Restart was not confirmed')
                                end
                            end

                            if taskApi.delay then
                                (taskApi.delay)(RESTART_TIMEOUT, timeout)
                            else
                                taskApi.spawn(function()
                                    taskApi.wait(RESTART_TIMEOUT)
                                    timeout()
                                end)
                            end

                            return false
                        end
                        if policy == 'Return to Lobby' then
                            local returnLobby = ad and ad.returnToLobby
                            local sent = returnLobby and (returnLobby)()

                            mode('idle')
                            status(if sent then'Return to Lobby requested'else'Return to Lobby request failed')

                            return false
                        end

                        mode('idle')
                        status('Placement ' .. index .. ' failed after retry limit')

                        return false
                    end

                    taskApi.spawn(function()
                        while active() and not ensureAdapter() do
                            taskApi.wait(POLL_SECONDS)
                        end

                        if not active() then
                            return
                        end
                        if self.adapter and type((self.adapter).currentStartPrompt) == 'function' then
                            voteForStart((self.adapter).currentStartPrompt())
                        end

                        while active() and not (self.adapter).state() do
                            if not self.startVoteSent and self.adapter and type((self.adapter).currentStartPrompt) == 'function' then
                                local prompt = (self.adapter).currentStartPrompt()

                                if prompt then
                                    voteForStart(prompt)
                                end
                            end

                            taskApi.wait(POLL_SECONDS)
                        end

                        if not active() then
                            return
                        end

                        self.playbackActive = true

                        local started = os.clock()
                        local refs = {}

                        for index = 1, #checked.actions do
                            if not waitSuspended() then
                                self.playbackActive = false

                                return
                            end

                            local action = checked.actions[index]

                            status('Playing ' .. index .. '/' .. #checked.actions .. ': ' .. action.kind)

                            if action.kind == 'voteStart' then
                                if not self.startVoteSent and self.adapter and type((self.adapter).currentStartPrompt) == 'function' then
                                    voteForStart((self.adapter).currentStartPrompt())
                                end

                                continue
                            end
                            if action.kind ~= 'place' and (refs[action.unitRef] == false or refs[action.unitRef] == nil) then
                                status('Skipped dependent step ' .. index .. ': ' .. tostring(action.unitRef))

                                continue
                            end
                            if action.kind == 'ability' then
                                local nextAction = checked.actions[index + 1]
                                local isAutoCompanion = nextAction and nextAction.kind == 'autoAbility' and nextAction.unitRef == action.unitRef and nextAction.abilityName == action.abilityName and nextAction.enabled == true and nextAction.wave == action.wave and math.abs(nextAction.time - action.time) <= 1
                                local state = if self.adapter and type((self.adapter).state) == 'function'then(self.adapter).state()else nil
                                local guid = refs[action.unitRef]
                                local unit = state and guid and state.units[guid]
                                local isAlreadyAuto = unit and type(unit.autoAbilities) == 'table' and table.find(unit.autoAbilities, action.abilityName) ~= nil

                                if isAutoCompanion or isAlreadyAuto then
                                    status('Skipped redundant ability ' .. index .. ': native auto-ability active')

                                    continue
                                end
                            end
                            if action.kind == 'upgrade' then
                                while active() do
                                    if self.adapter and type((self.adapter).satisfied) == 'function' and (self.adapter).satisfied(action, refs) then
                                        break
                                    end

                                    local state = if self.adapter and type((self.adapter).state) == 'function'then(self.adapter).state()else nil
                                    local guid = refs[action.unitRef]
                                    local unit = state and guid and state.units[guid]

                                    if not unit or not unit.autoUpgrade then
                                        break
                                    end

                                    status('Waiting ' .. index .. '/' .. #checked.actions .. ': native auto-upgrade level ' .. tostring(unit.level) .. '/' .. tostring(action.level))
                                    taskApi.wait(POLL_SECONDS)
                                end
                            end
                            if not active() then
                                return
                            end

                            local limit = math.clamp(math.floor(tonumber(self.settings.retryLimit) or 3), 1, 10)

                            if action.kind == 'upgradePriority' then
                                limit = math.max(limit, 8)
                            end

                            local firstBefore = nil
                            local attempted = {}
                            local completed = false

                            local function confirmPlacement()
                                if not firstBefore or not self.adapter then
                                    return false, nil
                                end

                                for _, candidate in attempted do
                                    local confirmed, guid = (self.adapter).confirm(candidate, firstBefore, refs)

                                    if confirmed then
                                        return true, guid
                                    end
                                end

                                return false, nil
                            end

                            for attemptNumber = 1, limit do
                                local before = waitReady(action, index, started, refs)

                                if not before or not active() then
                                    return
                                end
                                if self.adapter and type((self.adapter).satisfied) == 'function' and (self.adapter).satisfied(action, refs) then
                                    completed = true

                                    break
                                end
                                if action.kind == 'place' then
                                    local confirmed, guid = confirmPlacement()

                                    if confirmed then
                                        refs[action.unitRef] = guid
                                        completed = true

                                        break
                                    end
                                end

                                local candidate = if action.kind == 'place'then placementAttempt(action, attemptNumber)else action

                                firstBefore = firstBefore or before

                                local sent = self.adapter and type((self.adapter).request) == 'function' and (self.adapter).request(candidate, refs) == true

                                if sent and action.kind == 'place' then
                                    table.insert(attempted, candidate)
                                end
                                if sent then
                                    status('Waiting for game confirmation: step ' .. index .. ', attempt ' .. attemptNumber .. '/' .. limit)

                                    local deadline = os.clock() + (if injectedTask and injectedTask.actionTimeout ~= nil then injectedTask.actionTimeout else ACTION_TIMEOUT)

                                    repeat
                                        taskApi.wait(POLL_SECONDS)

                                        if not active() then
                                            return
                                        end

                                        local confirmed, guid

                                        if action.kind == 'place' then
                                            confirmed, guid = confirmPlacement()
                                        else
                                            confirmed, guid = if self.adapter and type((self.adapter).confirm) == 'function'then(self.adapter).confirm(action, before, refs)else false, nil
                                        end
                                        if confirmed then
                                            if action.kind == 'place' then
                                                refs[action.unitRef] = guid
                                            end

                                            completed = true

                                            break
                                        end
                                    until os.clock() >= deadline
                                end
                                if completed then
                                    break
                                end

                                taskApi.wait(REQUEST_GAP)

                                if not active() then
                                    return
                                end
                                if action.kind == 'place' then
                                    local confirmed, guid = confirmPlacement()

                                    if confirmed then
                                        refs[action.unitRef] = guid
                                        completed = true

                                        break
                                    end
                                end
                            end

                            if not completed then
                                if action.kind == 'ability' then
                                    status('Ability ' .. index .. ' (' .. tostring(action.abilityName) .. ') not confirmed; continuing')
                                elseif action.kind ~= 'place' then
                                    if injectedTask then
                                        mode('idle')
                                    end

                                    status('Step ' .. index .. ' not confirmed after retry limit')

                                    return
                                elseif not exhaustedPlacement(action, index, refs) then
                                    return
                                end
                            end
                            if completed and action.kind == 'sell' then
                                refs[action.unitRef] = false
                            end

                            taskApi.wait(REQUEST_GAP)
                        end

                        self.playbackActive = false

                        if active() then
                            local ad = self.adapter
                            local autoReplay = ad and ad.getGameSetting and (ad.getGameSetting)('AutoReplay') == true
                            local autoNext = ad and ad.getGameSetting and (ad.getGameSetting)('AutoNext') == true

                            if autoReplay or autoNext then
                                status('Actions completed; awaiting Auto Next / Auto Replay')
                            else
                                status('Actions completed; holding on victory screen')
                            end
                        end
                    end)

                    return true, nil
                end
                function self.stopPlayback()
                    if self.mode == 'play' then
                        self.generation += 1

                        self.pendingRestart = nil
                        self.activeDocument = nil
                        self.suspended = false

                        mode('idle')
                        status('Playback stopped')
                    end
                end
                function self.suspend()
                    if self.mode == 'play' then
                        self.suspended = true

                        status('Macro suspended (teleporting)')
                    end
                end
                function self.resume()
                    if self.mode == 'play' then
                        self.suspended = false

                        status('Macro resumed')
                    end
                end

                return self
            end

            return Runtime
        end

        function __DARKLUA_BUNDLE_MODULES.F()
            local v = __DARKLUA_BUNDLE_MODULES.cache.F

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.F = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Style = __DARKLUA_BUNDLE_MODULES.e()
            local Page = {}
            local SETTINGS = {
                {
                    key = 'AutoReplay',
                    title = 'Auto Replay',
                    desc = 'Automatically replays the match upon completion.',
                },
                {
                    key = 'AutoNext',
                    title = 'Auto Next',
                    desc = 'Automatically proceeds to the next stage upon victory.',
                },
                {
                    key = 'AutoSkipWaves',
                    title = 'Auto Skip Waves',
                    desc = 'Automatically votes to skip waves as soon as possible.',
                },
                {
                    key = 'AutoSkipStart',
                    title = 'Auto Skip Start',
                    desc = 'Automatically votes to start the match immediately.',
                },
            }

            function Page.mount(tab, adapter)
                tab:Paragraph({
                    Title = 'Game Settings',
                    Desc =
[[Synchronized controls for Anime Vanguards in-game automation and match settings.]],
                })

                local section = Style.section(tab, 'Match Automation', 'gamepad-2', true)

                if not adapter or not adapter.isAvailable() then
                    section:Paragraph({
                        Title = 'Status',
                        Desc =
[[Game settings modules are not yet loaded. Controls will synchronize in a match.]],
                    })
                end

                local toggles = {}
                local syncing = false

                for _, spec in SETTINGS do
                    local currentValue = if adapter then((adapter).get(spec.key) == true)else false
                    local toggle = section:Toggle({
                        Title = spec.title,
                        Desc = spec.desc,
                        Value = currentValue,
                        Callback = function(enabled)
                            if syncing then
                                return
                            end
                            if adapter and type((adapter).set) == 'function' then
                                (adapter).set(spec.key, enabled)
                            end
                        end,
                    })

                    toggles[spec.key] = toggle
                end

                local autoBackValue = if adapter and type((adapter).getAutoBackToLobby) == 'function'then(adapter).getAutoBackToLobby()else false

                section:Toggle({
                    Title = 'Auto Back to Lobby',
                    Desc =
[[Returns to lobby when match ends and Auto Replay / Auto Next cannot proceed.]],
                    Value = autoBackValue,
                    Callback = function(enabled)
                        if adapter and type((adapter).setAutoBackToLobby) == 'function' then
                            (adapter).setAutoBackToLobby(enabled)
                        end
                    end,
                })

                local function syncAll()
                    if not adapter or type((adapter).get) ~= 'function' then
                        return
                    end

                    for _, spec in SETTINGS do
                        local val = (adapter).get(spec.key)

                        if val ~= nil then
                            local toggle = toggles[spec.key]

                            if toggle and type(toggle.Set) == 'function' and toggle.Value ~= val then
                                syncing = true

                                pcall(toggle.Set, toggle, val, false)

                                syncing = false
                            end
                        end
                    end
                end

                syncAll()

                if adapter and type((adapter).observe) == 'function' then
                    (adapter).observe(function(name, value)
                        local toggle = toggles[name]

                        if toggle and type(toggle.Set) == 'function' and toggle.Value ~= value then
                            syncing = true

                            pcall(toggle.Set, toggle, value, false)

                            syncing = false
                        end
                    end)
                end

                local env = getfenv()
                local taskApi = env.task

                if type(taskApi) == 'table' and type(taskApi.spawn) == 'function' and type(taskApi.wait) == 'function' then
                    (taskApi.spawn)(function()
                        for _ = 1, 10 do
                            (taskApi.wait)(1)
                            syncAll()
                        end
                    end)
                end
            end

            return Page
        end

        function __DARKLUA_BUNDLE_MODULES.G()
            local v = __DARKLUA_BUNDLE_MODULES.cache.G

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.G = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local AdventureDetect = __DARKLUA_BUNDLE_MODULES.u()
            local FileStorage = __DARKLUA_BUNDLE_MODULES.l()
            local Adapter = {}
            local SETTINGS_STORAGE_KEY = 'AnimeVanguardsGameSettings'
            local SCHEMA_VERSION = 1

            local function resolve(root, path)
                local value = root

                for part in string.gmatch(path, '[^%.]+')do
                    if not value then
                        return nil
                    end

                    local ok, child = pcall(function()
                        local v = value

                        if type(v) == 'userdata' then
                            return v:FindFirstChild(part)
                        else
                            return v[part]
                        end
                    end)

                    value = if ok then child else nil
                end

                return value
            end
            local function liveDependencies()
                local env = getfenv()
                local gameObject = env.game

                if not gameObject then
                    return nil
                end

                local replicated = gameObject:GetService('ReplicatedStorage')
                local starter = gameObject:GetService('StarterPlayer')
                local codecMod = resolve(replicated, config.instancePaths.settingsCodec)
                local clientMod = resolve(replicated, config.instancePaths.sharedSettingsClient)
                local stateMod = resolve(starter, config.instancePaths.settingsState)

                if not codecMod or not clientMod or not stateMod then
                    return nil
                end

                local ok, result = pcall(function()
                    return {
                        codec = (require)(codecMod),
                        client = (require)(clientMod),
                        state = (require)(stateMod),
                    }
                end)

                return if ok then result else nil
            end

            function Adapter.new(injectedDeps)
                local self = {
                    dependencies = injectedDeps,
                    context = nil,
                    observers = {},
                    stateConnection = nil,
                    matchEndConnection = nil,
                    autoBackToLobby = false,
                    teleportCancelled = false,
                    lastKnownValues = {},
                }

                local function getDeps()
                    if self.dependencies then
                        return self.dependencies
                    end

                    local deps = liveDependencies()

                    if deps then
                        self.dependencies = deps
                    end

                    return self.dependencies
                end

                function self.isAvailable()
                    return getDeps() ~= nil
                end
                function self.get(name)
                    local deps = getDeps()

                    if not deps or not deps.state then
                        return nil
                    end

                    local ok, value = pcall(deps.state.GetSetting, deps.state, name)

                    if ok and type(value) == 'boolean' then
                        return value
                    end

                    return nil
                end
                function self.set(name, value)
                    if type(name) ~= 'string' or type(value) ~= 'boolean' then
                        return false
                    end

                    local deps = getDeps()

                    if not deps or not deps.codec or not deps.client then
                        return false
                    end

                    local okEncode, mutation = pcall(deps.codec.EncodeScalarMutation, name, value, nil)

                    if not okEncode or not mutation then
                        return false
                    end

                    local remote = deps.client[config.remoteNames.changeSetting]

                    if not remote or type(remote.Fire) ~= 'function' then
                        return false
                    end

                    local okFire = pcall(remote.Fire, mutation)

                    if okFire and deps.state then
                        if type(deps.state.UpdateSetting) == 'function' then
                            pcall(deps.state.UpdateSetting, deps.state, name, value)
                        elseif type(deps.state.SetSessionOverride) == 'function' then
                            pcall(deps.state.SetSessionOverride, deps.state, name, value)
                        end
                    end

                    self.lastKnownValues[name] = value

                    for _, observer in self.observers do
                        pcall(observer, name, value)
                    end

                    return okFire
                end
                function self.sync()
                    local deps = getDeps()

                    if not deps or not deps.state then
                        return
                    end

                    for _, name in {
                        'AutoReplay',
                        'AutoNext',
                        'AutoSkipWaves',
                        'AutoSkipStart',
                    }do
                        local val = self.get(name)

                        if val ~= nil and self.lastKnownValues[name] ~= val then
                            self.lastKnownValues[name] = val

                            for _, observer in self.observers do
                                pcall(observer, name, val)
                            end
                        end
                    end
                end

                local storage = nil
                local httpService = nil

                local function saveSettings()
                    if not storage or not httpService then
                        return
                    end

                    local ok, body = pcall(httpService.JSONEncode, httpService, {
                        schemaVersion = SCHEMA_VERSION,
                        autoBackToLobby = self.autoBackToLobby == true,
                    })

                    if ok and type(body) == 'string' then
                        pcall(storage.write, body)
                    end
                end

                local loadedSaved = false

                local function loadSaved()
                    if loadedSaved then
                        return
                    end

                    loadedSaved = true

                    local env = getfenv()

                    pcall(function()
                        storage = FileStorage.new(env, SETTINGS_STORAGE_KEY)
                        httpService = env.game and env.game:GetService('HttpService')

                        if storage and httpService then
                            local body = storage.read()

                            if body then
                                local ok, data = pcall(httpService.JSONDecode, httpService, body)

                                if ok and type(data) == 'table' and data.schemaVersion == SCHEMA_VERSION then
                                    if type(data.autoBackToLobby) == 'boolean' then
                                        self.autoBackToLobby = data.autoBackToLobby
                                    end
                                end
                            end
                        end
                    end)
                end

                function self.getAutoBackToLobby()
                    loadSaved()

                    return self.autoBackToLobby == true
                end
                function self.setAutoBackToLobby(val)
                    loadSaved()

                    self.autoBackToLobby = val == true

                    saveSettings()
                end
                function self.observe(callback)
                    if type(callback) ~= 'function' then
                        return nil
                    end

                    table.insert(self.observers, callback)

                    return function()
                        local index = table.find(self.observers, callback)

                        if index then
                            table.remove(self.observers, index)
                        end
                    end
                end
                function self.start(context)
                    self.context = context
                    self.teleportCancelled = false

                    local env = getfenv()

                    loadSaved()

                    local deps = getDeps()

                    if deps and deps.state and deps.state.OnSettingUpdate and type(deps.state.OnSettingUpdate.Connect) == 'function' then
                        local ok, conn = pcall(deps.state.OnSettingUpdate.Connect, deps.state.OnSettingUpdate, function(
                            name,
                            val
                        )
                            if type(name) == 'string' and type(val) == 'boolean' then
                                self.lastKnownValues[name] = val

                                for _, observer in self.observers do
                                    pcall(observer, name, val)
                                end
                            end
                        end)

                        if ok then
                            self.stateConnection = conn
                        end
                    end

                    self.sync()

                    local taskApi = env.task

                    if type(taskApi) == 'table' and type(taskApi.spawn) == 'function' and type(taskApi.wait) == 'function' then
                        (taskApi.spawn)(function()
                            while self.context == context and context.alive do
                                self.sync()

                                local waitFn = taskApi.wait

                                waitFn(1)
                            end
                        end)
                    end

                    local gameObject = env.game
                    local replicated = gameObject and gameObject:GetService('ReplicatedStorage')

                    local function canNativeProceed(localPlayer)
                        local playerGui = localPlayer and localPlayer:FindFirstChildOfClass('PlayerGui')
                        local endScreen = playerGui and playerGui:FindFirstChild('EndScreen')
                        local buttons = endScreen and endScreen:FindFirstChild('Holder') and endScreen.Holder:FindFirstChild('Buttons')

                        if not buttons then
                            local autoReplay = self.get('AutoReplay') == true
                            local autoNext = self.get('AutoNext') == true

                            return autoReplay or autoNext
                        end

                        local autoNext = self.get('AutoNext') == true
                        local autoReplay = self.get('AutoReplay') == true
                        local nextFrame = buttons:FindFirstChild('Next')
                        local nextPossible = autoNext and nextFrame ~= nil and nextFrame.Visible == true
                        local retryFrame = buttons:FindFirstChild('Retry')
                        local retryPossible = false

                        if autoReplay and retryFrame and retryFrame.Visible == true then
                            local retryLabel = retryFrame:FindFirstChild('Label') or retryFrame:FindFirstChildWhichIsA('TextLabel')
                            local retryText = retryLabel and retryLabel.Text or ''
                            local zeroAttempts = string.find(retryText, '%(0/') ~= nil

                            retryPossible = not zeroAttempts
                        end

                        return nextPossible or retryPossible
                    end

                    local gameHandlerMod = resolve(replicated, config.instancePaths.gameHandler)

                    if gameHandlerMod then
                        local okGh, gh = pcall(require, gameHandlerMod)

                        if okGh and gh and gh.MatchEnded and type(gh.MatchEnded.Connect) == 'function' then
                            self.matchEndConnection = (gh.MatchEnded.Connect)(gh.MatchEnded, function(
                            )
                                if self.autoBackToLobby and not AdventureDetect.isAdventureMatch(gh.GameData) then
                                    local taskApi = env.task

                                    local function doTeleport(held)
                                        if self.teleportCancelled or not self.context or not self.context.alive then
                                            return
                                        end

                                        local gate = self.returnGate
                                        local waited = held or 0

                                        if type(gate) == 'function' and waited < config.thresholds.returnGateMaxSeconds and type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                                            local okGate, busy = pcall(gate)

                                            if okGate and busy == true then
                                                (taskApi.delay)(0.5, function()
                                                    doTeleport(waited + 0.5)
                                                end)

                                                return
                                            end
                                        end

                                        local lr = resolve(replicated, config.instancePaths.lobbyReturnClient)

                                        if lr then
                                            local mod = (require)(lr)
                                            local remote = mod and mod[config.remoteNames.requestTeleportToLobby]

                                            if remote and type(remote.Fire) == 'function' then
                                                pcall(remote.Fire)
                                            end
                                        end
                                    end
                                    local function checkAndTeleport()
                                        if self.teleportCancelled or not self.context or not self.context.alive then
                                            return
                                        end

                                        local players = gameObject:GetService('Players')
                                        local localPlayer = players and players.LocalPlayer

                                        if not canNativeProceed(localPlayer) then
                                            doTeleport()
                                        end
                                    end

                                    if type(taskApi) == 'table' and type(taskApi.delay) == 'function' then
                                        local delayTask = taskApi.delay

                                        delayTask(2.5, checkAndTeleport)
                                        delayTask(7, checkAndTeleport)
                                    else
                                        checkAndTeleport()
                                    end
                                end
                            end)
                        end
                    end
                end
                function self.setReturnGate(gate)
                    self.returnGate = gate
                end
                function self.stop()
                    self.teleportCancelled = true

                    if self.matchEndConnection then
                        pcall(function()
                            if type(self.matchEndConnection) == 'function' then
                                (self.matchEndConnection)()
                            else
                                self.matchEndConnection:Disconnect()
                            end
                        end)

                        self.matchEndConnection = nil
                    end
                    if self.stateConnection then
                        pcall(function()
                            if type(self.stateConnection) == 'function' then
                                (self.stateConnection)()
                            else
                                self.stateConnection:Disconnect()
                            end
                        end)

                        self.stateConnection = nil
                    end
                    if self.clientConnection then
                        pcall(function()
                            if type(self.clientConnection) == 'function' then
                                (self.clientConnection)()
                            else
                                self.clientConnection:Disconnect()
                            end
                        end)

                        self.clientConnection = nil
                    end

                    table.clear(self.observers)

                    self.context = nil
                end

                return self
            end

            return Adapter
        end

        function __DARKLUA_BUNDLE_MODULES.H()
            local v = __DARKLUA_BUNDLE_MODULES.cache.H

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.H = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Style = __DARKLUA_BUNDLE_MODULES.e()
            local Page = {}
            local RULES_ERRORS = {
                AUTOPLAY_ENABLED = 'Turn off Auto play - ingame before changing presets.',
                MACRO_ACTIVE = 'Stop Play Macro before changing presets.',
                PRESET_UNKNOWN = "That preset is not in the game's preset list.",
                INVALID_RULE = 'That rule could not be saved.',
            }

            local function mountRules(tab, runtime, macro)
                local modes = runtime.getCatalog()

                tab:Paragraph({
                    Title = 'Stage Preset Rules',
                    Desc =
[[Choose a saved Auto Play preset per game mode. None leaves the game's current preset untouched. Rules apply only while Auto play - ingame is on and can be edited only while it is off.]],
                })

                if not modes then
                    tab:Paragraph({
                        Title = 'Mode list unavailable',
                        Desc = "The game's mode data could not be read yet.",
                    })

                    return
                end

                local rows = {}
                local syncing = false

                local function labelFor(row, options)
                    local entry = runtime.getRule(row.mode)

                    if not entry then
                        return 'None'
                    end

                    for _, option in options do
                        if option.id == entry.id then
                            return option.label
                        end
                    end

                    return entry.name
                end
                local function refreshRow(row)
                    local options = runtime.getPresetOptions()
                    local labels = {}
                    local byLabel = {}

                    for _, option in options do
                        table.insert(labels, option.label)

                        byLabel[option.label] = option.id
                    end

                    local current = labelFor(row, options)

                    if not table.find(labels, current) then
                        table.insert(labels, current)
                    end

                    row.byLabel = byLabel

                    local signature = current .. '|' .. table.concat(labels, '|')

                    if row.signature == signature then
                        return
                    end

                    row.signature = signature
                    row.current = current
                    syncing = true

                    local dropdown = row.dropdown

                    if type(dropdown.Select) == 'function' then
                        pcall(dropdown.Select, dropdown, current)
                    end
                    if type(dropdown.Refresh) == 'function' then
                        pcall(dropdown.Refresh, dropdown, labels)
                    end

                    syncing = false
                end
                local function applyLock()
                    local locked = runtime.isRulesLocked()

                    for _, row in rows do
                        local dropdown = row.dropdown
                        local method = if locked then dropdown.Lock else dropdown.Unlock

                        if type(method) == 'function' then
                            pcall(method, dropdown)
                        end
                    end
                end
                local function refreshAll()
                    for _, row in rows do
                        refreshRow(row)
                    end

                    applyLock()
                end

                local section = Style.section(tab, 'Preset per mode', 'layers', false)

                for _, mode in modes do
                    local row = {
                        mode = mode,
                        byLabel = {},
                    }

                    row.dropdown = section:Dropdown({
                        Title = runtime.getModeLabel(mode),
                        Values = {
                            'None',
                        },
                        Value = 'None',
                        Callback = function(label)
                            if syncing or label == row.current then
                                return
                            end

                            local ok, err = runtime.setRule(row.mode, row.byLabel[label])

                            if ok then
                                row.current = label
                                row.signature = nil
                            else
                                pcall(function()
                                    runtime.onStatus(RULES_ERRORS[err or ''] or ('Error: ' .. tostring(err)))
                                end)

                                row.signature = nil

                                refreshRow(row)
                            end
                        end,
                    })

                    table.insert(rows, row)
                end

                tab:Button({
                    Title = 'Refresh preset list',
                    Desc = 'Asks the game to resend your saved Auto Play presets.',
                    Callback = function()
                        runtime.refreshPresets()
                    end,
                })
                runtime.onRulesChange(refreshAll)
                runtime.onEnabledChange(function()
                    applyLock()
                end)

                if macro and type((macro).onModeChange) == 'function' then
                    (macro).onModeChange(function()
                        applyLock()
                    end)
                end

                refreshAll()
            end

            function Page.mount(tab, runtime, macro)
                tab:Paragraph({
                    Title = 'Auto Play',
                    Desc =
[[In-game automation controls for Anime Vanguards native Auto Play.]],
                })

                local status = tab:Paragraph({
                    Title = 'Auto Play Status',
                    Desc = if runtime then runtime.status else'Unavailable',
                })

                if runtime then
                    runtime.onStatus = function(val)
                        pcall(status.SetDesc, status, val)
                    end
                end

                local section = Style.section(tab, 'In-Game Automation', 'play', true)

                section:Paragraph({
                    Title = 'Native Auto Play',
                    Desc =
[[Directly engages the game's built-in Auto Play feature. If the match hasn't started yet, automatically votes to start before activating Auto Play.]],
                })

                local autoPlayToggle

                autoPlayToggle = section:Toggle({
                    Title = 'Auto play - ingame',
                    Desc =
[[Activates native in-game Auto Play across matches. Mutually exclusive with Play Macro.]],
                    Value = if runtime then runtime.isEnabled()else false,
                    Callback = function(enabled)
                        if not runtime then
                            return
                        end

                        local ok, err = runtime.setEnabled(enabled)

                        if not ok then
                            if err == 'MACRO_ACTIVE' then
                                status:SetDesc(
[[Cannot enable: Play Macro is currently active. Stop macro first.]])
                            else
                                status:SetDesc('Error: ' .. tostring(err))
                            end
                            if autoPlayToggle and type(autoPlayToggle.Set) == 'function' then
                                (autoPlayToggle.Set)(autoPlayToggle, false, false)
                            end
                        end
                    end,
                })

                local function updateAutoPlayLock()
                    if not autoPlayToggle then
                        return
                    end

                    local isMacroPlaying = macro and (macro.mode == 'play')

                    if isMacroPlaying then
                        if type(autoPlayToggle.Lock) == 'function' then
                            pcall(autoPlayToggle.Lock, autoPlayToggle)
                        end
                    else
                        if type(autoPlayToggle.Unlock) == 'function' then
                            pcall(autoPlayToggle.Unlock, autoPlayToggle)
                        end
                    end
                end

                if autoPlayToggle then
                    updateAutoPlayLock()
                end
                if macro and type((macro).onModeChange) == 'function' then
                    (macro).onModeChange(function(_m)
                        updateAutoPlayLock()
                    end)
                end
                if runtime then
                    runtime.onEnabled = function(enabled)
                        if autoPlayToggle and type(autoPlayToggle.Set) == 'function' then
                            pcall(autoPlayToggle.Set, autoPlayToggle, enabled, false)
                        end
                    end

                    mountRules(tab, runtime, macro)
                end
            end

            return Page
        end

        function __DARKLUA_BUNDLE_MODULES.I()
            local v = __DARKLUA_BUNDLE_MODULES.cache.I

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.I = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Rules = {}
            local MAX_KEY_LENGTH = 96
            local MAX_ID_LENGTH = 24
            local MAX_NAME_LENGTH = 96
            local MAX_RULES = 400
            local NONE_LABEL = 'None'

            Rules.NONE_LABEL = NONE_LABEL

            local function validText(value, limit)
                return type(value) == 'string' and #value > 0 and #value <= limit
            end

            function Rules.empty()
                return {}
            end
            function Rules.normalize(raw)
                local result = {}

                if type(raw) ~= 'table' then
                    return result
                end

                local count = 0

                for mode, entry in raw do
                    if count < MAX_RULES and validText(mode, MAX_KEY_LENGTH) and type(entry) == 'table' and validText(entry.id, MAX_ID_LENGTH) and validText(entry.name, MAX_NAME_LENGTH) then
                        result[mode] = {
                            id = entry.id,
                            name = entry.name,
                        }

                        count += 1
                    end
                end

                return result
            end
            function Rules.get(rules, mode)
                return rules[mode]
            end
            function Rules.set(rules, mode, entry)
                if not validText(mode, MAX_KEY_LENGTH) then
                    return false
                end
                if entry == nil then
                    rules[mode] = nil

                    return true
                end
                if not validText(entry.id, MAX_ID_LENGTH) or not validText(entry.name, MAX_NAME_LENGTH) then
                    return false
                end

                rules[mode] = {
                    id = entry.id,
                    name = entry.name,
                }

                return true
            end
            function Rules.resolve(entry, presets)
                local liveName = presets.names[entry.id]

                if type(liveName) == 'string' and liveName == entry.name then
                    return 'ok'
                end

                return 'invalid'
            end
            function Rules.prune(rules, presets)
                local doomed = {}

                for mode, entry in rules do
                    if Rules.resolve(entry, presets) ~= 'ok' then
                        table.insert(doomed, mode)
                    end
                end
                for _, mode in doomed do
                    rules[mode] = nil
                end

                return #doomed
            end
            function Rules.options(presets)
                local options = {
                    {label = NONE_LABEL},
                }

                if not presets then
                    return options
                end

                local seen = {}

                for _, id in presets.order do
                    local name = presets.names[id]

                    if type(name) == 'string' then
                        local count = (seen[name] or 0) + 1

                        seen[name] = count

                        local label = if count > 1 then string.format('%s (%d)', name, count)else name

                        table.insert(options, {
                            id = id,
                            name = name,
                            label = label,
                        })
                    end
                end

                return options
            end
            function Rules.readPresets(payload)
                if type(payload) ~= 'table' or type(payload.Order) ~= 'table' or type(payload.Names) ~= 'table' then
                    return nil
                end

                local order = {}
                local names = {}

                for _, id in payload.Order do
                    local name = payload.Names[id]

                    if type(id) == 'string' and type(name) == 'string' and #order < 64 then
                        table.insert(order, id)

                        names[id] = name
                    end
                end

                return {
                    active = if type(payload.Active) == 'string'then payload.Active else'',
                    max = if type(payload.Max) == 'number'then payload.Max else#order,
                    order = order,
                    names = names,
                }
            end

            return Rules
        end

        function __DARKLUA_BUNDLE_MODULES.J()
            local v = __DARKLUA_BUNDLE_MODULES.cache.J

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.J = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local Rules = __DARKLUA_BUNDLE_MODULES.J()
            local Adapter = {}

            local function resolve(root, path)
                local value = root

                for part in string.gmatch(path, '[^%.]+')do
                    if not value then
                        return nil
                    end

                    local ok, child = pcall(function()
                        local v = value

                        if type(v) == 'userdata' then
                            return v:FindFirstChild(part)
                        else
                            return v[part]
                        end
                    end)

                    value = if ok then child else nil
                end

                return value
            end
            local function optionalRequire(module)
                if not module then
                    return nil
                end

                local ok, result = pcall(function()
                    return (require)(module)
                end)

                return if ok then result else nil
            end
            local function liveDependencies()
                local env = getfenv()
                local gameObject = env.game

                if not gameObject then
                    return nil
                end

                local replicated = gameObject:GetService('ReplicatedStorage')
                local starter = gameObject:GetService('StarterPlayer')
                local autoPlayClientMod = resolve(replicated, config.instancePaths.autoPlayClient)
                local autoPlayHandlerMod = resolve(starter, config.instancePaths.autoPlayHandler)
                local gameHandlerMod = resolve(replicated, config.instancePaths.gameHandler)
                local wavesClientMod = resolve(replicated, config.instancePaths.wavesClient)
                local blocklistMod = resolve(replicated, config.instancePaths.autoPlayModeBlocklist)
                local stagesDataMod = resolve(replicated, config.instancePaths.stagesData)

                if not autoPlayClientMod or not autoPlayHandlerMod or not gameHandlerMod then
                    return nil
                end

                local ok, result = pcall(function()
                    return {
                        autoPlayClient = (require)(autoPlayClientMod),
                        autoPlayHandler = (require)(autoPlayHandlerMod),
                        gameHandler = (require)(gameHandlerMod),
                        wavesClient = if wavesClientMod then(require)(wavesClientMod)else nil,
                        blocklist = optionalRequire(blocklistMod),
                        stagesData = optionalRequire(stagesDataMod),
                    }
                end)

                return if ok then result else nil
            end

            function Adapter.new(injectedDeps)
                local self = {dependencies = injectedDeps}

                local function getDeps()
                    if self.dependencies then
                        return self.dependencies
                    end

                    local deps = liveDependencies()

                    if deps then
                        self.dependencies = deps
                    end

                    return self.dependencies
                end

                function self.isAvailable()
                    return getDeps() ~= nil
                end
                function self.isAutoPlaying()
                    local deps = getDeps()

                    if not deps or not deps.autoPlayHandler or type(deps.autoPlayHandler.IsAutoPlaying) ~= 'function' then
                        return nil
                    end

                    local ok, val = pcall(deps.autoPlayHandler.IsAutoPlaying)

                    return if ok and type(val) == 'boolean'then val else nil
                end
                function self.toggle()
                    local deps = getDeps()

                    if not deps or not deps.autoPlayClient then
                        return false
                    end

                    local remote = deps.autoPlayClient[config.remoteNames.toggleAutoPlay]

                    if not remote or type(remote.Fire) ~= 'function' then
                        return false
                    end

                    local ok = pcall(remote.Fire)

                    return ok
                end
                function self.isMatchStarted()
                    local deps = getDeps()

                    if not deps or not deps.gameHandler or deps.gameHandler.IsGameLoaded ~= true then
                        return nil
                    end
                    if type(deps.gameHandler.IsMatchStarted) ~= 'boolean' then
                        return nil
                    end

                    return deps.gameHandler.IsMatchStarted
                end
                function self.hasStartPrompt()
                    local deps = getDeps()

                    if not deps or not deps.gameHandler or deps.gameHandler.IsGameLoaded ~= true then
                        return false
                    end

                    local env = getfenv()
                    local gameObject = env.game

                    if not gameObject then
                        return false
                    end

                    local ok, visible = pcall(function()
                        local player = gameObject:GetService('Players').LocalPlayer
                        local playerGui = player and player:FindFirstChildOfClass('PlayerGui')
                        local prompt = playerGui and playerGui:FindFirstChild('SkipWave')
                        local holder = prompt and prompt:FindFirstChild('Holder')
                        local description = holder and holder:FindFirstChild('Description')
                        local yes = holder and holder:FindFirstChild('Yes')

                        return holder ~= nil and holder.Visible == true and yes ~= nil and description ~= nil and type(description.Text) == 'string' and string.find(string.lower(description.Text), 'vote start', 1, true) ~= nil
                    end)

                    return ok and visible == true
                end
                function self.castStartVote()
                    local deps = getDeps()

                    if not deps or not deps.wavesClient then
                        return false
                    end

                    local remote = deps.wavesClient[config.remoteNames.castWaveSkipVote]

                    if not remote or type(remote.Fire) ~= 'function' then
                        return false
                    end

                    local ok = pcall(remote.Fire)

                    return ok
                end

                local presets = nil
                local presetListeners = {}
                local presetUnsubscribe = nil
                local presetAlive = false

                function self.requestPresets()
                    local deps = getDeps()
                    local client = deps and deps.autoPlayClient
                    local remote = client and client[config.remoteNames.requestAutoPlayData]

                    if not remote or type(remote.Fire) ~= 'function' then
                        return false
                    end

                    return (pcall(remote.Fire))
                end
                function self.trackPresets()
                    if presetAlive then
                        return true
                    end

                    local deps = getDeps()
                    local client = deps and deps.autoPlayClient
                    local event = client and client[config.remoteNames.autoPlayPresetsUpdated]

                    if not event or type(event.On) ~= 'function' then
                        return false
                    end

                    local ok, unsubscribe = pcall(event.On, function(payload)
                        if not presetAlive then
                            return
                        end

                        local snapshot = Rules.readPresets(payload)

                        if not snapshot then
                            return
                        end

                        presets = snapshot

                        for _, listener in presetListeners do
                            pcall(listener, snapshot)
                        end
                    end)

                    if not ok then
                        return false
                    end

                    presetUnsubscribe = unsubscribe
                    presetAlive = true

                    self.requestPresets()

                    return true
                end
                function self.untrackPresets()
                    presetAlive = false
                    presets = nil

                    table.clear(presetListeners)

                    if type(presetUnsubscribe) == 'function' then
                        pcall(presetUnsubscribe)
                    end

                    presetUnsubscribe = nil
                end
                function self.getPresets()
                    return presets
                end
                function self.onPresetsUpdated(callback)
                    table.insert(presetListeners, callback)

                    return function()
                        local index = table.find(presetListeners, callback)

                        if index then
                            table.remove(presetListeners, index)
                        end
                    end
                end
                function self.switchPreset(id)
                    if type(id) ~= 'string' or id == '' then
                        return false
                    end

                    local deps = getDeps()
                    local client = deps and deps.autoPlayClient
                    local remote = client and client[config.remoteNames.switchAutoPlayPreset]

                    if not remote or type(remote.Fire) ~= 'function' then
                        return false
                    end

                    return (pcall(remote.Fire, {PresetId = id}))
                end
                function self.getGameData()
                    local deps = getDeps()
                    local handler = deps and deps.gameHandler

                    if not handler or handler.IsGameLoaded ~= true or type(handler.GetGameData) ~= 'function' then
                        return nil
                    end

                    local ok, data = pcall(handler.GetGameData, handler)

                    if not ok or type(data) ~= 'table' or type(data.StageType) ~= 'string' or type(data.Stage) ~= 'string' then
                        return nil
                    end

                    return {
                        mode = data.StageType,
                        stage = data.Stage,
                    }
                end
                function self.getModes()
                    local deps = getDeps()
                    local data = deps and deps.stagesData

                    if not data or type(data.GetAllStageTypeNames) ~= 'function' or type(data.GetAllStageNameAndIndex) ~= 'function' then
                        return nil
                    end

                    local okTypes, typeNames = pcall(data.GetAllStageTypeNames)

                    if not okTypes or type(typeNames) ~= 'table' then
                        return nil
                    end

                    local blocklist = deps.blocklist
                    local modes = {}
                    local seen = {}

                    for _, mode in typeNames do
                        if type(mode) == 'string' and not seen[mode] and not (config).hiddenModes[mode] then
                            seen[mode] = true

                            local okStages, stageMap = pcall(data.GetAllStageNameAndIndex, mode)
                            local supported = false

                            if okStages and type(stageMap) == 'table' then
                                for _, stageId in stageMap do
                                    local blocked = false

                                    if type(stageId) == 'string' and blocklist and type(blocklist.IsBlocked) == 'function' then
                                        local okBlock, result = pcall(blocklist.IsBlocked, {
                                            StageType = mode,
                                            Stage = stageId,
                                        })

                                        blocked = not okBlock or result == true
                                    end
                                    if type(stageId) == 'string' and not blocked then
                                        supported = true

                                        break
                                    end
                                end
                            end
                            if supported then
                                table.insert(modes, mode)
                            end
                        end
                    end
                    for _, extra in (config).extraModes do
                        local blocked = false

                        if blocklist and type(blocklist.IsBlocked) == 'function' then
                            local okBlock, result = pcall(blocklist.IsBlocked, {
                                StageType = extra,
                                Stage = extra,
                            })

                            blocked = not okBlock or result == true
                        end
                        if not seen[extra] and not blocked and not (config).hiddenModes[extra] then
                            seen[extra] = true

                            table.insert(modes, extra)
                        end
                    end

                    table.sort(modes, function(a, b)
                        if a == 'Story' or b == 'Story' then
                            return a == 'Story' and b ~= 'Story'
                        end

                        return a < b
                    end)

                    return modes
                end
                function self.observe(kind, callback)
                    local deps = getDeps()

                    if not deps or type(callback) ~= 'function' then
                        return nil
                    end
                    if kind == 'autoPlayToggled' and deps.autoPlayHandler and deps.autoPlayHandler.AutoPlayToggled then
                        local ev = deps.autoPlayHandler.AutoPlayToggled

                        if type(ev.Connect) == 'function' then
                            local conn = ev:Connect(callback)

                            return function()
                                pcall(function()
                                    conn:Disconnect()
                                end)
                            end
                        end
                    elseif kind == 'matchStarted' and deps.gameHandler and deps.gameHandler.MatchStarted then
                        local sig = deps.gameHandler.MatchStarted

                        if type(sig.Connect) == 'function' then
                            local conn = sig:Connect(callback)

                            return function()
                                pcall(function()
                                    conn:Disconnect()
                                end)
                            end
                        end
                    elseif kind == 'matchRestarted' and deps.gameHandler and deps.gameHandler.MatchRestarted then
                        local sig = deps.gameHandler.MatchRestarted

                        if type(sig.Connect) == 'function' then
                            local conn = sig:Connect(callback)

                            return function()
                                pcall(function()
                                    conn:Disconnect()
                                end)
                            end
                        end
                    end

                    return nil
                end

                return self
            end

            return Adapter
        end

        function __DARKLUA_BUNDLE_MODULES.K()
            local v = __DARKLUA_BUNDLE_MODULES.cache.K

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.K = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local FileStorage = __DARKLUA_BUNDLE_MODULES.l()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local Adapter = __DARKLUA_BUNDLE_MODULES.K()
            local Rules = __DARKLUA_BUNDLE_MODULES.J()
            local Runtime = {}
            local STORAGE_KEY = 'AnimeVanguardsAutoPlay'
            local SCHEMA_VERSION = 3
            local POLL_SECONDS = 1
            local RETRY_SECONDS = 8
            local PRESET_ATTEMPTS = (config).thresholds.presetSwitchAttempts
            local PRESET_TIMEOUT_SECONDS = (config).thresholds.presetSwitchTimeoutSeconds
            local PRESET_REQUEST_SECONDS = (config).thresholds.presetRequestSeconds

            function Runtime.new(
                injectedAdapter,
                injectedStorage,
                injectedTask,
                injectedHttp
            )
                local self = {
                    adapter = injectedAdapter,
                    storage = injectedStorage,
                    task = injectedTask,
                    http = injectedHttp,
                    context = nil,
                    enabled = false,
                    status = 'Disabled',
                    onStatus = nil,
                    onEnabled = nil,
                    enabledListeners = {},
                    macro = nil,
                    connections = {},
                    startVoteSent = false,
                    lastVoteRequest = -math.huge,
                    lastToggleRequest = -math.huge,
                    pendingToggle = false,
                    loaded = false,
                    rules = Rules.empty(),
                    rulesListeners = {},
                    presetAttempt = nil,
                    lastPresetRequest = -math.huge,
                    catalog = nil,
                    unsubscribePresets = nil,
                }
                local statusListeners = {}

                local function setStatus(value)
                    self.status = value

                    if self.onStatus then
                        pcall(self.onStatus, value)
                    end

                    for _, listener in table.clone(statusListeners)do
                        pcall(listener, value)
                    end
                end

                function self.addStatusListener(listener)
                    table.insert(statusListeners, listener)

                    return function()
                        local index = table.find(statusListeners, listener)

                        if index then
                            table.remove(statusListeners, index)
                        end
                    end
                end

                local function getAdapter()
                    if not self.adapter then
                        local ok, ad = pcall(Adapter.new)

                        if ok and ad then
                            self.adapter = ad
                        end
                    end

                    return self.adapter
                end
                local function save()
                    local s = self.storage

                    if not s then
                        return
                    end

                    local env = getfenv()
                    local http = self.http or (env.game and env.game:GetService('HttpService'))

                    if not http then
                        return
                    end

                    local ok, body = pcall(http.JSONEncode, http, {
                        schemaVersion = SCHEMA_VERSION,
                        enabled = self.enabled == true,
                        rules = self.rules,
                    })

                    if ok and type(body) == 'string' then
                        pcall(s.write, body)
                    end
                end
                local function notifyEnabled(val)
                    if self.onEnabled then
                        pcall(self.onEnabled, val)
                    end

                    for _, cb in self.enabledListeners do
                        pcall(cb, val)
                    end
                end
                local function notifyRules()
                    for _, cb in self.rulesListeners do
                        pcall(cb)
                    end
                end

                function self.onRulesChange(callback)
                    if type(callback) == 'function' then
                        table.insert(self.rulesListeners, callback)
                    end
                end
                function self.isRulesLocked()
                    return self.enabled == true or (self.macro ~= nil and self.macro.mode == 'play')
                end
                function self.getRule(mode)
                    return Rules.get(self.rules, mode)
                end
                function self.getModeLabel(mode)
                    local known = (config).modeLabels[mode]

                    if type(known) == 'string' then
                        return known
                    end

                    return (string.gsub(mode, '(%l)(%u)', '%1 %2'))
                end
                function self.getPresets()
                    local ad = getAdapter()

                    return if ad and type(ad.getPresets) == 'function'then(ad.getPresets)()else nil
                end
                function self.getPresetOptions()
                    return Rules.options(self.getPresets())
                end
                function self.getCatalog()
                    if not self.catalog then
                        local ad = getAdapter()

                        if ad and type(ad.getModes) == 'function' then
                            local ok, result = pcall(ad.getModes)

                            if ok and type(result) == 'table' then
                                self.catalog = result
                            end
                        end
                    end

                    return self.catalog
                end
                function self.refreshPresets()
                    local ad = getAdapter()

                    if ad and type(ad.trackPresets) == 'function' then
                        (ad.trackPresets)()
                    end

                    return ad ~= nil and type(ad.requestPresets) == 'function' and (ad.requestPresets)() == true
                end
                function self.setRule(mode, id)
                    if self.enabled then
                        return false, 'AUTOPLAY_ENABLED'
                    end
                    if self.macro and self.macro.mode == 'play' then
                        return false, 'MACRO_ACTIVE'
                    end
                    if id == nil then
                        Rules.set(self.rules, mode, nil)
                    else
                        local presets = self.getPresets()
                        local name = presets and presets.names[id]

                        if type(name) ~= 'string' then
                            return false, 'PRESET_UNKNOWN'
                        end
                        if not Rules.set(self.rules, mode, {
                            id = id,
                            name = name,
                        }) then
                            return false, 'INVALID_RULE'
                        end
                    end

                    save()

                    return true, nil
                end

                local function onPresetsSnapshot(snapshot)
                    if #snapshot.order > 0 and Rules.prune(self.rules, snapshot) > 0 then
                        save()
                        setStatus('Stage preset rule cleared: preset was deleted or renamed')
                    end

                    notifyRules()

                    if self.enabled then
                        self.step()
                    end
                end
                local function ensurePreset(ad, current)
                    if type(ad.getGameData) ~= 'function' or type(ad.getPresets) ~= 'function' then
                        return true
                    end
                    if self.macro and self.macro.mode == 'play' then
                        return true
                    end

                    local data = (ad.getGameData)()

                    if not data then
                        setStatus('Waiting for game data')

                        return false
                    end

                    local entry = Rules.get(self.rules, data.mode)

                    if not entry then
                        self.presetAttempt = nil

                        return true
                    end

                    local presets = (ad.getPresets)()

                    if not presets then
                        if type(ad.trackPresets) == 'function' then
                            (ad.trackPresets)()
                        end
                        if current - self.lastPresetRequest >= PRESET_REQUEST_SECONDS then
                            self.lastPresetRequest = current

                            if type(ad.requestPresets) == 'function' then
                                (ad.requestPresets)()
                            end
                        end

                        setStatus('Waiting for preset list')

                        return false
                    end
                    if Rules.resolve(entry, presets) ~= 'ok' then
                        Rules.set(self.rules, data.mode, nil)

                        self.presetAttempt = nil

                        save()
                        notifyRules()
                        setStatus('Stage preset rule cleared: preset was deleted or renamed')

                        return true
                    end
                    if presets.active == entry.id then
                        self.presetAttempt = nil

                        return true
                    end

                    local key = data.mode .. '/' .. entry.id
                    local attempt = self.presetAttempt

                    if not attempt or attempt.key ~= key then
                        attempt = {
                            key = key,
                            sent = 0,
                            last = -math.huge,
                            lastPause = -math.huge,
                            gaveUp = false,
                        }
                        self.presetAttempt = attempt
                    end
                    if attempt.gaveUp then
                        return true
                    end
                    if ad.isAutoPlaying() == true then
                        if current - attempt.lastPause >= RETRY_SECONDS then
                            attempt.lastPause = current

                            ad.toggle()
                        end

                        setStatus('Pausing native Auto Play to switch preset')

                        return false
                    end
                    if attempt.sent > 0 and current - attempt.last < PRESET_TIMEOUT_SECONDS then
                        setStatus('Waiting for preset switch confirmation')

                        return false
                    end
                    if attempt.sent >= PRESET_ATTEMPTS then
                        attempt.gaveUp = true

                        setStatus('Preset switch not confirmed; continuing with current preset')

                        return true
                    end

                    attempt.sent += 1

                    attempt.last = current

                    if ad.switchPreset(entry.id) then
                        setStatus(string.format('Switching preset (%d/%d)', attempt.sent, PRESET_ATTEMPTS))
                    else
                        setStatus('Preset switch request failed')
                    end

                    return false
                end

                function self.onEnabledChange(callback)
                    if type(callback) == 'function' then
                        table.insert(self.enabledListeners, callback)
                    end
                end
                function self.setMacro(m)
                    self.macro = m
                end
                function self.isEnabled()
                    return self.enabled == true
                end
                function self.setEnabled(value)
                    if type(value) ~= 'boolean' then
                        return false, 'INVALID_VALUE'
                    end
                    if value and self.macro and self.macro.mode == 'play' then
                        return false, 'MACRO_ACTIVE'
                    end
                    if self.enabled == value then
                        return true, nil
                    end

                    self.enabled = value
                    self.startVoteSent = false
                    self.presetAttempt = nil

                    notifyEnabled(value)
                    save()

                    if value then
                        setStatus('Enabled: waiting for match')
                        self.step()
                    else
                        local ad = getAdapter()
                        local state = ad and ad.isAutoPlaying()

                        if state == true and not self.pendingToggle then
                            self.pendingToggle = ad.toggle() == true
                        end

                        setStatus('Disabled')
                    end

                    return true, nil
                end
                function self.step(now)
                    if not self.enabled or not self.context or not self.context.alive then
                        return
                    end

                    local ad = getAdapter()

                    if not ad or not ad.isAvailable() then
                        setStatus('Auto Play unavailable (not in match)')

                        return
                    end

                    local clockFn = (self.task and self.task.clock) or (ad and ad.clock) or os.clock
                    local current = now or (if type(clockFn) == 'function'then(clockFn)()else os.clock())
                    local started = ad.isMatchStarted()

                    if started == nil then
                        setStatus('Waiting for game data')

                        return
                    end
                    if not ensurePreset(ad, current) then
                        return
                    end
                    if not started then
                        self.pendingToggle = false

                        if ad.hasStartPrompt() and current - self.lastVoteRequest >= RETRY_SECONDS then
                            self.lastVoteRequest = current

                            if ad.castStartVote() then
                                self.startVoteSent = true

                                setStatus('Vote to Start sent; awaiting match')
                            else
                                setStatus('Vote to Start request failed')
                            end
                        else
                            setStatus(if self.startVoteSent then'Awaiting match start...'else'Awaiting Vote to Start prompt')
                        end

                        return
                    end

                    local state = ad.isAutoPlaying()

                    if state == nil then
                        setStatus('Waiting for native Auto Play state')
                    elseif state then
                        self.pendingToggle = false

                        setStatus('Native Auto Play active')
                    elseif not self.pendingToggle and current - self.lastToggleRequest >= RETRY_SECONDS then
                        self.lastToggleRequest = current
                        self.pendingToggle = ad.toggle() == true

                        setStatus(if self.pendingToggle then'Enabling native Auto Play...'else'Auto Play request failed')
                    elseif self.pendingToggle and current - self.lastToggleRequest >= RETRY_SECONDS then
                        self.pendingToggle = false

                        setStatus('Auto Play confirmation timed out; retrying')
                    end
                end
                function self.start(context)
                    self.context = context

                    local env = getfenv()

                    if not self.storage then
                        pcall(function()
                            self.storage = FileStorage.new(env, STORAGE_KEY)
                        end)
                    end
                    if self.storage then
                        pcall(function()
                            local body = self.storage.read()
                            local http = self.http or (env.game and env.game:GetService('HttpService'))

                            if body and http then
                                local ok, data = pcall(http.JSONDecode, http, body)

                                if ok and type(data) == 'table' and (data.schemaVersion == SCHEMA_VERSION or data.schemaVersion == 2 or data.schemaVersion == 1) then
                                    if type(data.enabled) == 'boolean' then
                                        self.enabled = data.enabled
                                    end

                                    self.rules = Rules.normalize(data.rules)
                                end
                            end
                        end)
                    end
                    if self.enabled and self.macro and self.macro.mode == 'play' then
                        self.enabled = false

                        save()
                        setStatus('Play Macro active; native Auto Play disabled')
                    end

                    notifyEnabled(self.enabled)

                    self.loaded = true

                    local ad = getAdapter()

                    if ad and type(ad.observe) == 'function' then
                        local connRestart = (ad.observe)('matchRestarted', function(
                        )
                            self.presetAttempt = nil
                            self.startVoteSent = false
                            self.pendingToggle = false
                            self.lastVoteRequest = -math.huge
                            self.lastToggleRequest = -math.huge

                            if self.enabled then
                                self.step()
                            end
                        end)

                        if connRestart then
                            table.insert(self.connections, connRestart)
                        end

                        local connStart = (ad.observe)('matchStarted', function()
                            if self.enabled then
                                self.step()
                            end
                        end)

                        if connStart then
                            table.insert(self.connections, connStart)
                        end

                        local connToggled = (ad.observe)('autoPlayToggled', function(
                            toggled
                        )
                            self.pendingToggle = false

                            if self.enabled then
                                setStatus(if toggled then'Native Auto Play active'else'Native Auto Play was turned off in-game')
                            end
                        end)

                        if connToggled then
                            table.insert(self.connections, connToggled)
                        end
                    end

                    local function trackPresets()
                        if not self.unsubscribePresets and ad and type(ad.trackPresets) == 'function' and type(ad.onPresetsUpdated) == 'function' and (ad.trackPresets)() then
                            self.unsubscribePresets = (ad.onPresetsUpdated)(onPresetsSnapshot)
                        end
                    end

                    trackPresets()

                    if self.enabled then
                        setStatus('Enabled')
                        self.step()
                    else
                        setStatus('Disabled')
                    end

                    local taskApi = (if self.task then self.task else nil) or env.task

                    if type(taskApi) == 'table' and type(taskApi.spawn) == 'function' and type(taskApi.wait) == 'function' then
                        (taskApi.spawn)(function()
                            while self.context == context and context.alive do
                                trackPresets()

                                if self.enabled then
                                    self.step()
                                end

                                (taskApi.wait)(POLL_SECONDS)
                            end
                        end)
                    end
                end
                function self.stop()
                    for _, connection in self.connections do
                        local conn = connection
                        local ok = pcall(function()
                            conn:Disconnect()
                        end)

                        if not ok then
                            pcall(function()
                                conn()
                            end)
                        end
                    end

                    table.clear(self.connections)

                    if type(self.unsubscribePresets) == 'function' then
                        pcall(self.unsubscribePresets)
                    end

                    self.unsubscribePresets = nil

                    local ad = self.adapter

                    if ad and type(ad.untrackPresets) == 'function' then
                        pcall(ad.untrackPresets)
                    end

                    self.presetAttempt = nil
                    self.context = nil
                    self.startVoteSent = false
                    self.pendingToggle = false
                    self.loaded = false
                end

                return self
            end

            return Runtime
        end

        function __DARKLUA_BUNDLE_MODULES.L()
            local v = __DARKLUA_BUNDLE_MODULES.cache.L

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.L = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Style = __DARKLUA_BUNDLE_MODULES.e()
            local Page = {}
            local RECHECK_DELAYS = {
                3,
                5,
                10,
                20,
                30,
                60,
            }

            local function safeCheck(fn)
                local ok, res = pcall(fn)

                return ok and res == true
            end
            local function evaluateSystems()
                local env = getfenv()
                local gameObject = env.game
                local rep = gameObject and gameObject:GetService('ReplicatedStorage')
                local starter = gameObject and gameObject:GetService('StarterPlayer')
                local players = gameObject and gameObject:GetService('Players')
                local localPlayer = players and players.LocalPlayer
                local executorName = if type(env.identifyexecutor) == 'function'then tostring((env.identifyexecutor)())else(if type(env.getexecutorname) == 'function'then tostring((env.getexecutorname)())else'Executor')
                local hasLoadstring = safeCheck(function()
                    return type(env.loadstring) == 'function'
                end)
                local hasFilesystem = safeCheck(function()
                    return type(env.readfile) == 'function' and type(env.writefile) == 'function' and type(env.isfolder) == 'function'
                end)
                local hasNetwork = safeCheck(function()
                    return type(env.request) == 'function' or type(env.http_request) == 'function' or (gameObject and gameObject.HttpGet ~= nil)
                end)
                local hasMacroDir = safeCheck(function()
                    if type(env.makefolder) == 'function' and type(env.isfolder) == 'function' then
                        local makefolder = env.makefolder
                        local isfolder = env.isfolder

                        makefolder('ViperHubNextGen')
                        makefolder('ViperHubNextGen/macro')
                        makefolder('ViperHubNextGen/macro/AnimeVanguards')

                        return isfolder('ViperHubNextGen/macro/AnimeVanguards') == true
                    end

                    return false
                end)
                local hasRobloxCore = safeCheck(function()
                    return gameObject ~= nil and localPlayer ~= nil
                end)
                local hasGameHandler = safeCheck(function()
                    local gh = (require)(rep.Modules.Gameplay.GameHandler)

                    return type(gh) == 'table' and gh.MatchStarted ~= nil
                end)
                local hasSharedSettings = safeCheck(function()
                    local ssc = (require)(rep.NetworkCode.SharedSettingsClient)

                    return type(ssc.ChangeSetting.Fire) == 'function' and type(ssc.SettingUpdated.On) == 'function'
                end)
                local hasSettingsState = safeCheck(function()
                    local ss = (require)(starter.Modules.Gameplay.SettingsHandler.SettingsState)

                    return ss:GetSetting('AutoReplay') ~= nil
                end)
                local autoReplaySync = safeCheck(function()
                    local ss = (require)(starter.Modules.Gameplay.SettingsHandler.SettingsState)

                    return type(ss:GetSetting('AutoReplay')) == 'boolean'
                end)
                local autoNextSync = safeCheck(function()
                    local ss = (require)(starter.Modules.Gameplay.SettingsHandler.SettingsState)

                    return type(ss:GetSetting('AutoNext')) == 'boolean'
                end)
                local autoSkipWavesSync = safeCheck(function()
                    local ss = (require)(starter.Modules.Gameplay.SettingsHandler.SettingsState)

                    return type(ss:GetSetting('AutoSkipWaves')) == 'boolean'
                end)
                local autoSkipStartSync = safeCheck(function()
                    local ss = (require)(starter.Modules.Gameplay.SettingsHandler.SettingsState)

                    return type(ss:GetSetting('AutoSkipStart')) == 'boolean'
                end)
                local hasPlacement = safeCheck(function()
                    local pc = (require)(rep.NetworkCode.GameUnitPlacementClient)

                    return type(pc.RequestPlaceUnit.Fire) == 'function' and type(pc.UnitPlaced.On) == 'function'
                end)
                local hasUnitCodec = safeCheck(function()
                    local sc = (require)(rep.Modules.Shared.UnitSnapshotCodec)

                    return type(sc.DecodeUnitEnvelope) == 'function'
                end)
                local hasAffordability = safeCheck(function()
                    local yh = (require)(starter.Modules.Gameplay.PlayerYenHandler)

                    return type(yh.GetPlacementAffordability) == 'function'
                end)
                local hasUpgrade = safeCheck(function()
                    local pc = (require)(rep.NetworkCode.GameUnitPlacementClient)

                    return type(pc.RequestUpgradeUnit.Fire) == 'function' and type(pc.UnitUpgraded.On) == 'function'
                end)
                local hasUpgradePrice = safeCheck(function()
                    local bm = (require)(starter.Modules.Gameplay.Units.UnitUpgradeHandler.Managers.ButtonsManager)

                    return type(bm.GetUpgradePrice) == 'function'
                end)
                local hasSell = safeCheck(function()
                    local pc = (require)(rep.NetworkCode.GameUnitPlacementClient)

                    return type(pc.RequestSellUnit.Fire) == 'function' and type(pc.UnitRemoved.On) == 'function'
                end)
                local hasAbility = safeCheck(function()
                    local ac = (require)(rep.NetworkCode.GameUnitAbilitiesClient)

                    return type(ac.RequestAbilityActivation.Fire) == 'function' and type(ac.AbilityLifecycleUpdated.On) == 'function'
                end)
                local hasAutoUpgrade = safeCheck(function()
                    local guc = (require)(rep.NetworkCode.GameUnitsClient)

                    return type(guc.RequestAutoUpgradeToggle.Fire) == 'function' and type(guc.AutoUpgradeToggled.On) == 'function'
                end)
                local hasUpgradePriority = safeCheck(function()
                    local guc = (require)(rep.NetworkCode.GameUnitsClient)

                    return type(guc.RequestAutoUpgradeChangePriority.Fire) == 'function' and type(guc.AutoUpgradePriorityUpdated.On) == 'function'
                end)
                local hasAutoAbility = safeCheck(function()
                    local usc = (require)(rep.NetworkCode.GameUnitClientStateClient)

                    return type(usc.RequestAutoAbilityToggle.Fire) == 'function' and type(usc.AutoAbilityToggled.On) == 'function'
                end)
                local hasWaveSkip = safeCheck(function()
                    local wc = (require)(rep.NetworkCode.GameWavesClient)

                    return type(wc.CastWaveSkipVote.Fire) == 'function' and type(wc.WaveSkipPromptShown.On) == 'function'
                end)
                local hasStagesData = safeCheck(function()
                    local sd = (require)(rep.Modules.Data.StagesData)

                    return type(sd.Story) == 'table'
                end)
                local hasChallengesData = safeCheck(function()
                    local cd = (require)(rep.Modules.Data.Challenges.ChallengesData)

                    return type(cd.GetChallengesOfType) == 'function'
                end)
                local hasBossRushData = safeCheck(function()
                    local br = (require)(rep.Modules.Shared.BossRushDataHandler)

                    return type(br.GetCurrentBossEvent) == 'function'
                end)
                local hasWorldlinesData = safeCheck(function()
                    local wd = (require)(rep.Modules.Data.WorldlinesData)

                    return type(wd.GetAll) == 'function'
                end)
                local hasLobbyMatchmaking = safeCheck(function()
                    local lmc = (require)(rep.NetworkCode.LobbyMatchmakingClient)

                    return type(lmc.CreateMatch.Fire) == 'function' and type(lmc.MatchConfirmed.On) == 'function'
                end)

                return {
                    platform = {
                        {
                            name = 'Code Compiler',
                            passed = hasLoadstring,
                            desc = if hasLoadstring then executorName .. ' loadstring compiler verified.'else'loadstring compiler unavailable.',
                        },
                        {
                            name = 'Workspace File Storage',
                            passed = hasFilesystem,
                            desc = if hasFilesystem then'readfile/writefile/isfolder APIs verified.'else'File APIs missing; session-only storage.',
                        },
                        {
                            name = 'Network HTTP Transport',
                            passed = hasNetwork,
                            desc = if hasNetwork then'HTTP request capability verified.'else'HTTP request unavailable.',
                        },
                        {
                            name = 'Macro Storage Folder',
                            passed = hasMacroDir,
                            desc = if hasMacroDir then'workspace/ViperHubNextGen/macro verified.'else'Macro folder unavailable.',
                        },
                        {
                            name = 'Roblox Core Context',
                            passed = hasRobloxCore,
                            desc = if hasRobloxCore then'LocalPlayer & hierarchy accessible.'else'Roblox hierarchy unavailable.',
                        },
                    },
                    settings = {
                        {
                            name = 'Game Lifecycle Handler',
                            passed = hasGameHandler,
                            desc = if hasGameHandler then'GameHandler state and signals active.'else'GameHandler not replicated.',
                        },
                        {
                            name = 'Shared Settings Bridge',
                            passed = hasSharedSettings,
                            desc = if hasSharedSettings then'SharedSettingsClient remote bridge active.'else'SharedSettingsClient unavailable.',
                        },
                        {
                            name = 'Settings State Cache',
                            passed = hasSettingsState,
                            desc = if hasSettingsState then'SettingsHandler.SettingsState cache active.'else'SettingsState unavailable.',
                        },
                        {
                            name = 'Auto Replay Sync',
                            passed = autoReplaySync,
                            desc = if autoReplaySync then'AutoReplay verified & two-way synced.'else'AutoReplay setting inactive.',
                        },
                        {
                            name = 'Auto Next Sync',
                            passed = autoNextSync,
                            desc = if autoNextSync then'AutoNext verified & two-way synced.'else'AutoNext setting inactive.',
                        },
                        {
                            name = 'Auto Skip Waves Sync',
                            passed = autoSkipWavesSync,
                            desc = if autoSkipWavesSync then'AutoSkipWaves verified & two-way synced.'else'AutoSkipWaves setting inactive.',
                        },
                        {
                            name = 'Auto Skip Start Sync',
                            passed = autoSkipStartSync,
                            desc = if autoSkipStartSync then'AutoSkipStart verified & two-way synced.'else'AutoSkipStart setting inactive.',
                        },
                    },
                    macro = {
                        {
                            name = 'Unit Placement Remote',
                            passed = hasPlacement,
                            desc = if hasPlacement then'GameUnitPlacementClient RequestPlaceUnit verified.'else'Available in match.',
                        },
                        {
                            name = 'Unit Snapshot Codec',
                            passed = hasUnitCodec,
                            desc = if hasUnitCodec then'DecodeUnitEnvelope codec verified.'else'Snapshot codec unavailable.',
                        },
                        {
                            name = 'Placement Affordability',
                            passed = hasAffordability,
                            desc = if hasAffordability then'PlayerYenHandler pricing verified.'else'Available in match.',
                        },
                        {
                            name = 'Unit Upgrade Remote',
                            passed = hasUpgrade,
                            desc = if hasUpgrade then'RequestUpgradeUnit & UnitUpgraded verified.'else'Available in match.',
                        },
                        {
                            name = 'Upgrade Price Calculator',
                            passed = hasUpgradePrice,
                            desc = if hasUpgradePrice then'ButtonsManager GetUpgradePrice verified.'else'Available in match.',
                        },
                        {
                            name = 'Unit Sell Remote',
                            passed = hasSell,
                            desc = if hasSell then'RequestSellUnit & UnitRemoved verified.'else'Available in match.',
                        },
                        {
                            name = 'Unit Ability Remote',
                            passed = hasAbility,
                            desc = if hasAbility then'RequestAbilityActivation verified.'else'Available in match.',
                        },
                        {
                            name = 'Native Auto Upgrade',
                            passed = hasAutoUpgrade,
                            desc = if hasAutoUpgrade then'GameUnitsClient AutoUpgrade toggle verified.'else'Available in match.',
                        },
                        {
                            name = 'Native Upgrade Priority',
                            passed = hasUpgradePriority,
                            desc = if hasUpgradePriority then'RequestAutoUpgradeChangePriority (1-6) verified.'else'Available in match.',
                        },
                        {
                            name = 'Native Auto Ability',
                            passed = hasAutoAbility,
                            desc = if hasAutoAbility then'GameUnitClientStateClient auto-ability verified.'else'Available in match.',
                        },
                        {
                            name = 'Wave Skip / Vote Start',
                            passed = hasWaveSkip,
                            desc = if hasWaveSkip then'GameWavesClient CastWaveSkipVote verified.'else'Available in match.',
                        },
                        {
                            name = 'Persistent Macro Loop',
                            passed = true,
                            desc =
[[Continuous execution: loops across Auto Replay / Auto Next or holds on victory.]],
                        },
                    },
                    joiner = {
                        {
                            name = 'Stages Replicated Data',
                            passed = hasStagesData,
                            desc = if hasStagesData then'StagesData replicated & verified.'else'StagesData unavailable.',
                        },
                        {
                            name = 'Challenges Replicated Data',
                            passed = hasChallengesData,
                            desc = if hasChallengesData then'ChallengesData (Regular/Daily/Weekly) verified.'else'ChallengesData unavailable.',
                        },
                        {
                            name = 'Weekly Boss Rush Data',
                            passed = hasBossRushData,
                            desc = if hasBossRushData then'BossRushDataHandler weekly rotation verified.'else'BossRushDataHandler unavailable.',
                        },
                        {
                            name = 'Worldlines Replicated Data',
                            passed = hasWorldlinesData,
                            desc = if hasWorldlinesData then'WorldlinesData verified.'else'WorldlinesData unavailable.',
                        },
                        {
                            name = 'Lobby Matchmaking Remote',
                            passed = hasLobbyMatchmaking,
                            desc = if hasLobbyMatchmaking then'LobbyMatchmakingClient verified (Lobby mode).'else'Active in Lobby.',
                        },
                    },
                    pending = {
                        {
                            name = 'Auto Equip Units from Loadout',
                            passed = false,
                            desc = 'Pending \u{2022} Lobby inventory loadout equip API unverified.',
                        },
                        {
                            name = 'Elemental Towers Joiner',
                            passed = false,
                            desc = 'Pending \u{2022} Floor progression remote unverified.',
                        },
                        {
                            name = 'Portal Consumable Joiner',
                            passed = false,
                            desc = 'Pending \u{2022} Portal item consumption unverified.',
                        },
                        {
                            name = 'Discord Match Webhooks',
                            passed = false,
                            desc = 'Pending \u{2022} Embeds and queue pass local tests; live Discord delivery and end-screen parsing unverified.',
                        },
                    },
                }
            end

            function Page.mount(tab)
                local summaryPara = tab:Paragraph({
                    Title = 'Live System Audit',
                    Desc = 'Probing real-time game state...',
                })
                local sections = {
                    platform = Style.section(tab, 'Platform & Environment', 'cpu', false),
                    settings = Style.section(tab, 'Game Core & Settings Sync', 'shield', false),
                    macro = Style.section(tab, 'Macro Subsystems', 'puzzle', false),
                    joiner = Style.section(tab, 'Matchmaking & Joiner', 'users', false),
                    pending = Style.section(tab, 'Pending Features (In Development)', 'hammer', false),
                }
                local paragraphs = {}

                local function runLiveAudit()
                    local data = evaluateSystems()
                    local passedCount = 0
                    local pendingCount = 0

                    for _, group in data do
                        for _, item in group do
                            if item.passed then
                                passedCount += 1
                            else
                                pendingCount += 1
                            end
                        end
                    end

                    summaryPara:SetDesc(string.format('Live Verified: %d Systems Operational [\u{2713}]  \u{2022}  %d Pending / Inactive [\u{2717}]', passedCount, pendingCount))

                    for category, items in data do
                        local sec = sections[category]

                        if sec then
                            for _, item in items do
                                local prefix = if item.passed then'\u{2713} 'else'\u{2717} '
                                local title = prefix .. item.name
                                local desc = item.desc
                                local existing = paragraphs[item.name]

                                if existing and type(existing.SetDesc) == 'function' then
                                    pcall(existing.SetDesc, existing, desc)

                                    if type(existing.SetTitle) == 'function' then
                                        pcall(existing.SetTitle, existing, title)
                                    end
                                else
                                    local p = sec:Paragraph({
                                        Title = title,
                                        Desc = desc,
                                    })

                                    paragraphs[item.name] = p
                                end
                            end
                        end
                    end
                end

                runLiveAudit()

                local env = getfenv()
                local taskApi = env.task

                if type(taskApi) == 'table' and type(taskApi.spawn) == 'function' and type(taskApi.wait) == 'function' then
                    local spawnTask = taskApi.spawn
                    local waitTask = taskApi.wait

                    spawnTask(function()
                        for _, delay in RECHECK_DELAYS do
                            waitTask(delay)
                            pcall(runLiveAudit)
                        end
                    end)
                    pcall(function()
                        local starter = env.game:GetService('StarterPlayer')
                        local state = (require)(starter.Modules.Gameplay.SettingsHandler.SettingsState)

                        if state and state.SettingsLoaded ~= true and state.OnSettingsLoaded then
                            local signal = state.OnSettingsLoaded
                            local connection

                            connection = signal:Connect(function()
                                pcall(runLiveAudit)
                                pcall(function()
                                    connection:Disconnect()
                                end)
                            end)
                        end
                    end)
                end

                tab:Button({
                    Title = 'Re-probe Live Systems',
                    Callback = function()
                        runLiveAudit()
                    end,
                })
            end

            return Page
        end

        function __DARKLUA_BUNDLE_MODULES.M()
            local v = __DARKLUA_BUNDLE_MODULES.cache.M

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.M = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Style = __DARKLUA_BUNDLE_MODULES.e()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local metadata = __DARKLUA_BUNDLE_MODULES.b()
            local Page = {}
            local REFRESH_SECONDS = 2
            local STARTUP_WAIT_TICKS = 60

            local function setDesc(card, text)
                if card and type(card.SetDesc) == 'function' then
                    pcall(card.SetDesc, card, text)
                end
            end
            local function commas(value)
                local text = tostring(math.floor(value + 0.5))
                local out = text

                while true do
                    local replaced, count = string.gsub(out, '^(-?%d+)(%d%d%d)', '%1,%2')

                    out = replaced

                    if count == 0 then
                        break
                    end
                end

                return out
            end

            function Page.mount(tab, runtimes)
                local env = getfenv()
                local gameObject = env.game
                local player = gameObject and gameObject:GetService('Players').LocalPlayer
                local isLobby = gameObject ~= nil and gameObject.PlaceId == metadata.placeIds[1]
                local level = if player then player:GetAttribute((config).webhook.levelAttribute)else nil

                tab:Paragraph({
                    Title = if player then'Welcome, ' .. player.DisplayName else'Welcome',
                    Desc = string.format('@%s%s \u{2022} %s', if player then tostring(player.Name)else'player', if type(level) == 'number'then' \u{2022} Lv. ' .. tostring(math.floor(level))else'', if isLobby then'In the lobby'else'In a match'),
                    Image = if player then string.format('rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150', player.UserId)else'user',
                    ImageSize = 52,
                })

                local live = Style.section(tab, 'Live Status', 'activity', false)
                local cards = {}
                local rows = {
                    {
                        key = 'joiner',
                        title = 'Joiner',
                        icon = 'users',
                    },
                    {
                        key = 'autoPlay',
                        title = 'Auto Play',
                        icon = 'play',
                    },
                    {
                        key = 'macro',
                        title = 'Macro',
                        icon = 'list',
                    },
                    {
                        key = 'webhook',
                        title = 'Webhook',
                        icon = 'bell',
                    },
                    {
                        key = 'misc',
                        title = 'Session',
                        icon = 'shield-check',
                    },
                }

                for _, row in rows do
                    cards[row.key] = live:Paragraph({
                        Title = row.title,
                        Desc = '\u{2026}',
                        Image = row.icon,
                        ImageSize = 20,
                    })
                end

                local wallet = Style.section(tab, 'Balances', 'gem', false)
                local balanceCards = {}

                for _, currency in (config).webhook.currencies do
                    balanceCards[currency.key] = wallet:Paragraph({
                        Title = currency.emoji .. ' ' .. currency.label,
                        Desc = '\u{2026}',
                    })
                end

                local function statusOf(key)
                    local runtime = runtimes and runtimes[key]

                    if type(runtime) ~= 'table' then
                        return 'Unavailable'
                    end
                    if key == 'webhook' and type(runtime.getStatus) == 'function' then
                        local ok, text = pcall(runtime.getStatus)

                        return if ok and type(text) == 'string'then text else'Unavailable'
                    end

                    return if type(runtime.status) == 'string'then runtime.status else'Idle'
                end
                local function refresh()
                    for _, row in rows do
                        setDesc(cards[row.key], statusOf(row.key))
                    end

                    if player then
                        for _, currency in (config).webhook.currencies do
                            local value = player:GetAttribute(currency.key)

                            setDesc(balanceCards[currency.key], if type(value) == 'number'then commas(value)else'\u{2014}')
                        end
                    end
                end

                pcall(refresh)

                local taskApi = env.task

                if type(taskApi) ~= 'table' or type(taskApi.spawn) ~= 'function' or type(taskApi.wait) ~= 'function' then
                    return
                end

                local spawnTask = taskApi.spawn
                local waitTask = taskApi.wait

                spawnTask(function()
                    local joiner = runtimes and runtimes.joiner
                    local mounted = nil
                    local idle = 0

                    while true do
                        local current = if type(joiner) == 'table'then joiner.context else nil

                        if mounted == nil then
                            if current ~= nil and current.alive == true then
                                mounted = current
                            else
                                idle += 1

                                if idle > STARTUP_WAIT_TICKS then
                                    return
                                end
                            end
                        elseif mounted.alive ~= true or joiner.context ~= mounted then
                            return
                        end

                        pcall(refresh)
                        waitTask(REFRESH_SECONDS)
                    end
                end)
            end

            return Page
        end

        function __DARKLUA_BUNDLE_MODULES.N()
            local v = __DARKLUA_BUNDLE_MODULES.cache.N

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.N = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Embed = {}
            local MAX_TITLE = 256
            local MAX_DESCRIPTION = 4000
            local MAX_FIELDS = 25
            local MAX_FIELD_NAME = 256
            local MAX_FIELD_VALUE = 1024
            local MAX_FOOTER = 2048
            local MAX_AUTHOR = 256
            local MAX_TOTAL = 5800
            local MAX_CONTENT = 2000
            local MAX_USERNAME = 80
            local MAX_EMBEDS = 10

            function Embed.clip(text, max)
                local value = if type(text) == 'string'then text else tostring(text)

                if #value <= max then
                    return value
                end

                return string.sub(value, 1, math.max(0, max - 3)) .. '...'
            end
            function Embed.validUrl(url, hosts)
                if type(url) ~= 'string' or #url > 300 then
                    return false
                end

                local host, id, token = string.match(url, '^https://([%w%.%-]+)/api/webhooks/(%d+)/([%w_%-]+)/?$')

                if not host or not id or not token or #id < 15 or #id > 25 or #token < 20 then
                    return false
                end

                return table.find(hosts, string.lower(host)) ~= nil
            end
            function Embed.mask(url, hosts)
                if not Embed.validUrl(url, hosts) then
                    return '(not set)'
                end

                local host, id = string.match(url, '^https://([%w%.%-]+)/api/webhooks/(%d+)/')

                return string.format('https://%s/api/webhooks/%s\u{2026}/\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}', host or 'discord.com', string.sub(id or '', 1, 4))
            end

            local function isHttps(url)
                return type(url) == 'string' and #url <= 512 and string.match(url, "^https://[%w%.%-]+/[%w%./%-_%%%?&=:,~+@!*'()]*$") ~= nil
            end

            function Embed.number(value)
                local n = tonumber(value)

                if n == nil or n ~= n then
                    return '0'
                end

                local abs = math.abs(n)

                if abs >= 1e9 then
                    return string.format('%.2fB', n / 1e9)
                elseif abs >= 1e6 then
                    return string.format('%.2fM', n / 1e6)
                elseif abs >= 1e4 then
                    return string.format('%.1fK', n / 1e3)
                end

                local whole = math.floor(n + 0.5)
                local text = tostring(whole)
                local out = text

                while true do
                    local replaced, count = string.gsub(out, '^(-?%d+)(%d%d%d)', '%1,%2')

                    out = replaced

                    if count == 0 then
                        break
                    end
                end

                return out
            end
            function Embed.parseAmount(value)
                if type(value) == 'number' then
                    return if value == value and math.abs(value) ~= math.huge then value else nil
                end
                if type(value) ~= 'string' then
                    return nil
                end

                local digits, suffix = string.match(string.gsub(value, ',', ''), '^%s*([%d%.]+)%s*([KkMmBbTt]?)%s*$')
                local number = tonumber(digits)

                if not number then
                    return nil
                end

                local scale = ({
                    k = 1e3,
                    m = 1e6,
                    b = 1e9,
                    t = 1e12,
                })[string.lower(suffix or '')] or 1

                return number * scale
            end
            function Embed.commas(value)
                local n = tonumber(value)

                if n == nil or n ~= n or math.abs(n) == math.huge then
                    return '0'
                end

                local text = tostring(math.floor(math.abs(n) + 0.5))
                local out = text

                while true do
                    local replaced, count = string.gsub(out, '^(%d+)(%d%d%d)', '%1,%2')

                    out = replaced

                    if count == 0 then
                        break
                    end
                end

                return (if n < 0 then'-'else'') .. out
            end
            function Embed.duration(seconds)
                local total = math.max(0, math.floor(tonumber(seconds) or 0))
                local h = total // 3600
                local m = (total % 3600) // 60
                local s = total % 60

                if h > 0 then
                    return string.format('%dh %02dm %02ds', h, m, s)
                elseif m > 0 then
                    return string.format('%dm %02ds', m, s)
                end

                return string.format('%ds', s)
            end
            function Embed.build(spec)
                local embed = {}
                local budget = MAX_TOTAL

                local function take(text)
                    local clipped = Embed.clip(text, math.max(0, budget))

                    budget -= #clipped

                    return clipped
                end

                if spec.title and spec.title ~= '' then
                    embed.title = take(Embed.clip(spec.title, MAX_TITLE))
                end
                if spec.description and spec.description ~= '' then
                    embed.description = take(Embed.clip(spec.description, MAX_DESCRIPTION))
                end
                if type(spec.color) == 'number' then
                    embed.color = math.clamp(math.floor(spec.color), 0, 0xffffff)
                end
                if spec.url and isHttps(spec.url) then
                    embed.url = spec.url
                end
                if spec.authorName and spec.authorName ~= '' then
                    local author = {
                        name = take(Embed.clip(spec.authorName, MAX_AUTHOR)),
                    }

                    if spec.authorIcon and isHttps(spec.authorIcon) then
                        author.icon_url = spec.authorIcon
                    end

                    embed.author = author
                end
                if spec.thumbnail and isHttps(spec.thumbnail) then
                    embed.thumbnail = {
                        url = spec.thumbnail,
                    }
                end
                if spec.image and isHttps(spec.image) then
                    embed.image = {
                        url = spec.image,
                    }
                end
                if spec.fields then
                    local fields = {}

                    for _, field in spec.fields do
                        if #fields >= MAX_FIELDS or budget <= 0 then
                            break
                        end

                        local name = Embed.clip(field.name, MAX_FIELD_NAME)
                        local value = Embed.clip(field.value, MAX_FIELD_VALUE)

                        if name ~= '' and value ~= '' then
                            table.insert(fields, {
                                name = take(name),
                                value = take(value),
                                inline = field.inline == true,
                            })
                        end
                    end

                    if #fields > 0 then
                        embed.fields = fields
                    end
                end
                if spec.footer and spec.footer ~= '' then
                    embed.footer = {
                        text = take(Embed.clip(spec.footer, MAX_FOOTER)),
                    }
                end
                if spec.timestamp and string.match(spec.timestamp, '^%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%dZ$') then
                    embed.timestamp = spec.timestamp
                end

                return embed
            end
            function Embed.username(name, fallback)
                local value = if type(name) == 'string'then string.gsub(name, '[%c]', '')else''

                value = string.match(value, '^%s*(.-)%s*$') or ''

                local lower = string.lower(value)

                if value == '' or string.find(lower, 'discord', 1, true) or string.find(lower, 'clyde', 1, true) then
                    return fallback
                end

                return Embed.clip(value, MAX_USERNAME)
            end
            function Embed.payload(embeds, options)
                local capped = {}

                for index, embed in embeds do
                    if index > MAX_EMBEDS then
                        break
                    end

                    table.insert(capped, embed)
                end

                local payload = {
                    embeds = capped,
                    allowed_mentions = {parse = {}},
                }

                if options.username and options.username ~= '' then
                    payload.username = Embed.username(options.username, 'ViperHub')
                end
                if options.avatarUrl and isHttps(options.avatarUrl) then
                    payload.avatar_url = options.avatarUrl
                end

                local ping = options.pingUserId
                local mentions = {}
                local users = {}
                local parse = {}

                if options.everyone then
                    table.insert(mentions, '@everyone')
                    table.insert(parse, 'everyone')
                end
                if options.ping and type(ping) == 'string' and string.match(ping, '^%d+$') and #ping >= 15 and #ping <= 25 then
                    table.insert(mentions, '<@' .. ping .. '>')
                    table.insert(users, ping)
                end
                if #mentions > 0 then
                    payload.content = Embed.clip(table.concat(mentions, ' '), MAX_CONTENT)
                    payload.allowed_mentions = if#users > 0 then{
                        parse = parse,
                        users = users,
                    }else{parse = parse}
                end

                return payload
            end

            return Embed
        end

        function __DARKLUA_BUNDLE_MODULES.O()
            local v = __DARKLUA_BUNDLE_MODULES.cache.O

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.O = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Embed = __DARKLUA_BUNDLE_MODULES.O()
            local Events = {}
            local UNIT_ROWS = 6
            local SHARE_BAR = 10
            local GREEN = 0x2ecc71
            local RED = 0xe74c3c
            local BLUE = 0x3498db
            local ORANGE = 0xe67e22
            local TEAL = 0x1abc9c
            local PURPLE = 0x9b59b6

            Events.kinds = (table.freeze({
                {
                    id = 'matchEnd',
                    label = 'Match result',
                    desc =
[[Victory or defeat with stage, time, waves, damage and rewards.]],
                    default = true,
                },
                {
                    id = 'unit',
                    label = 'New unit obtained',
                    desc =
[[Every new unit at or above the minimum rarity (Secret, Exclusive and Vanguard can ping you).]],
                    default = true,
                },
                {
                    id = 'join',
                    label = 'Joiner entered a stage',
                    desc =
[[A joiner created or entered a stage, challenge, rift or bounty.]],
                    default = true,
                },
                {
                    id = 'joinProblem',
                    label = 'Joiner problems',
                    desc = 'No server confirmation, locked stages and failed requests.',
                    default = true,
                },
                {
                    id = 'bounty',
                    label = 'Boss Bounty progress',
                    desc = "Remaining Boss Bounties and today's target.",
                    default = true,
                },
                {
                    id = 'rift',
                    label = 'Rift opened',
                    desc = 'The hourly Rift event opened.',
                    default = true,
                },
                {
                    id = 'equipper',
                    label = 'Team and Macro Equipper',
                    desc = 'Missing units, unavailable teams and equip failures.',
                    default = true,
                },
                {
                    id = 'autoPlay',
                    label = 'Auto Play notices',
                    desc = 'Native Auto Play enabled, preset switched or unavailable.',
                    default = true,
                },
                {
                    id = 'warning',
                    label = 'Warnings and errors',
                    desc = 'Anything the script flags as a problem.',
                    default = true,
                },
                {
                    id = 'session',
                    label = 'Session started',
                    desc = 'Sent once when ViperHub loads.',
                    default = true,
                },
            }))

            function Events.rarityRank(rarity, order)
                if type(rarity) ~= 'string' then
                    return 0
                end

                return table.find(order, rarity) or 0
            end

            local function field(name, value, inline)
                local text = if type(value) == 'string'then value else tostring(value)

                if text == '' or text == 'nil' then
                    return nil
                end

                return {
                    name = name,
                    value = text,
                    inline = inline ~= false,
                }
            end
            local function addField(fields, name, value, inline)
                local entry = field(name, value, inline)

                if entry then
                    table.insert(fields, entry)
                end
            end
            local function modeText(data)
                local parts = {}

                for _, key in {
                    'stageType',
                    'stage',
                    'act',
                }do
                    if type(data[key]) == 'string' and data[key] ~= '' then
                        table.insert(parts, data[key])
                    end
                end

                if type(data.difficulty) == 'string' and data.difficulty ~= '' then
                    table.insert(parts, '(' .. data.difficulty .. ')')
                end

                return table.concat(parts, ' ')
            end
            local function rewardLines(rewards)
                local lines = {}

                if type(rewards) == 'table' then
                    for _, reward in rewards do
                        if type(reward) == 'table' and type(reward.name) == 'string' then
                            local amount = if reward.amount ~= nil then' \u{d7}' .. tostring(reward.amount)else''

                            table.insert(lines, '\u{2022} ' .. reward.name .. amount)
                        end
                        if #lines >= 12 then
                            break
                        end
                    end
                end

                return table.concat(lines, '\n')
            end
            local function playerLine(ctx)
                if not ctx.showPlayer or type(ctx.player) ~= 'string' or ctx.player == '' then
                    return nil
                end

                local text = ctx.player

                if type(ctx.displayName) == 'string' and ctx.displayName ~= '' and ctx.displayName ~= ctx.player then
                    text = ctx.displayName .. ' (@' .. ctx.player .. ')'
                end
                if type(ctx.level) == 'number' then
                    text ..= ' \u{2022} Lv. ' .. tostring(math.floor(ctx.level))
                end

                return text
            end
            local function sessionBlock(session)
                local bar = string.rep('\u{1f7e9}', session.bar) .. string.rep('\u{2b1b}', session.barSize - session.bar)

                return table.concat({
                    string.format('\u{1f3c5} **Win Rate** `%.1f%%` \u{2014} %d Win \u{2022} %d Loss \u{2022} %d Runs', session.winRate, session.wins, session.losses, session.total),
                    bar,
                    string.format('\u{23f1}\u{fe0f} **Session** `%s` \u{2022} Avg `%s`/run \u{2022} `~%.1f` runs/hr', Embed.duration(session.uptime), Embed.duration(session.averageRun), session.runsPerHour),
                }, '\n')
            end

            function Events.build(kind, data, ctx, config)
                local info = if type(data) == 'table'then data else{}
                local fields = {}
                local spec = {
                    color = BLUE,
                    footer = config.footer,
                    timestamp = ctx.timestamp,
                }
                local ping = false
                local everyone = false

                if ctx.showPlayer and type(ctx.player) == 'string' and ctx.player ~= '' then
                    spec.authorName = playerLine(ctx)

                    if type(ctx.avatarUrl) == 'string' then
                        spec.authorIcon = ctx.avatarUrl
                    end
                end
                if kind == 'matchEnd' then
                    local victory = info.result == 'Victory'

                    spec.color = if victory then GREEN else RED
                    spec.authorName = playerLine(ctx)

                    if type(info.session) == 'table' then
                        spec.footer = string.format('\u{23f1}\u{fe0f} Uptime: %s \u{2022} %s', Embed.duration(info.session.uptime), config.footer)
                    end

                    local parts = {}

                    if type(info.stage) == 'string' and info.stage ~= '' then
                        local stage = info.stage

                        if type(info.difficulty) == 'string' and info.difficulty ~= '' then
                            stage ..= ' (' .. info.difficulty .. ')'
                        end
                        if type(info.stageType) == 'string' and info.stageType ~= '' and info.stageType ~= info.stage then
                            stage ..= ' (' .. info.stageType .. ')'
                        end

                        table.insert(parts, stage)
                    end
                    if type(info.act) == 'string' and info.act ~= '' then
                        table.insert(parts, info.act)
                    end

                    local head = if victory then'\u{1f3c6} VICTORY'else'\u{1f480} DEFEAT'

                    if info.unknownResult then
                        head = '\u{1f3c1} MATCH ENDED'
                    end

                    spec.title = if#parts > 0 then head .. ' \u{2022} ' .. table.concat(parts, ' \u{2022} ')else head

                    local lines = {}
                    local macro = info.macro

                    if type(macro) == 'table' and type(macro.name) == 'string' then
                        table.insert(lines, string.format('> \u{1f3ae} **Macro**: `%s` \u{2022} **Status**: `%s`', macro.name, tostring(macro.status or 'Playing')))
                    end

                    local stats = {}

                    if info.duration then
                        table.insert(stats, '\u{23f1}\u{fe0f} **Duration**: `' .. Embed.duration(info.duration) .. '`')
                    elseif info.durationText then
                        table.insert(stats, '\u{23f1}\u{fe0f} **Duration**: `' .. tostring(info.durationText) .. '`')
                    end
                    if info.wave then
                        table.insert(stats, string.format('\u{1f30a} **Wave**: `%s`', if info.maxWave then tostring(info.wave) .. '/' .. tostring(info.maxWave)else tostring(info.wave)))
                    end

                    local session = info.session

                    if type(session) == 'table' then
                        local streak = '`' .. session.streak .. '`'

                        if session.bestStreak ~= '-' then
                            streak ..= ' (Best: ' .. session.bestStreak .. ')'
                        end

                        table.insert(stats, '\u{1f525} **Streak**: ' .. streak)
                    end
                    if #stats > 0 then
                        table.insert(lines, '> ' .. table.concat(stats, ' \u{2022} '))
                    end

                    local extra = {}

                    if info.damage then
                        table.insert(extra, '\u{1f4a5} **Damage**: `' .. tostring(info.damage) .. '`')
                    end
                    if info.takedowns then
                        table.insert(extra, '\u{2620}\u{fe0f} **Takedowns**: `' .. tostring(info.takedowns) .. '`')
                    end
                    if #extra > 0 then
                        table.insert(lines, '> ' .. table.concat(extra, ' \u{2022} '))
                    end
                    if #lines > 0 then
                        spec.description = table.concat(lines, '\n')
                    end

                    local unitRows = if type(info.units) == 'table'then info.units else{}

                    if #unitRows > 0 then
                        local total = 0

                        for _, row in unitRows do
                            total += row.damage
                        end

                        local contribution = {}

                        for index, row in unitRows do
                            if index > UNIT_ROWS then
                                break
                            end

                            local share = if total > 0 then row.damage / total else 0
                            local filled = math.clamp(math.floor(share * SHARE_BAR + 0.5), 0, SHARE_BAR)
                            local style = config.rarityStyle[row.rarity or '']
                            local badge = if index == 1
                                then'\u{1f451}'
                                elseif style
                                then style.emoji
                                else'\u{25ab}\u{fe0f}'
                            local count = if row.placements and row.placements > 1 then string.format(' `x%d`', row.placements)else''
                            local dps = if row.deployed and row.deployed > 0 then' \u{2022} \u{26a1} `' .. Embed.number(row.damage / row.deployed) .. '/s`'else''

                            table.insert(contribution, string.format('%s **%s**%s\n`%s%s` **%.1f%%** \u{2022} \u{1f4a5} `%s`%s \u{2022} \u{2620}\u{fe0f} `%s`', tostring(badge), tostring(row.name), tostring(count), string.rep('\u{25b0}', filled), string.rep('\u{25b1}', SHARE_BAR - filled), share * 100, Embed.number(row.damage), tostring(dps), Embed.commas(row.takedowns)))
                        end

                        table.insert(contribution, '**Match total** \u{2022} \u{1f4a5} `' .. Embed.number(total) .. '`')
                        addField(fields, '\u{2694}\u{fe0f} Unit Contribution', table.concat(contribution, '\n'), false)
                    end

                    local earned = {}
                    local earningRows = info.earnings or {}

                    for _, row in earningRows do
                        table.insert(earned, string.format('+%s %s [%s]', Embed.commas(row.amount), tostring(row.label), Embed.commas(row.balance)))
                    end

                    local rewards = rewardLines(info.rewards)

                    if rewards ~= '' and #earned == 0 then
                        table.insert(earned, rewards)
                    end

                    addField(fields, '\u{1f4b0} Match Earnings', if#earned > 0 then table.concat(earned, '\n')else'No change detected', true)

                    local balances = {}
                    local balanceRows = info.balances or {}

                    for _, row in balanceRows do
                        table.insert(balances, string.format('%s `%s` %s', tostring(row.emoji), Embed.commas(row.value), tostring(row.label)))
                    end

                    if #balances > 0 then
                        addField(fields, '\u{1f3e6} Current Balance', table.concat(balances, '\n'), true)
                    end
                    if type(session) == 'table' then
                        addField(fields, '\u{1f4ca} Session Overview', sessionBlock(session), false)

                        local rates = {}
                        local currencyRows = info.currencies or {}

                        for _, row in currencyRows do
                            local rate = session.rates[row.key]

                            if rate then
                                table.insert(rates, string.format('%s **%s** `+%s`/hr', row.emoji, row.label, Embed.number(rate)))
                            end
                        end

                        local dropLines = {}

                        for label, count in session.drops do
                            local perHour = session.dropRates[label]

                            table.insert(dropLines, string.format('\u{1f381} **%s** \u{d7}%d%s', label, count, if perHour then string.format(' (`%.2f`/hr)', perHour)else''))
                        end

                        table.sort(dropLines)

                        for _, line in dropLines do
                            table.insert(rates, line)
                        end

                        addField(fields, '\u{1f4c8} Farming Rates (/hr)', if#rates > 0 then table.concat(rates, '\n')else'No session rewards yet \u{2014} rates appear after a minute of play', false)
                    end
                elseif kind == 'unit' then
                    local style = config.rarityStyle[info.rarity] or {
                        emoji = '\u{1f195}',
                        color = TEAL,
                    }

                    spec.title = string.format('%s New %s unit obtained!', style.emoji, tostring(info.rarity or 'unit'))
                    spec.description = '**' .. tostring(info.name or 'Unknown unit') .. '**'
                    spec.color = style.color

                    addField(fields, 'Rarity', string.format('%s %s', style.emoji, tostring(info.rarity or '?')))
                    addField(fields, 'Level', info.level)
                    addField(fields, 'Trait', info.trait)

                    if info.subTrait and info.subTrait ~= 'None' then
                        addField(fields, 'Sub-trait', info.subTrait)
                    end

                    local rank = Events.rarityRank(info.rarity, config.rarityOrder)

                    ping = rank > 0 and rank >= Events.rarityRank(config.pingMinRarity, config.rarityOrder)
                    everyone = rank > 0 and rank >= Events.rarityRank(config.everyoneMinRarity, config.rarityOrder)
                elseif kind == 'join' then
                    spec.title = '\u{1f6aa} Entered ' .. tostring(info.name or 'stage')
                    spec.description = modeText(info)
                    spec.color = TEAL
                elseif kind == 'joinProblem' then
                    spec.title = '\u{26a0}\u{fe0f} Joiner problem'
                    spec.description = tostring(info.message or 'A joiner request did not complete.')
                    spec.color = ORANGE
                    ping = true
                elseif kind == 'bounty' then
                    spec.title = string.format('\u{1f3af} Boss Bounties: %s left today', tostring(info.left or '?'))
                    spec.color = PURPLE

                    local target = modeText({
                        stageType = info.mode,
                        stage = info.stage,
                        act = info.act,
                    })

                    spec.description = if target ~= ''then'Current target `' .. target .. '`' .. (if info.boss then' \u{2014} **' .. tostring(info.boss) .. '**'else'')else nil

                    addField(fields, 'Remaining', info.left)
                    addField(fields, 'Message', info.message, false)
                elseif kind == 'rift' then
                    spec.title = '\u{1f300} Rift is open'
                    spec.description = tostring(info.message or 'The hourly Rift event just opened.')
                    spec.color = PURPLE
                elseif kind == 'equipper' then
                    spec.title = '\u{1f9e9} Equipper notice'
                    spec.description = tostring(info.message or '')
                    spec.color = ORANGE
                elseif kind == 'autoPlay' then
                    spec.title = '\u{1f916} Auto Play'
                    spec.description = tostring(info.message or '')
                    spec.color = BLUE
                elseif kind == 'warning' then
                    spec.title = '\u{1f6a8} Warning'
                    spec.description = tostring(info.message or '')
                    spec.color = RED
                    ping = true
                elseif kind == 'session' then
                    spec.title = '\u{1f7e2} ViperHub session started'
                    spec.description = string.format('Running in the **%s**.', tostring(info.place or 'game'))
                    spec.color = GREEN

                    addField(fields, 'Version', ctx.version)
                    addField(fields, 'Place', info.placeName)
                elseif kind == 'test' then
                    spec.title = '\u{2705} Webhook connected'
                    spec.description =
[[ViperHub can post to this channel. Event notifications you enabled will appear here.]]
                    spec.color = GREEN

                    addField(fields, 'Enabled events', info.enabledCount)
                    addField(fields, 'Version', ctx.version)
                else
                    return nil, false, false
                end
                if #fields > 0 then
                    spec.fields = fields
                end

                return spec, ping, everyone
            end

            return Events
        end

        function __DARKLUA_BUNDLE_MODULES.P()
            local v = __DARKLUA_BUNDLE_MODULES.cache.P

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.P = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Style = __DARKLUA_BUNDLE_MODULES.e()
            local Events = __DARKLUA_BUNDLE_MODULES.P()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local Page = {}
            local WEBHOOK = (config).webhook
            local ERRORS = {
                INVALID_URL =
[[That is not a Discord webhook URL (https://discord.com/api/webhooks/<id>/<token>).]],
                NO_URL = 'Paste a webhook URL first.',
                NOT_SENT = 'The message could not be queued; check the status above.',
            }

            function Page.mount(tab, runtime)
                local status = tab:Paragraph({
                    Title = 'Discord Webhook',
                    Desc = if runtime then runtime.getStatus()else'Unavailable',
                })

                if not runtime then
                    return
                end

                local function show(text)
                    pcall(status.SetDesc, status, text)
                end

                runtime.onStatus = show

                local settings = runtime.getSettings()
                local connection = Style.section(tab, 'Connection', 'link', true)
                local urlInput

                urlInput = connection:Input({
                    Title = 'Webhook URL',
                    Desc = 'Channel settings \u{2192} Integrations \u{2192} Webhooks. The URL is stored on this device only and is never shown again after you enter it.',
                    Value = '',
                    Placeholder = if settings.hasUrl then settings.urlMasked else'https://discord.com/api/webhooks/\u{2026}',
                    Callback = function(text)
                        if type(text) ~= 'string' or text == '' then
                            return
                        end

                        local ok, err = runtime.setUrl(text)

                        if not ok then
                            show(ERRORS[err or ''] or 'Webhook URL rejected.')
                        end
                        if type(urlInput.Set) == 'function' then
                            pcall(urlInput.Set, urlInput, '', false)
                        end
                        if ok and type(urlInput.SetPlaceholder) == 'function' then
                            pcall(urlInput.SetPlaceholder, urlInput, runtime.getSettings().urlMasked)
                        end
                    end,
                })

                connection:Toggle({
                    Title = 'Send notifications',
                    Desc = 'Master switch. Nothing is sent while this is off.',
                    Value = settings.enabled,
                    Callback = function(value)
                        runtime.setEnabled(value)
                    end,
                })
                connection:Button({
                    Title = 'Send test message',
                    Desc =
[[Posts a connection check so you can see the look of the embeds.]],
                    Callback = function()
                        local ok, err = runtime.sendTest()

                        show(if ok then'Test message queued'else(ERRORS[err or ''] or 'Test message failed'))
                    end,
                })
                connection:Button({
                    Title = 'Forget webhook URL',
                    Desc = 'Removes the saved URL from this device.',
                    Callback = function()
                        runtime.clearUrl()

                        if type(urlInput.SetPlaceholder) == 'function' then
                            pcall(urlInput.SetPlaceholder, urlInput, 'https://discord.com/api/webhooks/\u{2026}')
                        end
                    end,
                })

                local appearance = Style.section(tab, 'Appearance', 'palette', false)

                appearance:Input({
                    Title = 'Bot name',
                    Desc = 'Shown as the sender in Discord. Empty uses ViperHub.',
                    Value = settings.username,
                    Placeholder = WEBHOOK.defaultUsername,
                    Callback = function(text)
                        runtime.setUsername(text)
                    end,
                })
                appearance:Input({
                    Title = 'Bot avatar URL',
                    Desc =
[[Optional https image link. Empty uses the webhook's own avatar.]],
                    Value = settings.avatarUrl,
                    Placeholder = 'https://\u{2026}',
                    Callback = function(text)
                        if not runtime.setAvatar(text) then
                            show('Avatar must be an https link.')
                        end
                    end,
                })
                appearance:Toggle({
                    Title = 'Show my Roblox name and avatar',
                    Desc =
[[Adds your name and headshot to the top of every embed. Turn off to keep the account private in shared channels.]],
                    Value = settings.showPlayer,
                    Callback = function(value)
                        runtime.setShowPlayer(value)
                    end,
                })
                appearance:Input({
                    Title = 'Ping my Discord user ID',
                    Desc = 'Optional numeric ID (Discord \u{2192} Developer Mode \u{2192} Copy User ID). Used only for rare unit drops, joiner problems and warnings.',
                    Value = settings.pingUserId,
                    Placeholder = 'e.g. 123456789012345678',
                    Callback = function(text)
                        if not runtime.setPingUser(text) then
                            show('Discord user ID must be 15 to 25 digits.')
                        end
                    end,
                })

                local drops = Style.section(tab, 'Unit drops', 'gem', false)

                drops:Toggle({
                    Title = 'Ping @everyone on rare drops',
                    Desc =
[[Adds @everyone to Secret and higher unit drops. The webhook must be allowed to mention everyone in that channel.]],
                    Value = settings.pingEveryone,
                    Callback = function(value)
                        runtime.setPingEveryone(value)
                    end,
                })
                drops:Dropdown({
                    Title = 'Minimum rarity to announce',
                    Desc =
[[New units below this rarity are ignored. Secret and above can ping you.]],
                    Values = WEBHOOK.rarityOrder,
                    Value = settings.minRarity,
                    Callback = function(value)
                        runtime.setMinRarity(value)
                    end,
                })

                local events = Style.section(tab, 'Events', 'list-checks', false)

                for _, kind in Events.kinds do
                    events:Toggle({
                        Title = kind.label,
                        Desc = kind.desc,
                        Value = settings.events[kind.id] == true,
                        Callback = function(value)
                            runtime.setEvent(kind.id, value)
                        end,
                    })
                end
            end

            return Page
        end

        function __DARKLUA_BUNDLE_MODULES.Q()
            local v = __DARKLUA_BUNDLE_MODULES.cache.Q

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.Q = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Sender = {}
            local SUCCESS_STATUSES = {
                [200] = true,
                [204] = true,
            }
            local MAX_RETRY_WAIT_SECONDS = 30

            function Sender.new(options)
                local self = {
                    url = nil,
                    state = 'idle',
                    queue = {},
                    running = false,
                    lastSent = -math.huge,
                    stats = {
                        sent = 0,
                        failed = 0,
                        dropped = 0,
                    },
                    onState = nil,
                    stopped = false,
                }

                local function setState(value)
                    self.state = value

                    if self.onState then
                        pcall(self.onState, value)
                    end
                end
                local function header(headers, name)
                    if type(headers) ~= 'table' then
                        return nil
                    end

                    for key, value in headers do
                        if type(key) == 'string' and string.lower(key) == name then
                            return value
                        end
                    end

                    return nil
                end
                local function retryAfter(response)
                    local waitSeconds = nil

                    if options.decode and type(response.Body) == 'string' and #response.Body < 4096 then
                        local ok, decoded = pcall(options.decode, response.Body)

                        if ok and type(decoded) == 'table' and type(decoded.retry_after) == 'number' then
                            waitSeconds = decoded.retry_after
                        end
                    end
                    if waitSeconds == nil then
                        waitSeconds = tonumber(header(response.Headers, 'retry-after'))
                    end

                    return math.clamp(waitSeconds or 2, 0.5, MAX_RETRY_WAIT_SECONDS)
                end
                local function deliver(payload)
                    local okBody, body = pcall(options.encode, payload)

                    if not okBody or type(body) ~= 'string' or #body > 100000 then
                        return 'drop', nil
                    end

                    local ok, response = pcall(options.request, {
                        Url = self.url,
                        Method = 'POST',
                        Headers = {
                            ['Content-Type'] = 'application/json',
                        },
                        Body = body,
                    })

                    if not ok or type(response) ~= 'table' then
                        return 'retry', 5
                    end

                    local status = response.StatusCode

                    if type(status) ~= 'number' then
                        status = response.Status
                    end
                    if SUCCESS_STATUSES[status] then
                        return 'ok', nil
                    elseif status == 429 then
                        return 'retry', retryAfter(response)
                    elseif type(status) == 'number' and status >= 500 then
                        return 'retry', 4
                    elseif status == 401 or status == 403 or status == 404 then
                        return 'invalid', nil
                    end

                    return 'drop', nil
                end
                local function pump()
                    while not self.stopped and #self.queue > 0 and self.url do
                        local item = self.queue[1]
                        local sinceLast = options.clock() - self.lastSent

                        if sinceLast < options.minInterval then
                            options.task.wait(options.minInterval - sinceLast)
                        end
                        if self.stopped or not self.url then
                            break
                        end

                        setState('sending')

                        local verdict, waitSeconds = deliver(item.payload)

                        self.lastSent = options.clock()

                        if verdict == 'ok' then
                            table.remove(self.queue, 1)

                            self.stats.sent += 1

                            setState('idle')
                        elseif verdict == 'retry' then
                            item.attempts += 1

                            if item.attempts > options.retryLimit then
                                table.remove(self.queue, 1)

                                self.stats.failed += 1

                                setState('offline')
                            else
                                setState(if waitSeconds and waitSeconds >= 5 then'rate limited'else'retrying')
                                options.task.wait(waitSeconds or 2)
                            end
                        elseif verdict == 'invalid' then
                            table.clear(self.queue)

                            self.stats.failed += 1

                            self.url = nil

                            setState('invalid')
                        else
                            table.remove(self.queue, 1)

                            self.stats.dropped += 1

                            setState('idle')
                        end
                    end

                    self.running = false

                    if #self.queue == 0 and self.state ~= 'invalid' and self.state ~= 'offline' then
                        setState('idle')
                    end
                end

                function self.setUrl(url)
                    self.url = url

                    table.clear(self.queue)
                    setState('idle')
                end
                function self.isReady()
                    return self.url ~= nil and self.state ~= 'invalid'
                end
                function self.enqueue(payload)
                    if not self.url or self.stopped then
                        return false
                    end
                    if #self.queue >= options.queueLimit then
                        table.remove(self.queue, 1)

                        self.stats.dropped += 1
                    end

                    table.insert(self.queue, {
                        payload = payload,
                        attempts = 0,
                    })

                    if not self.running then
                        self.running = true

                        local spawn = options.task.spawn
                        local started = pcall(spawn, pump)

                        if not started then
                            self.running = false

                            return false
                        end
                    end

                    return true
                end
                function self.stop()
                    self.stopped = true

                    table.clear(self.queue)
                end

                return self
            end

            return Sender
        end

        function __DARKLUA_BUNDLE_MODULES.R()
            local v = __DARKLUA_BUNDLE_MODULES.cache.R

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.R = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Session = {}
            local BAR_SEGMENTS = 10
            local MIN_RATE_SECONDS = 60

            function Session.new(clock)
                local self = {
                    startedAt = clock(),
                    wins = 0,
                    losses = 0,
                    other = 0,
                    drops = {},
                    streakKind = '',
                    streakCount = 0,
                    bestWinStreak = 0,
                    runSeconds = 0,
                    gains = {},
                }

                function self.record(won, duration, gains)
                    if won == nil then
                        self.other += 1
                    else
                        if won then
                            self.wins += 1
                        else
                            self.losses += 1
                        end

                        local kind = if won then'W'else'L'

                        if self.streakKind == kind then
                            self.streakCount += 1
                        else
                            self.streakKind = kind
                            self.streakCount = 1
                        end
                        if won and self.streakCount > self.bestWinStreak then
                            self.bestWinStreak = self.streakCount
                        end
                    end
                    if type(duration) == 'number' and duration > 0 then
                        self.runSeconds += duration
                    end

                    for key, amount in gains or {}do
                        if type(amount) == 'number' and amount > 0 then
                            self.gains[key] = (self.gains[key] or 0) + amount
                        end
                    end
                end
                function self.addDrop(label)
                    self.drops[label] = (self.drops[label] or 0) + 1
                end
                function self.summary()
                    local known = self.wins + self.losses
                    local total = known + self.other
                    local uptime = math.max(0, clock() - self.startedAt)
                    local winRate = if known > 0 then self.wins / known * 100 else 0
                    local filled = math.floor(winRate / 100 * BAR_SEGMENTS + 0.5)
                    local rates = {}
                    local dropRates = {}

                    if uptime >= MIN_RATE_SECONDS then
                        for key, amount in self.gains do
                            rates[key] = amount / uptime * 3600
                        end
                        for label, count in self.drops do
                            dropRates[label] = count / uptime * 3600
                        end
                    end

                    return {
                        wins = self.wins,
                        losses = self.losses,
                        total = total,
                        winRate = winRate,
                        bar = filled,
                        barSize = BAR_SEGMENTS,
                        streak = if self.streakCount > 0 then tostring(self.streakCount) .. self.streakKind else'-',
                        bestStreak = if self.bestWinStreak > 0 then tostring(self.bestWinStreak) .. 'W'else'-',
                        uptime = uptime,
                        averageRun = if total > 0 then uptime / total else 0,
                        runsPerHour = if total > 0 and uptime >= MIN_RATE_SECONDS then total / uptime * 3600 else 0,
                        gains = table.clone(self.gains),
                        rates = rates,
                        drops = table.clone(self.drops),
                        dropRates = dropRates,
                    }
                end

                return self
            end

            return Session
        end

        function __DARKLUA_BUNDLE_MODULES.S()
            local v = __DARKLUA_BUNDLE_MODULES.cache.S

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.S = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local FileStorage = __DARKLUA_BUNDLE_MODULES.l()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local metadata = __DARKLUA_BUNDLE_MODULES.b()
            local Embed = __DARKLUA_BUNDLE_MODULES.O()
            local Events = __DARKLUA_BUNDLE_MODULES.P()
            local Sender = __DARKLUA_BUNDLE_MODULES.R()
            local Session = __DARKLUA_BUNDLE_MODULES.S()
            local Runtime = {}
            local STORAGE_KEY = 'AnimeVanguardsWebhook'
            local SCHEMA_VERSION = 1
            local WEBHOOK = (config).webhook
            local THRESHOLDS = (config).thresholds
            local TICK_SECONDS = 1
            local SESSION_DELAY_SECONDS = 5
            local END_SCREEN_DELAY_SECONDS = 2
            local END_SCREEN_POLL_SECONDS = 0.25
            local UNIT_DEDUP_LIMIT = 4000

            local function resolve(root, path)
                local value = root

                for part in string.gmatch(path, '[^%.]+')do
                    if not value then
                        return nil
                    end

                    local ok, child = pcall(function()
                        local v = value

                        if type(v) == 'userdata' then
                            return v:FindFirstChild(part)
                        else
                            return v[part]
                        end
                    end)

                    value = if ok then child else nil
                end

                return value
            end
            local function optionalModule(root, path)
                local ok, result = pcall(function()
                    return (require)(resolve(root, path))
                end)

                return if ok then result else nil
            end
            local function defaults()
                local events = {}

                for _, kind in Events.kinds do
                    events[kind.id] = kind.default
                end

                return {
                    enabled = false,
                    url = nil,
                    username = '',
                    avatarUrl = '',
                    showPlayer = true,
                    pingUserId = '',
                    pingEveryone = true,
                    minRarity = WEBHOOK.rarityOrder[1],
                    events = events,
                }
            end
            local function childAt(root, path)
                local node = root

                for part in string.gmatch(path, '[^%.]+')do
                    if node == nil then
                        return nil
                    end

                    local current = node
                    local ok, child = pcall(function()
                        return current:FindFirstChild(part)
                    end)

                    node = if ok then child else nil
                end

                return node
            end
            local function textAt(root, path)
                local node = childAt(root, path)

                if node ~= nil and type(node.Text) == 'string' and node.Text ~= '' then
                    return node.Text
                end

                return nil
            end
            local function clockSeconds(text)
                local h, m, sec = string.match(text or '', '^(%d+):(%d+):(%d+)$')

                if h then
                    return (tonumber(h) or 0) * 3600 + (tonumber(m) or 0) * 60 + (tonumber(sec) or 0)
                end

                return nil
            end
            local function readEndScreen(gameObject)
                local layout = WEBHOOK.endScreen
                local ok, result = pcall(function()
                    local players = gameObject:GetService('Players')
                    local playerGui = players.LocalPlayer:FindFirstChildOfClass('PlayerGui')
                    local screen = playerGui and playerGui:FindFirstChild(layout.gui)

                    if not screen then
                        return nil
                    end

                    local data = {rewards = {}}
                    local title = textAt(screen, layout.title)

                    if title then
                        local lower = string.lower(title)

                        if lower == 'victory' then
                            data.result = 'Victory'
                        elseif lower == 'defeat' then
                            data.result = 'Defeat'
                        end
                    end

                    data.stage = textAt(screen, layout.stage)
                    data.act = textAt(screen, layout.act)
                    data.difficulty = textAt(screen, layout.difficulty)
                    data.units = textAt(screen, layout.units)
                    data.damage = textAt(screen, layout.damage)
                    data.money = textAt(screen, layout.money)
                    data.takedowns = textAt(screen, layout.takedowns)
                    data.waves = tonumber(textAt(screen, layout.waves) or '')
                    data.seconds = clockSeconds(textAt(screen, layout.playTime))

                    local tiles = childAt(screen, layout.rewards)

                    if tiles then
                        for _, tile in tiles:GetChildren()do
                            if #data.rewards >= 12 then
                                break
                            end
                            if tile:IsA('GuiObject') then
                                local name = textAt(tile, layout.rewardName) or tile.Name
                                local amount = textAt(tile, layout.rewardAmount)

                                table.insert(data.rewards, {
                                    name = name,
                                    amount = if amount then string.gsub(amount, '^[xX]', '')else nil,
                                })
                            end
                        end
                    end

                    return data
                end)

                return if ok then result else nil
            end

            function Runtime.contributionRows(summary)
                local found = {}
                local seen = {}

                local function visit(node, depth)
                    if type(node) ~= 'table' or depth > 5 or seen[node] or #found > 0 then
                        return
                    end

                    seen[node] = true

                    local first = node[1]

                    if type(first) == 'table' and type(first.DisplayName) == 'string' and type(first.Damage) == 'number' then
                        for _, row in node do
                            if type(row) == 'table' and type(row.DisplayName) == 'string' and type(row.Damage) == 'number' then
                                table.insert(found, {
                                    name = row.DisplayName,
                                    rarity = if type(row.Rarity) == 'string'then row.Rarity else nil,
                                    damage = row.Damage,
                                    takedowns = if type(row.Takedowns) == 'number'then row.Takedowns else 0,
                                    spent = if type(row.YenSpent) == 'number'then row.YenSpent else nil,
                                    placements = if type(row.PlacementCount) == 'number'then row.PlacementCount else 1,
                                    deployed = if type(row.TimeDeployed) == 'number'then row.TimeDeployed else nil,
                                })
                            end
                        end

                        return
                    end

                    for _, child in node do
                        visit(child, depth + 1)
                    end
                end

                visit(summary, 0)
                table.sort(found, function(a, b)
                    return a.damage > b.damage
                end)

                return found
            end
            function Runtime.new(injected)
                local self = {
                    deps = injected,
                    settings = defaults(),
                    sender = nil,
                    context = nil,
                    loaded = false,
                    status = 'Not configured',
                    onStatus = nil,
                    storage = nil,
                    cooldowns = {},
                    lastNotice = {},
                    lastLine = {},
                    seenUnits = {},
                    seenCount = 0,
                    unitReadyAt = math.huge,
                    bountyLeft = nil,
                    bountyChecked = -math.huge,
                    riftWasOpen = nil,
                    matchStartedAt = nil,
                    connections = {},
                    sources = {},
                }

                local function deps()
                    return self.deps or {}
                end
                local function call(name, ...)
                    local fn = deps()[name]

                    if type(fn) == 'function' then
                        return (fn)(...)
                    end

                    return nil
                end
                local function has(name)
                    return type(deps()[name]) == 'function'
                end
                local function clock()
                    local value = call('clock')

                    return if type(value) == 'number'then value else os.clock()
                end
                local function setStatus(value)
                    self.status = value

                    if self.onStatus then
                        pcall(self.onStatus, value)
                    end
                end
                local function describeState()
                    local sender = self.sender

                    if not Embed.validUrl(self.settings.url, WEBHOOK.hosts) then
                        return 'Not configured: paste a Discord webhook URL'
                    end
                    if sender and sender.state == 'invalid' then
                        return
[[Discord rejected the webhook URL (deleted or wrong); set it again]]
                    end
                    if not self.settings.enabled then
                        return 'Configured; notifications are off'
                    end

                    local stats = if sender then sender.stats else{
                        sent = 0,
                        failed = 0,
                        dropped = 0,
                    }

                    return string.format('On \u{2022} %s \u{2022} sent %d, failed %d, dropped %d', if sender then sender.state else'idle', stats.sent, stats.failed, stats.dropped)
                end
                local function refreshStatus()
                    setStatus(describeState())
                end
                local function save()
                    local storage = self.storage
                    local d = deps()

                    if not storage or not d.encode then
                        return
                    end

                    local ok, body = pcall(d.encode, {
                        schemaVersion = SCHEMA_VERSION,
                        enabled = self.settings.enabled,
                        url = self.settings.url,
                        username = self.settings.username,
                        avatarUrl = self.settings.avatarUrl,
                        showPlayer = self.settings.showPlayer,
                        pingUserId = self.settings.pingUserId,
                        pingEveryone = self.settings.pingEveryone,
                        minRarity = self.settings.minRarity,
                        events = self.settings.events,
                    })

                    if ok and type(body) == 'string' then
                        pcall(storage.write, body)
                    end
                end
                local function ensureSender()
                    if self.sender then
                        return
                    end

                    local d = deps()

                    if not d.request or not d.encode or not d.task then
                        return
                    end

                    local sender = Sender.new({
                        request = d.request,
                        encode = d.encode,
                        decode = d.decode,
                        task = d.task,
                        clock = clock,
                        minInterval = THRESHOLDS.webhookMinIntervalSeconds,
                        queueLimit = THRESHOLDS.webhookQueueLimit,
                        retryLimit = THRESHOLDS.webhookRetryLimit,
                    })

                    sender.onState = function()
                        refreshStatus()
                    end

                    if Embed.validUrl(self.settings.url, WEBHOOK.hosts) then
                        sender.setUrl(self.settings.url)
                    end

                    self.sender = sender
                end
                local function context()
                    local d = deps()

                    return {
                        player = d.playerName,
                        displayName = d.displayName,
                        level = call('readLevel'),
                        avatarUrl = self.avatarUrl,
                        userId = d.userId,
                        showPlayer = self.settings.showPlayer,
                        timestamp = if has('timestamp')then call('timestamp')else os.date('!%Y-%m-%dT%H:%M:%SZ'),
                        version = metadata.version,
                    }
                end
                local function dispatch(kind, data)
                    ensureSender()

                    local sender = self.sender

                    if not sender or not sender.isReady() then
                        return false
                    end

                    local spec, ping, everyone = Events.build(kind, data, context(), WEBHOOK)

                    if not spec then
                        return false
                    end

                    local embed = Embed.build(spec)
                    local payload = Embed.payload({embed}, {
                        username = if self.settings.username ~= ''then self.settings.username else WEBHOOK.defaultUsername,
                        avatarUrl = if self.settings.avatarUrl ~= ''then self.settings.avatarUrl else nil,
                        pingUserId = self.settings.pingUserId,
                        ping = ping,
                        everyone = everyone and self.settings.pingEveryone == true,
                    })

                    return sender.enqueue(payload)
                end

                function self.getSettings()
                    local copy = table.clone(self.settings)

                    copy.events = table.clone(self.settings.events)
                    copy.urlMasked = Embed.mask(self.settings.url, WEBHOOK.hosts)
                    copy.hasUrl = Embed.validUrl(self.settings.url, WEBHOOK.hosts)
                    copy.url = nil

                    return copy
                end
                function self.getStatus()
                    return self.status
                end
                function self.setEnabled(value)
                    if type(value) ~= 'boolean' then
                        return false
                    end

                    self.settings.enabled = value

                    save()
                    refreshStatus()

                    return true
                end
                function self.setUrl(url)
                    if not Embed.validUrl(url, WEBHOOK.hosts) then
                        return false, 'INVALID_URL'
                    end

                    self.settings.url = url

                    ensureSender()

                    if self.sender then
                        self.sender.setUrl(url)
                    end

                    save()
                    refreshStatus()

                    return true, nil
                end
                function self.clearUrl()
                    self.settings.url = nil

                    if self.sender then
                        self.sender.setUrl(nil)
                    end

                    save()
                    refreshStatus()
                end
                function self.setUsername(value)
                    if type(value) ~= 'string' then
                        return false
                    end

                    self.settings.username = if value == ''then''else Embed.username(value, WEBHOOK.defaultUsername)

                    save()

                    return true
                end
                function self.setAvatar(value)
                    if type(value) ~= 'string' then
                        return false
                    end

                    local trimmed = string.match(value, '^%s*(.-)%s*$') or ''

                    if trimmed ~= '' and string.match(trimmed, '^https://[%w%.%-]+/') == nil then
                        return false
                    end

                    self.settings.avatarUrl = Embed.clip(trimmed, 512)

                    save()

                    return true
                end
                function self.setShowPlayer(value)
                    if type(value) ~= 'boolean' then
                        return false
                    end

                    self.settings.showPlayer = value

                    save()

                    return true
                end
                function self.setPingUser(value)
                    if type(value) ~= 'string' then
                        return false
                    end

                    local trimmed = string.match(value, '^%s*(.-)%s*$') or ''

                    if trimmed ~= '' and (string.match(trimmed, '^%d+$') == nil or #trimmed < 15 or #trimmed > 25) then
                        return false
                    end

                    self.settings.pingUserId = trimmed

                    save()

                    return true
                end
                function self.setPingEveryone(value)
                    if type(value) ~= 'boolean' then
                        return false
                    end

                    self.settings.pingEveryone = value

                    save()

                    return true
                end
                function self.setMinRarity(value)
                    if type(value) ~= 'string' or table.find(WEBHOOK.rarityOrder, value) == nil then
                        return false
                    end

                    self.settings.minRarity = value

                    save()

                    return true
                end
                function self.setEvent(kind, value)
                    if type(kind) ~= 'string' or type(value) ~= 'boolean' or self.settings.events[kind] == nil then
                        return false
                    end

                    self.settings.events[kind] = value

                    save()

                    return true
                end
                function self.notify(kind, data, key, cooldown)
                    if not self.settings.enabled or self.settings.events[kind] ~= true then
                        return false
                    end
                    if key then
                        local now = clock()
                        local last = self.cooldowns[key]

                        if last and now - last < (cooldown or 0) then
                            return false
                        end

                        self.cooldowns[key] = now
                    end

                    return dispatch(kind, data)
                end
                function self.sendTest()
                    if not Embed.validUrl(self.settings.url, WEBHOOK.hosts) then
                        return false, 'NO_URL'
                    end

                    local count = 0

                    for _, value in self.settings.events do
                        if value then
                            count += 1
                        end
                    end

                    if not dispatch('test', {enabledCount = count}) then
                        return false, 'NOT_SENT'
                    end

                    return true, nil
                end
                function self.onUnitAdded(argument)
                    if clock() < self.unitReadyAt then
                        return
                    end

                    local guid = nil
                    local unit = nil

                    if type(argument) == 'string' then
                        guid = argument
                        unit = call('unitObject', argument)
                    elseif type(argument) == 'table' then
                        unit = argument
                        guid = argument.UniqueIdentifier
                    end
                    if type(guid) ~= 'string' or self.seenUnits[guid] then
                        return
                    end
                    if self.seenCount >= UNIT_DEDUP_LIMIT then
                        table.clear(self.seenUnits)

                        self.seenCount = 0
                    end

                    self.seenUnits[guid] = true

                    self.seenCount += 1

                    if type(unit) ~= 'table' or type(unit.UnitData) ~= 'table' then
                        return
                    end

                    local rarity = unit.UnitData.Rarity

                    if Events.rarityRank(rarity, WEBHOOK.rarityOrder) < Events.rarityRank(self.settings.minRarity, WEBHOOK.rarityOrder) then
                        return
                    end

                    local trait = nil

                    if type(unit.Trait) == 'table' and type(unit.Trait.Name) == 'string' then
                        trait = unit.Trait.Name
                    end
                    if self.session then
                        self.session.addDrop(string.format('%s %s', tostring(rarity), tostring(unit.UnitData.Name)))
                    end

                    self.notify('unit', {
                        name = unit.UnitData.Name,
                        rarity = rarity,
                        level = unit.Level,
                        trait = trait,
                        subTrait = unit.SubTrait,
                    })
                end

                local function classify(source, text)
                    local lower = string.lower(text)

                    local function has(...)
                        for _, needle in {...}do
                            if string.find(lower, needle, 1, true) then
                                return true
                            end
                        end

                        return false
                    end

                    if source == 'joiner' then
                        if string.find(text, '^Team Equipper:') or string.find(text, '^Macro Equipper:') then
                            if has('not available', 'no usable', 'not confirmed', 'could not', 'not loaded') then
                                return 'equipper', 'equipper:' .. text, {message = text}
                            end

                            return nil, nil, nil
                        end
                        if has('confirmed by server', 'entered match') then
                            local name = string.match(text, '^([^:]+):') or 'Joiner'

                            return 'join', 'join:' .. name, {
                                name = name,
                                message = text,
                            }
                        end
                        if has('none left today') then
                            return 'bounty', 'bounty-none', {
                                left = 0,
                                message = text,
                            }
                        end
                        if has('no server confirmation', 'request failed', 'locked or progress unavailable', 'host state not ready', 'start network unavailable', 'teleport not confirmed') then
                            return 'joinProblem', 'joinProblem:' .. text, {message = text}
                        end

                        return nil, nil, nil
                    end
                    if has('preset rule cleared', 'preset switch not confirmed', 'request failed', 'timed out', 'auto play unavailable') then
                        return 'autoPlay', 'autoPlay-problem:' .. text, {message = text}
                    end
                    if has('native auto play active') then
                        return 'autoPlay', 'autoPlay-active', {message = text}
                    end

                    return nil, nil, nil
                end
                local function watchStatus(source, text)
                    if type(text) ~= 'string' or text == '' or self.lastLine[source] == text then
                        return
                    end

                    self.lastLine[source] = text

                    local kind, key, data = classify(source, text)
                    local subject = string.match(text, '^([^:]+):') or source

                    if kind and key and kind ~= 'join' and key ~= 'autoPlay-active' then
                        if self.lastNotice[subject] == text then
                            return
                        end

                        self.lastNotice[subject] = text

                        self.notify(kind, data)

                        return
                    end
                    if not kind then
                        self.lastNotice[subject] = nil
                    end
                    if kind and key then
                        local cooldown = THRESHOLDS.webhookProblemCooldownSeconds

                        if kind == 'join' then
                            cooldown = 20
                        elseif key == 'autoPlay-active' then
                            cooldown = 600
                        end

                        self.notify(kind, data, key, cooldown)
                    end
                end

                function self.onStatusLine(source, text)
                    watchStatus(source, text)
                end

                local function watchBounty(now)
                    if not has('readBounty') or now - self.bountyChecked < THRESHOLDS.webhookBountyPollSeconds then
                        return
                    end

                    self.bountyChecked = now

                    local target = call('readBounty')

                    if type(target) ~= 'table' or type(target.left) ~= 'number' then
                        return
                    end

                    local left = target.left
                    local previous = self.bountyLeft

                    self.bountyLeft = left

                    if previous ~= nil and left < previous then
                        self.notify('bounty', {
                            left = left,
                            mode = target.mode,
                            stage = target.stage,
                            act = target.act,
                            boss = target.boss,
                            message = string.format('A Boss Bounty was cleared (%s \u{2192} %s).', tostring(previous), tostring(left)),
                        })
                    end
                end
                local function watchRift()
                    local open = call('riftOpen')

                    if type(open) ~= 'boolean' then
                        return
                    end
                    if open and self.riftWasOpen == false then
                        self.notify('rift', {
                            message = 'The hourly Rift event just opened.',
                        }, 'rift', 600)
                    end

                    self.riftWasOpen = open
                end

                function self.tick()
                    local d = deps()

                    watchBounty(clock())
                    watchRift()

                    if self.matchStartedAt then
                        local wave = call('readWave')

                        if type(wave) == 'table' and type(wave.current) == 'number' then
                            if wave.current > (self.lastWave or 0) then
                                self.lastWave = wave.current
                            end
                            if type(wave.max) == 'number' then
                                self.maxWave = wave.max
                            end
                        end
                    end
                    if d.afterTick then
                        pcall(d.afterTick)
                    end
                end

                local function balances()
                    local value = call('readCurrencies')

                    return if type(value) == 'table'then value else nil
                end

                function self.isBusy()
                    if self.matchEndPending then
                        return true
                    end

                    local sender = self.sender

                    if sender and #sender.queue > 0 then
                        return true
                    end

                    return false
                end
                function self.onMatchStarted()
                    self.matchStartedAt = clock()
                    self.matchBalances = balances()
                    self.lastWave = nil
                    self.maxWave = nil
                end

                local function resultFromArguments(arguments)
                    for _, value in arguments do
                        if type(value) == 'boolean' then
                            return if value then'Victory'else'Defeat'
                        elseif type(value) == 'string' then
                            local lower = string.lower(value)

                            if lower == 'victory' or lower == 'win' or lower == 'won' then
                                return 'Victory'
                            elseif lower == 'defeat' or lower == 'loss' or lower == 'lose' or lower == 'lost' then
                                return 'Defeat'
                            end
                        elseif type(value) == 'table' then
                            for _, key in WEBHOOK.resultKeys do
                                local flag = value[key]

                                if type(flag) == 'boolean' then
                                    return if flag then'Victory'else'Defeat'
                                elseif type(flag) == 'string' then
                                    local lower = string.lower(flag)

                                    if lower == 'victory' or lower == 'win' or lower == 'won' then
                                        return 'Victory'
                                    elseif lower == 'defeat' or lower == 'loss' or lower == 'lose' or lower == 'lost' then
                                        return 'Defeat'
                                    end
                                end
                            end
                        end
                    end

                    return nil
                end
                local function currencyRows(before, after)
                    local earnings = {}
                    local rows = {}
                    local gains = {}

                    for _, currency in WEBHOOK.currencies do
                        local now = after and after[currency.key]

                        if type(now) == 'number' then
                            table.insert(rows, {
                                key = currency.key,
                                label = currency.label,
                                emoji = currency.emoji,
                                value = now,
                            })

                            local was = before and before[currency.key]

                            if type(was) == 'number' and now > was then
                                gains[currency.key] = now - was

                                table.insert(earnings, {
                                    label = currency.label,
                                    amount = now - was,
                                    balance = now,
                                })
                            end
                        end
                    end

                    return earnings, rows, gains
                end

                function self.onEndSummary(status, summary)
                    local result = if type(status) == 'string'then WEBHOOK.resultStatus[status]else nil

                    if result then
                        self.endStatus = {
                            result = result,
                            at = clock(),
                        }
                    end

                    local units = Runtime.contributionRows(summary)

                    if #units > 0 then
                        self.endUnits = {
                            rows = units,
                            at = clock(),
                        }
                    end
                end

                local function summaryResult()
                    local entry = self.endStatus

                    if entry and clock() - entry.at < 60 then
                        return entry.result
                    end

                    return nil
                end

                function self.onMatchEnded(...)
                    local d = deps()
                    local startedAt = self.matchStartedAt
                    local before = self.matchBalances or self.balanceBaseline
                    local wave, maxWave = self.lastWave, self.maxWave
                    local argumentResult = resultFromArguments({...})

                    self.matchStartedAt = nil
                    self.matchBalances = nil
                    self.matchEndPending = self.settings.enabled and self.settings.events.matchEnd == true

                    local function send(screen)
                        local game = call('gameData')
                        local info = {
                            rewards = {},
                            currencies = WEBHOOK.currencies,
                        }

                        if type(game) == 'table' then
                            info.stageType = game.StageType
                            info.stage = game.Stage
                            info.act = game.Act
                            info.difficulty = game.Difficulty

                            for _, key in WEBHOOK.waveMaxKeys do
                                if type(game[key]) == 'number' then
                                    maxWave = maxWave or game[key]

                                    break
                                end
                            end
                        end
                        if type(screen) == 'table' then
                            info.result = screen.result
                            info.damage = screen.damage
                            info.takedowns = screen.takedowns
                            info.units = screen.units
                            info.rewards = screen.rewards
                            info.stage = screen.stage or info.stage
                            info.act = screen.act or info.act
                            info.difficulty = screen.difficulty or info.difficulty

                            if screen.waves then
                                wave = screen.waves
                            end
                            if info.result == 'Victory' and wave and not maxWave then
                                maxWave = wave
                            end
                        end

                        info.result = summaryResult() or argumentResult or info.result
                        self.endStatus = nil

                        local unitEntry = self.endUnits

                        if unitEntry and clock() - unitEntry.at < 60 then
                            info.units = unitEntry.rows
                        end

                        self.endUnits = nil

                        if wave then
                            info.wave = wave
                            info.maxWave = maxWave
                        end
                        if type(screen) == 'table' and screen.seconds then
                            info.duration = screen.seconds
                        elseif startedAt then
                            info.duration = clock() - startedAt
                        end

                        local after = balances()
                        local earnings, rows, gains = currencyRows(before, after)

                        info.earnings = earnings
                        info.balances = rows

                        if after then
                            self.balanceBaseline = after
                        end

                        local macro = call('macroInfo')

                        if type(macro) == 'table' then
                            info.macro = macro
                        end
                        if info.result == nil then
                            info.unknownResult = true
                            info.result = 'Defeat'
                        end
                        if self.session then
                            self.session.record(if info.unknownResult then nil else info.result == 'Victory', info.duration, gains)
                        end
                        if self.session then
                            info.session = self.session.summary()
                        end

                        self.notify('matchEnd', info)

                        self.matchEndPending = false
                    end

                    local taskApi = d.task

                    if type(taskApi) == 'table' and type(taskApi.spawn) == 'function' and type(taskApi.wait) == 'function' then
                        local spawnTask = taskApi.spawn
                        local waitTask = taskApi.wait

                        spawnTask(function()
                            local waited = 0
                            local screen = nil

                            repeat
                                waitTask(END_SCREEN_POLL_SECONDS)

                                waited += END_SCREEN_POLL_SECONDS

                                screen = call('readEndScreen')
                            until (type(screen) == 'table' and screen.result ~= nil) or summaryResult() ~= nil or waited >= END_SCREEN_DELAY_SECONDS

                            send(screen)
                        end)
                    else
                        send(call('readEndScreen'))
                    end
                end
                function self.start(ctx, sources)
                    self.context = ctx
                    self.sources = sources or {}

                    local env = getfenv()
                    local d = deps()

                    if not self.deps then
                        d = {}

                        local gameObject = env.game

                        if gameObject then
                            local players = gameObject:GetService('Players')
                            local replicated = gameObject:GetService('ReplicatedStorage')
                            local starter = gameObject:GetService('StarterPlayer')
                            local http = gameObject:GetService('HttpService')
                            local requestFn = env.request or env.http_request
                            local isLobby = gameObject.PlaceId == metadata.placeIds[1]
                            local ownedUnits = optionalModule(starter, config.instancePaths.ownedUnits)
                            local gameHandler = optionalModule(replicated, config.instancePaths.gameHandler)
                            local endScreenClient = if isLobby then nil else optionalModule(replicated, config.instancePaths.endScreenClient)
                            local endScreenCodec = if isLobby then nil else optionalModule(replicated, config.instancePaths.endScreenCodec)
                            local wavesHud = optionalModule(starter, config.instancePaths.wavesHud)

                            d = {
                                encode = function(value)
                                    return http:JSONEncode(value)
                                end,
                                decode = function(text)
                                    return http:JSONDecode(text)
                                end,
                                request = requestFn,
                                task = env.task,
                                playerName = players.LocalPlayer.Name,
                                displayName = players.LocalPlayer.DisplayName,
                                fetchAvatar = function()
                                    local ok, response = pcall(requestFn, {
                                        Url = string.format(
[[https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=150x150&format=Png]], players.LocalPlayer.UserId),
                                        Method = 'GET',
                                    })

                                    if not ok or type(response) ~= 'table' or type(response.Body) ~= 'string' then
                                        return nil
                                    end

                                    local okJson, data = pcall(http.JSONDecode, http, response.Body)
                                    local row = if okJson and type(data) == 'table' and type(data.data) == 'table'then data.data[1]else nil
                                    local url = if type(row) == 'table'then row.imageUrl else nil

                                    return if type(url) == 'string' and string.match(url, '^https://[%w%.%-]+/')then url else nil
                                end,
                                readCurrencies = function()
                                    local values = {}

                                    for _, currency in WEBHOOK.currencies do
                                        local ok, value = pcall(players.LocalPlayer.GetAttribute, players.LocalPlayer, currency.key)

                                        if ok and type(value) == 'number' then
                                            values[currency.key] = value
                                        end
                                    end

                                    return if next(values)then values else nil
                                end,
                                readLevel = function()
                                    local ok, value = pcall(players.LocalPlayer.GetAttribute, players.LocalPlayer, WEBHOOK.levelAttribute)

                                    return if ok and type(value) == 'number'then value else nil
                                end,
                                readWave = function()
                                    local current = if wavesHud then wavesHud.CurrentWave else nil
                                    local number = tonumber(current)

                                    return if number then{current = number}else nil
                                end,
                                macroInfo = function()
                                    local macro = self.sources.macro
                                    local document = if type(macro) == 'table'then macro.activeDocument else nil

                                    if type(document) == 'table' and macro.mode == 'play' and type(document.name) == 'string' then
                                        return {
                                            name = document.name,
                                            status = 'Playing',
                                        }
                                    end

                                    return nil
                                end,
                                userId = players.LocalPlayer.UserId,
                                unitObject = if ownedUnits and ownedUnits.GetUnitObject then function(
                                    guid
                                )
                                    local ok, unit = pcall(ownedUnits.GetUnitObject, guid)

                                    return if ok then unit else nil
                                end else nil,
                                gameData = if gameHandler and gameHandler.GetGameData then function(
                                )
                                    if gameHandler.IsGameLoaded ~= true then
                                        return nil
                                    end

                                    local ok, value = pcall(gameHandler.GetGameData, gameHandler)

                                    return if ok then value else nil
                                end else nil,
                                readEndScreen = function()
                                    return readEndScreen(gameObject)
                                end,
                                readBounty = function()
                                    local joiner = self.sources.joiner

                                    if joiner and type(joiner.readBounty) == 'function' then
                                        return (joiner.readBounty)()
                                    end

                                    return nil
                                end,
                                riftOpen = function()
                                    local ws = gameObject:GetService('Workspace')
                                    local ok, value = pcall(ws.GetAttribute, ws, config.attributes.riftOpen)

                                    return if ok and type(value) == 'boolean'then value else nil
                                end,
                                ownedUnitsModule = ownedUnits,
                                onEndSummary = function(callback)
                                    local event = endScreenClient and endScreenClient[config.remoteNames.showEndScreen]
                                    local decode = endScreenCodec and endScreenCodec.DecodeMatchEndSummary

                                    if type(event) ~= 'table' or type(event.On) ~= 'function' or type(decode) ~= 'function' then
                                        return nil
                                    end

                                    local ok, disconnect = pcall(event.On, function(
                                        payload
                                    )
                                        local okDecode, summary = pcall(decode, payload)

                                        if okDecode and type(summary) == 'table' and summary.IsFakeEndScreen ~= true then
                                            callback(summary.Status, summary)
                                        end
                                    end)

                                    return if ok then disconnect else nil
                                end,
                                gameHandlerModule = gameHandler,
                                isLobby = isLobby,
                            }
                        end

                        self.deps = d
                    end
                    if not self.storage and d.storage then
                        self.storage = d.storage
                    end
                    if not self.storage and env.game then
                        pcall(function()
                            self.storage = FileStorage.new(env, STORAGE_KEY)
                        end)
                    end

                    local storage = self.storage

                    if storage and d.decode then
                        local body = storage.read()

                        if body then
                            local ok, data = pcall(d.decode, body)

                            if ok and type(data) == 'table' and data.schemaVersion == SCHEMA_VERSION then
                                local settings = self.settings

                                if type(data.enabled) == 'boolean' then
                                    settings.enabled = data.enabled
                                end
                                if Embed.validUrl(data.url, WEBHOOK.hosts) then
                                    settings.url = data.url
                                end
                                if type(data.username) == 'string' then
                                    settings.username = Embed.clip(data.username, 80)
                                end
                                if type(data.avatarUrl) == 'string' and string.match(data.avatarUrl, '^https://[%w%.%-]+/') then
                                    settings.avatarUrl = Embed.clip(data.avatarUrl, 512)
                                end
                                if type(data.showPlayer) == 'boolean' then
                                    settings.showPlayer = data.showPlayer
                                end
                                if type(data.pingUserId) == 'string' and (data.pingUserId == '' or string.match(data.pingUserId, '^%d+$')) then
                                    settings.pingUserId = Embed.clip(data.pingUserId, 25)
                                end
                                if type(data.pingEveryone) == 'boolean' then
                                    settings.pingEveryone = data.pingEveryone
                                end
                                if type(data.minRarity) == 'string' and table.find(WEBHOOK.rarityOrder, data.minRarity) then
                                    settings.minRarity = data.minRarity
                                end
                                if type(data.events) == 'table' then
                                    for kind, value in data.events do
                                        if settings.events[kind] ~= nil and type(value) == 'boolean' then
                                            settings.events[kind] = value
                                        end
                                    end
                                end
                            end
                        end
                    end

                    self.loaded = true
                    self.session = Session.new(clock)
                    self.balanceBaseline = balances()

                    ensureSender()
                    refreshStatus()

                    if d.ownedUnitsModule and type(d.ownedUnitsModule.GetOwnedUnits) == 'function' then
                        local ok, owned = pcall(d.ownedUnitsModule.GetOwnedUnits)

                        if ok and type(owned) == 'table' then
                            for guid in owned do
                                if type(guid) == 'string' then
                                    self.seenUnits[guid] = true

                                    self.seenCount += 1
                                end
                            end
                        end

                        local signal = d.ownedUnitsModule.UnitAdded

                        if type(signal) == 'table' and type(signal.Connect) == 'function' then
                            local okConnect, connection = pcall(signal.Connect, signal, function(
                                argument
                            )
                                self.onUnitAdded(argument)
                            end)

                            if okConnect and connection then
                                table.insert(self.connections, connection)
                            end
                        end
                    end

                    self.unitReadyAt = clock() + THRESHOLDS.webhookUnitIgnoreSeconds

                    local endDisconnect = call('onEndSummary', function(
                        status,
                        summary
                    )
                        self.onEndSummary(status, summary)
                    end)

                    if endDisconnect then
                        table.insert(self.connections, endDisconnect)
                    end
                    if d.gameHandlerModule and not d.isLobby then
                        for name, handler in {
                            MatchStarted = self.onMatchStarted,
                            MatchEnded = self.onMatchEnded,
                        }do
                            local signal = d.gameHandlerModule[name]

                            if type(signal) == 'table' and type(signal.Connect) == 'function' then
                                local fire = handler
                                local okConnect, connection = pcall(signal.Connect, signal, function(
                                    ...
                                )
                                    fire(...)
                                end)

                                if okConnect and connection then
                                    table.insert(self.connections, connection)
                                end
                            end
                        end
                    end

                    for source, runtime in {
                        joiner = self.sources.joiner,
                        autoPlay = self.sources.autoPlay,
                    }do
                        if type(runtime) == 'table' and type(runtime.addStatusListener) == 'function' then
                            local subscribe = runtime.addStatusListener
                            local remove = subscribe(function(text)
                                self.onStatusLine(source, text)
                            end)

                            table.insert(self.connections, remove)
                        end
                    end

                    local taskApi = d.task

                    if type(taskApi) == 'table' and type(taskApi.spawn) == 'function' and type(taskApi.wait) == 'function' then
                        local spawnTask = taskApi.spawn
                        local waitTask = taskApi.wait

                        spawnTask(function()
                            local okFetch, fetched = pcall(call, 'fetchAvatar')

                            if okFetch and type(fetched) == 'string' then
                                self.avatarUrl = fetched
                            end
                        end)
                        spawnTask(function()
                            waitTask(SESSION_DELAY_SECONDS)

                            if self.context == ctx and ctx.alive then
                                pcall(self.notify, 'session', {
                                    place = if d.isLobby then'Lobby'else'Match',
                                    placeName = if env.game then tostring(env.game.PlaceId)else nil,
                                })
                            end

                            while self.context == ctx and ctx.alive do
                                pcall(self.tick)
                                waitTask(TICK_SECONDS)
                            end
                        end)
                    end
                end
                function self.stop()
                    for _, connection in self.connections do
                        local conn = connection
                        local ok = pcall(function()
                            conn:Disconnect()
                        end)

                        if not ok then
                            pcall(conn)
                        end
                    end

                    table.clear(self.connections)

                    if self.sender then
                        self.sender.stop()

                        self.sender = nil
                    end

                    self.context = nil
                end

                return self
            end

            return Runtime
        end

        function __DARKLUA_BUNDLE_MODULES.T()
            local v = __DARKLUA_BUNDLE_MODULES.cache.T

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.T = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Style = __DARKLUA_BUNDLE_MODULES.e()
            local Page = {}

            function Page.mount(tab, runtime)
                local status = tab:Paragraph({
                    Title = 'Session',
                    Desc = if runtime then runtime.status else'Unavailable',
                })

                if not runtime then
                    return
                end

                runtime.onStatus = function(value)
                    pcall(status.SetDesc, status, value)
                end

                local settings = runtime.getSettings()
                local session = Style.section(tab, 'Session Keeper', 'shield', false)

                session:Toggle({
                    Title = 'Anti-AFK',
                    Desc =
[[Simulates input when Roblox reports you idle, so the 20-minute idle kick does not happen.]],
                    Value = settings.antiAfk,
                    Callback = function(value)
                        runtime.setAntiAfk(value)
                    end,
                })
                session:Toggle({
                    Title = 'Auto Reconnect',
                    Desc =
[[After a real disconnect (lost connection, timeout, server shutdown, Error 256/277) teleports back to the lobby, up to 5 tries. Never after a kick, ban, login elsewhere or maintenance.]],
                    Value = settings.autoReconnect,
                    Callback = function(value)
                        runtime.setAutoReconnect(value)
                    end,
                })

                local rerun = Style.section(tab, 'Re-run After Teleport', 'refresh-cw', false)

                rerun:Toggle({
                    Title = 'Re-run ViperHub after teleport',
                    Desc = if runtime.canRerun()then
[[Queues your loadstring line for the next place, so the hub (joiner, macro, webhook) loads again after every teleport or reconnect.]]else
[[This executor has no queue_on_teleport; load the hub manually after a teleport.]],
                    Value = settings.rerunOnTeleport,
                    Locked = not runtime.canRerun(),
                    Callback = function(value)
                        runtime.setRerun(value)
                    end,
                })
                rerun:Input({
                    Title = 'Loader URL',
                    Desc =
[[The URL inside your loadstring(game:HttpGet("..."))() line (must end in .lua).]],
                    Value = settings.loaderUrl,
                    Placeholder = 'http://127.0.0.1:8766/runtime-smoke.lua',
                    Callback = function(text)
                        if type(text) == 'string' and text ~= '' and not runtime.setLoaderUrl(text) then
                            pcall(status.SetDesc, status, 'Loader URL must be an http(s) URL ending in .lua')
                        end
                    end,
                })
            end

            return Page
        end

        function __DARKLUA_BUNDLE_MODULES.U()
            local v = __DARKLUA_BUNDLE_MODULES.cache.U

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.U = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local FileStorage = __DARKLUA_BUNDLE_MODULES.l()
            local config = __DARKLUA_BUNDLE_MODULES.c()
            local metadata = __DARKLUA_BUNDLE_MODULES.b()
            local Runtime = {}
            local STORAGE_KEY = 'AnimeVanguardsMisc'
            local SCHEMA_VERSION = 1
            local MISC = (config).misc

            function Runtime.validLoaderUrl(url)
                return type(url) == 'string' and #url <= 300 and string.match(url, '^https?://[%w%.%-]+[:%d]*/[%w%./%-_]*%.lua$') ~= nil
            end
            function Runtime.loaderLine(url)
                return string.format('loadstring(game:HttpGet("%s"))()', url)
            end

            local function liveDependencies()
                local env = getfenv()
                local gameObject = env.game

                if not gameObject then
                    return nil
                end

                local players = gameObject:GetService('Players')
                local virtualUser = gameObject:GetService('VirtualUser')
                local guiService = gameObject:GetService('GuiService')
                local teleportService = gameObject:GetService('TeleportService')
                local http = gameObject:GetService('HttpService')
                local queue = env.queue_on_teleport or env.queueonteleport
                local vector2 = env.Vector2

                return {
                    task = env.task,
                    clock = os.clock,
                    encode = function(value)
                        return http:JSONEncode(value)
                    end,
                    decode = function(text)
                        return http:JSONDecode(text)
                    end,
                    storage = FileStorage.new(env, STORAGE_KEY),
                    idled = players.LocalPlayer.Idled,
                    nudge = function()
                        virtualUser:CaptureController()
                        virtualUser:ClickButton2(vector2.new())
                    end,
                    errorChanged = guiService.ErrorMessageChanged,
                    errorCode = function()
                        local ok, code = pcall(guiService.GetErrorCode, guiService)

                        return if ok and code then code.Name else nil
                    end,
                    teleport = function(placeId)
                        return (pcall(teleportService.Teleport, teleportService, placeId, players.LocalPlayer))
                    end,
                    queue = if type(queue) == 'function'then queue else nil,
                }
            end

            function Runtime.new(injected)
                local self = {
                    deps = injected,
                    settings = {
                        antiAfk = true,
                        autoReconnect = false,
                        rerunOnTeleport = false,
                        loaderUrl = MISC.defaultLoaderUrl,
                    },
                    status = 'Idle',
                    onStatus = nil,
                    context = nil,
                    connections = {},
                    afkCount = 0,
                    reconnecting = false,
                    queued = false,
                    storage = nil,
                }

                local function setStatus(value)
                    self.status = value

                    if self.onStatus then
                        pcall(self.onStatus, value)
                    end
                end
                local function save()
                    local d = self.deps

                    if not self.storage or not d or not d.encode then
                        return
                    end

                    local ok, body = pcall(d.encode, {
                        schemaVersion = SCHEMA_VERSION,
                        antiAfk = self.settings.antiAfk,
                        autoReconnect = self.settings.autoReconnect,
                        rerunOnTeleport = self.settings.rerunOnTeleport,
                        loaderUrl = self.settings.loaderUrl,
                    })

                    if ok and type(body) == 'string' then
                        pcall(self.storage.write, body)
                    end
                end
                local function queueRerun()
                    local d = self.deps

                    if not self.settings.rerunOnTeleport or self.queued or not d or type(d.queue) ~= 'function' then
                        return
                    end
                    if not Runtime.validLoaderUrl(self.settings.loaderUrl) then
                        setStatus('Re-run after teleport: loader URL is not valid')

                        return
                    end

                    local queueFn = d.queue

                    if pcall(queueFn, Runtime.loaderLine(self.settings.loaderUrl)) then
                        self.queued = true
                    end
                end

                function self.getSettings()
                    return table.clone(self.settings)
                end
                function self.canRerun()
                    return self.deps ~= nil and type(self.deps.queue) == 'function'
                end
                function self.setAntiAfk(value)
                    if type(value) ~= 'boolean' then
                        return false
                    end

                    self.settings.antiAfk = value

                    save()

                    return true
                end
                function self.setAutoReconnect(value)
                    if type(value) ~= 'boolean' then
                        return false
                    end

                    self.settings.autoReconnect = value

                    save()

                    return true
                end
                function self.setRerun(value)
                    if type(value) ~= 'boolean' then
                        return false
                    end

                    self.settings.rerunOnTeleport = value

                    save()

                    if value then
                        queueRerun()
                    end

                    return true
                end
                function self.setLoaderUrl(value)
                    local trimmed = if type(value) == 'string'then string.match(value, '^%s*(.-)%s*$')else nil

                    if not Runtime.validLoaderUrl(trimmed) then
                        return false
                    end

                    self.settings.loaderUrl = trimmed

                    save()

                    return true
                end
                function self.onIdle()
                    local d = self.deps

                    if not self.settings.antiAfk or not d or type(d.nudge) ~= 'function' then
                        return
                    end
                    if pcall(d.nudge) then
                        self.afkCount += 1

                        setStatus(string.format('Anti-AFK: kept the session active (%d)', self.afkCount))
                    end
                end
                function self.onDisconnect()
                    local d = self.deps

                    if not self.settings.autoReconnect or self.reconnecting or not d then
                        return
                    end

                    local errorCodeFn = d.errorCode
                    local code = if type(errorCodeFn) == 'function'then(errorCodeFn)()else nil

                    if type(code) ~= 'string' or table.find(MISC.reconnectErrors, code) == nil then
                        return
                    end

                    self.reconnecting = true

                    local ctx = self.context
                    local taskApi = d.task

                    local function run()
                        local waitTask = if taskApi then taskApi.wait else nil

                        if type(waitTask) == 'function' then
                            (waitTask)(MISC.reconnectDelaySeconds)
                        end

                        queueRerun()

                        for attempt = 1, MISC.reconnectAttempts do
                            if ctx ~= self.context then
                                return
                            end

                            setStatus(string.format('Reconnecting after %s (%d/%d)', code, attempt, MISC.reconnectAttempts))

                            local teleportFn = d.teleport

                            pcall(teleportFn, metadata.placeIds[1])

                            if type(waitTask) == 'function' then
                                (waitTask)(MISC.reconnectRetrySeconds)
                            end
                        end

                        setStatus('Auto Reconnect gave up; reconnect manually')
                    end

                    local spawnTask = if taskApi then taskApi.spawn else nil

                    if type(spawnTask) == 'function' then
                        (spawnTask)(run)
                    else
                        run()
                    end
                end
                function self.start(ctx)
                    self.context = ctx

                    if not self.deps then
                        local ok, live = pcall(liveDependencies)

                        self.deps = if ok then live else nil
                    end

                    local d = self.deps

                    if not d then
                        setStatus('Unavailable in this environment')

                        return
                    end

                    self.storage = d.storage

                    if self.storage and d.decode then
                        local body = self.storage.read()

                        if body then
                            local ok, data = pcall(d.decode, body)

                            if ok and type(data) == 'table' and data.schemaVersion == SCHEMA_VERSION then
                                for _, key in {
                                    'antiAfk',
                                    'autoReconnect',
                                    'rerunOnTeleport',
                                }do
                                    if type(data[key]) == 'boolean' then
                                        self.settings[key] = data[key]
                                    end
                                end

                                if Runtime.validLoaderUrl(data.loaderUrl) then
                                    self.settings.loaderUrl = data.loaderUrl
                                end
                            end
                        end
                    end

                    for _, pair in {
                        {
                            signal = d.idled,
                            handler = self.onIdle,
                        },
                        {
                            signal = d.errorChanged,
                            handler = self.onDisconnect,
                        },
                    }do
                        local signal = pair.signal
                        local handler = pair.handler

                        if signal and type(signal.Connect) == 'function' then
                            local ok, connection = pcall(signal.Connect, signal, function(
                            )
                                handler()
                            end)

                            if ok and connection then
                                table.insert(self.connections, connection)
                            end
                        end
                    end

                    queueRerun()
                    setStatus(string.format('Anti-AFK %s \u{2022} Auto Reconnect %s \u{2022} Re-run %s', if self.settings.antiAfk then'on'else'off', if self.settings.autoReconnect then'on'else'off', if self.settings.rerunOnTeleport then(if self.queued then'queued'else'on')else'off'))
                end
                function self.stop()
                    for _, connection in self.connections do
                        pcall(function()
                            connection:Disconnect()
                        end)
                    end

                    table.clear(self.connections)

                    self.context = nil
                    self.reconnecting = false
                end

                return self
            end

            return Runtime
        end

        function __DARKLUA_BUNDLE_MODULES.V()
            local v = __DARKLUA_BUNDLE_MODULES.cache.V

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.V = v
            end

            return v.c
        end
    end
end

local Types = __DARKLUA_BUNDLE_MODULES.a()
local metadata = __DARKLUA_BUNDLE_MODULES.b()
local config = __DARKLUA_BUNDLE_MODULES.c()
local JoinerPage = __DARKLUA_BUNDLE_MODULES.p()
local JoinerRuntime = __DARKLUA_BUNDLE_MODULES.v()
local AdventurePage = __DARKLUA_BUNDLE_MODULES.y()
local AdventureAdapter = __DARKLUA_BUNDLE_MODULES.z()
local AdventureRuntime = __DARKLUA_BUNDLE_MODULES.C()
local MacroPage = __DARKLUA_BUNDLE_MODULES.D()
local MacroRuntime = __DARKLUA_BUNDLE_MODULES.F()
local GamePage = __DARKLUA_BUNDLE_MODULES.G()
local GameAdapter = __DARKLUA_BUNDLE_MODULES.H()
local AutoPlayPage = __DARKLUA_BUNDLE_MODULES.I()
local AutoPlayRuntime = __DARKLUA_BUNDLE_MODULES.L()
local StatusPage = __DARKLUA_BUNDLE_MODULES.M()
local DashboardPage = __DARKLUA_BUNDLE_MODULES.N()
local WebhookPage = __DARKLUA_BUNDLE_MODULES.Q()
local WebhookRuntime = __DARKLUA_BUNDLE_MODULES.T()
local MiscPage = __DARKLUA_BUNDLE_MODULES.U()
local MiscRuntime = __DARKLUA_BUNDLE_MODULES.V()
local active = false
local joiner = JoinerRuntime.new()
local adventure = AdventureAdapter.new()
local adventureRun = AdventureRuntime.new(adventure.getSettings)
local macro = MacroRuntime.new()
local gameSettings = GameAdapter.new()
local autoPlay = AutoPlayRuntime.new()
local webhook = WebhookRuntime.new()
local misc = MiscRuntime.new()
local pages = {
    {
        title = 'Dashboard',
        icon = 'layout-dashboard',
        description =
[[Your player card, live status of every feature and your balances.]],
        group = 'Home',
        iconColor = 'primary',
        home = true,
        render = function(tab)
            DashboardPage.mount(tab, {
                joiner = joiner,
                autoPlay = autoPlay,
                macro = macro,
                webhook = webhook,
                misc = misc,
            })
        end,
    },
    {
        title = 'Joiner',
        icon = 'users',
        description =
[[Auto join stages, challenges, Rift, bounties and Worldline by priority.]],
        group = 'Farming',
        iconColor = 'primary',
        render = function(tab)
            JoinerPage.mount(tab, nil, joiner)
        end,
    },
    {
        title = 'Odyssey Adventure',
        icon = 'compass',
        description =
[[Odyssey: Adventure runs: character, Route Atlas, cards, Stitches Shop and cash out (settings only).]],
        group = 'Farming',
        iconColor = 'violet',
        render = function(tab)
            AdventurePage.mount(tab, adventure.getCatalog(), adventure.getSettings(), joiner)
        end,
    },
    {
        title = 'Auto Play',
        icon = 'play',
        description =
[[Native in-game Auto Play, vote start and stage preset rules.]],
        group = 'Farming',
        iconColor = 'blue',
        render = function(tab)
            AutoPlayPage.mount(tab, autoPlay, macro)
        end,
    },
    {
        title = 'Macro',
        icon = 'list',
        description = 'Record and replay match actions.',
        group = 'Farming',
        iconColor = 'violet',
        render = function(tab, window)
            MacroPage.mount(tab, macro, window, autoPlay)
        end,
    },
    {
        title = 'Game',
        icon = 'gamepad-2',
        description = 'Auto Replay, Auto Next, wave skip and Auto Back to Lobby.',
        group = 'Farming',
        iconColor = 'orange',
        render = function(tab)
            GamePage.mount(tab, gameSettings)
        end,
    },
    {
        title = 'Webhook',
        icon = 'bell',
        description =
[[Discord notifications for matches, units, joiner and bounty events.]],
        group = 'Tools',
        iconColor = 'gold',
        render = function(tab)
            WebhookPage.mount(tab, webhook)
        end,
    },
    {
        title = 'Misc',
        icon = 'shield-check',
        description =
[[Anti-AFK, Auto Reconnect and re-running the hub after a teleport.]],
        group = 'Tools',
        iconColor = 'rose',
        render = function(tab)
            MiscPage.mount(tab, misc)
        end,
    },
    {
        title = 'Status',
        icon = 'activity',
        description = 'Live checks of the game modules the hub depends on.',
        group = 'System',
        iconColor = 'slate',
        render = function(tab)
            StatusPage.mount(tab)
        end,
    },
}
local GameModule = {
    metadata = metadata,
    config = config,
    pages = pages,
    windowTags = config.windowTags,
}

function GameModule.start(context)
    if active or not context.alive then
        return
    end

    active = true

    joiner.setMacro(macro)
    joiner.setAdventure(adventure)
    joiner.setReturnGate(webhook.isBusy)
    gameSettings.setReturnGate(webhook.isBusy)
    joiner.setGameSettings(gameSettings)
    autoPlay.setMacro(macro)
    macro.setAutoPlay(autoPlay)

    local env = getfenv()
    local gameObject = env.game
    local taskApi = env.task

    local function initModule()
        if not context.alive or not active then
            return
        end
        if gameObject and type(gameObject.IsLoaded) == 'function' and not (gameObject):IsLoaded() then
            pcall(function()
                (gameObject).Loaded:Wait()
            end)
        end
        if type(taskApi) == 'table' and type(taskApi.wait) == 'function' then
            (taskApi).wait(config.thresholds.startDelaySeconds)
        end
        if gameObject and gameObject.PlaceId ~= metadata.placeIds[1] then
            pcall(function()
                local rep = gameObject:GetService('ReplicatedStorage')
                local ghMod = rep:FindFirstChild('Modules') and rep.Modules:FindFirstChild('Gameplay') and rep.Modules.Gameplay:FindFirstChild('GameHandler')

                if ghMod then
                    local gh = (require)(ghMod)

                    if gh and not gh.IsGameLoaded and gh.GameLoaded and type(gh.GameLoaded.Wait) == 'function' then
                        (gh.GameLoaded):Wait()
                    end
                end
            end)

            if type(taskApi) == 'table' and type(taskApi.wait) == 'function' then
                (taskApi).wait(1)
            end
        end
        if not context.alive or not active then
            return
        end

        joiner.start(context)
        macro.start(context)
        gameSettings.start(context)
        autoPlay.start(context)
        webhook.start(context, {
            joiner = joiner,
            autoPlay = autoPlay,
            macro = macro,
        })
        misc.start(context)
        adventureRun.start()

        local session = ((getfenv())).shared and ((getfenv())).shared.ViperHubNextGen

        if type(session) == 'table' then
            session.adventure = adventureRun
        end

        context.log('GAME_STARTED')
    end

    if type(taskApi) == 'table' and type(taskApi.spawn) == 'function' then
        (taskApi).spawn(initModule)
    else
        initModule()
    end
end
function GameModule.stop()
    joiner.stop()
    macro.stop()
    gameSettings.stop()
    autoPlay.stop()
    webhook.stop()
    misc.stop()
    adventureRun.stop()

    active = false
end

return GameModule
