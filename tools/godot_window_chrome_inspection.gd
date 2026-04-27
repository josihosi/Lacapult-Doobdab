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

	var margin = title_bar.get_node_or_null("MarginContainer")
	var icon = title_bar.get_node_or_null("MarginContainer/HBoxContainer/Icon")
	var minimize = title_bar.get_node_or_null("MarginContainer/HBoxContainer/MinimizeButton")
	var maximize = title_bar.get_node_or_null("MarginContainer/HBoxContainer/MaximizeButton")
	var close = title_bar.get_node_or_null("MarginContainer/HBoxContainer/CloseButton")
	_require(margin != null and icon != null, "custom titlebar margin/icon nodes missing")
	_require(minimize != null and maximize != null and close != null, "custom titlebar control buttons missing")
	_require(minimize is TextureButton and maximize is TextureButton and close is TextureButton, "custom titlebar controls are not TextureButtons")
	_require(title_bar.rect_min_size.y == 28, "custom titlebar height did not tighten from previous 32px baseline")
	_require(main.margin_top == 32, "main content offset did not follow titlebar reduction from previous 36px baseline")
	_require(icon.rect_min_size == Vector2(20, 20), "app icon did not tighten from previous 24x24 baseline")
	_require(minimize.rect_min_size == Vector2(28, 20) and maximize.rect_min_size == Vector2(28, 20) and close.rect_min_size == Vector2(28, 20), "window-control buttons did not tighten from previous 32x24 baseline")
	_require(margin.get_constant("margin_top") == 2 and margin.get_constant("margin_bottom") == 2, "titlebar vertical margins did not tighten from previous 4px baseline")

	print("Lacapult window chrome inspection passed")
	print("  Root-cause class: custom scene chrome, not native OS chrome")
	print("  Project: borderless=%s allow_hidpi=%s theme_hidpi=%s" % [str(borderless), str(allow_hidpi), str(theme_hidpi)])
	print("  Before baseline: titlebar=32px, Main.margin_top=36px, icon=24x24, buttons=32x24, vertical margins=4px")
	print("  After local patch: titlebar=%spx, Main.margin_top=%spx, icon=%s, buttons=%s/%s/%s, vertical margins=%s/%s" % [str(title_bar.rect_min_size.y), str(main.margin_top), str(icon.rect_min_size), str(minimize.rect_min_size), str(maximize.rect_min_size), str(close.rect_min_size), str(margin.get_constant("margin_top")), str(margin.get_constant("margin_bottom"))])
	print("  Visible seam changed: CustomTitleBar metrics and Catapult main offset tightened in the scene")
	print("  Local evidence boundary: this is macOS/Godot scene inspection only; Windows visual confirmation remains human/device-dependent")
	scene.free()
	quit(0)


func _require(condition: bool, message: String) -> void:
	if not condition:
		printerr("window chrome inspection failed: " + message)
		quit(1)
