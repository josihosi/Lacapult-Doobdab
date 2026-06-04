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
    require("caol-cdda-master-2026-05-25-1954" not in release_manager, "stale C-AOL preferred release pin is still present")
    require('"preferred_tags"' not in release_manager.split('"caol-release-linux"')[1].split('"caol-release": []')[0], "C-AOL release filters still use preferred_tags")
    require("_order_release_builds_by_filter" in release_manager, "C-AOL release rows are not ordered through the installability-aware filter")
    require("ordered.append_array(installable)" in release_manager and "ordered.append_array(blocked)" in release_manager, "installable release rows are not ordered before blocked rows")

    require('"Cataclysm-AOL.exe"' in installer, "installer launchability guard does not recognize Cataclysm-AOL.exe")
    require('"cataclysm-tiles.exe"' in installer, "installer launchability guard lost inherited Windows tile executable")
    require('"zzip.exe" if OS.get_name() == "Windows" else "zzip"' in installer, "installer preflight does not require the platform zzip helper")
    require("manual.mixed_hostile_siege_mcw" in installer and "manual.zombie_rider_open_field_mcw" in installer, "installer preflight does not require all manual scenarios")

    require("func _find_windows_executable" in catapult, "Windows launch path has no executable discovery helper")
    require('return ["Cataclysm-AOL.exe", "cataclysm-tiles.exe", "cataclysm.exe", "Cataclysm.exe"]' in catapult, "C-AOL Windows executable candidates are missing or reordered unexpectedly")
    require('item.to_lower().ends_with(".exe") and item.to_lower().find("cataclysm") >= 0' in catapult, "Windows launch path has no Cataclysm .exe fallback scan")
    require('var exe_info = _find_windows_executable(Paths.game_dir)' in catapult, "Windows launch branch does not use executable discovery")
    require('var game_exe_path = exe_info.get("path", "")' in catapult, "Windows command does not launch the discovered executable path")

    print("Windows install/launch static proof passed")
    print("  release list: latest valid C-AOL release selected; stale preferred tag removed; _windows.zip selected")
    print("  install guard: Cataclysm-AOL.exe and inherited cataclysm-tiles.exe are accepted; zzip.exe and manual scenarios are preflighted")
    print("  launch path: Windows Play discovers the installed C-AOL executable instead of hardcoding one name")


if __name__ == "__main__":
    main()
