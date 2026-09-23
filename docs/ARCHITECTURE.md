# Architecture

## Approved decisions

Public source; no obfuscation. WindUI via a pinned, locally adapted vendor bundle.
Two independent placeholder games. PlaceId allowlist; no automatic support for all places in a universe.
sourceCommit tracks source provenance; artifactRevision identifies the commit holding shipped dist files.
Release policy has Dev, Beta and Stable tiers. Beta evidence is scoped to selected games; unpublished or unselected games stay disabled.
No gameplay features or anti-cheat evasion.

## Boundaries

bootstrap/Main -> core + games/Detector + platform + network + config + ui/App
games/Detector -> Registry -> Metadata (never imports game behavior)
ui/App -> WindUIAdapter + pages; individual games never call WindUI directly.
Game exports are fetched independently and validated against id/version/start/stop.

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
The WindUI adapter owns the four root GUIs and calls the upstream connection cleanup.
Upstream animation/task/connection lifetime still requires real-client verification; mock teardown is not proof of complete WindUI cleanup.

## Runtime paths

Production: use the configured phiraphatdev/ViperHub-NextGen repository (or validate VIPER_REPOSITORY override) -> exact place detection -> mutable main/manifest.json and status.json -> immutable artifactRevision URL -> compile validated selected modules -> config -> UI -> placeholder start.
Development: generated work/runtime-smoke.lua supplies locally built artifact strings using a temporary VIPER_DEV_ARTIFACTS override and restores the previous value afterward.
The dev override is local user-controlled input, not fetched metadata. It deliberately does not certify production readiness.

status.json is disabled initially. Maintenance is shown only for explicit maintenance status.
Malformed/unavailable status blocks loading rather than claiming maintenance or ready.
Version comparison distinguishes loader minimum version, game module version and operational availability.
A newer module version is not proof that the latest game patch is compatible.

## Persistence and diagnostics

Only known config fields survive decoding. NaN and infinities are rejected before clamping.
Config paths are fixed under ViperHubNextGen/<Game>.json; callers cannot supply arbitrary paths.
All required filesystem functions must be callable; failed calls remain contained.
Saving verifies bytes by reading back. This is not atomic persistence and does not prove rejoin behavior.
Diagnostics retain at most 64 sanitized codes; no network payloads, file contents or stack traces are printed.

## Build

scripts/pipeline.mjs is an implementation helper for the three approved PowerShell entry points.
scripts/setup-tools.ps1 bootstraps pinned development executables under ignored .tools/.
darklua bundles relative Luau imports and removes type syntax; UI is copied from verified vendor source.
Each artifact is syntax-compiled; a second build must match hashes exactly.
Build metadata avoids wall-clock timestamps, random seeds and self-referential commit hashes.

## Evidence behind decisions

- Hoho registry: https://github.com/acsu123/HohoV2/blob/main/ScriptLoad.lua — uses GameId, not PlaceId; our exact-place rule is a deliberate project requirement.
- Sirius tooling: https://github.com/SiriusSoftwareLtd/Sirius — analyzer/formatter configurations are visible in the public tree.
- WindUI tree: https://github.com/Footagesus/WindUI/tree/7dd8a34a6bb59635c7b5f18ce9d46558a8cde138 — src, dist, tests and build separation.
- darklua: https://github.com/seaofvoices/darklua — native module bundling/transformation tool.

These are public-source observations, not a claim about private or leaked internal hub architecture.
