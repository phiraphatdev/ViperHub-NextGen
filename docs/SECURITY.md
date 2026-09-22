# Security scope and threat model

## Assets and trust boundaries

Protect local config integrity, predictable loading, user privacy and release provenance.
Untrusted boundaries are HTTP responses, decoded JSON, persisted files and third-party code.
The local executor and GitHub repository owner are trusted execution authorities; a compromised executor
can alter both code and checks. Public client source contains no durable secret.

## Controls implemented

- Only HTTPS GitHub Raw metadata/artifact URLs constructed from owner/repo and validated commit/path fields.
- Immutable artifactRevision for module code; mutable operational status kept separate.
- Strict manifest shape, bounds, finite numeric checks and exact module id/version contract.
- HTTP body caps and logical deadlines; timed-out responses cannot update accepted state.
- Source/executable/vendor checksums and reproducible artifact verification in the local build pipeline.
- Fixed config paths, bounded file size, decode validation, write/readback and session fallback.
- Bounded sanitized diagnostics; no raw response data or public stack traces.
- No Synapse APIs, GUI protection hooks, gameplay remotes or anti-cheat evasion.

## Limits requiring explicit understanding

The runtime checks body size and trusts GitHub HTTPS plus immutable commit URLs. It does not implement
SHA-256 verification or signature verification inside the client. Manifest hashes are verified by the build/release pipeline.
A hash stored beside an artifact is not an independent authenticity proof.
HTTP deadlines are logical cancellation; a blocked native transport may keep its worker alive until the transport returns.
JSON/HTTP size checks happen after the underlying API returns the body.
Config writes are not atomic and may fail during shutdown; invalid files fall back to defaults.
WindUI is upstream Beta code with optional paths outside the enabled foundation; actual lifecycle behavior remains unverified.
The upstream key-system provider code exists inside its vendor bundle but is never configured by this app.

No claim of undetectability, bypass capability or protection from game enforcement is made.
Game-specific security documents cover observed contracts and test limits, not evasion recipes.

References:

- https://create.roblox.com/docs/scripting/security/client-server-boundary
- https://github.com/Footagesus/WindUI

