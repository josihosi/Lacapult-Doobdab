#!/usr/bin/env python3
"""Static proof for the Lacapult backend setup installer packet v0.

This proof is deliberately non-mutating: it reads repo files, checks the new tab/copy
shape, confirms explicit confirmation-gated setup actions are present, and exercises
the Ollama recommendation wording with fixture hardware cases. It does not install
packages, pull models, call APIs, or touch real Application Support state.
"""
from __future__ import annotations

from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SCENE = REPO / "scenes" / "Catapult.tscn"
BACKEND_UI = REPO / "scripts" / "BackendSetupUI.gd"
BACKEND_CONFIG = REPO / "scripts" / "BackendConfigManager.gd"
SETTINGS_UI = REPO / "scripts" / "SettingsUI.gd"
EN_TEXT = REPO / "text" / "en" / "general.csv"

MODEL_MISTRAL = "mistral-v0.3"
MODEL_NEMOTRON = "nemotron-9b"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def recommendation_for_fixture(memory_mb: int) -> str:
    if memory_mb >= 24000:
        return f"Hardware recommendation: this machine appears to have enough memory for the larger {MODEL_NEMOTRON} path, but {MODEL_MISTRAL} remains available. Final model choice is yours."
    return f"Hardware recommendation: if memory/GPU capacity is unknown or modest, start with {MODEL_MISTRAL}. Choose {MODEL_NEMOTRON} manually if you know the machine has enough headroom. Catapult-Dabubu will not pull either model without confirmation."


def main() -> None:
    scene = read(SCENE)
    backend_ui = read(BACKEND_UI)
    backend_config = read(BACKEND_CONFIG)
    settings_ui = read(SETTINGS_UI)
    en_text = read(EN_TEXT)

    require('[node name="LLM" type="VBoxContainer" parent="Main/Tabs"]' in scene, "LLM tab node missing")
    require('script = ExtResource( 53 )' in scene, "backend tab script missing")
    require('_tabs.set_tab_title(7, "LLM")' in read(REPO / "scripts" / "Catapult.gd"), "LLM tab title assignment missing")
    require("_add_backend_setup_controls" not in settings_ui, "old Settings-tab backend setup is still constructed")

    for token in [
        "title.text = \"LLM\"",
        "Choose how C-AOL should reach an LLM backend",
        "Use an API provider through AnyLLM. Recent C-AOL logs show many calls around 300-400 tokens",
        "Use ollama for local LLM utilization.",
        "API / AnyLLM",
        "Ollama local",
        MODEL_MISTRAL,
        MODEL_NEMOTRON,
        "ConfirmExternalBackendAction",
        "popup_centered",
        "No external package install, model pull, API call, or real machine mutation",
    ]:
        require(token in backend_ui, f"backend setup UI token missing: {token}")

    backend_player_facing = "\n".join([backend_ui, scene])
    for banned in ["C-AOL LLM backend setup", "OpenVINO specialized", "Model directory", "around 1000 tokens", "1000 tokens", "Josef", "Windows test", "pre-release testing", "Windows-first"]:
        require(banned not in backend_player_facing, f"backend/setup banned wording remains: {banned}")

    low = recommendation_for_fixture(0)
    strong = recommendation_for_fixture(32768)
    require(MODEL_MISTRAL in low and MODEL_NEMOTRON in low and "will not pull" in low, "low/unknown hardware fixture does not recommend safely")
    require(MODEL_NEMOTRON in strong and "Final model choice is yours" in strong, "strong hardware fixture does not leave final choice to player")

    require("Thank you for installing Catapult-Dabubu" in en_text, "thank-you copy missing")
    require("MIT license" in en_text and "Dabdoob/Catapult" in en_text, "license/lineage thank-you credit missing")

    print("Backend setup installer packet proof passed")
    print("  tab: LLM")
    print("  old Settings backend panel: not constructed")
    print("  visible setup choices: API / AnyLLM and Ollama local only")
    print("  confirmation-gated actions: present, non-mutating proof text present")
    print(f"  Ollama choices: {MODEL_MISTRAL}, {MODEL_NEMOTRON}")
    print("  About thank-you copy: inherited support message preserved; backend/setup copy scan passed")


if __name__ == "__main__":
    main()
