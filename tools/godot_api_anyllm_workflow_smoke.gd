extends SceneTree

# Headless UI smoke for Package 3: API / AnyLLM setup workflow.
# Proves provider/model/env-var/session-key controls render, normal base URL stays hidden, and settings round-trip
# safely, Check is non-mutating/no-call, Save applies active C-AOL options, and Set up API / AnyLLM records a
# confirmation-gated venv + package setup intent. It does not run pip, call APIs, install packages,
# read a real secret, or mutate non-isolated Application Support data.

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
	_write_runner_fixture(install_dir)

	settings.store("backend_mode", "api")
	settings.store("backend_api_endpoint", "")
	settings.store("backend_api_provider", "openrouter")
	settings.store("backend_api_model", "")
	settings.store("backend_api_key_env", "LACAPULT_PACKAGE3_KEY")
	settings.store("backend_python_path", "python3")
	settings.store("backend_api_setup_proof_only", true)
	settings.store("backend_runner_test_proof_only", true)

	var config_path = paths.config.plus_file(backend_config.BACKEND_CONFIG_FILENAME)
	var patch_path = paths.config.plus_file(backend_config.C_AOL_OPTIONS_PATCH_FILENAME)
	var apply_path = paths.config.plus_file(backend_config.C_AOL_OPTIONS_APPLY_FILENAME)
	var options_path = paths.config.plus_file("options.json")
	var intent_path = paths.config.plus_file(backend_config.API_SETUP_INTENT_FILENAME)
	var runner_intent_path = paths.config.plus_file(backend_config.RUNNER_TEST_INTENT_FILENAME)
	_remove_if_exists(config_path)
	_remove_if_exists(patch_path)
	_remove_if_exists(apply_path)
	_remove_if_exists(options_path)
	_remove_if_exists(intent_path)
	_remove_if_exists(runner_intent_path)

	var ui_script = load("res://scripts/BackendSetupUI.gd")
	var ui = VBoxContainer.new()
	ui.set_script(ui_script)
	root.add_child(ui)
	yield(self, "idle_frame")

	var all_text = _collect_visible_text(ui)
	_require(all_text.find("API base URL") < 0 and all_text.find("Advanced/custom base URL") < 0, "normal API mode should hide base URL controls")
	_require(all_text.find("Provider") >= 0, "Provider field did not render")
	_require(all_text.find("API model") >= 0, "API model field did not render")
	_require(all_text.find("API key env var") >= 0, "API key env-var field did not render")
	_require(all_text.find("API key (session only)") >= 0, "session-only API key control did not render")
	_require(all_text.find("Use for this session") >= 0, "session API key action did not render")
	_require(_option_has_item(ui._backend_provider_button, "OpenAI") and _option_has_item(ui._backend_provider_button, "OpenRouter") and _option_has_item(ui._backend_provider_button, "AnyLLM custom provider"), "provider choices did not render")
	_require(_status_container_has_states(ui._api_status_lights, ["green", "yellow"]), "API status rows did not expose explicit colored states")
	_require(all_text.find("Set up API / AnyLLM") >= 0 and all_text.find("Create venv only") >= 0 and all_text.find("Test API runner") >= 0, "API setup/venv/runner-test actions did not render")
	_require(all_text.find("hardware") < 0 and all_text.find("Ollama URL") < 0, "API mode leaked Ollama/hardware copy")

	var check_button = _find_button(ui, "Check")
	_require(check_button != null, "Check button lookup failed")
	check_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(not File.new().file_exists(config_path), "Check wrote backend config; it should be detection-only")
	_require(ui._backend_status.text.find("no API call") >= 0, "Check lost no-API-call boundary")

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
	_require(_find_status_row(ui._api_status_lights, "API-keyenvvarStatusRow", "green"), "API-key env-var row did not show session-set state")

	var save_button = _find_button(ui, "Save options")
	_require(save_button != null, "Save options button lookup failed")
	save_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(File.new().file_exists(config_path), "Save options did not write backend config")
	_require(File.new().file_exists(patch_path), "Save options did not write options patch")
	_require(File.new().file_exists(apply_path), "Save options did not write options apply manifest")
	_require(File.new().file_exists(options_path), "Save options did not write active C-AOL options.json")
	var api_config = helpers.load_json_file(config_path)
	_require(api_config.get("backend", "") == "api", "backend config did not persist API mode")
	_require(api_config.get("api_provider", "") == "openrouter", "backend config did not persist provider")
	_require(api_config.get("endpoint", "") == "https://openrouter.ai/api/v1", "backend config did not derive provider default base URL")
	_require(api_config.get("model", "") == "openai/gpt-4.1-mini", "backend config did not persist model")
	_require(api_config.get("api_key_env", "") == "LACAPULT_PACKAGE3_KEY", "backend config did not persist env-var name")
	var config_text = JSON.print(api_config)
	_require(config_text.find(FAKE_SECRET) < 0 and not api_config.has("api_key") and not api_config.has("secret"), "backend config leaked API secret")
	var patch = helpers.load_json_file(patch_path)
	var patch_text = JSON.print(patch)
	_require(patch_text.find("LLM_INTENT_API_PROVIDER") >= 0 and patch_text.find("openrouter") >= 0, "options patch did not carry provider metadata")
	_require(patch_text.find(FAKE_SECRET) < 0, "options patch leaked API secret")
	var apply_manifest = helpers.load_json_file(apply_path)
	var applied = _option_values(helpers.load_json_file(options_path))
	_require(apply_manifest.get("ok", false) == true and str(apply_manifest.get("status", "")).begins_with("ok_changed_"), "active options apply manifest did not report success")
	_require(api_config.get("caol_options_apply", {}).get("ok", false) == true, "backend config did not include successful active options apply result")
	_require(applied.get("LLM_INTENT_ENABLE", "") == "true", "active options did not enable the LLM runner")
	_require(applied.get("LLM_INTENT_BACKEND", "") == "api" and applied.get("LLM_INTENT_USE_API", "") == "true", "active options did not select API runner mode")
	_require(applied.get("LLM_INTENT_API_PROVIDER", "") == "openrouter", "active options lost API provider")
	_require(applied.get("LLM_INTENT_API_MODEL", "") == "openai/gpt-4.1-mini", "active options lost API model")
	_require(applied.get("LLM_INTENT_API_KEY_ENV", "") == "LACAPULT_PACKAGE3_KEY", "active options lost API env-var name")
	_require(applied.get("LLM_INTENT_PYTHON", "") == "python3", "active options lost Python runner path")
	_require(JSON.print(applied).find(FAKE_SECRET) < 0, "active options leaked API secret")

	var runner_button = _find_button(ui, "Test API runner")
	_require(runner_button != null, "Test API runner button lookup failed")
	runner_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._confirm_dialog.dialog_text.find("tools/llm_runner/runner.py") >= 0 and ui._confirm_dialog.dialog_text.find("--backend api") >= 0, "API runner confirmation did not invoke C-AOL runner.py route")
	_require(ui._confirm_dialog.dialog_text.find("--dry-run") >= 0 and ui._confirm_dialog.dialog_text.find("no API call") >= 0, "API runner confirmation lost proof/no-spend boundary")
	_require(ui._confirm_dialog.dialog_text.find(FAKE_SECRET) < 0, "API runner confirmation leaked API secret")
	ui._on_ExternalBackendAction_confirmed()
	yield(self, "idle_frame")
	_require(File.new().file_exists(runner_intent_path), "confirmed API runner test did not record runner intent")
	var runner_intent = helpers.load_json_file(runner_intent_path)
	var runner_text = JSON.print(runner_intent)
	_require(runner_intent.get("action", "") == "runner_test" and runner_intent.get("backend", "") == "api", "API runner intent action/backend mismatch")
	_require(runner_intent.get("result_summary", "") == "runner_test_ok", "API runner dry-run did not pass")
	_require(runner_intent.get("performed_live_backend_call", true) == false, "API runner proof claimed a live backend call")
	_require(runner_text.find("--dry-run") >= 0 and runner_text.find(FAKE_SECRET) < 0, "API runner intent lost dry-run boundary or leaked secret")
	_require(_find_status_row(ui._api_status_lights, "APIrunnertestStatusRow", "green"), "API runner status row did not turn green after proof dry-run")

	var install_button = _find_button(ui, "Set up API / AnyLLM")
	_require(install_button != null, "Set up API / AnyLLM button lookup failed")
	install_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._confirm_dialog.dialog_text.find("-m venv") >= 0 and ui._confirm_dialog.dialog_text.find("pip install --upgrade any-llm-sdk[openrouter]") >= 0, "confirmation did not show planned venv + any-llm-sdk setup phases")
	_require(ui._confirm_dialog.dialog_text.find("creates/updates") >= 0 and ui._confirm_dialog.dialog_text.find("installs AnyLLM") >= 0, "confirmation did not explain real venv/package install boundary")
	_require(ui._confirm_dialog.dialog_text.find("\n") >= 0 and ui._confirm_dialog.dialog_autowrap == true, "confirmation dialog did not use wrapped/newline layout")
	_require(ui._confirm_dialog.dialog_text.find("Proof mode") >= 0 and ui._confirm_dialog.dialog_text.find("instead of creating a venv or running pip") >= 0, "confirmation lost proof-mode no-pip boundary")
	_require(ui._confirm_dialog.dialog_text.find(FAKE_SECRET) < 0, "confirmation leaked API secret")
	ui._on_ExternalBackendAction_confirmed()
	yield(self, "idle_frame")
	_require(File.new().file_exists(intent_path), "confirmed API setup did not record setup intent")
	var intent = helpers.load_json_file(intent_path)
	var intent_text = JSON.print(intent)
	_require(intent.get("action", "") == "install_api_backend", "setup intent action mismatch")
	_require(intent.get("phase_order", []).has("create_or_update_venv") and intent.get("phase_order", []).has("install_anyllm_packages"), "setup intent missing venv/package phases")
	_require(intent.get("provider", "") == "openrouter", "setup intent provider mismatch")
	_require(intent.get("package_spec", "") == "any-llm-sdk[openrouter]", "setup intent did not use Mozilla any-llm PyPI package shape")
	_require(intent.get("performed_external_install", true) == false, "setup intent claimed an external install ran")
	_require(intent.get("phase_order", []).has("create_or_update_venv") and intent.get("phase_order", []).has("install_anyllm_packages"), "setup intent did not record venv/package phases")
	_require(intent_text.find(FAKE_SECRET) < 0, "setup intent leaked API secret")

	print("API / AnyLLM workflow UI smoke passed")
	print("  UI proof: API provider/model/env-var/session-key controls with normal base URL hidden, colored status rows, Create venv only, and Set up API / AnyLLM rendered")
	print("  Check proof: readiness-only; no backend config write and no API call")
	print("  Save proof: provider/default base URL/model/env-var name round-tripped and active C-AOL options.json enables API runner without storing secret")
	print("  Runner proof: confirmation-gated C-AOL runner.py --backend api --dry-run exercised the runner route without API call/secret read")
	print("  Install proof: confirmation-gated venv + AnyLLM setup command staged in proof mode; no venv/pip/API call/secret read")
	quit(0)


func _write_runner_fixture(install_dir: String) -> void:
	var runner_dir = install_dir.plus_file("tools").plus_file("llm_runner")
	var err = Directory.new().make_dir_recursive(runner_dir)
	_require(err == OK or err == ERR_ALREADY_EXISTS, "could not create runner fixture dir")
	var f = File.new()
	_require(f.open(runner_dir.plus_file("runner.py"), File.WRITE) == OK, "could not open runner fixture")
	f.store_string("import sys\nif '--dry-run' in sys.argv and '--backend' in sys.argv:\n    print('dry-run ok')\n    raise SystemExit(0)\nprint('fixture blocks live calls', file=sys.stderr)\nraise SystemExit(2)\n")
	f.close()


func _remove_if_exists(path: String) -> void:
	var f := File.new()
	if f.file_exists(path):
		Directory.new().remove(path)


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


func _option_has_item(option: OptionButton, text: String) -> bool:
	for i in range(option.get_item_count()):
		if option.get_item_text(i) == text:
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


func _option_values(options) -> Dictionary:
	var values = {}
	if typeof(options) != TYPE_ARRAY:
		return values
	for option in options:
		if typeof(option) == TYPE_DICTIONARY:
			values[str(option.get("name", ""))] = str(option.get("value", ""))
	return values


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	printerr("API / AnyLLM workflow UI smoke failed: %s" % message)
	quit(1)
