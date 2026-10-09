"""Truncated Taylor jets over `Q(i)`, exactly.

Specification: docs/rational-interval-arithmetic-spec.md, section 1.
Statements: docs/preperiodic-certificates.md, section 4.

A jet of order `m` at a point is the list of coefficients of

```text
g(w + e) = a_0 + a_1 e + ... + a_m e^m    (mod e^(m+1))
```

with every `a_j` an exact Gaussian rational. Pushing the seed jet
`(w, 1, 0, ..., 0)` through `z -> z^2 + c` gives every derivative of `f^n` at
`w` at once, without ever forming a polynomial in `z`: truncated
multiplication is a finite convolution, and that is all the map needs.

This is the coefficient-free way to ask a question that looks like it needs
coefficients. `orbit_derivative` of `reference/preperiodic.py` is the order-one
case of it.
"""

from __future__ import annotations

from gaussian_q import GQ

#: The quadratic map has one parameter and one variable, so a jet is just a
#: tuple. Nothing here is a series: the truncation is the object.
Jet = tuple[GQ, ...]

ZERO = GQ.of(0)
ONE = GQ.of(1)


def constant(value: GQ, order: int) -> Jet:
    """`(value, 0, ..., 0)`: a jet that does not vary."""
    return (value,) + (ZERO,) * order


def seed(point: GQ, order: int) -> Jet:
    """`(point, 1, 0, ..., 0)`: the variable itself, expanded at `point`."""
    return (point, ONE) + (ZERO,) * (order - 1) if order >= 1 else (point,)


def add(left: Jet, right: Jet) -> Jet:
    return tuple(a + b for a, b in zip(left, right))


def sub(left: Jet, right: Jet) -> Jet:
    return tuple(a - b for a, b in zip(left, right))


def convolve(left: Jet, right: Jet) -> Jet:
    """The full product, of length `len(left) + len(right) - 1`.

    Nothing is dropped. `mul` truncates it and a Taylor model keeps the tail
    as an interval instead, which is the whole difference between the two
    (`docs/taylor-models.md`).
    """
    width = len(left) + len(right) - 1
    return tuple(
        sum(
            (left[i] * right[n - i]
             for i in range(max(0, n - len(right) + 1), min(n, len(left) - 1) + 1)),
            ZERO,
        )
        for n in range(width)
    )


def mul(left: Jet, right: Jet) -> Jet:
    """Truncated convolution: `(fg)_n = sum_(i+j=n) f_i g_j`, dropping the rest.

    Dropping is exact, not an approximation. Coefficients above the order are
    not computed wrongly; they are not part of the object.
    """
    return convolve(left, right)[:len(left)]


def step(state: Jet, c: GQ) -> Jet:
    """`z^2 + c` on a jet."""
    return add(mul(state, state), constant(c, len(state) - 1))


def orbit(point: GQ, c: GQ, steps: int, order: int) -> Jet | None:
    """The jet of `f_c^steps` at `point`, to the stated order."""
    if steps < 0 or order < 0:
        return None
    state = seed(point, order)
    for _ in range(steps):
        state = step(state, c)
    return state


def residual(point: GQ, c: GQ, preperiod: int, period: int, order: int) -> Jet | None:
    """The jet of `R^c_{l,k} = f^(l+k) - f^l` at `point`."""
    if preperiod < 0 or period < 1 or order < 0:
        return None
    late = orbit(point, c, preperiod + period, order)
    early = orbit(point, c, preperiod, order)
    return None if late is None or early is None else sub(late, early)


def vanishing_order(state: Jet | None) -> int | None:
    """The least index with a nonzero coefficient, or `None`.

    `None` is a budget that ran out, never a multiplicity: a jet whose
    coefficients all vanish to the order computed says the order is *above*
    that, and says nothing about how far above.
    """
    if state is None:
        return None
    for index, coefficient in enumerate(state):
        if not coefficient.is_zero():
            return index
    return None
