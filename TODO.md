# TODO

Short execution queue only.

## Now

Active target: `Lacapult 2026-04-26 release quarantine + identity investigation; C-AOL v0.3/signing/final public release parked`. The real C-AOL mod/Summarizer generation/apply UI v0 lane is implemented and proofed, but the 2026-04-26 Lacapult prerelease family is now Draft/quarantined after Josef reported the download as CAOL-looking/faulty rather than clearly Lacapult. Do not republish any Lacapult release from this family, start new C-AOL v0.3, signing/notarization, OpenVINO automation, or public-final release work unless Josef explicitly reprioritizes.

Current checkpoint: the v0.2.0 release installer, clicked install proof, backend triad readiness/config/apply proof, read-only packaged-mod bridge status, local unsigned export proof, macOS launch preflight proof, Lacapult-side macOS dylib repair/launch proof, Slice 1 C-AOL mod/Summarizer discovery/status model proof, Slice 2 UX dry-run status, Slice 3 sandbox summary-pack apply/rollback proof, Slice 4 deterministic C-AOL runtime-harness prompt-consumption proof, Slice 5 error/rollback matrix proof, click-level GUI audit, Lacapult GitHub test/prerelease, the first Slice 6 Settings apply-preview plan, the confirmed Slice 6 writer/apply seam, backend-generation/target-chooser/live-local-Ollama Slice 6 seams, the post-mod UI retestable-state package-shape proof, and the post-mod UI GitHub test/prerelease publication are complete as of 2026-04-26. The selected upstream C-AOL macOS `v0.2.0` app still ships with non-portable `/opt/local` dylib paths, but Lacapult now repairs the installed app locally by bundling universal repair dylibs, rewriting load paths to app-relative/system paths, ad-hoc signing the changed app pieces, and proving isolated launch smoke. This is the Lacapult installer/test lane; a new notarized C-AOL DMG or future C-AOL `v0.3.0` release shape remains parked/unknown and must not block v0.2.0 installer progress. The backend recommendation/setup lane is closed for Josef pre-release confidence: Settings presents API as the fastest onboarding/debug path, Ollama as the mainstream local path, and OpenVINO as the Windows-first specialized/detect-only path before exposing real Summarizer generation/apply UI. The mod/Summarizer implementation plan remains `doc/lacapult-mod-summarizer-feature-plan-2026-04-25.md`; the implementation slice is now closed at a Windows-retestable prerelease state, and the remaining confidence step is Josef's real Windows laptop click-through. The Lacapult launcher hotfix test/prerelease had been published for Josef's Windows test, fixing the missing Windows `utils/7za.exe` package blocker, curating the C-AOL install list to the four expected port releases, and replacing the startup lineage plaque with a simple Dabdoob/Catapult thank-you; it is now Draft/quarantined with the rest of the 2026-04-26 release family. The post-mod UI Windows retest prerelease was published from source commit `8c9d8f3`, with fresh unsigned Windows/macOS/Linux packages and the Windows `utils/7za.exe` sidecar preserved; it is also now Draft/quarantined after Josef's CAOL/Lacapult identity complaint. The backend setup installer packet in `doc/lacapult-llm-backend-setup-installer-packet-v0-2026-04-26.md` is implemented, proofed, and Schani-reviewed: backend setup has its own `C-AOL LLM backend setup` tab, neutral player-facing copy, confirmation-gated intent-only setup pathways for API/AnyLLM, Ollama, and OpenVINO, Ollama `mistral-v0.3` / `nemotron-9b` choices with safe recommendation text, and the required outsider GUI reasoning artifact. Those quarantined publications did **not** include a new C-AOL release, C-AOL `v0.3.0`, signing/notarization, full OpenVINO automation, upstream packaging changes, real user-data summary-pack mutation, or curated C-AOL mod downloads.

Product north star: `doc/lacapult-one-shot-installer-vision.md`. Use it for detail, but do not skip the proof order. Lacapult's own cross-platform installability is part of the product bar: Windows/macOS/Linux users should be able to install/open the launcher without developer tooling. Keep that evidence separate from C-AOL game-package launchability.

0. Lacapult LLM backend setup installer packet v0 — implemented / Schani-reviewed
   - [x] Move backend setup out of generic Settings into its own tab/page titled exactly `C-AOL LLM backend setup`.
   - [x] Rewrite backend setup copy so it is neutral player-facing C-AOL installer text: no Josef/test-run wording, no casual `Windows-first` recommendation copy, no raw debug/status-key clutter where prose belongs.
   - [x] Add guided installer pathways for API/AnyLLM, Ollama, and OpenVINO, with explicit confirmation before any external package/model install or download.
   - [x] Add Ollama model choices for `mistral-v0.3` and `nemotron-9b`, with safe hardware-based recommendation text and manual override rather than silent auto-pick.
   - [x] Leave the inherited About/thank-you depressed/anxious/loved-one support text in place; Josef explicitly okayed it. Still preserve attribution/license credit and keep backend/setup copy free of Josef/test-run leakage.
   - [x] Run a GUI reasoning roleplay from the perspective of a C:DDA aficionado who read about C-AOL on Reddit and wants to install/play it; use it to answer open installer flow/look/backend-choice/unexplained-name questions.
   - [x] Prove the tab/copy/install-confirmation/model-recommendation shape with safe static/Godot/fixture checks; do not mutate Josef's real machine in tests.

0. Lacapult launcher hotfix prerelease — quarantined after Josef identity complaint
   - [x] Regenerate fresh Lacapult package artifacts from current `main` with `python3 tools/prove_lacapult_export_packaging.py`; do not reuse stale packages from before `7ba1043`/`4d7198e`/`c7ccd26`.
   - [x] Create a Lacapult-specific GitHub test/prerelease, tag `lacapult-test-2026-04-26`, with the Windows unsigned zip attached and SHA-256 recorded.
   - [x] Republish hotfix prerelease `lacapult-test-2026-04-26-2` after Josef Windows testing found `utils/7za.exe` missing from the Windows package; fixed package includes sidecar `utils/7za.exe` and recorded SHA-256 `22617e7b195cc0e26f82354b6634f41feffb54d50bc749eb895aed83085eda21`.
   - [x] Curate the C-AOL release list to the four expected port rows (CDDA master, CTLG master, CDDA 0.H, CDDA 0.I) instead of showing plain `v0.2.0` as a fifth install option.
   - [x] Include release notes/instructions that say this is an unsigned Lacapult launcher test build for Josef Windows testing, not a new C-AOL game release and not C-AOL `v0.3.0`.
   - [x] Verify the remote release/assets with `gh release view` and record URL, artifact names, sizes, and hashes in `TESTING.md`.
   - [x] Draft/quarantine this prerelease with the rest of the 2026-04-26 release family after Josef's CAOL/Lacapult identity complaint.

0. Lacapult 2026-04-26 release quarantine + identity investigation — active
   - [x] Convert the 2026-04-26 Lacapult prerelease family to Draft/quarantine after Josef reported the download as faulty / CAOL-looking rather than clearly Lacapult: `lacapult-post-mod-ui-retest-2026-04-26`, `lacapult-test-2026-04-26-2`, and `lacapult-test-2026-04-26`.
   - [x] Verify public removal: authenticated release list shows all three as Draft, unauthenticated GitHub releases API returns zero public releases, and the latest old Windows asset URL returns `404`.
   - [x] Inspect the latest local Windows artifact shape: `Lacapult-Doobdab.exe` plus `utils/7-ZIP_LICENSE` / `utils/7za.exe`, with hash matching the remote digest.
   - [x] Record initial finding that the archive is not literally a full C-AOL game package, but the exported app is heavily C-AOL-facing by design and still carries inherited Catapult/Dabdoob naming.
   - [ ] Reproduce/inspect the exact Windows-facing symptom if possible: first launch, first visible tab, release-copy wording, and why the download reads as CAOL instead of Lacapult to Josef.
   - [ ] Decide the next identity/product correction packet before any republish.

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
   - [x] Add platform asset filters for C-AOL assets: `_linux.tar.gz`, `_macos.dmg`, `_windows.zip`, then curate visible install rows to the four C-AOL port release tags expected for the Lacapult test lane.
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
   - [x] Real C-AOL mod/Summarizer generation/apply UI v0: Settings apply-preview, confirmed writer/apply seam, first backend-generation seam, Settings target world/mod chooser error polish, optional live-local Ollama smoke, and retestable-state package-shape proof are landed and sandbox-smoked. The live smoke used already-local `mistral:latest` through Ollama HTTP and applied the generated entry through the same isolated companion-pack seam. The retestable-state proof regenerated local unsigned packages and confirmed the Windows zip still carries `utils/7za.exe`. Still no secrets, model pulls, package installs, remote APIs, real Application Support mutation, or GitHub release publication in automated proof.
   - [x] Lacapult post-mod UI Windows retest release packet: Josef greenlit the external publication, the GitHub test/prerelease was published, and it is now Draft/quarantined with the rest of the 2026-04-26 release family after Josef's CAOL/Lacapult identity complaint. Canonical release contract: `doc/lacapult-post-mod-ui-windows-retest-release-packet-2026-04-26.md`; incident note: `doc/lacapult-release-quarantine-investigation-2026-04-26.md`.
   - [x] NPC/LLM runtime integration proof that active mod summaries are consumed by C-AOL is landed, with schema/runtime behavior kept on the C-AOL side and Lacapult acting as UX/status/apply helper.
   - Public GitHub push/release publication, only after explicit clearance.
