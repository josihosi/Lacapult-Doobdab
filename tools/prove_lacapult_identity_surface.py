#!/usr/bin/env python3
"""Non-mutating identity-surface proof for the quarantined Lacapult Windows retest packet.

This does not run the Windows executable. It inspects the scene/release/package surfaces
that shaped Josef's reported "this reads like CAOL, not Lacapult" failure: package
contents, first visible Game-tab framing, About link target, and quarantined release copy.
"""
from __future__ import annotations

import json
import subprocess
import zipfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SCENE = REPO / "scenes" / "Catapult.tscn"
PROJECT = REPO / "project.godot"
PACKAGE = REPO / ".proof-cache" / "lacapult-export" / "packages" / "Lacapult-Doobdab-windows-unsigned.zip"
OUT = REPO / ".proof-cache" / "lacapult-identity-surface" / "latest.json"
RELEASE_TAG = "lacapult-post-mod-ui-retest-2026-04-26"
RELEASE_REPO = "josihosi/Lacapult-Doobdab"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def gh_release() -> dict:
    cmd = [
        "gh",
        "release",
        "view",
        RELEASE_TAG,
        "--repo",
        RELEASE_REPO,
        "--json",
        "name,tagName,isDraft,isPrerelease,body,url,assets",
    ]
    try:
        raw = subprocess.check_output(cmd, cwd=REPO, text=True, stderr=subprocess.STDOUT, timeout=30)
    except (FileNotFoundError, subprocess.CalledProcessError, subprocess.TimeoutExpired) as exc:
        return {"available": False, "error": str(exc)}
    data = json.loads(raw)
    data["available"] = True
    return data


def main() -> None:
    scene = read(SCENE)
    project = read(PROJECT)

    require('config/name="Lacapult Doobdab"' in project, "project name is not Lacapult Doobdab")
    require("Lacapult Doobdab launcher" in scene, "Game-tab launcher-first identity title missing")
    require("not a C-AOL game archive" in scene, "Game-tab launcher-not-game framing missing")
    require("fetch/install existing Cataclysm: Arsenic and Old Lace releases" in scene, "Game-tab launcher purpose missing")
    require("https://github.com/josihosi/Lacapult-Doobdab/" in scene, "About GitHub link does not point to Lacapult repo")
    require("https://github.com/Hihahahalol/Catapult_Dabdoob/]GitHub Repository" not in scene, "visible About GitHub link still points to upstream Dabdoob repo")

    tabs = [
        "Game",
        "Mods",
        "Tilesets",
        "Soundpacks",
        "Fonts",
        "Backups",
        "Settings",
        "C-AOL LLM backend setup",
        "About",
    ]
    for tab in tabs:
        require(f'[node name="{tab}"' in scene or f'_tabs.set_tab_title(7, "{tab}")' in scene, f"expected tab missing: {tab}")

    package_entries: list[str] = []
    if PACKAGE.exists():
        with zipfile.ZipFile(PACKAGE) as zf:
            package_entries = sorted(zf.namelist())
        require(package_entries == ["Lacapult-Doobdab.exe", "utils/7-ZIP_LICENSE", "utils/7za.exe"], "Windows package shape changed or contains unexpected top-level files")

    release = gh_release()
    release_summary = {"available": release.get("available", False)}
    if release.get("available"):
        body = release.get("body") or ""
        body_plain = body.replace("*", "")
        says_not_caol_release = "not a new Cataclysm: Arsenic and Old Lace game release" in body_plain
        release_summary.update(
            {
                "name": release.get("name"),
                "tagName": release.get("tagName"),
                "url": release.get("url"),
                "isDraft": release.get("isDraft"),
                "isPrerelease": release.get("isPrerelease"),
                "mentions_lacapult_launcher": "Lacapult launcher" in body_plain,
                "says_not_caol_release": says_not_caol_release,
                "asset_names": [asset.get("name") for asset in release.get("assets", [])],
            }
        )
        require(release.get("isDraft") is True, "quarantined retest release is not Draft")
        require("Lacapult launcher" in body_plain, "release body does not identify artifact as Lacapult launcher")
        require(says_not_caol_release, "release body does not disambiguate C-AOL game release")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "project_name_ok": True,
        "game_tab_identity_title": "Lacapult Doobdab launcher",
        "game_tab_identity_copy": "This download is the Lacapult launcher, not a C-AOL game archive.",
        "about_link": "https://github.com/josihosi/Lacapult-Doobdab/",
        "tabs": tabs,
        "windows_package_entries": package_entries,
        "release": release_summary,
        "conclusion": "Package/release are Lacapult-shaped, and the first Game tab now carries launcher-not-game framing; Windows runtime first-launch still needs real Windows click-through before republish.",
    }
    OUT.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    print("Lacapult identity surface proof passed")
    print("  Game tab: launcher-first / not-a-game-archive framing present")
    print("  About link: Lacapult GitHub repo")
    if package_entries:
        print("  Windows package: %s" % ", ".join(package_entries))
    if release_summary.get("available"):
        print("  Quarantined release: Draft=%s; launcher copy=%s; not-C-AOL-game copy=%s" % (release_summary.get("isDraft"), release_summary.get("mentions_lacapult_launcher"), release_summary.get("says_not_caol_release")))
    print("  Evidence JSON: %s" % OUT.relative_to(REPO))


if __name__ == "__main__":
    main()
