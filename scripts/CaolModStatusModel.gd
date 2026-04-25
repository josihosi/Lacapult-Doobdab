extends Node

# Read-only C-AOL mod/Summarizer discovery model.
# This is the Godot-side shape that the Mods/Settings UX can render in later slices.
# It deliberately does not install, enable, generate, apply, or mutate user data.

const SUMMARY_SHORT_REL := "npcs/Backgrounds/Summaries_short"
const SUMMARY_EXTRA_REL := "npcs/Backgrounds/Summaries_extra"

const NPC_TYPES := ["npc", "npc_class", "npc_template", "talk_topic", "mission_definition", "npc_personality_summary", "npc_personality_summary_bundle"]
const FACTION_TYPES := ["faction", "faction_template"]
const MONSTER_TYPES := ["MONSTER", "monster", "monstergroup", "SPECIES", "monster_attack"]
const ITEM_TYPES := ["AMMO", "ARMOR", "BIONIC_ITEM", "BOOK", "COMESTIBLE", "ENGINE", "GENERIC", "GUN", "GUNMOD", "ITEM_CATEGORY", "MAGAZINE", "PET_ARMOR", "TOOL", "TOOL_ARMOR", "WHEEL", "json_flag", "vehicle_part"]
const LOCATION_TYPES := ["city_building", "furniture", "map_extra", "mapgen", "overmap_special", "overmap_terrain", "palette", "region_settings", "terrain", "trap"]
const MECHANIC_TYPES := ["achievement", "effect_on_condition", "event_transformation", "field_type", "harvest", "martial_art", "mutation", "profession", "recipe", "recipe_category", "scenario", "skill", "snippet", "speech", "technique", "vehicle"]


func build_current_status(world_name := "") -> Dictionary:
	var paths = get_node_or_null("/root/Paths")
	if paths == null:
		return {"model": "caol_mod_summarizer_status", "version": 1, "read_only": true, "mods": [], "counts": {}, "world": {"errors": ["Paths autoload is unavailable"]}}
	return build_status(paths.mods_stock, paths.mods_user, paths.mod_repo, paths.savegames, world_name)


func build_status(stock_mods_dir: String, user_mods_dir: String, custom_catalog_dir: String, save_dir: String, world_name := "") -> Dictionary:
	var world = _read_world_mods(save_dir, world_name)
	var world_custom_dir = ""
	if world.get("world_path", "") != "":
		world_custom_dir = String(world["world_path"]).plus_file("mods")

	var records := []
	records += _scan_mod_root(stock_mods_dir, "stock")
	records += _scan_mod_root(user_mods_dir, "user")
	records += _scan_mod_root(custom_catalog_dir, "custom-catalog")
	records += _scan_mod_root(world_custom_dir, "world-custom")

	var installed_ids := []
	for record in records:
		if record.get("source_type", "") != "custom-catalog":
			installed_ids.append(record.get("id", ""))

	var enabled_ids = world.get("enabled_mod_ids", [])

	for record in records:
		var id = record.get("id", "")
		var source_type = record.get("source_type", "")
		if source_type == "custom-catalog":
			record["enabled_status"] = "catalog-untested"
		elif enabled_ids.has(id):
			record["enabled_status"] = "enabled-in-world"
		else:
			record["enabled_status"] = "disabled"

		var missing_deps := []
		var disabled_deps := []
		for dep in record.get("dependencies", []):
			if not installed_ids.has(dep):
				missing_deps.append(dep)
			elif not enabled_ids.has(dep):
				disabled_deps.append(dep)
		record["dependency_status"] = "dependency-ok" if missing_deps.empty() and disabled_deps.empty() else "dependency-blocked"
		record["missing_dependencies"] = missing_deps
		record["disabled_dependencies"] = disabled_deps
		record["obsolete_status"] = "obsolete-blocked" if record.get("obsolete", false) else "not-obsolete"

	var generated_by_source := {}
	for record in records:
		var generated = record.get("generated_summary_pack", {})
		var source_id = generated.get("source_mod_id", "")
		if source_id != "":
			if not generated_by_source.has(source_id):
				generated_by_source[source_id] = []
			generated_by_source[source_id].append(record)

	for record in records:
		record["summary_status"] = _summarize_record(record, generated_by_source)
		record["status_badges"] = [record["source_status"], record["enabled_status"], record["obsolete_status"], record["metadata_status"], record["dependency_status"], record["summary_status"]]
		if record.get("generated_summary_pack", {}).get("present", false):
			record["status_badges"].append("generated-summary-pack-present")

	return {
		"model": "caol_mod_summarizer_status",
		"version": 1,
		"read_only": true,
		"world": world,
		"paths": {
			"stock_mods": stock_mods_dir,
			"user_mods": user_mods_dir,
			"custom_catalog": custom_catalog_dir,
			"save_dir": save_dir,
			"world_custom_mods": world_custom_dir,
		},
		"counts": _count_badges(records),
		"mods": records,
	}


func _scan_mod_root(root: String, source_type: String) -> Array:
	var d = Directory.new()
	if root == "" or not d.dir_exists(root):
		return []
	var records := []
	for name in _list_dir(root):
		var mod_dir = root.plus_file(name)
		if not d.dir_exists(mod_dir):
			continue
		var modinfo = _read_modinfo(mod_dir)
		var json_content = _scan_json_content(mod_dir)
		var generated_manifest = null
		if json_content["generated_manifests"].size() > 0:
			generated_manifest = json_content["generated_manifests"][0]
		records.append({
			"id": modinfo["id"],
			"name": modinfo["name"],
			"dir": name,
			"path": mod_dir,
			"source_type": source_type,
			"source_status": _source_status(source_type),
			"category": modinfo.get("category", null),
			"dependencies": modinfo.get("dependencies", []),
			"obsolete": modinfo.get("obsolete", false),
			"metadata_status": "metadata-broken" if modinfo.get("modinfo_parse_error", "") != "" else "metadata-ok",
			"metadata_errors": [modinfo.get("modinfo_parse_error", "")] if modinfo.get("modinfo_parse_error", "") != "" else [],
			"summary_roots": _scan_summary_roots(mod_dir),
			"json_content": json_content,
			"generated_summary_pack": {
				"present": generated_manifest != null,
				"manifest": generated_manifest,
				"source_mod_id": generated_manifest.get("source_mod_id", "") if generated_manifest != null else "",
			},
			"source_fingerprint": _tree_fingerprint(mod_dir),
		})
	return records


func _source_status(source_type: String) -> String:
	if source_type == "stock":
		return "stock-packaged"
	if source_type == "user":
		return "user-installed"
	if source_type == "custom-catalog":
		return "custom-catalog"
	if source_type == "world-custom":
		return "world-specific-custom"
	return source_type


func _read_modinfo(mod_dir: String) -> Dictionary:
	var modinfo = mod_dir.plus_file("modinfo.json")
	var f = File.new()
	if not f.file_exists(modinfo):
		return {"id": mod_dir.get_file(), "name": mod_dir.get_file(), "modinfo_present": false, "modinfo_parse_error": "modinfo.json is missing", "dependencies": [], "obsolete": false}
	var data = _load_json(modinfo)
	if data.has("error"):
		return {"id": mod_dir.get_file(), "name": mod_dir.get_file(), "modinfo_present": true, "modinfo_parse_error": data["error"], "dependencies": [], "obsolete": false}
	var entries = data["data"] if typeof(data["data"]) == TYPE_ARRAY else [data["data"]]
	for entry in entries:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if entry.get("type", "MOD_INFO") != "MOD_INFO":
			continue
		var id = entry.get("id", entry.get("ident", mod_dir.get_file()))
		return {"id": str(id), "name": str(entry.get("name", id)), "category": entry.get("category", null), "modinfo_present": true, "modinfo_parse_error": "", "dependencies": _normalized_dependencies(entry.get("dependencies", [])), "obsolete": entry.get("obsolete", false)}
	return {"id": mod_dir.get_file(), "name": mod_dir.get_file(), "modinfo_present": true, "modinfo_parse_error": "modinfo.json contains no MOD_INFO entry", "dependencies": [], "obsolete": false}


func _read_world_mods(save_dir: String, world_name := "") -> Dictionary:
	var d = Directory.new()
	if save_dir == "" or not d.dir_exists(save_dir):
		return {"world_name": null, "world_path": null, "mods_json_present": false, "enabled_mod_ids": [], "errors": []}
	var world_path = save_dir.plus_file(world_name) if world_name != "" else ""
	if world_path == "" or not d.dir_exists(world_path):
		for candidate in _list_dir(save_dir):
			var candidate_path = save_dir.plus_file(candidate)
			if d.dir_exists(candidate_path) and d.file_exists(candidate_path.plus_file("mods.json")):
				world_path = candidate_path
				break
	if world_path == "":
		return {"world_name": null, "world_path": null, "mods_json_present": false, "enabled_mod_ids": [], "errors": []}
	var mods_json = world_path.plus_file("mods.json")
	if not d.file_exists(mods_json):
		return {"world_name": world_path.get_file(), "world_path": world_path, "mods_json_present": false, "enabled_mod_ids": [], "errors": ["mods.json is missing"]}
	var data = _load_json(mods_json)
	if data.has("error"):
		return {"world_name": world_path.get_file(), "world_path": world_path, "mods_json_present": true, "enabled_mod_ids": [], "errors": [data["error"]]}
	if typeof(data["data"]) != TYPE_ARRAY:
		return {"world_name": world_path.get_file(), "world_path": world_path, "mods_json_present": true, "enabled_mod_ids": [], "errors": ["mods.json is not a JSON array"]}
	var ids := []
	for id in data["data"]:
		ids.append(str(id))
	return {"world_name": world_path.get_file(), "world_path": world_path, "mods_json_present": true, "enabled_mod_ids": ids, "errors": []}


func _scan_summary_roots(mod_dir: String) -> Dictionary:
	var short_dir = mod_dir.plus_file(SUMMARY_SHORT_REL)
	var extra_dir = mod_dir.plus_file(SUMMARY_EXTRA_REL)
	var files := []
	files += _list_files_recursive(short_dir)
	files += _list_files_recursive(extra_dir)
	var json_count := 0
	var txt_count := 0
	var samples := []
	for path in files:
		if String(path).ends_with(".json"):
			json_count += 1
		elif String(path).ends_with(".txt"):
			txt_count += 1
		if samples.size() < 12:
			samples.append(_relative_path(path, mod_dir))
	var d = Directory.new()
	return {"summaries_short_exists": d.dir_exists(short_dir), "summaries_extra_exists": d.dir_exists(extra_dir), "summary_file_count": files.size(), "summary_json_count": json_count, "summary_txt_count": txt_count, "summary_file_samples": samples}


func _scan_json_content(mod_dir: String) -> Dictionary:
	var files = _list_files_recursive(mod_dir)
	var type_counts := {}
	var parse_errors := []
	var manifests := []
	var parsed_files := 0
	for path in files:
		if not String(path).ends_with(".json"):
			continue
		var loaded = _load_json(path)
		if loaded.has("error"):
			parse_errors.append("%s: %s" % [_relative_path(path, mod_dir), loaded["error"]])
			continue
		parsed_files += 1
		var records = loaded["data"] if typeof(loaded["data"]) == TYPE_ARRAY else [loaded["data"]]
		for record in records:
			if typeof(record) != TYPE_DICTIONARY:
				continue
			var record_type = record.get("type", "")
			if record_type != "":
				type_counts[record_type] = type_counts.get(record_type, 0) + 1
			if record_type == "lacapult_summary_pack_manifest":
				var manifest = record.duplicate(true)
				manifest["path"] = _relative_path(path, mod_dir)
				manifests.append(manifest)
	return {"json_file_count": _count_json_files(files), "json_files_parsed": parsed_files, "json_parse_error_count": parse_errors.size(), "json_parse_errors_sample": parse_errors.slice(0, 11), "type_counts_sample": type_counts, "content_flags": _content_flags(type_counts), "generated_manifests": manifests}


func _summarize_record(record: Dictionary, generated_by_source: Dictionary) -> String:
	if record.get("metadata_status", "") == "metadata-broken":
		return "summary-unknown"
	if record.get("json_content", {}).get("json_parse_error_count", 0) > 0:
		return "summary-unknown"
	if record.get("obsolete", false):
		return "summary-not-needed"
	var summaries = record.get("summary_roots", {})
	var has_root = summaries.get("summaries_short_exists", false) or summaries.get("summaries_extra_exists", false)
	var has_summary_files = summaries.get("summary_file_count", 0) > 0
	var generated_packs = generated_by_source.get(record.get("id", ""), [])
	for pack in generated_packs:
		if pack.get("enabled_status", "") == "enabled-in-world" and pack.get("summary_roots", {}).get("summary_file_count", 0) > 0:
			return "summary-ready"
	if generated_packs.size() > 0:
		return "summary-partial"
	if has_summary_files:
		return "summary-ready"
	if has_root:
		return "summary-partial"
	var flags = record.get("json_content", {}).get("content_flags", {})
	for key in ["npc", "faction", "monster", "item", "location"]:
		if flags.get(key, false):
			return "summary-missing"
	return "summary-not-needed"


func _content_flags(type_counts: Dictionary) -> Dictionary:
	return {
		"npc": _any_type(type_counts, NPC_TYPES),
		"faction": _any_type(type_counts, FACTION_TYPES),
		"monster": _any_type(type_counts, MONSTER_TYPES),
		"item": _any_type(type_counts, ITEM_TYPES),
		"location": _any_type(type_counts, LOCATION_TYPES),
		"mechanic": _any_type(type_counts, MECHANIC_TYPES),
	}


func _any_type(type_counts: Dictionary, names: Array) -> bool:
	for name in names:
		if type_counts.get(name, 0) > 0:
			return true
	return false


func _load_json(path: String) -> Dictionary:
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		return {"error": "open failed: %s" % err}
	var parsed = JSON.parse(f.get_as_text())
	f.close()
	if parsed.error != OK:
		return {"error": "%s at line %s" % [parsed.error_string, parsed.error_line]}
	return {"data": parsed.result}


func _normalized_dependencies(value) -> Array:
	var result := []
	if typeof(value) != TYPE_ARRAY:
		return result
	for dep in value:
		result.append(str(dep))
	return result


func _tree_fingerprint(root: String) -> String:
	var f = File.new()
	var files = _list_files_recursive(root)
	files.sort()
	var parts := []
	for path in files:
		var size := 0
		if f.open(path, File.READ) == OK:
			size = f.get_len()
			f.close()
		parts.append("%s:%s" % [_relative_path(path, root), size])
	return "tree-size-list:" + String(parts).sha256_text()


func _count_badges(records: Array) -> Dictionary:
	var counts := {}
	for record in records:
		for badge in record.get("status_badges", []):
			counts[badge] = counts.get(badge, 0) + 1
	return counts


func _count_json_files(files: Array) -> int:
	var count := 0
	for path in files:
		if String(path).ends_with(".json"):
			count += 1
	return count


func _list_dir(path: String) -> Array:
	var d = Directory.new()
	if d.open(path) != OK:
		return []
	var result := []
	d.list_dir_begin(true, true)
	while true:
		var name = d.get_next()
		if name == "":
			break
		result.append(name)
	d.list_dir_end()
	result.sort()
	return result


func _list_files_recursive(path: String) -> Array:
	var d = Directory.new()
	if path == "" or not d.dir_exists(path):
		return []
	var result := []
	for name in _list_dir(path):
		var child = path.plus_file(name)
		if d.dir_exists(child):
			result += _list_files_recursive(child)
		elif d.file_exists(child):
			result.append(child)
	return result


func _relative_path(path: String, base: String) -> String:
	if path.begins_with(base.plus_file("")):
		return path.substr(base.length() + 1, path.length())
	return path
