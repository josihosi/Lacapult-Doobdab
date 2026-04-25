#!/usr/bin/env python3
"""Controlled proof for the selected C-AOL v0.2.0 macOS DMG install shape.

This script fetches live release metadata, selects the same preferred macOS asset
used by Lacapult's release proof, optionally downloads it into a local proof cache,
mounts it read-only with hdiutil, inspects the app-bundle/executable layout, and
then detaches it. It does not launch the game, mutate an installed C-AOL config,
use API secrets, pull models, publish releases, or contact upstream maintainers.

Default mode is metadata-only. Pass --download to perform the controlled DMG
mount/inspect proof.
"""

from __future__ import annotations

import argparse
import json
import os
import plistlib
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path
from typing import Any

RELEASES_URL = "https://api.github.com/repos/josihosi/Cataclysm-AOL/releases"
MACOS_FILTERS = ["_macos.dmg", "_macos.tar.gz", "_macos.zip"]
PREFERRED_TAG = "v0.2.0"
DEFAULT_CACHE_DIR = Path(".proof-cache/caol-dmg")
LACAPULT_CAOL_EXECUTABLE_NAMES = ["cataclysm-tiles", "cataclysm-tiles.exe", "Cataclysm-AOL"]


def fetch_releases() -> list[dict[str, Any]]:
    req = urllib.request.Request(RELEASES_URL, headers={"User-Agent": "Lacapult-Doobdab-dmg-proof"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.load(resp)


def select_macos_asset(releases: list[dict[str, Any]]) -> tuple[dict[str, Any], dict[str, Any], list[dict[str, Any]]]:
    release = next((r for r in releases if r.get("tag_name") == PREFERRED_TAG), None)
    if release is None:
        raise RuntimeError(f"{PREFERRED_TAG} release not found")

    matches = [
        asset
        for asset in release.get("assets", [])
        if any(token in asset.get("name", "") for token in MACOS_FILTERS)
    ]
    if not matches:
        raise RuntimeError(f"no macOS asset matching {MACOS_FILTERS} found for {PREFERRED_TAG}")
    return release, matches[0], matches


def download_asset(asset: dict[str, Any], cache_dir: Path) -> Path:
    cache_dir.mkdir(parents=True, exist_ok=True)
    target = cache_dir / asset["name"]
    expected_size = int(asset.get("size") or 0)
    if target.exists() and (expected_size <= 0 or target.stat().st_size == expected_size):
        return target

    tmp_target = target.with_suffix(target.suffix + ".part")
    url = asset["browser_download_url"]
    req = urllib.request.Request(url, headers={"User-Agent": "Lacapult-Doobdab-dmg-proof"})
    with urllib.request.urlopen(req, timeout=60) as resp, tmp_target.open("wb") as out:
        shutil.copyfileobj(resp, out)

    if expected_size and tmp_target.stat().st_size != expected_size:
        tmp_target.unlink(missing_ok=True)
        raise RuntimeError(
            f"download size mismatch for {asset['name']}: got {tmp_target.stat().st_size}, expected {expected_size}"
        )

    tmp_target.replace(target)
    return target


def run(cmd: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, text=True, capture_output=True, check=check)


def mount_dmg(dmg_path: Path) -> str:
    proc = run(["hdiutil", "attach", "-readonly", "-nobrowse", "-plist", str(dmg_path)])
    plist = plistlib.loads(proc.stdout.encode())
    for entity in plist.get("system-entities", []):
        mount_point = entity.get("mount-point")
        if mount_point:
            return mount_point
    raise RuntimeError("hdiutil attach succeeded but no mount point was found")


def detach_dmg(mount_point: str) -> None:
    proc = run(["hdiutil", "detach", mount_point], check=False)
    if proc.returncode != 0:
        run(["hdiutil", "detach", "-force", mount_point], check=False)


def inspect_mount(mount_point: str) -> dict[str, Any]:
    root = Path(mount_point)
    top_level = sorted(p.name for p in root.iterdir() if not p.name.startswith("."))
    apps = sorted(p for p in root.iterdir() if p.is_dir() and p.name.endswith(".app"))
    app_results: list[dict[str, Any]] = []
    for app in apps:
        macos_dir = app / "Contents" / "MacOS"
        resources_dir = app / "Contents" / "Resources"
        executable_candidates = []
        lacapult_guard_matches = []
        for search_dir in [macos_dir, resources_dir]:
            if not search_dir.is_dir():
                continue
            files = sorted(child for child in search_dir.iterdir() if child.is_file())
            for child in files:
                st = child.stat()
                matches_guard = child.name in LACAPULT_CAOL_EXECUTABLE_NAMES or len(files) == 1
                candidate = {
                    "relative_path": str(child.relative_to(app)),
                    "name": child.name,
                    "size": st.st_size,
                    "is_executable": bool(st.st_mode & 0o111),
                    "matches_lacapult_guard": matches_guard,
                }
                executable_candidates.append(candidate)
                if matches_guard:
                    lacapult_guard_matches.append(candidate)
        app_results.append(
            {
                "app": app.name,
                "has_contents_macos": macos_dir.is_dir(),
                "has_contents_resources": resources_dir.is_dir(),
                "executable_candidates": executable_candidates,
                "lacapult_guard_matches": lacapult_guard_matches,
                "launchable_by_lacapult_guard": bool(lacapult_guard_matches),
            }
        )

    return {
        "mount_point": mount_point,
        "top_level_entries": top_level,
        "top_level_app_count": len(apps),
        "apps": app_results,
        "release_installer_root_expectation": "top-level .app keeps the containing temp directory as install root",
        "looks_launchable": any(app["launchable_by_lacapult_guard"] for app in app_results),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--download", action="store_true", help="download, mount, inspect, and detach the selected DMG")
    parser.add_argument("--cache-dir", type=Path, default=DEFAULT_CACHE_DIR, help="proof download cache directory")
    args = parser.parse_args()

    if sys.platform != "darwin":
        print("This DMG proof is macOS-only because it uses hdiutil.", file=sys.stderr)
        return 2

    releases = fetch_releases()
    release, asset, matches = select_macos_asset(releases)
    proof: dict[str, Any] = {
        "release": release.get("tag_name"),
        "release_name": release.get("name"),
        "published_at": release.get("published_at"),
        "selected_asset": {
            "name": asset.get("name"),
            "size": asset.get("size"),
            "url": asset.get("browser_download_url"),
        },
        "matching_macos_assets": [
            {"name": item.get("name"), "size": item.get("size"), "url": item.get("browser_download_url")}
            for item in matches
        ],
        "downloaded": False,
        "mounted": False,
    }

    if not args.download:
        print(json.dumps(proof, indent=2))
        return 0

    if shutil.which("hdiutil") is None:
        print("hdiutil is unavailable; cannot run macOS DMG mount proof", file=sys.stderr)
        return 2

    dmg_path = download_asset(asset, args.cache_dir)
    proof["downloaded"] = True
    proof["local_path"] = str(dmg_path)
    proof["local_size"] = dmg_path.stat().st_size

    mount_point = ""
    try:
        mount_point = mount_dmg(dmg_path)
        proof["mounted"] = True
        proof["mount_inspection"] = inspect_mount(mount_point)
    finally:
        if mount_point:
            detach_dmg(mount_point)
            proof["detached"] = True

    print(json.dumps(proof, indent=2))
    if not proof.get("mount_inspection", {}).get("looks_launchable"):
        print("Mounted DMG did not expose a launchable .app shape", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
