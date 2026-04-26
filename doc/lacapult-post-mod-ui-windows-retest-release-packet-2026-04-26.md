# Lacapult post-mod UI Windows retest release packet — 2026-04-26

Status: published / awaiting Josef Windows laptop retest.

## Normalized contract

**Title:** Lacapult post-mod UI Windows retest release packet v0

**Request kind:** Josef greenlit follow-up / release-after-current-lane request

**Summary:** After the current Lacapult UI/mod-installer/Summarizer lane is actually fixed and proven, make a fresh Lacapult GitHub test/prerelease so Josef can download a new Windows package from the GitHub Releases page and retest on his Windows laptop. Josef greenlit this publication on 2026-04-26, and the prerelease is now published at https://github.com/josihosi/Lacapult-Doobdab/releases/tag/lacapult-post-mod-ui-retest-2026-04-26. This is the next retest release after the UI/mod installer work, not a public-final release declaration and not a new C-AOL game release.

## Scope

1. Wait until the current real C-AOL mod/Summarizer generation/apply UI lane reaches its honest stop line: UI surfaces, mod install/enable or apply path, backend-readiness gates, preview/confirmation, backup/rollback visibility, and sandbox proof are coherent enough for a human Windows retest. Done for this packet via the Slice 6 retestable-state proof.
2. Regenerate fresh Lacapult unsigned package artifacts from the then-current `main` source, including the Windows package and sidecar extraction utilities required by the installer path.
3. Publish or update a Lacapult-specific GitHub test/prerelease with clear release notes and downloadable Windows artifact(s) for Josef.
4. Record tag/release URL, source commit, artifact names, sizes, SHA-256 hashes, and proof commands in canon/testing notes.
5. Keep the release notes explicit that this is a Lacapult launcher retest build for the UI/mod-installer lane, capable of installing existing C-AOL releases; it is not a new C-AOL game release.
6. Give Josef a short Windows retest checklist focused on the newly fixed UI/mod/Summarizer path plus the already expected install/play/resume path.

## Non-goals

- Do not create, tag, publish, or reshape a C-AOL game release.
- Do not call this a final public release unless signing/notarization/SmartScreen/public-QA work is explicitly done later.
- Do not block the implementation lane by making release publication active before the UI/mod-installer fixes are complete; for this packet, publication happened only after the retestable-state proof and Josef's explicit greenlight.
- Do not require live API secrets, model pulls/downloads, package installs, or mutation of Josef's real machine in automated proof.
- Do not reopen C-AOL `v0.3.0` release shape from this Lacapult retest packet.

## Success state

- [x] The current real C-AOL mod/Summarizer generation/apply UI lane is closed or parked at a retestable state with its own evidence recorded.
- [x] Fresh Lacapult unsigned packages are regenerated from the intended source commit, with the Windows package including required sidecar utilities such as `utils/7za.exe`.
- [x] A Lacapult GitHub test/prerelease exists for the post-mod UI retest build, with downloadable Windows artifact(s), clear notes, and no C-AOL-release confusion.
- [x] Remote release inspection proves the tag, URL, prerelease state, assets, sizes, and hashes.
- [x] Canon/testing notes record the source commit, proof commands, release URL, artifact hashes, and remaining caveats.
- [x] Josef has a concise Windows retest checklist for install/play/resume plus the fixed UI/mod/Summarizer path.

## Testing expectations

- Re-run the same package-shape gates that caught the previous missing `utils/7za.exe` blocker.
- Re-run the relevant Godot project/load and mod/Summarizer UI smoke gates for the implemented slice.
- Verify the remote GitHub release with `gh release view` or equivalent before telling Josef to download it.
- Keep automated proof sandboxed: no real Application Support mutation, API-secret use, model pull, package install, or public-final claim unless explicitly cleared.

## Publication evidence

- Release: https://github.com/josihosi/Lacapult-Doobdab/releases/tag/lacapult-post-mod-ui-retest-2026-04-26
- Source commit: `8c9d8f3d5e3bc9757fffd69b7eeecd8cb8bcbdba`.
- Windows asset: `Lacapult-Doobdab-windows-unsigned.zip`, 66,479,179 bytes, SHA-256 `694823044d89f091257ce6dedbf3cd92d0ba3b13ba0014ee3264146dae29dc42`, includes `utils/7za.exe`.
- Remote `gh release view` verified prerelease state, URL, asset names, sizes, and digests.
- Remaining caveat: real Windows laptop click-through/playtest is still Josef's external confidence step.
