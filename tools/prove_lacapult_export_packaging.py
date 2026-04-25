#!/usr/bin/env python3
"""Local release-prep export proof for Lacapult Doobdab.

This intentionally does not publish a GitHub release, sign/notarize builds, use
API secrets, install runtimes, or pull models. It creates a temporary
``export_presets.cfg`` at the Godot project root, exports platform PCK packs into
``.proof-cache/``, restores any previous preset file, and reports whether full
app exports are blocked by missing Godot export templates.

Why PCK packs first? Godot can produce them without platform export templates, so
this gives a repeatable local packaging/config sanity proof even when the actual
macOS/Linux/Windows release binaries cannot honestly be built on the machine yet.
"""

from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
PRESET_FILE = ROOT / "export_presets.cfg"
OUTPUT_ROOT = ROOT / ".proof-cache" / "lacapult-export"

PACK_PRESETS = [
    ("macOS Pack", "Mac OSX", "Lacapult-Doobdab-macos.pck"),
    ("Linux Pack", "Linux/X11", "Lacapult-Doobdab-linux.pck"),
    ("Windows Pack", "Windows Desktop", "Lacapult-Doobdab-windows.pck"),
]

APP_EXPORTS = {
    "macos": {
        "preset": "macOS App",
        "platform": "Mac OSX",
        "path": "app/Lacapult Doobdab.app",
        "required_templates": ["osx.zip"],
    },
    "linux": {
        "preset": "Linux App",
        "platform": "Linux/X11",
        "path": "app/Lacapult-Doobdab.x86_64",
        "required_templates": ["linux_x11_64_release"],
    },
    "windows": {
        "preset": "Windows App",
        "platform": "Windows Desktop",
        "path": "app/Lacapult-Doobdab.exe",
        "required_templates": ["windows_64_release.exe"],
    },
}


def run(cmd: list[str], log_path: Path | None = None) -> subprocess.CompletedProcess[str]:
    proc = subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if log_path is not None:
        log_path.parent.mkdir(parents=True, exist_ok=True)
        log_path.write_text(proc.stdout, encoding="utf-8")
    return proc


def find_godot() -> str:
    override = os.environ.get("GODOT_BIN")
    if override:
        return override
    for name in ("godot", "godot3", "/opt/homebrew/bin/godot"):
        path = shutil.which(name) if not name.startswith("/") else name
        if path and Path(path).exists():
            return path
    raise SystemExit("missing Godot binary: set GODOT_BIN or install Godot 3.x")


def godot_version(godot: str) -> str:
    proc = run([godot, "--version"])
    if proc.returncode != 0:
        raise SystemExit(proc.stdout.strip() or "could not run godot --version")
    return proc.stdout.strip().splitlines()[-1]


def template_version_candidates(version: str) -> list[str]:
    # Godot 3.x template dirs are usually e.g. "3.6.2.stable". Keep a few
    # harmless candidates because Homebrew/package builds sometimes append tags.
    parts = version.split(".")
    candidates = []
    if len(parts) >= 4:
        candidates.append(".".join(parts[:4]))
    if len(parts) >= 5:
        candidates.append(".".join(parts[:5]))
    candidates.append(version)
    seen = []
    for item in candidates:
        if item not in seen:
            seen.append(item)
    return seen


def template_roots(version: str) -> list[Path]:
    home = Path.home()
    bases = [
        home / "Library" / "Application Support" / "Godot" / "templates",
        home / "Library" / "Application Support" / "Godot" / "export_templates",
        home / ".local" / "share" / "godot" / "templates",
        home / ".godot" / "templates",
    ]
    roots = []
    for base in bases:
        for candidate in template_version_candidates(version):
            roots.append(base / candidate)
    return roots


def inspect_templates(version: str) -> dict[str, Any]:
    roots = template_roots(version)
    existing_roots = [root for root in roots if root.exists()]
    files = {str(path) for root in existing_roots for path in root.glob("*") if path.is_file()}
    per_platform: dict[str, Any] = {}
    for platform, spec in APP_EXPORTS.items():
        missing = []
        found = []
        for name in spec["required_templates"]:
            matches = [path for path in files if Path(path).name == name]
            if matches:
                found.extend(matches)
            else:
                missing.append(name)
        per_platform[platform] = {"found": found, "missing": missing, "ready": not missing}
    return {
        "version_candidates": template_version_candidates(version),
        "checked_roots": [str(root) for root in roots],
        "existing_roots": [str(root) for root in existing_roots],
        "platforms": per_platform,
        "all_app_templates_ready": all(item["ready"] for item in per_platform.values()),
    }


def preset_block(index: int, name: str, platform: str, export_path: str, app: bool = False) -> str:
    common = f'''[preset.{index}]
name="{name}"
platform="{platform}"
runnable={"true" if app else "false"}
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="{export_path}"
script_export_mode=1
script_encryption_key=""

[preset.{index}.options]
custom_template/debug=""
custom_template/release=""
'''
    if platform == "Mac OSX":
        return common + '''application/name="Lacapult Doobdab"
application/info="C-AOL launcher and installer"
application/icon="res://icons/appicon.icns"
application/identifier="at.schanigarten.lacapult-doobdab"
application/signature=""
application/short_version="0.2.0-prep"
application/version="0.2.0-prep"
application/copyright="MIT; see LICENSE and ATTRIBUTION.md"
display/high_res=true
privacy/camera_usage_description=""
privacy/microphone_usage_description=""
codesign/enable=false
codesign/identity=""
codesign/timestamp=true
codesign/hardened_runtime=false
codesign/entitlements=""

'''
    if platform == "Linux/X11":
        return common + '''binary_format/64_bits=true
binary_format/embed_pck=true
texture_format/bptc=false
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
texture_format/no_bptc_fallbacks=true

'''
    return common + '''binary_format/64_bits=true
binary_format/embed_pck=true
texture_format/bptc=false
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
texture_format/no_bptc_fallbacks=true
codesign/enable=false
codesign/identity_type=0
codesign/identity=""
codesign/password=""
codesign/timestamp=true
codesign/timestamp_server_url=""

'''


def generated_presets() -> str:
    blocks = []
    index = 0
    for name, platform, filename in PACK_PRESETS:
        blocks.append(preset_block(index, name, platform, str(OUTPUT_ROOT / "packs" / filename)))
        index += 1
    for spec in APP_EXPORTS.values():
        blocks.append(preset_block(index, spec["preset"], spec["platform"], str(OUTPUT_ROOT / spec["path"]), app=True))
        index += 1
    return "".join(blocks)


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def artifact(path: Path) -> dict[str, Any]:
    return {
        "path": str(path.relative_to(ROOT)),
        "bytes": path.stat().st_size,
        "sha256": sha256(path),
    }


def export_pack(godot: str, preset: str, path: Path) -> dict[str, Any]:
    path.parent.mkdir(parents=True, exist_ok=True)
    log_path = OUTPUT_ROOT / "logs" / f"{preset.replace(' ', '-')}.log"
    proc = run([godot, "--path", ".", "--no-window", "--export-pack", preset, str(path)], log_path)
    result = {"preset": preset, "returncode": proc.returncode, "log": str(log_path.relative_to(ROOT))}
    if proc.returncode == 0 and path.exists():
        result["artifact"] = artifact(path)
    else:
        result["tail"] = "\n".join(proc.stdout.splitlines()[-40:])
    return result


def export_app(godot: str, preset: str, path: Path) -> dict[str, Any]:
    path.parent.mkdir(parents=True, exist_ok=True)
    log_path = OUTPUT_ROOT / "logs" / f"{preset.replace(' ', '-')}.log"
    proc = run([godot, "--path", ".", "--no-window", "--export", preset, str(path)], log_path)
    result = {"preset": preset, "returncode": proc.returncode, "log": str(log_path.relative_to(ROOT))}
    if proc.returncode == 0 and path.exists():
        result["artifact_path"] = str(path.relative_to(ROOT))
    else:
        result["tail"] = "\n".join(proc.stdout.splitlines()[-40:])
    return result


def main() -> int:
    godot = find_godot()
    version = godot_version(godot)
    templates = inspect_templates(version)
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)

    previous = PRESET_FILE.read_text(encoding="utf-8", errors="replace") if PRESET_FILE.exists() else None
    wrote_temp = False
    try:
        PRESET_FILE.write_text(generated_presets(), encoding="utf-8")
        wrote_temp = True

        pack_results = []
        for preset, _platform, filename in PACK_PRESETS:
            pack_results.append(export_pack(godot, preset, OUTPUT_ROOT / "packs" / filename))

        app_results: list[dict[str, Any]] = []
        skipped_app_exports = []
        for platform, spec in APP_EXPORTS.items():
            state = templates["platforms"][platform]
            if not state["ready"]:
                skipped_app_exports.append(
                    {
                        "platform": platform,
                        "preset": spec["preset"],
                        "reason": "missing Godot export template(s)",
                        "missing_templates": state["missing"],
                    }
                )
                continue
            app_results.append(export_app(godot, spec["preset"], OUTPUT_ROOT / spec["path"]))

        proof = {
            "godot": godot,
            "godot_version": version,
            "output_root": str(OUTPUT_ROOT.relative_to(ROOT)),
            "temporary_export_presets_restored": True,
            "template_probe": templates,
            "pack_exports": pack_results,
            "app_exports": app_results,
            "skipped_app_exports": skipped_app_exports,
        }
        manifest = OUTPUT_ROOT / "manifest.json"
        manifest.write_text(json.dumps(proof, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(json.dumps(proof, indent=2, sort_keys=True))

        failed_packs = [item for item in pack_results if item.get("returncode") != 0 or "artifact" not in item]
        failed_apps = [item for item in app_results if item.get("returncode") != 0]
        if failed_packs or failed_apps:
            return 1
        return 0
    finally:
        if wrote_temp:
            if previous is None:
                try:
                    PRESET_FILE.unlink()
                except FileNotFoundError:
                    pass
            else:
                PRESET_FILE.write_text(previous, encoding="utf-8")


if __name__ == "__main__":
    raise SystemExit(main())
