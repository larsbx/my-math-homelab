from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "kernel/mojo/dynamics/multiset_b3_localization.mojo"
SMOKE = ROOT / "kernel/mojo/smoke/smoke_tests.mojo"
BRIDGE = ROOT / "docs" / "multiset-bridge-program.md"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_b3_root_handle_composes_factor_provenance_and_localization():
    body = read(SOURCE)
    assert "struct RationalB3RootHandle" in body
    assert "verify_linear_factor_provenance(-2, 2, 1, prime)" in body
    assert "verify_bigq_p21_krawczyk_c_minus_2" in body
    assert "factor_provenance_accepted" in body
    assert "localization_unique" in body
    assert "exact_type_verified_over_z" in body
    assert "current_q_backend_status()" in body
    assert "q_backend_blocks_proof_acceptance(backend)" in body


def test_b3_scope_is_rational_c_minus_2_and_fail_closed():
    body = read(SOURCE)
    assert "self.integer_root == -2" in body
    assert "self.preperiod == 2 and self.period == 1" in body
    assert "self.prime == 5" in body
    assert "def accepts_general_algebraic_factor" in body
    assert "def accepts_nonrational_complex_embedding" in body
    assert "def imports_distributional_bridge" in body
    assert body.count("return False") >= 3
    assert "def arithmetic_replay_accepted" in body
    assert "self.arithmetic_replay_accepted() and self.backend_proof_gate_open" in body
    assert "not replay.accepted()" in body
    assert "not replay.proof_grade_accepted()" in body


def test_exact_integer_orbit_replay_identifies_type_2_1():
    body = read(SOURCE)
    assert "def c_minus_2_exact_type_2_1_over_z" in body
    assert "q1 == -2 and q2 == 2 and q3 == 2" in body
    assert "q0 != q1 and q0 != q2 and q1 != q2" in body


def test_b3_bridge_documentation_names_executable_boundary():
    bridge = read(BRIDGE)
    normalized = " ".join(bridge.lower().split())
    assert "rationalb3roothandle" in normalized
    assert "c = -2" in normalized
    assert "general algebraic factors" in normalized
    assert "non-rational complex embeddings" in normalized


def test_b3_localization_is_compiler_wired(mojo_smoke):
    smoke = read(SMOKE)
    assert (
        "from dynamics.multiset_b3_localization import "
        "multiset_b3_localization_smoke" in smoke
    )
    assert 'report.record("multiset B3 localization"' in smoke
    assert mojo_smoke.case_passed("multiset B3 localization")
