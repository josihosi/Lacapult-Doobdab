extends Node

# Safe first-pass backend setup helper for C-AOL.
# This deliberately stores launcher-side metadata and environment-variable names,
# never API keys. Installed-game options writes are proof-only/sandbox-guarded in v0.

const BACKEND_API = "api"
const BACKEND_OLLAMA = "ollama"
const BACKEND_OPENVINO = "openvino"
const BACKEND_CONFIG_FILENAME = "caol_backend_setup.json"
const C_AOL_OPTIONS_PATCH_FILENAME = "caol_llm_options_patch.json"

const DEFAULT_API_PROVIDER = "openai"
const DEFAULT_API_KEY_ENV = "CATA_API_KEY"
const DEFAULT_OLLAMA_URL = "http://127.0.0.1:11434"
const DEFAULT_OPENVINO_DEVICE = "AUTO"

func get_supported_backends() -> Array:
	var python_path = _setting_or_default("backend_python_path", "")
	var api_model = _setting_or_default("backend_api_model", "")
	var api_provider = _setting_or_default("backend_api_provider", DEFAULT_API_PROVIDER)
	var api_key_env = _setting_or_default("backend_api_key_env", DEFAULT_API_KEY_ENV)
	var ollama_endpoint = _setting_or_default("backend_ollama_endpoint", DEFAULT_OLLAMA_URL)
	var ollama_model = _setting_or_default("backend_ollama_model", "")
	var openvino_model_dir = _setting_or_default("backend_openvino_model_dir", "")
	var openvino_device = _setting_or_default("backend_openvino_device", DEFAULT_OPENVINO_DEVICE)
	return [
		{
			"id": BACKEND_API,
			"label": "API backend",
			"recommendation_rank": 1,
			"recommendation": "Straightforward hosted path: use this when Python + AnyLLM and an API-key environment variable are already available.",
			"setup_role": "fastest_onboarding_debug",
			"v0_warning": "Lacapult stores provider/model/env-var metadata only; it never stores API keys or makes a live API call from this setup page.",
			"status": _detect_api_status(python_path, api_provider, api_model, api_key_env),
			"guidance": get_backend_guidance(BACKEND_API),
			"python_path": python_path,
			"api_provider": api_provider,
			"api_key_env": api_key_env,
			"secrets_policy": "Do not store or log API keys in Lacapult v0. Only the env-var name is stored."
		},
		{
			"id": BACKEND_OLLAMA,
			"label": "Ollama backend",
			"recommendation_rank": 2,
			"recommendation": "Mainstream local path: use when Ollama is installed, the local server is running, and a model is already present.",
			"setup_role": "mainstream_local",
			"v0_warning": "Lacapult detects command/server/model-list state only; it does not pull models or run an Ollama installer.",
			"status": _detect_ollama_status(ollama_endpoint, ollama_model),
			"guidance": get_backend_guidance(BACKEND_OLLAMA),
			"endpoint": ollama_endpoint,
			"model": ollama_model,
			"python_path": python_path
		},
		{
			"id": BACKEND_OPENVINO,
			"label": "OpenVINO backend",
			"recommendation_rank": 3,
			"recommendation": "Specialized local acceleration path: selectable for users who already have OpenVINO Python packages and a local model directory.",
			"setup_role": "specialized_detect_only",
			"v0_warning": "Lacapult v0 reports OpenVINO readiness only; it does not install runtimes, tokenizers, drivers, or download/convert models.",
			"status": _detect_openvino_status(python_path, openvino_model_dir),
			"guidance": get_backend_guidance(BACKEND_OPENVINO),
			"python_path": python_path,
			"model_dir": openvino_model_dir,
			"device": openvino_device
		},
	]


func get_backend_recommendation_summary() -> String:
	return "Setup paths: API / AnyLLM for a hosted backend, Ollama for mainstream local play, and OpenVINO for specialized local acceleration. This page saves metadata/status only: no API call, model pull, package install, generated summary-pack apply, or real C-AOL config mutation happens without an explicit confirmation step."

func get_backend_guidance(mode: String) -> String:
	if mode == BACKEND_API:
		return "Install Python plus the AnyLLM package/provider extra in the Python/venv selected here; set the named API-key environment variable outside Lacapult. Lacapult can check imports and env-var presence, but never reads or stores the secret."
	if mode == BACKEND_OLLAMA:
		return "Install Ollama for this OS, start the local server, and select a model already present in `ollama list`. Lacapult checks presence only and will not pull models without permission."
	if mode == BACKEND_OPENVINO:
		return "Select a Python/venv with OpenVINO packages and a local model directory; Lacapult checks imports/model path but does not install runtimes or download models without confirmation."
	return "Unsupported backend."


func check_backend_status(mode: String, endpoint: String = "", model: String = "", python_path: String = "", api_provider: String = DEFAULT_API_PROVIDER, api_key_env: String = DEFAULT_API_KEY_ENV, openvino_model_dir: String = "", openvino_device: String = DEFAULT_OPENVINO_DEVICE) -> String:
	if not mode in [BACKEND_API, BACKEND_OLLAMA, BACKEND_OPENVINO]:
		return "unsupported_backend"
	var normalized = _normalize_backend_fields(mode, endpoint, model, python_path, api_provider, api_key_env, openvino_model_dir, openvino_device)
	return _detect_backend_status(mode, normalized)


func get_status_light(raw_status: String) -> Dictionary:
	if raw_status == "ok":
		return {"icon": "🟢", "state": "Ready", "summary": "Options saved."}
	if raw_status.find("unsupported") >= 0 or raw_status.find("write_error") >= 0 or raw_status.find("config_dir_error") >= 0:
		return {"icon": "🔴", "state": "Error", "summary": "Save/check failed."}
	if raw_status.find("api_python_missing") >= 0 or raw_status.find("ollama_command_missing") >= 0 or raw_status.find("openvino_python_missing") >= 0:
		return {"icon": "🔴", "state": "Missing", "summary": _status_summary(raw_status)}
	if raw_status.find("api_python_ready_any_llm_import_ok") >= 0 and raw_status.find("model_configured") >= 0 and raw_status.find("api_key_env_present_secret_not_read") >= 0:
		return {"icon": "🟢", "state": "Ready", "summary": "Python, AnyLLM, model, and API-key env-var are present."}
	if raw_status.find("ollama_command_present_server_running_model_present") >= 0:
		return {"icon": "🟢", "state": "Ready", "summary": "Ollama server and selected model are present."}
	return {"icon": "🟡", "state": "Needs action", "summary": _status_summary(raw_status)}


func write_launcher_backend_config(mode: String, endpoint: String = "", model: String = "", python_path: String = "", api_provider: String = DEFAULT_API_PROVIDER, api_key_env: String = DEFAULT_API_KEY_ENV, openvino_model_dir: String = "", openvino_device: String = DEFAULT_OPENVINO_DEVICE) -> String:
	if not mode in [BACKEND_API, BACKEND_OLLAMA, BACKEND_OPENVINO]:
		return "unsupported_backend"

	var d = Directory.new()
	if not d.dir_exists(Paths.config):
		var err = d.make_dir_recursive(Paths.config)
		if err != OK:
			return "config_dir_error_%s" % err

	var normalized = _normalize_backend_fields(mode, endpoint, model, python_path, api_provider, api_key_env, openvino_model_dir, openvino_device)
	var status = _detect_backend_status(mode, normalized)
	var options_patch = _build_caol_options_patch(mode, normalized)
	var safe_config = {
		"backend": mode,
		"status": status,
		"readiness": status,
		"endpoint": normalized.get("endpoint", ""),
		"model": normalized.get("model", ""),
		"python_path": normalized.get("python_path", ""),
		"api_provider": normalized.get("api_provider", DEFAULT_API_PROVIDER),
		"api_key_env": normalized.get("api_key_env", DEFAULT_API_KEY_ENV),
		"openvino_model_dir": normalized.get("openvino_model_dir", ""),
		"openvino_device": normalized.get("openvino_device", DEFAULT_OPENVINO_DEVICE),
		"last_check": OS.get_datetime(),
		"notes": _backend_notes(mode),
		"guidance": get_backend_guidance(mode),
		"caol_options_patch": options_patch
	}
	if not Helpers.save_to_json_file(safe_config, Paths.config.plus_file(BACKEND_CONFIG_FILENAME)):
		return "config_write_error"
	if not Helpers.save_to_json_file(options_patch, Paths.config.plus_file(C_AOL_OPTIONS_PATCH_FILENAME)):
		return "options_patch_write_error"
	return "ok"


func _status_summary(raw_status: String) -> String:
	if raw_status.find("api_python_missing") >= 0:
		return "Python is missing; C-AOL needs Python to run the LLM helper."
	if raw_status.find("any_llm_missing") >= 0:
		return "Python works, but AnyLLM is not installed in that environment."
	if raw_status.find("api_key_env_not_set") >= 0:
		return "API-key env-var is named but not set; Lacapult did not read a secret."
	if raw_status.find("api_key_env_missing") >= 0:
		return "Choose an API-key env-var name; Lacapult stores the name only."
	if raw_status.find("model_missing") >= 0:
		return "Choose a model name before using this backend."
	if raw_status.find("ollama_command_missing") >= 0:
		return "Ollama is not on PATH."
	if raw_status.find("ollama_command_present_server_unreachable") >= 0:
		return "Ollama is installed, but the local server did not answer."
	if raw_status.find("ollama_command_present_server_running_model_missing") >= 0:
		return "Ollama is running, but the selected model is not installed."
	if raw_status.find("ollama_command_present_server_running_model_not_selected") >= 0:
		return "Ollama is running; choose a model."
	if raw_status.find("openvino") >= 0:
		return "OpenVINO is detect-only/hidden in Lacapult v0."
	return raw_status


func write_sandboxed_options_config(options_path: String, mode: String, endpoint: String = "", model: String = "", python_path: String = "", api_provider: String = DEFAULT_API_PROVIDER, api_key_env: String = DEFAULT_API_KEY_ENV, openvino_model_dir: String = "", openvino_device: String = DEFAULT_OPENVINO_DEVICE) -> String:
	# v0 guardrail: this is for repeatable proofs only. The UI does not call it,
	# and it refuses normal-looking user/Application Support paths.
	if not _is_sandbox_options_path(options_path):
		return "unsafe_options_path_refused"
	var normalized = _normalize_backend_fields(mode, endpoint, model, python_path, api_provider, api_key_env, openvino_model_dir, openvino_device)
	var patch = _build_caol_options_patch(mode, normalized)
	return _apply_options_patch_to_file(options_path, patch)


func _normalize_backend_fields(mode: String, endpoint: String, model: String, python_path: String, api_provider: String, api_key_env: String, openvino_model_dir: String, openvino_device: String) -> Dictionary:
	var normalized = {
		"endpoint": endpoint.strip_edges(),
		"model": model.strip_edges(),
		"python_path": python_path.strip_edges(),
		"api_provider": api_provider.strip_edges() if api_provider.strip_edges() != "" else DEFAULT_API_PROVIDER,
		"api_key_env": api_key_env.strip_edges() if api_key_env.strip_edges() != "" else DEFAULT_API_KEY_ENV,
		"openvino_model_dir": openvino_model_dir.strip_edges(),
		"openvino_device": openvino_device.strip_edges().to_upper() if openvino_device.strip_edges() != "" else DEFAULT_OPENVINO_DEVICE
	}
	if mode == BACKEND_OLLAMA and normalized["endpoint"] == "":
		normalized["endpoint"] = DEFAULT_OLLAMA_URL
	if mode == BACKEND_OPENVINO:
		normalized["endpoint"] = ""
		normalized["model"] = ""
	return normalized


func _build_caol_options_patch(mode: String, fields: Dictionary) -> Dictionary:
	var patch = {
		"format": "c-aol-options-patch-v1",
		"source": "Lacapult Doobdab",
		"apply_status": "preview_only_not_applied",
		"notes": "These are the C-AOL option names Lacapult can set once an installed game config path is chosen. API keys are referenced by environment variable only, never stored here. LLM_INTENT_ENABLE is intentionally left for the player/game UI until Lacapult has an explicit apply step. LLM_INTENT_PYTHON is the shared Python/venv path used by C-AOL to launch tools/llm_runner/runner.py, not only OpenVINO.",
		"metadata_only": {
			"api_provider": fields.get("api_provider", DEFAULT_API_PROVIDER),
			"api_provider_note": "C-AOL's current runtime path hardcodes openai in src/llm_intent.cpp; Lacapult stores provider intent without storing secrets."
		},
		"options": [
			{
				"name": "LLM_INTENT_BACKEND",
				"value": mode,
				"reason": "Select the LLM backend."
			}
		]
	}

	if fields.get("python_path", "") != "":
		patch["options"].append({
			"name": "LLM_INTENT_PYTHON",
			"value": fields.get("python_path", ""),
			"reason": "Python executable or venv path used to launch C-AOL's tools/llm_runner/runner.py for every backend."
		})

	if mode == BACKEND_API:
		patch["options"].append({
			"name": "LLM_INTENT_API_KEY_ENV",
			"value": fields.get("api_key_env", DEFAULT_API_KEY_ENV),
			"reason": "C-AOL reads the API key from this environment variable; Lacapult v0 does not store the secret."
		})
		if fields.get("model", "") != "":
			patch["options"].append({
				"name": "LLM_INTENT_API_MODEL",
				"value": fields.get("model", ""),
				"reason": "Selected API model name."
			})
	elif mode == BACKEND_OLLAMA:
		patch["options"].append({
			"name": "LLM_INTENT_OLLAMA_URL",
			"value": fields.get("endpoint", DEFAULT_OLLAMA_URL),
			"reason": "Local Ollama server URL."
		})
		if fields.get("model", "") != "":
			patch["options"].append({
				"name": "LLM_INTENT_OLLAMA_MODEL",
				"value": fields.get("model", ""),
				"reason": "Selected Ollama model tag."
			})
	elif mode == BACKEND_OPENVINO:
		if fields.get("openvino_model_dir", "") != "":
			patch["options"].append({
				"name": "LLM_INTENT_MODEL_DIR",
				"value": fields.get("openvino_model_dir", ""),
				"reason": "OpenVINO model directory. Lacapult v0 detects this path but does not download models."
			})
		patch["options"].append({
			"name": "LLM_INTENT_DEVICE",
			"value": fields.get("openvino_device", DEFAULT_OPENVINO_DEVICE),
			"reason": "OpenVINO target device. Lacapult v0 does not install runtimes or force hardware choices."
		})

	return patch

func _backend_notes(mode: String) -> String:
	if mode == BACKEND_API:
		return "API setup checks the configured/default Python can import any_llm without using API secrets. Lacapult stores provider/model/env-var names only."
	if mode == BACKEND_OLLAMA:
		return "Ollama setup checks command/server/model-list readiness without pulling models. C-AOL still launches runner.py through Python."
	if mode == BACKEND_OPENVINO:
		return "OpenVINO setup checks Python imports/model-dir presence only. It does not install runtimes or download models without confirmation."
	return "Launcher-side C-AOL backend setup metadata."


func _detect_backend_status(mode: String, fields: Dictionary) -> String:
	if mode == BACKEND_API:
		return _detect_api_status(fields.get("python_path", ""), fields.get("api_provider", DEFAULT_API_PROVIDER), fields.get("model", ""), fields.get("api_key_env", DEFAULT_API_KEY_ENV))
	if mode == BACKEND_OLLAMA:
		return _detect_ollama_status(fields.get("endpoint", DEFAULT_OLLAMA_URL), fields.get("model", ""))
	if mode == BACKEND_OPENVINO:
		return _detect_openvino_status(fields.get("python_path", ""), fields.get("openvino_model_dir", ""))
	return "unsupported_backend"


func _detect_api_status(python_path: String, provider: String, model: String, api_key_env: String) -> String:
	var py = _resolve_python(python_path)
	if not py.get("ok", false):
		return "api_python_missing_runner_requires_python"
	var import_status = _python_import_status(py.get("command", ""), ["any_llm"])
	if import_status != "imports_ok":
		return "api_python_ready_any_llm_missing_%s" % import_status
	var parts = ["api_python_ready_any_llm_import_ok"]
	if provider.strip_edges() == "":
		parts.append("provider_missing")
	else:
		parts.append("provider_%s" % provider.strip_edges())
	if model.strip_edges() == "":
		parts.append("model_missing")
	else:
		parts.append("model_configured")
	if api_key_env.strip_edges() == "":
		parts.append("api_key_env_missing")
	elif OS.get_environment(api_key_env.strip_edges()) == "":
		parts.append("api_key_env_not_set_no_secret_used")
	else:
		parts.append("api_key_env_present_secret_not_read")
	return "_".join(parts)


func _detect_openvino_status(python_path: String, model_dir: String = "") -> String:
	var py = _resolve_python(python_path)
	if not py.get("ok", false):
		return "openvino_python_missing_runner_requires_python"
	var import_status = _python_import_status(py.get("command", ""), ["openvino", "openvino_genai"])
	var parts = []
	if OS.get_name() != "Windows":
		parts.append("openvino_v0_specialized_non_windows_detect_only")
	else:
		parts.append("openvino_v0_supported_platform")
	parts.append("python_ready_%s" % import_status)
	if _python_import_status(py.get("command", ""), ["openvino_tokenizers"]) == "imports_ok":
		parts.append("tokenizers_present")
	else:
		parts.append("tokenizers_missing_or_packaged_differently")
	if model_dir.strip_edges() == "":
		parts.append("model_dir_missing")
	else:
		var d = Directory.new()
		if d.dir_exists(model_dir.strip_edges()):
			parts.append("model_dir_present")
		else:
			parts.append("model_dir_missing")
	return "_".join(parts)


func _detect_ollama_status(ollama_url: String = DEFAULT_OLLAMA_URL, model: String = "") -> String:
	var output = []
	var command_lookup = "where" if OS.get_name() == "Windows" else "which"
	var exit_code = OS.execute(command_lookup, ["ollama"], true, output, true)
	if exit_code != 0:
		return "ollama_command_missing"

	output.clear()
	exit_code = OS.execute("ollama", ["list"], true, output, true)
	if exit_code != 0:
		return "ollama_command_present_server_unreachable"
	if model.strip_edges() == "":
		return "ollama_command_present_server_running_model_not_selected"
	var list_text = "\n".join(output)
	if list_text.find(model.strip_edges()) >= 0:
		return "ollama_command_present_server_running_model_present"
	return "ollama_command_present_server_running_model_missing_no_pull_attempted"


func _resolve_python(python_path: String) -> Dictionary:
	var candidates = []
	if python_path.strip_edges() != "":
		candidates.append(python_path.strip_edges())
	else:
		if OS.get_name() == "Windows":
			candidates = ["python", "py"]
		else:
			candidates = ["python3", "python"]
	for candidate in candidates:
		var output = []
		var exit_code = OS.execute(candidate, ["-c", "import sys; print(sys.executable)"], true, output, true)
		if exit_code == 0:
			return {"ok": true, "command": candidate, "executable": "\n".join(output).strip_edges()}
	return {"ok": false, "command": "", "executable": ""}


func _python_import_status(python_command: String, modules: Array) -> String:
	if python_command == "":
		return "python_missing"
	var output = []
	var code = "import importlib.util, sys\nmissing=[m for m in sys.argv[1:] if importlib.util.find_spec(m) is None]\nprint('missing=' + ','.join(missing))\nsys.exit(1 if missing else 0)"
	var args = ["-c", code]
	args.append_array(modules)
	var exit_code = OS.execute(python_command, args, true, output, true)
	if exit_code == 0:
		return "imports_ok"
	var text = "\n".join(output).strip_edges()
	if text.find("missing=") >= 0:
		return text.replace("missing=", "missing_").replace(",", "_")
	return "imports_failed"


func _apply_options_patch_to_file(options_path: String, patch: Dictionary) -> String:
	var options = Helpers.load_json_file(options_path)
	if typeof(options) != TYPE_ARRAY:
		return "options_json_not_array"
	var changed = 0
	for patch_option in patch.get("options", []):
		var option_name = patch_option.get("name", "")
		var option_value = str(patch_option.get("value", ""))
		if option_name == "":
			continue
		var found = false
		for option in options:
			if typeof(option) == TYPE_DICTIONARY and option.get("name", "") == option_name:
				option["value"] = option_value
				changed += 1
				found = true
				break
		if not found:
			options.append({
				"name": option_name,
				"value": option_value,
				"info": "Added by Lacapult sandbox backend proof from %s." % patch.get("source", "Lacapult Doobdab")
			})
			changed += 1
	if not Helpers.save_to_json_file(options, options_path):
		return "options_write_error"
	return "ok_changed_%s" % changed


func _is_sandbox_options_path(path: String) -> bool:
	var p = path.replace("\\", "/")
	return p.find("/.proof-cache/") >= 0 or p.find("/tmp/") == 0 or p.find("sandbox") >= 0


func _setting_or_default(name: String, default_value: String) -> String:
	var value = Settings.read(name)
	if value == null:
		return default_value
	return str(value)
