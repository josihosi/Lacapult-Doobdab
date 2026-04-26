# Lacapult launcher test release packet — 2026-04-26

## Classification

HOTFIX PUBLISHED / PROVEN FOR JOSEF TEST AFTER WINDOWS 7-ZIP BLOCKER.

## User request

Josef wants Lacapult Doobdab itself packaged into a clean downloadable launcher release so he can download it on his Windows laptop and test the launcher/game path. This is not a request to create a new C-AOL game release, not a C-AOL `v0.3.0` decision, and not permission to shortcut unfinished release work.

## Scope

- Build from current Lacapult `main` after the macOS C-AOL `v0.2.0` launch repair canon is included.
- Regenerate fresh Lacapult launcher package artifacts from the current tree, not stale `.proof-cache` packages from before later commits.
- Produce at least a Windows downloadable package suitable for Josef's laptop test.
- Prefer producing the existing macOS/Linux unsigned packages too if the proof script can do so cleanly, because the current packaging lane already knows those shapes.
- Create a Lacapult Doobdab GitHub test/prerelease with clear release notes and attached artifacts/checksums, if GitHub auth/repo permissions allow it.
- Make the release notes say exactly what the package is: an unsigned Lacapult launcher test build for Josef testing, capable of fetching/installing existing C-AOL `v0.2.0` assets.
- Include Windows user instructions: download zip, extract, run the exe, expect normal unsigned-app/SmartScreen friction if Windows complains, then test install/play/resume/settings/mods/backups.
- Record artifact names, sizes, SHA-256 hashes, tag/release URL, commands, and proof results in `TESTING.md`.

## Non-goals

- Do not create, tag, publish, or reshape a C-AOL game release.
- Do not decide or fake a C-AOL `v0.3.0` release shape.
- Do not sign, notarize, or claim Windows SmartScreen trust unless that work is explicitly done later.
- Do not contact upstream, use API secrets, pull/install models, automate OpenVINO installs, or mutate Josef's real Application Support/game data.
- Do not call a stale local package good enough just because it exists.
- Do not describe this as a final public release candidate if it is only an unsigned test/prerelease.

## Success state

- [x] Fresh package proof passes from current `main` after this packet.
- [x] Windows launcher package exists, is attached to a Lacapult GitHub test/prerelease, and has a SHA-256 recorded.
- [x] Release notes clearly distinguish Lacapult launcher release from C-AOL game releases.
- [x] `gh release view` or equivalent proves the release/tag/assets exist remotely.
- [x] `TESTING.md` records the package proof, release URL/tag, artifact hashes, and remaining unsigned/not-final caveats.
- [x] Repo canon no longer says public release publication is wholly blocked for this test-release lane; it says final/signed release remains parked while this test prerelease is proven.

Published result: `lacapult-test-2026-04-26` / https://github.com/josihosi/Lacapult-Doobdab/releases/tag/lacapult-test-2026-04-26

Hotfix result after Josef Windows testing found missing `utils/7za.exe`: `lacapult-test-2026-04-26-2` / https://github.com/josihosi/Lacapult-Doobdab/releases/tag/lacapult-test-2026-04-26-2

## Suggested tag/name

Use a Lacapult-specific tag that cannot be confused with C-AOL game versions, for example:

- tag: `lacapult-test-2026-04-26`
- title: `Lacapult Doobdab test build 2026-04-26`

If that tag already exists, inspect it first. Update only if it is clearly the same test-release lane and safe to replace; otherwise use a monotonic suffix such as `lacapult-test-2026-04-26-2`.

## Evidence bar

Minimum commands/evidence:

```sh
python3 tools/prove_lacapult_export_packaging.py
python3 tools/prove_caol_release.py --all-platforms
python3 tools/prove_caol_backend_contract.py
/opt/homebrew/bin/godot --path . --no-window --quit
git diff --check
gh release view <tag> --repo josihosi/Lacapult-Doobdab --json tagName,name,isPrerelease,assets,url
```

Add any extra checks needed if the packaging/release path changes.


## Hotfix addendum - 2026-04-26

Josef's Windows test found the first prerelease could download the C-AOL archive but could not extract it because the Windows package did not contain `utils/7za.exe` next to the launcher. The hotfix release `lacapult-test-2026-04-26-2` fixes that packaging shape, includes sidecar 7-Zip binaries for Windows/Linux, proves the Windows zip contains `utils/7za.exe`, curates the C-AOL install list to the four expected port releases, and replaces the startup lineage note with a plain Dabdoob/Catapult developer thank-you.

The Windows custom-title-bar rendering note remains follow-up UI polish; it is not claimed fixed by this hotfix.
