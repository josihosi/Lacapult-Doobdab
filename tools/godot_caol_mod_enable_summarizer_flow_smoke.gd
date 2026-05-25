extends SceneTree

# Headless Godot 3 smoke for the normal C-AOL mod enable -> Summarizer flow.
# It uses an isolated HOME, fixture backend, and sandbox C-AOL install/userdata.
# No live backend call, package install, model pull, or real user-data mutation occurs.

func _init() -> void:
	var home = OS.get_environment("HOME")
	if home == "" or home.find("/tmp/lacapult-caol-mod-enable-home.") != 0:
		_fail("HOME must be an isolated /tmp/lacapult-caol-mod-enable-home.* path for this smoke")
		return

	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "models:mistral:v0.3")
	OS.set_environment("LACAPULT_SUMMARIZER_FIXTURE_BACKEND", "1")

	var settings = get_root().get_node("Settings")
	var paths = get_root().get_node("Paths")
	var fixture = _build_fixture(paths)
	settings.store("game", "caol")
	settings.store("active_install_caol", "Mod Enable Sandbox")
	settings.store("backend_mode", "ollama")
	settings.store("backend_ollama_model", "mistral:v0.3")
	settings.store("backend_ollama_endpoint", "http://127.0.0.1:11434")

	var mods = load("res://scripts/ModManager.gd").new()
	get_root().add_child(mods)
	mods.refresh_installed()
	mods.refresh_available()

	var initial = mods.get_caol_mod_summarizer_status("Sandbox World")
	_require(_target_record(initial, "magiclysm").get("enabled_status", "") == "disabled", "Magiclysm should start disabled")
	_require(_has_enable_candidate(mods.get_caol_mod_enable_candidates("Sandbox World"), "magiclysm"), "Magiclysm enable candidate missing")

	var unconfirmed = mods.get_caol_mod_enable_preview("Sandbox World", "magiclysm", false)
	_require(unconfirmed.get("would_mutate", true) == false, "unconfirmed enable preview claimed mutation")
	_require(unconfirmed.get("blocked_reasons", []).find("Explicit player confirmation is required before changing world mods.json.") >= 0, "enable preview did not require confirmation")

	var enable_result = mods.enable_caol_mod_for_world("Sandbox World", "magiclysm", true)
	_require(enable_result.get("enabled", false) == true, "Magiclysm did not enable: %s" % enable_result.get("message", "missing message"))
	_require(enable_result.get("rollback_visible", false) == true, "Magiclysm enable did not expose rollback visibility")
	_require(_read_json(fixture.get("sandbox_mods_json", "")) == ["dda", "magiclysm"], "Magiclysm mods.json order wrong after enable")

	var after_enable = mods.get_caol_mod_summarizer_status("Sandbox World")
	var magic = _target_record(after_enable, "magiclysm")
	_require(magic.get("enabled_status", "") == "enabled-in-world", "Magiclysm is not enabled after enable action")
	_require(magic.get("summary_status", "") == "summary-missing", "Magiclysm should need summary pack after enable")

	var summary_preview = mods.get_caol_summarizer_apply_preview("Sandbox World", "magiclysm", true)
	_require(summary_preview.get("would_generate_pack", false) == true, "Magiclysm summary preview did not become eligible after enable")
	var summary_result = mods.generate_and_apply_caol_summarizer_pack("Sandbox World", "magiclysm", true, true)
	_require(summary_result.get("applied", false) == true, "Magiclysm summary generation/apply failed: %s" % summary_result.get("message", "missing message"))
	_require(summary_result.get("generation", {}).get("backend_mode", "") == "fixture", "summary generation did not use fixture backend")

	var summarized = mods.get_caol_mod_summarizer_status("Sandbox World")
	_require(_target_record(summarized, "magiclysm").get("summary_status", "") == "summary-ready", "Magiclysm was not summary-ready after generated companion apply")
	_require(_target_record(summarized, "lacapult_summary_magiclysm").get("enabled_status", "") == "enabled-in-world", "Magiclysm companion pack is not enabled")

	var dependency_preview = mods.get_caol_mod_enable_preview("Dependency World", "DinoMod", true)
	_require(dependency_preview.get("would_enable_mods", false) == true, "DinoMod dependency preview was not writable")
	_require(dependency_preview.get("write_plan", {}).get("planned_mod_order", []) == ["dda", "DinoMod"], "DinoMod dependency order did not include dda first")
	var dependency_enable = mods.enable_caol_mod_for_world("Dependency World", "DinoMod", true)
	_require(dependency_enable.get("enabled", false) == true, "DinoMod dependency enable failed")
	_require(_read_json(fixture.get("dependency_mods_json", "")) == ["dda", "DinoMod"], "DinoMod dependency world mods.json order wrong")

	print("godot caol mod enable/summarizer flow smoke passed")
	print("  Flow: disabled stock mod -> confirmed world enable -> summary candidate -> fixture summary companion apply")
	print("  Dependency order: DinoMod enable planned and wrote dda before DinoMod")
	print("  Safety: isolated HOME only; no live backend call, model pull, package install, or real save mutation")
	quit(0)


func _build_fixture(paths: Node) -> Dictionary:
	var own = paths.own_dir
	var game_dir = own.plus_file("caol").plus_file("game0")
	var stock = game_dir.plus_file("data").plus_file("mods")
	var user = own.plus_file("caol").plus_file("userdata").plus_file("mods")
	var sandbox_world = own.plus_file("caol").plus_file("userdata").plus_file("save").plus_file("Sandbox World")
	var dependency_world = own.plus_file("caol").plus_file("userdata").plus_file("save").plus_file("Dependency World")
	_mkdir(stock.plus_file("dda"))
	_mkdir(stock.plus_file("Magiclysm"))
	_mkdir(stock.plus_file("DinoMod"))
	_mkdir(user)
	_mkdir(sandbox_world)
	_mkdir(dependency_world)
	_write_json(game_dir.plus_file("catapult_install_info.json"), {"name": "Mod Enable Sandbox"})
	_write_json(stock.plus_file("dda").plus_file("modinfo.json"), _modinfo("dda", "Dark Days Ahead", []))
	_write_json(stock.plus_file("Magiclysm").plus_file("modinfo.json"), _modinfo("magiclysm", "Magiclysm", ["dda"]))
	_write_json(stock.plus_file("Magiclysm").plus_file("items").plus_file("magic_fixture.json"), [{"type": "GENERIC", "id": "magiclysm_fixture_focus", "name": "magiclysm fixture focus"}])
	_write_json(stock.plus_file("DinoMod").plus_file("modinfo.json"), _modinfo("DinoMod", "DinoMod", ["dda"]))
	_write_json(stock.plus_file("DinoMod").plus_file("monsters").plus_file("dino_fixture.json"), [{"type": "MONSTER", "id": "dinomod_fixture_dino", "name": "fixture dino"}])
	_write_json(sandbox_world.plus_file("mods.json"), ["dda"])
	_write_json(dependency_world.plus_file("mods.json"), [])
	return {
		"sandbox_mods_json": sandbox_world.plus_file("mods.json"),
		"dependency_mods_json": dependency_world.plus_file("mods.json"),
	}


func _modinfo(mod_id: String, name: String, dependencies: Array) -> Dictionary:
	return {"type": "MOD_INFO", "id": mod_id, "name": name, "category": "content", "dependencies": dependencies}


func _has_enable_candidate(candidates: Array, mod_id: String) -> bool:
	for candidate in candidates:
		if candidate.get("id", "") == mod_id:
			return true
	return false


func _target_record(status: Dictionary, mod_id: String) -> Dictionary:
	for record in status.get("mods", []):
		if record.get("id", "") == mod_id:
			return record
	return {}


func _read_json(path: String):
	var f = File.new()
	if f.open(path, File.READ) != OK:
		return null
	var parsed = JSON.parse(f.get_as_text())
	f.close()
	if parsed.error != OK:
		return null
	return parsed.result


func _write_json(path: String, data) -> void:
	_mkdir(path.get_base_dir())
	var f = File.new()
	var err = f.open(path, File.WRITE)
	if err == OK:
		f.store_string(JSON.print(data, "  "))
		f.close()


func _mkdir(path: String) -> void:
	var d = Directory.new()
	d.make_dir_recursive(path)


func _require(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	printerr("caol mod enable/summarizer flow smoke failed: %s" % message)
	quit(1)
