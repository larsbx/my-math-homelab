#!/usr/bin/env python3
"""Audit the exact-arithmetic hook (docs/rational-interval-arithmetic-spec.md).

This repository's policy over the vendored ``exact_arithmetic_audit`` engine
(``vendor/python/exact_arithmetic_audit``, pinned in ``vendored.toml``), which
checks, lexically and CI-cheaply:

1. the specification exists, carries every required section heading, and
   names this repository as a consumer;
2. every module named in this repository's binding table (spec section 6.2)
   exists and cites the specification by path (criterion C7), except the
   vendored facades below, whose headers are upstream's;
3. every kernel module importing a ``Q``/``IQ`` layer module of
   ``finite_exact`` has a binding row;
4. the allowlist's list items are exactly the QUARANTINED rows;
5. no floating-point type, SIMD float dtype or decimal literal appears in
   executable kernel code outside the allowlist (criterion C1).

Consumers are discovered by the four ``Q``/``IQ`` modules only. A wider
reading (any ``finite_exact`` import) would also demand rows for modules that
use only ``integer_gcd``, ``bigint_z`` or ``exact_decimal``, which are not
consumers of the rational or interval layers the binding table governs.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "vendor" / "python"))
from exact_arithmetic_audit import Policy, audit as engine_audit, run  # noqa: E402

SPEC_REL = "docs/rational-interval-arithmetic-spec.md"
SPEC = ROOT / SPEC_REL
ALLOWLIST_REL = "tools/exact_arithmetic_allowlist.md"
ALLOWLIST = ROOT / ALLOWLIST_REL
# The specification spells this repository "finite-mandlebrot-research".
BINDING_HEADING = "### 6.2 `larsbx/finite-mandlebrot-research`"

REQUIRED_SECTIONS = (
    "## 0. The problem being solved",
    "## 1. Layer ℚ: eliminate rounding",
    "### 1.5 Backend requirement",
    "## 2. Layer I: keep rounding, bound it",
    "### 2.3 The inclusion theorem",
    "### 2.4 Decision semantics",
    "## 3. Combining the layers",
    "### 3.2 Filter-then-exact",
    "## 4. Decision table",
    "## 5. Conformance criteria",
    "## 6. Repository binding",
    "### 6.1 `larsbx/pisot-substitution-conjecture-research`",
    BINDING_HEADING,
    "## 7. Hook: how the specification is enforced",
)

VENDORED_FACADES = frozenset({
    # These pinned upstream facades/field instances retain upstream's headers;
    # byte identity is enforced by the vendoring gate rather than local edits.
    "vendor/mojo/finite_exact/rational.mojo",
    "vendor/mojo/finite_exact/closed_interval.mojo",
    "vendor/mojo/finite_exact/field.mojo",
    "vendor/mojo/finite_exact/fp.mojo",
})

POLICY = Policy(
    repository="larsbx/finite-mandlebrot-research",
    spec=SPEC_REL,
    required_sections=REQUIRED_SECTIONS,
    binding_heading=BINDING_HEADING,
    classes=None,
    allowlist=ALLOWLIST_REL,
    scan_roots=("kernel", "vendor/mojo"),
    arithmetic_modules=("rat_q", "rational", "closed_q", "closed_interval"),
    skip_hidden=True,
    citation_exempt=VENDORED_FACADES,
    exempt_vendored_citations=False,
)


def audit(root: Path = ROOT, policy: Policy = POLICY) -> list[str]:
    """Every violation under this repository's policy; empty means clean."""
    return engine_audit(root, policy)


def main() -> int:
    return run(ROOT, POLICY)


if __name__ == "__main__":
    sys.exit(main())
