from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_residual_frontier_refinement.md"
SRC = ROOT / "kernel/mojo/c1/residual/residual_frontier_refinement.mojo"


def text(path):
    return path.read_text(encoding="utf-8")


def test_residual_frontier_is_central_route():
    body = text(DOC)
    assert "PersistentNonSeparation(A,B)" in body
    assert "NoMissingTheoremCatalogueLink(A,B)" in body
    assert "NoBoundaryEquality(A,B)" in body
    assert "StrictCarrierRefinement(A,B)" in body
    assert "active attack on C1" in body


def test_residual_route_eliminates_all_but_refinement():
    body = text(DOC)
    assert "PersistentWakeAmbiguity" in body
    assert "CarrierObstruction" in body
    assert "RefinesToOppositeSideSeparation" in body
    assert "only surviving case is carrier obstruction" in body
    assert "all but strict carrier refinement" in body


def test_scaffold_requires_all_residual_hypotheses():
    src = text(SRC)
    assert "persistent_nonseparation" in src
    assert "no_missing_theorem_catalogue_link" in src
    assert "no_boundary_equality" in src
    assert "canonical_carrier_content" in src
    assert "catalogue_extensionality_local_route" in src
    assert "side_soundness_route" in src


def test_scaffold_forces_refinement_but_not_c1():
    src = text(SRC)
    assert "forces_strict_carrier_refinement" in src
    assert "proof_route_complete" in src
    assert "proves_c1" in src
    assert "proves_singleton_fiber" in src
    assert "ResidualFrontierConclusion(True, True, False, False, False)" in src


def test_no_shortcuts_or_rank2_loci():
    body = text(DOC).lower() + "\n" + text(SRC).lower()
    assert "bounded_search_proves_residual_frontier" in body
    assert "rank2_circle_primitive_available" in body
    assert "residual_route_claims_metric_diameter" in body
    assert "circle is undefined" not in text(SRC).lower()
    assert "unit circle" not in text(SRC).lower()
