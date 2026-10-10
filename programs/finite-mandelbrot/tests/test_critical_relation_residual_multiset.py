from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "kernel/mojo/dynamics/critical_relation_residual_multiset.mojo"
SMOKE = ROOT / "kernel/mojo/smoke/smoke_tests.mojo"
BRIDGE = ROOT / "docs" / "multiset-bridge-program.md"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_r41_strips_known_lower_type_multiplicities_exactly():
    body = read(SOURCE)
    assert "struct R41ResidualDivisorMultiset" in body
    assert "def strip_monic_linear_power" in body
    assert "self.zero_multiplicity == 5" in body
    assert "self.minus_two_multiplicity == 1" in body
    assert "self.stripped_lower_type_multiplicity == 6" in body
    assert "self.relation_degree == 16" in body
    assert "self.residual_degree == 10" in body


def test_residual_factor_is_checked_but_exact_type_remains_closed():
    body = read(SOURCE)
    assert "def expected_r41_residual_factor" in body
    assert "equal_poly(residual, expected_r41_residual_factor())" in body
    assert "self.residual_exact_type_certified" in body
    assert "not result.exact_type_divisor_accepted()" in body


def test_invalid_strip_power_and_global_claims_fail_closed():
    body = read(SOURCE)
    assert "if requested_power < 0" in body
    assert "not invalid_power.exact" in body
    assert "def proves_density" in body
    assert "def proves_equidistribution" in body
    assert "def proves_c1" in body


def test_documentation_refines_candidate_into_factorwise_exact_type_result():
    bridge = " ".join(read(BRIDGE).split())
    assert "degree-10 residual candidate divisor" in bridge
    assert "C^3+2C^2+2C+2" in bridge
    assert "the cubic is a lower-type contribution" in bridge
    assert "D^{exact}_{4,1} = div_0(F_7)" in bridge
    assert "seven distinct algebraic roots" in bridge


def test_r41_residual_multiset_is_compiler_wired(mojo_smoke):
    smoke = read(SMOKE)
    assert (
        "from dynamics.critical_relation_residual_multiset import "
        "critical_relation_residual_multiset_smoke" in smoke
    )
    assert 'report.record("R41 residual divisor multiset"' in smoke
    assert mojo_smoke.case_passed("R41 residual divisor multiset")
