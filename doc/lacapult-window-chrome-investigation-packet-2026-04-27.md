# Lacapult window chrome investigation packet (2026-04-27)

Status: local implementation boundary complete / Windows-Josef confirmation pending.

## Active item

Package 5 from `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md`: investigate the oversized/messed-up close/minimize/top-bar controls without widening into a launcher-frame redesign.

## Local root-cause class

Local/project evidence says the controls are Godot custom scene chrome, not native OS chrome:

- `project.godot` sets `display/window/size/borderless=true`.
- `scenes/Catapult.tscn` instances `scenes/CustomTitleBar.tscn` at `TitleBar`.
- `scenes/CustomTitleBar.tscn` owns the visible `MinimizeButton`, `MaximizeButton`, and `CloseButton` TextureButtons.

## Smallest-seam patch already landed

The local patch tightened only the custom-titlebar metrics and matching main content offset:

- titlebar height: `32px -> 28px`
- `Main.margin_top`: `36px -> 32px`
- app icon: `24x24 -> 20x20`
- close/min/max buttons: `32x24 -> 28x20`
- vertical titlebar margins: `4px -> 2px`

No native-window setting, release packaging, or wider frame redesign was changed.

## Evidence

Local Godot smoke:

```sh
HOME=$(mktemp -d /tmp/lacapult-window-chrome-home.XXXXXX) godot --path . --no-window -s tools/godot_window_chrome_inspection.gd
```

Current output boundary:

- root-cause class: custom scene chrome, not native OS chrome;
- project settings: `borderless=True`, `allow_hidpi=True`, `theme_hidpi=True`;
- metric seam changed from the old 32/36/24/32x24/4px baseline to the new 28/32/20/28x20/2px seam;
- proof is macOS/Godot scene inspection only.

Static scan:

```sh
rg -n "window/size/borderless|CustomTitleBar|MinimizeButton|MaximizeButton|CloseButton|OS.window|allow_hidpi|use_hidpi" project.godot scenes scripts
```

## Windows/Josef confirmation checklist

Before claiming the chrome issue is fixed cross-platform, Josef or a Windows automation path should open the latest debug-stack build/state and confirm:

1. Does the titlebar still look oversized, clipped, blurry, or misaligned on Windows?
2. Are the close/minimize/maximize buttons visually smaller and less intrusive than the quarantined 2026-04-26 build?
3. Does the first window still look like a Lacapult launcher rather than a C-AOL game archive?
4. If possible, provide one screenshot of the top 80-120px of the first Lacapult window.

## Remaining state

Package 5 is locally implemented and proofed, with a bounded external confirmation requirement. No further Alex-side unblocked debug-stack package remains unless Windows evidence shows the custom-titlebar seam is still wrong.

## Hollow-rock suspicion

A metric-only patch may not solve Josef's actual Windows complaint if Windows DPI/export scaling, texture assets, or the entire borderless custom-frame choice is the real irritant. The local smoke proves ownership and changed metrics, not taste or Windows appearance.
