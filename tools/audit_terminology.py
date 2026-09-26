#!/usr/bin/env python3
"""Audit the forbidden usages of `docs/terminology-registry.md` in prose.

`tests/test_documented_invariants.py` already bans the circle family as
*identifiers* in the executable core. That check never reads a sentence, so
the registry's forbidden usages -- which are about what the prose claims, not
about what the code declares -- were written down and not enforced. This
closes that gap.

The rule: the circle family is not available at rank 2, so its vocabulary may
not appear in this repository's prose or comments unless the occurrence is
covered by one of four exemptions, each of which is explicit and mechanical:

1. a phrase registered under "Established field terms" in the registry, used
   verbatim (`Siegel disk`, `circular points`);
2. a clause that denies the term ("not a circle", "no arc is available");
3. a section whose heading forbids ("## Forbidden usages");
4. a paragraph preceded by `<!-- terminology-exempt: reason -->`, or a
   literature gate, where the repository quotes a classical statement.

The registry is the source of truth: exemption 1 is read out of it rather
than duplicated here.

What is deliberately *not* banned is the bare word "angle". The registry
forbids deriving an angle *from the quadrance-1 locus*; it does not forbid
the rational angles of `Q/Z`, which are Route A field language and which
Phase 3 needs. A word ban there would be a gate that has to be switched off
to do correct work, which is worse than no gate.
"""

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "docs" / "terminology-registry.md"

#: The rank-2 unavailable vocabulary. `docs/terminology-governance.md`: "A
#: circle is undefined at rank 2."
BANNED = re.compile(
    r"\b(circles?|circular|discs?|disks?|arcs?|circumferences?|polar angles?|radians?)\b",
    re.IGNORECASE,
)

CLAUSE = re.compile(r"(?<=[.;:])\s+")

#: A clause that denies the term is a use of the prohibition, not a breach --
#: but the denial must *precede* the term and stay close enough to be denying
#: that term. Both halves matter. Reaching backwards only keeps "and not a
#: root of unity" from excusing what came before it; the distance keeps "it
#: never returns" from excusing a "disc" half a sentence earlier, which is
#: exactly how the phrase this audit was written for got through. The reach is
#: wide enough for one leading denial to cover an enumeration ("no circle,
#: disk, arc, polar angle").
DENIAL = re.compile(r"\b(no|not|nor|never|none|without|undefined|unavailable|cannot|forbidden|forbids|refuses)\b", re.IGNORECASE)
DENIAL_REACH = 48

EXEMPT_MARKER = re.compile(r"<!--\s*terminology-exempt:\s*(?P<reason>[^>]+?)\s*-->")

#: The registry clause this audit exists to enforce, checked for verbatim so
#: the audit cannot outlive the rule it enforces.
REQUIRED_CLAUSE = "calling the quadrance-1 locus of `J_0` a circle"

#: A claim the repository named, judged, and found false stays citable only as
#: a rejected one. The names are read from the registry rather than repeated
#: here, and an occurrence passes only with a rejection word within reach.
REJECTED_SECTION = "## Rejected bridge claims"
REJECTION = re.compile(r"reject", re.IGNORECASE)
REJECTION_REACH = 320

SELF = "tools/audit_terminology.py"


def vendored() -> set[Path]:
    manifest = tomllib.loads((ROOT / "vendored.toml").read_text(encoding="utf-8"))
    return {ROOT / pkg["root"] / pkg["name"] for pkg in manifest.get("package", [])}


def own_files() -> list[Path]:
    copied = vendored()
    return sorted(
        path
        for directory, pattern in (("docs", "*.md"), ("tools", "*.py"), ("src", "*.mojo"))
        for path in (ROOT / directory).rglob(pattern)
        if not any(parent in copied for parent in path.parents)
    )


def rel(path: Path) -> str:
    """The repository-relative path, or the path itself if it lies outside."""
    return path.as_posix() if ROOT not in path.parents else path.relative_to(ROOT).as_posix()


def field_terms() -> list[str]:
    """Registered field terms that contain banned vocabulary, from the registry."""
    text = REGISTRY.read_text(encoding="utf-8")
    section = text.split("## Established field terms", 1)[-1].split("\n## ", 1)[0]
    entries = (re.split(r"[(`]", item)[0].strip()
               for line in section.splitlines() if line.startswith("- ")
               for item in line[2:].split(","))
    return [entry for entry in entries if BANNED.search(entry)]


def rejected_claims() -> list[str]:
    """The names under the registry's rejected-claims section."""
    text = REGISTRY.read_text(encoding="utf-8")
    if REJECTED_SECTION not in text:
        return []
    section = text.split(REJECTED_SECTION, 1)[1].split("\n## ", 1)[0]
    return [line[4:].strip() for line in section.splitlines() if line.startswith("### ")]


def strip_comment(line: str) -> str:
    return re.sub(r'^\s*(#+\s?|"""|\'\'\')', "", line).replace('"""', "")


def units(path: Path) -> list[tuple[int, str, str]]:
    """`(line number, heading, clause)` for every clause of a file.

    A clause is a sentence of a paragraph, a list item, or a table row. The
    heading is the nearest preceding markdown heading, or the marker reason
    when the paragraph carries one.
    """
    markdown = path.suffix == ".md"
    heading, marker, out = "", "", []
    block: list[tuple[int, str]] = []

    def flush() -> None:
        nonlocal block
        if block:
            start = block[0][0]
            joined = " ".join(text.strip() for _, text in block)
            for sentence in CLAUSE.split(joined):
                if sentence:
                    out.append((start, marker or heading, sentence))
        block = []

    for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        line = raw if markdown else strip_comment(raw)
        if markdown and line.startswith("#"):
            flush()
            heading, marker = line, ""
            continue
        found = EXEMPT_MARKER.search(line)
        if found:
            flush()
            marker = found.group("reason")
            continue
        if not line.strip():
            flush()
            marker = ""
            continue
        if line.lstrip().startswith(("- ", "* ", "|")) or re.match(r"\s*\d+\.\s", line):
            flush()
        block.append((number, line))
    flush()
    return out


def mask(clause: str, terms: list[str]) -> str:
    """Blank registered field terms, keeping offsets so denials stay in reach.

    A space in a registered term also matches a hyphen, so a term reads the
    same inside a repository slug (`ford-circles`).
    """
    for term in terms:
        pattern = re.escape(term).replace(r"\ ", r"[\s-]")
        clause = re.sub(pattern, lambda found: " " * len(found.group(0)), clause, flags=re.IGNORECASE)
    return clause


def denied(clause: str, start: int, end: int) -> bool:
    """Is the occurrence at `[start, end)` denied by a preceding denial word?"""
    return any(0 <= start - found.end() <= DENIAL_REACH for found in DENIAL.finditer(clause))


def audit_registry(errors: list[str]) -> None:
    if not REGISTRY.exists():
        errors.append("docs/terminology-registry.md: the registry is missing")
        return
    text = REGISTRY.read_text(encoding="utf-8")
    for required in ("## Established field terms", "## Forbidden usages", REJECTED_SECTION, REQUIRED_CLAUSE, SELF):
        if required not in text:
            errors.append(f"docs/terminology-registry.md: missing {required!r}")


def audit_rejected(path: Path, claims: list[str], errors: list[str]) -> None:
    """Every mention of a rejected claim has to say so within reach."""
    if rel(path) == REGISTRY.relative_to(ROOT).as_posix() or path.name.startswith("literature-gate"):
        return
    text = path.read_text(encoding="utf-8")
    for claim in claims:
        for found in re.finditer(re.escape(claim), text):
            window = text[max(0, found.start() - REJECTION_REACH): found.end() + REJECTION_REACH]
            if not REJECTION.search(window):
                errors.append(
                    f"{rel(path)}: {claim!r} is a rejected claim and must be cited as one; "
                    "see the registry's rejected-claims section"
                )


def audit_file(path: Path, terms: list[str], errors: list[str]) -> None:
    if rel(path) == SELF or path.name.startswith("literature-gate"):
        return
    for number, heading, clause in units(path):
        if "forbidden" in heading.lower() or EXEMPT_MARKER.search(heading):
            continue
        if heading and not heading.startswith("#"):
            continue  # an exemption marker's reason, recorded at the paragraph
        masked = mask(clause, terms)
        for found in BANNED.finditer(masked):
            if denied(masked, found.start(), found.end()):
                continue
            errors.append(
                f"{rel(path)}:{number}: '{found.group(0)}' is not available at rank 2; "
                "register it, deny it, or mark the paragraph with "
                "<!-- terminology-exempt: reason -->"
            )


def main() -> int:
    errors: list[str] = []
    audit_registry(errors)
    if not errors:
        terms, claims = field_terms(), rejected_claims()
        for path in own_files():
            audit_file(path, terms, errors)
            audit_rejected(path, claims, errors)
    if errors:
        print("Terminology audit failed:")
        for error in errors:
            print(f"- {error}")
        return 1
    print(f"Terminology audit passed: {len(own_files())} files, registry clauses enforced.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
