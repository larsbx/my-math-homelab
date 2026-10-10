# critical_type_sieve.mojo
#
# Exact-type counts of the critical orbit over F_p.
#
#   N_p(ell, k) = #{ c in F_p : z_0 = 0 under x -> x^2 + c has type (ell, k) }
#
# with type as in dynamics/critical_type_census.mojo.  The obstruction lemma
# there becomes a counting law: c is a root of R_{ell,k} = Q_{ell+k} - Q_ell
# modulo p iff its type (mu, lambda) has mu <= ell and lambda | k, so
#
#   #{ c : R_{ell,k}(c) = 0 in F_p } = sum_{mu <= ell, lambda | k} N_p(mu, lambda).
#
# Two more exact laws: the counts and the unresolved residues partition F_p,
# and N_p(1, k) = 0 for odd p (z_{1+k} = z_1 = c forces z_k = -z_0 = 0).
#
# Reading.  N_p counts residue parameters once, with exact-type exclusions
# in F_p.  It counts the roots of the characteristic-zero exact-type polynomial
# reduced modulo p only away from the relevant discriminants AND collision
# resultants.  A sufficient exclusion is the discriminant of the squarefree
# part of R_{ell,k}; the exact-type polynomial's own discriminant is insufficient.
# Chebotarev identifies the limiting prime mean with the number of distinct
# Q-irreducible factors.  The entrypoint includes bad primes and supplies no
# finite-bound error or independent-sampling guarantee.  Its finite mean is
# research evidence, not an irreducibility, Galois-group, or C1 certificate.
#
# The tally types seed 0 with a short orbit buffer, O(horizon^2) per residue,
# rather than through the census, whose p-word table costs O(p) per call; the
# smoke checks the two agree.

from finite_field_orbit.census import step
from dynamics.critical_relation_bridge import bridge_residue, orbit_value_mod
from dynamics.critical_type_census import CriticalType, critical_type_mod_p


def critical_type_short(parameter: Int, prime: Int, cap: Int) -> CriticalType:
    """Seed 0's type when mu + lambda <= cap, else unresolved; p < 2^32."""
    var c = bridge_residue(parameter, prime)
    var orbit = List[Int](capacity=cap + 1)
    orbit.append(0)
    var z = 0
    for j in range(1, cap + 1):
        z = step(z, c, prime)
        for i in range(j):
            if orbit[i] == z:
                return CriticalType(True, i, j - i)
        orbit.append(z)
    return CriticalType(False, 0, 0)


struct TypeCounts(Movable):
    var prime: Int
    var horizon: Int
    var unresolved: Int
    var counts: List[Int]

    def __init__(out self, prime: Int, horizon: Int):
        self.prime = prime
        self.horizon = horizon
        self.unresolved = 0
        self.counts = List[Int](length=(horizon + 1) * (horizon + 1), fill=0)

    def at(self, ell: Int, k: Int) -> Int:
        return self.counts[ell * (self.horizon + 1) + k]

    def tally(mut self, t: CriticalType):
        if t.resolved:
            self.counts[t.mu * (self.horizon + 1) + t.period] += 1
        else:
            self.unresolved += 1


def type_counts(prime: Int, horizon: Int) -> TypeCounts:
    var out = TypeCounts(prime, horizon)
    for c in range(prime):
        out.tally(critical_type_short(c, prime, horizon))
    return out^


def relation_roots(prime: Int, ell: Int, k: Int) -> Int:
    var n = 0
    for c in range(prime):
        if orbit_value_mod(c, ell + k, prime) == orbit_value_mod(c, ell, prime):
            n += 1
    return n


def counts_obey_the_laws(t: TypeCounts) -> Bool:
    var total = t.unresolved
    for horizon in range(1, t.horizon + 1):
        for k in range(1, horizon + 1):
            var ell = horizon - k
            total += t.at(ell, k)
            var below = 0
            for mu in range(ell + 1):
                for lam in range(1, k + 1):
                    if k % lam == 0:
                        below += t.at(mu, lam)
            if below != relation_roots(t.prime, ell, k):
                return False
            if ell == 1 and t.prime % 2 == 1 and t.at(1, k) != 0:
                return False
    return total == t.prime


@fieldwise_init
struct GoldenCount(ImplicitlyCopyable):
    """tests/test_critical_type_sieve.py recomputes each from exact polynomials."""

    var prime: Int
    var ell: Int
    var k: Int
    var count: Int


def golden_counts() -> List[GoldenCount]:
    return [
        GoldenCount(101, 0, 3, 3),
        GoldenCount(101, 2, 2, 2),
        GoldenCount(101, 0, 5, 3),
        GoldenCount(101, 4, 2, 2),
        GoldenCount(101, 1, 4, 0),
        GoldenCount(101, 0, 6, 1),
        GoldenCount(1009, 0, 3, 1),
        GoldenCount(1009, 0, 4, 3),
        GoldenCount(1009, 0, 5, 2),
        GoldenCount(1009, 3, 3, 0),
        GoldenCount(1009, 2, 4, 1),
    ]


def critical_type_sieve_smoke() -> Bool:
    try:
        for prime in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
            for c in range(prime):
                for cap in range(9):
                    var a = critical_type_short(c, prime, cap)
                    var b = critical_type_mod_p(c, prime, cap)
                    if a.resolved != b.resolved or (a.resolved and (a.mu != b.mu or a.period != b.period)):
                        return False
        for prime in [2, 3, 5, 7, 13, 101, 1009]:
            if not counts_obey_the_laws(type_counts(prime, 8)):
                return False
        var t101 = type_counts(101, 6)
        var t1009 = type_counts(1009, 6)
        for g in golden_counts():
            var got = t101.at(g.ell, g.k) if g.prime == 101 else t1009.at(g.ell, g.k)
            if got != g.count:
                return False
        # C^2+1 has roots 2 and 3 mod 5, but 3=-2 has lower type (2,1).
        var t5 = type_counts(5, 4)
        return (
            t1009.at(0, 1) == 1 and t1009.at(0, 2) == 1 and t1009.at(2, 1) == 1
            and t5.at(2, 2) == 1 and t5.at(2, 1) == 1
        )
    except:
        return False
