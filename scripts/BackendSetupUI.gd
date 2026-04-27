extends VBoxContainer


const OLLAMA_MODEL_MISTRAL = "mistral-v0.3"
const OLLAMA_MODEL_NEMOTRON = "nemotron-9b"

var _backend_modes := ["api", "ollama"]
var _pending_confirm_action := ""

var _backend_mode_button: OptionButton = null
var _intro: Label = null
var _guidance: Label = null
var _backend_endpoint_label: Label = null
var _backend_endpoint: LineEdit = null
var _backend_model_label: Label = null
var _backend_model: LineEdit = null
var _ollama_model_choice_label: Label = null
var _ollama_model_choice: OptionButton = null
var _hardware_hint: Label = null
var _backend_python_path: LineEdit = null
var _backend_api_key_env: LineEdit = null
var _backend_status: Label = null
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
	_intro.text = "Choose how C-AOL should reach an LLM backend"
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
	_ollama_model_choice.add_item(OLLAMA_MODEL_MISTRAL)
	_ollama_model_choice.add_item(OLLAMA_MODEL_NEMOTRON)
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

	_backend_status = Label.new()
	_backend_status.autowrap = true
	add_child(_backend_status)

	var button_row = HBoxContainer.new()
	button_row.name = "BackendActions"
	add_child(button_row)
	var save_button = Button.new()
	save_button.text = "Save C-AOL backend setup"
	save_button.connect("pressed", self, "_on_SaveBackendSetup_pressed")
	button_row.add_child(save_button)
	var install_button = Button.new()
	install_button.text = "Confirm guided install step"
	install_button.hint_tooltip = "Opens a confirmation prompt first; automated tests do not install packages or pull models."
	install_button.connect("pressed", self, "_on_ConfirmGuidedInstall_pressed")
	button_row.add_child(install_button)

	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.name = "ConfirmExternalBackendAction"
	_confirm_dialog.window_title = "Confirm external setup action"
	_confirm_dialog.dialog_text = "Lacapult will ask before external package installs or model downloads. This proof build records the confirmed intent only and does not run package managers or pull models automatically."
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
	if mode == "api":
		_backend_endpoint_label.text = "API base URL"
		_backend_model_label.text = "API model"
		_backend_endpoint.placeholder_text = "Optional API base URL"
		_backend_model.placeholder_text = "gpt-4.1-mini or another AnyLLM model"
		_backend_endpoint.text = Settings.read("backend_api_endpoint")
		_backend_model.text = Settings.read("backend_api_model")
		_backend_api_key_env.get_parent().visible = true
		choice_row.visible = false
		_guidance.text = "Use an API provider through AnyLLM. Recent C-AOL logs show many calls around 300-400 tokens, with variation by prompt/provider/model."
	elif mode == "ollama":
		_backend_endpoint_label.text = "Ollama URL"
		_backend_model_label.text = "Ollama model tag"
		_backend_endpoint.placeholder_text = BackendConfig.DEFAULT_OLLAMA_URL
		_backend_model.placeholder_text = "%s or %s" % [OLLAMA_MODEL_MISTRAL, OLLAMA_MODEL_NEMOTRON]
		_backend_endpoint.text = Settings.read("backend_ollama_endpoint")
		_backend_model.text = Settings.read("backend_ollama_model")
		_backend_api_key_env.get_parent().visible = false
		choice_row.visible = true
		_select_ollama_choice(Settings.read("backend_ollama_model"))
		_guidance.text = "Use ollama for local LLM utilization."

	_backend_python_path.text = Settings.read("backend_python_path")
	_backend_api_key_env.text = Settings.read("backend_api_key_env")
	_hardware_hint.text = ""

	var status = "Backend status: unknown"
	for backend in BackendConfig.get_supported_backends():
		if backend.get("id", "") == mode:
			status = "%s readiness: %s" % [backend.get("label", mode), _human_readiness(backend.get("status", "unknown"))]
			break
	if mode == "api":
		status += "\nAPI secrets stay in the environment; Lacapult stores only the env-var name."
	elif mode == "ollama":
		status += "\nNo model pull is attempted until the player confirms the action."
	_backend_status.text = status


func _read_safe_hardware_signals() -> Dictionary:
	var signals = {"memory_mb": 0, "processor_count": OS.get_processor_count()}
	if OS.has_method("get_static_memory_usage"):
		signals["memory_note"] = "Runtime memory signal only; exact system RAM may be unavailable in Godot."
	return signals


func _build_ollama_hardware_recommendation_text(signals: Dictionary) -> String:
	var memory_mb = int(signals.get("memory_mb", 0))
	if memory_mb >= 24000:
		return "Hardware recommendation: this machine appears to have enough memory for the larger %s path, but %s remains available. Final model choice is yours." % [OLLAMA_MODEL_NEMOTRON, OLLAMA_MODEL_MISTRAL]
	return "Hardware recommendation: if memory/GPU capacity is unknown or modest, start with %s. Choose %s manually if you know the machine has enough headroom. Lacapult will not pull either model without confirmation." % [OLLAMA_MODEL_MISTRAL, OLLAMA_MODEL_NEMOTRON]


func _human_readiness(raw_status: String) -> String:
	if raw_status.find("api_python_missing") >= 0:
		return "Python was not found; choose a Python or virtual environment before using API mode."
	if raw_status.find("any_llm_missing") >= 0:
		return "Python is available, but AnyLLM is not installed in the selected environment."
	if raw_status.find("api_python_ready_any_llm_import_ok") >= 0:
		return "Python and AnyLLM are available. Check provider, model, and API-key environment variable before launching C-AOL."
	if raw_status.find("ollama_command_missing") >= 0:
		return "Ollama was not found on PATH. Install or choose a manual local setup before using this path."
	if raw_status.find("ollama_command_present_server_unreachable") >= 0:
		return "Ollama is installed, but the local server did not answer. Start Ollama and check again."
	if raw_status.find("ollama_command_present_server_running_model_present") >= 0:
		return "Ollama is running and the selected model appears in the local model list."
	if raw_status.find("ollama_command_present_server_running_model_missing") >= 0:
		return "Ollama is running, but the selected model is not installed. Lacapult will ask before any model pull."
	if raw_status.find("ollama_command_present_server_running_model_not_selected") >= 0:
		return "Ollama is running. Choose a model before saving the final setup."
	return "Readiness could not be summarized yet; save the setup and check the guidance above."


func _select_ollama_choice(model_name: String) -> void:
	if _ollama_model_choice == null:
		return
	var idx = 0
	if model_name == OLLAMA_MODEL_NEMOTRON:
		idx = 1
	_ollama_model_choice.select(idx)
	if model_name == "":
		Settings.store("backend_ollama_model", OLLAMA_MODEL_MISTRAL)
		_backend_model.text = OLLAMA_MODEL_MISTRAL


func _store_backend_field(setting_prefix: String, value: String) -> void:
	var mode = Settings.read("backend_mode")
	if mode == "api" or mode == "ollama":
		Settings.store("backend_%s_%s" % [mode, setting_prefix], value)


func _on_BackendMode_item_selected(index: int) -> void:
	Settings.store("backend_mode", _backend_modes[index])
	_refresh_backend_setup_controls()


func _on_BackendEndpoint_text_changed(new_text: String) -> void:
	_store_backend_field("endpoint", new_text)


func _on_BackendModel_text_changed(new_text: String) -> void:
	_store_backend_field("model", new_text)


func _on_OllamaModelChoice_item_selected(index: int) -> void:
	var model = OLLAMA_MODEL_MISTRAL if index == 0 else OLLAMA_MODEL_NEMOTRON
	Settings.store("backend_ollama_model", model)
	_backend_model.text = model
	_refresh_backend_setup_controls()


func _on_BackendPython_text_changed(new_text: String) -> void:
	Settings.store("backend_python_path", new_text)


func _on_BackendApiKeyEnv_text_changed(new_text: String) -> void:
	Settings.store("backend_api_key_env", new_text)


func _on_SaveBackendSetup_pressed() -> void:
	var mode = Settings.read("backend_mode")
	var endpoint = "" if _backend_endpoint == null else _backend_endpoint.text
	var model = "" if _backend_model == null else _backend_model.text
	var python_path = "" if _backend_python_path == null else _backend_python_path.text
	var api_provider = Settings.read("backend_api_provider")
	var api_key_env = "" if _backend_api_key_env == null else _backend_api_key_env.text
	var openvino_model_dir = Settings.read("backend_openvino_model_dir")
	var openvino_device = Settings.read("backend_openvino_device")
	var result = BackendConfig.write_launcher_backend_config(mode, endpoint, model, python_path, api_provider, api_key_env, openvino_model_dir, openvino_device)
	_refresh_backend_setup_controls()
	_backend_status.text = "Backend setup save result: %s\n%s" % [result, _backend_status.text]


func _on_ConfirmGuidedInstall_pressed() -> void:
	_pending_confirm_action = Settings.read("backend_mode")
	_confirm_dialog.dialog_text = _confirmation_text_for_mode(_pending_confirm_action)
	_confirm_dialog.popup_centered()


func _confirmation_text_for_mode(mode: String) -> String:
	if mode == "api":
		return "Confirm before installing AnyLLM/Python packages. This proof build records the intent only and does not run pip or read API secrets."
	if mode == "ollama":
		return "Confirm before installing Ollama or pulling model %s. This proof build records the intent only and does not download models." % Settings.read("backend_ollama_model")
	return "Confirm before running an external backend setup action. This proof build records the intent only and does not run package managers or download models."


func _on_ExternalBackendAction_confirmed() -> void:
	_backend_status.text = "Confirmed guided setup intent for %s. No external package install, model pull, API call, or real machine mutation was performed by this action.\n%s" % [_pending_confirm_action, _backend_status.text]
	Status.post("C-AOL backend setup confirmation recorded; no external install/download was performed.")
