#!/usr/bin/env python3
"""Live proof that C-AOL release metadata can feed Lacapult's installer shape.

No release archive is downloaded. This only reads GitHub JSON and filters asset names
using the same platform substrings wired in scripts/ReleaseManager.gd.
"""

from __future__ import annotations

import json
import platform
import sys
import urllib.request

RELEASES_URL = "https://api.github.com/repos/josihosi/Cataclysm-AOL/releases"
FILTERS = {
    "Linux": ["_linux.tar.gz"],
    "Darwin": ["_macos.dmg", "_macos.tar.gz", "_macos.zip"],
    "Windows": ["_windows.zip"],
}


def main() -> int:
    system = platform.system()
    substrings = FILTERS.get(system)
    if not substrings:
        print(f"unsupported platform for proof: {system}", file=sys.stderr)
        return 2

    req = urllib.request.Request(RELEASES_URL, headers={"User-Agent": "Lacapult-Doobdab-proof"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        releases = json.load(resp)

    v020 = next((r for r in releases if r.get("tag_name") == "v0.2.0" or r.get("name") == "v0.2.0"), None)
    if not v020:
        print("v0.2.0 release not found", file=sys.stderr)
        return 1

    selected = None
    for asset in v020.get("assets", []):
        name = asset.get("name", "")
        if any(s in name for s in substrings):
            selected = asset
            break

    installer_shape = {
        "name": v020.get("name") or v020.get("tag_name"),
        "url": selected.get("browser_download_url", "") if selected else "",
        "filename": selected.get("name", "") if selected else "",
        "published_at": v020.get("published_at", ""),
        "has_any_assets": bool(v020.get("assets")),
    }

    print(json.dumps({
        "release": v020.get("tag_name"),
        "platform": system,
        "filters": substrings,
        "asset_count": len(v020.get("assets", [])),
        "installer_shape": installer_shape,
    }, indent=2))

    if not installer_shape["url"] or not installer_shape["filename"]:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
