#!/usr/bin/env python3
"""Static proof for Catapult-Dabubu Windows retest follow-up v2 backend/UI repairs.

No installs, model pulls, API calls, secrets, or user-data mutation.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
backend = (ROOT / "scripts" / "BackendConfigManager.gd").read_text(encoding="utf-8")
ui = (ROOT / "scripts" / "BackendSetupUI.gd").read_text(encoding="utf-8")

def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"v2 backend static proof failed: {message}")

require('const ANY_LLM_PIP_PACKAGE = "any-llm-sdk"' in backend, "any-llm-sdk package constant missing")
require('package_spec = "%s[%s]" % [ANY_LLM_PIP_PACKAGE, install_extra]' in backend, "provider extras are not built on any-llm-sdk")
require('any_llm[' not in backend and 'pip install --upgrade any_llm' not in backend + ui, "stale any_llm pip package target remains")
require('_python_import_status(py.get("command", ""), ["any_llm"])' in backend, "runtime import seam no longer checks any_llm")

require('var show_advanced_base_url = provider_id == "custom_any_llm"' in ui, "API base URL is not gated to custom/advanced provider")
require('_backend_endpoint.get_parent().visible = show_advanced_base_url' in ui, "normal API mode does not hide base URL row")
require('Advanced/custom base URL' in ui and 'normal providers use their default endpoint' in ui, "advanced/custom base URL wording missing")

require('const OLLAMA_MODEL_MISTRAL = "mistral:v0.3"' in backend + ui, "Mistral runtime tag is not mistral:v0.3")
require('const OLLAMA_MODEL_NEMOTRON = "mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest"' in backend + ui, "Nemotron runtime tag is not the pullable registry tag")
require('const OLLAMA_LABEL_MISTRAL = "Mistral v0.3"' in ui and 'const OLLAMA_LABEL_NEMOTRON = "Nemotron 9B"' in ui, "short Ollama selector labels missing")
require('_ollama_model_choice.set_item_metadata' in ui, "Ollama selector does not separate labels from runtime tags")
require('ollama pull mistral-v0.3' not in backend + ui and 'ollama pull nemotron-9b' not in backend + ui, "stale fake Ollama pull tags remain")

require('"ram_gib"' in backend and '"vram_gib"' in backend and 'performance_lights' in backend, "hardware check does not expose GiB/performance lights")
require('RAM: %.1f GiB   VRAM: %.1f GiB' in ui, "Ollama hardware UI does not render GiB values")
require('mistral:v0.3 performance' in ui and 'nemotron-9b performance' in ui, "model-specific performance light rows missing")
require('"Hardware check", "state": hardware.get("state"' not in ui, "old generic hardware status row remains")
require('Hardware check: RAM' not in ui, "old advisory hardware prose remains")

require('The launcher may appear to time out. Wait for Ollama installation to commence.' in backend, "short Ollama timeout note missing in setup plan")
require('The launcher may appear to time out. Wait for Ollama installation to commence.' in ui, "short Ollama timeout note missing in UI confirmation/status")
require('output_summary' in backend and 'Package setup output:' in ui, "API package failure output is not captured/surfaced")

require('RUNNER_TEST_INTENT_FILENAME = "caol_runner_test_intent.json"' in backend, "runner test intent file is missing")
require('build_backend_runner_test_plan' in backend and '_resolve_caol_runner_path' in backend, "runner test plan does not resolve C-AOL runner.py")
require('tools").plus_file("llm_runner").plus_file("runner.py")' in backend, "runner test does not target tools/llm_runner/runner.py")
require('"--backend"' in backend and '"--dry-run"' in backend and '"--self-test"' in backend, "runner test plan lacks backend/dry-run/self-test arguments")
require('performed_live_backend_call' in backend and 'API key values are never written' in backend, "runner test intent lacks live-call/secret boundary")
require('Test API runner' in ui and 'Test Ollama runner' in ui, "runner test buttons missing from API/Ollama UI")
require('_runner_test_proof_only_enabled' in ui and 'no API call' in ui and 'no Ollama request' in ui, "runner test proof/no-spend UI boundary missing")

print("Catapult-Dabubu v2 backend static proof passed")
print("  API setup uses any-llm-sdk[...] while preserving any_llm import checks")
print("  normal API base URL is hidden; custom/advanced override remains")
print("  Ollama selector labels are short and mapped to real runtime tags")
print("  hardware display uses GiB plus model-specific performance lights")
print("  package setup failures surface non-secret command output summaries")
print("  API/Ollama runner test buttons invoke C-AOL runner.py with proof-mode dry-run boundaries")
