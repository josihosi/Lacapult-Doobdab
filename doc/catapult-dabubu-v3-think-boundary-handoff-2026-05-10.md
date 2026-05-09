# Catapult-Dabubu v3 `<think>` boundary handoff

Date: 2026-05-10
Classification: Lacapult-side mitigation complete / C-AOL runner-speech blocker

## Active item

Catapult-Dabubu Windows retest follow-up v3, `<think>` mitigation split.

Josef's v3 report has two separate seams:

1. **Lacapult/Catapult installer procedure:** prepare Nemotron as a no-thinking Ollama runtime alias without duplicating model weights.
2. **Cataclysm-AOL runtime speech hardening:** never let raw `<think>` reasoning text reach NPC `say`, even if the local model ignores prompt/setup hints.

## Lacapult-side state

The Lacapult-side seam is implemented and proofed locally:

- visible/runtime Nemotron tag is `nemotron-9b-dumber:latest`;
- source model remains `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`;
- setup plan writes `Nemotron-9B-no-think.Modelfile` with `SYSTEM /no_think` content;
- setup plan creates the alias with `ollama create nemotron-9b-dumber:latest -f <Modelfile>`;
- setup/proof copy states that Ollama reuses the source model blobs instead of pulling a second full model copy;
- `Save options` normalizes old/source Nemotron selections to the no-thinking runtime alias in sandboxed launcher/C-AOL option artifacts.

Proof rerun on 2026-05-10:

```sh
python3 tools/prove_windows_retest_followup_v2_backend_static.py
python3 tools/prove_backend_setup_installer_packet.py
python3 tools/prove_caol_backend_contract.py
HOME=$(mktemp -d /tmp/lacapult-v3-ollama-reproof-home.XXXXXX) godot --path . --no-window -s tools/godot_ollama_workflow_smoke.gd
```

Safety boundary: no package install, model pull, alias create, API call, secret readout, public release action, or real user config/Application Support/save mutation was performed.

## C-AOL blocker found by inspection

The remaining hard bug is in Cataclysm-AOL, not in the Lacapult repo under Alex's standing role.

Inspected seams:

- `/Users/josefhorvath/Schanigarten/Cataclysm-AOL/tools/llm_runner/runner.py`
  - `ollama_generate()` uses `/api/generate` with `model`, `prompt`, `stream`, and `options`; it does not send a hard `think: false` field or use `/api/chat` content-vs-thinking separation.
  - `strip_think_tags()` only removes a closed `<think>...</think>` block. An output that is only `<think>` or starts an unclosed think block can pass through unchanged.
  - `run_ollama_mode()` writes `text = strip_think_tags(sanitize_text(response.get("response", "")))` without rejecting/retrying empty/unclosed reasoning output.
- `/Users/josefhorvath/Schanigarten/Cataclysm-AOL/src/llm_intent.cpp`
  - ambient speech is extracted by `extract_ambient_speech(resp.text)` and then displayed via `add_msg(_("%s says: \"%s\""), ...)`.
  - normal intent speech computes `speak_text = strip_speaker_prefix(extract_speech_field(csv_text))` and displays it before a hard `<think>` reject/sanitize seam.
  - these paths need a C-AOL-side guard so raw `<think>` cannot become speech/memory, regardless of runner/model behavior.

## Exact blocker / decision needed

Alex should not edit Cataclysm-AOL under the current Lacapult-only role. The remaining product bug needs one of:

1. Schani/Josef assigns the C-AOL runner/speech hardening to Andi or another C-AOL worker; or
2. Schani/Josef explicitly grants Alex cross-repo clearance for this bounded C-AOL seam.

Recommended C-AOL acceptance bar:

- Ollama requests pass a non-thinking signal where supported (`think: false` and/or `/api/chat` content-only handling).
- Runner strips closed `<think>...</think>` blocks and rejects unclosed/leading `<think>` outputs.
- Empty-after-strip output returns an error or triggers one bounded final-only retry/fallback.
- `src/llm_intent.cpp` refuses to call the visible `say`/memory path with text containing `<think>`.
- Fixture proof covers closed think block + final text, unclosed `<think>`, `<think>` only, and normal CSV/speech output.

## Recommended next action

Use this as the cross-repo handoff. Do not claim the v3 `<think>` product bug is fixed until the C-AOL runner/speech boundary is patched/proofed or Josef accepts a v3 package that explicitly carries this known C-AOL caveat.
