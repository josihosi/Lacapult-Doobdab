# Catapult-Dabubu Windows retest follow-up v3 — imagination source

Date: 2026-05-09

This is the product picture behind the next repair pass after Josef's v2 Windows retest notes.

## Finished scene

Josef opens Catapult-Dabubu on Windows and the LLM/mod path feels like one coherent setup, not three half-connected cupboards.

The LLM page has an honest action model. If the visible action says `Save options`, the result is clear: either it is explicitly a draft-only launcher save, or it commits the selected backend as the active C-AOL runner setup. Josef should not select Ollama/Nemotron, press save, and then find another C-AOL option still set to `qwen`, runner disabled, or mode still not set. The selected provider/model, backend mode, runner enablement, and relevant C-AOL option patch/apply state must line up.

The local Ollama route is honest about Windows hardware. RAM/VRAM performance lights remain compact, but CPU-only/iGPU fallback does not look like a cheerful green route. If Windows local inference will crawl, Catapult-Dabubu says that plainly and points to a smaller model/API route without turning the setup area into a prose wall. If a real GPU path is present, the launcher should distinguish that from CPU fallback.

The mod path stops feeling like a fake shelf. Magiclysm/DinoMod JSON catalog footing was a start, but the procedure needs to prove the relevant mods can actually be installed/enabled/summarized in a sandbox or otherwise safe target. The UI should report whether the mods are present, compatible enough, summary-ready/missing, and what the next safe action is. It should not merely say "cataloged" while the player still cannot use them.

The runtime speech path is defensive around local reasoning models. If a reasoning-capable Ollama model tries to emit `<think>`, no raw reasoning tag reaches visible NPC speech. The app should request non-thinking output when Ollama supports it, strip or reject `<think>` blocks anyway, and recover with a final-only retry/fallback if the model spends the budget thinking.

## Boundaries

- No public/final release confidence and no quarantine lift.
- No repo rename.
- No surprise live API calls, API secret use, package-manager installs, Ollama model pulls, or real Application Support/save mutation in automated proof.
- Real mod install/apply proof must use a sandbox/fixture unless Josef explicitly clears a live target.
- Alex remains Lacapult-only unless Schani/Josef explicitly reassign cross-repo C-AOL runner work.
- Keep UI repair compact; do not solve confusion by adding paragraphs everywhere.

## Failure smells

- `Save options` writes launcher metadata but leaves C-AOL's active runner disabled or pointed at an old local model.
- Ollama mode says local setup is ready/good while Windows is CPU/iGPU fallback and painfully slow.
- Mod catalog entries exist but there is no proof that Magiclysm/DinoMod can be installed/enabled/summarized safely.
- The code relies only on prompt wording or stop tokens to suppress `<think>`.
- A local model can return `<think>` and C-AOL still sends that raw tag to `say`.

## Review questions

- Does the button label match what actually changes?
- Can Josef tell whether he saved a draft or applied the active runner setup?
- Does the hardware/status UI set realistic local-vs-API expectations for Windows CPU/iGPU users?
- Does the mod proof demonstrate a usable procedure, not just better catalog wording?
- Is the `<think>` leak fixed at a hard boundary, or only wished away by prompting?
