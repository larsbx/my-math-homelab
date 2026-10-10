#!/usr/bin/env python3
"""Audit backend.toml for proof-grade arithmetic safety.

The manifest is intentionally simple TOML so Python 3.11's stdlib tomllib can
parse it in CI. Proof-grade certificates are allowed only when every arithmetic
and serialization requirement is explicitly true and the backend kind is not
"demo".
"""

from __future__ import annotations

import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "backend.toml"

REQUIRED_FOR_PROOF = [
    "unbounded_storage",
    "exact_add_sub_mul",
    "exact_order",
    "euclidean_gcd",
    "exact_divisibility",
    "normalized_serialization",
    "canonical_hash_encoding",
]

REQUIRED_POLICY = [
    "no_analytic_trig",
    "no_analytic_points",
    "points_are_vertices_of_vertices",
    "squarefree_localization_only",
    "pointwise_exact_type_exclusion",
    "no_float_certificate_arithmetic",
]

EXACT_ARITHMETIC_SPEC = "docs/rational-interval-arithmetic-spec.md"


def main() -> int:
    data = tomllib.loads(MANIFEST.read_text(encoding="utf-8"))
    backend = data["backend"]
    reqs = data["requirements"]
    policy = data["policy"]

    errors: list[str] = []

    for key in REQUIRED_POLICY:
        if policy.get(key) is not True:
            errors.append(f"policy.{key} must be true")

    if policy.get("exact_arithmetic_spec") != EXACT_ARITHMETIC_SPEC or not (ROOT / EXACT_ARITHMETIC_SPEC).exists():
        errors.append(f"policy.exact_arithmetic_spec must name the existing {EXACT_ARITHMETIC_SPEC}")

    proof_grade = backend.get("proof_grade") is True
    allow_proof = policy.get("allow_proof_grade_certificates") is True

    if proof_grade or allow_proof:
        if backend.get("kind") == "demo":
            errors.append("demo backend cannot be proof_grade")
        for key in REQUIRED_FOR_PROOF:
            if reqs.get(key) is not True:
                errors.append(f"requirements.{key} must be true before proof-grade acceptance")
        if not (proof_grade and allow_proof):
            errors.append("backend.proof_grade and policy.allow_proof_grade_certificates must change together")
    else:
        if backend.get("kind") == "demo" and policy.get("allow_demo_certificates") is not True:
            errors.append("demo backend should allow demo certificates or change kind")

    if errors:
        print("Backend manifest audit failed:\n")
        for err in errors:
            print(f"- {err}")
        return 1

    print("OK: backend manifest is internally consistent and proof-grade safe.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
