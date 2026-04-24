# TESTING

Current validation policy and evidence for Lacapult Doobdab.

## Validation policy

Use the smallest evidence that honestly matches the change.

- Docs/README/license-only changes: grep/static inspection is enough.
- GDScript release parsing changes: live GitHub JSON fixture or small script proof plus static inspection.
- UI node-path changes: Godot parse/load or GUI smoke if Godot is available; otherwise record missing Godot binary as blocker and prove paths by inspection.
- Installer/download changes: avoid huge downloads unless needed; first prove metadata shape and asset selection, especially for C-AOL `v0.2.0`.
- Backend setup changes: prove config shape and safe local detection; do not require real API secrets or large model downloads for v0 evidence.
- Public repo creation/push: external action, requires explicit clearance.

## Current evidence

Initial source audit from Schani:

- Source repo `Hihahahalol/Catapult_Dabdoob` is public, standalone, and MIT licensed.
- Source tech is Godot/GDScript with helper Python/Shell scripts.
- Source `LICENSE` includes qrrk and Dabdoob copyright notices.
- Source README credits CDDA, CTLG, BN, and qrrk Catapult.
- Local scaffold created at `/Users/josefhorvath/Schanigarten/Lacapult-Doobdab` by copying source without inherited `.git` history and initializing a new local git repo.

## Required v0 proof packet

Before claiming v0 is done, Andi should record:

1. Identity/attribution proof
   - `grep -R` evidence that public identity points to Lacapult Doobdab/C-AOL.
   - Remaining Dabdoob/Catapult references are credits or internal filenames intentionally left for later.

2. Release parsing proof
   - live `gh release view` or GitHub API capture for `josihosi/Cataclysm-AOL`.
   - platform filter result for the current OS.
   - at least one expected asset selected from `v0.2.0` release assets.

3. Backend setup proof
   - API option/config path exists and avoids secret leakage.
   - Ollama option/config path exists and local detection is run if available.
   - OpenVINO is parked/stubbed rather than silently missing.

4. Modding investigation proof
   - inherited mod/soundpack/tileset entry points are identified.
   - first C-AOL compatibility-summary / future NPC-summary note is written.

5. Godot/static proof
   - `godot --version` / `godot3 --version` / `godot4 --version` check.
   - If Godot exists: run the strongest cheap headless/project parse check available for this version.
   - If Godot does not exist: state that clearly and rely on static grep plus code-shape proof for first handoff.

6. Installer-shape proof
   - show the release object handed to installer has `name`, `url`, `filename`, `published_at`, `has_any_assets`.
   - do not download a huge release archive unless Schani/Josef explicitly wants that proof.

## Known risk spots

- Godot 3 scene node paths may break if the game chooser/channel UI is removed too aggressively.
- Existing release manager duplicates per-game callbacks; adding C-AOL by copy may be safer for v0 than a clever refactor.
- Existing mod/soundpack/tileset code assumes multiple Cataclysm game IDs; hiding other games is safer than deleting support everywhere in the first slice.
- Mod compatibility/NPC summaries are investigation/docs first, not runtime integration in v0.
- Existing self-update URL points to Dabdoob and must not silently offer Dabdoob releases as Lacapult updates.

## Evidence - 2026-04-24 v0.2.0 release/backend proof slice

- Live release parser proof: `python3 tools/prove_caol_release.py`
  - Found `josihosi/Cataclysm-AOL` release `v0.2.0` on Darwin.
  - Matched macOS filter `_macos.dmg` against `caol_cdda-0-h_2026-03-29-1556_macos.dmg`.
  - Produced installer metadata shape with `name`, `url`, `filename`, `published_at`, and `has_any_assets` without downloading the archive.
- Backend local detection proof:
  - `command -v ollama` -> `/opt/homebrew/bin/ollama`
  - `curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags` -> running
  - API backend remains config-shape only; no secrets were used, stored, or logged.
  - OpenVINO remains parked as `parked_specialized_future` in `scripts/BackendConfigManager.gd`.
- Godot availability check:
  - `godot --version`, `godot3 --version`, and `godot4 --version` were not found on this machine, so no GUI/project-load smoke was claimed.
- Static identity/release proof:
  - `grep -R "caol-release\|josihosi/Cataclysm-AOL\|_macos.dmg\|_linux.tar.gz\|_windows.zip\|backend_ollama\|backend_api\|OpenVINO\|Lacapult Doobdab" -n README.md project.godot scripts text/en doc tools`
  - Shows Lacapult project identity/defaults, C-AOL release URL and asset filters, API/Ollama settings, and OpenVINO parked note.
- Mod support proof:
  - Inherited entry points remain present: `scripts/ModManager.gd`, `scripts/ModsUI.gd`, `scripts/SoundpackManager.gd`, `scripts/SoundpacksUI.gd`, `scripts/TilesetManager.gd`, `scripts/TilesetsUI.gd`.
  - First C-AOL compatibility/NPC-summary note added at `doc/caol-mod-compatibility-summary.md`.

## Evidence - 2026-04-24 warning enum cleanup

- Static warning enum proof: `grep -R "Enums.MSG_WARNING" -n scripts || true`
  - Before cleanup, this found warning posts in installer, download, filesystem, mod, soundpack, and tileset paths.
  - These now use the existing `Enums.MSG_WARN` member from `scripts/Enums.gd`, avoiding a runtime failure when those warning branches execute.
- Re-ran `python3 tools/prove_caol_release.py`; it still selects the Darwin `v0.2.0` DMG and produces installer metadata without downloading it.
- Re-ran Ollama cheap detection: `command -v ollama` is `/opt/homebrew/bin/ollama`; local server probe returned JSON with 8 models. No model pull or secret-bearing API smoke was attempted.

## Evidence - 2026-04-25 backend settings surface

- Added `BackendConfig` as a Godot autoload and wired the Settings tab to create a small C-AOL NPC backend setup section at runtime.
- Static UI proof: `grep -R "BackendConfig=\|BackendSetup\|Save backend setup metadata\|C-AOL NPC backend setup\|OpenVINO is parked\|API mode saves" -n project.godot scripts/SettingsUI.gd scripts/BackendConfigManager.gd`
  - Shows the autoload, runtime-created backend setup section, save button, API no-secret warning, Ollama status readout, and parked OpenVINO copy.
- Re-ran `python3 tools/prove_caol_release.py`; it still selects `caol_cdda-0-h_2026-03-29-1556_macos.dmg` for Darwin `v0.2.0` and produces installer metadata without downloading it.
- Re-ran Ollama cheap detection: `command -v ollama` is `/opt/homebrew/bin/ollama`; local server probe returned JSON with 8 models. No model pull or secret-bearing API smoke was attempted.
- Re-ran Godot availability check: `godot`, `godot3`, and `godot4` are still unavailable on this Mac, so no GUI/project-load smoke was claimed.
- `git diff --check` passed for the backend surface changes.

## Evidence - 2026-04-25 all-platform v0.2.0 asset proof

- Extended `tools/prove_caol_release.py` with `--all-platforms`, still using one live GitHub API read and no archive downloads.
- Ran `python3 tools/prove_caol_release.py --all-platforms`:
  - Found `josihosi/Cataclysm-AOL` release `v0.2.0` / `Cataclysm - Arsenic and Old Lace v0.2.0` with 12 assets.
  - Linux filter `_linux.tar.gz` matched 4 assets and produced an installable metadata shape.
  - macOS filters `_macos.dmg`, `_macos.tar.gz`, `_macos.zip` matched 4 DMG assets and produced an installable metadata shape.
  - Windows filter `_windows.zip` matched 4 assets and produced an installable metadata shape.
  - Each platform result included `name`, `url`, `filename`, `published_at`, and `has_any_assets` for the installer handoff shape.
