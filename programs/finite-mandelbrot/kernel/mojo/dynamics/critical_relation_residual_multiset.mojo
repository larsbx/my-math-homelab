# critical_relation_residual_multiset.mojo
#
# Exact lower-type stripping for
#
#     A_{4,1}(C) = C^5(C+2)(C^3+2C^2+2C+2)F_7(C).
#
# The known roots C=0 and C=-2 already collide before type (4,1), so their
# total multiplicity six is removed.  The remaining degree-10 factor is an
# algebraic candidate divisor only: this module does not certify the exact
# type, embeddings, or localization of its non-rational roots.

from polynomial.poly_z import (
    PolyZ,
    equal_poly,
    expected_F7_M41,
    expected_R_4_1_factorized,
    mul,
    raw_return_poly,
)
from dynamics.critical_relation_bridge import synthetic_divide_monic_linear
from dynamics.critical_relation_multiset import integer_exact_minimal_collision_pattern


struct LinearPowerStripResult:
    var quotient: PolyZ
    var divisions: Int
    var exact: Bool

    def __init__(
        out self, quotient: PolyZ, divisions: Int, exact: Bool
    ):
        self.quotient = quotient.copy()
        self.divisions = divisions
        self.exact = exact


struct R41ResidualDivisorMultiset(ImplicitlyCopyable):
    var relation_degree: Int
    var zero_multiplicity: Int
    var minus_two_multiplicity: Int
    var stripped_lower_type_multiplicity: Int
    var residual_degree: Int
    var degree_accounting_exact: Bool
    var relation_factorization_exact: Bool
    var residual_factorization_exact: Bool
    var known_roots_rejected_by_exact_type: Bool
    var residual_exact_type_certified: Bool
    var rejected: Bool

    def __init__(
        out self,
        relation_degree: Int,
        zero_multiplicity: Int,
        minus_two_multiplicity: Int,
        stripped_lower_type_multiplicity: Int,
        residual_degree: Int,
        degree_accounting_exact: Bool,
        relation_factorization_exact: Bool,
        residual_factorization_exact: Bool,
        known_roots_rejected_by_exact_type: Bool,
        residual_exact_type_certified: Bool,
        rejected: Bool,
    ):
        self.relation_degree = relation_degree
        self.zero_multiplicity = zero_multiplicity
        self.minus_two_multiplicity = minus_two_multiplicity
        self.stripped_lower_type_multiplicity = stripped_lower_type_multiplicity
        self.residual_degree = residual_degree
        self.degree_accounting_exact = degree_accounting_exact
        self.relation_factorization_exact = relation_factorization_exact
        self.residual_factorization_exact = residual_factorization_exact
        self.known_roots_rejected_by_exact_type = known_roots_rejected_by_exact_type
        self.residual_exact_type_certified = residual_exact_type_certified
        self.rejected = rejected

    def algebraic_replay_accepted(self) -> Bool:
        return (
            not self.rejected and self.relation_degree == 16 and
            self.zero_multiplicity == 5 and
            self.minus_two_multiplicity == 1 and
            self.stripped_lower_type_multiplicity == 6 and
            self.residual_degree == 10 and
            self.degree_accounting_exact and
            self.relation_factorization_exact and
            self.residual_factorization_exact and
            self.known_roots_rejected_by_exact_type
        )

    def exact_type_divisor_accepted(self) -> Bool:
        return (
            self.algebraic_replay_accepted() and
            self.residual_exact_type_certified
        )

    def proves_density(self) -> Bool:
        return False

    def proves_equidistribution(self) -> Bool:
        return False

    def proves_c1(self) -> Bool:
        return False


def strip_monic_linear_power(
    poly: PolyZ, root: Int, requested_power: Int
) -> LinearPowerStripResult:
    if requested_power < 0:
        return LinearPowerStripResult(poly, 0, False)
    var quotient = poly.copy()
    var divisions = 0
    for _ in range(requested_power):
        var step = synthetic_divide_monic_linear(quotient, root)
        if step.remainder != 0:
            return LinearPowerStripResult(quotient, divisions, False)
        quotient = step.quotient.copy()
        divisions += 1
    var next = synthetic_divide_monic_linear(quotient, root)
    return LinearPowerStripResult(
        quotient, divisions, next.remainder != 0,
    )


def expected_r41_residual_factor() -> PolyZ:
    var cubic = PolyZ()
    cubic.coeffs[0] = 2
    cubic.coeffs[1] = 2
    cubic.coeffs[2] = 2
    cubic.coeffs[3] = 1
    cubic.normalize()
    return mul(cubic, expected_F7_M41())


def verify_r41_residual_divisor_multiset() -> R41ResidualDivisorMultiset:
    var relation = raw_return_poly(4, 1)
    var strip_zero = strip_monic_linear_power(relation, 0, 5)
    if not strip_zero.exact:
        return R41ResidualDivisorMultiset(
            0, 0, 0, 0, 0,
            False, False, False, False, False, True,
        )
    var strip_minus_two = strip_monic_linear_power(
        strip_zero.quotient, -2, 1,
    )
    if not strip_minus_two.exact:
        return R41ResidualDivisorMultiset(
            0, 0, 0, 0, 0,
            False, False, False, False, False, True,
        )
    var residual = strip_minus_two.quotient.copy()
    var zero_is_exact_4_1 = integer_exact_minimal_collision_pattern(0, 4, 1)
    var minus_two_is_exact_4_1 = integer_exact_minimal_collision_pattern(
        -2, 4, 1,
    )
    return R41ResidualDivisorMultiset(
        relation.degree,
        strip_zero.divisions,
        strip_minus_two.divisions,
        strip_zero.divisions + strip_minus_two.divisions,
        residual.degree,
        relation.degree == (
            strip_zero.divisions +
            strip_minus_two.divisions +
            residual.degree
        ),
        equal_poly(relation, expected_R_4_1_factorized()),
        equal_poly(residual, expected_r41_residual_factor()),
        not zero_is_exact_4_1 and not minus_two_is_exact_4_1,
        False,
        False,
    )


def critical_relation_residual_multiset_smoke() -> Bool:
    var result = verify_r41_residual_divisor_multiset()
    var invalid_power = strip_monic_linear_power(
        raw_return_poly(4, 1), 0, -1,
    )
    return (
        result.algebraic_replay_accepted() and
        not result.exact_type_divisor_accepted() and
        result.stripped_lower_type_multiplicity == 6 and
        result.residual_degree == 10 and
        not invalid_power.exact and
        not result.proves_density() and
        not result.proves_equidistribution() and
        not result.proves_c1()
    )
