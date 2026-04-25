# Lacapult click-level GUI audit — 2026-04-25

Status: **MAYBE-READY FOR JOSEF WINDOWS TEST / NOT READY FOR PUBLIC RELEASE**

This is a product audit, not a release note. It checks whether Lacapult Doobdab currently behaves like a coherent C-AOL launcher rather than a pile of inherited Dabdoob doors with some C-AOL wallpaper stapled on.

## Evidence classes

- **Live GUI evidence:** Godot 3.6.2 launched the main Lacapult window under an isolated temporary `HOME`; screenshots were captured with Peekaboo under `~/.openclaw/workspace/runtime/lacapult-click-audit-2026-04-25/`.
- **Source-level click map:** `scenes/Catapult.tscn` and the visible tab scripts were inspected for every player-facing tab, button family, and inherited dead-end risk.
- **Existing deterministic proofs:** the audit relies on already-landed install/backend/mod/Summarizer proof scripts for behavior that should not mutate Josef's real Application Support data.

Live GUI automation caveat: Peekaboo could capture full-screen screenshots, but Godot's remote-window enumeration reported odd tiny window bounds in some runs. So this audit treats live screenshots as visual sanity evidence and source/proof inspection as the click-level authority. No real user C-AOL data was intentionally mutated.

## Audit verdict

**Verdict:** maybe-ready for Josef Windows test, not ready for public release.

Reasoning:

- The launcher now has a coherent visible first-run story: pick C-AOL, refresh/select `v0.2.0`, install selected release, configure backend metadata, inspect mod/Summarizer status, and use Play/Resume only when launch preflight allows it.
- The most dangerous hollow UI traps are guarded or honestly labelled:
  - Lacapult self-update is disabled until Lacapult has public releases.
  - C-AOL Summarizer controls are dry-run/status-only and say so.
  - Backend controls save metadata and readiness status, not secrets or silent installs.
  - OpenVINO is described as Windows-first/detect-only for v0.
  - Play/Resume has macOS launch preflight and blocks known non-portable C-AOL package dylib failures instead of crashing mysteriously.
- The largest remaining release blocker is not a click-path bug: the selected C-AOL macOS `v0.2.0` app bundle does not launch on this Mac because it links unbundled `/opt/local/lib/libfreetype.6.dylib` and `/opt/local/lib/libz.1.dylib` paths. That is a C-AOL package portability lane, not a Lacapult menu-flow issue.
- Windows still needs a real exported Lacapult build smoke and Josef laptop test before public release confidence. Local export proofs are good, but not the same as a normal-user Windows install/open/play pass.

## Small fixes made during this audit

### 1. C-AOL changelog link no longer opens an inherited empty PR dialog

Problem: the inherited `View Changelog` link was meaningful for DDA/BN GitHub PR streams, but C-AOL release users expect release notes. For C-AOL it was a misleading inherited door.

Fix: when `game == "caol"`, the link label becomes **View C-AOL release page** and opens the selected release's GitHub page, falling back to `https://github.com/josihosi/Cataclysm-AOL/releases`.

Files:

- `scripts/Catapult.gd`

### 2. Godot debug/test window is no longer configured as a one-pixel postage stamp

Problem: `project.godot` had `window/size/test_width=1` and `window/size/test_height=1`. That produced flaky visual QA and could make debug launches look broken when the app itself existed.

Fix: set debug/test dimensions to the normal 600x700 launcher size.

Files:

- `project.godot`

## Persona click map

### Persona 1 — fresh normal Windows user: install C-AOL v0.2.0 and play

Expected path:

1. Open Lacapult Doobdab.
2. Stay on **Game** tab.
3. Confirm target is C-AOL.
4. Click **Refresh** if releases are not loaded.
5. Select the platform-matching `v0.2.0` Windows asset.
6. Click **Install Selected**.
7. Wait for download/extract/install status.
8. Confirm active install appears.
9. Click **Play**.

What makes sense now:

- Release metadata and install paths have deterministic proofs.
- The visible install button has already been click-smoked in an isolated HOME.
- Local unsigned Windows export/package shape is proven, but not yet Josef-laptop-proven.

Remaining risk:

- A real Windows laptop pass is still required. The app may be locally exportable and still fail a normal user's OS/package/permissions reality check, because software distribution enjoys being a goblin.

### Persona 2 — fresh macOS/Linux user

Expected path:

1. Open Lacapult.
2. Select platform release.
3. Install.
4. Press **Play** only if launch preflight is green.

What makes sense now:

- macOS DMG install shape is proven in a sandbox.
- macOS Play/Resume preflight now reports the actual C-AOL package portability blocker instead of letting the binary abort.
- Linux package export shape is proven locally.

Remaining risk:

- macOS C-AOL `v0.2.0` currently fails because the upstream app bundle references non-bundled local dylibs. Lacapult should not pretend to fix that.
- Linux needs real package/open/run evidence before public release confidence.

### Persona 3 — backend setup user: API, Ollama, OpenVINO

Expected path:

1. Open **Settings**.
2. Use **C-AOL NPC backend setup**.
3. Choose API / Ollama / OpenVINO.
4. Fill endpoint/model/Python/env-var fields as applicable.
5. Click **Save backend setup metadata**.
6. Read backend readiness/status text.

What makes sense now:

- API path stores provider/model/env-var metadata only; it does not store or print secrets.
- Ollama path checks command/server/model-list state without pulling models.
- OpenVINO path is plainly Windows-first/detect-only for v0 and does not install packages or download/convert models.
- Backend option apply to real C-AOL config is sandbox-proven, but not exposed as a real-user mutation button.

Remaining risk:

- The next product decision should favor **backend recommendation/setup** before real generation/apply UI. A Summarizer generation button without a good backend recommendation path would be a shiny button wired to user confusion. Ja eh.
- C-AOL runtime still has hardcoded API provider behavior in source; Lacapult must not overpromise arbitrary API provider routing until C-AOL consumes it.

### Persona 4 — mod-curious user: mods and Summarizer status

Expected path:

1. Open **Mods**.
2. Inspect installed/available mods.
3. Read C-AOL summary badges/status.
4. Click **Summarizer dry-run**.
5. Optionally inspect Settings status too.

What makes sense now:

- Mods tab and Settings tab both expose C-AOL mod/Summarizer status.
- Dry-run buttons explicitly say no backend call, no generated pack, no apply, and no userdata mutation.
- Slice 3-5 proofs cover sandbox apply/rollback, runtime consumption, and error/rollback matrix.

Remaining risk:

- Real user generation/apply UI is intentionally not wired yet. This is correct for now; the UI should remain status-only until backend recommendation is less miserable.

### Persona 5 — returning user with an installed game

Expected path:

1. Open Lacapult.
2. Existing install appears in **Game Installs**.
3. Use **Make Active** if needed.
4. Use folder buttons for game/user dir inspection.
5. Use **Play** / **Resume** when preflight permits.
6. Use **Backups** if backup/restore is needed.
7. Use **Mods**, **Tilesets**, **Soundpacks**, and **Fonts** for inherited asset management.

What makes sense now:

- Inherited tabs are still present rather than silently deleted.
- Backups and launch-before-backup setting remain visible.
- C-AOL-specific launch preflight now prevents at least one known bad launch class from becoming a mysterious crash.

Remaining risk:

- Inherited DDA/BN/TLG catalog compatibility does not automatically mean C-AOL compatibility. Where C-AOL truth is not proven, UI/status must keep saying untested rather than supported.

### Persona 6 — failure/confused user

Expected failure paths:

- Backend dependency missing.
- API env var not set.
- Ollama missing/server down/model missing.
- OpenVINO packages/model dir missing.
- Broken/obsolete mod metadata.
- Missing/partial/stale/conflicting generated summaries.
- C-AOL launch package not portable.

What makes sense now:

- Existing proofs cover backend-not-ready gates, broken modinfo, content parse errors, missing dependencies, obsolete mods, partial/stale/conflicting summaries, and rollback restore.
- macOS launch package failure is surfaced as preflight status.

Remaining risk:

- The UI is still dense. For Josef's own testing this is acceptable; for public release a shorter first-run wizard would be kinder.

## Tab/menu audit summary

### Game tab

- **Refresh:** meaningful; fetches C-AOL release data.
- **Stable/Experimental:** C-AOL forces stable and disables channel choice, which is sensible for release-targeted `v0.2.0`.
- **View C-AOL release page:** meaningful after this audit; opens selected/fallback GitHub release page.
- **Install Selected:** meaningful; sandbox and clicked GUI proof exist.
- **Play/Resume:** meaningful only after active install; preflight blocks known bad C-AOL package portability on macOS.
- **Open/Search Wiki:** disabled for C-AOL; acceptable because no C-AOL wiki path is wired. Better disabled than a fake search.
- **Update Lacapult:** disabled because no public Lacapult release endpoint exists. Acceptable for pre-release; should be hidden or moved before public release if still disabled.

### Mods tab

- Installed/available mod lists remain useful.
- C-AOL status/badges are read-only and honest.
- Summarizer dry-run is useful as a status explainer, not fake generation.
- Real install/enable/apply is not feature-complete yet; do not relabel as done.

### Tilesets / Soundpacks / Fonts

- Inherited asset-management surfaces remain intact.
- No C-AOL-specific dead end found in source audit, but these need normal-user package smoke later because inherited logic may have C-AOL path edge cases.

### Backups

- Backup-before-launch remains visible and useful.
- Restore/delete flows should be tested with an installed Windows package before public release.

### Settings

- Backend setup panel is visible near the top, before inherited settings sprawl.
- API/Ollama/OpenVINO labels and status wording are honest enough for v0.
- C-AOL mod/Summarizer bridge panel says the native summary roots and no-real-apply state.

### About / Debug

- About remains suitable for attribution/support context.
- Debug tab is developer-facing; acceptable for pre-release but public release may want it hidden behind an advanced toggle.

## Remaining blockers before release confidence

1. **Windows normal-user test:** exported Lacapult package opens on Josef's Windows laptop, fetches C-AOL `v0.2.0`, installs the Windows asset, and reaches Play/Resume without a launcher-side crash.
2. **Backend recommendation/setup lane:** choose recommended default path in-product. Current recommendation: API for fastest onboarding/debug, Ollama as mainstream local backend, OpenVINO visible as Windows-first/specialized. Do this before real Summarizer generation/apply UI.
3. **Real user generation/apply UI:** still intentionally absent. Keep dry-run/status-only until backend readiness/recommendation is clear enough.
4. **C-AOL macOS package portability:** not a Lacapult UI blocker for Windows testing, but a public macOS release blocker.
5. **Public distribution hygiene:** signing/notarization/GitHub release/tags/upstream contact still require separate clearance.

## Recommendation

Do **not** public-release yet.

Do a Josef Windows test build next, but label it as a pre-release test packet. The launcher is coherent enough to test on Windows; it is not yet proven enough to hand to strangers with a straight face and a dry biscuit.

Next implementation lane I would pick: **backend recommendation/setup**, not real generation/apply UI. The Summarizer already has enough sandbox proof to be real later, but the user needs guidance on which backend to choose before the app asks them to generate anything.
