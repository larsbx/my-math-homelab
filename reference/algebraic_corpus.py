"""The algebraic corpus: Julia parameters at irrational hyperbolic centres.

Specification: docs/rational-interval-arithmetic-spec.md.

The parameter corpus (`reference/parameter_corpus.py`) holds Gaussian-rational
`c` only. The centres of the rabbit, co-rabbit and airplane components are the
three roots of `c^3 + 2c^2 + c + 1`, and Kokopelli's is a root of the period-4
Gleason factor; none is rational. A row here names its parameter by a **root
handle**: an integer polynomial and a rational box that isolates exactly one
of its roots. Every claim a row makes is checked:

- the polynomial divides `f_c^n(0)` and shares no root with `f_c^d(0)` for a
  proper divisor `d` of the row's period `n`, so every root is the centre of a
  component of exact period `n` (exact integer algebra, no import);
- the box isolates one root: the Krawczyk image lies strictly inside the box,
  read through the accepted import `KrawczykMooreUniqueness`
  (`docs/literature-gate-2026-09-20-krawczyk.md`);
- boxes on one polynomial are pairwise disjoint, so they name distinct roots;
- a declared conjugate has the conjugate box, the same polynomial, and the
  negated angles;
- the declared trap is a trap of the row's period at every parameter in the
  box (`reference/box_classifier.py`), so the classifier may count `IN`.

Which component a box sits in -- that the rays at `root_angles` land at the
root of the component whose centre is in the box -- is the accepted import
`RationalRayLanding` (`docs/literature-gate-2026-09-20-landing.md`), named and
not computed. The boxes were found offline by exact dyadic Newton steps and
are declared here, like every witness in the corpus; none is a search result.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction as F

from box_classifier import is_trap
from closed_interval import ComplexBox
from root_isolation_py import disjoint, krawczyk, strictly_inside

Poly = tuple[int, ...]  # integer coefficients in c, constant term first

#: Every row is a hyperbolic centre, so these columns are the same for all of
#: them; they are the parameter corpus's values for its centre rows.
REGIME = "HYPERBOLIC_CENTER"
MULTIPLIER_CLASS = "SUPERATTRACTING"
THEOREM_TAG = "DouadyHubbardHyperbolicLocallyConnected"
IDENTIFICATION_TAG = "RationalRayLanding"
J1_EXPECTATION = "STABILIZES"

#: Half-width of every declared box, and the dyadic grid of its centre.
HALF_WIDTH = F(1, 2**40)
GRID = 2**41

GLEASON_3: Poly = (1, 1, 2, 1)
GLEASON_4_FACTOR: Poly = (1, 0, 2, 3, 3, 3, 1)
UNIT_TRAP = ComplexBox.of(F(-1, 64), F(1, 64), F(-1, 64), F(1, 64))


@dataclass(frozen=True, slots=True)
class RootHandle:
    """An integer polynomial and a rational box that isolates one of its roots."""

    polynomial: Poly
    box: ComplexBox


@dataclass(frozen=True, slots=True)
class AlgebraicParameter:
    key: str
    name: str
    handle: RootHandle
    period: int
    root_angles: tuple[F, F]
    conjugate_of: str | None
    trap: tuple[ComplexBox, int]
    note: str


def _box(re_num: int, im_num: int) -> ComplexBox:
    re, im = F(re_num, GRID), F(im_num, GRID)
    return ComplexBox.of(re - HALF_WIDTH, re + HALF_WIDTH, im - HALF_WIDTH, im + HALF_WIDTH)


ALGEBRAIC_CORPUS: tuple[AlgebraicParameter, ...] = (
    AlgebraicParameter(
        key="rabbit",
        name="Douady rabbit",
        handle=RootHandle(GLEASON_3, _box(-269514856189, 1637968346968)),
        period=3,
        root_angles=(F(1, 7), F(2, 7)),
        conjugate_of=None,
        trap=(UNIT_TRAP, 3),
        note="Centre of the 1/3-bulb: the upper non-real root of c^3 + 2c^2 + c + 1.",
    ),
    AlgebraicParameter(
        key="co_rabbit",
        name="co-rabbit",
        handle=RootHandle(GLEASON_3, _box(-269514856189, -1637968346968)),
        period=3,
        root_angles=(F(5, 7), F(6, 7)),
        conjugate_of="rabbit",
        trap=(UNIT_TRAP, 3),
        note="Centre of the 2/3-bulb, the complex conjugate of the rabbit's.",
    ),
    AlgebraicParameter(
        key="airplane",
        name="airplane",
        handle=RootHandle(GLEASON_3, _box(-3859016798725, 0)),
        period=3,
        root_angles=(F(3, 7), F(4, 7)),
        conjugate_of=None,
        trap=(UNIT_TRAP, 3),
        note="Centre of the period-3 window: the real root of c^3 + 2c^2 + c + 1. The box straddles the real axis; it is its own conjugate.",
    ),
    AlgebraicParameter(
        key="kokopelli",
        name="Kokopelli",
        handle=RootHandle(GLEASON_4_FACTOR, _box(-344191486830, 2269935397998)),
        period=4,
        root_angles=(F(1, 5), F(4, 15)),
        conjugate_of=None,
        trap=(UNIT_TRAP, 4),
        note="Primitive period 4 in the 1/3-limb, internal address 1 -> 3 -> 4: a root of the degree-6 period-4 Gleason factor.",
    ),
    AlgebraicParameter(
        key="kokopelli_conjugate",
        name="Kokopelli conjugate",
        handle=RootHandle(GLEASON_4_FACTOR, _box(-344191486830, -2269935397998)),
        period=4,
        root_angles=(F(11, 15), F(4, 5)),
        conjugate_of="kokopelli",
        trap=(UNIT_TRAP, 4),
        note="Its mirror in the 2/3-limb.",
    ),
)


# --- exact integer polynomials -------------------------------------------------

def _trim(p) -> tuple:
    p = list(p)
    while p and p[-1] == 0:
        p.pop()
    return tuple(p)


def degree(p: Poly) -> int:
    return len(_trim(p)) - 1


def _mul(p, q) -> tuple:
    out = [0] * (len(p) + len(q) - 1) if p and q else []
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            out[i + j] += a * b
    return _trim(out)


def _add(p, q) -> tuple:
    return _trim((p[i] if i < len(p) else 0) + (q[i] if i < len(q) else 0) for i in range(max(len(p), len(q))))


def _rem(p, d) -> tuple:
    """Remainder over `Q`, with `Fraction` coefficients."""
    r = [F(a) for a in p]
    while len(_trim(r)) >= len(d) and _trim(r):
        r = list(_trim(r))
        k, s = len(r) - len(d), r[-1] / d[-1]
        r = [r[i] - (s * d[i - k] if i >= k else 0) for i in range(len(r))]
    return _trim(r)


def _gcd_is_constant(p, q) -> bool:
    while q:
        p, q = q, _rem(p, q)
    return len(p) == 1


def gleason(n: int) -> Poly:
    """`f_c^n(0)` as an integer polynomial in `c`."""
    g: tuple = (0, 1)
    for _ in range(n - 1):
        g = _add(_mul(g, g), (0, 1))
    return g


def exact_period_factor(p: Poly, n: int) -> bool:
    """`p` divides `f_c^n(0)` and is coprime to `f_c^d(0)` for every proper divisor `d` of `n`."""
    return degree(p) > 0 and _rem(gleason(n), p) == () and all(
        _gcd_is_constant(p, gleason(d)) for d in range(1, n) if n % d == 0
    )


# --- interval checks --------------------------------------------------------------

def _horner(p, z: ComplexBox) -> ComplexBox:
    acc = ComplexBox.singleton(0)
    for a in reversed(p):
        acc = acc.mul(z).add(ComplexBox.singleton(a))
    return acc


def isolates(p: Poly, box: ComplexBox) -> bool:
    """The Krawczyk image of `box` for `p` lies strictly inside `box`: by
    `KrawczykMooreUniqueness`, `p` has exactly one root there."""
    dp = tuple(i * a for i, a in enumerate(p))[1:]
    image = krawczyk(
        (box,),
        lambda m: ((_horner(p, m[0]),), ((_horner(dp, m[0]),),)),
        lambda x: ((_horner(dp, x[0]),),),
    )
    return strictly_inside(image, (box,))


def angle_period(theta: F) -> int | None:
    """Exact period of a periodic angle under doubling modulo one, or None."""
    if theta.denominator % 2 == 0:
        return None
    t, n = (2 * theta) % 1, 1
    while t != theta:
        t, n = (2 * t) % 1, n + 1
    return n


def row_errors(row: AlgebraicParameter, rows: tuple[AlgebraicParameter, ...]) -> list[str]:
    p, box = row.handle.polynomial, row.handle.box
    errors = []
    if not exact_period_factor(p, row.period):
        errors.append(f"polynomial is not an exact period-{row.period} Gleason factor")
    if not isolates(p, box):
        errors.append("the box does not isolate a root of the polynomial")
    errors += [
        f"box meets the box of {other.key}, on the same polynomial"
        for other in rows
        if other.key != row.key and other.handle.polynomial == p and not disjoint((box,), (other.handle.box,))
    ]
    if row.conjugate_of is not None:
        other = next((r for r in rows if r.key == row.conjugate_of), None)
        if other is None:
            errors.append("unknown conjugate")
        elif other.handle.polynomial != p or other.handle.box != box.conjugate():
            errors.append(f"not the conjugate root of {other.key}")
        elif sorted((1 - a) % 1 for a in other.root_angles) != sorted(row.root_angles):
            errors.append(f"angles are not those of {other.key}, negated")
    trap, trap_period = row.trap
    if trap_period != row.period or not is_trap(trap, box, trap_period):
        errors.append(f"the declared trap is not a period-{row.period} trap on the whole box")
    if any(angle_period(a) != row.period for a in row.root_angles):
        errors.append("an identification angle is not of the row's period")
    return errors
