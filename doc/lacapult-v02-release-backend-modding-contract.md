# Lacapult Doobdab v0.2.0 release + backend + modding contract

Status: **GREENLIT / ACTIVE AMENDMENT**

## Normalized contract

title: Lacapult Doobdab v0.2.0 release installer plus first backend setup options

request_kind: greenlight / active-scope amendment

summary: Lacapult Doobdab v0 should specifically install the existing C-AOL `v0.2.0` release assets, then grow the first practical LLM backend setup surface. The launcher remains C-AOL-specific for now, with possible future ports to other games. It should preserve inherited mod-management support and begin a bounded mod-compatibility investigation, including whether mod summaries can support NPC/LLM context later.

classification: active, with backend and modding sub-slices sequenced behind the v0.2.0 release install proof

## Scope

### Release install

- Fetch `josihosi/Cataclysm-AOL` GitHub releases.
- Prefer and prove `v0.2.0` assets first.
- Select platform-matching assets:
  - Linux: `_linux.tar.gz`
  - macOS: `_macos.dmg`
  - Windows: `_windows.zip`
- Preserve the option to show/install future releases after the v0.2.0 proof works.
- Reuse Dabdoob's existing install/update/userdata-preservation path where possible.

### LLM backend setup options

The visible backend selector has three choices, with v0 honesty about capability:
1. **API backend**
   - UI/config path for choosing API mode.
   - Safe config-writing/checking path for C-AOL.
   - Smoke/status check if feasible without needing secrets.
2. **Ollama backend**
   - UI/config path for choosing Ollama mode.
   - Detect whether `ollama` exists and whether the local server responds.
   - Offer setup guidance and config-writing first; only automate install if the safe platform-specific path is clear.
3. **OpenVINO backend**
   - Selectable third option in the UI.
   - v0 should save/report an honest placeholder, detection, or status artifact if feasible.
   - Full OpenVINO setup/installer automation remains later.

### Modding support

- Preserve inherited Dabdoob mod/soundpack/tileset support unless it directly blocks C-AOL-first UX.
- Investigate how inherited mod metadata maps onto C-AOL releases.
- Start a compatibility summary format for C-AOL mods.
- Include a future-facing note for NPC/LLM summaries: mod summaries may later tell NPC/context systems what extra content, factions, items, monsters, locations, or tone the installed mod adds.

## Non-goals

- Public repo exists at `https://github.com/josihosi/Lacapult-Doobdab`, but do not push, publish releases, or contact upstream without fresh explicit clearance.
- Do not attempt all three backend installers before v0.2.0 release installation works.
- Do not fully solve OpenVINO in this slice; make it selectable and honest, not fake-complete.
- Do not promise automatic Ollama installation unless the path is safe and verified.
- Do not rewrite all inherited mod infrastructure before proving the release installer.
- Do not make NPC summary generation part of the installer v0; only define the compatibility-summary direction.

## Success state

Done when:

- `v0.2.0` C-AOL release assets are fetched and correctly filtered by platform.
- At least one v0.2.0 asset produces valid installer metadata.
- The launcher is C-AOL-specific in visible identity and defaults.
- API, Ollama, and OpenVINO appear as the visible backend choices in canon and UI.
- API/Ollama have safe config/status paths; OpenVINO has an honest selectable placeholder/detection/status path without pretending full setup exists.
- Inherited modding support is not accidentally broken by C-AOL-only changes.
- The mod-compatibility/NPC-summary investigation records inherited sources, C-AOL assumptions, and next proof needs without pretending runtime NPC integration exists.

## Testing impact

Needed:

- Live GitHub release parsing proof for `v0.2.0` assets.
- Static/config proof for backend option defaults and any config-writing path.
- Safe backend detection proof where possible:
  - API path can be config-shape only if no key is available.
  - Ollama path can run local detection (`ollama` command/server presence) but must not pull huge models without explicit clearance.
- Modding proof starts as inventory/static inspection: identify inherited mod list/source and how it keys compatibility.

## Handoff note for Andi

Sequence the work:
1. Get v0.2.0 release listing/filter/install metadata working.
2. Rebrand and C-AOL-only defaults enough that the launcher surface is honest.
3. Add API + Ollama backend setup plan/stub/config path, and keep OpenVINO visible as the third selectable v0-honest option.
4. Inspect inherited mod support deeply enough to mark C-AOL compatibility assumptions and next proof needs.
5. Park full OpenVINO automation and deeper mod/NPC runtime integration as next slices unless explicitly reopened.
