extends SceneTree

# Headless Godot 3 smoke for the Catapult-Dabubu v2 JSON-mod catalog footing.
# It builds an isolated C-AOL install under HOME, seeds Magiclysm/DinoMod as
# stock JSON mods, and proves ModManager plus CaolModStatus surface them without
# downloads, generated packs, backend calls, or real user-data mutation.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	var paths = root.get_node("/root/Paths")
	var home = OS.get_environment("HOME")
	if home == "" or home.find("/tmp/lacapult-v2-json-mod-catalog-home.") != 0:
		_fail("HOME must be an isolated /tmp/lacapult-v2-json-mod-catalog-home.* path for this smoke")
	settings.store("game", "caol")
	settings.store("active_install_caol", "Sandbox C-AOL")
	var own = paths.own_dir
	var install_dir = own.plus_file("caol").plus_file("game0")
	var stock = install_dir.plus_file("data").plus_file("mods")
	var user = own.plus_file("caol").plus_file("userdata").plus_file("mods")
	var save = own.plus_file("caol").plus_file("userdata").plus_file("save").plus_file("Sandbox World")
	_mkdir(stock)
	_mkdir(user)
	_mkdir(save)
	_write_json(install_dir.plus_file("catapult_install_info.json"), {"name": "Sandbox C-AOL"})
	_write_json(stock.plus_file("dda").plus_file("modinfo.json"), _modinfo("dda", "Dark Days Ahead Core"))
	_write_json(stock.plus_file("Magiclysm").plus_file("modinfo.json"), _modinfo("magiclysm", "Magiclysm", ["dda"]))
	_write_json(stock.plus_file("Magiclysm").plus_file("items").plus_file("magic_fixture.json"), [{"type": "GENERIC", "id": "magiclysm_fixture_focus"}])
	_write_json(stock.plus_file("DinoMod").plus_file("modinfo.json"), _modinfo("DinoMod", "DinoMod", ["dda"]))
	_write_json(stock.plus_file("DinoMod").plus_file("monsters").plus_file("dino_fixture.json"), [{"type": "MONSTER", "id": "dinomod_fixture_dino"}])
	_write_json(save.plus_file("mods.json"), ["dda", "magiclysm", "DinoMod"])

	var mods = load("res://scripts/ModManager.gd").new()
	get_root().add_child(mods)
	mods.refresh_installed()
	mods.refresh_available()
	_require(mods.available.has("magiclysm"), "Magiclysm was not seeded into the C-AOL JSON catalog")
	_require(mods.available.has("DinoMod"), "DinoMod was not seeded into the C-AOL JSON catalog")
	_require(str(mods.available["magiclysm"].get("catalog_source", "")) == "caol-json-stock", "Magiclysm catalog source mismatch")
	_require(str(mods.available["DinoMod"].get("catalog_source", "")) == "caol-json-stock", "DinoMod catalog source mismatch")
	_require(str(mods.available["magiclysm"].get("catalog_note", "")).find("Summarizer") >= 0, "Magiclysm catalog note does not mention Summarizer footing")
	_require(mods.mod_status("magiclysm") == 2, "Magiclysm should be stock-present, not a fake download")
	_require(mods.mod_status("DinoMod") == 2, "DinoMod should be stock-present, not a fake download")

	var status = mods.get_caol_mod_summarizer_status("Sandbox World")
	_require(_catalog_target_present(status, "magiclysm"), "status model did not report Magiclysm JSON catalog target")
	_require(_catalog_target_present(status, "DinoMod"), "status model did not report DinoMod JSON catalog target")
	_require(_record_has_summary_status(status, "magiclysm", "stock", "summary-missing"), "Magiclysm should be a JSON Summarizer candidate")
	_require(_record_has_summary_status(status, "DinoMod", "stock", "summary-missing"), "DinoMod should be a JSON Summarizer candidate")
	print("godot caol JSON mod catalog smoke: available=%s,%s status_targets=%s" % [mods.available["magiclysm"].get("catalog_source", ""), mods.available["DinoMod"].get("catalog_source", ""), status.get("json_catalog_targets", []).size()])
	quit(0)


func _catalog_target_present(status: Dictionary, mod_id: String) -> bool:
	for target in status.get("json_catalog_targets", []):
		if target.get("id", "") == mod_id:
			return target.get("present", false) == true
	return false


func _record_has_summary_status(status: Dictionary, mod_id: String, source_type: String, summary_status: String) -> bool:
	for record in status.get("mods", []):
		if record.get("id", "") == mod_id and record.get("source_type", "") == source_type:
			return record.get("summary_status", "") == summary_status
	return false


func _modinfo(mod_id: String, name: String, dependencies := []) -> Dictionary:
	return {"type": "MOD_INFO", "id": mod_id, "name": name, "category": "content", "dependencies": dependencies}


func _mkdir(path: String) -> void:
	var d = Directory.new()
	var err = d.make_dir_recursive(path)
	if err != OK:
		_fail("failed to create directory %s: %s" % [path, err])


func _write_json(path: String, value) -> void:
	_mkdir(path.get_base_dir())
	var f = File.new()
	var err = f.open(path, File.WRITE)
	if err != OK:
		_fail("failed to write %s: %s" % [path, err])
	f.store_string(JSON.print(value, "  "))
	f.close()


func _require(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	printerr(message)
	quit(1)
