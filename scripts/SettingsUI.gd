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
var _backend_endpoint: LineEdit = null
var _backend_model: LineEdit = null
var _backend_status: Label = null

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
	var endpoint_label = Label.new()
	endpoint_label.text = "Endpoint"
	endpoint_label.size_flags_horizontal = SIZE_EXPAND_FILL
	endpoint_row.add_child(endpoint_label)
	_backend_endpoint = LineEdit.new()
	_backend_endpoint.rect_min_size = Vector2(260, 0)
	_backend_endpoint.placeholder_text = "API base URL or http://127.0.0.1:11434"
	_backend_endpoint.size_flags_horizontal = SIZE_EXPAND_FILL
	_backend_endpoint.connect("text_changed", self, "_on_BackendEndpoint_text_changed")
	endpoint_row.add_child(_backend_endpoint)

	var model_row = HBoxContainer.new()
	model_row.name = "BackendModel"
	section.add_child(model_row)
	var model_label = Label.new()
	model_label.text = "Model"
	model_label.size_flags_horizontal = SIZE_EXPAND_FILL
	model_row.add_child(model_label)
	_backend_model = LineEdit.new()
	_backend_model.rect_min_size = Vector2(260, 0)
	_backend_model.placeholder_text = "Optional model name"
	_backend_model.size_flags_horizontal = SIZE_EXPAND_FILL
	_backend_model.connect("text_changed", self, "_on_BackendModel_text_changed")
	model_row.add_child(_backend_model)

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


func _refresh_backend_setup_controls() -> void:
	if _backend_mode_button == null:
		return
	var mode = Settings.read("backend_mode")
	var mode_idx = _backend_modes.find(mode)
	if mode_idx < 0:
		mode_idx = 0
		mode = _backend_modes[mode_idx]
	_backend_mode_button.select(mode_idx)

	var endpoint_setting = "backend_api_endpoint" if mode == "api" else "backend_ollama_endpoint"
	var model_setting = "backend_api_model" if mode == "api" else "backend_ollama_model"
	_backend_endpoint.text = "" if mode == "openvino" else Settings.read(endpoint_setting)
	_backend_model.text = "" if mode == "openvino" else Settings.read(model_setting)
	_backend_endpoint.editable = mode != "openvino"
	_backend_model.editable = mode != "openvino"

	var status = "OpenVINO is selectable in v0; Lacapult records the choice but does not install runtimes or pull models yet."
	if mode == "api":
		status = "API mode saves endpoint/model metadata only; Lacapult v0 never stores API keys."
	elif mode == "ollama":
		for backend in BackendConfig.get_supported_backends():
			if backend.get("id", "") == "ollama":
				status = "Ollama status: %s" % backend.get("status", "unknown")
	_backend_status.text = status


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


func _on_SaveBackendSetup_pressed() -> void:
	var mode = Settings.read("backend_mode")
	var endpoint = "" if _backend_endpoint == null else _backend_endpoint.text
	var model = "" if _backend_model == null else _backend_model.text
	var result = BackendConfig.write_launcher_backend_config(mode, endpoint, model)
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


