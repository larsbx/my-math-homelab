"""Exact finite identities behind normalized-defect reconstruction.

The window helpers return two algebraically equal sides. They retain all
terminal terms and do not determine an infinite limit or certify a witness.
The trial parameters need not be the limits in the manuscript theorem.
"""

from fractions import Fraction
from typing import Sequence

Exact = int | Fraction


def _fraction(value: Exact) -> Fraction:
    if not isinstance(value, (int, Fraction)):
        raise TypeError("use integers or Fraction, never floating point")
    return Fraction(value)


def _values(values: Sequence[Exact]) -> tuple[Fraction, ...]:
    return tuple(_fraction(value) for value in values)


def _window(length: int, start: int, stop: int, extra: int = 0) -> None:
    if not 0 <= start <= stop or stop + extra >= length:
        raise ValueError("invalid finite window or insufficient values")


def normalized_defects(values: Sequence[Exact]) -> tuple[Fraction, ...]:
    """Return (a_n*a_(n+2)-a_(n+1)^2)/a_n on the available prefix."""
    exact = _values(values)
    return tuple(
        (exact[n] * exact[n + 2] - exact[n + 1] ** 2) / exact[n]
        for n in range(len(exact) - 2)
    )


def linear_defect_sides(
    a: Exact, b: Exact, c: Exact, alpha: Exact
) -> tuple[Fraction, Fraction]:
    """Return d_(n+1)-r_n*d_n and delta_n for an arbitrary trial alpha."""
    a, b, c, alpha = map(_fraction, (a, b, c, alpha))
    return (c - alpha * b) - (b / a) * (b - alpha * a), (a * c - b**2) / a


def ratio_telescope(
    values: Sequence[Exact], start: int, stop: int
) -> tuple[Fraction, Fraction]:
    """Return r_stop-r_start and the finite normalized-defect sum."""
    exact = _values(values)
    _window(len(exact), start, stop, extra=1)
    difference = exact[stop + 1] / exact[stop] - exact[start + 1] / exact[start]
    summed = sum(
        (exact[n] * exact[n + 2] - exact[n + 1] ** 2)
        / (exact[n] * exact[n + 1])
        for n in range(start, stop)
    )
    return difference, Fraction(summed)


def scaled_telescope(
    values: Sequence[Exact], alpha: Exact, start: int, stop: int
) -> tuple[Fraction, Fraction]:
    """Return q_stop-q_start and sum d_k/alpha^(k+1), with absolute indices."""
    exact, alpha = _values(values), _fraction(alpha)
    _window(len(exact), start, stop)
    if alpha == 0:
        raise ValueError("alpha must be nonzero")
    difference = exact[stop] / alpha**stop - exact[start] / alpha**start
    summed = sum(
        (exact[n + 1] - alpha * exact[n]) / alpha ** (n + 1)
        for n in range(start, stop)
    )
    return difference, Fraction(summed)


def backward_error_window(
    values: Sequence[Exact], alpha: Exact, amplitude: Exact, start: int, stop: int
) -> tuple[Fraction, Fraction]:
    """Return e_start and alpha^(start-stop)*e_stop minus the finite d sum.

    In particular, the terminal contribution is not dropped or interpreted
    as small from finite data. An arbitrary amplitude is allowed.
    """
    exact = _values(values)
    alpha, amplitude = _fraction(alpha), _fraction(amplitude)
    _window(len(exact), start, stop)
    if alpha == 0:
        raise ValueError("alpha must be nonzero")
    error = exact[start] - amplitude * alpha**start
    terminal = alpha ** (start - stop) * (exact[stop] - amplitude * alpha**stop)
    summed = sum(
        alpha ** (start - n - 1) * (exact[n + 1] - alpha * exact[n])
        for n in range(start, stop)
    )
    return error, terminal - summed
