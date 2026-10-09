from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_canonical_carrier_content.md"
SRC = ROOT / "kernel/mojo/c1/carrier/canonical_carrier_content.mojo"
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))
from claim_governance.lexing import mask_comments_and_strings


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_doc_has_governed_terminology_declaration():
    body = read(DOC)
    assert "Terminology declaration: CanonicalCarrierContent" in body
    assert "Genealogy:" in body
    assert "Bridge claim:" in body
    assert "Known leaks:" in body
    assert "Use discipline:" in body
    assert "Definition-only project term" in body


def test_canonical_content_fields_are_finite_and_order_independent():
    body = read(DOC)
    assert "sorted_incidence_atoms" in body
    assert "sorted_unresolved_obligations" in body
    assert "sorted_boundary_candidates" in body
    assert "sorted_missing_links" in body
    assert "display labels" in body
    assert "source ordering" in body


def test_scaffold_defines_allowed_atom_and_obligation_kinds():
    body = read(SRC)
    for atom in [
        "RootHandleRef",
        "RayAddressSetRef",
        "DyadicBoxRef",
        "SeparatorRef",
        "SideWitnessRef",
        "BoundaryCandidateRef",
        "ObligationRef",
    ]:
        assert atom in body
    for obligation in [
        "LandingTagMissing",
        "CatalogueLinkMissing",
        "WakeOrderUnderdetermined",
        "BoundaryEqualityCandidate",
        "CarrierTooCoarse",
    ]:
        assert obligation in body


def test_renaming_only_is_content_equality_not_label_equality():
    body = read(SRC)
    assert "same_canonical_content" in body
    assert "renaming_only_by_content" in body
    assert "content_fingerprint" in body
    assert "display_name" not in body


def test_productive_change_requires_real_content_movement():
    body = read(SRC)
    assert "productive_content_change" in body
    assert "unresolved_obligation_count" in body
    assert "boundary_candidate_count" in body
    assert "missing_link_count" in body
    assert "after.atom_count > before.atom_count" in body


def test_no_c1_singleton_or_rank2_circle_claims():
    body = read(SRC)
    assert "fn proves_c1() -> Bool:\n    return False" in body
    assert "fn proves_singleton_fiber() -> Bool:\n    return False" in body
    assert "fn rank2_circle_primitive_available() -> Bool:\n    return False" in body
    lowered = mask_comments_and_strings(body).lower()
    assert "circle object" not in lowered
    assert "unit circle" not in lowered
    assert "analytic locus" not in lowered
