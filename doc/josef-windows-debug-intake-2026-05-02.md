# Josef Windows retest intake — Catapult-Dabubu launcher — 2026-05-02

Source: Josef Discord retest note plus screenshot.

Screenshot: `/Users/josefhorvath/.openclaw/media/inbound/2fc7eceb-c09c-4588-ae3b-dc77c74eed34.png`.

## Raw report

Josef tested the current Catapult-Dabubu launcher and reported:

- API / LLM setup does not install AnyLLM packages with venv creation.
- Product question: what should an installer do? It should install the software needed to run the game/setup path. Current state does not fulfill the vision.
- Background/helper text is still too much and makes the screen too full.
- Readiness/status lights do not work; likely Unicode rendering problem on Windows.
- Desired replacement: use plain colored dots with font color red/green instead of fragile Unicode status-light glyphs.

## Schani classification

This is not cosmetic-only. It is a product-vision failure in three linked seams:

1. **Installer semantics:** API/LLM setup must install the required AnyLLM packages or present a single obvious action that does so. Creating an empty venv while the launcher still cannot run the API backend fails the installer promise.
2. **Information density:** setup screens still read like background documentation instead of an appliance. Reduce explanatory copy; surface status/action first.
3. **Status indicator rendering:** Unicode status lights are not safe enough on Windows. Replace them with robust colored text/dots, likely Godot RichTextLabel/Label font color or theme-colored bullet/circle fallback rather than emoji/Unicode traffic lights.

## Required follow-up shape

- Treat this as a fresh Windows retest failure after the 2026-05-01 test release.
- Do not close from macOS-only UI smoke.
- Do not call this fixed until Josef sees a Windows build where:
  - API setup creates/uses a venv and installs AnyLLM/provider deps through an obvious installer action;
  - status dots render as colored red/green/yellow dots or equivalent reliable colored labels;
  - background/helper text is substantially reduced;
  - the launcher feels like it installs the software needed to run the game/backend, not like it points at chores.

## 2026-05-02 02:25-02:29 — Additional Windows retest notes during v1 implementation

Ollama-specific follow-up:
- Hardware guidance must be a real hardware check, not a recommendation paragraph. Check measured RAM and VRAM, then draw runnability conclusions from those values.
- Readiness lights also fail on the Ollama page; apply the same Windows-safe colored-dot/label repair there.
- Command descriptions in backend setup menus should be shown as CLI-input-style text boxes, not loose prose.
- Ollama install/model download may appear to time out or wait while external install/download work continues; warn explicitly if this cannot be avoided cleanly.
- Investigate install + model pull sequencing. Do not unsafe-chain installer and pull; separate/serialize and require a Check when Ollama has just installed or is still starting.
- Josef prefers big colored dots where possible, including hardware check. Green/yellow/red are acceptable for hardware-check indicators when explicitly rendered by font/theme color, not emoji.

Mods / summarizer follow-up:
- The mods view label `Show Stock` is confusing. If this is mod discovery/summarizer inventory, label it plainly.
- Screenshot path for visual review: `/Users/josefhorvath/.openclaw/media/inbound/4e8d8209-6430-4ee4-a482-aa4cae3953d2.png`. Current subagent image tooling could not inspect it; preserve bottom-cutoff/button visibility as a Windows visual check item.

## 2026-05-02 02:36 — Live Windows log evidence

Exact visible status/log lines Josef provided:

```text
Install AnyLLM packages separately when using API mode.
[02:26:20.474] Pull the selected model after confirmation. failed after confirmation (exit 1): ollama pull mistral-v0.3. Installer/CLI/server/model-pull state is reported separately; use Check after fixing the failed step.
[02:28:13.919] C-AOL Summarizer dry-run/status-only check complete; no backend call, pack apply, or save mutation was attempted.
[02:28:16.272] C-AOL Summarizer dry-run/status-only check complete; no backend call, pack apply, or save mutation was attempted.
[02:35:04.769] Pull the selected model after confirmation. failed after confirmation (exit 1): ollama pull mistral-v0.3. Installer/CLI/server/model-pull state is reported separately; use Check after fixing the failed step
```

Interpretation:
- API setup still exposed AnyLLM install as a separate chore; v1 must replace this with one obvious API setup action that creates/uses the venv and installs AnyLLM/provider packages.
- Ollama pull failure is technically separated but not actionable enough; v1 should add likely-cause/next-step guidance, serialized install/server/model-pull behavior, and timeout/wait warning.
- Summarizer dry-run is safe/no-mutation, but repeated identical status posts are noisy; suppress or distinguish duplicate identical dry-run status spam and keep the result area clear.

## 2026-05-02 02:35 — Mods stock checkbox implementation finding

`show_stock_mods` defaults to false in `scripts/settings_manager.gd`. `scripts/ModsUI.gd::reload_installed()` only shows status-2 stock mods when that setting is true and counts them hidden otherwise. `scripts/ModManager.gd::refresh_installed()` parses user mods from `Paths.mods_user`, parses built-in packaged mods from `Paths.mods_stock`, sets `is_stock=true`, and stock mods cannot be deleted. Therefore the checkbox means: include C-AOL built-in packaged mods from `data/mods` in the installed/mod inventory/summarizer list. English label is now `Show built-in game mods`; tooltip is `Include C-AOL built-in mods from data/mods in this mod inventory and summarizer list.`

## 2026-05-02 02:37 — Additional Windows retest note: Mods tab / overcrowding / window chrome

Screenshot path: `/Users/josefhorvath/.openclaw/media/inbound/101b208a-5f4f-40d3-a033-9fe02fb43fb0.png`.

Josef reports:
- Mod tab shows no mods under `Downloadable`.
- He does not see how to actually create summaries. The Mods page shows dry-run/status-only, but the creation/apply path is not discoverable or maybe not implemented in this slice; UI must say plainly which it is.
- Top tab/top bar still is not rendered right.
- General diagnosis: overcrowding. Consider a bigger app window, resizable cursor/native resizing, or autofit as a shared layout fix instead of tiny text patches.

Implementation interpretation for v1:
- `Downloadable` is the optional downloadable add-on catalog, not the main source for built-in/user/world mod inventory or Summarizer status. If empty for C-AOL, say that directly.
- Mods page should say status-only/no-create-here; creation/apply path belongs in Settings > C-AOL packaged mod compatibility / Summary creation unless moved later.
- Shared layout fix should enlarge the default/test window and prefer native resizable window behavior over the brittle custom borderless top bar.
