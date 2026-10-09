from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_side_assignment_soundness.md"
SRC = ROOT / "kernel/mojo/c1/separator/side_assignment_soundness.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_side_assignment_soundness_doc_splits_local_lemmas():
    doc = read(DOC)
    assert "RayOrderSoundness" in doc
    assert "WakeMembershipSoundness" in doc
    assert "ComponentBoundarySoundness" in doc
    assert "FiniteSide(A, S, side)" in doc
    assert "ClassicalSide" in doc


def test_on_separator_is_nonseparating():
    doc = read(DOC)
    src = read(SRC)
    assert "`OnSeparator` is not a side for separation" in doc
    assert "fn on_separator_is_structural" in src
    assert "return label.name == \"OnSeparator\"" in src


def test_local_lemmas_remain_pending():
    src = read(SRC)
    assert "LocalSoundnessStatus(False, False, False, True, True)" in src
    assert "fn all_local_lemmas_closed" in src
    assert "WakeMembershipSoundness" in src


def test_no_generic_stabilization_claim():
    combined = read(DOC) + "\n" + read(SRC)
    assert "does not claim MLC" in combined
    assert "does not claim MLC or generic" in combined
    assert "generic_stabilization_not_claimed_by_side_soundness" in combined


def test_no_deferred_tracks_in_soundness_layer():
    combined = (read(DOC) + "\n" + read(SRC)).lower()
    forbidden = ["renderer", "pixel", "finite-field", "hashroot", "bigint migration"]
    for token in forbidden:
        assert token not in combined
