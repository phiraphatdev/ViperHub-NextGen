# Anime Vanguards security notes

No game-specific anti-cheat internals were inspected or inferred.
The placeholder reads PlaceId and changes only its own local foundation state/UI.
No remote discovery/calls, instance manipulation, hooks or gameplay automation are implemented.
Input validation, trusted-release boundaries and diagnostics follow ../../SECURITY.md.
Any later authorized testing must document actual observed inputs/results and avoid treating client-only state as server acknowledgement.
Owned root GUI teardown and loader reopen persistence passed on Potassium v2.4.9 / Windows. Rejoin and exhaustive third-party resource cleanup remain unverified.

