#!/usr/bin/env python3
"""Static proof for API setup status-copy boundary.

The API setup confirmation path has two very different modes:
- proof mode records intent only and must say no venv/pip mutation happened;
- real mode can create/update the venv and run pip, and must not claim no
  external install/download happened.

This proof intentionally does not run Godot, pip, or any API call.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ui_path = ROOT / "scripts" / "BackendSetupUI.gd"
text = ui_path.read_text()
start = text.index("func _on_ExternalBackendAction_confirmed() -> void:")
block = text[start:]

required = [
    'post_message = "C-AOL API backend setup intent recorded in proof mode; no external install/download was performed."',
    'post_message = "C-AOL API backend setup command finished; venv and AnyLLM/provider packages were handled after confirmation. No API call or API-secret read was performed."',
    'post_message = "C-AOL API backend setup command failed during venv/package setup. No API call or API-secret read was performed." if not proof_only else',
    'Status.post(post_message)',
]
missing = [needle for needle in required if needle not in block]
if missing:
    raise SystemExit("API setup status-copy boundary proof failed; missing:\n" + "\n".join(missing))

bad_tail = 'Status.post("C-AOL backend setup confirmation recorded; no external install/download was performed.")'
if bad_tail in block:
    raise SystemExit("API setup status-copy boundary proof failed: unconditional no-external-install Status.post remains")

if block.index('post_message = "C-AOL API backend setup command finished;') > block.index('else:\n\t\t\t_set_backend_status("api"'):
    pass
else:
    raise SystemExit("API setup status-copy boundary proof failed: real install status message is not in the non-proof branch")

print("API setup status-copy boundary proof passed")
print("  proof mode status says no external install/download")
print("  real setup path status says venv and AnyLLM packages were handled")
print("  failure path says venv/package setup failed without API/secret use")
print("  no unconditional final no-external-install Status.post remains in the API confirmation block")
