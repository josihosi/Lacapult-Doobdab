#!/usr/bin/env python3
"""Local release-prep export proof for Catapult-Dabubu.

This intentionally does not publish a GitHub release, sign/notarize builds, use
API secrets, install runtimes, or pull models. It creates a temporary
``export_presets.cfg`` at the Godot project root, exports platform PCK packs,
exports real unsigned app/executable artifacts when Godot templates are present,
creates unsigned archive/package shapes, writes a manifest with sizes/hashes and
shape checks under ``.proof-cache/``, then restores any previous preset file.

Why keep PCK packs too? Godot can produce them without platform export templates,
so they remain a useful baseline packaging/config sanity proof. The app/package
exports are the stronger local installability evidence once templates exist.
"""

from __future__ import annotations

import hashlib
import json
import os
import plistlib
import shutil
import subprocess
import sys
import tarfile
import zipfile
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
PRESET_FILE = ROOT / "export_presets.cfg"
OUTPUT_ROOT = ROOT / ".proof-cache" / "dabubu-export"

PACK_PRESETS = [
    ("macOS Pack", "Mac OSX", "Catapult-Dabubu-macos.pck"),
    ("Linux Pack", "Linux/X11", "Catapult-Dabubu-linux.pck"),
    ("Windows Pack", "Windows Desktop", "Catapult-Dabubu-windows.pck"),
]

APP_EXPORTS = {
    "macos": {
        "preset": "macOS App",
        "platform": "Mac OSX",
        "path": "app/Catapult-Dabubu.app",
        "required_templates": ["osx.zip"],
    },
    "linux": {
        "preset": "Linux App",
        "platform": "Linux/X11",
        "path": "app/Catapult-Dabubu.x86_64",
        "required_templates": ["linux_x11_64_release"],
    },
    "windows": {
        "preset": "Windows App",
        "platform": "Windows Desktop",
        "path": "app/Catapult-Dabubu.exe",
        "required_templates": ["windows_64_release.exe"],
    },
}

PACKAGE_EXPORTS = {
    "macos": {
        "path": "packages/Catapult-Dabubu-macos-unsigned.zip",
        "source_platform": "macos",
    },
    "linux": {
        "path": "packages/Catapult-Dabubu-linux-unsigned.tar.gz",
        "source_platform": "linux",
    },
    "windows": {
        "path": "packages/Catapult-Dabubu-windows-unsigned.zip",
        "source_platform": "windows",
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
include_filter="utils/*,fonts/*,resources/caol_macos_repair/*"
exclude_filter=""
export_path="{export_path}"
script_export_mode=1
script_encryption_key=""

[preset.{index}.options]
custom_template/debug=""
custom_template/release=""
'''
    if platform == "Mac OSX":
        return common + '''application/name="Catapult-Dabubu"
application/info="C-AOL launcher and installer"
application/icon="res://icons/appicon.icns"
application/identifier="at.schanigarten.catapult-dabubu"
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


def tree_digest(path: Path) -> tuple[int, int, str]:
    h = hashlib.sha256()
    total_bytes = 0
    file_count = 0
    for item in sorted(path.rglob("*")):
        rel = item.relative_to(path).as_posix()
        if item.is_symlink():
            target = os.readlink(item)
            h.update(f"symlink:{rel}->{target}\n".encode("utf-8"))
            file_count += 1
            continue
        if not item.is_file():
            continue
        stat = item.stat()
        total_bytes += stat.st_size
        file_count += 1
        h.update(f"file:{rel}:{stat.st_mode & 0o777}\n".encode("utf-8"))
        with item.open("rb") as fh:
            for chunk in iter(lambda: fh.read(1024 * 1024), b""):
                h.update(chunk)
    return total_bytes, file_count, h.hexdigest()


def artifact(path: Path) -> dict[str, Any]:
    if path.is_dir():
        total_bytes, file_count, digest = tree_digest(path)
        return {
            "path": str(path.relative_to(ROOT)),
            "kind": "directory",
            "bytes": total_bytes,
            "file_count": file_count,
            "sha256_tree": digest,
        }
    return {
        "path": str(path.relative_to(ROOT)),
        "kind": "file",
        "bytes": path.stat().st_size,
        "sha256": sha256(path),
    }


def macos_app_shape(path: Path) -> dict[str, Any]:
    info_path = path / "Contents" / "Info.plist"
    resources_pck = path / "Contents" / "Resources" / "Catapult-Dabubu.pck"
    macos_dir = path / "Contents" / "MacOS"
    executable_candidates = [item for item in macos_dir.iterdir()] if macos_dir.exists() else []
    executable_files = [item for item in executable_candidates if item.is_file() and os.access(item, os.X_OK)]
    info: dict[str, Any] = {}
    if info_path.exists():
        with info_path.open("rb") as fh:
            raw_info = plistlib.load(fh)
        for key in ("CFBundleName", "CFBundleIdentifier", "CFBundleExecutable", "CFBundleShortVersionString"):
            if key in raw_info:
                info[key] = raw_info[key]
    return {
        "platform": "macos",
        "path": str(path.relative_to(ROOT)),
        "is_app_directory": path.is_dir() and path.suffix == ".app",
        "info_plist_exists": info_path.exists(),
        "bundle_info": info,
        "pck_exists": resources_pck.exists(),
        "executable_files": [str(item.relative_to(ROOT)) for item in executable_files],
        "ready_unsigned_local_app": path.is_dir() and info_path.exists() and resources_pck.exists() and bool(executable_files),
        "signed_or_notarized": False,
    }


def linux_executable_shape(path: Path) -> dict[str, Any]:
    return {
        "platform": "linux",
        "path": str(path.relative_to(ROOT)),
        "exists": path.is_file(),
        "executable_bit": path.is_file() and os.access(path, os.X_OK),
        "embedded_pck_expected": True,
        "ready_unsigned_local_executable": path.is_file() and os.access(path, os.X_OK) and path.stat().st_size > 0,
    }


def windows_executable_shape(path: Path) -> dict[str, Any]:
    mz = False
    if path.is_file():
        with path.open("rb") as fh:
            mz = fh.read(2) == b"MZ"
    return {
        "platform": "windows",
        "path": str(path.relative_to(ROOT)),
        "exists": path.is_file(),
        "suffix_is_exe": path.suffix.lower() == ".exe",
        "mz_header": mz,
        "embedded_pck_expected": True,
        "ready_unsigned_local_executable": path.is_file() and mz and path.stat().st_size > 0,
    }


def shape_for_app_export(platform: str, path: Path) -> dict[str, Any]:
    if platform == "macos":
        return macos_app_shape(path)
    if platform == "linux":
        return linux_executable_shape(path)
    if platform == "windows":
        return windows_executable_shape(path)
    raise ValueError(f"unknown app export platform: {platform}")


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
        result["artifact"] = artifact(path)
    else:
        result["tail"] = "\n".join(proc.stdout.splitlines()[-40:])
    return result


def add_to_zip(zf: zipfile.ZipFile, path: Path, arcname: Path) -> None:
    info = zipfile.ZipInfo(arcname.as_posix())
    stat = path.lstat()
    if path.is_symlink():
        info.create_system = 3
        info.external_attr = (0o120777 & 0xFFFF) << 16
        zf.writestr(info, os.readlink(path))
        return
    info.create_system = 3
    info.external_attr = (stat.st_mode & 0xFFFF) << 16
    with path.open("rb") as fh:
        zf.writestr(info, fh.read())


def zip_path(source: Path, destination: Path, keep_parent: bool = True) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists():
        destination.unlink()
    base = source.parent if keep_parent else source
    with zipfile.ZipFile(destination, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        if source.is_file():
            add_to_zip(zf, source, Path(source.name) if keep_parent else Path(source.relative_to(base)))
            return
        for item in sorted(source.rglob("*")):
            if item.is_dir() and not item.is_symlink():
                continue
            add_to_zip(zf, item, item.relative_to(base))


def tar_gz_path(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists():
        destination.unlink()
    with tarfile.open(destination, "w:gz") as tf:
        tf.add(source, arcname=source.name, recursive=True)


def _package_contains_7zip(platform: str, package_path: Path) -> bool:
    if platform == "windows":
        with zipfile.ZipFile(package_path, "r") as zf:
            names = {name.replace("\\", "/") for name in zf.namelist()}
        return "utils/7za.exe" in names
    if platform == "linux":
        with tarfile.open(package_path, "r:gz") as tf:
            names = {member.name.replace("\\", "/") for member in tf.getmembers()}
        return "linux/utils/7za" in names or "utils/7za" in names
    return True


def package_shape(platform: str, package_path: Path, source_path: Path) -> dict[str, Any]:
    if platform == "linux":
        with tarfile.open(package_path, "r:gz") as tf:
            members = tf.getmembers()
        executable_members = [member.name for member in members if member.isfile() and member.mode & 0o111]
        return {
            "platform": platform,
            "path": str(package_path.relative_to(ROOT)),
            "format": "tar.gz",
            "member_count": len(members),
            "executable_members": executable_members,
            "ready_unsigned_local_package": bool(executable_members),
        }
    with zipfile.ZipFile(package_path, "r") as zf:
        names = zf.namelist()
    expected = source_path.name
    contains_expected_root = any(name == expected or name.startswith(expected + "/") for name in names)
    contains_root_executable = any("/" not in name and name.lower().endswith(".exe") for name in names)
    return {
        "platform": platform,
        "path": str(package_path.relative_to(ROOT)),
        "format": "zip",
        "member_count": len(names),
        "contains_expected_root": contains_expected_root,
        "contains_root_executable": contains_root_executable,
        "ready_unsigned_local_package": contains_expected_root or contains_root_executable,
    }


def _copy_sidecar_utils(platform: str, destination_root: Path) -> list[str]:
    copied: list[str] = []
    names = []
    if platform == "windows":
        names = ["7za.exe", "7-ZIP_LICENSE"]
    elif platform == "linux":
        names = ["7za", "7-ZIP_LICENSE"]

    if not names:
        return copied

    utils_dest = destination_root / "utils"
    utils_dest.mkdir(parents=True, exist_ok=True)
    for name in names:
        src = ROOT / "utils" / name
        if not src.exists():
            continue
        dest = utils_dest / name
        shutil.copy2(src, dest)
        if name == "7za":
            dest.chmod(dest.stat().st_mode | 0o755)
        copied.append(str(dest.relative_to(destination_root)))
    return copied


def _stage_package_source(platform: str, source_path: Path) -> tuple[Path, dict[str, Any]]:
    if platform not in ("windows", "linux"):
        return source_path, {"staged": False, "sidecar_utils": []}

    staging_root = OUTPUT_ROOT / "staging" / platform
    if staging_root.exists():
        shutil.rmtree(staging_root)
    staging_root.mkdir(parents=True)

    if source_path.is_dir():
        staged_source = staging_root / source_path.name
        shutil.copytree(source_path, staged_source, symlinks=True)
    else:
        staged_source = staging_root / source_path.name
        shutil.copy2(source_path, staged_source)
        if platform == "linux":
            staged_source.chmod(staged_source.stat().st_mode | 0o755)

    copied = _copy_sidecar_utils(platform, staging_root)
    return staging_root, {
        "staged": True,
        "staging_root": str(staging_root.relative_to(ROOT)),
        "source": str(source_path.relative_to(ROOT)),
        "sidecar_utils": copied,
    }


def write_package_checksums(package_results: list[dict[str, Any]]) -> dict[str, Any]:
    checksum_path = OUTPUT_ROOT / "packages" / "SHA256SUMS.txt"
    lines = []
    for item in package_results:
        artifact_info = item.get("artifact", {})
        digest = artifact_info.get("sha256", "")
        artifact_path = artifact_info.get("path", "")
        if not digest or not artifact_path:
            continue
        lines.append(f"{digest}  {Path(artifact_path).name}")
    checksum_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return artifact(checksum_path)


def package_exports(app_paths: dict[str, Path]) -> list[dict[str, Any]]:
    results = []
    for platform, spec in PACKAGE_EXPORTS.items():
        source_platform = spec["source_platform"]
        source_path = app_paths.get(source_platform)
        if source_path is None or not source_path.exists():
            results.append({
                "platform": platform,
                "skipped": True,
                "reason": "source app export was not produced",
            })
            continue
        package_path = OUTPUT_ROOT / spec["path"]
        package_source, staging = _stage_package_source(platform, source_path)
        if platform == "linux":
            tar_gz_path(package_source, package_path)
        else:
            zip_path(package_source, package_path, keep_parent=False if staging.get("staged") else True)
        shape = package_shape(platform, package_path, package_source)
        shape["contains_7zip_sidecar"] = _package_contains_7zip(platform, package_path)
        if platform in ("windows", "linux"):
            shape["ready_unsigned_local_package"] = shape.get("ready_unsigned_local_package", False) and shape["contains_7zip_sidecar"]
        results.append({
            "platform": platform,
            "artifact": artifact(package_path),
            "shape": shape,
            "staging": staging,
        })
    return results


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
        app_paths: dict[str, Path] = {}
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
            app_path = OUTPUT_ROOT / spec["path"]
            result = export_app(godot, spec["preset"], app_path)
            if result.get("returncode") == 0 and app_path.exists():
                result["shape"] = shape_for_app_export(platform, app_path)
                app_paths[platform] = app_path
            app_results.append(result)

        package_results = package_exports(app_paths)
        checksum_artifact = write_package_checksums(package_results)

        proof = {
            "godot": godot,
            "godot_version": version,
            "output_root": str(OUTPUT_ROOT.relative_to(ROOT)),
            "temporary_export_presets_restored": True,
            "template_probe": templates,
            "pack_exports": pack_results,
            "app_exports": app_results,
            "package_exports": package_results,
            "package_checksums": checksum_artifact,
            "skipped_app_exports": skipped_app_exports,
        }
        manifest = OUTPUT_ROOT / "manifest.json"
        manifest.write_text(json.dumps(proof, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(json.dumps(proof, indent=2, sort_keys=True))

        failed_packs = [item for item in pack_results if item.get("returncode") != 0 or "artifact" not in item]
        failed_apps = [item for item in app_results if item.get("returncode") != 0]
        failed_packages = [
            item for item in package_results
            if item.get("skipped") or not item.get("shape", {}).get("ready_unsigned_local_package")
        ]
        if failed_packs or failed_apps or failed_packages:
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
