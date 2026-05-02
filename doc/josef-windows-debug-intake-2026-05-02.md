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
