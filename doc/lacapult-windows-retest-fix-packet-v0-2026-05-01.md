# Lacapult Windows retest fix packet v0 — 2026-05-01

Status: active / greenlit from Josef Windows test feedback.

Imagination source: `doc/lacapult-windows-retest-fix-imagination-source-2026-05-01.md`.

Raw intake: `doc/josef-windows-debug-intake-2026-05-01.md`.

## Summary

Fix the Windows retest blockers Josef found in the Lacapult test build, then produce another clearly labelled Josef-only Windows test release. The work is one active follow-up lane with three ordered repair packets: shared popup/window layout, API / AnyLLM setup semantics/progress, and Ollama model/readiness/hardware-check behavior.

This does not lift release quarantine and does not authorize a public/final/stable Lacapult release.

## Scope

### Packet 1 — shared popup/window layout repair

- Revisit the custom titlebar/default-window metrics from the Windows screenshot feedback.
- Fix shared popup/dialog/tooltip sizing so button popups do not become wider than the launcher and do not cut off half their content.
- Add width constraints, wrapping/autowrap, deliberate newlines/bullets, and/or scrollable bodies for long popup/help text.
- Cover at least the API AnyLLM `Install venv` popup and `User of this session` tooltip family.

### Packet 2 — API / AnyLLM setup semantics and progress repair

- Add a default/safe read for `backend_external_setup_proof_only` so release builds stop logging nonexistent-setting errors.
- Make long-running installs show an in-progress/waiting state instead of looking crashed or timed out while work continues.
- Repair API / AnyLLM venv/package semantics: either make the relevant action create/update the venv and install AnyLLM/provider deps, or rename/split actions so the UI makes the empty-venv step and AnyLLM install step impossible to misunderstand.
- Keep API secrets out of saved config/logs.

### Packet 3 — Ollama readiness/model/hardware repair

- Fix Ollama model-choice persistence/state so Mistral/Nemotron selections are actually read by readiness/setup.
- Make readiness lights distinguish command, server, selected model(s), Python/venv, options, and unknown/failure states without confusing `?` fallbacks.
- Split Ollama installer, CLI/server detection, and model-pull result reporting so failures are actionable.
- Verify the Windows install plan (`winget install --id Ollama.Ollama -e`) and explain whether it provides the expected CLI/server behavior.
- Add a visible hardware suitability check or honest hardware guidance for Mistral and Nemotron.

### Packet 4 — rename / identity pass

- Treat `Catapult-Dabubu` as the target user-facing product/package/release name for the next test build.
- Update visible app/window/about/release/package naming enough that the fresh artifact does not still look like `Lacapult-Doobdab` wearing a fake moustache.
- Preserve attribution/lineage for upstream Catapult/Dabdoob and C-AOL.
- Do **not** rename the GitHub repository or perform other public repo-operation changes without fresh explicit Schani/Josef confirmation.

### Final retest release

- After fixes and gates, build/package a new Windows unsigned test artifact using the agreed current test-build naming.
- Create or update a clearly labelled GitHub Draft/prerelease test release for Josef only.
- Attach Windows package, checksums, and build notes.
- Verify remote release shape with `gh release view`.

## Non-goals

- No public/stable/latest/final Lacapult release claim.
- No GitHub repository rename without fresh explicit confirmation, even though `Catapult-Dabubu` is the target rename item.
- No release quarantine lift.
- No C-AOL `v0.3.0` or C-AOL game packaging work.
- No live API calls, API secret reads, real user data mutation, automated package installs, or automated model pulls in proof without fresh explicit clearance.
- No OpenVINO installer expansion.
- No broad redesign of all Lacapult tabs unless required to fix the shared popup/layout seam.

## Success state

- [ ] Popup/dialog/tooltip content wraps or scrolls and is no longer cut off by launcher bounds in the tested Windows flows.
- [ ] Top row/window metrics receive a follow-up fix and remain explicitly Windows-retest-gated.
- [ ] `backend_external_setup_proof_only` missing-setting log spam is gone.
- [ ] Long-running install actions visibly show in-progress/working state and do not imply a crash while commands continue.
- [ ] API / AnyLLM setup has coherent venv/package behavior and clear UI copy.
- [ ] Ollama model selection persists, readiness lights are meaningful, model pull/install failures are separated, and Mistral/Nemotron hardware suitability is visible or honestly bounded.
- [ ] Automated gates cover scene/UI smoke plus source/static checks for the repaired seams without external installs/model pulls/API calls/secrets.
- [x] A fresh Josef-only Windows test release exists with Windows asset, checksums/build notes, and verified GitHub Draft/prerelease shape.

## Testing expectations

- Run focused Godot UI smoke(s) for popup/dialog wrapping and titlebar/default-window metrics where feasible.
- Extend API AnyLLM smoke to cover missing setting default, venv/package semantics, and progress/status copy without running real pip unless explicitly cleared.
- Extend Ollama smoke to cover selected model persistence, readiness-light text, hardware-check/guidance text, and split failure reporting with fixtures.
- Add source/static checks for old/new product-name surfaces before creating the retest release.
- Run `python3 tools/prove_lacapult_export_packaging.py` before creating the retest release.
- Use `gh release view` to verify the release/tag/assets/checksums after publication.

## Handoff caution

Josef's notes are user-visible Windows evidence. Do not close this lane from macOS-only confidence. Local smoke and the Draft/prerelease package prove source/package/release shape, but the final status remains waiting on the new Josef Windows retest.
