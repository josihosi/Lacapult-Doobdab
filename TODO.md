# TODO

Short queue only. Remove finished items instead of turning this into a museum.

## Now

**Active target:** Lacapult Windows retest fix v0.

Canonical contract: `doc/lacapult-windows-retest-fix-packet-v0-2026-05-01.md`.
Handoff: `doc/alex-lacapult-windows-retest-fix-handoff-2026-05-01.md`.

- [x] Fix shared popup/window layout locally: default/test window enlarged, confirmation dialogs bounded/wrapped, and long setup/help copy split with deliberate newlines.
- [x] Fix API / AnyLLM setup locally: `backend_external_setup_proof_only` default/safe read, long-running install progress, and venv/package semantics.
- [x] Fix Ollama setup locally: model selection persistence/default, readiness lights, split installer/server/model-pull reporting, Windows installer copy/status separation, and Mistral/Nemotron hardware guidance.
- [x] Run focused UI/static/backend setup gates without live secrets/model pulls/user-data mutation.
- [x] Apply `Catapult-Dabubu` identity pass to safe user-facing/package surfaces while retaining upstream attribution and current GitHub repo URL.
- [x] Build/package a fresh Windows unsigned `Catapult-Dabubu` test artifact.
- [x] Create or update a clearly labelled Josef-only GitHub Draft/prerelease test release with `Catapult-Dabubu` Windows asset, checksums/build notes, and `gh release view` verification.

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
  - [ ] Josef retests the fresh `Catapult-Dabubu` Windows Draft/prerelease package and reports whether the top row/popup/layout repairs hold on Windows.

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
