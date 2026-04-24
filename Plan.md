# Plan

Canonical roadmap for Lacapult Doobdad.

This repo is a standalone C-AOL-specific launcher/installer derived from Dabdoob / Catapult under the MIT license. It should feel like the front door for Cataclysm: Arsenic and Old Lace, not a generic Cataclysm launcher with a hat glued on.

## File roles

- **Plan.md** - canonical roadmap and current delivery target
- **TODO.md** - short execution queue for the active target only
- **SUCCESS.md** - success-state ledger for the active target
- **TESTING.md** - validation policy and current proof requirements
- **TechnicalTome.md** - durable technical facts and architecture notes
- **ATTRIBUTION.md** - credits and license/lineage obligations

## Current active target

### Lacapult Doobdad v0 standalone scaffold and C-AOL release installer

**Status:** GREENLIT / ACTIVE

Build a new local standalone repo in `/Users/josefhorvath/Schanigarten/Lacapult-Doobdad` from Dabdoob source, then turn the first slice into a C-AOL-specific launcher that can fetch and install C-AOL releases from `josihosi/Cataclysm-AOL`.

This first target is not yet the full LLM-backend installer. It must create the clean product foundation without drowning in every future tab at once. Na bravo, restraint, the exotic spice.

### Product intent

Lacapult Doobdad should install and launch C-AOL releases with the minimum friction possible.

The player-facing v0 story:
1. Download/open Lacapult Doobdad.
2. See C-AOL as the only real game target.
3. Refresh available C-AOL releases.
4. Pick a platform-appropriate asset from GitHub releases.
5. Install/update the game while preserving user data.
6. Launch the installed game.

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
- Add C-AOL release fetching:
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
- Add an `LLM backend` plan/stub only if it is cheap and non-invasive:
  - a placeholder tab or settings field is allowed
  - real Ollama/OpenVINO/API setup is a later target unless Andi can do the stub without disturbing C-AOL release install proof

### Out of scope for v0

- Creating the public GitHub repo or pushing externally without fresh explicit clearance from Josef/Schani.
- Full LLM backend installation automation.
- Modpack curation beyond preserving inherited mod/soundpack/tileset behavior.
- Supporting DDA/TLG/BN/EOD/TISH as first-class visible targets.
- New artwork/icon polish unless needed to remove misleading Dabdoob branding.
- Cross-platform signed release builds of Lacapult itself.
- Perfect translation pass across every locale.

## Expected implementation shape

### 1. Repo hygiene / identity

- Keep original `LICENSE` MIT text and copyright notices.
- Add/maintain `ATTRIBUTION.md`.
- Rewrite README to explain Lacapult Doobdad as a C-AOL installer derived from Dabdoob/Catapult.
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

## Testing / evidence bar

Andi must not stop at "code looks fine". Godot launcher code has a talent for smiling while one node path is broken, naturally.

Minimum evidence for v0 handoff:
1. Static sanity:
   - grep shows old version-check URL and obvious Dabdoob/Catapult public identity are either intentionally credited or replaced
   - grep shows C-AOL release URL and asset filters exist
   - settings default to `caol`
2. GitHub release parsing proof:
   - run a small script or Godot-adjacent parser test against live `josihosi/Cataclysm-AOL` release JSON
   - prove it selects at least one asset for the current platform from `v0.2.0` if available
3. Installer path proof:
   - either run the launcher far enough to fetch/show C-AOL releases, or create a narrow executable-free test that proves selected asset metadata reaches `ReleaseInstaller.install_release()` shape: `name`, `url`, `filename`, `published_at`, `has_any_assets`
4. No public repo push unless explicitly cleared.

## Done means

The v0 target is done when:
- local repo exists and is committed locally
- docs/README/LICENSE/ATTRIBUTION tell the truth
- launcher identity says Lacapult Doobdad / C-AOL, not generic Dabdoob except in credits
- C-AOL releases are fetched from `josihosi/Cataclysm-AOL`
- platform asset matching works for current release assets
- install/update/launch paths are at least plausibly wired and tested to the smallest honest extent available on this Mac
- remaining LLM backend and modding work is parked as explicit next targets, not half-wired in secret
