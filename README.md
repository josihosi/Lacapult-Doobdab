# Lacapult Doobdab

**Lacapult Doobdab** is a local-first installer and setup helper for [Cataclysm: Arsenic and Old Lace](https://github.com/josihosi/Cataclysm-AOL).

It is derived from [Hihahahalol's Dabdoob / Catapult_Dabdoob](https://github.com/Hihahahalol/Catapult_Dabdoob), which is based on [qrrk's Catapult launcher](https://github.com/qrrk/Catapult). The inherited launcher code remains MIT licensed; see `LICENSE` and `ATTRIBUTION.md`.

> Current development target: fetch and install existing C-AOL `v0.2.0` GitHub release assets, expose the first backend setup selector for API/Ollama/OpenVINO, and keep packaging/installability blockers honest before any public release.

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
  - Ollama backend, with local command/server detection and config guidance.
  - OpenVINO backend, selectable in v0 with honest placeholder/status metadata only; full runtime setup is not automated yet.
- Preserve inherited mod/soundpack/tileset support while C-AOL-specific compatibility work is investigated and clearly marked as supported, untested, broken, or unknown for C-AOL.

## Development status

This repository is early development. It is public for transparency and collaboration, but no packaged Lacapult Doobdab release exists yet.

## Installation

No Lacapult Doobdab packaged release exists yet. For development, open the Godot project locally and run `scenes/Catapult.tscn` if a compatible Godot 3 binary is available.

Do not treat the raw Godot project or generated `.pck` files as user-facing installers. The current product bar still requires easy Windows/macOS/Linux app packages before a normal-player release.

## Release-prep validation

Run `python3 tools/prove_lacapult_export_packaging.py` for the current local packaging proof. It exports Godot PCK packs for macOS, Linux, and Windows into ignored `.proof-cache/` output and reports whether full app exports are blocked by missing Godot export templates.

As of the current local proof, Godot 3.6.2 can assemble the cross-platform PCK packs, but full app exports are blocked until the matching Godot 3.6.2 export templates are installed (`osx.zip`, `linux_x11_64_release`, and `windows_64_release.exe`). Signing, notarization, GitHub release publication, upstream contact, OpenVINO runtime setup, model pulls, and API-secret smoke tests are separate decisions and are not performed by this proof.

## Credits

Lacapult Doobdab stands on existing open-source Cataclysm launcher work:

- Catapult by qrrk
- Dabdoob / Catapult_Dabdoob by Hihahahalol
- Cataclysm: Arsenic and Old Lace by josihosi and contributors
- Cataclysm: Dark Days Ahead, Cataclysm: The Last Generation, and Cataclysm: Bright Nights, where inherited code/support/text still applies

See `ATTRIBUTION.md` for details.
