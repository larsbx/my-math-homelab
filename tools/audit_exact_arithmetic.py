#!/usr/bin/env python3
"""Enforce the exact-arithmetic contract on this repository's kernel scope.

Section 7 of `docs/rational-interval-arithmetic-spec.md` asks a consumer with
certificate paths for a lexical floating-point scan, a binding row per direct
arithmetic consumer, and the C7 citation check. This is that audit, over
`docs/exact-arithmetic-binding.md`.

It checks four things:

1. every module that imports the `Q` or `IQ` layers has a binding row;
2. every module a row names exists and cites the specification by path (C7),
   except the vendored package files, whose headers are upstream's;
3. no floating-point type or decimal literal appears in the kernel scope
   outside the allowlist;
4. the allowlist and the QUARANTINED rows are the same set, in both
   directions, so a quarantine cannot be granted or forgotten silently.

Usage: audit_exact_arithmetic.py            exit 1 on any violation
"""

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC_REL = "docs/rational-interval-arithmetic-spec.md"
BINDING_REL = "docs/exact-arithmetic-binding.md"
SPEC = ROOT / SPEC_REL
BINDING = ROOT / BINDING_REL
ALLOWLIST = ROOT / "tools" / "exact_arithmetic_allowlist.md"
#: The Mojo the audit reads: the kernel, and the vendored packages beside it,
#: whose arithmetic consumers are bound here even though their headers are upstream's.
SCAN_ROOTS = (ROOT / "kernel", ROOT / "vendor" / "mojo")

CLASSES = ("CONFORMS-CHECKED", "CONFORMS", "DEMO", "QUARANTINED")
PATH_RE = re.compile(r"`([A-Za-z0-9_./-]+\.(?:mojo|py))`")
ROW_RE = re.compile(r"^\|(?P<cells>.+)\|\s*$")
ARITHMETIC_IMPORT_RE = re.compile(r"^from finite_exact\.\w+ import", re.M)
FLOAT_RE = re.compile(r"\b(?:Float16|Float32|Float64|SIMD\[DType\.float|float)\b|\b\d+\.\d+\b")

def vendored_exempt() -> tuple[str, ...]:
    """Prefixes of the vendored packages, read from the manifest.

    Vendored package files carry upstream's headers; their citation is
    upstream's obligation, and editing them here would be drift, not
    compliance. The list used to be written out here, which meant vendoring a
    package and remembering to widen an audit were two steps instead of one.
    `vendored.toml` is the one place that knows what is vendored. A tree with
    no manifest vendors nothing, so it gets no exemptions -- which is the
    fail-closed direction.
    """
    path = ROOT / "vendored.toml"
    if not path.exists():
        return ()
    manifest = tomllib.loads(path.read_text(encoding="utf-8"))
    return tuple(f"{pkg['root']}/{pkg['name']}/" for pkg in manifest.get("package", []))

REQUIRED_SPEC_SECTIONS = (
    "## 0. The problem being solved",
    "## 5. Conformance criteria",
    "## 6. Consumers and binding tables",
    "## 7. Hook: how a consumer enforces the specification",
)


def binding_rows() -> list[tuple[str, list[str]]]:
    """Every (class, modules) row of the binding table."""
    rows = []
    for line in BINDING.read_text(encoding="utf-8").splitlines():
        match = ROW_RE.match(line)
        if not match:
            continue
        cells = [cell.strip() for cell in match.group("cells").split("|")]
        if len(cells) < 4:
            continue
        found = next((cls for cls in CLASSES if cells[2] == cls), None)
        if found:
            rows.append((found, PATH_RE.findall(cells[1])))
    return rows


def allowlisted() -> set[str]:
    """Paths listed as entries in the allowlist.

    Only list items count. The file's prose names paths too -- the audit's own
    path, the binding table's -- and reading those as grants would quarantine
    whatever the document happened to mention.
    """
    if not ALLOWLIST.exists():
        return set()
    entries: set[str] = set()
    for line in ALLOWLIST.read_text(encoding="utf-8").splitlines():
        if line.lstrip().startswith(("-", "*")):
            entries.update(PATH_RE.findall(line))
    return entries


def kernel_files() -> list[Path]:
    return sorted(path for root in SCAN_ROOTS for path in root.rglob("*.mojo"))


def arithmetic_consumers() -> set[str]:
    return {
        path.relative_to(ROOT).as_posix()
        for path in kernel_files()
        if ARITHMETIC_IMPORT_RE.search(path.read_text(encoding="utf-8"))
    }


def code_lines(text: str) -> list[tuple[int, str]]:
    """Lines outside comments and docstrings.

    Deliberately coarse: a line is dropped when it is a comment or sits inside
    a triple-quoted block. A coarse filter that drops too much would hide a
    violation, so anything it cannot classify is kept and scanned.
    """
    out, in_doc = [], False
    for lineno, line in enumerate(text.splitlines(), start=1):
        stripped = line.strip()
        if stripped.count('"""') == 1:
            in_doc = not in_doc
            continue
        if in_doc or stripped.startswith("#") or stripped.startswith('"""'):
            continue
        out.append((lineno, line.split("#", 1)[0]))
    return out


def audit() -> list[str]:
    errors: list[str] = []
    for path, rel in ((SPEC, SPEC_REL), (BINDING, BINDING_REL)):
        if not path.exists():
            errors.append(f"missing {rel}")
    if errors:
        return errors
    spec = SPEC.read_text(encoding="utf-8")
    errors += [f"spec lacks section {s!r}" for s in REQUIRED_SPEC_SECTIONS if s not in spec]
    if "larsbx/finite-julia-set-research" not in spec:
        errors.append(f"{SPEC_REL} does not name this repository as a consumer")
    if errors:
        return errors

    rows = binding_rows()
    if not rows:
        return [f"{BINDING_REL} has no binding rows"]

    bound: set[str] = set()
    quarantined: set[str] = set()
    for cls, modules in rows:
        for rel in modules:
            bound.add(rel)
            if cls == "QUARANTINED":
                quarantined.add(rel)
            path = ROOT / rel
            if not path.exists():
                errors.append(f"binding row names missing file {rel}")
                continue
            if rel.startswith(vendored_exempt()):
                continue
            if SPEC_REL not in path.read_text(encoding="utf-8"):
                errors.append(f"{rel} does not cite {SPEC_REL} (C7)")

    errors += [f"arithmetic consumer lacks binding row: {rel}" for rel in sorted(arithmetic_consumers() - bound)]

    allow = allowlisted()
    errors += [f"{rel} is QUARANTINED but not allowlisted" for rel in sorted(quarantined - allow)]
    errors += [f"{rel} is allowlisted but not a QUARANTINED binding row" for rel in sorted(allow - quarantined)]

    for path in kernel_files():
        rel = path.relative_to(ROOT).as_posix()
        if rel in allow or rel.startswith("vendor/mojo/finite_exact/"):
            continue
        for lineno, line in code_lines(path.read_text(encoding="utf-8")):
            if FLOAT_RE.search(line):
                errors.append(f"{rel}:{lineno}: floating point in kernel scope (C1): {line.strip()}")
    return list(dict.fromkeys(errors))


def main() -> int:
    errors = audit()
    if errors:
        print("exact-arithmetic audit failed:\n")
        print("\n".join(f"- {e}" for e in errors))
        print(f"\nSee {SPEC_REL}, sections 5 to 7, and {BINDING_REL}.")
        return 1
    print("OK: every arithmetic consumer is bound, cites the spec, and stays exact.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
