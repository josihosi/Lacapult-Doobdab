extends SceneTree

# Headless v3 smoke for Windows Ollama hardware honesty.
# It proves CPU-only/iGPU fixture states render as slow fallback rather than a
# happy green local mode, while NVIDIA/CUDA remains distinct. No installs,
# model pulls, Ollama requests, API calls, or real user-data mutation occur.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	var backend = root.get_node("/root/BackendConfig")
	settings.store("game", "caol")
	settings.store("backend_mode", "ollama")
	settings.store("backend_ollama_endpoint", backend.DEFAULT_OLLAMA_URL)
	settings.store("backend_ollama_model", "mistral:v0.3")
	settings.store("backend_python_path", "python3")
	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "models:mistral:v0.3")

	_assert_hardware_fixture(backend, "ram:32768,vram:0,accel:cpu", "red", "red", "red", "CPU-only slow fallback")
	_assert_hardware_fixture(backend, "ram:32768,vram:2048,accel:igpu", "yellow", "yellow", "yellow", "iGPU/other GPU slow fallback")
	_assert_hardware_fixture(backend, "ram:32768,vram:12000,accel:nvidia", "green", "green", "green", "NVIDIA/CUDA accelerated")

	var ui_script = load("res://scripts/BackendSetupUI.gd")
	var ui = VBoxContainer.new()
	ui.set_script(ui_script)
	root.add_child(ui)
	yield(self, "idle_frame")

	OS.set_environment("LACAPULT_HARDWARE_FIXTURE", "ram:32768,vram:0,accel:cpu")
	ui._refresh_backend_setup_controls()
	yield(self, "idle_frame")
	_require(_find_status_row(ui._ollama_status_lights, "AccelerationStatusRow", "red"), "CPU-only acceleration row was not red")
	_require(_find_status_row(ui._ollama_status_lights, "mistral:v0.3 performance", "red"), "CPU-only Mistral performance was not red")
	_require(_collect_visible_text(ui).find("CPU-only slow fallback") >= 0, "CPU-only fallback label did not render")

	OS.set_environment("LACAPULT_HARDWARE_FIXTURE", "ram:32768,vram:2048,accel:igpu")
	ui._refresh_backend_setup_controls()
	yield(self, "idle_frame")
	_require(_find_status_row(ui._ollama_status_lights, "AccelerationStatusRow", "yellow"), "iGPU acceleration row was not yellow")
	_require(_find_status_row(ui._ollama_status_lights, "mistral:v0.3 performance", "yellow"), "iGPU Mistral performance was not capped to yellow")
	_require(_collect_visible_text(ui).find("iGPU/other GPU slow fallback") >= 0, "iGPU fallback label did not render")

	OS.set_environment("LACAPULT_HARDWARE_FIXTURE", "ram:32768,vram:12000,accel:nvidia")
	ui._refresh_backend_setup_controls()
	yield(self, "idle_frame")
	_require(_find_status_row(ui._ollama_status_lights, "AccelerationStatusRow", "green"), "NVIDIA acceleration row was not green")
	_require(_find_status_row(ui._ollama_status_lights, "mistral:v0.3 performance", "green"), "NVIDIA Mistral performance did not remain green")
	_require(_collect_visible_text(ui).find("NVIDIA/CUDA accelerated") >= 0, "NVIDIA acceleration label did not render")

	print("v3 Ollama slow-fallback UI smoke passed")
	print("  CPU-only proof: acceleration and model-performance rows render red slow fallback")
	print("  iGPU proof: acceleration and model-performance rows render yellow slow fallback, not green")
	print("  NVIDIA proof: CUDA-capable fixture remains distinct/green")
	print("  Safety: fixture-only hardware/readiness proof; no installer, model pull, API call, Ollama request, or real user-data mutation")
	quit(0)


func _assert_hardware_fixture(backend: Node, fixture: String, accel_state: String, mistral_state: String, nemotron_state: String, label: String) -> void:
	OS.set_environment("LACAPULT_HARDWARE_FIXTURE", fixture)
	var hardware = backend.get_ollama_hardware_check()
	_require(hardware.get("acceleration_state", "") == accel_state, "%s acceleration state mismatch: %s" % [fixture, JSON.print(hardware)])
	var performance = hardware.get("performance_lights", {})
	_require(performance.get("mistral:v0.3", "") == mistral_state, "%s Mistral performance mismatch: %s" % [fixture, JSON.print(hardware)])
	_require(performance.get("nemotron-9b-dumber:latest", "") == nemotron_state, "%s Nemotron performance mismatch: %s" % [fixture, JSON.print(hardware)])
	_require(str(hardware.get("acceleration_label", "")).find(label) >= 0, "%s label mismatch: %s" % [fixture, JSON.print(hardware)])


func _find_status_row(container: Node, label_fragment: String, state: String) -> bool:
	for child in container.get_children():
		if child.has_meta("status_state") and child.get_meta("status_state") == state:
			if child.name == label_fragment:
				return true
			for grand in child.get_children():
				if grand is Label and grand.text.find(label_fragment) >= 0:
					return true
	return false


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


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	printerr("v3 Ollama slow-fallback smoke failed: %s" % message)
	quit(1)
