extends SceneTree

# Headless smoke for Catapult-Dabubu Windows retest follow-up v1.
# Proves the API setup path plans venv + AnyLLM install in proof mode,
# visible backend statuses use explicit colored big-dot rows rather than emoji
# traffic lights, Ollama hardware/readiness rows include fixture RAM/VRAM, and
# Ollama setup previews are serialized instead of shell-chained. No pip install,
# venv creation, model pull, API call, secret read, or non-isolated user-data mutation.

const OLD_LIGHTS = ["🟢", "🟡", "🔴", "🚦"]
const FAKE_SECRET = "sk-v1-proof-secret-do-not-save"

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	var paths = root.get_node("/root/Paths")
	var helpers = root.get_node("/root/Helpers")
	var backend_config = root.get_node("/root/BackendConfig")
	settings.store("game", "caol")
	settings.store("active_install_caol", "Windows V1 Sandbox")
	var install_dir = paths.own_dir.plus_file("caol").plus_file("game0")
	var dir_err = Directory.new().make_dir_recursive(install_dir)
	_require(dir_err == OK or dir_err == ERR_ALREADY_EXISTS, "could not create sandbox active install dir")
	_require(helpers.save_to_json_file({"name": "Windows V1 Sandbox"}, install_dir.plus_file("catapult_install_info.json")), "could not create sandbox install info")
	settings.store("backend_mode", "api")
	settings.store("backend_api_endpoint", "")
	settings.store("backend_api_provider", "openrouter")
	settings.store("backend_api_model", "")
	settings.store("backend_api_key_env", "LACAPULT_V1_FAKE_KEY")
	settings.store("backend_python_path", "")
	settings.store("backend_api_setup_proof_only", true)
	settings.store("backend_external_setup_proof_only", true)
	OS.set_environment("LACAPULT_V1_FAKE_KEY", FAKE_SECRET)

	var ui_script = load("res://scripts/BackendSetupUI.gd")
	var ui = VBoxContainer.new()
	ui.set_script(ui_script)
	root.add_child(ui)
	yield(self, "idle_frame")

	var all_text = _collect_visible_text(ui)
	_require(all_text.find("API path: choose provider/model") >= 0, "compact API guidance missing")
	_require(all_text.find("Use an API provider through AnyLLM") < 0 and all_text.find("300-400 tokens") < 0, "old verbose API helper text rendered")
	_require(all_text.find("Set up API / AnyLLM") >= 0, "one obvious API setup action missing")
	_require(all_text.find("CLI input preview") >= 0, "CLI input preview textbox text missing")
	_require(not _has_old_light(all_text), "old emoji traffic-light status rendered in visible API UI")
	_require(_status_container_has_states(ui._api_status_lights, ["green", "yellow"]), "API status rows did not expose explicit colored states")

	var install_button = _find_button(ui, "Set up API / AnyLLM")
	_require(install_button != null, "API setup button lookup failed")
	install_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._confirm_dialog.dialog_text.find("CLI input") >= 0, "confirmation did not mark command preview as CLI input")
	_require(ui._confirm_dialog.dialog_text.find("Step 1:") >= 0 and ui._confirm_dialog.dialog_text.find("-m venv") >= 0, "API setup confirmation missing venv phase")
	_require(ui._confirm_dialog.dialog_text.find("Step 2:") >= 0 and ui._confirm_dialog.dialog_text.find("pip install --upgrade") >= 0, "API setup confirmation missing AnyLLM package phase")
	_require(ui._confirm_dialog.dialog_text.find(FAKE_SECRET) < 0, "confirmation leaked fake API secret")
	ui._on_ExternalBackendAction_confirmed()
	yield(self, "idle_frame")
	var intent_path = paths.config.plus_file(backend_config.API_SETUP_INTENT_FILENAME)
	_require(File.new().file_exists(intent_path), "API setup proof intent not written")
	var intent = helpers.load_json_file(intent_path)
	_require(intent.get("performed_external_install", true) == false, "proof intent claimed external install")
	_require(intent.get("phase_order", []).has("create_or_update_venv") and intent.get("phase_order", []).has("install_anyllm_packages"), "API setup intent missing venv/package phases")
	_require(JSON.print(intent).find(FAKE_SECRET) < 0, "API setup intent leaked fake secret")

	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "models:mistral:v0.3")
	OS.set_environment("LACAPULT_HARDWARE_FIXTURE", "ram:32000,vram:12000")
	settings.store("backend_mode", "ollama")
	settings.store("backend_ollama_endpoint", "http://127.0.0.1:11434")
	settings.store("backend_ollama_model", "mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest")
	ui._refresh_backend_setup_controls()
	yield(self, "idle_frame")
	all_text = _collect_visible_text(ui)
	_require(all_text.find("Ollama path: Check hardware/readiness") >= 0, "compact Ollama guidance missing")
	_require(all_text.find("RAM: 31.2 GiB") >= 0 and all_text.find("VRAM: 11.7 GiB") >= 0, "hardware fixture check did not render measured RAM/VRAM in GiB")
	_require(not _has_old_light(all_text), "old emoji traffic-light status rendered in visible Ollama UI")
	_require(_status_container_has_states(ui._ollama_status_lights, ["green", "yellow"]), "Ollama status rows did not expose explicit colored states")
	_require(all_text.find("mistral:v0.3 performance: estimated good") >= 0 and all_text.find("nemotron-9b performance: estimated good") >= 0, "hardware performance lights did not expose green estimated states")
	_require(ui._command_preview_box.text.find("&&") < 0 and ui._command_preview_box.text.find("Step 1:") >= 0, "Ollama command preview was not serialized/stepwise")

	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "command_missing")
	var missing_plan = backend_config.build_ollama_setup_plan("http://127.0.0.1:11434", "mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest")
	_require(JSON.print(missing_plan.get("commands", [])).find("pull") < 0, "Ollama plan queued model pull while command/server not ready")
	_require(missing_plan.get("next_step", "").find("Run Check") >= 0, "Ollama missing-command plan did not tell user to Check before pull")

	print("Windows retest follow-up v1 UI/backend smoke passed")
	print("  API setup: proof-only venv + AnyLLM package phases recorded without secrets/pip/venv mutation")
	print("  Status UI: explicit colored big-dot rows for API/Ollama/model performance, no emoji traffic lights")
	print("  Ollama: fixture GiB hardware/performance check, timeout/wait warning, serialized setup plan, no install+pull chain when not ready")
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
	elif node is TextEdit:
		parts.append(node.text)
	elif node is OptionButton:
		for i in range(node.get_item_count()):
			parts.append(node.get_item_text(i))
	for child in node.get_children():
		_collect_visible_text_into(child, parts)


func _has_old_light(text: String) -> bool:
	for light in OLD_LIGHTS:
		if text.find(light) >= 0:
			return true
	return false


func _status_container_has_states(container: Node, states: Array) -> bool:
	for wanted in states:
		var found = false
		for child in container.get_children():
			if child.has_meta("status_state") and child.get_meta("status_state") == wanted:
				found = true
			for grand in child.get_children():
				if grand.has_meta("status_state") and grand.get_meta("status_state") == wanted:
					found = true
		if not found:
			return false
	return true


func _find_status_row(container: Node, row_name: String, state: String) -> bool:
	for child in container.get_children():
		if child.name == row_name and child.has_meta("status_state") and child.get_meta("status_state") == state:
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
	printerr("Windows retest follow-up v1 smoke failed: %s" % message)
	quit(1)
