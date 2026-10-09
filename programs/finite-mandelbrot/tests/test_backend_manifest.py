from pathlib import Path
import tomllib

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "backend.toml"
AUDIT = ROOT / "tools" / "audit_backend_manifest.py"


def manifest():
    return tomllib.loads(MANIFEST.read_text(encoding="utf-8"))


def test_manifest_declares_demo_backend_not_proof_grade():
    data = manifest()
    assert data["backend"]["name"] == "Int64DemoBackend"
    assert data["backend"]["kind"] == "demo"
    assert data["backend"]["proof_grade"] is False
    assert data["policy"]["allow_demo_certificates"] is True
    assert data["policy"]["allow_proof_grade_certificates"] is False


def test_manifest_keeps_finite_regime_invariants_true():
    policy = manifest()["policy"]
    assert policy["no_analytic_trig"] is True
    assert policy["no_analytic_points"] is True
    assert policy["points_are_vertices_of_vertices"] is True
    assert policy["squarefree_localization_only"] is True
    assert policy["pointwise_exact_type_exclusion"] is True
    assert policy["no_float_certificate_arithmetic"] is True
    assert policy["exact_arithmetic_spec"] == "docs/rational-interval-arithmetic-spec.md"


def test_manifest_blocks_proof_grade_requirements_on_demo_backend():
    reqs = manifest()["requirements"]
    assert reqs["unbounded_storage"] is False
    assert reqs["exact_add_sub_mul"] is False
    assert reqs["euclidean_gcd"] is False
    assert reqs["exact_divisibility"] is False
    assert reqs["normalized_serialization"] is False
    assert reqs["canonical_hash_encoding"] is False


RETIRED_CHECKED_STACK = [
    "kernel/mojo/arithmetic/checked_int64_backend.mojo",
    "kernel/mojo/dynamics/checked_ray_address.mojo",
    "kernel/mojo/arithmetic/checked_q.mojo",
    "kernel/mojo/arithmetic/checked_interval_q.mojo",
    "kernel/mojo/arithmetic/checked_complex_interval.mojo",
    "kernel/mojo/certificates/checked_krawczyk_witness.mojo",
    "kernel/mojo/certificates/checked_interval_exclusion.mojo",
    "kernel/mojo/certificates/certificate_arithmetic_migration_gate.mojo",
    "kernel/mojo/certificates/c_minus_2/checked_finite_certificate_gate.mojo",
    "kernel/mojo/certificates/c_minus_2/checked_landing_target_adapter.mojo",
]


def test_checked_int64_rational_stack_is_retired():
    """The c=-2 certificates of record are the BigZ/Q replays; the Int64
    Q/IQ/ComplexIQ duplicates are gone and nothing imports them."""
    modules = [path.removeprefix("kernel/mojo/").removesuffix(".mojo").replace("/", ".") for path in RETIRED_CHECKED_STACK]
    for path in RETIRED_CHECKED_STACK:
        assert not (ROOT / path).exists(), path
    for source in (ROOT / "kernel").rglob("*.mojo"):
        text = source.read_text(encoding="utf-8")
        for module in modules:
            assert f"from {module} import" not in text, (source, module)
    backend = (ROOT / "kernel/mojo/arithmetic/cert_backend.mojo").read_text(encoding="utf-8")
    assert "CheckedInt64TransitionBackend" not in backend


def test_bigq_replays_carry_the_c_minus_2_certificates(mojo_smoke):
    smoke = (ROOT / "kernel/mojo/smoke/smoke_tests.mojo").read_text(encoding="utf-8")
    tags = (ROOT / "kernel/mojo/c1/theorem_tags/theorem_tag_payload_instances.mojo").read_text(encoding="utf-8")
    assert "verify_bigq_c_minus_2_landing_target_association(C_MINUS_2_HALF_WIDTH_DEN_POWER)" in tags
    assert "verify_bigq_one_half_orbit" in tags
    assert "self.landing_target_association.finite_replay_associated()" in tags
    assert "self.association.finite_replay_associated()" in tags
    assert '"SchleicherRationalParameterRays"' in tags
    assert '"SchleicherFibersLC"' in tags
    assert "proof_grade_landing_target_association.proof_grade_associated()" in tags
    assert "class_specific_trivial_fiber_accepted()" in tags
    for case in [
        "bigq Krawczyk replay",
        "bigq exact-type exclusion replay",
        "bigq ray address replay",
        "bigq landing target replay",
        "bigq finite certificate gate",
        "theorem tag payload instances",
    ]:
        assert f'report.record("{case}"' in smoke
        assert mojo_smoke.case_passed(case)
    for retired in ["checked Q", "checked interval Q", "checked complex Horner", "checked Krawczyk",
                    "checked interval exclusion", "certificate arithmetic migration",
                    "checked finite certificate gate", "checked landing target adapter",
                    "checked i64 boundary", "checked ray address"]:
        assert f'report.record("{retired}"' not in smoke


def test_backend_manifest_audit_exists_and_checks_all_requirements():
    src = AUDIT.read_text(encoding="utf-8")
    for key in [
        "unbounded_storage",
        "exact_add_sub_mul",
        "exact_order",
        "euclidean_gcd",
        "exact_divisibility",
        "normalized_serialization",
        "canonical_hash_encoding",
    ]:
        assert key in src
    assert "demo backend cannot be proof_grade" in src
    assert "backend.proof_grade and policy.allow_proof_grade_certificates must change together" in src
