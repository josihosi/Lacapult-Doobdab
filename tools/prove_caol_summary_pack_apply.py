#!/usr/bin/env python3
"""Prove sandboxed C-AOL-native summary-pack apply and rollback.

Slice 3 proof boundary: build a tiny C-AOL-like sandbox under .proof-cache/,
choose one non-obsolete contextual packaged stock mod from the status model,
generate a companion summary mod with a C-AOL native npc_personality_summary_bundle,
apply it to the sandbox userdata/world mods.json with backups, prove status-model
visibility, then roll everything back and prove the prior mods.json/order and prior
pack path are restored exactly.

No real Application Support, save, installed game, backend, API secret, model pull, or
C-AOL package path is touched.
"""

from __future__ import annotations

import argparse
import filecmp
import json
import shutil
from pathlib import Path
from typing import Any

from caol_mod_status_model import build_status_model, tree_fingerprint

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ROOT = ROOT / ".proof-cache" / "caol-summary-pack-apply"
PROOF_TIMESTAMP = "2026-04-25T00:00:00Z"
WORLD_NAME = "Sandbox World"
SOURCE_MOD_ID = "fixture_apply_context_stock"
SOURCE_MOD_NAME = "Fixture Apply Context Stock"
COMPANION_MOD_ID = f"lacapult_summary_{SOURCE_MOD_ID}"
SUMMARY_REL = Path("npcs") / "Backgrounds" / "Summaries_extra" / f"generated_{SOURCE_MOD_ID}.json"
MANIFEST_REL = Path("lacapult_summary_pack_manifest.json")


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def write_mod(root: Path, dirname: str, modinfo: Any, extra_files: dict[str, Any] | None = None) -> Path:
    mod_dir = root / dirname
    mod_dir.mkdir(parents=True, exist_ok=True)
    write_json(mod_dir / "modinfo.json", modinfo)
    for rel, payload in (extra_files or {}).items():
        write_json(mod_dir / rel, payload)
    return mod_dir


def modinfo(mod_id: str, name: str, *, dependencies: list[str] | None = None) -> list[dict[str, Any]]:
    return [
        {
            "type": "MOD_INFO",
            "id": mod_id,
            "name": name,
            "category": "content",
            "dependencies": dependencies or [],
            "description": "Sandbox fixture mod for Lacapult C-AOL summary-pack apply proof.",
        }
    ]


def build_sandbox(root: Path) -> dict[str, Path]:
    if root.exists():
        shutil.rmtree(root)
    stock = root / "sandbox" / "game0" / "data" / "mods"
    user = root / "sandbox" / "userdata" / "mods"
    catalog = root / "sandbox" / "mod_repo"
    save = root / "sandbox" / "userdata" / "save"
    world = save / WORLD_NAME

    write_mod(stock, "dda", modinfo("dda", "Dark Days Ahead Core"))
    write_mod(
        stock,
        SOURCE_MOD_ID,
        modinfo(SOURCE_MOD_ID, SOURCE_MOD_NAME, dependencies=["dda"]),
        {
            "items/context.json": [
                {
                    "type": "GENERIC",
                    "id": "fixture_apply_context_item",
                    "name": "fixture apply context item",
                    "description": "Tiny contextual item proving this packaged mod needs a summary pack.",
                }
            ]
        },
    )
    world.mkdir(parents=True, exist_ok=True)
    write_json(world / "mods.json", ["dda"])
    catalog.mkdir(parents=True, exist_ok=True)
    user.mkdir(parents=True, exist_ok=True)
    return {"stock": stock, "user": user, "catalog": catalog, "save": save, "world": world}


def build_status(paths: dict[str, Path]) -> dict[str, Any]:
    return build_status_model(
        stock_mods=paths["stock"],
        user_mods=paths["user"],
        custom_catalog=paths["catalog"],
        save_dir=paths["save"],
        world_name=WORLD_NAME,
    )


def has_context(record: dict[str, Any]) -> bool:
    flags = record.get("json_content", {}).get("content_flags", {})
    return any(bool(flags.get(name)) for name in ("npc", "faction", "monster", "item", "location"))


def choose_source_mod(status: dict[str, Any]) -> dict[str, Any]:
    candidates = [
        record
        for record in status.get("mods", [])
        if record.get("source_type") == "stock"
        and not record.get("obsolete", False)
        and record.get("metadata_status") == "metadata-ok"
        and has_context(record)
        and record.get("summary_status") == "summary-missing"
    ]
    if not candidates:
        raise AssertionError("no non-obsolete contextual packaged stock mod needing summaries was found")
    candidates.sort(key=lambda item: str(item.get("id", "")))
    return candidates[0]


def validate_companion_pack(pack_dir: Path) -> None:
    modinfo_data = read_json(pack_dir / "modinfo.json")
    modinfo_entries = modinfo_data if isinstance(modinfo_data, list) else [modinfo_data]
    if not any(entry.get("type") == "MOD_INFO" and entry.get("id") == COMPANION_MOD_ID for entry in modinfo_entries if isinstance(entry, dict)):
        raise AssertionError("companion modinfo.json does not contain the expected MOD_INFO id")
    if SOURCE_MOD_ID not in modinfo_entries[0].get("dependencies", []):
        raise AssertionError("companion modinfo.json does not depend on the source mod")

    summary = read_json(pack_dir / SUMMARY_REL)
    if summary.get("type") != "npc_personality_summary_bundle":
        raise AssertionError("generated summary file is not an npc_personality_summary_bundle")
    entries = summary.get("entries")
    if not isinstance(entries, list) or not entries:
        raise AssertionError("generated summary bundle has no entries")
    first = entries[0]
    for key in ("selector", "topic", "your_background", "your_expression", "source_tag"):
        if not first.get(key):
            raise AssertionError(f"generated summary entry missing {key}")

    manifest = read_json(pack_dir / MANIFEST_REL)
    if manifest.get("type") != "lacapult_summary_pack_manifest":
        raise AssertionError("manifest has the wrong type")
    if manifest.get("source_mod_id") != SOURCE_MOD_ID:
        raise AssertionError("manifest source_mod_id does not match source mod")
    for rel in manifest.get("generated_paths", []):
        if not (pack_dir / rel).exists():
            raise AssertionError(f"manifest generated path is missing: {rel}")


def desired_mod_order(previous: list[str]) -> list[str]:
    cleaned = [item for item in previous if item not in {SOURCE_MOD_ID, COMPANION_MOD_ID}]
    if SOURCE_MOD_ID in previous:
        source_index = [item for item in previous if item != COMPANION_MOD_ID].index(SOURCE_MOD_ID)
        result = [item for item in previous if item != COMPANION_MOD_ID]
        result.insert(source_index + 1, COMPANION_MOD_ID)
        return result
    return cleaned + [SOURCE_MOD_ID, COMPANION_MOD_ID]


def copy_or_compare_dirs(left: Path, right: Path) -> bool:
    comparison = filecmp.dircmp(left, right)
    if comparison.left_only or comparison.right_only or comparison.diff_files or comparison.funny_files:
        return False
    return all(copy_or_compare_dirs(Path(comparison.left) / name, Path(comparison.right) / name) for name in comparison.common_dirs)


def apply_summary_pack(paths: dict[str, Path], source: dict[str, Any], proof_root: Path) -> dict[str, Any]:
    source_dir = Path(source["path"])
    pack_dir = paths["user"] / COMPANION_MOD_ID
    staging_dir = proof_root / "staging" / COMPANION_MOD_ID
    backup_dir = proof_root / "backups" / "slice3_apply"
    evidence_dir = proof_root / "evidence"
    world_mods_json = paths["world"] / "mods.json"

    if backup_dir.exists():
        shutil.rmtree(backup_dir)
    backup_dir.mkdir(parents=True)
    evidence_dir.mkdir(parents=True, exist_ok=True)

    previous_mods_text = world_mods_json.read_text(encoding="utf-8")
    previous_order = read_json(world_mods_json)
    if not isinstance(previous_order, list):
        raise AssertionError("sandbox world mods.json is not a list")
    previous_order = [str(item) for item in previous_order]
    write_json(backup_dir / "mods.json.before", previous_order)
    previous_mods_text_path = backup_dir / "mods.json.before.exact"
    previous_mods_text_path.write_text(previous_mods_text, encoding="utf-8")

    pack_existed_before = pack_dir.exists()
    pack_backup = backup_dir / "summary_pack.before"
    if pack_existed_before:
        shutil.copytree(pack_dir, pack_backup)
    else:
        write_json(backup_dir / "summary_pack.before.missing.json", {"path": pack_dir.as_posix(), "state": "missing"})

    if staging_dir.exists():
        shutil.rmtree(staging_dir)
    source_fingerprint = tree_fingerprint(source_dir)
    generated_summary = {
        "type": "npc_personality_summary_bundle",
        "version": 1,
        "entries": [
            {
                "type": "npc_personality_summary",
                "selector": "fixture_apply_context_stock:survivor",
                "topic": "fixture_apply_context_stock_world_context",
                "your_background": "You remember the tiny fixture mod as proof that generated C-AOL summaries can live in a companion mod root.",
                "your_expression": "Keep the fixture context close; the launcher staged this only in a sandbox.",
                "source_tag": f"lacapult-generated:{SOURCE_MOD_ID}",
            }
        ],
    }
    new_order = desired_mod_order(previous_order)
    manifest = {
        "type": "lacapult_summary_pack_manifest",
        "version": 1,
        "source_mod_id": SOURCE_MOD_ID,
        "source_mod_name": SOURCE_MOD_NAME,
        "source_fingerprint": source_fingerprint,
        "generated_at": PROOF_TIMESTAMP,
        "backend": "fixture-no-backend-call",
        "model": "fixture-summary-pack-proof",
        "target_schema": "c-aol npc_personality_summary_bundle v1",
        "generated_paths": [
            "modinfo.json",
            MANIFEST_REL.as_posix(),
            SUMMARY_REL.as_posix(),
        ],
        "apply": {
            "mode": "sandbox-proof-user-companion-mod",
            "applied_at": PROOF_TIMESTAMP,
            "target_user_mod_path": pack_dir.as_posix(),
            "world_mods_json": world_mods_json.as_posix(),
            "previous_mod_order": previous_order,
            "new_mod_order": new_order,
            "backup_paths": {
                "mods_json_exact": previous_mods_text_path.as_posix(),
                "mods_json_order": (backup_dir / "mods.json.before").as_posix(),
                "summary_pack_backup": pack_backup.as_posix() if pack_existed_before else None,
                "summary_pack_missing_marker": None if pack_existed_before else (backup_dir / "summary_pack.before.missing.json").as_posix(),
            },
        },
        "rollback": {
            "mode": "restore-previous-world-mods-json-and-summary-pack-dir",
            "pack_existed_before_apply": pack_existed_before,
            "restore_paths": [world_mods_json.as_posix(), pack_dir.as_posix()],
            "expected_mod_order_after_rollback": previous_order,
        },
    }

    write_json(staging_dir / "modinfo.json", modinfo(COMPANION_MOD_ID, f"Lacapult generated summaries for {SOURCE_MOD_NAME}", dependencies=[SOURCE_MOD_ID]))
    write_json(staging_dir / SUMMARY_REL, generated_summary)
    write_json(staging_dir / MANIFEST_REL, manifest)
    validate_companion_pack(staging_dir)

    if pack_dir.exists():
        shutil.rmtree(pack_dir)
    shutil.copytree(staging_dir, pack_dir)
    write_json(world_mods_json, new_order)
    validate_companion_pack(pack_dir)

    write_json(evidence_dir / "manifest.applied.copy.json", manifest)
    shutil.copy2(pack_dir / SUMMARY_REL, evidence_dir / f"{SUMMARY_REL.name}.applied.copy.json")
    shutil.copy2(pack_dir / "modinfo.json", evidence_dir / "companion_modinfo.applied.copy.json")
    return {
        "source_fingerprint": source_fingerprint,
        "pack_dir": pack_dir,
        "staging_dir": staging_dir,
        "backup_dir": backup_dir,
        "world_mods_json": world_mods_json,
        "previous_mods_text_path": previous_mods_text_path,
        "previous_order": previous_order,
        "new_order": new_order,
        "pack_existed_before": pack_existed_before,
        "pack_backup": pack_backup,
        "manifest": manifest,
    }


def assert_applied_status(status: dict[str, Any]) -> None:
    by_id = {(record["id"], record["source_type"]): record for record in status.get("mods", [])}
    source = by_id.get((SOURCE_MOD_ID, "stock"))
    companion = by_id.get((COMPANION_MOD_ID, "user"))
    if source is None:
        raise AssertionError("source stock mod is missing from applied status")
    if companion is None:
        raise AssertionError("companion user summary mod is missing from applied status")
    if source.get("enabled_status") != "enabled-in-world":
        raise AssertionError(f"source was not enabled after apply: {source.get('enabled_status')}")
    if source.get("summary_status") != "summary-ready":
        raise AssertionError(f"source was not summary-ready after apply: {source.get('summary_status')}")
    if companion.get("enabled_status") != "enabled-in-world":
        raise AssertionError(f"companion was not enabled after apply: {companion.get('enabled_status')}")
    if not companion.get("generated_summary_pack", {}).get("present"):
        raise AssertionError("status model did not see companion generated-pack manifest")


def rollback_apply(paths: dict[str, Path], apply_info: dict[str, Any]) -> None:
    world_mods_json: Path = apply_info["world_mods_json"]
    pack_dir: Path = apply_info["pack_dir"]
    backup_dir: Path = apply_info["backup_dir"]
    world_mods_json.write_text(apply_info["previous_mods_text_path"].read_text(encoding="utf-8"), encoding="utf-8")
    if pack_dir.exists():
        shutil.rmtree(pack_dir)
    if apply_info["pack_existed_before"]:
        shutil.copytree(apply_info["pack_backup"], pack_dir)

    if world_mods_json.read_text(encoding="utf-8") != apply_info["previous_mods_text_path"].read_text(encoding="utf-8"):
        raise AssertionError("rollback did not restore mods.json bytes exactly")
    if read_json(world_mods_json) != apply_info["previous_order"]:
        raise AssertionError("rollback did not restore prior mods.json order")
    if apply_info["pack_existed_before"]:
        if not copy_or_compare_dirs(pack_dir, backup_dir / "summary_pack.before"):
            raise AssertionError("rollback did not restore preexisting summary pack directory exactly")
    elif pack_dir.exists():
        raise AssertionError("rollback left a generated summary pack that did not exist before apply")


def assert_rolled_back_status(status: dict[str, Any]) -> None:
    source_records = [record for record in status.get("mods", []) if record.get("id") == SOURCE_MOD_ID and record.get("source_type") == "stock"]
    if len(source_records) != 1:
        raise AssertionError("expected exactly one source stock record after rollback")
    source = source_records[0]
    if source.get("enabled_status") != "disabled":
        raise AssertionError(f"source should be disabled again after rollback: {source.get('enabled_status')}")
    if source.get("summary_status") != "summary-missing":
        raise AssertionError(f"source should return to summary-missing after rollback: {source.get('summary_status')}")
    companion_records = [record for record in status.get("mods", []) if record.get("id") == COMPANION_MOD_ID]
    if companion_records:
        raise AssertionError("companion summary pack still appears after rollback")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    args = parser.parse_args()

    paths = build_sandbox(args.root)
    evidence_dir = args.root / "evidence"
    evidence_dir.mkdir(parents=True, exist_ok=True)

    initial_status = build_status(paths)
    write_json(evidence_dir / "status.initial.json", initial_status)
    source = choose_source_mod(initial_status)
    if source["id"] != SOURCE_MOD_ID:
        raise AssertionError(f"unexpected source chosen: {source['id']}")

    apply_info = apply_summary_pack(paths, source, args.root)
    applied_status = build_status(paths)
    write_json(evidence_dir / "status.applied.json", applied_status)
    assert_applied_status(applied_status)

    applied_order = read_json(apply_info["world_mods_json"])
    if applied_order.index(COMPANION_MOD_ID) <= applied_order.index(SOURCE_MOD_ID):
        raise AssertionError("companion summary mod is not ordered after source mod")

    rollback_apply(paths, apply_info)
    rollback_status = build_status(paths)
    write_json(evidence_dir / "status.rolled_back.json", rollback_status)
    assert_rolled_back_status(rollback_status)

    evidence = {
        "proof": "caol_summary_pack_apply_rollback",
        "version": 1,
        "sandbox_root": (args.root / "sandbox").as_posix(),
        "evidence_dir": evidence_dir.as_posix(),
        "source_mod": {
            "id": source["id"],
            "name": source["name"],
            "source_type": source["source_type"],
            "source_fingerprint": apply_info["source_fingerprint"],
            "initial_summary_status": source["summary_status"],
        },
        "companion_mod_id": COMPANION_MOD_ID,
        "summary_bundle_path_before_rollback": (apply_info["pack_dir"] / SUMMARY_REL).as_posix(),
        "summary_bundle_copy": (evidence_dir / f"{SUMMARY_REL.name}.applied.copy.json").as_posix(),
        "companion_modinfo_copy": (evidence_dir / "companion_modinfo.applied.copy.json").as_posix(),
        "manifest_copy": (evidence_dir / "manifest.applied.copy.json").as_posix(),
        "backup_dir": apply_info["backup_dir"].as_posix(),
        "previous_mod_order": apply_info["previous_order"],
        "applied_mod_order": apply_info["new_order"],
        "rollback_restored_mod_order_exactly": read_json(apply_info["world_mods_json"]) == apply_info["previous_order"],
        "rollback_removed_new_summary_pack": not apply_info["pack_dir"].exists() if not apply_info["pack_existed_before"] else None,
        "status_model_visibility": {
            "source_summary_ready_after_apply": True,
            "companion_generated_pack_present_after_apply": True,
            "source_summary_missing_after_rollback": True,
        },
        "non_goals_observed": [
            "no real Application Support paths touched",
            "no backend/API/model call",
            "no model pull/download/install",
            "no C-AOL package mutation",
        ],
    }
    write_json(evidence_dir / "evidence.json", evidence)

    print(json.dumps(evidence, indent=2, sort_keys=True))
    print(f"wrote proof evidence: {evidence_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
