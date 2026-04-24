# TESTING

Current validation policy and evidence for Lacapult Doobdad.

## Validation policy

Use the smallest evidence that honestly matches the change.

- Docs/README/license-only changes: grep/static inspection is enough.
- GDScript release parsing changes: live GitHub JSON fixture or small script proof plus static inspection.
- UI node-path changes: Godot parse/load or GUI smoke if Godot is available; otherwise record missing Godot binary as blocker and prove paths by inspection.
- Installer/download changes: avoid huge downloads unless needed; first prove metadata shape and asset selection, then optionally test one small or current-platform release asset if acceptable.
- Public repo creation/push: external action, requires explicit clearance.

## Current evidence

Initial source audit from Schani:

- Source repo `Hihahahalol/Catapult_Dabdoob` is public, standalone, and MIT licensed.
- Source tech is Godot/GDScript with helper Python/Shell scripts.
- Source `LICENSE` includes qrrk and Dabdoob copyright notices.
- Source README credits CDDA, CTLG, BN, and qrrk Catapult.
- Local scaffold created at `/Users/josefhorvath/Schanigarten/Lacapult-Doobdad` by copying source without inherited `.git` history and initializing a new local git repo.

## Required v0 proof packet

Before claiming v0 is done, Andi should record:

1. Identity/attribution proof
   - `grep -R` evidence that public identity points to Lacapult Doobdad/C-AOL.
   - Remaining Dabdoob/Catapult references are credits or internal filenames intentionally left for later.

2. Release parsing proof
   - live `gh release view` or GitHub API capture for `josihosi/Cataclysm-AOL`.
   - platform filter result for the current OS.
   - at least one expected asset selected from `v0.2.0` or latest release assets.

3. Godot/static proof
   - `godot --version` / `godot3 --version` / `godot4 --version` check.
   - If Godot exists: run the strongest cheap headless/project parse check available for this version.
   - If Godot does not exist: state that clearly and rely on static grep plus code-shape proof for first handoff.

4. Installer-shape proof
   - show the release object handed to installer has `name`, `url`, `filename`, `published_at`, `has_any_assets`.
   - do not download a huge release archive unless Schani/Josef explicitly wants that proof.

## Known risk spots

- Godot 3 scene node paths may break if the game chooser/channel UI is removed too aggressively.
- Existing release manager duplicates per-game callbacks; adding C-AOL by copy may be safer for v0 than a clever refactor.
- Existing mod/soundpack/tileset code assumes multiple Cataclysm game IDs; hiding other games is safer than deleting support everywhere in the first slice.
- Existing self-update URL points to Dabdoob and must not silently offer Dabdoob releases as Lacapult updates.
