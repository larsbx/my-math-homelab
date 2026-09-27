"""The real Markov partition of a postcritically finite parameter.

Specification: docs/rational-interval-arithmetic-spec.md, section 1.
Statements and the bridge: docs/tiling-connections-2026-09-20.md.

For a real parameter whose critical orbit is finite, the postcritical set cuts
the real line into finitely many intervals on each of which `f` is monotone.
Which interval covers which is a `0/1` matrix, and that matrix is the object
the substitution and tiling side of the estate consumes: its Perron root is
the growth rate of admissible words, and whether that root is a Pisot number
is the question a tiling spectrum turns on.

Everything here is exact rational arithmetic on a finite set of points. No
limit is taken, no entropy is claimed, and the matrix is a fact about
coverings, not about any measure.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Union

from gaussian_q import GQ
from julia_reference import DEFAULT_HORIZON, OrbitVerdict, critical_orbit

Scalar = Union[int, Fraction]


#: Section 3.2 of the note: a parameter of quadrance above this escapes.
PCF_QUADRANCE_BOUND = 4

#: The Mojo kernel stores an integer in base-`10^9` limbs, so a limb count is
#: a decimal digit count divided by nine and both sides can compute it
#: exactly. Sharing the budget in limbs is what lets the two transcripts be
#: compared rather than merely resemble each other.
LIMB_DIGITS = 9
DEFAULT_LIMB_BUDGET = 40


def limb_bound(limb_budget: int) -> int:
    """The least integer `BigZ` would need more than `limb_budget` limbs for."""
    return 10 ** (LIMB_DIGITS * limb_budget)


def within_limb_budget(value: Fraction, limb_budget: int) -> bool:
    """Would `BigZ` still hold both coordinates in `limb_budget` limbs?

    One comparison each, against a bound the caller can precompute. Counting
    the limbs instead would mean counting the digits of a number the budget
    exists to avoid writing down.
    """
    bound = limb_bound(limb_budget)
    return abs(value.numerator) < bound and value.denominator < bound


def postcritical_points(
    c: Scalar,
    horizon: int = DEFAULT_HORIZON,
    limb_budget: int = DEFAULT_LIMB_BUDGET,
) -> tuple[Fraction, ...] | None:
    """The finite forward orbit of the critical point, sorted, with `0`.

    `None` unless the orbit is genuinely finite: an escaping, capped, or
    unaffordable orbit has no Markov partition to offer, and saying so is the
    whole of the fail-closed rule here. This is
    `julia_reference.critical_orbit` restricted to the line, under a budget a
    Mojo kernel can compute the same way; `tests/test_markov.py` checks that
    the two agree on every verdict.

    Zero is included whether or not it is postcritical, because `f` is not
    monotone across it and a partition that ignores that is not a Markov
    partition.
    """
    c = Fraction(c)
    threshold = max(Fraction(PCF_QUADRANCE_BOUND), c * c)
    seen, z = [Fraction(0)], Fraction(0)
    for _ in range(horizon):
        z = z * z + c
        if z * z > threshold:
            return None
        if z in seen:
            return tuple(sorted(seen))
        if not within_limb_budget(z, limb_budget):
            return None
        seen.append(z)
    return None


@dataclass(frozen=True, slots=True)
class MarkovPartition:
    """The intervals, and which of them the map carries over which."""

    c: Fraction
    points: tuple[Fraction, ...]
    matrix: tuple[tuple[int, ...], ...]

    def size(self) -> int:
        return len(self.matrix)

    def intervals(self) -> tuple[tuple[Fraction, Fraction], ...]:
        return tuple(zip(self.points[:-1], self.points[1:]))


def image(c: Fraction, lo: Fraction, hi: Fraction) -> tuple[Fraction, Fraction]:
    """`f([lo, hi])` where the interval does not straddle zero.

    Monotone there, so the image is the interval between the endpoint images.
    That is why zero is a partition point.
    """
    left, right = lo * lo + c, hi * hi + c
    return (left, right) if left <= right else (right, left)


def partition(
    c: Scalar,
    horizon: int = DEFAULT_HORIZON,
    limb_budget: int = DEFAULT_LIMB_BUDGET,
) -> MarkovPartition | None:
    """The partition and its covering matrix, or `None` for a parameter with
    no finite critical orbit."""
    points = postcritical_points(c, horizon, limb_budget)
    if points is None or len(points) < 2:
        # One point is not a partition. At `c = 0` the whole postcritical set
        # is the critical point itself, so the real line carries no Markov
        # structure at all -- a fact about that parameter, not a failure.
        return None
    c = Fraction(c)
    pieces = tuple(zip(points[:-1], points[1:]))
    rows = []
    for lo, hi in pieces:
        low, high = image(c, lo, hi)
        rows.append(tuple(1 if low <= a and b <= high else 0 for a, b in pieces))
    return MarkovPartition(c, points, tuple(rows))


# --- the characteristic polynomial, exactly ---------------------------------


def characteristic_polynomial(matrix: tuple[tuple[int, ...], ...]) -> tuple[Fraction, ...]:
    """Coefficients of `det(x I - M)`, ascending, by Faddeev-LeVerrier.

    Exact over `Q`, and monic by construction. The recurrence divides by the
    step index, which is why the arithmetic is rational even though the
    answer is integral.
    """
    size = len(matrix)
    if size == 0:
        return (Fraction(1),)
    current = [[Fraction(0)] * size for _ in range(size)]
    coefficients = [Fraction(1)]
    for step in range(1, size + 1):
        # M_k = A (M_(k-1) + c_(k-1) I), which is A M_(k-1) + c_(k-1) A.
        current = [
            [sum(Fraction(matrix[i][k]) * current[k][j] for k in range(size))
             + coefficients[-1] * Fraction(matrix[i][j]) for j in range(size)]
            for i in range(size)
        ]
        trace = sum(current[i][i] for i in range(size))
        coefficients.append(-trace / step)
    return tuple(reversed(coefficients))


def evaluate(coefficients: tuple[Fraction, ...], x: Scalar) -> Fraction:
    """Horner, ascending coefficients. One occurrence of `x` per step, which
    is the case Horner is the right form for."""
    x = Fraction(x)
    total = Fraction(0)
    for coefficient in reversed(coefficients):
        total = total * x + coefficient
    return total


def growth_bracket(
    coefficients: tuple[Fraction, ...],
    upper: Scalar = 2,
    width: Scalar = Fraction(1, 1 << 20),
) -> tuple[Fraction, Fraction] | None:
    """A rational bracket of *a* root in `[1, upper]`, or `None`.

    Bisection on a sign change, which is a certificate rather than a search:
    the returned pair are rationals at which the polynomial has opposite
    signs, so a root lies between them. No root is named and none is
    approximated -- the bracket is the answer.

    It is deliberately not the largest root. Bisection converges to whichever
    root the sign changes lead it to, and isolating the Perron root would
    need a root-separation argument this repository has not built
    (`docs/tiling-connections-2026-09-20.md`, section 7, item 2).
    """
    lo, hi = Fraction(1), Fraction(upper)
    low, high = evaluate(coefficients, lo), evaluate(coefficients, hi)
    if low == 0:
        return (lo, lo)
    if low * high > 0:
        return None
    width = Fraction(width)
    while hi - lo > width:
        mid = (lo + hi) / 2
        middle = evaluate(coefficients, mid)
        if middle == 0:
            return (mid, mid)
        if low * middle < 0:
            hi, high = mid, middle
        else:
            lo, low = mid, middle
    return (lo, hi)


# --- the parameter domain the bridge can draw on ----------------------------


def gaussian_pcf_parameters(horizon: int = DEFAULT_HORIZON) -> tuple[tuple[int, int], ...]:
    """The postcritically finite parameters of `Q(i)`, as integer pairs.

    Exhaustive, not sampled: `docs/tiling-connections-2026-09-20.md`, section
    3.1 puts every such parameter in `Z[i]` and section 3.2 bounds its
    quadrance, which leaves the finitely many candidates this enumerates.
    """
    bound = PCF_QUADRANCE_BOUND
    side = range(-bound, bound + 1)
    return tuple(
        (a, b)
        for a in side
        for b in side
        if a * a + b * b <= bound
        and critical_orbit(GQ(Fraction(a), Fraction(b)), horizon=horizon).verdict
        is OrbitVerdict.PREPERIODIC
    )


# --- shapes the tests and the Mojo transcript share -------------------------


def covering_row_block(row: tuple[int, ...]) -> tuple[int, int] | None:
    """The first and last index a row covers, provided they are consecutive.

    `None` where the row is empty or has a gap, which section 2.2 of
    `docs/tiling-connections-2026-09-20.md` says cannot happen -- so the test
    that calls this is checking the theorem, not the data.
    """
    covered = [index for index, bit in enumerate(row) if bit]
    if not covered or covered != list(range(covered[0], covered[-1] + 1)):
        return None
    return (covered[0], covered[-1])


def rational_text(value: Fraction) -> str:
    return f"{value.numerator}/{value.denominator}"


def transcript_line(
    c: Scalar,
    horizon: int = DEFAULT_HORIZON,
    limb_budget: int = DEFAULT_LIMB_BUDGET,
) -> str:
    """One parameter, in the shape `kernel/markov_transcript.mojo` prints."""
    line = "c=" + rational_text(Fraction(c))
    part = partition(c, horizon, limb_budget)
    if part is None:
        return line + " none"
    matrix = "".join(str(bit) for row in part.matrix for bit in row)
    poly = ",".join(rational_text(term) for term in characteristic_polynomial(part.matrix))
    return f"{line} points={','.join(rational_text(p) for p in part.points)} matrix={matrix} poly={poly}"
