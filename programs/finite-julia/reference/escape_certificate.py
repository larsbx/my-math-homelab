"""The escape criterion as a finite certificate, derived rather than imported.

Specification: docs/rational-interval-arithmetic-spec.md.
Derivation and proofs: docs/escape-criterion.md.

`kernel/julia_orbit.mojo` decides escape by `N(z) > max(4, N(c))`. That test is a
sound *criterion*, but what it computes is only that a quadrance passed a
bound; the step from there to "the orbit is unbounded" is classical, and
nothing in this repository derived it or tagged it. This module supplies the
derivation, in the form the repository can check: a certificate carrying a
rational growth ratio.

Everything here is exact rational arithmetic on the two quadrances

    t = N(z),    m = N(c)

and no square root is taken anywhere, which is why the argument stays inside
the rank-2 layer instead of borrowing the modulus.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Union

Scalar = Union[int, Fraction]


def threshold_form(t: Fraction, ratio: Fraction) -> Fraction:
    """`T(t, r) = t^2 - 2t(1 + r) + (r - 1)^2`.

    Its roots in `t` are `(sqrt(r) ± 1)^2`, so `T > 0` holds on **both** sides
    of the parabola. The certificate wants the upper branch only, which is why
    `certificate_holds` also demands `t > 1 + r`, the vertex.
    """
    return t * t - 2 * t * (1 + ratio) + (ratio - 1) ** 2


def growth_form(t: Fraction, m: Fraction, ratio: Fraction) -> Fraction:
    """`G(t, m, r) = (t^2 + m - r t)^2 - 4 t^2 m`, expanded as a quadratic in `m`.

    `N(f(z)) >= t^2 - 2 t sqrt(m) + m`, and `G >= 0` with `t^2 + m - r t >= 0`
    is that bound rearranged so the square root never appears.
    """
    return m * m - 2 * t * (t + ratio) * m + t * t * (t - ratio) ** 2


def certificate_holds(t: Scalar, m: Scalar, ratio: Scalar) -> bool:
    """Does `ratio` certify geometric escape from quadrance `t` at parameter `m`?

    Four conditions, all rational: the ratio exceeds one, the parameter
    quadrance does not exceed the point's, the point is on the upper branch of
    the threshold parabola, and the threshold form is positive there.
    """
    t, m, ratio = Fraction(t), Fraction(m), Fraction(ratio)
    if ratio <= 1 or m < 0 or m > t or t <= 1 + ratio:
        return False
    return threshold_form(t, ratio) > 0


@dataclass(frozen=True, slots=True)
class EscapeCertificate:
    """A quadrance, a parameter, and the rational rate the orbit grows at.

    The claim is `N(f^n(z)) >= ratio^n * quadrance`, which diverges because
    `ratio > 1`. It is a statement about every step, not about a limit.
    """

    quadrance: Fraction
    parameter_quadrance: Fraction
    ratio: Fraction

    def valid(self) -> bool:
        return certificate_holds(self.quadrance, self.parameter_quadrance, self.ratio)

    def next_quadrance_bound(self) -> Fraction:
        """The certified lower bound on the next quadrance."""
        return self.ratio * self.quadrance

    def successor(self) -> "EscapeCertificate":
        """The same certificate at the next step.

        The hypotheses are preserved because the new quadrance is larger and
        the threshold form is increasing past its vertex, so one certificate
        covers the whole forward orbit rather than one step of it.
        """
        return EscapeCertificate(self.next_quadrance_bound(), self.parameter_quadrance, self.ratio)


#: Dyadic refinements used when searching for the largest admissible ratio.
DEFAULT_REFINEMENTS = 32


def best_ratio(t: Scalar, m: Scalar, refinements: int = DEFAULT_REFINEMENTS) -> Fraction | None:
    """The largest dyadic ratio that certifies escape, or `None` if none does.

    Bisection on a dyadic grid, every step decided by exact comparison. The
    admissible ratios are an interval `(1, (sqrt(t) - 1)^2)`, so bisection
    finds a ratio whenever one exists and `t` is not on the boundary.
    """
    t, m = Fraction(t), Fraction(m)
    if not certificate_holds(t, m, Fraction(1) + Fraction(1, 2 ** refinements)):
        return None
    low, high = Fraction(1), max(t, Fraction(2))
    for _ in range(refinements):
        middle = (low + high) / 2
        if certificate_holds(t, m, middle):
            low = middle
        else:
            high = middle
    return low


def escape_certificate(t: Scalar, m: Scalar, refinements: int = DEFAULT_REFINEMENTS) -> EscapeCertificate | None:
    """A certificate for `(t, m)`, or `None` where the quadrance is too small.

    `None` is not a claim that the orbit is bounded. It says this quadrance
    carries no certificate, which is the fail-closed reading.
    """
    ratio = best_ratio(t, m, refinements)
    if ratio is None:
        return None
    return EscapeCertificate(Fraction(t), Fraction(m), ratio)
