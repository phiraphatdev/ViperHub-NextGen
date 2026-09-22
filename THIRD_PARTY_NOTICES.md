# Third-party notices

WindUI by Footagesus: https://github.com/Footagesus/WindUI
Pinned commit: 7dd8a34a6bb59635c7b5f18ce9d46558a8cde138, package version 1.6.66.
The upstream MIT license is retained at vendor/WindUI/LICENSE.
The upstream credits identify the icon collections; their asset identifiers remain in the bundled source.

Local adaptations to vendor/WindUI/source.lua:

1. Remove the Synapse request fallback; keep generic request/http_request paths.
2. Disable the GUI protection callback; the scaffold has no stealth hook.
3. Use the six already-bundled icon tables instead of executing mutable remote icon scripts.
4. Route library print/warn to a sanitized UI_DIAGNOSTIC code supplied by the host.

Both the normalized upstream bundle hash and the locally adapted file hash are recorded in dependencies.lock.json.
The optional upstream key-system providers are not configured or invoked by ViperHub.
The upstream bundle is a third-party exception to our source formatting/header rules; our adapter is strict Luau.

Build tools (development only):

- darklua: https://github.com/seaofvoices/darklua — bundle and strip type syntax, no obfuscation requested.
- StyLua: https://github.com/JohnnyMorganz/StyLua — formatting.
- Luau: https://github.com/luau-lang/luau — analyzer, compiler and CLI tests.

Download URLs, archive checksums and extracted executable checksums are pinned in dependencies.lock.json.

