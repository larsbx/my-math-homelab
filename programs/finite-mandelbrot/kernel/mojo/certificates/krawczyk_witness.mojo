# krawczyk_witness.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Native target for squarefree-polynomial Krawczyk localization witnesses.
#
# This module is finite-regime only: exact polynomial data, dyadic rational
# boxes, and interval inclusion checks. It contains no analytic trig primitives.
# The Krawczyk operator (Krawczyk 1969) and the Krawczyk-Moore strict-interior
# test (Moore 1977) are the vendored root_isolation
# kernel (finite-math-kernels docs/root-isolation-spec.md); this module
# supplies P_{2,1}, its box and its preconditioner.
#
# Status:
# - P_{2,1}=C(C+2) has a native interval Krawczyk computation.
# - P_{4,1}=C(C+2)(C^3+2C^2+2C+2)F7 has general interval evaluation
#   functions available, but its final inclusion witness remains pending.

from finite_exact.closed_interval import ComplexIQ, IQ
from finite_exact.bigint_z import bigz_from_i64, bigz_mul
from finite_exact.rat_q import Q, q_from_bigz, q_rejected
from arithmetic.rat_backend_plan import current_q_backend_status, q_backend_blocks_proof_acceptance
from polynomial.poly_interval_eval import eval_p21, eval_p21_derivative, eval_p41, eval_p41_derivative
from root_isolation import centre, krawczyk_image, strictly_inside


struct KrawczykWitnessStatus:
    var polynomial_name: String
    var used_squarefree_polynomial: Bool
    var used_dyadic_center: Bool
    var used_dyadic_inverse: Bool
    var krawczyk_subset_interior: Bool
    var root_box_name: String

    def __init__(out self, polynomial_name: String, used_squarefree_polynomial: Bool, used_dyadic_center: Bool, used_dyadic_inverse: Bool, krawczyk_subset_interior: Bool, root_box_name: String):
        self.polynomial_name = polynomial_name
        self.used_squarefree_polynomial = used_squarefree_polynomial
        self.used_dyadic_center = used_dyadic_center
        self.used_dyadic_inverse = used_dyadic_inverse
        self.krawczyk_subset_interior = krawczyk_subset_interior
        self.root_box_name = root_box_name

    def accepted(self) -> Bool:
        return (
            self.used_squarefree_polynomial and
            self.used_dyadic_center and
            self.used_dyadic_inverse and
            self.krawczyk_subset_interior
        )


struct BigQKrawczykResult(Copyable):
    # Arithmetic rejection and a valid non-contraction are distinct. Accepted
    # here means only that the finite BigZ interval contraction was replayed.
    var contraction_verified: Bool
    var rejected: Bool

    def __init__(out self, contraction_verified: Bool, rejected: Bool):
        self.contraction_verified = contraction_verified
        self.rejected = rejected

    def arithmetic_replay_accepted(self) -> Bool:
        return self.contraction_verified and not self.rejected


def complex_minus_half() -> ComplexIQ:
    return ComplexIQ.singleton(Q(-1, 2), Q.zero())


# Regime correspondence: rational-box-half-width
def c_minus_2_box(half_width_den_power: Int) -> ComplexIQ:
    # Dyadic box centered at -2 with half-width 2^{-half_width_den_power} in each coordinate.
    if half_width_den_power < 0:
        return ComplexIQ.singleton(q_rejected(), q_rejected())
    var den = bigz_from_i64(1)
    for _ in range(half_width_den_power):
        den = bigz_mul(den, bigz_from_i64(2))
    var h = q_from_bigz(bigz_from_i64(1), den)
    return ComplexIQ(IQ(Q(-2, 1).sub(h), Q(-2, 1).add(h)), IQ(h.neg(), h))


def p21_krawczyk_image(beta: ComplexIQ) -> ComplexIQ:
    # K(beta)=m-A P(m)+(1-A P'(beta))(beta-m)
    # for m the exact centre of beta (-2 for c_minus_2_box) and A=-1/2, the
    # exact inverse of P'(-2) = -2. Any point A is admissible (spec section 4).
    var m = centre(beta)
    var a = complex_minus_half()
    return krawczyk_image(beta, m, a, eval_p21(m), eval_p21_derivative(beta))


# Regime correspondence: rational-box-krawczyk-replay
def verify_bigq_p21_krawczyk_c_minus_2(half_width_den_power: Int) -> BigQKrawczykResult:
    var beta = c_minus_2_box(half_width_den_power)
    var image = p21_krawczyk_image(beta)
    if not beta.accepted() or not image.accepted():
        return BigQKrawczykResult(False, True)
    var strict = strictly_inside(image, beta)
    if strict.rejected:
        return BigQKrawczykResult(False, True)
    return BigQKrawczykResult(strict.value, False)


def verify_p21_krawczyk_c_minus_2(half_width_den_power: Int) -> Bool:
    return verify_bigq_p21_krawczyk_c_minus_2(half_width_den_power).arithmetic_replay_accepted()


def demo_krawczyk_p21_c_minus_2() -> KrawczykWitnessStatus:
    # Computed native interval witness for beta centered at -2.
    # The default radius 2^-8 keeps the witness readable during debugging.
    var ok = verify_p21_krawczyk_c_minus_2(8)
    return KrawczykWitnessStatus("P_2_1", True, True, True, ok, "beta_c_minus_2")


def bigq_krawczyk_replay_smoke() -> Bool:
    var witness = verify_bigq_p21_krawczyk_c_minus_2(8)
    var invalid_half_width = verify_bigq_p21_krawczyk_c_minus_2(-1)
    var narrow_box = verify_bigq_p21_krawczyk_c_minus_2(80)
    var backend = current_q_backend_status()
    return (
        witness.arithmetic_replay_accepted() and
        invalid_half_width.rejected and not invalid_half_width.arithmetic_replay_accepted() and
        narrow_box.arithmetic_replay_accepted() and
        q_backend_blocks_proof_acceptance(backend)
    )


def f7_name() -> String:
    return "F7=C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2"


def p41_squarefree_name() -> String:
    return "P_4_1=C(C+2)(C^3+2C^2+2C+2)F7"


def p41_evaluation_available_on_box(beta: ComplexIQ) -> Bool:
    # This performs polynomial and derivative interval evaluation through the
    # general Horner evaluator, but does not yet certify a Krawczyk inclusion.
    var p_beta = eval_p41(beta)
    var dp_beta = eval_p41_derivative(beta)
    var p_re = p_beta.re.contains_zero()
    var dp_re = dp_beta.re.contains_zero()
    var dp_im = dp_beta.im.contains_zero()
    var p_im = p_beta.im.contains_zero()
    if p_re.rejected or dp_re.rejected or dp_im.rejected or p_im.rejected:
        return False
    return not p_re.value or dp_re.value or dp_im.value or not p_im.value


def demo_krawczyk_p41_m41_placeholder() -> KrawczykWitnessStatus:
    # Required target witness for M_{4,1}:
    #   P=P_4_1 squarefree polynomial.
    #   beta centered at dyadic approximation of upper non-real F7 root.
    #   A dyadic enclosure for inverse derivative at the center.
    #   Proof that K_P(beta) is strictly inside beta.
    # General polynomial interval evaluation is present; the inverse derivative
    # enclosure and final inclusion proof remain pending.
    return KrawczykWitnessStatus("P_4_1", True, True, False, False, "beta_m41_pending")


def krawczyk_ready_for_joint_certificate(status: KrawczykWitnessStatus) -> Bool:
    return status.accepted()
