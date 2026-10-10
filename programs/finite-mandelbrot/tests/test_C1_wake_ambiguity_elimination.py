from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_wake_ambiguity_elimination.md"
SRC = ROOT / "kernel/mojo/c1/wake/wake_ambiguity_elimination.mojo"


def read(path):
    return path.read_text(encoding="utf-8")


def test_elimination_route_names_all_sublemmas():
    body = read(DOC)
    for name in [
        "BoundaryEqualityRefinement",
        "ConflictingWakeCollapse",
        "UnresolvedWakeToCarrierObstruction",
        "MissingLandingTagReroute",
        "NoResidualWakeAmbiguity",
    ]:
        assert name in body


def test_unresolved_wake_to_carrier_is_next_priority():
    body = read(DOC)
    assert "highest-priority next lemma" in body
    assert "UnresolvedWakeToCarrierObstruction" in body
    assert "non-shrinking carrier obstruction" in body


def test_scaffold_does_not_prove_c1():
    src = read(SRC)
    assert "fn proves_c1(self) -> Bool" in src
    assert "return False" in src
    assert "strongest_elimination_available" in src


def test_rank2_circle_primitive_is_blocked():
    src = read(SRC)
    assert "rank2_circle_primitive_available" in src
    assert "return False" in src
    lowered = src.lower()
    assert "unit-circle primitive" in lowered
    assert "no rank-2 locus primitive" in lowered


def test_no_invalid_nonseparation_shortcut():
    body = read(DOC)
    assert "many prefixes fail to separate" in body
    assert "therefore A and B are same fiber" in body
    assert "invalid" in body
