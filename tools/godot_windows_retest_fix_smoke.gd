extends SceneTree

# Focused smoke for the 2026-05-01 Windows retest repair slice.
# It proves the safe UI/config seams only: larger default window metrics,
# wrapped/bounded backend confirmation copy, safe proof-only default, API venv/package
# split copy, and visible Ollama hardware guidance. It does not install packages,
# pull models, call APIs, read secrets, or mutate real user data.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	settings.store("backend_mode", "api")
	settings.store("backend_api_provider", "openrouter")
	settings.store("backend_api_model", "openai/gpt-4.1-mini")
	settings.store("backend_api_key_env", "LACAPULT_RETEST_KEY")
	settings.store("backend_python_path", "python3")
	settings.store("backend_api_setup_proof_only", true)

	_require(ProjectSettings.get_setting("display/window/size/width") >= 760, "default window width was not enlarged for retest")
	_require(ProjectSettings.get_setting("display/window/size/height") >= 820, "default window height was not enlarged for retest")
	_require(settings.read("backend_external_setup_proof_only") == false, "external proof-only default did not safe-read false")

	var catapult_scene = load("res://scenes/Catapult.tscn").instance()
	root.add_child(catapult_scene)
	yield(self, "idle_frame")
	var title_bar = catapult_scene.get_node("TitleBar")
	var main = catapult_scene.get_node("Main")
	_require(title_bar != null, "custom titlebar node did not render")
	_require(main.margin_top == 32, "main content offset regressed from local chrome seam")
	catapult_scene.queue_free()

	var ui_script = load("res://scripts/BackendSetupUI.gd")
	var ui = VBoxContainer.new()
	ui.set_script(ui_script)
	root.add_child(ui)
	yield(self, "idle_frame")

	var all_text = _collect_visible_text(ui)
	_require(all_text.find("Create venv only") >= 0, "API venv-only action did not render")
	_require(all_text.find("Install AnyLLM packages") >= 0, "API package-install action did not render")
	_require(all_text.find("Venv/package split") >= 0, "API status did not explain venv/package split")
	_require(ui._confirm_dialog.dialog_autowrap == true, "confirmation dialog autowrap is not enabled")
	_require(ui._confirm_dialog.rect_min_size.x <= ProjectSettings.get_setting("display/window/size/width") - 120, "confirmation dialog width is too close to launcher width")
	_require(ui._set_session_key_button.hint_tooltip.find("\n") >= 0, "session tooltip was not split into short lines")

	var venv_button = _find_button(ui, "Create venv only")
	_require(venv_button != null, "Create venv only lookup failed")
	venv_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._confirm_dialog.dialog_text.find("\n\n") >= 0, "venv confirmation text did not use paragraphs/newlines")
	_require(ui._confirm_dialog.dialog_text.find("does not install AnyLLM packages") >= 0, "venv confirmation did not clarify AnyLLM is separate")
	_require(ui._confirm_dialog.dialog_text.find("Install AnyLLM packages") >= 0, "venv confirmation did not point to package install action")

	var install_button = _find_button(ui, "Install AnyLLM packages")
	_require(install_button != null, "Install AnyLLM packages lookup failed")
	install_button.emit_signal("pressed")
	yield(self, "idle_frame")
	_require(ui._confirm_dialog.dialog_text.find("Planned command after approval:\n") >= 0, "AnyLLM confirmation did not put command on its own line")
	_require(ui._confirm_dialog.dialog_text.find("instead of running pip") >= 0, "AnyLLM confirmation lost proof-mode no-pip boundary")

	settings.store("backend_mode", "ollama")
	settings.store("backend_ollama_model", "")
	ui._refresh_backend_setup_controls()
	yield(self, "idle_frame")
	all_text = _collect_visible_text(ui)
	_require(settings.read("backend_ollama_model") == "mistral-v0.3", "empty Ollama model did not default to visible Mistral choice")
	_require(all_text.find("Hardware recommendation") >= 0, "Ollama hardware recommendation did not render")
	_require(all_text.find("mistral-v0.3") >= 0 and all_text.find("nemotron-9b") >= 0, "Ollama hardware guidance did not name supported models")
	_require(ui._ollama_status_lights.text.find("?") < 0, "Ollama readiness lights still contain '?' fallback")

	print("Windows retest fix focused UI smoke passed")
	print("  Layout proof: default window enlarged; custom titlebar/main offset seam preserved")
	print("  Popup proof: backend confirmation dialog autowraps, is width-bounded, and uses newline paragraphs")
	print("  API proof: proof-only default safe-reads false; Create venv only is separate from Install AnyLLM packages")
	print("  Ollama proof: empty model defaults to visible Mistral choice; hardware guidance and no '?' readiness fallback render")
	quit(0)


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
	elif node is OptionButton:
		for i in range(node.get_item_count()):
			parts.append(node.get_item_text(i))
	for child in node.get_children():
		_collect_visible_text_into(child, parts)


func _find_button(node: Node, text: String):
	if node is Button and node.text == text:
		return node
	for child in node.get_children():
		var found = _find_button(child, text)
		if found != null:
			return found
	return null


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	printerr("Windows retest fix smoke failed: %s" % message)
	quit(1)
