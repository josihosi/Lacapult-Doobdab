# TechnicalTome

Durable technical notes for Lacapult Doobdab.

## Lineage

Lacapult Doobdab starts from `Hihahahalol/Catapult_Dabdoob`, which itself is based on qrrk's Catapult launcher.

License is MIT. Preserve upstream license text and attribution.

Public repo: `https://github.com/josihosi/Lacapult-Doobdab`. Public pushes, release publication, or upstream contact require fresh Schani/Josef clearance.

## Source shape

- Godot project: `project.godot`
- Main scene: `scenes/Catapult.tscn`
- Main script: `scripts/Catapult.gd`
- Release fetching: `scripts/ReleaseManager.gd`
- Release installation/extraction: `scripts/ReleaseInstaller.gd`
- Settings: `scripts/settings_manager.gd`
- Paths/install folders: `scripts/path_helper.gd`
- Mod support: `scripts/ModManager.gd` + `scripts/ModsUI.gd`
- Soundpack support: `scripts/SoundpackManager.gd` + `scripts/SoundpacksUI.gd`
- Tileset support: `scripts/TilesetManager.gd` + `scripts/TilesetsUI.gd`
- English translation CSVs live under `text/en/`

## Current Dabdoob release model

`ReleaseManager.gd` has:
- `_RELEASE_URLS` mapping game/channel keys to GitHub API URLs.
- `_ASSET_FILTERS` mapping `game-channel-platform` keys to substring filters.
- `releases` dictionary with arrays keyed by release channel.
- `fetch(release_key)` dispatch that calls per-game request functions.
- `_parse_builds()` creates installer metadata dictionaries:
  - `name`
  - `url`
  - `filename`
  - `published_at`
  - `has_any_assets`

This shape should be reused for C-AOL v0 instead of redesigning everything.

## C-AOL release source

Use GitHub releases from:

`https://api.github.com/repos/josihosi/Cataclysm-AOL/releases`

Expected current release asset naming from `v0.2.0`:
- Linux assets include `_linux.tar.gz`
- macOS assets include `_macos.dmg`
- Windows assets include `_windows.zip`

Do not hardcode only `v0.2.0`; fetch normal release list and filter each release by platform asset.

## C-AOL game key

Preferred internal game key: `caol`.

Preferred release key: `caol-release` or `caol-stable`; choose one and keep it consistent. Since C-AOL public releases are curated release pages rather than nightly experimentals, `caol-release` is clearer.

## v0 architecture advice

Do not delete all inherited multi-game code immediately. For first slice:
- set defaults to C-AOL
- hide/limit UI to one game
- wire C-AOL release path
- leave deeper mod/soundpack generic cleanup for later

This minimizes node-path breakage and avoids turning a release installer task into archaeology with buttons.

## LLM backend future direction

Future `LLM backend` work should probably add:
- backend choice: API / Ollama / OpenVINO / manual custom
- config writer for C-AOL's LLM config files
- dependency/status check per backend
- smoke test button that confirms the selected backend can answer a trivial request or that the local runner starts

This is not v0 unless only a harmless stub is added.


## Backend setup direction

First supported setup options for the active v0 target are API and Ollama.

API path should focus on choosing API mode, writing/checking C-AOL config, and validating config shape without exposing secrets. Live API smoke tests that need real keys are later unless Josef explicitly provides/clears that path.

Ollama path should detect whether the `ollama` command exists and whether the local server responds. It may write/check C-AOL config for Ollama. It must not pull large models or run heavyweight installs without explicit clearance.

OpenVINO is the specialized third backend and remains parked after API/Ollama unless a cheap placeholder or detector can be added safely.

## Mod compatibility / NPC summary direction

Dabdoob already has mod, soundpack, and tileset management. Lacapult should preserve this first rather than rewriting it. The first C-AOL-specific step is to inspect where inherited mod metadata and compatibility rules live, then define a compatibility-summary shape.

Future NPC/LLM-facing mod summaries should describe what an installed mod adds or changes in terms useful for context: factions, items, monsters, locations, professions, tone, and any world assumptions. That is not runtime integration in v0; it is a metadata direction to prevent future context soup.


## Product north star

The detailed one-shot installer direction lives in `doc/lacapult-one-shot-installer-vision.md`. Treat it as product guidance, not permission to skip proof order. Release metadata/install proof comes before backend cleverness; backend setup comes before deeper mod/NPC integration.

## 2026-04-24 implementation notes

- C-AOL release channel key is now `caol-release`.
- `scripts/ReleaseManager.gd` fetches `https://api.github.com/repos/josihosi/Cataclysm-AOL/releases` and filters assets by platform substring:
  - Linux: `_linux.tar.gz`
  - Windows: `_windows.zip`
  - macOS: `_macos.dmg`, with fallback tolerance for `_macos.tar.gz` / `_macos.zip`.
- `scripts/settings_manager.gd` defaults the launcher to `game = "caol"`, `channel = "release"`, and keeps backend setup fields for API/Ollama without secrets.
- `scripts/BackendConfigManager.gd` is a safe first backend setup skeleton. It writes launcher-side metadata only, detects the Ollama command cheaply, and explicitly parks OpenVINO as specialized future work.
- `BackendConfig` is autoloaded in `project.godot` so Settings UI code can read supported backends and write launcher-side backend metadata.
- `scripts/SettingsUI.gd` creates a small runtime backend setup section in the existing Settings tab. It supports API, Ollama, and parked OpenVINO; API mode intentionally stores endpoint/model metadata only and not secrets.
- `doc/caol-mod-compatibility-summary.md` records the first compatibility-summary shape for inherited mod support and future NPC/LLM context use.
- Warning status calls use the actual `Enums.MSG_WARN` member. The inherited `Enums.MSG_WARNING` spelling was not defined and would fail if installer/filesystem/mod warning branches executed.
- `tools/prove_caol_release.py --all-platforms` now proves the v0.2.0 asset contract for Linux, macOS, and Windows in one live GitHub API read while preserving the default current-host proof mode.

## 2026-04-25 release list installability metadata

- `scripts/ReleaseManager.gd` now carries optional `asset_size` and `release_page_url` fields in release metadata alongside the installer-critical `name`, `url`, `filename`, `published_at`, and `has_any_assets` fields.
- `scripts/Catapult.gd` formats release-list rows with selected asset name, size, and readiness; non-installable releases remain visible but disabled with a tooltip explaining whether there are no assets or no matching platform asset.
- The install button selection handler now checks for a download URL before enabling install/update actions, closing the gap where a non-installable visible release could be selected.

## 2026-04-25 installer launchability guard

- `scripts/ReleaseInstaller.gd` now re-checks the moved target directory before posting install/update success, so an extracted archive must still look like a launchable game directory after the final move.
- macOS DMG/app-bundle extraction keeps top-level `.app` bundles inside the install directory instead of installing the bundle itself as the root. This matches the launcher lookup path, which searches for `.app` bundles inside `Paths.game_dir`.
- The install-root probe and Unix chmod pass now include the C-AOL-specific `Cataclysm-AOL` executable name alongside inherited `cataclysm-tiles` names.

## 2026-04-25 Ollama backend status tightening

- `scripts/BackendConfigManager.gd` now uses a platform-aware `which`/`where` command lookup for Ollama instead of assuming a Unix shell helper on every platform.
- When the Ollama command exists, the Godot-side detector runs `ollama list` as the cheap server/status probe. It reports `ollama_command_present_server_running` on success or `ollama_command_present_server_unreachable` when the command exists but the local server is not responding.
- The probe does not pull models, install anything, call remote APIs, or log/store API secrets.

## 2026-04-25 C-AOL backend option contract preview

- `scripts/BackendConfigManager.gd` now includes a preview-only C-AOL options patch inside `caol_backend_setup.json` and writes the same patch separately as `caol_llm_options_patch.json`.
- This is still a safe launcher-side artifact, not an installed-game mutation. It records the C-AOL `config/options.json` names Lacapult would set once an explicit apply step exists.
- Current mapped option names are `LLM_INTENT_BACKEND`, `LLM_INTENT_OLLAMA_URL`, `LLM_INTENT_OLLAMA_MODEL`, `LLM_INTENT_API_KEY_ENV`, and `LLM_INTENT_API_MODEL`.
- API mode stores `CATA_API_KEY` as the environment-variable name only; Lacapult still does not store API secrets.
- `LLM_INTENT_ENABLE` is intentionally not changed by the preview patch. Enabling NPC LLM calls should remain a clear player/apply-step decision until the installer has a real installed-game config writer.
- `tools/prove_caol_backend_contract.py` validates this mapping against a local C-AOL checkout without running Godot, mutating game config, using API secrets, pulling models, or downloading release archives.

## 2026-04-25 public-facing identity cleanup

Remaining non-credit player-facing text now says Lacapult Doobdab rather than Dabdoob in English startup tips, settings copy, font-help copy, the DOTD note, the macOS permission helper, and dormant self-update status/updater-script strings. Dabdoob/Catapult references remain intentionally in attribution, docs, inherited internal filenames/comments, and lineage copy.

## 2026-04-25 local proof packet closure

Release metadata, installer-shape proof, backend API/Ollama preview config, OpenVINO parked status, mod compatibility note, and identity cleanup are all locally proven.

## 2026-04-25 Godot GUI first-run smoke

Godot 3.6.2 is available as `godot` on this Mac. A GUI smoke launched the project and proved the first visible Game tab and Settings backend surface. The smoke also shaped three small fixes:

- C-AOL release rows now prefer `v0.2.0` first, then other installable rows, then blocked/no-platform-asset rows. This prevents old inherited/non-installable release names from being the first visible build even though the current C-AOL proof target is ready.
- The Settings-tab backend setup section is moved near the top of the inherited settings list so Backend, Endpoint, Model, status/help text, and Save are visible without relying on a clipped bottom area.
- The disabled self-update button now says `Update Lacapult` instead of inherited `Update Dabdoob`.

The next heavier proof is an actual controlled macOS DMG download/extraction/install pass for the selected `v0.2.0` asset. Do not treat the GUI smoke as proof that DMG extraction or `.app` launchability succeeded; it only proved the selected release metadata and visible setup surface.

## 2026-04-25 controlled macOS DMG shape proof

Added `tools/prove_caol_macos_dmg.py` as a repeatable proof for the selected C-AOL `v0.2.0` macOS DMG. In default mode it only proves live metadata; with `--download` it downloads the selected DMG into `.proof-cache/`, mounts it read-only/no-browse with `hdiutil`, inspects the top-level `.app` bundle and executable candidates, then detaches the image.

The selected asset `caol_cdda-0-h_2026-03-29-1556_macos.dmg` exposes `Cataclysm.app` plus an Applications symlink. Inside the app bundle, Lacapult's current launchability guard can match both `Contents/MacOS/Cataclysm.sh` via the single-file `Contents/MacOS` fallback and `Contents/Resources/cataclysm-tiles` via the preferred C-AOL executable list. This proves the downloaded DMG has a launchable shape compatible with the existing app-bundle installer/launcher guards, without claiming a full in-launcher install or launch smoke.

## 2026-04-25 sandboxed macOS DMG install-shape proof

`tools/prove_caol_macos_dmg.py --install-sandbox` now proves the selected C-AOL `v0.2.0` macOS DMG through a temporary Lacapult-style install tree. It mounts the DMG read-only, copies the mount root while skipping `Applications`, selects the app-containing extracted root the same way the macOS installer guard expects, writes `catapult_install_info.json`, moves contents into sandbox `caol/game0`, chmods app-bundle executable candidates, and asserts the final install directory remains launchable. The proof uses a temporary directory and does not mutate the real Lacapult Application Support install state or launch C-AOL.

## 2026-04-25 cron project-load/install-shape revalidation

The repeatable proof packet was re-run after the sandbox install proof: live all-platform release metadata, backend option contract, macOS DMG sandbox install shape, safe Ollama detection, and `git diff --check` all still pass. Godot 3.6.2 is available at `/opt/homebrew/bin/godot`; `godot --path . --no-window --quit` exits 0, giving a cheap project-load smoke in addition to the earlier GUI screenshots. The run still does not claim a clicked in-launcher install into the real Lacapult app-data folder or a C-AOL launch smoke.

## 2026-04-25 headless Godot installer smoke

`tools/godot_install_release_smoke.gd` is a narrow Godot-side installer proof for the selected cached C-AOL `v0.2.0` macOS DMG. Run it with an isolated `HOME` and `LACAPULT_CAOL_DMG=/absolute/path/to/caol_cdda-0-h_2026-03-29-1556_macos.dmg`. It copies the DMG into Lacapult's cache, calls `ReleaseInstaller.install_release()`, and verifies the final isolated `caol/game0` contains `Cataclysm.app`, `catapult_install_info.json`, and passes the same launchability guard used by the installer. It is stronger than the Python sandbox mimic because it exercises the real Godot installer code path, but it is still not a clicked GUI install and does not launch C-AOL.


## 2026-04-25 full-scene install button smoke

`tools/godot_scene_install_button_smoke.gd` is the current strongest non-interactive install proof. It instantiates `scenes/Catapult.tscn`, lets the normal startup path fetch C-AOL releases, verifies the first listed Game-tab build is the prioritized installable `v0.2.0` macOS DMG, selects that row, emits the real Install button signal, waits for the scene-owned `ReleaseInstaller`, and verifies the isolated final install folder. This proves the main scene release-list/install-button handoff in addition to the lower-level installer code path. It is still not a physical mouse-clicked GUI install and does not launch C-AOL.
## 2026-04-25 physical clicked GUI install pass

A visible Godot GUI pass was run under isolated `HOME=/tmp/lacapult-click-home.XIDrDG` with the selected C-AOL `v0.2.0` macOS DMG pre-populated in that HOME's Lacapult cache. Peekaboo captured the Game tab and then performed an actual mouse click on `Install Selected`. The clicked path installed into the isolated Lacapult app-data tree, producing `caol/game0/Cataclysm.app` plus `catapult_install_info.json` with install info name `Cataclysm - Arsenic and Old Lace v0.2.0`. This proves the physical clicked GUI install path without mutating the real user install state, launching C-AOL, publishing releases, pulling models, or using API secrets.


## 2026-04-25 backend triad and mod compatibility correction

- v0 backend setup is a three-choice selector: API, Ollama, and OpenVINO. API/Ollama have the first real config/status paths; OpenVINO is selectable and writes honest placeholder/status metadata, but full runtime setup remains later.
- C-AOL mod support cannot be declared done just because inherited Dabdoob systems survived. For `game = "caol"`, custom downloadable mod catalogs currently fall through to `Paths.mod_repo`; stock mods come from the active C-AOL install tree, including macOS app-bundle data paths. That proof now exists as `tools/prove_caol_mod_inventory.py`: the selected cached C-AOL v0.2.0 macOS DMG exposes 42 non-obsolete packaged stock mod IDs plus 7 obsolete IDs through `Cataclysm.app/Contents/Resources/data/mods`; inherited DDA/BN/TLG downloadable catalogs remain untested for C-AOL unless a C-AOL source is added.

## 2026-04-25 C-AOL mod/summarizer bridge proof

`tools/prove_caol_mod_inventory.py` now emits a structured per-mod compatibility/summarizer bridge report into `.proof-cache/caol-mod-bridge/` while preserving the older high-level inventory fields. The report inspects every packaged stock mod in the selected C-AOL `v0.2.0` macOS DMG and records id/name, obsolete flag, dependencies, packaged-path presence, summary roots, JSON content flags, and a status classification.

Current result: 42 non-obsolete packaged stock mods are path-supported; 7 packaged mods are blocker-obsolete; no packaged mod currently ships `npcs/Backgrounds/Summaries_short` or `npcs/Backgrounds/Summaries_extra`; 30 mods contain NPC/faction/monster/item/location-ish content and are classified `summarizer-compatible-but-needs-generated-pack`; 12 are `no-summary-needed` for this bridge. There were no JSON parse errors and no missing dependency blockers in the selected packaged mod set.

The bridge contract is intentionally C-AOL-native: C-AOL runtime summary loading already merges core data, active mod roots, and world custom mods, then reads `npcs/Backgrounds/Summaries_short` and `npcs/Backgrounds/Summaries_extra` as JSON or legacy text. Lacapult should therefore generate/install future summary packs into those active mod roots instead of storing a launcher-only summary metadata format. UI surfacing/apply flow is not claimed by this proof.

## 2026-04-25 release-prep export packaging proof

`tools/prove_lacapult_export_packaging.py` is the current local release-prep export proof. It generates temporary Godot 3 export presets for macOS, Linux, and Windows, runs `--export-pack` into `.proof-cache/lacapult-export/`, writes `.proof-cache/lacapult-export/manifest.json`, and restores `export_presets.cfg` afterward so local signing/export settings are not accidentally committed.

On this Mac, Godot 3.6.2 can export all three PCK resource packs, proving the project resources/package config can be assembled locally. It cannot yet produce real app/executable exports because the Godot export templates are not installed for this version: macOS needs `osx.zip`, Linux needs `linux_x11_64_release`, and Windows needs `windows_64_release.exe` under a Godot 3.6.2 template directory. Even after templates exist, signed/notarized public releases remain a separate release decision; this proof deliberately does not publish, sign, notarize, use secrets, install OpenVINO runtimes, or pull models.

## 2026-04-25 isolated C-AOL game-launch smoke blocker

`tools/prove_caol_game_launch_smoke.py` is the current launch proof for the selected C-AOL `v0.2.0` macOS DMG. It proves the same sandboxed install shape as the earlier DMG proof, then starts the installed `Cataclysm.app` launch script under an isolated `HOME` and observes whether the game reaches a running process.

On Josef's Mac mini, the selected `caol_cdda-0-h_2026-03-29-1556_macos.dmg` installs correctly but does not launch. `cataclysm-tiles` aborts via dyld because it links absolute `/opt/local/lib/libfreetype.6.dylib` and `/opt/local/lib/libz.1.dylib` paths; those libraries are not bundled inside `Cataclysm.app/Contents` and are not present on this Mac. This is an upstream C-AOL macOS package portability blocker, not a Lacapult release-list or installer-copy failure. Lacapult can still eventually surface this as a clearer launch preflight/status message, but fixing the packaged binary or bundling dylibs belongs to the C-AOL release/package lane and needs fresh clearance before upstream publication/contact.

## 2026-04-25 read-only C-AOL mod bridge UI status

`scripts/SettingsUI.gd` now surfaces the packaged C-AOL mod compatibility/summarizer bridge as read-only Settings status near the backend controls. It exposes the current report counts and generated-report reference, explicitly says no generated summary packs are applied and no mods are enabled from this block, and keeps future summary-pack language tied to C-AOL active mod roots: `npcs/Backgrounds/Summaries_short` and `npcs/Backgrounds/Summaries_extra`.

This is intentionally not a new metadata or application system. The repeatable proof report remains generated under ignored `.proof-cache/caol-mod-bridge/` by `python3 tools/prove_caol_mod_inventory.py`; committed canon stays in `doc/caol-mod-compatibility-summary.md`.
