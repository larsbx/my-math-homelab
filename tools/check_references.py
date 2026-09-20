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
sys.path.insert(0, str(ROOT / "tools"))

from references.check_references import Policy, run  # noqa: E402

#: The vendored packages carry upstream's prose, which names upstream's tests
#: and tools; those paths are attested below rather than resolved here.
KERNELS = "larsbx/finite-math-kernels at the commit pinned in vendored.toml"
MANDELBROT = "larsbx/finite-mandelbrot-research"

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
    # Named by the specification as package-relative upstream paths.
    "finite_exact/bigint_z.mojo": KERNELS,
    "finite_exact/rat_q.mojo": KERNELS,
    "finite_exact/closed_q.mojo": KERNELS,
    "finite_exact/closed_interval.mojo": KERNELS,
    "finite_exact/interval_q.mojo": KERNELS,
    "finite_exact/enclosure_width.mojo": KERNELS,
    "quadratic_orbit/preperiodic.mojo": KERNELS,
    "angle_doubling/angle.mojo": KERNELS,
    "projective/chart.mojo": KERNELS,
    "projective/homogeneous.mojo": KERNELS,
    # Named by documents mirrored from the parameter-plane program.
    "docs/rank2-coordinate-substrate.md": MANDELBROT,
    "spec/regime_correspondences.toml": MANDELBROT,
    "src/interval_orbit.mojo": MANDELBROT,
    "docs/no-points-invariant.md": MANDELBROT,
    "docs/rational-trigonometry-policy.md": MANDELBROT,
    "src/complex_inverse.mojo": MANDELBROT,
    "src/krawczyk_witness.mojo": MANDELBROT,
    "tools/audit_no_points.py": MANDELBROT,
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

POLICY = Policy(external=EXTERNAL, external_tasks=EXTERNAL_TASKS, skipped_prefixes=SKIPPED_PREFIXES)


if __name__ == "__main__":
    sys.exit(run(ROOT, POLICY))
