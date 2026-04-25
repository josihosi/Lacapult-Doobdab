#!/usr/bin/env python3
"""Inspect inherited Lacapult mod support against a C-AOL v0.2.0 macOS DMG.

The proof is deliberately read-only:
- uses an already cached DMG unless --download is explicitly added later
- mounts read-only/no-browse
- records stock packaged mod IDs from the C-AOL app bundle data tree
- records Lacapult's inherited user-mod and custom-catalog assumptions by static inspection
"""

from __future__ import annotations

import argparse
import json
import plistlib
import re
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DMG = ROOT / ".proof-cache" / "caol-dmg" / "caol_cdda-0-h_2026-03-29-1556_macos.dmg"


def run(cmd: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)


def load_jsonish(path: Path) -> Any:
    text = path.read_text(errors="replace")
    # C-AOL modinfo files are JSON enough for Python's parser in the release assets inspected here.
    return json.loads(text)


def iter_modinfo_files(mods_dir: Path) -> list[Path]:
    return sorted(mods_dir.glob("*/modinfo.json"))


def mod_records(mods_dir: Path) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for modinfo in iter_modinfo_files(mods_dir):
        try:
            data = load_jsonish(modinfo)
        except Exception as exc:  # noqa: BLE001 - proof should report parse failures, not hide them
            records.append({"dir": modinfo.parent.name, "parse_error": str(exc)})
            continue
        entries = data if isinstance(data, list) else [data]
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            if entry.get("type") not in (None, "MOD_INFO"):
                continue
            records.append(
                {
                    "dir": modinfo.parent.name,
                    "id": entry.get("id") or entry.get("ident"),
                    "name": entry.get("name"),
                    "category": entry.get("category"),
                    "obsolete": bool(entry.get("obsolete", False)),
                    "dependencies": entry.get("dependencies", []),
                }
            )
    return records


def find_app_bundle(mount_point: Path) -> Path:
    apps = sorted(mount_point.glob("*.app"))
    if not apps:
        raise RuntimeError(f"no top-level .app bundle found in {mount_point}")
    return apps[0]


def inspect_lacapult_sources() -> dict[str, Any]:
    path_helper = (ROOT / "scripts" / "path_helper.gd").read_text()
    mod_manager = (ROOT / "scripts" / "ModManager.gd").read_text()
    explicit_catalogs = sorted(set(re.findall(r'Settings\.read\("game"\) == "([^"]+)"', mod_manager)))
    return {
        "mods_stock_uses_app_bundle_data": "_get_app_bundle_data_path" in path_helper,
        "mods_user_shape": "_get_userdata_dir().plus_file(\"mods\")" in path_helper,
        "mod_repo_shape": "plus_file(\"mod_repo\")" in path_helper,
        "explicit_custom_catalog_game_keys": explicit_catalogs,
        "caol_has_explicit_custom_catalog": "caol" in explicit_catalogs,
        "caol_available_mod_strategy": "fallback_to_paths_mod_repo" if "parse_mods_dir(Paths.mod_repo)" in mod_manager else "unknown",
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dmg", type=Path, default=DEFAULT_DMG)
    args = parser.parse_args()

    if sys.platform != "darwin":
        print("This proof currently inspects the macOS DMG/app-bundle shape and must run on macOS.", file=sys.stderr)
        return 2
    if not args.dmg.exists():
        print(f"Missing cached DMG: {args.dmg}", file=sys.stderr)
        return 2

    attach = run(["hdiutil", "attach", "-readonly", "-nobrowse", "-plist", str(args.dmg)])
    if attach.returncode != 0:
        print(attach.stdout)
        print(attach.stderr, file=sys.stderr)
        return attach.returncode

    mount_point: Path | None = None
    try:
        plist = plistlib.loads(attach.stdout.encode())
        for entity in plist.get("system-entities", []):
            if "mount-point" in entity:
                mount_point = Path(entity["mount-point"])
                break
        if mount_point is None:
            raise RuntimeError("hdiutil attach did not report a mount point")

        app_bundle = find_app_bundle(mount_point)
        data_dir = app_bundle / "Contents" / "Resources" / "data"
        mods_dir = data_dir / "mods"
        sound_dir = data_dir / "sound"
        gfx_dir = app_bundle / "Contents" / "Resources" / "gfx"
        records = mod_records(mods_dir)
        stock_ids = sorted(r.get("id") for r in records if r.get("id") and not r.get("obsolete"))
        obsolete_ids = sorted(r.get("id") for r in records if r.get("id") and r.get("obsolete"))
        result = {
            "dmg": str(args.dmg),
            "mount_point": str(mount_point),
            "app_bundle": app_bundle.name,
            "stock_mods_path": str(mods_dir),
            "stock_mod_count": len(stock_ids),
            "obsolete_stock_mod_count": len(obsolete_ids),
            "stock_mod_ids_sample": stock_ids[:30],
            "obsolete_stock_mod_ids_sample": obsolete_ids[:20],
            "soundpack_dir_exists": sound_dir.exists(),
            "tileset_gfx_dir_exists": gfx_dir.exists(),
            "lacapult_source_assumptions": inspect_lacapult_sources(),
            "classification": {
                "stock_packaged_caol_mods": "supported_by_path_shape_and_present_in_v0_2_0_dmg",
                "user_installed_mods": "mechanically_supported_by_inherited_userdata_mods_path_content_compatibility_unknown",
                "custom_download_catalogs_for_caol": "unknown_or_empty_until_caol_mod_repo_is_populated",
                "inherited_dda_bn_tlg_catalogs": "untested_for_caol",
                "future_npc_llm_mod_summaries": "metadata_direction_only_not_runtime_integrated",
            },
        }
        print(json.dumps(result, indent=2, sort_keys=True))
        if len(stock_ids) == 0:
            print("No stock C-AOL mod IDs found", file=sys.stderr)
            return 1
        if not result["lacapult_source_assumptions"]["mods_stock_uses_app_bundle_data"]:
            print("Lacapult stock mod path does not use app-bundle data path", file=sys.stderr)
            return 1
        return 0
    finally:
        if mount_point is not None:
            detach = run(["hdiutil", "detach", str(mount_point)])
            if detach.returncode != 0:
                print(detach.stdout)
                print(detach.stderr, file=sys.stderr)


if __name__ == "__main__":
    raise SystemExit(main())
