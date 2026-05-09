# Alex handoff — Catapult-Dabubu Windows retest follow-up v3

Repo: `/Users/josefhorvath/Schanigarten/Lacapult-Doobdab`
Branch: `main`
Classification: active intake / next repair lane
Canon contract: `doc/catapult-dabubu-windows-retest-followup-v3-2026-05-09.md`
Imagination source: `doc/catapult-dabubu-windows-retest-followup-v3-imagination-source-2026-05-09.md`
Raw intake: `doc/josef-catapult-dabubu-debug-intake-2026-05-09.md`

## Active item

Catapult-Dabubu Windows retest follow-up v3: package and implement the fresh v2 Windows retest blockers Josef reported on 2026-05-09.

## Recommended bounded slices

1. **Save/apply semantics first**
   - Inspect current `Save options` path in `scripts/BackendSetupUI.gd` and `scripts/BackendConfigManager.gd`.
   - Decide the smallest honest contract: either rename/split draft save vs apply, or make the button commit the selected runner setup as Josef expects.
   - Proof target: sandboxed C-AOL options/apply artifact includes selected backend, selected model, runner mode, and runner enablement without secrets.

2. **Ollama slow-fallback status**
   - Extend the v2 hardware fixture/status model to distinguish CPU-only/iGPU from accelerated local mode.
   - Keep display compact and Windows-safe.
   - Proof target: fixture UI smoke for CPU-only/iGPU => slow fallback, not green; accelerated route remains distinct.

3. **Mod procedure proof**
   - Start with Magiclysm/DinoMod because v2 already built catalog/status footing there.
   - Prove safe install/enable/summary procedure in sandbox/fixture before any live target.
   - Do not install arbitrary mods into Josef's real tree or mutate real saves/Application Support.

4. **Nemotron no-think setup + `<think>` boundary triage**
   - Implement/prove the Lacapult-side setup seam Josef clarified: Save options should persist the no-thinking runtime alias, and Nemotron setup should pull the Virtuoso source tag if needed, then create/use a local no-thinking runtime alias (`nemotron-9b-dumber:latest`) with a Modelfile containing `SYSTEM /no_think`.
   - Do not duplicate model weights; the alias-create step should reuse the pulled source blobs and the UI/proof should say so.
   - Then identify whether any remaining Lacapult-side runner/procedure seam can prevent raw `<think>` speech.
   - If the hard speech fix is in C-AOL `tools/llm_runner` / speech code, do not edit it as Alex without explicit cross-repo clearance; write the precise blocker/handoff instead.

5. **Package v3 only after proof**
   - Fresh Josef-only Windows Draft/prerelease, not a quarantine lift.

## Non-goals

- No public/final release.
- No repo rename.
- No surprise package installs, Ollama pulls, live API calls, API secrets, or real user-data mutation.
- No broad UI redesign.
- No Cataclysm-AOL source edits unless explicitly reassigned.

## Validation floor

- `git diff --check` for docs/code.
- Static proof for save/apply option names and no-secret boundaries.
- Godot UI smoke for API/Ollama save/apply round-trip.
- Hardware fixture smoke for CPU/iGPU/accelerated states.
- Mod sandbox proof for Magiclysm/DinoMod procedure.
- Nemotron no-think alias setup proof.
- Remaining `<think>` proof or cross-repo blocker handoff.

## Hollow-rock suspicion

The largest trap is treating the current launcher options patch as if it already applies runtime C-AOL behavior. Josef's complaint says the visible button does not produce the active runner state he expects. Prove the actual artifact/path, not just the launcher field values.
