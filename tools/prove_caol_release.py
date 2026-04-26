#!/usr/bin/env python3
"""Live proof that C-AOL release metadata can feed Lacapult's installer shape.

No release archive is downloaded. This only reads GitHub JSON and filters asset names
using the same platform substrings wired in scripts/ReleaseManager.gd.

By default it proves the current host platform. Pass ``--all-platforms`` to prove the
curated C-AOL port release asset contract for Linux, macOS, and Windows in one API read.
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

CURATED_CAOL_TAG_PREFIXES = (
    "caol-cdda-master",
    "caol-ctlg-master",
    "caol-cdda-0-h",
    "caol-cdda-0-i",
)


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


def is_curated_caol_release(release: dict[str, Any]) -> bool:
    tag = release.get("tag_name", "")
    return any(tag.startswith(prefix) for prefix in CURATED_CAOL_TAG_PREFIXES)


def curated_releases_in_ui_order(releases: list[dict[str, Any]]) -> list[dict[str, Any]]:
    ordered = []
    for prefix in CURATED_CAOL_TAG_PREFIXES:
        ordered.extend(release for release in releases if release.get("tag_name", "").startswith(prefix))
    return ordered


def order_for_ui(releases: list[dict[str, Any]], system: str) -> list[dict[str, Any]]:
    shaped = []
    for release in curated_releases_in_ui_order(releases):
        asset_result = select_asset(release, system)
        shaped.append(
            {
                "tag_name": release.get("tag_name", ""),
                "name": release.get("name") or release.get("tag_name", ""),
                "installable": asset_result["installable"],
                "filename": asset_result["installer_shape"]["filename"],
            }
        )
    return shaped


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

    curated = curated_releases_in_ui_order(releases)
    if len(curated) != len(CURATED_CAOL_TAG_PREFIXES):
        print(f"expected {len(CURATED_CAOL_TAG_PREFIXES)} curated C-AOL releases, got {len(curated)}", file=sys.stderr)
        return 1

    platform_results = [
        {
            "system": system,
            "releases": [select_asset(release, system) for release in curated],
        }
        for system in systems
    ]
    ui_order = order_for_ui(releases, systems[0])
    proof = {
        "allowed_tag_prefixes": CURATED_CAOL_TAG_PREFIXES,
        "curated_release_tags": [release.get("tag_name", "") for release in curated],
        "ui_release_count": len(ui_order),
        "ui_order": ui_order,
        "platform_results": platform_results,
    }
    print(json.dumps(proof, indent=2))

    if len(ui_order) != len(CURATED_CAOL_TAG_PREFIXES):
        print("curated UI order does not contain exactly the expected C-AOL release rows", file=sys.stderr)
        return 1
    expected_order = list(CURATED_CAOL_TAG_PREFIXES)
    actual_order = [next(prefix for prefix in CURATED_CAOL_TAG_PREFIXES if item["tag_name"].startswith(prefix)) for item in ui_order]
    if actual_order != expected_order:
        print(f"curated UI order mismatch: {actual_order}", file=sys.stderr)
        return 1
    for platform in platform_results:
        if not all(result["installable"] for result in platform["releases"]):
            print(f"not all curated releases are installable for {platform['system']}", file=sys.stderr)
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
