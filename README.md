# Lacapult Doobdad

**Lacapult Doobdad** is a local-first installer and setup helper for [Cataclysm: Arsenic and Old Lace](https://github.com/josihosi/Cataclysm-AOL).

It is derived from [Hihahahalol's Dabdoob / Catapult_Dabdoob](https://github.com/Hihahahalol/Catapult_Dabdoob), which is based on [qrrk's Catapult launcher](https://github.com/qrrk/Catapult). The inherited launcher code remains MIT licensed; see `LICENSE` and `ATTRIBUTION.md`.

> Current development target: fetch and install existing C-AOL `v0.2.0` GitHub release assets, then add first safe backend setup paths for API and Ollama. OpenVINO is parked as a specialized future path.

## What v0 is meant to do

- Show C-AOL as the only first-class game target.
- Fetch releases from `josihosi/Cataclysm-AOL`.
- Select platform-appropriate assets:
  - Linux: `_linux.tar.gz`
  - Windows: `_windows.zip`
  - macOS: `_macos.dmg` (with future tolerance for `_macos.tar.gz` / `_macos.zip`)
- Reuse Dabdoob's install/update path while preserving saves, config, mods, soundpacks, and tilesets where possible.
- Provide safe first-pass backend setup metadata for:
  - API backend, without storing or logging secrets.
  - Ollama backend, with local detection/config guidance.
- Preserve inherited mod/soundpack/tileset support while C-AOL-specific compatibility work is investigated.

## Local development status

This repository is currently local-only. Do not treat this README as a public release page yet: public repo creation, pushing, publishing releases, or contacting upstream requires fresh explicit clearance from Josef/Schani.

## Installation

No Lacapult Doobdad packaged release exists yet. For development, open the Godot project locally and run `scenes/Catapult.tscn` if a compatible Godot binary is available.

## Credits

Lacapult Doobdad stands on existing open-source Cataclysm launcher work:

- Catapult by qrrk
- Dabdoob / Catapult_Dabdoob by Hihahahalol
- Cataclysm: Arsenic and Old Lace by josihosi and contributors
- Cataclysm: Dark Days Ahead, Cataclysm: The Last Generation, and Cataclysm: Bright Nights, where inherited code/support/text still applies

See `ATTRIBUTION.md` for details.
