# v0.1.0 Beta foundation release record

- Source commit S: `f5de8312ee023fe7b0c82602684983764b44f2fa`
- Artifact commit A: `af39a11236b66776d756b5362cdebcc7df3dfce4`
- Publication metadata commit B: `ae3d2855619f66f275d6970fda498225b0aee860`
- Activation commit C: `bde6ac7a0344170624eec2754aed074a1ad04ba4`
- Release tier: Beta foundation, both registered games, no gameplay features.

`check.ps1` and `verify-release.ps1` passed. GitHub Raw returned four artifact bytes with hashes matching `manifest.json`. Raw `main/status.json` initially remained `disabled` due to a CDN cache hit; a later fetch returned `ready` for both games. The exact-commit status was `ready` immediately.

The production loader at the A revision was executed in connected Roblox clients after Raw status became `ready`. Focused readback observed:

| Game | Place ID | State | Alive | Window | Diagnostics |
| --- | ---: | --- | --- | --- | --- |
| Anime Vanguards | 16146832113 | ready | true | present | PLACEHOLDER_STARTED, FOUNDATION_READY |
| Anime Expeditions | 84515722934860 | ready | true | present | PLACEHOLDER_STARTED, FOUNDATION_READY |

These are startup/readback observations, not fresh controls, physical/touch input, rejoin, gameplay or broad executor certification. Earlier controls/config observations were carried forward only because the shipped runtime artifact hashes were byte-identical. Release evidence in ignored `work/runtime-verification.json` retains its actual prior run timestamps and records that provenance.

Operational rollback: change the affected game's state in `status.json` to `disabled`, commit and push; allow for Raw CDN cache propagation. This does not require changing artifact A.
