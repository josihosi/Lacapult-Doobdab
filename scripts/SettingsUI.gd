extends VBoxContainer


var _langs := ["en", "fr", "ru", "zh", "cs", "es", "pl", "tr", "pt", "ko", "ja"]

var _themes := [
	"Godot_3.res",
	"Light.res",
	"Grey.res",
	"Solarized_Dark.res",
	"Solarized_Light.res",
]

var _proxy_options := ["off", "on", "download"]
var _backend_modes := ["api", "ollama", "openvino"]

var _backend_mode_button: OptionButton = null
var _backend_endpoint_label: Label = null
var _backend_endpoint: LineEdit = null
var _backend_model_label: Label = null
var _backend_model: LineEdit = null
var _backend_python_path: LineEdit = null
var _backend_api_key_env: LineEdit = null
var _backend_status: Label = null
var _caol_mod_bridge_status: Label = null

onready var _root = $"/root/Catapult"
onready var _tabs = $"/root/Catapult/Main/Tabs"
onready var _debug_ui = $"/root/Catapult/Main/Tabs/Debug"


func _ready() -> void:
	
	# On the first launch, automatically set UI to system language, if available.
	var sys_locale := TranslationServer.get_locale().substr(0, 2)
	if (Settings.read("launcher_locale") == "") and (sys_locale in TranslationServer.get_loaded_locales()):
		Settings.store("launcher_locale", sys_locale)
	
	var locale = Settings.read("launcher_locale")
	TranslationServer.set_locale(locale)
	var lang_idx := _langs.find(locale)
	if lang_idx >= 0:
		$LauncherLanguage/obtnLanguage.selected = lang_idx
	
	var theme_idx := _themes.find(Settings.read("launcher_theme"))
	if theme_idx >= 0:
		$LauncherTheme/obtnTheme.selected = theme_idx
	
	$ShowGameDesc.pressed = Settings.read("show_game_desc")
	$KeepLauncherOpen.pressed = Settings.read("keep_open_after_starting_game")
	$PrintTips.pressed = Settings.read("print_tips_of_the_day")
	$UpdateToSame.pressed = Settings.read("update_to_same_build_allowed")
	$ShortenNames.pressed = Settings.read("shorten_release_names")
	$AlwaysShowInstalls.pressed = Settings.read("always_show_installs")
	$ShowObsoleteMods.pressed = Settings.read("show_obsolete_mods")
	$UpdateModsWithGame.pressed = Settings.read("update_mods_with_game")

	$KeepCache.pressed = Settings.read("keep_cache")
	$IgnoreCache.pressed = Settings.read("ignore_cache")
	$ShowDebug.pressed = Settings.read("debug_mode")
	$NumReleases/sbNumReleases.value = Settings.read("num_releases_to_request") as int
	$NumPrs/sbNumPRs.value = Settings.read("num_prs_to_request") as int
	
	var proxy_option_idx := _proxy_options.find(Settings.read("proxy_option"))
	if proxy_option_idx >= 0:
		$ProxySettings/obtnProxyOption.selected = proxy_option_idx
	else:
		$ProxySettings/obtnProxyOption.selected = 0
	$ProxySettings/leProxyHost.text = Settings.read("proxy_host")
	$ProxySettings/sbProxyPort.value = Settings.read("proxy_port") as int
	
	$ScaleOverride/cbScaleOverrideEnable.pressed = Settings.read("ui_scale_override_enabled")
	$ScaleOverride/sbScaleOverride.editable = Settings.read("ui_scale_override_enabled")
	$ScaleOverride/sbScaleOverride.value = (Settings.read("ui_scale_override") as float) * 100.0
	_add_backend_setup_controls()
	_add_caol_mod_bridge_status_controls()


func _add_backend_setup_controls() -> void:
	if has_node("BackendSetup"):
		return

	var section = VBoxContainer.new()
	section.name = "BackendSetup"
	section.hint_tooltip = "C-AOL NPC backend setup metadata. API secrets are not stored by Lacapult v0."
	add_child(section)

	var title = Label.new()
	title.text = "C-AOL NPC backend setup"
	section.add_child(title)

	var mode_row = HBoxContainer.new()
	mode_row.name = "BackendMode"
	section.add_child(mode_row)
	var mode_label = Label.new()
	mode_label.text = "Backend"
	mode_label.size_flags_horizontal = SIZE_EXPAND_FILL
	mode_row.add_child(mode_label)
	_backend_mode_button = OptionButton.new()
	_backend_mode_button.rect_min_size = Vector2(180, 0)
	_backend_mode_button.size_flags_horizontal = SIZE_SHRINK_END
	_backend_mode_button.add_item("API backend")
	_backend_mode_button.add_item("Ollama backend")
	_backend_mode_button.add_item("OpenVINO backend")
	_backend_mode_button.connect("item_selected", self, "_on_BackendMode_item_selected")
	mode_row.add_child(_backend_mode_button)

	var endpoint_row = HBoxContainer.new()
	endpoint_row.name = "BackendEndpoint"
	section.add_child(endpoint_row)
	_backend_endpoint_label = Label.new()
	_backend_endpoint_label.text = "Endpoint"
	_backend_endpoint_label.size_flags_horizontal = SIZE_EXPAND_FILL
	endpoint_row.add_child(_backend_endpoint_label)
	_backend_endpoint = LineEdit.new()
	_backend_endpoint.rect_min_size = Vector2(260, 0)
	_backend_endpoint.placeholder_text = "API base URL or http://127.0.0.1:11434"
	_backend_endpoint.size_flags_horizontal = SIZE_EXPAND_FILL
	_backend_endpoint.connect("text_changed", self, "_on_BackendEndpoint_text_changed")
	endpoint_row.add_child(_backend_endpoint)

	var model_row = HBoxContainer.new()
	model_row.name = "BackendModel"
	section.add_child(model_row)
	_backend_model_label = Label.new()
	_backend_model_label.text = "Model"
	_backend_model_label.size_flags_horizontal = SIZE_EXPAND_FILL
	model_row.add_child(_backend_model_label)
	_backend_model = LineEdit.new()
	_backend_model.rect_min_size = Vector2(260, 0)
	_backend_model.placeholder_text = "Optional model name"
	_backend_model.size_flags_horizontal = SIZE_EXPAND_FILL
	_backend_model.connect("text_changed", self, "_on_BackendModel_text_changed")
	model_row.add_child(_backend_model)

	var python_row = HBoxContainer.new()
	python_row.name = "BackendPython"
	section.add_child(python_row)
	var python_label = Label.new()
	python_label.text = "Python / venv"
	python_label.size_flags_horizontal = SIZE_EXPAND_FILL
	python_row.add_child(python_label)
	_backend_python_path = LineEdit.new()
	_backend_python_path.rect_min_size = Vector2(260, 0)
	_backend_python_path.placeholder_text = "Optional Python executable or venv path for C-AOL runner.py"
	_backend_python_path.size_flags_horizontal = SIZE_EXPAND_FILL
	_backend_python_path.connect("text_changed", self, "_on_BackendPython_text_changed")
	python_row.add_child(_backend_python_path)

	var api_env_row = HBoxContainer.new()
	api_env_row.name = "BackendApiKeyEnv"
	section.add_child(api_env_row)
	var api_env_label = Label.new()
	api_env_label.text = "API key env"
	api_env_label.size_flags_horizontal = SIZE_EXPAND_FILL
	api_env_row.add_child(api_env_label)
	_backend_api_key_env = LineEdit.new()
	_backend_api_key_env.rect_min_size = Vector2(260, 0)
	_backend_api_key_env.placeholder_text = "CATA_API_KEY"
	_backend_api_key_env.size_flags_horizontal = SIZE_EXPAND_FILL
	_backend_api_key_env.connect("text_changed", self, "_on_BackendApiKeyEnv_text_changed")
	api_env_row.add_child(_backend_api_key_env)

	_backend_status = Label.new()
	_backend_status.autowrap = true
	section.add_child(_backend_status)

	var save_button = Button.new()
	save_button.text = "Save backend setup metadata"
	save_button.connect("pressed", self, "_on_SaveBackendSetup_pressed")
	section.add_child(save_button)

	# Keep the v0 backend controls above the long inherited settings list so the
	# endpoint/model/status/save path is visible in a normal launcher window.
	move_child(section, 2)

	_refresh_backend_setup_controls()


func _add_caol_mod_bridge_status_controls() -> void:
	if has_node("CaolModBridgeStatus"):
		return

	var section = VBoxContainer.new()
	section.name = "CaolModBridgeStatus"
	section.hint_tooltip = "Read-only C-AOL packaged-mod compatibility and summarizer bridge status."
	add_child(section)

	var title = Label.new()
	title.text = "C-AOL packaged mod compatibility"
	section.add_child(title)

	_caol_mod_bridge_status = Label.new()
	_caol_mod_bridge_status.autowrap = true
	section.add_child(_caol_mod_bridge_status)

	var dry_run_button = Button.new()
	dry_run_button.text = "Summarizer dry-run status"
	dry_run_button.hint_tooltip = "Status-only prompt: no backend call, no generated pack, no apply, no mod enable."
	dry_run_button.connect("pressed", self, "_on_CaolSummarizerDryRun_pressed")
	section.add_child(dry_run_button)

	var summary_roots = Label.new()
	summary_roots.autowrap = true
	summary_roots.text = "C-AOL summary roots stay native: future generated packs belong in active mod roots under npcs/Backgrounds/Summaries_short or npcs/Backgrounds/Summaries_extra. Lacapult v0 does not apply generated summary packs or enable mods from this status block."
	section.add_child(summary_roots)

	var report_reference = Label.new()
	report_reference.autowrap = true
	report_reference.text = "Full generated proof report: .proof-cache/caol-mod-bridge/caol_mod_summarizer_bridge_report.md. Regenerate from a source checkout with python3 tools/prove_caol_mod_inventory.py; canon summary: doc/caol-mod-compatibility-summary.md."
	section.add_child(report_reference)

	# Keep this read-only status surface near the backend controls, before the long
	# inherited settings list. The button is dry-run/status-only; applying/generated
	# summary packs is a later explicit flow.
	move_child(section, 3)
	_refresh_caol_mod_bridge_status()


func _refresh_caol_mod_bridge_status() -> void:
	if _caol_mod_bridge_status == null:
		return
	var mods = get_node_or_null("/root/Mods")
	if mods == null or not mods.has_method("get_caol_mod_summarizer_overview"):
		_caol_mod_bridge_status.text = "Read-only C-AOL mod/Summarizer status unavailable: Mods autoload is not ready."
		return
	var overview = mods.get_caol_mod_summarizer_overview()
	_caol_mod_bridge_status.text = overview.get("status_text", "Read-only C-AOL mod/Summarizer status unavailable.")


func _on_CaolSummarizerDryRun_pressed() -> void:
	var mods = get_node_or_null("/root/Mods")
	if mods == null or not mods.has_method("get_caol_summarizer_dry_run"):
		_caol_mod_bridge_status.text = "Summarizer dry-run unavailable: Mods autoload is not ready."
		return
	var dry_run = mods.get_caol_summarizer_dry_run()
	_caol_mod_bridge_status.text = dry_run.get("message", "Summarizer dry-run unavailable.")
	Status.post("C-AOL Summarizer dry-run/status-only check complete; no backend call, pack apply, or save mutation was attempted.")


func _refresh_backend_setup_controls() -> void:
	if _backend_mode_button == null:
		return
	var mode = Settings.read("backend_mode")
	var mode_idx = _backend_modes.find(mode)
	if mode_idx < 0:
		mode_idx = 0
		mode = _backend_modes[mode_idx]
	_backend_mode_button.select(mode_idx)

	if mode == "api":
		_backend_endpoint_label.text = "API base URL"
		_backend_model_label.text = "API model"
		_backend_endpoint.placeholder_text = "Optional; C-AOL currently uses provider/model/env key"
		_backend_model.placeholder_text = "gpt-4.1-mini"
		_backend_endpoint.text = Settings.read("backend_api_endpoint")
		_backend_model.text = Settings.read("backend_api_model")
		_backend_api_key_env.get_parent().visible = true
	elif mode == "ollama":
		_backend_endpoint_label.text = "Ollama URL"
		_backend_model_label.text = "Ollama model"
		_backend_endpoint.placeholder_text = "http://127.0.0.1:11434"
		_backend_model.placeholder_text = "qwen2.5:3b, mistral, llama..."
		_backend_endpoint.text = Settings.read("backend_ollama_endpoint")
		_backend_model.text = Settings.read("backend_ollama_model")
		_backend_api_key_env.get_parent().visible = false
	else:
		_backend_endpoint_label.text = "Model dir"
		_backend_model_label.text = "Device"
		_backend_endpoint.placeholder_text = "OpenVINO model directory"
		_backend_model.placeholder_text = "AUTO, CPU, GPU, NPU"
		_backend_endpoint.text = Settings.read("backend_openvino_model_dir")
		_backend_model.text = Settings.read("backend_openvino_device")
		_backend_api_key_env.get_parent().visible = false

	_backend_endpoint.editable = true
	_backend_model.editable = true
	_backend_python_path.text = Settings.read("backend_python_path")
	_backend_api_key_env.text = Settings.read("backend_api_key_env")

	var status = "Backend status: unknown"
	for backend in BackendConfig.get_supported_backends():
		if backend.get("id", "") == mode:
			status = "%s status: %s" % [backend.get("label", mode), backend.get("status", "unknown")]
			status += "\nSetup: %s" % backend.get("guidance", BackendConfig.get_backend_guidance(mode))
			break
	if mode == "api":
		status += "\nProvider intent: %s. API secrets stay in the environment; Lacapult stores only the env-var name." % Settings.read("backend_api_provider")
	elif mode == "ollama":
		status += "\nNo model pull is attempted. C-AOL still launches tools/llm_runner/runner.py through Python."
	else:
		status += "\nOpenVINO is Windows-first for Lacapult v0. Runtime/model install is not automated; this is detection plus config only."
	_backend_status.text = status
	_refresh_caol_mod_bridge_status()


func _store_backend_field(setting_prefix: String, value: String) -> void:
	var mode = Settings.read("backend_mode")
	if mode == "api" or mode == "ollama":
		Settings.store("backend_%s_%s" % [mode, setting_prefix], value)
	elif mode == "openvino":
		if setting_prefix == "endpoint":
			Settings.store("backend_openvino_model_dir", value)
		elif setting_prefix == "model":
			Settings.store("backend_openvino_device", value)


func _on_BackendMode_item_selected(index: int) -> void:
	Settings.store("backend_mode", _backend_modes[index])
	_refresh_backend_setup_controls()


func _on_BackendEndpoint_text_changed(new_text: String) -> void:
	_store_backend_field("endpoint", new_text)


func _on_BackendModel_text_changed(new_text: String) -> void:
	_store_backend_field("model", new_text)


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
	var openvino_model_dir = endpoint if mode == "openvino" else Settings.read("backend_openvino_model_dir")
	var openvino_device = model if mode == "openvino" else Settings.read("backend_openvino_device")
	var result = BackendConfig.write_launcher_backend_config(mode, endpoint, model, python_path, api_provider, api_key_env, openvino_model_dir, openvino_device)
	_backend_status.text = "Backend setup save result: %s" % result


func _on_obtnLanguage_item_selected(index: int) -> void:
	
	var locale = _langs[index]
	Settings.store("launcher_locale", locale)
	TranslationServer.set_locale(locale)
	_root.assign_localized_text()


func _on_obtnTheme_item_selected(index: int) -> void:
	
	Settings.store("launcher_theme", _themes[index])
	_root.load_ui_theme(_themes[index])


func _on_ShowGameDesc_toggled(button_pressed: bool) -> void:
	
	Settings.store("show_game_desc", button_pressed)
	$"../../GameInfo".visible = button_pressed


func _on_KeepLauncherOpen_toggled(button_pressed: bool) -> void:
	
	Settings.store("keep_open_after_starting_game", button_pressed)


func _on_PrintTips_toggled(button_pressed: bool) -> void:
	
	Settings.store("print_tips_of_the_day", button_pressed)


func _on_UpdateToSame_toggled(button_pressed: bool) -> void:
	
	Settings.store("update_to_same_build_allowed", button_pressed)


func _on_ShortenNames_toggled(button_pressed: bool) -> void:
	
	Settings.store("shorten_release_names", button_pressed)


func _on_AlwaysShowInstalls_toggled(button_pressed: bool) -> void:
	
	Settings.store("always_show_installs", button_pressed)


func _on_ShowObsoleteMods_toggled(button_pressed: bool) -> void:

	Settings.store("show_obsolete_mods", button_pressed)


func _on_UpdateModsWithGame_toggled(button_pressed: bool) -> void:

	Settings.store("update_mods_with_game", button_pressed)


func _on_KeepCache_toggled(button_pressed: bool) -> void:
	
	Settings.store("keep_cache", button_pressed)

func _on_IgnoreCache_toggled(button_pressed: bool) -> void:
	
	Settings.store("ignore_cache", button_pressed)

func _on_ShowDebug_toggled(button_pressed: bool) -> void:
	
	Settings.store("debug_mode", button_pressed)
	
	if button_pressed:
		if _debug_ui.get_parent() != _tabs:
			_tabs.call_deferred("add_child", _debug_ui)
	elif _debug_ui.get_parent() == _tabs:
		_tabs.call_deferred("remove_child", _debug_ui)


func _on_sbNumReleases_value_changed(value: float) -> void:
	
	Settings.store("num_releases_to_request", str(value))

func _on_sbNumPRs_value_changed(value: float) -> void:
	
	Settings.store("num_prs_to_request", str(value))


func _on_obtnProxyOption_item_selected(index):
	Settings.store("proxy_option", _proxy_options[index])

func _on_leProxyHost_text_changed(new_text):
	Settings.store("proxy_host", new_text)

func _on_sbProxyPort_value_changed(value):
	Settings.store("proxy_port", value)


func _on_cbScaleOverrideEnable_toggled(button_pressed: bool) -> void:
	
	Settings.store("ui_scale_override_enabled", button_pressed)
	$ScaleOverride/sbScaleOverride.editable = button_pressed
	
	if button_pressed:
		Geom.scale = Settings.read("ui_scale_override")
	else:
		Geom.scale = Geom.calculate_scale_from_dpi()
	
	_root.theme.apply_scale(Geom.scale)


func _on_sbScaleOverride_value_changed(value: float) -> void:
	
	if Settings.read("ui_scale_override_enabled"):
		Settings.store("ui_scale_override", value / 100.0)
		Geom.scale = value / 100.0
		_root.theme.apply_scale(Geom.scale)


