"""Deck-even/odd incidence decomposition for the C4 orientation cover.

For a strict closed nonproductive BPA component, let A count child occurrences
with positive orientation sign and B count occurrences with negative sign. Then

    N = A + B,     S = A - B,

where N is the ordinary derived-substitution incidence and S is its signed
orientation incidence. The oriented double cover has incidence

    N_tilde = [[A, B], [B, A]].

The deck-even sector carries N and the deck-odd sector carries S. The Parikh
factor is deck-even and annihilates the entire odd sector.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Sequence

from .bpa import State, Substitution
from .fixed_vector import matvec as _matvec
from .intertwiner import IntMatrix, build_scc_intertwiner, matmul
from .orientation import OrientedEdge, strict_orientation_edges


@dataclass(frozen=True)
class OrientationIncidence:
    states: tuple[State, ...]
    positive: IntMatrix
    negative: IntMatrix
    unsigned: IntMatrix
    signed: IntMatrix
    cover: IntMatrix
    parikh_cover: IntMatrix
    substitution_incidence: IntMatrix


def _combine(a: Sequence[Sequence[int]], b: Sequence[Sequence[int]], sign: int) -> IntMatrix:
    if len(a) != len(b) or any(len(x) != len(y) for x, y in zip(a, b)):
        raise ValueError("matrix dimensions do not agree")
    return tuple(
        tuple(x + sign * y for x, y in zip(row_a, row_b))
        for row_a, row_b in zip(a, b)
    )


def _block_cover(a: IntMatrix, b: IntMatrix) -> IntMatrix:
    n = len(a)
    if n == 0 or len(b) != n or any(len(row) != n for row in a + b):
        raise ValueError("orientation blocks must be nonempty square matrices of equal size")
    top = tuple(tuple(a[i]) + tuple(b[i]) for i in range(n))
    bottom = tuple(tuple(b[i]) + tuple(a[i]) for i in range(n))
    return top + bottom


def build_orientation_incidence(
    sigma: Substitution, comp: Sequence[State]
) -> OrientationIncidence:
    """Construct A, B, N, S and the oriented-cover incidence exactly."""
    base = build_scc_intertwiner(sigma, comp)
    states = base.states
    index = {state: i for i, state in enumerate(states)}
    n = len(states)
    positive = [[0] * n for _ in range(n)]
    negative = [[0] * n for _ in range(n)]

    for edge in strict_orientation_edges(sigma, states):
        row = index[edge.child]
        col = index[edge.parent]
        if edge.sign == 1:
            positive[row][col] += 1
        else:
            negative[row][col] += 1

    a = tuple(tuple(row) for row in positive)
    b = tuple(tuple(row) for row in negative)
    unsigned = _combine(a, b, 1)
    signed = _combine(a, b, -1)
    if unsigned != base.incidence:
        raise AssertionError("signed occurrence counts do not recover N_C")

    cover = _block_cover(a, b)
    parikh_cover = tuple(tuple(row) + tuple(row) for row in base.parikh_matrix)
    data = OrientationIncidence(
        states=states,
        positive=a,
        negative=b,
        unsigned=unsigned,
        signed=signed,
        cover=cover,
        parikh_cover=parikh_cover,
        substitution_incidence=base.substitution_incidence,
    )
    if not verify_deck_decomposition(data):
        raise AssertionError("orientation cover failed even/odd decomposition checks")
    return data


def verify_deck_decomposition(data: OrientationIncidence) -> bool:
    """Check the even=N and odd=S actions plus Parikh-cover intertwining."""
    n = len(data.states)
    if len(data.cover) != 2 * n:
        return False

    for j in range(n):
        basis = tuple(1 if i == j else 0 for i in range(n))
        even = basis + basis
        odd = basis + tuple(-x for x in basis)
        n_image = _matvec(data.unsigned, basis)
        s_image = _matvec(data.signed, basis)
        if _matvec(data.cover, even) != n_image + n_image:
            return False
        if _matvec(data.cover, odd) != s_image + tuple(-x for x in s_image):
            return False
        if any(x != 0 for x in _matvec(data.parikh_cover, odd)):
            return False

    return matmul(data.parikh_cover, data.cover) == matmul(
        data.substitution_incidence, data.parikh_cover
    )


def parallel_signs_are_consistent(edges: Sequence[OrientedEdge]) -> bool:
    """Whether all parallel parent->child occurrences have the same sign.

    Mixed signs force strict entrywise cancellation in S=A-B relative to
    N=A+B, which is a sufficient condition for a strict Perron comparison when
    N is irreducible.
    """
    signs: dict[tuple[State, State], int] = {}
    for edge in edges:
        key = (edge.parent, edge.child)
        previous = signs.get(key)
        if previous is None:
            signs[key] = edge.sign
        elif previous != edge.sign:
            return False
    return True


def solve_constant_phase_gauge(
    states: Sequence[State], edges: Sequence[OrientedEdge], phase: int
) -> dict[State, int] | None:
    """Solve g(child)=phase*sign(edge)*g(parent) for phase in {+1,-1}.

    `phase=+1` is ordinary cocycle triviality. `phase=-1` is the anti-gauge
    case in which, after reorienting vertices, every child occurrence flips
    orientation once per derived-substitution step.
    """
    if phase not in (-1, 1):
        raise ValueError("phase must be +/-1")
    state_set = set(states)
    adjacency: dict[State, list[tuple[State, int]]] = {state: [] for state in states}
    for edge in edges:
        if edge.parent not in state_set or edge.child not in state_set:
            raise ValueError("edge endpoint lies outside supplied state set")
        effective = phase * edge.sign
        adjacency[edge.parent].append((edge.child, effective))
        adjacency[edge.child].append((edge.parent, effective))

    gauge: dict[State, int] = {}
    for root in states:
        if root in gauge:
            continue
        gauge[root] = 1
        stack = [root]
        while stack:
            parent = stack.pop()
            for child, effective in adjacency[parent]:
                required = gauge[parent] * effective
                if child not in gauge:
                    gauge[child] = required
                    stack.append(child)
                elif gauge[child] != required:
                    return None
    return gauge
