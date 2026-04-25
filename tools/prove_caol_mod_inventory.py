#!/usr/bin/env python3
"""Inspect inherited Lacapult mod support against a C-AOL v0.2.0 macOS DMG.

The proof is deliberately read-only:
- uses an already cached DMG
- mounts read-only/no-browse
- records packaged stock mod metadata from the C-AOL app bundle data tree
- emits a per-mod compatibility/summarizer bridge report into .proof-cache/
- records Lacapult's inherited user-mod and custom-catalog assumptions by static inspection

The summarizer bridge intentionally follows C-AOL's runtime summary roots:
active mod roots can provide npcs/Backgrounds/Summaries_short and/or
npcs/Backgrounds/Summaries_extra with the same text/JSON schema C-AOL already loads.
"""

from __future__ import annotations

import argparse
import json
import plistlib
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DMG = ROOT / ".proof-cache" / "caol-dmg" / "caol_cdda-0-h_2026-03-29-1556_macos.dmg"
DEFAULT_REPORT_DIR = ROOT / ".proof-cache" / "caol-mod-bridge"

SUMMARY_SHORT_REL = Path("npcs") / "Backgrounds" / "Summaries_short"
SUMMARY_EXTRA_REL = Path("npcs") / "Backgrounds" / "Summaries_extra"
SUMMARY_REGISTRY_REL = Path("npcs") / "Backgrounds" / "summary_registry.json"

NPC_TYPES = {
    "npc",
    "npc_class",
    "npc_template",
    "talk_topic",
    "mission_definition",
    "npc_personality_summary",
    "npc_personality_summary_bundle",
}
FACTION_TYPES = {"faction", "faction_template"}
MONSTER_TYPES = {"MONSTER", "monster", "monstergroup", "SPECIES", "monster_attack"}
ITEM_TYPES = {
    "AMMO",
    "ARMOR",
    "BIONIC_ITEM",
    "BOOK",
    "COMESTIBLE",
    "ENGINE",
    "GENERIC",
    "GUN",
    "GUNMOD",
    "ITEM_CATEGORY",
    "MAGAZINE",
    "PET_ARMOR",
    "TOOL",
    "TOOL_ARMOR",
    "WHEEL",
    "json_flag",
    "vehicle_part",
}
LOCATION_TYPES = {
    "city_building",
    "furniture",
    "map_extra",
    "mapgen",
    "overmap_special",
    "overmap_terrain",
    "palette",
    "region_settings",
    "terrain",
    "trap",
}
MECHANIC_TYPES = {
    "achievement",
    "effect_on_condition",
    "event_transformation",
    "field_type",
    "harvest",
    "martial_art",
    "mutation",
    "profession",
    "recipe",
    "recipe_category",
    "scenario",
    "skill",
    "snippet",
    "speech",
    "technique",
    "vehicle",
}
CONTEXTUAL_TYPE_GROUPS = {
    "npc": NPC_TYPES,
    "faction": FACTION_TYPES,
    "monster": MONSTER_TYPES,
    "item": ITEM_TYPES,
    "location": LOCATION_TYPES,
}


def run(cmd: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)


def load_jsonish(path: Path) -> Any:
    text = path.read_text(encoding="utf-8", errors="replace")
    return json.loads(text)


def json_records(data: Any) -> list[dict[str, Any]]:
    if isinstance(data, list):
        return [entry for entry in data if isinstance(entry, dict)]
    if isinstance(data, dict):
        if isinstance(data.get("entries"), list):
            return [entry for entry in data["entries"] if isinstance(entry, dict)]
        return [data]
    return []


def iter_modinfo_files(mods_dir: Path) -> list[Path]:
    return sorted(mods_dir.glob("*/modinfo.json"))


def normalized_dependencies(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []
    return sorted(str(dep) for dep in value if isinstance(dep, (str, int, float)))


def relative_path(path: Path, base: Path) -> str:
    try:
        return path.relative_to(base).as_posix()
    except ValueError:
        return path.as_posix()


def mod_records(mods_dir: Path) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for modinfo in iter_modinfo_files(mods_dir):
        try:
            data = load_jsonish(modinfo)
        except Exception as exc:  # noqa: BLE001 - proof should report parse failures, not hide them
            records.append(
                {
                    "dir": modinfo.parent.name,
                    "id": None,
                    "name": None,
                    "obsolete": False,
                    "dependencies": [],
                    "packaged_path_present": modinfo.parent.exists(),
                    "modinfo_present": modinfo.exists(),
                    "parse_error": str(exc),
                }
            )
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
                    "dependencies": normalized_dependencies(entry.get("dependencies", [])),
                    "packaged_path_present": modinfo.parent.exists(),
                    "modinfo_present": modinfo.exists(),
                }
            )
    return records


def find_app_bundle(mount_point: Path) -> Path:
    apps = sorted(mount_point.glob("*.app"))
    if not apps:
        raise RuntimeError(f"no top-level .app bundle found in {mount_point}")
    return apps[0]


def inspect_lacapult_sources() -> dict[str, Any]:
    path_helper = (ROOT / "scripts" / "path_helper.gd").read_text(encoding="utf-8")
    mod_manager = (ROOT / "scripts" / "ModManager.gd").read_text(encoding="utf-8")
    explicit_catalogs = sorted(set(re.findall(r'Settings\.read\("game"\) == "([^"]+)"', mod_manager)))
    return {
        "mods_stock_uses_app_bundle_data": "_get_app_bundle_data_path" in path_helper,
        "mods_user_shape": "_get_userdata_dir().plus_file(\"mods\")" in path_helper,
        "mod_repo_shape": "plus_file(\"mod_repo\")" in path_helper,
        "explicit_custom_catalog_game_keys": explicit_catalogs,
        "caol_has_explicit_custom_catalog": "caol" in explicit_catalogs,
        "caol_available_mod_strategy": "fallback_to_paths_mod_repo" if "parse_mods_dir(Paths.mod_repo)" in mod_manager else "unknown",
    }


def scan_summary_roots(mod_dir: Path) -> dict[str, Any]:
    short_dir = mod_dir / SUMMARY_SHORT_REL
    extra_dir = mod_dir / SUMMARY_EXTRA_REL
    registry = mod_dir / SUMMARY_REGISTRY_REL
    summary_files = sorted(
        [path for root in (short_dir, extra_dir) if root.exists() for path in root.rglob("*") if path.is_file()]
    )
    return {
        "summaries_short_exists": short_dir.exists(),
        "summaries_extra_exists": extra_dir.exists(),
        "summary_registry_exists": registry.exists(),
        "summary_file_count": len(summary_files),
        "summary_json_count": len([path for path in summary_files if path.suffix == ".json"]),
        "summary_txt_count": len([path for path in summary_files if path.suffix == ".txt"]),
        "summary_file_samples": [relative_path(path, mod_dir) for path in summary_files[:12]],
    }


def scan_json_content(mod_dir: Path) -> dict[str, Any]:
    type_counts: Counter[str] = Counter()
    parse_errors: list[str] = []
    parsed_files = 0
    json_files = sorted(mod_dir.rglob("*.json")) if mod_dir.exists() else []
    for path in json_files:
        try:
            data = load_jsonish(path)
        except Exception as exc:  # noqa: BLE001 - bad mod JSON is a compatibility fact
            parse_errors.append(f"{relative_path(path, mod_dir)}: {exc}")
            continue
        parsed_files += 1
        for record in json_records(data):
            record_type = record.get("type")
            if isinstance(record_type, str) and record_type:
                type_counts[record_type] += 1
    flags: dict[str, bool] = {}
    for group_name, record_types in CONTEXTUAL_TYPE_GROUPS.items():
        flags[group_name] = any(type_counts.get(record_type, 0) > 0 for record_type in record_types)
    flags["mechanic"] = any(type_counts.get(record_type, 0) > 0 for record_type in MECHANIC_TYPES)
    return {
        "json_file_count": len(json_files),
        "json_files_parsed": parsed_files,
        "json_parse_error_count": len(parse_errors),
        "json_parse_errors_sample": parse_errors[:8],
        "type_counts_sample": dict(type_counts.most_common(24)),
        "content_flags": flags,
    }


def classify_mod(record: dict[str, Any], mod_dir: Path, all_mod_ids: set[str], summary: dict[str, Any], content: dict[str, Any]) -> dict[str, Any]:
    dependencies = record.get("dependencies", [])
    missing_deps = [dep for dep in dependencies if dep and dep not in all_mod_ids]
    has_summaries = summary["summaries_short_exists"] or summary["summaries_extra_exists"] or summary["summary_file_count"] > 0
    flags = content["content_flags"]
    has_contextual_content = any(flags.get(name, False) for name in ("npc", "faction", "monster", "item", "location"))
    if record.get("parse_error"):
        status = "blocker-bad-metadata"
        reason = f"modinfo.json failed to parse: {record['parse_error']}"
    elif not record.get("packaged_path_present") or not record.get("modinfo_present"):
        status = "blocker-missing-packaged-path"
        reason = "packaged mod directory or modinfo.json is missing"
    elif record.get("obsolete"):
        status = "blocker-obsolete"
        reason = "packaged modinfo marks this mod obsolete"
    elif missing_deps:
        status = "blocker-missing-dependency"
        reason = "packaged mod depends on missing ids: " + ", ".join(missing_deps)
    elif has_summaries:
        status = "summarizer-ready"
        reason = "active-mod summary roots/files already exist and C-AOL runtime loads them"
    elif has_contextual_content:
        status = "summarizer-compatible-but-needs-generated-pack"
        reason = "packaged path is supported and content looks NPC/world-context relevant, but no C-AOL summary roots are present"
    else:
        status = "no-summary-needed"
        reason = "packaged path is supported and no obvious NPC/context JSON content was detected"
    return {
        "status": status,
        "reason": reason,
        "packaging_status": "stock-packaged-path-supported" if record.get("packaged_path_present") else "stock-packaged-path-missing",
        "missing_dependencies": missing_deps,
    }


def build_mod_report(mods_dir: Path) -> list[dict[str, Any]]:
    records = mod_records(mods_dir)
    all_mod_ids = {str(record["id"]) for record in records if record.get("id")}
    report: list[dict[str, Any]] = []
    for record in sorted(records, key=lambda item: (str(item.get("id") or item.get("dir") or "").lower(), item.get("dir", ""))):
        mod_dir = mods_dir / str(record.get("dir"))
        summary = scan_summary_roots(mod_dir)
        content = scan_json_content(mod_dir)
        classification = classify_mod(record, mod_dir, all_mod_ids, summary, content)
        report.append(
            {
                "id": record.get("id"),
                "name": record.get("name"),
                "dir": record.get("dir"),
                "category": record.get("category"),
                "obsolete": bool(record.get("obsolete", False)),
                "dependencies": record.get("dependencies", []),
                "packaged_path_present": bool(record.get("packaged_path_present", False)),
                "modinfo_present": bool(record.get("modinfo_present", False)),
                "summary_roots": summary,
                "json_content": content,
                "classification": classification,
            }
        )
    return report


def status_counts(mods: list[dict[str, Any]]) -> dict[str, int]:
    counts: Counter[str] = Counter()
    for mod in mods:
        counts[mod["classification"]["status"]] += 1
    return dict(sorted(counts.items()))


def write_markdown_report(path: Path, result: dict[str, Any]) -> None:
    mods = result["mods"]
    lines = [
        "# C-AOL v0.2.0 packaged mod compatibility / summarizer bridge report",
        "",
        "Generated by `python3 tools/prove_caol_mod_inventory.py` from the selected cached C-AOL macOS DMG.",
        "The proof is read-only and follows C-AOL's existing runtime summary contract instead of inventing Lacapult-only metadata.",
        "",
        "## Summary",
        "",
        f"- App bundle: `{result['app_bundle']}`",
        f"- Stock mod root: `{result['stock_mods_path']}`",
        f"- Non-obsolete packaged mods: {result['stock_mod_count']}",
        f"- Obsolete packaged mods: {result['obsolete_stock_mod_count']}",
        f"- Status counts: {json.dumps(result['status_counts'], sort_keys=True)}",
        "- Runtime bridge: C-AOL loads `npcs/Backgrounds/Summaries_short` and `npcs/Backgrounds/Summaries_extra` from core data, active mods, and world custom mods.",
        "",
        "## Per-mod status",
        "",
        "| id | name | obsolete | deps | summaries | context flags | status |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]
    for mod in mods:
        flags = [name for name, value in mod["json_content"]["content_flags"].items() if value]
        summary_roots = []
        if mod["summary_roots"]["summaries_short_exists"]:
            summary_roots.append("short")
        if mod["summary_roots"]["summaries_extra_exists"]:
            summary_roots.append("extra")
        if mod["summary_roots"]["summary_registry_exists"]:
            summary_roots.append("registry")
        lines.append(
            "| {id} | {name} | {obsolete} | {deps} | {summaries} | {flags} | {status} |".format(
                id=str(mod.get("id") or "").replace("|", "\\|"),
                name=str(mod.get("name") or "").replace("|", "\\|"),
                obsolete="yes" if mod.get("obsolete") else "no",
                deps=", ".join(mod.get("dependencies") or []) or "-",
                summaries=", ".join(summary_roots) or "-",
                flags=", ".join(flags) or "-",
                status=mod["classification"]["status"],
            )
        )
    lines.extend(
        [
            "",
            "## Next application step",
            "",
            "Lacapult surfaces this proof as read-only status metadata only. Future generated summary packs must stay in C-AOL-compatible active-mod roots (`npcs/Backgrounds/Summaries_short` / `Summaries_extra`) rather than a launcher-only format, and this proof still does not enable mods or apply generated packs.",
            "",
        ]
    )
    path.write_text("\n".join(lines), encoding="utf-8")


def write_reports(report_dir: Path, result: dict[str, Any]) -> dict[str, str]:
    report_dir.mkdir(parents=True, exist_ok=True)
    json_path = report_dir / "caol_mod_summarizer_bridge_report.json"
    markdown_path = report_dir / "caol_mod_summarizer_bridge_report.md"
    paths = {"json": str(json_path), "markdown": str(markdown_path)}
    result["report_paths"] = paths
    json_path.write_text(json.dumps(result, indent=2, sort_keys=True), encoding="utf-8")
    write_markdown_report(markdown_path, result)
    return paths


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dmg", type=Path, default=DEFAULT_DMG)
    parser.add_argument("--report-dir", type=Path, default=DEFAULT_REPORT_DIR)
    parser.add_argument("--no-write-reports", action="store_true")
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
        mods = build_mod_report(mods_dir)
        stock_ids = sorted(str(mod.get("id")) for mod in mods if mod.get("id") and not mod.get("obsolete"))
        obsolete_ids = sorted(str(mod.get("id")) for mod in mods if mod.get("id") and mod.get("obsolete"))
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
            "summarizer_bridge_contract": {
                "runtime_source": "C-AOL src/llm_intent.cpp background_summary_data_roots/load_background_summary_dir",
                "roots_loaded_by_runtime": [
                    "core data/json",
                    "active world mod paths",
                    "world custom mods path",
                ],
                "active_mod_summary_dirs": [
                    SUMMARY_SHORT_REL.as_posix(),
                    SUMMARY_EXTRA_REL.as_posix(),
                ],
                "formats": [
                    "legacy pipe-delimited .txt",
                    "npc_personality_summary JSON object/array/bundle",
                ],
                "lacapult_bridge_rule": "Generate or install summary packs into active C-AOL mod roots; do not invent a Lacapult-only summary metadata format.",
            },
            "classification": {
                "stock_packaged_caol_mods": "supported_by_path_shape_and_present_in_v0_2_0_dmg",
                "user_installed_mods": "mechanically_supported_by_inherited_userdata_mods_path_content_compatibility_unknown",
                "custom_download_catalogs_for_caol": "unknown_or_empty_until_caol_mod_repo_is_populated",
                "inherited_dda_bn_tlg_catalogs": "untested_for_caol",
                "future_npc_llm_mod_summaries": "use_existing_active_mod_summary_roots_not_runtime_integrated_by_lacapult_yet",
            },
            "status_counts": status_counts(mods),
            "mods": mods,
        }
        if not args.no_write_reports:
            result["report_paths"] = write_reports(args.report_dir, result)
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
