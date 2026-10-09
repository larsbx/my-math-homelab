"""Exact Parikh intertwiners for closed nonproductive BPA components.

For a strict closed nonproductive SCC C, reduction of sigma(T) for T in C
contains only states of C.  This defines a derived substitution with incidence
matrix N_C.  If P_C stores the common Parikh vector of each balanced-pair state,
then exactly

    P_C N_C = M_sigma P_C.

The routines here construct and verify that identity using only integer/rational
arithmetic.  They do not assert that such an SCC exists in the PIP regime.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Sequence

from .bpa import State, Substitution, alphabet_size, children, parikh

IntMatrix = tuple[tuple[int, ...], ...]


@dataclass(frozen=True)
class SCCIntertwiner:
    states: tuple[State, ...]
    incidence: IntMatrix  # N_C, rows child states / columns parent states
    parikh_matrix: IntMatrix  # P_C, 3 x |C|
    substitution_incidence: IntMatrix  # M_sigma, 3 x 3


def substitution_incidence(sigma: Substitution) -> IntMatrix:
    """Return M[i,j] = number of occurrences of letter i+1 in sigma(j+1)."""
    size = alphabet_size(sigma)
    rows = [[0] * size for _ in range(size)]
    for j in range(1, size + 1):
        for a in sigma[j]:
            rows[a - 1][j - 1] += 1
    return tuple(tuple(row) for row in rows)


def matmul(a: Sequence[Sequence[int]], b: Sequence[Sequence[int]]) -> IntMatrix:
    """Integer matrix product with dimension checks."""
    if not a or not b:
        raise ValueError("matrices must be nonempty")
    a_cols = len(a[0])
    if any(len(row) != a_cols for row in a):
        raise ValueError("left matrix is ragged")
    b_cols = len(b[0])
    if any(len(row) != b_cols for row in b):
        raise ValueError("right matrix is ragged")
    if a_cols != len(b):
        raise ValueError("incompatible matrix dimensions")
    return tuple(
        tuple(sum(a[i][k] * b[k][j] for k in range(a_cols)) for j in range(b_cols))
        for i in range(len(a))
    )


def rational_rank(matrix: Sequence[Sequence[int]]) -> int:
    """Exact row rank over Q by Fraction Gaussian elimination."""
    if not matrix:
        return 0
    width = len(matrix[0])
    if any(len(row) != width for row in matrix):
        raise ValueError("matrix is ragged")
    rows = [[Fraction(x) for x in row] for row in matrix]
    rank = 0
    for col in range(width):
        pivot = next((i for i in range(rank, len(rows)) if rows[i][col] != 0), None)
        if pivot is None:
            continue
        rows[rank], rows[pivot] = rows[pivot], rows[rank]
        pivot_value = rows[rank][col]
        rows[rank] = [x / pivot_value for x in rows[rank]]
        for i in range(len(rows)):
            if i == rank or rows[i][col] == 0:
                continue
            factor = rows[i][col]
            rows[i] = [rows[i][j] - factor * rows[rank][j] for j in range(width)]
        rank += 1
        if rank == len(rows):
            break
    return rank


def build_scc_intertwiner(sigma: Substitution, comp: Sequence[State]) -> SCCIntertwiner:
    """Construct P_C and N_C for a *strict* closed nonproductive component.

    Strict means every irreducible child of every state is noncoincident and
    belongs to ``comp``.  If a coincidence child or an outside child occurs,
    the component is not the no-leakage counterexample object for which the
    intertwining theorem is stated, so this function raises ``ValueError``.
    """
    if not comp:
        raise ValueError("component must be nonempty")
    states = tuple(comp)
    index = {state: i for i, state in enumerate(states)}
    if len(index) != len(states):
        raise ValueError("component contains duplicate states")

    n = len(states)
    incidence = [[0] * n for _ in range(n)]
    size = alphabet_size(sigma)
    p = [[0] * n for _ in range(size)]

    for j, state in enumerate(states):
        u, v = state
        if u == v:
            raise ValueError("component contains a coincidence state")
        pv = parikh(u, size)
        if pv != parikh(v, size):
            raise ValueError("component contains an unbalanced state")
        for row, value in enumerate(pv):
            p[row][j] = value

        for child in children(sigma, state):
            cu, cv = child
            if cu == cv:
                raise ValueError("component has a coincidence child")
            if child not in index:
                raise ValueError("component has a noncoincident child outside the component")
            incidence[index[child]][j] += 1

    data = SCCIntertwiner(
        states=states,
        incidence=tuple(tuple(row) for row in incidence),
        parikh_matrix=tuple(tuple(row) for row in p),
        substitution_incidence=substitution_incidence(sigma),
    )
    if not verify_intertwining(data):
        raise AssertionError("constructed SCC data violates P_C N_C = M P_C")
    return data


def verify_intertwining(data: SCCIntertwiner) -> bool:
    """Check P_C N_C = M_sigma P_C exactly."""
    return matmul(data.parikh_matrix, data.incidence) == matmul(
        data.substitution_incidence, data.parikh_matrix
    )
