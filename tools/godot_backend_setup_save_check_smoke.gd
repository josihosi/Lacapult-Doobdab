extends SceneTree

# Headless UI smoke for Package 2: setup Save/Check/Install action pattern.
# It instantiates the actual BackendSetupUI under an isolated HOME and proves:
# - Save options / Check / Install setup controls render;
# - Check refreshes status without writing backend config;
# - Save writes the current UI fields to launcher-side config/options metadata;
# - Install setup saves current options before opening the confirm-gated setup step.
# It does not install packages, pull models, call APIs, read secrets, or mutate real
# Application Support data.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	var paths = root.get_node("/root/Paths")
	var helpers = root.get_node("/root/Helpers")
	var backend_config = root.get_node("/root/BackendConfig")
	settings.store("game", "caol")
	settings.store("active_install_caol", "Package 2 Sandbox")
	var install_dir = paths.own_dir.plus_file("caol").plus_file("game0")
	var d = Directory.new()
	var dir_err = d.make_dir_recursive(install_dir)
	_require(dir_err == OK or dir_err == ERR_ALREADY_EXISTS, "could not create sandbox active install dir")
	_require(helpers.save_to_json_file({"name": "Package 2 Sandbox"}, install_dir.plus_file("catapult_install_info.json")), "could not create sandbox install info")

	settings.store("backend_mode", "api")
	settings.store("backend_api_endpoint", "")
	settings.store("backend_api_model", "")
	settings.store("backend_api_key_env", "CATA_API_KEY")
	settings.store("backend_api_provider", "openai")
	settings.store("backend_python_path", "")
	settings.store("backend_ollama_endpoint", backend_config.DEFAULT_OLLAMA_URL)
	settings.store("backend_ollama_model", "")

	var ui_script = load("res://scripts/BackendSetupUI.gd")
	var ui = VBoxContainer.new()
	ui.set_script(ui_script)
	root.add_child(ui)
	yield(self, "idle_frame")

	var config_path = paths.config.plus_file(backend_config.BACKEND_CONFIG_FILENAME)
	var patch_path = paths.config.plus_file(backend_config.C_AOL_OPTIONS_PATCH_FILENAME)
	var all_text = _collect_visible_text(ui)
	_require(all_text.find("Save options") >= 0, "Save options button did not render")
	_require(all_text.find("Check") >= 0, "Check button did not render")
	_require(all_text.find("Install setup") >= 0, "Install setup button did not render")
	_require(all_text.find("Confirm guided install step") < 0, "old install button copy still rendered")
	_require(all_text.find("Backend setup save result") < 0, "old long save status copy rendered")
	_require(all_text.find("🟡") >= 0 or all_text.find("🔴") >= 0 or all_text.find("🟢") >= 0, "status light did not render")
	_require(not File.new().file_exists(config_path), "backend config existed before Save/Install")

	var check_button = _find_button(ui, "Check")
	_require(check_button != null, "Check button lookup failed")
	check_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(not File.new().file_exists(config_path), "Check wrote backend config; it should be detection-only")
	_require(ui._backend_status.text.find("Checked") >= 0, "Check did not refresh visible status")
	_require(ui._backend_status.text.find("no API call") >= 0, "Check status lost API no-call boundary")

	ui._backend_endpoint.text = "https://api.example.invalid/v1"
	ui._backend_model.text = "example-package2-api-model"
	ui._backend_api_key_env.text = "LACAPULT_PACKAGE2_KEY"
	ui._backend_python_path.text = "python3"
	var save_button = _find_button(ui, "Save options")
	_require(save_button != null, "Save options button lookup failed")
	save_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(File.new().file_exists(config_path), "Save options did not write backend config")
	_require(File.new().file_exists(patch_path), "Save options did not write C-AOL options patch")
	var api_config = helpers.load_json_file(config_path)
	_require(api_config.get("backend", "") == "api", "Save options did not persist API backend")
	_require(api_config.get("endpoint", "") == "https://api.example.invalid/v1", "Save options did not persist API endpoint from current UI field")
	_require(api_config.get("model", "") == "example-package2-api-model", "Save options did not persist API model from current UI field")
	_require(api_config.get("api_key_env", "") == "LACAPULT_PACKAGE2_KEY", "Save options did not persist env-var name only")
	_require(not api_config.has("api_key") and not api_config.has("secret"), "Save options stored a secret-shaped API key field")

	settings.store("backend_mode", "ollama")
	ui._refresh_backend_setup_controls()
	yield(self, "idle_frame")
	ui._backend_endpoint.text = "http://127.0.0.1:11434"
	ui._backend_model.text = "mistral-v0.3"
	var install_button = _find_button(ui, "Install setup")
	_require(install_button != null, "Install setup button lookup failed")
	install_button.emit_signal("pressed")
	yield(self, "idle_frame")
	var ollama_config = helpers.load_json_file(config_path)
	_require(ollama_config.get("backend", "") == "ollama", "Install setup did not save Ollama backend before confirm")
	_require(ollama_config.get("endpoint", "") == "http://127.0.0.1:11434", "Install setup did not save current Ollama endpoint")
	_require(ollama_config.get("model", "") == "mistral-v0.3", "Install setup did not save current Ollama model")
	_require(ui._backend_status.text.find("Saved before install") >= 0, "Install setup did not report save-before-install ordering")
	_require(ui._confirm_dialog.dialog_text.find("does not download models") >= 0, "Install setup lost confirmation/no-download boundary")

	print("backend setup Save/Check UI smoke passed")
	print("  rendered actions: Save options / Check / Install setup")
	print("  Check proof: detection-only status refresh; no backend config write")
	print("  Save proof: API fields persisted to sandboxed launcher config/options patch")
	print("  Install proof: Ollama fields saved before confirm-gated setup intent; no pull/install/API call")
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


func _find_button(node: Node, text: String):
	if node is Button and node.text == text:
		return node
	for child in node.get_children():
		var found = _find_button(child, text)
		if found != null:
			return found
	return null


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	printerr("backend setup Save/Check UI smoke failed: %s" % message)
	quit(1)
