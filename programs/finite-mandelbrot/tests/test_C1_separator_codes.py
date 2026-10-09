from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_admissible_separator_codes.md"
SRC = ROOT / "kernel/mojo/c1/separator/separator_codes.mojo"
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))
from claim_governance.lexing import mask_comments_and_strings


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_admissible_separator_doc_scopes_codes_only():
    doc = read(DOC)
    assert "TwoRaySeparator" in doc
    assert "ComponentArcSeparator" in doc
    assert "Fairness means" in doc
    assert "This is the enumeration lemma required by C1. It is not an MLC statement." in doc


def test_separator_code_tags_are_literature_bound_not_generic():
    src = read(SRC)
    assert "RationalRayLanding" in src
    assert "ParabolicLanding" in src
    assert "HyperbolicBoundaryLanding" in src
    assert "GenericBoundaryLanding" in src
    assert "MLCBinding" in src
    assert "fn must_reject_generic_separator" in src
    assert "not code.admissible()" in src


def test_two_ray_separator_requires_finite_shape():
    src = read(SRC)
    assert "self.left.shape_valid()" in src
    assert "self.right.shape_valid()" in src
    assert "self.distinct_rays()" in src
    assert "self.endpoint_compatible" in src


def test_fair_enumeration_does_not_claim_stabilization():
    src = read(SRC)
    assert "claims_stabilization" in src
    assert "not self.claims_stabilization" in src
    assert "demo_fair_enumeration_witness" in src


def test_no_deferred_side_tracks_in_separator_codes():
    combined = mask_comments_and_strings(read(SRC)).lower()
    forbidden = ["renderer", "pixel", "hashroot", "bigint migration", "finite-field"]
    for token in forbidden:
        assert token not in combined
