# proof_grade_gate.mojo
#
# Final proof-grade acceptance gate.
#
# This layer composes the finite incidence certificate with the arithmetic backend
# contract. A demo certificate may be structurally accepted, but it is not a
# proof-grade certificate unless the backend is certificate-ready.

from arithmetic.cert_backend import BackendGate, demo_gate, certificate_gate_pending, int64_demo_backend
from certificates.misiurewicz_certificate import MisiurewiczCertificate, c_minus_2_certificate, m41_certificate_placeholder


struct ProofGradeStatus:
    var certificate_name: String
    var finite_certificate_accepted: Bool
    var backend_gate: BackendGate
    var theorem_tags_bound: Bool
    var incidence_vertex_valid: Bool

    fn __init__(inout self, certificate_name: String, finite_certificate_accepted: Bool, backend_gate: BackendGate, theorem_tags_bound: Bool, incidence_vertex_valid: Bool):
        self.certificate_name = certificate_name
        self.finite_certificate_accepted = finite_certificate_accepted
        self.backend_gate = backend_gate
        self.theorem_tags_bound = theorem_tags_bound
        self.incidence_vertex_valid = incidence_vertex_valid

    fn proof_grade_accepted(self) -> Bool:
        return (
            self.finite_certificate_accepted and
            self.backend_gate.valid() and
            self.backend_gate.allows_certificate_acceptance and
            self.theorem_tags_bound and
            self.incidence_vertex_valid
        )


fn demo_c_minus_2_not_proof_grade() -> ProofGradeStatus:
    var cert = c_minus_2_certificate()
    return ProofGradeStatus(
        "c_minus_2_demo_only",
        cert.accepted(),
        demo_gate(),
        True,
        True,
    )


fn m41_not_proof_grade() -> ProofGradeStatus:
    var cert = m41_certificate_placeholder()
    return ProofGradeStatus(
        "m41_pending",
        cert.accepted(),
        certificate_gate_pending(),
        True,
        True,
    )


fn must_reject_demo_as_proof_grade() -> Bool:
    var status = demo_c_minus_2_not_proof_grade()
    return not status.proof_grade_accepted()


fn must_reject_m41_as_proof_grade() -> Bool:
    var status = m41_not_proof_grade()
    return not status.proof_grade_accepted()


fn must_reject_int64_even_if_certificate_flag_requested() -> Bool:
    var cert = c_minus_2_certificate()
    var bad_gate = BackendGate(int64_demo_backend(), True, True)
    var status = ProofGradeStatus("bad_int64_acceptance", cert.accepted(), bad_gate, True, True)
    return not status.proof_grade_accepted()
