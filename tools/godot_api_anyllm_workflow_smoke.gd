extends SceneTree

# Headless UI smoke for Package 3: API / AnyLLM setup workflow.
# Proves provider/base URL/model/env-var/session-key controls render and round-trip
# safely, Check is non-mutating/no-call, and Install AnyLLM packages records only a
# confirmation-gated setup intent. It does not run pip, call APIs, install packages,
# read a real secret, or mutate real Application Support data.

const FAKE_SECRET = "sk-package3-secret-do-not-save"

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	var paths = root.get_node("/root/Paths")
	var helpers = root.get_node("/root/Helpers")
	var backend_config = root.get_node("/root/BackendConfig")
	settings.store("game", "caol")
	settings.store("active_install_caol", "Package 3 Sandbox")
	var install_dir = paths.own_dir.plus_file("caol").plus_file("game0")
	var d = Directory.new()
	var dir_err = d.make_dir_recursive(install_dir)
	_require(dir_err == OK or dir_err == ERR_ALREADY_EXISTS, "could not create sandbox active install dir")
	_require(helpers.save_to_json_file({"name": "Package 3 Sandbox"}, install_dir.plus_file("catapult_install_info.json")), "could not create sandbox install info")

	settings.store("backend_mode", "api")
	settings.store("backend_api_endpoint", "")
	settings.store("backend_api_provider", "openrouter")
	settings.store("backend_api_model", "")
	settings.store("backend_api_key_env", "LACAPULT_PACKAGE3_KEY")
	settings.store("backend_python_path", "python3")
	settings.store("backend_api_setup_proof_only", true)

	var ui_script = load("res://scripts/BackendSetupUI.gd")
	var ui = VBoxContainer.new()
	ui.set_script(ui_script)
	root.add_child(ui)
	yield(self, "idle_frame")

	var config_path = paths.config.plus_file(backend_config.BACKEND_CONFIG_FILENAME)
	var patch_path = paths.config.plus_file(backend_config.C_AOL_OPTIONS_PATCH_FILENAME)
	var intent_path = paths.config.plus_file(backend_config.API_SETUP_INTENT_FILENAME)
	var all_text = _collect_visible_text(ui)
	_require(all_text.find("API base URL") >= 0, "API base URL field did not render")
	_require(all_text.find("Provider") >= 0, "Provider field did not render")
	_require(all_text.find("API model") >= 0, "API model field did not render")
	_require(all_text.find("API key env var") >= 0, "API key env-var field did not render")
	_require(all_text.find("API key (session only)") >= 0, "session-only API key control did not render")
	_require(all_text.find("Use for this session") >= 0, "session API key action did not render")
	_require(_option_has_item(ui._backend_provider_button, "OpenAI") and _option_has_item(ui._backend_provider_button, "OpenRouter") and _option_has_item(ui._backend_provider_button, "AnyLLM custom provider"), "provider choices did not render")
	_require(all_text.find("server endpoint") >= 0 and all_text.find("proxy/router") >= 0, "API base URL help did not render")
	_require(all_text.find("Python") >= 0 and all_text.find("AnyLLM") >= 0 and all_text.find("API-key env var") >= 0 and all_text.find("API setup") >= 0, "API status lights did not render")
	_require(all_text.find("Install AnyLLM packages") >= 0 and all_text.find("Create venv only") >= 0, "API AnyLLM package/venv actions did not render")
	_require(all_text.find("hardware") < 0 and all_text.find("Ollama URL") < 0, "API mode leaked Ollama/hardware copy")

	var check_button = _find_button(ui, "Check")
	_require(check_button != null, "Check button lookup failed")
	check_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(not File.new().file_exists(config_path), "Check wrote backend config; it should be detection-only")
	_require(ui._backend_status.text.find("no API call") >= 0, "Check lost no-API-call boundary")

	ui._backend_endpoint.text = "https://openrouter.ai/api/v1"
	ui._backend_model.text = "openai/gpt-4.1-mini"
	ui._backend_api_key_env.text = "LACAPULT_PACKAGE3_KEY"
	ui._backend_python_path.text = "python3"
	ui._backend_api_key_secret.text = FAKE_SECRET
	var session_button = _find_button(ui, "Use for this session")
	_require(session_button != null, "session key button lookup failed")
	session_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._backend_api_key_secret.text == "", "session key field was not cleared after use")
	_require(OS.get_environment("LACAPULT_PACKAGE3_KEY") == FAKE_SECRET, "session key was not set in process environment")
	_require(ui._api_status_lights.text.find("API-key env var 🟢") >= 0, "API-key env-var light did not show session-set state")

	var save_button = _find_button(ui, "Save options")
	_require(save_button != null, "Save options button lookup failed")
	save_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(File.new().file_exists(config_path), "Save options did not write backend config")
	_require(File.new().file_exists(patch_path), "Save options did not write options patch")
	var api_config = helpers.load_json_file(config_path)
	_require(api_config.get("backend", "") == "api", "backend config did not persist API mode")
	_require(api_config.get("api_provider", "") == "openrouter", "backend config did not persist provider")
	_require(api_config.get("endpoint", "") == "https://openrouter.ai/api/v1", "backend config did not persist base URL")
	_require(api_config.get("model", "") == "openai/gpt-4.1-mini", "backend config did not persist model")
	_require(api_config.get("api_key_env", "") == "LACAPULT_PACKAGE3_KEY", "backend config did not persist env-var name")
	var config_text = JSON.print(api_config)
	_require(config_text.find(FAKE_SECRET) < 0 and not api_config.has("api_key") and not api_config.has("secret"), "backend config leaked API secret")
	var patch = helpers.load_json_file(patch_path)
	var patch_text = JSON.print(patch)
	_require(patch_text.find("LLM_INTENT_API_PROVIDER") >= 0 and patch_text.find("openrouter") >= 0, "options patch did not carry provider metadata")
	_require(patch_text.find(FAKE_SECRET) < 0, "options patch leaked API secret")

	var install_button = _find_button(ui, "Install AnyLLM packages")
	_require(install_button != null, "Install AnyLLM packages button lookup failed")
	install_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._confirm_dialog.dialog_text.find("python3 -m pip install --upgrade") >= 0, "confirmation did not show planned AnyLLM setup command")
	_require(ui._confirm_dialog.dialog_text.find("may install or upgrade Python packages") >= 0, "confirmation did not explain real install boundary")
	_require(ui._confirm_dialog.dialog_text.find("\n") >= 0 and ui._confirm_dialog.dialog_autowrap == true, "confirmation dialog did not use wrapped/newline layout")
	_require(ui._confirm_dialog.dialog_text.find("Proof mode") >= 0 and ui._confirm_dialog.dialog_text.find("instead of running pip") >= 0, "confirmation lost proof-mode no-pip boundary")
	_require(ui._confirm_dialog.dialog_text.find(FAKE_SECRET) < 0, "confirmation leaked API secret")
	ui._on_ExternalBackendAction_confirmed()
	yield(self, "idle_frame")
	_require(File.new().file_exists(intent_path), "confirmed API setup did not record setup intent")
	var intent = helpers.load_json_file(intent_path)
	var intent_text = JSON.print(intent)
	_require(intent.get("action", "") == "install_api_backend", "setup intent action mismatch")
	_require(intent.get("provider", "") == "openrouter", "setup intent provider mismatch")
	_require(intent.get("performed_external_install", true) == false, "setup intent claimed an external install ran")
	_require(intent_text.find(FAKE_SECRET) < 0, "setup intent leaked API secret")

	print("API / AnyLLM workflow UI smoke passed")
	print("  UI proof: API base URL/provider/model/env-var/session-key controls, status lights, Create venv only, and Install AnyLLM packages rendered")
	print("  Check proof: readiness-only; no backend config write and no API call")
	print("  Save proof: provider/base URL/model/env-var name round-tripped without storing secret")
	print("  Install proof: confirmation-gated AnyLLM setup command staged in proof mode; no pip/API call/secret read")
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


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	printerr("API / AnyLLM workflow UI smoke failed: %s" % message)
	quit(1)
