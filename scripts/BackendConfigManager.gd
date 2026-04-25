extends Node

# Safe first-pass backend setup helper for C-AOL.
# This deliberately writes only launcher-side metadata and never stores API keys.

const BACKEND_API = "api"
const BACKEND_OLLAMA = "ollama"
const BACKEND_OPENVINO = "openvino"
const BACKEND_CONFIG_FILENAME = "caol_backend_setup.json"
const C_AOL_OPTIONS_PATCH_FILENAME = "caol_llm_options_patch.json"

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
		"notes": "Launcher-side C-AOL backend setup metadata. API secrets are intentionally not stored here.",
		"caol_options_patch": _build_caol_options_patch(mode, endpoint, model)
	}
	var options_patch = safe_config["caol_options_patch"]
	if not Helpers.save_to_json_file(safe_config, Paths.config.plus_file(BACKEND_CONFIG_FILENAME)):
		return "config_write_error"
	if not Helpers.save_to_json_file(options_patch, Paths.config.plus_file(C_AOL_OPTIONS_PATCH_FILENAME)):
		return "options_patch_write_error"
	return "ok"


func _build_caol_options_patch(mode: String, endpoint: String, model: String) -> Dictionary:
	var patch = {
		"format": "c-aol-options-patch-v1",
		"source": "Lacapult Doobdab",
		"apply_status": "preview_only_not_applied",
		"notes": "These are the C-AOL option names Lacapult would set after an installed game config path is chosen. API keys are referenced by environment variable only, never stored here. LLM_INTENT_ENABLE is intentionally left for the player/game UI until Lacapult has an explicit apply step.",
		"options": [
			{
				"name": "LLM_INTENT_BACKEND",
				"value": mode,
				"reason": "Select the NPC LLM backend."
			}
		]
	}

	if mode == BACKEND_API:
		patch["options"].append({
			"name": "LLM_INTENT_API_KEY_ENV",
			"value": "CATA_API_KEY",
			"reason": "C-AOL reads the API key from this environment variable; Lacapult v0 does not store the secret."
		})
		if model.strip_edges() != "":
			patch["options"].append({
				"name": "LLM_INTENT_API_MODEL",
				"value": model,
				"reason": "Selected API model name."
			})
	elif mode == BACKEND_OLLAMA:
		patch["options"].append({
			"name": "LLM_INTENT_OLLAMA_URL",
			"value": endpoint if endpoint.strip_edges() != "" else "http://127.0.0.1:11434",
			"reason": "Local Ollama server URL."
		})
		if model.strip_edges() != "":
			patch["options"].append({
				"name": "LLM_INTENT_OLLAMA_MODEL",
				"value": model,
				"reason": "Selected Ollama model tag."
			})

	return patch

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
