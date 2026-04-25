#!/usr/bin/env python3
"""Prove Slice 5 C-AOL summary error/rollback fixture coverage.

This is a sandbox-only safety proof. It builds weird C-AOL-like mod fixtures under
.proof-cache/, drives the read-only status model across broken metadata, content
parse errors, missing dependencies, obsolete mods, partial/stale/conflicting
summary packs, backend-not-ready gating, and proves replacing an existing generated
companion pack can be rolled back to the exact prior pack plus mods.json bytes.

No real Application Support, installed C-AOL tree, backend/API secret, model pull,
OpenVINO install, release signing, or upstream package path is touched.
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
DEFAULT_ROOT = ROOT / ".proof-cache" / "caol-summary-error-matrix"
WORLD_NAME = "Sandbox World"
PROOF_TIMESTAMP = "2026-04-25T00:00:00Z"
SUMMARY_REL = Path("npcs") / "Backgrounds" / "Summaries_extra" / "generated.json"
MANIFEST_REL = Path("lacapult_summary_pack_manifest.json")


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def write_mod(root: Path, dirname: str, modinfo_data: Any | None, extra_files: dict[str, Any] | None = None) -> Path:
    mod_dir = root / dirname
    mod_dir.mkdir(parents=True, exist_ok=True)
    if modinfo_data is not None:
        if isinstance(modinfo_data, str):
            (mod_dir / "modinfo.json").write_text(modinfo_data, encoding="utf-8")
        else:
            write_json(mod_dir / "modinfo.json", modinfo_data)
    for rel, payload in (extra_files or {}).items():
        target = mod_dir / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        if isinstance(payload, str):
            target.write_text(payload, encoding="utf-8")
        else:
            write_json(target, payload)
    return mod_dir


def modinfo(mod_id: str, name: str, *, dependencies: list[str] | None = None, obsolete: bool = False) -> list[dict[str, Any]]:
    return [
        {
            "type": "MOD_INFO",
            "id": mod_id,
            "name": name,
            "category": "content",
            "dependencies": dependencies or [],
            "obsolete": obsolete,
            "description": "Slice 5 sandbox fixture mod for Lacapult C-AOL summary safety proof.",
        }
    ]


def contextual_item(item_id: str) -> list[dict[str, str]]:
    return [
        {
            "type": "GENERIC",
            "id": item_id,
            "name": item_id,
            "description": "Fixture contextual item so the Summarizer status model has real context to classify.",
        }
    ]


def summary_bundle(selector: str, topic: str, text: str) -> dict[str, Any]:
    return {
        "type": "npc_personality_summary_bundle",
        "version": 1,
        "entries": [
            {
                "type": "npc_personality_summary",
                "selector": selector,
                "topic": topic,
                "your_background": text,
                "your_expression": text,
                "source_tag": f"lacapult-generated:{selector}:{topic}",
            }
        ],
    }


def generated_manifest(source_mod_id: str, source_name: str, source_fingerprint: str) -> dict[str, Any]:
    return {
        "type": "lacapult_summary_pack_manifest",
        "version": 1,
        "source_mod_id": source_mod_id,
        "source_mod_name": source_name,
        "source_fingerprint": source_fingerprint,
        "generated_at": PROOF_TIMESTAMP,
        "backend": "fixture-no-backend-call",
        "model": "slice5-error-matrix-fixture",
        "target_schema": "c-aol npc_personality_summary_bundle v1",
        "generated_paths": ["modinfo.json", MANIFEST_REL.as_posix(), SUMMARY_REL.as_posix()],
    }


def write_generated_pack(user_root: Path, pack_id: str, source_id: str, source_name: str, source_fingerprint: str, *, selector: str, topic: str, text: str) -> Path:
    return write_mod(
        user_root,
        pack_id,
        modinfo(pack_id, f"Generated summaries for {source_name}", dependencies=[source_id]),
        {
            MANIFEST_REL.as_posix(): generated_manifest(source_id, source_name, source_fingerprint),
            SUMMARY_REL.as_posix(): summary_bundle(selector, topic, text),
        },
    )


def compare_dirs(left: Path, right: Path) -> bool:
    comparison = filecmp.dircmp(left, right)
    if comparison.left_only or comparison.right_only or comparison.diff_files or comparison.funny_files:
        return False
    return all(compare_dirs(Path(comparison.left) / name, Path(comparison.right) / name) for name in comparison.common_dirs)


def build_fixture(root: Path) -> dict[str, Path]:
    if root.exists():
        shutil.rmtree(root)
    stock = root / "sandbox" / "game0" / "data" / "mods"
    user = root / "sandbox" / "userdata" / "mods"
    catalog = root / "sandbox" / "mod_repo"
    save = root / "sandbox" / "userdata" / "save"
    world = save / WORLD_NAME

    write_mod(stock, "dda", modinfo("dda", "Dark Days Ahead Core"))
    write_mod(stock, "fixture_broken_metadata", "{ this is not json")
    write_mod(
        stock,
        "fixture_content_parse_error",
        modinfo("fixture_content_parse_error", "Fixture Content Parse Error"),
        {"items/broken.json": "{ also not json"},
    )
    write_mod(
        stock,
        "fixture_missing_dep",
        modinfo("fixture_missing_dep", "Fixture Missing Dependency", dependencies=["fixture_absent_dependency"]),
        {"items/context.json": contextual_item("fixture_missing_dep_item")},
    )
    write_mod(
        stock,
        "fixture_obsolete",
        modinfo("fixture_obsolete", "Fixture Obsolete", obsolete=True),
        {"items/context.json": contextual_item("fixture_obsolete_item")},
    )
    partial = write_mod(
        stock,
        "fixture_partial_summary",
        modinfo("fixture_partial_summary", "Fixture Partial Summary"),
        {"items/context.json": contextual_item("fixture_partial_item")},
    )
    (partial / "npcs" / "Backgrounds" / "Summaries_extra").mkdir(parents=True, exist_ok=True)
    write_mod(
        stock,
        "fixture_backend_blocked",
        modinfo("fixture_backend_blocked", "Fixture Backend Blocked"),
        {"items/context.json": contextual_item("fixture_backend_blocked_item")},
    )

    stale_source = write_mod(
        stock,
        "fixture_stale_source",
        modinfo("fixture_stale_source", "Fixture Stale Source"),
        {"items/context.json": contextual_item("fixture_stale_item")},
    )
    write_generated_pack(
        user,
        "lacapult_summary_fixture_stale_source",
        "fixture_stale_source",
        "Fixture Stale Source",
        "sha256:intentionally-stale-source-fingerprint",
        selector="fixture:stale",
        topic="stale-context",
        text="old stale generated text",
    )

    conflict_source = write_mod(
        stock,
        "fixture_conflict_source",
        modinfo("fixture_conflict_source", "Fixture Conflict Source"),
        {"items/context.json": contextual_item("fixture_conflict_item")},
    )
    conflict_fingerprint = tree_fingerprint(conflict_source)
    for suffix in ("a", "b"):
        write_generated_pack(
            user,
            f"lacapult_summary_fixture_conflict_source_{suffix}",
            "fixture_conflict_source",
            "Fixture Conflict Source",
            conflict_fingerprint,
            selector="fixture:conflict",
            topic="same-topic",
            text=f"conflicting generated text {suffix}",
        )

    replacement_source = write_mod(
        stock,
        "fixture_replacement_source",
        modinfo("fixture_replacement_source", "Fixture Replacement Source"),
        {"items/context.json": contextual_item("fixture_replacement_item")},
    )
    replacement_fingerprint = tree_fingerprint(replacement_source)
    write_generated_pack(
        user,
        "lacapult_summary_fixture_replacement_source",
        "fixture_replacement_source",
        "Fixture Replacement Source",
        replacement_fingerprint,
        selector="fixture:replacement",
        topic="replacement-topic",
        text="original preexisting generated text",
    )

    catalog.mkdir(parents=True, exist_ok=True)
    world.mkdir(parents=True, exist_ok=True)
    write_json(
        world / "mods.json",
        [
            "dda",
            "fixture_stale_source",
            "lacapult_summary_fixture_stale_source",
            "fixture_conflict_source",
            "lacapult_summary_fixture_conflict_source_a",
            "lacapult_summary_fixture_conflict_source_b",
            "fixture_replacement_source",
            "lacapult_summary_fixture_replacement_source",
            "fixture_backend_blocked",
        ],
    )
    return {"stock": stock, "user": user, "catalog": catalog, "save": save, "world": world}


def build_status(paths: dict[str, Path]) -> dict[str, Any]:
    return build_status_model(
        stock_mods=paths["stock"],
        user_mods=paths["user"],
        custom_catalog=paths["catalog"],
        save_dir=paths["save"],
        world_name=WORLD_NAME,
        backend_gate={
            "mode": "api",
            "status": "api_python_ready_any_llm_missing_missing_any_llm_model_configured_api_key_env_not_set_no_secret_used",
        },
    )


def find_record(status: dict[str, Any], mod_id: str, source_type: str) -> dict[str, Any]:
    matches = [record for record in status["mods"] if record["id"] == mod_id and record["source_type"] == source_type]
    if len(matches) != 1:
        raise AssertionError(f"expected one {mod_id}/{source_type}, found {len(matches)}")
    return matches[0]


def require_badge(status: dict[str, Any], mod_id: str, source_type: str, badge: str) -> None:
    record = find_record(status, mod_id, source_type)
    if badge != record.get("summary_status") and badge not in record.get("status_badges", []):
        raise AssertionError(f"{mod_id}/{source_type} missing {badge}: {record.get('status_badges')}")


def assert_status_matrix(status: dict[str, Any]) -> dict[str, Any]:
    expected = [
        ("fixture_broken_metadata", "stock", "metadata-broken"),
        ("fixture_broken_metadata", "stock", "summary-unknown"),
        ("fixture_content_parse_error", "stock", "content-parse-error"),
        ("fixture_content_parse_error", "stock", "summary-unknown"),
        ("fixture_missing_dep", "stock", "dependency-blocked"),
        ("fixture_obsolete", "stock", "obsolete-blocked"),
        ("fixture_partial_summary", "stock", "summary-partial"),
        ("fixture_stale_source", "stock", "summary-stale"),
        ("fixture_conflict_source", "stock", "summary-conflict"),
        ("fixture_backend_blocked", "stock", "summary-missing"),
        ("fixture_backend_blocked", "stock", "backend-not-ready"),
        ("fixture_backend_blocked", "stock", "summary-blocked"),
    ]
    for mod_id, source_type, badge in expected:
        require_badge(status, mod_id, source_type, badge)

    missing_roots = find_record(status, "fixture_backend_blocked", "stock")["summary_roots"]
    if missing_roots["summaries_short_exists"] or missing_roots["summaries_extra_exists"]:
        raise AssertionError("missing-roots fixture unexpectedly had summary root directories")

    ids = sorted({mod_id for mod_id, _source_type, _badge in expected})
    return {mod_id: find_record(status, mod_id, "stock") for mod_id in ids}


def apply_replacement_then_rollback(paths: dict[str, Path], proof_root: Path) -> dict[str, Any]:
    source_id = "fixture_replacement_source"
    source_name = "Fixture Replacement Source"
    pack_id = "lacapult_summary_fixture_replacement_source"
    pack_dir = paths["user"] / pack_id
    source_dir = paths["stock"] / source_id
    world_mods = paths["world"] / "mods.json"
    backup_dir = proof_root / "backups" / "replacement_apply"
    staging_dir = proof_root / "staging" / pack_id

    if backup_dir.exists():
        shutil.rmtree(backup_dir)
    if staging_dir.exists():
        shutil.rmtree(staging_dir)
    backup_dir.mkdir(parents=True)

    mods_before_text = world_mods.read_text(encoding="utf-8")
    mods_before_path = backup_dir / "mods.json.before.exact"
    mods_before_path.write_text(mods_before_text, encoding="utf-8")
    pack_backup = backup_dir / "summary_pack.before"
    shutil.copytree(pack_dir, pack_backup)

    old_summary_text = (pack_dir / SUMMARY_REL).read_text(encoding="utf-8")
    new_fingerprint = tree_fingerprint(source_dir)
    write_generated_pack(
        proof_root / "staging",
        pack_id,
        source_id,
        source_name,
        new_fingerprint,
        selector="fixture:replacement",
        topic="replacement-topic",
        text="replacement generated text that must disappear after rollback",
    )
    shutil.rmtree(pack_dir)
    shutil.copytree(staging_dir, pack_dir)

    order = [str(item) for item in read_json(world_mods)]
    cleaned = [item for item in order if item != pack_id]
    source_index = cleaned.index(source_id)
    cleaned.insert(source_index + 1, pack_id)
    write_json(world_mods, cleaned)
    if "replacement generated text" not in (pack_dir / SUMMARY_REL).read_text(encoding="utf-8"):
        raise AssertionError("replacement pack was not applied")

    world_mods.write_text(mods_before_path.read_text(encoding="utf-8"), encoding="utf-8")
    shutil.rmtree(pack_dir)
    shutil.copytree(pack_backup, pack_dir)

    if world_mods.read_text(encoding="utf-8") != mods_before_text:
        raise AssertionError("rollback did not restore mods.json bytes exactly")
    if not compare_dirs(pack_dir, pack_backup):
        raise AssertionError("rollback did not restore preexisting generated pack exactly")
    if (pack_dir / SUMMARY_REL).read_text(encoding="utf-8") != old_summary_text:
        raise AssertionError("rollback did not restore old summary text")

    return {
        "source_mod_id": source_id,
        "pack_id": pack_id,
        "backup_dir": backup_dir.as_posix(),
        "mods_json_restored_exactly": True,
        "preexisting_pack_restored_exactly": True,
        "replacement_pack_removed": "replacement generated text" not in (pack_dir / SUMMARY_REL).read_text(encoding="utf-8"),
    }


def compact_records(records: dict[str, dict[str, Any]]) -> dict[str, Any]:
    return {
        mod_id: {
            "summary_status": record.get("summary_status"),
            "status_badges": record.get("status_badges"),
            "missing_dependencies": record.get("missing_dependencies"),
            "metadata_errors": record.get("metadata_errors"),
            "json_parse_errors_sample": record.get("json_content", {}).get("json_parse_errors_sample", []),
        }
        for mod_id, record in sorted(records.items())
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    args = parser.parse_args()

    paths = build_fixture(args.root)
    evidence_dir = args.root / "evidence"
    evidence_dir.mkdir(parents=True, exist_ok=True)

    initial_status = build_status(paths)
    write_json(evidence_dir / "status.initial.json", initial_status)
    matrix_records = assert_status_matrix(initial_status)
    rollback = apply_replacement_then_rollback(paths, args.root)
    rollback_status = build_status(paths)
    write_json(evidence_dir / "status.after_rollback.json", rollback_status)
    require_badge(rollback_status, "fixture_replacement_source", "stock", "summary-ready")

    evidence = {
        "proof": "caol_summary_slice5_error_rollback_matrix",
        "version": 1,
        "sandbox_root": (args.root / "sandbox").as_posix(),
        "evidence_dir": evidence_dir.as_posix(),
        "backend_gate": initial_status.get("backend_gate"),
        "weird_cases_covered": [
            "parse error / broken metadata",
            "content JSON parse error",
            "missing dependency",
            "obsolete mod",
            "partial summary root",
            "missing summary roots reported as summary-missing",
            "stale manifest/source fingerprint mismatch",
            "conflicting generated packs with overlapping selector/topic",
            "backend-not-ready generation gating/status",
            "preexisting generated pack replacement rollback restores prior pack and mods.json bytes",
        ],
        "status_counts": initial_status.get("counts", {}),
        "status_samples": compact_records(matrix_records),
        "rollback": rollback,
        "non_goals_observed": [
            "no real Application Support paths touched",
            "no backend/API/model call",
            "no model pull/download/install",
            "no OpenVINO install",
            "no C-AOL package mutation",
            "no signing/notarization/release publication",
        ],
        "verdict": "passed",
    }
    write_json(evidence_dir / "evidence.json", evidence)
    print(json.dumps(evidence, indent=2, sort_keys=True))
    print(f"wrote Slice 5 error matrix evidence: {evidence_dir / 'evidence.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
