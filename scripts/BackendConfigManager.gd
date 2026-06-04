extends Node

# Safe first-pass backend setup helper for C-AOL.
# This deliberately stores runner option values and environment-variable names,
# never API keys. Save options applies runner settings to the active C-AOL userdir
# with a backup and manifest; installs/downloads/backend calls remain confirmation-gated.

const BACKEND_API = "api"
const BACKEND_OLLAMA = "ollama"
const BACKEND_OPENVINO = "openvino"
const BACKEND_CONFIG_FILENAME = "caol_backend_setup.json"
const C_AOL_OPTIONS_PATCH_FILENAME = "caol_llm_options_patch.json"
const C_AOL_OPTIONS_APPLY_FILENAME = "caol_llm_options_apply.json"
const C_AOL_OPTIONS_FILENAME = "options.json"
const API_SETUP_INTENT_FILENAME = "caol_api_setup_intent.json"
const OLLAMA_SETUP_INTENT_FILENAME = "caol_ollama_setup_intent.json"
const PYTHON_VENV_SETUP_INTENT_FILENAME = "caol_python_venv_setup_intent.json"
const RUNNER_TEST_INTENT_FILENAME = "caol_runner_test_intent.json"
const OPENCLAW_HARNESS_SCRIPT_RELATIVE_PATH = "tools/openclaw_harness/startup_harness.py"
const OPENCLAW_HARNESS_REQUIREMENTS_RELATIVE_PATH = "tools/openclaw_harness/requirements.txt"
const DEFAULT_HARDWARE_RAM_WARN_MB = 16000
const DEFAULT_HARDWARE_VRAM_WARN_MB = 6000

const DEFAULT_API_PROVIDER = "openai"
const DEFAULT_API_KEY_ENV = "CATA_API_KEY"
const DEFAULT_OLLAMA_URL = "http://127.0.0.1:11434"
const DEFAULT_OPENVINO_DEVICE = "AUTO"
const ANY_LLM_PIP_PACKAGE = "any-llm-sdk"
const OLLAMA_MODEL_MISTRAL = "mistral:v0.3"
const OLLAMA_MODEL_NEMOTRON_SOURCE = "mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest"
const OLLAMA_MODEL_NEMOTRON = "nemotron-9b-dumber:latest"
const OLLAMA_MODEL_NEMOTRON_MODE = "system_no_think_alias_no_blob_copy"

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
	var package_spec = ANY_LLM_PIP_PACKAGE
	var install_extra = choice.get("install_extra", "")
	if install_extra != "":
		package_spec = "%s[%s]" % [ANY_LLM_PIP_PACKAGE, install_extra]
	var venv_plan = build_python_venv_setup_plan(python_path)
	var target_path = venv_plan.get("target_path", "")
	var venv_python_command = _venv_python_command(target_path)
	var commands = [
		{
			"phase": "create_or_update_venv",
			"command": venv_plan.get("python_command", "python3"),
			"args": ["-m", "venv", target_path],
			"preview": venv_plan.get("command_preview", "python3 -m venv"),
			"purpose": "Create or update the Python venv used by C-AOL runner.py."
		}
	]
	var harness_step = _build_openclaw_harness_requirements_step(venv_python_command)
	if not harness_step.empty():
		commands.append(harness_step)
	commands.append(
		{
			"phase": "install_anyllm_packages",
			"command": venv_python_command,
			"args": ["-m", "pip", "install", "--upgrade", package_spec],
			"preview": "%s -m pip install --upgrade %s" % [venv_python_command, package_spec],
			"purpose": "Install AnyLLM/provider packages into that venv."
		}
	)
	var preview = []
	var phase_order = []
	for i in range(commands.size()):
		preview.append("Step %s: %s" % [str(i + 1), commands[i].get("preview", "")])
		phase_order.append(commands[i].get("phase", ""))
	phase_order.append("check_readiness_next")
	return {
		"provider": choice.get("id", DEFAULT_API_PROVIDER),
		"provider_label": choice.get("label", "OpenAI"),
		"target_venv_path": target_path,
		"python_command": venv_python_command,
		"package_spec": package_spec,
		"harness_requirements_path": resolve_openclaw_harness_requirements_path(),
		"commands": commands,
		"command": PoolStringArray(preview).join("\n"),
		"requires_confirmation": true,
		"phase_order": phase_order,
		"automated_proof_policy": "plan_only_no_venv_no_pip_no_secret_no_api_call"
	}


func run_api_setup(provider_id: String, python_path: String = "", proof_only: bool = false) -> Dictionary:
	var plan = build_api_setup_plan(provider_id, python_path)
	if proof_only:
		var proof_result = write_api_setup_intent(provider_id, python_path, false, -1, "proof_only_no_venv_no_pip_no_secret_no_api_call", [])
		return {
			"status": proof_result,
			"plan": plan,
			"performed_external_install": false,
			"exit_code": -1,
			"proof_only": true
		}

	var results = []
	var failed = false
	var exit_code = 0
	for step in plan.get("commands", []):
		var output = []
		exit_code = OS.execute(step.get("command", ""), step.get("args", []), true, output, true)
		var result = {"phase": step.get("phase", ""), "command": step.get("command", ""), "args": step.get("args", []), "purpose": step.get("purpose", ""), "exit_code": exit_code, "output_line_count": output.size(), "output_summary": _safe_command_output_summary(output)}
		results.append(result)
		if exit_code != 0:
			failed = true
			break
	var failed_phase = results[results.size() - 1].get("phase", "api_setup") if results.size() > 0 else "api_setup"
	var summary = "api_venv_harness_and_anyllm_install_ok" if not failed else "%s_failed" % failed_phase
	var write_result = write_api_setup_intent(provider_id, python_path, true, exit_code, summary, results)
	var status = "api_setup_install_ok" if not failed else "api_setup_%s_failed_%s" % [failed_phase, exit_code]
	if write_result != "ok":
		status = write_result
	return {
		"status": status,
		"plan": plan,
		"performed_external_install": true,
		"exit_code": exit_code,
		"proof_only": false,
		"results": results
	}



func get_ollama_model_choices() -> Array:
	return [OLLAMA_MODEL_MISTRAL, OLLAMA_MODEL_NEMOTRON]


func get_ollama_pull_source_for_model(model: String) -> String:
	var normalized = normalize_ollama_model_tag(model)
	if normalized == OLLAMA_MODEL_NEMOTRON:
		return OLLAMA_MODEL_NEMOTRON_SOURCE
	return normalized


func get_ollama_readiness(endpoint: String = DEFAULT_OLLAMA_URL, python_path: String = "") -> Dictionary:
	var inventory = _ollama_inventory(endpoint)
	var py = _resolve_python(python_path)
	var command_state = "red"
	var server_state = "red"
	if inventory.get("command", "missing") == "present":
		command_state = "green"
	if inventory.get("server", "unreachable") == "running":
		server_state = "green"
	elif inventory.get("command", "missing") == "present":
		server_state = "yellow"
	var model_states = {}
	for model_name in get_ollama_model_choices():
		var model_state = "red"
		if inventory.get("server", "unreachable") == "running":
			model_state = "green" if _ollama_model_list_has(inventory.get("models", []), model_name) else "yellow"
		model_states[model_name] = model_state
	return {
		"command": inventory.get("command", "missing"),
		"server": inventory.get("server", "unreachable"),
		"models": inventory.get("models", []),
		"command_light": command_state,
		"server_light": server_state,
		"command_state": command_state,
		"server_state": server_state,
		"model_lights": model_states,
		"model_states": model_states,
		"python_light": "green" if py.get("ok", false) else "red",
		"python_state": "green" if py.get("ok", false) else "red",
		"python_command": py.get("command", ""),
		"options_light": "green",
		"options_state": "green",
		"proof_policy": "detect_only_no_pull_no_install"
	}


func get_ollama_hardware_check() -> Dictionary:
	var fixture = OS.get_environment("LACAPULT_HARDWARE_FIXTURE")
	if fixture != "":
		return _ollama_hardware_fixture(fixture)
	var ram_mb = 0
	var vram_mb = 0
	var gpu_names = []
	var source = "unavailable"
	if OS.get_name() == "Windows":
		source = "windows_powershell_cim"
		ram_mb = _windows_total_ram_mb()
		vram_mb = _windows_max_vram_mb()
		gpu_names = _windows_gpu_names()
	return _build_ollama_hardware_check(ram_mb, vram_mb, source, "", gpu_names)


func build_ollama_setup_plan(endpoint: String = DEFAULT_OLLAMA_URL, model: String = "") -> Dictionary:
	var selected_model = normalize_ollama_model_tag(model)
	if selected_model == "":
		selected_model = OLLAMA_MODEL_MISTRAL
	var inventory = _ollama_inventory(endpoint)
	var commands = []
	var installer = "manual"
	var os_name = OS.get_name()
	if inventory.get("command", "missing") != "present":
		if os_name == "OSX" and _command_exists("brew"):
			installer = "homebrew"
			commands.append({"phase": "install_ollama_cli", "command": "brew", "args": ["install", "ollama"], "purpose": "Install Ollama through Homebrew."})
		elif os_name == "Windows" and _command_exists("winget"):
			installer = "winget"
			commands.append({"phase": "install_ollama_cli", "command": "winget", "args": ["install", "--id", "Ollama.Ollama", "-e"], "purpose": "Install the official Ollama Windows package through winget id Ollama.Ollama."})
		else:
			installer = "manual_required"
	if inventory.get("command", "missing") == "present" and inventory.get("server", "unreachable") == "running" and selected_model != "":
		if selected_model == OLLAMA_MODEL_NEMOTRON:
			if not _ollama_model_list_has(inventory.get("models", []), OLLAMA_MODEL_NEMOTRON_SOURCE):
				commands.append({"phase": "pull_nemotron_source", "command": "ollama", "args": ["pull", OLLAMA_MODEL_NEMOTRON_SOURCE], "purpose": "Pull the Nemotron Virtuoso source model after confirmation."})
			if not _ollama_model_list_has(inventory.get("models", []), OLLAMA_MODEL_NEMOTRON):
				var modelfile_path = _ollama_nemotron_modelfile_path()
				commands.append({"phase": "write_nemotron_no_think_modelfile", "command": "write_file", "args": [modelfile_path], "preview": "write %s" % modelfile_path, "content": _ollama_nemotron_modelfile_text(), "purpose": "Write a local no-thinking Nemotron Modelfile. This records setup text only; it does not duplicate model weights."})
				commands.append({"phase": "create_nemotron_no_think_alias", "command": "ollama", "args": ["create", OLLAMA_MODEL_NEMOTRON, "-f", modelfile_path], "purpose": "Create the C-AOL-safe Nemotron alias with SYSTEM /no_think. Ollama reuses the source model blobs instead of pulling a second copy."})
		elif not _ollama_model_list_has(inventory.get("models", []), selected_model):
			commands.append({"phase": "pull_selected_model", "command": "ollama", "args": ["pull", selected_model], "purpose": "Pull the selected model after confirmation."})
	var preview = []
	for step in commands:
		preview.append("Step %s: %s" % [str(preview.size() + 1), step.get("preview", "%s %s" % [step.get("command", ""), " ".join(step.get("args", []))])])
	return {
		"action": "install_ollama_and_prepare_model",
		"endpoint": endpoint.strip_edges() if endpoint.strip_edges() != "" else DEFAULT_OLLAMA_URL,
		"model": selected_model,
		"model_source": get_ollama_pull_source_for_model(selected_model),
		"model_setup_mode": OLLAMA_MODEL_NEMOTRON_MODE if selected_model == OLLAMA_MODEL_NEMOTRON else "direct_pull",
		"platform": os_name,
		"installer": installer,
		"commands": commands,
		"phase_order": _command_phases(commands),
		"command_preview": "\n".join(preview) if preview.size() > 0 else "Manual Ollama install/startup required before model preparation; no safe one-step command is queued.",
		"sequencing": "serialized_steps_not_shell_chained",
		"timeout_note": "The launcher may appear to time out. Wait for Ollama installation to commence.",
		"next_step": "Run Check after an Ollama install/startup step, then use Install Ollama / model again for model pull or alias preparation if needed.",
		"requires_confirmation": true,
		"automated_proof_policy": "plan_only_no_installer_no_model_pull_no_alias_create"
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
		var exit_code = 0
		if step.get("command", "") == "write_file":
			exit_code = _write_text_file(str(step.get("args", [""])[0]), str(step.get("content", "")), output)
		else:
			exit_code = OS.execute(step.get("command", ""), step.get("args", []), true, output, true)
		var result = {"phase": step.get("phase", "ollama_setup"), "command": step.get("command", ""), "args": step.get("args", []), "purpose": step.get("purpose", "Ollama setup command."), "exit_code": exit_code, "output_line_count": output.size(), "output_summary": _safe_command_output_summary(output)}
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

func build_backend_runner_test_plan(mode: String, endpoint: String = "", model: String = "", python_path: String = "", api_provider: String = DEFAULT_API_PROVIDER, api_key_env: String = DEFAULT_API_KEY_ENV, proof_only: bool = false) -> Dictionary:
	var normalized = _normalize_backend_fields(mode, endpoint, model, python_path, api_provider, api_key_env, "", DEFAULT_OPENVINO_DEVICE)
	var runner_path = _resolve_caol_runner_path()
	var py = _resolve_python(normalized.get("python_path", ""))
	var python_command = py.get("command", "") if py.get("ok", false) else "python3"
	var args = []
	if runner_path != "":
		args.append(runner_path)
	args.append("--backend")
	args.append(mode)
	if mode == BACKEND_API:
		args.append_array(["--api-provider", normalized.get("api_provider", DEFAULT_API_PROVIDER), "--api-model", normalized.get("model", ""), "--api-key-env", normalized.get("api_key_env", DEFAULT_API_KEY_ENV)])
	elif mode == BACKEND_OLLAMA:
		args.append_array(["--ollama-url", normalized.get("endpoint", DEFAULT_OLLAMA_URL), "--ollama-model", normalized.get("model", "")])
	if proof_only:
		args.append("--dry-run")
	else:
		args.append_array(["--self-test", "--self-test-prompt", "Catapult-Dabubu runner test", "--max-tokens", "16"])
	var preview_args = []
	for arg in args:
		preview_args.append(str(arg))
	return {
		"action": "runner_test",
		"backend": mode,
		"runner_path": runner_path,
		"python_command": python_command,
		"args": args,
		"command_preview": "%s %s" % [python_command, PoolStringArray(preview_args).join(" ")],
		"requires_confirmation": true,
		"proof_only": proof_only,
		"proof_policy": "dry_run_invokes_caol_runner_no_api_call_no_model_request" if proof_only else "confirmed_self_test_may_call_selected_backend_no_install_no_pull",
		"secret_policy": "API key values are never written to the command preview or intent; only the configured env-var name is passed."
	}


func run_backend_runner_test(mode: String, endpoint: String = "", model: String = "", python_path: String = "", api_provider: String = DEFAULT_API_PROVIDER, api_key_env: String = DEFAULT_API_KEY_ENV, proof_only: bool = false) -> Dictionary:
	var plan = build_backend_runner_test_plan(mode, endpoint, model, python_path, api_provider, api_key_env, proof_only)
	if not mode in [BACKEND_API, BACKEND_OLLAMA]:
		return {"status": "runner_test_unsupported_backend", "plan": plan, "exit_code": -1, "proof_only": proof_only, "performed_live_backend_call": false}
	if plan.get("runner_path", "") == "":
		var missing_result = write_backend_runner_test_intent(mode, plan, false, -1, "runner_test_runner_missing", "")
		return {"status": "runner_test_runner_missing" if missing_result == "ok" else missing_result, "plan": plan, "exit_code": -1, "proof_only": proof_only, "performed_live_backend_call": false}
	var output = []
	var exit_code = OS.execute(plan.get("python_command", "python3"), plan.get("args", []), true, output, true)
	var output_summary = _safe_command_output_summary(output)
	var summary = "runner_test_ok" if exit_code == 0 else "runner_test_failed_%s" % exit_code
	var write_result = write_backend_runner_test_intent(mode, plan, not proof_only, exit_code, summary, output_summary)
	var status = summary if write_result == "ok" else write_result
	return {"status": status, "plan": plan, "exit_code": exit_code, "proof_only": proof_only, "performed_live_backend_call": not proof_only, "output_summary": output_summary}


func build_python_venv_setup_plan(python_path: String = "") -> Dictionary:
	var input_path = python_path.strip_edges()
	var target = input_path
	var py = _resolve_python(input_path if _looks_like_python_executable_path(input_path) else "")
	if target == "" or _looks_like_python_executable_path(target):
		target = Paths.config.plus_file("caol-llm-python-venv")
	if not py.get("ok", false):
		py = _resolve_python("")
	var python_command = py.get("command", "python3") if py.get("ok", false) else "python3"
	var venv_python_command = _venv_python_command(target)
	var commands = [
		{
			"phase": "create_or_update_venv",
			"command": python_command,
			"args": ["-m", "venv", target],
			"preview": "%s -m venv %s" % [python_command, target],
			"purpose": "Create or update the shared Python venv used by C-AOL runner.py and manual debug handoffs."
		}
	]
	var harness_step = _build_openclaw_harness_requirements_step(venv_python_command)
	if not harness_step.empty():
		commands.append(harness_step)
	var preview = []
	var phase_order = []
	for i in range(commands.size()):
		preview.append("Step %s: %s" % [str(i + 1), commands[i].get("preview", "")])
		phase_order.append(commands[i].get("phase", ""))
	return {
		"action": "create_python_venv",
		"target_path": target,
		"python_command": python_command,
		"venv_python_command": venv_python_command,
		"command_preview": "%s -m venv %s" % [python_command, target],
		"command": PoolStringArray(preview).join("\n"),
		"commands": commands,
		"phase_order": phase_order,
		"harness_requirements_path": resolve_openclaw_harness_requirements_path(),
		"requires_confirmation": true,
		"automated_proof_policy": "plan_only_no_venv_no_pip_mutation"
	}


func run_python_venv_setup(python_path: String = "", proof_only: bool = false) -> Dictionary:
	var plan = build_python_venv_setup_plan(python_path)
	if proof_only:
		var proof_result = write_python_venv_setup_intent(plan.get("target_path", ""), false, -1, "proof_only_no_venv_no_pip_mutation", plan, [])
		return {"status": proof_result, "plan": plan, "performed_external_install": false, "proof_only": true}
	var results = []
	var failed = false
	var exit_code = 0
	for step in plan.get("commands", []):
		var output = []
		exit_code = OS.execute(step.get("command", ""), step.get("args", []), true, output, true)
		results.append({"phase": step.get("phase", ""), "command": step.get("command", ""), "args": step.get("args", []), "purpose": step.get("purpose", ""), "exit_code": exit_code, "output_line_count": output.size(), "output_summary": _safe_command_output_summary(output)})
		if exit_code != 0:
			failed = true
			break
	var failed_phase = results[results.size() - 1].get("phase", "python_venv") if results.size() > 0 else "python_venv"
	var summary = "python_venv_and_harness_requirements_setup_ok" if not failed else "%s_failed" % failed_phase
	var write_result = write_python_venv_setup_intent(plan.get("target_path", ""), true, exit_code, summary, plan, results)
	var status = "python_venv_setup_ok" if not failed else "python_venv_setup_%s_failed_%s" % [failed_phase, exit_code]
	if write_result != "ok":
		status = write_result
	return {"status": status, "plan": plan, "performed_external_install": true, "proof_only": false, "exit_code": exit_code, "results": results}


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
	return "Setup paths: API / AnyLLM for a hosted backend, Ollama for mainstream local play, and OpenVINO for specialized local acceleration. Check is detection-only. Save options writes the selected runner option patch and applies it to the active C-AOL userdir options.json with a backup. It still makes no API call, model pull, package install, or generated summary-pack apply."

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
		return {"color": "green", "state": "Ready", "summary": "Options saved."}
	if raw_status.find("unsupported") >= 0 or raw_status.find("write_error") >= 0 or raw_status.find("config_dir_error") >= 0 or raw_status.find("game_config_dir_unavailable") >= 0 or raw_status.find("options_apply") >= 0 or raw_status.find("options_json") >= 0:
		return {"color": "red", "state": "Error", "summary": "Save/check failed."}
	if raw_status.find("api_python_missing") >= 0 or raw_status.find("ollama_command_missing") >= 0 or raw_status.find("openvino_python_missing") >= 0:
		return {"color": "red", "state": "Missing", "summary": _status_summary(raw_status)}
	if raw_status.find("api_python_ready_any_llm_import_ok") >= 0 and raw_status.find("model_configured") >= 0 and raw_status.find("api_key_env_present_secret_not_read") >= 0:
		return {"color": "green", "state": "Ready", "summary": "Python, AnyLLM, model, and API-key env-var are present."}
	if raw_status.find("ollama_command_present_server_running_model_present") >= 0:
		return {"color": "green", "state": "Ready", "summary": "Ollama server and selected model are present."}
	return {"color": "yellow", "state": "Needs action", "summary": _status_summary(raw_status)}


func write_launcher_backend_config(mode: String, endpoint: String = "", model: String = "", python_path: String = "", api_provider: String = DEFAULT_API_PROVIDER, api_key_env: String = DEFAULT_API_KEY_ENV, openvino_model_dir: String = "", openvino_device: String = DEFAULT_OPENVINO_DEVICE) -> String:
	if not mode in [BACKEND_API, BACKEND_OLLAMA, BACKEND_OPENVINO]:
		return "unsupported_backend"

	var config_dir = Paths.config
	if config_dir == "":
		return "game_config_dir_unavailable_active_install_required"
	var d = Directory.new()
	if not d.dir_exists(config_dir):
		var err = d.make_dir_recursive(config_dir)
		if err != OK:
			return "config_dir_error_%s" % err

	var normalized = _normalize_backend_fields(mode, endpoint, model, python_path, api_provider, api_key_env, openvino_model_dir, openvino_device)
	var status = _detect_backend_status(mode, normalized)
	var options_patch = _build_caol_options_patch(mode, normalized)
	var options_apply = _apply_caol_options_patch_to_active_user_config(options_patch)
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
		"caol_options_patch": options_patch,
		"caol_options_apply": options_apply
	}
	if not Helpers.save_to_json_file(safe_config, config_dir.plus_file(BACKEND_CONFIG_FILENAME)):
		return "config_write_error"
	if not Helpers.save_to_json_file(options_patch, config_dir.plus_file(C_AOL_OPTIONS_PATCH_FILENAME)):
		return "options_patch_write_error"
	if not Helpers.save_to_json_file(options_apply, config_dir.plus_file(C_AOL_OPTIONS_APPLY_FILENAME)):
		return "options_apply_manifest_write_error"
	if not options_apply.get("ok", false):
		return str(options_apply.get("status", "options_apply_failed"))
	return "ok"


func _ensure_backend_config_dir() -> Dictionary:
	var config_dir = Paths.config
	if config_dir == "":
		return {"ok": false, "status": "game_config_dir_unavailable_active_install_required", "path": ""}
	var d = Directory.new()
	if not d.dir_exists(config_dir):
		var err = d.make_dir_recursive(config_dir)
		if err != OK and err != ERR_ALREADY_EXISTS:
			return {"ok": false, "status": "config_dir_error_%s" % err, "path": config_dir}
	return {"ok": true, "status": "ok", "path": config_dir}


func write_api_setup_intent(provider_id: String, python_path: String = "", performed_external_install: bool = false, exit_code: int = -1, result_summary: String = "plan_only_no_venv_no_pip_no_secret_no_api_call", command_results: Array = []) -> String:
	var config_dir_status = _ensure_backend_config_dir()
	if not config_dir_status.get("ok", false):
		return config_dir_status.get("status", "config_dir_error")
	var config_dir = config_dir_status.get("path", "")
	var plan = build_api_setup_plan(provider_id, python_path)
	var intent = {
		"action": "install_api_backend",
		"provider": plan.get("provider", DEFAULT_API_PROVIDER),
		"provider_label": plan.get("provider_label", "OpenAI"),
		"target_venv_path": plan.get("target_venv_path", ""),
		"python_command": plan.get("python_command", "python3"),
		"package_spec": plan.get("package_spec", ANY_LLM_PIP_PACKAGE),
		"harness_requirements_path": plan.get("harness_requirements_path", ""),
		"command_preview": plan.get("command", "python3 -m pip install --upgrade %s" % ANY_LLM_PIP_PACKAGE),
		"commands": plan.get("commands", []),
		"phase_order": plan.get("phase_order", []),
		"confirmed": true,
		"performed_external_install": performed_external_install,
		"exit_code": exit_code,
		"command_results": command_results,
		"result_summary": result_summary,
		"proof_policy": plan.get("automated_proof_policy", "plan_only_no_pip_no_secret_no_api_call"),
		"secret_policy": "No API key is stored or displayed; only the env-var name belongs in backend config.",
		"recorded_at": OS.get_datetime()
	}
	if not Helpers.save_to_json_file(intent, config_dir.plus_file(API_SETUP_INTENT_FILENAME)):
		return "api_setup_intent_write_error"
	return "ok"



func write_ollama_setup_intent(endpoint: String = DEFAULT_OLLAMA_URL, model: String = "", performed_external_install: bool = false, command_results: Array = [], result_summary: String = "plan_only_no_installer_no_model_pull") -> String:
	var config_dir_status = _ensure_backend_config_dir()
	if not config_dir_status.get("ok", false):
		return config_dir_status.get("status", "config_dir_error")
	var config_dir = config_dir_status.get("path", "")
	var plan = build_ollama_setup_plan(endpoint, model)
	var intent = {
		"action": plan.get("action", "install_ollama_and_prepare_model"),
		"endpoint": plan.get("endpoint", DEFAULT_OLLAMA_URL),
		"model": plan.get("model", model),
		"model_source": plan.get("model_source", plan.get("model", model)),
		"model_setup_mode": plan.get("model_setup_mode", "direct_pull"),
		"platform": plan.get("platform", OS.get_name()),
		"installer": plan.get("installer", "manual_required"),
		"command_preview": plan.get("command_preview", ""),
		"commands": plan.get("commands", []),
		"phase_order": plan.get("phase_order", []),
		"confirmed": true,
		"performed_external_install": performed_external_install,
		"command_results": command_results,
		"result_summary": result_summary,
		"proof_policy": plan.get("automated_proof_policy", "plan_only_no_installer_no_model_pull_no_alias_create"),
		"recorded_at": OS.get_datetime()
	}
	if not Helpers.save_to_json_file(intent, config_dir.plus_file(OLLAMA_SETUP_INTENT_FILENAME)):
		return "ollama_setup_intent_write_error"
	return "ok"


func write_backend_runner_test_intent(mode: String, plan: Dictionary, performed_live_backend_call: bool = false, exit_code: int = -1, result_summary: String = "plan_only_no_runner_call", output_summary: String = "") -> String:
	var config_dir_status = _ensure_backend_config_dir()
	if not config_dir_status.get("ok", false):
		return config_dir_status.get("status", "config_dir_error")
	var config_dir = config_dir_status.get("path", "")
	var intent = {
		"action": "runner_test",
		"backend": mode,
		"runner_path": plan.get("runner_path", ""),
		"python_command": plan.get("python_command", "python3"),
		"args": plan.get("args", []),
		"command_preview": plan.get("command_preview", ""),
		"confirmed": true,
		"performed_live_backend_call": performed_live_backend_call,
		"exit_code": exit_code,
		"result_summary": result_summary,
		"output_summary": output_summary,
		"proof_policy": plan.get("proof_policy", "dry_run_invokes_caol_runner_no_api_call_no_model_request"),
		"secret_policy": plan.get("secret_policy", "API key values are never stored."),
		"recorded_at": OS.get_datetime()
	}
	if not Helpers.save_to_json_file(intent, config_dir.plus_file(RUNNER_TEST_INTENT_FILENAME)):
		return "runner_test_intent_write_error"
	return "ok"


func write_python_venv_setup_intent(target_path: String, performed_external_install: bool = false, exit_code: int = -1, result_summary: String = "plan_only_no_venv_no_pip_mutation", plan: Dictionary = {}, command_results: Array = []) -> String:
	var config_dir_status = _ensure_backend_config_dir()
	if not config_dir_status.get("ok", false):
		return config_dir_status.get("status", "config_dir_error")
	var config_dir = config_dir_status.get("path", "")
	if plan.empty():
		plan = build_python_venv_setup_plan(target_path)
	var intent = {
		"action": "create_python_venv",
		"target_path": target_path,
		"venv_python_command": plan.get("venv_python_command", ""),
		"harness_requirements_path": plan.get("harness_requirements_path", ""),
		"command_preview": plan.get("command", plan.get("command_preview", "")),
		"commands": plan.get("commands", []),
		"phase_order": plan.get("phase_order", []),
		"confirmed": true,
		"performed_external_install": performed_external_install,
		"exit_code": exit_code,
		"command_results": command_results,
		"result_summary": result_summary,
		"proof_policy": plan.get("automated_proof_policy", "plan_only_no_venv_no_pip_mutation"),
		"recorded_at": OS.get_datetime()
	}
	if not Helpers.save_to_json_file(intent, config_dir.plus_file(PYTHON_VENV_SETUP_INTENT_FILENAME)):
		return "python_venv_setup_intent_write_error"
	return "ok"


func _status_summary(raw_status: String) -> String:
	if raw_status.find("game_config_dir_unavailable") >= 0:
		return "Choose/install an active C-AOL build before saving game options."
	if raw_status.find("options_json_not_array") >= 0:
		return "Active C-AOL options.json is not a JSON option array; a backup was preserved."
	if raw_status.find("options_backup") >= 0:
		return "Could not back up active C-AOL options.json before applying runner options."
	if raw_status.find("options_apply") >= 0 or raw_status.find("options_write_error") >= 0:
		return "Could not apply runner options to the active C-AOL options.json."
	if raw_status.find("runner_test_runner_missing") >= 0:
		return "C-AOL runner.py was not found in the active install."
	if raw_status.find("runner_test_failed") >= 0:
		return "C-AOL runner test failed; inspect the runner output."
	if raw_status.find("runner_test_ok") >= 0:
		return "C-AOL runner path responded."
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
	if command == "write_file":
		return "ollama_setup_modelfile_write_failed_%s" % str(failed_step.get("exit_code", "unknown"))
	if command == "ollama" and args.size() > 0 and str(args[0]) == "pull":
		return "ollama_setup_model_pull_failed_%s" % str(failed_step.get("exit_code", "unknown"))
	if command == "ollama" and args.size() > 0 and str(args[0]) == "create":
		return "ollama_setup_model_alias_create_failed_%s" % str(failed_step.get("exit_code", "unknown"))
	if command == "brew" or command == "winget":
		return "ollama_setup_installer_failed_%s" % str(failed_step.get("exit_code", "unknown"))
	return "ollama_setup_command_failed_%s" % str(failed_step.get("exit_code", "unknown"))


func write_sandboxed_options_config(options_path: String, mode: String, endpoint: String = "", model: String = "", python_path: String = "", api_provider: String = DEFAULT_API_PROVIDER, api_key_env: String = DEFAULT_API_KEY_ENV, openvino_model_dir: String = "", openvino_device: String = DEFAULT_OPENVINO_DEVICE) -> String:
	# Repeatable proof helper only. Normal Save options writes the active C-AOL
	# userdir config/options.json; this helper still refuses normal-looking paths.
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
	if mode == BACKEND_OLLAMA:
		if normalized["endpoint"] == "":
			normalized["endpoint"] = DEFAULT_OLLAMA_URL
		normalized["model"] = normalize_ollama_model_tag(normalized["model"])
	if mode == BACKEND_OPENVINO:
		normalized["endpoint"] = ""
		normalized["model"] = ""
	return normalized


func normalize_ollama_model_tag(model: String) -> String:
	var cleaned = model.strip_edges()
	if cleaned == "" or cleaned == "mistral-v0.3":
		return OLLAMA_MODEL_MISTRAL
	if cleaned == "nemotron-9b" or cleaned == OLLAMA_MODEL_NEMOTRON_SOURCE or cleaned == "nemotron-9b-full:latest":
		return OLLAMA_MODEL_NEMOTRON
	return cleaned


func _ollama_nemotron_modelfile_path() -> String:
	return Paths.config.plus_file("Nemotron-9B-no-think.Modelfile")


func _ollama_nemotron_modelfile_text() -> String:
	return "FROM %s\nSYSTEM \"/no_think\nAnswer directly. No reasoning.\nPrefer straightforward, practical answers.\nChoose the obvious option over a clever one.\nKeep outputs simple, grounded, and gamey.\nAvoid overexplaining, roleplay flourishes, and fancy wording unless explicitly asked.\n\"\nPARAMETER num_ctx 16384\nPARAMETER num_gpu 999\nPARAMETER num_keep 2048\nPARAMETER num_predict 4096\nPARAMETER temperature 0.85\nPARAMETER top_p 0.92\n" % OLLAMA_MODEL_NEMOTRON_SOURCE


func _write_text_file(path: String, content: String, output: Array) -> int:
	var dir = path.get_base_dir()
	var d = Directory.new()
	if dir != "" and not d.dir_exists(dir):
		var err = d.make_dir_recursive(dir)
		if err != OK:
			output.append("failed to create directory %s: %s" % [dir, err])
			return int(err) if int(err) != 0 else 1
	var f = File.new()
	var open_err = f.open(path, File.WRITE)
	if open_err != OK:
		output.append("failed to open %s: %s" % [path, open_err])
		return int(open_err) if int(open_err) != 0 else 1
	f.store_string(content)
	f.close()
	output.append("wrote %s" % path)
	return 0


func _command_phases(commands: Array) -> Array:
	var phases = []
	for step in commands:
		phases.append(step.get("phase", step.get("command", "")))
	return phases


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
		"apply_status": "applied_to_active_userdir_on_save",
		"notes": "These are the C-AOL option names Catapult-Dabubu saves for the active runner setup and applies to the active userdir config/options.json. The patch includes runner enablement, backend mode, selected model, and hidden API-vs-local mode so C-AOL does not keep an old runner state. API keys are referenced by environment variable only, never stored here. LLM_INTENT_PYTHON is the shared Python/venv path used by C-AOL to launch tools/llm_runner/runner.py, not only OpenVINO.",
		"metadata_only": {
			"api_provider": fields.get("api_provider", DEFAULT_API_PROVIDER),
			"api_provider_note": "C-AOL reads LLM_INTENT_API_PROVIDER; Catapult-Dabubu stores provider intent without storing secrets."
		},
		"options": [
			{
				"name": "LLM_INTENT_ENABLE",
				"value": "true",
				"reason": "Enable the C-AOL LLM runner when the selected setup is applied."
			},
			{
				"name": "LLM_INTENT_BACKEND",
				"value": mode,
				"reason": "Select the LLM backend."
			},
			{
				"name": "LLM_INTENT_USE_API",
				"value": "true" if mode == BACKEND_API else "false",
				"reason": "Clear stale hidden API/local runner mode when switching between API, Ollama, and OpenVINO."
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
			"reason": "Selected API provider for C-AOL runner.py/AnyLLM."
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


func resolve_runner_python_command(python_path: String = "") -> String:
	var py = _resolve_python(python_path)
	if py.get("ok", false):
		return py.get("command", "")
	return "python" if OS.get_name() == "Windows" else "python3"


func resolve_openclaw_harness_script_path() -> String:
	return _resolve_caol_relative_file_path(OPENCLAW_HARNESS_SCRIPT_RELATIVE_PATH, "LACAPULT_OPENCLAW_HARNESS_PATH")


func resolve_active_install_openclaw_harness_script_path() -> String:
	return _resolve_caol_active_install_relative_file_path(OPENCLAW_HARNESS_SCRIPT_RELATIVE_PATH)


func resolve_openclaw_harness_requirements_path() -> String:
	return _resolve_caol_relative_file_path(OPENCLAW_HARNESS_REQUIREMENTS_RELATIVE_PATH, "LACAPULT_OPENCLAW_HARNESS_REQUIREMENTS")


func resolve_openclaw_harness_root() -> String:
	var script_path = resolve_openclaw_harness_script_path()
	if script_path == "":
		return ""
	return script_path.get_base_dir()


func _resolve_caol_runner_path() -> String:
	var env_path = OS.get_environment("LACAPULT_CAOL_RUNNER_PATH")
	if env_path != "" and File.new().file_exists(env_path):
		return env_path
	var d = Directory.new()
	var game_runner = Paths.game_dir.plus_file("tools").plus_file("llm_runner").plus_file("runner.py")
	if game_runner != "" and File.new().file_exists(game_runner):
		return game_runner
	var dev_runner = Paths.own_dir.get_base_dir().plus_file("Cataclysm-AOL").plus_file("tools").plus_file("llm_runner").plus_file("runner.py")
	if d.file_exists(dev_runner):
		return dev_runner
	return ""


func _resolve_caol_relative_file_path(relative_path: String, env_name: String) -> String:
	var env_path = OS.get_environment(env_name)
	if env_path != "" and File.new().file_exists(env_path):
		return env_path
	var d = Directory.new()
	for root in _caol_resource_roots():
		var candidate = root.plus_file(relative_path)
		if d.file_exists(candidate):
			return candidate
	return ""


func _resolve_caol_active_install_relative_file_path(relative_path: String) -> String:
	var d = Directory.new()
	for root in _caol_active_install_resource_roots():
		var candidate = root.plus_file(relative_path)
		if d.file_exists(candidate):
			return candidate
	return ""


func _caol_active_install_resource_roots() -> Array:
	var roots = []
	var game_dir = Paths.game_dir
	if game_dir == "" or not Directory.new().dir_exists(game_dir):
		return roots
	roots.append(game_dir)
	if game_dir.ends_with(".app"):
		roots.append(game_dir.plus_file("Contents").plus_file("Resources"))
	else:
		var d = Directory.new()
		for item in FS.list_dir(game_dir):
			if item.ends_with(".app"):
				roots.append(game_dir.plus_file(item).plus_file("Contents").plus_file("Resources"))
	return roots


func _caol_resource_roots() -> Array:
	var roots = _caol_active_install_resource_roots()
	var dev_root = Paths.own_dir.get_base_dir().plus_file("Cataclysm-AOL")
	roots.append(dev_root)
	return roots


func _build_openclaw_harness_requirements_step(venv_python_command: String) -> Dictionary:
	var requirements_path = resolve_openclaw_harness_requirements_path()
	if requirements_path == "":
		return {}
	return {
		"phase": "install_openclaw_harness_requirements",
		"command": venv_python_command,
		"args": ["-m", "pip", "install", "--upgrade", "-r", requirements_path],
		"preview": "%s -m pip install --upgrade -r %s" % [venv_python_command, requirements_path],
		"purpose": "Install packaged OpenClaw manual-handoff harness requirements into the shared C-AOL Python venv."
	}


func _command_exists(command: String) -> bool:
	var output = []
	var command_lookup = "where" if OS.get_name() == "Windows" else "which"
	return OS.execute(command_lookup, [command], true, output, true) == 0


func _venv_python_command(target_path: String) -> String:
	if target_path.strip_edges() == "":
		return "python3"
	if OS.get_name() == "Windows":
		return target_path.plus_file("Scripts").plus_file("python.exe")
	return target_path.plus_file("bin").plus_file("python")


func _windows_total_ram_mb() -> int:
	var output = []
	var code = "$m=(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory; [math]::Round($m/1MB)"
	var exit_code = OS.execute("powershell", ["-NoProfile", "-Command", code], true, output, true)
	if exit_code != 0:
		return 0
	return int("\n".join(output).strip_edges())


func _windows_max_vram_mb() -> int:
	var output = []
	var code = "$m=(Get-CimInstance Win32_VideoController | Measure-Object AdapterRAM -Maximum).Maximum; if ($m) { [math]::Round($m/1MB) } else { 0 }"
	var exit_code = OS.execute("powershell", ["-NoProfile", "-Command", code], true, output, true)
	if exit_code != 0:
		return 0
	return int("\n".join(output).strip_edges())


func _windows_gpu_names() -> Array:
	var output = []
	var code = "Get-CimInstance Win32_VideoController | ForEach-Object { ($_.Name + ' | ' + $_.VideoProcessor + ' | ' + $_.AdapterCompatibility) }"
	var exit_code = OS.execute("powershell", ["-NoProfile", "-Command", code], true, output, true)
	if exit_code != 0:
		return []
	var names = []
	for line in output:
		var cleaned = str(line).strip_edges()
		if cleaned != "":
			names.append(cleaned)
	return names


func _ollama_hardware_fixture(fixture: String) -> Dictionary:
	var ram_mb = 0
	var vram_mb = 0
	var accel_hint = ""
	var gpu_names = []
	for part in fixture.split(","):
		var bits = part.split(":")
		if bits.size() != 2:
			continue
		if bits[0] == "ram":
			ram_mb = int(bits[1])
		elif bits[0] == "vram":
			vram_mb = int(bits[1])
		elif bits[0] == "accel":
			accel_hint = str(bits[1])
		elif bits[0] == "gpu":
			gpu_names.append(str(bits[1]).replace("_", " "))
	return _build_ollama_hardware_check(ram_mb, vram_mb, "fixture", accel_hint, gpu_names)


func _build_ollama_hardware_check(ram_mb: int, vram_mb: int, source: String, accel_hint: String = "", gpu_names: Array = []) -> Dictionary:
	var ram_gib = float(ram_mb) / 1024.0 if ram_mb > 0 else 0.0
	var vram_gib = float(vram_mb) / 1024.0 if vram_mb > 0 else 0.0
	var state = "gray"
	var acceleration = _ollama_acceleration_state(accel_hint, gpu_names, vram_mb, source)
	if ram_mb > 0 or vram_mb > 0:
		state = "green"
		var mistral_state = _ollama_performance_state(ram_mb, vram_mb, 16000, 4000, 8000, 1000)
		var nemotron_state = _ollama_performance_state(ram_mb, vram_mb, 32000, 8000, 16000, 2000)
		mistral_state = _cap_ollama_performance_for_acceleration(mistral_state, acceleration.get("state", "gray"))
		nemotron_state = _cap_ollama_performance_for_acceleration(nemotron_state, acceleration.get("state", "gray"))
		if mistral_state == "red" or nemotron_state == "red":
			state = "red"
		elif mistral_state == "yellow" or nemotron_state == "yellow":
			state = "yellow"
		if acceleration.get("state", "gray") == "red":
			state = "red"
		elif acceleration.get("state", "gray") == "yellow" and state == "green":
			state = "yellow"
		return {"ram_mb": ram_mb, "vram_mb": vram_mb, "ram_gib": ram_gib, "vram_gib": vram_gib, "state": state, "performance_lights": {OLLAMA_MODEL_MISTRAL: mistral_state, OLLAMA_MODEL_NEMOTRON: nemotron_state}, "acceleration": acceleration, "acceleration_state": acceleration.get("state", "gray"), "acceleration_label": acceleration.get("label", "not measured"), "gpu_names": gpu_names, "source": source, "proof_policy": "hardware_detect_only_no_install_no_pull"}
	return {"ram_mb": ram_mb, "vram_mb": vram_mb, "ram_gib": ram_gib, "vram_gib": vram_gib, "state": state, "performance_lights": {OLLAMA_MODEL_MISTRAL: "gray", OLLAMA_MODEL_NEMOTRON: "gray"}, "acceleration": acceleration, "acceleration_state": acceleration.get("state", "gray"), "acceleration_label": acceleration.get("label", "not measured"), "gpu_names": gpu_names, "source": source, "proof_policy": "hardware_detect_only_no_install_no_pull"}


func _ollama_acceleration_state(accel_hint: String, gpu_names: Array, vram_mb: int, source: String) -> Dictionary:
	var hint = accel_hint.strip_edges().to_lower()
	var joined = PoolStringArray(gpu_names).join(" ").to_lower()
	if hint in ["nvidia", "cuda", "accelerated"] or joined.find("nvidia") >= 0:
		return {"mode": "nvidia_cuda", "state": "green", "label": "NVIDIA/CUDA accelerated", "summary": "NVIDIA/CUDA detected for local Ollama."}
	if hint in ["cpu", "cpu_only", "none"] or (source == "windows_powershell_cim" and vram_mb <= 0):
		return {"mode": "cpu_only", "state": "red", "label": "CPU-only slow fallback", "summary": "CPU-only Windows Ollama will be very slow; prefer API or a smaller local model."}
	if hint in ["igpu", "integrated", "intel", "amd", "other_gpu"] or joined.find("intel") >= 0 or joined.find("iris") >= 0 or joined.find("uhd") >= 0 or joined.find("radeon") >= 0:
		return {"mode": "igpu_or_other_gpu", "state": "yellow", "label": "iGPU/other GPU slow fallback", "summary": "Windows local mode may fall back to slow iGPU/CPU behavior; API or smaller models may feel better."}
	return {"mode": "not_measured", "state": "gray", "label": "acceleration not measured", "summary": "GPU acceleration was not measured by this check."}


func _cap_ollama_performance_for_acceleration(state: String, acceleration_state: String) -> String:
	if acceleration_state == "red":
		return "red"
	if acceleration_state == "yellow" and state == "green":
		return "yellow"
	return state


func _ollama_performance_state(ram_mb: int, vram_mb: int, green_ram_mb: int, green_vram_mb: int, yellow_ram_mb: int, yellow_vram_mb: int) -> String:
	if ram_mb >= green_ram_mb and vram_mb >= green_vram_mb:
		return "green"
	if ram_mb >= yellow_ram_mb and vram_mb >= yellow_vram_mb:
		return "yellow"
	return "red"


func _safe_command_output_summary(output: Array, max_lines: int = 8, max_chars: int = 1200) -> String:
	var lines = []
	for raw in output:
		var line = str(raw).strip_edges()
		if line == "":
			continue
		lines.append(line)
		if lines.size() >= max_lines:
			break
	var summary = PoolStringArray(lines).join("\n")
	if summary.length() > max_chars:
		summary = summary.substr(0, max_chars) + "... [truncated]"
	return summary


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


func _apply_caol_options_patch_to_active_user_config(patch: Dictionary) -> Dictionary:
	var config_dir = Paths.config
	if str(Settings.read("game")) != "caol":
		return {"ok": false, "status": "game_config_dir_unavailable_caol_required", "options_path": ""}
	if config_dir == "":
		return {"ok": false, "status": "game_config_dir_unavailable_active_install_required", "options_path": ""}

	var d = Directory.new()
	if not d.dir_exists(config_dir):
		var dir_err = d.make_dir_recursive(config_dir)
		if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
			return {"ok": false, "status": "config_dir_error_%s" % dir_err, "options_path": ""}

	var options_path = config_dir.plus_file(C_AOL_OPTIONS_FILENAME)
	var existed_before = File.new().file_exists(options_path)
	var backup = _backup_options_file_for_apply(options_path, existed_before)
	if not backup.get("ok", false):
		return backup
	var seed_result = _ensure_options_file_for_apply(options_path)
	if not seed_result.get("ok", false):
		seed_result["backup_dir"] = backup.get("backup_dir", "")
		seed_result["backup_path"] = backup.get("backup_path", "")
		return seed_result

	var apply_status = _apply_options_patch_to_file(options_path, patch)
	var ok = str(apply_status).begins_with("ok_changed_")
	return {
		"ok": ok,
		"status": apply_status if ok else "options_apply_failed_%s" % apply_status,
		"raw_apply_status": apply_status,
		"options_path": options_path,
		"backup_dir": backup.get("backup_dir", ""),
		"backup_path": backup.get("backup_path", ""),
		"existed_before": existed_before,
		"seed_status": seed_result.get("status", ""),
		"template_path": seed_result.get("template_path", ""),
		"patch_values": _patch_option_values(patch),
		"applied_at": OS.get_datetime(),
		"secret_policy": "API key values are never stored; only the configured environment variable name is written."
	}


func _ensure_options_file_for_apply(options_path: String) -> Dictionary:
	if File.new().file_exists(options_path):
		var current = Helpers.load_json_file(options_path)
		if typeof(current) != TYPE_ARRAY:
			return {"ok": false, "status": "options_json_not_array", "options_path": options_path}
		return {"ok": true, "status": "options_file_present", "options_path": options_path, "template_path": ""}

	var template_path = _find_caol_options_template_path()
	var seed_options = []
	if template_path != "":
		var template = Helpers.load_json_file(template_path)
		if typeof(template) != TYPE_ARRAY:
			return {"ok": false, "status": "options_template_json_not_array", "options_path": options_path, "template_path": template_path}
		seed_options = template

	if not Helpers.save_to_json_file(seed_options, options_path):
		return {"ok": false, "status": "options_seed_write_error", "options_path": options_path, "template_path": template_path}

	var seed_status = "options_file_seeded_from_template" if template_path != "" else "options_file_created_minimal"
	return {"ok": true, "status": seed_status, "options_path": options_path, "template_path": template_path}


func _find_caol_options_template_path() -> String:
	var game_dir = Paths.game_dir
	if game_dir == "":
		return ""
	var candidates = [
		game_dir.plus_file("config").plus_file(C_AOL_OPTIONS_FILENAME)
	]
	for item in FS.list_dir(game_dir):
		if item.ends_with(".app"):
			candidates.append(game_dir.plus_file(item).plus_file("Contents").plus_file("Resources").plus_file("config").plus_file(C_AOL_OPTIONS_FILENAME))
	for candidate in candidates:
		if File.new().file_exists(candidate):
			return candidate
	return ""


func _backup_options_file_for_apply(options_path: String, existed_before: bool) -> Dictionary:
	var backup_root = Paths.save_backups
	if backup_root == "":
		backup_root = Paths.own_dir.plus_file(str(Settings.read("game"))).plus_file("save_backups")
	var backup_dir = backup_root.plus_file("caol_llm_options_%s" % _timestamp_fragment())
	var d = Directory.new()
	var dir_err = d.make_dir_recursive(backup_dir)
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		return {"ok": false, "status": "options_backup_dir_error_%s" % dir_err, "options_path": options_path, "backup_dir": backup_dir}

	var backup_path = backup_dir.plus_file("options.json.before")
	if not existed_before:
		backup_path = backup_dir.plus_file("options.json.before.missing.json")
		var missing_write = _write_text_file_simple(backup_path, "{\n    \"missing_before_apply\": true\n}\n")
		if missing_write != "ok":
			return {"ok": false, "status": "options_backup_write_error_%s" % missing_write, "options_path": options_path, "backup_dir": backup_dir, "backup_path": backup_path}
		return {"ok": true, "status": "options_backup_missing_marker_written", "options_path": options_path, "backup_dir": backup_dir, "backup_path": backup_path}

	var read_result = _read_text_file_simple(options_path)
	if not read_result.get("ok", false):
		read_result["backup_dir"] = backup_dir
		return read_result
	var write_result = _write_text_file_simple(backup_path, read_result.get("text", ""))
	if write_result != "ok":
		return {"ok": false, "status": "options_backup_write_error_%s" % write_result, "options_path": options_path, "backup_dir": backup_dir, "backup_path": backup_path}
	return {"ok": true, "status": "options_backup_written", "options_path": options_path, "backup_dir": backup_dir, "backup_path": backup_path}


func _read_text_file_simple(path: String) -> Dictionary:
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		return {"ok": false, "status": "options_backup_read_error_%s" % err, "options_path": path}
	var text = f.get_as_text()
	f.close()
	return {"ok": true, "status": "ok", "text": text}


func _write_text_file_simple(path: String, content: String) -> String:
	var f = File.new()
	var err = f.open(path, File.WRITE)
	if err != OK:
		return str(err)
	f.store_string(content)
	f.close()
	return "ok"


func _timestamp_fragment() -> String:
	var dt = OS.get_datetime()
	return "%04d%02d%02d_%02d%02d%02d_%s" % [dt["year"], dt["month"], dt["day"], dt["hour"], dt["minute"], dt["second"], str(OS.get_ticks_msec())]


func _patch_option_values(patch: Dictionary) -> Dictionary:
	var values = {}
	for patch_option in patch.get("options", []):
		if typeof(patch_option) == TYPE_DICTIONARY:
			var option_name = str(patch_option.get("name", ""))
			if option_name != "":
				values[option_name] = str(patch_option.get("value", ""))
	return values


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
				"info": "Added by Catapult-Dabubu backend options apply from %s." % patch.get("source", "Catapult-Dabubu")
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
