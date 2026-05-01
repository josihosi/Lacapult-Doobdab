#!/usr/bin/env python3
"""Non-mutating Catapult-Dabubu identity-surface proof for the Windows retest packet.

This does not run the Windows executable or publish a release. It inspects the
current project/scene/package surfaces that shaped Josef's reported identity
failure: product name, first visible Game-tab framing, titlebar, About link,
package contents, and the currently quarantined release copy.
"""
from __future__ import annotations

import json
import subprocess
import zipfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SCENE = REPO / "scenes" / "Catapult.tscn"
TITLEBAR = REPO / "scenes" / "CustomTitleBar.tscn"
PROJECT = REPO / "project.godot"
PACKAGE = REPO / ".proof-cache" / "lacapult-export" / "packages" / "Catapult-Dabubu-windows-unsigned.zip"
OUT = REPO / ".proof-cache" / "lacapult-identity-surface" / "latest.json"
RELEASE_TAG = "lacapult-post-mod-ui-retest-2026-04-26"
RELEASE_REPO = "josihosi/Lacapult-Doobdab"
PRODUCT_NAME = "Catapult-Dabubu"
REPO_URL = "https://github.com/josihosi/Lacapult-Doobdab/"
INTENTIONALLY_RETAINED = {
    "repo_name": "Lacapult-Doobdab is retained until an explicit public GitHub repository rename is confirmed.",
    "scene_root": "Catapult scene/node/script names are inherited/internal Godot wiring, not fresh user-facing product copy.",
    "lineage": "Catapult, Dabdoob/Catapult_Dabdoob, and C-AOL names remain in attribution/lineage copy.",
}


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
    titlebar = read(TITLEBAR)
    project = read(PROJECT)

    require(f'config/name="{PRODUCT_NAME}"' in project, "project product name is not Catapult-Dabubu")
    require(f"{PRODUCT_NAME} launcher" in scene, "Game-tab Catapult-Dabubu identity title missing")
    require("not a C-AOL game archive" in scene, "Game-tab launcher-not-game framing missing")
    require("fetch/install existing Cataclysm: Arsenic and Old Lace releases" in scene, "Game-tab launcher purpose missing")
    require(f'text = "{PRODUCT_NAME}"' in titlebar, "custom titlebar does not show Catapult-Dabubu")
    require(REPO_URL in scene, "About GitHub link does not point to retained Lacapult repo URL")
    require(f"{PRODUCT_NAME} GitHub Repository" in scene, "About link visible label is not Catapult-Dabubu")
    require("https://github.com/Hihahahalol/Catapult_Dabdoob/]GitHub Repository" not in scene, "visible About GitHub link still points to upstream Dabdoob repo")

    tabs = [
        "Game",
        "Mods",
        "Tilesets",
        "Soundpacks",
        "Fonts",
        "Backups",
        "Settings",
        "LLM",
        "About",
    ]
    for tab in tabs:
        require(f'[node name="{tab}"' in scene or f'_tabs.set_tab_title(7, "{tab}")' in scene, f"expected tab missing: {tab}")

    package_entries: list[str] = []
    if PACKAGE.exists():
        with zipfile.ZipFile(PACKAGE) as zf:
            package_entries = sorted(zf.namelist())
        require(package_entries == ["Catapult-Dabubu.exe", "utils/7-ZIP_LICENSE", "utils/7za.exe"], "Windows package shape changed or contains unexpected top-level files")

    release = gh_release()
    release_summary = {"available": release.get("available", False), "current_quarantined_release_checked": RELEASE_TAG}
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
                "mentions_legacy_lacapult_launcher": "Lacapult launcher" in body_plain,
                "says_not_caol_release": says_not_caol_release,
                "asset_names": [asset.get("name") for asset in release.get("assets", [])],
            }
        )
        require(release.get("isDraft") is True, "quarantined retest release is not Draft")
        require(says_not_caol_release, "release body does not disambiguate C-AOL game release")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "project_name": PRODUCT_NAME,
        "game_tab_identity_title": f"{PRODUCT_NAME} launcher",
        "game_tab_identity_copy": "This download is Catapult-Dabubu, a launcher, not a C-AOL game archive.",
        "titlebar": PRODUCT_NAME,
        "about_link_label": f"{PRODUCT_NAME} GitHub Repository",
        "about_link_url": REPO_URL,
        "tabs": tabs,
        "windows_package_entries": package_entries,
        "release": release_summary,
        "intentionally_retained": INTENTIONALLY_RETAINED,
        "conclusion": "Current project/package surfaces are Catapult-Dabubu-shaped while preserving upstream lineage and retaining the existing Lacapult-Doobdab GitHub repo URL until an explicit public repo rename is confirmed. Windows runtime first-launch still needs real Windows click-through before any confidence/republish claim.",
    }
    OUT.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    print("Catapult-Dabubu identity surface proof passed")
    print("  Game tab: Catapult-Dabubu / not-a-game-archive framing present")
    print("  Titlebar: Catapult-Dabubu")
    print("  About link: Catapult-Dabubu label on retained Lacapult repo URL")
    if package_entries:
        print("  Windows package: %s" % ", ".join(package_entries))
    if release_summary.get("available"):
        print("  Quarantined release: Draft=%s; not-C-AOL-game copy=%s" % (release_summary.get("isDraft"), release_summary.get("says_not_caol_release")))
    print("  Evidence JSON: %s" % OUT.relative_to(REPO))


if __name__ == "__main__":
    main()
