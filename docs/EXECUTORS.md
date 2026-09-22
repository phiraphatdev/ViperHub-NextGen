# Executors

## Evidence status

| Target | Priority | OS/version | Actual result |
| --- | --- | --- | --- |
| Delta | 1 | Not supplied | Unverified |
| Potassium | 2 | v2.4.9 / Windows | Anime Vanguards foundation partially verified |
| Volt | 3 | Not supplied | Unverified |
| Wave | 4 | Not supplied | Unverified |
| madium | 5 | Identity/version not confirmed | Unverified |
| Real | 6 | Identity/version not confirmed | Unverified |

The original requirement mentioned both four and six executors. All six are recorded as targets;
the mandatory release matrix must be agreed before a compatibility claim or release.
No name-based compatibility assumptions are encoded in the loader.

## APIs and fallback

| Capability | Detection/use | Fallback |
| --- | --- | --- |
| loadstring | Callable check, protected compile and invoke | Stop with a clear unsupported-environment message |
| request / http_request | Callable check; status/body validation | Protected game:HttpGet, may still be unsupported |
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
