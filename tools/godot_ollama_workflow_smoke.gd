extends SceneTree

# Headless UI smoke for Package 4: Ollama installer/model readiness workflow.
# Proves the visible Ollama setup has one model-choice control, compact readiness
# lights for Mistral/Nemotron plus Python/options state, Check/Save/Install actions,
# and confirmation-gated setup intents. It does not install Ollama, create a real
# venv, pull models, call APIs, or mutate real user Application Support data.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	var paths = root.get_node("/root/Paths")
	var helpers = root.get_node("/root/Helpers")
	var backend_config = root.get_node("/root/BackendConfig")
	settings.store("game", "caol")
	settings.store("active_install_caol", "Package 4 Sandbox")
	var install_dir = paths.own_dir.plus_file("caol").plus_file("game0")
	var d = Directory.new()
	var dir_err = d.make_dir_recursive(install_dir)
	_require(dir_err == OK or dir_err == ERR_ALREADY_EXISTS, "could not create sandbox active install dir")
	_require(helpers.save_to_json_file({"name": "Package 4 Sandbox"}, install_dir.plus_file("catapult_install_info.json")), "could not create sandbox install info")

	settings.store("backend_mode", "ollama")
	settings.store("backend_ollama_endpoint", backend_config.DEFAULT_OLLAMA_URL)
	settings.store("backend_ollama_model", "mistral-v0.3")
	settings.store("backend_python_path", "python3")
	settings.store("backend_external_setup_proof_only", true)
	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "models:mistral-v0.3")

	var missing = backend_config.get_ollama_readiness(backend_config.DEFAULT_OLLAMA_URL, "python3")
	_require(missing.get("model_lights", {}).get("mistral-v0.3", "") == "🟢", "fixture model-present state did not mark Mistral ready")
	_require(missing.get("model_lights", {}).get("nemotron-9b", "") == "🟡", "fixture model-missing state did not mark Nemotron pull-needed")
	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "server_unreachable")
	var unreachable = backend_config.get_ollama_readiness(backend_config.DEFAULT_OLLAMA_URL, "python3")
	_require(unreachable.get("command_light", "") == "🟢" and unreachable.get("server_light", "") == "🟡", "fixture server-unreachable state did not mark command/server lights correctly")
	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "command_missing")
	var no_command = backend_config.get_ollama_readiness(backend_config.DEFAULT_OLLAMA_URL, "python3")
	_require(no_command.get("command_light", "") == "🔴", "fixture command-missing state did not mark command red")
	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "models:mistral-v0.3")

	var ui_script = load("res://scripts/BackendSetupUI.gd")
	var ui = VBoxContainer.new()
	ui.set_script(ui_script)
	root.add_child(ui)
	yield(self, "idle_frame")

	var config_path = paths.config.plus_file(backend_config.BACKEND_CONFIG_FILENAME)
	var patch_path = paths.config.plus_file(backend_config.C_AOL_OPTIONS_PATCH_FILENAME)
	var ollama_intent_path = paths.config.plus_file(backend_config.OLLAMA_SETUP_INTENT_FILENAME)
	var venv_intent_path = paths.config.plus_file(backend_config.PYTHON_VENV_SETUP_INTENT_FILENAME)
	var all_text = _collect_visible_text(ui)
	_require(all_text.find("Ollama model choice") >= 0, "Ollama model choice control did not render")
	_require(_visible_text_count(all_text, "Ollama model choice") == 1, "Ollama model choice rendered more than once")
	_require(all_text.find("Ollama model tag") < 0, "duplicate freeform Ollama model field is still visible")
	_require(_option_has_item(ui._ollama_model_choice, "mistral-v0.3") and _option_has_item(ui._ollama_model_choice, "nemotron-9b"), "supported Ollama model choices did not render")
	_require(all_text.find("Ollama cmd") >= 0 and all_text.find("Mistral") >= 0 and all_text.find("Nemotron") >= 0 and all_text.find("Python/venv") >= 0, "Ollama status lights did not render")
	_require(all_text.find("Save options") >= 0 and all_text.find("Check") >= 0 and all_text.find("Install Ollama / model") >= 0 and all_text.find("Create venv only") >= 0, "Ollama action row did not render Save/Check/Install/venv actions")
	_require(all_text.find("API key") < 0 and all_text.find("Provider") < 0, "Ollama mode leaked API-only controls")
	_require(all_text.find("Hardware recommendation") >= 0 and all_text.find("Mistral") >= 0 and all_text.find("Nemotron") >= 0, "Ollama hardware recommendation did not render")

	var check_button = _find_button(ui, "Check")
	_require(check_button != null, "Check button lookup failed")
	check_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(not File.new().file_exists(config_path), "Check wrote backend config; it should be detection-only")
	_require(ui._ollama_status_lights.text.find("Mistral 🟢") >= 0 and ui._ollama_status_lights.text.find("Nemotron 🟡") >= 0, "fixture model readiness lights did not render expected present/missing state")

	var save_button = _find_button(ui, "Save options")
	_require(save_button != null, "Save options button lookup failed")
	save_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(File.new().file_exists(config_path), "Save options did not write backend config")
	_require(File.new().file_exists(patch_path), "Save options did not write options patch")
	var ollama_config = helpers.load_json_file(config_path)
	_require(ollama_config.get("backend", "") == "ollama", "backend config did not persist Ollama mode")
	_require(ollama_config.get("model", "") == "mistral-v0.3", "backend config did not persist selected Ollama model")
	_require(JSON.print(ollama_config).find("LLM_INTENT_PYTHON") >= 0, "options patch/config did not explain shared Python runner path")

	var install_button = _find_button(ui, "Install Ollama / model")
	_require(install_button != null, "Install Ollama / model button lookup failed")
	install_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._confirm_dialog.dialog_text.find("ollama pull mistral-v0.3") >= 0, "Ollama confirmation did not preview selected model pull")
	_require(ui._confirm_dialog.dialog_text.find("Proof mode") >= 0 and ui._confirm_dialog.dialog_text.find("instead of running installers") >= 0, "Ollama confirmation lost proof-mode no-pull boundary")
	ui._on_ExternalBackendAction_confirmed()
	yield(self, "idle_frame")
	_require(File.new().file_exists(ollama_intent_path), "confirmed Ollama setup did not record setup intent")
	var ollama_intent = helpers.load_json_file(ollama_intent_path)
	_require(ollama_intent.get("action", "") == "install_ollama_and_pull_model", "Ollama setup intent action mismatch")
	_require(ollama_intent.get("model", "") == "mistral-v0.3", "Ollama setup intent model mismatch")
	_require(ollama_intent.get("performed_external_install", true) == false, "Ollama setup proof claimed an external install ran")

	var venv_button = _find_button(ui, "Create venv only")
	_require(venv_button != null, "Create venv only button lookup failed")
	var executable_venv_plan = backend_config.build_python_venv_setup_plan("python3")
	_require(executable_venv_plan.get("target_path", "").find("caol-llm-python-venv") >= 0, "Python venv plan treated executable name as the venv target path")
	ui._backend_python_path.text = ""
	venv_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._confirm_dialog.dialog_text.find("python3 -m venv") >= 0 and ui._confirm_dialog.dialog_text.find("runner.py") >= 0, "Python venv confirmation did not explain runner.py setup")
	ui._on_ExternalBackendAction_confirmed()
	yield(self, "idle_frame")
	_require(File.new().file_exists(venv_intent_path), "confirmed Python venv setup did not record setup intent")
	var venv_intent = helpers.load_json_file(venv_intent_path)
	_require(venv_intent.get("action", "") == "create_python_venv", "Python venv setup intent action mismatch")
	_require(venv_intent.get("performed_external_install", true) == false, "Python venv proof claimed a venv was created")
	_require(ui._backend_python_path.text.find("caol-llm-python-venv") >= 0, "Python venv proof did not fill the intended path field")

	print("Ollama workflow UI smoke passed")
	print("  UI proof: one Ollama model-choice control, Mistral/Nemotron/Python/options lights, hardware guidance, Check, Save, Install Ollama / model, and Create venv only rendered")
	print("  Fixture proof: command-missing, server-unreachable, model-present, and model-missing states are distinguishable without real pulls")
	print("  Check proof: readiness-only; no backend config write")
	print("  Save proof: Ollama endpoint/model/Python metadata round-tripped into sandbox launcher config/options patch")
	print("  Install proof: confirmation-gated Ollama/model and Python venv intents recorded in proof mode; no installer, venv creation, model pull, API call, or real user config mutation")
	quit(0)


func _collect_visible_text(node: Node) -> String:
	var parts := []
	_collect_visible_text_into(node, parts)
	return PoolStringArray(parts).join("\n")


func _collect_visible_text_into(node: Node, parts: Array) -> void:
	if node is Control and not node.visible:
		return
	if node is Label:
		parts.append(node.text)
	elif node is Button:
		parts.append(node.text)
	elif node is LineEdit:
		parts.append(node.placeholder_text)
	elif node is OptionButton:
		for i in range(node.get_item_count()):
			parts.append(node.get_item_text(i))
	for child in node.get_children():
		_collect_visible_text_into(child, parts)


func _option_has_item(option: OptionButton, text: String) -> bool:
	for i in range(option.get_item_count()):
		if option.get_item_text(i) == text:
			return true
	return false


func _find_button(node: Node, text: String):
	if node is Button and node.text == text:
		return node
	for child in node.get_children():
		var found = _find_button(child, text)
		if found != null:
			return found
	return null


func _visible_text_count(text: String, needle: String) -> int:
	var count = 0
	var offset = 0
	while true:
		var idx = text.find(needle, offset)
		if idx < 0:
			break
		count += 1
		offset = idx + needle.length()
	return count


func _require(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	printerr("Ollama workflow smoke failed: " + message)
	quit(1)
