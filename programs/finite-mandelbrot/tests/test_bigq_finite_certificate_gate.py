from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_bigq_theorem_payloads_match_finite_scope_but_not_imports():
    src = read("kernel/mojo/certificates/c_minus_2/bigq_theorem_tag_payload_instances.mojo")
    assert "struct BigQRationalRayLandingInstance(Copyable)" in src
    assert "struct BigQMisiurewiczTrivialFiberInstance(Copyable)" in src
    assert "var classification_proof_attached: Bool" in src
    assert "True, False," in src
    assert "not landing.final_import_admissible()" in src
    assert "not fiber.final_import_admissible()" in src


def test_bigq_payload_address_uses_normalized_beyond_i64_inputs():
    src = read("kernel/mojo/certificates/c_minus_2/bigq_theorem_tag_payload_instances.mojo")
    assert "var beyond_i64 = bigz_add(bigz_from_i64(9223372036854775807)" in src
    assert "q_from_bigz(beyond_i64, bigz_mul(beyond_i64, bigz_from_i64(2)))" in src
    assert "self.address.eq(Q(1, 2))" in src


def test_bigq_certificate_gate_separates_finite_and_final_acceptance():
    src = read("kernel/mojo/certificates/c_minus_2/bigq_finite_certificate_gate.mojo")
    assert "def finite_inputs_accepted(self) -> Bool:" in src
    assert "def theorem_tags_accepted(self) -> Bool:" in src
    assert "def certificate_accepted(self) -> Bool:" in src
    assert "not status.theorem_tags_accepted()" in src
    assert "not status.certificate_accepted()" in src
    assert "not ambiguous.finite_inputs_accepted()" in src
    assert "not rejected.finite_inputs_accepted()" in src


def test_c1_and_residual_closure_are_explicitly_unproved():
    src = read("kernel/mojo/certificates/c_minus_2/bigq_finite_certificate_gate.mojo")
    assert "def proves_c1(self) -> Bool:\n        return False" in src
    assert "def proves_residual_closure_no_missing_links(self) -> Bool:\n        return False" in src
    assert "not status.proves_c1()" in src
    assert "not status.proves_residual_closure_no_missing_links()" in src


def test_new_replays_are_compiler_wired(mojo_smoke):
    smoke = read("kernel/mojo/smoke/smoke_tests.mojo")
    boundary = read("docs/mojo-toolchain-boundary.md")
    assert "from certificates.c_minus_2.bigq_theorem_tag_payload_instances import bigq_theorem_payload_replay_smoke" in smoke
    assert "from certificates.c_minus_2.bigq_finite_certificate_gate import bigq_finite_certificate_gate_smoke" in smoke
    assert mojo_smoke.case_passed("bigq theorem payload replay")
    assert mojo_smoke.case_passed("bigq finite certificate gate")
    assert "kernel/mojo/certificates/c_minus_2/bigq_theorem_tag_payload_instances.mojo" in boundary
    assert "kernel/mojo/certificates/c_minus_2/bigq_finite_certificate_gate.mojo" in boundary
