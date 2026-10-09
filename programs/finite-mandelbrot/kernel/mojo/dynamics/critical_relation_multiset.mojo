# critical_relation_multiset.mojo
#
# Executable effective-divisor semantics for the first critical relation:
#
#     A_{2,1}(C) = Q_3(C) - Q_2(C) = C^3(C+2).
#
# Coefficients in this multiset are algebraic root multiplicities.  Exact-type
# filtering is a separate operation: the triple root C=0 is a lower-type
# collision and is removed, while C=-2 remains with multiplicity one.
#
# This is a finite identity over Z[C].  It does not assert density,
# equidistribution, localization, MLC, residual closure, or C1.

from polynomial.poly_z import (
    PolyZ,
    equal_poly,
    expected_R_2_1,
    monic_linear,
    mul,
    pow_poly,
    raw_return_poly,
    variable,
)
from dynamics.critical_relation_bridge import synthetic_divide_monic_linear
from finite_exact.bigint_z import BigZ, bigz_add, bigz_eq, bigz_from_i64, bigz_mul, bigz_zero


struct CriticalRelationDivisorMultiset(ImplicitlyCopyable):
    var relation_degree: Int
    var zero_multiplicity: Int
    var minus_two_multiplicity: Int
    var declared_total_multiplicity: Int
    var factorization_exact: Bool
    var zero_rejected_by_exact_type: Bool
    var minus_two_has_exact_type_2_1: Bool
    var exact_type_support_count: Int
    var exact_type_total_multiplicity: Int
    var rejected: Bool

    def __init__(
        out self,
        relation_degree: Int,
        zero_multiplicity: Int,
        minus_two_multiplicity: Int,
        declared_total_multiplicity: Int,
        factorization_exact: Bool,
        zero_rejected_by_exact_type: Bool,
        minus_two_has_exact_type_2_1: Bool,
        exact_type_support_count: Int,
        exact_type_total_multiplicity: Int,
        rejected: Bool,
    ):
        self.relation_degree = relation_degree
        self.zero_multiplicity = zero_multiplicity
        self.minus_two_multiplicity = minus_two_multiplicity
        self.declared_total_multiplicity = declared_total_multiplicity
        self.factorization_exact = factorization_exact
        self.zero_rejected_by_exact_type = zero_rejected_by_exact_type
        self.minus_two_has_exact_type_2_1 = minus_two_has_exact_type_2_1
        self.exact_type_support_count = exact_type_support_count
        self.exact_type_total_multiplicity = exact_type_total_multiplicity
        self.rejected = rejected

    def accepted(self) -> Bool:
        return (
            not self.rejected and self.relation_degree == 4 and
            self.zero_multiplicity == 3 and
            self.minus_two_multiplicity == 1 and
            self.declared_total_multiplicity == self.relation_degree and
            self.factorization_exact and
            self.zero_rejected_by_exact_type and
            self.minus_two_has_exact_type_2_1 and
            self.exact_type_support_count == 1 and
            self.exact_type_total_multiplicity == 1
        )

    def proves_density(self) -> Bool:
        return False

    def proves_equidistribution(self) -> Bool:
        return False

    def proves_c1(self) -> Bool:
        return False


def bounded_integer_root_multiplicity(poly: PolyZ, root: Int) -> Int:
    """Count repeated exact division by C-root, bounded by the input degree."""
    var current = poly.copy()
    var multiplicity = 0
    var remaining = poly.degree
    while remaining > 0:
        var division = synthetic_divide_monic_linear(current, root)
        if division.remainder != 0:
            break
        multiplicity += 1
        current = division.quotient.copy()
        remaining -= 1
    return multiplicity


def integer_orbit_value(parameter: Int, depth: Int) -> BigZ:
    """Q_depth(parameter) over Z. The orbit grows doubly exponentially (c = 2
    passes Int at depth 7), so it is BigZ and never wraps."""
    var c = bigz_from_i64(Int64(parameter))
    var value = bigz_zero()
    for _ in range(depth):
        value = bigz_add(bigz_mul(value, value), c)
    return value^


def integer_exact_minimal_collision_pattern(
    parameter: Int, ell: Int, period: Int
) -> Bool:
    if ell < 0 or period < 1:
        return False
    var horizon = ell + period
    for left in range(horizon + 1):
        var left_value = integer_orbit_value(parameter, left)
        for right in range(left + 1, horizon + 1):
            var equal = bigz_eq(left_value, integer_orbit_value(parameter, right))
            var intended = left == ell and right == horizon
            if equal != intended:
                return False
    return True


def verify_r21_divisor_multiset() -> CriticalRelationDivisorMultiset:
    var relation = raw_return_poly(2, 1)
    var c = variable()
    var declared = mul(pow_poly(c, 3), monic_linear(2))
    var zero_multiplicity = bounded_integer_root_multiplicity(relation, 0)
    var minus_two_multiplicity = bounded_integer_root_multiplicity(relation, -2)
    var zero_exact_2_1 = integer_exact_minimal_collision_pattern(0, 2, 1)
    var minus_two_exact_2_1 = integer_exact_minimal_collision_pattern(-2, 2, 1)
    var exact_support = 0
    var exact_total = 0
    if zero_exact_2_1:
        exact_support += 1
        exact_total += zero_multiplicity
    if minus_two_exact_2_1:
        exact_support += 1
        exact_total += minus_two_multiplicity
    return CriticalRelationDivisorMultiset(
        relation.degree,
        zero_multiplicity,
        minus_two_multiplicity,
        zero_multiplicity + minus_two_multiplicity,
        equal_poly(relation, expected_R_2_1()) and
            equal_poly(relation, declared),
        not zero_exact_2_1,
        minus_two_exact_2_1,
        exact_support,
        exact_total,
        False,
    )


def critical_relation_multiset_smoke() -> Bool:
    var divisor = verify_r21_divisor_multiset()
    var counterfeit = CriticalRelationDivisorMultiset(
        4, 2, 2, 4, True, True, True, 1, 1, False,
    )
    return (
        divisor.accepted() and
        divisor.declared_total_multiplicity == divisor.relation_degree and
        divisor.exact_type_support_count == 1 and
        divisor.exact_type_total_multiplicity == 1 and
        not counterfeit.accepted() and
        not divisor.proves_density() and
        not divisor.proves_equidistribution() and
        not divisor.proves_c1()
    )
