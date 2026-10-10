from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_bigint_backend_marks_int64_as_not_certificate_ready():
    text = read("kernel/mojo/arithmetic/big_int_boundary.mojo")
    assert "has_unbounded_storage = False" in text
    assert "backend_ready_for_certificates" in text
    assert "has_exact_divisibility" in text


def test_poly_witness_forbids_lower_factor_stripping():
    text = read("kernel/mojo/polynomial/poly_witness.mojo")
    assert "reject_lower_factor_gcd_stripping" in text
    assert "return not attempted" in text
    assert "squarefree only" in text.lower()


def test_exact_type_uses_same_box_joint_witness():
    text = read("kernel/mojo/certificates/exact_type_exclusion.mojo")
    assert "joint_box_witness_valid" in text
    assert "localization.box_id.eq(w.exclusions.box_id)" in text
    assert "all_interval_exclusions_checked" in text


def test_correct_forbidden_counts_are_documented():
    text = read("kernel/mojo/certificates/exact_type_exclusion.mojo")
    assert "demo_m41_forbidden_count_h6" in text
    assert "Forbidden = 18" in text
    assert "demo_c_minus_2_forbidden_count_h3" in text
    assert "Forbidden = 5" in text


def test_intended_pair_drops_redundant_j_ge_ell_check():
    text = read("kernel/mojo/certificates/exact_type_exclusion.mojo")
    assert "if i < ell" in text
    assert "j >= ell" not in text
