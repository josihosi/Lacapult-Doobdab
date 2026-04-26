# SUCCESS

Success-state ledger for Lacapult Doobdab.


## Lacapult LLM backend setup installer packet v0

Status: **IMPLEMENTED / SAFE STATIC+GODOT PROOF PASSED / READY FOR SCHANI REVIEW**

Done only when all are true:

- [x] Backend setup has its own visible tab/page titled exactly `C-AOL LLM backend setup`.
- [x] Player-facing backend copy is neutral and no longer mentions Josef, Windows test positioning, or raw internal/debug status wording where a normal installer sentence belongs.
- [x] API/AnyLLM, Ollama, and OpenVINO each expose a guided setup/install pathway with explicit confirmation before external changes.
- [x] Ollama setup offers `mistral-v0.3` and `nemotron-9b` choices, with hardware-based recommendation and manual override.
- [x] Installer-path tests prove package/model install actions are gated, mocked, or sandboxed and do not mutate Josef's real machine.
- [x] Inherited About/thank-you personal support message is preserved, while backend/setup installer copy is cleaned so no Josef/test-run wording leaks into normal setup surfaces.
- [x] A GUI reasoning roleplay from a Reddit C:DDA aficionado installing C-AOL has been run, and its findings are reflected in UI/copy/proof expectations.

Canonical contract: `doc/lacapult-llm-backend-setup-installer-packet-v0-2026-04-26.md`.

## Evidence - 2026-04-26 LLM backend setup installer packet v0

- Backend setup is a standalone tab/page named exactly `C-AOL LLM backend setup` in `scenes/Catapult.tscn`, wired through `scripts/BackendSetupUI.gd`, with the old Settings-tab backend construction removed.
- Player-facing backend/setup copy is neutral for anonymous C-AOL players; proof scans backend setup surfaces for `Josef`, `Windows test`, `pre-release testing`, and `Windows-first` leakage.
- API/AnyLLM, Ollama, and OpenVINO each expose guided setup paths with `ConfirmExternalBackendAction`; confirmation records intent only and explicitly performs no package install, model pull, API call, or real machine mutation.
- Ollama setup offers `mistral-v0.3` and `nemotron-9b`; fixture hardware recommendations steer low/unknown hardware toward `mistral-v0.3`, allow/recommend `nemotron-9b` on stronger memory, and leave the final choice to the player.
- Required outsider roleplay artifact exists at `doc/lacapult-gui-reasoning-reddit-cdda-install-run-2026-04-26.md`; it treats unexplained Josef/test-run wording as internal scaffolding leakage unless kept in credits/history.
- Validation passed: `python3 tools/prove_backend_setup_installer_packet.py`, `python3 tools/prove_caol_backend_contract.py`, `/opt/homebrew/bin/godot --path . --no-window --script tools/godot_backend_triad_smoke.gd`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`. Godot emitted known macOS/no-window cleanup warnings but exited 0.

## Lacapult Doobdab v0.2.0 release installer plus first backend setup options

Status: **LACAPULT LAUNCHER HOTFIX PRERELEASE PUBLISHED / WINDOWS 7ZA PACKAGE BLOCKER FIXED / C-AOL v0.2.0 INSTALL+LAUNCH REPAIR PROVEN / C-AOL v0.3 PARKED / FINAL SIGNED PUBLIC RELEASE NOT CLAIMED**

Done only when all are true:

- [x] Local standalone repo exists at `/Users/josefhorvath/Schanigarten/Lacapult-Doobdab` with no inherited Dabdoob `.git` history.
- [x] Original MIT license notice is preserved.
- [x] `ATTRIBUTION.md` credits qrrk/Catapult, Hihahahalol/Dabdoob, CDDA, CTLG, BN if still inherited/mentioned, and C-AOL.
- [x] README presents Lacapult Doobdab as C-AOL-specific and clearly derived from Dabdoob/Catapult.
- [x] Godot project/window identity says Lacapult Doobdab.
- [x] Self-update check no longer points at `Hihahahalol/Catapult_Dabdoob` unless explicitly shown as upstream credit, not update source.
- [x] Settings default to C-AOL (`caol`) and the visible game selection is C-AOL-only or hidden.
- [x] Release manager fetches from `https://api.github.com/repos/josihosi/Cataclysm-AOL/releases`.
- [x] Platform filters select current C-AOL `v0.2.0` release assets for Linux (`_linux.tar.gz`), macOS (`_macos.dmg`), and Windows (`_windows.zip`).
- [x] Installer receives valid metadata (`name`, `url`, `filename`, `published_at`, `has_any_assets`) for at least one real C-AOL `v0.2.0` release asset.
- [x] Launch/install paths know plausible C-AOL executable names for the current platform.
- [x] API backend appears as a first supported setup/config option without leaking secrets; Lacapult stores provider/model/API-key env-var names only.
- [x] API readiness checks the configured/default Python path for `any_llm` importability without making remote calls or reading API secrets.
- [x] Ollama backend appears as a first supported setup/config option with safe command/server/model-list detection and no model pulls.
- [x] Backend setup has a visible Settings-tab selector/status/save path, including the shared C-AOL Python/venv runner path.
- [x] API, Ollama, and OpenVINO are visible as backend choices.
- [x] Backend setup presents a player-facing recommendation order: API first for fastest Windows onboarding/debug, Ollama second as mainstream local setup, OpenVINO third as Windows-first specialized/detect-only.
- [x] OpenVINO selection saves/reports honest v0 Windows-first Python-import/model-dir/device detection/config metadata without pretending runtime install/download/live inference exists.
- [x] Sandboxed C-AOL `config/options.json` apply proof verifies API, Ollama, and OpenVINO option patches without mutating Josef's real C-AOL Application Support config.
- [x] Inherited mod/soundpack/tileset support is preserved or any temporary breakage is documented.
- [x] First C-AOL mod compatibility / future NPC-summary investigation note exists.
- [x] C-AOL mod compatibility investigation records inherited source assumptions and marks first useful compatibility statuses as supported, untested, broken, or unknown.
- [x] Per-mod packaged C-AOL `v0.2.0` compatibility/summarizer bridge report exists, classifies obsolete blockers vs supported packaged mods, and points future summary packs at C-AOL `Summaries_short` / `Summaries_extra` roots.
- [x] Settings tab surfaces that report as read-only status with packaged-mod counts, blocker/status distinctions, full report reference/regeneration path, C-AOL `npcs/Backgrounds/Summaries_short` / `Summaries_extra` language, and an explicit no-generated-pack-apply boundary.
- [x] Launcher-side C-AOL macOS launch preflight/status checks the active app-bundle launch binary with `otool -L`, reports missing non-portable local dylibs (`/opt/local/lib/libfreetype.6.dylib`, `/opt/local/lib/libz.1.dylib`), and now repairs the installed app by bundling universal repair dylibs, rewriting load paths, and ad-hoc signing the changed bundle pieces before launch.
- [x] Validation evidence is recorded in `TESTING.md`.
- [x] Godot 3.6.2 GUI smoke proves the project launches, the Game tab prioritizes the C-AOL `v0.2.0` macOS DMG, and the Settings tab exposes backend setup controls.
- [x] Public repo existence is recorded (`https://github.com/josihosi/Lacapult-Doobdab`), and public releases/contact remain blocked without fresh Josef/Schani clearance.
- [x] Lacapult itself has local unsigned app/executable/package evidence for Windows, macOS, and Linux; developer-only Godot project launch or raw PCK export is not the final bar.
- [x] Click-level GUI audit doc exists at `doc/lacapult-click-level-gui-audit-2026-04-25.md`; binary verdict is `ready-for-Josef-Windows-test`, not public release.
- [x] Isolated macOS launch smoke with repair proves the selected C-AOL `v0.2.0` app no longer aborts on `/opt/local` dylib paths after Lacapult repair; the repaired app stays running past the smoke observation window, with no package-manager paths left in the checked load graph.
- [x] C-AOL release/changelog link no longer opens an inherited empty changelog path; for C-AOL it opens the selected/fallback GitHub release page.
- [x] Fresh no-install state does not display a checked `Update current active install` checkbox, and unavailable Lacapult self-update is labeled as unavailable instead of implying a working update action.
- [x] Fresh Lacapult launcher packages are regenerated from current `main` after the macOS launch repair/canon commits.
- [x] A Lacapult-specific GitHub test/prerelease exists with at least a Windows downloadable package for Josef.
- [x] Release notes, tag, and asset names clearly distinguish Lacapult launcher test build from C-AOL game releases and C-AOL `v0.3.0`.
- [x] SHA-256 hashes, asset sizes, and remote release URL are recorded in `TESTING.md`.

## Feature-complete C-AOL mod install/enable plus Summarizer UX/status/apply

Status: **SLICE 1 DISCOVERY/STATUS MODEL PROVEN + SLICE 2 UX/DRY-RUN STATUS SURFACE PROVEN + SLICE 3 SANDBOX SUMMARY-PACK APPLY/ROLLBACK PROVEN + SLICE 4 RUNTIME-HARNESS CONSUMPTION PROVEN + SLICE 5 ERROR/ROLLBACK MATRIX PROVEN / REAL GENERATION UI NOT IMPLEMENTED**

Done only when all are true:

- [x] Mod discovery distinguishes stock packaged, user-installed, custom-catalog, and world-specific mods for C-AOL in the Slice 1 read-only status model/proof.
- [x] Enabled vs disabled status is world-aware for at least one sandbox world in the Slice 1 fixture proof.
- [x] Obsolete mods, broken metadata, content parse errors, missing roots, missing dependencies, partial summaries, stale summaries, conflicts, backend-not-ready gates, and disabled mods produce visible statuses in the sandbox status/error matrix.
- [x] After mod install, and from persistent Mods/Settings status surfaces, Lacapult offers a Summarizer prompt/button rather than burying the next action, currently dry-run/status-only.
- [ ] A true post-enable hook is still pending because the current inherited launcher does not yet apply C-AOL world `mods.json` enable changes.
- [x] The launcher shows whether all enabled extra NPC/content is summarized, blocked, needs summaries, or unknown.
- [ ] API, Ollama, and OpenVINO generation readiness is gated through the backend-good checks for real generation/apply; current Slice 2 dry-run only reports selected backend status and performs no API calls/model pulls/downloads.
- [x] A sandbox fixture generated pack is C-AOL-native under `npcs/Backgrounds/Summaries_extra`, not launcher-only metadata.
- [x] Applying a generated companion summary pack and changing a world `mods.json` list is sandbox-proven with backup and rollback.
- [x] C-AOL runtime consumption is proven in a sandbox/harness, or a concrete C-AOL-side blocker is recorded.
- [x] Slice 1, Slice 2, Slice 3, Slice 4, and Slice 5 proof scripts do not mutate Josef's real Application Support config, saves, worlds, or mods; future real apply/generation UI must keep the same boundary until explicitly approved.

## Parked next slices

These are not part of v0 unless Josef/Schani explicitly reopens them:

- [ ] OpenVINO guided setup path beyond v0-safe detection/config/status metadata; future direction may use explicit user approval, a fixed package list, and model-dir setup, but no installs/downloads are implemented yet.
- [ ] Large model download/model-pull automation or Ollama model recommendation UX. Local model inventory can inform a future backend recommendation lane, but nothing in Slice 1 pulls or recommends models yet.
- [ ] API-key/backend live smoke test requiring real secrets.
- [ ] C-AOL-specific mod/soundpack/tileset recommendation packs.
- [active above] Feature-complete mod install/enable plus Summarizer UX; the current Mods/Settings surfaces show read-only status and dry-run Summarizer prompts, sandbox C-AOL-native `Summaries_extra` companion-pack apply/rollback is proven, and deterministic C-AOL harness prompt consumption is proven. The current surface still does not call a backend, apply packs, or enable mods from the UI.
- [x] Slice 5 fixture/error coverage for obsolete mods, parse errors, missing dependencies, partial/stale summaries, conflicts, backend-not-ready, and rollback-restores-replacement handling is landed as a sandbox-only proof.
- [x] Controlled selected macOS DMG download/mount/launchability-shape proof, without launching or installing the game.
- [x] Sandboxed Lacapult-style macOS DMG copy/move install-shape proof, without touching the real Application Support install state or launching the game.
- [x] Headless Godot `ReleaseInstaller.install_release()` pass for the selected cached macOS DMG inside an isolated HOME, without touching the real Application Support install state or launching the game.
- [x] Full-scene Godot Install-button signal pass for the selected cached macOS DMG inside an isolated HOME, without touching the real Application Support install state or launching the game.
- [x] Physical clicked GUI macOS DMG extraction/install pass, without launching the game.
- [x] Local Godot export-pack/PCK release-prep proof for macOS/Linux/Windows into ignored `.proof-cache/`, with `export_presets.cfg` restored afterward.
- [x] Local unsigned Lacapult app/executable/package export proof for macOS/Linux/Windows into ignored `.proof-cache/`, with app/package shape checks, sizes, hashes, and `export_presets.cfg` restored afterward.
- [x] C-AOL game-launch smoke from an isolated installed app bundle reaches a running process after Lacapult repairs the selected C-AOL `v0.2.0` app's non-portable `/opt/local` dylib paths.
- [x] Full local unsigned app exports / package-shaped Lacapult distribution artifacts for Windows/Linux/macOS; no binaries committed.
- [ ] Signed/notarized/public Lacapult release publication and normal-player install QA.

## Evidence - 2026-04-26 Lacapult launcher test/prerelease

- Published original prerelease `lacapult-test-2026-04-26`: https://github.com/josihosi/Lacapult-Doobdab/releases/tag/lacapult-test-2026-04-26
- Published hotfix prerelease `lacapult-test-2026-04-26-2`: https://github.com/josihosi/Lacapult-Doobdab/releases/tag/lacapult-test-2026-04-26-2
- Uploaded fresh unsigned launcher package assets from the 2026-04-26 package proof:
  - `Lacapult-Doobdab-windows-unsigned.zip` — 66,426,171 bytes — SHA-256 `22617e7b195cc0e26f82354b6634f41feffb54d50bc749eb895aed83085eda21` — includes `utils/7za.exe` sidecar
  - `Lacapult-Doobdab-macos-unsigned.zip` — 90,238,414 bytes — SHA-256 `53b3aade2655c7a4b2290060664a62ff79a2b8f37be35ed2eb4cd01132f9881b`
  - `Lacapult-Doobdab-linux-unsigned.tar.gz` — 37,458,834 bytes — SHA-256 `d2b76a829218a976dd5f320f7fb94f29089db1c8fdaf5882c0ee13c6e7ee26f7` — includes `utils/7za` sidecar
  - `SHA256SUMS.txt` — 311 bytes — SHA-256 `853d8273a3ecc67896721d98deba6cf99f9ec8f1975aeb15ba7c028b1e227b77`
- Re-ran package/release/backend/project-load gates and `git diff --check`; all passed.
- Caveat remains intentionally open: this is unsigned/not notarized/not SmartScreen-trusted and needs Josef's real Windows laptop click-through/playtest before claiming final public confidence.

## Evidence - 2026-04-25 click-level GUI audit

- Added `doc/lacapult-click-level-gui-audit-2026-04-25.md` with persona click maps for fresh Windows, macOS/Linux, backend setup, mod/Summarizer, returning-user, and failure-user paths.
- Patched the C-AOL changelog/release link so C-AOL opens the selected/fallback GitHub release page instead of the inherited changelog dialog.
- Patched `project.godot` debug/test window dimensions from 1x1 to 600x700 so GUI QA/debug launches are not hidden in a postage stamp.
- Patched fresh no-install/update-current and unavailable self-update labels so the Game tab no longer offers impossible-looking update actions.
- Added Settings-tab backend recommendation copy and smoke coverage: API fastest onboarding/debug, Ollama mainstream local, OpenVINO Windows-first specialized/detect-only.
- Audit verdict: ready for a Josef Windows pre-release test, not ready for public release; real Summarizer generation/apply UI remains deferred behind backend readiness.
- Re-ran Godot project load, backend triad smoke, C-AOL mod status/UX smokes, related Python compile, and `git diff --check`; all passed. Combined log: `.proof-cache/click-gui-audit/gates-rerun.log`.
