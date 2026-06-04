extends SceneTree

# Headless UI smoke for Package 4: Ollama installer/model readiness workflow.
# Proves the visible Ollama setup has one model-choice control, compact readiness
# lights for Mistral/Nemotron plus Python/options state, Check/Save/Install actions,
# active C-AOL options apply, and confirmation-gated setup intents. It does not
# install Ollama, create a real venv, pull models, call APIs, or mutate non-isolated
# Application Support data.

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
	_write_runner_fixture(install_dir)
	_write_harness_requirements_fixture(install_dir)

	settings.store("backend_mode", "ollama")
	settings.store("backend_ollama_endpoint", backend_config.DEFAULT_OLLAMA_URL)
	settings.store("backend_ollama_model", "mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest")
	settings.store("backend_python_path", "python3")
	settings.store("backend_external_setup_proof_only", true)
	settings.store("backend_runner_test_proof_only", true)
	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "models:mistral:v0.3")

	var missing = backend_config.get_ollama_readiness(backend_config.DEFAULT_OLLAMA_URL, "python3")
	_require(missing.get("model_states", {}).get("mistral:v0.3", "") == "green", "fixture model-present state did not mark Mistral ready")
	_require(missing.get("model_states", {}).get("nemotron-9b-dumber:latest", "") == "yellow", "fixture model-missing state did not mark Nemotron pull-needed")
	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "server_unreachable")
	var unreachable = backend_config.get_ollama_readiness(backend_config.DEFAULT_OLLAMA_URL, "python3")
	_require(unreachable.get("command_state", "") == "green" and unreachable.get("server_state", "") == "yellow", "fixture server-unreachable state did not mark command/server lights correctly")
	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "command_missing")
	var no_command = backend_config.get_ollama_readiness(backend_config.DEFAULT_OLLAMA_URL, "python3")
	_require(no_command.get("command_state", "") == "red", "fixture command-missing state did not mark command red")
	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "models:mistral:v0.3")
	var nemotron_plan = backend_config.build_ollama_setup_plan(backend_config.DEFAULT_OLLAMA_URL, "nemotron-9b")
	var nemotron_plan_text = JSON.print(nemotron_plan)
	_require(nemotron_plan.get("model", "") == "nemotron-9b-dumber:latest", "Nemotron setup plan did not normalize to the no-think runtime alias")
	_require(nemotron_plan.get("model_source", "") == "mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest", "Nemotron setup plan lost the Virtuoso source model")
	_require(nemotron_plan_text.find("SYSTEM /no_think") >= 0 or nemotron_plan_text.find("/no_think") >= 0, "Nemotron setup plan did not write a no-think Modelfile")
	_require(nemotron_plan_text.find("create_nemotron_no_think_alias") >= 0, "Nemotron setup plan did not create the no-think alias")
	_require(nemotron_plan_text.find("does not duplicate model weights") >= 0 or nemotron_plan_text.find("reuses the source model blobs") >= 0, "Nemotron setup plan does not state no duplicate model blob boundary")
	OS.set_environment("LACAPULT_HARDWARE_FIXTURE", "ram:16000,vram:1024")

	var config_path = paths.config.plus_file(backend_config.BACKEND_CONFIG_FILENAME)
	var patch_path = paths.config.plus_file(backend_config.C_AOL_OPTIONS_PATCH_FILENAME)
	var apply_path = paths.config.plus_file(backend_config.C_AOL_OPTIONS_APPLY_FILENAME)
	var options_path = paths.config.plus_file("options.json")
	var ollama_intent_path = paths.config.plus_file(backend_config.OLLAMA_SETUP_INTENT_FILENAME)
	var venv_intent_path = paths.config.plus_file(backend_config.PYTHON_VENV_SETUP_INTENT_FILENAME)
	var runner_intent_path = paths.config.plus_file(backend_config.RUNNER_TEST_INTENT_FILENAME)
	_remove_if_exists(config_path)
	_remove_if_exists(patch_path)
	_remove_if_exists(apply_path)
	_remove_if_exists(options_path)
	_remove_if_exists(ollama_intent_path)
	_remove_if_exists(venv_intent_path)
	_remove_if_exists(runner_intent_path)

	var ui_script = load("res://scripts/BackendSetupUI.gd")
	var ui = VBoxContainer.new()
	ui.set_script(ui_script)
	root.add_child(ui)
	yield(self, "idle_frame")

	var all_text = _collect_visible_text(ui)
	_require(all_text.find("Ollama model choice") >= 0, "Ollama model choice control did not render")
	_require(_visible_text_count(all_text, "Ollama model choice") == 1, "Ollama model choice rendered more than once")
	_require(all_text.find("Ollama model tag") < 0, "duplicate freeform Ollama model field is still visible")
	_require(_option_has_item(ui._ollama_model_choice, "Mistral v0.3") and _option_has_item(ui._ollama_model_choice, "Nemotron 9B"), "supported Ollama model choices did not render")
	_require(all_text.find("Ollama command") >= 0 and all_text.find("Mistral") >= 0 and all_text.find("Nemotron") >= 0 and all_text.find("Python/venv") >= 0, "Ollama status rows did not render")
	_require(all_text.find("Save options") >= 0 and all_text.find("Check") >= 0 and all_text.find("Install Ollama / model") >= 0 and all_text.find("Set up Python venv") >= 0 and all_text.find("Test Ollama runner") >= 0, "Ollama action row did not render Save/Check/Install/venv/runner-test actions")
	_require(all_text.find("API key") < 0 and all_text.find("Provider") < 0, "Ollama mode leaked API-only controls")
	_require(all_text.find("RAM: 15.6 GiB") >= 0 and all_text.find("VRAM: 1.0 GiB") >= 0 and all_text.find("mistral:v0.3 performance") >= 0 and all_text.find("nemotron-9b performance") >= 0 and all_text.find("Hardware check: missing") < 0, "Ollama GiB hardware/performance display did not render or still says missing")

	var check_button = _find_button(ui, "Check")
	_require(check_button != null, "Check button lookup failed")
	check_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(not File.new().file_exists(config_path), "Check wrote backend config; it should be detection-only")
	_require(_find_status_row(ui._ollama_status_lights, "MistralmodelStatusRow", "green") and _find_status_row(ui._ollama_status_lights, "NemotronmodelStatusRow", "yellow"), "fixture model readiness rows did not render expected present/missing state")

	var save_button = _find_button(ui, "Save options")
	_require(save_button != null, "Save options button lookup failed")
	save_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(File.new().file_exists(config_path), "Save options did not write backend config")
	_require(File.new().file_exists(patch_path), "Save options did not write options patch")
	_require(File.new().file_exists(apply_path), "Save options did not write options apply manifest")
	_require(File.new().file_exists(options_path), "Save options did not write active C-AOL options.json")
	var ollama_config = helpers.load_json_file(config_path)
	_require(ollama_config.get("backend", "") == "ollama", "backend config did not persist Ollama mode")
	_require(ollama_config.get("model", "") == "nemotron-9b-dumber:latest", "Save options did not normalize/persist the Nemotron no-think runtime alias")
	_require(settings.read("backend_ollama_model") == "nemotron-9b-dumber:latest", "Save options did not update the saved Ollama model setting to the no-think runtime alias")
	_require(JSON.print(ollama_config).find("LLM_INTENT_PYTHON") >= 0, "options patch/config did not explain shared Python runner path")
	var apply_manifest = helpers.load_json_file(apply_path)
	var applied = _option_values(helpers.load_json_file(options_path))
	_require(apply_manifest.get("ok", false) == true and str(apply_manifest.get("status", "")).begins_with("ok_changed_"), "active options apply manifest did not report success")
	_require(ollama_config.get("caol_options_apply", {}).get("ok", false) == true, "backend config did not include successful active options apply result")
	_require(applied.get("LLM_INTENT_ENABLE", "") == "true", "active options did not enable the LLM runner")
	_require(applied.get("LLM_INTENT_BACKEND", "") == "ollama" and applied.get("LLM_INTENT_USE_API", "") == "false", "active options did not select local Ollama runner mode")
	_require(applied.get("LLM_INTENT_OLLAMA_URL", "") == backend_config.DEFAULT_OLLAMA_URL, "active options lost Ollama URL")
	_require(applied.get("LLM_INTENT_OLLAMA_MODEL", "") == "nemotron-9b-dumber:latest", "active options lost no-think Ollama model")
	_require(applied.get("LLM_INTENT_PYTHON", "") == "python3", "active options lost Python runner path")

	var runner_button = _find_button(ui, "Test Ollama runner")
	_require(runner_button != null, "Test Ollama runner button lookup failed")
	runner_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._confirm_dialog.dialog_text.find("tools/llm_runner/runner.py") >= 0 and ui._confirm_dialog.dialog_text.find("--backend ollama") >= 0, "Ollama runner confirmation did not invoke C-AOL runner.py route")
	_require(ui._confirm_dialog.dialog_text.find("--dry-run") >= 0 and ui._confirm_dialog.dialog_text.find("no Ollama request") >= 0, "Ollama runner confirmation lost proof/no-request boundary")
	ui._on_ExternalBackendAction_confirmed()
	yield(self, "idle_frame")
	_require(File.new().file_exists(runner_intent_path), "confirmed Ollama runner test did not record runner intent")
	var runner_intent = helpers.load_json_file(runner_intent_path)
	var runner_text = JSON.print(runner_intent)
	_require(runner_intent.get("action", "") == "runner_test" and runner_intent.get("backend", "") == "ollama", "Ollama runner intent action/backend mismatch")
	_require(runner_intent.get("result_summary", "") == "runner_test_ok", "Ollama runner dry-run did not pass")
	_require(runner_intent.get("performed_live_backend_call", true) == false, "Ollama runner proof claimed a live backend call")
	_require(runner_text.find("--dry-run") >= 0 and runner_text.find("nemotron-9b-dumber:latest") >= 0, "Ollama runner intent lost dry-run/no-think model tag boundary")
	_require(_find_status_row(ui._ollama_status_lights, "OllamarunnertestStatusRow", "green"), "Ollama runner status row did not turn green after proof dry-run")

	var install_button = _find_button(ui, "Install Ollama / model")
	_require(install_button != null, "Install Ollama / model button lookup failed")
	install_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._confirm_dialog.dialog_text.find("nemotron-9b-dumber:latest") >= 0 or ui._confirm_dialog.dialog_text.find("mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest") >= 0, "Ollama confirmation did not name the selected no-think model/preparation path")
	_require(ui._confirm_dialog.dialog_text.find("Proof mode") >= 0 and ui._confirm_dialog.dialog_text.find("instead of running installers") >= 0, "Ollama confirmation lost proof-mode no-pull boundary")
	ui._on_ExternalBackendAction_confirmed()
	yield(self, "idle_frame")
	_require(File.new().file_exists(ollama_intent_path), "confirmed Ollama setup did not record setup intent")
	var ollama_intent = helpers.load_json_file(ollama_intent_path)
	_require(ollama_intent.get("action", "") == "install_ollama_and_prepare_model", "Ollama setup intent action mismatch")
	_require(ollama_intent.get("model", "") == "nemotron-9b-dumber:latest", "Ollama setup intent model mismatch")
	_require(ollama_intent.get("model_source", "") == "mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest", "Ollama setup intent lost Virtuoso source model")
	_require(ollama_intent.get("performed_external_install", true) == false, "Ollama setup proof claimed an external install ran")

	var venv_button = _find_button(ui, "Set up Python venv")
	_require(venv_button != null, "Set up Python venv button lookup failed")
	var executable_venv_plan = backend_config.build_python_venv_setup_plan("python3")
	_require(executable_venv_plan.get("target_path", "").find("caol-llm-python-venv") >= 0, "Python venv plan treated executable name as the venv target path")
	ui._backend_python_path.text = ""
	venv_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._confirm_dialog.dialog_text.find("uv 0.11.19") >= 0 and ui._confirm_dialog.dialog_text.find("CPython 3.13.13") >= 0 and ui._confirm_dialog.dialog_text.find("harness requirements") >= 0, "Python venv confirmation did not explain uv-managed runner.py/manual harness setup")
	ui._on_ExternalBackendAction_confirmed()
	yield(self, "idle_frame")
	_require(File.new().file_exists(venv_intent_path), "confirmed Python venv setup did not record setup intent")
	var venv_intent = helpers.load_json_file(venv_intent_path)
	_require(venv_intent.get("action", "") == "create_python_venv", "Python venv setup intent action mismatch")
	_require(venv_intent.get("performed_external_install", true) == false, "Python venv proof claimed a venv was created")
	_require(venv_intent.get("phase_order", []).has("install_openclaw_harness_requirements"), "Python venv proof did not include harness requirements phase")
	_require(venv_intent.get("harness_requirements_path", "").find("tools/openclaw_harness/requirements.txt") >= 0, "Python venv proof did not record harness requirements path")
	_require(ui._backend_python_path.text.find("caol-llm-python-venv") >= 0, "Python venv proof did not fill the intended path field")

	print("Ollama workflow UI smoke passed")
	print("  UI proof: one short-label Ollama model-choice control, real Mistral tag and Nemotron no-think alias, GiB hardware/performance lights, Check, Save, Install Ollama / model, and Set up Python venv rendered")
	print("  Fixture proof: command-missing, server-unreachable, model-present, and model-missing states are distinguishable without real pulls")
	print("  Check proof: readiness-only; no backend config write")
	print("  Save proof: Ollama endpoint/model/Python metadata round-tripped and active C-AOL options.json enables local runner")
	print("  Runner proof: confirmation-gated C-AOL runner.py --backend ollama --dry-run exercised the runner route without Ollama request/install/pull")
	print("  Install proof: confirmation-gated Ollama/model and Python venv intents recorded in proof mode; no installer, venv creation, model pull, API call, or non-isolated user config mutation")
	quit(0)


func _write_runner_fixture(install_dir: String) -> void:
	var runner_dir = install_dir.plus_file("tools").plus_file("llm_runner")
	var err = Directory.new().make_dir_recursive(runner_dir)
	_require(err == OK or err == ERR_ALREADY_EXISTS, "could not create runner fixture dir")
	var f = File.new()
	_require(f.open(runner_dir.plus_file("runner.py"), File.WRITE) == OK, "could not open runner fixture")
	f.store_string("import sys\nif '--dry-run' in sys.argv and '--backend' in sys.argv:\n    print('dry-run ok')\n    raise SystemExit(0)\nprint('fixture blocks live calls', file=sys.stderr)\nraise SystemExit(2)\n")
	f.close()


func _write_harness_requirements_fixture(install_dir: String) -> void:
	var harness_dir = install_dir.plus_file("tools").plus_file("openclaw_harness")
	var err = Directory.new().make_dir_recursive(harness_dir)
	_require(err == OK or err == ERR_ALREADY_EXISTS, "could not create harness fixture dir")
	var f = File.new()
	_require(f.open(harness_dir.plus_file("requirements.txt"), File.WRITE) == OK, "could not open harness requirements fixture")
	f.store_string("# stdlib-only harness requirements fixture\n")
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


func _option_values(options) -> Dictionary:
	var values = {}
	if typeof(options) != TYPE_ARRAY:
		return values
	for option in options:
		if typeof(option) == TYPE_DICTIONARY:
			values[str(option.get("name", ""))] = str(option.get("value", ""))
	return values


func _require(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	printerr("Ollama workflow smoke failed: " + message)
	quit(1)
