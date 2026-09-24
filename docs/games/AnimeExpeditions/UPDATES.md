# Updates

## Local 0.2.0 candidate — not published

Version metadata now distinguishes the local Universe GameId foundation from published 0.1.0. No new gameplay feature or live match verification is claimed.

## Local Phase 3 — universe detection (not published)

Roblox place-to-universe API identifies lobby `84515722934860` with Universe GameId `7613921865`: https://apis.roblox.com/universes/v1/places/84515722934860/universe. The loader now detects an unknown PlaceId with this GameId, without claiming that match sub-places have passed live tests. Startup diagnostics, notification timing and keybind behavior also changed in shared UI/core.

## 2026-09-24 — Foundation runtime check (no module version change)

Local harness observed ready state, WindUI overview/settings, settings file readback, loader rerun and restored defaults on Potassium v2.5.0 / Windows. This is partial evidence, not a game patch fix or production release. Rejoin, physical input and published loader remain pending. See ../../../tests/runtime/AnimeExpeditions-2026-09-24.json.

## 2026-09-22 — 0.1.0 foundation

Added exact place registry, metadata, empty patch-sensitive config and independent placeholder export.
No game patch fix or gameplay capability is claimed. Live Roblox verification pending.
