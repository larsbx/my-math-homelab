from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_catalogue_extensionality.md"
SRC = ROOT / "kernel/mojo/c1/bridge/fair_enumeration.mojo"
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))
from claim_governance.lexing import mask_comments_and_strings


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_catalogue_extensionality_names_two_directions():
    doc = read(DOC)
    assert "Direction CE-1" in doc
    assert "Direction CE-2" in doc
    assert "Catalogue extensionality" in doc
    assert "FairEnumerationLemma" in doc


def test_fair_enumeration_scaffold_is_narrow():
    src = read(SRC)
    assert "struct SeparationLineCode" in src
    assert "struct CataloguePrefix" in src
    assert "struct FairEnumerationWitness" in src
    assert "claims_only_enumeration" in src
    assert "claims_no_generic_stabilization" in src


def test_admissibility_requires_all_separator_fields():
    src = read(SRC)
    assert "self.rational_ray_code" in src
    assert "self.landing_tags_present" in src
    assert "self.side_predicate_code_present" in src
    assert "self.incidence_refs_present" in src


def test_rejects_bad_and_overclaiming_witnesses():
    src = read(SRC)
    assert "fn must_reject_non_admissible_code" in src
    assert "fn must_reject_generic_stabilization_claim" in src
    assert "return not witness.accepted()" in src


def test_no_deferred_tracks_reintroduced():
    combined = mask_comments_and_strings(read(SRC)).lower()
    forbidden = ["renderer", "pixel", "finite-field", "hashroot", "bigint backend implementation"]
    for token in forbidden:
        assert token not in combined
