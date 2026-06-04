extends VBoxContainer


const MANUAL_SCENARIO_PREFIX = "manual."
const MAX_OUTPUT_CHARS = 5000

onready var _mods = get_node_or_null("../../../Mods")
onready var _sound = get_node_or_null("../../../Sound")

var _scenario_list: ItemList = null
var _details_label: Label = null
var _status_label: Label = null
var _output_box: TextEdit = null
var _refresh_button: Button = null
var _validate_button: Button = null
var _handoff_button: Button = null
var _open_report_button: Button = null
var _copy_command_button: Button = null
var _diagnostics_container: VBoxContainer = null
var _manual_scenarios := []
var _last_report_path := ""
var _last_run_dir := ""
var _busy := false


func _ready() -> void:
	_build_manual_handoff_controls()
	_refresh_manual_scenarios()


func _build_manual_handoff_controls() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	add_constant_override("separation", 6)

	var title = Label.new()
	title.text = "Manual Playtest Scenarios"
	title.align = Label.ALIGN_CENTER
	add_child(title)

	var intro = Label.new()
	intro.autowrap = true
	intro.text = "Choose a packaged manual scenario and start a C-AOL handoff for human playtesting."
	add_child(intro)

	_status_label = Label.new()
	_status_label.name = "HandoffStatus"
	_status_label.autowrap = true
	add_child(_status_label)

	var button_row = HBoxContainer.new()
	button_row.name = "HandoffActions"
	add_child(button_row)

	_refresh_button = Button.new()
	_refresh_button.text = "Refresh"
	_refresh_button.hint_tooltip = "Reload packaged manual scenarios from the active C-AOL install."
	_refresh_button.connect("pressed", self, "_refresh_manual_scenarios")
	button_row.add_child(_refresh_button)

	_validate_button = Button.new()
	_validate_button.text = "Validate setup"
	_validate_button.hint_tooltip = "Dry-run the selected handoff contract without launching the game."
	_validate_button.connect("pressed", self, "_on_ValidateHandoff_pressed")
	button_row.add_child(_validate_button)

	_handoff_button = Button.new()
	_handoff_button.text = "Start handoff"
	_handoff_button.hint_tooltip = "Set up the selected scenario, launch C-AOL, and leave the game open for human testing."
	_handoff_button.connect("pressed", self, "_on_StartHandoff_pressed")
	button_row.add_child(_handoff_button)

	_open_report_button = Button.new()
	_open_report_button.text = "Open handoff folder"
	_open_report_button.hint_tooltip = "Open the last handoff run folder."
	_open_report_button.connect("pressed", self, "_on_OpenHandoffReport_pressed")
	button_row.add_child(_open_report_button)

	_copy_command_button = Button.new()
	_copy_command_button.text = "Copy command"
	_copy_command_button.hint_tooltip = "Copy the selected handoff command for terminal use on another machine."
	_copy_command_button.connect("pressed", self, "_on_CopyHandoffCommand_pressed")
	button_row.add_child(_copy_command_button)

	_scenario_list = ItemList.new()
	_scenario_list.name = "ManualScenarioList"
	_scenario_list.rect_min_size = Vector2(0, 170)
	_scenario_list.size_flags_horizontal = SIZE_EXPAND_FILL
	_scenario_list.size_flags_vertical = SIZE_EXPAND_FILL
	_scenario_list.connect("item_selected", self, "_on_ManualScenario_selected")
	add_child(_scenario_list)

	_details_label = Label.new()
	_details_label.name = "ManualScenarioDetails"
	_details_label.autowrap = true
	add_child(_details_label)

	_output_box = TextEdit.new()
	_output_box.name = "HandoffOutput"
	_output_box.readonly = true
	_output_box.rect_min_size = Vector2(0, 110)
	_output_box.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(_output_box)

	var separator = HSeparator.new()
	add_child(separator)

	_build_launcher_diagnostics()
	_set_handoff_status("Ready. Select Refresh if you changed the active install.")
	_update_handoff_buttons()


func _build_launcher_diagnostics() -> void:
	_diagnostics_container = VBoxContainer.new()
	_diagnostics_container.name = "LauncherDiagnostics"
	_diagnostics_container.add_constant_override("separation", 4)
	add_child(_diagnostics_container)

	var label = Label.new()
	label.text = "Launcher diagnostics"
	label.align = Label.ALIGN_CENTER
	_diagnostics_container.add_child(label)

	var row_a = HBoxContainer.new()
	_diagnostics_container.add_child(row_a)
	_add_diag_button(row_a, "Mods", "_on_Button_pressed")
	_add_diag_button(row_a, "Sound", "_on_Button2_pressed")
	_add_diag_button(row_a, "Paths", "_on_Button7_pressed")
	_add_diag_button(row_a, "Screen", "_on_Button9_pressed")

	var row_b = HBoxContainer.new()
	_diagnostics_container.add_child(row_b)
	_add_diag_button(row_b, "Status", "_on_Button4_pressed")
	_add_diag_button(row_b, "Listing", "_on_Button5_pressed")
	_add_diag_button(row_b, "Tip", "_on_Button6_pressed")
	_add_diag_button(row_b, "Locale", "_on_Button8_pressed")


func _add_diag_button(parent: HBoxContainer, text: String, method: String) -> void:
	var button = Button.new()
	button.text = text
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.connect("pressed", self, method)
	parent.add_child(button)


func _refresh_manual_scenarios() -> void:
	if _busy:
		return
	var script_path = _manual_handoff_script_path()
	if script_path == "":
		_manual_scenarios.clear()
		_render_manual_scenarios()
		_set_handoff_status(_manual_handoff_missing_status())
		_set_output("")
		_update_handoff_buttons()
		return
	var python = _python_command_for_harness()
	_set_handoff_status("Loading manual scenarios from %s" % script_path)
	var result = yield(_run_harness_command("list", python, [script_path, "list-scenarios"]), "completed")
	if result.get("exit_code", -1) != 0:
		_manual_scenarios.clear()
		_render_manual_scenarios()
		_set_handoff_status("Could not list manual scenarios. Check Python and the active C-AOL install.")
		_set_output(result.get("text", ""))
		_update_handoff_buttons()
		return
	var parsed = _parse_json_text(result.get("text", ""))
	if parsed.empty() or not parsed.has("scenarios"):
		_manual_scenarios.clear()
		_render_manual_scenarios()
		_set_handoff_status("Harness returned an unreadable scenario list.")
		_set_output(result.get("text", ""))
		_update_handoff_buttons()
		return
	_manual_scenarios.clear()
	for scenario in parsed.get("scenarios", []):
		if not (scenario is Dictionary):
			continue
		var name = str(scenario.get("name", ""))
		if name.begins_with(MANUAL_SCENARIO_PREFIX):
			_manual_scenarios.append(scenario)
	_render_manual_scenarios()
	_set_output(result.get("text", ""))
	if _manual_scenarios.size() == 0:
		_set_handoff_status("No manual handoff scenarios were packaged in this C-AOL install.")
	else:
		_set_handoff_status("Loaded %s manual handoff scenario(s)." % _manual_scenarios.size())
	_update_handoff_buttons()


func _render_manual_scenarios() -> void:
	if _scenario_list == null:
		return
	_scenario_list.clear()
	for scenario in _manual_scenarios:
		var name = str(scenario.get("name", ""))
		var label = name.replace(MANUAL_SCENARIO_PREFIX, "")
		if scenario.get("status", "active") != "active":
			label += " (blocked)"
		var index = _scenario_list.get_item_count()
		_scenario_list.add_item(label)
		_scenario_list.set_item_metadata(index, scenario)
		_scenario_list.set_item_tooltip(index, str(scenario.get("description", "")))
		if scenario.get("status", "active") != "active":
			_scenario_list.set_item_disabled(index, true)
	if _manual_scenarios.size() > 0:
		_scenario_list.select(0)
		_update_selected_scenario_details()
	else:
		_details_label.text = ""


func _on_ManualScenario_selected(_index: int) -> void:
	_update_selected_scenario_details()
	_update_handoff_buttons()


func _update_selected_scenario_details() -> void:
	if _details_label == null:
		return
	var scenario = _selected_manual_scenario()
	if scenario.empty():
		_details_label.text = "No manual scenario selected."
		return
	var lines = []
	lines.append(str(scenario.get("name", "")))
	lines.append(str(scenario.get("description", "")))
	var full = _load_scenario_file(scenario)
	if not full.empty() and full.has("manual_playtest"):
		var manual = full.get("manual_playtest", {})
		if manual is Dictionary:
			var question = str(manual.get("question", "")).strip_edges()
			if question != "":
				lines.append("Question: %s" % question)
			var notes = manual.get("tester_notes", [])
			if notes is Array and notes.size() > 0:
				lines.append("Tester notes:")
				for note in notes:
					lines.append("- %s" % str(note))
	if scenario.get("status", "active") != "active":
		lines.append("Blocked: %s" % str(scenario.get("blocked_reason", "required helper missing")))
	_details_label.text = PoolStringArray(lines).join("\n")


func _load_scenario_file(scenario: Dictionary) -> Dictionary:
	var path = str(scenario.get("path", ""))
	if path == "" or not File.new().file_exists(path):
		return {}
	var parsed = Helpers.load_json_file(path)
	if parsed is Dictionary:
		return parsed
	return {}


func _selected_manual_scenario() -> Dictionary:
	if _scenario_list == null:
		return {}
	var selected = _scenario_list.get_selected_items()
	if selected.size() == 0:
		return {}
	var metadata = _scenario_list.get_item_metadata(selected[0])
	if metadata is Dictionary:
		return metadata
	return {}


func _on_ValidateHandoff_pressed() -> void:
	var scenario = _selected_manual_scenario()
	if scenario.empty() or _busy:
		return
	var script_path = _manual_handoff_script_path()
	var python = _python_command_for_harness()
	var args = [script_path, "handoff", scenario.get("name", ""), "--compact-stdout", "--launch-only", "--dry-run"]
	_set_handoff_status("Validating %s without launching the game..." % scenario.get("name", "manual scenario"))
	var result = yield(_run_harness_command("validate", python, args), "completed")
	_set_output(result.get("text", ""))
	var parsed = _parse_json_text(result.get("text", ""))
	if result.get("exit_code", -1) == 0:
		_set_handoff_status("Validation passed for %s. Start handoff will launch the game." % scenario.get("name", "manual scenario"))
	else:
		_set_handoff_status(_command_failure_status("Validation", result, parsed))


func _on_StartHandoff_pressed() -> void:
	var scenario = _selected_manual_scenario()
	if scenario.empty() or _busy:
		return
	var script_path = _manual_handoff_script_path()
	var python = _python_command_for_harness()
	var args = [script_path, "handoff", scenario.get("name", ""), "--compact-stdout", "--launch-only"]
	_set_handoff_status("Starting handoff for %s..." % scenario.get("name", "manual scenario"))
	var result = yield(_run_harness_command("handoff", python, args), "completed")
	_set_output(result.get("text", ""))
	var parsed = _parse_json_text(result.get("text", ""))
	if not parsed.empty():
		_last_report_path = str(parsed.get("report_path", ""))
		_last_run_dir = str(parsed.get("run_dir", ""))
	if result.get("exit_code", -1) == 0:
		var suffix = ""
		if _last_report_path != "":
			suffix = " Report: %s" % _last_report_path
		_set_handoff_status("Handoff started; C-AOL is left running for human testing.%s" % suffix)
	else:
		_set_handoff_status(_command_failure_status("Handoff", result, parsed))
	_update_handoff_buttons()


func _on_OpenHandoffReport_pressed() -> void:
	var folder = _last_run_dir
	if folder == "" and _last_report_path != "":
		folder = _last_report_path.get_base_dir()
	if folder == "" or not Directory.new().dir_exists(folder):
		_set_handoff_status("No handoff report folder is available yet.")
		return
	_open_directory(folder)


func _on_CopyHandoffCommand_pressed() -> void:
	var scenario = _selected_manual_scenario()
	if scenario.empty():
		return
	var script_path = _manual_handoff_script_path()
	if script_path == "":
		_set_handoff_status(_manual_handoff_missing_status())
		return
	var python = _python_command_for_harness()
	var args = [script_path, "handoff", scenario.get("name", ""), "--compact-stdout", "--launch-only"]
	var command = _quote_cli(python)
	for arg in args:
		command += " " + _quote_cli(str(arg))
	OS.set_clipboard(command)
	_set_handoff_status("Copied handoff command for %s." % scenario.get("name", "manual scenario"))


func _run_harness_command(_kind: String, python: String, args: Array):
	_busy = true
	_update_handoff_buttons()
	var oew = OSExecWrapper.new()
	oew.execute(python, PoolStringArray(args), true)
	yield(oew, "process_exited")
	_busy = false
	_update_handoff_buttons()
	var text = PoolStringArray(oew.output).join("\n")
	return {"exit_code": int(oew.exit_code), "text": text}


func _python_command_for_harness() -> String:
	return BackendConfig.resolve_runner_python_command(str(Settings.read("backend_python_path")))


func _manual_handoff_script_path() -> String:
	return BackendConfig.resolve_active_install_openclaw_harness_script_path()


func _manual_handoff_missing_status() -> String:
	var game = str(Settings.read("game"))
	var active = str(Settings.read("active_install_" + game)).strip_edges()
	var game_dir = str(Paths.game_dir)
	if active == "":
		active = "(none selected)"
	if game_dir == "":
		game_dir = "(unresolved)"
	return "Manual handoff requires an active C-AOL install with tools/openclaw_harness/startup_harness.py. Active install: %s. Path: %s" % [active, game_dir]


func _parse_json_text(text: String) -> Dictionary:
	var parsed = JSON.parse(text.strip_edges())
	if parsed.error == OK and parsed.result is Dictionary:
		return parsed.result
	return {}


func _command_failure_status(action: String, result: Dictionary, parsed: Dictionary) -> String:
	var exit_code = int(result.get("exit_code", -1))
	var detail = ""
	if not parsed.empty():
		for key in ["start_stderr", "stderr", "reason", "verdict"]:
			if parsed.has(key):
				detail = _first_output_line(str(parsed.get(key, "")))
				if detail != "":
					break
	if detail == "":
		detail = _first_output_line(str(result.get("text", "")))
	if detail != "":
		return "%s failed (exit %s): %s" % [action, exit_code, detail]
	return "%s failed (exit %s). Check the output box above and the active C-AOL install." % [action, exit_code]


func _first_output_line(text: String) -> String:
	for line in text.replace("\r", "\n").split("\n"):
		var cleaned = str(line).strip_edges()
		if cleaned == "" or cleaned == "{" or cleaned == "}":
			continue
		if cleaned.length() > 220:
			return cleaned.substr(0, 220) + "..."
		return cleaned
	return ""


func _set_handoff_status(text: String) -> void:
	if _status_label != null:
		_status_label.text = text
	Status.post(text, Enums.MSG_INFO)


func _set_output(text: String) -> void:
	if _output_box == null:
		return
	_output_box.text = _trim_output(text)


func _trim_output(text: String) -> String:
	if text.length() <= MAX_OUTPUT_CHARS:
		return text
	return text.substr(0, MAX_OUTPUT_CHARS) + "\n... [truncated]"


func _update_handoff_buttons() -> void:
	var has_harness = _manual_handoff_script_path() != ""
	var has_selection = not _selected_manual_scenario().empty()
	if _refresh_button != null:
		_refresh_button.disabled = _busy
	if _validate_button != null:
		_validate_button.disabled = _busy or not has_harness or not has_selection
	if _handoff_button != null:
		_handoff_button.disabled = _busy or not has_harness or not has_selection
	if _copy_command_button != null:
		_copy_command_button.disabled = _busy or not has_harness or not has_selection
	if _open_report_button != null:
		_open_report_button.disabled = _last_report_path == "" and _last_run_dir == ""


func _quote_cli(value: String) -> String:
	if value.find(" ") < 0 and value.find("\"") < 0 and value.find("'") < 0:
		return value
	if OS.get_name() == "Windows":
		return "\"" + value.replace("\"", "\\\"") + "\""
	return "'" + value.replace("'", "'\\''") + "'"


func _open_directory(path: String) -> void:
	if OS.get_name() == "OSX":
		OS.execute("open", [path], false)
	else:
		OS.shell_open(path)


func _on_Button_pressed() -> void:
	
	# Test modinfo parsing.
	if _mods == null:
		Status.post("Mod diagnostics are unavailable outside the full Catapult scene.", Enums.MSG_WARN)
		return
	
	var message = "Found mods:"
	var mods_dir = Paths.mods_stock
	
	Status.post("Looking for mods in %s" % mods_dir)
	
	for mod in _mods.parse_mods_dir(mods_dir):
		message += "\n" + mod["modinfo"]["name"]
		message += "\n(%s)" % mod["location"]
	
	Status.post(message)


func _on_Button2_pressed() -> void:
	
	# Test soundpack parsing.
	if _sound == null:
		Status.post("Sound diagnostics are unavailable outside the full Catapult scene.", Enums.MSG_WARN)
		return
	
	var message = "Found soundpacks:"
	var sound_dir = Paths.sound_user
	
	Status.post("Looking for soundpacks in %s" % sound_dir)
	
	for pack in _sound.parse_sound_dir(sound_dir):
		message += "\nName: %s" % pack["name"]
		message += "\nDescription: %s" % pack["description"]
		message += "\nLocation: %s" % pack["location"]
	
	Status.post(message)


func _on_Button3_pressed():
	
	var d = Directory.new()
	var dir = Paths.own_dir.plus_file("testdir")
	d.make_dir(dir)
	
	var command_linux = {
		"name": "sh",
		"args": ["-c", "echo", "Lorem ipsum"]
	}
	var command_windows = {
		"name": "cmd",
		"args": ["/S", "/C", "rmdir \"%s\"" % dir]
	}
	
	var command
	match OS.get_name():
		"X11":
			command = command_linux
		"Windows":
			command = command_windows
	
	Status.post("Command data: " + str(command))
	yield(get_tree().create_timer(2), "timeout")
	
	var oew = OSExecWrapper.new()
	oew.execute(command["name"], command["args"])
	yield(oew, "process_exited")

	Status.post("Command exited with code %s. Output:\n%s" % [oew.exit_code, oew.output[0]])


func _on_Button4_pressed() -> void:
	
	Status.post("Testing status messages:\n")
	yield(get_tree().create_timer(0.05), "timeout")
	Status.post("This is a normal (info) message.", Enums.MSG_INFO)
	yield(get_tree().create_timer(0.05), "timeout")
	Status.post("This is a warning message.", Enums.MSG_WARN)
	yield(get_tree().create_timer(0.05), "timeout")
	Status.post("This is an error message.", Enums.MSG_ERROR)
	yield(get_tree().create_timer(0.05), "timeout")
	Status.post("This is a debug message.\n", Enums.MSG_DEBUG)


func _on_Button5_pressed() -> void:
	
	var path = Paths.own_dir
	Status.post("Listing directory %s..." % path, Enums.MSG_DEBUG)
	yield(get_tree().create_timer(0.1), "timeout")
	
	var listing_msg = "\n"
	for p in FS.list_dir(path, true):
		listing_msg += p + "\n"
		
	Status.post(listing_msg, Enums.MSG_DEBUG)


func _on_Button6_pressed() -> void:
	
	Status.post("Random tip of the day (debug):\n%s\n" % TOTD.get_tip())


func _on_Button7_pressed() -> void:
	
	var msg = "PathHelper properties:"
	
	for prop in Paths.get_property_list():
		var name = prop["name"]
		if (prop["type"] == 4):
			msg += "\n%s: %s" % [name, Paths.get(name)]
	
	Status.post(msg, Enums.MSG_DEBUG)


func _on_Button8_pressed() -> void:
	
	var locales = TranslationServer.get_loaded_locales()
	var curr_locale = TranslationServer.get_locale()
	Status.post("Loaded locales: " + str(locales), Enums.MSG_DEBUG)
	Status.post("Current locale: " + curr_locale, Enums.MSG_DEBUG)
	for locale in locales:
		TranslationServer.set_locale(locale)
		Status.post(tr("debug_test"), Enums.MSG_DEBUG)
	TranslationServer.set_locale(curr_locale)


func _on_Button9_pressed() -> void:
	
	var msg := """Screen information:
	Screen count: %s
	Current screen: %s
	Screen position: %s
	Screen size: %s
	Window position: %s
	Window size: %s
	Real window size: %s\n""" % [ \
	OS.get_screen_count(),
	OS.current_screen,
	OS.get_screen_position(),
	OS.get_screen_size(),
	OS.window_position,
	OS.window_size,
	OS.get_real_window_size()]
	
	Status.post(msg, Enums.MSG_DEBUG)
