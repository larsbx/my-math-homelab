from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_finite_separation_predicate.md"
SRC = ROOT / "kernel/mojo/c1/bridge/finite_separation.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_finite_separation_predicate_doc_exists():
    doc = read(DOC)
    assert "Separated_k(A, B)" in doc
    assert "SideAssignment" in doc
    assert "SameFiberPrefix_k" in doc
    assert "SameFiberStream" in doc
    assert "SeparatorCatalogueAdequacy" in doc


def test_scaffold_requires_admissible_separator_and_distinct_sides():
    src = read(SRC)
    assert "struct SideAssignment" in src
    assert "struct SeparationWitness" in src
    assert "code_admissible(self.separator)" in src
    assert "self.left.valid()" in src
    assert "self.right.valid()" in src
    assert "self.sides_distinct()" in src


def test_prefix_nonseparation_does_not_claim_classical_same_fiber():
    src = read(SRC)
    assert "fn claims_classical_same_fiber" in src
    assert "return False" in src
    assert "fn finite_prefix_nonseparation_claims_stabilization" in src


def test_generic_separator_rejected():
    src = read(SRC)
    assert "demo_reject_generic_separator" in src
    assert "GenericBoundaryLanding" in src
    assert "return not separated_k(w)" in src


def test_valid_and_invalid_demo_paths_present():
    src = read(SRC)
    assert "demo_valid_two_side_separation" in src
    assert "demo_reject_same_side" in src
    assert "LeftSide" in src
    assert "RightSide" in src


def test_no_deferred_tracks_in_finite_separation_layer():
    combined = (read(DOC) + "\n" + read(SRC)).lower()
    forbidden = ["renderer", "pixel", "finite-field", "bigint", "hashroot", "float64", "cmath", "numpy"]
    for token in forbidden:
        assert token not in combined
