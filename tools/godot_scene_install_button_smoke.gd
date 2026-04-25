extends SceneTree

# Headless full-scene smoke for Lacapult's C-AOL install button path.
#
# Run with an isolated HOME and LACAPULT_CAOL_DMG pointing at the cached selected
# v0.2.0 macOS DMG. Unlike godot_install_release_smoke.gd, this instantiates the
# main Catapult scene, waits for the real ReleaseManager live GitHub fetch to
# populate the Game tab, selects the first build row, emits the Install button's
# pressed signal, and then verifies the isolated installed C-AOL app shape.

const INFO_FILENAME := "catapult_install_info.json"
const EXPECTED_RELEASE := "Cataclysm - Arsenic and Old Lace v0.2.0"
const MAX_FETCH_SECONDS := 45.0
const MAX_INSTALL_SECONDS := 90.0

var _exit_code := 1
var _finished := false
var _catapult = null
var _installer = null
var _install_finished := false

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var dmg_path := OS.get_environment("LACAPULT_CAOL_DMG")
	if dmg_path == "":
		_fail("LACAPULT_CAOL_DMG must point at the selected C-AOL v0.2.0 macOS DMG")
		return
	if not File.new().file_exists(dmg_path):
		_fail("DMG does not exist: %s" % dmg_path)
		return
	if OS.get_name() != "OSX":
		_fail("This smoke targets the C-AOL macOS DMG installer path; OS is %s" % OS.get_name())
		return

	var settings = root.get_node("/root/Settings")
	var paths = root.get_node("/root/Paths")
	var fs = root.get_node("/root/FS")
	var helpers = root.get_node("/root/Helpers")

	settings.store("game", "caol")
	settings.store("channel", "release")
	settings.store("keep_cache", true)
	settings.store("ignore_cache", false)
	settings.store("debug_mode", false)
	settings.store("update_current_when_installing", false)
	settings.store("update_to_same_build_allowed", true)

	var scene := load("res://scenes/Catapult.tscn")
	if scene == null:
		_fail("Could not load scenes/Catapult.tscn")
		return
	_catapult = scene.instance()
	root.add_child(_catapult)
	_installer = _catapult.get_node("ReleaseInstaller")
	if _installer == null:
		_fail("Main scene has no ReleaseInstaller node")
		return
	_installer.connect("operation_finished", self, "_on_install_finished")

	# Let _ready() wire the UI and start the real C-AOL release fetch.
	yield(self, "idle_frame")
	yield(self, "idle_frame")

	var release_manager = _catapult.get_node("Releases")
	if release_manager == null:
		_fail("Main scene has no Releases node")
		return

	var waited := 0.0
	while release_manager.releases["caol-release"].empty() and waited < MAX_FETCH_SECONDS:
		yield(create_timer(0.5), "timeout")
		waited += 0.5

	var releases = release_manager.releases["caol-release"]
	if releases.empty():
		_fail("C-AOL release list stayed empty after %.1f seconds" % waited)
		return

	var selected = releases[0]
	if selected.get("name", "") != EXPECTED_RELEASE:
		_fail("First release row was not the prioritized v0.2.0 target: %s" % selected.get("name", ""))
		return
	if selected.get("url", "") == "" or selected.get("filename", "") == "":
		_fail("Prioritized C-AOL release row is not installable: %s" % JSON.print(selected))
		return

	_mkdir(paths.cache_dir)
	_mkdir(paths.tmp_dir)
	var cached_dmg = paths.cache_dir.plus_file(selected["filename"])
	var copy_result := Directory.new().copy(dmg_path, cached_dmg)
	if copy_result != OK:
		_fail("Could not copy DMG into isolated Lacapult cache: %s -> %s (error %s)" % [dmg_path, cached_dmg, copy_result])
		return

	var list = _catapult.get_node("Main/Tabs/Game/Builds/BuildsList")
	var install_button = _catapult.get_node("Main/Tabs/Game/BtnInstall")
	if list == null or install_button == null:
		_fail("Could not find Game tab build list or install button")
		return

	list.select(0)
	list.emit_signal("item_selected", 0)
	if install_button.disabled:
		_fail("Install button stayed disabled after selecting the prioritized v0.2.0 row")
		return

	install_button.emit_signal("pressed")

	waited = 0.0
	while not _install_finished and waited < MAX_INSTALL_SECONDS:
		yield(create_timer(0.5), "timeout")
		waited += 0.5
	if not _install_finished:
		_fail("Install button path did not finish after %.1f seconds" % waited)
		return

	var expected_target = paths.game_dir
	var info_path = expected_target.plus_file(INFO_FILENAME)
	var app_path = expected_target.plus_file("Cataclysm.app")
	var proof := {
		"home": OS.get_environment("HOME"),
		"own_dir": paths.own_dir,
		"selected_release": selected,
		"cache_file": cached_dmg,
		"target_dir": expected_target,
		"target_exists": Directory.new().dir_exists(expected_target),
		"app_exists": Directory.new().dir_exists(app_path),
		"info_exists": Directory.new().file_exists(info_path),
		"looks_launchable": _installer._looks_like_game_directory(expected_target),
		"install_listing": fs.list_dir(expected_target),
		"info": helpers.load_json_file(info_path) if Directory.new().file_exists(info_path) else null
	}

	print(JSON.print(proof, "  "))
	if not proof["target_exists"]:
		_fail("Install button path did not create target dir: %s" % expected_target)
		return
	if not proof["app_exists"]:
		_fail("Installed C-AOL target does not contain Cataclysm.app")
		return
	if not proof["info_exists"]:
		_fail("Installed C-AOL target does not contain %s" % INFO_FILENAME)
		return
	if not proof["looks_launchable"]:
		_fail("Installed C-AOL target failed ReleaseInstaller launchability guard")
		return
	var info = proof["info"]
	if typeof(info) != TYPE_DICTIONARY or info.get("name", "") != EXPECTED_RELEASE:
		_fail("Install info did not record the selected C-AOL v0.2.0 release")
		return

	_exit_code = 0
	_finalize()


func _on_install_finished() -> void:
	_install_finished = true


func _mkdir(path: String) -> void:
	var d := Directory.new()
	if not d.dir_exists(path):
		var err := d.make_dir_recursive(path)
		if err != OK:
			_fail("Could not create directory %s (error %s)" % [path, err])


func _fail(message: String) -> void:
	if _finished:
		return
	push_error(message)
	print("SCENE_INSTALL_BUTTON_SMOKE_FAILED: " + message)
	_exit_code = 1
	_finalize()


func _finalize() -> void:
	if _finished:
		return
	_finished = true
	quit(_exit_code)
