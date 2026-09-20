"""Exact finite verdicts for a quadratic map at a Gaussian-rational parameter.

Every routine here is a *checker*: it consumes a parameter and, where one is
required, a witness, and returns what exact arithmetic decides. Nothing
searches for a witness, and nothing promotes an exhausted budget to a verdict.
A capped critical orbit reports `CAPPED`, which is not a classification.

Specification: `docs/rational-interval-arithmetic-spec.md`.
Terminology: `docs/terminology-registry.md`.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from fractions import Fraction
from typing import Sequence

from escape_certificate import EscapeCertificate, escape_certificate
from gaussian_q import GQ, ZERO, is_root_of_unity


def step(z: GQ, c: GQ) -> GQ:
    """`f_c(z) = z^2 + c`."""
    return z.square() + c


def escape_bound_quadrance(c: GQ) -> Fraction:
    """`max(4, N(c))`.

    The classical escape criterion is `|z| > max(2, |c|)`. Squaring both sides
    keeps the test inside the rank-2 layer: a quadrance compared against a
    rational bound, with no circle primitive and no square root.
    """
    return max(Fraction(4), c.quadrance())


def escapes_at(z: GQ, c: GQ) -> bool:
    return z.quadrance() > escape_bound_quadrance(c)


class OrbitVerdict(Enum):
    ESCAPES = "ESCAPES"
    PREPERIODIC = "PREPERIODIC"
    CAPPED = "CAPPED"


class CapReason(Enum):
    HORIZON = "HORIZON"
    BIT_BUDGET = "BIT_BUDGET"


@dataclass(frozen=True, slots=True)
class CriticalOrbit:
    """What a bounded exact run of the critical orbit established.

    `ESCAPES` carries the first index whose quadrance exceeds the bound, and
    the certificate that says what exceeding it buys: a rational ratio the
    quadrance grows by at every later step (`docs/escape-criterion.md`). The
    index alone would be a threshold crossing; the certificate is the reason
    to call it escape.
    `PREPERIODIC` carries the exact preperiod and period of the critical
    orbit. `CAPPED` carries the budget that ran out and the step reached, and
    establishes nothing: the orbit neither escaped nor repeated within the
    budget, which is a statement about the budget.
    """

    verdict: OrbitVerdict
    escape_index: int | None = None
    certificate: EscapeCertificate | None = None
    preperiod: int | None = None
    period: int | None = None
    horizon: int | None = None
    steps_taken: int | None = None
    cap_reason: CapReason | None = None

    def decided(self) -> bool:
        return self.verdict is not OrbitVerdict.CAPPED

    def signature(self) -> str:
        if self.verdict is OrbitVerdict.ESCAPES:
            return f"ESCAPES(n={self.escape_index})"
        if self.verdict is OrbitVerdict.PREPERIODIC:
            return f"PREPERIODIC(l={self.preperiod}, k={self.period})"
        return f"CAPPED({self.cap_reason.value}, n={self.steps_taken})"


def coordinate_bits(z: GQ) -> int:
    """Bit length of the largest numerator or denominator of a coordinate."""
    parts = (z.re.numerator, z.re.denominator, z.im.numerator, z.im.denominator)
    return max(abs(part).bit_length() for part in parts)


DEFAULT_HORIZON = 16
DEFAULT_BIT_BUDGET = 1 << 16


def critical_orbit(c: GQ, horizon: int = DEFAULT_HORIZON, bit_budget: int = DEFAULT_BIT_BUDGET) -> CriticalOrbit:
    """Run `z_0 = 0`, `z_{n+1} = z_n^2 + c` exactly, under two budgets.

    Exact arithmetic makes the repeat test an equality rather than a proximity
    test, so `PREPERIODIC` is a decided fact and not a tolerance. It is also
    why the run needs a bit budget as well as a step budget: squaring doubles
    the coordinate bit length, so an orbit that neither escapes nor repeats
    costs `O(2^n)` bits at step `n`. A parameter whose critical orbit merely
    converges -- every parabolic and every irrationally indifferent parameter
    in the corpus -- exhausts any budget by construction.

    Both budgets fail closed in the refuse-to-proceed direction: an exhausted
    budget returns `CAPPED` with the reason, never a classification.
    """
    if horizon < 1:
        raise ValueError("horizon must be at least 1")
    if bit_budget < 1:
        raise ValueError("bit_budget must be at least 1")
    seen: dict[GQ, int] = {}
    z = ZERO
    bound = escape_bound_quadrance(c)
    for n in range(horizon + 1):
        if z.quadrance() > bound:
            return CriticalOrbit(
                OrbitVerdict.ESCAPES,
                escape_index=n,
                certificate=escape_certificate(z.quadrance(), c.quadrance()),
            )
        if z in seen:
            first = seen[z]
            return CriticalOrbit(OrbitVerdict.PREPERIODIC, preperiod=first, period=n - first)
        if coordinate_bits(z) > bit_budget:
            return CriticalOrbit(
                OrbitVerdict.CAPPED, horizon=horizon, steps_taken=n, cap_reason=CapReason.BIT_BUDGET
            )
        seen[z] = n
        z = step(z, c)
    return CriticalOrbit(
        OrbitVerdict.CAPPED, horizon=horizon, steps_taken=horizon, cap_reason=CapReason.HORIZON
    )


def is_cycle(c: GQ, cycle: Sequence[GQ]) -> bool:
    """Is `cycle` an exact `k`-cycle of `f_c` with `k` distinct elements?"""
    if not cycle or len(set(cycle)) != len(cycle):
        return False
    return all(step(cycle[j], c) == cycle[(j + 1) % len(cycle)] for j in range(len(cycle)))


def multiplier(cycle: Sequence[GQ]) -> GQ:
    """`lam = (f^k)'(z) = 2^k * prod z_j` over the cycle."""
    product = GQ.of(1)
    for z in cycle:
        product = product * z
    return product.scale(2 ** len(cycle))


class MultiplierClass(Enum):
    SUPERATTRACTING = "SUPERATTRACTING"
    ATTRACTING = "ATTRACTING"
    PARABOLIC = "PARABOLIC"
    IRRATIONALLY_INDIFFERENT = "IRRATIONALLY_INDIFFERENT"
    REPELLING = "REPELLING"


def classify_multiplier(lam: GQ) -> MultiplierClass:
    """Classify a Gaussian-rational multiplier exactly.

    The indifferent case splits by the rational multiplier dichotomy: a
    quadrance-1 element of `Q(i)` is a root of unity exactly when it is one of
    `1, -1, i, -i`, so *parabolic* versus *irrationally indifferent* is decided
    by a four-element membership test and needs no bound on the period. What
    the dichotomy does **not** decide is *Siegel* versus *Cremer*: that turns
    on the Brjuno condition for the rotation number, which is not a finite
    test on the multiplier.
    """
    if lam.is_zero():
        return MultiplierClass.SUPERATTRACTING
    quadrance = lam.quadrance()
    if quadrance < 1:
        return MultiplierClass.ATTRACTING
    if quadrance > 1:
        return MultiplierClass.REPELLING
    return MultiplierClass.PARABOLIC if is_root_of_unity(lam) else MultiplierClass.IRRATIONALLY_INDIFFERENT


def indifferent_fixed_parameter(lam: GQ) -> GQ:
    """`c = lam (2 - lam) / 4`, the exact cardioid-boundary parameter.

    The fixed point of `f_c` with multiplier `lam` is `z = lam / 2`. For
    `lam` in `Q(i)` of quadrance 1 this produces an exactly representable
    parameter with an indifferent fixed point, which is how the corpus reaches
    the parabolic and irrationally indifferent regimes.
    """
    return (lam * (GQ.of(2) - lam)).scale(Fraction(1, 4))


#: Wire encoding shared with the Mojo kernel. `src/julia_orbit.mojo` declares
#: the same numbers as aliases, and `tests/test_mojo_replay.py` fails if the
#: two ever disagree, so a transcript cannot be compared under two different
#: codes.
MULTIPLIER_CODE = {
    MultiplierClass.SUPERATTRACTING: 0,
    MultiplierClass.ATTRACTING: 1,
    MultiplierClass.PARABOLIC: 2,
    MultiplierClass.IRRATIONALLY_INDIFFERENT: 3,
    MultiplierClass.REPELLING: 4,
}

MULTIPLIER_CODE_NONE = -1

ORBIT_CODE = {
    OrbitVerdict.ESCAPES: 0,
    OrbitVerdict.PREPERIODIC: 1,
    OrbitVerdict.CAPPED: 2,
}
