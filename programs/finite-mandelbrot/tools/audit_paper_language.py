#!/usr/bin/env python3
"""Audit field-facing mathematical manuscripts for project-internal language.

This audit is intentionally narrower than the repository terminology audit.  It
scans manuscript `.tex` files under `paper/` and rejects internal project names,
implementation labels, and proof-engineering slogans that would make the paper
less legible to mathematicians in complex dynamics.

The paper may discuss finite certificates, rational parameter rays, fibers,
landing theorems, interval certificates, algebraic computation, and proof
checking in field-standard language.  It must not depend on repository-private
labels to state the mathematics.
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAPER_ROOT = ROOT / "paper"


@dataclass(frozen=True)
class BannedTerm:
    pattern: str
    replacement: str
    reason: str
    regex: bool = False


BANNED_TERMS = [
    BannedTerm(
        r"\bC1\b",
        "the main conjecture, the separator formulation, or the proof criterion",
        "private conjecture label",
        True,
    ),
    BannedTerm(
        "finite-mandlebrot-research",
        "this paper or this program",
        "repository name, not mathematical terminology",
    ),
    BannedTerm(
        "Mojo",
        "a proof-checking implementation, only outside the paper or in non-mathematical build notes",
        "implementation language should not frame the mathematical manuscript",
    ),
    BannedTerm(
        "theorem kernel",
        "finite proof checker or proof-object checker",
        "proof-engineering phrase rather than standard complex-dynamics terminology",
    ),
    BannedTerm(
        "separator-catalogue",
        "finite rational-ray separation certificates or finite enumeration of rational-ray separators",
        "repository-internal compound term",
    ),
    BannedTerm(
        "separator catalogue",
        "finite rational-ray separation certificates or finite enumeration of rational-ray separators",
        "repository-internal compound term",
    ),
    BannedTerm(
        "catalogue extensionality",
        "adequacy of finite rational-ray separation certificates",
        "deprecated project phrase",
    ),
    BannedTerm(
        "carrier",
        "finite record, finite certificate state, or finite incidence data",
        "project-internal proof-route term",
    ),
    BannedTerm(
        "ResidualClosureNoMissingLinks",
        "the residual case closes without missing assumptions",
        "private proof-block label",
    ),
    BannedTerm(
        "ExitClosureForC1",
        "closure of residual alternatives",
        "private proof-block label",
    ),
    BannedTerm(
        "ResidualFrontierRefinement",
        "the residual case forces finite progress",
        "private proof-block label",
    ),
    BannedTerm(
        "ResidualDescentContradiction",
        "well-founded descent argument for the residual case",
        "private proof-block label",
    ),
    BannedTerm(
        "PRIORITY_ZERO",
        "main open problem or principal objective",
        "repository planning label",
    ),
    BannedTerm(
        "OPEN_FRONTIER",
        "open problem or remaining analytic difficulty",
        "repository status label",
    ),
]

FIELD_REQUIRED_TERMS = [
    "Mandelbrot set",
    "quadratic family",
    "rational parameter rays",
    "fiber",
    "finite certificate",
    "Mandelbrot local connectivity",
]

FIELD_REQUIRED_REFERENCES = [
    "DouadyHubbardEtude",
    "SchleicherRationalParameterRays",
    "SchleicherFibersLC",
    "MilnorOrbitPortraits",
]


def iter_paper_tex_files() -> list[Path]:
    if not PAPER_ROOT.exists():
        return []
    return sorted(PAPER_ROOT.glob("*.tex"))


def strip_comments(text: str) -> str:
    lines: list[str] = []
    for line in text.splitlines():
        escaped = False
        kept: list[str] = []
        for ch in line:
            if ch == "%" and not escaped:
                break
            kept.append(ch)
            escaped = ch == "\\" and not escaped
            if ch != "\\":
                escaped = False
        lines.append("".join(kept))
    return "\n".join(lines)


def find_banned(text: str, term: BannedTerm) -> list[tuple[int, str]]:
    if term.regex:
        matches = list(re.finditer(term.pattern, text))
    else:
        matches = list(re.finditer(re.escape(term.pattern), text, flags=re.IGNORECASE))
    hits: list[tuple[int, str]] = []
    for match in matches:
        line = text.count("\n", 0, match.start()) + 1
        excerpt = text[match.start(): match.end()]
        hits.append((line, excerpt))
    return hits


def audit_file(path: Path) -> list[str]:
    raw = path.read_text(encoding="utf-8")
    text = strip_comments(raw)
    errors: list[str] = []
    rel = path.relative_to(ROOT).as_posix()

    for term in BANNED_TERMS:
        for line, excerpt in find_banned(text, term):
            errors.append(
                f"{rel}:{line}: banned project-internal term {excerpt!r}; "
                f"use {term.replacement}; reason: {term.reason}"
            )

    for required in FIELD_REQUIRED_TERMS:
        if required not in text:
            errors.append(
                f"{rel}: missing field-facing term {required!r}; manuscript may be too internal"
            )

    for ref in FIELD_REQUIRED_REFERENCES:
        if ref not in text:
            errors.append(
                f"{rel}: missing core bibliography citation key {ref!r}"
            )

    if "not a proof" not in text and "not prove" not in text:
        errors.append(
            f"{rel}: manuscript must explicitly state that the finite certificate criterion is not itself a proof of MLC"
        )

    return errors


def main() -> int:
    files = iter_paper_tex_files()
    errors: list[str] = []
    if not files:
        errors.append("paper/: no LaTeX manuscript files found")
    for path in files:
        errors.extend(audit_file(path))

    if errors:
        print("Paper language audit failed:")
        for error in errors:
            print(f"- {error}")
        return 1
    print("Paper language audit passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
