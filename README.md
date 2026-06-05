# Catapult-Dabubu

**Catapult-Dabubu** is a local-first installer and setup helper for [Cataclysm: Arsenic and Old Lace](https://github.com/josihosi/Cataclysm-AOL).

It is derived from [Hihahahalol's Dabdoob / Catapult_Dabdoob](https://github.com/Hihahahalol/Catapult_Dabdoob), which is based on [qrrk's Catapult launcher](https://github.com/qrrk/Catapult). The inherited launcher code remains MIT licensed; see `LICENSE` and `ATTRIBUTION.md`.

## Current Contract

Dabubu is the installer. A fresh Windows, macOS, or Linux machine should be able to download Dabubu, install the matching C-AOL `caol-cdda-master-*` release through the Game tab, run `Set up Python venv`, and use the Playtest tab's packaged manual scenarios.

The current C-AOL install preflight expects:

- C-AOL executable
- `data`
- `gfx`
- `tools/openclaw_harness/startup_harness.py`
- `tools/openclaw_harness/requirements.txt`
- root `zzip.exe` on Windows, root `zzip` on macOS/Linux
- exactly five packaged `manual.*` handoff scenarios

`Set up Python venv` is not a bundled venv. Dabubu downloads `uv` `0.11.19`, installs managed CPython `3.13.13` app-locally, creates `caol/userdata/config/caol-llm-python-venv`, installs the active C-AOL harness requirements, and stores the venv Python path. It does not mutate global `PATH` and does not require system Python.

## Manual Playtest

The Playtest tab uses C-AOL's packaged `tools/openclaw_harness/startup_harness.py`.

Expected manual scenarios:

- `manual.cannibal_night_pack_mcw`
- `manual.intact_camp_shakedown_mcw`
- `manual.mixed_hostile_siege_mcw`
- `manual.writhing_stalker_hit_fade_mcw`
- `manual.zombie_rider_open_field_mcw`

Manual handoff should prepare the fixture/profile, validate the target world/save, launch C-AOL, write a handoff report/PID, and leave the game open for human play. It must not depend on screenshots, OCR, Peekaboo, or GUI automation.

## Development

Open the Godot project locally and run `scenes/Catapult.tscn` with a compatible Godot 3 binary.

Package proof command:

```bash
python3 tools/prove_dabubu_export_packaging.py
```

The proof exports unsigned Windows/macOS/Linux app artifacts into ignored `.proof-cache/` output, records sizes and hashes, and restores temporary export presets.

## Release Gate

Before handing a Dabubu release to Josef:

- Build Windows/macOS/Linux packages from the final commit.
- Upload release assets to GitHub.
- Download the published GitHub asset back; do not only test a local build folder.
- On Windows, extract into a short isolated folder, install/extract a real C-AOL release into `caol/game0`, run the exported `Catapult-Dabubu.exe` venv setup smoke, and remove the temp folder after success or failure.
- Confirm the smoke reaches `python_venv_setup_ok`.

## Credits

Catapult-Dabubu stands on existing open-source Cataclysm launcher work:

- Catapult by qrrk
- Dabdoob / Catapult_Dabdoob by Hihahahalol
- Cataclysm: Arsenic and Old Lace by josihosi and contributors
- Cataclysm: Dark Days Ahead, Cataclysm: The Last Generation, and Cataclysm: Bright Nights, where inherited code/support/text still applies

See `ATTRIBUTION.md` for details.
