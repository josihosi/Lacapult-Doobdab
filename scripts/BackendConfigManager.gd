extends Node

# Safe first-pass backend setup helper for C-AOL.
# This deliberately stores launcher-side metadata and environment-variable names,
# never API keys. Installed-game options writes are proof-only/sandbox-guarded in v0.

const BACKEND_API = "api"
const BACKEND_OLLAMA = "ollama"
const BACKEND_OPENVINO = "openvino"
const BACKEND_CONFIG_FILENAME = "caol_backend_setup.json"
const C_AOL_OPTIONS_PATCH_FILENAME = "caol_llm_options_patch.json"
const API_SETUP_INTENT_FILENAME = "caol_api_setup_intent.json"
const OLLAMA_SETUP_INTENT_FILENAME = "caol_ollama_setup_intent.json"
const PYTHON_VENV_SETUP_INTENT_FILENAME = "caol_python_venv_setup_intent.json"

const DEFAULT_API_PROVIDER = "openai"
const DEFAULT_API_KEY_ENV = "CATA_API_KEY"
const DEFAULT_OLLAMA_URL = "http://127.0.0.1:11434"
const DEFAULT_OPENVINO_DEVICE = "AUTO"
const OLLAMA_MODEL_MISTRAL = "mistral-v0.3"
const OLLAMA_MODEL_NEMOTRON = "nemotron-9b"

const API_PROVIDER_CHOICES = [
	{
		"id": "openai",
		"label": "OpenAI",
		"default_base_url": "https://api.openai.com/v1",
		"default_model": "gpt-4.1-mini",
		"install_extra": "openai"
	},
	{
		"id": "openrouter",
		"label": "OpenRouter",
		"default_base_url": "https://openrouter.ai/api/v1",
		"default_model": "openai/gpt-4.1-mini",
		"install_extra": "openrouter"
	},
	{
		"id": "anthropic",
		"label": "Anthropic / Claude",
		"default_base_url": "",
		"default_model": "claude-3-5-haiku-latest",
		"install_extra": "anthropic"
	},
	{
		"id": "gemini",
		"label": "Google Gemini",
		"default_base_url": "",
		"default_model": "gemini-1.5-flash",
		"install_extra": "gemini"
	},
	{
		"id": "custom_any_llm",
		"label": "AnyLLM custom provider",
		"default_base_url": "",
		"default_model": "",
		"install_extra": ""
	}
]


func get_api_provider_choices() -> Array:
	return API_PROVIDER_CHOICES.duplicate(true)


func get_api_provider_choice(provider_id: String) -> Dictionary:
	var normalized_id = _normalize_api_provider(provider_id)
	for choice in API_PROVIDER_CHOICES:
		if choice.get("id", "") == normalized_id:
			return choice.duplicate(true)
	return API_PROVIDER_CHOICES[0].duplicate(true)


func get_api_provider_default_base_url(provider_id: String) -> String:
	return get_api_provider_choice(provider_id).get("default_base_url", "")


func get_api_provider_default_model(provider_id: String) -> String:
	return get_api_provider_choice(provider_id).get("default_model", "")


func build_api_setup_plan(provider_id: String, python_path: String = "") -> Dictionary:
	var choice = get_api_provider_choice(provider_id)
	var package_spec = "any_llm"
	var install_extra = choice.get("install_extra", "")
	if install_extra != "":
		package_spec = "any_llm[%s]" % install_extra
	var py = _resolve_python(python_path)
	var python_command = py.get("command", "python3") if py.get("ok", false) else (python_path.strip_edges() if python_path.strip_edges() != "" else "python3")
	return {
		"provider": choice.get("id", DEFAULT_API_PROVIDER),
		"provider_label": choice.get("label", "OpenAI"),
		"python_command": python_command,
		"package_spec": package_spec,
		"command": "%s -m pip install --upgrade %s" % [python_command, package_spec],
		"requires_confirmation": true,
		"automated_proof_policy": "plan_only_no_pip_no_secret_no_api_call"
	}


func run_api_setup(provider_id: String, python_path: String = "", proof_only: bool = false) -> Dictionary:
	var plan = build_api_setup_plan(provider_id, python_path)
	if proof_only:
		var proof_result = write_api_setup_intent(provider_id, python_path, false, -1, "proof_only_no_pip_no_secret_no_api_call")
		return {
			"status": proof_result,
			"plan": plan,
			"performed_external_install": false,
			"exit_code": -1,
			"proof_only": true
		}

	var output = []
	var exit_code = OS.execute(plan.get("python_command", "python3"), ["-m", "pip", "install", "--upgrade", plan.get("package_spec", "any_llm")], true, output, true)
	var summary = "pip_install_ok" if exit_code == 0 else "pip_install_failed"
	var write_result = write_api_setup_intent(provider_id, python_path, true, exit_code, summary)
	var status = "api_setup_install_ok" if exit_code == 0 else "api_setup_install_failed_%s" % exit_code
	if write_result != "ok":
		status = write_result
	return {
		"status": status,
		"plan": plan,
		"performed_external_install": true,
		"exit_code": exit_code,
		"proof_only": false,
		"output_line_count": output.size()
	}



func get_ollama_model_choices() -> Array:
	return [OLLAMA_MODEL_MISTRAL, OLLAMA_MODEL_NEMOTRON]


func get_ollama_readiness(endpoint: String = DEFAULT_OLLAMA_URL, python_path: String = "") -> Dictionary:
	var inventory = _ollama_inventory(endpoint)
	var py = _resolve_python(python_path)
	var command_light = "🔴"
	var server_light = "🔴"
	if inventory.get("command", "missing") == "present":
		command_light = "🟢"
	if inventory.get("server", "unreachable") == "running":
		server_light = "🟢"
	elif inventory.get("command", "missing") == "present":
		server_light = "🟡"
	var model_lights = {}
	for model_name in get_ollama_model_choices():
		var model_light = "🔴"
		if inventory.get("server", "unreachable") == "running":
			model_light = "🟢" if _ollama_model_list_has(inventory.get("models", []), model_name) else "🟡"
		model_lights[model_name] = model_light
	return {
		"command": inventory.get("command", "missing"),
		"server": inventory.get("server", "unreachable"),
		"models": inventory.get("models", []),
		"command_light": command_light,
		"server_light": server_light,
		"model_lights": model_lights,
		"python_light": "🟢" if py.get("ok", false) else "🔴",
		"python_command": py.get("command", ""),
		"options_light": "🟢",
		"proof_policy": "detect_only_no_pull_no_install"
	}


func build_ollama_setup_plan(endpoint: String = DEFAULT_OLLAMA_URL, model: String = "") -> Dictionary:
	var selected_model = model.strip_edges()
	if selected_model == "":
		selected_model = OLLAMA_MODEL_MISTRAL
	var inventory = _ollama_inventory(endpoint)
	var commands = []
	var installer = "manual"
	var os_name = OS.get_name()
	if inventory.get("command", "missing") != "present":
		if os_name == "OSX" and _command_exists("brew"):
			installer = "homebrew"
			commands.append({"command": "brew", "args": ["install", "ollama"], "purpose": "Install Ollama through Homebrew."})
		elif os_name == "Windows" and _command_exists("winget"):
			installer = "winget"
			commands.append({"command": "winget", "args": ["install", "--id", "Ollama.Ollama", "-e"], "purpose": "Install the official Ollama Windows package through winget id Ollama.Ollama."})
		else:
			installer = "manual_required"
	if selected_model != "":
		commands.append({"command": "ollama", "args": ["pull", selected_model], "purpose": "Pull the selected model after confirmation."})
	var preview = []
	for step in commands:
		preview.append("%s %s" % [step.get("command", ""), " ".join(step.get("args", []))])
	return {
		"action": "install_ollama_and_pull_model",
		"endpoint": endpoint.strip_edges() if endpoint.strip_edges() != "" else DEFAULT_OLLAMA_URL,
		"model": selected_model,
		"platform": os_name,
		"installer": installer,
		"commands": commands,
		"command_preview": " && ".join(preview) if preview.size() > 0 else "Manual Ollama install required; no safe platform installer found.",
		"requires_confirmation": true,
		"automated_proof_policy": "plan_only_no_installer_no_model_pull"
	}


func run_ollama_setup(endpoint: String = DEFAULT_OLLAMA_URL, model: String = "", proof_only: bool = false) -> Dictionary:
	var plan = build_ollama_setup_plan(endpoint, model)
	if proof_only:
		var proof_result = write_ollama_setup_intent(endpoint, plan.get("model", model), false, [], "proof_only_no_installer_no_model_pull")
		return {
			"status": proof_result,
			"plan": plan,
			"performed_external_install": false,
			"proof_only": true
		}
	var results = []
	var failed = false
	var failed_step = {}
	for step in plan.get("commands", []):
		var output = []
		var exit_code = OS.execute(step.get("command", ""), step.get("args", []), true, output, true)
		var result = {"command": step.get("command", ""), "args": step.get("args", []), "purpose": step.get("purpose", "Ollama setup command."), "exit_code": exit_code, "output_line_count": output.size()}
		results.append(result)
		if exit_code != 0:
			failed = true
			failed_step = result
			break
	var summary = _ollama_setup_failure_summary(failed_step) if failed else "ollama_setup_commands_ok"
	var write_result = write_ollama_setup_intent(endpoint, plan.get("model", model), true, results, summary)
	var status = summary if failed else "ollama_setup_install_ok"
	if write_result != "ok":
		status = write_result
	return {
		"status": status,
		"plan": plan,
		"performed_external_install": true,
		"proof_only": false,
		"results": results,
		"failed_step": failed_step
	}

func build_python_venv_setup_plan(python_path: String = "") -> Dictionary:
	var input_path = python_path.strip_edges()
	var target = input_path
	var py = _resolve_python(input_path if _looks_like_python_executable_path(input_path) else "")
	if target == "" or _looks_like_python_executable_path(target):
		target = Paths.config.plus_file("caol-llm-python-venv")
	if not py.get("ok", false):
		py = _resolve_python("")
	var python_command = py.get("command", "python3") if py.get("ok", false) else "python3"
	return {
		"action": "create_python_venv",
		"target_path": target,
		"python_command": python_command,
		"command_preview": "%s -m venv %s" % [python_command, target],
		"requires_confirmation": true,
		"automated_proof_policy": "plan_only_no_venv_mutation"
	}


func run_python_venv_setup(python_path: String = "", proof_only: bool = false) -> Dictionary:
	var plan = build_python_venv_setup_plan(python_path)
	if proof_only:
		var proof_result = write_python_venv_setup_intent(plan.get("target_path", ""), false, -1, "proof_only_no_venv_mutation")
		return {"status": proof_result, "plan": plan, "performed_external_install": false, "proof_only": true}
	var output = []
	var exit_code = OS.execute(plan.get("python_command", "python3"), ["-m", "venv", plan.get("target_path", "")], true, output, true)
	var summary = "venv_create_ok" if exit_code == 0 else "venv_create_failed"
	var write_result = write_python_venv_setup_intent(plan.get("target_path", ""), true, exit_code, summary)
	var status = "python_venv_setup_ok" if exit_code == 0 else "python_venv_setup_failed_%s" % exit_code
	if write_result != "ok":
		status = write_result
	return {"status": status, "plan": plan, "performed_external_install": true, "proof_only": false, "exit_code": exit_code, "output_line_count": output.size()}


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
			"v0_warning": "Catapult-Dabubu stores provider/model/env-var metadata only; it never stores API keys or makes a live API call from this setup page.",
			"status": _detect_api_status(python_path, api_provider, api_model, api_key_env),
			"guidance": get_backend_guidance(BACKEND_API),
			"python_path": python_path,
			"api_provider": api_provider,
			"api_key_env": api_key_env,
			"secrets_policy": "Do not store or log API keys in Catapult-Dabubu v0. Only the env-var name is stored."
		},
		{
			"id": BACKEND_OLLAMA,
			"label": "Ollama backend",
			"recommendation_rank": 2,
			"recommendation": "Mainstream local path: use when Ollama is installed, the local server is running, and a model is already present.",
			"setup_role": "mainstream_local",
			"v0_warning": "Catapult-Dabubu detects command/server/model-list state on Check; Install Ollama / model is confirmation-gated before any platform installer or model pull.",
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
			"v0_warning": "Catapult-Dabubu v0 reports OpenVINO readiness only; it does not install runtimes, tokenizers, drivers, or download/convert models.",
			"status": _detect_openvino_status(python_path, openvino_model_dir),
			"guidance": get_backend_guidance(BACKEND_OPENVINO),
			"python_path": python_path,
			"model_dir": openvino_model_dir,
			"device": openvino_device
		},
	]


func get_backend_recommendation_summary() -> String:
	return "Setup paths: API / AnyLLM for a hosted backend, Ollama for mainstream local play, and OpenVINO for specialized local acceleration. Check/Save are metadata/status only: no API call, model pull, package install, generated summary-pack apply, or real C-AOL config mutation happens without an explicit confirmation step."

func get_backend_guidance(mode: String) -> String:
	if mode == BACKEND_API:
		return "Install Python plus the AnyLLM package/provider extra in the Python/venv selected here; set the named API-key environment variable outside Catapult-Dabubu. Catapult-Dabubu can check imports and env-var presence, but never reads or stores the secret."
	if mode == BACKEND_OLLAMA:
		return "Install Ollama for this OS, start the local server, and select or pull Mistral/Nemotron only after explicit confirmation. Check reads command/server/model-list state without pulling models."
	if mode == BACKEND_OPENVINO:
		return "Select a Python/venv with OpenVINO packages and a local model directory; Catapult-Dabubu checks imports/model path but does not install runtimes or download models without confirmation."
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


func write_api_setup_intent(provider_id: String, python_path: String = "", performed_external_install: bool = false, exit_code: int = -1, result_summary: String = "plan_only_no_pip_no_secret_no_api_call") -> String:
	var d = Directory.new()
	if not d.dir_exists(Paths.config):
		var err = d.make_dir_recursive(Paths.config)
		if err != OK:
			return "config_dir_error_%s" % err
	var plan = build_api_setup_plan(provider_id, python_path)
	var intent = {
		"action": "install_api_backend",
		"provider": plan.get("provider", DEFAULT_API_PROVIDER),
		"provider_label": plan.get("provider_label", "OpenAI"),
		"python_command": plan.get("python_command", "python3"),
		"package_spec": plan.get("package_spec", "any_llm"),
		"command_preview": plan.get("command", "python3 -m pip install --upgrade any_llm"),
		"confirmed": true,
		"performed_external_install": performed_external_install,
		"exit_code": exit_code,
		"result_summary": result_summary,
		"proof_policy": plan.get("automated_proof_policy", "plan_only_no_pip_no_secret_no_api_call"),
		"secret_policy": "No API key is stored or displayed; only the env-var name belongs in backend config.",
		"recorded_at": OS.get_datetime()
	}
	if not Helpers.save_to_json_file(intent, Paths.config.plus_file(API_SETUP_INTENT_FILENAME)):
		return "api_setup_intent_write_error"
	return "ok"



func write_ollama_setup_intent(endpoint: String = DEFAULT_OLLAMA_URL, model: String = "", performed_external_install: bool = false, command_results: Array = [], result_summary: String = "plan_only_no_installer_no_model_pull") -> String:
	var d = Directory.new()
	if not d.dir_exists(Paths.config):
		var err = d.make_dir_recursive(Paths.config)
		if err != OK:
			return "config_dir_error_%s" % err
	var plan = build_ollama_setup_plan(endpoint, model)
	var intent = {
		"action": "install_ollama_and_pull_model",
		"endpoint": plan.get("endpoint", DEFAULT_OLLAMA_URL),
		"model": plan.get("model", model),
		"platform": plan.get("platform", OS.get_name()),
		"installer": plan.get("installer", "manual_required"),
		"command_preview": plan.get("command_preview", ""),
		"confirmed": true,
		"performed_external_install": performed_external_install,
		"command_results": command_results,
		"result_summary": result_summary,
		"proof_policy": plan.get("automated_proof_policy", "plan_only_no_installer_no_model_pull"),
		"recorded_at": OS.get_datetime()
	}
	if not Helpers.save_to_json_file(intent, Paths.config.plus_file(OLLAMA_SETUP_INTENT_FILENAME)):
		return "ollama_setup_intent_write_error"
	return "ok"


func write_python_venv_setup_intent(target_path: String, performed_external_install: bool = false, exit_code: int = -1, result_summary: String = "plan_only_no_venv_mutation") -> String:
	var d = Directory.new()
	if not d.dir_exists(Paths.config):
		var err = d.make_dir_recursive(Paths.config)
		if err != OK:
			return "config_dir_error_%s" % err
	var intent = {
		"action": "create_python_venv",
		"target_path": target_path,
		"confirmed": true,
		"performed_external_install": performed_external_install,
		"exit_code": exit_code,
		"result_summary": result_summary,
		"proof_policy": "plan_only_no_venv_mutation",
		"recorded_at": OS.get_datetime()
	}
	if not Helpers.save_to_json_file(intent, Paths.config.plus_file(PYTHON_VENV_SETUP_INTENT_FILENAME)):
		return "python_venv_setup_intent_write_error"
	return "ok"


func _status_summary(raw_status: String) -> String:
	if raw_status.find("api_python_missing") >= 0:
		return "Python is missing; C-AOL needs Python to run the LLM helper."
	if raw_status.find("any_llm_missing") >= 0:
		return "Python works, but AnyLLM is not installed in that environment."
	if raw_status.find("api_key_env_not_set") >= 0:
		return "API-key env-var is named but not set; Catapult-Dabubu did not read a secret."
	if raw_status.find("api_key_env_missing") >= 0:
		return "Choose an API-key env-var name; Catapult-Dabubu stores the name only."
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
	if raw_status.find("ollama_setup_installer_failed") >= 0:
		return "Ollama installer command failed; CLI/server/model pull should be checked separately."
	if raw_status.find("ollama_setup_model_pull_failed") >= 0:
		return "Ollama model pull failed after installer/CLI step; Check can still report command/server readiness separately."
	if raw_status.find("ollama_setup_command_failed") >= 0:
		return "Ollama setup command failed; inspect the named step and then run Check again."
	if raw_status.find("openvino") >= 0:
		return "OpenVINO is detect-only/hidden in Catapult-Dabubu v0."
	return raw_status


func _ollama_setup_failure_summary(failed_step: Dictionary) -> String:
	var command = str(failed_step.get("command", ""))
	var args = failed_step.get("args", [])
	if command == "ollama" and args.size() > 0 and str(args[0]) == "pull":
		return "ollama_setup_model_pull_failed_%s" % str(failed_step.get("exit_code", "unknown"))
	if command == "brew" or command == "winget":
		return "ollama_setup_installer_failed_%s" % str(failed_step.get("exit_code", "unknown"))
	return "ollama_setup_command_failed_%s" % str(failed_step.get("exit_code", "unknown"))


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
		"api_provider": _normalize_api_provider(api_provider),
		"api_key_env": api_key_env.strip_edges() if api_key_env.strip_edges() != "" else DEFAULT_API_KEY_ENV,
		"openvino_model_dir": openvino_model_dir.strip_edges(),
		"openvino_device": openvino_device.strip_edges().to_upper() if openvino_device.strip_edges() != "" else DEFAULT_OPENVINO_DEVICE
	}
	if mode == BACKEND_API:
		if normalized["endpoint"] == "":
			normalized["endpoint"] = get_api_provider_default_base_url(normalized["api_provider"])
		if normalized["model"] == "":
			normalized["model"] = get_api_provider_default_model(normalized["api_provider"])
	if mode == BACKEND_OLLAMA and normalized["endpoint"] == "":
		normalized["endpoint"] = DEFAULT_OLLAMA_URL
	if mode == BACKEND_OPENVINO:
		normalized["endpoint"] = ""
		normalized["model"] = ""
	return normalized


func _normalize_api_provider(provider_id: String) -> String:
	var normalized_id = provider_id.strip_edges().to_lower()
	if normalized_id == "":
		normalized_id = DEFAULT_API_PROVIDER
	for choice in API_PROVIDER_CHOICES:
		if choice.get("id", "") == normalized_id:
			return normalized_id
	return "custom_any_llm"


func _build_caol_options_patch(mode: String, fields: Dictionary) -> Dictionary:
	var patch = {
		"format": "c-aol-options-patch-v1",
		"source": "Catapult-Dabubu",
		"apply_status": "preview_only_not_applied",
		"notes": "These are the C-AOL option names Catapult-Dabubu can set once an installed game config path is chosen. API keys are referenced by environment variable only, never stored here. LLM_INTENT_ENABLE is intentionally left for the player/game UI until Catapult-Dabubu has an explicit apply step. LLM_INTENT_PYTHON is the shared Python/venv path used by C-AOL to launch tools/llm_runner/runner.py, not only OpenVINO.",
		"metadata_only": {
			"api_provider": fields.get("api_provider", DEFAULT_API_PROVIDER),
			"api_provider_note": "C-AOL's current runtime path hardcodes openai in src/llm_intent.cpp; Catapult-Dabubu stores provider intent without storing secrets."
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
			"name": "LLM_INTENT_API_PROVIDER",
			"value": fields.get("api_provider", DEFAULT_API_PROVIDER),
			"reason": "Selected API provider metadata; current C-AOL runtime still consumes OpenAI-compatible paths first."
		})
		patch["options"].append({
			"name": "LLM_INTENT_API_KEY_ENV",
			"value": fields.get("api_key_env", DEFAULT_API_KEY_ENV),
			"reason": "C-AOL reads the API key from this environment variable; Catapult-Dabubu v0 does not store the secret."
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
				"reason": "OpenVINO model directory. Catapult-Dabubu v0 detects this path but does not download models."
			})
		patch["options"].append({
			"name": "LLM_INTENT_DEVICE",
			"value": fields.get("openvino_device", DEFAULT_OPENVINO_DEVICE),
			"reason": "OpenVINO target device. Catapult-Dabubu v0 does not install runtimes or force hardware choices."
		})

	return patch

func _backend_notes(mode: String) -> String:
	if mode == BACKEND_API:
		return "API setup checks the configured/default Python can import any_llm without using API secrets. Catapult-Dabubu stores provider/model/env-var names only."
	if mode == BACKEND_OLLAMA:
		return "Ollama setup checks command/server/model-list readiness without pulling models. Install is confirmation-gated for platform setup/model pull, and C-AOL still launches runner.py through Python."
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
	var parts = []
	if import_status == "imports_ok":
		parts.append("api_python_ready_any_llm_import_ok")
	else:
		parts.append("api_python_ready_any_llm_missing_%s" % import_status)
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
	var inventory = _ollama_inventory(ollama_url)
	if inventory.get("command", "missing") != "present":
		return "ollama_command_missing"
	if inventory.get("server", "unreachable") != "running":
		return "ollama_command_present_server_unreachable"
	if model.strip_edges() == "":
		return "ollama_command_present_server_running_model_not_selected"
	if _ollama_model_list_has(inventory.get("models", []), model.strip_edges()):
		return "ollama_command_present_server_running_model_present"
	return "ollama_command_present_server_running_model_missing_no_pull_attempted"


func _ollama_inventory(ollama_url: String = DEFAULT_OLLAMA_URL) -> Dictionary:
	var fixture = OS.get_environment("LACAPULT_OLLAMA_FIXTURE")
	if fixture != "":
		return _ollama_fixture_inventory(fixture)
	var output = []
	var command_lookup = "where" if OS.get_name() == "Windows" else "which"
	var exit_code = OS.execute(command_lookup, ["ollama"], true, output, true)
	if exit_code != 0:
		return {"command": "missing", "server": "unreachable", "models": []}
	output.clear()
	exit_code = OS.execute("ollama", ["list"], true, output, true)
	if exit_code != 0:
		return {"command": "present", "server": "unreachable", "models": []}
	return {"command": "present", "server": "running", "models": _parse_ollama_list_models("\n".join(output))}


func _ollama_fixture_inventory(fixture: String) -> Dictionary:
	if fixture == "command_missing":
		return {"command": "missing", "server": "unreachable", "models": []}
	if fixture == "server_unreachable":
		return {"command": "present", "server": "unreachable", "models": []}
	var text = fixture
	if fixture.begins_with("models:"):
		text = fixture.substr(7, fixture.length() - 7)
	return {"command": "present", "server": "running", "models": _parse_ollama_list_models(text)}


func _parse_ollama_list_models(text: String) -> Array:
	var models = []
	for raw_line in text.split("\n"):
		var line = raw_line.strip_edges()
		if line == "" or line.begins_with("NAME"):
			continue
		var first = line.split(" ")[0].strip_edges()
		if first != "" and not first in models:
			models.append(first)
	return models


func _ollama_model_list_has(models: Array, model: String) -> bool:
	var wanted = model.strip_edges()
	for entry in models:
		var candidate = str(entry).strip_edges()
		if candidate == wanted or candidate.begins_with(wanted + ":") or wanted.begins_with(candidate + ":"):
			return true
	return false


func _command_exists(command: String) -> bool:
	var output = []
	var command_lookup = "where" if OS.get_name() == "Windows" else "which"
	return OS.execute(command_lookup, [command], true, output, true) == 0


func _looks_like_python_executable_path(path: String) -> bool:
	var cleaned = path.strip_edges().replace("\\", "/")
	if cleaned == "":
		return false
	var base = cleaned.get_file().to_lower()
	return base == "python" or base == "python3" or base.begins_with("python3.") or base == "python.exe" or base == "py.exe" or cleaned == "python" or cleaned == "python3" or cleaned == "py"


func _resolve_python(python_path: String) -> Dictionary:
	var candidates = []
	if python_path.strip_edges() != "":
		var requested = python_path.strip_edges()
		var d = Directory.new()
		if d.dir_exists(requested):
			if OS.get_name() == "Windows":
				candidates.append(requested.plus_file("Scripts").plus_file("python.exe"))
				candidates.append(requested.plus_file("python.exe"))
			else:
				candidates.append(requested.plus_file("bin").plus_file("python"))
				candidates.append(requested.plus_file("bin").plus_file("python3"))
		candidates.append(requested)
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
				"info": "Added by Catapult-Dabubu sandbox backend proof from %s." % patch.get("source", "Catapult-Dabubu")
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
