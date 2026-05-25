#!/usr/bin/env python3
"""Static proof for the Windows-first C-AOL install/launch surface.

No downloads, installs, API calls, model pulls, or user-data mutation.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"Windows install/launch static proof failed: {message}")


def main() -> None:
    release_manager = (ROOT / "scripts" / "ReleaseManager.gd").read_text(encoding="utf-8")
    installer = (ROOT / "scripts" / "ReleaseInstaller.gd").read_text(encoding="utf-8")
    catapult = (ROOT / "scripts" / "Catapult.gd").read_text(encoding="utf-8")

    require('"caol-release-win"' in release_manager, "C-AOL Windows release filter is missing")
    require('"substring": "_windows.zip"' in release_manager, "Windows release filter does not select _windows.zip assets")
    require('"preferred_tags": ["v0.2.0"]' in release_manager, "v0.2.0 is not the preferred cross-platform release row")
    require("_order_release_builds_by_filter" in release_manager, "C-AOL release rows are not ordered through the installability-aware filter")
    require("ordered.append_array(installable)" in release_manager and "ordered.append_array(blocked)" in release_manager, "installable release rows are not ordered before blocked rows")

    require('"Cataclysm-AOL.exe"' in installer, "installer launchability guard does not recognize Cataclysm-AOL.exe")
    require('"cataclysm-tiles.exe"' in installer, "installer launchability guard lost inherited Windows tile executable")

    require("func _find_windows_executable" in catapult, "Windows launch path has no executable discovery helper")
    require('return ["Cataclysm-AOL.exe", "cataclysm-tiles.exe", "cataclysm.exe", "Cataclysm.exe"]' in catapult, "C-AOL Windows executable candidates are missing or reordered unexpectedly")
    require('item.to_lower().ends_with(".exe") and item.to_lower().find("cataclysm") >= 0' in catapult, "Windows launch path has no Cataclysm .exe fallback scan")
    require('var exe_info = _find_windows_executable(Paths.game_dir)' in catapult, "Windows launch branch does not use executable discovery")
    require('var game_exe_path = exe_info.get("path", "")' in catapult, "Windows command does not launch the discovered executable path")

    print("Windows install/launch static proof passed")
    print("  release list: v0.2.0 preferred; _windows.zip selected; installable rows precede blocked rows")
    print("  install guard: Cataclysm-AOL.exe and inherited cataclysm-tiles.exe are accepted")
    print("  launch path: Windows Play discovers the installed C-AOL executable instead of hardcoding one name")


if __name__ == "__main__":
    main()
