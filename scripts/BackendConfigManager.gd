extends Node

# Safe first-pass backend setup helper for C-AOL.
# This deliberately writes only launcher-side metadata and never stores API keys.

const BACKEND_API = "api"
const BACKEND_OLLAMA = "ollama"
const BACKEND_OPENVINO = "openvino"
const BACKEND_CONFIG_FILENAME = "caol_backend_setup.json"

func get_supported_backends() -> Array:
	return [
		{
			"id": BACKEND_API,
			"label": "API backend",
			"status": "configurable",
			"secrets_policy": "Do not store or log API keys in Lacapult v0."
		},
		{
			"id": BACKEND_OLLAMA,
			"label": "Ollama backend",
			"status": _detect_ollama_status(),
			"endpoint": Settings.read("backend_ollama_endpoint")
		},
		{
			"id": BACKEND_OPENVINO,
			"label": "OpenVINO backend",
			"status": "parked_specialized_future"
		},
	]

func write_launcher_backend_config(mode: String, endpoint: String = "", model: String = "") -> String:
	if not mode in [BACKEND_API, BACKEND_OLLAMA, BACKEND_OPENVINO]:
		return "unsupported_backend"
	if mode == BACKEND_OPENVINO:
		return "openvino_parked"

	var d = Directory.new()
	if not d.dir_exists(Paths.config):
		var err = d.make_dir_recursive(Paths.config)
		if err != OK:
			return "config_dir_error_%s" % err

	var safe_config = {
		"backend": mode,
		"status": "configured_without_secret" if mode == BACKEND_API else _detect_ollama_status(),
		"endpoint": endpoint,
		"model": model,
		"last_check": OS.get_datetime(),
		"notes": "Launcher-side C-AOL backend setup metadata. API secrets are intentionally not stored here."
	}
	Helpers.save_to_json_file(safe_config, Paths.config.plus_file(BACKEND_CONFIG_FILENAME))
	return "ok"

func _detect_ollama_status() -> String:
	var output = []
	var command_lookup = "where" if OS.get_name() == "Windows" else "which"
	var exit_code = OS.execute(command_lookup, ["ollama"], true, output, true)
	if exit_code != 0:
		return "ollama_command_missing"

	output.clear()
	exit_code = OS.execute("ollama", ["list"], true, output, true)
	if exit_code == 0:
		return "ollama_command_present_server_running"
	return "ollama_command_present_server_unreachable"
