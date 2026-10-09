"""Fixed-dimension integer vector arithmetic: the oracle, in one place.

The canonical implementation of this kernel is Mojo, in
`kernel/finite_linear_algebra/integer_vector.mojo` (vendored; AGENTS.md: Mojo is canonical, Python is an
oracle). This module is the independent cross-check, and the reason it exists
as a module rather than as a private helper in each caller is that four callers
had four copies of it -- `prefix_difference`, `prefix_ancestry`,
`orientation_spectrum` and `factorization_degree2` -- which is four chances for
the oracle to disagree with itself about the same sum.

Kept deliberately in its generic, obvious form. An oracle earns its keep by
being easy to read against the definition, not by being fast: a
dimension-specialised branch here would add a second path taken by exactly the
dimensions the corpus actually uses, which is the worst place for an
unverified shortcut. Performance work belongs in the canonical kernel, where
`kernel/integer_vector_bench.mojo` measures it.

Python's `int` is arbitrary precision, so nothing here can overflow. The Mojo
kernel is 64-bit and raises where an intermediate would leave the range; that
asymmetry is the one documented difference between the two, and it is why the
Mojo side is exact-or-absent rather than exact-or-wrapped.
"""

from __future__ import annotations

from typing import Sequence

Vector = tuple[int, ...]


def add(a: Sequence[int], b: Sequence[int]) -> Vector:
    """`a + b`, entrywise."""
    if len(a) != len(b):
        raise ValueError("vector dimensions differ")
    return tuple(x + y for x, y in zip(a, b))


def sub(a: Sequence[int], b: Sequence[int]) -> Vector:
    """`a - b`, entrywise."""
    if len(a) != len(b):
        raise ValueError("vector dimensions differ")
    return tuple(x - y for x, y in zip(a, b))


def matvec(matrix: Sequence[Sequence[int]], vector: Sequence[int]) -> Vector:
    """`M v`."""
    if not matrix:
        raise ValueError("matrix has no rows")
    if any(len(row) != len(vector) for row in matrix):
        raise ValueError("matrix/vector dimensions do not agree")
    return tuple(sum(row[j] * vector[j] for j in range(len(vector))) for row in matrix)
