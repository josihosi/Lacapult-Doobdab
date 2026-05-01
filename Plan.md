# Plan

Canonical roadmap for Lacapult Doobdab.

Lacapult is a C-AOL-specific launcher/installer derived from Dabdoob/Catapult under the MIT license. It should feel like the front door for Cataclysm: Arsenic and Old Lace, not a generic Cataclysm launcher wearing a hat.

## File roles

- `Plan.md` - current product state and roadmap truth.
- `TODO.md` - short queue only; no archaeology.
- `SUCCESS.md` - success ledger for active/parked/completed items.
- `TESTING.md` - validation policy, current proof needs, and evidence index.
- `TechnicalTome.md` - durable implementation facts.
- `ATTRIBUTION.md` - lineage/license obligations.
- `doc/*.md` - full contracts, evidence packets, investigations, and longer notes.

If these disagree, `Plan.md` wins; repair the other file instead of inventing a second truth. Detailed evidence belongs in `doc/*.md`, not in the top-level roadmap.

## Current status

**State:** RELEASE QUARANTINE ACTIVE / WINDOWS RETEST FIX ACTIVE

The 2026-04-26 Lacapult prerelease family is quarantined as Draft after Josef reported that the download looked like CAOL rather than clearly like Lacapult. No Lacapult release from that family should be republished until the quarantine/identity investigation is closed and Josef/Schani explicitly re-greenlight.

Current public-release facts:
- Draft/quarantined releases: `lacapult-post-mod-ui-retest-2026-04-26`, `lacapult-test-2026-04-26-2`, `lacapult-test-2026-04-26`.
- Public GitHub releases API returned zero public releases after quarantine.
- The old latest Windows asset URL returned `404`.
- Local artifact inspection says the package is Lacapult-shaped (`Lacapult-Doobdab.exe` plus `utils/7za.exe`), not a full C-AOL archive, but the product surface was too C-AOL-heavy / inherited-name-leaky for public confidence.

Canonical incident note: `doc/lacapult-release-quarantine-investigation-2026-04-26.md`.

## Josef test release slice

**READY FOR JOSEF: Lacapult Josef test release v0** - Josef superseded the parking/deactivate idea on 2026-04-27 and explicitly asked for a Lacapult release he can test. A bounded GitHub Draft/prerelease test release now exists for Josef Windows validation: `https://github.com/josihosi/Lacapult-Doobdab/releases/tag/untagged-62e620a97f3b0edaa8ca`. This does **not** lift quarantine, authorize a stable/latest/final claim, announce broadly, or start C-AOL release work.

Test-release target:
- Build/package the current locally-complete debug-stack state from `main`.
- Attach the Windows unsigned Lacapult launcher package plus checksums/build notes customary for the repo.
- Release copy must say this is for Josef Windows validation and not final/public confidence.
- Josef checklist: first launch/top bar, first visible tab, release row wording, install/download impression.

Canonical packet: `doc/lacapult-josef-test-release-v0-2026-04-27.md`.

## Josef playtest ledger

- [ ] Real Windows first-launch click-through before any renewed confidence/republish claim: extract/open package, inspect first window/tab, release-row wording, and install/download impression.
  - 2026-05-01 Josef Windows screenshot feedback: top row/titlebar area is still visually messed up; suspected fix direction is a slightly larger window and/or moving the custom-chrome/content stack downward. Treat `Lacapult window chrome investigation v0` as **not Windows-confirmed** and requiring a follow-up metrics/layout slice before any visual-fix claim.

Do not schedule repeated reminders for this. It is a ledger item, not an implementation blocker.

## Active Windows retest fix lane

**ACTIVE / GREENLIT: Lacapult Windows retest fix v0** - Josef completed the 2026-05-01 Windows test pass and explicitly asked to package the findings, reactivate the Lacapult worker, and produce another testing release. Canonical contract: `doc/lacapult-windows-retest-fix-packet-v0-2026-05-01.md`; imagination source: `doc/lacapult-windows-retest-fix-imagination-source-2026-05-01.md`; raw intake: `doc/josef-windows-debug-intake-2026-05-01.md`; executor handoff: `doc/alex-lacapult-windows-retest-fix-handoff-2026-05-01.md`.

Scope order:
1. shared popup/window layout repair: top row/window metrics, clipped dialogs/tooltips, wrapping/newlines, and popup width bounds;
2. API / AnyLLM setup repair: missing `backend_external_setup_proof_only` default/safe read, long-running install progress, and coherent venv/package semantics;
3. Ollama setup repair: model-choice persistence, readiness lights, installer/server/model-pull reporting, Windows installer verification, and Mistral/Nemotron hardware suitability guidance;
4. fresh clearly labelled Josef-only Windows test release with package/checksums/build notes verified by `gh release view`.

This active lane does **not** lift the release quarantine, authorize a public/final release, start C-AOL release work, or permit automated live API calls/secrets/model pulls/package installs outside explicit confirmation and proof boundaries.

## Active debug-note correction stack

Canonical contract: `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`.

Josef reopened the collected Lacapult debug notes on 2026-04-27 and asked for a separate Lacapult execution worker, Alex, so C-AOL Andi can continue independently. Alex should work the stack in this order unless Josef/Schani reprioritizes:

1. **COMPLETE: LLM tab de-clutter + backend-scope correction v0** - visible backend tab is `LLM`, top/helper text is shortened, visible OpenVINO setup choice is removed while hidden config support remains, and API token copy uses the checked `300-400`-with-variation wording.
2. **COMPLETE: Setup save/check action pattern v0** - backend setup now has `Save options`, `Check`, compact status-light text, and `Install setup` saves the current fields before the confirmation-gated setup step.
3. **COMPLETE: API / AnyLLM real setup workflow v0** - provider-aware API setup with base URL/provider/model, safe API-key/env-var workflow, and real AnyLLM setup path behind explicit confirmation/proof gates.
4. **COMPLETE: Ollama real installer + model readiness workflow v0** - one visible model-choice control, Mistral/Nemotron readiness lights, Check/Save/Install behavior, and confirmation-gated Python venv/Ollama setup intents are implemented/proofed without automated pulls/installs.
5. **LOCAL COMPLETE / PARKED FOR WINDOWS CONFIRMATION: Lacapult window chrome investigation v0** - local root cause is custom scene chrome; the smallest CustomTitleBar metric seam is patched/proofed locally, and the bounded handoff/checklist lives in `doc/lacapult-window-chrome-investigation-packet-2026-04-27.md`. Windows/Josef visual confirmation remains separate before any cross-platform fix claim.

This reopens implementation only for the debug-note stack. It does **not** lift the release quarantine or authorize republishing.

## Completed footing

These are implemented/proofed enough to serve as footing, not active work:

- C-AOL `v0.2.0` release metadata/install path and macOS DMG install-shape proof.
- Backend triad status/config proof for API, Ollama, and OpenVINO at v0-safe readiness level.
- Read-only C-AOL mod compatibility/Summarizer status model.
- Real C-AOL mod/Summarizer generation/apply UI v0, sandbox proof, fixture backend proof, and already-local Ollama smoke.
- Local unsigned macOS/Linux/Windows Lacapult package-shape proof, including Windows `utils/7za.exe` sidecar.
- Lacapult-side macOS repair path for selected C-AOL `v0.2.0` app dylib/load-path issues.
- Identity-surface correction after quarantine: first Game-tab launcher framing and About GitHub link retargeted to Lacapult.

Detailed evidence lives in `TESTING.md` as an index and in the relevant `doc/*.md` packets.

## Held / out of scope unless reopened

- Public GitHub push/release publication, signing, notarization, and final public release confidence.
- New C-AOL game release or C-AOL `v0.3.0` packaging.
- API secrets or live remote API calls in automated proof.
- Automated package-manager installs or model pulls without explicit clearance.
- Full OpenVINO installer automation; OpenVINO remains hidden/specialized until a clearer product path exists.
- Real user Application Support / saves / worlds / mods mutation in automated tests.
- DDA/TLG/BN/EOD/TISH as visible first-class launcher targets.

## Product intent

The v0 player story is still simple:

1. Download/open Lacapult without developer tooling.
2. See a clearly Lacapult launcher surface for C-AOL.
3. Fetch existing C-AOL releases from `josihosi/Cataclysm-AOL`.
4. Install/update the selected game package while preserving user data.
5. Configure or check LLM backend readiness with honest API/Ollama guidance.
6. Optionally generate/apply C-AOL-native companion summary packs through explicit confirmation and rollback-aware paths.
7. Launch the installed game.

## Required source lineage

Preserve MIT license notice and credits for qrrk's Catapult, Hihahahalol's Dabdoob/Catapult_Dabdoob, Cataclysm: DDA/TLG/BN while inherited support or credits remain, and Cataclysm: Arsenic and Old Lace. Do not erase lineage; remove only misleading public product identity.
