#!/usr/bin/env python3
"""Audit executable core files for forbidden analytic/transcendental primitives.

Docs may discuss the ban and historical terminology. Executable source must use
quadrance, spread, dot/cross determinants, algebraic rotors, or Q/Z doubling.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "vendor" / "python"))
from claim_governance.lexing import mask_comments_and_strings  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
CORE_PATHS = [ROOT / "kernel", ROOT / "vendor" / "mojo"]
TOKEN_RE = re.compile(
    r"\b(?:sin|cos|tan|asin|acos|atan|sinh|cosh|tanh|exp|log|sqrt|radians?)\b"
    r"|unit circle|polar angle|\b(?:angle[_ ]?degrees?|degrees?[_ ]?angle)\b",
    re.IGNORECASE,
)


def iter_files() -> list[Path]:
    files: list[Path] = []
    for base in CORE_PATHS:
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if path.is_file() and path.suffix == ".mojo":
                files.append(path)
    return files


def main() -> int:
    violations: list[tuple[Path, int, str]] = []
    for path in iter_files():
        text = mask_comments_and_strings(path.read_text(encoding="utf-8"))
        for lineno, line in enumerate(text.splitlines(), start=1):
            if TOKEN_RE.search(line):
                violations.append((path.relative_to(ROOT), lineno, line.strip()))

    if violations:
        print("Forbidden analytic or transcendental primitives found in executable core files:\n")
        for path, lineno, line in violations:
            print(f"{path}:{lineno}: {line}")
        print("\nUse quadrance, spread, dot/cross determinants, algebraic rotors, or Q/Z doubling instead.")
        return 1

    print("OK: executable core files contain no forbidden analytic or transcendental primitives.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
