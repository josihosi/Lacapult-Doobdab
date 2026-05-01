# Lacapult Windows retest fix imagination source — 2026-05-01

This is the product picture for the next Windows retest repair pass. It sources from Josef's 2026-05-01 hands-on Windows feedback, preserved in `doc/josef-windows-debug-intake-2026-05-01.md`.

## Finished scene

Josef downloads a clearly labelled test build, extracts it, opens the launcher, and the first window looks like a launcher instead of a cramped Godot costume. The next test build should also account for Josef's requested rename target, `Catapult-Dabubu`, so the visible product/package/release identity is no longer stuck halfway between old Lacapult wording and inherited Catapult/Dabdoob lineage. The title/top row has breathing room, the default window is large enough for the first real workflow, and the app does not hide text behind its own borders.

In the LLM tab, API / AnyLLM and Ollama setup behave like guided setup, not like a guessing booth:

- button popups and tooltips fit inside the window or deliberately scroll/wrap;
- long help text is wrapped into readable lines/paragraphs;
- install actions show that work is still running instead of implying the app crashed;
- API / AnyLLM setup either installs the needed AnyLLM package/deps or names the separate step honestly;
- Ollama model choice, readiness lights, model pull/install results, and hardware suitability for Mistral/Nemotron are visible enough that Josef can tell what happened.

After the repair, a fresh Windows test release exists only for Josef validation. It is not a public confidence release and it does not lift the release quarantine.

## Boundaries

- Keep Lacapult as a C-AOL launcher; do not start C-AOL release work.
- Keep public release quarantine active; only create a clearly labelled Draft/prerelease test build for Josef.
- Treat `Catapult-Dabubu` as the rename target for the next identity pass, but do not perform an actual GitHub repository rename without fresh explicit confirmation.
- Do not run live API calls, read secrets, pull models, or mutate real user data in automated proof.
- External installs/model pulls in the app must stay confirmation-gated and visibly explained.
- Do not hide failures behind generic “may have attempted” messages when the command/result can be separated.

## Failure smells

- A popup text line is wider than the window.
- A tooltip/dialog is clipped by the launcher border.
- A status says “choose a model” while the model-choice UI visibly has a selection.
- The app shows `?` where a readiness light should explain unknown/warning/ready.
- “Install venv” creates an empty venv and leaves API / AnyLLM still unusable without a clear next step.
- Ollama installer failure, server failure, PATH failure, and model-pull failure are all collapsed into one vague message.
- Hardware suitability for Mistral/Nemotron is absent or hidden.

## Review questions

- Can Josef use the new test build to exercise the LLM setup path without the UI cutting itself off?
- Does the app tell the truth about what it did, what is still running, and what failed?
- Are API / AnyLLM and Ollama setup flows understandable from the UI without reading code?
- Does the release artifact remain a private/test validation build, not a public release signal?
