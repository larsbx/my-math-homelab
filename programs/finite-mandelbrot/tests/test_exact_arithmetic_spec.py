"""Regressions for the exact-arithmetic hook.

Specification: docs/rational-interval-arithmetic-spec.md. The first group checks
that every wire of the hook (section 7) is present; the second executes the
spec's laws against the secondary Python oracle over ``fractions.Fraction``.
"""

from fractions import Fraction
from pathlib import Path
import subprocess
import sys
import tomllib

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))

from dataclasses import replace  # noqa: E402

from audit_exact_arithmetic import (  # noqa: E402
    ALLOWLIST,
    BINDING_HEADING,
    POLICY,
    REQUIRED_SECTIONS,
    SPEC,
    SPEC_REL,
    audit,
)
from exact_arithmetic_audit import allowlisted, arithmetic_consumers, binding_rows  # noqa: E402
from closed_interval import IQ  # noqa: E402


def text(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


# --- section 7: hook wiring -------------------------------------------------


def test_spec_exists_with_required_sections():
    body = SPEC.read_text(encoding="utf-8")
    assert all(section in body for section in REQUIRED_SECTIONS)
    assert "implemented canonically in `larsbx/finite-math-kernels`" in body
    assert "is mirrored byte-for-byte" not in body


def test_audit_passes_on_current_tree():
    assert audit() == []


def test_audit_script_is_executable_and_green():
    result = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "audit_exact_arithmetic.py")],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def test_binding_table_covers_the_kernels_and_quarantines_floats():
    rows = binding_rows(ROOT, POLICY)
    by_class = {}
    for cls, paths in rows:
        by_class.setdefault(cls, set()).update(paths)
    assert "kernel/mojo/polynomial/poly_interval_eval.mojo" in by_class["DEMO"]
    assert {"vendor/mojo/finite_exact/rat_q.mojo", "vendor/mojo/finite_exact/closed_q.mojo"} <= by_class["CONFORMS"]
    assert "kernel/mojo/dynamics/complex_box.mojo" in by_class["QUARANTINED"]
    assert by_class["QUARANTINED"] == allowlisted(ROOT, POLICY)
    assert ALLOWLIST.exists()
    assert arithmetic_consumers(ROOT, POLICY) <= set().union(*by_class.values())


def scratch_consumer(tmp_path, name: str = "leak.mojo", source: str = ""):
    """A minimal consumer under ``tmp_path``: the spec's required headings, a
    binding table with one bound module that cites the spec, an empty
    allowlist, and ``source`` as the unbound kernel file ``src/<name>``."""
    (tmp_path / "docs").mkdir()
    (tmp_path / "tools").mkdir()
    (tmp_path / "src").mkdir()
    table = (
        "\n\n| Spec item | Module | Class | Notes |\n| --- | --- | --- | --- |\n"
        "| 1.1 | `src/bound.mojo` | CONFORMS | bound |\n"
    )
    spec = "\n\n".join(REQUIRED_SECTIONS).replace(BINDING_HEADING, BINDING_HEADING + table)
    (tmp_path / SPEC_REL).write_text(f"{POLICY.repository}\n\n{spec}\n", encoding="utf-8")
    (tmp_path / "src" / "bound.mojo").write_text(f"# {SPEC_REL}\n", encoding="utf-8")
    (tmp_path / POLICY.allowlist).write_text("# Allowlist\n", encoding="utf-8")
    if source:
        (tmp_path / "src" / name).write_text(source, encoding="utf-8")
    return replace(POLICY, scan_roots=("src",))


def test_scratch_consumer_is_clean(tmp_path):
    policy = scratch_consumer(tmp_path)
    assert audit(tmp_path, policy) == []


def test_audit_rejects_a_float_outside_the_allowlist(tmp_path):
    policy = scratch_consumer(tmp_path, "leak.mojo", "var x: Float64 = 1.5\n")
    errors = audit(tmp_path, policy)
    assert any("leak.mojo:1" in e and "C1" in e for e in errors)


def test_audit_rejects_every_mojo_decimal_float_form(tmp_path):
    forms = ["1e-3", "2.", ".5", "1.25", "1_000.5_0", "2E+4"]
    policy = scratch_consumer(
        tmp_path, "leak.mojo", "\n".join(f"var x{i} = {literal}" for i, literal in enumerate(forms))
    )
    errors = audit(tmp_path, policy)
    assert len([e for e in errors if "floating point in kernel scope" in e]) == len(forms)


def test_audit_rejects_unbound_arithmetic_consumer(tmp_path):
    policy = scratch_consumer(tmp_path, "consumer.mojo", "from finite_exact.rat_q import Q\n")
    assert "arithmetic consumer lacks binding row: src/consumer.mojo" in audit(tmp_path, policy)


def test_audit_reads_consumers_of_the_q_and_iq_layers_only(tmp_path):
    # A BigZ- or gcd-only import is not a Q/IQ consumer under this policy.
    policy = scratch_consumer(tmp_path, "consumer.mojo", "from finite_exact.integer_gcd import gcd_int\n")
    assert audit(tmp_path, policy) == []


def test_audit_rejects_a_simd_float_dtype(tmp_path):
    policy = scratch_consumer(tmp_path, "leak.mojo", "comptime d = DType.float32\n")
    assert any("leak.mojo:1" in e and "C1" in e for e in audit(tmp_path, policy))


def test_allowlist_prose_grants_nothing(tmp_path):
    policy = scratch_consumer(tmp_path, "leak.mojo", "var x: Float64 = 1.5\n")
    (tmp_path / POLICY.allowlist).write_text("Prose naming `src/leak.mojo` grants nothing.\n", encoding="utf-8")
    assert any("leak.mojo:1" in e and "C1" in e for e in audit(tmp_path, policy))


def test_policy_surfaces_point_at_the_spec():
    assert SPEC_REL in text("README.md")
    assert SPEC_REL in text("docs/mojo_first_execution_policy.md")
    assert "tools/audit_exact_arithmetic.py" in text(".github/workflows/no-trig-audit.yml")
    policy = tomllib.loads(text("backend.toml"))["policy"]
    assert policy["exact_arithmetic_spec"] == SPEC_REL
    assert policy["no_float_certificate_arithmetic"] is True
    assert "no_float_certificate_arithmetic" in text("tools/audit_backend_manifest.py")


CASE_NAMES = {
    "test_rational_field_laws": "rational field laws",
    "test_interval_enclosure_laws": "interval enclosure laws",
}


def test_mojo_law_tests_are_wired_into_the_smoke_target(mojo_smoke):
    smoke = text("kernel/mojo/smoke/smoke_tests.mojo")
    for name in ["test_rational_field_laws", "test_interval_enclosure_laws"]:
        assert f"def {name}()" in smoke
        assert mojo_smoke.case_passed(CASE_NAMES[name])


# --- sections 1 to 3: executable laws against the Fraction oracle -----------


def iv(lo, hi) -> IQ:
    return IQ.of(Fraction(lo), Fraction(hi))


def test_rational_equality_is_decidable_and_cancellation_lossless():
    assert Fraction(1, 10) + Fraction(2, 10) == Fraction(3, 10)
    a, b, c = Fraction(1, 3), Fraction(1, 7), Fraction(-2, 9)
    assert (a + b) + c == a + (b + c)
    assert a * (b + c) == a * b + a * c
    assert (a + b) - b == a


def test_floats_violate_the_laws_the_spec_is_replacing():
    assert 0.1 + 0.2 != 0.3
    assert (1e16 + 1.0) - 1e16 != 1.0


def test_inclusion_theorem_on_a_sample():
    x, y = iv(1, 3), iv(-1, 2)
    for px in (Fraction(1), Fraction(5, 2), Fraction(3)):
        for py in (Fraction(-1), Fraction(1, 3), Fraction(2)):
            for op, fop in ((x.add, px + py), (x.sub, px - py), (x.mul, px * py)):
                box = op(y)
                assert box.lo <= fop <= box.hi


def test_dependency_problem_and_subdistributivity():
    x, y, z = iv(1, 3), iv(-1, 2), iv(2, 5)
    d = x.sub(x)
    assert (d.lo, d.hi) == (Fraction(-2), Fraction(2)) and d.contains_zero()
    lhs, rhs = x.mul(y.add(z)), x.mul(y).add(x.mul(z))
    assert rhs.lo <= lhs.lo and lhs.hi <= rhs.hi


def test_reversed_endpoints_fail_closed():
    # J1: reversed endpoints are a rejected interval that poisons every
    # operation it enters and is never read as evidence, as in closed_q.
    bad = iv(2, 1)
    assert not bad.accepted()
    assert not bad.add(iv(0, 1)).accepted()
    assert not bad.contains_zero() and not bad.excludes_zero()
