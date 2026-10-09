# critical_relation_bridge.mojo
#
# First executable slice of docs/multiset-bridge-program.md.
#
# This checker proves a bounded modular statement about the integral
# critical-orbit relation A_{ell,k} = Q_{ell+k} - Q_ell.  Acceptance means:
# - the supplied modulus is prime;
# - polynomial reduction agrees with direct orbit iteration through ell+k;
# - the declared return relation holds;
# - every other collision through the minimal horizon is excluded; and
# - the critical-relation root is simple modulo p.
#
# It does not construct an infinite Hensel lift, identify a
# characteristic-zero factor, choose a complex embedding, or localize a
# parameter root.
#
# Arithmetic modulo p and p^2 (evaluation, the primality check, the Hensel
# step) is the vendored finite_polynomial.polynomial_fp, whose moduli stay
# below 2^31 so no product of residues can wrap.

from polynomial.poly_z import PolyZ, critical_orbit_poly, derivative, sub, mul, monic_linear, equal_poly
from finite_field_orbit.census import step
from finite_polynomial import hensel_step, is_prime
from finite_polynomial.polynomial_fp import Modulus, PolyFp, poly_fp_eval

comptime MAX_BRIDGE_PRIME = 1048576
# PolyZ coefficients are Int and wrap silently: Q_7 peaks at 35 bits, Q_8 at
# 72 (its derivative at 78). Past horizon 7, verify_simple_residue_root_by_census
# in dynamics/critical_type_census.mojo answers without materializing Q_n.
comptime MAX_BRIDGE_HORIZON = 7
comptime MAX_HENSEL_PRIME = 4096
comptime MAX_HENSEL_HORIZON = 6
comptime MAX_LINEAR_FACTOR_HORIZON = 3
comptime MAX_LINEAR_FACTOR_ROOT_ABS = 4
comptime MAX_LINEAR_FACTOR_COEFFICIENT_ABS = 1000000


struct SimpleResidueRootCertificate(ImplicitlyCopyable):
    var prime: Int
    var residue: Int
    var preperiod: Int
    var period: Int
    var reduction_commutes: Bool
    var relation_holds: Bool
    var exact_type_exclusions_hold: Bool
    var derivative_nonzero: Bool
    var rejected: Bool

    def __init__(
        out self,
        prime: Int,
        residue: Int,
        preperiod: Int,
        period: Int,
        reduction_commutes: Bool,
        relation_holds: Bool,
        exact_type_exclusions_hold: Bool,
        derivative_nonzero: Bool,
        rejected: Bool,
    ):
        self.prime = prime
        self.residue = residue
        self.preperiod = preperiod
        self.period = period
        self.reduction_commutes = reduction_commutes
        self.relation_holds = relation_holds
        self.exact_type_exclusions_hold = exact_type_exclusions_hold
        self.derivative_nonzero = derivative_nonzero
        self.rejected = rejected

    def accepted(self) -> Bool:
        return (
            not self.rejected and self.reduction_commutes and
            self.relation_holds and self.exact_type_exclusions_hold and
            self.derivative_nonzero
        )


struct HenselStepCertificate(ImplicitlyCopyable):
    """One independently replayable lift from a simple root modulo p to the
    unique compatible root modulo p^2."""

    var prime: Int
    var base_residue: Int
    var correction_digit: Int
    var lifted_residue: Int
    var modulus_squared: Int
    var base_certificate_accepted: Bool
    var congruent_to_base: Bool
    var lifted_relation_holds: Bool
    var derivative_unit: Bool
    var rejected: Bool

    def __init__(
        out self,
        prime: Int,
        base_residue: Int,
        correction_digit: Int,
        lifted_residue: Int,
        modulus_squared: Int,
        base_certificate_accepted: Bool,
        congruent_to_base: Bool,
        lifted_relation_holds: Bool,
        derivative_unit: Bool,
        rejected: Bool,
    ):
        self.prime = prime
        self.base_residue = base_residue
        self.correction_digit = correction_digit
        self.lifted_residue = lifted_residue
        self.modulus_squared = modulus_squared
        self.base_certificate_accepted = base_certificate_accepted
        self.congruent_to_base = congruent_to_base
        self.lifted_relation_holds = lifted_relation_holds
        self.derivative_unit = derivative_unit
        self.rejected = rejected

    def accepted(self) -> Bool:
        return (
            not self.rejected and self.base_certificate_accepted and
            self.congruent_to_base and self.lifted_relation_holds and
            self.derivative_unit
        )


struct LinearFactorProvenance(ImplicitlyCopyable):
    """Bounded characteristic-zero provenance for a monic linear factor."""

    var integer_root: Int
    var factor_degree: Int
    var quotient_degree: Int
    var remainder_zero: Bool
    var recomposition_exact: Bool
    var root_simple: Bool
    var matches_residue_mod_p: Bool
    var matches_lift_mod_p2: Bool
    var rejected: Bool

    def __init__(
        out self,
        integer_root: Int,
        factor_degree: Int,
        quotient_degree: Int,
        remainder_zero: Bool,
        recomposition_exact: Bool,
        root_simple: Bool,
        matches_residue_mod_p: Bool,
        matches_lift_mod_p2: Bool,
        rejected: Bool,
    ):
        self.integer_root = integer_root
        self.factor_degree = factor_degree
        self.quotient_degree = quotient_degree
        self.remainder_zero = remainder_zero
        self.recomposition_exact = recomposition_exact
        self.root_simple = root_simple
        self.matches_residue_mod_p = matches_residue_mod_p
        self.matches_lift_mod_p2 = matches_lift_mod_p2
        self.rejected = rejected

    def accepted(self) -> Bool:
        return (
            not self.rejected and self.factor_degree == 1 and
            self.remainder_zero and self.recomposition_exact and
            self.root_simple and self.matches_residue_mod_p and
            self.matches_lift_mod_p2
        )


struct LinearDivisionResult:
    var quotient: PolyZ
    var remainder: Int

    def __init__(out self, quotient: PolyZ, remainder: Int):
        self.quotient = quotient.copy()
        self.remainder = remainder


def bridge_residue(value: Int, prime: Int) -> Int:
    var out = value % prime
    if out < 0:
        out += prime
    return out


def bounded_prime(prime: Int) -> Bool:
    try:
        return prime <= MAX_BRIDGE_PRIME and is_prime(prime)
    except:
        return False


def poly_mod(poly: PolyZ, modulus: Modulus) -> PolyFp:
    """The image of an Int-coefficient PolyZ in (Z/m)[C]."""
    var coefficients = List[Int](capacity=poly.degree + 1)
    for i in range(poly.degree + 1):
        coefficients.append(poly.coefficient(i))
    return PolyFp(modulus, coefficients^)


def eval_poly_mod(poly: PolyZ, value: Int, modulus: Int) raises -> Int:
    """poly(value) mod m; a modulus outside [2, 2^31) raises."""
    return poly_fp_eval(poly_mod(poly, Modulus(modulus)), value)


def orbit_value_mod(parameter: Int, depth: Int, prime: Int) -> Int:
    """Q_depth(parameter) mod p, stepping with the vendored census `step`,
    which is exact in UInt64 for every 2 <= p < 2^32."""
    var value = 0
    var c = bridge_residue(parameter, prime)
    for _ in range(depth):
        value = step(value, c, prime)
    return value


def reduction_commutes_through(parameter: Int, horizon: Int, prime: Int) raises -> Bool:
    for depth in range(horizon + 1):
        var polynomial_value = eval_poly_mod(critical_orbit_poly(depth), parameter, prime)
        if polynomial_value != orbit_value_mod(parameter, depth, prime):
            return False
    return True


def exact_minimal_collision_pattern(parameter: Int, ell: Int, k: Int, prime: Int) -> Bool:
    var horizon = ell + k
    for left in range(horizon + 1):
        var left_value = orbit_value_mod(parameter, left, prime)
        for right in range(left + 1, horizon + 1):
            var equal = left_value == orbit_value_mod(parameter, right, prime)
            var intended = left == ell and right == horizon
            if equal != intended:
                return False
    return True


def rejected_simple_root_certificate() -> SimpleResidueRootCertificate:
    return SimpleResidueRootCertificate(0, 0, 0, 0, False, False, False, False, True)


def verify_simple_residue_root(
    parameter: Int, ell: Int, k: Int, prime: Int
) -> SimpleResidueRootCertificate:
    if (
        not bounded_prime(prime) or ell < 0 or k < 1 or
        ell + k > MAX_BRIDGE_HORIZON
    ):
        return rejected_simple_root_certificate()

    var q_later = critical_orbit_poly(ell + k)
    var q_earlier = critical_orbit_poly(ell)
    var relation = sub(q_later, q_earlier)
    var relation_derivative = derivative(relation)
    var residue = bridge_residue(parameter, prime)
    try:
        var commutes = reduction_commutes_through(residue, ell + k, prime)
        var relation_holds = eval_poly_mod(relation, residue, prime) == 0
        var exclusions = exact_minimal_collision_pattern(residue, ell, k, prime)
        var simple = eval_poly_mod(relation_derivative, residue, prime) != 0
        return SimpleResidueRootCertificate(
            prime,
            residue,
            ell,
            k,
            commutes,
            relation_holds,
            exclusions,
            simple,
            False,
        )
    except:
        return rejected_simple_root_certificate()


def rejected_hensel_step() -> HenselStepCertificate:
    return HenselStepCertificate(0, 0, 0, 0, 0, False, False, False, False, True)


def verify_hensel_step(
    parameter: Int, ell: Int, k: Int, prime: Int
) -> HenselStepCertificate:
    """Compute and replay the unique simple-root correction modulo p^2.

    This is one finite Hensel step. It is not an infinite p-adic lift and does
    not identify a characteristic-zero factor or complex embedding.
    """
    if prime > MAX_HENSEL_PRIME or ell + k > MAX_HENSEL_HORIZON:
        return rejected_hensel_step()
    var base = verify_simple_residue_root(parameter, ell, k, prime)
    if not base.accepted():
        return rejected_hensel_step()
    var relation = sub(critical_orbit_poly(ell + k), critical_orbit_poly(ell))
    try:
        var relation_mod_p2 = poly_mod(relation, Modulus(prime * prime))
        # hensel_step refuses a non-root and a root whose derivative vanishes.
        var step = hensel_step(relation_mod_p2, base.residue, prime)
        return HenselStepCertificate(
            step.prime,
            step.base,
            step.digit,
            step.lifted,
            step.modulus,
            base.accepted(),
            step.lifted % prime == base.residue,
            poly_fp_eval(relation_mod_p2, step.lifted) == 0,
            base.derivative_nonzero,
            False,
        )
    except:
        return rejected_hensel_step()


def bounded_relation_coefficients(poly: PolyZ) -> Bool:
    for index in range(poly.degree + 1):
        var coefficient = poly.coefficient(index)
        if (
            coefficient < -MAX_LINEAR_FACTOR_COEFFICIENT_ABS or
            coefficient > MAX_LINEAR_FACTOR_COEFFICIENT_ABS
        ):
            return False
    return True


def synthetic_divide_monic_linear(poly: PolyZ, integer_root: Int) -> LinearDivisionResult:
    """Divide by C - integer_root and return (quotient, remainder)."""
    var quotient = PolyZ()
    if poly.degree < 1:
        return LinearDivisionResult(quotient^, poly.coefficient(0))
    quotient.coeffs[poly.degree - 1] = poly.coefficient(poly.degree)
    if poly.degree >= 2:
        for offset in range(poly.degree - 1):
            var index = poly.degree - 2 - offset
            quotient.coeffs[index] = (
                poly.coefficient(index + 1) +
                integer_root * quotient.coefficient(index + 1)
            )
    quotient.normalize()
    var remainder = poly.coefficient(0) + integer_root * quotient.coefficient(0)
    return LinearDivisionResult(quotient^, remainder)


def rejected_linear_factor_provenance() -> LinearFactorProvenance:
    return LinearFactorProvenance(0, 0, 0, False, False, False, False, False, True)


def verify_linear_factor_provenance(
    integer_root: Int, ell: Int, k: Int, prime: Int
) -> LinearFactorProvenance:
    """Bind a rational integral root to the modular and p^2 certificates.

    This handles only a bounded monic linear factor. It does not factor a
    general critical-relation polynomial or select a non-rational embedding.
    """
    if (
        ell < 0 or k < 1 or ell + k > MAX_LINEAR_FACTOR_HORIZON or
        integer_root < -MAX_LINEAR_FACTOR_ROOT_ABS or
        integer_root > MAX_LINEAR_FACTOR_ROOT_ABS
    ):
        return rejected_linear_factor_provenance()
    var lift = verify_hensel_step(integer_root, ell, k, prime)
    if not lift.accepted():
        return rejected_linear_factor_provenance()
    var relation = sub(critical_orbit_poly(ell + k), critical_orbit_poly(ell))
    if not bounded_relation_coefficients(relation):
        return rejected_linear_factor_provenance()
    var division = synthetic_divide_monic_linear(relation, integer_root)
    var quotient = division.quotient.copy()
    var remainder = division.remainder
    var factor = monic_linear(-integer_root)
    var recomposed = mul(factor, quotient)
    var derivative_value: Int
    try:
        derivative_value = eval_poly_mod(derivative(relation), integer_root, prime)
    except:
        return rejected_linear_factor_provenance()
    return LinearFactorProvenance(
        integer_root,
        factor.degree,
        quotient.degree,
        remainder == 0,
        equal_poly(relation, recomposed),
        derivative_value != 0,
        bridge_residue(integer_root, prime) == lift.base_residue,
        bridge_residue(integer_root, lift.modulus_squared) == lift.lifted_residue,
        False,
    )


def critical_relation_bridge_smoke() -> Bool:
    # c = -2 reduces to 3 modulo 5 and has orbit 0,3,2,2: exact type (2,1).
    # A_{2,1}(C) = C^3(C+2); the root 3 is simple modulo 5.
    var accepted = verify_simple_residue_root(-2, 2, 1, 5)
    var repeated = verify_simple_residue_root(0, 2, 1, 5)
    var composite = verify_simple_residue_root(3, 2, 1, 9)
    var wrong_type = verify_simple_residue_root(3, 1, 1, 5)
    # Q_8 has 72-bit coefficients: past Int, so horizon 8 is refused, not wrapped.
    var past_int = verify_simple_residue_root(1, 4, 4, 1009)
    var lift = verify_hensel_step(-2, 2, 1, 5)
    var refused_lift = verify_hensel_step(0, 2, 1, 5)
    var factor = verify_linear_factor_provenance(-2, 2, 1, 5)
    var false_factor = verify_linear_factor_provenance(-1, 2, 1, 5)
    return (
        accepted.accepted() and accepted.residue == 3 and
        not repeated.accepted() and repeated.relation_holds and
        not repeated.derivative_nonzero and
        not composite.accepted() and composite.rejected and
        not wrong_type.accepted() and
        past_int.rejected and
        lift.accepted() and lift.base_residue == 3 and
        lift.correction_digit == 4 and lift.lifted_residue == 23 and
        lift.modulus_squared == 25 and
        not refused_lift.accepted() and refused_lift.rejected and
        factor.accepted() and factor.integer_root == -2 and
        factor.factor_degree == 1 and factor.quotient_degree == 3 and
        not false_factor.accepted()
    )
