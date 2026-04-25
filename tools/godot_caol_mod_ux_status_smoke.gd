extends SceneTree

# Headless Godot 3 smoke for Slice 2 C-AOL mod/Summarizer UX view state.
# It proves the rendered status text and dry-run action state from sandbox fixture
# data without calling a backend, generating packs, applying mods, or mutating saves.

func _init() -> void:
	var fixture_root = OS.get_environment("LACAPULT_CAOL_MOD_STATUS_FIXTURE")
	var output_path = OS.get_environment("LACAPULT_CAOL_MOD_UX_OUTPUT")
	if fixture_root == "":
		printerr("LACAPULT_CAOL_MOD_STATUS_FIXTURE is required")
		quit(2)
		return

	var status_model = get_root().get_node("CaolModStatus")
	var status = status_model.build_status(
		fixture_root.plus_file("game0/data/mods"),
		fixture_root.plus_file("userdata/mods"),
		fixture_root.plus_file("mod_repo"),
		fixture_root.plus_file("userdata/save"),
		"Sandbox World"
	)
	var overview = status_model.build_ux_overview(status)
	var dry_run = status_model.build_dry_run_summarizer_prompt(status, "ollama", "ollama_command_present_server_running_model_not_selected")
	var ok = _assert_ux_state(overview, dry_run)
	if output_path != "":
		var f = File.new()
		var err = f.open(output_path, File.WRITE)
		if err == OK:
			f.store_string(JSON.print({"overview": overview, "dry_run": dry_run}, "  "))
			f.close()
		else:
			printerr("failed to write UX output: %s" % err)
			ok = false
	print("godot caol mod UX status smoke: state=%s candidates=%s read_only=%s" % [overview.get("all_enabled_extra_context_state", "missing"), overview.get("summarizer_candidate_count", -1), dry_run.get("read_only", false)])
	quit(0 if ok else 1)


func _assert_ux_state(overview: Dictionary, dry_run: Dictionary) -> bool:
	if overview.get("all_enabled_extra_context_state", "") != "needs-summaries":
		printerr("expected needs-summaries state, got %s" % overview.get("all_enabled_extra_context_state", "missing"))
		return false
	if overview.get("summarizer_candidate_count", 0) < 1:
		printerr("expected at least one dry-run Summarizer candidate")
		return false
	if overview.get("status_text", "").find("Read-only C-AOL mod/Summarizer status") < 0:
		printerr("overview status text is not renderable")
		return false
	if dry_run.get("action", "") != "summarizer_dry_run_status_only":
		printerr("dry-run action is wrong: %s" % dry_run.get("action", "missing"))
		return false
	if dry_run.get("would_mutate", true) or dry_run.get("would_call_backend", true) or dry_run.get("would_generate_pack", true) or dry_run.get("would_enable_mods", true):
		printerr("dry-run action claims unsafe side effects")
		return false
	if dry_run.get("message", "").find("Dry-run only") < 0:
		printerr("dry-run message does not expose status-only boundary")
		return false
	return true
