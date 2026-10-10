"""The state a Pisot digit exploration carries, and the reserve that bounds it.

Two explorations in this repository carry the same state: the numeration
conversion and the coincidence automaton both accumulate `M x + s` while
reading digits most significant first, and both diverge unless states that can
no longer reach zero are cut. (`psc.numeration_addition` cuts the same way for
the same reason, but its state weighs shifts of one sequence rather than one
coefficient per letter, so its comparison is in a different basis and is not
this one.)

The state is a vector `x` of integers weighing quantities that grow like
`v_b beta^m`, where `v` is the left Perron eigenvector of the incidence matrix
and `beta` its Perron root. Its value at the Perron embedding is the cubic
element `sum_b x[b] v_b`, and what the remaining digits can still contribute is
bounded by a geometric series in `1/beta`. Clearing the series' `1/(beta - 1)`
by multiplying the comparison through by `beta - 1`, which is positive, leaves
an exact comparison between two elements of `Z[beta]` that `sign_at_perron`
decides -- by Sturm-Tarski counting where the coefficients are small enough for
it, and by a rational enclosure of `beta` where they are not, so no size of
coordinate the step admits can leave the comparison undecided. No division and
no float enters.

`slack` is the caller's, not this module's. The bound here is
`slack (radix - 1) sum_b v_b`, and whether `slack = 1` is a theorem about the
caller's state or an estimate that has to be measured depends on whether the
caller's weights are exactly `v_b beta^m` or only asymptotically so. Each
caller states which, and the asymmetry is the same for all of them: pruning too
little adds states, which a cap catches; pruning too much drops a real answer,
which nothing catches.
"""

from finite_linear_algebra.mat3 import Mat3
from psc.perron_field3 import (
    CubicElt,
    PerronField3,
    TileLengths3,
    cubic_add_checked,
    cubic_mul,
    cubic_scale_checked,
    cubic_sub_checked,
    sign_at_perron,
)


comptime ENTRY_BOUND = 1 << 52
"""Where a state coordinate is refused rather than allowed to wrap.

This is the bound on the *stepping* arithmetic, and it is the only one: the
sign query the reserve comparison ends in decides every element of `Z[beta]`
whose coordinates fit in `Int`, because `sign_at_perron` hands a coefficient
past its machine-integer rung to an unbounded rational enclosure rather than
refusing it. A coordinate admitted here therefore reaches a decision, which
was not true while the sign oracle stopped near `2 * 10^6`."""

comptime INCIDENCE_BOUND = 64
"""Where an incidence entry is refused, so the bound above can be checked once.

The two together are what make the accumulation safe rather than merely
plausible: three columns of entries at most this large, against coordinates at
most `ENTRY_BOUND`, keep every intermediate under `193 * 2^52`, which is an
order of magnitude inside the machine range. Both are checked on the way in, so
the only unchecked quantity is the sum, which is checked on the way out.

This bound is the *matrix's* alone. A step's contribution is bounded by
`ENTRY_BOUND` like a coordinate, because it is one: a caller with a large digit
alphabet legitimately contributes more than an incidence entry ever holds, and
the arithmetic above has room for it."""


def incidence_step(m: Mat3, x: List[Int], s: List[Int]) raises -> List[Int]:
    """`M x + s`, the one step both explorations here take.

    `M[i][j]` counts letter `i` in `sigma(j)`, so `M^k e_b` is the Parikh vector
    of `sigma^k(b)` and a state accumulated this way *is* a Parikh vector: what
    the digits read so far have skipped, weighed by the level at which they were
    skipped.

    Nothing is trusted to be small. A wrapped coordinate would be a wrong number
    presented as a state, and every later step would be computed from it, so the
    inputs and the result are checked rather than assumed to have come from a
    previous checked step."""
    if len(x) != 3 or len(s) != 3:
        raise Error("a state vector carries one coefficient per letter of three")
    for i in range(3):
        if x[i] > ENTRY_BOUND or x[i] < -ENTRY_BOUND:
            raise Error("state coordinate outside the checked range")
        if s[i] > ENTRY_BOUND or s[i] < -ENTRY_BOUND:
            raise Error("step contribution outside the checked range")
    var out = List[Int](length=3, fill=0)
    for row in range(3):
        var total = s[row]
        for col in range(3):
            var entry = m.at(row, col)
            if entry < -INCIDENCE_BOUND or entry > INCIDENCE_BOUND:
                raise Error("incidence entry outside the checked range")
            total += entry * x[col]
        if total > ENTRY_BOUND or total < -ENTRY_BOUND:
            raise Error("state coordinate outside the checked range")
        out[row] = total
    return out^


def perron_value(field: PerronField3, v: TileLengths3, x: List[Int]) raises -> CubicElt:
    """`sum_b x[b] v_b`, the state's value in the eigenvector's own scale."""
    if len(x) != 3:
        raise Error("a state vector carries one coefficient per letter of three")
    var total = CubicElt()
    for b in range(3):
        total = cubic_add_checked(total, cubic_scale_checked(v.at(b), x[b]))
    return total


def completion_reserve(v: TileLengths3, radix: Int, slack: Int) raises -> CubicElt:
    """`slack (radix - 1) sum_b v_b`, with the comparison already multiplied
    through by `beta - 1`.

    One step contributes at most `radix - 1` letters on either side, so its
    value lies within `(radix - 1) sum_b v_b` -- a simple majorant of the
    tighter `(radix - 1) max_b v_b`, chosen because comparing the entries would
    itself need a sign query and the looser bound only costs states."""
    if radix < 2:
        raise Error("a digit alphabet has at least two digits")
    if slack < 1:
        raise Error("a pruning bound is positive")
    var total = CubicElt()
    for b in range(3):
        total = cubic_add_checked(total, v.at(b))
    return cubic_scale_checked(total, slack * (radix - 1))


def within_reserve(
    field: PerronField3, v: TileLengths3, x: List[Int], reserve: CubicElt
) raises -> Bool:
    """Whether `(beta - 1)` times the state's value lies inside the reserve on
    both sides. A state outside it can never be completed to zero."""
    var scaled = cubic_mul(field, CubicElt(-1, 1, 0), perron_value(field, v, x))
    if sign_at_perron(field, cubic_sub_checked(reserve, scaled)) < 0:
        return False
    if sign_at_perron(field, cubic_add_checked(scaled, reserve)) < 0:
        return False
    return True
