# TESTING

Current validation policy and evidence index for Lacapult Doobdab.

## Validation policy

Use the smallest evidence that honestly matches the change.

- Docs/README/license-only changes: grep/static inspection and `git diff --check`.
- GDScript/UI copy/node-path changes: static scan plus Godot scene load or UI smoke when available.
- Release parsing/install changes: live or fixture release JSON proof, selected asset metadata proof, and sandboxed install-shape proof before any real user path.
- Backend setup changes: config-shape and safe local detection proof; no real API secrets, package installs, or model pulls unless explicitly cleared.
- Mod/Summarizer changes: status/discovery proof first, then sandbox generated packs and rollback; never mutate Josef's real Application Support data in automated proof.
- Public pushes, releases, or upstream contact: external actions requiring explicit clearance.

## Current proof target

**Active Lacapult implementation is reopened for Alex.** Current validation target is Package 1 from the debug-note correction stack: `LLM tab de-clutter + backend-scope correction v0`.

Package 1 evidence must include:

- static scan proving the visible backend tab/page is now `LLM`;
- static scan proving old sprawling helper copy and the stale `around 1000 tokens` claim are gone;
- static scan proving visible Lacapult OpenVINO installer/setup choices are removed while hidden/in-game support is not accidentally deleted;
- Godot scene/load or UI smoke proving the changed label/helper copy render in the actual UI.

Before any renewed republish/confidence claim, evidence must include:

- real Windows first-launch click-through from the extracted package;
- first window / first visible tab identity check;
- release-row wording and install/download impression check;
- confirmation that the player sees Lacapult as launcher, not as a mistaken C-AOL game archive.

## Pending evidence - debug-note correction stack

Canonical contract: `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`.

Validate packages as follows:

- LLM tab de-clutter/backend-scope correction: static scan plus Godot scene/load or UI smoke proving `LLM` tab label, short helper copy, no stale `1000 tokens` claim, and no visible Lacapult OpenVINO installer choice while hidden in-game support remains deliberate.
- Setup save/check pattern: UI/static proof for Save options, Check, status lights, and Install-saves-first ordering; sandboxed config/options round-trip proof.
- API / AnyLLM workflow: UI proof for API base URL/provider/model/env-var controls and status lights; sandboxed install/import proof where safe; no real secrets or remote API calls in automated gates.
- Ollama workflow: UI proof for one model-choice control, Mistral/Nemotron readiness lights, Check, Save, and Install actions; mocked/fixture model-present/missing/error states; no automated model pulls unless cleared.
- Window chrome investigation: screenshot/UI artifact evidence separated by macOS/local versus Windows/Josef behavior before claiming a cross-platform fix.

No debug-stack proof may mutate real Application Support config/saves/mods, install packages/models, use API secrets, publish releases, or republish quarantined artifacts without explicit clearance.

## Evidence index

Detailed evidence is intentionally stored in auxiliary docs instead of repeated here.

- Release quarantine / identity: `doc/lacapult-release-quarantine-investigation-2026-04-26.md`.
- Launcher test release / 7-Zip hotfix: `doc/lacapult-launcher-test-release-packet-2026-04-26.md`.
- Post-mod UI Windows retest release: `doc/lacapult-post-mod-ui-windows-retest-release-packet-2026-04-26.md`.
- LLM backend setup installer packet: `doc/lacapult-llm-backend-setup-installer-packet-v0-2026-04-26.md`.
- Mod/Summarizer feature plan and proof shape: `doc/lacapult-mod-summarizer-feature-plan-2026-04-25.md`.
- C-AOL mod compatibility summary: `doc/caol-mod-compatibility-summary.md`.
- Click-level GUI audit: `doc/lacapult-click-level-gui-audit-2026-04-25.md`.
- Outsider GUI reasoning run: `doc/lacapult-gui-reasoning-reddit-cdda-install-run-2026-04-26.md`.
- One-shot installer north star: `doc/lacapult-one-shot-installer-vision.md`.
- v0.2 release/backend/modding contract: `doc/lacapult-v02-release-backend-modding-contract.md`.
- Debug-note correction stack: `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`.

Recent gate commands used for canon-only cleanup:
- `git diff --check`
- static presence checks for debug stack / active quarantine references

## Known risk spots

- Godot 3 scene node paths are brittle; prove scene load after node-path or UI tree changes.
- The release manager has inherited multi-game assumptions; hiding other games is safer than deleting support blindly.
- Public product identity must preserve lineage while not making the app look like Dabdoob/Catapult or like a C-AOL game archive.
- Backend install/setup flows touch secrets, packages, models, and user config; default automated tests must stay mocked/sandboxed.
- Windows appearance cannot be fully trusted from macOS-only proof; keep platform evidence separate.
