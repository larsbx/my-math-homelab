from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/c1/separator/side_assignment.mojo"
DOC = ROOT / "docs" / "C1_side_assignment_witnesses.md"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_side_assignment_witness_structures_exist():
    src = read(SRC)
    assert "struct SideAssignmentWitness" in src
    assert "struct SideEvidence" in src
    assert "struct SideLabel" in src
    assert "fn separated_by_side_assignments" in src


def test_only_left_right_are_separation_sides():
    src = read(SRC)
    assert "return self.is_left() or self.is_right()" in src
    assert "is_on_separator" in src
    assert "structural_on_separator" in src


def test_separation_requires_same_separator_and_opposite_sides():
    src = read(SRC)
    assert "same_separator(a, b)" in src
    assert "opposite_separation_sides(a, b)" in src
    assert "a.valid_for_separation()" in src
    assert "b.valid_for_separation()" in src


def test_generic_separator_and_on_separator_rejected():
    src = read(SRC)
    assert "demo_generic_separator_rejected_for_side_assignment" in src
    assert "rejected_generic_separator" in src
    assert "demo_on_separator_rejected_for_separation" in src
    assert "return not separated_by_side_assignments" in src


def test_doc_names_next_soundness_obligation():
    doc = read(DOC)
    assert "SideAssignmentSoundness" in doc
    assert "finite cyclic-order" in doc
    assert "Failure to find opposite side assignments in a finite prefix means only" in doc


def test_no_deferred_or_analytic_tracks_in_side_assignment_layer():
    combined = (read(SRC) + "\n" + read(DOC)).lower()
    forbidden = ["pixel", "renderer", "float64", "numpy", "cmath", "mlcbinding", "genericboundarylanding"]
    for token in forbidden:
        assert token not in combined
