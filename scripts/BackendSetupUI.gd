extends VBoxContainer


const OLLAMA_MODEL_MISTRAL = "mistral:v0.3"
const OLLAMA_MODEL_NEMOTRON_SOURCE = "mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest"
const OLLAMA_MODEL_NEMOTRON = "nemotron-9b-dumber:latest"
const OLLAMA_LABEL_MISTRAL = "Mistral v0.3"
const OLLAMA_LABEL_NEMOTRON = "Nemotron 9B"
const CONFIRM_DIALOG_SIZE = Vector2(520, 260)

var _backend_modes := ["api", "ollama"]
var _pending_confirm_action := ""

var _backend_mode_button: OptionButton = null
var _intro: Label = null
var _guidance: Label = null
var _backend_endpoint_label: Label = null
var _backend_endpoint: LineEdit = null
var _api_base_url_help: Label = null
var _backend_provider_label: Label = null
var _backend_provider_button: OptionButton = null
var _backend_model_label: Label = null
var _backend_model: LineEdit = null
var _ollama_model_choice_label: Label = null
var _ollama_model_choice: OptionButton = null
var _hardware_hint: Label = null
var _backend_python_path: LineEdit = null
var _backend_api_key_env: LineEdit = null
var _backend_api_key_secret: LineEdit = null
var _set_session_key_button: Button = null
var _install_python_button: Button = null
var _api_status_lights: VBoxContainer = null
var _ollama_status_lights: VBoxContainer = null
var _backend_status: Label = null
var _command_preview_box: TextEdit = null
var _save_button: Button = null
var _check_button: Button = null
var _install_button: Button = null
var _runner_test_button: Button = null
var _confirm_dialog: ConfirmationDialog = null


func _ready() -> void:
	_build_controls()
	_refresh_backend_setup_controls()


func _build_controls() -> void:
	add_constant_override("separation", 6)

	var title = Label.new()
	title.text = "LLM"
	title.align = Label.ALIGN_CENTER
	add_child(title)

	_intro = Label.new()
	_intro.autowrap = true
	_intro.text = "Choose API or local Ollama setup."
	add_child(_intro)

	var mode_row = HBoxContainer.new()
	mode_row.name = "BackendMode"
	add_child(mode_row)
	var mode_label = Label.new()
	mode_label.text = "Setup path"
	mode_label.size_flags_horizontal = SIZE_EXPAND_FILL
	mode_row.add_child(mode_label)
	_backend_mode_button = OptionButton.new()
	_backend_mode_button.rect_min_size = Vector2(240, 0)
	_backend_mode_button.size_flags_horizontal = SIZE_SHRINK_END
	_backend_mode_button.add_item("API / AnyLLM")
	_backend_mode_button.add_item("Ollama local")
	_backend_mode_button.connect("item_selected", self, "_on_BackendMode_item_selected")
	mode_row.add_child(_backend_mode_button)

	_guidance = Label.new()
	_guidance.autowrap = true
	add_child(_guidance)

	var endpoint_row = HBoxContainer.new()
	endpoint_row.name = "BackendEndpoint"
	add_child(endpoint_row)
	_backend_endpoint_label = Label.new()
	_backend_endpoint_label.text = "Endpoint"
	_backend_endpoint_label.size_flags_horizontal = SIZE_EXPAND_FILL
	endpoint_row.add_child(_backend_endpoint_label)
	_backend_endpoint = LineEdit.new()
	_backend_endpoint.rect_min_size = Vector2(300, 0)
	_backend_endpoint.size_flags_horizontal = SIZE_EXPAND_FILL
	_backend_endpoint.connect("text_changed", self, "_on_BackendEndpoint_text_changed")
	endpoint_row.add_child(_backend_endpoint)

	_api_base_url_help = Label.new()
	_api_base_url_help.name = "ApiBaseUrlHelp"
	_api_base_url_help.autowrap = true
	_api_base_url_help.text = "Leave the provider default unless you use a proxy/router."
	add_child(_api_base_url_help)

	var provider_row = HBoxContainer.new()
	provider_row.name = "BackendApiProvider"
	add_child(provider_row)
	_backend_provider_label = Label.new()
	_backend_provider_label.text = "Provider"
	_backend_provider_label.size_flags_horizontal = SIZE_EXPAND_FILL
	provider_row.add_child(_backend_provider_label)
	_backend_provider_button = OptionButton.new()
	_backend_provider_button.rect_min_size = Vector2(300, 0)
	for choice in BackendConfig.get_api_provider_choices():
		_backend_provider_button.add_item(choice.get("label", choice.get("id", "provider")))
		_backend_provider_button.set_item_metadata(_backend_provider_button.get_item_count() - 1, choice.get("id", BackendConfig.DEFAULT_API_PROVIDER))
	_backend_provider_button.connect("item_selected", self, "_on_ApiProvider_item_selected")
	provider_row.add_child(_backend_provider_button)

	var model_row = HBoxContainer.new()
	model_row.name = "BackendModel"
	add_child(model_row)
	_backend_model_label = Label.new()
	_backend_model_label.text = "Model"
	_backend_model_label.size_flags_horizontal = SIZE_EXPAND_FILL
	model_row.add_child(_backend_model_label)
	_backend_model = LineEdit.new()
	_backend_model.rect_min_size = Vector2(300, 0)
	_backend_model.size_flags_horizontal = SIZE_EXPAND_FILL
	_backend_model.connect("text_changed", self, "_on_BackendModel_text_changed")
	model_row.add_child(_backend_model)

	var ollama_choice_row = HBoxContainer.new()
	ollama_choice_row.name = "OllamaModelChoice"
	add_child(ollama_choice_row)
	_ollama_model_choice_label = Label.new()
	_ollama_model_choice_label.text = "Ollama model choice"
	_ollama_model_choice_label.size_flags_horizontal = SIZE_EXPAND_FILL
	ollama_choice_row.add_child(_ollama_model_choice_label)
	_ollama_model_choice = OptionButton.new()
	_ollama_model_choice.rect_min_size = Vector2(300, 0)
	_ollama_model_choice.add_item(OLLAMA_LABEL_MISTRAL)
	_ollama_model_choice.set_item_metadata(_ollama_model_choice.get_item_count() - 1, OLLAMA_MODEL_MISTRAL)
	_ollama_model_choice.add_item(OLLAMA_LABEL_NEMOTRON)
	_ollama_model_choice.set_item_metadata(_ollama_model_choice.get_item_count() - 1, OLLAMA_MODEL_NEMOTRON)
	_ollama_model_choice.connect("item_selected", self, "_on_OllamaModelChoice_item_selected")
	ollama_choice_row.add_child(_ollama_model_choice)

	_hardware_hint = Label.new()
	_hardware_hint.name = "HardwareRecommendation"
	_hardware_hint.autowrap = true
	_hardware_hint.visible = false
	add_child(_hardware_hint)

	var python_row = HBoxContainer.new()
	python_row.name = "BackendPython"
	add_child(python_row)
	var python_label = Label.new()
	python_label.text = "Python / venv"
	python_label.size_flags_horizontal = SIZE_EXPAND_FILL
	python_row.add_child(python_label)
	_backend_python_path = LineEdit.new()
	_backend_python_path.rect_min_size = Vector2(300, 0)
	_backend_python_path.placeholder_text = "Optional Python executable or venv path for C-AOL runner.py"
	_backend_python_path.size_flags_horizontal = SIZE_EXPAND_FILL
	_backend_python_path.connect("text_changed", self, "_on_BackendPython_text_changed")
	python_row.add_child(_backend_python_path)
	_install_python_button = Button.new()
	_install_python_button.text = "Create venv only"
	_install_python_button.hint_tooltip = "Creates or updates the runner.py Python venv only.\nIt does not install AnyLLM packages.\nUse the AnyLLM install action after choosing that venv."
	_install_python_button.connect("pressed", self, "_on_ConfirmPythonVenvInstall_pressed")
	python_row.add_child(_install_python_button)

	var api_env_row = HBoxContainer.new()
	api_env_row.name = "BackendApiKeyEnv"
	add_child(api_env_row)
	var api_env_label = Label.new()
	api_env_label.text = "API key env var"
	api_env_label.size_flags_horizontal = SIZE_EXPAND_FILL
	api_env_row.add_child(api_env_label)
	_backend_api_key_env = LineEdit.new()
	_backend_api_key_env.rect_min_size = Vector2(300, 0)
	_backend_api_key_env.placeholder_text = "CATA_API_KEY"
	_backend_api_key_env.size_flags_horizontal = SIZE_EXPAND_FILL
	_backend_api_key_env.connect("text_changed", self, "_on_BackendApiKeyEnv_text_changed")
	api_env_row.add_child(_backend_api_key_env)

	var api_secret_row = HBoxContainer.new()
	api_secret_row.name = "BackendApiSessionKey"
	add_child(api_secret_row)
	var api_secret_label = Label.new()
	api_secret_label.text = "API key (session only)"
	api_secret_label.size_flags_horizontal = SIZE_EXPAND_FILL
	api_secret_row.add_child(api_secret_label)
	_backend_api_key_secret = LineEdit.new()
	_backend_api_key_secret.rect_min_size = Vector2(220, 0)
	_backend_api_key_secret.placeholder_text = "Optional paste; never saved or logged"
	_backend_api_key_secret.secret = true
	_backend_api_key_secret.size_flags_horizontal = SIZE_EXPAND_FILL
	api_secret_row.add_child(_backend_api_key_secret)
	_set_session_key_button = Button.new()
	_set_session_key_button.text = "Use for this session"
	_set_session_key_button.hint_tooltip = "Session only:\nSets the named environment variable for this Catapult-Dabubu process.\nClears the paste field.\nNever saves the key to settings/config."
	_set_session_key_button.connect("pressed", self, "_on_SetSessionApiKey_pressed")
	api_secret_row.add_child(_set_session_key_button)

	_api_status_lights = VBoxContainer.new()
	_api_status_lights.name = "ApiStatusLights"
	add_child(_api_status_lights)

	_ollama_status_lights = VBoxContainer.new()
	_ollama_status_lights.name = "OllamaStatusLights"
	add_child(_ollama_status_lights)

	_backend_status = Label.new()
	_backend_status.autowrap = true
	add_child(_backend_status)

	var button_row = HBoxContainer.new()
	button_row.name = "BackendActions"
	add_child(button_row)
	_save_button = Button.new()
	_save_button.text = "Save options"
	_save_button.hint_tooltip = "Persist the current backend options without installing packages, pulling models, or calling an API."
	_save_button.connect("pressed", self, "_on_SaveBackendSetup_pressed")
	button_row.add_child(_save_button)
	_check_button = Button.new()
	_check_button.text = "Check"
	_check_button.hint_tooltip = "Refresh readiness lights only; no install, model pull, or API call."
	_check_button.connect("pressed", self, "_on_CheckBackendSetup_pressed")
	button_row.add_child(_check_button)
	_install_button = Button.new()
	_install_button.text = "Install setup"
	_install_button.hint_tooltip = "Saves current options first, then opens a confirmation prompt; automated tests do not install packages or pull models."
	_install_button.connect("pressed", self, "_on_ConfirmGuidedInstall_pressed")
	button_row.add_child(_install_button)
	_runner_test_button = Button.new()
	_runner_test_button.text = "Runner test"
	_runner_test_button.hint_tooltip = "Saves options, then asks before exercising C-AOL tools/llm_runner/runner.py. Proof mode uses --dry-run and makes no API call or model request."
	_runner_test_button.connect("pressed", self, "_on_ConfirmRunnerTest_pressed")
	button_row.add_child(_runner_test_button)

	_command_preview_box = TextEdit.new()
	_command_preview_box.name = "BackendCommandPreview"
	_command_preview_box.readonly = true
	_command_preview_box.rect_min_size = Vector2(0, 68)
	_command_preview_box.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(_command_preview_box)

	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.name = "ConfirmExternalBackendAction"
	_confirm_dialog.window_title = "Confirm external setup action"
	_confirm_dialog.dialog_text = "Catapult-Dabubu will ask before external package installs or model downloads. This proof build records the confirmed intent only and does not run package managers or pull models automatically."
	_confirm_dialog.dialog_autowrap = true
	_confirm_dialog.rect_min_size = CONFIRM_DIALOG_SIZE
	_confirm_dialog.connect("confirmed", self, "_on_ExternalBackendAction_confirmed")
	add_child(_confirm_dialog)


func _refresh_backend_setup_controls() -> void:
	if _backend_mode_button == null:
		return
	var mode = Settings.read("backend_mode")
	var mode_idx = _backend_modes.find(mode)
	if mode_idx < 0:
		mode_idx = 0
		mode = _backend_modes[mode_idx]
		Settings.store("backend_mode", mode)
	_backend_mode_button.select(mode_idx)

	var choice_row = _ollama_model_choice.get_parent()
	var model_row = _backend_model.get_parent()
	var provider_row = _backend_provider_button.get_parent()
	var api_secret_row = _backend_api_key_secret.get_parent()
	if mode == "api":
		var provider_id = _select_api_provider(Settings.read("backend_api_provider"))
		var provider_base_url = BackendConfig.get_api_provider_default_base_url(provider_id)
		var provider_model = BackendConfig.get_api_provider_default_model(provider_id)
		_backend_endpoint_label.text = "Advanced/custom base URL"
		_backend_model_label.text = "API model"
		var show_advanced_base_url = provider_id == "custom_any_llm"
		_backend_endpoint.placeholder_text = provider_base_url if provider_base_url != "" else "Optional proxy/router/custom endpoint"
		_backend_model.placeholder_text = provider_model if provider_model != "" else "Provider model name"
		_backend_endpoint.hint_tooltip = "Advanced/custom endpoint override only; normal providers use their default endpoint."
		_backend_endpoint.text = Settings.read("backend_api_endpoint") if show_advanced_base_url else ""
		_backend_model.text = Settings.read("backend_api_model")
		_backend_api_key_env.get_parent().visible = true
		api_secret_row.visible = true
		provider_row.visible = true
		_backend_endpoint.get_parent().visible = show_advanced_base_url
		_api_base_url_help.visible = show_advanced_base_url
		_api_status_lights.visible = true
		_ollama_status_lights.visible = false
		_hardware_hint.visible = false
		choice_row.visible = false
		model_row.visible = true
		_install_python_button.text = "Create venv only"
		_install_python_button.hint_tooltip = "Advanced: creates/updates only the runner.py venv. The main API setup action also installs AnyLLM packages."
		_install_button.text = "Set up API / AnyLLM"
		_install_button.hint_tooltip = "Saves options, then asks before creating/updating the venv and installing AnyLLM/provider packages into it.\nNo API call or API-secret read is performed."
		_runner_test_button.text = "Test API runner"
		_runner_test_button.hint_tooltip = "Asks before exercising C-AOL runner.py with the selected API provider/model/env-var. Proof mode uses --dry-run so no live API call or secret read happens."
		_guidance.text = "API path: choose provider/model, set env-var name, then run setup."
	elif mode == "ollama":
		_backend_endpoint_label.text = "Ollama URL"
		_backend_model_label.text = "Ollama model tag"
		_backend_endpoint.placeholder_text = BackendConfig.DEFAULT_OLLAMA_URL
		_backend_model.placeholder_text = "%s or %s" % [OLLAMA_MODEL_MISTRAL, OLLAMA_MODEL_NEMOTRON]
		_backend_endpoint.hint_tooltip = "Local Ollama server URL."
		_backend_endpoint.text = Settings.read("backend_ollama_endpoint")
		var normalized_model = BackendConfig.normalize_ollama_model_tag(Settings.read("backend_ollama_model"))
		_backend_model.text = normalized_model
		Settings.store("backend_ollama_model", normalized_model)
		_backend_endpoint.get_parent().visible = true
		_backend_api_key_env.get_parent().visible = false
		api_secret_row.visible = false
		provider_row.visible = false
		_api_base_url_help.visible = false
		_api_status_lights.visible = false
		_ollama_status_lights.visible = true
		_hardware_hint.visible = true
		choice_row.visible = true
		model_row.visible = false
		_install_python_button.text = "Create venv only"
		_install_python_button.hint_tooltip = "Creates or updates the runner.py Python venv only.\nOllama itself and model pulls use Install Ollama / model."
		_install_button.text = "Install Ollama / model"
		_install_button.hint_tooltip = "Saves options, then asks before installing Ollama or pulling the selected model.\nAutomated proof records intent only."
		_runner_test_button.text = "Test Ollama runner"
		_runner_test_button.hint_tooltip = "Asks before exercising C-AOL runner.py against the selected local Ollama endpoint/model. It never installs Ollama or pulls a model."
		_select_ollama_choice(Settings.read("backend_ollama_model"))
		_guidance.text = "Ollama path: Check hardware/readiness, then install or pull one step at a time."

	_backend_python_path.text = Settings.read("backend_python_path")
	_backend_api_key_env.text = Settings.read("backend_api_key_env")
	_hardware_hint.text = ""
	_update_command_preview_box(mode)

	var raw_status = _check_current_backend_status()
	_set_backend_status(mode, raw_status)


func _check_current_backend_status() -> String:
	var fields = _collect_current_backend_fields()
	return BackendConfig.check_backend_status(fields.get("mode", "api"), fields.get("endpoint", ""), fields.get("model", ""), fields.get("python_path", ""), fields.get("api_provider", BackendConfig.DEFAULT_API_PROVIDER), fields.get("api_key_env", BackendConfig.DEFAULT_API_KEY_ENV), fields.get("openvino_model_dir", ""), fields.get("openvino_device", BackendConfig.DEFAULT_OPENVINO_DEVICE))


func _set_backend_status(mode: String, raw_status: String, prefix: String = "") -> void:
	var light = BackendConfig.get_status_light(raw_status)
	var lines = []
	var lead = "%s" % light.get("state", "Needs action")
	if prefix != "":
		lead = "%s — %s" % [prefix, lead]
	lines.append("%s: %s" % [lead, light.get("summary", raw_status)])
	if mode == "api":
		if _api_status_lights != null:
			_set_status_rows(_api_status_lights, _api_status_rows(raw_status))
		lines.append("Secret policy: env-var name only; pasted keys are session-only and cleared after use. Check makes no API call.")
		lines.append("Runner test: confirmation-gated; proof mode invokes C-AOL runner.py with --dry-run and no API call.")
		lines.append("Setup path: creates/updates the venv, installs AnyLLM/provider packages, then use Check.")
	elif mode == "ollama":
		if _ollama_status_lights != null:
			_set_status_rows(_ollama_status_lights, _ollama_status_rows())
		lines.append("Install policy: serialized confirmed steps only; no chained install+pull when Ollama is not ready.")
		lines.append("Runner test: confirmation-gated C-AOL runner.py check; no Ollama install or model pull.")
		lines.append("The launcher may appear to time out. Wait for Ollama installation to commence.")
	_backend_status.text = "\n".join(lines)
	_update_command_preview_box(mode)


func _ollama_status_rows() -> Array:
	var endpoint = _backend_endpoint.text if _backend_endpoint != null else BackendConfig.DEFAULT_OLLAMA_URL
	var python_path = _backend_python_path.text if _backend_python_path != null else ""
	var readiness = BackendConfig.get_ollama_readiness(endpoint, python_path)
	var model_states = readiness.get("model_states", readiness.get("model_lights", {}))
	var hardware = BackendConfig.get_ollama_hardware_check()
	_hardware_hint.text = "RAM: %.1f GiB   VRAM: %.1f GiB" % [hardware.get("ram_gib", 0.0), hardware.get("vram_gib", 0.0)]
	var performance = hardware.get("performance_lights", {})
	return [
		{"label": "Ollama command", "state": readiness.get("command_state", readiness.get("command_light", "red"))},
		{"label": "Ollama server", "state": readiness.get("server_state", readiness.get("server_light", "red"))},
		{"label": "Mistral model", "state": model_states.get(OLLAMA_MODEL_MISTRAL, "red")},
		{"label": "Nemotron model", "state": model_states.get(OLLAMA_MODEL_NEMOTRON, "red")},
		{"label": "mistral:v0.3 performance", "state": performance.get(OLLAMA_MODEL_MISTRAL, "gray"), "state_label": _performance_label(performance.get(OLLAMA_MODEL_MISTRAL, "gray"))},
		{"label": "nemotron-9b performance", "state": performance.get(OLLAMA_MODEL_NEMOTRON, "gray"), "state_label": _performance_label(performance.get(OLLAMA_MODEL_NEMOTRON, "gray"))},
		{"label": "Python/venv", "state": readiness.get("python_state", readiness.get("python_light", "red"))},
		{"label": "Options", "state": readiness.get("options_state", readiness.get("options_light", "green"))},
		{"label": "Ollama runner test", "state": _runner_test_state("ollama")}
	]


func _api_status_rows(raw_status: String) -> Array:
	var python_state = "red" if raw_status.find("api_python_missing") >= 0 else "green"
	var import_state = "green" if raw_status.find("any_llm_import_ok") >= 0 else "yellow"
	if raw_status.find("any_llm_missing") >= 0:
		import_state = "yellow"
	var env_state = "green" if raw_status.find("api_key_env_present_secret_not_read") >= 0 else "yellow"
	if raw_status.find("api_key_env_missing") >= 0:
		env_state = "red"
	var ready_state = "green" if raw_status.find("any_llm_import_ok") >= 0 and raw_status.find("model_configured") >= 0 and raw_status.find("api_key_env_present_secret_not_read") >= 0 else "yellow"
	return [
		{"label": "Python / venv", "state": python_state},
		{"label": "AnyLLM packages", "state": import_state},
		{"label": "API-key env var", "state": env_state},
		{"label": "API setup", "state": ready_state},
		{"label": "API runner test", "state": _runner_test_state("api")}
	]


func _runner_test_state(mode: String) -> String:
	var status = str(Settings.read("backend_%s_runner_test_status" % mode))
	if status.find("runner_test_ok") >= 0:
		return "green"
	if status.find("runner_test_failed") >= 0 or status.find("runner_test_runner_missing") >= 0:
		return "red"
	return "yellow"


func _set_status_rows(container: VBoxContainer, rows: Array) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	for row in rows:
		var h = HBoxContainer.new()
		h.name = "%sStatusRow" % str(row.get("label", "State")).replace(" ", "")
		h.set_meta("status_state", row.get("state", "gray"))
		var dot = Label.new()
		dot.name = "BigStatusDot"
		dot.text = "●"
		dot.rect_min_size = Vector2(24, 20)
		dot.align = Label.ALIGN_CENTER
		dot.add_color_override("font_color", _status_color(row.get("state", "gray")))
		dot.set_meta("status_state", row.get("state", "gray"))
		h.add_child(dot)
		var label = Label.new()
		label.name = "StatusLabel"
		label.text = "%s: %s" % [row.get("label", "State"), row.get("state_label", _status_label(row.get("state", "gray")))]
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		h.add_child(label)
		container.add_child(h)


func _status_color(state: String) -> Color:
	if state == "green":
		return Color(0.1, 0.75, 0.2)
	if state == "yellow":
		return Color(0.95, 0.72, 0.1)
	if state == "red":
		return Color(0.9, 0.15, 0.12)
	return Color(0.45, 0.45, 0.45)


func _status_label(state: String) -> String:
	if state == "green":
		return "ready"
	if state == "yellow":
		return "needs action"
	if state == "red":
		return "missing"
	return "unknown"


func _performance_label(state: String) -> String:
	if state == "green":
		return "estimated good"
	if state == "yellow":
		return "estimated borderline"
	if state == "red":
		return "estimated slow"
	return "not measured"


func _select_api_provider(provider_id: String) -> String:
	if _backend_provider_button == null:
		return BackendConfig.DEFAULT_API_PROVIDER
	var normalized = BackendConfig.get_api_provider_choice(provider_id).get("id", BackendConfig.DEFAULT_API_PROVIDER)
	for i in range(_backend_provider_button.get_item_count()):
		if str(_backend_provider_button.get_item_metadata(i)) == normalized:
			_backend_provider_button.select(i)
			return normalized
	_backend_provider_button.select(0)
	return str(_backend_provider_button.get_item_metadata(0))


func _current_api_provider_id() -> String:
	if _backend_provider_button == null:
		return Settings.read("backend_api_provider")
	var idx = _backend_provider_button.get_selected()
	if idx < 0:
		return BackendConfig.DEFAULT_API_PROVIDER
	return str(_backend_provider_button.get_item_metadata(idx))


func _select_ollama_choice(model_name: String) -> void:
	if _ollama_model_choice == null:
		return
	var selected_model = BackendConfig.normalize_ollama_model_tag(model_name)
	var idx = 0
	for i in range(_ollama_model_choice.get_item_count()):
		if str(_ollama_model_choice.get_item_metadata(i)) == selected_model:
			idx = i
			break
	_ollama_model_choice.select(idx)
	Settings.store("backend_ollama_model", str(_ollama_model_choice.get_item_metadata(idx)))
	_backend_model.text = str(_ollama_model_choice.get_item_metadata(idx))


func _store_backend_field(setting_prefix: String, value: String) -> void:
	var mode = Settings.read("backend_mode")
	if mode == "api" or mode == "ollama":
		Settings.store("backend_%s_%s" % [mode, setting_prefix], value)


func _collect_current_backend_fields() -> Dictionary:
	var mode = Settings.read("backend_mode")
	var model_value = "" if _backend_model == null else _backend_model.text
	if mode == "ollama":
		model_value = BackendConfig.normalize_ollama_model_tag(Settings.read("backend_ollama_model"))
	return {
		"mode": mode,
		"endpoint": "" if _backend_endpoint == null else _backend_endpoint.text,
		"model": model_value,
		"python_path": "" if _backend_python_path == null else _backend_python_path.text,
		"api_provider": _current_api_provider_id(),
		"api_key_env": "" if _backend_api_key_env == null else _backend_api_key_env.text,
		"openvino_model_dir": Settings.read("backend_openvino_model_dir"),
		"openvino_device": Settings.read("backend_openvino_device")
	}


func _persist_current_fields_to_settings() -> void:
	var fields = _collect_current_backend_fields()
	var mode = fields.get("mode", "api")
	Settings.store("backend_python_path", fields.get("python_path", ""))
	if mode == "api":
		Settings.store("backend_api_endpoint", fields.get("endpoint", ""))
		Settings.store("backend_api_model", fields.get("model", ""))
		Settings.store("backend_api_provider", fields.get("api_provider", BackendConfig.DEFAULT_API_PROVIDER))
		Settings.store("backend_api_key_env", fields.get("api_key_env", BackendConfig.DEFAULT_API_KEY_ENV))
	elif mode == "ollama":
		Settings.store("backend_ollama_endpoint", fields.get("endpoint", BackendConfig.DEFAULT_OLLAMA_URL))
		Settings.store("backend_ollama_model", BackendConfig.normalize_ollama_model_tag(fields.get("model", "")))


func _save_current_backend_setup() -> String:
	_persist_current_fields_to_settings()
	var fields = _collect_current_backend_fields()
	return BackendConfig.write_launcher_backend_config(fields.get("mode", "api"), fields.get("endpoint", ""), fields.get("model", ""), fields.get("python_path", ""), fields.get("api_provider", BackendConfig.DEFAULT_API_PROVIDER), fields.get("api_key_env", BackendConfig.DEFAULT_API_KEY_ENV), fields.get("openvino_model_dir", ""), fields.get("openvino_device", BackendConfig.DEFAULT_OPENVINO_DEVICE))


func _on_BackendMode_item_selected(index: int) -> void:
	Settings.store("backend_mode", _backend_modes[index])
	_refresh_backend_setup_controls()


func _on_BackendEndpoint_text_changed(new_text: String) -> void:
	_store_backend_field("endpoint", new_text)


func _on_BackendModel_text_changed(new_text: String) -> void:
	_store_backend_field("model", new_text)


func _on_ApiProvider_item_selected(index: int) -> void:
	var provider_id = str(_backend_provider_button.get_item_metadata(index))
	Settings.store("backend_api_provider", provider_id)
	if _backend_endpoint.text.strip_edges() == "":
		_backend_endpoint.placeholder_text = BackendConfig.get_api_provider_default_base_url(provider_id)
	if _backend_model.text.strip_edges() == "":
		_backend_model.placeholder_text = BackendConfig.get_api_provider_default_model(provider_id)
	_refresh_backend_setup_controls()


func _on_OllamaModelChoice_item_selected(index: int) -> void:
	var model = str(_ollama_model_choice.get_item_metadata(index))
	Settings.store("backend_ollama_model", model)
	_backend_model.text = model
	_refresh_backend_setup_controls()


func _on_BackendPython_text_changed(new_text: String) -> void:
	Settings.store("backend_python_path", new_text)


func _on_BackendApiKeyEnv_text_changed(new_text: String) -> void:
	Settings.store("backend_api_key_env", new_text)


func _on_SetSessionApiKey_pressed() -> void:
	var env_name = _backend_api_key_env.text.strip_edges()
	var key_value = _backend_api_key_secret.text
	if env_name == "":
		_set_backend_status(Settings.read("backend_mode"), "api_key_env_missing", "Session key not set")
		return
	if key_value == "":
		_set_backend_status(Settings.read("backend_mode"), "api_key_env_not_set_no_secret_used", "Session key not set")
		return
	OS.set_environment(env_name, key_value)
	_backend_api_key_secret.text = ""
	Settings.store("backend_api_key_env", env_name)
	_set_backend_status("api", _check_current_backend_status(), "Session API key set")


func _on_SaveBackendSetup_pressed() -> void:
	var result = _save_current_backend_setup()
	var mode = Settings.read("backend_mode")
	if result != "ok":
		_set_backend_status(mode, result, "Save options")
		return
	_set_backend_status(mode, _check_current_backend_status(), "Saved options")


func _on_CheckBackendSetup_pressed() -> void:
	_set_backend_status(Settings.read("backend_mode"), _check_current_backend_status(), "Checked")



func _on_ConfirmPythonVenvInstall_pressed() -> void:
	var result = _save_current_backend_setup()
	_pending_confirm_action = "python_venv"
	if result != "ok":
		_set_backend_status(Settings.read("backend_mode"), result, "Create venv save failed")
		return
	_confirm_dialog.dialog_text = _confirmation_text_for_mode(_pending_confirm_action)
	_confirm_dialog.popup_centered(CONFIRM_DIALOG_SIZE)


func _on_ConfirmGuidedInstall_pressed() -> void:
	var result = _save_current_backend_setup()
	_pending_confirm_action = Settings.read("backend_mode")
	if result != "ok":
		_set_backend_status(_pending_confirm_action, result, "Install setup save failed")
		return
	_set_backend_status(_pending_confirm_action, _check_current_backend_status(), "Saved before install")
	_confirm_dialog.dialog_text = _confirmation_text_for_mode(_pending_confirm_action)
	_confirm_dialog.popup_centered(CONFIRM_DIALOG_SIZE)


func _on_ConfirmRunnerTest_pressed() -> void:
	var result = _save_current_backend_setup()
	var mode = Settings.read("backend_mode")
	_pending_confirm_action = "%s_runner_test" % mode
	if result != "ok":
		_set_backend_status(mode, result, "Runner test save failed")
		return
	_set_backend_status(mode, _check_current_backend_status(), "Saved before runner test")
	_confirm_dialog.dialog_text = _confirmation_text_for_mode(_pending_confirm_action)
	_confirm_dialog.popup_centered(CONFIRM_DIALOG_SIZE)


func _update_command_preview_box(mode: String) -> void:
	if _command_preview_box == null:
		return
	if mode == "api":
		var fields = _collect_current_backend_fields()
		var plan = BackendConfig.build_api_setup_plan(fields.get("api_provider", BackendConfig.DEFAULT_API_PROVIDER), fields.get("python_path", ""))
		_command_preview_box.text = "CLI input preview (runs only after confirmation):\n%s" % plan.get("command", "")
	elif mode == "ollama":
		var fields = _collect_current_backend_fields()
		var plan = BackendConfig.build_ollama_setup_plan(fields.get("endpoint", BackendConfig.DEFAULT_OLLAMA_URL), fields.get("model", ""))
		_command_preview_box.text = "CLI input preview (serialized; no shell chain):\n%s\n%s" % [plan.get("command_preview", "manual install/startup required"), plan.get("next_step", "Run Check after each long step.")]
	else:
		_command_preview_box.text = ""


func _confirmation_text_for_mode(mode: String) -> String:
	if mode == "api":
		var fields = _collect_current_backend_fields()
		var plan = BackendConfig.build_api_setup_plan(fields.get("api_provider", BackendConfig.DEFAULT_API_PROVIDER), fields.get("python_path", ""))
		var proof_note = ""
		if _api_setup_proof_only_enabled():
			proof_note = "\n\nProof mode is enabled for this run, so Catapult-Dabubu records the confirmed intent only instead of creating a venv or running pip."
		return "Confirm API / AnyLLM setup for %s.\n\nCLI input (serialized, not shell-chained):\n%s\n\nThis creates/updates the selected venv, then installs AnyLLM/provider packages into it.\nCatapult-Dabubu will not read API secrets or make API calls.%s" % [plan.get("provider_label", "provider"), plan.get("command", "python3 -m pip install --upgrade any-llm-sdk"), proof_note]
	if mode == "ollama":
		var fields = _collect_current_backend_fields()
		var plan = BackendConfig.build_ollama_setup_plan(fields.get("endpoint", BackendConfig.DEFAULT_OLLAMA_URL), fields.get("model", ""))
		var proof_note = "\n\nProof mode is enabled for this run, so Catapult-Dabubu records the confirmed intent only instead of running installers or `ollama pull`." if _external_setup_proof_only_enabled() else ""
		return "Confirm Ollama setup for model %s.\n\nCLI input (serialized, not shell-chained):\n%s\n\nThis may install Ollama or pull a model only after the matching readiness step is available. If Ollama was just installed or is still opening, run Check before pulling the model.\nThe launcher may appear to time out. Wait for Ollama installation to commence.\nCatapult-Dabubu will not pull models before this confirmation.%s" % [plan.get("model", Settings.read("backend_ollama_model")), plan.get("command_preview", "manual install required"), proof_note]
	if mode == "api_runner_test" or mode == "ollama_runner_test":
		var fields = _collect_current_backend_fields()
		var backend = "api" if mode == "api_runner_test" else "ollama"
		var proof_only = _runner_test_proof_only_enabled()
		var plan = BackendConfig.build_backend_runner_test_plan(backend, fields.get("endpoint", ""), fields.get("model", ""), fields.get("python_path", ""), fields.get("api_provider", BackendConfig.DEFAULT_API_PROVIDER), fields.get("api_key_env", BackendConfig.DEFAULT_API_KEY_ENV), proof_only)
		if backend == "api":
			var api_live_note = "\n\nProof mode is enabled, so this invokes C-AOL runner.py with --dry-run: no API call, no secret read, and no spend." if proof_only else "\n\nThis can make one live API self-test call after confirmation using only the named env-var; the key value is not shown or saved."
			return "Confirm API runner test.\n\nC-AOL runner command:\n%s\n\nThis exercises tools/llm_runner/runner.py instead of only launcher metadata.%s" % [plan.get("command_preview", "python runner.py --backend api --dry-run"), api_live_note]
		var ollama_live_note = "\n\nProof mode is enabled, so this invokes C-AOL runner.py with --dry-run: no Ollama request is sent." if proof_only else "\n\nThis can send one local Ollama self-test request to the selected endpoint/model. It will not install Ollama or pull a model."
		return "Confirm Ollama runner test.\n\nC-AOL runner command:\n%s\n\nThis exercises tools/llm_runner/runner.py instead of only launcher metadata.%s" % [plan.get("command_preview", "python runner.py --backend ollama --dry-run"), ollama_live_note]
	if mode == "python_venv":
		var plan = BackendConfig.build_python_venv_setup_plan(_backend_python_path.text if _backend_python_path != null else "")
		var proof_note = "\n\nProof mode is enabled for this run, so Catapult-Dabubu records the venv intent only." if _external_setup_proof_only_enabled() else ""
		var api_note = "\n\nAPI note: this creates the venv only; the main API setup also installs AnyLLM packages; use this only for venv repair to install any-llm-sdk/provider dependencies into that selected venv." if Settings.read("backend_mode") == "api" else ""
		return "Confirm Python venv setup.\n\nPlanned command after approval:\n%s\n\nThis creates or updates the venv path used by C-AOL runner.py.\nIt does not install AnyLLM packages or pull Ollama models.%s%s" % [plan.get("command_preview", "python3 -m venv"), api_note, proof_note]
	return "Confirm before running an external backend setup action. This proof build records the intent only and does not run package managers or download models."

func _api_setup_proof_only_enabled() -> bool:
	return Settings.read("backend_api_setup_proof_only") == true


func _external_setup_proof_only_enabled() -> bool:
	return Settings.read("backend_external_setup_proof_only") == true or Settings.read("backend_api_setup_proof_only") == true


func _runner_test_proof_only_enabled() -> bool:
	return Settings.read("backend_runner_test_proof_only") == true or _external_setup_proof_only_enabled()


func _on_ExternalBackendAction_confirmed() -> void:
	var post_message = "C-AOL backend setup confirmation recorded; no external install/download was performed."
	if _pending_confirm_action == "api":
		var fields = _collect_current_backend_fields()
		var proof_only = _api_setup_proof_only_enabled()
		if not proof_only:
			_set_external_action_progress("api", "Creating/updating venv, then installing AnyLLM/provider packages. Keep Catapult-Dabubu open; this may take a while.")
			yield(get_tree(), "idle_frame")
		var setup_result = BackendConfig.run_api_setup(fields.get("api_provider", BackendConfig.DEFAULT_API_PROVIDER), fields.get("python_path", ""), proof_only)
		var status = setup_result.get("status", "api_setup_unknown")
		if status != "ok" and status != "api_setup_install_ok":
			_set_backend_status("api", status, "API setup command failed" if not proof_only else "API setup intent failed")
			post_message = _api_setup_failure_message(setup_result, proof_only)
			Status.post(post_message)
			return
		var target_path = setup_result.get("plan", {}).get("target_venv_path", "")
		if target_path != "":
			_backend_python_path.text = target_path
			Settings.store("backend_python_path", target_path)
		if setup_result.get("proof_only", false):
			_backend_status.text = "Confirmed API backend setup intent was recorded. Proof mode performed no venv creation, pip install, API call, secret read, or real machine mutation.\n%s" % _backend_status.text
			post_message = "C-AOL API backend setup intent recorded in proof mode; no external install/download was performed."
		else:
			_set_backend_status("api", _check_current_backend_status(), "API setup command finished")
			post_message = "C-AOL API backend setup command finished; venv and AnyLLM/provider packages were handled after confirmation. No API call or API-secret read was performed."
	elif _pending_confirm_action == "ollama":
		var fields = _collect_current_backend_fields()
		var proof_only = _external_setup_proof_only_enabled()
		if not proof_only:
			_set_external_action_progress("ollama", "Running Ollama installer/model command. Keep Catapult-Dabubu open; install or pull can take a while.")
			yield(get_tree(), "idle_frame")
		var setup_result = BackendConfig.run_ollama_setup(fields.get("endpoint", BackendConfig.DEFAULT_OLLAMA_URL), fields.get("model", ""), proof_only)
		var status = setup_result.get("status", "ollama_setup_unknown")
		if status != "ok" and status != "ollama_setup_install_ok":
			_set_backend_status("ollama", status, "Ollama setup command failed" if not proof_only else "Ollama setup intent failed")
			post_message = _ollama_setup_failure_message(setup_result, proof_only)
			Status.post(post_message)
			return
		if setup_result.get("proof_only", false):
			_backend_status.text = "Confirmed Ollama setup intent was recorded. Proof mode performed no installer, model pull, API call, or real machine mutation.\n%s" % _backend_status.text
			post_message = "Ollama setup intent recorded in proof mode; no external install/download was performed."
		else:
			_set_backend_status("ollama", _check_current_backend_status(), "Ollama setup command finished")
			post_message = "Ollama setup command finished after confirmation; installer/CLI/server and model-pull state can be checked separately."
	elif _pending_confirm_action == "api_runner_test" or _pending_confirm_action == "ollama_runner_test":
		var fields = _collect_current_backend_fields()
		var backend = "api" if _pending_confirm_action == "api_runner_test" else "ollama"
		var proof_only = _runner_test_proof_only_enabled()
		var setup_result = BackendConfig.run_backend_runner_test(backend, fields.get("endpoint", ""), fields.get("model", ""), fields.get("python_path", ""), fields.get("api_provider", BackendConfig.DEFAULT_API_PROVIDER), fields.get("api_key_env", BackendConfig.DEFAULT_API_KEY_ENV), proof_only)
		var status = setup_result.get("status", "runner_test_unknown")
		Settings.store("backend_%s_runner_test_status" % backend, status)
		_set_backend_status(backend, _check_current_backend_status(), "Runner test")
		post_message = _runner_test_message(setup_result, backend, proof_only)
		Status.post(post_message, Enums.MSG_INFO if status == "runner_test_ok" else Enums.MSG_ERROR)
		return
	elif _pending_confirm_action == "python_venv":
		var proof_only = _external_setup_proof_only_enabled()
		if not proof_only:
			_set_external_action_progress(Settings.read("backend_mode"), "Creating/updating the runner.py Python venv. Keep Catapult-Dabubu open; this may take a while.")
			yield(get_tree(), "idle_frame")
		var setup_result = BackendConfig.run_python_venv_setup(_backend_python_path.text if _backend_python_path != null else "", proof_only)
		var status = setup_result.get("status", "python_venv_setup_unknown")
		if status != "ok" and status != "python_venv_setup_ok":
			_set_backend_status(Settings.read("backend_mode"), status, "Python venv setup failed" if not proof_only else "Python venv intent failed")
			post_message = "Python venv setup failed." if not proof_only else "Python venv proof intent failed; no venv was created."
			Status.post(post_message)
			return
		var target_path = setup_result.get("plan", {}).get("target_path", "")
		if target_path != "":
			_backend_python_path.text = target_path
			Settings.store("backend_python_path", target_path)
		if setup_result.get("proof_only", false):
			_backend_status.text = "Confirmed Python venv setup intent was recorded. Proof mode created no venv.\n%s" % _backend_status.text
			post_message = "Python venv setup intent recorded in proof mode; no venv was created."
		else:
			_set_backend_status(Settings.read("backend_mode"), _check_current_backend_status(), "Python venv setup finished")
			post_message = "Python venv setup command finished after confirmation; it created/updated the runner.py venv only. run the main API setup if AnyLLM packages still need repair."
	else:
		_backend_status.text = "Confirmed guided setup intent for %s. No external package install, model pull, API call, or real machine mutation was performed by this action.\n%s" % [_pending_confirm_action, _backend_status.text]
	Status.post(post_message)


func _runner_test_message(setup_result: Dictionary, backend: String, proof_only: bool) -> String:
	var status = setup_result.get("status", "runner_test_unknown")
	var summary = str(setup_result.get("output_summary", "")).strip_edges()
	var prefix = "C-AOL %s runner test" % backend.capitalize()
	var boundary = "Proof mode used --dry-run; no API call, secret read, Ollama request, install, or model pull happened." if proof_only else "Confirmed self-test ran no install or model pull; API route may have used the named env-var only."
	var message = "%s %s. %s" % [prefix, "passed" if status == "runner_test_ok" else "failed", boundary]
	if summary != "":
		message += "\nRunner output:\n%s" % summary
	return message


func _set_external_action_progress(mode: String, message: String) -> void:
	_backend_status.text = "Working: %s\nNo API secrets are read. No model pull or package install started before your confirmation." % message
	if mode == "api" and _api_status_lights != null:
		_set_status_rows(_api_status_lights, [
			{"label": "Python / venv", "state": "yellow"},
			{"label": "AnyLLM packages", "state": "yellow"},
			{"label": "API-key env var", "state": "yellow"},
			{"label": "API setup", "state": "yellow"}
		])
	elif mode == "ollama" and _ollama_status_lights != null:
		_set_status_rows(_ollama_status_lights, _ollama_status_rows() + [{"label": "Ollama setup", "state": "yellow"}])


func _api_setup_failure_message(setup_result: Dictionary, proof_only: bool) -> String:
	if proof_only:
		return "C-AOL API backend setup proof intent failed; no external install/download was performed."
	var failed_result = {}
	var results = setup_result.get("results", [])
	if results.size() > 0:
		failed_result = results[results.size() - 1]
	var phase = str(failed_result.get("phase", "venv/package setup"))
	var exit_code = str(failed_result.get("exit_code", setup_result.get("exit_code", "unknown")))
	var detail = str(failed_result.get("output_summary", "")).strip_edges()
	var message = "C-AOL API backend setup failed during %s (exit %s). No API call or API-secret read was performed." % [phase, exit_code]
	if detail != "":
		message += "\nPackage setup output:\n%s" % detail
	return message


func _ollama_setup_failure_message(setup_result: Dictionary, proof_only: bool) -> String:
	if proof_only:
		return "Ollama setup proof intent failed; no external install/download was performed."
	var failed_step = setup_result.get("failed_step", {})
	var purpose = failed_step.get("purpose", "Ollama setup command")
	var command = failed_step.get("command", "")
	var args = ""
	if failed_step.has("args"):
		var arg_strings = []
		for arg in failed_step.get("args", []):
			arg_strings.append(str(arg))
		args = PoolStringArray(arg_strings).join(" ")
	var exit_code = str(failed_step.get("exit_code", "unknown"))
	return "%s failed after confirmation (exit %s): %s %s. Installer/CLI/server/model-pull state is reported separately; use Check after fixing the failed step." % [purpose, exit_code, command, args]
