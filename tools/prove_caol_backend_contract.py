#!/usr/bin/env python3
"""Static proof for Lacapult's C-AOL backend option contract.

This does not run Godot, mutate C-AOL config, use API secrets, or pull models.
It verifies that Lacapult's preview patch names match option names present in a
local Cataclysm-AOL checkout.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CAOL_ROOT = Path("/Users/josefhorvath/Schanigarten/Cataclysm-AOL")
BACKEND_MANAGER = REPO_ROOT / "scripts" / "BackendConfigManager.gd"
REQUIRED_CAOL_OPTIONS = {
    "LLM_INTENT_BACKEND",
    "LLM_INTENT_OLLAMA_URL",
    "LLM_INTENT_OLLAMA_MODEL",
    "LLM_INTENT_API_KEY_ENV",
    "LLM_INTENT_API_MODEL",
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
    "openvino_selectable_setup_not_automated",
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


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--caol-root", type=Path, default=DEFAULT_CAOL_ROOT)
    args = parser.parse_args()

    backend_text = read(BACKEND_MANAGER)
    caol_options = extract_caol_option_names(args.caol_root)

    missing_in_caol = sorted(REQUIRED_CAOL_OPTIONS - caol_options)
    missing_in_lacapult = sorted(
        option for option in REQUIRED_CAOL_OPTIONS if option not in backend_text
    )
    forbidden_hits = sorted(
        token for token in FORBIDDEN_SECRET_FIELDS if token in backend_text.lower()
    )
    missing_backend_tokens = sorted(
        token for token in REQUIRED_BACKEND_TOKENS if token not in backend_text
    )

    print("C-AOL backend option contract proof")
    print(f"  C-AOL root: {args.caol_root}")
    print(f"  Lacapult file: {BACKEND_MANAGER.relative_to(REPO_ROOT)}")
    print(f"  Required option names: {', '.join(sorted(REQUIRED_CAOL_OPTIONS))}")

    if missing_in_caol:
        print(f"  Missing from C-AOL options.cpp: {', '.join(missing_in_caol)}")
        return 1
    print("  C-AOL options.cpp contains all required LLM option names")

    if missing_in_lacapult:
        print(f"  Missing from Lacapult patch builder: {', '.join(missing_in_lacapult)}")
        return 1
    print("  Lacapult patch builder references all required C-AOL option names")

    if forbidden_hits:
        print(f"  Forbidden secret-bearing field tokens found: {', '.join(forbidden_hits)}")
        return 1
    print("  No forbidden secret-bearing field tokens found in backend manager")

    if missing_backend_tokens:
        print(f"  Missing backend selector/status tokens: {', '.join(missing_backend_tokens)}")
        return 1
    print("  Backend manager exposes API, Ollama, and OpenVINO v0 selector/status tokens")

    if "preview_only_not_applied" not in backend_text:
        print("  Missing preview-only apply status guard")
        return 1
    print("  Patch is explicitly preview-only; no installed C-AOL config is mutated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
