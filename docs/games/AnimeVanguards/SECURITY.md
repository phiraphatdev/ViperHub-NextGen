# Anime Vanguards security notes

No game-specific anti-cheat internals were inspected or inferred.
The game module reads PlaceId and replicated stage-progress data; the Joiner can request private lobbies only when explicitly enabled.
The Joiner uses `LobbyMatchmakingClient.CreateMatch.Fire` for private stage lobbies and `LobbyChallengesClient.StartChallenge.Fire` for challenge lobbies. It validates selected stage progress or the current challenge name/stage against replicated game data and waits for a matching `MatchConfirmed` payload. Only that confirmed request, while still enabled and `IsHosting=true`, may issue one `StartMatch.Fire()`; sending Start is not itself proof of teleport. It does not hook or modify game instances. The 30-second retry floor avoids rapid repeated requests.
Worldline requests validate the selected replicated ID and progress response before using the game's `TeleportToWorldline` path. Boss Event requests require the live weekly event name to match the selected name and wait for matching host confirmation. Neither request is counted as arrival or completion.
Macro Play defaults to Stop after failed direct-placement attempts. Its optional Restart and Return to Lobby policies use the game's `CastRestartVote` and `RequestTeleportToLobby` paths only when selected; a sent vote or teleport request is not treated as a confirmed restart or arrival. No live vote, teleport, placement or upgrade was sent for local tests.
Input validation, trusted-release boundaries and diagnostics follow ../../SECURITY.md.
Any later authorized testing must document actual observed inputs/results and avoid treating client-only state as server acknowledgement.
Owned root GUI teardown and loader reopen persistence passed on Potassium v2.4.9 / Windows. Rejoin and exhaustive third-party resource cleanup remain unverified.
