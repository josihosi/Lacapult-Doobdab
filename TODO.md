# TODO

Short execution queue only.

## Now

Active target: `Lacapult Doobdab v0.2.0 release installer plus first backend setup options`.

Current checkpoint: local proof packet, first Godot GUI smoke, controlled selected-macOS-DMG mount/launchability-shape proof, sandboxed Lacapult-style DMG install-shape proof, Godot 3.6.2 project-load revalidation, a headless Godot `ReleaseInstaller.install_release()` pass, a full-scene Godot Install-button signal pass, a physical clicked GUI install pass against the selected cached macOS DMG, backend triad, first C-AOL mod compatibility inventory, per-mod C-AOL summarizer bridge report, read-only Settings status surfacing for that report, local Godot export-pack plus unsigned app/executable/package release-prep proof, and read-only C-AOL macOS launch preflight/status are complete as of 2026-04-25. The C-AOL game-launch smoke from an isolated installed app bundle remains blocked by the selected upstream C-AOL macOS app binary linking unbundled `/opt/local/lib/libfreetype.6.dylib` and `/opt/local/lib/libz.1.dylib`. Do not sign/notarize, publish, solve full OpenVINO automation, patch upstream packaging, apply generated summary packs, or curate C-AOL mod downloads in this lane without fresh clearance.

Product north star: `doc/lacapult-one-shot-installer-vision.md`. Use it for detail, but do not skip the proof order. Lacapult's own cross-platform installability is part of the product bar: Windows/macOS/Linux users should be able to install/open the launcher without developer tooling. Keep that evidence separate from C-AOL game-package launchability.

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

4. LLM backend setup options — three visible choices, v0-honest capability
   - [x] Add API as a selectable setup/config path without exposing secrets.
   - [x] Add Ollama as a selectable setup/config path with local command/server detection where safe.
   - [x] Expose API, Ollama, and OpenVINO in the existing Settings-tab backend selector without scene-node surgery.
   - [x] Record preview-only C-AOL option patch names for API/Ollama (`LLM_INTENT_*`) without mutating installed game config.
   - [x] Make OpenVINO selection save/report an honest v0 placeholder/detection/status artifact instead of acting like a dead parked row.
   - [x] Revalidate the selector/status/save behavior for all three backend choices with a headless Godot backend-triad smoke.

5. Modding compatibility investigation — active follow-up
   - [x] Preserve inherited mod/soundpack/tileset support.
   - [x] Identify inherited mod metadata/compatibility entry points.
   - [x] Write the first compatibility-summary direction for C-AOL mods and future NPC/LLM summaries.
   - [x] Inventory inherited mod/soundpack/tileset source assumptions against a C-AOL `v0.2.0` install tree.
   - [x] Mark what is supported, untested, broken, or unknown for C-AOL instead of treating inherited support as automatically true.
   - [x] Record the next smallest proof for C-AOL mod compatibility and future NPC/LLM summary metadata.
   - [x] Emit a per-mod packaged C-AOL `v0.2.0` compatibility/summarizer bridge report that reuses C-AOL active-mod summary roots instead of inventing a Lacapult-only format.
   - [x] Surface the packaged-mod compatibility/summarizer bridge report as read-only Settings status with counts, report reference, native summary-root language, and an explicit no-apply/no-enable boundary.

6. Minimal validation
   - Prove release JSON parsing selects correct platform asset(s) from live C-AOL v0.2.0 releases.
   - Prove backend config/detection paths at static or safe local-detection level.
   - Prove Lacapult backend option names against local C-AOL `src/options.cpp` without secrets or installed-game mutation.
   - Run the smallest Godot/static check available on this machine.
   - If full GUI launch is possible, smoke launch to the release list; otherwise record the exact missing tool/blocker.

7. Park next slices
   - [x] Local Godot export-pack/PCK proof and real unsigned app/executable/package proof for macOS/Linux/Windows using temporary safe presets, installed Godot 3.6.2 templates, ignored `.proof-cache/` outputs, and `export_presets.cfg` restoration.
   - [ ] Signed/notarized/public Lacapult release publication and normal-player install QA remain separate release decisions.
   - [x] C-AOL game-launch smoke from an isolated installed app bundle attempted; sandbox install still succeeds, but actual game startup aborts before running because the selected macOS binary depends on unbundled `/opt/local/lib/libfreetype.6.dylib` and `/opt/local/lib/libz.1.dylib`.
   - [x] Launcher-side read-only C-AOL macOS launch preflight/status added; it distinguishes successful Lacapult install/app-bundle presence from missing non-portable upstream dylib dependencies and blocks Play/Resume with an explanatory status instead of launching into an abort.
   - OpenVINO full setup/installer automation beyond selectable v0 status metadata.
   - Real model install/model-pull automation.
   - C-AOL-specific mod/soundpack/tileset recommendation packs.
   - Generated summary-pack install/apply flow after the read-only report status surface.
   - NPC/LLM runtime integration of mod summaries.
   - Public GitHub push/release publication, only after explicit clearance.
