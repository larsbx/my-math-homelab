# poly_interval_eval.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Native interval polynomial evaluation for squarefree localization polynomials.
#
# Coefficients are stored in ascending order: coeffs[d] is the coefficient of C^d.
# This module evaluates polynomials over ComplexIQ using Horner's rule.
# It uses BigZ-backed Q and fail-closed intervals, but remains an
# implementation-grade scaffold until its acceptance-bearing replay is done.

from finite_exact.closed_interval import ComplexIQ
from finite_exact.rat_q import Q


struct PolyIQEvalStatus:
    var polynomial_name: String
    var used_horner: Bool
    var used_complex_interval: Bool
    var coefficient_order_ascending: Bool
    var backend_certificate_ready: Bool

    def __init__(out self, polynomial_name: String, used_horner: Bool, used_complex_interval: Bool, coefficient_order_ascending: Bool, backend_certificate_ready: Bool):
        self.polynomial_name = polynomial_name
        self.used_horner = used_horner
        self.used_complex_interval = used_complex_interval
        self.coefficient_order_ascending = coefficient_order_ascending
        self.backend_certificate_ready = backend_certificate_ready

    def scaffold_accepted(self) -> Bool:
        return self.used_horner and self.used_complex_interval and self.coefficient_order_ascending

    def certificate_ready(self) -> Bool:
        return self.scaffold_accepted() and self.backend_certificate_ready


def const_complex(n: Int64) -> ComplexIQ:
    return ComplexIQ.singleton(Q(n, 1), Q.zero())


def eval_poly_ascending_horner_ciq(c_box: ComplexIQ, coeffs: List[Int64]) -> ComplexIQ:
    # Horner from highest degree down to constant term.
    var acc = const_complex(0)
    var idx = len(coeffs) - 1
    while idx >= 0:
        acc = acc.mul(c_box).add(const_complex(coeffs[idx]))
        idx -= 1
    return acc^


# Regime correspondence: formal-polynomial-derivative
def derivative_coeffs_ascending(coeffs: List[Int64]) -> List[Int64]:
    var out = List[Int64]()
    for d in range(1, len(coeffs)):
        out.append(coeffs[d] * Int64(d))
    return out^


def p21_coeffs_ascending() -> List[Int64]:
    # P_{2,1}=C(C+2)=C^2+2C.
    return [0, 2, 1]


def p21_derivative_coeffs_ascending() -> List[Int64]:
    # P'_{2,1}=2C+2.
    return derivative_coeffs_ascending(p21_coeffs_ascending())


def f3_m41_coeffs_ascending() -> List[Int64]:
    # C^3+2C^2+2C+2.
    return [2, 2, 2, 1]


def f7_m41_coeffs_ascending() -> List[Int64]:
    # F7=C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2.
    return [2, 2, 4, 6, 6, 6, 4, 1]


def p41_coeffs_ascending() -> List[Int64]:
    # P_{4,1}=C(C+2)(C^3+2C^2+2C+2)F7.
    # Expanded ascending coefficients, computed from the preserved factorization.
    # Degree 12.
    return [0, 8, 20, 40, 68, 94, 114, 116, 94, 60, 28, 8, 1]


def p41_derivative_coeffs_ascending() -> List[Int64]:
    return derivative_coeffs_ascending(p41_coeffs_ascending())


def eval_p21(c_box: ComplexIQ) -> ComplexIQ:
    return eval_poly_ascending_horner_ciq(c_box, p21_coeffs_ascending())


# Regime correspondence: formal-polynomial-derivative
def eval_p21_derivative(c_box: ComplexIQ) -> ComplexIQ:
    return eval_poly_ascending_horner_ciq(c_box, p21_derivative_coeffs_ascending())


def eval_p41(c_box: ComplexIQ) -> ComplexIQ:
    return eval_poly_ascending_horner_ciq(c_box, p41_coeffs_ascending())


def eval_p41_derivative(c_box: ComplexIQ) -> ComplexIQ:
    return eval_poly_ascending_horner_ciq(c_box, p41_derivative_coeffs_ascending())


def demo_poly_interval_eval_status() -> PolyIQEvalStatus:
    return PolyIQEvalStatus("P_2_1_and_P_4_1", True, True, True, False)
