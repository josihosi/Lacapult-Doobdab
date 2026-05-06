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

Still open:

- API/Ollama runner test buttons that exercise the C-AOL runner path under explicit safe/no-surprise-spend boundaries.
- JSON mod catalog/summarizer footing for Magiclysm/DinoMod.
- Broader focused regression/package proof and fresh Josef-only Windows v2 Draft/prerelease after local proof.

Hollow-rock suspicion: runner-test and Mods catalog remain real v2 blockers; this checkpoint only closes the backend setup/model/hardware wording slice, not the full v2 lane.
