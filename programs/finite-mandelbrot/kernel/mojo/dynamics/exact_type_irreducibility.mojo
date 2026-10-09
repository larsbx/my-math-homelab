# exact_type_irreducibility.mojo
#
# Irreducibility over Q of the exact-type polynomials of the critical orbit,
# certified by factor degrees modulo small primes.
#
# E_{ell,k} in Z[C] is the monic polynomial whose roots are the parameters of
# exact type (ell, k) (dynamics/critical_type_census.mojo). Over Z,
#
#   R_{ell,k} = Q_{ell+k} - Q_ell = E_{ell,k} * prod E_{mu,lambda}^{m}
#
# over the lower types mu <= ell, lambda | k, with the multiplicities m of
# multiplicities(). Every factor is monic, so the identity survives reduction
# modulo p and E_{ell,k} mod p is an exact quotient of polynomials over F_p.
#
# Certificate. At each listed prime, E mod p is squarefree with the listed
# factor degrees (distinct-degree factorization). If E = G H over Q, Gauss's
# lemma makes G and H monic in Z[C], so deg G is a subset sum of the factor
# degrees at every prime; E is irreducible when the common subset sums are
# {0, deg E}. The multiplicity read off by exact division is the true one only
# once the lower E are irreducible, so the types are certified in increasing
# order and a type is accepted only after every lower one.
#
# Each replayed pattern's linear factors are also checked against a root count.
#
# The arithmetic over F_p (exact division, gcd, distinct-degree factorization,
# root counts) is the vendored finite_polynomial.polynomial_fp, whose residues
# stay below 2^31 so no product can wrap.
#
# reference/python/polynomial/exact_type_irreducibility.py recomputes E over Z,
# the multiplicities by exact division, and every certificate with its own
# factorization; tests/test_exact_type_irreducibility.py binds the two.

from finite_polynomial import poly_fp_factor_degrees
from finite_polynomial.polynomial_fp import (
    Modulus,
    PolyFp,
    poly_fp_add,
    poly_fp_divmod,
    poly_fp_mul,
    poly_fp_root_count,
    poly_fp_sub,
    poly_fp_x,
    prime_field,
)

comptime CERTIFIED_HORIZON = 10


@fieldwise_init
struct Multiplicity(ImplicitlyCopyable):
    var ell: Int
    var k: Int
    var mu: Int
    var lam: Int
    var m: Int


@fieldwise_init
struct FactorPattern(ImplicitlyCopyable):
    var ell: Int
    var k: Int
    var prime: Int
    var degrees: String


def multiplicities() -> List[Multiplicity]:
    return [
        Multiplicity(0, 2, 0, 1, 1),
        Multiplicity(2, 1, 0, 1, 3),
        Multiplicity(0, 3, 0, 1, 1),
        Multiplicity(3, 1, 0, 1, 4),
        Multiplicity(3, 1, 2, 1, 1),
        Multiplicity(2, 2, 0, 1, 3),
        Multiplicity(2, 2, 0, 2, 2),
        Multiplicity(2, 2, 2, 1, 1),
        Multiplicity(0, 4, 0, 1, 1),
        Multiplicity(0, 4, 0, 2, 1),
        Multiplicity(4, 1, 0, 1, 5),
        Multiplicity(4, 1, 2, 1, 1),
        Multiplicity(4, 1, 3, 1, 1),
        Multiplicity(3, 2, 0, 1, 4),
        Multiplicity(3, 2, 0, 2, 3),
        Multiplicity(3, 2, 2, 1, 1),
        Multiplicity(3, 2, 3, 1, 1),
        Multiplicity(3, 2, 2, 2, 1),
        Multiplicity(2, 3, 0, 1, 3),
        Multiplicity(2, 3, 2, 1, 1),
        Multiplicity(2, 3, 0, 3, 2),
        Multiplicity(0, 5, 0, 1, 1),
        Multiplicity(5, 1, 0, 1, 6),
        Multiplicity(5, 1, 2, 1, 1),
        Multiplicity(5, 1, 3, 1, 1),
        Multiplicity(5, 1, 4, 1, 1),
        Multiplicity(4, 2, 0, 1, 5),
        Multiplicity(4, 2, 0, 2, 3),
        Multiplicity(4, 2, 2, 1, 1),
        Multiplicity(4, 2, 3, 1, 1),
        Multiplicity(4, 2, 2, 2, 1),
        Multiplicity(4, 2, 4, 1, 1),
        Multiplicity(4, 2, 3, 2, 1),
        Multiplicity(3, 3, 0, 1, 4),
        Multiplicity(3, 3, 2, 1, 1),
        Multiplicity(3, 3, 0, 3, 2),
        Multiplicity(3, 3, 3, 1, 1),
        Multiplicity(3, 3, 2, 3, 1),
        Multiplicity(2, 4, 0, 1, 3),
        Multiplicity(2, 4, 0, 2, 2),
        Multiplicity(2, 4, 2, 1, 1),
        Multiplicity(2, 4, 2, 2, 1),
        Multiplicity(2, 4, 0, 4, 2),
        Multiplicity(0, 6, 0, 1, 1),
        Multiplicity(0, 6, 0, 2, 1),
        Multiplicity(0, 6, 0, 3, 1),
        Multiplicity(6, 1, 0, 1, 7),
        Multiplicity(6, 1, 2, 1, 1),
        Multiplicity(6, 1, 3, 1, 1),
        Multiplicity(6, 1, 4, 1, 1),
        Multiplicity(6, 1, 5, 1, 1),
        Multiplicity(5, 2, 0, 1, 6),
        Multiplicity(5, 2, 0, 2, 4),
        Multiplicity(5, 2, 2, 1, 1),
        Multiplicity(5, 2, 3, 1, 1),
        Multiplicity(5, 2, 2, 2, 1),
        Multiplicity(5, 2, 4, 1, 1),
        Multiplicity(5, 2, 3, 2, 1),
        Multiplicity(5, 2, 5, 1, 1),
        Multiplicity(5, 2, 4, 2, 1),
        Multiplicity(4, 3, 0, 1, 5),
        Multiplicity(4, 3, 2, 1, 1),
        Multiplicity(4, 3, 0, 3, 3),
        Multiplicity(4, 3, 3, 1, 1),
        Multiplicity(4, 3, 4, 1, 1),
        Multiplicity(4, 3, 2, 3, 1),
        Multiplicity(4, 3, 3, 3, 1),
        Multiplicity(3, 4, 0, 1, 4),
        Multiplicity(3, 4, 0, 2, 3),
        Multiplicity(3, 4, 2, 1, 1),
        Multiplicity(3, 4, 3, 1, 1),
        Multiplicity(3, 4, 2, 2, 1),
        Multiplicity(3, 4, 0, 4, 2),
        Multiplicity(3, 4, 3, 2, 1),
        Multiplicity(3, 4, 2, 4, 1),
        Multiplicity(2, 5, 0, 1, 3),
        Multiplicity(2, 5, 2, 1, 1),
        Multiplicity(2, 5, 0, 5, 2),
        Multiplicity(0, 7, 0, 1, 1),
        Multiplicity(7, 1, 0, 1, 8),
        Multiplicity(7, 1, 2, 1, 1),
        Multiplicity(7, 1, 3, 1, 1),
        Multiplicity(7, 1, 4, 1, 1),
        Multiplicity(7, 1, 5, 1, 1),
        Multiplicity(7, 1, 6, 1, 1),
        Multiplicity(6, 2, 0, 1, 7),
        Multiplicity(6, 2, 0, 2, 4),
        Multiplicity(6, 2, 2, 1, 1),
        Multiplicity(6, 2, 3, 1, 1),
        Multiplicity(6, 2, 2, 2, 1),
        Multiplicity(6, 2, 4, 1, 1),
        Multiplicity(6, 2, 3, 2, 1),
        Multiplicity(6, 2, 5, 1, 1),
        Multiplicity(6, 2, 4, 2, 1),
        Multiplicity(6, 2, 6, 1, 1),
        Multiplicity(6, 2, 5, 2, 1),
        Multiplicity(5, 3, 0, 1, 6),
        Multiplicity(5, 3, 2, 1, 1),
        Multiplicity(5, 3, 0, 3, 3),
        Multiplicity(5, 3, 3, 1, 1),
        Multiplicity(5, 3, 4, 1, 1),
        Multiplicity(5, 3, 2, 3, 1),
        Multiplicity(5, 3, 5, 1, 1),
        Multiplicity(5, 3, 3, 3, 1),
        Multiplicity(5, 3, 4, 3, 1),
        Multiplicity(4, 4, 0, 1, 5),
        Multiplicity(4, 4, 0, 2, 3),
        Multiplicity(4, 4, 2, 1, 1),
        Multiplicity(4, 4, 3, 1, 1),
        Multiplicity(4, 4, 2, 2, 1),
        Multiplicity(4, 4, 0, 4, 2),
        Multiplicity(4, 4, 4, 1, 1),
        Multiplicity(4, 4, 3, 2, 1),
        Multiplicity(4, 4, 4, 2, 1),
        Multiplicity(4, 4, 2, 4, 1),
        Multiplicity(4, 4, 3, 4, 1),
        Multiplicity(3, 5, 0, 1, 4),
        Multiplicity(3, 5, 2, 1, 1),
        Multiplicity(3, 5, 3, 1, 1),
        Multiplicity(3, 5, 0, 5, 2),
        Multiplicity(3, 5, 2, 5, 1),
        Multiplicity(2, 6, 0, 1, 3),
        Multiplicity(2, 6, 0, 2, 2),
        Multiplicity(2, 6, 2, 1, 1),
        Multiplicity(2, 6, 0, 3, 2),
        Multiplicity(2, 6, 2, 2, 1),
        Multiplicity(2, 6, 2, 3, 1),
        Multiplicity(2, 6, 0, 6, 2),
        Multiplicity(0, 8, 0, 1, 1),
        Multiplicity(0, 8, 0, 2, 1),
        Multiplicity(0, 8, 0, 4, 1),
        Multiplicity(8, 1, 0, 1, 9),
        Multiplicity(8, 1, 2, 1, 1),
        Multiplicity(8, 1, 3, 1, 1),
        Multiplicity(8, 1, 4, 1, 1),
        Multiplicity(8, 1, 5, 1, 1),
        Multiplicity(8, 1, 6, 1, 1),
        Multiplicity(8, 1, 7, 1, 1),
        Multiplicity(7, 2, 0, 1, 8),
        Multiplicity(7, 2, 0, 2, 5),
        Multiplicity(7, 2, 2, 1, 1),
        Multiplicity(7, 2, 3, 1, 1),
        Multiplicity(7, 2, 2, 2, 1),
        Multiplicity(7, 2, 4, 1, 1),
        Multiplicity(7, 2, 3, 2, 1),
        Multiplicity(7, 2, 5, 1, 1),
        Multiplicity(7, 2, 4, 2, 1),
        Multiplicity(7, 2, 6, 1, 1),
        Multiplicity(7, 2, 5, 2, 1),
        Multiplicity(7, 2, 7, 1, 1),
        Multiplicity(7, 2, 6, 2, 1),
        Multiplicity(6, 3, 0, 1, 7),
        Multiplicity(6, 3, 2, 1, 1),
        Multiplicity(6, 3, 0, 3, 3),
        Multiplicity(6, 3, 3, 1, 1),
        Multiplicity(6, 3, 4, 1, 1),
        Multiplicity(6, 3, 2, 3, 1),
        Multiplicity(6, 3, 5, 1, 1),
        Multiplicity(6, 3, 3, 3, 1),
        Multiplicity(6, 3, 6, 1, 1),
        Multiplicity(6, 3, 4, 3, 1),
        Multiplicity(6, 3, 5, 3, 1),
        Multiplicity(5, 4, 0, 1, 6),
        Multiplicity(5, 4, 0, 2, 4),
        Multiplicity(5, 4, 2, 1, 1),
        Multiplicity(5, 4, 3, 1, 1),
        Multiplicity(5, 4, 2, 2, 1),
        Multiplicity(5, 4, 0, 4, 3),
        Multiplicity(5, 4, 4, 1, 1),
        Multiplicity(5, 4, 3, 2, 1),
        Multiplicity(5, 4, 5, 1, 1),
        Multiplicity(5, 4, 4, 2, 1),
        Multiplicity(5, 4, 2, 4, 1),
        Multiplicity(5, 4, 5, 2, 1),
        Multiplicity(5, 4, 3, 4, 1),
        Multiplicity(5, 4, 4, 4, 1),
        Multiplicity(4, 5, 0, 1, 5),
        Multiplicity(4, 5, 2, 1, 1),
        Multiplicity(4, 5, 3, 1, 1),
        Multiplicity(4, 5, 4, 1, 1),
        Multiplicity(4, 5, 0, 5, 2),
        Multiplicity(4, 5, 2, 5, 1),
        Multiplicity(4, 5, 3, 5, 1),
        Multiplicity(3, 6, 0, 1, 4),
        Multiplicity(3, 6, 0, 2, 3),
        Multiplicity(3, 6, 2, 1, 1),
        Multiplicity(3, 6, 0, 3, 2),
        Multiplicity(3, 6, 3, 1, 1),
        Multiplicity(3, 6, 2, 2, 1),
        Multiplicity(3, 6, 3, 2, 1),
        Multiplicity(3, 6, 2, 3, 1),
        Multiplicity(3, 6, 3, 3, 1),
        Multiplicity(3, 6, 0, 6, 2),
        Multiplicity(3, 6, 2, 6, 1),
        Multiplicity(2, 7, 0, 1, 3),
        Multiplicity(2, 7, 2, 1, 1),
        Multiplicity(2, 7, 0, 7, 2),
        Multiplicity(0, 9, 0, 1, 1),
        Multiplicity(0, 9, 0, 3, 1),
        Multiplicity(9, 1, 0, 1, 10),
        Multiplicity(9, 1, 2, 1, 1),
        Multiplicity(9, 1, 3, 1, 1),
        Multiplicity(9, 1, 4, 1, 1),
        Multiplicity(9, 1, 5, 1, 1),
        Multiplicity(9, 1, 6, 1, 1),
        Multiplicity(9, 1, 7, 1, 1),
        Multiplicity(9, 1, 8, 1, 1),
        Multiplicity(8, 2, 0, 1, 9),
        Multiplicity(8, 2, 0, 2, 5),
        Multiplicity(8, 2, 2, 1, 1),
        Multiplicity(8, 2, 3, 1, 1),
        Multiplicity(8, 2, 2, 2, 1),
        Multiplicity(8, 2, 4, 1, 1),
        Multiplicity(8, 2, 3, 2, 1),
        Multiplicity(8, 2, 5, 1, 1),
        Multiplicity(8, 2, 4, 2, 1),
        Multiplicity(8, 2, 6, 1, 1),
        Multiplicity(8, 2, 5, 2, 1),
        Multiplicity(8, 2, 7, 1, 1),
        Multiplicity(8, 2, 6, 2, 1),
        Multiplicity(8, 2, 8, 1, 1),
        Multiplicity(8, 2, 7, 2, 1),
        Multiplicity(7, 3, 0, 1, 8),
        Multiplicity(7, 3, 2, 1, 1),
        Multiplicity(7, 3, 0, 3, 4),
        Multiplicity(7, 3, 3, 1, 1),
        Multiplicity(7, 3, 4, 1, 1),
        Multiplicity(7, 3, 2, 3, 1),
        Multiplicity(7, 3, 5, 1, 1),
        Multiplicity(7, 3, 3, 3, 1),
        Multiplicity(7, 3, 6, 1, 1),
        Multiplicity(7, 3, 4, 3, 1),
        Multiplicity(7, 3, 7, 1, 1),
        Multiplicity(7, 3, 5, 3, 1),
        Multiplicity(7, 3, 6, 3, 1),
        Multiplicity(6, 4, 0, 1, 7),
        Multiplicity(6, 4, 0, 2, 4),
        Multiplicity(6, 4, 2, 1, 1),
        Multiplicity(6, 4, 3, 1, 1),
        Multiplicity(6, 4, 2, 2, 1),
        Multiplicity(6, 4, 0, 4, 3),
        Multiplicity(6, 4, 4, 1, 1),
        Multiplicity(6, 4, 3, 2, 1),
        Multiplicity(6, 4, 5, 1, 1),
        Multiplicity(6, 4, 4, 2, 1),
        Multiplicity(6, 4, 2, 4, 1),
        Multiplicity(6, 4, 6, 1, 1),
        Multiplicity(6, 4, 5, 2, 1),
        Multiplicity(6, 4, 3, 4, 1),
        Multiplicity(6, 4, 6, 2, 1),
        Multiplicity(6, 4, 4, 4, 1),
        Multiplicity(6, 4, 5, 4, 1),
        Multiplicity(5, 5, 0, 1, 6),
        Multiplicity(5, 5, 2, 1, 1),
        Multiplicity(5, 5, 3, 1, 1),
        Multiplicity(5, 5, 4, 1, 1),
        Multiplicity(5, 5, 0, 5, 2),
        Multiplicity(5, 5, 5, 1, 1),
        Multiplicity(5, 5, 2, 5, 1),
        Multiplicity(5, 5, 3, 5, 1),
        Multiplicity(5, 5, 4, 5, 1),
        Multiplicity(4, 6, 0, 1, 5),
        Multiplicity(4, 6, 0, 2, 3),
        Multiplicity(4, 6, 2, 1, 1),
        Multiplicity(4, 6, 0, 3, 3),
        Multiplicity(4, 6, 3, 1, 1),
        Multiplicity(4, 6, 2, 2, 1),
        Multiplicity(4, 6, 4, 1, 1),
        Multiplicity(4, 6, 3, 2, 1),
        Multiplicity(4, 6, 2, 3, 1),
        Multiplicity(4, 6, 4, 2, 1),
        Multiplicity(4, 6, 3, 3, 1),
        Multiplicity(4, 6, 0, 6, 2),
        Multiplicity(4, 6, 4, 3, 1),
        Multiplicity(4, 6, 2, 6, 1),
        Multiplicity(4, 6, 3, 6, 1),
        Multiplicity(3, 7, 0, 1, 4),
        Multiplicity(3, 7, 2, 1, 1),
        Multiplicity(3, 7, 3, 1, 1),
        Multiplicity(3, 7, 0, 7, 2),
        Multiplicity(3, 7, 2, 7, 1),
        Multiplicity(2, 8, 0, 1, 3),
        Multiplicity(2, 8, 0, 2, 2),
        Multiplicity(2, 8, 2, 1, 1),
        Multiplicity(2, 8, 2, 2, 1),
        Multiplicity(2, 8, 0, 4, 2),
        Multiplicity(2, 8, 2, 4, 1),
        Multiplicity(2, 8, 0, 8, 2),
        Multiplicity(0, 10, 0, 1, 1),
        Multiplicity(0, 10, 0, 2, 1),
        Multiplicity(0, 10, 0, 5, 1),
    ]


def certificates() -> List[FactorPattern]:
    return [
        FactorPattern(0, 3, 3, "3"),
        FactorPattern(3, 1, 3, "3"),
        FactorPattern(2, 2, 3, "2"),
        FactorPattern(0, 4, 3, "6"),
        FactorPattern(4, 1, 3, "2 5"),
        FactorPattern(4, 1, 5, "3 4"),
        FactorPattern(3, 2, 3, "3"),
        FactorPattern(2, 3, 3, "1 5"),
        FactorPattern(2, 3, 5, "6"),
        FactorPattern(0, 5, 3, "5 10"),
        FactorPattern(0, 5, 5, "2 13"),
        FactorPattern(5, 1, 3, "15"),
        FactorPattern(4, 2, 3, "3 5"),
        FactorPattern(4, 2, 5, "8"),
        FactorPattern(3, 3, 3, "2 10"),
        FactorPattern(3, 3, 7, "3 9"),
        FactorPattern(2, 4, 3, "3 9"),
        FactorPattern(2, 4, 7, "12"),
        FactorPattern(0, 6, 3, "6 8 13"),
        FactorPattern(0, 6, 5, "6 10 11"),
        FactorPattern(0, 6, 7, "2 3 22"),
        FactorPattern(6, 1, 3, "10 21"),
        FactorPattern(6, 1, 7, "4 12 15"),
        FactorPattern(5, 2, 3, "4 5 6"),
        FactorPattern(5, 2, 5, "3 12"),
        FactorPattern(4, 3, 3, "4 17"),
        FactorPattern(4, 3, 5, "8 13"),
        FactorPattern(3, 4, 3, "10 14"),
        FactorPattern(3, 4, 7, "1 23"),
        FactorPattern(2, 5, 3, "7 23"),
        FactorPattern(2, 5, 11, "1 3 26"),
        FactorPattern(0, 7, 3, "13 50"),
        FactorPattern(0, 7, 5, "11 19 33"),
        FactorPattern(7, 1, 3, "7 15 41"),
        FactorPattern(7, 1, 5, "2 3 58"),
        FactorPattern(6, 2, 3, "16 16"),
        FactorPattern(6, 2, 5, "2 8 9 13"),
        FactorPattern(5, 3, 3, "3 9 11 25"),
        FactorPattern(5, 3, 7, "6 42"),
        FactorPattern(4, 4, 3, "11 37"),
        FactorPattern(4, 4, 5, "48"),
        FactorPattern(3, 5, 3, "13 14 33"),
        FactorPattern(3, 5, 5, "7 7 12 17 17"),
        FactorPattern(3, 5, 7, "60"),
        FactorPattern(2, 6, 3, "54"),
        FactorPattern(0, 8, 3, "22 48 50"),
        FactorPattern(0, 8, 5, "29 91"),
        FactorPattern(8, 1, 3, "9 11 21 86"),
        FactorPattern(8, 1, 5, "3 5 7 9 103"),
        FactorPattern(8, 1, 7, "2 23 41 61"),
        FactorPattern(7, 2, 3, "6 7 21 29"),
        FactorPattern(7, 2, 5, "3 28 32"),
        FactorPattern(7, 2, 11, "4 18 41"),
        FactorPattern(6, 3, 3, "16 18 62"),
        FactorPattern(6, 3, 5, "5 91"),
        FactorPattern(5, 4, 3, "4 8 12 14 52"),
        FactorPattern(5, 4, 5, "2 3 3 6 76"),
        FactorPattern(5, 4, 7, "3 5 11 13 58"),
        FactorPattern(5, 4, 11, "2 3 12 17 23 33"),
        FactorPattern(5, 4, 13, "2 39 49"),
        FactorPattern(4, 5, 3, "5 29 86"),
        FactorPattern(4, 5, 7, "4 5 17 18 20 23 33"),
        FactorPattern(4, 5, 13, "2 5 51 62"),
        FactorPattern(4, 5, 17, "1 6 8 105"),
        FactorPattern(3, 6, 3, "18 19 71"),
        FactorPattern(3, 6, 5, "20 20 68"),
        FactorPattern(2, 7, 3, "3 32 40 51"),
        FactorPattern(2, 7, 5, "4 15 107"),
        FactorPattern(0, 9, 3, "6 8 34 204"),
        FactorPattern(0, 9, 5, "13 86 153"),
        FactorPattern(9, 1, 3, "5 12 21 30 187"),
        FactorPattern(9, 1, 5, "11 17 227"),
        FactorPattern(9, 1, 19, "3 3 7 15 81 146"),
        FactorPattern(8, 2, 3, "4 11 13 42 58"),
        FactorPattern(8, 2, 5, "6 8 17 34 63"),
        FactorPattern(8, 2, 7, "2 3 10 38 75"),
        FactorPattern(7, 3, 3, "24 53 112"),
        FactorPattern(7, 3, 5, "53 65 71"),
        FactorPattern(7, 3, 7, "10 23 45 111"),
        FactorPattern(6, 4, 3, "7 28 65 92"),
        FactorPattern(6, 4, 5, "4 5 7 176"),
        FactorPattern(6, 4, 13, "4 6 23 24 26 109"),
        FactorPattern(5, 5, 3, "4 236"),
        FactorPattern(5, 5, 7, "3 3 6 38 46 144"),
        FactorPattern(4, 6, 3, "4 12 200"),
        FactorPattern(4, 6, 5, "7 209"),
        FactorPattern(3, 7, 3, "9 59 184"),
        FactorPattern(3, 7, 5, "3 3 4 10 33 199"),
        FactorPattern(2, 8, 3, "5 30 205"),
        FactorPattern(2, 8, 5, "1 2 7 8 222"),
        FactorPattern(0, 10, 3, "16 479"),
        FactorPattern(0, 10, 5, "8 18 68 170 231"),
    ]




def critical_polys_mod_p(horizon: Int, field: Modulus) raises -> List[PolyFp]:
    """Q_0, ..., Q_horizon mod p."""
    var x = poly_fp_x(field)
    var out: List[PolyFp] = [PolyFp(field, [])]
    for _ in range(horizon):
        var q = out[len(out) - 1].copy()
        out.append(poly_fp_add(poly_fp_mul(q, q), x))
    return out^


struct ExactTypes(Movable):
    """Every E_{ell,k} mod p with ell + k <= horizon, each the exact quotient of
    R_{ell,k} by the lower types already in the table."""

    var prime: Int
    var horizon: Int
    var polys: List[PolyFp]

    def __init__(out self, prime: Int, horizon: Int) raises:
        var field = prime_field(prime)
        self.prime = prime
        self.horizon = horizon
        self.polys = List[PolyFp](length=(horizon + 1) * (horizon + 1), fill=PolyFp(field, []))
        var q = critical_polys_mod_p(horizon, field)
        var rows = multiplicities()
        for h in range(1, horizon + 1):
            for k in range(1, h + 1):
                var ell = h - k
                if ell == 1:
                    continue
                var rest = poly_fp_sub(q[h], q[ell])
                for row in rows:
                    if row.ell == ell and row.k == k:
                        for _ in range(row.m):
                            var qr = poly_fp_divmod(rest, self.polys[self.slot(row.mu, row.lam)])
                            if not qr.remainder.is_zero():
                                raise Error("inexact division of R_" + String(ell) + "," + String(k))
                            rest = qr.quotient.copy()
                self.polys[self.slot(ell, k)] = rest^

    def slot(self, ell: Int, k: Int) -> Int:
        return ell * (self.horizon + 1) + k

    def at(self, ell: Int, k: Int) -> PolyFp:
        return self.polys[self.slot(ell, k)].copy()


def exact_type_mod_p(ell: Int, k: Int, p: Int) raises -> PolyFp:
    """E_{ell,k} mod p as the exact quotient of R_{ell,k}; raises if a division is not exact."""
    return ExactTypes(p, ell + k).at(ell, k)


def parse_degrees(s: String) raises -> List[Int]:
    var out = List[Int]()
    for part in s.split(" "):
        out.append(Int(String(part)))
    return out^


def forces_irreducible(degree: Int, patterns: List[List[Int]]) -> Bool:
    """True iff the only subset sums common to every factor-degree pattern are 0 and degree."""
    var common = List[Bool](length=degree + 1, fill=True)
    for degrees in patterns:
        var reach = List[Bool](length=degree + 1, fill=False)
        reach[0] = True
        var total = 0
        for d in degrees:
            total += d
            for s in range(degree, d - 1, -1):
                if reach[s - d]:
                    reach[s] = True
        if total != degree:
            return False
        for s in range(degree + 1):
            common[s] = common[s] and reach[s]
    for s in range(1, degree):
        if common[s]:
            return False
    return True


def linear_factors(degrees: List[Int]) -> Int:
    var n = 0
    for d in degrees:
        if d == 1:
            n += 1
    return n


def certified_irreducible(
    ell: Int, k: Int, patterns: List[FactorPattern], tables: List[ExactTypes]
) raises -> Bool:
    """Replays the listed factor patterns of E_{ell,k}; True iff they force irreducibility."""
    var degree = tables[0].at(ell, k).degree()
    var replayed = List[List[Int]]()
    for row in patterns:
        if row.ell != ell or row.k != k:
            continue
        var found = False
        for t in range(len(tables)):
            if tables[t].prime == row.prime:
                found = True
                var f = tables[t].at(ell, k)
                if f.degree() != degree:
                    return False
                var degrees = poly_fp_factor_degrees(f)
                var claimed = parse_degrees(row.degrees)
                if len(degrees) != len(claimed):
                    return False
                for i in range(len(degrees)):
                    if degrees[i] != claimed[i]:
                        return False
                if linear_factors(degrees) != poly_fp_root_count(f):
                    return False
                replayed.append(degrees^)
        if not found:
            return False
    return forces_irreducible(degree, replayed)


def all_types_certified(patterns: List[FactorPattern]) raises -> Bool:
    """Every exact type with ell + k <= CERTIFIED_HORIZON, in increasing order."""
    var tables = List[ExactTypes]()
    tables.append(ExactTypes(3, CERTIFIED_HORIZON))
    for row in patterns:
        var seen = False
        for t in range(len(tables)):
            seen = seen or tables[t].prime == row.prime
        if not seen:
            tables.append(ExactTypes(row.prime, CERTIFIED_HORIZON))
    for horizon in range(1, CERTIFIED_HORIZON + 1):
        for k in range(1, horizon + 1):
            var ell = horizon - k
            if ell != 1 and not certified_irreducible(ell, k, patterns, tables):
                return False
    return True


def exact_type_irreducibility_smoke() -> Bool:
    try:
        if not all_types_certified(certificates()):
            return False
        # A product of two exact-type polynomials must never certify.
        var product_patterns = List[List[Int]]()
        for p in [3, 5, 7, 11, 13, 17, 19, 23]:
            var product = poly_fp_mul(exact_type_mod_p(0, 3, p), exact_type_mod_p(3, 1, p))
            try:
                product_patterns.append(poly_fp_factor_degrees(product))
            except:
                pass
        if len(product_patterns) < 3 or forces_irreducible(6, product_patterns):
            return False
        return True
    except:
        return False
