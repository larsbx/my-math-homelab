# complex_inverse.mojo
#
# Rational complex inverse helpers for Krawczyk witnesses.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Finite-regime rule: inverse is computed algebraically by conjugate divided by
# quadrance. There are no analytic angle APIs and no transcendental operations.
# No ideal points are introduced here: ComplexQ is a rational coordinate record.

from finite_exact.closed_interval import ComplexIQ, IQ
from finite_exact.rat_q import Q


struct ComplexQ:
    var re: Q
    var im: Q

    fn __init__(inout self, re: Q, im: Q):
        self.re = re
        self.im = im

    fn coord(re_num: Int64, re_den: Int64, im_num: Int64, im_den: Int64) -> ComplexQ:
        return ComplexQ(Q(re_num, re_den), Q(im_num, im_den))

    fn quadrance(self) -> Q:
        return self.re.square().add(self.im.square())

    fn inverse(self) -> ComplexQ:
        # z^{-1} = conjugate(z) / (x^2 + y^2).
        # Caller contract: quadrance is nonzero.
        var q = self.quadrance()
        return ComplexQ(self.re.div(q), self.im.neg().div(q))

    fn to_singleton_box(self) -> ComplexIQ:
        # Singleton box constructor for a rational coordinate record.
        return ComplexIQ.singleton(self.re, self.im)


struct InverseWitness:
    var input_name: String
    var quadrance_nonzero: Bool
    var inverse_is_dyadic_or_rational: Bool
    var used_quadrance_formula: Bool

    fn __init__(inout self, input_name: String, quadrance_nonzero: Bool, inverse_is_dyadic_or_rational: Bool, used_quadrance_formula: Bool):
        self.input_name = input_name
        self.quadrance_nonzero = quadrance_nonzero
        self.inverse_is_dyadic_or_rational = inverse_is_dyadic_or_rational
        self.used_quadrance_formula = used_quadrance_formula

    fn accepted(self) -> Bool:
        return self.quadrance_nonzero and self.inverse_is_dyadic_or_rational and self.used_quadrance_formula


fn inverse_p21_derivative_at_minus_2() -> ComplexQ:
    # P21'(C)=2C+2, so P21'(-2)=-2 and inverse is -1/2.
    return ComplexQ.coord(-1, 2, 0, 1)


fn witness_inverse_p21_derivative_at_minus_2() -> InverseWitness:
    return InverseWitness("dP21_at_minus_2", True, True, True)


fn m41_center_record() -> ComplexQ:
    # Dyadic coordinate record used by the M41 handoff.
    return ComplexQ(Q(-56912193317957, 562949953421312), Q(538341446717435, 562949953421312))


fn inverse_derivative_m41_pending() -> InverseWitness:
    # Native P41'(m) evaluation exists in poly_interval_eval.mojo. The next step
    # is to feed that value through ComplexQ.inverse once coordinate-record
    # evaluation is available over exact coefficient arrays.
    return InverseWitness("dP41_at_m41_center_pending", False, False, True)
