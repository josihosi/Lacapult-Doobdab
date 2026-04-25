# SUCCESS

Success-state ledger for Lacapult Doobdab.

## Lacapult Doobdab v0.2.0 release installer plus first backend setup options

Status: **CLICKED INSTALL + BACKEND TRIAD V0-SAFE CONFIG/READINESS + SANDBOX OPTIONS APPLY PROVEN + MOD UI STATUS + LOCAL UNSIGNED APP/PACKAGE EXPORTS PROVEN + LAUNCH PREFLIGHT STATUS PROVEN / GAME-LAUNCH BLOCKED ON C-AOL DYLIBS / SIGNING+PUBLIC RELEASE NOT CLAIMED**

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
- [x] OpenVINO selection saves/reports honest v0 Windows-first Python-import/model-dir/device detection/config metadata without pretending runtime install/download/live inference exists.
- [x] Sandboxed C-AOL `config/options.json` apply proof verifies API, Ollama, and OpenVINO option patches without mutating Josef's real C-AOL Application Support config.
- [x] Inherited mod/soundpack/tileset support is preserved or any temporary breakage is documented.
- [x] First C-AOL mod compatibility / future NPC-summary investigation note exists.
- [x] C-AOL mod compatibility investigation records inherited source assumptions and marks first useful compatibility statuses as supported, untested, broken, or unknown.
- [x] Per-mod packaged C-AOL `v0.2.0` compatibility/summarizer bridge report exists, classifies obsolete blockers vs supported packaged mods, and points future summary packs at C-AOL `Summaries_short` / `Summaries_extra` roots.
- [x] Settings tab surfaces that report as read-only status with packaged-mod counts, blocker/status distinctions, full report reference/regeneration path, C-AOL `npcs/Backgrounds/Summaries_short` / `Summaries_extra` language, and an explicit no-generated-pack-apply boundary.
- [x] Launcher-side C-AOL macOS launch preflight/status checks the active app-bundle launch binary with `otool -L`, reports missing non-portable local dylibs (`/opt/local/lib/libfreetype.6.dylib`, `/opt/local/lib/libz.1.dylib`) as a C-AOL package portability issue, and does not imply Lacapult can repair the package.
- [x] Validation evidence is recorded in `TESTING.md`.
- [x] Godot 3.6.2 GUI smoke proves the project launches, the Game tab prioritizes the C-AOL `v0.2.0` macOS DMG, and the Settings tab exposes backend setup controls.
- [x] Public repo existence is recorded (`https://github.com/josihosi/Lacapult-Doobdab`), and public releases/contact remain blocked without fresh Josef/Schani clearance.
- [x] Lacapult itself has local unsigned app/executable/package evidence for Windows, macOS, and Linux; developer-only Godot project launch or raw PCK export is not the final bar.

## Parked next slices

These are not part of v0 unless Josef/Schani explicitly reopens them:

- [ ] OpenVINO full setup path beyond v0-safe detection/config/status metadata.
- [ ] Large model download/model-pull automation.
- [ ] API-key/backend live smoke test requiring real secrets.
- [ ] C-AOL-specific mod/soundpack/tileset recommendation packs.
- [ ] Feature-complete mod install/enable plus Summarizer UX; after mod install/enable, Lacapult should offer a Summarizer button/pop-up, show whether extra NPC/content summaries exist, handle generation/apply status, and write C-AOL-native `Summaries_short` / `Summaries_extra` data through a sandbox-proven flow. The current Settings surface is read-only and does not apply packs or enable mods.
- [ ] NPC/LLM runtime consumption of mod compatibility summaries.
- [x] Controlled selected macOS DMG download/mount/launchability-shape proof, without launching or installing the game.
- [x] Sandboxed Lacapult-style macOS DMG copy/move install-shape proof, without touching the real Application Support install state or launching the game.
- [x] Headless Godot `ReleaseInstaller.install_release()` pass for the selected cached macOS DMG inside an isolated HOME, without touching the real Application Support install state or launching the game.
- [x] Full-scene Godot Install-button signal pass for the selected cached macOS DMG inside an isolated HOME, without touching the real Application Support install state or launching the game.
- [x] Physical clicked GUI macOS DMG extraction/install pass, without launching the game.
- [x] Local Godot export-pack/PCK release-prep proof for macOS/Linux/Windows into ignored `.proof-cache/`, with `export_presets.cfg` restored afterward.
- [x] Local unsigned Lacapult app/executable/package export proof for macOS/Linux/Windows into ignored `.proof-cache/`, with app/package shape checks, sizes, hashes, and `export_presets.cfg` restored afterward.
- [ ] C-AOL game-launch smoke from an isolated installed app bundle reaches a running game process. Current proof is attempted but blocked by unbundled upstream macOS dylib dependencies (`/opt/local/lib/libfreetype.6.dylib`, `/opt/local/lib/libz.1.dylib`) in the selected C-AOL `v0.2.0` DMG.
- [x] Full local unsigned app exports / package-shaped Lacapult distribution artifacts for Windows/Linux/macOS; no binaries committed.
- [ ] Signed/notarized/public Lacapult release publication and normal-player install QA.
