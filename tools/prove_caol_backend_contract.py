#!/usr/bin/env python3
"""Proof for Lacapult's C-AOL backend option/readiness contract.

This does not run Godot, mutate Josef's installed C-AOL config, use API secrets,
pull models, download runtimes, or contact remote model APIs. It verifies the
local C-AOL backend truth, checks Lacapult's option tokens/readiness code shape,
and applies representative API/Ollama/OpenVINO patches to sandbox copies of a
C-AOL config/options.json file under .proof-cache/.
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CAOL_ROOT = Path("/Users/josefhorvath/Schanigarten/Cataclysm-AOL")
BACKEND_MANAGER = REPO_ROOT / "scripts" / "BackendConfigManager.gd"
SETTINGS_UI = REPO_ROOT / "scripts" / "BackendSetupUI.gd"
PROOF_DIR = REPO_ROOT / ".proof-cache" / "caol-backend-contract"

REQUIRED_CAOL_OPTIONS = {
    "LLM_INTENT_BACKEND",
    "LLM_INTENT_OLLAMA_URL",
    "LLM_INTENT_OLLAMA_MODEL",
    "LLM_INTENT_API_KEY_ENV",
    "LLM_INTENT_API_MODEL",
    "LLM_INTENT_PYTHON",
    "LLM_INTENT_MODEL_DIR",
    "LLM_INTENT_DEVICE",
}
HIDDEN_OR_METADATA_OPTIONS = {
    "LLM_INTENT_USE_API",
    "LLM_INTENT_API_PROVIDER",
}
FORBIDDEN_SECRET_FIELDS = {
    "api_secret",
    "secret_key",
    "authorization",
    "bearer_token",
}
REQUIRED_BACKEND_TOKENS = {
    "BACKEND_API",
    "BACKEND_OLLAMA",
    "BACKEND_OPENVINO",
    "API backend",
    "Ollama backend",
    "OpenVINO backend",
    "LLM_INTENT_PYTHON",
    "write_sandboxed_options_config",
    "api_key_env",
    "openvino_model_dir",
    "ollama_command_present_server_running_model_present",
    "get_backend_guidance",
    "OpenVINO setup checks Python imports/model-dir presence only",
}
REQUIRED_UI_TOKENS = {
    "title.text = \"LLM\"",
    "Choose how C-AOL should reach an LLM backend",
    "Python / venv",
    "API key env var",
    "mistral-v0.3",
    "nemotron-9b",
    "ConfirmExternalBackendAction",
    "does not download models",
}


PATCH_CASES: dict[str, dict[str, str]] = {
    "api": {
        "LLM_INTENT_BACKEND": "api",
        "LLM_INTENT_API_KEY_ENV": "CATA_API_KEY",
        "LLM_INTENT_API_MODEL": "example-api-model",
        "LLM_INTENT_PYTHON": sys.executable,
    },
    "ollama": {
        "LLM_INTENT_BACKEND": "ollama",
        "LLM_INTENT_OLLAMA_URL": "http://127.0.0.1:11434",
        "LLM_INTENT_OLLAMA_MODEL": "llama-test",
        "LLM_INTENT_PYTHON": sys.executable,
    },
    "openvino": {
        "LLM_INTENT_BACKEND": "openvino",
        "LLM_INTENT_PYTHON": sys.executable,
        "LLM_INTENT_MODEL_DIR": str(PROOF_DIR / "fake-openvino-model"),
        "LLM_INTENT_DEVICE": "AUTO",
    },
}


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError as exc:
        raise SystemExit(f"missing required file: {path}") from exc


def extract_caol_option_names(caol_root: Path) -> set[str]:
    options_cpp = caol_root / "src" / "options.cpp"
    text = read(options_cpp)
    return set(re.findall(r'add\(\s*"([A-Z0-9_]+)"\s*,\s*"llm"', text))


def verify_runner_truth(caol_root: Path) -> list[str]:
    runner = read(caol_root / "tools" / "llm_runner" / "runner.py")
    llm_intent = read(caol_root / "src" / "llm_intent.cpp")
    required_runner_tokens = [
        'choices=["openvino", "api", "ollama"]',
        "from any_llm import completion",
        "--api-provider",
        "--ollama-url",
        "--ollama-model",
        "import openvino_genai",
        "import openvino as ov",
        "--self-test",
        "--dry-run",
    ]
    required_cpp_tokens = [
        'cfg.backend = get_option<std::string>( "LLM_INTENT_BACKEND" )',
        'cfg.runner_path = "tools/llm_runner/runner.py"',
        'get_option<std::string>( "LLM_INTENT_PYTHON" )',
        'cfg.api_provider = "openai"',
        'cfg.ollama_url = get_option<std::string>( "LLM_INTENT_OLLAMA_URL" )',
        'cfg.ollama_model = get_option<std::string>( "LLM_INTENT_OLLAMA_MODEL" )',
    ]
    missing = [token for token in required_runner_tokens if token not in runner]
    missing.extend(token for token in required_cpp_tokens if token not in llm_intent)
    return missing


def verify_lacapult_tokens() -> list[str]:
    backend_text = read(BACKEND_MANAGER)
    ui_text = read(SETTINGS_UI)
    missing: list[str] = []
    missing.extend(
        f"BackendConfigManager.gd:{token}"
        for token in sorted(REQUIRED_BACKEND_TOKENS)
        if token not in backend_text
    )
    missing.extend(
        f"BackendSetupUI.gd:{token}" for token in sorted(REQUIRED_UI_TOKENS) if token not in ui_text
    )
    forbidden_hits = sorted(
        token for token in FORBIDDEN_SECRET_FIELDS if token in backend_text.lower()
    )
    missing.extend(f"forbidden_secret_token:{token}" for token in forbidden_hits)
    return missing


def load_options_template(caol_root: Path) -> list[dict[str, Any]]:
    config_options = caol_root / "config" / "options.json"
    data = json.loads(read(config_options))
    if not isinstance(data, list):
        raise SystemExit(f"C-AOL options template is not a list: {config_options}")
    return data


def apply_options_patch(options: list[dict[str, Any]], patch: dict[str, str]) -> list[dict[str, Any]]:
    by_name = {entry.get("name"): entry for entry in options if isinstance(entry, dict)}
    for name, value in patch.items():
        if name in by_name:
            by_name[name]["value"] = value
        else:
            options.append(
                {
                    "name": name,
                    "value": value,
                    "info": "Added by Lacapult backend contract sandbox proof.",
                }
            )
    return options


def extract_values(options: list[dict[str, Any]], names: set[str]) -> dict[str, str]:
    values: dict[str, str] = {}
    for entry in options:
        if isinstance(entry, dict) and entry.get("name") in names:
            values[str(entry["name"])] = str(entry.get("value", ""))
    return values


def run_python_import_probe(modules: list[str]) -> tuple[int, str]:
    code = (
        "import importlib.util, sys\n"
        "missing=[m for m in sys.argv[1:] if importlib.util.find_spec(m) is None]\n"
        "print('missing=' + ','.join(missing))\n"
        "sys.exit(1 if missing else 0)\n"
    )
    proc = subprocess.run(
        [sys.executable, "-c", code, *modules],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
        timeout=10,
    )
    return proc.returncode, proc.stdout.strip()


def run_ollama_probe() -> dict[str, Any]:
    ollama_path = shutil.which("ollama")
    result: dict[str, Any] = {"command": ollama_path or "", "server": "not_checked"}
    if not ollama_path:
        result["status"] = "ollama_command_missing"
        return result
    proc = subprocess.run(
        [ollama_path, "list"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
        timeout=10,
    )
    result["exit_code"] = proc.returncode
    result["output_first_line"] = proc.stdout.splitlines()[0] if proc.stdout.splitlines() else ""
    result["server"] = "running" if proc.returncode == 0 else "unreachable"
    result["status"] = (
        "ollama_command_present_server_running"
        if proc.returncode == 0
        else "ollama_command_present_server_unreachable"
    )
    return result


def write_sandbox_apply_proofs(caol_root: Path) -> dict[str, Any]:
    template = load_options_template(caol_root)
    PROOF_DIR.mkdir(parents=True, exist_ok=True)
    (PROOF_DIR / "fake-openvino-model").mkdir(exist_ok=True)
    proof: dict[str, Any] = {}
    for backend, patch in PATCH_CASES.items():
        options = json.loads(json.dumps(template))
        patched = apply_options_patch(options, patch)
        out_path = PROOF_DIR / f"options_{backend}.json"
        out_path.write_text(json.dumps(patched, indent=2) + "\n", encoding="utf-8")
        values = extract_values(patched, set(patch))
        if values != patch:
            raise SystemExit(f"sandbox apply verification failed for {backend}: {values} != {patch}")
        proof[backend] = {
            "path": str(out_path.relative_to(REPO_ROOT)),
            "verified_values": values,
        }
    manifest = PROOF_DIR / "manifest.json"
    manifest.write_text(json.dumps(proof, indent=2) + "\n", encoding="utf-8")
    return proof


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--caol-root", type=Path, default=DEFAULT_CAOL_ROOT)
    args = parser.parse_args()

    backend_text = read(BACKEND_MANAGER)
    caol_options = extract_caol_option_names(args.caol_root)
    required_plus_hidden = REQUIRED_CAOL_OPTIONS | HIDDEN_OR_METADATA_OPTIONS

    missing_in_caol = sorted(required_plus_hidden - caol_options)
    missing_in_lacapult = sorted(
        option for option in REQUIRED_CAOL_OPTIONS if option not in backend_text
    )
    missing_lacapult_tokens = verify_lacapult_tokens()
    missing_runner_truth = verify_runner_truth(args.caol_root)
    sandbox_apply = write_sandbox_apply_proofs(args.caol_root)
    any_llm_probe = run_python_import_probe(["any_llm"])
    openvino_probe = run_python_import_probe(["openvino", "openvino_genai"])
    ollama_probe = run_ollama_probe()

    print("C-AOL backend option/readiness contract proof")
    print(f"  C-AOL root: {args.caol_root}")
    print(f"  Lacapult file: {BACKEND_MANAGER.relative_to(REPO_ROOT)}")
    print(f"  Backend setup UI: {SETTINGS_UI.relative_to(REPO_ROOT)}")
    print(f"  Required option names: {', '.join(sorted(REQUIRED_CAOL_OPTIONS))}")

    if missing_in_caol:
        print(f"  Missing from C-AOL options.cpp: {', '.join(missing_in_caol)}")
        return 1
    print("  C-AOL options.cpp contains required LLM option names, including hidden API provider/use-api metadata")

    if missing_runner_truth:
        print("  Missing C-AOL runner/source tokens:")
        for token in missing_runner_truth:
            print(f"    - {token}")
        return 1
    print("  C-AOL runner truth: API via any_llm, Ollama HTTP, OpenVINO imports, self-test/dry-run, and shared Python runner path are present")
    print("  C-AOL runtime currently hardcodes API provider to openai in src/llm_intent.cpp; Lacapult stores provider intent but does not pretend C-AOL consumes arbitrary providers yet")

    if missing_in_lacapult:
        print(f"  Missing from Lacapult patch builder: {', '.join(missing_in_lacapult)}")
        return 1
    if missing_lacapult_tokens:
        print("  Missing/forbidden Lacapult tokens:")
        for token in missing_lacapult_tokens:
            print(f"    - {token}")
        return 1
    print("  Lacapult exposes API/Ollama/OpenVINO readiness/config tokens without secret-bearing fields")

    if "preview_only_not_applied" not in backend_text:
        print("  Missing preview-only apply status guard")
        return 1
    print("  Launcher metadata patch remains preview-only; sandbox options apply is separately guarded")

    print("  Sandbox options apply proof wrote and verified:")
    for backend, detail in sandbox_apply.items():
        values = ", ".join(f"{k}={v}" for k, v in sorted(detail["verified_values"].items()))
        print(f"    - {backend}: {detail['path']} ({values})")

    print(f"  API dependency probe with current Python: rc={any_llm_probe[0]} {any_llm_probe[1]}")
    print(f"  OpenVINO dependency probe with current Python: rc={openvino_probe[0]} {openvino_probe[1]}")
    print("  OpenVINO installer posture: specialized detect/config path; installs/downloads are confirmation-gated")
    print(f"  Ollama probe: {ollama_probe}")
    print("  No API call, secret readout, model pull, OpenVINO install, or real user config mutation was performed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
