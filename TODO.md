# TODO

Short execution queue only.

## Now

Active target: `Lacapult Doobdab v0.2.0 release installer plus first backend setup options`.

Product north star: `doc/lacapult-one-shot-installer-vision.md`. Use it for detail, but do not skip the proof order.

1. Confirm source/import state
   - Verify this repo is local-only and has no inherited `.git` history from Dabdoob.
   - Commit the imported source plus canon docs once attribution files are present.

2. Public identity and attribution cleanup
   - Preserve `LICENSE` MIT notice for qrrk and Dabdoob.
   - Add/update `ATTRIBUTION.md`.
   - Rewrite README top section for Lacapult Doobdab as a C-AOL-specific launcher/installer.
   - Update `project.godot` name/description.
   - Replace or disable Dabdoob self-update URL until Lacapult has its own public releases.

3. C-AOL-only v0.2.0 release path — proof landed 2026-04-24
   - [x] Add `caol` / C-AOL as the default and only visible game target.
   - [x] Add release URL for `josihosi/Cataclysm-AOL`.
   - [x] Add platform asset filters for C-AOL `v0.2.0` assets: `_linux.tar.gz`, `_macos.dmg`, `_windows.zip`.
   - [x] Wire fetch/list/install path so a C-AOL v0.2.0 asset becomes the existing installer metadata shape.

4. First LLM backend setup options — first safe skeleton landed 2026-04-24
   - [x] Add API as a selectable setup/config path without exposing secrets.
   - [x] Add Ollama as a selectable setup/config path with local command/server detection where safe.
   - [x] Keep OpenVINO parked/specialized unless a cheap placeholder/detection hook falls out naturally.

5. Modding compatibility investigation — first note landed 2026-04-24
   - [x] Preserve inherited mod/soundpack/tileset support.
   - [x] Identify inherited mod metadata/compatibility entry points.
   - [x] Write the first compatibility-summary direction for C-AOL mods and future NPC/LLM summaries.

6. Minimal validation
   - Prove release JSON parsing selects correct platform asset(s) from live C-AOL v0.2.0 releases.
   - Prove backend config/detection paths at static or safe local-detection level.
   - Run the smallest Godot/static check available on this machine.
   - If full GUI launch is possible, smoke launch to the release list; otherwise record the exact missing tool/blocker.

7. Park next slices
   - OpenVINO full setup.
   - Real model install/model-pull automation.
   - C-AOL-specific mod/soundpack/tileset recommendation packs.
   - NPC/LLM runtime integration of mod summaries.
   - Public GitHub repo creation and first push, only after explicit clearance.
