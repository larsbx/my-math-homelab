from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_unresolved_wake_to_carrier_obstruction.md"
SRC = ROOT / "kernel/mojo/c1/wake/unresolved_wake_carrier.mojo"


def text(path):
    return path.read_text(encoding="utf-8")


def test_new_terms_are_declared_with_genealogy_and_leaks():
    body = text(DOC)
    assert "Terminology declaration: carrier obstruction" in body
    assert "Terminology declaration: unresolved wake evidence" in body
    assert body.count("Genealogy:") >= 2
    assert body.count("Bridge claim:") >= 2
    assert body.count("Known leaks:") >= 2
    assert body.count("Use discipline:") >= 2


def test_allowed_failure_kinds_are_explicit():
    body = text(DOC)
    src = text(SRC)
    for kind in [
        "BoundaryEqualityCandidate",
        "CarrierTooCoarse",
        "LandingTagMissing",
        "CatalogueLinkMissing",
        "WakeOrderUnderdetermined",
    ]:
        assert kind in body
        assert kind in src


def test_routes_do_not_prove_c1_or_same_fiber():
    src = text(SRC)
    assert "proves_c1 = False" in src
    assert "proves_same_fiber = False" in src
    assert "bounded_search_failure_is_persistent() -> Bool" in src
    assert "return False" in src


def test_rank2_circle_locus_remains_unavailable():
    body = text(DOC).lower()
    src = text(SRC).lower()
    assert "rank-2 circle" in body
    assert "rank2_circle_or_locus_available" in src
    assert "return false" in src


def test_next_progress_target_is_named():
    body = text(DOC)
    assert "CarrierRefinementProgress" in body
    assert "strictly refined finite carrier" in body
