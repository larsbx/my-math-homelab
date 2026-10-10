"""Invariant-factor decomposition of a small finite abelian group given as a set with an operation.

`abelian_structure(elements, add, zero)` returns (basis, orders) with orders n_1 | ... wait, in the
order produced n_1 = exp(G) and each later order divides the previous one, G = ⊕ <b_i>.

Algorithm (the constructive proof of the structure theorem): b_1 = an element of maximal order n_1;
Q = G / <b_1> with canonical coset representatives; decompose Q recursively into <y_2>, ..., <y_r>
with orders m_i; lift: m_i y_i = c_i b_1 with m_i | c_i (since n_1 y_i = 0 and n_1 = exp G), and
replace y_i by y_i - (c_i / m_i) b_1, which has order exactly m_i and lies in a complement of <b_1>.
No greedy choice ever needs a direct complement to exist among the raw elements.
"""
from __future__ import annotations

from typing import Callable, Iterable


def _mul(add, zero, n: int, g):
    out = zero
    for _ in range(n):
        out = add(out, g)
    return out


def _order(add, zero, g) -> int:
    n, h = 1, g
    while h != zero:
        h, n = add(h, g), n + 1
    return n


def abelian_structure(elements: Iterable, add: Callable, zero) -> tuple[list, list[int]]:
    elems = list(elements)
    if len(elems) == 1:
        return [], []
    position = {g: i for i, g in enumerate(elems)}  # elements need not be comparable: order by position
    b1 = max(elems, key=lambda g: _order(add, zero, g))
    n1 = _order(add, zero, b1)
    multiples = [_mul(add, zero, i, b1) for i in range(n1)]
    canon = {}
    for g in elems:
        if g in canon:
            continue
        coset = [add(g, m) for m in multiples]
        rep = min(coset, key=position.get)
        for h in coset:
            canon[h] = rep
    reps = sorted(set(canon.values()), key=position.get)
    q_add = lambda a, b: canon[add(a, b)]  # noqa: E731
    q_zero = canon[zero]
    q_basis, q_orders = abelian_structure(reps, q_add, q_zero)
    basis, orders = [b1], [n1]
    for y, m in zip(q_basis, q_orders):
        my = _mul(add, zero, m, y)
        c = multiples.index(my)  # m y = c b1
        if c % m:
            raise AssertionError("lifting failed: m does not divide c")  # impossible when n1 = exp(G)
        y_corrected = add(y, _mul(add, zero, (n1 - c // m) % n1, b1))
        if _order(add, zero, y_corrected) != m:
            raise AssertionError("corrected generator has the wrong order")
        basis.append(y_corrected)
        orders.append(m)
    return basis, orders
