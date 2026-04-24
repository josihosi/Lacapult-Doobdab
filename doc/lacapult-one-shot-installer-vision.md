# Lacapult Doobdad one-shot installer vision

Status: **GREENLIT PRODUCT NORTH STAR / EXECUTE IN PROOF ORDER**

This is the bigger apple basket. It tells Andi what the installer should become, while `TODO.md` still controls the immediate proof order.

## One-shot promise

A new player should be able to go from “I want to try C-AOL” to “the game launches and the NPC backend is configured enough to test” without hunting through scattered README steps.

The launcher should answer four questions in order:

1. **Which C-AOL build do you want?**
2. **Where should it live?**
3. **How should NPC LLMs run?**
4. **Which supported extras/mods should be enabled?**

If the installer cannot fully automate a step, it should still guide and verify it instead of shrugging.

## Ideal first-run flow

### 1. Welcome / target

- Product name: Lacapult Doobdad.
- Target: Cataclysm: Arsenic and Old Lace.
- Short explanation: installs C-AOL releases and helps set up the NPC LLM backend.
- Credits link visible from this screen or About.

### 2. Game release selection

Default path:
- Highlight `v0.2.0` as the first supported release target.
- Show platform-matching assets only by default.
- Advanced toggle may reveal all assets/branches later.

Release list fields:
- release tag/name
- published date
- platform asset name
- file size if available
- installability state:
  - ready
  - no asset for this platform
  - unsupported archive type
  - download unavailable

Expected v0.2.0 asset patterns:
- Linux: `_linux.tar.gz`
- macOS: `_macos.dmg`
- Windows: `_windows.zip`

### 3. Install/update location

Use Dabdoob’s existing installed-version model where possible.

Installer should preserve:
- saves
- config
- mods/user data
- previous install records

Installer should avoid:
- overwriting user data without backup
- marking an install active before a plausible executable is found
- pretending a DMG/tar/zip extraction succeeded when it merely downloaded

### 4. LLM backend setup

First backend pair: **API** and **Ollama**.

OpenVINO remains specialized/future, but visible enough that users know it exists.

#### API backend

Purpose: fastest onboarding/debug path.

Installer behavior:
- select API mode
- show provider/config fields only if the C-AOL config format supports them cleanly
- never print or log secrets
- write/check C-AOL config shape
- smoke test only when safe and a key/config already exists

Success is allowed to be “config path written and no key provided, smoke test skipped honestly.”

#### Ollama backend

Purpose: mainstream local backend.

Installer behavior:
- detect `ollama` command if present
- detect local server if running
- show installed models if cheap/safe
- write/check C-AOL config for local endpoint/model
- offer setup guidance if Ollama is missing

Do **not** pull large models or run heavyweight installers without explicit clearance. The one-shot installer can be excellent without deciding to download half the moon while nobody is looking.

#### OpenVINO backend

Purpose: specialized hardware/local path.

v0 behavior:
- visible as future/specialized option or documented parked path
- optional detector/stub only if cheap
- no full install automation in v0

## Backend configuration model

Preferred shape:

```json
{
  "backend": "api|ollama|openvino|manual",
  "status": "not_configured|configured|detected|verified|blocked",
  "endpoint": "...",
  "model": "...",
  "last_check": "...",
  "notes": "..."
}
```

The actual C-AOL config files win over this sketch. If the game already has a different config shape, adapt to reality and record it in `TechnicalTome.md`.

## Modding support

Dabdoob already contains mod/soundpack/tileset machinery. Lacapult should preserve that first.

v0 should investigate, not overpromise:
- where mod metadata comes from
- how compatibility is currently determined
- whether C-AOL v0.2.0 can safely reuse the inherited lists
- whether installed mods can be summarized for later NPC/LLM context

## Mod compatibility summary direction

A future C-AOL mod summary should be small, structured, and useful for both humans and NPC context.

Suggested shape:

```yaml
id: <mod id>
name: <display name>
source: <repo/url/local>
compatibility:
  caol_v0_2_0: supported | untested | broken | unknown
  notes: <short reason>
adds:
  factions: []
  monsters: []
  items: []
  professions: []
  locations: []
  mechanics: []
npc_context_summary: >
  One or two paragraphs explaining what NPCs/LLM context should know if this mod is installed.
risks:
  - <balance/lore/conflict issue>
```

v0 does not need runtime NPC consumption. It needs the metadata direction and the first compatibility investigation so later work has rails.

## Settings / UX details worth preserving

- Proxy/Auth_Token support for GitHub API rate limits should remain if inherited code already works.
- A failed release asset match should produce a clear status message, not an empty list with sad vibes.
- Debug log should not leak API keys or local secrets.
- The launcher should distinguish:
  - downloaded
  - extracted/installed
  - active
  - launchable
  - backend configured
  - backend verified
- Reinstall/update should offer backup when user data might be touched.

## Validation matrix

Minimum proof before calling a slice done:

### Release proof

- live GitHub data includes `v0.2.0`
- asset filter selects current-platform asset
- installer metadata includes `name`, `url`, `filename`, `published_at`, `has_any_assets`

### Install proof

- no huge download required for first metadata proof
- if an actual download/install is tested, record archive type and resulting executable discovery
- macOS DMG handling must be treated as separate from zip/tar extraction if inherited code does not support it

### Backend proof

- API: config path exists and secrets are not logged
- Ollama: command/server detection attempted or missing-tool blocker recorded
- OpenVINO: explicitly parked/stubbed

### Mod proof

- inherited mod-support entry points identified
- first compatibility-summary schema exists
- no accidental deletion/breakage of mod/soundpack/tileset tabs without intentional replacement

## Execution order for Andi

1. Release metadata: `v0.2.0` fetch/filter proof.
2. Identity: Lacapult/C-AOL visible naming and defaults.
3. Install path: existing installer receives valid C-AOL release metadata.
4. Backend: API + Ollama config/detection skeleton.
5. Mods: inherited support inventory + compatibility-summary note.
6. Godot/static proof packet.
7. Commit and handoff.

Do not reverse this order just because backend UI is more fun. First make it install the game. Then make it clever.
