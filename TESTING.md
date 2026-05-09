# TESTING

Current validation policy and evidence index for Catapult-Dabubu (formerly Lacapult Doobdab).

## Validation policy

Use the smallest evidence that honestly matches the change.

- Docs/README/license-only changes: grep/static inspection and `git diff --check`.
- GDScript/UI copy/node-path changes: static scan plus Godot scene load or UI smoke when available.
- Release parsing/install changes: live or fixture release JSON proof, selected asset metadata proof, and sandboxed install-shape proof before any real user path.
- Backend setup changes: config-shape and safe local detection proof; no real API secrets, package installs, or model pulls unless explicitly cleared.
- Mod/Summarizer changes: status/discovery proof first, then sandbox generated packs and rollback; never mutate Josef's real Application Support data in automated proof.
- Public pushes, releases, or upstream contact: external actions requiring explicit clearance.

## Current proof target

**Active validation target:** `Catapult-Dabubu Windows retest follow-up v3` is active after Josef's 2026-05-09 v2 Windows retest notes. The v2 Draft/prerelease exposed fresh blockers: save/apply semantics do not commit the selected LLM runner setup as expected, Windows Ollama CPU/iGPU fallback is painfully slow and needs honest status, mod compatibility/procedure still feels half-done beyond catalog seeding, and C-AOL local NPC speech can leak raw `<think>` reasoning output. This is not a quarantine lift or final/public-confidence claim.

Minimum evidence for the active v3 slice:
- source/static proof for the chosen `Save options` / apply action contract, including backend mode, selected API/Ollama model, runner mode, runner enablement, and no-secret boundaries;
- Godot UI smoke for API and Ollama save/apply behavior that inspects the sandboxed C-AOL options/apply artifact rather than only launcher fields;
- hardware/status fixture proof that CPU-only/iGPU Windows local mode renders as slow fallback/amber-red, distinct from accelerated local mode, while keeping compact RAM/VRAM/model lights;
- mod procedure proof in fixture/sandbox for Magiclysm/DinoMod or current targets: discovery, compatibility/status, enable/install/apply plan, summarizer readiness or precise blockers, and no real user-data mutation;
- `<think>` boundary proof if the seam is in Lacapult scope; otherwise a precise cross-repo blocker/handoff for the C-AOL runner/speech path;
- focused regression smokes for backend setup, Ollama workflow, Windows retest UI, mod procedure/status, and package proof;
- GitHub Draft/prerelease verification only if a fresh Josef-only Windows v3 package is published;
- Josef/Windows confirmation before closing the v3 visible setup/mod/runtime complaints.

Previous v2 evidence remains below as footing, not closure for the new v3 notes.

Catapult-Dabubu Windows retest follow-up v3 intake/canon evidence landed on 2026-05-09:

- Raw intake preserved in `doc/josef-catapult-dabubu-debug-intake-2026-05-09.md`.
- Repair packet, imagination source, and Alex handoff added under `doc/catapult-dabubu-windows-retest-followup-v3-2026-05-09.md`, `doc/catapult-dabubu-windows-retest-followup-v3-imagination-source-2026-05-09.md`, and `doc/alex-catapult-dabubu-windows-retest-followup-v3-2026-05-09.md`.
- Top-level `Plan.md`, `TODO.md`, `SUCCESS.md`, and `TESTING.md` now mark v3 as active and v2 as Windows-retested/superseded.
- Safety boundary: docs/canon sync only; no live API call, API secret readout, package-manager install, Python venv creation, Ollama request/model pull, public release action, or real Application Support/user-data mutation was performed.

Catapult-Dabubu Windows retest follow-up v3 Nemotron no-think setup slice landed on 2026-05-09:

- Source/static proof: `python3 tools/prove_windows_retest_followup_v2_backend_static.py` now verifies the Nemotron setup source/runtime split: source tag `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`, runtime alias `nemotron-9b-dumber:latest`, Modelfile `SYSTEM /no_think`, alias creation through `ollama create`, and explicit no-duplicate-weight boundary.
- Installer packet/backend contract proof: `python3 tools/prove_backend_setup_installer_packet.py` and `python3 tools/prove_caol_backend_contract.py` pass with the no-think alias shape.
- Godot Ollama UI smoke: `HOME=$(mktemp -d /tmp/lacapult-v3-ollama-home.XXXXXX) godot --path . --no-window -s tools/godot_ollama_workflow_smoke.gd` proves the short-label Ollama UI still renders, direct Nemotron plan normalizes `nemotron-9b` to `nemotron-9b-dumber:latest`, Save options also rewrites an old/source Nemotron setting to that no-think runtime alias, preserves source `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`, writes a `/no_think` Modelfile, creates the no-think alias, and records proof-mode setup intent without installer, venv creation, model pull, alias create, API call, or real user config mutation.
- Remaining caveat: this is the Lacapult installer/procedure mitigation. C-AOL still needs its runner/speech hard strip/reject/retry seam before the raw `<think>` product bug can be fully closed.


Catapult-Dabubu Windows retest follow-up v2 backend/setup slice local evidence landed on 2026-05-06:

- Static/source proof: `python3 tools/prove_windows_retest_followup_v2_backend_static.py` verifies API setup uses `any-llm-sdk[...]` provider extras while preserving `any_llm` import checks; normal API base URL is hidden except custom/advanced override; Ollama labels map to runtime tags `mistral:v0.3` and `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`; hardware display uses GiB plus model-specific performance lights; and API package failures capture/surface non-secret command output summaries.
- API failure/status boundary proof: `python3 tools/prove_api_setup_status_copy_boundary.py` verifies proof-mode vs real setup status copy and package-output failure surfacing without API calls or secret reads.
- Godot API UI smoke: `HOME=$(mktemp -d /tmp/lacapult-v2-api-home.XXXXXX) godot --path . --no-window -s tools/godot_api_anyllm_workflow_smoke.gd` proves provider/model/env-var/session-key controls render with normal base URL hidden, OpenRouter default base URL is derived on save, `any-llm-sdk[openrouter]` is staged in proof mode, and no secret/pip/API call occurs.
- Godot Ollama UI smoke: `HOME=$(mktemp -d /tmp/lacapult-v2-ollama-home.XXXXXX) godot --path . --no-window -s tools/godot_ollama_workflow_smoke.gd` proves short labels, exact runtime tags, GiB RAM/VRAM fixture display, Mistral/Nemotron performance lights, short timeout wording, proof-only setup intent, and no installer/model pull/API/user-data mutation.
- Regression smokes: `HOME=$(mktemp -d /tmp/lacapult-v2-save-home.XXXXXX) godot --path . --no-window -s tools/godot_backend_setup_save_check_smoke.gd` and `HOME=$(mktemp -d /tmp/lacapult-v2-win-v1-home.XXXXXX) godot --path . --no-window -s tools/godot_windows_retest_followup_v1_smoke.gd` pass after updating the prior v1 expectations to the v2 GiB/performance-light shape.
- Safety boundary: no live API call, API secret readout, package-manager install, Python venv creation, Ollama model pull, public release action, or real Application Support/user-data mutation was performed.

Catapult-Dabubu Windows retest follow-up v2 runner-test slice local evidence landed on 2026-05-06:

- Static/source proof: `python3 tools/prove_windows_retest_followup_v2_backend_static.py` now also verifies API/Ollama runner test buttons, `caol_runner_test_intent.json`, C-AOL `tools/llm_runner/runner.py` path resolution, `--backend`/`--dry-run`/`--self-test` command shaping, and no-secret/no-surprise-spend UI copy.
- Godot API UI smoke: `HOME=$(mktemp -d /tmp/lacapult-v2-api-runner-home.XXXXXX) godot --path . --no-window -s tools/godot_api_anyllm_workflow_smoke.gd` proves `Test API runner` renders, confirms against a sandbox active-install `tools/llm_runner/runner.py`, records a green proof-mode runner intent, and performs no API call, secret read, package install, venv creation, or real user-data mutation.
- Godot Ollama UI smoke: `HOME=$(mktemp -d /tmp/lacapult-v2-ollama-runner-home.XXXXXX) godot --path . --no-window -s tools/godot_ollama_workflow_smoke.gd` proves `Test Ollama runner` renders, confirms against a sandbox active-install `tools/llm_runner/runner.py`, records a green proof-mode runner intent with selected `mistral:v0.3`, and performs no Ollama request, install, model pull, API call, or real user-data mutation.
- Direct C-AOL runner dry-run proof: `python3 /Users/josefhorvath/Schanigarten/Cataclysm-AOL/tools/llm_runner/runner.py --backend api --api-provider openrouter --api-model openai/gpt-4.1-mini --api-key-env LACAPULT_NO_SECRET --dry-run` and `python3 /Users/josefhorvath/Schanigarten/Cataclysm-AOL/tools/llm_runner/runner.py --backend ollama --ollama-url http://127.0.0.1:11434 --ollama-model mistral:v0.3 --dry-run` both printed `dry-run ok`.
- Safety boundary: proof-mode runner tests exercise the C-AOL runner command route with `--dry-run`; live API/Ollama self-tests remain explicit confirmation actions only.

Catapult-Dabubu Windows retest follow-up v2 JSON-mod catalog/summarizer footing evidence landed on 2026-05-07:

- Source/UI shape: C-AOL `ModManager.refresh_available()` now seeds Magiclysm and DinoMod from the active stock/user/mod_repo roots when present, tags them as `caol-json-*` catalog entries, and `ModsUI` shows them as `[JSON catalog; Summarizer]` instead of leaving the C-AOL Downloadable catalog empty. If neither target is found, the empty-state names the checked roots and reports Magiclysm/DinoMod unavailable precisely.
- Status-model shape: Godot and Python C-AOL mod status models now expose `json_catalog_targets` for `magiclysm` and `DinoMod`, including present/unavailable state, source type, JSON file count, content flags, dependency status, and summary status.
- Fixture/static proof: `python3 tools/prove_caol_mod_status_model.py` proves Magiclysm and DinoMod as stock JSON mods with C-AOL summary-missing/Summarizer-candidate status.
- Godot catalog smoke: `HOME=$(mktemp -d /tmp/lacapult-v2-json-mod-catalog-home.XXXXXX) godot --path . --no-window -s tools/godot_caol_json_mod_catalog_smoke.gd` proves the visible catalog seeding and status target shape from an isolated C-AOL install fixture.
- Godot status smoke: `LACAPULT_CAOL_MOD_STATUS_FIXTURE=.proof-cache/caol-mod-status-fixture HOME=$(mktemp -d /tmp/lacapult-caol-mod-status-home.XXXXXX) godot --path . --no-window -s tools/godot_caol_mod_status_smoke.gd` proves the Godot status mirror sees Magiclysm/DinoMod JSON catalog targets and summary-missing status. The fixture deliberately includes broken-metadata JSON and emits expected parse-error log lines while still passing.
- Regression proof also passed in the same gate: `python3 tools/prove_windows_retest_followup_v2_backend_static.py`, `python3 tools/prove_api_setup_status_copy_boundary.py`, `tools/godot_api_anyllm_workflow_smoke.gd`, `tools/godot_ollama_workflow_smoke.gd`, `tools/godot_backend_setup_save_check_smoke.gd`, `tools/godot_windows_retest_followup_v1_smoke.gd`, and `git diff --check`.
- Safety boundary: no live API call, API secret readout, package-manager install, Python venv creation, Ollama request/model pull, public release action, or real Application Support/user-data mutation was performed.

Catapult-Dabubu Windows retest follow-up v2 packaging/release evidence landed on 2026-05-07:

- Package proof: `python3 tools/prove_lacapult_export_packaging.py` exported the fresh Windows package `.proof-cache/lacapult-export/packages/Catapult-Dabubu-windows-unsigned.zip` (66,616,377 bytes, SHA-256 `492d63fbfeebdc44874d61093020dcba0f036ef61ac2859f79559caed96a0849`) with entries `Catapult-Dabubu.exe`, `utils/7-ZIP_LICENSE`, and `utils/7za.exe`; package `SHA256SUMS.txt` SHA-256 is `f866e2e9ff30d768bc15a66bbef8f9da75b88d4326b604fdb1ecf933d5e163fa`, and uploaded `manifest.json` SHA-256 is `4057e7ceed26c72b56d708112e95b5d61720f01e2d0619eb0ba0ea9b08909d16`.
- GitHub Draft/prerelease verification: `gh release view catapult-dabubu-josef-windows-retest-v2-2026-05-07 --repo josihosi/Lacapult-Doobdab --json tagName,name,isDraft,isPrerelease,targetCommitish,url,assets` reported Draft=true, Prerelease=true, target `dfae55db0bedd458360e5dbf201bee0e1ae61bc8`, URL `https://github.com/josihosi/Lacapult-Doobdab/releases/tag/untagged-d5b5f0671b6676dfc344`, and uploaded assets `Catapult-Dabubu-windows-unsigned.zip`, `SHA256SUMS.txt`, `manifest.json`, and `Catapult-Dabubu-josef-windows-retest-v2-build-notes-2026-05-07.md`.
- Release copy says Josef-only Windows validation for v2, not stable/latest/final/public confidence and not a C-AOL release.
- Safety boundary: Draft/prerelease test release only; no quarantine lift, no public/final release claim, no repository rename, no package/model install, no live API call, and no real user-data mutation as proof.

Open for v2 after this slice: Josef Windows retest.


Catapult-Dabubu Windows retest follow-up v1 local evidence landed on 2026-05-02:

- Static/source proof: `python3 tools/prove_windows_retest_followup_v1_static.py` verifies no backend emoji traffic-light source remains, API setup has venv + AnyLLM phases, Ollama has RAM/VRAM hardware check + serialized setup/wait warning, Mods label says built-in game mods, native-resizable window metrics are present, and C-AOL Downloadable/Summarizer clarity copy exists.
- API status boundary proof: `python3 tools/prove_api_setup_status_copy_boundary.py` verifies proof mode records no external install/download, real setup status says venv + AnyLLM/provider packages were handled, and failure copy stays secret/API-call safe.
- Backend contract proof: `python3 tools/prove_caol_backend_contract.py` verifies Lacapult still maps C-AOL backend option/readiness tokens without secret-bearing fields and performs no API call/model pull/user config mutation.
- Godot UI smoke: `HOME=$(mktemp -d /tmp/lacapult-v1-home.XXXXXX) godot --path . --no-window -s tools/godot_windows_retest_followup_v1_smoke.gd` proves proof-only API venv + AnyLLM package intent, explicit colored big-dot status rows for API/Ollama/hardware, fixture RAM/VRAM rendering, and no Ollama pull queued while command/server are not ready.
- Regression UI smokes also pass with isolated HOME: `tools/godot_api_anyllm_workflow_smoke.gd`, `tools/godot_backend_setup_save_check_smoke.gd`, `tools/godot_ollama_workflow_smoke.gd`, `tools/godot_llm_tab_declutter_smoke.gd`, `tools/godot_windows_retest_fix_smoke.gd`, and `tools/godot_window_chrome_inspection.gd`.
- Package proof: `python3 tools/prove_lacapult_export_packaging.py` exported the fresh Windows package `.proof-cache/lacapult-export/packages/Catapult-Dabubu-windows-unsigned.zip` (66,587,417 bytes, SHA-256 `a0ae09628349df1f6840b68b6328f8ef066892f0a7a1a8dc6f5a70f8ebe3ac5d`) with entries `Catapult-Dabubu.exe`, `utils/7-ZIP_LICENSE`, and `utils/7za.exe`; package `SHA256SUMS.txt` SHA-256 is `0d05542b69f33b0526bd58684a5411366ad32b504b90849024d77a18fc0d28dc`.
- GitHub Draft/prerelease verification: `gh release view catapult-dabubu-josef-windows-retest-v1-2026-05-02 --repo josihosi/Lacapult-Doobdab --json tagName,name,isDraft,isPrerelease,targetCommitish,url,assets` reported Draft=true, Prerelease=true, target `655da7831c8cc1a6bd68b4b495307615106ecf9a`, URL `https://github.com/josihosi/Lacapult-Doobdab/releases/tag/untagged-6c700e3ce1114782def5`, and uploaded assets `Catapult-Dabubu-windows-unsigned.zip`, `SHA256SUMS.txt`, `manifest.json`, and `Catapult-Dabubu-josef-windows-retest-v1-build-notes-2026-05-02.md`.
- Safety boundary: no live API call, API secret readout, package-manager install, Python venv creation, Ollama model pull, public/final release publication, or real Application Support/user-data mutation was performed.

Previous validation target: `Lacapult Windows retest fix v0` produced the 2026-05-01 Draft/prerelease package, but Josef's 2026-05-02 retest failed the installer-vision/status-light/text-density bar. Keep its evidence below as footing, not closure.

Prior v0 evidence for reference:
- focused Godot UI smoke/static scans for titlebar/window metrics, popup/dialog/tooltip wrapping/bounds, and long-text wrapping/newlines;
- API / AnyLLM setup proof for `backend_external_setup_proof_only` default/safe read, install-progress/status copy, and venv/package semantics without live secrets or unapproved pip installs;
- Ollama setup proof for model-choice persistence, readiness-light text, split installer/server/model-pull failure reporting, and Mistral/Nemotron hardware guidance using fixtures where possible;
- Catapult-Dabubu naming/identity surface scan for user-facing/package/release text, with explicit note for any intentionally retained Lacapult/internal/upstream references;
- fresh package proof from current `main` using `python3 tools/prove_lacapult_export_packaging.py`;
- Windows package shape includes `Catapult-Dabubu.exe` and `utils/7za.exe`;
- checksums/build manifest exist for the attached assets;
- GitHub release is Draft if feasible, or prerelease if draft asset access is awkward;
- release notes clearly say Josef Windows validation only, not public/stable/final confidence.

Catapult-Dabubu Josef Windows retest release evidence landed on 2026-05-01:

- GitHub Draft/prerelease test release: `https://github.com/josihosi/Lacapult-Doobdab/releases/tag/untagged-cb4272b172c83b11deff`.
- Tag/name reported by `gh release view`: `catapult-dabubu-josef-windows-retest-2026-05-01` / `Catapult-Dabubu Josef Windows retest build 2026-05-01`; target commitish `9c13fdbd9843d01a9debdaf818a7b27b68b6dde6`.
- Attached Windows asset: `Catapult-Dabubu-windows-unsigned.zip`, 66,565,257 bytes, SHA-256 `d001c22f2adf34b51879ae326cdd6d85334d630c30cf480b31da520608475753`.
- Attached checksums/manifest: `SHA256SUMS.txt` SHA-256 `d1ad293c441cccc05e95a67e5f395e8b3e4d174ea5470d415d098987e7d7b684`; `manifest.json` SHA-256 `dcaadfeebded7f2fcccd7dfc721519ca76ee84f636c68bb02671bd8107d33b36`.
- Release copy says Josef-only Windows validation, not stable/latest/final/public confidence and not a C-AOL release.
- Safety boundary: Draft/prerelease test release only; no quarantine lift, no public/final release claim, no repository rename, no package/model install, no live API call, and no real user-data mutation as proof.

Windows retest fix local repair evidence landed on 2026-05-01:

- Godot UI smoke: `HOME=$(mktemp -d /tmp/lacapult-retest-home.XXXXXX) godot --path . --no-window -s tools/godot_windows_retest_fix_smoke.gd` proved enlarged default/test window metrics, bounded/autowrapped backend confirmation dialog, deliberate newline confirmation copy, safe `backend_external_setup_proof_only` default read, API venv/package split copy, and Ollama Mistral/Nemotron hardware guidance/default model behavior.
- API workflow smoke: `HOME=$(mktemp -d /tmp/lacapult-api-anyllm-home.XXXXXX) godot --path . --no-window -s tools/godot_api_anyllm_workflow_smoke.gd` proved API controls plus `Create venv only` / `Install AnyLLM packages`, safe Check/Save behavior, and proof-mode AnyLLM setup intent without pip/API/secret use.
- Setup action smoke: `HOME=$(mktemp -d /tmp/lacapult-backend-setup-home.XXXXXX) godot --path . --no-window -s tools/godot_backend_setup_save_check_smoke.gd` proved Save/Check/Install action rendering and save-before-confirm behavior with the updated copy.
- Ollama workflow smoke: `HOME=$(mktemp -d /tmp/lacapult-ollama-workflow-home.XXXXXX) godot --path . --no-window -s tools/godot_ollama_workflow_smoke.gd` proved one model choice, hardware guidance, readiness-light fixture states, save/check/setup proof mode, and no installer/venv/model/API/user-config mutation.
- Static/status proof: `python3 tools/prove_api_setup_status_copy_boundary.py` still passes, and source scan confirms no stale old `Install venv` / `Install API backend` strings remain in `scripts/` or `tools/`.
- Safety boundary: all proof stayed local/sandboxed; no live API call, API secret, package-manager install, Python venv creation, Ollama model pull, release publication, or real Application Support/user-data mutation.

Catapult-Dabubu identity evidence landed on 2026-05-01:

- Static/project proof: `project.godot` product name, custom titlebar, first Game-tab identity copy, disabled update copy, English about/tips text, and safe backend/setup/mod metadata now use `Catapult-Dabubu` where user-facing.
- Package proof target: `python3 tools/prove_lacapult_export_packaging.py` now exports `Catapult-Dabubu` app/executable/package names and keeps the Windows 7-Zip sidecar shape.
- Identity proof: `python3 tools/prove_lacapult_identity_surface.py` verifies `Catapult-Dabubu` project/titlebar/Game-tab/About/package surfaces while explicitly retaining `josihosi/Lacapult-Doobdab` as the GitHub repo URL until a public repo rename is confirmed.
- Retained lineage boundary: upstream `Catapult`, `Dabdoob/Catapult_Dabdoob`, and C-AOL attribution remains intentional; inherited internal scene/node/script names are not part of this rename slice.
- Packaging proof: `python3 tools/prove_lacapult_export_packaging.py` produced `.proof-cache/lacapult-export/packages/Catapult-Dabubu-windows-unsigned.zip` (66,565,257 bytes, SHA-256 `d001c22f2adf34b51879ae326cdd6d85334d630c30cf480b31da520608475753`) plus `SHA256SUMS.txt` (SHA-256 `d1ad293c441cccc05e95a67e5f395e8b3e4d174ea5470d415d098987e7d7b684`). Windows zip entries are exactly `Catapult-Dabubu.exe`, `utils/7-ZIP_LICENSE`, and `utils/7za.exe`.

Josef test release evidence landed on 2026-04-27:

- GitHub Draft/prerelease test release: `https://github.com/josihosi/Lacapult-Doobdab/releases/tag/untagged-62e620a97f3b0edaa8ca`.
- Tag/name reported by `gh release view`: `lacapult-josef-test-2026-04-27` / `Lacapult Doobdab Josef test build 2026-04-27`; target commit `e1c05d66d7937010e98adab52355c7987ec21f08`.
- Attached Windows asset: `Lacapult-Doobdab-windows-unsigned.zip`, 66,552,571 bytes, SHA-256 `cb999fdee5d6aaf1b8f8adde428923ee65265266666b281108ec2ecc624caaf7`.
- Attached build notes/checksums: `SHA256SUMS.txt` SHA-256 `3d37262be1267e51a3c4868fbd8b150ca9c1263a898a3b4d8e15b4e6618f15a7`; `manifest.json` SHA-256 `4ac42282af5eb0568644cdc153d89afc7e989c73419dbed2e8b8d69de9db5e84`.
- Package shape proof: Windows zip entries are exactly `Lacapult-Doobdab.exe`, `utils/7-ZIP_LICENSE`, and `utils/7za.exe`.
- Safety boundary: Draft/prerelease test release only; no stable/latest/final claim, no C-AOL release work, no package/model install, no live API call, and no real user-data mutation as proof.

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

- Godot UI smoke: `HOME=$(mktemp -d /tmp/lacapult-ollama-workflow-home.XXXXXX) godot --path . --no-window -s tools/godot_ollama_workflow_smoke.gd` proved Ollama mode renders exactly one visible model-choice control (`mistral-v0.3` / `nemotron-9b`), compact Ollama command/server/Mistral/Nemotron/Python/options readiness lights, `Save options`, `Check`, `Install Ollama / model`, and `Create venv only`.
- Fixture readiness proof: the same smoke uses `LACAPULT_OLLAMA_FIXTURE` to prove command-missing, server-unreachable, model-present, and model-missing light states without contacting/pulling real models.
- Check/save/setup proof: `Check` remains detection-only/no config write; `Save options` round-trips Ollama endpoint/model/Python metadata into sandbox launcher config/options patch; `Install Ollama / model` and `Create venv only` save first and record confirmation-gated setup intents in proof mode.
- Safety boundary: automated proof performs no platform package-manager install, no Ollama model pull, no Python venv creation, no API call, and no real Application Support/user-data mutation.

Package 3 evidence landed on 2026-04-27:

- Godot UI smoke: `HOME=$(mktemp -d /tmp/lacapult-api-anyllm-home.XXXXXX) godot --path . --no-window -s tools/godot_api_anyllm_workflow_smoke.gd` proved API base URL/provider/model/env-var/session-key controls, compact status lights, `Save options`, `Check`, and `Install AnyLLM packages` render in API mode without Ollama/hardware copy leaking into the API seam.
- Sandbox config/options proof: provider `openrouter`, API base URL, model, Python path, and env-var name round-trip into launcher metadata/options patch without storing the pasted fake API key.
- Safe setup/install-path proof: `Install AnyLLM packages` saves first, shows a confirmation-gated AnyLLM pip command preview, and the production path can run `python -m pip install --upgrade any_llm[...]` through `OS.execute` without shell interpolation; the automated smoke enables proof mode so it records the setup intent only. No automated pip install, live API call, real secret read, model pull, or real Application Support mutation is performed.
- Source/static proof: API setup output stores only provider/model/base URL/env-var metadata and setup result summary; it does not store command output or API-key material.
- Boundary-copy proof: `python3 tools/prove_api_setup_status_copy_boundary.py` verifies proof-only status copy says no external install/download while the real pip path says pip may have installed/upgraded packages, without running pip.

Package 3 remaining manual/cleared evidence: an actual pip install/import run in a deliberately disposable Python environment may be added later if Josef/Schani explicitly clears package installation proof. It is not required for the no-install automated gate.

Before any renewed republish/confidence claim, evidence must include:

- real Windows first-launch click-through from the extracted package;
- first window / first visible tab identity check;
- release-row wording and install/download impression check;
- confirmation that the player sees Lacapult as launcher, not as a mistaken C-AOL game archive;
- 2026-05-01 Windows screenshot feedback: top row/titlebar still looks visually wrong, so the chrome-fix confidence claim remains reopened; next proof should adjust default window/layout metrics and require another Windows screenshot/retest.

## Pending evidence - debug-note correction stack

Canonical contract: `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`.

Validate packages as follows:

- LLM tab de-clutter/backend-scope correction: static scan plus Godot scene/load or UI smoke proving `LLM` tab label, short helper copy, no stale `1000 tokens` claim, and no visible Lacapult OpenVINO installer choice while hidden in-game support remains deliberate.
- Setup save/check pattern: UI/static proof for Save options, Check, status lights, and Install-saves-first ordering; sandboxed config/options round-trip proof.
- API / AnyLLM workflow: UI proof for API base URL/provider/model/env-var controls and status lights; sandboxed install/import proof where safe; no real secrets or remote API calls in automated gates.
- Ollama workflow: COMPLETE via UI proof for one model-choice control, Mistral/Nemotron readiness lights, Check, Save, Install Ollama / model, Create venv only, and mocked/fixture model-present/missing/error states; no automated model pulls/installs were performed.
- Window chrome investigation: LOCAL COMPLETE / WINDOWS CONFIRMATION PENDING; `HOME=$(mktemp -d /tmp/lacapult-window-chrome-home.XXXXXX) godot --path . --no-window -s tools/godot_window_chrome_inspection.gd` proves the local root-cause class is custom scene chrome (`project.godot` borderless window + `scenes/CustomTitleBar.tscn` inside `scenes/Catapult.tscn`), not native OS chrome, and proves the visible metric seam changed from titlebar `32px` / main offset `36px` / icon `24x24` / buttons `32x24` / vertical margins `4px` to titlebar `28px` / main offset `32px` / icon `20x20` / buttons `28x20` / vertical margins `2px`. The Windows confirmation checklist is in `doc/lacapult-window-chrome-investigation-packet-2026-04-27.md`; Windows/Josef visual confirmation is still separate and required before claiming cross-platform appearance fixed.

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
- Window chrome investigation packet / Windows checklist: `doc/lacapult-window-chrome-investigation-packet-2026-04-27.md`.
- Josef test release packet: `doc/lacapult-josef-test-release-v0-2026-04-27.md`.
- Windows retest fix packet: `doc/lacapult-windows-retest-fix-packet-v0-2026-05-01.md`.
- Windows retest imagination source: `doc/lacapult-windows-retest-fix-imagination-source-2026-05-01.md`.
- Windows retest raw intake: `doc/josef-windows-debug-intake-2026-05-01.md`.
- Windows retest executor handoff: `doc/alex-lacapult-windows-retest-fix-handoff-2026-05-01.md`.

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
- focused `rg` source/UI scans for API base URL/provider/model/session-secret controls, `Install AnyLLM packages`, proof-mode no-pip boundary, real-pip status copy, and no secret leakage

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
