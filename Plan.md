# Plan

Canonical roadmap for Lacapult Doobdab.

This repo is a standalone C-AOL-specific launcher/installer derived from Dabdoob / Catapult under the MIT license. It should feel like the front door for Cataclysm: Arsenic and Old Lace, not a generic Cataclysm launcher with a hat glued on.

## File roles

- **Plan.md** - canonical roadmap and current delivery target
- **TODO.md** - short execution queue for the active target only
- **SUCCESS.md** - success-state ledger for the active target
- **TESTING.md** - validation policy and current proof requirements
- **TechnicalTome.md** - durable technical facts and architecture notes
- **ATTRIBUTION.md** - credits and license/lineage obligations
- **doc/lacapult-one-shot-installer-vision.md** - product north star for the one-shot installer
- **doc/lacapult-v02-release-backend-modding-contract.md** - active scope amendment for v0.2.0/backend/modding work

## Current active target

### Lacapult Doobdab v0.2.0 release installer plus first backend setup options

**Status:** CLICKED INSTALL + BACKEND TRIAD + MOD INVENTORY + RELEASE-PREP PACK PROVEN / APP EXPORT BLOCKED ON GODOT TEMPLATES

Build from the local standalone repo at `/Users/josefhorvath/Schanigarten/Lacapult-Doobdab`, then turn the first product slice into a C-AOL-specific launcher that can fetch and install the existing `v0.2.0` C-AOL releases from `josihosi/Cataclysm-AOL`. The local proof packet is complete as of 2026-04-25, a Godot 3.6.2 GUI smoke proves the project launches, surfaces the prioritized C-AOL `v0.2.0` macOS DMG first, and exposes the Settings-tab backend setup controls. Controlled DMG proofs now confirm the selected macOS asset exposes a launchable `.app` shape and that a sandboxed Lacapult-style copy/move install leaves `Cataclysm.app` plus `catapult_install_info.json` in the final install folder without touching the real Application Support install state or launching the game.

The active scope now includes a visible three-option backend setup selector for **API**, **Ollama**, and **OpenVINO** after the v0.2.0 release install path is proven. API and Ollama get the first real config/status paths; OpenVINO must still be selectable and honest in v0, with a safe placeholder/detection/status path rather than full installer automation. Modding support is not merely a parked courtesy note: inherited mod/soundpack/tileset support must be investigated against C-AOL enough to tell what is preserved, what is untested, and what metadata shape can later feed NPC/LLM summaries. A headless Godot installer smoke exercises the real `ReleaseInstaller.install_release()` path against the selected cached macOS DMG inside an isolated HOME. A stronger full-scene Godot smoke instantiates the main Catapult scene, waits for the live C-AOL release fetch, selects the prioritized `v0.2.0` build row, emits the real Install button signal, and verifies the isolated install. A physical GUI pass now launched the visible Godot window under an isolated HOME, used a real mouse click on `Install Selected`, and verified the final sandbox install folder contains `Cataclysm.app` plus `catapult_install_info.json`. A release-prep export proof now generates temporary safe Godot presets, exports macOS/Linux/Windows PCK packs into ignored `.proof-cache/`, and restores `export_presets.cfg`; full app exports are blocked locally because Godot 3.6.2 export templates are missing (`osx.zip`, `linux_x11_64_release`, `windows_64_release.exe`), with signing/notarization still unclaimed. It still is not a C-AOL game-launch smoke.

Product north star: `doc/lacapult-one-shot-installer-vision.md`. It is greenlit as direction, but execution still follows proof order: v0.2.0 release metadata/install path first, backend skeleton second, mod compatibility investigation third.

### Product intent

Lacapult Doobdab should install and launch C-AOL releases with the minimum friction possible.

The player-facing v0 story:
1. Download/open Lacapult Doobdab.
2. See C-AOL as the only real game target.
3. Refresh available C-AOL releases.
4. Pick a platform-appropriate `v0.2.0` asset from GitHub releases.
5. Install/update the game while preserving user data.
6. Choose a backend setup path from API, Ollama, or OpenVINO, with v0 honesty about what each path can actually configure.
7. Launch the installed game.

### Required source lineage

The repo is derived from:
- qrrk's Catapult
- Hihahahalol's Dabdoob / Catapult_Dabdoob
- Cataclysm: Dark Days Ahead
- Cataclysm: The Last Generation
- Cataclysm: Bright Nights, while inherited support or credits remain
- Cataclysm: Arsenic and Old Lace

Preserve MIT license notice and attribution. Do not make the repo look like an unattributed copy.

## Active slice scope

### In scope for v0

- Standalone local repo with no inherited `.git` history.
- Minimal repo-local canon and attribution docs.
- Rebrand obvious launcher identity:
  - project name/window title
  - version-check URL or disable version check until Lacapult releases exist
  - README top-level identity
  - about/credits text where currently visible
- Make the launcher C-AOL-first / C-AOL-only:
  - default setting `game = "caol"`
  - remove or hide generic game chooser from the first surface unless hiding breaks layout badly
  - replace game description with C-AOL description
- Add C-AOL release fetching, with `v0.2.0` as the first proof target:
  - GitHub API endpoint: `https://api.github.com/repos/josihosi/Cataclysm-AOL/releases`
  - release key: `caol-release` or similar, but keep the naming consistent across settings, release manager, UI, paths, and installer
  - platform asset filtering for release assets currently shaped like the `v0.2.0` assets:
    - Linux: asset names containing `_linux.tar.gz`
    - Windows: asset names containing `_windows.zip`
    - macOS: asset names containing `_macos.dmg` (and tolerate `_macos.tar.gz` / `_macos.zip` if future releases change packaging)
  - include releases even when no matching asset exists, but show them as non-installable rather than pretending install works
- Reuse existing installer/update/userdata preservation behavior where possible.
- Update launch executable discovery to handle C-AOL's actual packaged executable names:
  - `cataclysm-tiles`
  - `cataclysm-tiles.exe`
  - any C-AOL package-specific executable name discovered in release archives
- Add first LLM backend setup options after the v0.2.0 install path is structurally proven:
  - API backend: selectable mode plus config-writing/checking path; smoke/status check only if it does not require secrets
  - Ollama backend: selectable mode plus local `ollama`/server detection and C-AOL config path; do not pull huge models or automate risky installs without clearance
  - OpenVINO backend: selectable third mode with an honest v0 placeholder/detection/status path; full OpenVINO install/setup automation remains later

### Out of scope for v0

- Pushing to the public GitHub repo, publishing releases, or contacting upstream without fresh explicit clearance from Josef/Schani. The public repo exists at `https://github.com/josihosi/Lacapult-Doobdab`, but public writes remain clearance-gated.
- Full all-three-backend installation automation.
- OpenVINO implementation beyond selectable placeholder/detection/status metadata.
- Pulling or installing large local models without explicit clearance.
- Modpack curation beyond investigating inherited mod/soundpack/tileset behavior, marking C-AOL compatibility honestly, and starting a bounded compatibility-summary shape.
- Supporting DDA/TLG/BN/EOD/TISH as first-class visible targets.
- New artwork/icon polish unless needed to remove misleading Dabdoob branding.
- Cross-platform signed release builds of Lacapult itself.
- Perfect translation pass across every locale.

## Expected implementation shape

### 1. Repo hygiene / identity

- Keep original `LICENSE` MIT text and copyright notices.
- Add/maintain `ATTRIBUTION.md`.
- Rewrite README to explain Lacapult Doobdab as a C-AOL installer derived from Dabdoob/Catapult.
- Keep credits near the top, not buried in a legal cellar.
- Update `project.godot` name/description.
- Replace self-update URL in `scripts/Catapult.gd` with a Lacapult placeholder or disable update check cleanly until releases exist.

### 2. Game model simplification

Current Dabdoob supports many game keys (`dda`, `bn`, `tlg`, `eod`, `tish`). For v0, avoid deep generic abstraction unless it is cheaper than removal.

Preferred bounded approach:
- Add `caol` as the only configured/default game.
- Hide the game choice UI or make it a one-item selector.
- Keep internal arrays/dictionaries simple but consistent.
- Preserve path isolation under a `caol/` folder in launcher data.

### 3. Release manager

- Add `_RELEASE_URLS["caol-release"] = "https://api.github.com/repos/josihosi/Cataclysm-AOL/releases"`.
- Add platform filters for C-AOL release assets.
- Add a request-completed callback for C-AOL or refactor duplicated callbacks lightly.
- Add `releases["caol-release"] = []`.
- Update `fetch()` so the selected C-AOL channel uses this key.
- Confirm GitHub auth-token path still works for higher rate limits.

### 4. UI/channel behavior

- C-AOL can initially have one channel called `Release` / `Latest releases`.
- Stable/Experimental radio buttons can be hidden, disabled, or repurposed only if done honestly.
- Build list should show release name/tag, publish date, and installability.
- Changelog link can be disabled or pointed to the C-AOL release page for v0.

### 5. Installer / launcher behavior

- Use existing archive download/extract flow.
- Validate installed folder contains a plausible game executable before marking install active.
- Preserve update/current-install behavior if the existing code path already does it.
- Launch should find executable across Windows/Linux/macOS package shapes.
- macOS permission-fix script should include C-AOL executable/app bundle names once known.


### 6. LLM backend setup behavior

- Add C-AOL backend setup as a visible concept only after the release install path is not vapor.
- The player-facing selector should expose three options: API, Ollama, and OpenVINO.
- API setup should focus on mode/config fields and safe validation without exposing secrets.
- Ollama setup should detect local availability/server status and write/check C-AOL config; installation/model-pull automation is later unless explicitly cleared.
- OpenVINO setup should be selectable and honest in v0: placeholder/detection/status metadata is enough, but it should not disappear as if only two backends exist.

### 7. Modding compatibility investigation

- Keep inherited Dabdoob mod/soundpack/tileset support unless it blocks C-AOL-first UX.
- Identify where inherited mod metadata, download sources, compatibility rules, and UI entry points live.
- Check how those inherited assumptions map onto an installed C-AOL `v0.2.0` tree and mark the result honestly as supported, untested, broken, or unknown.
- Start a C-AOL compatibility-summary note for mods.
- Treat NPC/LLM mod summaries as future-facing metadata: useful later for telling NPC/context systems what factions, items, monsters, locations, or tone an installed mod adds.

## Testing / evidence bar

Andi must not stop at "code looks fine". Godot launcher code has a talent for smiling while one node path is broken, naturally.

Minimum evidence for v0 handoff:
1. Static sanity:
   - grep shows old version-check URL and obvious Dabdoob/Catapult public identity are either intentionally credited or replaced
   - grep shows C-AOL release URL and asset filters exist
   - settings default to `caol`
2. GitHub release parsing proof:
   - run a small script or Godot-adjacent parser test against live `josihosi/Cataclysm-AOL` release JSON
   - prove it selects at least one asset for the current platform from `v0.2.0`
3. Installer path proof:
   - either run the launcher far enough to fetch/show C-AOL releases, or create a narrow executable-free test that proves selected asset metadata reaches `ReleaseInstaller.install_release()` shape: `name`, `url`, `filename`, `published_at`, `has_any_assets`
4. Backend setup proof:
   - API config path is present and does not leak secrets
   - Ollama detection/config path is present or the blocker is recorded
5. Modding investigation proof:
   - inherited mod-support entry points are identified
   - first compatibility-summary direction is documented
6. No public repo push unless explicitly cleared.

## Done means

The v0 target is done when:
- local repo exists and is committed locally
- docs/README/LICENSE/ATTRIBUTION tell the truth
- launcher identity says Lacapult Doobdab / C-AOL, not generic Dabdoob except in credits
- C-AOL `v0.2.0` releases are fetched from `josihosi/Cataclysm-AOL`
- platform asset matching works for current `v0.2.0` assets
- install/update/launch paths are at least plausibly wired and tested to the smallest honest extent available on this Mac
- API, Ollama, and OpenVINO backend setup options are represented in canon and in the UI selector, with v0-honest capability/status for each
- OpenVINO is selectable but not falsely implemented beyond placeholder/detection/status metadata
- inherited modding support is preserved and the C-AOL compatibility/NPC-summary investigation records entry points, assumptions, and next proof needs
