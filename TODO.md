# TODO

Short queue only. Remove finished items instead of turning this into a museum.

## Now

**Active target:** Catapult-Dabubu Windows retest follow-up v1.

Canonical contract: `doc/catapult-dabubu-windows-retest-followup-v1-2026-05-02.md`.
Handoff: `doc/alex-catapult-dabubu-windows-retest-followup-v1-2026-05-02.md`.
Raw intake: `doc/josef-windows-debug-intake-2026-05-02.md`.

- [ ] Fix API / AnyLLM installer semantics: one obvious path creates/uses the venv and installs required AnyLLM packages/dependencies, with clear venv/package/progress/success/failure states.
- [ ] Reduce visible LLM/API setup background/helper text so controls/status/actions are primary.
- [ ] Replace fragile Unicode/emoji readiness lights with Windows-safe colored dots/labels using explicit red/green/yellow/gray rendering.
- [ ] Run focused UI/static/backend setup gates without live secrets/model pulls/user-data mutation or uncontrolled package installs.
- [ ] Build/package a fresh Windows unsigned `Catapult-Dabubu` test artifact after fixes.
- [ ] Create or update a clearly labelled Josef-only GitHub Draft/prerelease test release with Windows asset, checksums/build notes, and `gh release view` verification.

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
  - [ ] Josef retests the next v1 Windows Draft/prerelease package after the installer-vision/status-dot fixes.

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
