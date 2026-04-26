# Lacapult LLM backend setup installer packet v0 — 2026-04-26

## Classification

IMPLEMENTED / SAFE STATIC+GODOT PROOF PASSED / READY FOR SCHANI REVIEW.

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
- Leave the inherited About/thank-you personal support message in place; Josef explicitly okayed keeping it. Still preserve attribution/license credit, and keep backend/setup installer copy neutral for anonymous players.

## Non-goals

- Do not actually install packages, pull models, or mutate Josef's machine during automated proofs without explicit confirmation or a sandbox/mocked proof path.
- Do not store API secrets in Lacapult.
- Do not turn the first slice into a full package-manager framework for every OS.
- Do not claim OpenVINO is easy/mainstream if the implementation only provides a guided/specialized path.
- Do not reopen C-AOL `v0.3.0`, signing/notarization, or a new C-AOL game release.
- Do not let the backend installer work interrupt the separately parked C-AOL Smart Zone Manager follow-up.
- Do not spend this packet rewriting the inherited About/thank-you support message unless Josef explicitly reopens it.

## Success state

- [x] Backend setup appears as its own tab/page titled `C-AOL LLM backend setup`.
- [x] Player-facing text is neutral and contains no Josef/test-run copy or casual platform-first recommendation phrasing.
- [x] API/AnyLLM, Ollama, and OpenVINO each have a visible guided setup path with confirmation before external install/download actions.
- [x] Ollama setup offers `mistral-v0.3` and `nemotron-9b` choices, with hardware-based recommendation text and manual override.
- [x] Automated proof covers the UI/tab/copy shape and confirms installer actions are gated behind explicit confirmation or mocked/sandboxed execution.
- [x] Inherited About/thank-you support text remains intact, while backend/setup installer copy is checked so `Josef`, test-run wording, and unexplained internal context do not leak into normal player-facing setup surfaces.
- [x] A GUI reasoning run roleplays a C:DDA aficionado who read about C-AOL on Reddit and now wants to install/play it; findings answer installer flow, look, backend choice, and unexplained-name questions.

## Testing / evidence bar

Minimum evidence before closure:

- Static or Godot smoke proving the new tab/page exists and the old Settings debug panel is no longer the primary backend setup surface.
- Text scan proving no `Josef`, `Windows test`, or equivalent test-run copy leaks into player-facing backend setup text.
- Safe proof for installer commands/actions showing confirmations and no accidental live package/model install during tests.
- Hardware recommendation proof with at least two fixture cases: low/unknown hardware recommends the lighter model path; stronger hardware recommends or permits the larger model path.
- Existing small Godot/project-load gate and `git diff --check`.
- GUI reasoning-run artifact: roleplay a Reddit C:DDA aficionado installing C-AOL through Lacapult. Record what they click first, where they get confused, what `Josef` means to them if they see it, which backend path seems easiest/local/specialized, and which visible installer steps must exist before the flow feels complete.

## Notes from live test

Screenshot review showed the backend setup as dense, status-heavy, and mixed into Settings. The user should see an installer flow: pick backend, understand compatibility, confirm install/setup, then configure C-AOL. Not a little museum of internal readiness keys. Na bravo.

## Required GUI reasoning run

Before closing the packet, run a short but explicit outsider roleplay:

- Persona: a Cataclysm:DDA aficionado reads about C-AOL on Reddit and wants to install/play it.
- Unknowns: they do not know Josef, Schani, Andi, the Windows laptop test, or the project's internal proof history.
- Flow to imagine: download/open Lacapult, choose/install a C-AOL build, choose API/Ollama/OpenVINO, confirm any install/download action, then launch the game.
- Questions to answer: what do they click first; what wording feels like internal scaffolding; if they see `Josef`, will they know who that is; what should the installer do before asking them to leave the app; what visual grouping makes backend setup feel like setup rather than a debug panel.
- Output: a concise finding list that directly maps to UI/copy/proof changes.

This is not decorative theatre. If the Reddit C:DDA player cannot understand the installer, the installer is not done. Na bravo, the entire product is a door handle; people must know which way it turns.
