extends SceneTree

# Headless v3 smoke for Save options / active runner apply semantics.
# It exercises the API and Ollama Save options UI, proves active C-AOL
# userdir options.json is updated, then also applies the produced C-AOL option
# set to sandbox options.json files. It never reads API secrets, calls a backend,
# installs packages, pulls models, or mutates non-isolated Application Support/user data.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	var paths = root.get_node("/root/Paths")
	var helpers = root.get_node("/root/Helpers")
	var backend = root.get_node("/root/BackendConfig")

	settings.store("game", "caol")
	settings.store("active_install_caol", "V3 Save Apply Sandbox")
	settings.store("backend_mode", "api")
	settings.store("backend_api_provider", "openrouter")
	settings.store("backend_api_endpoint", "")
	settings.store("backend_api_model", "")
	settings.store("backend_api_key_env", "LACAPULT_V3_KEY")
	settings.store("backend_python_path", "python3")
	settings.store("backend_ollama_endpoint", backend.DEFAULT_OLLAMA_URL)
	settings.store("backend_ollama_model", "qwen2.5:3b")

	var install_dir = paths.own_dir.plus_file("caol").plus_file("game0")
	var dir_err = Directory.new().make_dir_recursive(install_dir)
	_require(dir_err == OK or dir_err == ERR_ALREADY_EXISTS, "could not create sandbox active install")
	_require(helpers.save_to_json_file({"name": "V3 Save Apply Sandbox"}, install_dir.plus_file("catapult_install_info.json")), "could not create sandbox install info")

	var ui_script = load("res://scripts/BackendSetupUI.gd")
	var ui = VBoxContainer.new()
	ui.set_script(ui_script)
	root.add_child(ui)
	yield(self, "idle_frame")

	_run_api_save_apply_case(ui, backend, helpers, paths)
	_run_ollama_save_apply_case(ui, backend, helpers, paths, settings)

	print("v3 Save/apply runner UI smoke passed")
	print("  API proof: Save options produced backend=api and active options.json has LLM_INTENT_ENABLE=true, LLM_INTENT_USE_API=true, selected model, provider metadata, Python runner path, and env-var name without a secret")
	print("  Ollama proof: Save options normalized Nemotron to nemotron-9b-dumber:latest and active options.json has backend=ollama, LLM_INTENT_ENABLE=true, LLM_INTENT_USE_API=false, URL, model, and Python runner path")
	print("  Sandbox apply proof: both cases were also applied to sandbox options.json artifacts; no non-isolated user config mutation, backend call, install, or model pull occurred")
	quit(0)


func _run_api_save_apply_case(ui: Node, backend: Node, helpers: Node, paths: Node) -> void:
	ui._backend_model.text = "openai/gpt-4.1-mini"
	ui._backend_api_key_env.text = "LACAPULT_V3_KEY"
	ui._backend_python_path.text = "python3"
	var save_button = _find_button(ui, "Save options")
	_require(save_button != null, "API Save options button missing")
	save_button.emit_signal("pressed")

	var config = helpers.load_json_file(paths.config.plus_file(backend.BACKEND_CONFIG_FILENAME))
	var patch = helpers.load_json_file(paths.config.plus_file(backend.C_AOL_OPTIONS_PATCH_FILENAME))
	var apply_manifest = helpers.load_json_file(paths.config.plus_file(backend.C_AOL_OPTIONS_APPLY_FILENAME))
	var active_values = _option_values(helpers.load_json_file(paths.config.plus_file("options.json")))
	var patch_values = _patch_option_values(patch)
	_require(config.get("backend", "") == "api", "API save did not persist API backend")
	_require(config.get("model", "") == "openai/gpt-4.1-mini", "API save did not persist selected model")
	_require(config.get("api_key_env", "") == "LACAPULT_V3_KEY", "API save did not persist env-var name")
	_require(JSON.print(config).find("sk-") < 0 and JSON.print(patch).find("sk-") < 0, "API save leaked a secret-shaped value")
	_require(patch.get("apply_status", "") == "applied_to_active_userdir_on_save", "API patch did not carry active apply status")
	_require(apply_manifest.get("ok", false) == true and str(apply_manifest.get("status", "")).begins_with("ok_changed_"), "API active options apply manifest did not report success")
	_require(patch_values.get("LLM_INTENT_ENABLE", "") == "true", "API patch did not enable runner")
	_require(patch_values.get("LLM_INTENT_BACKEND", "") == "api", "API patch did not set backend mode")
	_require(patch_values.get("LLM_INTENT_USE_API", "") == "true", "API patch did not set hidden API runner mode")
	_require(patch_values.get("LLM_INTENT_API_PROVIDER", "") == "openrouter", "API patch lost provider metadata")
	_require(patch_values.get("LLM_INTENT_API_MODEL", "") == "openai/gpt-4.1-mini", "API patch lost selected model")
	_require(patch_values.get("LLM_INTENT_API_KEY_ENV", "") == "LACAPULT_V3_KEY", "API patch lost env-var name")
	_require(patch_values.get("LLM_INTENT_PYTHON", "") == "python3", "API patch lost Python runner path")
	_require(active_values.get("LLM_INTENT_ENABLE", "") == "true", "API active options did not enable runner")
	_require(active_values.get("LLM_INTENT_BACKEND", "") == "api" and active_values.get("LLM_INTENT_USE_API", "") == "true", "API active options did not set runner mode")
	_require(active_values.get("LLM_INTENT_API_PROVIDER", "") == "openrouter", "API active options lost provider")
	_require(active_values.get("LLM_INTENT_API_MODEL", "") == "openai/gpt-4.1-mini" and active_values.get("LLM_INTENT_API_KEY_ENV", "") == "LACAPULT_V3_KEY", "API active options lost selected model/env-var")

	var sandbox_path = paths.config.plus_file("sandbox_v3_api_options.json")
	_require(helpers.save_to_json_file(_stale_options_fixture(), sandbox_path), "could not write API sandbox options")
	var apply_result = backend.write_sandboxed_options_config(sandbox_path, "api", "", "openai/gpt-4.1-mini", "python3", "openrouter", "LACAPULT_V3_KEY")
	_require(str(apply_result).begins_with("ok_changed_"), "API sandbox apply failed: %s" % apply_result)
	var applied = _option_values(helpers.load_json_file(sandbox_path))
	_require(applied.get("LLM_INTENT_ENABLE", "") == "true" and applied.get("LLM_INTENT_BACKEND", "") == "api" and applied.get("LLM_INTENT_USE_API", "") == "true", "API sandbox apply did not set runner enable/backend/mode")
	_require(applied.get("LLM_INTENT_API_MODEL", "") == "openai/gpt-4.1-mini" and applied.get("LLM_INTENT_API_KEY_ENV", "") == "LACAPULT_V3_KEY", "API sandbox apply did not set selected model/env-var")


func _run_ollama_save_apply_case(ui: Node, backend: Node, helpers: Node, paths: Node, settings: Node) -> void:
	settings.store("backend_mode", "ollama")
	settings.store("backend_ollama_endpoint", "http://127.0.0.1:11434")
	settings.store("backend_ollama_model", "mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest")
	settings.store("backend_python_path", "python3")
	ui._refresh_backend_setup_controls()
	var save_button = _find_button(ui, "Save options")
	_require(save_button != null, "Ollama Save options button missing")
	save_button.emit_signal("pressed")

	var config = helpers.load_json_file(paths.config.plus_file(backend.BACKEND_CONFIG_FILENAME))
	var patch = helpers.load_json_file(paths.config.plus_file(backend.C_AOL_OPTIONS_PATCH_FILENAME))
	var apply_manifest = helpers.load_json_file(paths.config.plus_file(backend.C_AOL_OPTIONS_APPLY_FILENAME))
	var active_values = _option_values(helpers.load_json_file(paths.config.plus_file("options.json")))
	var patch_values = _patch_option_values(patch)
	_require(config.get("backend", "") == "ollama", "Ollama save did not persist Ollama backend")
	_require(config.get("model", "") == "nemotron-9b-dumber:latest", "Ollama save did not persist no-think runtime alias")
	_require(settings.read("backend_ollama_model") == "nemotron-9b-dumber:latest", "Ollama setting was not normalized to no-think runtime alias")
	_require(patch.get("apply_status", "") == "applied_to_active_userdir_on_save", "Ollama patch did not carry active apply status")
	_require(apply_manifest.get("ok", false) == true and str(apply_manifest.get("status", "")).begins_with("ok_changed_"), "Ollama active options apply manifest did not report success")
	_require(patch_values.get("LLM_INTENT_ENABLE", "") == "true", "Ollama patch did not enable runner")
	_require(patch_values.get("LLM_INTENT_BACKEND", "") == "ollama", "Ollama patch did not set backend mode")
	_require(patch_values.get("LLM_INTENT_USE_API", "") == "false", "Ollama patch did not clear hidden API runner mode")
	_require(patch_values.get("LLM_INTENT_OLLAMA_URL", "") == "http://127.0.0.1:11434", "Ollama patch lost endpoint")
	_require(patch_values.get("LLM_INTENT_OLLAMA_MODEL", "") == "nemotron-9b-dumber:latest", "Ollama patch lost selected no-think model")
	_require(patch_values.get("LLM_INTENT_PYTHON", "") == "python3", "Ollama patch lost Python runner path")
	_require(active_values.get("LLM_INTENT_ENABLE", "") == "true", "Ollama active options did not enable runner")
	_require(active_values.get("LLM_INTENT_BACKEND", "") == "ollama" and active_values.get("LLM_INTENT_USE_API", "") == "false", "Ollama active options did not set local runner mode")
	_require(active_values.get("LLM_INTENT_OLLAMA_URL", "") == "http://127.0.0.1:11434" and active_values.get("LLM_INTENT_OLLAMA_MODEL", "") == "nemotron-9b-dumber:latest", "Ollama active options lost selected URL/model")

	var sandbox_path = paths.config.plus_file("sandbox_v3_ollama_options.json")
	_require(helpers.save_to_json_file(_stale_options_fixture(), sandbox_path), "could not write Ollama sandbox options")
	var apply_result = backend.write_sandboxed_options_config(sandbox_path, "ollama", "http://127.0.0.1:11434", "mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest", "python3")
	_require(str(apply_result).begins_with("ok_changed_"), "Ollama sandbox apply failed: %s" % apply_result)
	var applied = _option_values(helpers.load_json_file(sandbox_path))
	_require(applied.get("LLM_INTENT_ENABLE", "") == "true" and applied.get("LLM_INTENT_BACKEND", "") == "ollama" and applied.get("LLM_INTENT_USE_API", "") == "false", "Ollama sandbox apply did not set runner enable/backend/mode")
	_require(applied.get("LLM_INTENT_OLLAMA_MODEL", "") == "nemotron-9b-dumber:latest" and applied.get("LLM_INTENT_OLLAMA_URL", "") == "http://127.0.0.1:11434", "Ollama sandbox apply did not set selected model/url")


func _stale_options_fixture() -> Array:
	return [
		{"name": "LLM_INTENT_ENABLE", "value": "false"},
		{"name": "LLM_INTENT_BACKEND", "value": "openvino"},
		{"name": "LLM_INTENT_USE_API", "value": "false"},
		{"name": "LLM_INTENT_OLLAMA_URL", "value": "http://old.example.invalid:11434"},
		{"name": "LLM_INTENT_OLLAMA_MODEL", "value": "qwen2.5:3b"},
		{"name": "LLM_INTENT_API_PROVIDER", "value": "openai"},
		{"name": "LLM_INTENT_API_KEY_ENV", "value": "OLD_KEY"},
		{"name": "LLM_INTENT_API_MODEL", "value": "old-api-model"},
		{"name": "LLM_INTENT_PYTHON", "value": "old-python"}
	]


func _patch_option_values(patch: Dictionary) -> Dictionary:
	return _option_values(patch.get("options", []))


func _option_values(options) -> Dictionary:
	var values = {}
	if typeof(options) != TYPE_ARRAY:
		return values
	for option in options:
		if typeof(option) == TYPE_DICTIONARY:
			values[str(option.get("name", ""))] = str(option.get("value", ""))
	return values


func _find_button(node: Node, text: String) -> Button:
	if node is Button and node.text == text:
		return node as Button
	for child in node.get_children():
		var found: Button = _find_button(child, text)
		if found != null:
			return found
	return null


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	printerr("v3 Save/apply runner smoke failed: %s" % message)
	quit(1)
