# Alex handoff — Lacapult Windows retest fix v0

Classification: active / greenlit now.

Canonical contract: `doc/lacapult-windows-retest-fix-packet-v0-2026-05-01.md`.
Imagination source: `doc/lacapult-windows-retest-fix-imagination-source-2026-05-01.md`.
Raw intake: `doc/josef-windows-debug-intake-2026-05-01.md`.

## Scope order

1. Shared popup/window layout repair:
   - top row/window metrics follow-up from Josef screenshot;
   - popup/dialog/tooltip width bounds;
   - wrapping/newlines/scrollable long text;
   - include API AnyLLM Install venv popup and User-of-this-session tooltip.

2. API / AnyLLM setup repair:
   - default/safe read for `backend_external_setup_proof_only`;
   - visible long-running install/progress state;
   - coherent venv/package behavior: either install AnyLLM deps with setup or rename/split the empty-venv action honestly.

3. Ollama setup repair:
   - persist/read Mistral/Nemotron selection;
   - restore meaningful readiness lights;
   - split installer/server/model-pull failure reporting;
   - verify Windows `winget install --id Ollama.Ollama -e` behavior;
   - add visible hardware suitability check/guidance for Mistral/Nemotron.

4. Fresh Josef-only Windows retest release:
   - build/package current fixed state;
   - create/update clearly labelled GitHub Draft/prerelease test release;
   - attach Windows asset, checksums, build notes;
   - verify with `gh release view`.

## Non-goals

- No release quarantine lift.
- No public/stable/latest/final Lacapult release.
- No C-AOL release work.
- No real API calls/secrets/user-data mutation in automated gates.
- No automated package install or model pull in proof without fresh explicit clearance.

## Evidence expectations

- Godot UI smoke/static scans for layout/wrapping/titlebar metrics.
- API AnyLLM smoke for missing setting default, progress/status copy, venv/package semantics.
- Ollama smoke/fixtures for model persistence, readiness lights, split failure reporting, and hardware guidance.
- `python3 tools/prove_lacapult_export_packaging.py` before release.
- `gh release view` proof after the test release.

## Trap list

- Do not close from macOS-only appearance proof; Windows retest remains separate.
- Do not let “Install venv” mean one thing in API mode and another unclear thing in Ollama mode without UI copy making it obvious.
- Do not collapse Ollama installer failure and model-pull failure into one vague line.
- Do not publish a public-looking release by accident; this is Josef validation only.
