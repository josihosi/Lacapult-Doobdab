# Catapult-Dabubu

**Catapult-Dabubu** is a local-first installer and setup helper for [Cataclysm: Arsenic and Old Lace](https://github.com/josihosi/Cataclysm-AOL).

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
- Provide v0-safe backend setup/config/status for:
  - API backend, storing provider/model/API-key env-var names only, checking Python/AnyLLM readiness without using secrets.
  - Ollama backend, checking local command/server/model-list state without pulling models.
  - OpenVINO backend, Windows-first for v0, checking Python imports/model-dir/device metadata without installing runtimes or downloading models.
- Preserve inherited mod/soundpack/tileset support while C-AOL-specific compatibility work is investigated and clearly marked as supported, untested, broken, or unknown for C-AOL.

## Development status

This repository is early development. It is public for transparency and collaboration, but no packaged Catapult-Dabubu release exists yet.

## Installation

No Catapult-Dabubu public packaged release exists yet. For development, open the Godot project locally and run `scenes/Catapult.tscn` if a compatible Godot 3 binary is available.

Do not treat the raw Godot project or generated `.pck` files as user-facing installers. The current local proof can produce unsigned macOS/Linux/Windows app/package artifacts, but signed/notarized/public releases and normal-player install QA are still separate release work.

## Release-prep validation

Run `python3 tools/prove_lacapult_export_packaging.py` for the current local packaging proof. It exports Godot PCK packs plus real unsigned macOS/Linux/Windows app/executable artifacts into ignored `.proof-cache/` output, creates unsigned archive/package shapes, records sizes/hashes/shape checks in a manifest, and restores temporary export presets.

As of the current local proof, Godot 3.6.2 plus installed export templates can assemble the cross-platform PCK packs and local unsigned app/package artifacts. Signing, notarization, GitHub release publication, upstream contact, OpenVINO runtime setup, model pulls, and API-secret smoke tests are separate decisions and are not performed by this proof.

## Backend setup validation

Run `python3 tools/prove_caol_backend_contract.py` for the current backend contract proof. It audits the local C-AOL checkout, verifies Catapult-Dabubu's API/Ollama/OpenVINO option mapping, and writes sandbox copies of C-AOL `config/options.json` under `.proof-cache/caol-backend-contract/` for all three backend modes.

Current local backend status: setup/config/status/apply-proof is good for v0; live readiness still depends on the user's environment. AnyLLM/API and Ollama/llama-family are intended to work on Windows/macOS/Linux when their dependencies are installed. OpenVINO is Windows-first for v0 and should be presented that way. This Mac currently has Ollama running, but the default Python is missing `any_llm` and OpenVINO packages, so API/OpenVINO need a configured Python/venv plus secrets/model files before live inference can honestly work.

## Credits

Catapult-Dabubu stands on existing open-source Cataclysm launcher work:

- Catapult by qrrk
- Dabdoob / Catapult_Dabdoob by Hihahahalol
- Cataclysm: Arsenic and Old Lace by josihosi and contributors
- Cataclysm: Dark Days Ahead, Cataclysm: The Last Generation, and Cataclysm: Bright Nights, where inherited code/support/text still applies

See `ATTRIBUTION.md` for details.
