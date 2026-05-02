# Catapult-Dabubu Windows retest follow-up v1 — installer vision / status dots / text density

Status: ACTIVE / GREENLIT FOLLOW-UP FROM JOSEF WINDOWS RETEST

Imagination source: `doc/catapult-dabubu-installer-vision-retest-imagination-source-2026-05-02.md`.

Raw intake: `doc/josef-windows-debug-intake-2026-05-02.md`.

Prior packet: `doc/lacapult-windows-retest-fix-packet-v0-2026-05-01.md`.

## Summary

Josef retested the `Catapult-Dabubu` launcher and found three remaining product blockers:

1. API / LLM setup does not install AnyLLM packages with venv creation, so the installer does not actually install the software needed for the backend path.
2. The visible setup screen still has too much background/helper text and feels too full.
3. Readiness/status lights do not render correctly on Windows; likely Unicode/emoji glyph support. Replace them with reliable colored dots/labels using font/theme color.

Schani verdict: the vision is not fulfilled yet. The launcher currently still asks too much of the user and does not provide a trustworthy install/status surface.

## Scope

### 1. API / AnyLLM installer semantics

- Make the API/LLM setup path install the required AnyLLM packages into the selected/created venv through an obvious installer action.
- If retaining separate venv/package actions, the primary visible path must still make the dependency chain impossible to miss; ideally one action handles both or clearly stages both.
- Status/progress must distinguish: creating venv, installing AnyLLM/packages, success, failure, and next check.
- Keep API secrets out of saved config/logs.
- Automated proof may use sandbox/proof mode; do not install packages into Josef's real environment during tests without explicit clearance.

### 2. Visible text density reduction

- Audit the LLM/API setup visible page and remove or move background/helper paragraphs that do not directly guide the next action.
- Keep short labels, compact status, and local button help; move longer explanation to tooltip/help/collapsible text only if still needed.
- The screen should present controls/status/actions first, not a wall of setup prose.

### 3. Robust colored status dots

- Replace fragile Unicode/emoji readiness lights with a Windows-safe colored indicator implementation.
- Preferred shape: small dot/bullet/circle rendered with font color/theme color red/green/yellow/gray, plus text label for accessibility.
- Do not depend on emoji color rendering or special glyph support.
- Add a local/static/UI proof that status indicator nodes carry explicit colors/states rather than relying on Unicode traffic-light symbols.

## Non-goals

- No public/stable/latest release or quarantine lift.
- No GitHub repository rename.
- No C-AOL game release work.
- No live API calls, secret reads, real user-data mutation, or package installs in automated proof without fresh explicit clearance.
- Do not reopen unrelated launcher tabs unless their shared status-light/helper-text component must change.

## Success state

- [ ] API / AnyLLM setup has an obvious path that creates/uses the venv and installs required AnyLLM packages/dependencies, with status/progress for each phase.
- [ ] Automated/sandbox proof verifies the intended AnyLLM package-install command/plan without touching real user secrets or real environment.
- [ ] Visible LLM/API setup copy is substantially reduced; controls/status/actions are visually primary.
- [ ] Readiness indicators are implemented as Windows-safe colored dots/labels, not fragile emoji/Unicode traffic lights.
- [ ] UI/static smoke proves colored status indicators carry explicit red/green/yellow/gray states and no old fragile light glyph path remains in visible setup status.
- [ ] A fresh Josef-only Windows test build/release is produced after the fixes.
- [ ] Josef confirms on Windows that API install semantics, text density, and colored dots are acceptable.

## Testing expectations

- Source/static scan for old Unicode light glyphs and remaining long visible setup text.
- Godot UI smoke for status-dot rendering/state data and LLM/API setup copy density.
- Sandbox/proof-mode API AnyLLM installer test that records the exact venv/package install plan and status phases without running uncontrolled pip in the real environment.
- Packaging proof before any new Windows test build.
- GitHub Draft/prerelease verification if a new Josef-only package is published.

## Handoff caution

Do not close from macOS-only screenshots. The complaint is Windows-visible and user-facing. Local tests can prove structure; final acceptance needs Josef Windows confirmation.
