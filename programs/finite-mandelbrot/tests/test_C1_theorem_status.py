from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_catalogue_extensionality_proof_consolidation.md"
SRC = ROOT / "kernel/mojo/c1/proof/theorem_status.mojo"


def text(path):
    return path.read_text(encoding="utf-8")


def test_catalogue_extensionality_has_real_two_direction_proof_skeleton():
    body = text(DOC)
    assert "## Direction 1: SeparatorCatalogueSoundness" in body
    assert "## Direction 2: SeparatorCatalogueCompleteness" in body
    assert "## Proof: soundness direction" in body
    assert "## Proof: completeness direction" in body
    assert "ClassicallySeparated(A,B)" in body
    assert "exists k. Separated_k(A,B)" in body


def test_local_lemmas_are_named_as_dependencies():
    body = text(DOC)
    for lemma in [
        "RationalSeparatorCodingCompleteness",
        "LandingTagCompletenessForFiberSeparators",
        "FairEnumerationLemma",
        "SideAssignmentSoundness",
        "SideWitnessExtraction",
        "OppositeSideSeparationSoundness",
        "FinitePrefixToExistentialSeparation",
    ]:
        assert lemma in body


def test_residual_frontier_is_the_active_target():
    body = text(DOC)
    src = text(SRC)
    assert "residual case" in body
    assert "residual_frontier_target" in src
    assert "no descent" in src
    assert "no missing link" in src
    assert "no boundary equality" in src


def test_c1_not_claimed_and_rank2_circle_blocked():
    src = text(SRC)
    assert "c1_proved: Bool" in src
    assert "c1_disproved: Bool" in src
    assert "return C1Status(local, True, True, False, False)" in src
    assert "rank2_circle_primitive_available() -> Bool" in src
    assert "return False" in src


def test_bounded_search_does_not_prove_c1():
    src = text(SRC)
    assert "bounded_search_proves_c1" in src
    assert "return False" in src
