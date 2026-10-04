# Changelog

## Unreleased

- Anime Vanguards: Odyssey Adventure tab (settings only; automation pending). Option lists read from the game's Adventure data with a config fallback.

## v0.3.0 — Anime Vanguards features and the shared ViperHub UI

- UI base for every game: 14 ViperHub themes (Viper default) plus WindUI's own, live theme switching, grouped sidebar (Home / game groups / System), title-bar tags, player card, page headers, shared `ui/Style`, animated dropdown menus and collapsible sections; most sections start collapsed.
- Anime Vanguards Dashboard: player card, live feature status and balances.
- Joiner: priority joining for Stage, Legend Stage, Raid, Dungeon, Boss Event, Worldline, Boss Bounties, Regular/Daily/Weekly Challenge and Rift; Team and Macro Equipper; Change Stage in Match that respects priority; Joiner Report with ✅/❌ per mode and a persistent action trace.
- Auto Play: native Auto Play with Stage Preset Rules per mode.
- Macro recorder/player; Game settings sync with Auto Back to Lobby.
- Discord Webhook: match result from the game's end summary with Unit Contribution, rewards, balances and session overview; unit drops (Secret+ can ping / @everyone); joiner, bounty, rift and auto play notices.
- Misc: Anti-AFK, Auto Reconnect after real disconnects, Re-run after teleport.
- Fixes from a full code audit (Worldline Auto Next, webhook spam, settings overwrite, page isolation, Status re-checks).
- Runtime verification is partial and recorded per feature in `docs/games/AnimeVanguards/UPDATES.md`; Auto Reconnect after a real disconnect is still unverified.

## Unreleased 0.2.2 candidate

- Preserve the previous valid toggle key when the picker supplies an unsupported key.
- Keep teardown on the adapter's immediate GUI/connection cleanup path; avoid invoking WindUI's asynchronous window destroy as a second competing cleanup.
- Send one unsupported-game notification and reject a published Place ID that conflicts with the loader registry.
- Verify downloaded module byte length and SHA-256 before compilation; require a callable `crypt.hash` capability.
- Keep development as the default build mode intentionally; use `build.ps1 -Release` before a release commit.
- No gameplay features. Publishing this candidate to `main` still requires GitHub Raw and live loader verification before announcing a release.

## Unreleased 0.2.1 candidate (superseded)

- Preserved the previous valid toggle key when the picker supplies an unsupported key.
- That candidate was superseded before publication; its local runtime observations are in `tests/runtime/0.2.1-audit.json`.

## v0.2.0 main beta foundation

- Published the single-commit foundation build to `main` and verified GitHub Raw artifact hashes.
- Production loader returned `ready` in Anime Vanguards and Anime Expeditions; physical input and rejoin remain unverified.
- The immutable v0.1.0 loader is incompatible with the current main manifest; users must switch to `main/dist/loader.lua`.

## v0.1.0 Beta — foundation

- Added modular bootstrap, lifecycle/cleanup and bounded diagnostics.
- Added exact PlaceId detection and independent placeholders for Anime Vanguards and Anime Expeditions.
- Added validated manifests/status, bounded HTTP requests and sanitized module errors.
- Added config validation, optional file persistence and readback.
- Integrated pinned WindUI 1.6.66 with documented compatibility patches.
- Added strict analysis, unit tests, mocked bootstrap tests and deterministic build verification.
- Verified foundation startup, live UI control methods, loader close/reopen persistence and RightShift toggling on Potassium v2.4.9 / Windows in Anime Vanguards.
- Fixed initial tab selection and keybind-picker save synchronization based on live observations.
- Added manifest/registry metadata consistency checks, strict release evidence validation, negative tests and a Thai user manual.
- Verified current-source foundation startup, visible UI, settings file readback and loader-rerun persistence in both games on Potassium v2.5.0 / Windows; see the dated partial records in `tests/runtime/`.
- Beta foundation is enabled for both registered games. The published loader path was read back as ready, alive and window-present in Anime Vanguards and Anime Expeditions. Earlier controls/config observations were carried forward because shipped artifact hashes are byte-identical.
- No gameplay features. Physical/touch input and other environments are not certified.
