#!/usr/bin/env python3
"""Live proof that C-AOL release metadata can feed Lacapult's installer shape.

No release archive is downloaded. This only reads GitHub JSON and filters asset names
using the same platform substrings wired in scripts/ReleaseManager.gd.

By default it proves the current host platform. Pass ``--all-platforms`` to prove the
v0.2.0 asset contract for Linux, macOS, and Windows in one API read.
"""

from __future__ import annotations

import argparse
import json
import platform
import sys
import urllib.request
from typing import Any

RELEASES_URL = "https://api.github.com/repos/josihosi/Cataclysm-AOL/releases"
FILTERS = {
    "Linux": ["_linux.tar.gz"],
    "Darwin": ["_macos.dmg", "_macos.tar.gz", "_macos.zip"],
    "Windows": ["_windows.zip"],
}


def select_asset(release: dict[str, Any], system: str) -> dict[str, Any]:
    substrings = FILTERS[system]
    matches = []
    for asset in release.get("assets", []):
        name = asset.get("name", "")
        if any(s in name for s in substrings):
            matches.append(asset)

    selected = matches[0] if matches else None
    installer_shape = {
        "name": release.get("name") or release.get("tag_name"),
        "url": selected.get("browser_download_url", "") if selected else "",
        "filename": selected.get("name", "") if selected else "",
        "asset_size": selected.get("size", 0) if selected else 0,
        "release_page_url": release.get("html_url", ""),
        "published_at": release.get("published_at", ""),
        "has_any_assets": bool(release.get("assets")),
    }
    return {
        "platform": system,
        "filters": substrings,
        "match_count": len(matches),
        "installable": bool(installer_shape["url"] and installer_shape["filename"]),
        "installer_shape": installer_shape,
        "matching_assets": [
            {
                "name": asset.get("name", ""),
                "size": asset.get("size", 0),
                "url": asset.get("browser_download_url", ""),
            }
            for asset in matches
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--all-platforms",
        action="store_true",
        help="prove Linux, macOS, and Windows v0.2.0 asset filters instead of only this host",
    )
    args = parser.parse_args()

    systems = list(FILTERS) if args.all_platforms else [platform.system()]
    unsupported = [system for system in systems if system not in FILTERS]
    if unsupported:
        print(f"unsupported platform(s) for proof: {', '.join(unsupported)}", file=sys.stderr)
        return 2

    req = urllib.request.Request(RELEASES_URL, headers={"User-Agent": "Lacapult-Doobdab-proof"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        releases = json.load(resp)

    v020 = next((r for r in releases if r.get("tag_name") == "v0.2.0" or r.get("name") == "v0.2.0"), None)
    if not v020:
        print("v0.2.0 release not found", file=sys.stderr)
        return 1

    platform_results = [select_asset(v020, system) for system in systems]
    proof = {
        "release": v020.get("tag_name"),
        "release_name": v020.get("name"),
        "published_at": v020.get("published_at", ""),
        "asset_count": len(v020.get("assets", [])),
        "platform_results": platform_results,
    }
    print(json.dumps(proof, indent=2))

    if not all(result["installable"] for result in platform_results):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
