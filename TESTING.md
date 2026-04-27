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

**Active Lacapult implementation is reopened for Alex.** Current validation target is Package 5 from the debug-note correction stack: `Lacapult window chrome investigation v0`.

Package 2 evidence landed on 2026-04-27:

- source/UI scan: backend setup action row now renders `Save options`, `Check`, and backend-specific install actions instead of the old long save/install copy;
- source/UI scan: setup status text uses compact `🟢/🟡/🔴` status-light vocabulary via `BackendConfig.get_status_light()`;
- Godot UI smoke: `godot --path . --no-window -s tools/godot_backend_setup_save_check_smoke.gd` proved Check refreshes readiness without writing backend config, Save persists current API UI fields to sandboxed launcher config/options metadata, and the Ollama install action saves fields before the confirm-gated setup intent;
- safety boundary: no package install, model pull, live API call, API-secret read, or real Application Support mutation in the proof.

Package 1 evidence landed on 2026-04-27:

- source/scene scan: visible backend tab/page is now `LLM`;
- source/scene scan: old sprawling helper copy and stale `around 1000 tokens` product copy are absent from the visible UI seam;
- source/scene scan: visible Lacapult OpenVINO setup choice is removed from `BackendSetupUI.gd` while `BackendConfigManager.gd` still preserves hidden/sandboxed OpenVINO config/readiness support;
- Godot UI smoke: `godot --path . --no-window -s tools/godot_llm_tab_declutter_smoke.gd` rendered the actual BackendSetupUI labels/options and loaded `scenes/Catapult.tscn` with `Main/Tabs/LLM`.

Package 4 evidence landed on 2026-04-27:

- Godot UI smoke: `HOME=$(mktemp -d /tmp/lacapult-ollama-workflow-home.XXXXXX) godot --path . --no-window -s tools/godot_ollama_workflow_smoke.gd` proved Ollama mode renders exactly one visible model-choice control (`mistral-v0.3` / `nemotron-9b`), compact Ollama command/server/Mistral/Nemotron/Python/options readiness lights, `Save options`, `Check`, `Install Ollama / model`, and `Install venv`.
- Fixture readiness proof: the same smoke uses `LACAPULT_OLLAMA_FIXTURE` to prove command-missing, server-unreachable, model-present, and model-missing light states without contacting/pulling real models.
- Check/save/setup proof: `Check` remains detection-only/no config write; `Save options` round-trips Ollama endpoint/model/Python metadata into sandbox launcher config/options patch; `Install Ollama / model` and `Install venv` save first and record confirmation-gated setup intents in proof mode.
- Safety boundary: automated proof performs no platform package-manager install, no Ollama model pull, no Python venv creation, no API call, and no real Application Support/user-data mutation.

Package 3 evidence landed on 2026-04-27:

- Godot UI smoke: `HOME=$(mktemp -d /tmp/lacapult-api-anyllm-home.XXXXXX) godot --path . --no-window -s tools/godot_api_anyllm_workflow_smoke.gd` proved API base URL/provider/model/env-var/session-key controls, compact status lights, `Save options`, `Check`, and `Install API backend` render in API mode without Ollama/hardware copy leaking into the API seam.
- Sandbox config/options proof: provider `openrouter`, API base URL, model, Python path, and env-var name round-trip into launcher metadata/options patch without storing the pasted fake API key.
- Safe setup/install-path proof: `Install API backend` saves first, shows a confirmation-gated AnyLLM pip command preview, and the production path can run `python -m pip install --upgrade any_llm[...]` through `OS.execute` without shell interpolation; the automated smoke enables proof mode so it records the setup intent only. No automated pip install, live API call, real secret read, model pull, or real Application Support mutation is performed.
- Source/static proof: API setup output stores only provider/model/base URL/env-var metadata and setup result summary; it does not store command output or API-key material.
- Boundary-copy proof: `python3 tools/prove_api_setup_status_copy_boundary.py` verifies proof-only status copy says no external install/download while the real pip path says pip may have installed/upgraded packages, without running pip.

Package 3 remaining manual/cleared evidence: an actual pip install/import run in a deliberately disposable Python environment may be added later if Josef/Schani explicitly clears package installation proof. It is not required for the no-install automated gate.

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
- Ollama workflow: COMPLETE via UI proof for one model-choice control, Mistral/Nemotron readiness lights, Check, Save, Install Ollama / model, Install venv, and mocked/fixture model-present/missing/error states; no automated model pulls/installs were performed.
- Window chrome investigation: ACTIVE; `HOME=$(mktemp -d /tmp/lacapult-window-chrome-home.XXXXXX) godot --path . --no-window -s tools/godot_window_chrome_inspection.gd` proves the local root-cause class is custom scene chrome (`project.godot` borderless window + `scenes/CustomTitleBar.tscn` inside `scenes/Catapult.tscn`), not native OS chrome, and proves the visible metric seam changed from titlebar `32px` / main offset `36px` / icon `24x24` / buttons `32x24` / vertical margins `4px` to titlebar `28px` / main offset `32px` / icon `20x20` / buttons `28x20` / vertical margins `2px`. Windows/Josef visual confirmation is still separate and required before claiming cross-platform appearance fixed.

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

Recent gate commands used for Package 5:
- `HOME=$(mktemp -d /tmp/lacapult-window-chrome-home.XXXXXX) godot --path . --no-window -s tools/godot_window_chrome_inspection.gd`
- `rg -n "window/size/borderless|CustomTitleBar|MinimizeButton|MaximizeButton|CloseButton|OS.window|allow_hidpi|use_hidpi" project.godot scenes scripts`

Recent gate commands used for Package 4:
- `HOME=$(mktemp -d /tmp/lacapult-ollama-workflow-home.XXXXXX) godot --path . --no-window -s tools/godot_ollama_workflow_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-api-anyllm-home.XXXXXX) godot --path . --no-window -s tools/godot_api_anyllm_workflow_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-save-check-home.XXXXXX) godot --path . --no-window -s tools/godot_backend_setup_save_check_smoke.gd`
- `python3 tools/prove_caol_backend_contract.py`
- focused `rg` source/UI scans for duplicate Ollama model fields, Mistral/Nemotron lights, confirmation-gated Ollama/model and Python venv setup intents, and fixture no-pull boundaries

Recent gate commands used for Package 3:
- `HOME=$(mktemp -d /tmp/lacapult-api-anyllm-home.XXXXXX) godot --path . --no-window -s tools/godot_api_anyllm_workflow_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-save-check-home.XXXXXX) godot --path . --no-window -s tools/godot_backend_setup_save_check_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-llm-ui-home.XXXXXX) godot --path . --no-window -s tools/godot_llm_tab_declutter_smoke.gd`
- `python3 tools/prove_caol_backend_contract.py`
- `python3 tools/prove_api_setup_status_copy_boundary.py`
- focused `rg` source/UI scans for API base URL/provider/model/session-secret controls, `Install API backend`, proof-mode no-pip boundary, real-pip status copy, and no secret leakage

Recent gate commands used for Package 2:
- `HOME=$(mktemp -d /tmp/lacapult-save-check-home.XXXXXX) godot --path . --no-window -s tools/godot_backend_setup_save_check_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-llm-ui-home.XXXXXX) godot --path . --no-window -s tools/godot_llm_tab_declutter_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-backend-triad-home.XXXXXX) godot --path . --no-window -s tools/godot_backend_triad_smoke.gd`
- focused `rg` source/UI scans for Save options, Check, status lights, Install-saves-first ordering, and old long setup-copy absence

Recent gate commands used for Package 1:
- `python3 tools/prove_backend_setup_installer_packet.py`
- `python3 tools/prove_caol_backend_contract.py`
- `HOME=$(mktemp -d /tmp/lacapult-llm-ui-home.XXXXXX) godot --path . --no-window -s tools/godot_llm_tab_declutter_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-backend-triad-home.XXXXXX) godot --path . --no-window -s tools/godot_backend_triad_smoke.gd`
- focused `rg` source/scene scans for LLM tab copy, stale helper/token copy, and visible OpenVINO setup absence

## Known risk spots

- Godot 3 scene node paths are brittle; prove scene load after node-path or UI tree changes.
- The release manager has inherited multi-game assumptions; hiding other games is safer than deleting support blindly.
- Public product identity must preserve lineage while not making the app look like Dabdoob/Catapult or like a C-AOL game archive.
- Backend install/setup flows touch secrets, packages, models, and user config; default automated tests must stay mocked/sandboxed.
- Windows appearance cannot be fully trusted from macOS-only proof; keep platform evidence separate.
