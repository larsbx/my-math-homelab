from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_classical_separation_to_finite_witness.md"
SRC = ROOT / "kernel/mojo/c1/bridge/classical_to_finite.mojo"


def test_hard_direction_document_names_exact_target():
    text = DOC.read_text()
    assert "ClassicallySeparated(A, B) => exists k. Separated_k(A, B)" in text
    assert "RationalSeparatorCodingCompleteness" in text
    assert "LandingTagCompletenessForFiberSeparators" in text
    assert "SideWitnessExtraction" in text
    assert "FairEnumerationLemma" in text


def test_scaffold_blocks_until_all_local_obligations_complete():
    text = SRC.read_text()
    assert "status.all_complete()" in text
    assert "local completeness obligations are still pending" in text
    assert "rational_separator_coding_complete" in text
    assert "landing_tag_complete" in text
    assert "side_witness_extraction_complete" in text
    assert "fair_enumeration_complete" in text


def test_generic_boundary_and_mlc_are_rejected():
    text = SRC.read_text()
    assert "generic boundary separator is not an admissible finite code" in text
    assert "MLC claim is outside local classical-to-finite witness" in text
    assert "claims_mlc" in text
    assert "claims_generic_boundary" in text


def test_acceptance_is_existential_not_stabilization():
    text = SRC.read_text()
    assert "finite existential separation witness introduced" in text
    assert "claims_stabilization" in text
    assert "True, \"finite existential separation witness introduced\"" in text
    forbidden = ["renderer", "pixel", "hash-root", "bigint backend accepted"]
    lowered = text.lower()
    for token in forbidden:
        assert token not in lowered
