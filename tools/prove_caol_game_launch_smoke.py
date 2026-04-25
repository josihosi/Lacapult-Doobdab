#!/usr/bin/env python3
"""Launch-smoke the selected C-AOL v0.2.0 macOS app from an isolated install.

This proof fetches live release metadata, reuses/downloads the selected macOS DMG,
mounts it read-only, copies it into a temporary Lacapult-style install directory,
and briefly starts the installed Cataclysm.app bundle entry script under an
isolated HOME. The process is killed after a short observation window; success
means the app bundle reached a running process instead of exiting immediately or
crashing during startup.

It does not touch the user's real Lacapult Application Support directory, publish
anything, use API secrets, pull models, or perform full backend setup.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import signal
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any

import prove_caol_macos_dmg as dmg_proof

DEFAULT_OBSERVE_SECONDS = 8.0
INFO_FILENAME = dmg_proof.INFO_FILENAME


def install_from_mount_keep(mount_point: str, release_name: str, sandbox_root: Path) -> tuple[Path, dict[str, Any]]:
    tmp_dir = sandbox_root / "Library" / "Application Support" / "Lacapult Doobdab" / "caol" / "tmp"
    install_dir = sandbox_root / "Library" / "Application Support" / "Lacapult Doobdab" / "caol" / "game0"
    tmp_dir.mkdir(parents=True, exist_ok=True)
    install_dir.parent.mkdir(parents=True, exist_ok=True)

    copied_root = dmg_proof.copy_mount_like_lacapult(mount_point, tmp_dir)
    selected_root = dmg_proof.find_game_root_like_lacapult(tmp_dir)
    (selected_root / INFO_FILENAME).write_text(json.dumps({"name": release_name}, indent=4), encoding="utf-8")

    install_dir.mkdir(parents=True, exist_ok=True)
    moved_entries: list[str] = []
    for child in selected_root.iterdir():
        if child.name == "Applications" or child.name.startswith("."):
            continue
        target = install_dir / child.name
        shutil.move(str(child), str(target))
        moved_entries.append(child.name)

    chmodded = dmg_proof.chmod_app_bundle_executables(install_dir)
    proof = {
        "sandbox_root": str(sandbox_root),
        "copied_mount_root_name": copied_root.name,
        "selected_install_root_relative": str(selected_root.relative_to(sandbox_root)),
        "final_install_dir": str(install_dir),
        "moved_entries": sorted(moved_entries),
        "final_listing": sorted(child.name for child in install_dir.iterdir()),
        "info_file_present": (install_dir / INFO_FILENAME).is_file(),
        "looks_launchable_after_move": dmg_proof.looks_like_game_directory(install_dir),
        "chmodded_app_executables": chmodded,
    }
    return install_dir, proof


def find_app_launch_script(install_dir: Path) -> Path:
    apps = sorted(child for child in install_dir.iterdir() if child.is_dir() and child.name.endswith(".app"))
    if not apps:
        raise RuntimeError(f"no .app bundle found in {install_dir}")
    app = apps[0]
    script = app / "Contents" / "MacOS" / "Cataclysm.sh"
    if not script.is_file():
        raise RuntimeError(f"expected app bundle launch script missing: {script}")
    script.chmod(script.stat().st_mode | 0o111)
    return script


def launch_and_observe(script: Path, sandbox_root: Path, observe_seconds: float) -> dict[str, Any]:
    env = os.environ.copy()
    env.update(
        {
            "HOME": str(sandbox_root),
            "XDG_CONFIG_HOME": str(sandbox_root / ".config"),
            "XDG_DATA_HOME": str(sandbox_root / ".local" / "share"),
            "XDG_CACHE_HOME": str(sandbox_root / ".cache"),
            "LACAPULT_CAOL_LAUNCH_SMOKE": "1",
        }
    )
    stdout_path = sandbox_root / "launch-smoke.stdout.txt"
    stderr_path = sandbox_root / "launch-smoke.stderr.txt"
    with stdout_path.open("wb") as stdout, stderr_path.open("wb") as stderr:
        proc = subprocess.Popen(
            [str(script)],
            cwd=str(script.parent),
            env=env,
            stdout=stdout,
            stderr=stderr,
            start_new_session=True,
        )
        started_at = time.monotonic()
        time.sleep(observe_seconds)
        returncode_after_observe = proc.poll()
        was_running_after_observe = returncode_after_observe is None
        if was_running_after_observe:
            os.killpg(proc.pid, signal.SIGTERM)
            try:
                proc.wait(timeout=5)
                terminated_by_smoke = True
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.wait(timeout=5)
                terminated_by_smoke = True
        else:
            terminated_by_smoke = False

    stdout_text = stdout_path.read_text(errors="replace")[-4000:]
    stderr_text = stderr_path.read_text(errors="replace")[-4000:]
    immediate_success_exit = returncode_after_observe == 0
    return {
        "launch_script": str(script),
        "observe_seconds": observe_seconds,
        "was_running_after_observe": was_running_after_observe,
        "returncode_after_observe": returncode_after_observe,
        "terminated_by_smoke": terminated_by_smoke,
        "immediate_success_exit": immediate_success_exit,
        "stdout_tail": stdout_text,
        "stderr_tail": stderr_text,
        "elapsed_before_check_seconds": round(time.monotonic() - started_at, 3),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cache-dir", type=Path, default=dmg_proof.DEFAULT_CACHE_DIR)
    parser.add_argument("--observe-seconds", type=float, default=DEFAULT_OBSERVE_SECONDS)
    parser.add_argument("--keep-sandbox", action="store_true", help="print and keep the temporary install root for inspection")
    args = parser.parse_args()

    if sys.platform != "darwin":
        print("C-AOL app launch smoke is macOS-only because the selected proof asset is a DMG.", file=sys.stderr)
        return 2
    if shutil.which("hdiutil") is None:
        print("hdiutil is unavailable; cannot mount the selected C-AOL DMG", file=sys.stderr)
        return 2

    releases = dmg_proof.fetch_releases()
    release, asset, matches = dmg_proof.select_macos_asset(releases)
    dmg_path = dmg_proof.download_asset(asset, args.cache_dir)

    if args.keep_sandbox:
        sandbox_root = Path(tempfile.mkdtemp(prefix="lacapult-caol-launch-home-"))
        sandbox_context = None
    else:
        sandbox_context = tempfile.TemporaryDirectory(prefix="lacapult-caol-launch-home-")
        sandbox_root = Path(sandbox_context.name)
    mount_point = ""
    proof: dict[str, Any] = {
        "release": release.get("tag_name"),
        "release_name": release.get("name"),
        "selected_asset": {"name": asset.get("name"), "size": asset.get("size")},
        "matching_macos_asset_count": len(matches),
        "local_dmg": str(dmg_path),
        "local_dmg_size": dmg_path.stat().st_size,
        "sandbox_cleanup": "kept" if args.keep_sandbox else "removed_after_proof",
    }
    try:
        mount_point = dmg_proof.mount_dmg(dmg_path)
        proof["mount_point"] = mount_point
        install_dir, install_proof = install_from_mount_keep(mount_point, release.get("name") or dmg_proof.PREFERRED_TAG, sandbox_root)
        proof["install"] = install_proof
        script = find_app_launch_script(install_dir)
        proof["launch"] = launch_and_observe(script, sandbox_root, args.observe_seconds)
    finally:
        if mount_point:
            dmg_proof.detach_dmg(mount_point)
            proof["detached"] = True

    launch = proof.get("launch", {})
    success = bool(proof.get("install", {}).get("looks_launchable_after_move")) and (
        launch.get("was_running_after_observe") or launch.get("immediate_success_exit")
    )
    print(json.dumps(proof, indent=2))
    if sandbox_context is not None:
        sandbox_context.cleanup()
    if not success:
        print("C-AOL app launch smoke did not reach a running/successfully exiting app process", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
