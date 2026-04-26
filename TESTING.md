# TESTING

Current validation policy and evidence for Lacapult Doobdab.

## Validation policy

Use the smallest evidence that honestly matches the change.

- Docs/README/license-only changes: grep/static inspection is enough.
- GDScript release parsing changes: live GitHub JSON fixture or small script proof plus static inspection.
- UI node-path changes: Godot parse/load or GUI smoke if Godot is available; otherwise record missing Godot binary as blocker and prove paths by inspection.
- Installer/download changes: avoid huge downloads unless needed; first prove metadata shape and asset selection, especially for C-AOL `v0.2.0`.
- Backend setup changes: prove config shape and safe local detection; do not require real API secrets or large model downloads for v0 evidence.
- Mod Summarizer/apply changes: prove status/discovery first, then sandbox generated packs and rollback; never mutate Josef's real Application Support saves/config/mods for proof work.
- Public pushes/release publication/upstream contact: external actions, require explicit clearance.

## Active proof target - 2026-04-26 real C-AOL mod/Summarizer generation/apply UI v0

Slice 6 is active. Use `doc/lacapult-mod-summarizer-feature-plan-2026-04-25.md` as the contract: promote the existing read-only/dry-run Summarizer surfaces into a user-confirmed generation/apply path for eligible contextual C-AOL mods/worlds. Proofs must remain sandboxed/non-mutating: no package installs, model pulls/downloads, API calls/secrets, or real Application Support/game-state writes without explicit confirmation and a safe path.

## Evidence - 2026-04-26 Summarizer Slice 6 retestable-state/package-shape proof

- Re-ran the post-mod UI retestable-state gate set without publishing a release or mutating real Application Support state: `python3 -m py_compile tools/caol_mod_status_model.py tools/prove_caol_mod_status_model.py tools/prove_caol_summary_pack_apply.py tools/prove_caol_summary_error_matrix.py tools/prove_caol_summarizer_ui_polish.py tools/prove_caol_summarizer_live_ollama_smoke.py tools/prove_lacapult_export_packaging.py`, `python3 tools/prove_caol_mod_status_model.py`, `python3 tools/prove_caol_summarizer_ui_polish.py`, isolated-HOME fixture-backend `/opt/homebrew/bin/godot --path . --no-window --script tools/godot_caol_summarizer_apply_smoke.gd`, `python3 tools/prove_caol_backend_contract.py`, `python3 tools/prove_lacapult_export_packaging.py`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`.
- Evidence logs/artifacts: `.proof-cache/post-mod-ui-retest-readiness/gates.log`, `.proof-cache/post-mod-ui-retest-readiness/gates-rerun.log`, `.proof-cache/post-mod-ui-retest-readiness/fixture-apply.json`, `.proof-cache/post-mod-ui-retest-readiness/package-summary.json`, plus the refreshed ignored export package outputs under `.proof-cache/lacapult-export/`.
- The fixture Summarizer apply smoke used isolated HOME `/tmp/lacapult-summarizer-apply-home.*`, explicit fixture backend generation, and already-local model metadata only; it confirmed preview blocking, separate backend-call confirmation, native `Summaries_extra` companion pack write, `mods.json` order, and backup/rollback visibility.
- `tools/prove_lacapult_export_packaging.py` regenerated unsigned macOS/Linux/Windows packages from current `main` without publishing them. The Windows package was `66,479,179` bytes, SHA-256 `694823044d89f091257ce6dedbf3cd92d0ba3b13ba0014ee3264146dae29dc42`, and the package-shape proof confirmed the required `utils/7za.exe` sidecar. Linux and macOS unsigned packages were also regenerated locally; this remains local package-shape evidence, not a GitHub release.
- Result: the real C-AOL mod/Summarizer generation/apply UI v0 lane is at an honest retestable state for a future Windows retest package. The queued post-mod UI GitHub test/prerelease remains unpublished/parked until Schani/Josef explicitly greenlights that external publication step.

## Evidence - 2026-04-26 Summarizer Slice 6 live-local Ollama smoke v0

- Added `tools/prove_caol_summarizer_live_ollama_smoke.py`, an optional local proof that first checks existing `ollama list` inventory, selects an already-local model, and then runs the existing Godot Summarizer apply smoke under isolated `/tmp/lacapult-summarizer-apply-home.*` HOME with fixture backend disabled and expected backend `ollama`.
- Extended `tools/godot_caol_summarizer_apply_smoke.gd` so the same sandbox writer/apply proof can assert either fixture generation or live-local Ollama generation; the default remains fixture for deterministic gates.
- Tightened the Ollama backend bridge request to use Ollama JSON mode and a bounded `num_predict`, reducing malformed live-response risk without adding model pulls/downloads, remote APIs, package installs, secrets, or real user-data mutation.
- Validation passed locally with already-local model `mistral:latest` from `/opt/homebrew/bin/ollama list`: `python3 -m py_compile tools/prove_caol_summarizer_live_ollama_smoke.py tools/caol_mod_status_model.py tools/prove_caol_mod_status_model.py tools/prove_caol_summary_pack_apply.py tools/prove_caol_summary_error_matrix.py tools/prove_caol_summarizer_ui_polish.py`, `python3 tools/prove_caol_summarizer_live_ollama_smoke.py`, `python3 tools/prove_caol_summarizer_ui_polish.py`, fixture-backend isolated-HOME `/opt/homebrew/bin/godot --path . --no-window --script tools/godot_caol_summarizer_apply_smoke.gd`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`. Evidence JSON: `.proof-cache/slice6-live-ollama-smoke/latest.json`; Godot/output payload: `.proof-cache/slice6-live-ollama-smoke/godot-live-ollama-apply.json`; gate log: `.proof-cache/slice6-live-ollama-gates.log`. Godot emitted known headless macOS cleanup/icon/sound warnings but exited 0.
- Result: live Ollama HTTP generated one C-AOL summary entry and Lacapult applied/staged it through the same isolated companion-pack seam (`npcs/Backgrounds/Summaries_extra`, manifest, selected world `mods.json`, backup/rollback visibility). API/OpenVINO live generation remains gated.


## Evidence - 2026-04-26 Summarizer Slice 6 UI target selection/error polish v0

- Added Settings-tab `Summarizer target world` and `Summarizer target mod` selectors. Worlds are read from local save folders with a readable `mods.json`; eligible mod choices are populated from the selected world's contextual candidates.
- The preview and confirmed generation/apply buttons now pass the selected world and mod id into the existing Slice 6 preview/backend/write gates instead of silently taking the first candidate from the first readable world.
- Added disabled/no-candidate UI states so blocked status is visible before a user tries to confirm generation/apply.
- Added `tools/prove_caol_summarizer_ui_polish.py`, a non-mutating static proof that the Settings surface exposes the selectors, preview/confirm paths use the selected world/mod id, and existing confirmation/backend-call gates remain in place.
- Validation passed: `python3 -m py_compile tools/caol_mod_status_model.py tools/prove_caol_mod_status_model.py tools/prove_caol_summary_pack_apply.py tools/prove_caol_summary_error_matrix.py tools/prove_caol_summarizer_ui_polish.py`, `python3 tools/prove_caol_mod_status_model.py`, `python3 tools/prove_caol_summarizer_ui_polish.py`, fixture-root `tools/godot_caol_mod_ux_status_smoke.gd`, fixture-backend isolated-HOME `tools/godot_caol_summarizer_apply_smoke.gd`, `python3 tools/prove_caol_backend_contract.py`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`. Evidence log: `.proof-cache/slice6-ui-polish-gates.log`; UX JSON: `.proof-cache/slice6-ui-polish-ux.json`; apply JSON: `.proof-cache/slice6-ui-polish-apply.json`. Godot emitted known fixture parse/headless macOS cleanup warnings but exited 0.
- Remaining honest gap at this checkpoint: this polished the chooser/error surface and re-proved sandbox generation/apply; the subsequent live-local Ollama smoke above closes the optional local-model evidence on Josef's Mac, while API/OpenVINO live generation remains gated.


## Evidence - 2026-04-26 Summarizer Slice 6 backend-generation seam v0

- Added `ModManager.generate_and_apply_caol_summarizer_pack()`, a stricter Slice 6 path that requires the existing preview/backend/world/confirmation gates plus a separate explicit backend-call allowance before generation. It then reuses the confirmed writer seam, backup, manifest, native `Summaries_extra`, and world `mods.json` apply machinery.
- Added a proof-safe backend bridge: automated smoke can force `LACAPULT_SUMMARIZER_FIXTURE_BACKEND=1` for deterministic C-AOL summary entries; the live Ollama path calls only the configured local Ollama HTTP endpoint/model with a timeout and does not pull models; API and OpenVINO currently return player-facing gated errors without reading secrets, installing packages, converting/downloading models, or writing files.
- Updated the Settings button to `Confirm backend generation and apply Summary pack`, so the visible confirmed path is now generation+apply rather than writer-only staging.
- Extended `tools/godot_caol_summarizer_apply_smoke.gd` to prove the extra backend-call confirmation block, fixture generation result, companion pack apply, `mods.json` order, and rollback visibility under isolated `/tmp/lacapult-summarizer-apply-home.*` HOME.
- Validation passed: `python3 -m py_compile tools/caol_mod_status_model.py tools/prove_caol_mod_status_model.py tools/prove_caol_summary_pack_apply.py tools/prove_caol_summary_error_matrix.py`, `python3 tools/prove_caol_mod_status_model.py`, fixture-root `tools/godot_caol_mod_ux_status_smoke.gd`, fixture-backend isolated-HOME `tools/godot_caol_summarizer_apply_smoke.gd`, `python3 tools/prove_caol_backend_contract.py`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`. Evidence log: `.proof-cache/slice6-backend-generation-gates.log`; generation/apply JSON: `.proof-cache/slice6-backend-generation-smoke.json`. Godot emitted known fixture parse/headless macOS cleanup warnings but exited 0.
- Remaining honest gap at this checkpoint: fixture generation was sandbox-proven and Ollama live wiring existed behind confirmation/readiness gates, but no real model/API/OpenVINO generation smoke was claimed in that run. The subsequent live-local Ollama smoke above closes the Ollama part on Josef's Mac; API/OpenVINO live generation remains gated.


## Evidence - 2026-04-26 Summarizer Slice 6 confirmed apply/writer seam v0

- Added `ModManager.apply_caol_summarizer_generated_pack()`, the first confirmed writer seam for Slice 6. It reuses the apply preview/backend-good/world gates, requires explicit confirmation, stages a C-AOL-native companion mod, writes `modinfo.json`, `lacapult_summary_pack_manifest.json`, and `npcs/Backgrounds/Summaries_extra/generated_<source>.json`, updates the selected world `mods.json` order so the companion loads after the source mod, and records backup/rollback paths.
- Added a Settings-tab button `Confirm and apply generated Summary pack` next to the existing preview button. The visible copy now distinguishes preview from explicit confirmation and keeps backend/package/model actions gated.
- Added `tools/godot_caol_summarizer_apply_smoke.gd`, which builds a tiny C-AOL-like install/userdata tree under an isolated `/tmp/lacapult-summarizer-apply-home.*` HOME, uses an already-local Ollama model only for readiness detection, confirms the apply path, and verifies the generated companion pack, native `Summaries_extra` file, manifest, `mods.json` order, and backup visibility. It does not pull models, call APIs, install packages, or touch real Application Support state.
- Validation passed: `python3 -m py_compile tools/caol_mod_status_model.py tools/prove_caol_mod_status_model.py tools/prove_caol_summary_pack_apply.py tools/prove_caol_summary_error_matrix.py`, `python3 tools/prove_caol_mod_status_model.py`, `LACAPULT_CAOL_MOD_STATUS_FIXTURE=... /opt/homebrew/bin/godot --path . --no-window --script tools/godot_caol_mod_ux_status_smoke.gd`, isolated-HOME `/opt/homebrew/bin/godot --path . --no-window --script tools/godot_caol_summarizer_apply_smoke.gd`, `python3 tools/prove_caol_backend_contract.py`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`. Evidence log: `.proof-cache/slice6-confirmed-apply-gates.log`; confirmed apply JSON: `.proof-cache/slice6-confirmed-apply-smoke.json`. Godot emitted known fixture parse/headless macOS cleanup warnings but exited 0.
- Remaining honest gap: the writer stages deterministic/generated entries through the Lacapult seam and backup/apply machinery; live LLM text generation with API/Ollama/OpenVINO remains gated and must not use secrets, package installs, model pulls, or real user-data mutation without explicit confirmation.

## Evidence - 2026-04-26 Summarizer Slice 6 apply-preview v0

- Added a Slice 6 generation/apply plan model in `scripts/CaolModStatusModel.gd`: it selects an eligible enabled contextual mod from the existing status model, carries the backend-good gate, names the companion summary mod, previews C-AOL-native `npcs/Backgrounds/Summaries_extra` / `Summaries_short` write paths, shows the planned world `mods.json` order, and lists backup/rollback responsibilities.
- Added `ModManager.get_caol_summarizer_apply_preview()` and a Settings button `Preview Summarizer apply plan`. The button is still non-mutating: it renders the plan and confirmation requirement only; it does not call a backend, generate files, apply packs, enable mods, or edit saves.
- Extended `tools/godot_caol_mod_ux_status_smoke.gd` so the sandbox fixture proves three Slice 6 states: unconfirmed preview is blocked and non-mutating, confirmed+backend-ready plan exposes the real would-write/would-generate/would-enable side effects plus native summary-root path, and confirmed+backend-not-ready remains blocked.
- Validation passed: `python3 -m py_compile tools/caol_mod_status_model.py tools/prove_caol_mod_status_model.py tools/prove_caol_summary_pack_apply.py tools/prove_caol_summary_error_matrix.py`, `python3 tools/prove_caol_mod_status_model.py`, `LACAPULT_CAOL_MOD_STATUS_FIXTURE=... /opt/homebrew/bin/godot --path . --no-window --script tools/godot_caol_mod_ux_status_smoke.gd`, `python3 tools/prove_caol_backend_contract.py`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`. Godot emitted known fixture parse errors/headless macOS cleanup warnings but exited 0. Evidence log: `.proof-cache/slice6-preview-gates.log`; plan JSON: `.proof-cache/caol-mod-status-fixture/ux_slice6.json`.
- This is the first real UI/action-plan step, not the final writer: automated proof still writes only ignored sandbox/proof-cache artifacts and does not mutate Josef's real Application Support config, saves, worlds, mods, API secrets, packages, or models.

## Evidence - 2026-04-26 LLM backend setup installer packet v0

- `python3 tools/prove_backend_setup_installer_packet.py` passed. It proves the standalone `C-AOL LLM backend setup` tab exists, the old Settings backend panel is no longer constructed, player-facing backend setup surfaces avoid Josef/test-run/Windows-first leakage, confirmation-gated actions are present, the inherited thank-you/lineage copy remains, and Ollama fixture recommendations cover low/unknown vs stronger hardware while leaving choice manual.
- `python3 tools/prove_caol_backend_contract.py` passed. It still verifies C-AOL `LLM_INTENT_*` option names, API/Ollama/OpenVINO config/readiness shape, sandboxed options patches, no secret-bearing fields, no API calls, no model pulls, no OpenVINO installs, and no real user config mutation.
- `/opt/homebrew/bin/godot --path . --no-window --script tools/godot_backend_triad_smoke.gd` passed, including backend tab token checks for `API / AnyLLM`, `Ollama local`, `OpenVINO specialized`, `mistral-v0.3`, `nemotron-9b`, and confirmation/no-download wording.
- `/opt/homebrew/bin/godot --path . --no-window --quit` passed as the project-load gate. It printed known macOS/headless cleanup warnings and a real-user sound-dir warning, but exited 0 and performed no installer/backend mutation.
- `git diff --check` passed.

## Evidence - 2026-04-26 Lacapult launcher test/prerelease

- Removed stale `.proof-cache/lacapult-export` output before packaging, then regenerated fresh unsigned Lacapult launcher packages from `main` at source commit `c7ccd26` (`Greenlight Lacapult launcher test release`).
- Created GitHub prerelease `lacapult-test-2026-04-26`: https://github.com/josihosi/Lacapult-Doobdab/releases/tag/lacapult-test-2026-04-26
- Release title: `Lacapult Doobdab test build 2026-04-26`; `gh release view lacapult-test-2026-04-26 --repo josihosi/Lacapult-Doobdab --json tagName,name,isPrerelease,assets,url` verified `isPrerelease=true` and the uploaded assets below.
- Uploaded assets:
  - `Lacapult-Doobdab-windows-unsigned.zip` — 59,704,154 bytes — SHA-256 `357e906bb20a3e3ae558774e1bd25a716ebb1952e4a3c93ac515d91cb7d3ef71`
  - `Lacapult-Doobdab-macos-unsigned.zip` — 84,107,918 bytes — SHA-256 `f14644f94bd930c2567627c46e3e1362cafc1904175c04b732966154526c6b12`
  - `Lacapult-Doobdab-linux-unsigned.tar.gz` — 32,940,324 bytes — SHA-256 `522885ba710130f2cf95551c566b305638d3db211f493c4e65f9ddfb36c3d935`
  - `SHA256SUMS.txt` — 311 bytes — SHA-256 `2304fb9067950fc7dd535e431d134f72c3aff0e68b3fc197b140923cf15f8ef1`
- Proof commands passed:
  - `python3 tools/prove_lacapult_export_packaging.py`
  - `python3 tools/prove_caol_release.py --all-platforms`
  - `python3 tools/prove_caol_backend_contract.py`
  - `/opt/homebrew/bin/godot --path . --no-window --quit`
  - `git diff --check`
- Release notes and tag are Lacapult-specific and state that this is an unsigned Lacapult launcher test build, not a C-AOL game release and not C-AOL `v0.3.0`.
- Remaining caveats: unsigned Windows/macOS/Linux launcher packages; no Apple notarization; no Windows code signing or SmartScreen reputation; not final public confidence; Josef's real Windows laptop download/extract/run/install/launch click-through still remains his test step.

## Current evidence

Initial source audit from Schani:

- Source repo `Hihahahalol/Catapult_Dabdoob` is public, standalone, and MIT licensed.
- Source tech is Godot/GDScript with helper Python/Shell scripts.
- Source `LICENSE` includes qrrk and Dabdoob copyright notices.
- Source README credits CDDA, CTLG, BN, and qrrk Catapult.
- Local scaffold created at `/Users/josefhorvath/Schanigarten/Lacapult-Doobdab` by copying source without inherited `.git` history and initializing a new local git repo.

## Required v0 proof packet

Before claiming v0 is done, Andi should record:

1. Identity/attribution proof
   - `grep -R` evidence that public identity points to Lacapult Doobdab/C-AOL.
   - Remaining Dabdoob/Catapult references are credits or internal filenames intentionally left for later.

2. Release parsing proof
   - live `gh release view` or GitHub API capture for `josihosi/Cataclysm-AOL`.
   - platform filter result for the current OS.
   - at least one expected asset selected from `v0.2.0` release assets.

3. Backend setup proof
   - API option/config path exists and avoids secret leakage.
   - Ollama option/config path exists and local detection is run if available.
   - API, Ollama, and OpenVINO selector/status paths exist; OpenVINO is selectable with honest v0 placeholder/detection/status metadata, not full automation.

4. Modding investigation proof
   - inherited mod/soundpack/tileset entry points are identified.
   - C-AOL stock/user/custom-catalog compatibility assumptions are classified as supported, untested, broken, or unknown; future NPC-summary metadata remains investigation-only.

5. Godot/static proof
   - `godot --version` / `godot3 --version` / `godot4 --version` check.
   - If Godot exists: run the strongest cheap headless/project parse check available for this version.
   - If Godot does not exist: state that clearly and rely on static grep plus code-shape proof for first handoff.

6. Installer-shape proof
   - show the release object handed to installer has `name`, `url`, `filename`, `published_at`, `has_any_assets`.
   - do not download a huge release archive unless Schani/Josef explicitly wants that proof.

## Evidence - 2026-04-25 controlled macOS DMG shape proof

- Added `tools/prove_caol_macos_dmg.py` to prove the selected C-AOL `v0.2.0` macOS DMG shape from live GitHub metadata. Default mode is metadata-only; `--download` performs the bounded download/mount/inspect/detach proof.
- Ran `python3 tools/prove_caol_macos_dmg.py --download`; it selected `caol_cdda-0-h_2026-03-29-1556_macos.dmg` from `josihosi/Cataclysm-AOL` `v0.2.0`, downloaded 271,265,739 bytes into ignored `.proof-cache/`, mounted read-only/no-browse with `hdiutil`, inspected `/Volumes/Cataclysm DDA`, and detached successfully.
- DMG shape proof found top-level `Cataclysm.app` plus `Applications`. Inside `Cataclysm.app`, Lacapult's current app-bundle guard can match `Contents/MacOS/Cataclysm.sh` and preferred C-AOL executable `Contents/Resources/cataclysm-tiles`; `looks_launchable` was true.
- This proves the selected macOS asset has a launchable app-bundle shape compatible with the current installer/launcher guards. It does **not** claim a full in-launcher install into Lacapult's install folder or a game launch smoke.
- Re-ran `python3 tools/prove_caol_release.py --all-platforms`; Linux, macOS, and Windows still produced installable `v0.2.0` metadata without archive downloads.
- Re-ran `python3 tools/prove_caol_backend_contract.py`; C-AOL option names still match local `src/options.cpp`, no secret-bearing fields are introduced, and the patch remains preview-only.
- `godot --version` returned `3.6.2.stable.official.3cd3caab6`; this run did not need a new GUI screenshot because the changed seam was the external DMG shape proof.
- Re-ran `git diff --check`; it passed.


## Evidence - 2026-04-25 sandboxed macOS DMG install-shape proof

- Extended `tools/prove_caol_macos_dmg.py` with `--install-sandbox`. The new mode still fetches live release metadata and uses the selected C-AOL `v0.2.0` macOS DMG, then mounts it read-only/no-browse and copies/moves its contents through a temporary Lacapult-style `Library/Application Support/Lacapult Doobdab/caol/{tmp,game0}` tree. The sandbox is removed after the proof.
- Ran `python3 tools/prove_caol_macos_dmg.py --install-sandbox`; it reused/downloaded `caol_cdda-0-h_2026-03-29-1556_macos.dmg` (271,265,739 bytes), mounted `/Volumes/Cataclysm DDA`, copied the mount root while skipping `Applications`, selected the app-containing extracted root, created `catapult_install_info.json`, moved contents into sandbox `caol/game0`, and detached successfully.
- Final sandbox install listing was `Cataclysm.app` plus `catapult_install_info.json`; the info file contained `Cataclysm - Arsenic and Old Lace v0.2.0`; `looks_launchable_after_move` was true via Lacapult's app-bundle guard.
- This is stronger than metadata/mount inspection because it proves the final install-folder shape after a Lacapult-style copy/move. It still does **not** claim a clicked GUI install, mutation of the real Lacapult Application Support install state, or a C-AOL launch smoke.
- Ran `python3 -m py_compile tools/prove_caol_macos_dmg.py`; it passed.
- Re-ran `python3 tools/prove_caol_release.py --all-platforms` and `python3 tools/prove_caol_backend_contract.py`; release metadata and backend option contract still pass.
- Re-ran `godot --version`; Godot is available as `/opt/homebrew/bin/godot` and reports `3.6.2.stable.official.3cd3caab6`.
- Re-ran `git diff --check`; it passed.

## Evidence - 2026-04-25 cron revalidation

- Re-ran `python3 tools/prove_caol_release.py --all-platforms`; live `josihosi/Cataclysm-AOL` `v0.2.0` data still has 12 assets, and Linux, macOS, and Windows each matched 4 platform assets with installer metadata containing `name`, `url`, `filename`, `asset_size`, `release_page_url`, `published_at`, and `has_any_assets` without downloading archives.
- Re-ran `python3 tools/prove_caol_backend_contract.py`; local C-AOL `src/options.cpp` still contains the required `LLM_INTENT_*` option names, Lacapult still references all required names, no forbidden secret-bearing field tokens were found, and the patch remains preview-only.
- Re-ran safe Ollama detection: `command -v ollama` returned `/opt/homebrew/bin/ollama`; `ollama list` succeeded against the local server. No model pull, install, remote API call, or API secret was used.
- Re-ran Godot availability check: `godot`, `godot3`, and `godot4` are still unavailable on this Mac, so no GUI/project-load smoke was claimed.
- `git diff --check` passed.

## Evidence - 2026-04-25 Ollama backend status tightening

- Tightened `scripts/BackendConfigManager.gd` so the UI/config path can distinguish an installed Ollama command with a responding local server from an installed command whose server is unreachable.
- Static proof: `grep -n "where\|OS.execute(\"ollama\"\|ollama_command_present_server_running\|ollama_command_present_server_unreachable" scripts/BackendConfigManager.gd` shows the platform-aware command lookup and cheap server probe statuses.
- Re-ran safe local Ollama proof: `command -v ollama` returned `/opt/homebrew/bin/ollama`; `ollama list` returned the local model table, proving the current Mac would report `ollama_command_present_server_running`. No model pull, install, remote API call, or secret-bearing smoke test was attempted.
- Re-ran `python3 tools/prove_caol_release.py --all-platforms`; v0.2.0 still produced installable metadata for Linux, macOS, and Windows without downloading archives.
- Re-ran Godot availability check: `godot`, `godot3`, and `godot4` are still unavailable on this Mac, so no GUI/project-load smoke was claimed.
- `git diff --check` passed.

## Evidence - 2026-04-25 local proof packet closure

- Re-ran `python3 tools/prove_caol_release.py --all-platforms`; live GitHub data for `josihosi/Cataclysm-AOL` still includes `v0.2.0` with 12 assets, and Linux, macOS, and Windows each produced installable metadata with `name`, `url`, `filename`, `asset_size`, `release_page_url`, `published_at`, and `has_any_assets` without archive downloads.
- Re-ran `python3 tools/prove_caol_backend_contract.py`; the local C-AOL checkout still contains `LLM_INTENT_BACKEND`, `LLM_INTENT_OLLAMA_URL`, `LLM_INTENT_OLLAMA_MODEL`, `LLM_INTENT_API_KEY_ENV`, and `LLM_INTENT_API_MODEL`; Lacapult references all of them, stores no forbidden secret-bearing field tokens, and keeps the options patch preview-only.
- Re-ran Godot availability check: `godot`, `godot3`, and `godot4` are unavailable on this Mac, so no GUI/project-load smoke is claimed.
- Re-ran `git diff --check`; it passed.
- Canon now records that the public repo exists at `https://github.com/josihosi/Lacapult-Doobdab`, while public pushes/releases/contact remain blocked on fresh Schani/Josef clearance.

## Evidence - 2026-04-25 Godot GUI first-run smoke

- Ran Godot 3.6.2 GUI from `/Users/josefhorvath/Schanigarten/Lacapult-Doobdab` and captured the launched window with Peekaboo screenshots under `~/.openclaw/workspace/runtime/lacapult-gui-smoke/`.
- Initial GUI smoke surfaced two user-visible issues before handoff: the build selector opened on an older non-installable inherited `Cataclysm-DDA experimental build...` release row, and the backend setup section was appended below the visible Settings area.
- Fixed `scripts/ReleaseManager.gd` so C-AOL release filters prefer `v0.2.0` and then show other installable releases before blocked/no-asset rows; `tools/prove_caol_release.py --all-platforms` now also asserts the prioritized UI order starts with installable `v0.2.0`.
- Fixed `scripts/SettingsUI.gd` so `C-AOL NPC backend setup` appears near the top of Settings with visible Backend, Endpoint, Model, status/help text, and `Save backend setup metadata` controls.
- Fixed the inherited disabled self-update button text in `scenes/Catapult.tscn` from `Update Dabdoob` to `Update Lacapult`.
- Final GUI screenshots proved:
  - window title `Lacapult Doobdab — Cataclysm: Arsenic and Old Lace`
  - Game target `Cataclysm: Arsenic and Old Lace`
  - first build row `Cataclysm - Arsenic and Old Lace v0.2.0 — caol_cdda-0-h_2026-03-29-1556_macos.dmg ...`
  - backend dropdown options for API, Ollama, and the third OpenVINO path; later evidence below tightens the label/status to `OpenVINO backend` with v0-honest placeholder metadata
  - API backend status/help text: `API mode saves endpoint/model metadata only; Lacapult v0 never stores API keys.`
- No API secrets, model pulls, heavy release downloads, GitHub releases, or upstream contact were used. The real macOS DMG extraction/app-bundle install pass remains the next heavier proof.

## Evidence - 2026-04-25 cron project-load/install-shape revalidation

- Re-ran `python3 tools/prove_caol_release.py --all-platforms`; live `josihosi/Cataclysm-AOL` `v0.2.0` still has 12 assets, Linux/macOS/Windows each matched 4 installable platform assets, and the prioritized UI order still starts with installable `v0.2.0` metadata.
- Re-ran `python3 tools/prove_caol_backend_contract.py`; local C-AOL `src/options.cpp` still contains the required `LLM_INTENT_*` option names, Lacapult still references them without forbidden secret-bearing field tokens, and the patch remains preview-only.
- Re-ran `python3 -m py_compile tools/prove_caol_macos_dmg.py` and `python3 tools/prove_caol_macos_dmg.py --install-sandbox`; the cached selected macOS DMG still mounts read-only, exposes launchable `Cataclysm.app`, and produces a sandbox final install folder containing `Cataclysm.app` plus `catapult_install_info.json` with `looks_launchable_after_move=true`.
- Re-ran Godot availability/project-load proof: `/opt/homebrew/bin/godot --version` reports `3.6.2.stable.official.3cd3caab6`, and `godot --path . --no-window --quit` exits 0. Godot printed known macOS/headless cleanup warnings at exit, but this was still a successful project-load smoke; it did not click through an in-launcher install.
- Re-ran safe Ollama detection: `command -v ollama` returned `/opt/homebrew/bin/ollama`; `ollama list` succeeded against the local server. No model pull, install, remote API call, or API secret was used.
- Re-ran `git diff --check`; it passed.

## Evidence - 2026-04-25 headless Godot installer smoke

- Added `tools/godot_install_release_smoke.gd`, a headless Godot 3 script intended to run with an isolated `HOME` and an already-downloaded C-AOL macOS DMG path in `LACAPULT_CAOL_DMG`.
- Ran `LACAPULT_CAOL_DMG="$PWD/.proof-cache/caol-dmg/caol_cdda-0-h_2026-03-29-1556_macos.dmg" HOME=$(mktemp -d /tmp/lacapult-godot-install-home.XXXXXX) /opt/homebrew/bin/godot --path . --no-window --script tools/godot_install_release_smoke.gd`.
- The smoke invoked the actual Godot `ReleaseInstaller.install_release()` path with the selected cached `v0.2.0` DMG, so `FS.extract()`, `hdiutil` mount/copy/detach, `_find_game_root_directory()`, `catapult_install_info.json` creation, final move into `caol/game0`, chmod pass, and `_looks_like_game_directory()` launchability guard were exercised by Lacapult's GDScript rather than the Python mimic.
- The isolated install root was under `/tmp/lacapult-godot-install-home.../Library/Application Support/Lacapult Doobdab`, not the real user Application Support tree. Final proof JSON reported `target_exists=true`, `app_exists=true`, `info_exists=true`, `looks_launchable=true`, listing `Cataclysm.app` plus `catapult_install_info.json`, with install info name `Cataclysm - Arsenic and Old Lace v0.2.0`.
- Godot exited 0. It printed the known no-UI `Status label not found`/cleanup warnings because the smoke intentionally did not instantiate the full `Catapult` scene; those warnings did not prevent the installer path from completing. This still does **not** claim a clicked GUI install or C-AOL game launch smoke.

## Evidence - 2026-04-25 full-scene install button smoke

- Added `tools/godot_scene_install_button_smoke.gd`, a headless Godot 3 script that instantiates `scenes/Catapult.tscn` instead of calling `ReleaseInstaller` directly. It runs with an isolated `HOME` and an already-downloaded C-AOL macOS DMG path in `LACAPULT_CAOL_DMG`.
- Ran `LACAPULT_CAOL_DMG="$PWD/.proof-cache/caol-dmg/caol_cdda-0-h_2026-03-29-1556_macos.dmg" HOME=$(mktemp -d /tmp/lacapult-scene-install-home.XXXXXX) /opt/homebrew/bin/godot --path . --no-window --script tools/godot_scene_install_button_smoke.gd`.
- The smoke waited for the real `ReleaseManager` live GitHub fetch in the main scene, verified the first Game-tab release row was `Cataclysm - Arsenic and Old Lace v0.2.0` with selected asset `caol_cdda-0-h_2026-03-29-1556_macos.dmg`, selected build row 0, emitted the real `BtnInstall` pressed signal, and waited for the scene's `ReleaseInstaller` to finish.
- Final isolated install proof reported `target_exists=true`, `app_exists=true`, `info_exists=true`, and `looks_launchable=true` under `/tmp/lacapult-scene-install-home.../Library/Application Support/Lacapult Doobdab/caol/game0`; the final listing included `Cataclysm.app` and `catapult_install_info.json`, and install info name was `Cataclysm - Arsenic and Old Lace v0.2.0`.
- This is stronger than the direct headless installer smoke because it exercises the main scene's release-list selection and Install button signal path. It still does **not** claim a physical mouse-clicked GUI install or a C-AOL game launch smoke.
- Godot exited 0. It printed known macOS/no-window cleanup warnings at process exit; they did not prevent the full-scene install-button path from completing.

## Evidence - 2026-04-25 physical clicked GUI install pass

- Launched `/opt/homebrew/bin/godot --path .` as a visible GUI with isolated `HOME=/tmp/lacapult-click-home.XIDrDG`, after pre-populating that HOME's Lacapult cache with the selected C-AOL `v0.2.0` macOS DMG (`caol_cdda-0-h_2026-03-29-1556_macos.dmg`). This avoided touching the real `~/Library/Application Support/Lacapult Doobdab` state and avoided a fresh heavy download.
- Captured the visible launcher window with Peekaboo under `~/.openclaw/workspace/runtime/lacapult-click-smoke/initial.png`; the window title was `Lacapult Doobdab — Cataclysm: Arsenic and Old Lace`, the first build row was the prioritized `Cataclysm - Arsenic and Old Lace v0.2.0` macOS DMG, and `Install Selected` was visible/enabled.
- Used Peekaboo to send an actual mouse click at the visible `Install Selected` button location rather than emitting a Godot signal.
- Verified the isolated clicked install completed at `/tmp/lacapult-click-home.XIDrDG/Library/Application Support/Lacapult Doobdab/caol/game0` with `Cataclysm.app` and `catapult_install_info.json`; the install info recorded `Cataclysm - Arsenic and Old Lace v0.2.0`.
- Re-ran the cheap proof packet after the clicked pass: `python3 tools/prove_caol_release.py --all-platforms`, `python3 tools/prove_caol_backend_contract.py`, `python3 -m py_compile tools/prove_caol_macos_dmg.py`, `/opt/homebrew/bin/godot --version`, `/opt/homebrew/bin/godot --path . --no-window --quit`, safe `ollama list`, and `git diff --check`. Godot printed the known macOS/no-window cleanup warnings but exited successfully; `git diff --check` passed after trimming a trailing blank line in this documentation update.
- This closes the previously parked clicked GUI install proof. It still does **not** claim a C-AOL game-launch smoke, GitHub release publication, upstream contact, model pulls, heavyweight installs, or API-secret use.


## Evidence - 2026-04-25 cron release-prep revalidation

- Re-ran `python3 tools/prove_caol_release.py --all-platforms`; live `josihosi/Cataclysm-AOL` `v0.2.0` still has 12 assets, Linux/macOS/Windows each matched 4 installable platform assets, and the prioritized UI order still starts with installable `v0.2.0` metadata.
- Re-ran `python3 tools/prove_caol_backend_contract.py`; local C-AOL `src/options.cpp` still contains the required `LLM_INTENT_*` option names, Lacapult still references them without forbidden secret-bearing fields, and the options patch remains preview-only.
- Re-ran `python3 -m py_compile tools/prove_caol_macos_dmg.py`; the DMG proof helper still compiles.
- Re-ran Godot availability/project-load proof: `/opt/homebrew/bin/godot --version` reports `3.6.2.stable.official.3cd3caab6`, and `/opt/homebrew/bin/godot --path . --no-window --quit` exits 0. Godot printed the known macOS/no-window cleanup warnings at exit, but the project-load smoke succeeded.
- Re-ran safe Ollama detection: `ollama list` succeeded against the local server. No model pull, install, remote API call, or API secret was used.
- Re-ran `git diff --check`; it passed. `git status --short --branch` showed `main...origin/main` before this documentation-only evidence update.

## Evidence - 2026-04-25 C-AOL mod/summarizer bridge report

- Extended `tools/prove_caol_mod_inventory.py` from a high-level mod inventory into a structured per-mod compatibility/summarizer bridge proof. It still mounts the selected cached C-AOL `v0.2.0` macOS DMG read-only/no-browse, but now emits JSON and Markdown reports under `.proof-cache/caol-mod-bridge/`.
- Ran `python3 tools/prove_caol_mod_inventory.py`; it found 42 non-obsolete packaged stock mods and 7 obsolete packaged mods in `Cataclysm.app/Contents/Resources/data/mods`. Status counts were `blocker-obsolete: 7`, `summarizer-compatible-but-needs-generated-pack: 30`, and `no-summary-needed: 12`. No packaged mod currently has `npcs/Backgrounds/Summaries_short` or `npcs/Backgrounds/Summaries_extra`, so no mod is `summarizer-ready` yet.
- The report records per-mod id/name, obsolete flag, dependencies, packaged-path presence, summary-root presence, JSON content flags, parse errors, missing dependencies, and status/reason classification. No JSON parse errors or missing dependency blockers were found in the selected packaged mod set.
- Verified the C-AOL bridge contract by static source inspection: `src/llm_intent.cpp` merges core data, active mod roots, and world custom-mod roots in `background_summary_data_roots()`, then loads active-root `npcs/Backgrounds/Summaries_short` and `npcs/Backgrounds/Summaries_extra`. `TechnicalTome.md` documents the JSON schema and override rules.
- Validation command set for this slice: `python3 -m py_compile tools/prove_caol_mod_inventory.py`, `python3 tools/prove_caol_mod_inventory.py`, `python3 tools/prove_caol_release.py --all-platforms`, static `rg` for C-AOL summary roots/runtime loading, and `git diff --check`; all passed.
- This is proof/report only. It does not claim UI surfacing, generated summary-pack installation, world mutation, enabling mods in real saves, model pulls, API secrets, upstream contact, or public release work.

## Evidence - 2026-04-25 C-AOL summary-pack apply/rollback Slice 3

- Added `tools/prove_caol_summary_pack_apply.py`, a sandbox-only Slice 3 proof for C-AOL-native companion summary-pack generation/apply/rollback. It builds a fixture C-AOL userdata/world tree under `.proof-cache/caol-summary-pack-apply/`; it does not touch Josef's real Application Support config, saves, mods, or installed game.
- Ran `python3 -m py_compile tools/prove_caol_summary_pack_apply.py tools/caol_mod_status_model.py`; it passed.
- Ran `python3 tools/prove_caol_summary_pack_apply.py`; it chose fixture stock mod `fixture_apply_context_stock`, staged companion user mod `lacapult_summary_fixture_apply_context_stock`, wrote `npcs/Backgrounds/Summaries_extra/generated_fixture_apply_context_stock.json` as an `npc_personality_summary_bundle`, wrote `lacapult_summary_pack_manifest.json`, backed up sandbox `mods.json`, applied the companion pack, changed sandbox mod order from `["dda"]` to `["dda", "fixture_apply_context_stock", "lacapult_summary_fixture_apply_context_stock"]`, proved the status model saw the source as `summary-ready` and companion manifest as generated-pack-present, then rolled back to the exact prior `mods.json` bytes and removed the generated pack. Evidence: `.proof-cache/caol-summary-pack-apply/evidence/evidence.json`.
- Re-ran no-regression proof: `python3 tools/prove_caol_release.py --all-platforms`, `python3 tools/prove_caol_backend_contract.py`, `python3 tools/prove_caol_mod_status_model.py`, `godot_caol_mod_status_smoke.gd`, `godot_caol_mod_ux_status_smoke.gd`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`; all passed. Godot printed the known fixture JSON parse errors and macOS/no-window cleanup warnings, but exited 0.
- This is still fixture/proof-only. It does not call a backend, use API secrets, pull models, install OpenVINO, mutate real user data, enable real mods, prove C-AOL runtime prompt consumption, publish releases, or contact upstream.

## Evidence - 2026-04-25 C-AOL runtime summary consumption Slice 4

- Added `tools/prove_caol_runtime_summary_consumption.py`, a deterministic C-AOL harness/source proof for Slice 4. It builds a sandbox under `.proof-cache/caol-runtime-summary-consumption/`, activates `dda`, `fixture_runtime_context_stock`, and `lacapult_summary_fixture_runtime_context_stock` in sandbox `mods.json`, and stages a generated C-AOL-native `npc_personality_summary_bundle` under the companion mod's `npcs/Backgrounds/Summaries_extra`.
- The proof chose the current C-AOL path `/Users/josefhorvath/Schanigarten/Cataclysm-AOL` after verifying it is on `dev`; the older `Cataclysm-AOL-standalone` path is not present in this workspace. Source inspection records the relevant `src/llm_intent.cpp` seams: `background_summary_data_roots()` uses `active_world->active_mod_order`, loads `Summaries_short` / `Summaries_extra`, accepts bundled JSON summaries, and emits `your_tone` / `your_example_expression` during prompt construction.
- Ran `python3 tools/prove_caol_runtime_summary_consumption.py`; it derived active roots from sandbox `mods.json`, confirmed the generated companion root contributes `npcs/Backgrounds/Summaries_extra`, ran C-AOL `tools/llm_runner/npc_harness.py --resolve-only --json`, and dumped the deterministic prompt. Evidence: `.proof-cache/caol-runtime-summary-consumption/evidence/evidence.json`, `npc_harness_resolve.json`, and `npc_harness_prompt.txt`.
- Decisive result: selected selector `name:Lacapult Runtime Fixture NPC`; `your_tone` was `The generated companion pack makes this NPC speak with sandbox runtime-proof context.`; `your_example_expression` was `Mention the Lacapult-generated summary only because the active companion root supplied it.`
- Revalidation for this handoff passed: `python3 -m py_compile tools/prove_caol_runtime_summary_consumption.py tools/prove_caol_summary_pack_apply.py tools/caol_mod_status_model.py`, `python3 tools/prove_caol_runtime_summary_consumption.py`, `python3 tools/prove_caol_summary_pack_apply.py`, and `git diff --check`. This is deterministic harness proof plus C++ source-seam inspection; it does not launch a compiled C-AOL game world, call a backend, use API secrets, pull models, mutate real Application Support state, or cover the broader Slice 5 error matrix.

## Pending evidence - real C-AOL mod/Summarizer generation/apply UI v0

Active contract: `doc/lacapult-mod-summarizer-feature-plan-2026-04-25.md`, Slice 6.

Required before closure:

- Godot/UI proof that the existing dry-run Summarizer button can become a real user-confirmed path only for eligible contextual mods/worlds.
- Backend readiness gate proof for API/Ollama/OpenVINO before generation/apply actions are enabled.
- Preview/confirmation proof before any companion summary pack write or `mods.json` change.
- Sandbox apply/rollback proof using the same C-AOL-native companion pack shape already proven in Slices 3-5.
- No automated proof may mutate Josef's real Application Support config, saves, worlds, mods, API secrets, packages, or models.
- `git diff --check` plus the smallest meaningful Godot/project-load/smoke gate.

## Evidence - 2026-04-25 C-AOL Summarizer Slice 5 error/rollback matrix

- Added `tools/prove_caol_summary_error_matrix.py`, a sandbox-only proof that builds weird C-AOL-like fixtures under `.proof-cache/caol-summary-error-matrix/` and writes compact evidence to `.proof-cache/caol-summary-error-matrix/evidence/evidence.json`.
- The proof covers broken `modinfo.json`, content JSON parse errors, missing dependencies, obsolete mods, missing summary roots reported as `summary-missing`, partial summary roots, stale generated-pack source fingerprints, conflicting generated packs with overlapping selector/topic claims, backend-not-ready generation gates, and replacement rollback for a preexisting generated companion pack.
- Status-model visibility was tightened in both `tools/caol_mod_status_model.py` and `scripts/CaolModStatusModel.gd`: content parse errors, `summary-stale`, `summary-conflict`, backend-not-ready, and `summary-blocked` are now surfaced as status badges/counts where applicable.
- Rollback proof replaces a preexisting generated companion pack, edits sandbox `mods.json`, then restores the exact prior `mods.json` bytes and preexisting pack directory.
- Validation command set for this handoff: `python3 -m py_compile tools/caol_mod_status_model.py tools/prove_caol_mod_status_model.py tools/prove_caol_summary_pack_apply.py tools/prove_caol_runtime_summary_consumption.py tools/prove_caol_summary_error_matrix.py`, `python3 tools/prove_caol_mod_status_model.py`, `python3 tools/prove_caol_summary_error_matrix.py`, `python3 tools/prove_caol_summary_pack_apply.py`, `python3 tools/prove_caol_runtime_summary_consumption.py`, `LACAPULT_CAOL_MOD_STATUS_FIXTURE=... /opt/homebrew/bin/godot --path . --no-window --script tools/godot_caol_mod_status_smoke.gd`, `LACAPULT_CAOL_MOD_STATUS_FIXTURE=... /opt/homebrew/bin/godot --path . --no-window --script tools/godot_caol_mod_ux_status_smoke.gd`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`; all passed. Godot still prints the known fixture JSON parse-error/status-warning lines and macOS/no-window cleanup warnings, but exits 0.
- This remains proof/status work only: no real user mod apply, no real Application Support mutation, no backend/API call, no API secret use, no model pull/download/install, no OpenVINO install, no C-AOL package mutation, no signing/notarization/release publication, and no upstream contact.

## Known risk spots

- Godot 3 scene node paths may break if the game chooser/channel UI is removed too aggressively.
- Existing release manager duplicates per-game callbacks; adding C-AOL by copy may be safer for v0 than a clever refactor.
- Existing mod/soundpack/tileset code assumes multiple Cataclysm game IDs; hiding other games is safer than deleting support everywhere in the first slice.
- Mod compatibility/NPC summaries are investigation/docs first, not runtime integration in v0.
- Existing self-update URL points to Dabdoob and must not silently offer Dabdoob releases as Lacapult updates.

## Evidence - 2026-04-24 v0.2.0 release/backend proof slice

- Live release parser proof: `python3 tools/prove_caol_release.py`
  - Found `josihosi/Cataclysm-AOL` release `v0.2.0` on Darwin.
  - Matched macOS filter `_macos.dmg` against `caol_cdda-0-h_2026-03-29-1556_macos.dmg`.
  - Produced installer metadata shape with `name`, `url`, `filename`, `published_at`, and `has_any_assets` without downloading the archive.
- Backend local detection proof:
  - `command -v ollama` -> `/opt/homebrew/bin/ollama`
  - `curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags` -> running
  - API backend remains config-shape only; no secrets were used, stored, or logged.
  - OpenVINO was present as a specialized placeholder in this earlier slice; later evidence below upgrades it to selectable v0 status metadata.
- Godot availability check:
  - `godot --version`, `godot3 --version`, and `godot4 --version` were not found on this machine, so no GUI/project-load smoke was claimed.
- Static identity/release proof:
  - `grep -R "caol-release\|josihosi/Cataclysm-AOL\|_macos.dmg\|_linux.tar.gz\|_windows.zip\|backend_ollama\|backend_api\|OpenVINO\|Lacapult Doobdab" -n README.md project.godot scripts text/en doc tools`
  - Shows Lacapult project identity/defaults, C-AOL release URL and asset filters, API/Ollama settings, and OpenVINO parked note.
- Mod support proof:
  - Inherited entry points remain present: `scripts/ModManager.gd`, `scripts/ModsUI.gd`, `scripts/SoundpackManager.gd`, `scripts/SoundpacksUI.gd`, `scripts/TilesetManager.gd`, `scripts/TilesetsUI.gd`.
  - First C-AOL compatibility/NPC-summary note added at `doc/caol-mod-compatibility-summary.md`.

## Evidence - 2026-04-24 warning enum cleanup

- Static warning enum proof: `grep -R "Enums.MSG_WARNING" -n scripts || true`
  - Before cleanup, this found warning posts in installer, download, filesystem, mod, soundpack, and tileset paths.
  - These now use the existing `Enums.MSG_WARN` member from `scripts/Enums.gd`, avoiding a runtime failure when those warning branches execute.
- Re-ran `python3 tools/prove_caol_release.py`; it still selects the Darwin `v0.2.0` DMG and produces installer metadata without downloading it.
- Re-ran Ollama cheap detection: `command -v ollama` is `/opt/homebrew/bin/ollama`; local server probe returned JSON with 8 models. No model pull or secret-bearing API smoke was attempted.

## Evidence - 2026-04-25 backend settings surface

- Added `BackendConfig` as a Godot autoload and wired the Settings tab to create a small C-AOL NPC backend setup section at runtime.
- Static UI proof: `grep -R "BackendConfig=\|BackendSetup\|Save backend setup metadata\|C-AOL NPC backend setup\|OpenVINO\|API mode saves" -n project.godot scripts/SettingsUI.gd scripts/BackendConfigManager.gd`
  - Shows the autoload, runtime-created backend setup section, save button, API no-secret warning, Ollama status readout, and the OpenVINO placeholder/status copy later tightened by the backend triad proof.
- Re-ran `python3 tools/prove_caol_release.py`; it still selects `caol_cdda-0-h_2026-03-29-1556_macos.dmg` for Darwin `v0.2.0` and produces installer metadata without downloading it.
- Re-ran Ollama cheap detection: `command -v ollama` is `/opt/homebrew/bin/ollama`; local server probe returned JSON with 8 models. No model pull or secret-bearing API smoke was attempted.
- Re-ran Godot availability check: `godot`, `godot3`, and `godot4` are still unavailable on this Mac, so no GUI/project-load smoke was claimed.
- `git diff --check` passed for the backend surface changes.

## Evidence - 2026-04-25 all-platform v0.2.0 asset proof

- Extended `tools/prove_caol_release.py` with `--all-platforms`, still using one live GitHub API read and no archive downloads.
- Ran `python3 tools/prove_caol_release.py --all-platforms`:
  - Found `josihosi/Cataclysm-AOL` release `v0.2.0` / `Cataclysm - Arsenic and Old Lace v0.2.0` with 12 assets.
  - Linux filter `_linux.tar.gz` matched 4 assets and produced an installable metadata shape.
  - macOS filters `_macos.dmg`, `_macos.tar.gz`, `_macos.zip` matched 4 DMG assets and produced an installable metadata shape.
  - Windows filter `_windows.zip` matched 4 assets and produced an installable metadata shape.
  - Each platform result included `name`, `url`, `filename`, `published_at`, and `has_any_assets` for the installer handoff shape.

## Evidence - 2026-04-25 release list installability metadata

- Added release-list display metadata so each fetched C-AOL release row can show the selected platform asset name, file size, release-page tooltip, and a clear non-installable state when no matching asset exists.
- Install button guard now also checks selected release `url`, so a release row with no platform asset cannot enable installation just by being selected.
- Extended installer metadata proof with `asset_size` and `release_page_url` while preserving the existing handoff fields: `name`, `url`, `filename`, `published_at`, and `has_any_assets`.
- Re-ran `python3 tools/prove_caol_release.py --all-platforms`:
  - v0.2.0 found with 12 assets.
  - Linux, macOS, and Windows each matched 4 platform assets.
  - Installer shape now includes asset sizes and the v0.2.0 release page URL without downloading archives.
- Re-ran Godot availability check: `godot`, `godot3`, and `godot4` are still unavailable on this Mac, so no GUI/project-load smoke was claimed.
- `git diff --check` passed.

## Evidence - 2026-04-25 installer launchability guard

- Added a post-move launchability guard in `scripts/ReleaseInstaller.gd`: install/update success is no longer posted unless the final target directory still looks like a launchable game root.
- Added macOS `.app` install-root handling for DMG-style extraction: a top-level `.app` keeps the containing temp directory as the game root, so the final install directory contains the bundle where launcher lookup expects it.
- Added `Cataclysm-AOL` to installer executable probes/permission fixups alongside inherited `cataclysm-tiles` names.
- Re-ran `python3 tools/prove_caol_release.py --all-platforms`:
  - v0.2.0 found with 12 assets.
  - Linux, macOS, and Windows each matched 4 platform assets and produced installable metadata without archive downloads.
- Static proof: `grep -n "top-level macOS app bundles\|not _looks_like_game_directory(target_dir)\|Cataclysm-AOL" scripts/ReleaseInstaller.gd` shows the new app-bundle root handling, final target guard, and C-AOL executable probes.
- `git diff --check` passed.
- Re-ran Godot availability check: `godot`, `godot3`, and `godot4` are still unavailable on this Mac, so no GUI/project-load smoke was claimed.

## Evidence - 2026-04-25 C-AOL backend option contract preview

- Tightened `scripts/BackendConfigManager.gd` so saving API/Ollama backend setup now also writes a preview-only `caol_llm_options_patch.json` next to `caol_backend_setup.json`.
- The preview patch uses real C-AOL option names discovered in the local C-AOL source: `LLM_INTENT_BACKEND`, `LLM_INTENT_OLLAMA_URL`, `LLM_INTENT_OLLAMA_MODEL`, `LLM_INTENT_API_KEY_ENV`, and `LLM_INTENT_API_MODEL`.
- The patch is explicitly `preview_only_not_applied`; it does not mutate an installed game's `config/options.json` yet and does not flip `LLM_INTENT_ENABLE` without a future explicit apply step.
- Added `tools/prove_caol_backend_contract.py` and ran it against `/Users/josefhorvath/Schanigarten/Cataclysm-AOL`; it proved the option names exist in `src/options.cpp`, Lacapult references them, no forbidden secret-bearing field tokens are present, and the patch remains preview-only.
- Re-ran `python3 tools/prove_caol_release.py --all-platforms`; Linux, macOS, and Windows still produced installable v0.2.0 metadata without archive downloads.
- Re-ran cheap Ollama detection: `command -v ollama` returned `/opt/homebrew/bin/ollama`; `ollama list` printed the local model table. No model pull, install, remote API call, or API secret was used.
- Re-ran Godot availability check: `godot`, `godot3`, and `godot4` are still unavailable on this Mac, so no GUI/project-load smoke was claimed.
- `git diff --check` passed.

## Evidence - 2026-04-25 public-facing Dabdoob string cleanup

- Replaced remaining non-credit, player-facing Dabdoob references in English tips/settings/help text, startup DOTD copy, macOS permission helper output, and dormant self-update status/updater-script text with Lacapult Doobdab wording.
- Preserved Dabdoob/Catapult/Hihahahalol references where they are attribution, lineage, docs, or internal inherited filenames/comments.
- Static proof: `grep -R "Dabdoob\\|Catapult_Dabdoob\\|Hihahahalol" -n README.md project.godot scripts text/en doc Plan.md TODO.md SUCCESS.md TESTING.md TechnicalTome.md ATTRIBUTION.md | head -120` now shows remaining hits as lineage/credits/docs, one About formatting helper, or the intentional Lacapult lineage note.
- Re-ran `python3 tools/prove_caol_release.py --all-platforms`; Linux, macOS, and Windows still produced installable v0.2.0 metadata without archive downloads.
- Re-ran `python3 tools/prove_caol_backend_contract.py`; C-AOL option names still match local `src/options.cpp`, no secret-bearing fields are introduced, and the patch remains preview-only.
- Re-ran Godot availability check: `godot`, `godot3`, and `godot4` are still unavailable on this Mac, so no GUI/project-load smoke was claimed.
- `git diff --check` passed.

## Evidence - 2026-04-25 backend triad + mod compatibility re-scope

- Josef clarified that v0 should not collapse backend setup to only API/Ollama: API, Ollama, and OpenVINO should all be visible choices, with v0 honesty about what each path can configure.
- `scripts/BackendConfigManager.gd` now treats OpenVINO as a selectable backend that writes launcher-side placeholder/status metadata and a preview-only C-AOL backend patch, without installing runtimes, pulling models, or pretending full OpenVINO setup exists.
- `scripts/SettingsUI.gd` labels the third option `OpenVINO backend` rather than a dead parked row.
- Added `tools/godot_backend_triad_smoke.gd`; it runs under an isolated `HOME`, creates a fake active C-AOL install record so `Paths.config` resolves, writes API/Ollama/OpenVINO backend metadata, and verifies the final OpenVINO config/preview patch has `LLM_INTENT_BACKEND=openvino` with `preview_only_not_applied`.
- Ran `python3 tools/prove_caol_backend_contract.py`; it asserts API/Ollama/OpenVINO selector/status tokens in addition to the C-AOL `LLM_INTENT_*` option contract and secret-safety guard.
- Ran `HOME=$(mktemp -d /tmp/lacapult-backend-triad-home.XXXXXX) /opt/homebrew/bin/godot --path . --no-window --script tools/godot_backend_triad_smoke.gd`; API, Ollama, and OpenVINO all returned `ok`, with OpenVINO status `openvino_selectable_setup_not_automated`.
- `doc/caol-mod-compatibility-summary.md` now records the inherited mod/source inventory: stock mods come from the active C-AOL install tree, user mods keep the inherited userdata shape, custom downloadable catalogs exist for TLG/BN/DDA but not C-AOL, and each class must be marked as supported, untested, broken, or unknown instead of waved through.
- Added and ran `tools/prove_caol_mod_inventory.py`; it mounted the selected cached `caol_cdda-0-h_2026-03-29-1556_macos.dmg` read-only, inspected `Cataclysm.app/Contents/Resources/data/mods`, and detached cleanly.
- The mod inventory proof found 42 non-obsolete stock C-AOL mod IDs and 7 obsolete IDs in the packaged app bundle; sample supported stock IDs include `dda`, `magiclysm`, `mindovermatter`, `no_hope`, `aftershock`, `DinoMod`, and `MMA`.
- The same proof confirmed packaged sound/gfx paths exist and that Lacapult's source paths preserve app-bundle stock mods, per-game userdata user mods, and fallback `mod_repo` parsing for `caol`.
- Classification now recorded in `doc/caol-mod-compatibility-summary.md`: stock packaged C-AOL mods are supported by path shape/presence; user-installed mods are mechanically supported but content-unknown; inherited DDA/BN/TLG custom download catalogs are untested for C-AOL; future NPC/LLM mod summaries remain metadata direction only.

## Evidence - 2026-04-25 release-prep export packaging proof

- Added `tools/prove_lacapult_export_packaging.py`, a local-only release-prep proof that writes a temporary safe `export_presets.cfg`, exports platform PCK packs into ignored `.proof-cache/lacapult-export/`, records a manifest, and restores any prior/absent preset file afterward.
- Ran `python3 tools/prove_lacapult_export_packaging.py`; Godot was `/opt/homebrew/bin/godot` reporting `3.6.2.stable.official.3cd3caab6`.
- Export-pack proof succeeded for all three platform presets: `Lacapult-Doobdab-macos.pck`, `Lacapult-Doobdab-linux.pck`, and `Lacapult-Doobdab-windows.pck`, each 25,530,272 bytes with SHA-256 `91c021eabb1e8fda577962fd3a27f5fb84cd2cf68896382ffbea90d575b2e752`. The identical pack hash is expected because these are resource packs, not platform executables.
- Full app exports were honestly skipped: no Godot 3.6.2 template roots existed under the checked user template locations, so macOS lacked `osx.zip`, Linux lacked `linux_x11_64_release`, and Windows lacked `windows_64_release.exe`. No signing, notarization, publication, model pull, OpenVINO runtime install, or API-secret action was attempted.
- Re-ran the required proof suite for this handoff: `python3 tools/prove_caol_release.py --all-platforms`, `python3 tools/prove_caol_backend_contract.py`, `HOME=$(mktemp -d /tmp/lacapult-backend-triad-home.XXXXXX) /opt/homebrew/bin/godot --path . --no-window --script tools/godot_backend_triad_smoke.gd`, `python3 tools/prove_caol_mod_inventory.py`, `python3 tools/prove_caol_macos_dmg.py --install-sandbox`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`; all exited 0. Logs are under `.proof-cache/release-prep-20260425T1415/`.

## Next greenlit proof - C-AOL game-launch smoke

Schani greenlit the next bounded non-release-decision proof after the export-pack checkpoint: launch C-AOL from an isolated installed app bundle, preferably reusing the proven clicked/headless install footing or a fresh isolated install. The proof should show the app starts without mutating Josef's real Lacapult/C-AOL state, and should record logs/evidence plus any debug/crash result honestly. This does not authorize Godot export-template installation, signing/notarization, public release publication, API secrets, model pulls, full OpenVINO runtime setup, or curated C-AOL mod downloads.

## Evidence - 2026-04-25 isolated C-AOL game-launch smoke blocker

- Added `tools/prove_caol_game_launch_smoke.py`, a repeatable macOS-only proof that fetches live C-AOL release metadata, reuses/downloads the selected `v0.2.0` macOS DMG, mounts it read-only, copies it into a temporary Lacapult-style install root, and briefly starts the installed `Cataclysm.app/Contents/MacOS/Cataclysm.sh` under an isolated `HOME`. The sandbox is removed after the proof unless explicitly kept.
- Ran `python3 tools/prove_caol_game_launch_smoke.py --observe-seconds 8`; install shape still succeeded (`Cataclysm.app` plus `catapult_install_info.json`, `looks_launchable_after_move=true`), but launch failed before a running game process was observed. The app exited with return code 134 / abort trap.
- Failure evidence: dyld reported `Library not loaded: /opt/local/lib/libfreetype.6.dylib`, referenced by `Cataclysm.app/Contents/Resources/cataclysm-tiles`; the tried paths did not exist on this Mac. `otool -L` also shows absolute dependencies on `/opt/local/lib/libfreetype.6.dylib` and `/opt/local/lib/libz.1.dylib` for both x86_64 and arm64 slices, and the selected app bundle does not include matching dylibs under `Contents`.
- Re-ran `python3 tools/prove_caol_release.py --all-platforms`, `python3 tools/prove_caol_backend_contract.py`, `python3 -m py_compile tools/prove_caol_macos_dmg.py tools/prove_caol_game_launch_smoke.py`, `/opt/homebrew/bin/godot --version`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`. Cheap Lacapult proofs still pass; Godot remains `3.6.2.stable.official.3cd3caab6`.
- This does not invalidate Lacapult's release selection or install-shape proof. It means the selected upstream C-AOL `v0.2.0` macOS asset is not launchable on this clean Mac without those MacPorts dylibs being present or the app bundle being repackaged with portable/bundled dependencies. No real user Application Support state, API secrets, model downloads, public releases, or upstream contact were used.

## Evidence - 2026-04-26 Lacapult-side macOS launch repair

- Commit `7ba1043` (`Repair C-AOL macOS app dylib paths`) changes Lacapult, not C-AOL. It adds a repair path for installed C-AOL macOS app bundles that hit the known `v0.2.0` absolute `/opt/local` dylib dependency failure.
- Lacapult now vendors universal `x86_64` + `arm64` repair dylibs under `resources/caol_macos_repair/`: `libfreetype.6.dylib` and `libpng16.16.dylib`, with license files and README. It rewrites the installed app's launch binary from `/opt/local/lib/libfreetype.6.dylib` to `@executable_path/libfreetype.6.dylib`, rewrites `/opt/local/lib/libz.1.dylib` to system `/usr/lib/libz.1.dylib`, rewrites freetype's libpng dependency to `@executable_path/libpng16.16.dylib`, and ad-hoc signs the changed dylibs/binary/app.
- Reproduced the old blocker with `python3 tools/prove_caol_game_launch_smoke.py --preflight-only --expect-blocker --keep-sandbox > .proof-cache/mac-launch-fix/before-preflight.json`.
- Proved repair plus launch with `python3 tools/prove_caol_game_launch_smoke.py --repair --keep-sandbox --observe-seconds 8 > .proof-cache/mac-launch-fix/after-repair-launch.json`; after repair, preflight was `ok`, the checked load graph had no package-manager paths, bundled repair dylibs were universal, and the launched process was still running after 8 seconds before the smoke test terminated it.
- Ran the C-AOL portability verifier against the repaired app with `bash build-data/osx/bundle_portable_dependencies.sh --verify-only "$APP" "$BIN"`; log `.proof-cache/mac-launch-fix/c-aol-verify-repaired-app.log` reports `macOS app bundle dependency preflight passed` for the isolated Lacapult install.
- Revalidation passed: `python3 -m py_compile tools/prove_caol_macos_dmg.py tools/prove_caol_game_launch_smoke.py`, `/opt/homebrew/bin/godot --path . --quit`, and `git diff --check`. Otool evidence is recorded under `.proof-cache/mac-launch-fix/after-cataclysm-tiles-otool.txt`, `.proof-cache/mac-launch-fix/after-libfreetype.6.dylib-otool.txt`, and `.proof-cache/mac-launch-fix/after-libpng16.16.dylib-otool.txt`.
- This is portable-by-construction for the Lacapult-repaired install path and does not require MacPorts/Homebrew on the target Mac. It still does not claim a notarized/new C-AOL DMG release, GitHub release publication, upstream contact, API secrets, model pulls, or mutation of Josef's real Application Support install state.

## Evidence - 2026-04-25 read-only C-AOL mod bridge UI status

- `scripts/SettingsUI.gd` now adds a read-only `C-AOL packaged mod compatibility` Settings block near the backend controls. It exposes the generated report status without mod enabling or generated summary-pack application.
- The visible status distinguishes the current bridge counts: 49 packaged mods total; 42 non-obsolete stock packaged mods path-supported; 7 obsolete blockers; 30 `summarizer-compatible-but-needs-generated-pack`; 12 `no-summary-needed`; 0 `summarizer-ready`.
- The same block uses C-AOL-native summary-root language: future generated packs belong under active mod roots at `npcs/Backgrounds/Summaries_short` or `npcs/Backgrounds/Summaries_extra`, not a Lacapult-only metadata system.
- The visible report reference points to `.proof-cache/caol-mod-bridge/caol_mod_summarizer_bridge_report.md`, says to regenerate it with `python3 tools/prove_caol_mod_inventory.py`, and points at `doc/caol-mod-compatibility-summary.md` for the committed canon summary.
- Revalidation for this handoff passed: `python3 tools/prove_caol_mod_inventory.py`, `python3 -m py_compile tools/prove_caol_mod_inventory.py`, static grep for the UI/status tokens in `scripts/SettingsUI.gd`, `/opt/homebrew/bin/godot --path . --no-window --quit`, `git diff --check`, plus a JSON assertion that the regenerated proof still reports 42 stock, 7 obsolete, 30 generated-pack-needed, 12 no-summary-needed, and a markdown report path. Logs are under `.proof-cache/ui-status-20260425T1513/`.

## Evidence - 2026-04-25 read-only C-AOL launch preflight status

- `scripts/Catapult.gd` now creates a read-only Game-tab `LaunchPreflightStatus` label for active C-AOL installs on macOS. It reuses the app-bundle executable discovery path, runs `otool -L` against the selected launch binary, classifies absolute local dylibs under `/opt/local`, `/usr/local`, or `/opt/homebrew`, and blocks Play/Resume only when required local dylibs are missing.
- The player-facing copy distinguished the important layers at the time: Lacapult install/copy succeeded, the C-AOL app bundle existed, but the actual launch binary was blocked by non-portable local dylib dependencies. This read-only status was superseded by the 2026-04-26 Lacapult-side repair path for the known `v0.2.0` freetype/libpng/zlib shape.
- Extended `tools/prove_caol_game_launch_smoke.py` with `--preflight-only --expect-blocker`, which performs the selected C-AOL `v0.2.0` DMG install-shape proof, inspects the launch binary with `otool -L`, and does not launch the game.
- Ran `python3 tools/prove_caol_game_launch_smoke.py --preflight-only --expect-blocker`; it installed into a temporary Lacapult-style sandbox with `Cataclysm.app` plus `catapult_install_info.json`, `looks_launchable_after_move=true`, and reported `blocked_missing_nonportable_dylibs` for `Cataclysm.app/Contents/Resources/cataclysm-tiles` with missing `/opt/local/lib/libfreetype.6.dylib` and `/opt/local/lib/libz.1.dylib`. Log: `.proof-cache/preflight-status-20260425T1525/preflight.json`.
- Revalidation for this handoff passed: `python3 -m py_compile tools/prove_caol_game_launch_smoke.py`, static grep for `LaunchPreflightStatus`, `blocked_missing_nonportable_dylibs`, `otool`, and the C-AOL package-portability copy, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`. Godot printed the known macOS/no-window cleanup warnings but exited 0.
- This was launcher-side UX/status only at the time. It did not patch/rebuild the C-AOL package, install missing dylibs, sign/notarize, publish releases, contact upstream, use API secrets, pull models, or mutate Josef's real Application Support install state; the later 2026-04-26 Lacapult repair changes only the installed app copy in an isolated/proven Lacapult path.

## Product packaging bar - Lacapult itself

Lacapult is the installer/launcher, so release-prep evidence must distinguish Lacapult's own app distribution from the C-AOL game bundle it installs. A raw Godot project launch or PCK export is not enough for the final product bar: Windows, macOS, and Linux should each get an easy user-facing install/open path. The current local proof now covers unsigned app/package artifacts, while signing/notarization, public release publication, and normal-player install QA remain separate release decisions.

## Evidence - 2026-04-25 README installability/status alignment

- Updated `README.md` so the public-facing development target matches current canon: the backend setup selector is API/Ollama/OpenVINO, with OpenVINO selectable as honest v0 placeholder/status metadata rather than full runtime automation.
- Clarified that no packaged Lacapult release exists yet, raw Godot project launch and generated `.pck` files are not user-facing installers, and the remaining product bar is easy Windows/macOS/Linux app packages.
- Re-ran `python3 tools/prove_lacapult_export_packaging.py`; at that earlier point before local template installation, Godot 3.6.2 exported all three platform PCK packs, each 25,538,144 bytes with SHA-256 `e25b1b802ab8c41cc499466540e772a5f6dff437f0a983cd0e96c1fbf54a0ad6`, while full app exports were honestly skipped because the checked template roots did not contain `osx.zip`, `linux_x11_64_release`, or `windows_64_release.exe`.
- Re-ran `python3 tools/prove_caol_release.py --all-platforms`, `python3 tools/prove_caol_backend_contract.py`, `/opt/homebrew/bin/godot --path . --no-window --quit`, and `git diff --check`; all passed. Godot printed the known macOS/no-window cleanup warnings but exited 0.
- Static README proof: `rg -n 'API/Ollama/OpenVINO|OpenVINO backend|generated \`.pck\`|osx.zip|linux_x11_64_release|windows_64_release.exe|separate decisions' README.md` shows the corrected public status text.


## Evidence - 2026-04-25 local unsigned app/package export proof

- Extended `tools/prove_lacapult_export_packaging.py` beyond PCK-only proof. It still writes temporary safe Godot 3 export presets and restores any prior/absent `export_presets.cfg`, but now also attempts real app/executable exports when templates are present, records app/package shape checks, and creates unsigned archive/package outputs under ignored `.proof-cache/lacapult-export/`.
- Ran `python3 tools/prove_lacapult_export_packaging.py`; Godot was `/opt/homebrew/bin/godot` reporting `3.6.2.stable.official.3cd3caab6`. Template probe found `osx.zip`, `linux_x11_64_release`, and `windows_64_release.exe` under `~/Library/Application Support/Godot/templates/3.6.2.stable`; no app exports were skipped.
- PCK pack exports still succeeded for macOS/Linux/Windows: each `.pck` was 25,538,144 bytes with SHA-256 `e25b1b802ab8c41cc499466540e772a5f6dff437f0a983cd0e96c1fbf54a0ad6`.
- Real unsigned app/executable exports succeeded:
  - macOS: `.proof-cache/lacapult-export/app/Lacapult Doobdab.app`, 84,030,208 bytes across 17 files, tree SHA-256 `106f491ce7e6d01ad0fc3656d67601a322d71f50dc365e5891aacd623d5997f8`; shape check found `Info.plist`, bundled `Lacapult Doobdab.pck`, executable `Contents/MacOS/Lacapult Doobdab`, bundle id `at.schanigarten.lacapult-doobdab`, and explicitly `signed_or_notarized=false`.
  - Linux: `.proof-cache/lacapult-export/app/Lacapult-Doobdab.x86_64`, 60,186,832 bytes, SHA-256 `c02dc05abd08ba5a62cc40dc9c33174e2051229ac8eab00215b606573b12b06f`; shape check found the executable bit and embedded-PCK export setting.
  - Windows: `.proof-cache/lacapult-export/app/Lacapult-Doobdab.exe`, 59,629,680 bytes, SHA-256 `bd657e3dff3ef0a61eaf39b9b3e010ab8227f67791ae4fbdf943573cf5eb9b69`; shape check found `.exe` suffix and `MZ` header.
- Unsigned package/archive shapes succeeded:
  - macOS zip: `.proof-cache/lacapult-export/packages/Lacapult-Doobdab-macos-unsigned.zip`, 84,033,582 bytes, SHA-256 `da8ece82ff6bb361927251708f89ee42bfc996f47f4196539be4a4763fed24d6`, contains expected `.app` root.
  - Linux tar.gz: `.proof-cache/lacapult-export/packages/Lacapult-Doobdab-linux-unsigned.tar.gz`, 32,912,128 bytes, SHA-256 `e2e60bfac9e678dcc01a26e2403b36730c8392120c1e3159ebc090dc3658dd53`, contains executable member `Lacapult-Doobdab.x86_64`.
  - Windows zip: `.proof-cache/lacapult-export/packages/Lacapult-Doobdab-windows-unsigned.zip`, 59,629,818 bytes, SHA-256 `bf152f127cda7aec3c297942750f0193223b721c4376d7f9952ea53246ac8d86`, contains expected `.exe` root.
- Manifest/logs: `.proof-cache/lacapult-export/manifest.json` and `.proof-cache/lacapult-export/logs/`. `export_presets.cfg` was absent before the proof and absent afterward; binary artifacts remain ignored and uncommitted. This proves local unsigned app/package exportability only. It does not claim signing, notarization, public release publication, platform security-prompt behavior, upstream contact, OpenVINO runtime setup, model pulls, API secrets, or C-AOL game package launchability.

## Evidence - 2026-04-25 backend-good v0-safe hardening

- Audited local C-AOL backend truth from `/Users/josefhorvath/Schanigarten/Cataclysm-AOL`: C-AOL exposes `LLM_INTENT_BACKEND` values `openvino`, `api`, and `ollama`; runs `tools/llm_runner/runner.py`; uses `any_llm` for API; uses local Ollama HTTP for Ollama; imports `openvino`/`openvino_genai` for OpenVINO; and resolves `LLM_INTENT_PYTHON` as the Python runner path for all backends, not only OpenVINO.
- Tightened `scripts/BackendConfigManager.gd` and `scripts/SettingsUI.gd` from selector/preview metadata into a v0-safe setup assistant: API stores provider/model/env-var names only and checks Python/`any_llm` importability without secrets; Ollama checks command/server/model-list state without pulling models; OpenVINO is labeled Windows-first for v0 and checks Python imports plus model-dir/device metadata without installs/downloads; the UI now exposes the shared Python/venv path honestly.
- Extended `tools/prove_caol_backend_contract.py` to validate C-AOL option/source truth, Lacapult readiness/config tokens, and sandboxed `config/options.json` apply output for API, Ollama, and OpenVINO under `.proof-cache/caol-backend-contract/`. It verified the expected `LLM_INTENT_*` values for `options_api.json`, `options_ollama.json`, and `options_openvino.json` without touching real Application Support config.
- Ran `python3 -m py_compile tools/prove_caol_backend_contract.py`; it passed.
- Ran `python3 tools/prove_caol_backend_contract.py > .proof-cache/caol-backend-contract/latest.log`; it passed. Local readiness result: default Python is missing `any_llm`; default Python is missing `openvino`/`openvino_genai`; Ollama command exists at `/opt/homebrew/bin/ollama` and `ollama list` reports the server running. No API call, secret readout, model pull, OpenVINO install, or real config mutation occurred.
- Ran `CAOL_OPTIONS_JSON=/Users/josefhorvath/Schanigarten/Cataclysm-AOL/config/options.json HOME=$(mktemp -d /tmp/lacapult-backend-home.XXXXXX) /opt/homebrew/bin/godot --path . --no-window --script tools/godot_backend_triad_smoke.gd`; it passed. The smoke wrote API/Ollama/OpenVINO launcher-side metadata and applied each generated patch to sandbox C-AOL `options_*.json` copies under the isolated HOME.
- Ran `/opt/homebrew/bin/godot --path . --no-window --quit`; it exited 0 with the known macOS/headless cleanup warnings.
- This evidence makes backend setup/config/status/apply-proof good for v0. It still does not claim live API calls with secrets, model pulls/downloads, OpenVINO runtime setup, arbitrary AnyLLM provider consumption by C-AOL runtime, or mutation of Josef's real installed-game config. Backend hardening remains the active implementation lane; feature-complete mod install/enable plus Summarizer apply UX is documented as the next planned lane, not implemented by this proof.

## Evidence - 2026-04-25 C-AOL mod/Summarizer status model Slice 1

- Added `scripts/CaolModStatusModel.gd` as a read-only Godot autoload and `ModManager.get_caol_mod_summarizer_status()`, so later Mods/Settings UX can render one deliberate status shape without mutating installed game data. The model scans stock packaged, user-installed, custom-catalog, and world-custom mod roots, reads a selected world's `mods.json`, records enabled/disabled state, dependency status, obsolete/metadata status, C-AOL-native summary-root status, generated-pack manifests, and source fingerprints.
- Added `tools/caol_mod_status_model.py` plus `tools/prove_caol_mod_status_model.py` as the sandbox Slice 1 proof. The proof builds a C-AOL-like fixture under ignored `.proof-cache/caol-mod-status-fixture` and emits `.proof-cache/caol-mod-status/status.json`; `--clean-fixture-after` can remove the fixture after inspection. It does not touch Josef's real Application Support config, saves, worlds, or mods.
- Ran `python3 -m py_compile tools/caol_mod_status_model.py tools/prove_caol_mod_status_model.py`; it passed.
- Ran `python3 tools/prove_caol_mod_status_model.py > .proof-cache/caol-mod-status/latest.log`; it passed and emitted 10 fixture records: 6 stock packaged, 2 user-installed, 1 custom-catalog, and 1 world-custom. The sandbox world enabled `fixture_context_stock`, `fixture_no_summary_needed`, `fixture_world_custom`, and `lacapult_summary_fixture_context_stock`.
- The fixture assertions covered `stock-packaged`, `user-installed`, `catalog-untested`, `world-specific-custom`, `enabled-in-world`, `disabled`, `obsolete-blocked`, `metadata-broken`, `dependency-blocked`, `summary-ready`, `summary-missing`, `summary-partial`, `summary-not-needed`, `summary-unknown`, and `generated-summary-pack-present`. Counts included 4 enabled, 5 disabled, 1 obsolete blocker, 1 metadata-broken mod, 1 dependency blocker, 2 summary-ready, 4 summary-missing, 1 summary-partial, and 1 generated summary pack.
- Ran `LACAPULT_CAOL_MOD_STATUS_FIXTURE="$PWD/.proof-cache/caol-mod-status-fixture" LACAPULT_CAOL_MOD_STATUS_GODOT_OUTPUT="$PWD/.proof-cache/caol-mod-status/godot-status.json" /opt/homebrew/bin/godot --path . --no-window --script tools/godot_caol_mod_status_smoke.gd`; it exited 0 and proved the Godot autoload/status model sees the same 10 fixture mods, including 4 enabled mods, 2 summary-ready mods, 4 summary-missing mods, and 1 dependency blocker. The two JSON parse errors printed during this smoke are expected fixture coverage for the deliberately broken `modinfo.json`.
- Ran `/opt/homebrew/bin/godot --path . --no-window --quit`; it exited 0, giving a project-load/autoload parse smoke. Godot printed the known macOS/no-window cleanup warnings at exit.
- Re-ran the cheap no-regression packet for this handoff: `python3 tools/prove_caol_release.py --all-platforms`, `python3 tools/prove_caol_backend_contract.py`, `python3 tools/prove_caol_mod_inventory.py`, `python3 tools/prove_caol_mod_status_model.py`, the Godot status smoke, `/opt/homebrew/bin/godot --path . --no-window --quit`, `python3 -m py_compile tools/caol_mod_status_model.py tools/prove_caol_mod_status_model.py`, and `git diff --check`; all passed. This is discovery/status only: no Summarizer UI prompt, generated-pack apply/rollback, C-AOL runtime consumption proof, backend generation call, real user-data mutation, public release, API secret, model pull, or OpenVINO install is claimed.

## Evidence - 2026-04-25 C-AOL mod/Summarizer UX status Slice 2

- Added `CaolModStatus.build_ux_overview()` and `build_dry_run_summarizer_prompt()` as a read-only UX view model for the Slice 1 status dictionary. The dry-run action explicitly reports `would_mutate=false`, `would_call_backend=false`, `would_generate_pack=false`, and `would_enable_mods=false`.
- Added `ModManager.get_caol_mod_summarizer_overview()` / `get_caol_summarizer_dry_run()` and surfaced them in `scripts/ModsUI.gd` and `scripts/SettingsUI.gd`: installed mod rows get C-AOL summary badges, selected-mod info gets enabled/dependency/summary state, Settings shows live overview text, and both surfaces expose a status-only Summarizer dry-run button/prompt. The post-install prompt is wired; a true post-enable hook remains pending until a C-AOL world enable/apply flow exists.
- Added `tools/godot_caol_mod_ux_status_smoke.gd`; it runs against the same sandbox fixture and proves the UX view reports `needs-summaries`, at least one candidate, renderable status text, the dry-run action id, and no unsafe side effects.
- Re-ran the cheap no-regression packet for this handoff: `python3 tools/prove_caol_release.py --all-platforms`, `python3 tools/prove_caol_backend_contract.py`, `python3 tools/prove_caol_mod_inventory.py`, `python3 tools/prove_caol_mod_status_model.py`, the Godot status smoke, the Godot UX status smoke, `/opt/homebrew/bin/godot --path . --no-window --quit`, `python3 -m py_compile tools/caol_mod_status_model.py tools/prove_caol_mod_status_model.py`, and `git diff --check`; all passed. This is UX/status/dry-run only: no backend generation call, generated-pack apply/rollback, mod enable, real user-data mutation, C-AOL runtime consumption proof, public release, API secret, model pull, or OpenVINO install is claimed.


## Evidence - 2026-04-25 click-level GUI audit

- Launched the Lacapult Godot GUI under isolated temporary `HOME` and captured visual evidence under `~/.openclaw/workspace/runtime/lacapult-click-audit-2026-04-25/`; Peekaboo full-screen screenshots showed the launcher window and C-AOL first-run surface, while Godot window enumeration was flaky/tiny-bounds and is recorded as visual-evidence caveat.
- Source-level click map inspected `scenes/Catapult.tscn`, `scripts/Catapult.gd`, `scripts/SettingsUI.gd`, `scripts/ModsUI.gd`, `scripts/BackendConfigManager.gd`, and related tab scripts.
- Added `doc/lacapult-click-level-gui-audit-2026-04-25.md`; binary verdict is `ready-for-Josef-Windows-test`, not public release.
- Small UI fixes from the audit: C-AOL release/changelog link opens the selected/fallback GitHub release page; Godot debug/test dimensions are 600x700 instead of 1x1.
- Re-ran `/opt/homebrew/bin/godot --path . --no-window --quit`, `/opt/homebrew/bin/godot --path . --no-window --script tools/godot_backend_triad_smoke.gd`, the C-AOL mod status and UX Godot smokes, `python3 -m py_compile tools/caol_mod_status_model.py tools/prove_caol_mod_status_model.py tools/prove_caol_summary_error_matrix.py`, and `git diff --check`; all passed. Combined log: `.proof-cache/click-gui-audit/gates-rerun.log`.

## Evidence - 2026-04-25 backend recommendation / Windows-test readiness closure

- `scripts/BackendConfigManager.gd` now returns backend recommendation metadata in stable order: API rank 1 for fastest Windows pre-release onboarding/debug, Ollama rank 2 for mainstream local, and OpenVINO rank 3 for Windows-first specialized/detect-only.
- `scripts/SettingsUI.gd` now renders that recommendation summary above the backend selector, labels the dropdown choices by role (`Recommended: API backend`, `Local: Ollama backend`, `Windows-first: OpenVINO backend`), and includes per-backend recommendation plus v0 warning text in the status block.
- Extended `tools/godot_backend_triad_smoke.gd` so the headless Godot smoke verifies backend order/rank/warning metadata, the Settings UI recommendation labels, sandboxed options apply for API/Ollama/OpenVINO, and the existing Summarizer dry-run/status-only boundary. No API call, API secret readout, model pull, OpenVINO install, generated summary-pack apply, or real C-AOL config mutation is attempted.
- Re-ran the closure gate packet into `.proof-cache/remove-maybe/gates.log`: `python3 -m py_compile` for relevant proof helpers, `python3 tools/prove_caol_backend_contract.py`, `python3 tools/prove_caol_mod_status_model.py`, the backend recommendation Godot smoke, C-AOL mod status and UX Godot smokes, `/opt/homebrew/bin/godot --path . --no-window --quit`, `python3 tools/prove_lacapult_export_packaging.py`, and `git diff --check`; all exited 0. Godot still prints the known fixture parse-error and macOS/headless cleanup warnings.
- Local unsigned export/package proof still produces a Windows test packet candidate without publishing: `.proof-cache/lacapult-export/app/Lacapult-Doobdab.exe` (59,697,824 bytes, SHA-256 `765fd75dad39bd573e4f32691d88ff88153fa80e09843b23a0633b85161a29fd`) and `.proof-cache/lacapult-export/packages/Lacapult-Doobdab-windows-unsigned.zip` (59,697,962 bytes, SHA-256 `8cc5432784b76b7d2ca71231227dc4e249933012d97b2b6b86e243728455452e`). Manifest: `.proof-cache/lacapult-export/manifest.json`.
- Binary verdict for launcher handoff is now `ready-for-Josef-Windows-test`. This still does not claim public release readiness, signing/notarization, GitHub release publication, Windows SmartScreen/security-prompt behavior, live API/backend inference, model downloads, OpenVINO runtime setup, or that the upstream C-AOL macOS package launch blocker is fixed.


## Evidence - 2026-04-26 Lacapult Windows 7-Zip hotfix prerelease

Josef's real Windows laptop test of `lacapult-test-2026-04-26` found a hard install/extract blocker: C-AOL release download completed, then Lacapult failed with `7za.exe not found at .../Lacapult-Doobdab-windows-unsigned/utils/7za.exe`. The same test also found that the C-AOL install list exposed five install rows when the product expectation is four port releases, and that the startup lineage note was too shrine-like.

Fixes landed in this hotfix:

- `tools/prove_lacapult_export_packaging.py` now exports resources with `utils/*`, `fonts/*`, and `resources/caol_macos_repair/*` included explicitly.
- Windows packages now include sidecar `utils/7za.exe` and `utils/7-ZIP_LICENSE`; Linux packages include sidecar `utils/7za` and license.
- Package proof now fails unless Windows/Linux package shapes contain the 7-Zip sidecar.
- `scripts/ReleaseManager.gd` now curates C-AOL visible release rows to four expected port tag prefixes: `caol-cdda-master`, `caol-ctlg-master`, `caol-cdda-0-h`, and `caol-cdda-0-i`; plain `v0.2.0` no longer appears as a fifth install row in this Lacapult lane.
- `scripts/dotd.gd` now says a plain thank-you to Dabdoob/Catapult developers instead of the previous lineage plaque.

Local proof:

- `python3 -m py_compile tools/prove_lacapult_export_packaging.py tools/prove_caol_release.py`
- `git diff --check`
- `python3 tools/prove_caol_release.py --all-platforms` proved exactly four curated C-AOL release rows, installable on Linux/macOS/Windows.
- `python3 tools/prove_lacapult_export_packaging.py` regenerated unsigned macOS/Linux/Windows packages and `SHA256SUMS.txt`.
- `/opt/homebrew/bin/godot --path . --no-window --quit` completed with existing harmless/headless warnings.
- Windows package zip contents verified: `Lacapult-Doobdab.exe`, `utils/7-ZIP_LICENSE`, `utils/7za.exe`.

Published hotfix prerelease: `lacapult-test-2026-04-26-2` / https://github.com/josihosi/Lacapult-Doobdab/releases/tag/lacapult-test-2026-04-26-2

Assets:

- `Lacapult-Doobdab-windows-unsigned.zip` — 66,426,171 bytes — SHA-256 `22617e7b195cc0e26f82354b6634f41feffb54d50bc749eb895aed83085eda21`
- `Lacapult-Doobdab-macos-unsigned.zip` — 90,238,414 bytes — SHA-256 `53b3aade2655c7a4b2290060664a62ff79a2b8f37be35ed2eb4cd01132f9881b`
- `Lacapult-Doobdab-linux-unsigned.tar.gz` — 37,458,834 bytes — SHA-256 `d2b76a829218a976dd5f320f7fb94f29089db1c8fdaf5882c0ee13c6e7ee26f7`
- `SHA256SUMS.txt` — 311 bytes — SHA-256 `853d8273a3ecc67896721d98deba6cf99f9ec8f1975aeb15ba7c028b1e227b77`

Remaining caveat: Josef's note about the Windows custom title bar looking low-resolution/awkwardly large is recorded as UI polish/follow-up; this hotfix release prioritizes the hard missing-7za install blocker plus the misleading release list and lineage note.


## Closed evidence - Lacapult LLM backend setup installer packet v0

Contract: `doc/lacapult-llm-backend-setup-installer-packet-v0-2026-04-26.md`.

Schani review accepted the closure after rerunning the smallest static contract gates on 2026-04-26:

- `python3 tools/prove_backend_setup_installer_packet.py`
- `python3 tools/prove_caol_backend_contract.py`
- `git diff --check`

The proof confirms the standalone `C-AOL LLM backend setup` tab, neutral player-facing setup copy, confirmation-gated intent-only setup pathways, Ollama `mistral-v0.3` / `nemotron-9b` recommendation fixtures, preserved inherited support/thank-you copy, and no real API call, secret readout, model pull, OpenVINO install, or user config mutation. Josef's real Windows laptop click-through remains the external launcher-test step; no C-AOL `v0.3.0`, signing/notarization, or public release decision is implied.
