# Catapult-Dabubu Windows retest follow-up v2 — debug-note repair packet

Date: 2026-05-06
Classification: active
Imagination source: `doc/catapult-dabubu-windows-retest-followup-v2-imagination-source-2026-05-06.md`
Raw intake: `doc/josef-catapult-dabubu-debug-intake-2026-05-06.md`

## Summary

Josef completed the 2026-05-06 Catapult-Dabubu v1 Windows retest notes and explicitly asked to package and activate a cook. The next repair pass fixes the broken API package setup, removes redundant normal-user API base URL clutter, repairs Ollama model tags/labels, replaces misleading hardware prose/status with compact model performance lights, adds runner tests for both API and Ollama routes, improves the Ollama timeout note, and starts making the Mods catalog useful for JSON mods such as Magiclysm and DinoMod.

This is a Josef-only retest repair lane. It does not lift quarantine, authorize public/final release confidence, rename the GitHub repo, start C-AOL release work, or permit unapproved live secrets/API calls/package installs/model pulls in automated proof.

## Scope

1. **API / any-llm package setup repair**
   - Use Mozilla `any-llm` correctly: PyPI install package `any-llm-sdk[...]`, code import seam `from any_llm import completion`.
   - Provider extras should be provider-aware, e.g. `openai`, `anthropic`, `gemini`, `openrouter`, or combined/all where appropriate.
   - Remove current `any_llm[...]` install-preview/command bug.
   - Capture and surface useful setup stderr/stdout summary when package setup fails, without logging secrets.

2. **API setup UI simplification**
   - Remove API base URL from normal setup UI.
   - Keep base URL only as an advanced/custom endpoint override for proxy/router/local gateway/custom provider cases.
   - Normal UI should prioritize Provider, Model, API key/env-var/session key, setup/check, and runner test.

3. **Ollama model tag and selector repair**
   - Mistral command/runtime tag: `mistral:v0.3`, not `mistral-v0.3`.
   - Nemotron command/runtime tag: `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`, not fake `nemotron-9b`.
   - GUI model selector must show short labels only, e.g. `Mistral v0.3` / `Nemotron 9B` or equivalent.
   - Command preview/logs/readiness may show the exact underlying tag when useful.
   - Readiness should distinguish invalid/nonexistent tag, not installed, installed, and pullable registry tag where practical.

4. **Ollama hardware/performance display repair**
   - Show RAM and VRAM in GiB.
   - Replace advisory prose with compact model-specific estimated performance lights for Mistral and Nemotron.
   - Color is determined from measured RAM/VRAM thresholds.
   - Red/yellow/green hardware model lights must not be rendered as `missing` when measurements exist.
   - Do not add extra recommendation paragraphs.

5. **Runner test buttons**
   - Add a runner test button for the Ollama/local route.
   - Add a runner test button for the API route.
   - The test must exercise the actual C-AOL runner path, not merely saved launcher metadata.
   - API runner test must be explicitly gated to avoid surprise spend or secret leakage.
   - Ollama runner test must not install Ollama or pull models.

6. **Ollama timeout/wait wording**
   - In the install/model confirmation/submenu flow, use short wording: `The launcher may appear to time out. Wait for Ollama installation to commence.`
   - Do not add a broad explanatory paragraph.

7. **Mods catalog / JSON summarizer foothold**
   - Investigate why no mods are added to the catalog.
   - Start adding useful JSON mod catalog entries, at minimum Magiclysm and DinoMod if present/available in the supported C-AOL data/mods inventory.
   - Shape the fix around a summarizer adapter for JSON mods rather than a hardcoded empty shelf.

## Non-goals

- No public/stable release or quarantine lift.
- No GitHub repo rename.
- No broad provider-matrix rewrite beyond the provider inputs needed for this repair.
- No automatic package install, model pull, live API call, real secret use, or real user-data mutation in automated proof.
- No full mod ecosystem solution in this slice; prove the first useful JSON-mod catalog/summarizer footing.
- No UI prose expansion to compensate for unclear state; prefer compact controls, lights, and exact failure messages.

## Success state

- [x] API setup uses `any-llm-sdk[...]` provider extras and still imports/tests `any_llm` as the runtime seam.
- [x] Normal API setup no longer shows API base URL; base URL survives only as advanced/custom override.
- [x] Package setup failures show a useful non-secret error summary that clearly distinguishes package setup from model/base/key/API-call failures.
- [x] Mistral uses real tag `mistral:v0.3` for pull/readiness/runner paths.
- [x] Nemotron uses real tag `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest` internally while the selector shows a short label.
- [x] Hardware display shows RAM/VRAM in GiB plus red/yellow/green estimated performance lights for Mistral and Nemotron, with no advisory prose wall.
- [x] Hardware measured-but-low state is not displayed as `missing`.
- [ ] API and Ollama routes each expose a runner test button that exercises the actual C-AOL runner route under explicit safety boundaries.
- [x] Ollama install/model confirmation uses the exact short timeout/commencement warning.
- [ ] Mods catalog no longer stays empty for supported JSON mod discovery; Magiclysm and DinoMod are attempted or clearly reported unavailable.
- [ ] Focused static/Godot smoke tests cover the repaired seams without live secrets, unapproved package installs, model pulls, or real user-data mutation.
- [ ] A fresh Josef-only Windows Draft/prerelease package is produced/uploaded only after local proof, with release notes saying this is v2 retest only.
- [ ] Josef retests the v2 Windows package.

## Testing and evidence expectations

Minimum proof before packaging:

- Static/source scan that no `any_llm[` install command remains and `any-llm-sdk[...]` provider extras are used.
- Static/source scan or unit proof for provider -> key/env/base/default mapping and advanced base-url-only UI behavior.
- Godot UI smoke for API normal mode showing no base URL field and showing provider/model/key/setup/check/runner-test controls.
- Godot UI smoke for Ollama model selector showing short labels while command/readiness uses exact runtime tags.
- Fixture readiness proof for Mistral/Nemotron model missing/present/invalid states.
- Hardware fixture proof for GiB display and Mistral/Nemotron performance lights, including low measured hardware not saying `missing`.
- Runner-test proof using safe fixture/no-secret paths; API runner test must be gated and no live API call in automated proof.
- Mods catalog proof with fixture or sandboxed C-AOL data/mods input showing Magiclysm/DinoMod catalog/summarizer footing or precise unavailable status.
- Existing regression smokes for LLM tab, backend setup save/check, Ollama workflow, Windows retest follow-up, and packaging proof.

## Known traps

- There are two similarly named libraries. The repo's current `from any_llm import completion` seam points to Mozilla `any-llm` / PyPI `any-llm-sdk`, not the unrelated `anyllm` package.
- Display labels and command tags must be separate for Nemotron.
- Generic red status text currently risks saying `missing`; hardware performance red is not dependency missing.
- GitHub release assets for Linux/macOS already exist locally from prior export proof, but v2 should stay Windows-first unless Josef separately asks to publish cross-platform assets.
- Keep all live-operation boundaries visible. Confirmation-gated manual actions are not automated proof.
