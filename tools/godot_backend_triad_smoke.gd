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
	_mkdir(install_dir.plus_file("fake-openvino-model"))
	var info = {
		"name": "Backend Triad Smoke",
		"source": "Lacapult backend triad smoke"
	}
	if not helpers.save_to_json_file(info, install_dir.plus_file(INFO_FILENAME)):
		_fail("could not write fake active install info")
		return

	var results = {}
	results["api"] = backend.write_launcher_backend_config("api", "https://api.example.invalid/v1", "example-api-model", "python3", "openai", "CATA_API_KEY")
	results["ollama"] = backend.write_launcher_backend_config("ollama", "http://127.0.0.1:11434", "llama-test", "python3")
	results["openvino"] = backend.write_launcher_backend_config("openvino", "", "", "python3", "openai", "CATA_API_KEY", install_dir.plus_file("fake-openvino-model"), "AUTO")

	var sandbox_results = _run_sandbox_options_apply(paths, helpers, backend, install_dir)
	var config_path = paths.config.plus_file("caol_backend_setup.json")
	var patch_path = paths.config.plus_file("caol_llm_options_patch.json")
	var last_config = helpers.load_json_file(config_path)
	var last_patch = helpers.load_json_file(patch_path)
	var proof = {
		"home": OS.get_environment("HOME"),
		"config_path": config_path,
		"patch_path": patch_path,
		"results": results,
		"sandbox_options_apply": sandbox_results,
		"last_config": last_config,
		"last_patch": last_patch,
		"supported_backends": backend.get_supported_backends()
	}
	print(JSON.print(proof, "  "))

	for mode in ["api", "ollama", "openvino"]:
		if results[mode] != "ok":
			_fail("backend %s write result was %s" % [mode, results[mode]])
			return
		if not sandbox_results.has(mode) or not str(sandbox_results[mode].get("result", "")).begins_with("ok_changed_"):
			_fail("sandbox options apply for %s failed: %s" % [mode, sandbox_results.get(mode, {})])
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


func _run_sandbox_options_apply(paths, helpers, backend, install_dir: String) -> Dictionary:
	var source_options = OS.get_environment("CAOL_OPTIONS_JSON")
	var source_data = null
	if source_options != "":
		source_data = helpers.load_json_file(source_options)
	if typeof(source_data) != TYPE_ARRAY:
		source_data = _minimal_caol_options()

	var sandbox_dir = install_dir.plus_file("config-sandbox")
	_mkdir(sandbox_dir)
	var results = {}
	var cases = {
		"api": ["api", "https://api.example.invalid/v1", "example-api-model", "python3", "openai", "CATA_API_KEY", "", "AUTO"],
		"ollama": ["ollama", "http://127.0.0.1:11434", "llama-test", "python3", "openai", "CATA_API_KEY", "", "AUTO"],
		"openvino": ["openvino", "", "", "python3", "openai", "CATA_API_KEY", install_dir.plus_file("fake-openvino-model"), "AUTO"],
	}
	for mode in ["api", "ollama", "openvino"]:
		var options_path = sandbox_dir.plus_file("options_%s.json" % mode)
		helpers.save_to_json_file(source_data, options_path)
		var c = cases[mode]
		var result = backend.write_sandboxed_options_config(options_path, c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7])
		results[mode] = {
			"path": options_path,
			"result": result,
			"values": _option_values(helpers.load_json_file(options_path)),
		}
	return results


func _minimal_caol_options() -> Array:
	var names = [
		"LLM_INTENT_BACKEND",
		"LLM_INTENT_OLLAMA_URL",
		"LLM_INTENT_OLLAMA_MODEL",
		"LLM_INTENT_API_KEY_ENV",
		"LLM_INTENT_API_MODEL",
		"LLM_INTENT_PYTHON",
		"LLM_INTENT_MODEL_DIR",
		"LLM_INTENT_DEVICE",
	]
	var result = []
	for name in names:
		result.append({"name": name, "value": ""})
	return result


func _option_values(options) -> Dictionary:
	var values = {}
	if typeof(options) != TYPE_ARRAY:
		return values
	for option in options:
		if typeof(option) == TYPE_DICTIONARY and str(option.get("name", "")).begins_with("LLM_INTENT_"):
			values[option.get("name", "")] = option.get("value", "")
	return values


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
