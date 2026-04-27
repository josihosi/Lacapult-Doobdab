# Lacapult Josef test release v0 — 2026-04-27

Status: active release-test slice.

## Clearance and boundary

Josef superseded the parking/deactivate idea on 2026-04-27 and asked for a Lacapult release he can test. This is fresh clearance for a **test release only**.

This does not lift the Lacapult release quarantine and does not authorize:

- stable/latest/final/public-confidence wording;
- broad release announcement;
- C-AOL game release work;
- signing/notarization claims;
- package/model installs, model pulls, live API calls, or real user-data mutation as proof.

## Target

Create a clearly labelled GitHub Draft test release if feasible for owner testing. Use prerelease only if Draft asset access becomes awkward.

Planned tag/name:

- tag: `lacapult-josef-test-2026-04-27`
- name: `Lacapult Doobdab Josef test build 2026-04-27`

Assets:

- `Lacapult-Doobdab-windows-unsigned.zip`
- `SHA256SUMS.txt`
- `manifest.json` if useful as build notes/proof context

## Build/proof commands

Run from current `main` after canon is committed:

```sh
python3 tools/prove_lacapult_export_packaging.py
HOME=$(mktemp -d /tmp/lacapult-window-chrome-home.XXXXXX) godot --path . --no-window -s tools/godot_window_chrome_inspection.gd
gh release view lacapult-josef-test-2026-04-27 --repo josihosi/Lacapult-Doobdab --json tagName,name,isDraft,isPrerelease,assets
```

## Release-note requirements

The release notes must say:

- this is an unsigned Lacapult launcher test build for Josef Windows validation;
- it is not a C-AOL game release;
- it is not final/public confidence and does not lift quarantine;
- it fetches/installs existing C-AOL releases rather than bundling a C-AOL game archive.

## Josef checklist

Josef should test:

1. First launch / top bar: do the close/minimize/maximize controls look acceptable, not oversized/clipped/messed up?
2. First visible tab: does the window clearly read as Lacapult launcher, not a C-AOL game archive?
3. Release row wording: does the C-AOL release row read like target-game selection, not like Lacapult itself is CAOL?
4. Install/download impression: does download/install feel like Lacapult fetching an existing C-AOL release?

## Success state

- [ ] Fresh packaging proof passes from current debug-stack-complete `main`.
- [ ] Windows package contains `Lacapult-Doobdab.exe` and `utils/7za.exe`.
- [ ] GitHub Draft/prerelease test release exists with Windows asset, checksums, and build notes.
- [ ] Release notes preserve quarantine language and include Josef's checklist.
- [ ] Remote release shape is verified with `gh release view`.

## Hollow-rock suspicion

A downloadable test release gives Josef the missing Windows evidence, but it can also look like a quarantine lift if the GitHub surface is sloppy. Keep the release Draft if feasible and make every visible word say “Josef test build”, not “public release candidate”.
