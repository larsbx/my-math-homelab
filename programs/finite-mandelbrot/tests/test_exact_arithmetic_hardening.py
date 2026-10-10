"""Regressions for the exact-arithmetic public boundary hardening.

Boundary: docs/exact-arithmetic-public-boundary.md. The first group checks the
wiring (probe, oracle, pixi task, CI step, binding rows, audit); the second
checks the oracle's own encoder and generator; the third runs the full
Mojo-versus-Python comparison when a ``mojo`` binary is available.
"""

from __future__ import annotations

import shutil
import sys
import tomllib
from fractions import Fraction
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from reference.python.arithmetic import exact_arithmetic_property_oracle as oracle  # noqa: E402


def text(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


# --- wiring -------------------------------------------------------------------


def test_boundary_document_declares_names_semantics_and_promise():
    doc = text("docs/exact-arithmetic-public-boundary.md")
    for section in ["## 1. Public names", "## 2. Semantics that consumers may rely on",
                    "## 3. Semantics that consumers must not rely on", "## 4. Verification of the boundary",
                    "## 5. Stability promise"]:
        assert section in doc
    for name in ["`bigz_divmod`", "`IQ.singleton`", "`ComplexIQ.singleton`", "`q_canonical_bytes`"]:
        assert name in doc
    assert "enables no certificate acceptance" in doc


def test_long_division_replaces_shift_and_subtract_and_keeps_the_reference(mojo_smoke):
    z = text("vendor/mojo/finite_exact/bigint_z.mojo")
    assert "def bigz_abs_divmod_shift_subtract(" in z
    assert "def bigz_abs_divmod(" in z
    assert "Knuth Algorithm D" in z
    assert "def bigz_abs_mul_small(" in z
    assert "def bigz_long_division_smoke(" in z
    assert mojo_smoke.case_passed("bigz long division")


def test_an_exact_number_can_be_read_in_base_ten(mojo_smoke):
    """Limbs are base 10^9, so the decimal form is exact and needs no division;
    it is how an exact rational leaves the repository readable. First written
    here, it now lives upstream in finite_exact as its own module, vendored
    byte-identical to its upstream; no local copy remains."""
    assert "def bigz_decimal(" in text("vendor/mojo/finite_exact/exact_decimal.mojo")
    assert "def bigz_decimal(" not in text("vendor/mojo/finite_exact/bigint_z.mojo")
    assert not (ROOT / "kernel/mojo/arithmetic/exact_decimal.mojo").exists()
    assert "from finite_exact.exact_decimal import" in text("kernel/mojo/entrypoints/atlas_dataset.mojo")
    assert mojo_smoke.case_passed("exact decimal")


def test_rational_operations_cancel_before_multiplying(mojo_smoke):
    q = text("vendor/mojo/finite_exact/rat_q.mojo")
    assert "struct QCrossTerms(Copyable)" in q
    assert "def q_cross_terms(" in q
    assert "var g1 = bigz_gcd(self.num, other.den)" in q
    assert "var g2 = bigz_gcd(other.num, self.den)" in q
    assert "def q_cancellation_smoke(" in q
    assert mojo_smoke.case_passed("Q cancellation")
    # naive cross-multiplication must be gone from the comparison methods
    assert "bigz_lt(bigz_mul(self.num, other.den), bigz_mul(other.num, self.den))" not in q


def test_singleton_replaces_point_everywhere_in_core():
    iq = text("vendor/mojo/finite_exact/closed_q.mojo")
    assert "def singleton(x: Q) -> IQ:" in iq
    assert "def singleton(re: Q, im: Q) -> ComplexIQ:" in iq
    assert "No ideal point" in iq
    core = sorted((ROOT / "kernel" / "mojo").rglob("*.mojo"))
    assert len(core) > 50, "the core scan must not be vacuous"
    for path in core:
        body = path.read_text(encoding="utf-8")
        assert ".point(" not in body, path
        assert "def point(" not in body and "fn point(" not in body, path


def test_no_points_audit_has_no_exemptions_and_bans_def_point():
    audit = text("tools/audit_no_points.py")
    assert "ALLOW_LINES: set[str] = set()" in audit
    assert r"(?:fn|def)\s+point\s*\(" in audit
    assert r"\.point\s*\(" in audit


def test_property_probe_is_wired_into_pixi_ci_and_binding_table():
    manifest = tomllib.loads(text("pixi.toml"))
    assert manifest["tasks"]["property"] == "python reference/python/arithmetic/exact_arithmetic_property_oracle.py"
    assert "pixi run property" in text(".github/workflows/no-trig-audit.yml")
    spec = text("docs/rational-interval-arithmetic-spec.md")
    assert "`kernel/mojo/arithmetic/exact_arithmetic_property_probe.mojo`" in spec
    assert "`reference/python/arithmetic/exact_arithmetic_property_oracle.py`" in spec
    assert "kernel/mojo/arithmetic/exact_arithmetic_property_probe.mojo" in text("docs/mojo-toolchain-boundary.md")
    probe = text("kernel/mojo/arithmetic/exact_arithmetic_property_probe.mojo")
    assert "docs/rational-interval-arithmetic-spec.md" in probe
    assert "from finite_exact.bigint_z import" in probe and "from finite_exact.rat_q import" in probe and "from finite_exact.closed_interval import" in probe


# --- oracle self-checks ---------------------------------------------------------


def test_oracle_encoder_matches_documented_canonical_bytes():
    # docs/canonical-serialization.md: -1000000001 -> 02 0000000000000004 3b9aca01
    assert oracle.encode_z(-1000000001) == "2.0.0.0.0.0.0.0.4.59.154.202.1"
    assert oracle.encode_z(0) == "0.0.0.0.0.0.0.0.0"
    assert oracle.encode_z(1) == "1.0.0.0.0.0.0.0.1.1"
    assert oracle.encode_q(Fraction(1, 2)) == oracle.encode_z(1) + "." + oracle.encode_z(2)
    assert oracle.encode_q(Fraction(2, -4)) == oracle.encode_z(-1) + "." + oracle.encode_z(2)


def test_oracle_generator_is_deterministic_and_bounded():
    first, second = oracle.expected_lines(), oracle.expected_lines()
    assert first == second
    assert first[0] == oracle.HEADER and first[-1] == "END"
    assert len(first) == 2 + oracle.Z_CASES + oracle.Q_CASES + oracle.I_CASES
    rng = oracle.Xorshift64Star(oracle.SEED)
    values = [oracle.random_int(rng) for _ in range(500)]
    assert all(abs(v) < oracle.BASE ** oracle.MAX_LIMBS for v in values)
    assert any(v < 0 for v in values) and any(0 <= v < 1000 for v in values)
    assert any(abs(v) >= oracle.BASE ** 4 for v in values)


def test_oracle_division_convention_truncates_toward_zero():
    assert oracle.trunc_divmod(-10, 3) == (-3, -1)
    assert oracle.trunc_divmod(10, -3) == (-3, 1)
    assert oracle.trunc_divmod(-10, -3) == (3, -1)
    assert oracle.trunc_divmod(0, 7) == (0, 0)


def test_oracle_rejects_a_corrupted_transcript():
    lines = oracle.expected_lines()
    assert oracle.compare(lines) == []
    corrupted = list(lines)
    tokens = corrupted[1].split(" ")
    tokens[4] = tokens[3]  # a + b replaced by b
    corrupted[1] = " ".join(tokens)
    errors = oracle.compare(corrupted)
    assert len(errors) == 1 and errors[0].startswith("line 2 token 4")
    assert oracle.compare(lines[:-1]) != []


# --- full comparison ------------------------------------------------------------


@pytest.mark.skipif(shutil.which("mojo") is None, reason="mojo binary not on PATH")
def test_mojo_probe_agrees_with_python_oracle():
    actual = oracle.run_probe()
    assert actual is not None
    assert oracle.compare(actual) == []
