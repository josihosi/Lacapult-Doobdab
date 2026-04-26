# Lacapult GUI reasoning run — Reddit C:DDA aficionado installing C-AOL

## Persona

I play Cataclysm:DDA, see a Reddit post about Cataclysm: Arsenic and Old Lace, and want to try it. I do not know Josef, Schani, Andi, the Windows laptop test, or the project proof history.

## Expected flow

1. Download Lacapult because it is presented as the C-AOL installer/launcher.
2. Open Lacapult and see an obvious C-AOL install path.
3. Pick a suitable C-AOL build/release without needing to decode upstream branch history.
4. Install/update the game while keeping user data safe.
5. See a dedicated backend setup page if C-AOL needs an LLM backend.
6. Choose the easiest hosted path, the mainstream local path, or the specialized acceleration path.
7. Confirm before Lacapult installs packages, downloads models, pulls Ollama models, or changes real game config.
8. Launch the game.

## Confusion traps

- If the installer says `Josef`, I assume this is a private test build or an unexplained maintainer reference. I do not know whether it applies to me.
- If it says `Windows test`, `pre-release testing`, or similar proof wording, I wonder whether this is meant for ordinary players.
- If backend setup is buried in Settings, it reads as optional/debuggy even when it may be required to make NPCs work.
- If readiness appears as raw tokens, it feels like a developer panel rather than a guided installer.
- If missing dependencies are detected but Lacapult cannot explain the next action, the installer becomes a checklist and loses the thread.

## Installer answers this user needs

- Which C-AOL build should I install?
- Where do I set up the LLM backend?
- Which backend is easiest?
- Which backend is local?
- Which backend is specialized/advanced?
- What exactly will happen if I confirm an install/download step?
- Which Ollama model should I choose on modest hardware?
- Can I override the recommendation if my machine is stronger?
- How do I launch C-AOL after setup?

## UI requirements from the roleplay

- Backend setup belongs in its own tab/page titled exactly `C-AOL LLM backend setup`.
- Copy speaks to an anonymous C-AOL player, not Josef or a test session.
- API / AnyLLM is presented as the easiest hosted setup path.
- Ollama is presented as the mainstream local setup path, with `mistral-v0.3` and `nemotron-9b` choices.
- OpenVINO is presented honestly as specialized/advanced.
- Hardware detection recommends but never silently chooses.
- External package/model actions are confirmation-gated and explain what they would do.
- Internal names can remain in credits/history when explained, but not in setup instructions that ordinary players must follow.

## Current verdict

The active backend packet should be judged through this outside-user lens. If the Reddit C:DDA player cannot get from download to C-AOL install, backend choice, and launch without decoding internal project history, the installer is not finished.
