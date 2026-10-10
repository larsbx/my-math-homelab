from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/certificates/misiurewicz_certificate.mojo"
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))
from claim_governance.lexing import mask_comments_and_strings


def text() -> str:
    return SRC.read_text(encoding="utf-8")


def test_certificate_envelope_exists():
    src = mask_comments_and_strings(text())
    assert "struct MisiurewiczCertificate" in src
    assert "struct RootHandle" in src
    assert "struct RayAddressDatum" in src
    assert "struct TheoremTags" in src


def test_certificate_requires_incidence_and_joint_gate():
    src = text()
    assert "self.joint.accepted()" in src
    assert "self.incidence.accepted()" in src
    assert "self.tags.valid()" in src
    assert "self.root.valid()" in src
    assert "self.rays.valid()" in src


def test_ray_preperiod_is_shifted_from_critical_orbit():
    src = text()
    assert "fn lambda_preperiod(self) -> Int" in src
    assert "return self.ell - 1" in src
    assert "self.rays.preperiod == self.lambda_preperiod()" in src


def test_c_minus_2_accepted_and_m41_rejected_paths_exist():
    src = text()
    assert "fn demo_c_minus_2_certificate_accepted" in src
    assert "return c_minus_2_certificate().accepted()" in src
    assert "fn demo_m41_certificate_rejected_until_krawczyk_lands" in src
    assert "return not m41_certificate_placeholder().accepted()" in src


def test_m41_header_preserves_ray_period_distinction():
    src = text()
    assert 'RayAddressDatum("theta_9_11_15_over_56", 3, 3, 1, 3, True)' in src
    assert "(self.ray_period % self.orbit_period == 0)" in src


def test_no_classical_point_equation_language_in_certificate_core():
    src = mask_comments_and_strings(text())
    forbidden = ["analytic singleton", "point evaluation", "eval_point", "point_value"]
    for token in forbidden:
        assert token not in src.lower()
    assert "PointVertex" not in src or "incidence" in src
