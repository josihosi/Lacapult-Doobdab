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

PREFERRED_CAOL_TAGS = ("caol-cdda-master-2026-05-25-1954", "v0.2.0")

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
    return tag in PREFERRED_CAOL_TAGS or any(tag.startswith(prefix) for prefix in CURATED_CAOL_TAG_PREFIXES)


def curated_releases_in_ui_order(releases: list[dict[str, Any]]) -> list[dict[str, Any]]:
    ordered = []
    seen = set()
    for preferred_tag in PREFERRED_CAOL_TAGS:
        for release in releases:
            if release.get("tag_name", "") == preferred_tag and preferred_tag not in seen:
                ordered.append(release)
                seen.add(preferred_tag)
    for prefix in CURATED_CAOL_TAG_PREFIXES:
        installable = []
        blocked = []
        for release in releases:
            tag_name = release.get("tag_name", "")
            if tag_name in seen or not tag_name.startswith(prefix):
                continue
            asset_result = select_asset(release, "Windows")
            if asset_result["installable"]:
                installable.append(release)
            else:
                blocked.append(release)
            seen.add(tag_name)
        ordered.extend(installable)
        ordered.extend(blocked)
    return ordered


def order_for_ui(releases: list[dict[str, Any]], system: str) -> list[dict[str, Any]]:
    preferred = []
    installable = []
    blocked = []
    seen = set()

    for preferred_tag in PREFERRED_CAOL_TAGS:
        for release in releases:
            tag_name = release.get("tag_name", "")
            if tag_name == preferred_tag and tag_name not in seen:
                asset_result = select_asset(release, system)
                preferred.append((release, asset_result))
                seen.add(tag_name)

    for prefix in CURATED_CAOL_TAG_PREFIXES:
        for release in releases:
            tag_name = release.get("tag_name", "")
            if tag_name in seen or not tag_name.startswith(prefix):
                continue
            asset_result = select_asset(release, system)
            if asset_result["installable"]:
                installable.append((release, asset_result))
            else:
                blocked.append((release, asset_result))
            seen.add(tag_name)

    shaped = []
    for release, asset_result in preferred + installable + blocked:
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
        help="prove Linux, macOS, and Windows preferred C-AOL asset filters instead of only this host",
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
    if not curated:
        print("expected at least one curated C-AOL release row", file=sys.stderr)
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
        "preferred_tags": PREFERRED_CAOL_TAGS,
        "allowed_tag_prefixes": CURATED_CAOL_TAG_PREFIXES,
        "curated_release_tags": [release.get("tag_name", "") for release in curated],
        "api_release_count": len(releases),
        "ui_order": ui_order,
        "platform_results": platform_results,
    }
    print(json.dumps(proof, indent=2))

    for system in systems:
        system_order = order_for_ui(releases, system)
        if not system_order:
            print(f"no curated UI rows for {system}", file=sys.stderr)
            return 1
        first = system_order[0]
        expected_first_tag = PREFERRED_CAOL_TAGS[0]
        if first["tag_name"] != expected_first_tag or not first["installable"]:
            print(f"{system} first row is not installable {expected_first_tag}: {first}", file=sys.stderr)
            return 1
        seen_blocked = False
        for item in system_order:
            if item["installable"] and seen_blocked:
                print(f"{system} has installable rows after blocked rows: {system_order}", file=sys.stderr)
                return 1
            if not item["installable"]:
                seen_blocked = True

    for platform in platform_results:
        first_release = platform["releases"][0] if platform["releases"] else {}
        if not first_release.get("installable", False):
            print(f"preferred {PREFERRED_CAOL_TAGS[0]} row is not installable for {platform['system']}", file=sys.stderr)
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
