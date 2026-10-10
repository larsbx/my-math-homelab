#!/usr/bin/env python3
"""Audit PSC manuscript sources for stale or overclaiming formulations.

The audit is intentionally conservative: it catches phrases that caused
version drift during the v11 -> v12.1 transition. It is not a LaTeX prover;
it is a CI guardrail against known bad claims.
"""
from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

TEXT_SUFFIXES = {".tex", ".md", ".txt", ".rst"}
DEFAULT_SKIP_DIRS = {
    ".git",
    ".pytest_cache",
    "__pycache__",
    "dist",
    "build",
    ".venv",
    "venv",
}

CURRENT_SURFACE = {
    "README.md",
    "docs/proof-ladder.md",
    "docs/conjecture-ledger.md",
    "docs/boundary-synchronization.md",
    "docs/automation-protocol.md",
}


@dataclass(frozen=True)
class Rule:
    name: str
    pattern: re.Pattern[str]
    message: str


RULES: tuple[Rule, ...] = (
    Rule(
        name="synthetic-countermodel-transpose",
        pattern=re.compile(r"N[_ ]?C\s*=\s*M[_ ]?sigma(?!\s*(?:\^T|\\top|\^\\top|\^\\T))", re.IGNORECASE),
        message="Synthetic countermodel must be N_C = M_sigma^T, P = I; not N_C = M_sigma.",
    ),
    Rule(
        name="old-cycle-exclusion-target",
        pattern=re.compile(r"no recurrent noncoincident cycle", re.IGNORECASE),
        message="Cycle-exclusion is a retired false target; use SCC Producer / nonsynchronizing trap framing.",
    ),
    Rule(
        name="future-replacement-overclaim",
        pattern=re.compile(r"self-contained replacement is in preparation", re.IGNORECASE),
        message="Do not promise a self-contained replacement; state the precise open conjecture instead.",
    ),
    Rule(
        name="unconditional-main-theorem",
        pattern=re.compile(
            r"Then\s+(?:the\s+)?associated\s+tiling\s+dynamical\s+system\s+has\s+pure\s+discrete\s+spectrum(?![^.]{0,120}conditional)",
            re.IGNORECASE | re.DOTALL,
        ),
        message="Main PDS claim must be explicitly conditional unless SCC Producer is proved.",
    ),
    Rule(
        name="psc-closed-premise",
        pattern=re.compile(
            r"(?i:\b(?:PSC|Pisot\s+Substitution\s+Conjecture)\b(?:\s+[\w-]+){0,2}?"
            r"\s+(?:is|as|was|has\s+been)\s+(?:(?:now|treated\s+as|considered)\s+)?"
            r"(?:closed|proved|proven|settled|resolved)\b)"
            r"|(?<![\w/-])post-PSC(?![\w-])"
        ),
        message="PSC is open (one open premise, OP_seed / #84); do not state or premise it as proved or closed.",
    ),
    Rule(
        name="loose-subblock-language",
        pattern=re.compile(r"contains\s+M[_ ]?sigma\s+as\s+an\s+invariant\s+sub-?block", re.IGNORECASE),
        message="Use 'acts on an invariant subspace as a similar copy of M_sigma' instead of loose sub-block language.",
    ),
)


def iter_text_files(root: Path, strict_current: bool = False):
    if strict_current:
        base = root.resolve()
        for rel in sorted(CURRENT_SURFACE):
            path = base / rel
            if path.exists():
                yield path
        return

    for path in root.rglob("*"):
        if path.is_dir():
            continue
        if any(part in DEFAULT_SKIP_DIRS for part in path.parts):
            continue
        if path.suffix.lower() in TEXT_SUFFIXES:
            yield path


def audit_file(path: Path) -> list[str]:
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return []
    failures: list[str] = []
    for rule in RULES:
        for match in rule.pattern.finditer(text):
            # Use paragraph context so ordinary TeX/Markdown line wrapping does
            # not change the semantic audit result.
            para_break = text.rfind("\n\n", 0, match.start())
            para_start = 0 if para_break == -1 else para_break + 2
            para_end = text.find("\n\n", match.end())
            if para_end == -1:
                para_end = len(text)
            paragraph = " ".join(text[para_start:para_end].split())

            if rule.name == "synthetic-countermodel-transpose":
                # Exempt only the exact occurrence that is syntactically the
                # middle of the proved Parikh intertwiner
                # P_C N_C = M_sigma P_C.  A second bad assignment elsewhere
                # on the same line/paragraph must still be rejected.
                before = text[max(0, match.start() - 32):match.start()]
                after = text[match.end():match.end() + 32]
                if (
                    re.search(r"P[_ ]?C\s*$", before, re.IGNORECASE)
                    and re.match(r"\s+P[_ ]?C\b", after, re.IGNORECASE)
                ):
                    continue

                # Guidance may quote the stale form if it explicitly requires
                # a supported transposed replacement.  Match all transpose
                # spellings accepted by the base rule.
                transpose = (
                    r"N[_ ]?C\s*=\s*M[_ ]?sigma"
                    r"\s*(?:\^T|\\top|\^\\top|\^\\T)"
                )
                if (
                    re.search(transpose, paragraph, re.IGNORECASE)
                    and re.search(
                        r"\b(?:must|instead|stale|replace|replacement|should)\b",
                        paragraph,
                        re.IGNORECASE,
                    )
                ):
                    continue

            if rule.name == "old-cycle-exclusion-target":
                # Permit only explicit rejection/retirement of the matched
                # target.  Mere historical framing such as "earlier work
                # proves ..." is still an affirmative false claim and fails.
                if re.search(
                    r"\b(?:false|retired|withdrawn|no longer|do not|don't)\b",
                    paragraph,
                    re.IGNORECASE,
                ):
                    continue

            if rule.name == "psc-closed-premise":
                # Permit only guidance or retraction that negates the claim,
                # e.g. "Never describe ... PSC as proved" or "... is withdrawn".
                # A Markdown list is read together with the colon-terminated
                # lead-in paragraph that introduces it ("Avoid these ...:").
                context = paragraph
                if re.match(r"[-*+]\s|\d+[.)]\s", paragraph):
                    lead_end = para_start - 2 if para_break != -1 else -1
                    lead_break = text.rfind("\n\n", 0, max(lead_end, 0))
                    lead = " ".join(text[lead_break + 2 if lead_break != -1 else 0:max(lead_end, 0)].split())
                    if lead.endswith(":"):
                        context = f"{lead} {paragraph}"
                if re.search(
                    r"\b(?:never|not|withdrawn|false|retired|no longer|avoid)\b",
                    context,
                    re.IGNORECASE,
                ):
                    continue

            line = text.count("\n", 0, match.start()) + 1
            snippet = " ".join(match.group(0).split())
            failures.append(f"{path}:{line}: {rule.name}: {rule.message} [matched: {snippet!r}]")
    return failures


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd(), help="repository root to audit")
    parser.add_argument(
        "--strict-current",
        action="store_true",
        help="audit only the canonical current manuscript/research surface, not archives",
    )
    args = parser.parse_args(argv)

    root = args.root.resolve()
    failures: list[str] = []
    for path in iter_text_files(root, strict_current=args.strict_current):
        failures.extend(audit_file(path))

    if failures:
        print("PSC manuscript/source audit failed:", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1
    print("PSC manuscript/source audit passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
