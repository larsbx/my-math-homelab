from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/dynamics/interval_orbit.mojo"
# The collision partition and the orbit step are the vendored quadratic_orbit
# package (pinned in vendored.toml); this consumer imports them.
COLLISION = ROOT / "vendor/mojo/quadratic_orbit/collision.mojo"
ORBIT = ROOT / "vendor/mojo/quadratic_orbit/orbit.mojo"


def text() -> str:
    return SRC.read_text(encoding="utf-8")


def vendored(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_interval_orbit_scaffold_exists():
    src = text()
    assert "struct OrbitEvalConfig" in src
    assert "struct IntervalOrbitStatus" in src
    assert "from quadratic_orbit.collision import forbidden_count, intended_pair" in src
    assert "def forbidden_count" not in src and "def intended_pair" not in src
    collision = vendored(COLLISION)
    assert "def forbidden_count(ell: Int, period: Int, horizon: Int) -> Int:" in collision
    assert "def intended_pair(ell: Int, period: Int, i: Int, j: Int) -> Bool:" in collision


def test_native_interval_recurrence_exists():
    src = text()
    assert "from finite_exact.closed_interval import ComplexIQ, IQ, IQBoolResult" in src
    assert "from quadratic_orbit.orbit import collision_interval, complex_excludes_zero, zero_box" in src
    assert "from quadratic_orbit.orbit import quadratic_step as next_orbit_value" in src
    assert "def build_interval_orbit_h3" in src
    assert "def build_interval_orbit_h6" in src
    assert "def excludes_zero" in src
    assert "return not result.rejected and result.value" in src
    orbit = vendored(ORBIT)
    assert "def zero_box() -> ComplexIQ:" in orbit
    assert "def quadratic_step(z: ComplexIQ, c: ComplexIQ) -> ComplexIQ:" in orbit
    assert "return z.square().add(c)" in orbit
    assert "def collision_interval(a: ComplexIQ, b: ComplexIQ) -> ComplexIQ:" in orbit
    assert "return b.sub(a)" in orbit
    assert "def complex_excludes_zero(z: ComplexIQ) -> IQBoolResult:" in orbit
    assert "if re_result.rejected or im_result.rejected:" in orbit
    assert "return IQBoolResult(re_result.value or im_result.value, False)" in orbit


def test_bigq_exact_type_replay_uses_shared_box_and_typed_failure(mojo_smoke):
    src = text()
    smoke = (ROOT / "kernel/mojo/smoke/smoke_tests.mojo").read_text(encoding="utf-8")
    assert "from certificates.krawczyk_witness import c_minus_2_box" in src
    assert "struct BigQExactTypeExclusionResult(Copyable)" in src
    assert "def bigq_p21_exact_type_exclusions(half_width_den_power: Int)" in src
    assert "c_minus_2_box(half_width_den_power)" in src
    assert "def arithmetic_replay_accepted(self) -> Bool:" in src
    assert "def ambiguous(self) -> Bool:" in src
    assert "var narrow_box = bigq_p21_exact_type_exclusions(80)" in src
    assert mojo_smoke.case_passed("bigq exact-type exclusion replay")


def test_intended_pair_has_clean_semantics():
    # ell = 0 and period = 0 intend nothing, exactly as the former local copy:
    # the vendored guard also refuses negative indices, which no caller passes.
    collision = vendored(COLLISION)
    assert "if ell < 1 or period < 1 or i < 0 or j < 0:" in collision
    assert "return i >= ell and ((j - i) % period == 0)" in collision
    assert "j >= ell" not in collision
    assert "j >= ell" not in text()


def test_public_verifiers_reject_invalid_orbit_configs_before_partitioning(mojo_smoke):
    src = text()
    assert "var config = OrbitEvalConfig(ell, period, 3)" in src
    assert "var config = OrbitEvalConfig(ell, period, 6)" in src
    assert src.count("if not config.valid():") >= 2
    assert "def invalid_orbit_config_rejection_smoke() -> Bool:" in src
    assert "verify_exact_type_exclusions_h3(c_minus_2_box(8), 2, 0)" in src
    assert "verify_exact_type_exclusions_h6(c_minus_2_box(8), 4, 0)" in src
    assert mojo_smoke.case_passed("invalid orbit config rejection")


def test_same_box_and_exact_endpoint_gate_present():
    src = text()
    assert "used_same_parameter_box" in src
    assert "used_exact_rational_endpoints" in src
    assert "excluded_forbidden_count == self.forbidden_count" in src


def test_c_minus_2_uses_native_interval_verifier():
    src = text()
    assert "from certificates.krawczyk_witness import c_minus_2_box" in src
    assert "verify_exact_type_exclusions_h3(c_minus_2_box(8), 2, 1)" in src
    assert "def demo_native_c_minus_2_accepts" in src
    assert "return demo_c_minus_2_status().accepted()" in src


def test_m41_is_still_marked_placeholder_not_proof():
    src = text()
    assert "Placeholder until a certificate-ready dyadic M_4,1 box" in src
    assert "contract check, not as a completed proof witness" in src


def test_demo_counts_preserved():
    src = text()
    assert "IntervalOrbitStatus(True, True, True, 18" in src
    assert "forbidden_count(ell, period, horizon)" in src


def test_no_forbidden_runtime_shortcuts_in_interval_orbit():
    src = text().lower()
    forbidden = ["float64", "math.", "cmath", "numpy", "atan", "radian", "degree"]
    for token in forbidden:
        assert token not in src
