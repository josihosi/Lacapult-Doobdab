# TechnicalTome

Durable technical notes for Catapult-Dabubu.

## Product

Catapult-Dabubu is a C-AOL installer and setup helper derived from Dabdoob/Catapult.
The old Lacapult planning/canon workflow is retired. Current work follows the command-center `AGENTS.md` instructions and the live user request.

Public repo URL is still `https://github.com/josihosi/Lacapult-Doobdab` until the repository is renamed.

## Source Shape

- Godot project: `project.godot`
- Main scene: `scenes/Catapult.tscn`
- Main script: `scripts/Catapult.gd`
- Release fetching: `scripts/ReleaseManager.gd`
- Release installation/extraction: `scripts/ReleaseInstaller.gd`
- Backend setup: `scripts/BackendConfigManager.gd` and `scripts/BackendSetupUI.gd`
- Settings: `scripts/settings_manager.gd`
- Paths/install folders: `scripts/path_helper.gd`
- Playtest/manual handoff tab: `scripts/Debug.gd`

## C-AOL Install Contract

Dabubu fetches C-AOL releases from:

`https://api.github.com/repos/josihosi/Cataclysm-AOL/releases`

Current manual playtest target is the `caol-cdda-master-*` release family. Platform asset filters:

- Windows: `_windows.zip`
- macOS: `_macos.dmg`
- Linux: `_linux.tar.gz`

After install, Dabubu should preflight the active C-AOL install for:

- executable
- `data`
- `gfx`
- `tools/openclaw_harness/startup_harness.py`
- `tools/openclaw_harness/requirements.txt`
- root `zzip.exe` on Windows, root `zzip` on macOS/Linux
- five packaged `manual.*` handoff scenarios

## Python Venv Setup

`Set up Python venv` is real installer behavior, not a bundled venv.

Pinned toolchain:

- `uv` version: `0.11.19`
- managed CPython: `3.13.13`

The Windows `uv` archive extracts `uv.exe` at the archive root. macOS/Linux uv archives extract into a nested directory.

The setup path must stay app-local:

- uv cache: `utils/uv-toolchain/cache`
- uv binary: `utils/uv-toolchain/uv-0.11.19`
- managed Python: `utils/uv-toolchain/python`
- C-AOL shared venv: `caol/userdata/config/caol-llm-python-venv`

No global PATH mutation. No system Python requirement. On Windows, launch PowerShell setup helpers through the resolved System32 `powershell.exe` path, not bare `powershell`.

## Manual Playtest

The Playtest tab uses C-AOL's packaged `tools/openclaw_harness/startup_harness.py`.

Manual handoff must not depend on screenshots, OCR, Peekaboo, or GUI automation. The launcher path should prepare the fixture/userdir, validate target world/save, launch C-AOL, write the handoff report/PID, and leave the game open for human play.

Expected manual scenarios:

- `manual.cannibal_night_pack_mcw`
- `manual.intact_camp_shakedown_mcw`
- `manual.mixed_hostile_siege_mcw`
- `manual.writhing_stalker_hit_fade_mcw`
- `manual.zombie_rider_open_field_mcw`

## Release Validation

Before handing Josef a Dabubu release link:

- build unsigned Windows/macOS/Linux packages from the final commit
- download the published GitHub asset back, not only use a local build folder
- on Windows, extract into a short isolated folder, install/extract a real C-AOL release into `caol/game0`, run the exported `Catapult-Dabubu.exe` venv setup smoke, and remove the temp folder after success/failure
- verify the Windows smoke reaches `python_venv_setup_ok`
- keep release notes clear that Dabubu is the installer and C-AOL is downloaded by Dabubu

## Attribution

Preserve MIT license obligations and lineage for:

- qrrk's Catapult
- Hihahahalol's Dabdoob/Catapult_Dabdoob
- Cataclysm: Arsenic and Old Lace
- inherited Cataclysm launcher targets while inherited support/text remains
