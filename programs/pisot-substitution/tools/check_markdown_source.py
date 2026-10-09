#!/usr/bin/env python3
"""Reject unexpected ASCII C0 controls in theorem/research Markdown."""

from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_TARGETS = (ROOT / "README.md", ROOT / "docs", ROOT / "sources", ROOT / "manuscripts")
ALLOWED_CONTROLS = {0x0A}  # LF is the repository Markdown line separator.


def markdown_files(targets: list[Path]) -> tuple[list[Path], list[str]]:
    files: set[Path] = set()
    errors: list[str] = []
    for raw_target in targets:
        target = raw_target if raw_target.is_absolute() else raw_target.resolve()
        if not target.exists():
            errors.append(f"{raw_target}: target does not exist")
            continue
        if target.is_file():
            if target.suffix.lower() != ".md":
                errors.append(f"{raw_target}: explicit target is not a Markdown file")
                continue
            files.add(target)
            continue
        if not target.is_dir():
            errors.append(f"{raw_target}: unsupported target type")
            continue
        found = [path for path in target.rglob("*.md") if path.is_file()]
        if not found:
            errors.append(f"{raw_target}: directory contains no Markdown files")
            continue
        files.update(found)
    return sorted(files), errors


def unexpected_controls(path: Path) -> list[tuple[int, int, int]]:
    findings: list[tuple[int, int, int]] = []
    line = 1
    column = 0
    for byte in path.read_bytes():
        column += 1
        if byte < 0x20 and byte not in ALLOWED_CONTROLS:
            findings.append((line, column, byte))
        if byte == 0x0A:
            line += 1
            column = 0
    return findings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("targets", nargs="*", type=Path)
    args = parser.parse_args()
    targets = args.targets or list(DEFAULT_TARGETS)
    files, errors = markdown_files(targets)

    for error in errors:
        print(f"ERROR: {error}")

    failed = bool(errors)
    for path in files:
        for line, column, byte in unexpected_controls(path):
            failed = True
            try:
                display = path.relative_to(ROOT)
            except ValueError:
                display = path
            print(f"{display}:{line}:{column}: unexpected C0 control 0x{byte:02x}")

    if not files:
        print("ERROR: no Markdown files were checked")
        return 1
    if failed:
        return 1

    print(f"OK Markdown source integrity: {len(files)} file(s) checked")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
