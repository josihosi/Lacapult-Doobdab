#!/usr/bin/env python3
"""Build a tiny C-AOL-like sandbox fixture and emit mod/Summarizer status JSON.

This proof never touches the real Lacapult/C-AOL Application Support tree. By
default it writes under .proof-cache/caol-mod-status-fixture and proves the Slice 1
status model against stock, user-installed, custom-catalog, and world-specific
custom mods plus enabled/disabled, obsolete, broken metadata, dependency-blocked,
summary-ready/missing/not-needed/partial/unknown, and generated-pack detection.
"""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path
from typing import Any

from caol_mod_status_model import build_status_model, tree_fingerprint

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_FIXTURE = ROOT / ".proof-cache" / "caol-mod-status-fixture"
DEFAULT_OUTPUT = ROOT / ".proof-cache" / "caol-mod-status" / "status.json"


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def write_mod(root: Path, dirname: str, modinfo: Any, extra_files: dict[str, Any] | None = None) -> None:
    mod_dir = root / dirname
    mod_dir.mkdir(parents=True, exist_ok=True)
    if isinstance(modinfo, str):
        (mod_dir / "modinfo.json").write_text(modinfo, encoding="utf-8")
    else:
        write_json(mod_dir / "modinfo.json", modinfo)
    for rel, payload in (extra_files or {}).items():
        target = mod_dir / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        if isinstance(payload, str):
            target.write_text(payload, encoding="utf-8")
        else:
            write_json(target, payload)


def modinfo(mod_id: str, name: str, *, dependencies: list[str] | None = None, obsolete: bool = False) -> dict[str, Any]:
    return {
        "type": "MOD_INFO",
        "id": mod_id,
        "name": name,
        "category": "content",
        "dependencies": dependencies or [],
        "obsolete": obsolete,
    }


def contextual_item(item_id: str) -> dict[str, str]:
    return {"type": "GENERIC", "id": item_id, "name": item_id, "description": "Fixture context item."}


def contextual_monster(monster_id: str) -> dict[str, str]:
    return {"type": "MONSTER", "id": monster_id, "name": monster_id, "description": "Fixture context monster."}


def build_fixture(root: Path) -> dict[str, Path]:
    if root.exists():
        shutil.rmtree(root)
    stock = root / "game0" / "data" / "mods"
    user = root / "userdata" / "mods"
    catalog = root / "mod_repo"
    save = root / "userdata" / "save"
    world = save / "Sandbox World"
    world_mods = world / "mods"

    # Stock packaged: enabled, contextual, summarized by an active generated user pack.
    write_mod(
        stock,
        "fixture_context_stock",
        modinfo("fixture_context_stock", "Fixture Context Stock"),
        {"items/context.json": [contextual_item("fixture_context_stock_item")]},
    )
    # Stock packaged: enabled, no contextual content, summary-not-needed.
    write_mod(stock, "fixture_no_summary_needed", modinfo("fixture_no_summary_needed", "Fixture No Summary Needed"))
    write_mod(stock, "dda", modinfo("dda", "Dark Days Ahead Core"))
    # C-AOL JSON catalog targets requested by the Windows v2 retest notes.
    write_mod(
        stock,
        "Magiclysm",
        modinfo("magiclysm", "Magiclysm", dependencies=["dda"]),
        {"items/magic_fixture.json": [contextual_item("magiclysm_fixture_focus")]},
    )
    write_mod(
        stock,
        "DinoMod",
        modinfo("DinoMod", "DinoMod", dependencies=["dda"]),
        {"monsters/dino_fixture.json": [contextual_monster("dinomod_fixture_dino")]},
    )
    # Stock packaged: obsolete-blocked.
    write_mod(stock, "fixture_obsolete", modinfo("fixture_obsolete", "Fixture Obsolete", obsolete=True))
    # Stock packaged: dependency-blocked.
    write_mod(
        stock,
        "fixture_missing_dep",
        modinfo("fixture_missing_dep", "Fixture Missing Dependency", dependencies=["fixture_absent_dep"]),
        {"items/missing_dep_context.json": [contextual_item("fixture_missing_dep_item")]},
    )
    # Stock packaged: metadata-broken / summary-unknown.
    write_mod(stock, "fixture_broken_metadata", "{ not json at all")
    # Stock packaged: partial summary roots.
    write_mod(
        stock,
        "fixture_partial_summary",
        modinfo("fixture_partial_summary", "Fixture Partial Summary"),
        {"items/partial_context.json": [contextual_item("fixture_partial_item")]},
    )
    (stock / "fixture_partial_summary" / "npcs" / "Backgrounds" / "Summaries_extra").mkdir(parents=True, exist_ok=True)

    # User-installed: disabled contextual mod, summary-missing.
    write_mod(
        user,
        "fixture_user_context",
        modinfo("fixture_user_context", "Fixture User Context"),
        {"monsters/context.json": [{"type": "MONSTER", "id": "fixture_user_monster"}]},
    )
    # User-installed generated companion pack: enabled and points at the stock source.
    write_mod(
        user,
        "lacapult_summary_fixture_context_stock",
        modinfo(
            "lacapult_summary_fixture_context_stock",
            "Generated summaries for Fixture Context Stock",
            dependencies=["fixture_context_stock"],
        ),
        {
            "lacapult_summary_pack_manifest.json": {
                "type": "lacapult_summary_pack_manifest",
                "version": 1,
                "source_mod_id": "fixture_context_stock",
                "source_mod_name": "Fixture Context Stock",
                "source_fingerprint": tree_fingerprint(stock / "fixture_context_stock"),
                "backend": "fixture",
                "model": "fixture",
                "target_schema": "c-aol npc_personality_summary_bundle v1",
            },
            "npcs/Backgrounds/Summaries_extra/generated_fixture_context_stock.json": {
                "type": "npc_personality_summary_bundle",
                "version": 1,
                "entries": [
                    {
                        "type": "npc_personality_summary",
                        "selector": "fixture:context_stock",
                        "your_background": "fixture summary",
                        "your_expression": "fixture line",
                        "source_tag": "lacapult-generated:fixture_context_stock",
                    }
                ],
            },
        },
    )

    # Custom catalog/custom repo: downloadable-shaped but C-AOL-untested until installed/proven.
    write_mod(
        catalog,
        "fixture_catalog_context",
        modinfo("fixture_catalog_context", "Fixture Catalog Context"),
        {"items/catalog_context.json": [contextual_item("fixture_catalog_item")]},
    )

    # World-specific custom mod: enabled in the sandbox world.
    write_mod(
        world_mods,
        "fixture_world_custom",
        modinfo("fixture_world_custom", "Fixture World Custom"),
        {"factions/context.json": [{"type": "faction", "id": "fixture_world_faction"}]},
    )

    write_json(
        world / "mods.json",
        [
            "dda",
            "fixture_context_stock",
            "fixture_no_summary_needed",
            "magiclysm",
            "DinoMod",
            "fixture_world_custom",
            "lacapult_summary_fixture_context_stock",
        ],
    )
    return {"stock": stock, "user": user, "catalog": catalog, "save": save, "world": world}


def require_status(result: dict[str, Any], mod_id: str, source_type: str, badge_or_summary: str) -> None:
    for record in result["mods"]:
        if record["id"] == mod_id and record["source_type"] == source_type:
            if record["summary_status"] == badge_or_summary or badge_or_summary in record["status_badges"]:
                return
            raise AssertionError(f"{mod_id}/{source_type} missing {badge_or_summary}: {record['status_badges']}")
    raise AssertionError(f"{mod_id}/{source_type} not found")


def assert_fixture_status(result: dict[str, Any]) -> None:
    catalog_targets = {target["id"]: target for target in result.get("json_catalog_targets", [])}
    for target_id in ["magiclysm", "DinoMod"]:
        target = catalog_targets.get(target_id)
        if not target or not target.get("present"):
            raise AssertionError(f"{target_id} was not reported as a present C-AOL JSON catalog target")
        if not any(match.get("source_type") == "stock" and match.get("summary_status") == "summary-missing" for match in target.get("matches", [])):
            raise AssertionError(f"{target_id} did not land as a stock JSON Summarizer candidate: {target}")
    require_status(result, "fixture_context_stock", "stock", "stock-packaged")
    require_status(result, "fixture_context_stock", "stock", "enabled-in-world")
    require_status(result, "fixture_context_stock", "stock", "summary-ready")
    require_status(result, "fixture_user_context", "user", "user-installed")
    require_status(result, "fixture_user_context", "user", "disabled")
    require_status(result, "fixture_user_context", "user", "summary-missing")
    require_status(result, "fixture_catalog_context", "custom-catalog", "catalog-untested")
    require_status(result, "fixture_world_custom", "world-custom", "world-specific-custom")
    require_status(result, "fixture_world_custom", "world-custom", "enabled-in-world")
    require_status(result, "fixture_obsolete", "stock", "obsolete-blocked")
    require_status(result, "fixture_broken_metadata", "stock", "metadata-broken")
    require_status(result, "fixture_broken_metadata", "stock", "summary-unknown")
    require_status(result, "fixture_missing_dep", "stock", "dependency-blocked")
    require_status(result, "fixture_partial_summary", "stock", "summary-partial")
    require_status(result, "fixture_no_summary_needed", "stock", "summary-not-needed")
    require_status(result, "magiclysm", "stock", "summary-missing")
    require_status(result, "DinoMod", "stock", "summary-missing")
    require_status(result, "lacapult_summary_fixture_context_stock", "user", "generated-summary-pack-present")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fixture-root", type=Path, default=DEFAULT_FIXTURE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--clean-fixture-after", action="store_true", help="Remove the ignored fixture tree after writing the proof JSON.")
    args = parser.parse_args()

    paths = build_fixture(args.fixture_root)
    result = build_status_model(
        stock_mods=paths["stock"],
        user_mods=paths["user"],
        custom_catalog=paths["catalog"],
        save_dir=paths["save"],
        world_name="Sandbox World",
    )
    assert_fixture_status(result)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    write_json(args.output, result)
    print(json.dumps(result, indent=2, sort_keys=True))
    print(f"wrote status proof: {args.output}")
    print(f"fixture root: {args.fixture_root}")
    if args.clean_fixture_after:
        shutil.rmtree(args.fixture_root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
