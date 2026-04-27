extends SceneTree

# Headless inspection for Package 5: Lacapult window chrome investigation.
# Evidence class: Godot scene/project inspection only. It does not prove Windows
# appearance and does not mutate real user config when run with isolated HOME.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var borderless = ProjectSettings.get_setting("display/window/size/borderless")
	var allow_hidpi = ProjectSettings.get_setting("display/window/dpi/allow_hidpi")
	var theme_hidpi = ProjectSettings.get_setting("gui/theme/use_hidpi")
	_require(borderless == true, "project is no longer borderless; update chrome investigation canon")

	var scene = load("res://scenes/Catapult.tscn").instance()
	var title_bar = scene.get_node_or_null("TitleBar")
	var main = scene.get_node_or_null("Main")
	_require(title_bar != null, "Catapult scene has no TitleBar node")
	_require(title_bar.filename == "res://scenes/CustomTitleBar.tscn", "TitleBar is not the custom titlebar scene")
	_require(main != null, "Catapult scene has no Main node")

	var minimize = title_bar.get_node_or_null("MarginContainer/HBoxContainer/MinimizeButton")
	var maximize = title_bar.get_node_or_null("MarginContainer/HBoxContainer/MaximizeButton")
	var close = title_bar.get_node_or_null("MarginContainer/HBoxContainer/CloseButton")
	_require(minimize != null and maximize != null and close != null, "custom titlebar control buttons missing")
	_require(minimize is TextureButton and maximize is TextureButton and close is TextureButton, "custom titlebar controls are not TextureButtons")

	print("Lacapult window chrome inspection passed")
	print("  Root-cause class: custom scene chrome, not native OS chrome")
	print("  Project: borderless=%s allow_hidpi=%s theme_hidpi=%s" % [str(borderless), str(allow_hidpi), str(theme_hidpi)])
	print("  Scene: Catapult/TitleBar instances %s; Main margin_top=%s" % [title_bar.filename, str(main.margin_top)])
	print("  Custom controls: Minimize=%s Maximize=%s Close=%s expand=%s stretch=%s" % [str(minimize.rect_min_size), str(maximize.rect_min_size), str(close.rect_min_size), str(close.expand), str(close.stretch_mode)])
	print("  Local evidence boundary: this is macOS/Godot scene inspection only; Windows visual confirmation remains human/device-dependent")
	scene.free()
	quit(0)


func _require(condition: bool, message: String) -> void:
	if not condition:
		printerr("window chrome inspection failed: " + message)
		quit(1)
