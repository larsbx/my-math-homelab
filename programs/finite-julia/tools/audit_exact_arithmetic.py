#!/usr/bin/env python3
"""Enforce the exact-arithmetic contract on this repository's kernel scope.

Section 7 of `docs/rational-interval-arithmetic-spec.md` asks a consumer with
certificate paths for a lexical floating-point scan, a binding row per direct
arithmetic consumer, and the C7 citation check. The engine is the vendored
`exact_arithmetic_audit` package; this file is the policy, over
`docs/exact-arithmetic-binding.md`.

What the policy decides:

1. the binding table is its own document, and its rows use the four classes
   of the specification's section 6;
2. the scan reads the Mojo of `kernel/` and of `vendor/mojo/`, whose
   arithmetic consumers are bound here even though their headers are
   upstream's; every vendored package file is exempt from the citation (C7),
   read from `vendored.toml`, so vendoring a package widens the exemption in
   the same step;
3. the vendored `finite_exact` package, the arithmetic itself, is exempt from
   the floating-point scan (C1);
4. the allowlist is `tools/exact_arithmetic_allowlist.md`, and it is empty.

Usage: audit_exact_arithmetic.py            exit 1 on any violation
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "vendor" / "python"))

from exact_arithmetic_audit import CLASSES, Policy, run  # noqa: E402

POLICY = Policy(
    repository="larsbx/finite-julia-set-research",
    spec="docs/rational-interval-arithmetic-spec.md",
    required_sections=(
        "## 0. The problem being solved",
        "## 5. Conformance criteria",
        "## 6. Consumers and binding tables",
        "## 7. Hook: how a consumer enforces the specification",
    ),
    binding="docs/exact-arithmetic-binding.md",
    classes=CLASSES,
    allowlist="tools/exact_arithmetic_allowlist.md",
    scan_roots=("kernel", "vendor/mojo"),
    suffixes=(".mojo",),
    exempt_vendored_citations=True,
    float_exempt_prefixes=("vendor/mojo/finite_exact/",),
)


if __name__ == "__main__":
    sys.exit(run(ROOT, POLICY))
