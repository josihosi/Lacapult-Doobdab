# Catapult-Dabubu Windows retest follow-up v1 — installer vision / status dots / text density

Status: LOCAL PROOFED / TEST RELEASE PENDING / QUARANTINE STILL ACTIVE

Imagination source: `doc/catapult-dabubu-installer-vision-retest-imagination-source-2026-05-02.md`.

Raw intake: `doc/josef-windows-debug-intake-2026-05-02.md`.

Prior packet: `doc/lacapult-windows-retest-fix-packet-v0-2026-05-01.md`.

## Summary

Josef retested the `Catapult-Dabubu` launcher and found three remaining product blockers:

1. API / LLM setup does not install AnyLLM packages with venv creation, so the installer does not actually install the software needed for the backend path.
2. The visible setup screen still has too much background/helper text and feels too full.
3. Readiness/status lights do not render correctly on Windows; likely Unicode/emoji glyph support. Replace them with reliable big colored dots/labels using font/theme color.
4. Ollama setup needs real RAM/VRAM hardware checks, explicit long install/download wait warnings, and serialized install/pull behavior instead of unsafe chaining.
5. Mods/summarizer inventory labeling must stop saying unclear `Show Stock`; built-in/mod inventory wording should be plain.

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

- Replace fragile Unicode/emoji readiness lights with a Windows-safe colored indicator implementation on both API and Ollama pages.
- Preferred shape: big dot/bullet/circle rendered with font color/theme color red/green/yellow/gray, plus text label for accessibility.
- Do not depend on emoji color rendering or special glyph support.
- Add a local/static/UI proof that status indicator nodes carry explicit colors/states rather than relying on Unicode traffic-light symbols.

### 4. Ollama hardware check / install sequencing

- Replace hardware recommendation prose with a real hardware check: measure RAM and VRAM where available, then show green/yellow/red runnability status from those values.
- Show Ollama command previews as CLI-input-style text, not loose prose.
- Warn that Ollama install/model download can take several minutes and may appear to wait while external work continues.
- Do not unsafe-chain install + model pull. If Ollama was just installed or is not running yet, stop after the install/startup step and tell the user to Check before pulling the model.

### 5. Mods/summarizer inventory labeling

- Rename unclear `Show Stock` English mod-inventory copy to plain built-in/mod inventory wording.
- Preserve bottom cutoff/button visibility as a Windows visual check item from screenshot `/Users/josefhorvath/.openclaw/media/inbound/4e8d8209-6430-4ee4-a482-aa4cae3953d2.png` if local image inspection is unavailable.

## Non-goals

- No public/stable/latest release or quarantine lift.
- No GitHub repository rename.
- No C-AOL game release work.
- No live API calls, secret reads, real user-data mutation, or package installs in automated proof without fresh explicit clearance.
- Do not reopen unrelated launcher tabs unless their shared status-light/helper-text component must change.

## Success state

- [x] API / AnyLLM setup has an obvious path that creates/uses the venv and installs required AnyLLM packages/dependencies, with status/progress for each phase.
- [x] Automated/sandbox proof verifies the intended AnyLLM package-install command/plan without touching real user secrets or real environment.
- [x] Visible LLM/API setup copy is substantially reduced; controls/status/actions are visually primary.
- [x] Readiness indicators are implemented as Windows-safe big colored dots/labels on API and Ollama pages, not fragile emoji/Unicode traffic lights.
- [x] UI/static smoke proves colored status indicators carry explicit red/green/yellow/gray states and no old fragile light glyph path remains in visible setup status.
- [x] Ollama hardware check measures RAM/VRAM where available and shows explicit green/yellow/red runnability state.
- [x] Ollama setup preview/warnings make long install/download waits clear and avoid unsafe install+pull chaining when Ollama is not ready.
- [x] Mods/summarizer inventory label is plain (`built-in game mods`/inventory wording), not `Show Stock`; Windows bottom-cutoff visual check remains tracked.
- [x] C-AOL `Downloadable` mod catalog empty-state explains it is optional add-on catalog, not the main built-in/user/world mod inventory or Summarizer source.
- [x] Mods page clearly says Summarizer is status-only/no-create-here and points to the Settings Summary creation/apply path if available.
- [x] Repeated identical Summarizer dry-run/status-only clicks do not spam indistinguishable duplicate log lines.
- [x] Shared overcrowding/top-bar fix enlarges the window and restores native resizable behavior or equivalent autofit evidence.
- [x] A fresh Josef-only Windows test build is produced after the fixes.
- [ ] A fresh Josef-only Windows Draft/prerelease is created/updated and verified after the fixes.
- [ ] Josef confirms on Windows that API install semantics, text density, and colored dots are acceptable.

## Testing expectations

- Source/static scan for old Unicode light glyphs and remaining long visible setup text.
- Godot UI smoke for status-dot rendering/state data and LLM/API setup copy density.
- Sandbox/proof-mode API AnyLLM installer test that records the exact venv/package install plan and status phases without running uncontrolled pip in the real environment.
- Packaging proof before any new Windows test build.
- GitHub Draft/prerelease verification if a new Josef-only package is published.

## Handoff caution

Do not close from macOS-only screenshots. The complaint is Windows-visible and user-facing. Local tests can prove structure; final acceptance needs Josef Windows confirmation.

## Local proof boundary — 2026-05-02

Local implementation/proof now covers the non-release v1 repair scope:

- API setup has one obvious `Set up API / AnyLLM` path that creates/updates the venv and installs AnyLLM/provider packages after confirmation; automated proof records intent only.
- LLM setup copy is compact, with controls/status/actions visually primary.
- API/Ollama readiness uses explicit big colored dot rows with state metadata instead of emoji traffic-light glyphs.
- Ollama shows RAM/VRAM hardware check results, serialized CLI previews, long-wait warning, and does not queue model pull before command/server readiness.
- Mods wording now says built-in game mods/inventory; C-AOL Downloadable empty-state and Summarizer status-only vs Settings creation/apply path are explicit.
- Shared window layout is larger/native-resizable and hides the custom titlebar compatibility node locally.

Evidence classes: source/static proof, isolated-HOME Godot UI smokes, sandboxed backend/config proof. Safety boundary: no live API call, API secret readout, package-manager install, Python venv creation, Ollama model pull, release publication, or real user-data mutation.

Package proof produced the fresh Windows unsigned test artifact, and the Josef-only Draft/prerelease `catapult-dabubu-josef-windows-retest-v1-2026-05-02` is uploaded/verified at `https://github.com/josihosi/Lacapult-Doobdab/releases/tag/untagged-6c700e3ce1114782def5` with Windows asset `Catapult-Dabubu-windows-unsigned.zip` (66,587,417 bytes, SHA-256 `a0ae09628349df1f6840b68b6328f8ef066892f0a7a1a8dc6f5a70f8ebe3ac5d`). Remaining: Josef Windows confirmation. Release quarantine remains active.
