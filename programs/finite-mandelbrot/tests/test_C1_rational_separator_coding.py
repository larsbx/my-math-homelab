from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_rational_separator_coding_completeness.md"
SRC = ROOT / "kernel/mojo/c1/separator/rational_separator_coding.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_rational_separator_coding_target_is_explicit():
    text = read(DOC)
    assert "RationalSeparatorCodingCompleteness" in text
    assert "ClassicalRationalSeparator" in text
    assert "CanonicalSeparatorCode" in text
    assert "AdmissibleSeparatorCode" in text


def test_normalization_rules_are_locked():
    text = read(DOC) + read(SRC)
    assert "den > 0" in text or "addr.den <= 0" in text
    assert "0 <= num < den" in text or "addr.num >= addr.den" in text
    assert "gcd" in text
    assert "unique normalized representative" in text


def test_swap_invariant_separator_identity_is_required():
    text = read(DOC) + read(SRC)
    assert "Swapping" in text or "demo_swap_invariant_identity" in text
    assert "same_separator_identity" in text
    assert "ray_addr_before" in text
    assert "lexicographic" in text


def test_duplicate_and_generic_tags_are_rejected():
    text = read(SRC)
    assert "demo_duplicate_rejected" in text
    assert "demo_generic_landing_rejected" in text
    assert "GenericBoundaryLanding" in text
    assert "MLCBinding" in text
    assert "NumericalLandingGuess" in text
    assert "landing_tag_rejected" in text


def test_theorem_tag_is_required_but_not_a_global_claim():
    text = read(SRC) + read(DOC)
    assert "nonempty_theorem_tag" in text
    assert "theorem_tag" in text
    assert "does not prove fibre triviality" in text or "does not prove local connectivity" in text
    forbidden_local_claims = [
        "fn prove_mlc",
        "fn prove_fiber_triviality",
        "fn generic_boundary_landing",
        "return FiberTrivial",
    ]
    for phrase in forbidden_local_claims:
        assert phrase not in text


def test_no_deferred_tracks_enter_separator_coding_layer():
    text = read(SRC)
    forbidden = [
        "pixel",
        "renderer",
        "hash_root",
        "bigint_backend",
        "finite_field_shadow",
        "Krawczyk",
    ]
    for phrase in forbidden:
        assert phrase not in text
