# TODO

Short execution queue only.

## Now

Active target: `Lacapult launcher test/prerelease for Josef Windows laptop; C-AOL v0.3 parked`.

Current checkpoint: the v0.2.0 release installer, clicked install proof, backend triad readiness/config/apply proof, read-only packaged-mod bridge status, local unsigned export proof, macOS launch preflight proof, Lacapult-side macOS dylib repair/launch proof, Slice 1 C-AOL mod/Summarizer discovery/status model proof, Slice 2 UX dry-run status, Slice 3 sandbox summary-pack apply/rollback proof, Slice 4 deterministic C-AOL runtime-harness prompt-consumption proof, Slice 5 error/rollback matrix proof, and click-level GUI audit are complete as of 2026-04-26. The selected upstream C-AOL macOS `v0.2.0` app still ships with non-portable `/opt/local` dylib paths, but Lacapult now repairs the installed app locally by bundling universal repair dylibs, rewriting load paths to app-relative/system paths, ad-hoc signing the changed app pieces, and proving isolated launch smoke. This is the Lacapult installer/test lane; a new notarized C-AOL DMG or future C-AOL `v0.3.0` release shape remains parked/unknown and must not block v0.2.0 installer progress. The backend recommendation/setup lane is closed for Josef pre-release confidence: Settings presents API as the fastest onboarding/debug path, Ollama as the mainstream local path, and OpenVINO as the Windows-first specialized/detect-only path before exposing real Summarizer generation/apply UI. The mod/Summarizer implementation plan remains `doc/lacapult-mod-summarizer-feature-plan-2026-04-25.md`, with real generation/apply UI intentionally deferred until backend choice/readiness is less hollow. Fresh clearance now exists for a Lacapult launcher test/prerelease so Josef can download the Windows package and test it. That clearance does **not** include a new C-AOL release, C-AOL `v0.3.0`, signing/notarization, full OpenVINO automation, upstream packaging changes, real user-data summary-pack mutation, or curated C-AOL mod downloads.

Product north star: `doc/lacapult-one-shot-installer-vision.md`. Use it for detail, but do not skip the proof order. Lacapult's own cross-platform installability is part of the product bar: Windows/macOS/Linux users should be able to install/open the launcher without developer tooling. Keep that evidence separate from C-AOL game-package launchability.

0. Lacapult launcher test/prerelease — active now
   - [ ] Regenerate fresh Lacapult package artifacts from current `main` with `python3 tools/prove_lacapult_export_packaging.py`; do not reuse stale packages from before `7ba1043`/`4d7198e`.
   - [ ] Create a Lacapult-specific GitHub test/prerelease, preferably tag `lacapult-test-2026-04-26`, with at least the Windows unsigned zip attached and SHA-256 recorded.
   - [ ] Include release notes/instructions that say this is an unsigned Lacapult launcher test build for Josef Windows testing, not a new C-AOL game release and not C-AOL `v0.3.0`.
   - [ ] Verify the remote release/assets with `gh release view` and record URL, artifact names, sizes, and hashes in `TESTING.md`.

0. Backend recommendation/setup lane — closed for Windows test
   - [x] Turn backend setup into a player-facing recommendation path: API = fastest onboarding/debug, Ollama = mainstream local, OpenVINO = Windows-first specialized/detect-only.
   - [x] Add/verify Windows-focused wording and smoke coverage for the selected recommendation path before Josef laptop testing.
   - [x] Keep real Summarizer generation/apply UI disabled or dry-run/status-only until backend recommendation/readiness is good enough.

1. Mod install/enable + Summarizer implemented slices
   - [x] Implement Slice 1 from `doc/lacapult-mod-summarizer-feature-plan-2026-04-25.md`: discovery/status model for stock packaged, user-installed, custom-catalog, and world-specific mods, with enabled/disabled state for at least one sandbox world.
   - [x] Implement Slice 2: visible Mods/Settings UX status plus post-install Summarizer prompt and persistent dry-run/status buttons; true post-enable hook remains dependent on a later real enable/apply flow.
   - [x] Implement Slice 3: sandboxed C-AOL-native companion summary-pack generation/apply proof with manifest, backup, and rollback.
   - [x] Implement Slice 4: C-AOL sandbox/harness proof that an active generated summary root is consumed by runtime prompt construction, or record the exact C-AOL-side blocker.
   - [x] Implement Slice 5: fixture coverage for obsolete mods, parse errors, missing dependencies, partial summaries, stale summaries, conflicts, backend-not-ready, and rollback failure handling.

2. Confirm source/import state
   - Verify this repo is local-only and has no inherited `.git` history from Dabdoob.
   - Commit the imported source plus canon docs once attribution files are present.

3. Public identity and attribution cleanup
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
   - [x] Add the explicit player-facing recommendation order: API first for Windows pre-release onboarding/debug, Ollama second for mainstream local, OpenVINO third as Windows-first specialized/detect-only.

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
   - [x] C-AOL game-launch smoke from an isolated installed app bundle first reproduced the upstream macOS package abort on unbundled `/opt/local/lib/libfreetype.6.dylib` and `/opt/local/lib/libz.1.dylib`.
   - [x] Launcher-side C-AOL macOS repair path added; it distinguishes successful Lacapult install/app-bundle presence from non-portable upstream dylib dependencies, bundles universal repair dylibs, rewrites load paths, ad-hoc signs the changed app pieces, verifies no package-manager paths remain, and proves isolated launch smoke.
   - OpenVINO guided setup/installer automation beyond v0-safe detection/config/status metadata. Future direction may offer an explicit-approval fixed package list such as `openvino`, `openvino-genai`, and `openvino-tokenizers` plus model-dir setup, but no installs/downloads are implemented in the current slice.
   - Real model install/model-pull automation and deeper Ollama model recommendation UX. Future direction should account for local model inventory/recommendations, but this Windows-test closure does not recommend/pull/download models.
   - C-AOL-specific mod/soundpack/tileset recommendation packs.
   - [active next] Feature-complete mod install/enable plus Summarizer UX after the read-only report/status-only dry-run surface: sandbox-proven C-AOL-native `Summaries_extra` companion-pack application, backup, rollback, and status-model visibility are now proven; real user apply UI and broader error handling remain later.
   - [x] NPC/LLM runtime integration proof that active mod summaries are consumed by C-AOL is landed, with schema/runtime behavior kept on the C-AOL side and Lacapult acting as UX/status/apply helper.
   - Public GitHub push/release publication, only after explicit clearance.
