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
