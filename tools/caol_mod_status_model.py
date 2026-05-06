#!/usr/bin/env python3
"""C-AOL mod/Summarizer status model shared by Lacapult proof tools.

The model is intentionally read-only. It scans a C-AOL-like userdata/install tree,
classifies stock/user/custom-catalog/world mod roots, reads one world's mods.json,
and reports C-AOL-native summary-root / generated-pack status without applying or
enabling anything.
"""

from __future__ import annotations

import hashlib
import json
from collections import Counter
from pathlib import Path
from typing import Any

SUMMARY_SHORT_REL = Path("npcs") / "Backgrounds" / "Summaries_short"
SUMMARY_EXTRA_REL = Path("npcs") / "Backgrounds" / "Summaries_extra"
SUMMARY_ROOTS = (SUMMARY_SHORT_REL, SUMMARY_EXTRA_REL)
GENERATED_MANIFEST_TYPES = {"lacapult_summary_pack_manifest"}
SUMMARY_RECORD_TYPES = {"npc_personality_summary", "npc_personality_summary_bundle"}
CAOL_JSON_CATALOG_TARGET_IDS = ("magiclysm", "DinoMod")

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


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8", errors="replace"))


def json_records(data: Any) -> list[dict[str, Any]]:
    if isinstance(data, list):
        return [entry for entry in data if isinstance(entry, dict)]
    if isinstance(data, dict):
        if isinstance(data.get("entries"), list):
            return [entry for entry in data["entries"] if isinstance(entry, dict)]
        return [data]
    return []


def normalized_dependencies(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []
    return sorted(str(dep) for dep in value if isinstance(dep, (str, int, float)))


def normalized_claim_values(value: Any) -> list[str]:
    if isinstance(value, list):
        return sorted(str(item) for item in value if isinstance(item, (str, int, float)) and str(item))
    if isinstance(value, (str, int, float)) and str(value):
        return [str(value)]
    return []


def relative_path(path: Path, base: Path) -> str:
    try:
        return path.relative_to(base).as_posix()
    except ValueError:
        return path.as_posix()


def read_modinfo(mod_dir: Path) -> dict[str, Any]:
    modinfo = mod_dir / "modinfo.json"
    if not modinfo.exists():
        return {
            "id": mod_dir.name,
            "name": mod_dir.name,
            "modinfo_present": False,
            "modinfo_parse_error": "modinfo.json is missing",
            "dependencies": [],
            "obsolete": False,
        }
    try:
        data = load_json(modinfo)
    except Exception as exc:  # noqa: BLE001 - status model must report bad mod metadata
        return {
            "id": mod_dir.name,
            "name": mod_dir.name,
            "modinfo_present": True,
            "modinfo_parse_error": str(exc),
            "dependencies": [],
            "obsolete": False,
        }
    entries = data if isinstance(data, list) else [data]
    for entry in entries:
        if not isinstance(entry, dict):
            continue
        if entry.get("type") not in (None, "MOD_INFO"):
            continue
        mod_id = entry.get("id") or entry.get("ident") or mod_dir.name
        return {
            "id": str(mod_id),
            "name": str(entry.get("name") or mod_id),
            "category": entry.get("category"),
            "modinfo_present": True,
            "modinfo_parse_error": None,
            "dependencies": normalized_dependencies(entry.get("dependencies", [])),
            "obsolete": bool(entry.get("obsolete", False)),
            "raw_modinfo": entry,
        }
    return {
        "id": mod_dir.name,
        "name": mod_dir.name,
        "modinfo_present": True,
        "modinfo_parse_error": "modinfo.json contains no MOD_INFO entry",
        "dependencies": [],
        "obsolete": False,
    }


def scan_summary_roots(mod_dir: Path) -> dict[str, Any]:
    summary_files = sorted(
        path for root in SUMMARY_ROOTS for path in (mod_dir / root).rglob("*") if path.is_file()
    )
    return {
        "summaries_short_exists": (mod_dir / SUMMARY_SHORT_REL).exists(),
        "summaries_extra_exists": (mod_dir / SUMMARY_EXTRA_REL).exists(),
        "summary_file_count": len(summary_files),
        "summary_json_count": len([path for path in summary_files if path.suffix == ".json"]),
        "summary_txt_count": len([path for path in summary_files if path.suffix == ".txt"]),
        "summary_file_samples": [relative_path(path, mod_dir) for path in summary_files[:12]],
    }


def scan_json_content(mod_dir: Path) -> dict[str, Any]:
    type_counts: Counter[str] = Counter()
    parse_errors: list[str] = []
    manifest_records: list[dict[str, Any]] = []
    summary_claims: list[dict[str, Any]] = []
    json_files = sorted(mod_dir.rglob("*.json")) if mod_dir.exists() else []
    parsed_files = 0
    for path in json_files:
        try:
            data = load_json(path)
        except Exception as exc:  # noqa: BLE001 - bad mod JSON is status, not a hidden failure
            parse_errors.append(f"{relative_path(path, mod_dir)}: {exc}")
            continue
        parsed_files += 1
        for record in json_records(data):
            record_type = record.get("type")
            if isinstance(record_type, str) and record_type:
                type_counts[record_type] += 1
            if record_type in GENERATED_MANIFEST_TYPES:
                manifest_records.append({"path": relative_path(path, mod_dir), **record})
            rel_path = relative_path(path, mod_dir)
            in_summary_root = rel_path.startswith(SUMMARY_SHORT_REL.as_posix()) or rel_path.startswith(SUMMARY_EXTRA_REL.as_posix())
            selectors = normalized_claim_values(record.get("selectors")) or normalized_claim_values(record.get("selector"))
            topics = normalized_claim_values(record.get("topics")) or normalized_claim_values(record.get("topic"))
            if record_type in SUMMARY_RECORD_TYPES and not selectors:
                selectors = normalized_claim_values(record.get("id"))
            if in_summary_root and (record_type in SUMMARY_RECORD_TYPES or selectors or topics):
                if selectors or topics:
                    summary_claims.append(
                        {
                            "path": relative_path(path, mod_dir),
                            "selectors": selectors,
                            "topics": topics,
                            "source_tag": record.get("source_tag"),
                        }
                    )
    flags: dict[str, bool] = {}
    for group_name, record_types in CONTEXTUAL_TYPE_GROUPS.items():
        flags[group_name] = any(type_counts.get(record_type, 0) > 0 for record_type in record_types)
    flags["mechanic"] = any(type_counts.get(record_type, 0) > 0 for record_type in MECHANIC_TYPES)
    return {
        "json_file_count": len(json_files),
        "json_files_parsed": parsed_files,
        "json_parse_error_count": len(parse_errors),
        "json_parse_errors_sample": parse_errors[:12],
        "type_counts_sample": dict(type_counts.most_common(24)),
        "content_flags": flags,
        "generated_manifests": manifest_records,
        "summary_claims": summary_claims[:48],
    }


def tree_fingerprint(mod_dir: Path) -> str:
    digest = hashlib.sha256()
    if not mod_dir.exists():
        return "missing"
    for path in sorted(p for p in mod_dir.rglob("*") if p.is_file()):
        rel = relative_path(path, mod_dir)
        # Generated status/proof artifacts should not make the source fingerprint flap.
        if rel.endswith(".DS_Store"):
            continue
        stat = path.stat()
        digest.update(rel.encode("utf-8", errors="replace"))
        digest.update(str(stat.st_size).encode())
        digest.update(str(int(stat.st_mtime)).encode())
        if path.name == "modinfo.json" or path.suffix == ".json":
            try:
                digest.update(path.read_bytes())
            except OSError:
                pass
    return "sha256:" + digest.hexdigest()


def scan_mod_root(root: Path | None, source_type: str) -> list[dict[str, Any]]:
    if root is None or not root.exists():
        return []
    records: list[dict[str, Any]] = []
    for mod_dir in sorted(path for path in root.iterdir() if path.is_dir()):
        modinfo = read_modinfo(mod_dir)
        summary_roots = scan_summary_roots(mod_dir)
        json_content = scan_json_content(mod_dir)
        generated_manifest = json_content["generated_manifests"][0] if json_content["generated_manifests"] else None
        records.append(
            {
                "id": modinfo["id"],
                "name": modinfo["name"],
                "dir": mod_dir.name,
                "path": mod_dir.as_posix(),
                "source_type": source_type,
                "source_status": {
                    "stock": "stock-packaged",
                    "user": "user-installed",
                    "custom-catalog": "custom-catalog",
                    "world-custom": "world-specific-custom",
                }.get(source_type, source_type),
                "category": modinfo.get("category"),
                "dependencies": modinfo.get("dependencies", []),
                "obsolete": bool(modinfo.get("obsolete", False)),
                "metadata_status": "metadata-broken" if modinfo.get("modinfo_parse_error") else "metadata-ok",
                "metadata_errors": [modinfo["modinfo_parse_error"]] if modinfo.get("modinfo_parse_error") else [],
                "summary_roots": summary_roots,
                "json_content": json_content,
                "generated_summary_pack": {
                    "present": generated_manifest is not None,
                    "manifest": generated_manifest,
                    "source_mod_id": generated_manifest.get("source_mod_id") if generated_manifest else None,
                },
                "source_fingerprint": tree_fingerprint(mod_dir),
            }
        )
    return records


def read_world_mods(save_dir: Path | None, world_name: str | None = None) -> dict[str, Any]:
    if save_dir is None or not save_dir.exists():
        return {"world_name": None, "world_path": None, "mods_json_present": False, "enabled_mod_ids": [], "errors": []}
    world_path = save_dir / world_name if world_name else None
    if world_path is None or not world_path.exists():
        worlds = sorted(path for path in save_dir.iterdir() if path.is_dir() and (path / "mods.json").exists())
        world_path = worlds[0] if worlds else None
    if world_path is None:
        return {"world_name": None, "world_path": None, "mods_json_present": False, "enabled_mod_ids": [], "errors": []}
    mods_json = world_path / "mods.json"
    if not mods_json.exists():
        return {
            "world_name": world_path.name,
            "world_path": world_path.as_posix(),
            "mods_json_present": False,
            "enabled_mod_ids": [],
            "errors": ["mods.json is missing"],
        }
    try:
        data = load_json(mods_json)
    except Exception as exc:  # noqa: BLE001 - proof status should carry parse failure
        return {
            "world_name": world_path.name,
            "world_path": world_path.as_posix(),
            "mods_json_present": True,
            "enabled_mod_ids": [],
            "errors": [str(exc)],
        }
    enabled = [str(item) for item in data] if isinstance(data, list) else []
    return {
        "world_name": world_path.name,
        "world_path": world_path.as_posix(),
        "mods_json_present": True,
        "enabled_mod_ids": enabled,
        "errors": [] if isinstance(data, list) else ["mods.json is not a JSON array"],
    }


def summary_claim_keys(record: dict[str, Any]) -> set[tuple[str, str]]:
    keys: set[tuple[str, str]] = set()
    for claim in record.get("json_content", {}).get("summary_claims", []):
        selectors = claim.get("selectors") or [""]
        topics = claim.get("topics") or [""]
        for selector in selectors:
            for topic in topics:
                keys.add((str(selector), str(topic)))
    return keys


def generated_packs_conflict(packs: list[dict[str, Any]]) -> bool:
    seen: set[tuple[str, str]] = set()
    for pack in packs:
        keys = summary_claim_keys(pack)
        if keys & seen:
            return True
        seen |= keys
    return False


def generated_pack_is_stale(source_record: dict[str, Any], pack_record: dict[str, Any]) -> bool:
    manifest = pack_record.get("generated_summary_pack", {}).get("manifest") or {}
    manifest_fingerprint = str(manifest.get("source_fingerprint") or "")
    if not manifest_fingerprint:
        return False
    return manifest_fingerprint != str(source_record.get("source_fingerprint") or "")


def record_has_context(record: dict[str, Any]) -> bool:
    flags = record.get("json_content", {}).get("content_flags", {})
    return any(flags.get(name, False) for name in ("npc", "faction", "monster", "item", "location"))


def backend_gate_ready(backend_gate: dict[str, Any] | None) -> bool | None:
    if not backend_gate:
        return None
    mode = str(backend_gate.get("mode") or "")
    status = str(backend_gate.get("status") or "")
    if mode == "api":
        return "any_llm_import_ok" in status and "model_configured" in status and "api_key_env_present_secret_not_read" in status
    if mode == "ollama":
        return "server_running_model_present" in status
    if mode == "openvino":
        return "imports_ok" in status and "model_dir_present" in status
    return False


def summarize_record(record: dict[str, Any], generated_by_source: dict[str, list[dict[str, Any]]]) -> str:
    if record["metadata_status"] == "metadata-broken":
        return "summary-unknown"
    if record["json_content"]["json_parse_error_count"] > 0:
        return "summary-unknown"
    if record["obsolete"]:
        return "summary-not-needed"
    summaries = record["summary_roots"]
    has_root = summaries["summaries_short_exists"] or summaries["summaries_extra_exists"]
    has_summary_files = summaries["summary_file_count"] > 0
    generated_packs = generated_by_source.get(record["id"], [])
    active_generated_packs = [pack for pack in generated_packs if pack.get("enabled_status") == "enabled-in-world"]
    if active_generated_packs:
        if generated_packs_conflict(active_generated_packs):
            return "summary-conflict"
        if any(generated_pack_is_stale(record, pack) for pack in active_generated_packs):
            return "summary-stale"
        if any(pack["summary_roots"]["summary_file_count"] > 0 for pack in active_generated_packs):
            return "summary-ready"
        return "summary-partial"
    if has_summary_files:
        return "summary-ready"
    if has_root:
        return "summary-partial"
    return "summary-missing" if record_has_context(record) else "summary-not-needed"


def json_catalog_targets(records: list[dict[str, Any]]) -> list[dict[str, Any]]:
    targets: list[dict[str, Any]] = []
    for target_id in CAOL_JSON_CATALOG_TARGET_IDS:
        matches = [
            {
                "id": record["id"],
                "name": record["name"],
                "source_type": record["source_type"],
                "enabled_status": record.get("enabled_status"),
                "summary_status": record.get("summary_status"),
                "dependency_status": record.get("dependency_status"),
                "json_file_count": record.get("json_content", {}).get("json_file_count", 0),
                "content_flags": record.get("json_content", {}).get("content_flags", {}),
            }
            for record in records
            if record["id"] == target_id
        ]
        targets.append(
            {
                "id": target_id,
                "present": bool(matches),
                "attempted_sources": ["stock", "user", "custom-catalog", "world-custom"],
                "matches": matches,
                "unavailable_reason": "" if matches else "not found in active C-AOL data/mods, user mods, mod_repo, or world custom mods",
            }
        )
    return targets


def build_status_model(
    *,
    stock_mods: Path | None,
    user_mods: Path | None,
    custom_catalog: Path | None,
    save_dir: Path | None,
    world_name: str | None = None,
    backend_gate: dict[str, Any] | None = None,
) -> dict[str, Any]:
    world = read_world_mods(save_dir, world_name)
    world_custom_root = Path(world["world_path"]) / "mods" if world.get("world_path") else None
    records = []
    records.extend(scan_mod_root(stock_mods, "stock"))
    records.extend(scan_mod_root(user_mods, "user"))
    records.extend(scan_mod_root(custom_catalog, "custom-catalog"))
    records.extend(scan_mod_root(world_custom_root, "world-custom"))

    installed_ids = {record["id"] for record in records if record["source_type"] != "custom-catalog"}
    enabled_ids = set(world["enabled_mod_ids"])

    for record in records:
        source_type = record["source_type"]
        if source_type == "custom-catalog":
            record["enabled_status"] = "catalog-untested"
        elif record["id"] in enabled_ids:
            record["enabled_status"] = "enabled-in-world"
        else:
            record["enabled_status"] = "disabled"
        missing_deps = [dep for dep in record["dependencies"] if dep not in installed_ids]
        disabled_deps = [dep for dep in record["dependencies"] if dep in installed_ids and dep not in enabled_ids]
        dependency_status = "dependency-ok" if not missing_deps and not disabled_deps else "dependency-blocked"
        record["dependency_status"] = dependency_status
        record["missing_dependencies"] = missing_deps
        record["disabled_dependencies"] = disabled_deps
        record["obsolete_status"] = "obsolete-blocked" if record["obsolete"] else "not-obsolete"

    generated_by_source: dict[str, list[dict[str, Any]]] = {}
    for record in records:
        source_id = record["generated_summary_pack"].get("source_mod_id")
        if source_id:
            generated_by_source.setdefault(str(source_id), []).append(record)

    gate_ready = backend_gate_ready(backend_gate)
    for record in records:
        record["summary_status"] = summarize_record(record, generated_by_source)
        record["status_badges"] = [
            record["source_status"],
            record["enabled_status"],
            record["obsolete_status"],
            record["metadata_status"],
            record["dependency_status"],
            record["summary_status"],
        ]
        if record.get("json_content", {}).get("json_parse_error_count", 0) > 0:
            record["status_badges"].append("content-parse-error")
        if gate_ready is False and record_has_context(record) and record["summary_status"] in {"summary-missing", "summary-partial", "summary-stale", "summary-conflict", "summary-unknown"}:
            record["status_badges"].append("backend-not-ready")
            record["status_badges"].append("summary-blocked")
        if record["generated_summary_pack"]["present"]:
            record["status_badges"].append("generated-summary-pack-present")

    return {
        "model": "caol_mod_summarizer_status",
        "version": 1,
        "read_only": True,
        "world": world,
        "paths": {
            "stock_mods": stock_mods.as_posix() if stock_mods else None,
            "user_mods": user_mods.as_posix() if user_mods else None,
            "custom_catalog": custom_catalog.as_posix() if custom_catalog else None,
            "save_dir": save_dir.as_posix() if save_dir else None,
            "world_custom_mods": world_custom_root.as_posix() if world_custom_root else None,
        },
        "backend_gate": {
            "mode": backend_gate.get("mode") if backend_gate else None,
            "status": backend_gate.get("status") if backend_gate else None,
            "generation_ready": gate_ready,
        },
        "json_catalog_targets": json_catalog_targets(records),
        "counts": dict(Counter(badge for record in records for badge in record["status_badges"])),
        "mods": sorted(records, key=lambda item: (item["id"].lower(), item["source_type"], item["dir"])),
    }
