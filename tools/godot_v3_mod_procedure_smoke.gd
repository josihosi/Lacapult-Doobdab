extends SceneTree

# Headless v3 smoke for Magiclysm/DinoMod mod procedure proof.
# It builds a C-AOL-like install/userdata tree inside an isolated HOME, proves the
# targets progress from catalog/disabled to enabled-in-world, then uses the real
# ModManager Summarizer preview/generation/apply seam with a fixture backend.
# No live backend call, model pull, package install, or real user-data mutation occurs.

func _init() -> void:
	var home = OS.get_environment("HOME")
	var output_path = OS.get_environment("LACAPULT_V3_MOD_PROCEDURE_OUTPUT")
	if home == "" or home.find("/tmp/lacapult-v3-mod-procedure-home.") != 0:
		_fail("HOME must be an isolated /tmp/lacapult-v3-mod-procedure-home.* path for this smoke")
		return

	OS.set_environment("LACAPULT_OLLAMA_FIXTURE", "models:mistral:v0.3")
	OS.set_environment("LACAPULT_SUMMARIZER_FIXTURE_BACKEND", "1")

	var settings = get_root().get_node("Settings")
	var paths = get_root().get_node("Paths")
	var fixture = _build_fixture(paths)
	settings.store("game", "caol")
	settings.store("active_install_caol", "V3 Mod Procedure Sandbox")
	settings.store("backend_mode", "ollama")
	settings.store("backend_ollama_model", "mistral:v0.3")
	settings.store("backend_ollama_endpoint", "http://127.0.0.1:11434")

	var mods = load("res://scripts/ModManager.gd").new()
	get_root().add_child(mods)
	mods.refresh_installed()

	var catalog_status = mods.get_caol_mod_summarizer_status("Sandbox World")
	_require(_target_record(catalog_status, "magiclysm").get("enabled_status", "") == "disabled", "Magiclysm should begin cataloged but disabled")
	_require(_target_record(catalog_status, "DinoMod").get("enabled_status", "") == "disabled", "DinoMod should begin cataloged but disabled")
	_require(_catalog_target_present(catalog_status, "magiclysm"), "Magiclysm JSON catalog target missing before enable")
	_require(_catalog_target_present(catalog_status, "DinoMod"), "DinoMod JSON catalog target missing before enable")

	var enable_plan = ["dda", "magiclysm", "DinoMod"]
	_write_json(fixture.get("mods_json", ""), enable_plan)
	var enabled_status = mods.get_caol_mod_summarizer_status("Sandbox World")
	for target_id in ["magiclysm", "DinoMod"]:
		var record = _target_record(enabled_status, target_id)
		_require(record.get("enabled_status", "") == "enabled-in-world", "%s was not enabled in sandbox world" % target_id)
		_require(record.get("dependency_status", "") == "dependency-ok", "%s dependency status is not clean: %s" % [target_id, record.get("dependency_status", "")])
		_require(record.get("summary_status", "") == "summary-missing", "%s should need a generated summary pack before apply" % target_id)
		var preview = mods.get_caol_summarizer_apply_preview("Sandbox World", target_id, false)
		_require(preview.get("would_mutate", true) == false, "%s unconfirmed preview claimed mutation" % target_id)
		_require(preview.get("blocked_reasons", []).find("Explicit player confirmation is required before any generated pack or mods.json write.") >= 0, "%s preview did not require explicit confirmation" % target_id)
		var confirmed_preview = mods.get_caol_summarizer_apply_preview("Sandbox World", target_id, true)
		_require(confirmed_preview.get("would_generate_pack", false) == true and confirmed_preview.get("would_enable_mods", false) == true, "%s confirmed preview did not expose generated-pack/mods.json side effects" % target_id)

	var apply_results = []
	for target_id in ["magiclysm", "DinoMod"]:
		var blocked = mods.generate_and_apply_caol_summarizer_pack("Sandbox World", target_id, true, false)
		_require(blocked.get("applied", true) == false, "%s applied without separate backend-call allowance" % target_id)
		var result = mods.generate_and_apply_caol_summarizer_pack("Sandbox World", target_id, true, true)
		_require(result.get("applied", false) == true, "%s confirmed generation/apply did not apply: %s" % [target_id, result.get("message", "missing message")])
		_require(result.get("generation", {}).get("backend_mode", "") == "fixture", "%s did not use fixture backend" % target_id)
		_require(result.get("rollback_visible", false) == true, "%s apply did not expose rollback visibility" % target_id)
		_verify_apply_result_paths(home, target_id, result)
		apply_results.append(result)

	var applied_status = mods.get_caol_mod_summarizer_status("Sandbox World")
	for target_id in ["magiclysm", "DinoMod"]:
		var source = _target_record(applied_status, target_id)
		var companion = _target_record(applied_status, "lacapult_summary_%s" % _safe_id_fragment(target_id))
		_require(source.get("summary_status", "") == "summary-ready", "%s source was not summary-ready after companion apply" % target_id)
		_require(companion.get("enabled_status", "") == "enabled-in-world" and companion.get("generated_summary_pack", {}).get("present", false), "%s companion pack not visible/enabled after apply" % target_id)

	_restore_sandbox_to_initial(fixture, apply_results)
	var rollback_status = mods.get_caol_mod_summarizer_status("Sandbox World")
	for target_id in ["magiclysm", "DinoMod"]:
		var restored = _target_record(rollback_status, target_id)
		_require(restored.get("enabled_status", "") == "disabled", "%s was not restored to disabled after sandbox rollback" % target_id)
		_require(restored.get("summary_status", "") == "summary-missing", "%s summary status did not return to missing after sandbox rollback" % target_id)
		_require(_target_record(rollback_status, "lacapult_summary_%s" % _safe_id_fragment(target_id)).empty(), "%s companion pack remained after rollback" % target_id)

	if output_path != "":
		_write_json(output_path, {
			"catalog_status": catalog_status,
			"enabled_status": enabled_status,
			"apply_results": apply_results,
			"applied_status": applied_status,
			"rollback_status": rollback_status,
			"safety": "isolated HOME fixture; fixture backend only; no live backend call, model pull, package install, or real user-data mutation",
		})
	print("v3 Magiclysm/DinoMod mod procedure smoke passed")
	print("  Procedure: catalog discovery -> sandbox mods.json enable plan -> confirmed fixture-backend summary companion apply -> backup-visible rollback")
	print("  Safety: isolated HOME only; no live API/Ollama request, model pull, package install, arbitrary mod download, or real Application Support/save mutation")
	quit(0)


func _build_fixture(paths: Node) -> Dictionary:
	var own = paths.own_dir
	var game_dir = own.plus_file("caol").plus_file("game0")
	var stock = game_dir.plus_file("data").plus_file("mods")
	var user = own.plus_file("caol").plus_file("userdata").plus_file("mods")
	var world = own.plus_file("caol").plus_file("userdata").plus_file("save").plus_file("Sandbox World")
	_mkdir(stock.plus_file("dda"))
	_mkdir(stock.plus_file("Magiclysm"))
	_mkdir(stock.plus_file("DinoMod"))
	_mkdir(user)
	_mkdir(world)
	_write_json(game_dir.plus_file("catapult_install_info.json"), {"name": "V3 Mod Procedure Sandbox"})
	_write_json(stock.plus_file("dda").plus_file("modinfo.json"), _modinfo("dda", "Dark Days Ahead", []))
	_write_json(stock.plus_file("Magiclysm").plus_file("modinfo.json"), _modinfo("magiclysm", "Magiclysm", ["dda"]))
	_write_json(stock.plus_file("Magiclysm").plus_file("items").plus_file("magic_fixture.json"), [{"type": "GENERIC", "id": "magiclysm_fixture_focus", "name": "magiclysm fixture focus", "description": "Contextual fixture item for Magiclysm summary procedure proof."}])
	_write_json(stock.plus_file("DinoMod").plus_file("modinfo.json"), _modinfo("DinoMod", "DinoMod", ["dda"]))
	_write_json(stock.plus_file("DinoMod").plus_file("monsters").plus_file("dino_fixture.json"), [{"type": "MONSTER", "id": "dinomod_fixture_dino", "name": "fixture dino", "description": "Contextual fixture monster for DinoMod summary procedure proof."}])
	_write_json(world.plus_file("mods.json"), ["dda"])
	return {"game_dir": game_dir, "stock": stock, "user": user, "world": world, "mods_json": world.plus_file("mods.json"), "initial_mod_order": ["dda"]}


func _modinfo(mod_id: String, name: String, dependencies: Array) -> Dictionary:
	return {"type": "MOD_INFO", "id": mod_id, "name": name, "category": "content", "dependencies": dependencies}


func _verify_apply_result_paths(home: String, target_id: String, result: Dictionary) -> void:
	var details = result.get("details", {})
	var companion_dir = str(details.get("companion_pack_dir", ""))
	var summary_json = str(details.get("summaries_extra_json", ""))
	var manifest_json = str(details.get("manifest_json", ""))
	var backup_dir = str(details.get("backup_dir", ""))
	var d = Directory.new()
	_require(companion_dir.begins_with(home), "%s companion dir escaped isolated HOME: %s" % [target_id, companion_dir])
	_require(d.file_exists(summary_json) and summary_json.find("npcs/Backgrounds/Summaries_extra") >= 0, "%s native Summaries_extra JSON was not written" % target_id)
	_require(d.file_exists(manifest_json), "%s manifest JSON was not written" % target_id)
	_require(d.file_exists(backup_dir.plus_file("mods.json.before.exact")), "%s mods.json exact backup missing" % target_id)
	_require(d.file_exists(backup_dir.plus_file("summary_pack.before.missing.json")), "%s missing-pack backup marker missing" % target_id)


func _restore_sandbox_to_initial(fixture: Dictionary, apply_results: Array) -> void:
	_write_json(fixture.get("mods_json", ""), fixture.get("initial_mod_order", []))
	for result in apply_results:
		var companion_dir = str(result.get("details", {}).get("companion_pack_dir", ""))
		if companion_dir != "":
			_remove_dir_recursive(companion_dir)


func _target_record(status: Dictionary, mod_id: String) -> Dictionary:
	for record in status.get("mods", []):
		if record.get("id", "") == mod_id:
			return record
	return {}


func _catalog_target_present(status: Dictionary, target_id: String) -> bool:
	for target in status.get("json_catalog_targets", []):
		if target.get("id", "") == target_id and target.get("present", false):
			return true
	return false


func _safe_id_fragment(value) -> String:
	var raw = str(value).to_lower()
	var out = ""
	for i in range(raw.length()):
		var c = raw[i]
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9") or c == "_" or c == "-":
			out += c
		else:
			out += "_"
	return out.strip_edges()


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


func _remove_dir_recursive(path: String) -> void:
	var d = Directory.new()
	if not d.dir_exists(path):
		return
	if d.open(path) != OK:
		return
	d.list_dir_begin(true, true)
	while true:
		var name = d.get_next()
		if name == "":
			break
		var child = path.plus_file(name)
		if d.current_is_dir():
			_remove_dir_recursive(child)
		else:
			d.remove(child)
	d.list_dir_end()
	d.remove(path)


func _require(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	printerr("v3 mod procedure smoke failed: %s" % message)
	quit(1)
