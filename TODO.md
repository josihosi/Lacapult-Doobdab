# TODO

Short queue only. Remove finished items instead of turning this into a museum.

## Now

**Active target:** Catapult-Dabubu Windows retest follow-up v2.

Canonical contract: `doc/catapult-dabubu-windows-retest-followup-v2-2026-05-06.md`.
Imagination source: `doc/catapult-dabubu-windows-retest-followup-v2-imagination-source-2026-05-06.md`.
Handoff: `doc/alex-catapult-dabubu-windows-retest-followup-v2-2026-05-06.md`.
Raw intake: `doc/josef-catapult-dabubu-debug-intake-2026-05-06.md`.

- [x] Fix API package setup to install Mozilla `any-llm` as `any-llm-sdk[...]` provider extras while preserving `from any_llm import completion`.
- [x] Hide API base URL from normal provider setup; keep it only as advanced/custom endpoint override.
- [x] Improve API package setup failure output so it shows useful non-secret package/pip failure detail and does not imply base/model/key/API-call failure.
- [x] Fix Ollama model tags: `mistral:v0.3` for Mistral and `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest` for Nemotron.
- [x] Keep GUI model selector labels short, especially Nemotron, while mapping internally to the full runtime tag.
- [x] Replace Ollama hardware advisory prose/status row with RAM/VRAM in GiB plus red/yellow/green estimated performance lights for Mistral and Nemotron.
- [x] Ensure measured low hardware is not displayed as `Hardware check: missing`.
- [x] Add runner test buttons for API and Ollama routes that exercise the actual C-AOL runner path under safe/no-surprise-spend proof boundaries.
- [x] Change Ollama install/model wait note to: `The launcher may appear to time out. Wait for Ollama installation to commence.`
- [ ] Start JSON-mod catalog/summarizer footing so Magiclysm and DinoMod are cataloged/summarized when present/available, or precisely reported unavailable.
- [ ] Run focused static/Godot/backend/mod proof without live secrets, unapproved package installs, model pulls, or real user-data mutation.
- [ ] Build/package/upload a fresh Josef-only Windows v2 Draft/prerelease only after local proof.

## Completed debug-note stack

- [x] Quarantine the 2026-04-26 Lacapult prerelease family as Draft and verify public removal.
- [x] Record the release identity/product failure in canon.
- [x] Add the Lacapult debug-note correction stack to canon.
- [x] Clean top-level Lacapult canon so `Plan.md`, `TODO.md`, and `TESTING.md` stop carrying every old evidence fossil.
- [x] Reopen Lacapult implementation for Alex while keeping C-AOL Andi separate.
- [x] Work from `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`, Package 1.
- [x] Rename the visible backend tab/page to `LLM` and reduce top/backend-selected helper text.
- [x] Remove visible Lacapult OpenVINO installer/setup choice while preserving hidden/in-game support deliberately.
- [x] Correct the stale API token-cost copy; no `around 1000 tokens` claim unless fresh evidence proves it.
- [x] Prove the UI/copy change with static scan plus Godot scene load or UI smoke.
- [x] Work from `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`, Package 2.
- [x] Add `Save options` next to relevant backend/setup install actions.
- [x] Add/standardize `Check` actions that refresh readiness without installing.
- [x] Make install actions save current options before attempting setup.
- [x] Replace long setup status text with compact status-light state.
- [x] Work from `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`, Package 3.
- [x] Add provider/base URL/model/API-key env-var controls in the API setup path without storing secrets.
- [x] Add real AnyLLM/Python setup/check workflow behind explicit confirmation only.
- [x] Prove API setup with UI smoke plus sandboxed config/status proof; do not call live APIs or use secrets.
- [x] Work from `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`, Package 4.
- [x] Keep one visible Ollama model-choice control for Mistral/Nemotron and remove the duplicate freeform model field from Ollama mode.
- [x] Add compact Ollama command/server, Mistral, Nemotron, Python/venv, and options readiness lights plus non-mutating `Check`.
- [x] Add confirmation-gated `Install Ollama / model` and `Create venv only` setup intents that save first and remain proof-only in automated gates.
- [x] Prove Ollama setup with UI smoke plus fixture command/server/model states; do not install Ollama, create a venv, or pull models in automated proof.
- [x] Work from `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`, Package 5.
- [x] Name the local root-cause class: custom scene chrome (`borderless=true` + `CustomTitleBar.tscn`), not native OS chrome.
- [x] Patch the smallest custom-titlebar metric seam first: titlebar height, vertical margins, app icon size, close/min/max button size, and matching main content offset.
- [x] Prove the visible seam changed with local Godot smoke comparing old baseline metrics to new scene metrics.
- [x] Keep Windows/Josef screenshot confirmation separate before any cross-platform visual-fix claim.
- [x] Write the Package 5 bounded handoff/checklist for Windows confirmation.

## Josef playtest ledger

- [ ] Real Windows first-launch click-through before any renewed confidence/republish claim: extracted package, first window, first visible tab, release row wording, and install/download impression.
  - [x] Follow up on 2026-05-01 Windows screenshot: top row/titlebar remains visibly wrong; likely needs larger default window and/or downward content/custom-chrome offset, then a new Windows retest build.
  - [x] Josef retested the fresh `Catapult-Dabubu` Windows Draft/prerelease package on 2026-05-02 and found remaining blockers: AnyLLM packages not installed with venv creation, too much background text, and broken Unicode readiness lights.
  - [x] Josef retested the v1 Windows Draft/prerelease package `catapult-dabubu-josef-windows-retest-v1-2026-05-02` and reported the 2026-05-06 v2 debug-note batch.
  - [ ] Josef retests the next v2 Windows Draft/prerelease after the new repair pass.

## Greenlit implementation stack

Canonical contract: `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`.

1. [x] COMPLETE - LLM tab de-clutter + backend-scope correction v0.
2. [x] COMPLETE - Setup save/check action pattern v0.
3. [x] COMPLETE - API / AnyLLM real setup workflow v0.
4. [x] COMPLETE - Ollama real installer + model readiness workflow v0.
5. [x] LOCAL COMPLETE / PARKED FOR WINDOWS CONFIRMATION - Lacapult window chrome investigation v0.

## Do not do without fresh clearance

- [ ] Republish quarantined Lacapult releases as public/non-test releases.
- [ ] Push non-test public releases / contact upstream.
- [ ] Start C-AOL `v0.3.0`, signing, notarization, or public-final release work.
- [ ] Install packages, pull models, call live APIs, handle real API secrets, or mutate real Application Support data in automated proof.
