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
	var resizable = ProjectSettings.get_setting("display/window/size/resizable")
	var width = ProjectSettings.get_setting("display/window/size/width")
	var height = ProjectSettings.get_setting("display/window/size/height")
	_require(borderless == false, "project should use native OS chrome for v1 retest")
	_require(resizable == true, "project should be native-resizable for v1 retest")
	_require(width >= 1040 and height >= 900, "default window was not enlarged for v1 retest")

	var scene = load("res://scenes/Catapult.tscn").instance()
	var title_bar = scene.get_node_or_null("TitleBar")
	var main = scene.get_node_or_null("Main")
	_require(title_bar != null, "Catapult scene has no TitleBar node")
	_require(title_bar.filename == "res://scenes/CustomTitleBar.tscn", "TitleBar compatibility node is not the custom titlebar scene")
	_require(main != null, "Catapult scene has no Main node")
	_require(title_bar.visible == false, "custom titlebar should be hidden now that native OS chrome is restored")
	_require(main.margin_top == 4, "main content did not reclaim hidden custom-titlebar space")

	print("Catapult-Dabubu window chrome inspection passed")
	print("  Root-cause correction: native OS chrome restored; old custom titlebar compatibility node is hidden")
	print("  Project: borderless=%s resizable=%s size=%sx%s allow_hidpi=%s theme_hidpi=%s" % [str(borderless), str(resizable), str(width), str(height), str(allow_hidpi), str(theme_hidpi)])
	print("  Scene: TitleBar.visible=%s Main.margin_top=%s" % [str(title_bar.visible), str(main.margin_top)])
	print("  Local evidence boundary: this is macOS/Godot scene inspection only; Windows visual confirmation remains human/device-dependent")
	scene.free()
	quit(0)


func _require(condition: bool, message: String) -> void:
	if not condition:
		printerr("window chrome inspection failed: " + message)
		quit(1)
