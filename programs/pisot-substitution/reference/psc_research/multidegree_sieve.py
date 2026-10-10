"""Exact multidegree sieve for first scattered-subword defects on 3 letters.

The multihomogeneous degree-r component of the free Lie algebra has dimension

    m(a,b,c) = (1/r) * sum_{d | gcd(a,b,c)} mu(d)
                         * (r/d)! / ((a/d)!(b/d)!(c/d)!).

For a PIP cubic with root moduli beta > 1 > A >= G > 0 and
|det M| = beta*A*G >= 1, a sorted weight a>=b>=c has full S_3-orbit spectral
maximum beta^a A^b G^c.  The PIP cone forces that maximum above beta except for
a tiny near-balanced list depending only on r mod 3.  The same list controls
the A_3 branch because an all-distinct exponent triple gives two cyclic orbits,
each containing a beta^a weight that is already strictly above beta.

This module performs only exact integer/combinatorial classification.  It does
not numerically approximate algebraic roots.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import factorial, gcd

Weight = tuple[int, int, int]


def mobius(n: int) -> int:
    """Exact Mobius function for positive integers."""
    if n < 1:
        raise ValueError("Mobius function requires n>=1")
    value = 1
    p = 2
    while p * p <= n:
        if n % p == 0:
            n //= p
            value = -value
            if n % p == 0:
                return 0
            while n % p == 0:
                n //= p
        p += 1
    if n > 1:
        value = -value
    return value


def divisors(n: int) -> tuple[int, ...]:
    if n < 1:
        raise ValueError("divisors require n>=1")
    return tuple(d for d in range(1, n + 1) if n % d == 0)


def multinomial3(a: int, b: int, c: int) -> int:
    if min(a, b, c) < 0:
        raise ValueError("multinomial exponents must be nonnegative")
    n = a + b + c
    return factorial(n) // (factorial(a) * factorial(b) * factorial(c))


def multidegree_multiplicity(weight: Weight) -> int:
    """Generalized Witt multiplicity of one ordered multidegree."""
    a, b, c = weight
    if min(weight) < 0:
        raise ValueError("multidegree entries must be nonnegative")
    r = a + b + c
    if r == 0:
        return 0
    g = gcd(gcd(a, b), c)
    # gcd(0,0,0) is the only zero case, already excluded by r>0.
    total = 0
    for d in divisors(g if g else r):
        # If some entries are zero and gcd is nonzero, ordinary divisibility
        # still applies.  When gcd(a,b,c)=0 only one entry is nonzero; then
        # Lie words in a single generator vanish in degree >1.  Handle that
        # directly instead of using divisors(r) as a fake gcd.
        if g == 0:
            break
        total += mobius(d) * multinomial3(a // d, b // d, c // d)
    if g == 0:
        return 1 if r == 1 else 0
    if total % r != 0:
        raise AssertionError("Witt multidegree numerator is not divisible by total degree")
    return total // r


def witt_dimension(rank: int, degree: int) -> int:
    """Ordinary Witt dimension in homogeneous degree `degree`."""
    if rank < 0 or degree < 1:
        raise ValueError("rank must be nonnegative and degree positive")
    total = sum(mobius(d) * rank ** (degree // d) for d in divisors(degree))
    if total % degree != 0:
        raise AssertionError("Witt dimension numerator is not divisible by degree")
    return total // degree


def sorted_weights(degree: int) -> tuple[Weight, ...]:
    """Partitions of `degree` into at most three parts, padded by zero."""
    if degree < 1:
        raise ValueError("degree must be positive")
    out: list[Weight] = []
    for a in range(degree, -1, -1):
        for b in range(min(a, degree - a), -1, -1):
            c = degree - a - b
            if c < 0 or b < c:
                continue
            weight = (a, b, c)
            if multidegree_multiplicity(weight) > 0:
                out.append(weight)
    return tuple(out)


def orbit_size(weight: Weight) -> int:
    a, b, c = weight
    if a == b == c:
        return 1
    if a == b or b == c or a == c:
        return 3
    return 6


def dimension_from_multidegrees(degree: int) -> int:
    """Recover dim Lie_degree(Q^3) from sorted multidegrees and orbit sizes."""
    return sum(
        orbit_size(weight) * multidegree_multiplicity(weight)
        for weight in sorted_weights(degree)
    )


@dataclass(frozen=True)
class CandidateFamily:
    degree: int
    weight: Weight
    label: str
    operator_type: str
    low_growth_condition: str


def candidate_families(degree: int, *, complex_pair: bool = True) -> tuple[CandidateFamily, ...]:
    """All multidegree orbit shapes not forced strictly above beta by the PIP cone.

    `complex_pair=False` means the irreducible cubic has three real roots.  The
    upper repeated family in degree 1 mod 3 is then omitted: equality there
    would require equal stable-root moduli, impossible for three distinct real
    roots of an irreducible cubic.
    """
    if degree < 2:
        return ()
    m, residue = divmod(degree, 3)
    out: list[CandidateFamily] = []
    if residue == 0:
        weight = (m, m, m)
        if multidegree_multiplicity(weight) > 0:
            out.append(CandidateFamily(
                degree, weight, "balanced_scalar", "det^m scalar",
                "|det M|^m <= beta",
            ))
    elif residue == 1:
        lower = (m + 1, m, m)
        if multidegree_multiplicity(lower) > 0:
            out.append(CandidateFamily(
                degree, lower, "standard_twist", "det^m tensor V",
                "|det M|=1 (then rho=beta)",
            ))
        if m >= 1 and complex_pair:
            upper = (m + 1, m + 1, m - 1)
            if multidegree_multiplicity(upper) > 0:
                out.append(CandidateFamily(
                    degree, upper, "pair_square", "det^(m-1) times squared Lambda^2 orbit",
                    "|det M|=1 and |alpha|=|gamma| (then rho=beta)",
                ))
    else:
        weight = (m + 1, m + 1, m)
        if multidegree_multiplicity(weight) > 0:
            out.append(CandidateFamily(
                degree, weight, "dual_twist", "det^m tensor Lambda^2(V)",
                "|det M|^m |alpha| <= 1",
            ))
    return tuple(out)


def is_forced_above_beta(weight: Weight, *, complex_pair: bool = True) -> bool:
    """Theorem-level PIP-cone exclusion for one sorted positive-multiplicity weight."""
    a, b, c = weight
    if not (a >= b >= c >= 0):
        raise ValueError("weight must be sorted a>=b>=c>=0")
    degree = a + b + c
    if degree < 2 or multidegree_multiplicity(weight) == 0:
        raise ValueError("weight must occur in free Lie degree >=2")
    return weight not in {family.weight for family in candidate_families(degree, complex_pair=complex_pair)}


def expected_candidate_weights(degree: int, *, complex_pair: bool = True) -> tuple[Weight, ...]:
    return tuple(family.weight for family in candidate_families(degree, complex_pair=complex_pair))
