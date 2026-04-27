# SUCCESS

Success-state ledger for Lacapult Doobdab. Keep it compact; full evidence belongs in `doc/*.md` and git history.

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

## Lacapult Josef test release v0

Status: ACTIVE / TEST RELEASE ONLY / QUARANTINE STILL ACTIVE

Success state:
- [ ] Canon records Josef's 2026-04-27 clearance for a bounded test release without lifting quarantine.
- [ ] Fresh package proof from current debug-stack-complete `main` passes.
- [ ] Windows unsigned package and checksums/build notes are attached to a GitHub Draft/prerelease test release.
- [ ] Release copy says this is for Josef Windows validation, not a final/public confidence claim or C-AOL game release.
- [ ] Josef checklist is included: first launch/top bar, first visible tab, release row wording, install/download impression.
- [ ] `gh release view` proves the remote release/tag/assets exist.

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
