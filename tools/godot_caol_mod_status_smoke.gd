extends SceneTree

# Headless Godot 3 smoke for the C-AOL mod/Summarizer status model.
# Expects tools/prove_caol_mod_status_model.py to create the ignored fixture first.

func _init() -> void:
	var fixture_root = OS.get_environment("LACAPULT_CAOL_MOD_STATUS_FIXTURE")
	var output_path = OS.get_environment("LACAPULT_CAOL_MOD_STATUS_GODOT_OUTPUT")
	if fixture_root == "":
		printerr("LACAPULT_CAOL_MOD_STATUS_FIXTURE is required")
		quit(2)
		return
	var status_model = get_root().get_node("CaolModStatus")
	var result = status_model.build_status(
		fixture_root.plus_file("game0/data/mods"),
		fixture_root.plus_file("userdata/mods"),
		fixture_root.plus_file("mod_repo"),
		fixture_root.plus_file("userdata/save"),
		"Sandbox World"
	)
	var ok = _assert_status(result)
	var overview = status_model.build_ux_overview(result)
	var prompt = status_model.build_dry_run_summarizer_prompt(result, "ollama", "fixture-ready")
	if overview.get("all_enabled_extra_context_state", "") != "needs-summaries":
		printerr("unexpected overview all-enabled state: %s" % overview.get("all_enabled_extra_context_state", ""))
		ok = false
	if prompt.get("would_mutate", true) or prompt.get("would_call_backend", true) or prompt.get("would_generate_pack", true):
		printerr("dry-run prompt is not read-only")
		ok = false
	if output_path != "":
		var f = File.new()
		var err = f.open(output_path, File.WRITE)
		if err == OK:
			f.store_string(JSON.print(result, "  "))
			f.close()
		else:
			printerr("failed to write status output: %s" % err)
			ok = false
	print("godot caol mod status smoke: mods=%s enabled=%s summary_ready=%s summary_missing=%s" % [result.get("mods", []).size(), result.get("counts", {}).get("enabled-in-world", 0), result.get("counts", {}).get("summary-ready", 0), result.get("counts", {}).get("summary-missing", 0)])
	quit(0 if ok == true else 1)


func _assert_status(result: Dictionary) -> bool:
	for target_id in ["magiclysm", "DinoMod"]:
		if not _has_catalog_target(result, target_id):
			printerr("missing C-AOL JSON catalog target %s" % target_id)
			return false
	var checks = [
		["fixture_context_stock", "stock", "summary-ready"],
		["fixture_user_context", "user", "summary-missing"],
		["fixture_catalog_context", "custom-catalog", "catalog-untested"],
		["fixture_world_custom", "world-custom", "enabled-in-world"],
		["fixture_obsolete", "stock", "obsolete-blocked"],
		["fixture_broken_metadata", "stock", "metadata-broken"],
		["fixture_missing_dep", "stock", "dependency-blocked"],
		["fixture_partial_summary", "stock", "summary-partial"],
		["magiclysm", "stock", "summary-missing"],
		["DinoMod", "stock", "summary-missing"],
		["lacapult_summary_fixture_context_stock", "user", "generated-summary-pack-present"],
	]
	for check in checks:
		if not _has_status(result, check[0], check[1], check[2]):
			printerr("missing status %s/%s -> %s" % [check[0], check[1], check[2]])
			return false
	return true


func _has_catalog_target(result: Dictionary, mod_id: String) -> bool:
	for target in result.get("json_catalog_targets", []):
		if target.get("id", "") == mod_id:
			return target.get("present", false) == true
	return false


func _has_status(result: Dictionary, mod_id: String, source_type: String, status: String) -> bool:
	for record in result.get("mods", []):
		if record.get("id", "") == mod_id and record.get("source_type", "") == source_type:
			if record.get("summary_status", "") == status:
				return true
			return record.get("status_badges", []).has(status)
	return false
