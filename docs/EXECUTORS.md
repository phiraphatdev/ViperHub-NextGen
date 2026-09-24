# Executors

## Evidence status

| Executor actually observed | OS/version | Actual result |
| --- | --- | --- |
| Potassium | v2.4.9 / Windows | Anime Vanguards foundation partially verified |
| Potassium | v2.5.0 / Windows | Anime Expeditions foundation partially verified |
| Potassium | v2.5.0 / Windows | Anime Vanguards current-source foundation partially verified |

ไม่มี allowlist หรือ mandatory matrix ของ executor ใน loader หรือ release gate
ความเข้ากันได้ตัดสินจาก capability detection และหลักฐานที่ทดสอบจริงเป็นราย environment เท่านั้น
ผลของ executor หนึ่งไม่ยืนยันผลของ executor อื่น

## APIs and fallback

| Capability | Detection/use | Fallback |
| --- | --- | --- |
| loadstring | Callable check, protected compile and invoke | Stop with a clear unsupported-environment message |
| request / http_request | Callable check; status/body validation | If `request` throws or returns a non-table, try callable `http_request`; otherwise use protected game:HttpGet when neither exists |
| readfile/writefile/isfile/isfolder/makefolder | All callable, operations protected | Session-only config |
| shared, task, game | Required Roblox context | Stop before constructing UI |
| gethui | Optional upstream UI parent selection | Upstream default parent; actual permission must be tested |
| clipboard, custom assets, key systems | Not part of foundation behavior | Not enabled |

Synapse-specific APIs are removed from our vendored WindUI copy and prohibited in src.
No obfuscation layer exists. Third-party UI may use Roblox APIs beyond the small bootstrap capability set;
capability flags do not certify complete UI support. Touch behavior and keybind availability depend on device.

Source references (documentation is not runtime evidence):

- https://docs.voltbz.net/docs/scripts/loadstring
- https://getwave.gg/documentation
- https://github.com/Footagesus/WindUI/tree/7dd8a34a6bb59635c7b5f18ce9d46558a8cde138

Record executor name, exact version, OS, device/input, source commit, artifact hashes, startup outcome,
UI state, toggle/slider/dropdown/keybind behavior, close/reopen and file-persistence results for each verified target.


Actual 2026-09-22 results: startup, settings callbacks, config readback, loader reopen persistence, owned GUI teardown and RightShift input passed on Potassium. Rejoin, other games, touch devices and complete upstream leak profiling remain pending. See ../tests/runtime/verification.json.
