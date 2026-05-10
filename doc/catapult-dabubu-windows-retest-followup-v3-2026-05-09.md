# Catapult-Dabubu Windows retest follow-up v3 — debug-note repair packet

Date: 2026-05-09
Classification: active intake / next repair lane
Imagination source: `doc/catapult-dabubu-windows-retest-followup-v3-imagination-source-2026-05-09.md`
Raw intake: `doc/josef-catapult-dabubu-debug-intake-2026-05-09.md`

## Summary

Josef retested the v2 Windows Draft/prerelease and reported a fresh batch: mod compatibility/procedure still feels half-done, `Save options` does not commit the selected LLM setup into the actual runner/options state, Windows Ollama CPU/iGPU fallback is painfully slow and needs honest status, and C-AOL local NPC speech can leak raw `<think>` reasoning output.

This is a Josef-only repair lane. It does not lift release quarantine, authorize public/final confidence, rename the GitHub repo, start a C-AOL release, or permit unapproved live secrets/API calls/package installs/model pulls/real user-data mutation in automated proof.

## Scope order

1. **Save/apply runner setup semantics**
   - Decide and implement the visible action contract: draft-only save vs explicit apply/commit of active runner setup.
   - Josef's expectation is that the selected API/Ollama setup becomes the active C-AOL runner mode.
   - The committed/apply shape must set backend mode, selected local/API model, and runner enablement coherently.
   - Do not silently mutate a real installed C-AOL config in automated proof; use sandbox/options-patch proof or an explicit user-selected/confirmed apply path.

2. **Ollama Windows CPU/GPU honesty**
   - Preserve compact RAM/VRAM/model-light behavior from v2.
   - Add or expose acceleration-state footing so CPU-only/iGPU fallback is amber/red/slow fallback, not a happy green local path.
   - Where possible, distinguish NVIDIA/CUDA-capable, other GPU/iGPU, and CPU-only/no acceleration states.
   - Keep text short; prefer exact status rows/lights over advisory paragraphs.

3. **Mod compatibility/procedure proof**
   - Move beyond catalog presence for Magiclysm/DinoMod.
   - Prove a safe procedure for relevant mods: discovery, compatibility/status, enable/install/apply plan, summarizer readiness, and rollback/no-real-user-data boundaries.
   - Use sandbox/fixture proof first. Do not mutate Josef's real saves/Application Support or install arbitrary mods without clearance.

4. **C-AOL `<think>` speech leak boundary / Ollama no-think setup**
   - Desired product behavior: local Ollama NPC speech requests non-thinking output, strips/rejects `<think>` blocks, retries/falls back when the final line is empty, and never sends raw `<think>` to `say`.
   - Lacapult-side installer scope is now clear: for Nemotron, pull the Virtuoso source model if needed, then create/use a local no-thinking alias with a Modelfile `SYSTEM /no_think` setup, mirroring Josef's working Mac setup without duplicating model weights.
   - The prepared runtime alias is `nemotron-9b-dumber:latest`; the source model remains `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`.
   - The remaining hard speech guard likely lives primarily in the Cataclysm-AOL runner/speech path. Alex must not edit the C-AOL repo under the standing Lacapult-only role unless Schani/Josef explicitly assign that cross-repo fix.
   - Lacapult-side proof must show Save options persists the no-think runtime alias, the setup plan writes the no-think Modelfile, creates the alias, and states that Ollama reuses source blobs instead of pulling a second copy.

5. **Fresh Josef-only Windows v3 retest package**
   - Build/package/upload only after local proof for the implemented local scope.
   - Release copy must remain Josef-only Draft/prerelease test wording, not stable/latest/public confidence.

## Non-goals

- No quarantine lift, public/stable release, or broad announcement.
- No GitHub repo rename.
- No unapproved package installs, model pulls, live API calls, secrets, or real user-data mutation in automated proof.
- No broad launcher redesign or prose expansion.
- No Cataclysm-AOL source edits by Alex without explicit cross-repo clearance.

## Success state

- [x] Canon/raw intake for the 2026-05-09 v2 retest notes is recorded and linked from top-level roadmap files.
- [x] `Save options` / apply semantics are no longer ambiguous: selected backend, selected model, runner mode, and runner enablement line up in the produced confirmed/sandbox C-AOL options/apply path.
- [x] The Ollama status UI/proof distinguishes slow CPU/iGPU fallback from acceptable accelerated local mode.
- [x] Magiclysm/DinoMod (or the current relevant mod targets) have a safe compatibility/procedure proof beyond catalog seeding.
- [x] Lacapult prepares the Nemotron no-think runtime alias from the Virtuoso source without duplicating model weights, and the remaining C-AOL runner/speech hardening seam is explicitly handed off in `doc/catapult-dabubu-v3-think-boundary-handoff-2026-05-10.md`.
- [x] Focused static/Godot/sandbox proof passes without live secrets, unapproved package installs, model pulls, or real user-data mutation.
- [ ] Schani/Josef decide whether v3 packaging waits for the C-AOL runner/speech fix or proceeds with the blocker explicitly caveated.
- [ ] A fresh Josef-only Windows Draft/prerelease v3 package is produced/verified only after local proof and that decision.
- [ ] Josef confirms the v3 Windows package.

## Testing and evidence expectations

Minimum proof before packaging:

- Source/static proof for the selected save/apply action contract and option names, including runner enablement and backend/model mode.
- Godot UI smoke that exercises the save/apply action in API and Ollama modes and inspects the sandboxed C-AOL options/apply artifact.
- Hardware/status fixture proof for CPU-only/iGPU vs accelerated states, plus RAM/VRAM/model lights.
- Mod procedure proof in fixture/sandbox: Magiclysm/DinoMod discovery, compatibility/status, summary readiness or precise blockers, and no real user-data mutation.
- Ollama setup proof for the Nemotron no-think alias plan: source pull if needed, Modelfile `SYSTEM /no_think`, alias create, runtime model persisted, and no duplicate-weight/no automated-pull boundary in proof mode.
- Remaining `<think>` boundary proof if the seam is in Lacapult scope; otherwise a parked cross-repo handoff naming the C-AOL runner/speech boundary.
- `git diff --check` and focused regression smokes for backend setup, Ollama workflow, Windows retest UI, mod status/procedure, and packaging shape.

## Known traps

- The existing v2 options patch deliberately says `LLM_INTENT_ENABLE` is left for the player/game UI. Josef's v3 note challenges that product decision.
- A launcher metadata save is not the same as applying active C-AOL runtime options; the UI must not imply more than it does.
- CPU/iGPU fallback may technically work while being too slow for a good product path.
- Stop tokens are not a complete defense against `<think>` leakage; hard sanitization/retry is required at the speech boundary.
- Mod compatibility proof must not become an unsafe live install against Josef's real save/config state.
