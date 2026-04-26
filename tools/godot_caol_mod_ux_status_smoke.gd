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
		"Sandbox World",
		{"mode": "ollama", "status": "ollama_command_present_server_running_model_present model:fixture-llm"}
	)
	var overview = status_model.build_ux_overview(status)
	var dry_run = status_model.build_dry_run_summarizer_prompt(status, "ollama", "ollama_command_present_server_running_model_not_selected")
	var preview = status_model.build_generation_apply_plan(status, "", "ollama", "ollama_command_present_server_running_model_present model:fixture-llm", false)
	var confirmed_plan = status_model.build_generation_apply_plan(status, "", "ollama", "ollama_command_present_server_running_model_present model:fixture-llm", true)
	var blocked_backend_plan = status_model.build_generation_apply_plan(status, "", "ollama", "ollama_command_present_server_running_model_not_selected", true)
	var ok = _assert_ux_state(overview, dry_run, preview, confirmed_plan, blocked_backend_plan)
	if output_path != "":
		var f = File.new()
		var err = f.open(output_path, File.WRITE)
		if err == OK:
			f.store_string(JSON.print({"overview": overview, "dry_run": dry_run, "preview": preview, "confirmed_plan": confirmed_plan, "blocked_backend_plan": blocked_backend_plan}, "  "))
			f.close()
		else:
			printerr("failed to write UX output: %s" % err)
			ok = false
	print("godot caol mod UX status smoke: state=%s candidates=%s preview_action=%s confirmed_would_mutate=%s" % [overview.get("all_enabled_extra_context_state", "missing"), overview.get("summarizer_candidate_count", -1), preview.get("action", "missing"), confirmed_plan.get("would_mutate", false)])
	quit(0 if ok else 1)


func _assert_ux_state(overview: Dictionary, dry_run: Dictionary, preview: Dictionary, confirmed_plan: Dictionary, blocked_backend_plan: Dictionary) -> bool:
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
	if preview.get("action", "") != "caol_summarizer_generation_apply_plan_v0":
		printerr("preview action is wrong: %s" % preview.get("action", "missing"))
		return false
	if preview.get("would_mutate", true) or preview.get("would_call_backend", true) or preview.get("confirmation_received", true):
		printerr("unconfirmed preview claims unsafe side effects")
		return false
	if preview.get("blocked_reasons", []).find("Explicit player confirmation is required before any generated pack or mods.json write.") < 0:
		printerr("unconfirmed preview does not require explicit confirmation")
		return false
	if confirmed_plan.get("would_mutate", false) != true or confirmed_plan.get("would_generate_pack", false) != true or confirmed_plan.get("would_enable_mods", false) != true:
		printerr("confirmed ready plan does not expose real apply side effects")
		return false
	if confirmed_plan.get("write_plan", {}).get("summaries_extra_json", "").find("npcs/Backgrounds/Summaries_extra") < 0:
		printerr("confirmed plan missing C-AOL native summary root")
		return false
	if confirmed_plan.get("write_plan", {}).get("planned_mod_order", []).find(confirmed_plan.get("companion_mod_id", "")) < 0:
		printerr("confirmed plan does not add companion mod to planned order")
		return false
	if blocked_backend_plan.get("would_mutate", true) or blocked_backend_plan.get("blocked_reasons", []).find("Backend generation is not ready; API/Ollama/OpenVINO readiness must pass before generation/apply.") < 0:
		printerr("backend-blocked plan is not safely blocked")
		return false
	return true
