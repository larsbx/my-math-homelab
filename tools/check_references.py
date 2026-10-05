#!/usr/bin/env python3
"""Check that the path and task references in this repository resolve.

The engine is the vendored `references` package; this file is the policy.
A reference that resolves to nothing is a sentence nobody can follow, and the
design analysis carried one for a day before this check existed.

Usage: check_references.py            exit 1 on any unresolved reference
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "vendor" / "python"))

from references.check_references import Policy, run  # noqa: E402

#: The vendored packages carry upstream's prose, which names upstream's tests
#: and tools; those paths are attested below rather than resolved here.
KERNELS = "larsbx/finite-math-kernels at the commit pinned in vendored.toml"
#: Pinned: the estate layout later moved these paths (src/ -> kernel/mojo/<domain>/,
#: spec/ -> schemas/), and a mirrored document names them as they were.
MANDELBROT = "larsbx/finite-mandelbrot-research at 834446b, before its estate layout"

#: The first consumer of the vendored `finite_linear_algebra/integer_vector.mojo`,
#: whose header names that consumer's benchmark.
PISOT = "larsbx/pisot-substitution-conjecture-research, the first consumer of integer_vector"

#: Every entry says which repository the path lives in. A reader can check an
#: attestation; a bare exemption would only say that someone once decided not
#: to look.
EXTERNAL: dict[str, str] = {
    # Named by the mirrored arithmetic specification, which describes upstream.
    "audit/CONSOLIDATION_PROVENANCE.md": KERNELS,
    "audit/provenance.json": KERNELS,
    "docs/exact-arithmetic-public-boundary.md": KERNELS,
    "tests/finite_exact/property_probe.mojo": KERNELS,
    "tests/finite_exact/test_finite_exact.mojo": KERNELS,
    "tools/property_oracle.py": KERNELS,
    # Named by documents mirrored from the parameter-plane program.
    "docs/rank2-coordinate-substrate.md": MANDELBROT,
    "spec/regime_correspondences.toml": MANDELBROT,
    "src/interval_orbit.mojo": MANDELBROT,
    "docs/no-points-invariant.md": MANDELBROT,
    "docs/rational-trigonometry-policy.md": MANDELBROT,
    "src/complex_inverse.mojo": MANDELBROT,
    "src/krawczyk_witness.mojo": MANDELBROT,
    "tools/audit_no_points.py": MANDELBROT,
    "docs/atlas-dataset.md": MANDELBROT,
    "docs/exact-polynomial-root-isolation-spec.md": KERNELS,
    # Named by the vendored `finite_linear_algebra` headers, which are upstream's.
    "docs/madic-ball-arithmetic-spec.md": KERNELS,
    "reference/qpoly_reference.py": KERNELS,
    "test_integer_vector.mojo": KERNELS,
    "kernel/integer_vector_bench.mojo": PISOT,
    # Named by the vendored `substitution_dynamics` headers and by the note
    # that hands them a word.
    "docs/tuning-substitutions-spec.md": KERNELS,
    "reference/tuning_reference.py": KERNELS,
    "tests/substitution_dynamics/test_tuning.mojo": KERNELS,
    # Named by the vendored `mojo_smoke/claims.mojo`, which links a test to a
    # claim in a consumer's ledger; this repository keeps no such ledger.
    "claim_governance.toml": "a consumer repository root, per larsbx/finite-math-kernels docs/audit/policy-format.md",
    "tools/claim_governance/checks/coverage.py": KERNELS,
}

#: Tasks the mirrored specification names, which belong to upstream's manifest.
EXTERNAL_TASKS: dict[str, str] = {
    "test-finite-exact": KERNELS,
    "property": KERNELS,
}

#: Files that contain synthetic references by construction: each builds a
#: repository in a temporary directory and asserts what the audit says about
#: it, so its paths are fixtures rather than claims.
SKIPPED_PREFIXES = ("tests/test_exact_arithmetic_audit.py", "tests/test_check_references.py")

#: The vendored include roots. A package-relative path such as
#: `finite_exact/closed_q.mojo` resolves to the pinned copy beneath one of
#: them, so it needs no attestation: the file is here, at the pinned bytes.
PACKAGE_ROOTS = ("vendor/mojo", "vendor/python")

POLICY = Policy(
    external=EXTERNAL,
    external_tasks=EXTERNAL_TASKS,
    skipped_prefixes=SKIPPED_PREFIXES,
    package_roots=PACKAGE_ROOTS,
)


if __name__ == "__main__":
    sys.exit(run(ROOT, POLICY))
