# ViperHub NextGen — working agreement

## Context protocol

Before changing code, read manifest.json, docs/ARCHITECTURE.md and the headers of affected modules.
For game work, read all files in docs/games/<Game>/; for platform work, read docs/EXECUTORS.md.
Research upstream primary sources before proposing changes; distinguish observed source from inference.

## Scope and authorization

The approved scaffold uses WindUI, public source, no obfuscation and sourceCommit provenance.
The two game modules are placeholders. No gameplay automation, anti-cheat evasion, stealth hooks or remote manipulation.
New dependencies, changes to approved folder architecture and changes to existing public interfaces require a proposal and approval.
Do not commit, tag, push or publish until the release workflow is explicitly authorized.
Research, scaffold implementation and local checks are authorized. Live verification needs a connected client and scoped test actions.

## Source rules

Edit src, then rebuild dist; never hand-edit dist. Keep shared core independent of individual games.
Use --!strict, PascalCase modules, camelCase functions/locals, named constants and task APIs.
Every source module has Purpose/Input/Output/Dependencies; public APIs document inputs and return values.
Use any only at dynamic Roblox, executor and third-party boundaries; validate external input at runtime.
Never use Synapse-specific APIs. Keep diagnostics bounded and free of user payloads, tokens and stack traces.
Any changes to vendor/WindUI must be documented and update the pinned vendored checksum.

## Checks and reporting

Run scripts/check.ps1 after implementation. Tests must cover actual failure risks, not just copy implementation.
Use list_clients before selecting a Roblox client. Run the generated local harness only within the agreed scope.
Read actual context/UI state after execution. Report mock tests and live results separately.
Never set tests/runtime/verification.json to passed based on mocks.
Without live evidence, report implementation complete locally and runtime pending; do not claim overall Definition of Done.

