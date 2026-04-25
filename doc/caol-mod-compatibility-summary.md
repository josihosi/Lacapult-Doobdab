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

`tools/prove_caol_mod_inventory.py` inspected the selected cached C-AOL `v0.2.0` macOS DMG read-only and compared it with Lacapult's inherited source paths. It now also writes a per-mod compatibility/summarizer bridge report under `.proof-cache/caol-mod-bridge/caol_mod_summarizer_bridge_report.{json,md}`. Current classification:

- **Stock packaged C-AOL mods: supported by path shape and present in v0.2.0.** The selected DMG exposes `Cataclysm.app/Contents/Resources/data/mods`; Lacapult's `Paths.mods_stock` already resolves macOS `.app` bundle data paths, and the proof found 42 non-obsolete stock mod IDs plus 7 obsolete IDs. Sample IDs include `dda`, `magiclysm`, `mindovermatter`, `no_hope`, `aftershock`, `DinoMod`, and `MMA`.
- **User-installed mods: mechanically supported, content compatibility unknown.** `Paths.mods_user` still points at the per-game userdata `mods` folder under the C-AOL app-support tree. The file/path mechanism survives, but Lacapult has not proven arbitrary user mod content against C-AOL.
- **Soundpacks/tilesets: packaged paths present.** The selected C-AOL app bundle has `data/sound` and `gfx`, and Lacapult's inherited path helpers still resolve app-bundle sound/gfx locations.
- **Custom downloadable mod catalogs: not C-AOL-proven.** `ModManager.refresh_available()` has explicit custom-download catalogs for `tlg`, `bn`, and `dda`, disables mods for `tish`/`eod`, and falls back to parsing `Paths.mod_repo` for any other game key. Since C-AOL uses `game = "caol"`, it currently has no explicit curated C-AOL download catalog. Treat inherited DDA/BN/TLG catalog entries as **untested for C-AOL**, not supported.
- **NPC/LLM mod summaries: C-AOL-native bridge, proof only.** C-AOL already merges core data, active mod roots, and world custom mods for background summaries, then reads `npcs/Backgrounds/Summaries_short` and `npcs/Backgrounds/Summaries_extra` in JSON or legacy text format. The report therefore points future generated packs at those roots instead of inventing a Lacapult-only metadata format.

Per-mod bridge result from the selected packaged `v0.2.0` DMG:

- 42 non-obsolete packaged stock mods are path-supported.
- 7 packaged mods are blocker-obsolete: `Graphical_Overmap`, `Rummaging`, `blazeindustries`, `desertpack`, `military_professions`, `ruralbiome`, and `test_data`.
- 0 packaged mods currently contain `Summaries_short` or `Summaries_extra`, so none are `summarizer-ready` yet.
- 30 packaged mods contain obvious NPC/faction/monster/item/location-ish JSON content and are classified `summarizer-compatible-but-needs-generated-pack`.
- 12 packaged mods are classified `no-summary-needed` for this bridge because they do not expose obvious NPC/context JSON content.
- No JSON parse errors or missing dependency blockers were found in the selected packaged mod set.

Current application step: Lacapult now surfaces this report in Settings as read-only compatibility/status information for packaged stock mods. A later apply flow can generate or install C-AOL-compatible summary packs into active mod roots, but this proof does not claim generated-pack application, mod enabling, or runtime NPC consumption.

## Report shape vs runtime summary shape

The Lacapult proof report may keep launcher-side inspection fields such as:

```yaml
id: <mod id>
name: <display name>
compatibility_status: stock-packaged-path-supported | user-installed-unknown | blocker-*
summarizer_bridge_status: summarizer-ready | summarizer-compatible-but-needs-generated-pack | no-summary-needed
adds_flags:
  npc: true|false
  faction: true|false
  monster: true|false
  item: true|false
  location: true|false
```

That is only report/status metadata. Any runtime NPC personality pack should use C-AOL's existing summary schema inside an active mod root, for example:

```json
{
  "type": "npc_personality_summary_bundle",
  "version": 1,
  "entries": [
    {
      "type": "npc_personality_summary",
      "selector": "name:<NPC name>",
      "your_background": "five-ish grounded descriptors",
      "your_expression": "one in-voice example line",
      "source_tag": "lacapult-generated:<mod id>"
    }
  ]
}
```

Preferred target path for named/context overrides is `<active_mod>/npcs/Backgrounds/Summaries_extra/*.json`; background-topic summaries may use `<active_mod>/npcs/Backgrounds/Summaries_short/*.json` or legacy text if needed.

## v0 rule

Do not promise automatic NPC/LLM consumption yet. The useful v0 behavior is to preserve inherited mod/soundpack/tileset support, make C-AOL compatibility status honest in the launcher, and keep future runtime summary packs compatible with C-AOL's existing loader.
