# coord_record_eval.mojo
#
# Coordinate-record polynomial evaluation for finite certificate construction.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Regime rule: this is not analytic point evaluation. A CoordRecord is a finite
# rational data record that may feed a singleton box or RootHandle witness.

from arithmetic.complex_inverse import ComplexQ, m41_center
from finite_exact.rat_q import Q


struct CoordEvalStatus:
    var polynomial_name: String
    var coord_record_name: String
    var used_coeff_array: Bool
    var used_horner: Bool
    var used_exact_rational_ops: Bool
    var certificate_ready_backend: Bool

    fn __init__(inout self, polynomial_name: String, coord_record_name: String, used_coeff_array: Bool, used_horner: Bool, used_exact_rational_ops: Bool, certificate_ready_backend: Bool):
        self.polynomial_name = polynomial_name
        self.coord_record_name = coord_record_name
        self.used_coeff_array = used_coeff_array
        self.used_horner = used_horner
        self.used_exact_rational_ops = used_exact_rational_ops
        self.certificate_ready_backend = certificate_ready_backend

    fn accepted(self) -> Bool:
        return self.used_coeff_array and self.used_horner and self.used_exact_rational_ops and self.certificate_ready_backend


fn cq_zero() -> ComplexQ:
    return ComplexQ.coord(0, 1, 0, 1)


fn cq_from_int(n: Int64) -> ComplexQ:
    return ComplexQ.coord(n, 1, 0, 1)


fn cq_add(a: ComplexQ, b: ComplexQ) -> ComplexQ:
    return ComplexQ(a.re.add(b.re), a.im.add(b.im))


fn cq_sub(a: ComplexQ, b: ComplexQ) -> ComplexQ:
    return ComplexQ(a.re.sub(b.re), a.im.sub(b.im))


fn cq_mul(a: ComplexQ, b: ComplexQ) -> ComplexQ:
    return ComplexQ(a.re.mul(b.re).sub(a.im.mul(b.im)), a.re.mul(b.im).add(a.im.mul(b.re)))


fn eval_poly13_ascending(coeff0: Int64, coeff1: Int64, coeff2: Int64, coeff3: Int64, coeff4: Int64, coeff5: Int64, coeff6: Int64, coeff7: Int64, coeff8: Int64, coeff9: Int64, coeff10: Int64, coeff11: Int64, coeff12: Int64, z: ComplexQ) -> ComplexQ:
    # Horner evaluation for coefficients [c0..c12], ascending powers.
    var acc = cq_from_int(coeff12)
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff11))
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff10))
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff9))
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff8))
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff7))
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff6))
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff5))
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff4))
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff3))
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff2))
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff1))
    acc = cq_add(cq_mul(acc, z), cq_from_int(coeff0))
    return acc


fn eval_p41_coord_record(z: ComplexQ) -> ComplexQ:
    # P41 coefficients ascending:
    # [0,8,20,40,68,94,114,116,94,60,28,8,1]
    return eval_poly13_ascending(0, 8, 20, 40, 68, 94, 114, 116, 94, 60, 28, 8, 1, z)


fn eval_p41_derivative_coord_record(z: ComplexQ) -> ComplexQ:
    # dP41 coefficients ascending:
    # [8,40,120,272,470,684,812,752,540,280,88,12,0]
    return eval_poly13_ascending(8, 40, 120, 272, 470, 684, 812, 752, 540, 280, 88, 12, 0, z)


fn m41_coord_eval_status_pending_backend() -> CoordEvalStatus:
    # The computation path is present, but current Q uses Int64. This remains
    # non-certificate-ready until the bigint boundary is satisfied.
    var _value = eval_p41_coord_record(m41_center())
    var _deriv = eval_p41_derivative_coord_record(m41_center())
    return CoordEvalStatus("P_4_1", "m41_center_coord_record", True, True, True, False)
