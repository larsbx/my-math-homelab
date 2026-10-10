from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_persistent_wake_ambiguity_extraction.md"
SRC = ROOT / "kernel/mojo/c1/wake/wake_ambiguity.mojo"


def text(path):
    return path.read_text(encoding="utf-8")


def test_persistent_wake_ambiguity_is_frontier_obstruction_not_solution():
    body = text(DOC)
    assert "frontier lemma" in body
    assert "does not prove C1 by itself" in body
    assert "PersistentWakeAmbiguity(A,B) => contradiction" in body


def test_obstruction_extraction_has_named_alternatives():
    body = text(DOC)
    assert "UndeclaredBoundaryCarrier" in body
    assert "NonShrinkingNestedCarrier" in body
    assert "MissingCatalogueExtensionality" in body
    assert "PersistentWakeAmbiguity" in body


def test_wake_ambiguity_record_rejects_overclaims():
    src = text(SRC)
    assert "claims_same_fiber" in src
    assert "claims_singleton_fiber" in src
    assert "claims_C1" in src
    assert "return False" in src


def test_bounded_search_is_rejected():
    src = text(SRC)
    assert "bounded_search_only" in src
    assert "demo_bounded_search_rejected" in src


def test_extraction_state_requires_some_named_explanation():
    src = text(SRC)
    assert "explains_persistent_nonseparation" in src
    assert "wake_ambiguity" in src
    assert "undeclared_boundary_carrier" in src
    assert "nonshrinking_nested_carrier" in src
    assert "missing_catalogue_extensionality" in src


def test_no_deferred_implementation_tracks_in_wake_ambiguity_layer():
    combined = text(DOC) + text(SRC)
    forbidden = ["pixel", "renderer", "hashroot", "GPU", "Float64"]
    for token in forbidden:
        assert token not in combined
