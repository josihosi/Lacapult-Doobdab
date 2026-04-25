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
- **doc/lacapult-mod-summarizer-feature-plan-2026-04-25.md** - active next-lane plan for C-AOL mod install/enable plus Summarizer UX/status/apply

## Current active target

### Lacapult Doobdab v0.2.0 release installer plus first backend setup options

**Status:** CLICKED INSTALL + BACKEND TRIAD V0-SAFE CONFIG/READINESS + SANDBOX OPTIONS APPLY PROVEN + MOD/SUMMARIZER SLICE 5 ERROR/ROLLBACK MATRIX PROVEN + LOCAL UNSIGNED APP/PACKAGE EXPORTS PROVEN + LAUNCH PREFLIGHT STATUS PROVEN / GAME-LAUNCH SMOKE BLOCKED BY C-AOL macOS DYLIBS / SIGNING+PUBLIC RELEASE NOT CLAIMED

Build from the local standalone repo at `/Users/josefhorvath/Schanigarten/Lacapult-Doobdab`, then turn the first product slice into a C-AOL-specific launcher that can fetch and install the existing `v0.2.0` C-AOL releases from `josihosi/Cataclysm-AOL`. The local proof packet is complete as of 2026-04-25, a Godot 3.6.2 GUI smoke proves the project launches, surfaces the prioritized C-AOL `v0.2.0` macOS DMG first, and exposes the Settings-tab backend setup controls. Controlled DMG proofs now confirm the selected macOS asset exposes a launchable `.app` shape and that a sandboxed Lacapult-style copy/move install leaves `Cataclysm.app` plus `catapult_install_info.json` in the final install folder without touching the real Application Support install state or launching the game.

The active scope now includes a visible three-option backend setup selector for **API**, **Ollama**, and **OpenVINO** after the v0.2.0 release install path is proven. API, Ollama, and OpenVINO now have v0-safe config/readiness paths: Lacapult stores provider/model/env-var names rather than API secrets, checks the configured/default Python runner path for backend imports where safe, detects Ollama command/server/model-list state without pulling models, detects OpenVINO Python imports and model-dir presence without installing runtimes, and has a sandbox-guarded proof path that applies backend option patches to copied C-AOL `config/options.json` files for all three backends. This is still not full live backend automation: current local proof reports `any_llm` missing from the default Python, OpenVINO packages/model availability missing unless supplied, C-AOL runtime provider use still hardcoded to OpenAI, and no API calls/model pulls/downloads are attempted. The product target is that AnyLLM/API and Ollama/llama-family setups become genuinely good across Windows/macOS/Linux wherever dependencies are available; OpenVINO may remain Windows-first for v0, but Lacapult must say that plainly and check it well. Modding support is the next planned lane, not secretly implemented in this backend hardening slice: inherited mod/soundpack/tileset support must be investigated against C-AOL enough to tell what is preserved, what is untested, and what metadata shape can later feed NPC/LLM summaries. A headless Godot installer smoke exercises the real `ReleaseInstaller.install_release()` path against the selected cached macOS DMG inside an isolated HOME. A stronger full-scene Godot smoke instantiates the main Catapult scene, waits for the live C-AOL release fetch, selects the prioritized `v0.2.0` build row, emits the real Install button signal, and verifies the isolated install. A physical GUI pass now launched the visible Godot window under an isolated HOME, used a real mouse click on `Install Selected`, and verified the final sandbox install folder contains `Cataclysm.app` plus `catapult_install_info.json`. The modding lane now has a read-only per-mod compatibility/summarizer bridge report for all packaged C-AOL `v0.2.0` stock mods, plus a Settings-tab read-only status block that surfaces the key counts and report reference: 42 non-obsolete packaged mods are path-supported, 7 are obsolete blockers, no packaged mod currently ships C-AOL summary roots, and 30 context-relevant mods are ready for future generated summary packs in C-AOL-compatible `Summaries_short` / `Summaries_extra` roots rather than launcher-only metadata. A release-prep export proof now generates temporary safe Godot presets, exports macOS/Linux/Windows PCK packs plus real unsigned app/executable outputs into ignored `.proof-cache/`, creates unsigned macOS/Linux/Windows package archives, validates their shape/hashes, and restores `export_presets.cfg`; this proves local app exportability with the installed Godot 3.6.2 templates, but still does not claim signing, notarization, GitHub release publication, or end-user install QA. A C-AOL game-launch smoke from an isolated installed app bundle was attempted and now gives the next hard blocker: the selected `v0.2.0` macOS DMG installs into the sandboxed Lacapult app shape, but `Cataclysm.app/Contents/Resources/cataclysm-tiles` aborts on this Mac because it links absolute `/opt/local/lib/libfreetype.6.dylib` and `/opt/local/lib/libz.1.dylib` paths that are not bundled in the app and are not present locally. Lacapult now has a read-only macOS launch preflight/status path that checks the active C-AOL launch binary with `otool -L`, reports the missing non-portable local dylibs as a C-AOL package portability issue, and blocks the Play/Resume path before the user gets a mysterious abort. Signing/notarization, public release packaging/publication, live compiled C-AOL game-world launch proof, and any upstream packaging fix remain separate decisions.

Product north star: `doc/lacapult-one-shot-installer-vision.md`. It is greenlit as direction, but execution still follows proof order: v0.2.0 release metadata/install path first, backend skeleton second, mod compatibility investigation third. Lacapult is itself an installer/launcher product, so its own distribution must be easy for normal users to install on Windows, macOS, and Linux; do not let C-AOL package launchability work obscure the separate Lacapult app packaging/installability bar.

### Active next implementation family

The next planned lane after backend-good hardening is now **feature-complete C-AOL mod install/enable plus Summarizer UX/status/apply**, defined in `doc/lacapult-mod-summarizer-feature-plan-2026-04-25.md`. Slice 1 is implemented as a read-only C-AOL mod/Summarizer discovery/status model with sandbox proof, Slice 2 is implemented as a read-only Mods/Settings UX status surface plus dry-run Summarizer prompt/button, Slice 3 is implemented as a sandbox-only C-AOL-native companion summary-pack generation/apply/rollback proof with manifest, backups, exact `mods.json` restore, and status-model visibility, Slice 4 is implemented as a deterministic C-AOL `npc_harness.py` plus C++ source-seam proof that a sandbox active generated companion root reaches prompt construction as `your_tone` / `your_example_expression`, and Slice 5 is implemented as a sandbox-only error/rollback matrix for broken metadata, content parse errors, missing dependencies, obsolete mods, partial/stale/conflicting summaries, backend-not-ready gating, and replacement rollback. The next bounded target should be chosen between sandbox-gated real generation/apply UI wiring and the separate backend recommendation/setup lane; release/signing remains product-judgment-heavy and needs Josef/Schani decision. The lane promotes the existing read-only packaged-mod bridge into a bounded implementation plan: discover stock/user/catalog/world mods, report enabled/disabled and summary coverage status, offer a post-install/post-enable Summarizer prompt, gate generation on API/Ollama/OpenVINO backend readiness, stage C-AOL-native `npcs/Backgrounds/Summaries_short` / `Summaries_extra` packs, and prove sandboxed apply/rollback plus C-AOL runtime consumption. C-AOL owns runtime schema/loading/consumption; Lacapult owns installer UX, status, generation orchestration, apply/rollback help, and backend readiness checks. No proof script or UI slice may mutate Josef's real Application Support config, saves, worlds, or mods.

### Product intent

Lacapult Doobdab should install and launch C-AOL releases with the minimum friction possible.

The player-facing v0 story:
1. Download/install Lacapult Doobdab easily on Windows, macOS, or Linux.
2. Open Lacapult without developer tooling.
3. See C-AOL as the only real game target.
4. Refresh available C-AOL releases.
5. Pick a platform-appropriate `v0.2.0` asset from GitHub releases.
6. Install/update the game while preserving user data.
7. Choose a backend setup path from API, Ollama, or OpenVINO, with v0 honesty about what each path can actually configure.
8. Launch the installed game.

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
  - API backend: selectable mode plus config-writing/checking path; check Python/`any_llm` import readiness without using secrets; store API-key env-var name/provider/model only
  - Ollama backend: selectable mode plus local `ollama` command/server/model-list detection and C-AOL config path; do not pull huge models or automate risky installs without clearance
  - OpenVINO backend: selectable third mode with Python import/model-dir/device detection and C-AOL config path; full OpenVINO install/setup automation remains later

### Out of scope for v0

- Pushing to the public GitHub repo, publishing releases, or contacting upstream without fresh explicit clearance from Josef/Schani. The public repo exists at `https://github.com/josihosi/Lacapult-Doobdab`, but public writes remain clearance-gated.
- Full all-three-backend installation automation, model downloads, or secret-bearing live API calls.
- OpenVINO implementation beyond v0-safe detection/config/status metadata; runtime install/model download/live inference remain later. Future direction may grow into a guided, explicit-approval setup path with a fixed package list and model-dir setup, but that is not implemented in this mod-status slice.
- Pulling or installing large local models without explicit clearance. Ollama model recommendation UX is a later backend lane; Slice 1 does not recommend, rename, verify provenance for, or pull models.
- Modpack curation beyond investigating inherited mod/soundpack/tileset behavior, marking C-AOL compatibility honestly, and starting a bounded compatibility-summary shape; feature-complete mod install/enable plus summarizer apply UX is the next planned lane.
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
- API setup should focus on mode/config fields, AnyLLM/Python readiness, guided missing-dependency messages, and safe validation without exposing secrets.
- Ollama setup should detect local availability/server/model-list status and write/check C-AOL config; installation/model-pull automation is later unless explicitly cleared.
- OpenVINO setup should be selectable and honest in v0: Windows-first detection/config/status metadata is enough, but it should not disappear as if only two backends exist.

### 7. Modding compatibility investigation

- Keep inherited Dabdoob mod/soundpack/tileset support unless it blocks C-AOL-first UX.
- Identify where inherited mod metadata, download sources, compatibility rules, and UI entry points live.
- Check how those inherited assumptions map onto an installed C-AOL `v0.2.0` tree and mark the result honestly as supported, untested, broken, or unknown.
- Start a C-AOL compatibility-summary note for mods.
- Treat NPC/LLM mod summaries as the next feature-complete lane, not current backend work: after mod install/enable, Lacapult should offer Summarizer UX/status/apply help while C-AOL owns `Summaries_short` / `Summaries_extra` schema and runtime consumption.

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
   - API config/readiness path is present and does not leak secrets
   - Ollama detection/config path is present or the blocker is recorded
   - OpenVINO is surfaced as Windows-first v0 detection/config/status rather than fake cross-platform automation
   - sandboxed C-AOL `config/options.json` apply proof exists for API, Ollama, and OpenVINO
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
- API, Ollama, and OpenVINO backend setup options are represented in canon and in the UI selector, with v0-honest capability/status/guidance for each
- OpenVINO is selectable but not falsely implemented beyond Windows-first detection/config/status metadata
- inherited modding support is preserved and the C-AOL compatibility/NPC-summary investigation records entry points, assumptions, and next proof needs
