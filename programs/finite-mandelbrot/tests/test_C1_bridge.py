from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_finite_classical_dictionary.md"
SRC = ROOT / "kernel/mojo/c1/bridge/bridge.mojo"
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))
from claim_governance.lexing import mask_comments_and_strings


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_c1_dictionary_names_exact_bridge():
    text = read(DOC)
    assert "Finite rational-ray nest stabilization" in text
    assert "fiber triviality" in text
    assert "MLC" in text
    assert "C1-A. The finite catalogue relation is extensionally the same as fiber separation." in text
    assert "C1-C" in text


def test_c1_bridge_keeps_project_owned_blocker_false():
    src = read(SRC)
    assert "catalogue_extensionality is project-owned proof work and remains false" in src
    assert "return FiberBridgeTag(False, True, True)" in src
    assert "Must remain false until catalogue_extensionality is proved." in src


def test_finite_prefix_never_claims_generic_stabilization():
    src = read(SRC)
    assert "fn claims_generic_stabilization" in src
    assert "return False" in src
    assert "demo_finite_prefix_not_stabilization" in src


def test_bridge_uses_incidence_refs_not_analytic_points():
    src = mask_comments_and_strings(read(SRC))
    assert "IncidenceObjectRef" in src
    assert "is_point_vertex" in src
    forbidden = ["point_eval", "eval_point", "analytic point", "Float64", "cmath", "numpy"]
    for token in forbidden:
        assert token not in src


def test_no_secondary_tracks_reintroduced_in_c1_bridge():
    combined = mask_comments_and_strings(read(SRC)).lower()
    forbidden = ["pixel", "renderer", "hashroot", "finite-field experiment", "bigint implementation", "krawczyk optimization"]
    for token in forbidden:
        assert token not in combined
