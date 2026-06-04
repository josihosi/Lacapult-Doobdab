extends SceneTree

# Regression smoke: manual handoff controls must be visible in normal builds.
# This catches the old behavior where the whole tab was removed unless
# Settings -> Debug mode was enabled.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	settings.store("debug_mode", false)
	settings.store("game", "caol")
	settings.store("backend_python_path", "python3")

	var scene = load("res://scenes/Catapult.tscn").instance()
	root.add_child(scene)
	yield(self, "idle_frame")
	yield(self, "idle_frame")

	var tabs = scene.get_node("Main/Tabs")
	var playtest_index = -1
	for index in range(tabs.get_tab_count()):
		if tabs.get_tab_title(index) == "Playtest":
			playtest_index = index
			break

	_require(playtest_index >= 0, "Playtest tab is missing when debug_mode=false")
	_require(tabs.get_child(playtest_index).name == "Debug", "Playtest tab is not backed by the manual handoff panel")
	_require(tabs.get_child(playtest_index).has_node("ManualScenarioList"), "Playtest tab did not build the manual scenario list")

	print("Playtest tab visible smoke passed")
	print("  debug_mode=false")
	print("  tab_title=Playtest")
	print("  manual handoff list is present")
	quit(0)


func _require(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		print("Playtest tab visible smoke failed: %s" % message)
		quit(1)
