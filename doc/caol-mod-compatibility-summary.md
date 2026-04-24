# C-AOL mod compatibility / NPC-summary investigation

Status: first bounded investigation note for the v0.2.0 installer/backend slice.

## Inherited entry points preserved

Lacapult still inherits Dabdoob's content-management code paths:

- Mods: `scripts/ModManager.gd` + `scripts/ModsUI.gd`
- Soundpacks: `scripts/SoundpackManager.gd` + `scripts/SoundpacksUI.gd`
- Tilesets: `scripts/TilesetManager.gd` + `scripts/TilesetsUI.gd`
- Install/user paths: `scripts/path_helper.gd`

The v0 C-AOL-first changes should hide/limit game choice rather than deleting these systems. Compatibility is therefore an investigation layer, not a rewrite.

## Current compatibility risk

Inherited mod lists were assembled for DDA/BN/TLG/EOD/TISH assumptions. C-AOL `v0.2.0` may accept some of them, but Lacapult should mark them `untested` until a mod is actually checked against a C-AOL install.

## Proposed summary shape

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
  One or two paragraphs explaining what NPC/LLM context should know if this mod is installed.
risks:
  - <balance/lore/conflict issue>
```

## v0 rule

Do not promise automatic NPC/LLM consumption yet. The useful v0 behavior is to preserve inherited mod/soundpack/tileset support, make C-AOL compatibility status honest, and keep metadata ready for a future NPC context layer.
