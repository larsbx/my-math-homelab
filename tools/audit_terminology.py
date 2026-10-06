#!/usr/bin/env python3
"""Audit the forbidden usages of `docs/terminology-registry.md` in prose.

`tests/test_documented_invariants.py` already bans the circle family as
*identifiers* in the executable core. That check never reads a sentence, so
the registry's forbidden usages -- which are about what the prose claims, not
about what the code declares -- were written down and not enforced. This
closes that gap. The engine is the vendored `lexical_audit` package; this
file is the policy.

The rule: the circle family is not available at rank 2, so its vocabulary may
not appear in this repository's prose or comments unless the occurrence is
covered by one of four exemptions, each of which is explicit and mechanical:

1. a phrase registered under "Established field terms" in the registry, used
   verbatim (`Siegel disk`, `circular points`);
2. a clause that denies the term ("not a circle", "no arc is available"): the
   denial must *precede* the term, within 48 characters, so that "and not a
   root of unity" cannot excuse what came before it and "it never returns"
   cannot excuse a "disc" half a sentence earlier;
3. a section whose heading forbids ("## Forbidden usages");
4. a paragraph preceded by `<!-- terminology-exempt: reason -->`, or a
   literature gate, where the repository quotes a classical statement.

The registry is the source of truth: exemption 1 is read out of it rather
than duplicated here, and so are the rejected claims, each of which may be
mentioned only with a rejection word within reach.

What is deliberately *not* banned is the bare word "angle". The registry
forbids deriving an angle *from the quadrance-1 locus*; it does not forbid
the rational angles of `Q/Z`, which are Route A field language and which
Phase 3 needs. A word ban there would be a gate that has to be switched off
to do correct work, which is worse than no gate.
"""

from __future__ import annotations

import re
import sys
from dataclasses import replace
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "vendor" / "python"))

from lexical_audit import ClauseRule, ContextRule, Document, Policy, Scope, contains, run  # noqa: E402

REGISTRY = "docs/terminology-registry.md"
SELF = "tools/audit_terminology.py"

#: The rank-2 unavailable vocabulary. `docs/terminology-governance.md`: "A
#: circle is undefined at rank 2."
BANNED = r"(?i)\b(circles?|circular|discs?|disks?|arcs?|circumferences?|polar angles?|radians?)\b"
DENIAL = r"(?i)\b(no|not|nor|never|none|without|undefined|unavailable|cannot|forbidden|forbids|refuses)\b"

#: The registry clause this audit exists to enforce, checked for verbatim so
#: the audit cannot outlive the rule it enforces.
REQUIRED_CLAUSE = "calling the quadrance-1 locus of `J_0` a circle"
FIELD_SECTION = "## Established field terms"
REJECTED_SECTION = "## Rejected bridge claims"

SCOPE = Scope(
    include=("docs/**/*.md", "tools/**/*.py", "reference/**/*.py", "oracles/**/*.py", "kernel/**/*.mojo"),
    exclude=("*/literature-gate*",),
    skip_vendored=True,
)


def _section(text: str, heading: str) -> str:
    return text.split(heading, 1)[1].split("\n## ", 1)[0] if heading in text else ""


def field_terms(registry: str) -> tuple[str, ...]:
    """Registered field terms that contain banned vocabulary."""
    entries = (re.split(r"[(`]", item)[0].strip()
               for line in _section(registry, FIELD_SECTION).splitlines() if line.startswith("- ")
               for item in line[2:].split(","))
    return tuple(entry for entry in entries if re.search(BANNED, entry))


def rejected_claims(registry: str) -> tuple[str, ...]:
    """The names under the registry's rejected-claims section."""
    return tuple(line[4:].strip() for line in _section(registry, REJECTED_SECTION).splitlines() if line.startswith("### "))


def policy(root: Path = ROOT) -> Policy:
    registry = root / REGISTRY
    text = registry.read_text(encoding="utf-8") if registry.is_file() else ""
    return Policy(
        title="Terminology audit",
        documents=(Document(REGISTRY, f"{REGISTRY}: the registry is missing", tuple(
            contains(required, f"{REGISTRY}: missing {required!r}")
            for required in (FIELD_SECTION, "## Forbidden usages", REJECTED_SECTION, REQUIRED_CLAUSE, SELF)
        )),),
        rules=(
            ClauseRule(
                scope=replace(SCOPE, exclude=(*SCOPE.exclude, SELF)),
                banned=BANNED,
                message="{path}:{line}: '{match}' is not available at rank 2; register it, deny it, "
                        "or mark the paragraph with <!-- terminology-exempt: reason -->",
                denial=DENIAL,
                reach=48,
                clause=r"(?<=[.;:])\s+",
                exempt_sections=("(?i)forbidden",),
                marker="terminology-exempt",
                allowed=field_terms(text),
            ),
            ContextRule(
                scope=replace(SCOPE, exclude=(*SCOPE.exclude, REGISTRY)),
                terms=rejected_claims(text),
                message="{path}: {term!r} is a rejected claim and must be cited as one; "
                        "see the registry's rejected-claims section",
                context=("reject",),
                radius=320,
            ),
        ),
    )


def main() -> int:
    return run(ROOT, policy())


if __name__ == "__main__":
    sys.exit(main())
