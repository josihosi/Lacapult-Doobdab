extends SceneTree

# Headless Godot 3 smoke for Slice 6 confirmed Summarizer writer/apply seam.
# It builds a tiny C-AOL-like install/userdata tree inside the isolated HOME,
# applies a generated companion summary pack only after explicit confirmation,
# and verifies backup/rollback visibility without touching real user state.

func _init() -> void:
	var home = OS.get_environment("HOME")
	var output_path = OS.get_environment("LACAPULT_CAOL_SUMMARIZER_APPLY_OUTPUT")
	var ollama_model = OS.get_environment("LACAPULT_TEST_OLLAMA_MODEL")
	if home == "" or home.find("/tmp/lacapult-summarizer-apply-home.") != 0:
		_fail("HOME must be an isolated /tmp/lacapult-summarizer-apply-home.* path for this smoke")
		return
	if ollama_model == "":
		_fail("LACAPULT_TEST_OLLAMA_MODEL must name an already-local Ollama model; this smoke never pulls models")
		return

	var settings = get_root().get_node("Settings")
	var paths = get_root().get_node("Paths")
	_build_fixture(paths)
	settings.store("game", "caol")
	settings.store("active_install_caol", "Sandbox C-AOL")
	settings.store("backend_mode", "ollama")
	settings.store("backend_ollama_model", ollama_model)

	var mods = load("res://scripts/ModManager.gd").new()
	get_root().add_child(mods)
	var preview = mods.get_caol_summarizer_apply_preview("Sandbox World", "fixture_world_custom", false)
	if preview.get("would_mutate", true):
		_fail("unconfirmed preview claimed mutation")
		return
	if preview.get("blocked_reasons", []).find("Explicit player confirmation is required before any generated pack or mods.json write.") < 0:
		_fail("unconfirmed preview did not require explicit confirmation")
		return

	var result = mods.apply_caol_summarizer_generated_pack("Sandbox World", "fixture_world_custom", true, [_generated_entry()])
	if not result.get("applied", false):
		_fail("confirmed apply did not apply: %s" % result.get("message", "missing message"))
		return
	if not result.get("rollback_visible", false):
		_fail("apply result did not expose rollback visibility")
		return

	var details = result.get("details", {})
	var companion_dir = str(details.get("companion_pack_dir", ""))
	var summary_json = str(details.get("summaries_extra_json", ""))
	var manifest_json = str(details.get("manifest_json", ""))
	var mods_json = str(details.get("mods_json", ""))
	var backup_dir = str(details.get("backup_dir", ""))
	var d = Directory.new()
	if not companion_dir.begins_with(home):
		_fail("companion dir escaped isolated HOME: %s" % companion_dir)
		return
	if not d.file_exists(summary_json) or summary_json.find("npcs/Backgrounds/Summaries_extra") < 0:
		_fail("native Summaries_extra JSON was not written")
		return
	if not d.file_exists(manifest_json):
		_fail("manifest JSON was not written")
		return
	if not d.file_exists(backup_dir.plus_file("mods.json.before.exact")):
		_fail("mods.json exact backup is missing")
		return
	if not d.file_exists(backup_dir.plus_file("summary_pack.before.missing.json")):
		_fail("missing-pack backup marker is missing")
		return

	var order = _read_json(mods_json)
	if typeof(order) != TYPE_ARRAY:
		_fail("mods.json after apply is not an array")
		return
	var source_index = order.find("fixture_world_custom")
	var companion_index = order.find("lacapult_summary_fixture_world_custom")
	if source_index < 0 or companion_index <= source_index:
		_fail("companion summary mod was not ordered after source mod: %s" % JSON.print(order))
		return

	var applied_status = mods.get_caol_mod_summarizer_status("Sandbox World")
	var source = _find_record(applied_status, "fixture_world_custom", "world-custom")
	var companion = _find_record(applied_status, "lacapult_summary_fixture_world_custom", "user")
	if source.empty() or source.get("summary_status", "") != "summary-ready":
		_fail("source is not summary-ready after apply")
		return
	if companion.empty() or companion.get("enabled_status", "") != "enabled-in-world":
		_fail("companion pack is not visible/enabled after apply")
		return

	if output_path != "":
		_write_json(output_path, {"preview": preview, "result": result, "applied_status": applied_status})
	print("godot caol summarizer apply smoke: applied=true companion=%s backup=%s" % [companion_dir, backup_dir])
	quit(0)


func _build_fixture(paths: Node) -> void:
	var own = paths.own_dir
	var game_dir = own.plus_file("caol").plus_file("game0")
	var stock = game_dir.plus_file("data").plus_file("mods")
	var user = own.plus_file("caol").plus_file("userdata").plus_file("mods")
	var world = own.plus_file("caol").plus_file("userdata").plus_file("save").plus_file("Sandbox World")
	_mkdir(stock.plus_file("fixture_no_summary_needed"))
	_mkdir(world.plus_file("mods").plus_file("fixture_world_custom"))
	_mkdir(user)
	_write_json(game_dir.plus_file("catapult_install_info.json"), {"name": "Sandbox C-AOL"})
	_write_json(stock.plus_file("fixture_no_summary_needed").plus_file("modinfo.json"), _modinfo("fixture_no_summary_needed", "Fixture No Summary Needed"))
	_write_json(world.plus_file("mods").plus_file("fixture_world_custom").plus_file("modinfo.json"), _modinfo("fixture_world_custom", "Fixture World Custom"))
	_write_json(world.plus_file("mods").plus_file("fixture_world_custom").plus_file("factions").plus_file("context.json"), [{"type": "faction", "id": "fixture_world_faction"}])
	_write_json(world.plus_file("mods.json"), ["fixture_no_summary_needed", "fixture_world_custom"])


func _modinfo(mod_id: String, name: String) -> Dictionary:
	return {"type": "MOD_INFO", "id": mod_id, "name": name, "category": "content", "dependencies": []}


func _generated_entry() -> Dictionary:
	return {
		"type": "npc_personality_summary",
		"selector": "fixture_world_custom:guide",
		"topic": "fixture_world_custom_world_context",
		"your_background": "You know the sandbox world's custom faction context from the generated Lacapult companion pack.",
		"your_expression": "Mention the sandbox faction only as proof-context.",
		"source_tag": "lacapult-generated:fixture_world_custom",
	}


func _find_record(status: Dictionary, mod_id: String, source_type: String) -> Dictionary:
	for record in status.get("mods", []):
		if record.get("id", "") == mod_id and record.get("source_type", "") == source_type:
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


func _fail(message: String) -> void:
	printerr(message)
	quit(1)
