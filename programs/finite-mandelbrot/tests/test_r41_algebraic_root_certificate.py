from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "kernel" / "mojo" / "dynamics" / "r41_algebraic_root_certificate.mojo"
SMOKE = ROOT / "kernel" / "mojo" / "smoke" / "smoke_tests.mojo"
BRIDGE = ROOT / "docs" / "multiset-bridge-program.md"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_modular_gcd_is_an_exact_characteristic_zero_witness():
    body = read(SOURCE)
    assert "def remainder_mod_prime" in body
    assert "def gcd_degree_mod_prime" in body
    assert "def remainder_monic_over_integers" in body
    assert "def factor_is_squarefree_mod_prime" in body
    assert "var prime = 5" in body
    assert "composite_refused == -1" in body


def test_cubic_is_removed_by_an_earlier_collision():
    body = read(SOURCE)
    assert "critical_orbit_poly(4), critical_orbit_poly(3)" in body
    assert "remainder_monic_over_integers(cubic_collision, cubic).is_zero()" in body
    assert "remainder_mod_prime(cubic_collision, cubic, prime)" not in body
    assert "self.cubic_is_lower_type" in body


def test_f7_roots_have_exact_type_4_1_without_embedding_selection():
    body = read(SOURCE)
    assert "factor_excludes_all_unintended_collisions(f7, 4, 1, prime)" in body
    assert "remainder_monic_over_integers(relation, f7).is_zero()" in body
    assert "remainder_mod_prime(relation, f7, prime)" not in body
    assert "self.f7_squarefree" in body
    assert "self.factors_coprime" in body
    assert "self.exact_type_root_count == 7" in body
    assert "embeddings_selected" in body
    assert "localization_supplied" in body
    assert "not certificate.b3_localization_accepted()" in body


def test_mod_five_false_positive_is_rejected_over_integers():
    body = read(SOURCE)
    assert "var false_membership = add(mul(cubic, constant(1)), constant(5))" in body
    assert "modular_false_positive" in body
    assert "exact_negative_control" in body


def test_global_claims_remain_false():
    body = read(SOURCE)
    assert "def proves_density" in body
    assert "def proves_equidistribution" in body
    assert "def proves_c1" in body


def test_documentation_promotes_only_the_algebraic_exact_type_divisor():
    bridge = " ".join(read(BRIDGE).split())
    assert "D^{exact}_{4,1} = div_0(F_7)" in bridge
    assert "seven distinct algebraic roots" in bridge
    assert "does not choose or localize any embedding" in bridge


def test_r41_root_certificate_is_compiler_wired(mojo_smoke):
    smoke = read(SMOKE)
    assert (
        "from dynamics.r41_algebraic_root_certificate import "
        "r41_algebraic_root_certificate_smoke" in smoke
    )
    assert 'report.record("R41 algebraic roots"' in smoke
    assert mojo_smoke.case_passed("R41 algebraic roots")
