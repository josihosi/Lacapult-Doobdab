# SUCCESS

Success-state ledger for Catapult-Dabubu (formerly Lacapult Doobdab). Keep it compact; full evidence belongs in `doc/*.md` and git history.

## Release quarantine / identity investigation

Status: ACTIVE QUARANTINE / REPUBLISH HELD

Success state:
- [x] 2026-04-26 Lacapult prerelease family converted to Draft/quarantine.
- [x] Public removal verified: unauthenticated releases API returned zero public releases and old latest Windows asset URL returned `404`.
- [x] Local Windows artifact inspected as Lacapult-shaped (`Lacapult-Doobdab.exe` plus 7-Zip sidecars), not a full C-AOL game archive.
- [x] Initial identity surface correction landed: first Game-tab launcher framing and About GitHub link retargeted to Lacapult.
- [ ] Real Windows first-launch click-through checks user-facing identity before any renewed confidence claim.
- [ ] Josef/Schani explicitly decide whether and how to republish.

Canonical docs:
- `doc/lacapult-release-quarantine-investigation-2026-04-26.md`
- `doc/lacapult-post-mod-ui-windows-retest-release-packet-2026-04-26.md`
- `doc/lacapult-launcher-test-release-packet-2026-04-26.md`

## Lacapult debug-note correction stack

Status: LOCAL IMPLEMENTATION COMPLETE / WINDOWS CONFIRMATION PENDING

Success state:
- [x] Raw 2026-04-26 debug-note intake found in workspace memory/runtime files.
- [x] All notes are preserved in canon under `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`.
- [x] Stack was parked until Josef explicitly reopened it for Alex on 2026-04-27.
- [x] Package 1 complete: LLM tab de-clutter/backend-scope correction.
- [x] Package 2 complete: setup Save/Check/Install action pattern.
- [x] Package 3 complete: API / AnyLLM real setup workflow.
- [x] Package 4 complete: Ollama real installer + model readiness workflow.
- [x] Package 5 locally complete: window chrome investigation/fix root-cause class named, smallest CustomTitleBar metric seam patched/proofed, and bounded Windows confirmation checklist written.
- [ ] Windows/Josef visual confirmation before any cross-platform chrome-fix claim.

## Catapult-Dabubu Windows retest follow-up v3

Status: LOCAL IMPLEMENTATION PROOFED / DECISION NEEDED / QUARANTINE STILL ACTIVE

Success state:
- [x] Raw 2026-05-09 v2 Windows retest notes are preserved in canon.
- [x] Save/apply semantics coherently set selected backend, selected model, runner mode, and runner enablement in the produced confirmed/sandbox apply path without mutating real user config during proof.
- [x] Ollama Windows CPU-only/iGPU fallback is shown as a slow fallback instead of a happy green local path.
- [x] Magiclysm/DinoMod mod compatibility/procedure is proved beyond catalog seeding in a safe sandbox/fixture path.
- [x] Nemotron local setup prepares a `SYSTEM /no_think` alias without duplicating model weights, and remaining `<think>` reasoning leakage is handed off as an explicit C-AOL runner/speech-path blocker in `doc/catapult-dabubu-v3-think-boundary-handoff-2026-05-10.md`.
- [x] Focused local proof passes without live secrets, unapproved package installs, model pulls, or real user-data mutation.
- [ ] Schani/Josef decide whether v3 packaging waits for the C-AOL runner/speech fix or proceeds with the blocker explicitly caveated.
- [ ] Fresh Josef-only Windows v3 Draft/prerelease is produced and verified after local proof and that decision.
- [ ] Josef confirms the v3 Windows package.

Canonical docs:
- `doc/catapult-dabubu-windows-retest-followup-v3-imagination-source-2026-05-09.md`
- `doc/catapult-dabubu-windows-retest-followup-v3-2026-05-09.md`
- `doc/alex-catapult-dabubu-windows-retest-followup-v3-2026-05-09.md`
- `doc/josef-catapult-dabubu-debug-intake-2026-05-09.md`

## Catapult-Dabubu Windows retest follow-up v2

Status: WINDOWS RETESTED / SUPERSEDED BY V3 / QUARANTINE STILL ACTIVE

Success state:
- [x] API setup uses `any-llm-sdk[...]` provider extras while preserving the `from any_llm import completion` runtime seam.
- [x] Normal API setup hides API base URL; base URL remains available only as advanced/custom override.
- [x] Package setup failures surface useful non-secret package/pip error detail and do not imply base/model/key/API-call failure.
- [x] Mistral uses `mistral:v0.3` for pull/readiness/runner paths.
- [x] Nemotron uses `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest` internally while the selector shows a short label.
- [x] Ollama hardware display shows RAM/VRAM in GiB plus red/yellow/green estimated performance lights for Mistral and Nemotron.
- [x] Measured low hardware is not displayed as `missing`.
- [x] API and Ollama routes each expose a safe runner test button that exercises the actual C-AOL runner route.
- [x] Ollama install/model confirmation uses the short timeout/commencement warning.
- [x] Mods catalog/summarizer footing handles Magiclysm/DinoMod when present/available, or reports unavailability precisely.
- [x] Focused static/Godot/backend/mod proof passes without live secrets, unapproved package installs, model pulls, or real user-data mutation.
- [x] Fresh Josef-only Windows v2 Draft/prerelease is produced and verified after local proof.
- [x] Josef retested the v2 Windows package on 2026-05-09 and reported the v3 debug-note batch.

Canonical docs:
- `doc/catapult-dabubu-windows-retest-followup-v2-imagination-source-2026-05-06.md`
- `doc/catapult-dabubu-windows-retest-followup-v2-2026-05-06.md`
- `doc/alex-catapult-dabubu-windows-retest-followup-v2-2026-05-06.md`
- `doc/josef-catapult-dabubu-debug-intake-2026-05-06.md`

## Catapult-Dabubu Windows retest follow-up v1

Status: WINDOWS RETESTED / SUPERSEDED BY V2 / QUARANTINE STILL ACTIVE

Success state:
- [x] API / AnyLLM setup has an obvious path that creates/uses the venv and installs required AnyLLM packages/dependencies, with status/progress for each phase.
- [x] Automated/sandbox proof verifies the intended AnyLLM package-install command/plan without touching real user secrets or real environment.
- [x] Visible LLM/API setup copy is substantially reduced; controls/status/actions are visually primary.
- [x] Readiness indicators are implemented as Windows-safe big colored dots/labels on API and Ollama pages, not fragile emoji/Unicode traffic lights.
- [x] Ollama hardware check measures RAM/VRAM and reports explicit runnability state; install/pull flow is serialized with long-wait warning.
- [x] Mods/summarizer inventory label is plain built-in/mod inventory wording, not unclear `Show Stock`; Windows bottom cutoff remains visually checked.
- [x] C-AOL Downloadable empty-state and Summarizer status-only/create path are discoverable.
- [x] Window/top-bar overcrowding is addressed with larger native-resizable/autofit-style layout proof.
- [x] Repeated identical Summarizer dry-run/status-only clicks are de-spammed or clearly marked as refreshes while remaining no-mutation.
- [x] UI/static smoke proves colored status indicators carry explicit red/green/yellow/gray states and no old fragile light-glyph path remains in visible setup status.
- [x] A fresh Josef-only Windows test build is produced after the fixes.
- [x] A fresh Josef-only Windows Draft/prerelease is created/updated and verified after the fixes.
- [x] Josef retested v1 on Windows and reported the 2026-05-06 v2 debug-note batch.
- [x] Josef retested the next v2 Windows package; remaining findings are tracked in v3.

Canonical docs:
- `doc/catapult-dabubu-installer-vision-retest-imagination-source-2026-05-02.md`
- `doc/catapult-dabubu-windows-retest-followup-v1-2026-05-02.md`
- `doc/alex-catapult-dabubu-windows-retest-followup-v1-2026-05-02.md`
- `doc/josef-windows-debug-intake-2026-05-02.md`

## Lacapult Windows retest fix v0

Status: LOCAL PATCHED / RETEST FAILED ON WINDOWS / QUARANTINE STILL ACTIVE

Success state:
- [ ] Shared popup/dialog/tooltip/layout remains Windows-retest-gated; 2026-05-02 retest found broader installer-vision/text/status-light blockers now tracked in v1.
- [x] Long backend setup popup/help text wraps via autowrap, bounded confirmation size, and deliberate newlines in local UI smoke.
- [x] Top row/window metrics received a follow-up local fix: default/test window is now `760x820`; Windows visual confirmation remains required.
- [x] `backend_external_setup_proof_only` has a safe default and local smoke proves safe-read false.
- [x] Long-running install actions set a visible in-progress/waiting state before non-proof external commands.
- [x] API / AnyLLM venv/package setup is split as `Create venv only` vs `Install AnyLLM packages`, with confirmation/status copy explaining the boundary.
- [x] Ollama model selection/default, readiness lights, installer/model-pull failure separation, Windows `Ollama.Ollama` copy, and Mistral/Nemotron hardware guidance are locally proofed.
- [x] `Catapult-Dabubu` identity pass is reflected in source/package proof surfaces where safe, with upstream lineage still credited and GitHub repo rename held for fresh confirmation.
- [x] Fresh Josef-only `Catapult-Dabubu` Windows package is built/checksumed locally without lifting quarantine.
- [x] Fresh Josef-only `Catapult-Dabubu` GitHub Draft/prerelease test release is attached and verified without lifting quarantine.
- [x] Josef completed a Windows retest from the fresh Draft/prerelease and reported remaining blockers; v1 follow-up is active.

Canonical docs:
- `doc/lacapult-windows-retest-fix-imagination-source-2026-05-01.md`
- `doc/lacapult-windows-retest-fix-packet-v0-2026-05-01.md`
- `doc/alex-lacapult-windows-retest-fix-handoff-2026-05-01.md`
- `doc/josef-windows-debug-intake-2026-05-01.md`

## Lacapult Josef test release v0

Status: READY FOR JOSEF / TEST RELEASE ONLY / QUARANTINE STILL ACTIVE

Success state:
- [x] Canon records Josef's 2026-04-27 clearance for a bounded test release without lifting quarantine.
- [x] Fresh package proof from current debug-stack-complete `main` passes.
- [x] Windows unsigned package and checksums/build notes are attached to a GitHub Draft/prerelease test release.
- [x] Release copy says this is for Josef Windows validation, not a final/public confidence claim or C-AOL game release.
- [x] Josef checklist is included: first launch/top bar, first visible tab, release row wording, install/download impression.
- [x] `gh release view` proves the remote release/tag/assets exist: `https://github.com/josihosi/Lacapult-Doobdab/releases/tag/untagged-62e620a97f3b0edaa8ca`.
- [ ] Josef completes Windows validation from the Draft test release.

## Completed product footing

Status: CHECKPOINTED / NOT ACTIVE

- [x] C-AOL `v0.2.0` release fetch/install path proven far enough for launcher footing.
- [x] Controlled macOS DMG shape and sandbox install-shape proofs completed.
- [x] Lacapult-side macOS dylib/load-path repair path added and smoke-proven for the selected C-AOL app.
- [x] Backend API/Ollama/OpenVINO v0-safe readiness/config paths implemented and proofed without secrets/model pulls/package installs.
- [x] LLM backend setup installer packet implemented/proofed with its own tab, confirmation-gated intent actions, Ollama model choices, and outsider GUI reasoning artifact.
- [x] C-AOL mod/Summarizer discovery/status model, dry-run UX, sandbox generated-pack apply/rollback, runtime prompt-consumption proof, error/rollback matrix, target chooser, fixture backend, and already-local Ollama smoke completed.
- [x] Local unsigned macOS/Linux/Windows package exports generated and shape-checked; Windows package includes `utils/7za.exe`.
- [x] Post-mod UI Windows retest prerelease was published after explicit greenlight, then Draft/quarantined after the identity complaint.

## Parked future slices

- [ ] Signed/notarized/public Lacapult release and normal-player install QA.
- [ ] C-AOL `v0.3.0` release shape.
- [ ] OpenVINO guided setup/installer automation beyond hidden/specialized v0 scope.
- [ ] Large model download/model-pull automation or deeper local-model recommendation UX.
- [ ] API-key/backend live smoke requiring real secrets.
- [ ] C-AOL-specific mod/soundpack/tileset recommendation packs.
