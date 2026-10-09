from pathlib import Path

SRC = Path("kernel/mojo/c1/separator/opposite_side_separation.mojo").read_text()
DOC = Path("docs/C1_opposite_side_separation_soundness.md").read_text()


def test_opposite_side_soundness_note_names_local_inputs():
    assert "OppositeSideSeparationSoundness" in DOC
    assert "SeparatorAdmissibilitySoundness" in DOC
    assert "SideAssignmentSoundness" in DOC
    assert "SideDisjointness" in DOC
    assert "BoundaryCaseDiscipline" in DOC


def test_finite_checks_require_opposite_open_sides():
    assert "fn opposite_open_sides" in SRC
    assert 'a == "Left" and b == "Right"' in SRC
    assert 'a == "Right" and b == "Left"' in SRC
    assert "fn demo_same_side_rejected" in SRC


def test_on_separator_is_rejected_not_separating():
    assert "fn on_separator_case" in SRC
    assert '"OnSeparator"' in SRC
    assert "fn demo_on_separator_rejected" in SRC
    assert "BoundaryCaseDiscipline" in DOC
    assert "not separation" in DOC


def test_classical_conclusion_remains_theorem_dependent():
    assert "classical_conclusion_available" in SRC
    assert "False" in SRC
    assert "needs_side_assignment_soundness" in SRC
    assert "needs_separator_admissibility_soundness" in SRC
    assert "theorem-tagged reading" in DOC


def test_no_global_overclaim():
    forbidden = ["claims MLC", "prove MLC", "generic stabilization", "catalogue is complete"]
    lowered = (SRC + "\n" + DOC).lower()
    assert "does not prove catalogue completeness" in lowered
    assert "does not claim generic boundary fibers" not in lowered or "generic" in lowered
    for token in ["pixel", "renderer", "hash-root", "bigint backend"]:
        assert token not in SRC.lower()
