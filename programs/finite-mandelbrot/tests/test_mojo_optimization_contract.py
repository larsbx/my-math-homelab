from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "kernel/mojo/theorem_kernel/mojo_optimization_contract.mojo"
POLICY = ROOT / "docs" / "mojo_first_execution_policy.md"


def body(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_mojo_is_default_first_class_computation_language():
    text = body(CONTRACT) + "\n" + body(POLICY)
    assert "default_computation_language(policy: OptimizationPolicy)" in text
    assert "return policy.computation_language" in text
    assert "Mojo is the default first-class language" in text


def test_mojo_is_default_finite_theorem_kernel_language():
    text = body(CONTRACT) + "\n" + body(POLICY)
    assert "default_theorem_kernel_language(policy: OptimizationPolicy)" in text
    assert "theorem_kernel_discipline" in text
    assert "finite proof-object theorem kernel" in text
    assert "deterministic_proof_replay_required(policy: OptimizationPolicy)" in text


def test_core_kernels_have_optimization_discipline():
    text = body(CONTRACT)
    assert "polynomial_kernel_discipline" in text
    assert "separator_catalogue_kernel_discipline" in text
    assert "interval_kernel_discipline" in text
    assert "theorem_kernel_discipline" in text
    assert "uses_value_structs" in text
    assert "avoids_heap_pressure" in text
    assert "batchable" in text
    assert "backend_boundary_explicit" in text


def test_horner_batching_and_proof_replay_are_required():
    text = body(CONTRACT) + "\n" + body(POLICY)
    assert "horner_polynomial_evaluation_required(policy: OptimizationPolicy)" in text
    assert "batchable_catalogue_scans_required(policy: OptimizationPolicy)" in text
    assert "deterministic_proof_replay_required(policy: OptimizationPolicy)" in text
    assert "Horner evaluation" in text
    assert "batchable vector-style loops" in text
    assert "deterministic proof replay" in text


def test_python_remains_reference_not_primary_after_mojo_port():
    text = body(CONTRACT) + "\n" + body(POLICY)
    assert "python_reference_oracle_allowed(policy: OptimizationPolicy)" in text
    assert "python_primary_certificate_engine_allowed_after_mojo_port(policy: OptimizationPolicy)" in text
    assert "python_primary_theorem_kernel_allowed_after_mojo_port(policy: OptimizationPolicy)" in text
    assert "Python remains acceptable" in text
    assert "must not become the source of truth" in text


def test_theorem_tag_import_boundary_is_explicit():
    text = body(CONTRACT) + "\n" + body(POLICY)
    assert "theorem_tag_import_boundary_explicit(policy: OptimizationPolicy)" in text
    assert "theorem-tag imports are an explicit trust boundary" in text or "theorem tags with source metadata" in text


def test_debug_paths_are_never_proof_grade_by_default():
    text = body(CONTRACT) + "\n" + body(POLICY)
    assert "debug_path_is_proof_grade(policy: OptimizationPolicy)" in text
    assert "debug/demo paths" in text
    assert "proof-grade" in text


def test_optimization_policy_is_data_checked():
    text = body(CONTRACT)
    assert "struct OptimizationPolicy" in text
    assert "optimization_policy_valid(policy: OptimizationPolicy)" in text
    assert "return policy.debug_proof_grade" in text
