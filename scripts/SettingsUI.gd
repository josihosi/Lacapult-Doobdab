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
var _caol_mod_bridge_status: Label = null
var _caol_summarizer_world_select: OptionButton = null
var _caol_summarizer_world_names := []
var _caol_summarizer_mod_select: OptionButton = null
var _caol_summarizer_selected_mod_ids := []

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
	_add_caol_mod_bridge_status_controls()


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

	var world_label = Label.new()
	world_label.text = "Summarizer target world"
	section.add_child(world_label)

	_caol_summarizer_world_select = OptionButton.new()
	_caol_summarizer_world_select.hint_tooltip = "Choose the C-AOL world whose mods.json should be previewed before any generated summary companion pack is applied."
	_caol_summarizer_world_select.connect("item_selected", self, "_on_CaolSummarizerWorld_selected")
	section.add_child(_caol_summarizer_world_select)

	var chooser_label = Label.new()
	chooser_label.text = "Summarizer target mod"
	section.add_child(chooser_label)

	_caol_summarizer_mod_select = OptionButton.new()
	_caol_summarizer_mod_select.hint_tooltip = "Choose one enabled contextual mod from the current world before previewing or confirming a generated C-AOL summary companion pack."
	section.add_child(_caol_summarizer_mod_select)

	var dry_run_button = Button.new()
	dry_run_button.text = "Summarizer dry-run status"
	dry_run_button.hint_tooltip = "Status-only prompt: no backend call, no generated pack, no apply, no mod enable."
	dry_run_button.connect("pressed", self, "_on_CaolSummarizerDryRun_pressed")
	section.add_child(dry_run_button)

	var preview_button = Button.new()
	preview_button.text = "Preview Summarizer apply plan"
	preview_button.hint_tooltip = "Shows the eligible mod/world, backend gate, companion pack paths, backups, and confirmation requirement before any real write."
	preview_button.connect("pressed", self, "_on_CaolSummarizerApplyPreview_pressed")
	section.add_child(preview_button)

	var apply_button = Button.new()
	apply_button.text = "Confirm backend generation and apply Summary pack"
	apply_button.hint_tooltip = "Explicit confirmation: if backend/world gates pass, asks the selected backend to generate C-AOL summary entries, then writes the companion pack with backup/rollback visibility."
	apply_button.connect("pressed", self, "_on_CaolSummarizerApplyConfirmed_pressed")
	section.add_child(apply_button)

	var summary_roots = Label.new()
	summary_roots.autowrap = true
	summary_roots.text = "C-AOL summary roots stay native: generated companion packs belong in active mod roots under npcs/Backgrounds/Summaries_short or npcs/Backgrounds/Summaries_extra. The preview button shows the real apply/backup plan; the confirm button is the explicit confirmation step before a pack write or mods.json change, and backend/package/model actions remain gated."
	section.add_child(summary_roots)

	var report_reference = Label.new()
	report_reference.autowrap = true
	report_reference.text = "Full generated proof report: .proof-cache/caol-mod-bridge/caol_mod_summarizer_bridge_report.md. Regenerate from a source checkout with python3 tools/prove_caol_mod_inventory.py; canon summary: doc/caol-mod-compatibility-summary.md."
	section.add_child(report_reference)

	# Keep this read-only status surface before the long inherited settings list.
	# The dry-run remains status-only; the preview button exposes the Slice 6
	# confirmation-gated write plan without performing the write here.
	move_child(section, 3)
	_refresh_caol_mod_bridge_status()


func _refresh_caol_mod_bridge_status() -> void:
	if _caol_mod_bridge_status == null:
		return
	var mods = get_node_or_null("/root/Mods")
	if mods == null or not mods.has_method("get_caol_mod_summarizer_overview"):
		_caol_mod_bridge_status.text = "Read-only C-AOL mod/Summarizer status unavailable: Mods autoload is not ready."
		_populate_caol_summarizer_target_selector({})
		return
	if mods.has_method("get_caol_summarizer_world_names"):
		_populate_caol_summarizer_world_selector(mods.get_caol_summarizer_world_names())
	var overview = mods.get_caol_mod_summarizer_overview(_selected_caol_summarizer_world_name())
	_caol_mod_bridge_status.text = overview.get("status_text", "Read-only C-AOL mod/Summarizer status unavailable.")
	_populate_caol_summarizer_target_selector(overview)


func _populate_caol_summarizer_world_selector(worlds: Array) -> void:
	if _caol_summarizer_world_select == null:
		return
	var previous = _selected_caol_summarizer_world_name()
	_caol_summarizer_world_names.clear()
	_caol_summarizer_world_select.clear()
	if worlds.empty():
		_caol_summarizer_world_select.add_item("No readable world mods.json found", 0)
		_caol_summarizer_world_select.disabled = true
		return
	_caol_summarizer_world_select.disabled = false
	var selected_index = 0
	for world in worlds:
		var world_name = str(world)
		_caol_summarizer_world_names.append(world_name)
		_caol_summarizer_world_select.add_item(world_name, _caol_summarizer_world_names.size() - 1)
		if world_name == previous:
			selected_index = _caol_summarizer_world_names.size() - 1
	_caol_summarizer_world_select.select(selected_index)


func _selected_caol_summarizer_world_name() -> String:
	if _caol_summarizer_world_select == null or _caol_summarizer_world_select.disabled:
		return ""
	var index = _caol_summarizer_world_select.get_selected_id()
	if index < 0 or index >= _caol_summarizer_world_names.size():
		index = _caol_summarizer_world_select.selected
	if index < 0 or index >= _caol_summarizer_world_names.size():
		return ""
	return str(_caol_summarizer_world_names[index])


func _populate_caol_summarizer_target_selector(overview: Dictionary) -> void:
	if _caol_summarizer_mod_select == null:
		return
	var previous_id = _selected_caol_summarizer_mod_id()
	_caol_summarizer_selected_mod_ids.clear()
	_caol_summarizer_mod_select.clear()
	var candidates = overview.get("summarizer_candidates", [])
	if typeof(candidates) != TYPE_ARRAY or candidates.empty():
		_caol_summarizer_mod_select.add_item("No eligible enabled contextual mod needs summaries", 0)
		_caol_summarizer_mod_select.disabled = true
		return
	_caol_summarizer_mod_select.disabled = false
	var selected_index = 0
	for candidate in candidates:
		var mod_id = str(candidate.get("id", ""))
		var label = "%s (%s) - %s" % [candidate.get("name", mod_id), mod_id, candidate.get("summary_status", "summary-unknown")]
		_caol_summarizer_selected_mod_ids.append(mod_id)
		_caol_summarizer_mod_select.add_item(label, _caol_summarizer_selected_mod_ids.size() - 1)
		if mod_id == previous_id:
			selected_index = _caol_summarizer_selected_mod_ids.size() - 1
	_caol_summarizer_mod_select.select(selected_index)


func _selected_caol_summarizer_mod_id() -> String:
	if _caol_summarizer_mod_select == null or _caol_summarizer_mod_select.disabled:
		return ""
	var index = _caol_summarizer_mod_select.get_selected_id()
	if index < 0 or index >= _caol_summarizer_selected_mod_ids.size():
		index = _caol_summarizer_mod_select.selected
	if index < 0 or index >= _caol_summarizer_selected_mod_ids.size():
		return ""
	return str(_caol_summarizer_selected_mod_ids[index])


func _on_CaolSummarizerWorld_selected(_index: int) -> void:
	_refresh_caol_mod_bridge_status()


func _on_CaolSummarizerDryRun_pressed() -> void:
	var mods = get_node_or_null("/root/Mods")
	if mods == null or not mods.has_method("get_caol_summarizer_dry_run"):
		_caol_mod_bridge_status.text = "Summarizer dry-run unavailable: Mods autoload is not ready."
		return
	var dry_run = mods.get_caol_summarizer_dry_run(_selected_caol_summarizer_world_name())
	_caol_mod_bridge_status.text = dry_run.get("message", "Summarizer dry-run unavailable.")
	Status.post("C-AOL Summarizer dry-run/status-only check complete; no backend call, pack apply, or save mutation was attempted.")


func _on_CaolSummarizerApplyPreview_pressed() -> void:
	var mods = get_node_or_null("/root/Mods")
	if mods == null or not mods.has_method("get_caol_summarizer_apply_preview"):
		_caol_mod_bridge_status.text = "Summarizer apply preview unavailable: Mods autoload is not ready."
		return
	var selected_world = _selected_caol_summarizer_world_name()
	var selected_mod_id = _selected_caol_summarizer_mod_id()
	var preview = mods.get_caol_summarizer_apply_preview(selected_world, selected_mod_id)
	_caol_mod_bridge_status.text = preview.get("message", "Summarizer apply preview unavailable.")
	Status.post("C-AOL Summarizer apply preview built for %s; explicit confirmation is still required before any backend call, generated pack, or save mutation." % (selected_mod_id if selected_mod_id != "" else "the current eligible mod"))


func _on_CaolSummarizerApplyConfirmed_pressed() -> void:
	var mods = get_node_or_null("/root/Mods")
	if mods == null or not mods.has_method("generate_and_apply_caol_summarizer_pack"):
		_caol_mod_bridge_status.text = "Summarizer apply unavailable: Mods autoload is not ready."
		return
	var selected_world = _selected_caol_summarizer_world_name()
	var selected_mod_id = _selected_caol_summarizer_mod_id()
	var result = mods.generate_and_apply_caol_summarizer_pack(selected_world, selected_mod_id, true, true)
	_caol_mod_bridge_status.text = result.get("message", "Summarizer apply unavailable.")
	if result.get("applied", false):
		Status.post("C-AOL Summarizer backend generation/apply completed with backup/rollback visibility.")
	else:
		Status.post("C-AOL Summarizer apply blocked before mutation; review the visible reason.", Enums.MSG_ERROR)


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


