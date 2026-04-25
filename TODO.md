# TODO

Short execution queue only.

## Now

Active target: `Feature-complete C-AOL mod install/enable plus Summarizer UX/status/apply`.

Current checkpoint: the v0.2.0 release installer, clicked install proof, backend triad readiness/config/apply proof, read-only packaged-mod bridge status, local unsigned export proof, macOS launch preflight proof, Slice 1 C-AOL mod/Summarizer discovery/status model proof, Slice 2 UX dry-run status, and Slice 3 sandbox summary-pack apply/rollback proof are complete as of 2026-04-25. The C-AOL game-launch smoke from an isolated installed app bundle remains blocked by the selected upstream C-AOL macOS app binary linking unbundled `/opt/local/lib/libfreetype.6.dylib` and `/opt/local/lib/libz.1.dylib`; that stays a C-AOL packaging lane, not this mod/summarizer lane. The active next-lane plan is `doc/lacapult-mod-summarizer-feature-plan-2026-04-25.md`. Do not sign/notarize, publish, solve full OpenVINO automation, patch upstream packaging, apply generated summary packs to real user data, or curate C-AOL mod downloads in this lane without fresh clearance.

Product north star: `doc/lacapult-one-shot-installer-vision.md`. Use it for detail, but do not skip the proof order. Lacapult's own cross-platform installability is part of the product bar: Windows/macOS/Linux users should be able to install/open the launcher without developer tooling. Keep that evidence separate from C-AOL game-package launchability.

0. Mod install/enable + Summarizer active next lane
   - [x] Implement Slice 1 from `doc/lacapult-mod-summarizer-feature-plan-2026-04-25.md`: discovery/status model for stock packaged, user-installed, custom-catalog, and world-specific mods, with enabled/disabled state for at least one sandbox world.
   - [x] Implement Slice 2: visible Mods/Settings UX status plus post-install Summarizer prompt and persistent dry-run/status buttons; true post-enable hook remains dependent on a later real enable/apply flow.
   - [x] Implement Slice 3: sandboxed C-AOL-native companion summary-pack generation/apply proof with manifest, backup, and rollback.
   - [ ] Implement Slice 4: C-AOL sandbox/harness proof that an active generated summary root is consumed by runtime prompt construction, or record the exact C-AOL-side blocker.
   - [ ] Implement Slice 5: fixture coverage for obsolete mods, parse errors, missing dependencies, partial summaries, stale summaries, conflicts, backend-not-ready, and rollback failure handling.

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
   - [x] Record preview-only C-AOL option patch names for API/Ollama/OpenVINO (`LLM_INTENT_*`) without mutating installed game config.
   - [x] Make OpenVINO selection save/report honest v0 detection/config/status metadata instead of acting like a dead parked row.
   - [x] Surface the shared `LLM_INTENT_PYTHON` runner path honestly as Python/venv for every backend, not just as an OpenVINO wording accident.
   - [x] Add safe readiness checks for API/AnyLLM Python imports, Ollama command/server/model-list state, and Windows-first OpenVINO Python imports/model-dir presence.
   - [x] Prove sandboxed C-AOL `config/options.json` apply output for API, Ollama, and OpenVINO without touching Josef's real Application Support config.
   - [x] Revalidate the selector/status/save/apply-proof behavior for all three backend choices with a headless Godot backend-triad smoke.

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
   - OpenVINO guided setup/installer automation beyond v0-safe detection/config/status metadata. Future direction may offer an explicit-approval fixed package list such as `openvino`, `openvino-genai`, and `openvino-tokenizers` plus model-dir setup, but no installs/downloads are implemented in the current slice.
   - Real model install/model-pull automation and Ollama recommendation UX. Future direction should account for local model inventory/recommendations, but Slice 1 only preserves status-model compatibility and does not recommend or pull models.
   - C-AOL-specific mod/soundpack/tileset recommendation packs.
   - [active above] Feature-complete mod install/enable plus Summarizer UX after the read-only report/status-only dry-run surface: sandbox-proven C-AOL-native `Summaries_extra` companion-pack application, backup, rollback, and status-model visibility are now proven; real user apply UI and broader error handling remain later.
   - [active above] NPC/LLM runtime integration proof that active mod summaries are consumed by C-AOL is the next bounded slice, with schema/runtime behavior kept on the C-AOL side and Lacapult acting as UX/status/apply helper.
   - Public GitHub push/release publication, only after explicit clearance.
