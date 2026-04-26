# Lacapult LLM backend setup installer packet v0 — 2026-04-26

## Classification

ACTIVE / GREENLIT FOR ANDI.

## User request

Josef's Windows launcher test showed that the current backend setup surface is too messy and too internal. Lacapult is an installer, so C-AOL backend setup should be a first-class installer flow instead of a Settings-tab debug panel with platform-test copy.

## Scope

- Move the LLM backend setup flow out of the generic Settings surface into its own launcher tab.
- Title the tab/page exactly: `C-AOL LLM backend setup`.
- Rewrite backend setup copy for a normal C-AOL player:
  - no Josef/test-run-specific wording
  - no “Windows-first” phrasing in player-facing recommendation copy
  - no internal/debug labels such as raw status keys where a user-facing sentence belongs
  - keep any platform limitations as plain, neutral compatibility notes
- Provide a guided installer pathway with explicit confirmation before external changes.
- Stage all three backend paths without making one giant science project:
  - API / AnyLLM Python package readiness and install guidance/pathway
  - Ollama local setup, including install/check and model pull pathway
  - OpenVINO package/model setup pathway, still honest about heavier specialized requirements
- For Ollama, offer at least `mistral-v0.3` and `nemotron-9b` model choices.
- Add a hardware recommendation step that inspects safe local signals where available, such as RAM and/or VRAM/GPU info, then recommends a model instead of silently auto-picking.
- Keep user choice final: hardware detection recommends; the user chooses what to install/pull.
- Clean up the About/thank-you page copy where inherited personal crisis text feels out of place for this C-AOL installer; preserve attribution/license gratitude, but replace launcher-personal messaging with normal product copy.

## Non-goals

- Do not actually install packages, pull models, or mutate Josef's machine during automated proofs without explicit confirmation or a sandbox/mocked proof path.
- Do not store API secrets in Lacapult.
- Do not turn the first slice into a full package-manager framework for every OS.
- Do not claim OpenVINO is easy/mainstream if the implementation only provides a guided/specialized path.
- Do not reopen C-AOL `v0.3.0`, signing/notarization, or a new C-AOL game release.
- Do not let the backend installer work interrupt the separately parked C-AOL Smart Zone Manager follow-up.

## Success state

- [ ] Backend setup appears as its own tab/page titled `C-AOL LLM backend setup`.
- [ ] Player-facing text is neutral and contains no Josef/test-run copy or casual platform-first recommendation phrasing.
- [ ] API/AnyLLM, Ollama, and OpenVINO each have a visible guided setup path with confirmation before external install/download actions.
- [ ] Ollama setup offers `mistral-v0.3` and `nemotron-9b` choices, with hardware-based recommendation text and manual override.
- [ ] Automated proof covers the UI/tab/copy shape and confirms installer actions are gated behind explicit confirmation or mocked/sandboxed execution.
- [ ] About/thank-you copy is checked against inherited text and cleaned up for Lacapult without removing required attribution/license credit.

## Testing / evidence bar

Minimum evidence before closure:

- Static or Godot smoke proving the new tab/page exists and the old Settings debug panel is no longer the primary backend setup surface.
- Text scan proving no `Josef`, `Windows test`, or equivalent test-run copy leaks into player-facing backend setup text.
- Safe proof for installer commands/actions showing confirmations and no accidental live package/model install during tests.
- Hardware recommendation proof with at least two fixture cases: low/unknown hardware recommends the lighter model path; stronger hardware recommends or permits the larger model path.
- Existing small Godot/project-load gate and `git diff --check`.

## Notes from live test

Screenshot review showed the backend setup as dense, status-heavy, and mixed into Settings. The user should see an installer flow: pick backend, understand compatibility, confirm install/setup, then configure C-AOL. Not a little museum of internal readiness keys. Na bravo.
