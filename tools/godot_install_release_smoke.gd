extends SceneTree

# Headless Godot smoke for Lacapult's real ReleaseInstaller path.
#
# This intentionally runs with an isolated HOME supplied by the caller. It copies
# an already-downloaded C-AOL macOS DMG into Lacapult's cache, then invokes
# ReleaseInstaller.install_release() so FS.extract(), DMG mount/copy/detach,
# install-root detection, metadata writing, final move, chmod, and launchability
# guards are all exercised by the Godot code path.

const INFO_FILENAME := "catapult_install_info.json"

var _exit_code := 1
var _messages := []

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
		_fail("This smoke currently targets the C-AOL macOS DMG installer path; OS is %s" % OS.get_name())
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

	var d := Directory.new()
	_mkdir(paths.cache_dir)
	_mkdir(paths.tmp_dir)

	var filename := dmg_path.get_file()
	var cached_dmg = paths.cache_dir.plus_file(filename)
	var copy_result := d.copy(dmg_path, cached_dmg)
	if copy_result != OK:
		_fail("Could not copy DMG into isolated Lacapult cache: %s -> %s (error %s)" % [dmg_path, cached_dmg, copy_result])
		return

	var expected_target = paths.next_install_dir
	var release_info := {
		"name": "Cataclysm - Arsenic and Old Lace v0.2.0",
		"url": "https://github.com/josihosi/Cataclysm-AOL/releases/download/v0.2.0/%s" % filename,
		"filename": filename,
		"published_at": "2026-03-29T00:00:00Z",
		"has_any_assets": true,
		"asset_size": _file_size(cached_dmg),
		"release_page_url": "https://github.com/josihosi/Cataclysm-AOL/releases/tag/v0.2.0"
	}

	var release_installer_script = load("res://scripts/ReleaseInstaller.gd")
	if release_installer_script == null:
		_fail("Could not load ReleaseInstaller.gd")
		return
	var installer = release_installer_script.new()
	root.add_child(installer)
	installer.install_release(release_info, "caol")
	yield(installer, "operation_finished")

	var info_path = expected_target.plus_file(INFO_FILENAME)
	var app_path = expected_target.plus_file("Cataclysm.app")
	var proof := {
		"home": OS.get_environment("HOME"),
		"own_dir": paths.own_dir,
		"cached_dmg": cached_dmg,
		"target_dir": expected_target,
		"target_exists": d.dir_exists(expected_target),
		"app_exists": d.dir_exists(app_path),
		"info_exists": d.file_exists(info_path),
		"looks_launchable": installer._looks_like_game_directory(expected_target),
		"install_listing": fs.list_dir(expected_target),
		"info": helpers.load_json_file(info_path) if d.file_exists(info_path) else null
	}

	print(JSON.print(proof, "  "))
	if not proof["target_exists"]:
		_fail("ReleaseInstaller did not create target dir: %s" % expected_target)
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

	_exit_code = 0
	_finalize()


func _mkdir(path: String) -> void:
	var d := Directory.new()
	if not d.dir_exists(path):
		var err := d.make_dir_recursive(path)
		if err != OK:
			_fail("Could not create directory %s (error %s)" % [path, err])


func _file_size(path: String) -> int:
	var f := File.new()
	if f.open(path, File.READ) != OK:
		return 0
	var size := f.get_len()
	f.close()
	return size


func _fail(message: String) -> void:
	push_error(message)
	print("INSTALL_SMOKE_FAILED: " + message)
	_exit_code = 1
	_finalize()


func _finalize() -> void:
	quit(_exit_code)
