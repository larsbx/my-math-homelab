from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/certificates/certificate_incidence.mojo"
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))
from claim_governance.lexing import mask_comments_and_strings


def text() -> str:
    return SRC.read_text(encoding="utf-8")


def test_certificate_incidence_wrapper_exists():
    src = mask_comments_and_strings(text())
    assert "struct CertificateIncidence" in src
    assert "var root_handle: Vertex" in src
    assert "var ray_addr_set: Vertex" in src
    assert "var box: Vertex" in src
    assert "var emitted: PointVertex" in src


def test_incidence_is_built_from_three_vertices():
    src = text()
    assert "root_handle_vertex(poly_name, status.same_box_name)" in src
    assert "ray_addr_set_vertex(ray_set_name)" in src
    assert "box_vertex(status.same_box_name)" in src
    assert "carrier_size() == 3" in src


def test_acceptance_requires_joint_status_and_valid_incidence():
    src = text()
    assert "self.status.accepted() and self.emitted.valid()" in src
    assert "accepted_certificate_emits_only_vertex_of_vertices" in src


def test_m41_placeholder_incidence_not_accepted():
    src = text()
    assert "demo_m41_certificate_incidence_placeholder" in src
    assert "return not ci.accepted() and ci.emitted.valid()" in src


def test_no_analytic_point_terms_added():
    src = mask_comments_and_strings(text())
    forbidden = ["analytic singleton", "eval_point", "point_eval", "point_value", "to_point_interval"]
    for token in forbidden:
        assert token not in src
