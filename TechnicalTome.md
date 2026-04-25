# TechnicalTome

Durable technical notes for Lacapult Doobdab.

## Lineage

Lacapult Doobdab starts from `Hihahahalol/Catapult_Dabdoob`, which itself is based on qrrk's Catapult launcher.

License is MIT. Preserve upstream license text and attribution.

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
