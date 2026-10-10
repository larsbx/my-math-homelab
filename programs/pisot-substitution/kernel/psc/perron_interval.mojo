"""Rational-interval enclosure layer for the cubic Perron embedding.

This module is intentionally separate from the Sturm--Tarski oracle. It first
isolates the distinguished Perron root inside an exact rational interval, then
uses the natural interval extension of ``a0 + a1 X + a2 X^2``. A strict sign
is returned only when the enclosure excludes zero. Ambiguous or invalid interval
work falls back to ``sign_at_perron``; it is never interpreted as a zero or a
negative mathematical result. Endpoints are unbounded ``finite_exact``
rationals, so refinement depth is limited by cost only, never by overflow.

What this module adds over `psc.perron_root_sign`, which holds the bracketing
and the same enclosure in plain integers, is the field's own type and one
enclosure cached per field: a census isolates beta once per substitution and
answers every element against the stored box.
"""

from finite_exact.closed_interval import IQ
from finite_exact.rat_q import Q
from psc.exact import interval_horner_int, strict_sign
from psc.perron_field3 import CubicElt, PerronField3, sign_at_perron
from psc.perron_root_sign import perron_root_bracket


struct PerronIntervalDecision(ImplicitlyCopyable, Copyable, Movable):
    var sign: Int
    var interval_certified: Bool

    def __init__(out self, sign: Int, interval_certified: Bool):
        self.sign = sign
        self.interval_certified = interval_certified


def perron_root_interval(
    field: PerronField3, refinements: Int = 10
) raises -> IQ:
    """Return an exact rational enclosure containing the unique Perron root.

    The bracketing and bisection live in `psc.perron_root_sign`, which is
    below `psc.perron_field3` and so can also serve as that module's unbounded
    rung; this is the same enclosure under the field's own type."""
    return perron_root_bracket(field.chi0, field.chi1, field.chi2, refinements)


struct PerronEnclosure(Copyable, Movable):
    """One field's Perron root enclosure, computed once and reused.

    Bracketing and bisection depend only on the field, so a census computes
    this once per substitution (AGENTS.md rule 3) and evaluates the natural
    interval extension of each ``x(beta)`` against the stored box.
    """

    var field: PerronField3
    var beta_box: IQ

    def __init__(out self, field: PerronField3, refinements: Int = 10) raises:
        self.field = field
        self.beta_box = perron_root_interval(field, refinements)

    def interval(self, x: CubicElt) raises -> IQ:
        """Natural rational interval extension of ``x(beta)``."""
        var coeffs: List[Int] = [x.a0, x.a1, x.a2]
        return interval_horner_int(coeffs, self.beta_box)

    def interval_sign(self, x: CubicElt) raises -> Int:
        """Return +/-1 when the rational enclosure proves the sign, else 0."""
        if x.is_zero():
            return 0
        return strict_sign(self.interval(x))

    def sign_decision(self, x: CubicElt) raises -> PerronIntervalDecision:
        """Interval-first sign decision with exact Sturm--Tarski fallback.

        ``interval_certified`` means specifically that a strict nonzero sign
        was proved because the entire rational enclosure excluded zero.
        Symbolic zero is exact but is not a strict interval sign certificate.
        """
        if x.is_zero():
            return PerronIntervalDecision(0, False)
        var boxed_sign = 0
        try:
            boxed_sign = self.interval_sign(x)
        except:
            boxed_sign = 0
        if boxed_sign != 0:
            return PerronIntervalDecision(boxed_sign, True)
        return PerronIntervalDecision(sign_at_perron(self.field, x), False)

    def sign_interval_first(self, x: CubicElt) raises -> Int:
        return self.sign_decision(x).sign


def cubic_perron_interval(
    field: PerronField3,
    x: CubicElt,
    refinements: Int = 10,
) raises -> IQ:
    """Natural rational interval extension of ``x(beta)``."""
    return PerronEnclosure(field, refinements).interval(x)


def interval_sign_at_perron(
    field: PerronField3,
    x: CubicElt,
    refinements: Int = 10,
) raises -> Int:
    """Return +/-1 when the rational enclosure proves the sign, else 0."""
    if x.is_zero():
        return 0
    return PerronEnclosure(field, refinements).interval_sign(x)


def perron_sign_decision(
    field: PerronField3,
    x: CubicElt,
    refinements: Int = 10,
) raises -> PerronIntervalDecision:
    """One-shot form of ``PerronEnclosure.sign_decision``; a failed bracket
    counts as an unresolved interval and falls back to the exact oracle."""
    if x.is_zero():
        return PerronIntervalDecision(0, False)
    var boxed_sign = 0
    try:
        boxed_sign = PerronEnclosure(field, refinements).interval_sign(x)
    except:
        boxed_sign = 0
    if boxed_sign != 0:
        return PerronIntervalDecision(boxed_sign, True)
    return PerronIntervalDecision(sign_at_perron(field, x), False)


def sign_at_perron_interval_first(
    field: PerronField3,
    x: CubicElt,
    refinements: Int = 10,
) raises -> Int:
    return perron_sign_decision(field, x, refinements).sign
