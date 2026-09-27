"""Exact low-order parabolic-index reconstruction over Q(i).

This module is a research/reference oracle. It does not accept Julia-set
certificates and it does not replace the Mojo checker boundary.

For g_lambda(w) = lambda*w + w^2 with lambda^q = 1, write

    w - g_lambda^q(w) = w^(q+1) P(w).

The holomorphic fixed-point index is the coefficient of w^q in 1/P.  When
lambda lies in Q(i), every coefficient is an exact Gaussian rational, so the
calculation needs no floating point, no transcendental functions, and no
limiting process.

The translation

    z0 = lambda/2
    c  = lambda/2 - lambda^2/4
    z  = z0 + w

identifies z^2 + c with g_lambda around z0 exactly:
f_c(z0 + w) - z0 = lambda*w + w^2.
"""

from __future__ import annotations

from fractions import Fraction as F

from gaussian_q import GQ, I, ONE, ZERO
from jet import convolve

Jet = tuple[GQ, ...]


def reciprocal(value: GQ) -> GQ:
    """Exact multiplicative inverse in Q(i); zero is rejected."""
    norm = value.quadrance()
    if norm == 0:
        raise ZeroDivisionError("zero has no reciprocal")
    return GQ(value.re / norm, -value.im / norm)


def power(value: GQ, exponent: int) -> GQ:
    if exponent < 0:
        raise ValueError("negative exponent")
    out = ONE
    for _ in range(exponent):
        out = out * value
    return out


def germ_step(state: Jet, lam: GQ) -> Jet:
    """One truncated step of w -> lam*w + w^2."""
    squared = convolve(state, state)[: len(state)]
    return tuple(lam * a + b for a, b in zip(state, squared))


def germ_iterate(lam: GQ, q: int, order: int) -> Jet:
    if q < 1 or order < 1:
        raise ValueError("q and order must be positive")
    state: Jet = (ZERO, ONE) + (ZERO,) * (order - 1)
    for _ in range(q):
        state = germ_step(state, lam)
    return state


def reciprocal_series(coeffs: Jet, order: int) -> Jet:
    """Coefficients of 1/P through the requested order."""
    if not coeffs or coeffs[0].is_zero():
        raise ZeroDivisionError("series constant coefficient is zero")
    inv0 = reciprocal(coeffs[0])
    out = [inv0]
    for n in range(1, order + 1):
        total = ZERO
        for k in range(1, n + 1):
            if k < len(coeffs):
                total = total + coeffs[k] * out[n - k]
        out.append(-(inv0 * total))
    return tuple(out)


def parabolic_index(lam: GQ, q: int) -> GQ:
    """Return Res dw/(w - g_lambda^q(w)) exactly over Q(i).

    The routine deliberately supports only inputs representable by GQ.  A
    general p/q root of unity belongs to a cyclotomic extension and is a
    separate kernel boundary.
    """
    if q < 1 or power(lam, q) != ONE:
        raise ValueError("lambda must be an exact q-th root of unity")

    order = 2 * q + 1
    iterate = germ_iterate(lam, q, order)

    identity: Jet = (ZERO, ONE) + (ZERO,) * (order - 1)
    difference = tuple(a - b for a, b in zip(identity, iterate))

    if any(not coefficient.is_zero() for coefficient in difference[: q + 1]):
        raise ArithmeticError("parabolic multiplicity is below q+1")

    p_coeffs = difference[q + 1 : 2 * q + 2]
    if len(p_coeffs) != q + 1 or p_coeffs[0].is_zero():
        raise ArithmeticError("insufficient jet order for index reconstruction")
    return reciprocal_series(p_coeffs, q)[q]


def fixed_point(lam: GQ) -> GQ:
    return lam.scale(F(1, 2))


def mandelbrot_parameter(lam: GQ) -> GQ:
    return lam.scale(F(1, 2)) - (lam * lam).scale(F(1, 4))


LOW_Q_FIXTURES = (
    (ONE, 1, GQ.of(0)),
    (-ONE, 2, GQ.of(F(1, 8))),
    (I, 4, GQ(F(1447, 4624), F(-365, 4624))),
    (-I, 4, GQ(F(1447, 4624), F(365, 4624))),
)
