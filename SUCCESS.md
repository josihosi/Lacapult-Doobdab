# SUCCESS

Success-state ledger for Lacapult Doobdab.

## Lacapult Doobdab v0.2.0 release installer plus first backend setup options

Status: **CLICKED INSTALL + BACKEND TRIAD + MOD INVENTORY PROVEN / AWAITING RELEASE-PREP DECISION**

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
- [x] API backend appears as a first supported setup/config option without leaking secrets.
- [x] Ollama backend appears as a first supported setup/config option with safe local detection or a recorded blocker.
- [x] Backend setup has a visible Settings-tab selector/status/save path.
- [x] API, Ollama, and OpenVINO are visible as backend choices.
- [x] OpenVINO selection saves/reports an honest v0 placeholder/detection/status artifact without pretending full setup exists.
- [x] Inherited mod/soundpack/tileset support is preserved or any temporary breakage is documented.
- [x] First C-AOL mod compatibility / future NPC-summary investigation note exists.
- [x] C-AOL mod compatibility investigation records inherited source assumptions and marks first useful compatibility statuses as supported, untested, broken, or unknown.
- [x] Validation evidence is recorded in `TESTING.md`.
- [x] Godot 3.6.2 GUI smoke proves the project launches, the Game tab prioritizes the C-AOL `v0.2.0` macOS DMG, and the Settings tab exposes backend setup controls.
- [x] Public repo existence is recorded (`https://github.com/josihosi/Lacapult-Doobdab`), and public releases/contact remain blocked without fresh Josef/Schani clearance.

## Parked next slices

These are not part of v0 unless Josef/Schani explicitly reopens them:

- [ ] OpenVINO full setup path beyond selectable v0 status metadata.
- [ ] Large model download/model-pull automation.
- [ ] API-key/backend live smoke test requiring real secrets.
- [ ] C-AOL-specific mod/soundpack/tileset recommendation packs.
- [ ] NPC/LLM runtime consumption of mod compatibility summaries.
- [x] Controlled selected macOS DMG download/mount/launchability-shape proof, without launching or installing the game.
- [x] Sandboxed Lacapult-style macOS DMG copy/move install-shape proof, without touching the real Application Support install state or launching the game.
- [x] Headless Godot `ReleaseInstaller.install_release()` pass for the selected cached macOS DMG inside an isolated HOME, without touching the real Application Support install state or launching the game.
- [x] Full-scene Godot Install-button signal pass for the selected cached macOS DMG inside an isolated HOME, without touching the real Application Support install state or launching the game.
- [x] Physical clicked GUI macOS DMG extraction/install pass, without launching the game.
- [ ] C-AOL game-launch smoke from an installed app bundle.
- [ ] Signed/packaged Lacapult releases for Windows/Linux/macOS.
