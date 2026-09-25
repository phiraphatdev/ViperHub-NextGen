# Updates

## 0.2.2 candidate — no tagged release

Shared foundation fixes for keybind validation, UI window cleanup, unsupported-game notification and registry consistency. No gameplay feature or game patch fix.

## Local 0.2.0 candidate — not published

Version metadata now distinguishes the local Universe GameId foundation from published 0.1.0. No new gameplay feature or live match verification is claimed.

## Local Phase 3 — universe detection (not published)

Roblox place-to-universe API identifies lobby `16146832113` with Universe GameId `5578556129`: https://apis.roblox.com/universes/v1/places/16146832113/universe. The loader now detects an unknown PlaceId with this GameId, without claiming that match sub-places have passed live tests. Startup diagnostics, notification timing and keybind behavior also changed in shared UI/core.

## 2026-09-24 — Current-source foundation runtime check (no module version change)

Local harness observed ready state, visible WindUI, settings file readback, loader rerun and restored defaults on Potassium v2.5.0 / Windows. This is partial evidence, not a game patch fix or production release. Rejoin, physical input and published loader remain pending. See ../../../tests/runtime/AnimeVanguards-2026-09-24.json.

## 2026-09-22 — 0.1.0 foundation

Added exact place registry, metadata, empty patch-sensitive config and independent placeholder export.
No game patch fix or gameplay capability is claimed. Live Roblox verification pending.


Live validation: Potassium v2.4.9 / Windows. Fixed initial tab selection and picker-save synchronization found during UI tests. Config persisted through loader destroy/reopen; old owned GUI was removed and one new root remained. No game rejoin or gameplay feature was tested.
