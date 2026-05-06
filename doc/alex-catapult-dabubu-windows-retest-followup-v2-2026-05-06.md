# Alex handoff — Catapult-Dabubu Windows retest follow-up v2

Repo: `/Users/josefhorvath/Schanigarten/Lacapult-Doobdab`
Branch: `main`
Classification: active
Canon contract: `doc/catapult-dabubu-windows-retest-followup-v2-2026-05-06.md`
Imagination source: `doc/catapult-dabubu-windows-retest-followup-v2-imagination-source-2026-05-06.md`
Raw intake: `doc/josef-catapult-dabubu-debug-intake-2026-05-06.md`

## Active item

Catapult-Dabubu Windows retest follow-up v2: repair the v1 retest blockers Josef just finished reporting.

## Implement in bounded state-boundary slices

Recommended first slice order:

1. Fix API package identity and normal API UI:
   - install `any-llm-sdk[...]`, not `any_llm[...]`;
   - preserve `from any_llm import completion` import seam;
   - hide API base URL from normal provider UI; keep advanced/custom override only;
   - improve package setup failure output without secrets.

2. Fix Ollama model tags/labels:
   - Mistral runtime tag `mistral:v0.3`;
   - Nemotron runtime tag `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`;
   - selector uses short labels, not the full Nemotron tag.

3. Fix Ollama hardware/status display:
   - RAM/VRAM in GiB;
   - model-specific performance lights for Mistral/Nemotron;
   - no advisory prose wall;
   - no `Hardware check: missing` when RAM/VRAM were measured.

4. Add runner test buttons:
   - API route runner test, gated/no surprise spend/no secret leakage in proof;
   - Ollama route runner test, no install/no pull.

5. Mods catalog foothold:
   - investigate empty catalog;
   - add JSON mod catalog/summarizer footing for Magiclysm and DinoMod if present/available.

6. Package fresh Josef-only Windows v2 retest build only after local proof.

## Non-goals

- No public/final release or quarantine lift.
- No repo rename.
- No broad provider rewrite beyond this repair.
- No automated live API calls, package installs, model pulls, secrets, or real user-data mutation.
- No full mod ecosystem solve; first useful JSON-mod foothold only.

## Success bar

Do not call this done until:

- API setup preview/intent uses `any-llm-sdk[...]` provider extras.
- Normal API UI has no base URL field.
- Ollama pull/readiness uses real model tags.
- Nemotron selector label stays short.
- Hardware performance lights replace the old recommendation/missing row problem.
- API and Ollama runner test buttons exist and are safely proofed.
- Magiclysm/DinoMod catalog footing is attempted/proofed or precisely reported unavailable.
- Focused smokes/static checks pass.
- Fresh Josef-only Windows Draft/prerelease v2 is uploaded/verified if packaging is reached.

## Validation floor

Run focused proof first, then regressions:

- static scan for any-llm package command and no stale `any_llm[` install target;
- Godot API UI smoke for provider/model/key/setup/check/runner-test and hidden advanced base URL;
- Godot Ollama UI smoke for short labels, exact command tags, GiB hardware display, performance lights, and no `missing` hardware row when measured;
- runner-test fixture proof/no live API proof;
- mod catalog/summarizer fixture proof for JSON mods;
- existing backend/Ollama/Windows-retet smokes;
- packaging proof before GitHub upload.

Final summary must include active item, files touched, validation, package/release state, remaining blocker if any, and whether code was touched.

## Alex local checkpoint — 2026-05-06 backend/setup slice

Implemented/proofed in this slice:

- API setup plan now installs Mozilla any-llm as `any-llm-sdk[...]` provider extras while preserving the `any_llm` import/readiness seam.
- Normal API UI hides the base URL row; it remains available only for the `AnyLLM custom provider` advanced/custom override path, and known providers derive defaults on save.
- API package setup failures now include a bounded captured command-output summary, while still stating that no API call or secret read happened during package setup.
- Ollama selector labels stay short (`Mistral v0.3`, `Nemotron 9B`) while metadata/runtime paths use `mistral:v0.3` and `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`.
- Ollama hardware UI now shows RAM/VRAM in GiB plus Mistral/Nemotron estimated performance lights; the generic `Hardware check: missing` row was removed for measured hardware.
- Ollama install/model warning now uses: `The launcher may appear to time out. Wait for Ollama installation to commence.`

Evidence:

- `python3 tools/prove_windows_retest_followup_v2_backend_static.py`
- `python3 tools/prove_api_setup_status_copy_boundary.py`
- `python3 tools/prove_windows_retest_followup_v1_static.py`
- `HOME=$(mktemp -d /tmp/lacapult-v2-api-home.XXXXXX) godot --path . --no-window -s tools/godot_api_anyllm_workflow_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-v2-ollama-home.XXXXXX) godot --path . --no-window -s tools/godot_ollama_workflow_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-v2-save-home.XXXXXX) godot --path . --no-window -s tools/godot_backend_setup_save_check_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-v2-win-v1-home.XXXXXX) godot --path . --no-window -s tools/godot_windows_retest_followup_v1_smoke.gd`

## Alex local checkpoint — 2026-05-06 runner-test slice

Implemented/proofed in this slice:

- API setup page now exposes `Test API runner`.
- Ollama setup page now exposes `Test Ollama runner`.
- Both buttons save current options first, open an explicit confirmation, and exercise the active C-AOL `tools/llm_runner/runner.py` route rather than only launcher metadata.
- Proof mode invokes the runner with `--dry-run`, records `caol_runner_test_intent.json`, and does not call APIs, read secrets, send Ollama requests, install packages, create venvs, pull models, or mutate real user data.
- Non-proof/manual confirmation path is shaped as one runner self-test for the selected backend; API still warns about possible live spend and passes only the env-var name, while Ollama still forbids install/pull behavior.

Evidence:

- `python3 tools/prove_windows_retest_followup_v2_backend_static.py`
- `HOME=$(mktemp -d /tmp/lacapult-v2-api-runner-home.XXXXXX) godot --path . --no-window -s tools/godot_api_anyllm_workflow_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-v2-ollama-runner-home.XXXXXX) godot --path . --no-window -s tools/godot_ollama_workflow_smoke.gd`
- `python3 /Users/josefhorvath/Schanigarten/Cataclysm-AOL/tools/llm_runner/runner.py --backend api --api-provider openrouter --api-model openai/gpt-4.1-mini --api-key-env LACAPULT_NO_SECRET --dry-run`
- `python3 /Users/josefhorvath/Schanigarten/Cataclysm-AOL/tools/llm_runner/runner.py --backend ollama --ollama-url http://127.0.0.1:11434 --ollama-model mistral:v0.3 --dry-run`

Still open:

- JSON mod catalog/summarizer footing for Magiclysm/DinoMod.
- Broader focused regression/package proof and fresh Josef-only Windows v2 Draft/prerelease after local proof.

Hollow-rock suspicion: proof mode uses runner `--dry-run`; that is the right no-spend automated gate, but not a real API spend/local-model response. Josef/Windows still needs the packaged visible-button retest, and Mods catalog remains the main unimplemented v2 blocker.

## Alex local checkpoint — 2026-05-07 JSON-mod catalog/summarizer footing

Implemented/proofed in this slice:

- C-AOL Mods catalog now seeds Magiclysm and DinoMod from active stock/user/mod_repo roots when present.
- The visible C-AOL Downloadable catalog shows those entries as `[JSON catalog; Summarizer]` instead of an empty shelf, while stock-present entries remain stock/skipped rather than fake downloads.
- If Magiclysm/DinoMod are absent, the empty-state reports the checked roots precisely instead of implying generic emptiness.
- Godot/Python C-AOL status models now expose `json_catalog_targets` for `magiclysm` and `DinoMod`, with present/unavailable state, source type, JSON file count, content flags, dependency status, and summary status.
- Fixture proof treats Magiclysm and DinoMod as JSON Summarizer candidates (`summary-missing`) when enabled and present.

Evidence:

- `python3 tools/prove_windows_retest_followup_v2_backend_static.py`
- `python3 tools/prove_api_setup_status_copy_boundary.py`
- `python3 tools/prove_caol_mod_status_model.py`
- `HOME=$(mktemp -d /tmp/lacapult-v2-json-mod-catalog-home.XXXXXX) godot --path . --no-window -s tools/godot_caol_json_mod_catalog_smoke.gd`
- `LACAPULT_CAOL_MOD_STATUS_FIXTURE=.proof-cache/caol-mod-status-fixture HOME=$(mktemp -d /tmp/lacapult-caol-mod-status-home.XXXXXX) godot --path . --no-window -s tools/godot_caol_mod_status_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-v2-api-home.XXXXXX) godot --path . --no-window -s tools/godot_api_anyllm_workflow_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-v2-ollama-home.XXXXXX) godot --path . --no-window -s tools/godot_ollama_workflow_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-v2-save-home.XXXXXX) godot --path . --no-window -s tools/godot_backend_setup_save_check_smoke.gd`
- `HOME=$(mktemp -d /tmp/lacapult-v2-win-v1-home.XXXXXX) godot --path . --no-window -s tools/godot_windows_retest_followup_v1_smoke.gd`
- `git diff --check`

Still open:

- Fresh Josef-only Windows v2 package/Draft-prerelease verification.
- Josef Windows retest of the v2 package.

Hollow-rock suspicion: this proves catalog seeding/status adapter behavior with fixtures and active install roots; it does not prove Josef's packaged Windows install actually has Magiclysm/DinoMod present until the v2 package is built and clicked on Windows.

## Alex release checkpoint — 2026-05-07 Josef-only Windows v2 Draft/prerelease

Packaged/uploaded after local proof:

- GitHub Draft/prerelease tag: `catapult-dabubu-josef-windows-retest-v2-2026-05-07`
- Release name: `Catapult-Dabubu Josef Windows retest build v2 2026-05-07`
- URL: `https://github.com/josihosi/Lacapult-Doobdab/releases/tag/untagged-d5b5f0671b6676dfc344`
- Source commit: `dfae55db0bedd458360e5dbf201bee0e1ae61bc8`
- Windows asset: `Catapult-Dabubu-windows-unsigned.zip`
- Windows asset size/SHA-256: 66,616,377 bytes / `492d63fbfeebdc44874d61093020dcba0f036ef61ac2859f79559caed96a0849`
- Expected Windows zip entries: `Catapult-Dabubu.exe`, `utils/7-ZIP_LICENSE`, `utils/7za.exe`
- Uploaded support assets: `SHA256SUMS.txt`, `manifest.json`, `Catapult-Dabubu-josef-windows-retest-v2-build-notes-2026-05-07.md`

Verification:

- `python3 tools/prove_lacapult_export_packaging.py`
- `gh release view catapult-dabubu-josef-windows-retest-v2-2026-05-07 --repo josihosi/Lacapult-Doobdab --json tagName,name,isDraft,isPrerelease,targetCommitish,url,assets`
- `gh release view` reported Draft=true and Prerelease=true, target `dfae55db0bedd458360e5dbf201bee0e1ae61bc8`, with the four expected assets uploaded.

Remaining:

- Josef Windows retest of the v2 package.

Hollow-rock suspicion: package shape and release metadata are verified, but all repaired UI/runtime behavior remains Mac-side/Godot-smoke/fixture proof until Josef opens this exact v2 Windows zip and clicks through it.
