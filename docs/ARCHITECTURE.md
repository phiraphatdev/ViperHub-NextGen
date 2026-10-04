# Architecture

## Approved decisions

Public source; no obfuscation. WindUI via a pinned, locally adapted vendor bundle.
Two independent placeholder games. Verified lobby PlaceIds and Universe GameIds identify a game; a matching universe does not certify gameplay compatibility for every sub-place.
Single-commit builds regenerate dist and manifest together; optional commit fields are not release gates.
Runtime observations remain documented but do not block a local build. Operational status controls availability per game.
Anime Vanguards now has a game-owned Joiner for four stage-based modes, Boss Bounties, Worldline, Boss Event, Rift and Regular/Daily/Weekly Challenge, plus an Auto Play module (`AutoPlay/Adapter`, `Rules`, `Runtime`, `Page`) that owns native Auto Play and per-mode Stage Preset Rules (persisted as `AnimeVanguardsAutoPlay.json` schema v3). It starts only its own confirmed hosted lobby; no anti-cheat evasion.
Anime Vanguards Macro owns its file store, JSON validation, match adapter, recorder, player and UI. It uses observed game broadcasts and a separate executor-workspace directory; shared platform and UI stay game-neutral. Playback places directly after checking the live price and never creates phantom placements. Native per-unit Auto Upgrade, Upgrade Priority and Auto Ability toggle actions use the game's decoded client events and readback; auto-equip remains reserved.
Macro playback processes action indices sequentially without the former time-adjacent upgrade skip. Upgrade actions carry the achieved level; older files infer per-unit levels in memory. Native auto-upgrade purchases are level checkpoints, not duplicate manual upgrade requests. Attack priority reads the game's numeric `Data.Priority` via `PriorityHandler.PRIORITIES` and records from the unit-state change signal.
`GameModule.pages.render` now receives the tab and an optional window as its second argument so game-owned pages can show native confirmation dialogs; older one-argument renderers remain compatible.

## Boundaries

bootstrap/Main -> core + games/Detector + platform + network + config + ui/App
games/Detector -> Registry -> Metadata (never imports game behavior); exact PlaceId first, verified GameId fallback.
ui/App -> WindUIAdapter + pages; individual games never call WindUI directly.
Game exports are fetched independently and validated against id/version/start/stop. An optional, validated `GameModule.pages` list owns game-specific navigation labels and descriptions; `ui/App` renders it generically between Overview and shared Settings/Diagnostics. Older modules without pages remain valid. A page may optionally render game-owned controls; shared UI remains game-neutral. Anime Vanguards Joiner owns distinct stage and challenge request paths, a matching confirmation subscription, and one-shot Start after host readback; shared UI does not know game modes.

| Directory | Responsibility |
| --- | --- |
| bootstrap | One startup composition point and error boundary |
| core | Per-run context, cleanup, diagnostics, lifecycle transition rules |
| platform | Dynamic executor functions and optional fixed-path filesystem |
| network | HTTP, manifest/status validation, compilation boundary |
| config | Schema, defaults and persistence independent of UI flags |
| games | Exact registry and independently bundled game entries |
| ui | WindUI adapter and presentation pages |
| types | Shared contracts; dynamic third-party boundaries use validated any |
| utils | Stateless input and version validation |
| vendor | Reviewed third-party revision and license |
| scripts | PowerShell entry points and a native-Node pipeline (no npm packages) |
| tests | Unit, integration, fixtures and actual-runtime evidence |

## Lifecycle

A second run destroys the previous owned context before creating a new one.
Context starts created -> loading -> ready. Unsupported places finish unsupported; failures finish failed.
alive=false prevents late HTTP results from mounting UI after cancellation.
Cleanup runs once in reverse acquisition order; one failing callback cannot skip remaining callbacks.
The WindUI adapter owns the window and four root GUIs, destroys its owned GUIs and disconnects upstream connections; it does not invoke the asynchronous window destroy method because that can race the immediate cleanup path.
The ViperHub window uses WindUI's non-NewElements layout and disables the animated element-hover gradient, so moving the pointer across controls does not trigger the newer moving/dimming treatment.
The vendored WindUI patch also uses zero-duration tweens, tab transitions and progress transitions. This affects ViperHub only; game UI animation is unchanged.
Upstream animation/task/connection lifetime still requires real-client verification; mock teardown is not proof of complete WindUI cleanup.

## Runtime paths

Production: use the configured phiraphatdev/ViperHub-NextGen repository (or validate VIPER_REPOSITORY override) -> exact PlaceId or verified Universe GameId detection -> config -> main/manifest.json and status.json -> selected game and UI artifacts from a valid artifactRevision SHA or main fallback -> compile -> UI -> placeholder start.
The production branch requires `manifest.mode = "release"`; development manifests are accepted only by the explicit local harness. An available `http_request` is selected when `request` exists but is not callable.
Development: generated work/runtime-smoke.lua supplies locally built artifact strings using a temporary VIPER_DEV_ARTIFACTS override and restores the previous value afterward.
The dev override is local user-controlled input, not fetched metadata. It deliberately does not certify production readiness.

status.json is an operational switch. Maintenance is shown only for explicit maintenance status.
Malformed/unavailable status blocks loading rather than claiming maintenance or ready.
Version comparison distinguishes loader minimum version, game module version and operational availability.
A newer module version is not proof that the latest game patch is compatible.

## Persistence and diagnostics

Only known config fields survive decoding. NaN and infinities are rejected before clamping.
Anime Vanguards Macro JSON schema v2 stores placement CFrame as 12 finite numbers; its reader normalizes v1 position/yaw without rewriting the source. Match metadata keeps mode/map only. Record start and match restart replace the selected file with an empty document before collecting new actions.
Config paths are fixed under ViperHubNextGen/<Game>.json; callers cannot supply arbitrary paths.
All required filesystem functions must be callable; failed calls remain contained.
Valid shared UI changes autosave through ConfigStore; Anime Vanguards Joiner uses a separate fixed-path file for its controls. Saving verifies bytes by reading back. This is not atomic persistence and does not prove rejoin behavior.
Diagnostics retain at most 64 sanitized codes; no network payloads, file contents or stack traces are printed.

## Build

scripts/pipeline.mjs is an implementation helper for the PowerShell build/check/verify entry points.
scripts/setup-tools.ps1 bootstraps pinned development executables under ignored .tools/.
darklua bundles relative Luau imports and removes type syntax; UI is copied from verified vendor source.
Each artifact is syntax-compiled; a second build must match hashes exactly.
Build metadata avoids wall-clock timestamps, random seeds and stale commit hashes.
The pipeline's `PROJECT_VERSION` generates the local candidate manifest version, loader version and minimum loader version. Game Metadata versions and the loader constant must match; local release-guard tests reject drift. This candidate is not a published tag.
`Metadata.luau` เป็น source of truth ของข้อมูลเกม; pipeline สแกนโฟลเดอร์เกมเพื่อสร้าง entries, artifacts และ `manifest.games`. Registry ยังเป็น allowlist สำหรับ Place ID และ Universe GameId ที่ตรวจสอบแล้ว.
`check.ps1` สร้าง dist/manifest ใหม่ก่อน tests; build, check และ verify ไม่อ่าน Git history หรือ `work/runtime-verification.json`.

## Evidence behind decisions

- Hoho registry: https://github.com/acsu123/HohoV2/blob/main/ScriptLoad.lua — uses GameId, not PlaceId; our exact-place rule is a deliberate project requirement.
- Sirius tooling: https://github.com/SiriusSoftwareLtd/Sirius — analyzer/formatter configurations are visible in the public tree.
- WindUI tree: https://github.com/Footagesus/WindUI/tree/7dd8a34a6bb59635c7b5f18ce9d46558a8cde138 — src, dist, tests and build separation.
- darklua: https://github.com/seaofvoices/darklua — native module bundling/transformation tool.

These are public-source observations, not a claim about private or leaked internal hub architecture.

## UI base (all games)

Every game uses the same shared UI; games describe pages and never call WindUI directly.

| Part | Where | What it gives every game |
| --- | --- | --- |
| Themes | `src/ui/Theme.luau` | 14 ViperHub themes (Viper default, Sakura, Ocean, Sunset, Galaxy, Blood Moon, Gold Rush, Frost, Matrix, Cyberpunk, Lava, Royal, Toxic, Shadow) plus the library's own themes; chosen in Settings, applied live, saved in the shared config (`theme`, `themeVersion`). |
| Window | `src/ui/WindUIAdapter.luau` | Icon, 680x460 size, sidebar player card, gradient open button, layer tags. |
| Layout | `src/ui/App.luau` | Title-bar tags (game name, module version); sidebar sections: `Home` (Overview or the game's home page), the game's groups, and `System` (Settings, Diagnostics). Each page shows its title and description. A failing page shows a placeholder instead of aborting startup. |
| Page style | `src/ui/Style.luau` | `section` (boxed, iconed heading), `sub` (dim sub-heading), `card` (icon paragraph). Game style modules may extend it (Anime Vanguards adds Joiner row icons). |

`GameModule.pages` entries (all optional beyond title/description, validated by `network/ModuleLoader`):

| Field | Meaning |
| --- | --- |
| `title`, `description`, `icon` | Tab label, header description, icon name from the bundled icon set |
| `render(tab, window)` | Builds the page; runs isolated |
| `group` | Sidebar section title (max 24 characters); pages without one are listed under the game's name |
| `iconColor` | Brand color name from `Theme.colors` (primary, secondary, gold, blue, violet, rose, orange, slate) or `#rrggbb` |
| `home` | `true` replaces the shared Overview with this page |

Compatibility: libraries or mocks without `Section`, `Tag`, `AddTheme` or `Gradient` fall back to the flat layout and the Dark theme; games without pages keep Overview, Settings and Diagnostics.

