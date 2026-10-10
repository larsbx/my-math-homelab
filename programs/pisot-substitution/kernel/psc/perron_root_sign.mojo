"""The sign of a cubic element at the Perron root, over unbounded rationals.

`psc.perron_field3.sign_at_perron` answers this question in machine integers by
Sturm--Tarski counting: exact, and fast enough to be asked tens of millions of
times in one census. It is also bounded -- the terminal resultant of its
signed-remainder chain is a cubic form in quantities linear in the
coefficients, so it leaves `Int` once they reach roughly `2 * 10^6`. This
module answers the same question with no coefficient bound at all, so that the
fixed-width oracle has something to hand a question to rather than refusing it.

`beta` is bracketed between consecutive integers and then bisected; the answer
is read off the natural interval extension of `Q` over the bracket, and is
returned only when that enclosure excludes zero. Nothing here is an estimate:
a bracket that has not yet separated returns no sign, it does not guess one.

The bisection terminates, and the depth it needs is known in advance. `chi` is
irreducible of degree three and `deg Q <= 2`, so `Q(beta) != 0` and

    Res(chi, Q) = prod_i Q(beta_i)

is a nonzero integer, hence at least one in absolute value. `beta` is Pisot, so
its two conjugates lie in the open unit disc and `|Q(beta_i)| <= 3H` for
`H = max |a_i|`. Therefore

    |Q(beta)| >= 1 / (9 H^2).                                             (*)

The initial bracket has width at most one, so `k` bisections leave width
`2^-k`, over which the natural Horner extension of `Q` has width at most
`3 H B 2^-k` with `B = max |chi_i| + 1`. Any `k` with `2^k > 27 H^3 B` makes
that smaller than the separation (*), and an interval of width below `|Q(beta)|`
that contains `Q(beta)` cannot contain zero. `_sufficient_refinements` returns
such a `k`. Reaching it without a strict sign is a defect in this reasoning or
in the field it was handed, not an inconclusive answer, and raises.
"""

from finite_exact.closed_interval import IQ
from finite_exact.rat_q import Q
from psc.exact import (
    eval_int_poly_at_q,
    interval_horner_int,
    midpoint,
    q_int,
    q_sign,
    require_iq,
    strict_sign,
)


comptime BRACKET_BOUND = 1 << 20
"""Where the integer bracketing refuses rather than enumerating.

The initial bracket walks the integers of `(1, B]`, so `B` sets its cost. The
cubics this kernel forms come from incidence matrices with entries at most
three, putting `B` under thirty; a field far outside that is malformed, and
scanning towards it would be a hang rather than an answer."""


comptime FIRST_REFINEMENT = 24
"""Where the escalation starts, before the proved budget is needed.

Every coefficient a census actually produces separates long before this, so
the common fallback costs one bracketing and no doubling at all."""


def _bit_length(n: Int) -> Int:
    if n == Int.MIN:
        return 64
    var m = -n if n < 0 else n
    var bits = 0
    while m > 0:
        bits += 1
        m = m >> 1
    return bits


def _magnitude(a0: Int, a1: Int, a2: Int) -> Int:
    """`bit_length(max |a_i|)`, which is all the bound below needs of `H`."""
    var bits = _bit_length(a0)
    var t = _bit_length(a1)
    if t > bits:
        bits = t
    t = _bit_length(a2)
    if t > bits:
        bits = t
    return bits


def _perron_bound(chi0: Int, chi1: Int, chi2: Int) -> Int:
    """`max |chi_i| + 1`, the Cauchy bound; every root is strictly inside it."""
    var bits = _bit_length(chi0)
    var t = _bit_length(chi1)
    if t > bits:
        bits = t
    t = _bit_length(chi2)
    if t > bits:
        bits = t
    return bits


def _sufficient_refinements(
    chi0: Int, chi1: Int, chi2: Int, a0: Int, a1: Int, a2: Int
) -> Int:
    """A bisection depth `k` with `2^k > 27 H^3 B`, from the bit lengths alone.

    `27 < 2^5`, `H < 2^bits(H)` and `B <= 2^(bits(max |chi_i|) + 1)`, so
    `5 + 3 bits(H) + bits(max |chi_i|) + 1` is such a `k`. Working in bit
    lengths keeps the budget itself free of the overflow it exists to avoid."""
    return 6 + 3 * _magnitude(a0, a1, a2) + _perron_bound(chi0, chi1, chi2)


def perron_root_bracket(
    chi0: Int, chi1: Int, chi2: Int, refinements: Int
) raises -> IQ:
    """An exact rational enclosure of the unique Perron root of `chi`.

    The root is first located between consecutive integers of `(1, B]`, so the
    enclosure starts at width one and each refinement halves it."""
    if refinements < 0:
        raise Error("Perron bracket refinement count must be nonnegative")
    var coeffs: List[Int] = [chi0, chi1, chi2, 1]
    var bound = 1
    for c in [chi0, chi1, chi2]:
        if c == Int.MIN:
            raise Error("Perron bracket cannot take abs(Int.MIN)")
        var m = -c if c < 0 else c
        if m > bound - 1:
            if m == Int.MAX:
                raise Error("Perron bracket integer bound overflow")
            bound = m + 1
    if bound <= 1:
        raise Error("invalid Perron bracket bound")
    if bound > BRACKET_BOUND:
        raise Error("Perron bracket refuses to enumerate integers past its domain")

    var lo = Q.one()
    var flo = q_sign(eval_int_poly_at_q(coeffs, lo))
    if flo == 0:
        raise Error("irreducible Perron cubic unexpectedly vanishes at 1")
    var hi = q_int(bound)
    var found = False
    for k in range(2, bound + 1):
        var right = q_int(k)
        var fright = q_sign(eval_int_poly_at_q(coeffs, right))
        if fright == 0:
            raise Error("irreducible Perron cubic unexpectedly has an integer root")
        if fright != flo:
            hi = right.copy()
            found = True
            break
        lo = right.copy()
        flo = fright
    if not found:
        raise Error("failed to bracket the Perron root between consecutive integers")

    for _ in range(refinements):
        var mid = midpoint(lo, hi)
        var fm = q_sign(eval_int_poly_at_q(coeffs, mid))
        if fm == 0:
            raise Error("irreducible Perron cubic unexpectedly has a rational root")
        if fm == flo:
            lo = mid.copy()
            flo = fm
        else:
            hi = mid.copy()
    return require_iq(IQ(lo, hi), "Perron root enclosure")


def perron_sign_by_enclosure(
    chi0: Int, chi1: Int, chi2: Int, a0: Int, a1: Int, a2: Int
) raises -> Int:
    """`sign(Q(beta))` for `Q = a2 X^2 + a1 X + a0`, at any coefficient size.

    The bracket is refined by doubling from `FIRST_REFINEMENT` so that an easy
    element costs one bracketing, and the doubling stops at the depth the
    separation bound proves is enough."""
    if a0 == 0 and a1 == 0 and a2 == 0:
        return 0
    var coeffs: List[Int] = [a0, a1, a2]
    var budget = _sufficient_refinements(chi0, chi1, chi2, a0, a1, a2)
    var depth = FIRST_REFINEMENT
    while True:
        if depth > budget:
            depth = budget
        var box = perron_root_bracket(chi0, chi1, chi2, depth)
        var decided = strict_sign(interval_horner_int(coeffs, box))
        if decided != 0:
            return decided
        if depth >= budget:
            raise Error(
                "the Perron enclosure did not separate within its proved refinement budget"
            )
        depth = depth * 2
