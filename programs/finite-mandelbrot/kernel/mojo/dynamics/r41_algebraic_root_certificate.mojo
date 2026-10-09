# r41_algebraic_root_certificate.mojo
#
# Algebraic certification of the non-rational factors of A_{4,1}.
#
# Reduction modulo 5 is used only as an exact coprimality witness:
# if two primitive integer polynomials have gcd 1 after reduction, then their
# characteristic-zero gcd is 1.  This proves squarefreeness and excludes every
# unintended collision without selecting numerical or complex embeddings.

from polynomial.poly_z import (
    PolyZ,
    add,
    constant,
    critical_orbit_poly,
    derivative,
    expected_F7_M41,
    mul,
    raw_return_poly,
    sub,
)
from dynamics.critical_relation_bridge import bounded_prime, poly_mod
from finite_polynomial.polynomial_fp import PolyFp, poly_fp_gcd, poly_fp_rem, prime_field


def r41_cubic_factor() -> PolyZ:
    var cubic = PolyZ()
    cubic.coeffs[0] = 2
    cubic.coeffs[1] = 2
    cubic.coeffs[2] = 2
    cubic.coeffs[3] = 1
    cubic.normalize()
    return cubic^


def reduce_poly_mod_prime(poly: PolyZ, prime: Int) raises -> PolyFp:
    """The image of poly in F_p[C]; a prime past the bridge bound raises."""
    if not bounded_prime(prime):
        raise Error("not a bounded prime: " + String(prime))
    return poly_mod(poly, prime_field(prime))


def remainder_mod_prime(
    dividend: PolyZ, divisor: PolyZ, prime: Int
) raises -> PolyFp:
    return poly_fp_rem(
        reduce_poly_mod_prime(dividend, prime),
        reduce_poly_mod_prime(divisor, prime),
    )


def remainder_monic_over_integers(
    dividend: PolyZ, divisor: PolyZ
) -> PolyZ:
    # Exact long division in Z[C].  The certified factors are monic, so every
    # quotient coefficient is integral and no modular reduction is involved.
    var remainder = dividend.copy()
    if divisor.is_zero() or divisor.coefficient(divisor.degree) != 1:
        return remainder^
    while not remainder.is_zero() and remainder.degree >= divisor.degree:
        var shift = remainder.degree - divisor.degree
        var scale = remainder.coefficient(remainder.degree)
        for i in range(divisor.degree + 1):
            var index = i + shift
            remainder.coeffs[index] = (
                remainder.coefficient(index) -
                scale * divisor.coefficient(i)
            )
        remainder.normalize()
    return remainder^

def gcd_degree_mod_prime(a: PolyZ, b: PolyZ, prime: Int) -> Int:
    """deg gcd(a mod p, b mod p); -1 for a refused prime or when both vanish."""
    try:
        return poly_fp_gcd(
            reduce_poly_mod_prime(a, prime), reduce_poly_mod_prime(b, prime),
        ).degree()
    except:
        return -1


def factor_is_squarefree_mod_prime(factor: PolyZ, prime: Int) -> Bool:
    return gcd_degree_mod_prime(factor, derivative(factor), prime) == 0


def factor_excludes_all_unintended_collisions(
    factor: PolyZ, ell: Int, period: Int, prime: Int
) -> Bool:
    var horizon = ell + period
    for left in range(horizon + 1):
        for right in range(left + 1, horizon + 1):
            if left == ell and right == horizon:
                continue
            var collision = sub(
                critical_orbit_poly(right),
                critical_orbit_poly(left),
            )
            if gcd_degree_mod_prime(factor, collision, prime) != 0:
                return False
    return True


struct R41AlgebraicRootCertificate(ImplicitlyCopyable):
    var witness_prime: Int
    var cubic_squarefree: Bool
    var f7_squarefree: Bool
    var factors_coprime: Bool
    var cubic_is_lower_type: Bool
    var f7_divides_relation: Bool
    var f7_unintended_collisions_excluded: Bool
    var exact_type_root_count: Int
    var embeddings_selected: Bool
    var localization_supplied: Bool
    var rejected: Bool

    def __init__(
        out self,
        witness_prime: Int,
        cubic_squarefree: Bool,
        f7_squarefree: Bool,
        factors_coprime: Bool,
        cubic_is_lower_type: Bool,
        f7_divides_relation: Bool,
        f7_unintended_collisions_excluded: Bool,
        exact_type_root_count: Int,
        embeddings_selected: Bool,
        localization_supplied: Bool,
        rejected: Bool,
    ):
        self.witness_prime = witness_prime
        self.cubic_squarefree = cubic_squarefree
        self.f7_squarefree = f7_squarefree
        self.factors_coprime = factors_coprime
        self.cubic_is_lower_type = cubic_is_lower_type
        self.f7_divides_relation = f7_divides_relation
        self.f7_unintended_collisions_excluded = (
            f7_unintended_collisions_excluded
        )
        self.exact_type_root_count = exact_type_root_count
        self.embeddings_selected = embeddings_selected
        self.localization_supplied = localization_supplied
        self.rejected = rejected

    def algebraic_exact_type_accepted(self) -> Bool:
        return (
            not self.rejected and self.witness_prime == 5 and
            self.cubic_squarefree and self.f7_squarefree and
            self.factors_coprime and self.cubic_is_lower_type and
            self.f7_divides_relation and
            self.f7_unintended_collisions_excluded and
            self.exact_type_root_count == 7
        )

    def b3_localization_accepted(self) -> Bool:
        return (
            self.algebraic_exact_type_accepted() and
            self.embeddings_selected and self.localization_supplied
        )

    def proves_density(self) -> Bool:
        return False

    def proves_equidistribution(self) -> Bool:
        return False

    def proves_c1(self) -> Bool:
        return False


def verify_r41_algebraic_roots() -> R41AlgebraicRootCertificate:
    var prime = 5
    var cubic = r41_cubic_factor()
    var f7 = expected_F7_M41()
    var relation = raw_return_poly(4, 1)
    var cubic_collision = sub(
        critical_orbit_poly(4), critical_orbit_poly(3),
    )
    return R41AlgebraicRootCertificate(
        prime,
        factor_is_squarefree_mod_prime(cubic, prime),
        factor_is_squarefree_mod_prime(f7, prime),
        gcd_degree_mod_prime(cubic, f7, prime) == 0,
        remainder_monic_over_integers(cubic_collision, cubic).is_zero(),
        remainder_monic_over_integers(relation, f7).is_zero(),
        factor_excludes_all_unintended_collisions(f7, 4, 1, prime),
        f7.degree,
        False,
        False,
        False,
    )


def r41_algebraic_root_certificate_smoke() -> Bool:
    var certificate = verify_r41_algebraic_roots()
    var cubic = r41_cubic_factor()
    var composite_refused = gcd_degree_mod_prime(
        cubic, expected_F7_M41(), 9,
    )
    # A remainder of 5 is zero modulo 5 but nonzero in Z[C].  This control
    # would have passed the former modular membership predicate.
    var false_membership = add(mul(cubic, constant(1)), constant(5))
    var modular_false_positive = False
    try:
        modular_false_positive = remainder_mod_prime(
            false_membership, cubic, 5,
        ).is_zero()
    except:
        pass
    var exact_negative_control = not remainder_monic_over_integers(
        false_membership, cubic,
    ).is_zero()
    return (
        certificate.algebraic_exact_type_accepted() and
        certificate.exact_type_root_count == 7 and
        not certificate.b3_localization_accepted() and
        composite_refused == -1 and
        modular_false_positive and exact_negative_control and
        not certificate.proves_density() and
        not certificate.proves_equidistribution() and
        not certificate.proves_c1()
    )
