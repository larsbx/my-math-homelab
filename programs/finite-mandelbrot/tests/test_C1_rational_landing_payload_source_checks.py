from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/c1/theorem_tags/theorem_tag_payload_instances.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_rational_landing_source_check_hook_exists():
    body = read(SRC)
    assert "def rational_landing_payload_source_checks_ready() -> Bool" in body
    assert "c_minus_2_landing_instance()" in body
    assert "landing.source_scope_checked()" in body


def test_misiurewicz_trivial_fiber_source_check_hook_exists():
    body = read(SRC)
    assert "def misiurewicz_trivial_fiber_payload_source_checks_ready() -> Bool" in body
    assert "c_minus_2_trivial_fiber_instance()" in body
    assert "fiber.source_scope_checked()" in body
    assert "fiber.final_import_admissible()" in body


def test_source_scope_is_specific_not_generic():
    body = read(SRC)
    assert '"SchleicherRationalParameterRays"' in body
    assert '"preperiodic rational parameter rays"' in body
    assert '"SchleicherFibersLC"' in body
    assert '"Misiurewicz parameters"' in body
    assert '"GenericMLC"' not in body
    assert '"AllFibersTrivial"' not in body


def test_replayed_path_is_c_minus_2_specific():
    body = read(SRC)
    assert "address_num == 1 and self.address_den == 2" in body
    assert '"beta_c_minus_2"' in body
    assert "self.ell == 2 and self.period == 1" in body
    assert "verify_bigq_c_minus_2_landing_target_association(C_MINUS_2_HALF_WIDTH_DEN_POWER)" in body
    assert "comptime C_MINUS_2_HALF_WIDTH_DEN_POWER = 8" in body
    assert "c_minus_2_checked_localization" not in body


def test_smoke_and_next_priority_are_updated():
    body = read(SRC)
    assert "theorem_tag_payload_instances_smoke()" in body
    assert "rational_landing_payload_source_checks_ready()" in body
    assert "misiurewicz_trivial_fiber_payload_source_checks_ready()" in body
    assert "def rational_landing_payload_proof_grade_association_ready() -> Bool" in body
    assert "landing.final_import_admissible()" in body
    assert "def next_priority_after_proof_grade_landing_association() -> String" in body
    assert 'return "CanonicalFiniteCertificateIncidenceReplay"' in body
