#!/usr/bin/env python3
"""Prove a sandbox active generated C-AOL summary root reaches prompt construction.

Slice 4 proof boundary: build a tiny C-AOL-like sandbox under .proof-cache/,
activate a source mod plus a generated companion summary mod in sandbox mods.json,
derive the same active summary roots C-AOL's background_summary_data_roots() uses,
and drive C-AOL's deterministic npc_harness.py far enough to render a prompt with
that generated bundle as your_tone / your_example_expression.

This is a deterministic C-AOL harness/source proof. It does not mutate Josef's real
Application Support tree, launch C-AOL, call a backend, use API secrets, pull models,
or modify the C-AOL checkout.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PROOF_ROOT = ROOT / ".proof-cache" / "caol-runtime-summary-consumption"
DEFAULT_CAOL_ROOT = Path("/Users/josefhorvath/Schanigarten/Cataclysm-AOL")
WORLD_NAME = "Sandbox World"
SOURCE_MOD_ID = "fixture_runtime_context_stock"
SOURCE_MOD_NAME = "Fixture Runtime Context Stock"
COMPANION_MOD_ID = f"lacapult_summary_{SOURCE_MOD_ID}"
NPC_NAME = "Lacapult Runtime Fixture NPC"
SUMMARY_SELECTOR = f"name:{NPC_NAME}"
SUMMARY_TOPIC = "TALK_LACAPULT_RUNTIME_FIXTURE"
SUMMARY_BACKGROUND = "The generated companion pack makes this NPC speak with sandbox runtime-proof context."
SUMMARY_EXPRESSION = "Mention the Lacapult-generated summary only because the active companion root supplied it."
SOURCE_TAG = f"lacapult-generated:{SOURCE_MOD_ID}:slice4"
SUMMARY_REL = Path("npcs") / "Backgrounds" / "Summaries_extra" / f"generated_{SOURCE_MOD_ID}.json"
MANIFEST_REL = Path("lacapult_summary_pack_manifest.json")


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def run_capture(command: list[str], *, cwd: Path, stdout_path: Path, stderr_path: Path) -> subprocess.CompletedProcess[str]:
    stdout_path.parent.mkdir(parents=True, exist_ok=True)
    stderr_path.parent.mkdir(parents=True, exist_ok=True)
    with stdout_path.open("w", encoding="utf-8") as stdout, stderr_path.open("w", encoding="utf-8") as stderr:
        return subprocess.run(command, cwd=cwd, text=True, stdout=stdout, stderr=stderr, check=False)


def git_current_branch(repo: Path) -> str:
    proc = subprocess.run(
        ["git", "-C", str(repo), "branch", "--show-current"],
        text=True,
        capture_output=True,
        check=False,
    )
    return proc.stdout.strip() if proc.returncode == 0 else ""


def line_hits(path: Path, needles: list[str]) -> dict[str, list[int]]:
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    result: dict[str, list[int]] = {}
    for needle in needles:
        result[needle] = [index for index, line in enumerate(lines, start=1) if needle in line]
    return result


def modinfo(mod_id: str, name: str, *, dependencies: list[str] | None = None) -> list[dict[str, Any]]:
    return [
        {
            "type": "MOD_INFO",
            "id": mod_id,
            "name": name,
            "category": "content",
            "dependencies": dependencies or [],
            "description": "Sandbox fixture mod for Lacapult C-AOL runtime summary consumption proof.",
        }
    ]


def write_mod(root: Path, dirname: str, modinfo_data: Any, extra_files: dict[str, Any] | None = None) -> Path:
    mod_dir = root / dirname
    mod_dir.mkdir(parents=True, exist_ok=True)
    write_json(mod_dir / "modinfo.json", modinfo_data)
    for rel, payload in (extra_files or {}).items():
        write_json(mod_dir / rel, payload)
    return mod_dir


def build_sandbox(proof_root: Path) -> dict[str, Path]:
    if proof_root.exists():
        shutil.rmtree(proof_root)
    core_json = proof_root / "sandbox" / "game0" / "data" / "json"
    stock = proof_root / "sandbox" / "game0" / "data" / "mods"
    user = proof_root / "sandbox" / "userdata" / "mods"
    save = proof_root / "sandbox" / "userdata" / "save"
    world = save / WORLD_NAME
    world_mods = world / "mods"

    core_json.mkdir(parents=True, exist_ok=True)
    world_mods.mkdir(parents=True, exist_ok=True)
    write_mod(stock, "dda", modinfo("dda", "Dark Days Ahead Core"))
    write_mod(
        stock,
        SOURCE_MOD_ID,
        modinfo(SOURCE_MOD_ID, SOURCE_MOD_NAME, dependencies=["dda"]),
        {
            "items/context.json": [
                {
                    "type": "GENERIC",
                    "id": "fixture_runtime_context_item",
                    "name": "fixture runtime context item",
                    "description": "Tiny contextual item proving this packaged mod has world/NPC context worth summarizing.",
                }
            ]
        },
    )

    companion_summary = {
        "type": "npc_personality_summary_bundle",
        "version": 1,
        "entries": [
            {
                "type": "npc_personality_summary",
                "selector": SUMMARY_SELECTOR,
                "topic": SUMMARY_TOPIC,
                "your_background": SUMMARY_BACKGROUND,
                "your_expression": SUMMARY_EXPRESSION,
                "source_tag": SOURCE_TAG,
            }
        ],
    }
    companion_manifest = {
        "type": "lacapult_summary_pack_manifest",
        "version": 1,
        "source_mod_id": SOURCE_MOD_ID,
        "source_mod_name": SOURCE_MOD_NAME,
        "source_fingerprint": "fixture-runtime-proof",
        "generated_at": "2026-04-25T00:00:00Z",
        "backend": "fixture-no-backend-call",
        "model": "fixture-runtime-summary-consumption-proof",
        "target_schema": "c-aol npc_personality_summary_bundle v1",
        "generated_paths": ["modinfo.json", MANIFEST_REL.as_posix(), SUMMARY_REL.as_posix()],
    }
    companion = write_mod(
        user,
        COMPANION_MOD_ID,
        modinfo(COMPANION_MOD_ID, f"Generated summaries for {SOURCE_MOD_NAME}", dependencies=[SOURCE_MOD_ID]),
        {MANIFEST_REL.as_posix(): companion_manifest, SUMMARY_REL.as_posix(): companion_summary},
    )

    world.mkdir(parents=True, exist_ok=True)
    write_json(world / "mods.json", ["dda", SOURCE_MOD_ID, COMPANION_MOD_ID])
    return {"stock": stock, "user": user, "save": save, "world": world, "companion": companion}


def resolve_mod_roots(paths: dict[str, Path], order: list[str]) -> list[dict[str, str]]:
    roots: list[dict[str, str]] = []
    for mod_id in order:
        for source_type, root in (("stock", paths["stock"]), ("user", paths["user"]), ("world-custom", paths["world"] / "mods")):
            candidate = root / mod_id
            if candidate.exists():
                roots.append({"id": mod_id, "source_type": source_type, "path": candidate.as_posix()})
                break
        else:
            roots.append({"id": mod_id, "source_type": "missing", "path": ""})
    return roots


def build_scenario(proof_root: Path) -> Path:
    scenario = {
        "npc_name": NPC_NAME,
        "player_name": "Sandbox Survivor",
        "player_utterance": "What do you know about this place?",
        "profession": "runtime proof witness",
        "chatbin": {"first_topic": SUMMARY_TOPIC},
        "expectations": {
            "selector_equals": SUMMARY_SELECTOR,
            "source_tag_contains": SOURCE_TAG,
        },
    }
    scenario_path = proof_root / "scenario" / "lacapult_runtime_fixture_npc.json"
    write_json(scenario_path, scenario)
    return scenario_path


def assert_file_contains(path: Path, expected: str) -> None:
    text = path.read_text(encoding="utf-8", errors="replace")
    if expected not in text:
        raise AssertionError(f"{path} did not contain expected text: {expected}")


def prove(args: argparse.Namespace) -> dict[str, Any]:
    caol_root = args.caol_root.resolve()
    if not caol_root.exists():
        raise AssertionError(f"C-AOL root does not exist: {caol_root}")
    harness = caol_root / "tools" / "llm_runner" / "npc_harness.py"
    llm_intent = caol_root / "src" / "llm_intent.cpp"
    if not harness.exists():
        raise AssertionError(f"C-AOL npc_harness.py is missing: {harness}")
    if not llm_intent.exists():
        raise AssertionError(f"C-AOL llm_intent.cpp is missing: {llm_intent}")

    paths = build_sandbox(args.proof_root)
    scenario_path = build_scenario(args.proof_root)
    active_order = read_json(paths["world"] / "mods.json")
    if not isinstance(active_order, list):
        raise AssertionError("sandbox mods.json did not contain a list")
    active_order = [str(item) for item in active_order]
    active_mod_roots = resolve_mod_roots(paths, active_order)
    companion_root = paths["companion"]
    companion_summary_root = companion_root / "npcs" / "Backgrounds" / "Summaries_extra"
    if not companion_summary_root.exists():
        raise AssertionError("generated companion Summaries_extra root was not created")
    if not any(entry["id"] == COMPANION_MOD_ID and entry["path"] == companion_root.as_posix() for entry in active_mod_roots):
        raise AssertionError("active mods.json order did not resolve to the generated companion root")

    evidence_dir = args.proof_root / "evidence"
    command_base = [
        args.python_path,
        str(harness),
        "--scenario",
        str(scenario_path),
        "--summary-root",
        str(paths["stock"] / SOURCE_MOD_ID),
        "--summary-root",
        str(companion_root),
    ]
    resolve_stdout = evidence_dir / "npc_harness_resolve.json"
    resolve_stderr = evidence_dir / "npc_harness_resolve.stderr.log"
    resolve_proc = run_capture(
        command_base + ["--resolve-only", "--json"],
        cwd=caol_root,
        stdout_path=resolve_stdout,
        stderr_path=resolve_stderr,
    )
    if resolve_proc.returncode != 0:
        raise AssertionError(f"npc_harness resolve failed; see {resolve_stdout} / {resolve_stderr}")
    resolve_json = read_json(resolve_stdout)
    snapshot_fields = resolve_json.get("snapshot_fields") or {}
    if resolve_json.get("selected_selector") != SUMMARY_SELECTOR:
        raise AssertionError(f"unexpected selected selector: {resolve_json.get('selected_selector')}")
    if snapshot_fields.get("your_tone") != SUMMARY_BACKGROUND:
        raise AssertionError("your_tone did not come from generated companion summary")
    if snapshot_fields.get("your_example_expression") != SUMMARY_EXPRESSION:
        raise AssertionError("your_example_expression did not come from generated companion summary")

    prompt_stdout = evidence_dir / "npc_harness_prompt.txt"
    prompt_stderr = evidence_dir / "npc_harness_prompt.stderr.log"
    prompt_proc = run_capture(
        command_base + ["--dump-prompt"],
        cwd=caol_root,
        stdout_path=prompt_stdout,
        stderr_path=prompt_stderr,
    )
    if prompt_proc.returncode != 0:
        raise AssertionError(f"npc_harness prompt dump failed; see {prompt_stdout} / {prompt_stderr}")
    assert_file_contains(prompt_stdout, f"your_tone: {SUMMARY_BACKGROUND}")
    assert_file_contains(prompt_stdout, f"your_example_expression: {SUMMARY_EXPRESSION}")

    source_hits = line_hits(
        llm_intent,
        [
            "background_summary_data_roots()",
            "active_mod_order",
            "PATH_INFO::world_base_save_path() / \"mods\"",
            "Summaries_short",
            "Summaries_extra",
            "your_tone:",
            "your_example_expression:",
            "has_array( \"entries\" )",
        ],
    )
    required_hits = [
        "background_summary_data_roots()",
        "active_mod_order",
        "Summaries_extra",
        "your_tone:",
        "your_example_expression:",
    ]
    missing = [needle for needle in required_hits if not source_hits.get(needle)]
    if missing:
        raise AssertionError(f"C-AOL source inspection missing required prompt/root seam tokens: {missing}")

    evidence = {
        "claim": "sandbox active generated companion summary root reaches C-AOL deterministic prompt construction",
        "evidence_class": "deterministic C-AOL npc_harness.py + C++ source seam inspection; not a live game process",
        "caol_root": caol_root.as_posix(),
        "caol_branch": git_current_branch(caol_root),
        "sandbox_world": (paths["world"]).as_posix(),
        "mods_json_order": active_order,
        "active_mod_roots": active_mod_roots,
        "cxx_equivalent_summary_roots": [
            (args.proof_root / "sandbox" / "game0" / "data" / "json").as_posix(),
            *[entry["path"] for entry in active_mod_roots if entry["path"]],
            (paths["world"] / "mods").as_posix(),
        ],
        "generated_companion_root": companion_root.as_posix(),
        "generated_summary_root": companion_summary_root.as_posix(),
        "generated_summary_file": (companion_root / SUMMARY_REL).as_posix(),
        "scenario": scenario_path.as_posix(),
        "npc_harness_command_resolve": command_base + ["--resolve-only", "--json"],
        "npc_harness_command_prompt": command_base + ["--dump-prompt"],
        "npc_harness_resolve_json": resolve_stdout.as_posix(),
        "npc_harness_prompt": prompt_stdout.as_posix(),
        "selected_selector": resolve_json.get("selected_selector"),
        "resolution_kind": resolve_json.get("resolution_kind"),
        "summary": resolve_json.get("summary"),
        "snapshot_fields": snapshot_fields,
        "source_inspection": {
            "file": llm_intent.as_posix(),
            "line_hits": source_hits,
        },
        "verdict": "passed",
        "caveat": "This proves C-AOL's deterministic Python NPC harness consumes the active companion-style root when supplied from the sandbox-derived active mod order, and C++ source inspection shows the live runtime derives roots from active_world->active_mod_order and emits the same prompt fields. It does not launch a compiled C-AOL world from this Lacapult sandbox.",
    }
    evidence_path = evidence_dir / "evidence.json"
    write_json(evidence_path, evidence)
    return evidence


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--proof-root", type=Path, default=DEFAULT_PROOF_ROOT)
    parser.add_argument("--caol-root", type=Path, default=DEFAULT_CAOL_ROOT)
    parser.add_argument("--python-path", default="python3")
    args = parser.parse_args()
    evidence = prove(args)
    print(json.dumps(evidence, indent=2, sort_keys=True))
    print(f"wrote runtime summary consumption proof: {args.proof_root / 'evidence' / 'evidence.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
