extends SceneTree

# Headless Godot smoke for Lacapult's v0 backend selector/config contract.
# Runs under an isolated HOME. It creates a tiny fake active C-AOL install record
# so Paths.config resolves, then writes API/Ollama/OpenVINO launcher-side backend
# metadata without secrets, model pulls, runtime installs, or installed-game mutation.

const INFO_FILENAME := "catapult_install_info.json"

var _exit_code := 1

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	var paths = root.get_node("/root/Paths")
	var helpers = root.get_node("/root/Helpers")
	var backend = root.get_node("/root/BackendConfig")

	settings.store("game", "caol")
	settings.store("channel", "release")
	settings.store("active_install_caol", "Backend Triad Smoke")

	var install_dir = paths.own_dir.plus_file("caol").plus_file("game0")
	_mkdir(install_dir)
	var info = {
		"name": "Backend Triad Smoke",
		"source": "Lacapult backend triad smoke"
	}
	if not helpers.save_to_json_file(info, install_dir.plus_file(INFO_FILENAME)):
		_fail("could not write fake active install info")
		return

	var results = {}
	results["api"] = backend.write_launcher_backend_config("api", "https://api.example.invalid/v1", "example-api-model")
	results["ollama"] = backend.write_launcher_backend_config("ollama", "http://127.0.0.1:11434", "llama-test")
	results["openvino"] = backend.write_launcher_backend_config("openvino")

	var config_path = paths.config.plus_file("caol_backend_setup.json")
	var patch_path = paths.config.plus_file("caol_llm_options_patch.json")
	var last_config = helpers.load_json_file(config_path)
	var last_patch = helpers.load_json_file(patch_path)
	var proof = {
		"home": OS.get_environment("HOME"),
		"config_path": config_path,
		"patch_path": patch_path,
		"results": results,
		"last_config": last_config,
		"last_patch": last_patch,
		"supported_backends": backend.get_supported_backends()
	}
	print(JSON.print(proof, "  "))

	for mode in ["api", "ollama", "openvino"]:
		if results[mode] != "ok":
			_fail("backend %s write result was %s" % [mode, results[mode]])
			return
	if not last_config or last_config.get("backend", "") != "openvino":
		_fail("OpenVINO final config was not written")
		return
	if not last_patch or last_patch.get("apply_status", "") != "preview_only_not_applied":
		_fail("OpenVINO preview patch guard missing")
		return
	if last_patch.get("options", []).empty() or last_patch["options"][0].get("value", "") != "openvino":
		_fail("OpenVINO backend option missing from preview patch")
		return

	_exit_code = 0
	_finalize()


func _mkdir(path: String) -> void:
	var d := Directory.new()
	if not d.dir_exists(path):
		var err := d.make_dir_recursive(path)
		if err != OK:
			_fail("could not create %s (error %s)" % [path, err])


func _fail(message: String) -> void:
	push_error(message)
	print("BACKEND_TRIAD_SMOKE_FAILED: %s" % message)
	_exit_code = 1
	_finalize()


func _finalize() -> void:
	quit(_exit_code)
