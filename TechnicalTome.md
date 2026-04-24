# TechnicalTome

Durable technical notes for Lacapult Doobdad.

## Lineage

Lacapult Doobdad starts from `Hihahahalol/Catapult_Dabdoob`, which itself is based on qrrk's Catapult launcher.

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
- `doc/caol-mod-compatibility-summary.md` records the first compatibility-summary shape for inherited mod support and future NPC/LLM context use.
