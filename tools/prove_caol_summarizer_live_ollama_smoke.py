#!/usr/bin/env python3
"""Optional Slice 6 live-local Ollama smoke.

This proof is deliberately narrow: it only uses an already-local Ollama command,
server, and model inventory; it never pulls models, reads API secrets, installs
packages, or touches real C-AOL Application Support/userdata. If no suitable local
model is available, it records an honest blocked evidence JSON and exits 0 so the
optional smoke does not pretend CI has Josef's local models.
"""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
PROOF_DIR = ROOT / ".proof-cache" / "slice6-live-ollama-smoke"
PREFERRED_MODELS = [
    "mistral:latest",
    "mistral",
    "qwen2.5:3b",
    "gemma2:2b",
    "phi3:mini",
    "nemotron-4b:latest",
    "nemotron-9b-full:latest",
    "nemotron-9b-dumber:latest",
]


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")


def run(cmd: list[str], *, env: dict[str, str] | None = None, timeout: int = 60) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        cwd=ROOT,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout,
        check=False,
    )


def parse_ollama_list(text: str) -> list[str]:
    models: list[str] = []
    for line in text.splitlines()[1:]:
        parts = line.split()
        if parts:
            models.append(parts[0])
    return models


def choose_model(models: list[str]) -> str:
    requested = os.environ.get("LACAPULT_TEST_OLLAMA_MODEL", "").strip()
    if requested:
        return requested if requested in models else ""
    model_set = set(models)
    for candidate in PREFERRED_MODELS:
        if candidate in model_set:
            return candidate
    return models[0] if models else ""


def main() -> int:
    PROOF_DIR.mkdir(parents=True, exist_ok=True)
    evidence_path = PROOF_DIR / "latest.json"
    log_path = PROOF_DIR / "godot-live-ollama.log"
    ollama = shutil.which("ollama")
    if not ollama:
        write_json(evidence_path, {"status": "blocked_no_ollama_command", "no_model_pull": True})
        print(f"live Ollama smoke blocked: ollama command not found; evidence={evidence_path}")
        return 0

    listed = run([ollama, "list"], timeout=30)
    if listed.returncode != 0:
        write_json(evidence_path, {
            "status": "blocked_ollama_server_or_list_unavailable",
            "ollama_command": ollama,
            "ollama_list_output": listed.stdout[-4000:],
            "no_model_pull": True,
        })
        print(f"live Ollama smoke blocked: ollama list failed; evidence={evidence_path}")
        return 0

    models = parse_ollama_list(listed.stdout)
    model = choose_model(models)
    if not model:
        write_json(evidence_path, {
            "status": "blocked_no_suitable_local_model",
            "ollama_command": ollama,
            "local_models": models,
            "requested_model": os.environ.get("LACAPULT_TEST_OLLAMA_MODEL", ""),
            "preferred_models": PREFERRED_MODELS,
            "no_model_pull": True,
        })
        print(f"live Ollama smoke blocked: no suitable already-local model; evidence={evidence_path}")
        return 0

    godot = os.environ.get("GODOT_BIN", "").strip() or shutil.which("godot") or "/opt/homebrew/bin/godot"
    if not Path(godot).exists() and shutil.which(godot) is None:
        write_json(evidence_path, {"status": "blocked_godot_missing", "godot": godot, "model": model, "no_model_pull": True})
        print(f"live Ollama smoke blocked: Godot not found; evidence={evidence_path}")
        return 0

    with tempfile.TemporaryDirectory(prefix="lacapult-summarizer-apply-home.", dir="/tmp") as home:
        apply_json = PROOF_DIR / "godot-live-ollama-apply.json"
        env = os.environ.copy()
        env.pop("LACAPULT_SUMMARIZER_FIXTURE_BACKEND", None)
        env.update({
            "HOME": home,
            "LACAPULT_TEST_OLLAMA_MODEL": model,
            "LACAPULT_EXPECT_SUMMARIZER_BACKEND": "ollama",
            "LACAPULT_CAOL_SUMMARIZER_APPLY_OUTPUT": str(apply_json),
        })
        proc = run([godot, "--path", ".", "--no-window", "--script", "tools/godot_caol_summarizer_apply_smoke.gd"], env=env, timeout=120)
        log_path.write_text(proc.stdout, encoding="utf-8")
        if proc.returncode != 0:
            write_json(evidence_path, {
                "status": "failed_live_ollama_generation_or_apply",
                "ollama_command": ollama,
                "model": model,
                "local_models": models,
                "godot": godot,
                "log": str(log_path),
                "stdout_tail": proc.stdout[-4000:],
                "no_model_pull": True,
                "no_api_secret": True,
                "isolated_home_prefix": "/tmp/lacapult-summarizer-apply-home.*",
            })
            print(f"live Ollama smoke failed; evidence={evidence_path}; log={log_path}")
            return 1

    payload = json.loads(apply_json.read_text(encoding="utf-8"))
    result = payload.get("result", {})
    generation = result.get("generation", {})
    if result.get("applied") is not True or generation.get("backend_mode") != "ollama" or generation.get("model") != model:
        write_json(evidence_path, {
            "status": "failed_unexpected_apply_payload",
            "model": model,
            "generation": generation,
            "applied": result.get("applied"),
            "apply_json": str(apply_json),
            "log": str(log_path),
            "no_model_pull": True,
        })
        print(f"live Ollama smoke failed: unexpected apply payload; evidence={evidence_path}")
        return 1

    details = result.get("details", {})
    evidence = {
        "status": "passed_live_local_ollama_generation_apply",
        "ollama_command": ollama,
        "model": model,
        "model_source": "already-local `ollama list` inventory; no pull/download/install attempted",
        "local_models_seen": models,
        "backend_mode": generation.get("backend_mode"),
        "generation_message": generation.get("message"),
        "applied": True,
        "companion_pack_dir": details.get("companion_pack_dir"),
        "summaries_extra_json": details.get("summaries_extra_json"),
        "mods_json": details.get("mods_json"),
        "backup_dir": details.get("backup_dir"),
        "apply_json": str(apply_json),
        "log": str(log_path),
        "no_model_pull": True,
        "no_api_secret": True,
        "no_remote_api": True,
        "no_package_install": True,
        "isolated_home_prefix": "/tmp/lacapult-summarizer-apply-home.*",
    }
    write_json(evidence_path, evidence)
    print("live Ollama smoke passed: model=%s evidence=%s" % (model, evidence_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
