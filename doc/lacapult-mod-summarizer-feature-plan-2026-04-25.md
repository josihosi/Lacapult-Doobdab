# Lacapult mod install/enable + Summarizer feature plan

Status: **ACTIVE NEXT LANE / SLICES 1-5 PROVEN THROUGH ERROR-ROLLBACK MATRIX / REAL GENERATION UI NOT IMPLEMENTED**

This packet turns the read-only C-AOL mod compatibility report into the next bounded implementation family. It does **not** implement the feature yet. It defines the contract Andi should execute in slices after backend-good hardening.

## Normalized contract

**Title:** Feature-complete C-AOL mod install/enable plus Summarizer UX/status/apply

**Request kind:** greenlight / active next-lane planning packet

**Summary:** Lacapult should stop treating modding as a read-only museum label and become the C-AOL-aware installer surface for mods and generated NPC/context summaries. After a mod is installed or enabled, Lacapult should tell the player whether extra NPC/content context is already summarized, offer a Summarizer pop-up/button when it is not, generate or stage C-AOL-native summary packs only when backend readiness is good enough, and apply those packs through a reversible sandbox-proven flow. C-AOL owns the runtime summary schema, active mod roots, world loading, and any runtime fixes; Lacapult owns discovery, user-facing status, prompts, generation orchestration, staging, apply/rollback help, and backend-readiness gating.

**Classification:** active next planned lane after backend-good hardening; implementation must be split into bounded slices.

## Responsibility split

### C-AOL owns runtime truth

C-AOL is the authority for what the game can load and consume:

- Active world mod order comes from each world `mods.json` and is consumed as `world_generator->active_world->active_mod_order`.
- Runtime summary roots are assembled by `src/llm_intent.cpp::background_summary_data_roots()`:
  - core `data/json`
  - every active world mod path
  - the world custom-mod path at `PATH_INFO::world_base_save_path() / "mods"`
- Runtime summary loading reads, in order, from:
  - `npcs/Backgrounds/Summaries_short`
  - `npcs/Backgrounds/Summaries_extra`
- Accepted runtime formats are C-AOL formats, not launcher inventions:
  - legacy pipe-delimited `.txt`
  - `npc_personality_summary` JSON object
  - JSON array of summary objects
  - `npc_personality_summary_bundle` with `entries[]`
- JSON entries may address `selector` / `selectors`, `topic` / `topics`, or fallback `id`; `your_background` / `background`, `your_expression` / `expression`, and `source_tag` are the useful fields.
- C-AOL decides override behavior, cache invalidation, parse tolerance, and whether runtime support needs fixes for mod summary packs.
- C-AOL should eventually provide or bless a tiny harness/proof that a sandbox world with an active summary-pack mod causes NPC prompts to include the expected `your_tone` / `your_example_expression` lines.

### Lacapult owns installer UX/status/apply help

Lacapult should not invent a second summary schema. Its job is the boring useful work around C-AOL's schema:

- Discover packaged stock mods, user-installed mods, custom catalog mods, and world-specific custom mods.
- Classify installability, enablement, dependency, obsolete, parse, and summary coverage state.
- After install/enable, surface a clear Summarizer prompt only when there is contextual content that lacks C-AOL summaries.
- Gate generation on backend readiness from the backend-good checks:
  - API/AnyLLM Python import readiness, provider/model/env-var metadata, no secret storage
  - Ollama command/server/model-list readiness, no model pulls without clearance
  - OpenVINO Python import/model-dir/device readiness now; future guided install may offer an explicit-approval fixed package list such as `openvino`, `openvino-genai`, and `openvino-tokenizers` plus model-dir setup, but no install/download belongs in the discovery/status slice
- Stage generated summary packs in a sandbox first.
- Apply generated packs as C-AOL-native mod roots or world custom-mod roots, with backups and rollback.
- Explain failures in player language without pretending Lacapult can fix broken upstream packages or malformed third-party mods.

## Current repo truth this plan builds on

- `scripts/ModManager.gd` parses `modinfo.json`, tracks installed vs available mods, preserves stock/user distinction, handles obsolete stock collisions, and installs GitHub/local mods into `Paths.mods_user`.
- `scripts/ModsUI.gd` already lists installed and available mods, colors stock/update/outdated rows, and has install/delete/reinstall flows.
- `scripts/path_helper.gd` already resolves C-AOL macOS app-bundle stock data paths plus userdata paths:
  - stock mods: active install `data/mods`, or macOS `Cataclysm.app/Contents/Resources/data/mods`
  - user mods: `Library/Application Support/Lacapult Doobdab/caol/userdata/mods` on macOS, equivalent launcher data paths elsewhere
  - custom repo: `.../caol/mod_repo`
  - world/save data: `.../caol/userdata/save`
- `scripts/SettingsUI.gd` and `scripts/ModsUI.gd` now surface the live read-only C-AOL mod/Summarizer overview, including enabled/disabled counts, summary coverage, blockers, “all enabled extra context” state, and a Summarizer dry-run/status button.
- `tools/prove_caol_mod_inventory.py` proves the current packaged C-AOL `v0.2.0` macOS DMG has 42 non-obsolete packaged stock mods, 7 obsolete blockers, 30 contextual mods needing generated packs, 12 no-summary-needed mods, and 0 packaged summary-ready mods.
- `scripts/BackendConfigManager.gd` now gives the backend-good readiness/config/status foundation that the Summarizer button should reuse.

## Player-facing UX target

### Discovery/status surface

Add a C-AOL mod summary status model that can be rendered in the existing Mods tab first, and only later polished into a wizard if needed. Minimum useful row/badge states:

- `stock-packaged`: packaged with the installed C-AOL release; not installed into user mods.
- `user-installed`: copied/downloaded into user mods.
- `world-custom`: present under a specific world's `mods/` folder.
- `enabled-in-world`: present in that world's `mods.json` active order.
- `disabled`: installed but not active in the selected/default world.
- `obsolete-blocked`: `modinfo.json` says `obsolete: true`.
- `metadata-broken`: `modinfo.json` missing or parse-failed.
- `dependency-blocked`: dependencies missing or disabled.
- `catalog-untested`: downloadable source exists but is not C-AOL-proven.
- `summary-ready`: active root already contains `Summaries_short` or `Summaries_extra` entries.
- `summary-not-needed`: no obvious NPC/faction/monster/item/location context found.
- `summary-missing`: contextual content exists and no summary pack is active.
- `summary-partial`: some roots/files exist but coverage is incomplete.
- `summary-stale`: source mod changed since the generated pack was created.
- `summary-blocked`: backend or mod state prevents generation/apply.

The UI should be blunt and useful:

- Show a small summary badge next to installed/enabled mods.
- Show a post-install/post-enable dialog when a contextual mod becomes active: “This mod adds NPC/world context that is not summarized yet. Run Summarizer now?”
- Offer buttons: `Run Summarizer`, `Not now`, `Always ask after mod enable`, and eventually `Do not summarize this mod`.
- Keep a Settings status switch/checklist for “All enabled extra NPC/content summarized” with states like `all clear`, `needs summaries`, `blocked`, and `unknown`.
- Never say “ready” when C-AOL cannot consume the generated files.

### Generated pack shape

Preferred apply shape is a companion user mod, because it is reversible and keeps packaged stock mods untouched:

```text
userdata/mods/lacapult_summary_<source_mod_id>/
  modinfo.json
  npcs/Backgrounds/Summaries_extra/generated_<source_mod_id>.json
  npcs/Backgrounds/Summaries_short/generated_<source_mod_id>.json   # only if topic summaries are generated
```

The generated `modinfo.json` should:

- use a stable id like `lacapult_summary_<source_mod_id>`
- depend on the source mod when possible
- state clearly that it contains generated C-AOL NPC/context summaries
- avoid claiming gameplay content beyond summaries

World-specific summaries may instead stage into `<world>/mods/lacapult_summary_<source_mod_id>/` when the source content is world-only or when the user explicitly chooses a per-world apply. That path is also C-AOL-native, because C-AOL loads world custom mods after active mod roots.

## Weird mod cases and required handling

### Obsolete or broken packaged mods

- If `obsolete: true`, block install/enable/Summarizer by default and explain that C-AOL marks the mod obsolete.
- Do not generate summaries for obsolete mods unless a future advanced override exists.
- If `modinfo.json` is missing or parse-failed, show `metadata-broken`, keep raw error details expandable/copyable, and do not apply generated packs.

### Dependency chains

- Read dependencies from `modinfo.json` and compare against installed and active mod ids.
- Mark missing dependencies as `dependency-blocked` before download/apply.
- When enabling a summary companion mod, ensure the source mod is active first and the summary mod is ordered after it.
- If C-AOL's in-game dependency resolver disagrees, treat C-AOL as authority and surface the C-AOL error rather than hiding it.

### User-installed mods

- User mods under `Paths.mods_user` are mechanically supported but content compatibility is unknown until parsed.
- Lacapult should scan them locally, not assume inherited DDA/BN/TLG compatibility labels apply to C-AOL.
- Summary generation is allowed only after the mod parses, is non-obsolete, and can be staged in a sandbox.

### Packaged stock mods

- Do not mutate packaged stock mod folders inside the installed release/app bundle.
- Use companion user mods or world custom mods for generated summaries.
- If a packaged mod already ships summaries, report `summary-ready` and do not overwrite them unless the user explicitly regenerates a companion override.

### Custom downloadable catalogs

- C-AOL has no explicit curated downloadable mod catalog yet; `caol` currently falls back to `Paths.mod_repo`.
- Inherited DDA/BN/TLG GitHub catalog entries are `catalog-untested` for C-AOL, not supported.
- A future custom catalog must carry C-AOL compatibility metadata, dependency metadata, and a source hash/version field if summaries can be generated from it.

### Parse errors and missing roots

- Parse all `modinfo.json` and content JSON in a status pass that records file-relative errors.
- A missing summary root is normal and should produce `summary-missing`, not `broken`.
- A missing mod root or missing `modinfo.json` is a blocker.

### Partial summaries

- Treat “some summary files exist” as partial unless coverage rules say the specific mod/content set is complete.
- First implementation can use coarse coverage: contextual content flags vs any active summary pack for that source mod.
- Later implementation may compare generated manifest entries against source files/topics/selectors.

### Stale summaries after mod update

Every generated pack needs a manifest, for example:

```json
{
  "type": "lacapult_summary_pack_manifest",
  "version": 1,
  "source_mod_id": "mindovermatter",
  "source_mod_name": "Mind Over Matter",
  "source_fingerprint": "sha256-or-file-mtime-tree-hash",
  "generated_at": "2026-04-25T00:00:00Z",
  "backend": "ollama",
  "model": "example-model",
  "target_schema": "c-aol npc_personality_summary_bundle v1"
}
```

If the source fingerprint changes, show `summary-stale` and offer regeneration.

### Conflicts and overrides

- C-AOL loads roots in core + active mods + world custom mods order, and generated files are sorted so manual files can override generated files inside a summary directory.
- Lacapult should not promise conflict-free semantics; it should show when more than one summary pack claims the same selector/topic.
- Companion summary mods should be ordered after the source mod. World custom packs naturally load after active mod roots.

### Disabled mods and world-specific mods

- Do not summarize disabled mods by default.
- If a user asks to pre-generate for a disabled installed mod, stage only; do not call the world `all summarized` state clear until the mod and its companion summary pack are active.
- For existing worlds, status must be world-aware because `mods.json` is per-world.
- For new worlds/defaults, Lacapult may later help update default mod lists, but the first proof should focus on one sandbox world.

### Backup and rollback

Before any real apply outside a sandbox, Lacapult must back up:

- `userdata/mods/lacapult_summary_<source_mod_id>` if replacing an existing generated pack
- target world `mods.json` if changing active mod order
- target world custom `mods/lacapult_summary_<source_mod_id>` if using a world-specific pack
- a small apply manifest containing old paths, new paths, previous mod order, and generated pack ids

Rollback should restore the prior files and prior `mods.json` order. If rollback cannot fully restore, the UI must say exactly which paths remain changed.

## Backend interaction

The Summarizer button should be enabled only when a selected backend is plausibly ready for generation or when the user chooses a dry-run/status-only check.

### API backend

- Lacapult may store provider/model/API-key env-var names only.
- It must not store, print, or inspect the secret value.
- Generation is `blocked` until the configured/default Python can import `any_llm` and the env-var name is configured; live key validation remains optional and explicit.
- C-AOL runtime currently hardcodes provider `openai` in `src/llm_intent.cpp` for API intent calls; Lacapult should not imply arbitrary provider routing is consumed by C-AOL until C-AOL changes that path.

### Ollama backend

- Detect command presence, local server/list response, and configured model presence.
- Later backend recommendation UX may suggest among locally available models or a cleared model list, but provenance/renamed public names and hardware-fit recommendations are a separate backend lane. That lane must stay cross-platform for Linux/macOS/Windows, prioritize Windows UX/evidence, and not become Mac-only because current proofs run on Josef's Mac.
- Do not pull models automatically.
- If Ollama is installed but the server is down, show “start Ollama” guidance rather than a fake failure.
- If the model is missing, offer guidance; model pull automation is a separate explicit decision.

### OpenVINO backend

- Treat as Windows-first for v0.
- Check Python imports (`openvino`, `openvino_genai`) and local model-dir presence.
- Later Lacapult may offer guided setup with explicit user approval, a fixed package list, and model-dir setup, but that is outside Slice 1.
- Do not install runtimes or download/convert models in this lane.
- On non-Windows, detect-only/status-only wording must stay honest.

### Offline/error states

- Discovery/status must work offline for installed mods and existing generated packs.
- Catalog refresh and GitHub mod download failures should not erase existing status.
- Backend readiness failures should disable generation/apply, not hide the mod status itself.

## Execution slices for Andi

### Slice 1 — discovery/status model

Status: **landed 2026-04-25 as read-only Godot/Python status model plus sandbox proof.**

Goal: make mod/summarizer status computable without applying anything.

- Landed a Godot-side status model for packaged, user, custom-catalog, and world custom mods in `scripts/CaolModStatusModel.gd`, exposed through `ModManager.get_caol_mod_summarizer_status()`.
- Landed helper/proof code in `tools/caol_mod_status_model.py` and `tools/prove_caol_mod_status_model.py` rather than leaving the runtime-facing state as a Markdown-only report.
- Landed source fingerprints and generated-pack manifest/root detection.
- Landed world-aware enabled/disabled state for a sandbox world via `mods.json`.
- Gate: passed via static/project-load inspection plus a sandbox fixture/proof that emits status JSON for stock/user/world/custom-catalog mods without mutating real Application Support.

### Slice 2 — UX/status surface

Status: **landed 2026-04-25 as read-only Mods/Settings status plus dry-run Summarizer prompt.**

Goal: show the useful truth in the launcher.

- Landed C-AOL summary badges/status text in `scripts/ModsUI.gd` and the near-term Settings bridge panel.
- Landed a post-install Summarizer prompt path and persistent dry-run/status buttons; a true post-enable hook remains pending until Lacapult owns a C-AOL world `mods.json` enable/apply flow.
- Landed the “all enabled extra NPC/content summarized” state via `CaolModStatus.build_ux_overview()`.
- Gate: passed via Godot project-load plus headless status/UX smoke proving the dry-run view state is read-only and does not crash.

### Slice 3 — sandboxed summary-pack generation/apply proof

Status: **landed 2026-04-25 as sandbox-only C-AOL-native companion summary-pack apply plus rollback proof.**

Goal: generate one tiny C-AOL-native companion summary pack in a sandbox.

- Landed `tools/prove_caol_summary_pack_apply.py`, which creates a C-AOL-like sandbox under ignored `.proof-cache/caol-summary-pack-apply/` and chooses one non-obsolete contextual packaged stock mod from the status model.
- Landed a generated companion user mod shape with `modinfo.json`, `lacapult_summary_pack_manifest.json`, and a minimal `npc_personality_summary_bundle` under `npcs/Backgrounds/Summaries_extra`.
- Landed manifest fields for source mod id/name/fingerprint, deterministic proof timestamp, generated paths, backup paths, prior/new world mod order, apply target paths, and rollback plan.
- Landed sandbox `mods.json` apply proof that activates the source mod and companion summary mod with the companion after the source.
- Landed backup/rollback proof that restores the prior `mods.json` bytes/order exactly and removes the generated pack when it did not exist before apply.
- Landed status-model visibility proof: after apply the source mod is `summary-ready` and the companion generated-pack manifest is visible; after rollback the source returns to `summary-missing` and the companion disappears.
- Gate: passed via `python3 tools/prove_caol_summary_pack_apply.py`; evidence is under `.proof-cache/caol-summary-pack-apply/evidence/`.

### Slice 4 — C-AOL runtime consumption proof

Status: **landed 2026-04-25 as deterministic C-AOL harness/source proof.**

Goal: prove this is not launcher-only theater.

- Landed `tools/prove_caol_runtime_summary_consumption.py`, which builds a sandbox world with active order `dda`, a source fixture mod, and a generated companion summary mod.
- The proof derives active mod roots from sandbox `mods.json`, confirms the generated companion root contributes `npcs/Backgrounds/Summaries_extra`, and runs C-AOL's current `/Users/josefhorvath/Schanigarten/Cataclysm-AOL` checkout on branch `dev` through `tools/llm_runner/npc_harness.py`.
- The generated `npc_personality_summary_bundle` resolves through selector `name:Lacapult Runtime Fixture NPC` and reaches prompt construction as `your_tone` and `your_example_expression`.
- Gate: passed via `python3 tools/prove_caol_runtime_summary_consumption.py`; evidence is under `.proof-cache/caol-runtime-summary-consumption/evidence/`. This is deterministic harness proof plus C++ source-seam inspection, not a live compiled game-world launch.

### Slice 5 — error/rollback/backup proof

Status: **landed 2026-04-25 as sandbox-only error matrix plus replacement rollback proof.**

Goal: make the installer safe enough to trust.

- Landed `tools/prove_caol_summary_error_matrix.py`, which builds weird C-AOL-like fixtures under ignored `.proof-cache/caol-summary-error-matrix/`.
- Landed status-model visibility for broken metadata, content JSON parse errors, missing dependencies, obsolete mods, missing summary roots, partial summary roots, stale generated-pack manifests, conflicting generated packs, and backend-not-ready generation gates.
- Landed rollback proof for replacing a preexisting generated companion pack while editing sandbox `mods.json`, then restoring the exact prior `mods.json` bytes and preexisting pack directory.
- Gate: passed via `python3 tools/prove_caol_summary_error_matrix.py`; evidence is under `.proof-cache/caol-summary-error-matrix/evidence/`.

## Success state

This lane is complete only when all of the following are true:

- Mod discovery distinguishes stock packaged, user-installed, custom-catalog, and world-specific mods for C-AOL.
- Enabled vs disabled status is world-aware for at least one sandbox world.
- Obsolete, broken metadata, parse errors, missing roots, missing dependencies, partial summaries, stale summaries, and conflicts produce visible statuses.
- After install of a contextual mod, and from persistent Mods/Settings status surfaces, the UI offers a Summarizer prompt/button rather than burying the next action. A true post-enable hook remains a later enable/apply-flow requirement.
- The “all enabled extra NPC/content summarized” state is visible and honest.
- Backend readiness gates generation for API, Ollama, and OpenVINO using the backend-good checks; no API secrets are stored and no model pulls/downloads happen without explicit clearance.
- A generated pack is C-AOL-native under `npcs/Backgrounds/Summaries_short` / `Summaries_extra`; no launcher-only schema is treated as runtime-ready.
- Applying a generated pack and changing a world mod list is sandbox-proven with backup and rollback.
- C-AOL runtime consumption is proven in a sandbox/harness, or a concrete C-AOL-side blocker is recorded.
- Josef's real Application Support config, saves, mods, and worlds are never mutated by proof scripts.

## Non-goals

- No real user mod install/apply during proof work.
- No mutation of Josef's real C-AOL Application Support tree.
- No model pulls, API secret calls, OpenVINO installs, signing, notarization, release tags, or public release publication.
- No C-AOL runtime schema invented in Lacapult.
- No claim that inherited DDA/BN/TLG downloadable catalogs are C-AOL-compatible.
- No upstream contact or C-AOL package mutation without fresh explicit clearance.

## Recommended next implementation handoff

Next implement **Slice 5: error/rollback/backup proof**. Slice 4 now proves that a sandbox active generated companion summary root can reach C-AOL deterministic prompt construction. The next cut should broaden fixture coverage for obsolete mods, parse errors, missing dependencies, partial summaries, stale summaries, conflicts, backend-not-ready, and rollback failure handling.
