# Lacapult click-level GUI audit — 2026-04-25

Scope: pre-release confidence pass for Lacapult Doobdab as a C-AOL launcher. This is not a signing, tagging, release, or publication pass.

Evidence classes used:

- Source click-map review of `scenes/Catapult.tscn` plus the tab/controller scripts.
- Isolated live launch with a temporary `HOME` so the pass did not intentionally mutate Josef's real C-AOL Application Support data.
- Peekaboo screenshots for the first-launch Game tab and the C-AOL release-page handoff.
- Existing Godot/Python smoke tests listed in `TESTING.md` and rerun for touched areas.

Live UI automation caveat: Peekaboo coordinate clicks were flaky with the Godot 3 debug window on this Mac/retina setup. The Game tab was visually verified; source-level click mapping plus existing Godot smokes were used for the other tabs. Source inspection is not being presented as full visual QA.

Runtime artifacts kept under:

- `~/.openclaw/workspace/runtime/lacapult-click-audit-2026-04-25/`
- Key screenshots: `relaunch-screen.png`, `screen-after-patch.png`, `screen-see-after-patch.png`, `game-tab-after-patch.png`

## Release-readiness verdict

`ready-for-Josef-Windows-test`

Meaning: the launcher no longer has obvious hollow/dead-end C-AOL controls in the audited paths, and the high-risk v0 limitations are now surfaced as status-only/config-only rather than pretending to do more. This is still not a public release greenlight. Final release confidence still needs Josef's Windows click-through of install -> play -> resume/settings/mods/backups on the packaged build.

## Persona click map

### 1. Fresh Windows user: install C-AOL v0.2.0 and play

Click path:

1. Launch Lacapult.
2. Confirm game selector is `Cataclysm: Arsenic and Old Lace`.
3. Read the C-AOL description.
4. See channel fixed to release/stable for C-AOL; experimental is disabled.
5. Open available builds.
6. Select `Cataclysm - Arsenic and Old Lace v0.2.0 ... windows.zip` on Windows.
7. Click `Install Selected`.
8. Wait for download/extract/move status in the log.
9. Confirm `Active install` changes from `None` to the installed release.
10. Click `Play`.
11. If a previous world exists, click `Resume Last World`.
12. Use `GameDir` / `UserDir` folder icons if troubleshooting paths.

Audit read:

- The selected build item includes installability/asset status and tooltips include release page/asset details.
- Install refuses releases with no platform asset instead of pretending they can install.
- With no active install, Play/Resume are disabled.
- The `Update current active install` checkbox is now visually unchecked when no active install exists, so a fresh user is not invited to update something that does not exist.

Remaining Windows-specific proof needed:

- A real Windows packaged-build click-through must confirm the `.zip` asset selection, extraction root, executable launch, `--userdir`, and resume behavior.

### 2. Fresh macOS/Linux user: platform differences and launch preflight

Click path:

1. Launch Lacapult.
2. Select/read C-AOL build list.
3. On macOS, select the `.dmg` asset if present; on Linux, select the `.tar.gz` asset.
4. Install.
5. Observe active-install launch preflight.
6. Click Play only if preflight allows it.

Audit read:

- `ReleaseInstaller.gd` searches the extracted root differently on Windows vs Linux/macOS and has specific `.app` bundle handling.
- macOS has C-AOL launch preflight for missing/non-portable local dylibs and blocks launch when known missing dylibs would make the package fail.
- The preflight text explicitly says Lacapult can report package portability issues, not repair them.

Remaining macOS/Linux caveat:

- This remains package-sensitive. If the C-AOL macOS artifact links `/opt/local`, `/usr/local`, or `/opt/homebrew` dylibs, Lacapult surfaces the problem instead of hiding it. That is acceptable launcher behavior, but not proof that the macOS game package is portable.

### 3. Backend setup user: API, Ollama, OpenVINO

Click path:

1. Click `Settings`.
2. Find `C-AOL NPC backend setup` near the top of Settings.
3. Choose backend: `Recommended: API backend`, `Local: Ollama backend`, or `Windows-first: OpenVINO backend`.
4. Fill endpoint/model/Python/env-var fields as relevant.
5. Read the status/guidance block.
6. Click `Save backend setup metadata`.

Audit read:

- Backend UI is config/status, not an installer.
- The UI now recommends API first for fastest Windows onboarding/debug, Ollama second as the mainstream local path, and OpenVINO third as Windows-first specialized/detect-only.
- API path stores only provider/model/env-var metadata; secrets stay in environment variables.
- Ollama path states no model pull is attempted.
- OpenVINO path states Windows-first v0 and no automated runtime/model install.
- Backend detection reports missing Python/import/model-dir/API-key-env statuses instead of silently downloading or calling anything.

Dead-end risk checked:

- No backend selection claims it will install OpenVINO, pull Ollama models, call an API, or fix missing dependencies. The v0 promise is intentionally narrow.

### 4. Mod-curious user: mods, Summarizer status, dry-run

Click path:

1. Install/activate a C-AOL game first; until then, `Mods` is disabled by the base launcher gating.
2. Click `Mods`.
3. Select available/installed mods.
4. Read badges: enabled/disabled, summary-ready/missing/partial, obsolete/dependency/metadata blocked.
5. Click `Summarizer dry-run`.
6. Read the status message.
7. Use install/delete buttons for actual mod file operations only.

Audit read:

- The Summarizer surface is explicitly status-only.
- Dry-run tooltip and status text say no backend call, generated pack, apply, enable, or save mutation happens.
- Settings has a second read-only C-AOL packaged-mod compatibility block with the same limitation.
- Generation/apply is not exposed as a real-user-active button. Good; no hollow promise here.

Remaining product limitation:

- The inherited mod UI is dense, and compatibility-date fetching may feel technical. This is tolerable for v0, but future UX should separate simple mod install from compatibility diagnostics.

### 5. Returning user with an installed game

Click path:

1. Launch Lacapult.
2. Read `Active install`.
3. Click `Play`.
4. Click `Resume Last World` if lastworld exists.
5. Open `GameDir` or `UserDir` for troubleshooting.
6. Use `Backups` for manual/automatic saves.
7. Use `Settings` for backend setup and launcher preferences.
8. Use `Mods`, `Tilesets`, `Soundpacks`, `Fonts` after an install exists.
9. If multiple installs exist, use the installs list: select -> `Make Active`; double-click opens install folder; `Delete` removes an install.

Audit read:

- Installed-game-only tabs remain disabled until an install exists, preventing most empty dead ends.
- Multiple-install controls are disabled until a list item is selected.
- Backups are reachable only when there is enough game/userdata context for them to make sense.

### 6. Failure user: missing deps, blocked launch package, obsolete/broken mod, backend-not-ready

Click path / statuses:

- Missing platform asset: build list says no asset for this platform and install is disabled.
- Release has no assets: build list says no release assets yet and install is disabled.
- Missing install folder/executable: launch preflight reports the specific missing folder/executable.
- macOS non-portable package: launch preflight names the missing dylibs and blocks launch.
- API backend not ready: status reports Python/import/provider/model/env-var readiness without reading secrets.
- Ollama backend not ready: status reports endpoint/model/Python/import readiness; no model pull.
- OpenVINO not ready: status reports Windows-first/config-only/runtime/model-dir readiness; no install.
- Obsolete/dependency-blocked mod: mod badges and detail text show blocked status.

Audit read:

- The important failure paths now either disable the action, show status, or log a specific reason. No high-risk path silently proceeds into a promised install/download/API action that v0 cannot actually deliver.

## Dead ends / hollow promises found

1. C-AOL changelog link still behaved like inherited Catapult experimental changelog.
   - Why it was hollow: C-AOL uses GitHub releases, not the inherited experimental changelog dialog.
   - Fix: for C-AOL, the link is now labeled `View C-AOL release page` and opens the selected C-AOL release page, falling back to the releases index.

2. Fresh-user Game tab could show `Update current active install` as checked even with `Active install: None`.
   - Why it was hollow: the disabled checked state suggested Lacapult might update an install that does not exist.
   - Fix: when no install exists, the checkbox is disabled and visually unchecked; when an install exists, the stored setting is restored.

3. `Update Lacapult` was visible but disabled while self-update is intentionally unavailable.
   - Why it was hollow: the button title suggested an action that cannot exist until public Lacapult releases exist.
   - Fix: when self-update is disabled, the button text changes to `Lacapult update unavailable` with a direct tooltip.

## Small fixes made

- `project.godot`: changed debug test window size from `1x1` to `600x700`, so local debug launches are visually inspectable instead of appearing as a one-pixel/black-window trap.
- `scripts/Catapult.gd`: C-AOL release link now routes to the selected release page and has C-AOL-specific label/tooltip.
- `scripts/Catapult.gd`: fresh no-install state no longer displays a checked `Update current active install` checkbox.
- `scripts/Catapult.gd`: disabled self-update now says unavailable in the button itself.
- `scripts/BackendConfigManager.gd`, `scripts/SettingsUI.gd`, `tools/godot_backend_triad_smoke.gd`: Settings now exposes the backend recommendation order and the smoke asserts that the order/warnings stay present.

## Remaining blockers before public release confidence

- Windows packaged-build click-through: install C-AOL v0.2.0, play, create/enter world, quit, resume, verify userdir isolation.
- Windows backend setup smoke from the packaged app, especially Python path / env-var / Ollama URL fields.
- Windows mod tab smoke after an install exists: install/enable ordinary mod, read Summarizer status, press dry-run, confirm no generation/apply mutation.
- Backups tab smoke with a real save directory.
- Optional but wise: reduce first-screen text density and lore-heavy wording before broad public users see it.

## Recommendation

Proceed to Josef Windows testing. Do not publish/release yet. If Josef's Windows test confirms install -> play -> resume and the Settings/Mods/Backups flows behave as mapped here, this audit no longer sees a launcher-shaped hollow spot blocking a release candidate.
