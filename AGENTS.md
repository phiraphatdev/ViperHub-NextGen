# ViperHub NextGen — working agreement

## Context protocol

Before changing code, read manifest.json, docs/ARCHITECTURE.md and the headers of affected modules.
For game work, read all files in docs/games/<Game>/; for platform work, read docs/EXECUTORS.md.
Research upstream primary sources before proposing changes; distinguish observed source from inference.

## Scope and authorization

The approved scaffold uses WindUI, public source and no obfuscation.
The two game modules are placeholders. No anti-cheat evasion or stealth hooks.
New dependencies and approved-folder architecture changes require a proposal. Public interface changes may proceed when necessary, but must include compatibility notes or a migration path.
Build and check are local single-step operations; they do not need a runtime evidence JSON or S/A/B commits.
A direct implementation, continuation or release-preparation request authorizes local commits needed for that task. Push, tag and public release still require explicit authorization.
Research, implementation, local checks, read-only live inspection and reversible live verification are authorized when a client is connected. Ask first before purchases, spending currency, deleting data, teleport/rejoin, irreversible actions or actions affecting other players.

## Feature development

Prioritize Anime Vanguards until its module is usable; keep Anime Expeditions as a placeholder unless the user changes priority.
UI references may guide navigation and grouping, but do not copy proprietary source or claim behavior from labels alone.
Implement game behavior behind the Anime Vanguards adapter, not in bootstrap, shared core or UI pages.
Keep frequently patched instance paths, remote names, mode identifiers and thresholds in the game module config rather than scattering them through logic.
Each feature owns its connections, tasks and temporary instances and must stop cleanly through the shared lifecycle.
Rate-limit repeated actions, validate runtime objects and responses, and fail one feature without taking down unrelated tabs.
Read-only discovery and reversible tests may run immediately on a connected client. Record before/after state; ask first for purchases, currency spending, inventory deletion, teleport/rejoin, irreversible actions or effects on other players.
A feature is complete only when its focused local test passes and its observable live result is read back. If live testing is unavailable, mark runtime verification pending.
## Source rules

Edit src, then run build.ps1 and check.ps1; never hand-edit dist or manifest artifacts. Commit source, dist and manifest together. Keep shared core independent of individual games.
Use --!strict, PascalCase modules, camelCase functions/locals, named constants and task APIs.
Every source module has Purpose/Input/Output/Dependencies; public APIs document inputs and return values.
Use any only at dynamic Roblox, executor and third-party boundaries; validate external input at runtime.
Never use Synapse-specific APIs. Keep diagnostics bounded and free of user payloads, tokens and stack traces.
Any changes to vendor/WindUI must be documented and update the pinned vendored checksum.

## Checks and reporting

Run scripts/check.ps1 (BUILD & CHECKS) after every code modification — this is a mandatory step that must be performed every single time without exception.
The local check formats source via StyLua, rebuilds dist and manifest, executes unit and integration tests, and verifies release guards.
Always execute the latest generated script into the active connected Roblox client upon completing changes/fixes, and verify live UI/runtime state.
Use list_clients before selecting a Roblox client. Run the generated local harness only within the agreed scope.
Read actual context/UI state after execution. Report mock tests and live results separately.
Never set tests/runtime/verification.json to passed based on mocks.
Without live evidence, report implementation complete locally and runtime pending; do not claim overall Definition of Done.
