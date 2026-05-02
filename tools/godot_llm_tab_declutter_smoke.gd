extends SceneTree

# Headless UI smoke for Package 1: LLM tab de-clutter/backend-scope correction.
# Instantiates the actual BackendSetupUI script under an isolated HOME and checks
# rendered labels/options without package installs, model pulls, API calls, or real
# Application Support mutation.

var _exit_code := 1

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	settings.store("backend_mode", "api")
	settings.store("backend_api_endpoint", "")
	settings.store("backend_api_model", "")
	settings.store("backend_api_key_env", "CATA_API_KEY")
	settings.store("backend_api_provider", "openai")
	settings.store("backend_python_path", "")
	settings.store("backend_ollama_endpoint", "http://127.0.0.1:11434")
	settings.store("backend_ollama_model", "mistral-v0.3")

	var ui_script = load("res://scripts/BackendSetupUI.gd")
	var ui = VBoxContainer.new()
	ui.set_script(ui_script)
	root.add_child(ui)
	yield(self, "idle_frame")

	var all_text = _collect_visible_text(ui)
	_require(all_text.find("LLM") >= 0, "LLM title did not render")
	_require(all_text.find("Choose API or local Ollama setup.") >= 0, "compact intro did not render")
	_require(all_text.find("API path: choose provider/model") >= 0, "compact API helper did not render")
	_require(all_text.find("300-400 tokens") < 0, "old API token evidence copy still rendered")
	_require(all_text.find("around 1000 tokens") < 0 and all_text.find("1000 tokens") < 0, "stale token copy rendered")
	_require(all_text.find("OpenVINO") < 0, "OpenVINO rendered in visible LLM setup UI")

	var mode_button = _find_option_button(ui)
	_require(mode_button != null, "backend mode option button missing")
	_require(mode_button.get_item_count() == 2, "backend mode should expose exactly API and Ollama")
	_require(mode_button.get_item_text(0) == "API / AnyLLM", "first backend option mismatch")
	_require(mode_button.get_item_text(1) == "Ollama local", "second backend option mismatch")

	settings.store("backend_mode", "ollama")
	ui._refresh_backend_setup_controls()
	yield(self, "idle_frame")
	all_text = _collect_visible_text(ui)
	_require(all_text.find("Ollama path: Check hardware/readiness") >= 0, "compact Ollama helper did not render")
	_require(all_text.find("OpenVINO") < 0, "OpenVINO rendered after Ollama mode switch")

	var scene = load("res://scenes/Catapult.tscn")
	_require(scene != null, "Catapult scene did not load")
	var inst = scene.instance()
	var llm_tab = inst.get_node_or_null("Main/Tabs/LLM")
	_require(llm_tab != null, "Catapult scene does not contain Main/Tabs/LLM")
	inst.free()

	print("LLM tab de-clutter UI smoke passed")
	print("  rendered title/helper: LLM / compact intro / compact API and Ollama helpers")
	print("  visible setup choices: API / AnyLLM, Ollama local")
	print("  hidden support boundary: OpenVINO absent from visible setup UI; scene still loads")
	_exit_code = 0
	quit(_exit_code)


func _collect_visible_text(node: Node) -> String:
	var parts := []
	_collect_visible_text_into(node, parts)
	return PoolStringArray(parts).join("\n")


func _collect_visible_text_into(node: Node, parts: Array) -> void:
	if node is Control and not node.visible:
		return
	if node is Label:
		parts.append(node.text)
	elif node is Button:
		parts.append(node.text)
	elif node is LineEdit:
		parts.append(node.placeholder_text)
	elif node is TextEdit:
		parts.append(node.text)
	elif node is OptionButton:
		for i in range(node.get_item_count()):
			parts.append(node.get_item_text(i))
	for child in node.get_children():
		_collect_visible_text_into(child, parts)


func _find_option_button(node: Node):
	if node is OptionButton:
		return node
	for child in node.get_children():
		var found = _find_option_button(child)
		if found != null:
			return found
	return null


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	printerr("LLM tab de-clutter UI smoke failed: %s" % message)
	quit(1)
