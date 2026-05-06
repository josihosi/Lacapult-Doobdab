# Catapult-Dabubu Windows retest follow-up v2 — imagination source

Date: 2026-05-06

This is the product picture behind the next Catapult-Dabubu repair pass after Josef's v1 Windows retest notes.

## Finished scene

Josef opens the Catapult-Dabubu Windows test build and the LLM page behaves like an appliance, not a form from a municipal basement.

The API route starts with the things a user actually understands: provider, model, key/env-var, setup/check, and a runner test. The API base URL is no longer normal-page clutter. It exists only as an advanced/custom endpoint override for proxies, routers, local gateways, or weird provider-specific cases. If a provider is selected, Catapult knows the normal provider defaults.

When API setup runs, the command preview and installer use the actual Mozilla any-llm package shape: install `any-llm-sdk[...]` while keeping the code import seam `from any_llm import completion`. If package setup fails, the UI says it failed during package setup and shows useful captured pip error output; it does not make Josef wonder whether base URL, model, or key caused a step that never reached the network.

The Ollama route feels equally direct. It offers the two intended local model choices using short human labels. Internally, it preserves the real pull/runtime tags:

- Mistral short label -> `mistral:v0.3`
- Nemotron short label -> `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`

The selector does not spray the full Nemotron registry path into the normal GUI. The command preview and logs may show the true tag when needed, but the dropdown stays readable.

The hardware area reports RAM and VRAM in GiB, then shows two compact performance lights: one for Mistral and one for Nemotron. Red/yellow/green means estimated run performance from the measured RAM/VRAM. It does not lecture the user to use a small model. If the machine is weak, the light says so. The UI shuts up.

If an install/model operation can appear stalled while Ollama opens or Windows starts the installer, the note is short and explicit: "The launcher may appear to time out. Wait for Ollama installation to commence."

The status rows do not lie. If RAM/VRAM were measured, hardware is not "missing". A red hardware state means low/poor estimated performance, not absence. Model readiness separates invalid tag, not installed, installed, and pullable where possible.

Both the API route and the Ollama route include a runner test button. These test the actual C-AOL runner route, not just UI metadata. The API runner test is explicitly gated so it cannot surprise-spend or expose secrets. The Ollama runner test uses the selected local endpoint/model and does not install or pull anything.

The Mods area no longer feels empty by design. Catapult should start cataloging usable JSON mods, beginning with Magiclysm and DinoMod if present/available, and route them through a summarizer adapter shape rather than showing a sad empty catalog.

## Boundaries

- No public/final release confidence.
- No quarantine lift.
- No automatic live API call, package install, model pull, or real user-data mutation in automated tests.
- Confirmation-gated manual setup paths may exist, but proof gates must stay sandboxed/fixture-backed unless Josef explicitly clears live operations.
- Do not solve every provider or every mod in one slice. Fix the broken obvious path first.

## Failure smells

- The UI still asks normal users for API base URL after provider selection.
- It still says `any_llm[...]` in install preview or tests.
- It still offers `mistral-v0.3` or `nemotron-9b` as real pull commands.
- Nemotron dropdown shows the full registry path instead of a short label.
- Hardware check says `missing` while RAM/VRAM numbers are visible.
- Hardware text becomes another paragraph instead of compact GiB + model lights.
- Runner test only checks saved config and never exercises the C-AOL runner path.
- Mods catalog remains empty with no JSON-mod discovery attempt.

## Review questions

- Can a normal user select provider/model/key and understand what to press next without knowing what an API base URL is?
- Does every displayed model label map to a real command/runtime tag?
- Does the no-secrets/no-surprise-spend boundary remain visible and enforced?
- Do the proof tests catch the exact regressions Josef hit on Windows?
- Does the next Josef build answer the retest notes, or just move the same confusion into different words?
