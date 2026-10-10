"""Exact Cayley–Dickson arithmetic over Q under one fixed doubling convention.

Convention ``cayley-dickson/v1`` (docs/n1-specification.md, section 1):

    A_0 = Q,  A_k = A_{k-1} ⊕ A_{k-1} with parameter g_k,
    (a, b)(c, d) = (ac + g_k · conj(d) b,  d a + b conj(c)),
    conj(a, b)   = (conj(a), -b).

An element of A_n is a tuple of 2^n Fractions; the first half is the A_{n-1}
component. With parameters (a_1, a_2) the algebra A_2 is the quaternion
algebra (a_1, a_2)_Q: i = e_1, j = e_2, i^2 = a_1, j^2 = a_2, ij = -ji = e_3.
A_{n-1} embeds in A_n as (x, 0). Pure functions on immutable tuples.
"""

from __future__ import annotations

from fractions import Fraction

Element = tuple[Fraction, ...]
Params = tuple[Fraction, ...]


def zero(n: int) -> Element:
    return (Fraction(0),) * (1 << n)


def add(x: Element, y: Element) -> Element:
    return tuple(a + b for a, b in zip(x, y, strict=True))


def scale(g: Fraction, x: Element) -> Element:
    return tuple(g * a for a in x)


def conj(x: Element) -> Element:
    if len(x) == 1:
        return x
    h = len(x) // 2
    return conj(x[:h]) + tuple(-b for b in x[h:])


def mul(x: Element, y: Element, params: Params) -> Element:
    """The product of x and y in A_n, n = len(params)."""
    if len(x) != 1 << len(params) or len(y) != len(x):
        raise ValueError("element length must be 2^len(params)")
    if not params:
        return (x[0] * y[0],)
    h, g, p = len(x) // 2, params[-1], params[:-1]
    a, b, c, d = x[:h], x[h:], y[:h], y[h:]
    return add(mul(a, c, p), scale(g, mul(conj(d), b, p))) + add(mul(d, a, p), mul(b, conj(c), p))


def embed(x: Element, n: int) -> Element:
    """x ∈ A_k as an element of A_n (n ≥ k) via the iterated (x, 0) inclusion."""
    if len(x) > 1 << n:
        raise ValueError("cannot embed into a smaller algebra")
    return tuple(x) + zero(n)[len(x):]
