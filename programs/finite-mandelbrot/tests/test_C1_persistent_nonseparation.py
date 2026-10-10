from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_persistent_nonseparation.md"
SRC = ROOT / "kernel/mojo/c1/residual/persistent_nonseparation.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_persistent_nonseparation_is_universal_prefix_statement_not_bounded_search():
    body = read(DOC)
    assert "forall k. not Separated_k(A,B)" in body
    assert "meta-level universal statement" in body
    assert "single finite search unless an independent theorem gives a finite bound" in body.replace("\n", " ")


def test_persistent_nonseparation_does_not_imply_same_fiber_or_mlc():
    body = read(DOC)
    src = read(SRC)
    assert "must not imply by itself" in body
    assert "SameFiber(A,B)" in body
    assert "MLC" in body
    assert "fn proves_C1(self) -> Bool:" in src
    assert "return False" in src


def test_frontier_hypothesis_rejects_shortcuts():
    src = read(SRC)
    assert "finite_bound_claimed" in src
    assert "same_fiber_claimed" in src
    assert "singleton_claimed" in src
    assert "mlc_claimed" in src
    assert "demo_rejects_bounded_same_fiber_shortcut" in src


def test_obstruction_classification_has_active_F1_forms():
    body = read(DOC)
    src = read(SRC)
    for token in [
        "persistent wake ambiguity",
        "undeclared boundary carrier",
        "non-shrinking nested carrier",
        "missing catalogue-extensionality lemma",
    ]:
        assert token in body
    for token in [
        "persistent_wake_ambiguity",
        "undeclared_boundary_carrier",
        "nonshrinking_nested_carrier",
        "missing_catalogue_extensionality",
    ]:
        assert token in src


def test_no_deferred_implementation_tracks_in_persistent_nonseparation_layer():
    src = read(SRC)
    lowered = src.lower()
    forbidden = ["pixel", "renderer", "hashroot", "sha256", "float64", "finite field shadow"]
    for token in forbidden:
        assert token not in lowered
