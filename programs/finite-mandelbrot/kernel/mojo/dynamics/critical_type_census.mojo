# critical_type_census.mojo
#
# The exact critical-orbit type modulo p, read from the vendored
# `finite_field_orbit` census (contract orbit-census-v1, pinned in
# vendored.toml), and the modular obstruction it yields.
#
# Write z_0 = 0, z_{n+1} = z_n^2 + c.  The type of c modulo p is (mu, lambda):
# z_{mu+lambda} is the first term equal to an earlier one, and z_mu is that
# earlier term.  The single-seed census block (p, c mod p, cap, 0, 1) answers it
# exactly, resolved iff mu + lambda <= cap.
#
# Obstruction.  If c is an integer whose critical orbit has exact type
# (ell, k) over Q, then z_{ell+k} = z_ell, so z_{ell+k} = z_ell modulo every
# p, and that holds iff mu <= ell and lambda divides k.  One prime where it
# fails excludes the type (ell, k) for c.  The converse does not hold: a type
# unobstructed at every prime tried is not thereby the exact type over Q.
#
# The bounded bridge check `exact_minimal_collision_pattern(c, ell, k, p)`
# says the same thing as "the type modulo p is (ell, k)"; the smoke below
# checks that equivalence, and the obstruction against direct iteration, on
# every residue of the small primes through horizon PATTERN_HORIZON.
#
# Simple residue roots without polynomials.  `verify_simple_residue_root`
# materializes Q_n in Int coefficients, which caps it at horizon 7 and
# p <= 2^20.  Every value its certificate needs is also a value of the B0
# recurrence, and reduction modulo p is a ring map, so iteration in F_p
# computes it exactly:
#
#   Q_{n+1}(c)  = Q_n(c)^2 + c
#   Q'_{n+1}(c) = 2 Q_n(c) Q'_n(c) + 1     (an identity in Z[C])
#
# `verify_simple_residue_root_by_census` evaluates R_{ell,k} = Q_{ell+k} - Q_ell
# and R' this way in 64-bit words, and takes the exclusions from the census
# type, for every prime p < 2^32 and horizon below the census cap 2^32.  It
# issues the same certificate; `reduction_commutes` holds by construction,
# since no polynomial is reduced.  The smoke checks it field by field against
# the polynomial verifier on that verifier's whole exact domain for the small
# primes; tests/test_critical_relation_census.py checks the golden vectors
# past both old bounds against exact big-integer polynomials in Python.

from finite_field_orbit.census import Block, census, step
from dynamics.critical_relation_bridge import (
    MAX_BRIDGE_HORIZON,
    SimpleResidueRootCertificate,
    bridge_residue,
    exact_minimal_collision_pattern,
    orbit_value_mod,
    rejected_simple_root_certificate,
    verify_simple_residue_root,
)

comptime PATTERN_HORIZON = 8
comptime CENSUS_BOUND = 4294967296


@fieldwise_init
struct CriticalType(ImplicitlyCopyable):
    var resolved: Bool
    var mu: Int
    var period: Int

    def equals(self, ell: Int, k: Int) -> Bool:
        return self.resolved and self.mu == ell and self.period == k


def critical_type_mod_p(parameter: Int, prime: Int, cap: Int) raises -> CriticalType:
    """The census of seed 0; raises the contract's refusal for a malformed block."""
    var a = census(Block(prime, bridge_residue(parameter, prime), cap, 0, 1))
    return CriticalType(a.resolved == 1, a.w_mu, a.w_lambda)


def type_obstructed_mod_p(parameter: Int, ell: Int, k: Int, prime: Int) raises -> Bool:
    """True iff p excludes exact type (ell, k), k >= 1, for the integer parameter."""
    var t = critical_type_mod_p(parameter, prime, ell + k)
    return not (t.resolved and t.mu <= ell and k % t.period == 0)


def relation_values_mod_p(parameter: Int, ell: Int, k: Int, prime: Int) -> Tuple[Int, Int]:
    """(R(c), R'(c)) mod p for R = Q_{ell+k} - Q_ell, by the B0 recurrence; p < 2^32."""
    var c = bridge_residue(parameter, prime)
    var z = 0
    var d = 0
    var z_ell = 0
    var d_ell = 0
    for n in range(ell + k):
        if n == ell:
            z_ell = z
            d_ell = d
        d = Int((UInt64(2 * z % prime) * UInt64(d) + 1) % UInt64(prime))
        z = step(z, c, prime)
    return (bridge_residue(z - z_ell, prime), bridge_residue(d - d_ell, prime))


def verify_simple_residue_root_by_census(
    parameter: Int, ell: Int, k: Int, prime: Int
) -> SimpleResidueRootCertificate:
    if ell < 0 or k < 1 or ell + k >= CENSUS_BOUND or prime < 2 or prime >= CENSUS_BOUND:
        return rejected_simple_root_certificate()
    try:
        var t = critical_type_mod_p(parameter, prime, ell + k)
        var values = relation_values_mod_p(parameter, ell, k, prime)
        return SimpleResidueRootCertificate(
            prime,
            bridge_residue(parameter, prime),
            ell,
            k,
            True,
            values[0] == 0,
            t.equals(ell, k),
            values[1] != 0,
            False,
        )
    except:
        return rejected_simple_root_certificate()


@fieldwise_init
struct Golden(ImplicitlyCopyable):
    """A certificate past the polynomial bounds; tests/test_critical_relation_census.py
    recomputes every field from exact big-integer polynomials."""

    var parameter: Int
    var ell: Int
    var k: Int
    var prime: Int
    var relation_holds: Bool
    var exclusions_hold: Bool
    var derivative_nonzero: Bool


def golden_certificates() -> List[Golden]:
    return [
        Golden(137462, 4, 5, 1048583, True, True, True),
        Golden(247423, 3, 6, 1048583, True, True, True),
        Golden(6268, 2, 8, 1048583, True, True, True),
        Golden(16992, 9, 1, 1048583, True, True, True),
        Golden(1047843, 9, 3, 16777259, True, True, True),
        Golden(3503477, 8, 4, 16777259, True, True, True),
        Golden(-2, 2, 1, 4294967291, True, True, True),
        Golden(-1, 0, 2, 4294967291, True, True, True),
        Golden(0, 2, 1, 4294967291, True, False, False),
        Golden(-2, 1, 1, 4294967291, False, False, True),
        Golden(12345, 5, 7, 4294967291, False, False, True),
    ]


def same_verdicts(a: SimpleResidueRootCertificate, b: SimpleResidueRootCertificate) -> Bool:
    return (
        a.rejected == b.rejected and a.residue == b.residue and
        a.relation_holds == b.relation_holds and
        a.exact_type_exclusions_hold == b.exact_type_exclusions_hold and
        a.derivative_nonzero == b.derivative_nonzero and
        a.accepted() == b.accepted()
    )


def census_bridge_agrees_with_the_polynomial_bridge() -> Bool:
    for prime in [2, 3, 5, 7, 11, 13, 101]:
        for c in range(prime):
            for horizon in range(1, MAX_BRIDGE_HORIZON + 1):
                for k in range(1, horizon + 1):
                    var ell = horizon - k
                    var by_poly = verify_simple_residue_root(c, ell, k, prime)
                    if not by_poly.reduction_commutes or not same_verdicts(
                        by_poly, verify_simple_residue_root_by_census(c, ell, k, prime)
                    ):
                        return False
    for g in golden_certificates():
        var cert = verify_simple_residue_root_by_census(g.parameter, g.ell, g.k, g.prime)
        if (
            cert.rejected or not cert.reduction_commutes or
            cert.relation_holds != g.relation_holds or
            cert.exact_type_exclusions_hold != g.exclusions_hold or
            cert.derivative_nonzero != g.derivative_nonzero
        ):
            return False
    var refused = [
        verify_simple_residue_root_by_census(5, 2, 1, 9),
        verify_simple_residue_root_by_census(5, 2, 1, CENSUS_BOUND + 15),
        verify_simple_residue_root_by_census(5, 2, 0, 7),
        verify_simple_residue_root_by_census(5, -1, 2, 7),
    ]
    for cert in refused:
        if not cert.rejected or cert.accepted():
            return False
    return True


def refusal(parameter: Int, prime: Int, cap: Int) -> String:
    """The contract's refusal for the request, or "" when it is answered."""
    try:
        _ = critical_type_mod_p(parameter, prime, cap)
        return ""
    except e:
        return String(e)


def census_agrees_with_the_bridge() raises -> Bool:
    # c = -2 has orbit 0, -2, 2, 2: exact type (2, 1), unobstructed at every p.
    # c = 1 has orbit 0, 1, 2, 5, ...; modulo 2 it is 0, 1, 0, so (2, 1) fails.
    for prime in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
        if type_obstructed_mod_p(-2, 2, 1, prime):
            return False
        for c in range(prime):
            for horizon in range(1, PATTERN_HORIZON + 1):
                var t = critical_type_mod_p(c, prime, horizon)
                for k in range(1, horizon + 1):
                    var ell = horizon - k
                    if t.equals(ell, k) != exact_minimal_collision_pattern(c, ell, k, prime):
                        return False
                    var returns = orbit_value_mod(c, horizon, prime) == orbit_value_mod(c, ell, prime)
                    if type_obstructed_mod_p(c, ell, k, prime) == returns:
                        return False
    for prime in [0, -7, 1, 9]:
        if refusal(5, prime, 3) != "malformed:p":
            return False
    return type_obstructed_mod_p(1, 2, 1, 2) and not type_obstructed_mod_p(-1, 0, 2, 1048573)


def critical_type_census_smoke() -> Bool:
    try:
        return census_agrees_with_the_bridge() and census_bridge_agrees_with_the_polynomial_bridge()
    except:
        return False
