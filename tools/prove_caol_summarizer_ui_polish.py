#!/usr/bin/env python3
"""Static proof for Slice 6 C-AOL Summarizer UI/error polish.

This proof is deliberately non-mutating: it checks that the Settings surface lets
the player choose an eligible contextual mod before preview/confirmed generation,
and that the confirm path passes that chosen id into the sandbox-proven backend
and apply seam. It does not call a backend or touch Application Support state.
"""
from __future__ import annotations

from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SETTINGS_UI = REPO / "scripts" / "SettingsUI.gd"
MOD_MANAGER = REPO / "scripts" / "ModManager.gd"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    settings_ui = SETTINGS_UI.read_text(encoding="utf-8")
    mod_manager = MOD_MANAGER.read_text(encoding="utf-8")

    for token in [
        "var _caol_summarizer_world_select: OptionButton",
        "var _caol_summarizer_world_names := []",
        "var _caol_summarizer_mod_select: OptionButton",
        "var _caol_summarizer_selected_mod_ids := []",
        "Summarizer target world",
        "Summarizer target mod",
        "Choose one enabled contextual mod from the current world",
        "get_caol_summarizer_world_names",
        "_populate_caol_summarizer_target_selector(overview)",
        "overview.get(\"summarizer_candidates\", [])",
        "No eligible enabled contextual mod needs summaries",
        "func _selected_caol_summarizer_world_name() -> String:",
        "func _selected_caol_summarizer_mod_id() -> String:",
        "get_caol_summarizer_apply_preview(selected_world, selected_mod_id)",
        "generate_and_apply_caol_summarizer_pack(selected_world, selected_mod_id, true, true)",
    ]:
        require(token in settings_ui, f"Settings Summarizer UI token missing: {token}")

    require("func get_caol_summarizer_world_names() -> Array:" in mod_manager, "world chooser source helper missing")
    require("mods.json" in mod_manager, "world chooser does not check world mods.json")
    require("allow_backend_call := false" in mod_manager, "backend-call confirmation gate missing")
    require("a separate explicit backend-call confirmation is required" in mod_manager, "backend-call blocked message missing")
    require("preview did not pass confirmation/backend/world gates" in mod_manager, "confirmed apply gate message missing")

    print("C-AOL Summarizer UI polish proof passed")
    print("  Settings surface has selectable target world and eligible contextual mod controls")
    print("  Preview and confirmed generation/apply pass the chosen world and mod id")
    print("  Existing backend-call and write confirmations remain gated")


if __name__ == "__main__":
    main()
