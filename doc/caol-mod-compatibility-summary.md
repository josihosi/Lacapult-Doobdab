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

## Current inherited-source inventory - 2026-04-25

`tools/prove_caol_mod_inventory.py` inspected the selected cached C-AOL `v0.2.0` macOS DMG read-only and compared it with Lacapult's inherited source paths. Current classification:

- **Stock packaged C-AOL mods: supported by path shape and present in v0.2.0.** The selected DMG exposes `Cataclysm.app/Contents/Resources/data/mods`; Lacapult's `Paths.mods_stock` already resolves macOS `.app` bundle data paths, and the proof found 42 non-obsolete stock mod IDs plus 7 obsolete IDs. Sample IDs include `dda`, `magiclysm`, `mindovermatter`, `no_hope`, `aftershock`, `DinoMod`, and `MMA`.
- **User-installed mods: mechanically supported, content compatibility unknown.** `Paths.mods_user` still points at the per-game userdata `mods` folder under the C-AOL app-support tree. The file/path mechanism survives, but Lacapult has not proven arbitrary user mod content against C-AOL.
- **Soundpacks/tilesets: packaged paths present.** The selected C-AOL app bundle has `data/sound` and `gfx`, and Lacapult's inherited path helpers still resolve app-bundle sound/gfx locations.
- **Custom downloadable mod catalogs: not C-AOL-proven.** `ModManager.refresh_available()` has explicit custom-download catalogs for `tlg`, `bn`, and `dda`, disables mods for `tish`/`eod`, and falls back to parsing `Paths.mod_repo` for any other game key. Since C-AOL uses `game = "caol"`, it currently has no explicit curated C-AOL download catalog. Treat inherited DDA/BN/TLG catalog entries as **untested for C-AOL**, not supported.
- **NPC/LLM mod summaries: metadata direction only.** The useful future shape is to summarize installed/selected mod metadata for NPC context later; v0 does not integrate that runtime path.

Next smallest proof: run the inventory helper through Andi after any install-path changes and, if a C-AOL `mod_repo` source is added later, classify each downloadable entry as supported/untested/broken/unknown against the selected C-AOL release.

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
