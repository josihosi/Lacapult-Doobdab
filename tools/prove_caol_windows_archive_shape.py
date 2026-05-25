#!/usr/bin/env python3
"""Verify the downloaded live C-AOL Windows archive shape.

This proof reads a local ZIP only. It does not install, execute, mutate user
data, call APIs, install packages, or pull models.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ARCHIVE = ROOT / ".proof-cache" / "caol-live-windows" / "caol_cdda-0-h_2026-03-29-1556_windows.zip"
EXECUTABLE_CANDIDATES = (
    "Cataclysm-AOL.exe",
    "cataclysm-tiles.exe",
    "cataclysm.exe",
    "Cataclysm.exe",
)
REQUIRED_FILES = (
    "tools/llm_runner/runner.py",
    "README.md",
    "TechnicalTome.md",
    "VERSION.txt",
)
REQUIRED_PREFIXES = (
    "data/json/",
    "gfx/",
    "lang/mo/",
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"C-AOL Windows archive shape proof failed: {message}")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", nargs="?", type=Path, default=DEFAULT_ARCHIVE)
    parser.add_argument("--skip-crc", action="store_true", help="skip full ZIP CRC verification")
    args = parser.parse_args()

    archive = args.archive
    require(archive.exists(), f"archive does not exist: {archive}")

    with ZipFile(archive) as zf:
        names = zf.namelist()
        name_set = set(names)
        require(names, "archive is empty")
        unsafe = [name for name in names if name.startswith("/") or ".." in Path(name).parts]
        require(not unsafe, f"archive has unsafe paths: {unsafe[:5]}")

        bad_crc = None if args.skip_crc else zf.testzip()
        require(bad_crc is None, f"ZIP CRC failed at {bad_crc}")

        executables = [name for name in EXECUTABLE_CANDIDATES if name in name_set]
        require(executables, f"none of {EXECUTABLE_CANDIDATES} found at archive root")
        missing_files = [name for name in REQUIRED_FILES if name not in name_set]
        require(not missing_files, f"missing required files: {missing_files}")
        missing_prefixes = [prefix for prefix in REQUIRED_PREFIXES if not any(name.startswith(prefix) for name in names)]
        require(not missing_prefixes, f"missing required directory prefixes: {missing_prefixes}")

        dlls = [name for name in names if name.lower().endswith(".dll")]
        proof = {
            "archive": str(archive),
            "size": archive.stat().st_size,
            "sha256": sha256_file(archive),
            "entry_count": len(names),
            "executables": executables,
            "dll_count": len(dlls),
            "runner": "tools/llm_runner/runner.py",
            "required_prefixes": REQUIRED_PREFIXES,
            "crc_checked": not args.skip_crc,
        }

    print(json.dumps(proof, indent=2))
    print("C-AOL Windows archive shape proof passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
