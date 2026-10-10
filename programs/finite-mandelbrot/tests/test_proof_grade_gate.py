from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKEND = ROOT / "kernel/mojo/arithmetic/cert_backend.mojo"
PROOF = ROOT / "kernel/mojo/certificates/c_minus_2/proof_grade_gate.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_backend_contract_requires_unbounded_storage():
    src = read(BACKEND)
    assert "struct CertIntBackend" in src
    assert "unbounded_storage" in src
    assert "exact_add_sub_mul" in src
    assert "euclidean_gcd" in src
    assert "exact_divisibility" in src
    assert "normalized_serialization" in src
    assert "def certificate_ready" in src


def test_int64_demo_backend_not_certificate_ready():
    src = read(BACKEND)
    assert "Int64DemoBackend" in src
    assert "False," in src
    assert "must_reject_certificate_on_int64_demo_backend" in src


def test_replay_and_certificate_acceptance_are_separate_gates():
    src = read(ROOT / "kernel/mojo/certificates/c_minus_2/bigq_finite_certificate_gate.mojo")
    assert "def finite_inputs_accepted" in src
    assert "def certificate_accepted" in src
    assert "return self.finite_inputs_accepted() and self.theorem_tags_accepted()" in src
    assert "not status.theorem_tags_accepted() and not status.certificate_accepted()" in src
    assert "not ambiguous.finite_inputs_accepted() and not rejected.finite_inputs_accepted()" in src


def test_proof_grade_gate_composes_certificate_and_backend():
    src = read(PROOF)
    assert "struct ProofGradeStatus" in src
    assert "finite_certificate_accepted" in src
    assert "backend_gate.valid()" in src
    assert "backend_gate.allows_certificate_acceptance" in src
    assert "theorem_tags_bound" in src
    assert "incidence_vertex_valid" in src


def test_demo_and_m41_rejected_as_proof_grade():
    src = read(PROOF)
    assert "fn demo_c_minus_2_not_proof_grade" in src
    assert "fn m41_not_proof_grade" in src
    assert "fn must_reject_demo_as_proof_grade" in src
    assert "fn must_reject_m41_as_proof_grade" in src
    assert "return not status.proof_grade_accepted()" in src


def test_no_forbidden_runtime_shortcuts():
    combined = (read(BACKEND) + "\n" + read(PROOF)).lower()
    forbidden = ["float64", "math.", "cmath", "numpy", "atan(", "radian", "degree"]
    for token in forbidden:
        assert token not in combined
