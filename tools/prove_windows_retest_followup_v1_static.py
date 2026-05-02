#!/usr/bin/env python3
"""Static proof for Catapult-Dabubu Windows retest follow-up v1.

No installs, model pulls, API calls, secrets, or user-data mutation.
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"static v1 proof failed: {message}")


def main() -> None:
    backend_ui = (ROOT / "scripts" / "BackendSetupUI.gd").read_text(encoding="utf-8")
    backend_config = (ROOT / "scripts" / "BackendConfigManager.gd").read_text(encoding="utf-8")
    mods_en = (ROOT / "text" / "en" / "mods_tab.csv").read_text(encoding="utf-8")

    old_lights = ["🟢", "🟡", "🔴", "🚦"]
    visible_source = backend_ui + "\n" + backend_config
    require(not any(light in visible_source for light in old_lights), "emoji/traffic-light glyphs remain in backend setup source")
    require('dot.text = "●"' in backend_ui, "big colored dot label is not constructed")
    require('add_color_override("font_color"' in backend_ui, "status dots do not carry explicit font color")
    require('set_meta("status_state"' in backend_ui, "status rows do not expose explicit state metadata")
    require("Set up API / AnyLLM" in backend_ui, "one obvious API setup action label missing")
    require("create_or_update_venv" in backend_config and "install_anyllm_packages" in backend_config, "API setup plan lacks venv/package phases")
    require("run_api_setup" in backend_config and "for step in plan.get(\"commands\", [])" in backend_config, "API setup does not execute serialized phase plan")
    require("get_ollama_hardware_check" in backend_config and "Win32_VideoController" in backend_config and "Win32_ComputerSystem" in backend_config, "Ollama hardware check does not inspect Windows RAM/VRAM")
    require("serialized_steps_not_shell_chained" in backend_config, "Ollama plan does not declare serialized sequencing")
    require('"pull"' in backend_config and 'inventory.get("server", "unreachable") == "running"' in backend_config, "Ollama pull is not gated on server readiness")
    require("launcher may appear to wait" in backend_ui and "model download can take several minutes" in backend_config, "Ollama timeout/wait warning missing")
    require("Show built-in game mods" in mods_en, "Mods checkbox still uses unclear Show Stock label")
    require("mod inventory and summarizer list" in mods_en, "Mods stock tooltip does not mention inventory/summarizer plainly")
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    scene = (ROOT / "scenes" / "Catapult.tscn").read_text(encoding="utf-8")
    mods_ui = (ROOT / "scripts" / "ModsUI.gd").read_text(encoding="utf-8")
    settings_ui = (ROOT / "scripts" / "SettingsUI.gd").read_text(encoding="utf-8")
    require("window/size/width=1040" in project and "window/size/height=900" in project, "window was not enlarged for overcrowding")
    require("window/size/resizable=true" in project and "window/size/borderless=false" in project, "window is not native/resizable")
    require("[node name=\"TitleBar\"" in scene and "visible = false" in scene and "margin_top = 4.0" in scene, "custom top bar was not hidden/reclaimed")
    require("Downloadable add-on mods" in mods_ui and "No downloadable add-on catalog entries" in mods_ui, "C-AOL downloadable empty-state is not explicit")
    require("Summarizer status (no create here)" in mods_ui and "Summary creation" in settings_ui, "Summarizer create/apply path is not discoverable/plain")
    require("same no-mutation status as previous check" in mods_ui and "same no-mutation status as previous check" in settings_ui, "duplicate dry-run status refresh handling missing")
    require("300-400 tokens" not in backend_ui and "Use an API provider through AnyLLM" not in backend_ui, "old verbose API helper copy remains visible")

    print("Windows retest follow-up v1 static proof passed")
    print("  no emoji traffic-light source in backend setup")
    print("  API setup has venv + AnyLLM phases and proof-safe intent shape")
    print("  Ollama has RAM/VRAM hardware check, serialized setup, timeout warning")
    print("  Mods label says built-in game mods, not Show Stock")
    print("  window is larger/native/resizable; custom titlebar hidden")
    print("  C-AOL Downloadable empty-state and Summarizer create/apply path are explicit")


if __name__ == "__main__":
    main()
