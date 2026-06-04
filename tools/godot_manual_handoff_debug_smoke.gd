extends SceneTree

# Headless UI smoke for the shipped Playtest tab manual handoff workflow.
# It uses a fake packaged C-AOL install and fake startup_harness.py so the test
# clicks the launcher controls without launching the real game.

var _had_failure := false

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings = root.get_node("/root/Settings")
	var helpers = root.get_node("/root/Helpers")
	settings.store("game", "caol")
	settings.store("active_install_caol", "Manual Handoff Sandbox")
	settings.store("backend_python_path", "python3")

	var install_dir = root.get_node("/root/Paths").own_dir.plus_file("caol").plus_file("game0")
	_mkdir(install_dir)
	_require(helpers.save_to_json_file({"name": "Manual Handoff Sandbox"}, install_dir.plus_file("catapult_install_info.json")), "could not create sandbox install info")
	_write_fake_harness(install_dir)

	var ui_script = load("res://scripts/Debug.gd")
	var ui = VBoxContainer.new()
	ui.set_script(ui_script)
	root.add_child(ui)
	yield(self, "idle_frame")
	yield(_wait_for_manual_load(ui), "completed")

	_require(ui._manual_scenarios.size() == 1, "Playtest tab did not filter to exactly one manual scenario")
	_require(ui._manual_scenarios[0].get("name", "") == "manual.intact_camp_shakedown_mcw", "manual scenario name mismatch")
	_require(ui._scenario_list.get_item_count() == 1, "manual scenario list item count mismatch")
	_require(ui._details_label.text.find("Does the staged scene make sense?") >= 0, "manual playtest question did not render")
	_require(ui._details_label.text.find("Automated") < 0, "automated/probe scenario leaked into details")

	ui._on_CopyHandoffCommand_pressed()
	var copied = OS.get_clipboard()
	_require(copied.find("handoff") >= 0 and copied.find("manual.intact_camp_shakedown_mcw") >= 0, "copy command did not include handoff scenario")
	_require(copied.find("--launch-only") >= 0, "copy command did not request launch-only manual handoff")
	_require(copied.find("probe") < 0, "copy command exposed probe mode")

	ui._validate_button.emit_signal("pressed")
	yield(_wait_for_status(ui, ["Validation passed", "Validation failed"]), "completed")
	_require(ui._output_box.text.find("\"dry_run\": true") >= 0, "validate setup did not dry-run the handoff contract")
	_require(ui._status_label.text.find("Validation passed") >= 0, "validate setup did not report success")

	ui._handoff_button.emit_signal("pressed")
	yield(_wait_for_status(ui, ["Handoff started", "Handoff failed"]), "completed")
	_require(ui._last_report_path.ends_with("handoff.report.json"), "handoff did not record report path")
	_require(ui._open_report_button.disabled == false, "open report button did not enable after handoff")
	_require(ui._status_label.text.find("left running for human testing") >= 0, "handoff success text did not say game is left running")
	_require(ui._output_box.text.find("\"mode\": \"handoff\"") >= 0, "handoff output did not stay in handoff mode")
	_require(ui._output_box.text.find("\"probe\"") < 0, "handoff output exposed probe mode")
	if _had_failure:
		return

	print("Manual handoff Playtest tab smoke passed")
	print("  refresh: packaged manual scenarios loaded from fake active install")
	print("  filter: automated/probe scenario hidden from shipped UI")
	print("  controls: copy command, validate setup, and start handoff exercised")
	print("  result: handoff report path captured and report button enabled")
	quit(0)


func _wait_until_idle(ui: Node):
	for _i in range(120):
		yield(self, "idle_frame")
		if not ui._busy:
			return true
	_require(false, "Playtest tab command did not finish")
	return false


func _wait_for_manual_load(ui: Node):
	for _i in range(240):
		yield(self, "idle_frame")
		if not ui._busy and ui._manual_scenarios.size() > 0:
			return true
		if not ui._busy and ui._status_label.text.find("No manual handoff scenarios") >= 0:
			break
		if not ui._busy and ui._status_label.text.find("Could not list manual scenarios") >= 0:
			break
	_require(false, "Playtest tab did not finish loading manual scenarios")
	return false


func _wait_for_status(ui: Node, phrases: Array):
	for _i in range(240):
		yield(self, "idle_frame")
		if ui._busy:
			continue
		for phrase in phrases:
			if ui._status_label.text.find(str(phrase)) >= 0:
				return true
	_require(false, "Playtest tab did not reach expected status: %s" % PoolStringArray(phrases).join(", "))
	return false


func _write_fake_harness(install_dir: String) -> void:
	var harness_dir = install_dir.plus_file("tools").plus_file("openclaw_harness")
	var scenario_dir = harness_dir.plus_file("scenarios")
	_mkdir(scenario_dir)
	var helpers = root.get_node("/root/Helpers")
	_require(helpers.save_to_json_file({
		"name": "manual.intact_camp_shakedown_mcw",
		"description": "Manual playtest handoff: fake staged bandit camp pressure.",
		"manual_playtest": {
			"question": "Does the staged scene make sense?",
			"tester_notes": ["Play naturally.", "Save if the outcome is interesting."]
		}
	}, scenario_dir.plus_file("manual.intact_camp_shakedown_mcw.json")), "could not write fake manual scenario")

	var req = File.new()
	_require(req.open(harness_dir.plus_file("requirements.txt"), File.WRITE) == OK, "could not write fake requirements")
	req.store_string("# fake stdlib-only requirements\n")
	req.close()

	var script = File.new()
	_require(script.open(harness_dir.plus_file("startup_harness.py"), File.WRITE) == OK, "could not write fake harness script")
	script.store_string("""#!/usr/bin/env python3
import json
import sys
from pathlib import Path

root = Path(__file__).resolve().parent
scenario_path = root / "scenarios" / "manual.intact_camp_shakedown_mcw.json"

if len(sys.argv) >= 2 and sys.argv[1] == "list-scenarios":
    print(json.dumps({
        "scenarios": [
            {
                "name": "manual.intact_camp_shakedown_mcw",
                "path": str(scenario_path),
                "description": "Manual playtest handoff: fake staged bandit camp pressure.",
                "status": "active",
                "step_count": 1
            },
            {
                "name": "bandit.extortion_first_demand_pay_mcw",
                "path": str(root / "scenarios" / "bandit.extortion_first_demand_pay_mcw.json"),
                "description": "Automated probe scenario.",
                "status": "active",
                "step_count": 8
            }
        ]
    }))
    raise SystemExit(0)

if len(sys.argv) >= 4 and sys.argv[1] == "handoff":
    scenario = sys.argv[2]
    run_dir = root / "runs" / "manual"
    run_dir.mkdir(parents=True, exist_ok=True)
    report = run_dir / "handoff.report.json"
    payload = {
        "ok": True,
        "mode": "handoff",
        "scenario": scenario,
        "dry_run": "--dry-run" in sys.argv,
        "run_dir": str(run_dir),
        "report_path": str(report)
    }
    if "--dry-run" not in sys.argv:
        report.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print(json.dumps(payload, indent=2))
    raise SystemExit(0)

print("unexpected fake harness args: " + repr(sys.argv), file=sys.stderr)
raise SystemExit(2)
""")
	script.close()


func _mkdir(path: String) -> void:
	var err = Directory.new().make_dir_recursive(path)
	_require(err == OK or err == ERR_ALREADY_EXISTS, "could not create directory: %s" % path)


func _require(condition: bool, message: String) -> void:
	if not condition:
		_had_failure = true
		push_error(message)
		print("Manual handoff Playtest tab smoke failed: %s" % message)
		quit(1)
