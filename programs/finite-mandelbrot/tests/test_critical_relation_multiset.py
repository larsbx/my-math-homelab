from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "kernel/mojo/dynamics/critical_relation_multiset.mojo"
SMOKE = ROOT / "kernel/mojo/smoke/smoke_tests.mojo"
BRIDGE = ROOT / "docs" / "multiset-bridge-program.md"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_r21_divisor_records_algebraic_multiplicities():
    body = read(SOURCE)
    assert "struct CriticalRelationDivisorMultiset" in body
    assert "def bounded_integer_root_multiplicity" in body
    assert "self.zero_multiplicity == 3" in body
    assert "self.minus_two_multiplicity == 1" in body
    assert "self.declared_total_multiplicity == self.relation_degree" in body
    assert "equal_poly(relation, expected_R_2_1())" in body


def test_exact_type_filter_is_separate_from_root_multiplicity():
    body = read(SOURCE)
    assert "def integer_exact_minimal_collision_pattern" in body
    assert "not zero_exact_2_1" in body
    assert "minus_two_exact_2_1" in body
    assert "self.exact_type_support_count == 1" in body
    assert "self.exact_type_total_multiplicity == 1" in body


def test_multiset_slice_preserves_global_claim_firewall():
    body = read(SOURCE)
    assert "def proves_density" in body
    assert "def proves_equidistribution" in body
    assert "def proves_c1" in body
    assert body.count("return False") >= 4


def test_bridge_documentation_distinguishes_raw_and_exact_type_cycles():
    bridge = " ".join(read(BRIDGE).split())
    assert "div_0(A_{2,1}) = 3[0] + [-2]" in bridge
    assert "D^{exact}_{2,1} = [-2]" in bridge
    assert "root multiplicity is not exact-type multiplicity" in bridge


def test_critical_relation_multiset_is_compiler_wired(mojo_smoke):
    smoke = read(SMOKE)
    assert (
        "from dynamics.critical_relation_multiset import "
        "critical_relation_multiset_smoke" in smoke
    )
    assert 'report.record("critical-relation divisor multiset"' in smoke
    assert mojo_smoke.case_passed("critical-relation divisor multiset")
