"""Order-sensitive degree-2 constraints for balanced-pair factorization.

The signed K2 intertwiner remembers the difference between the two sides of a
balanced state, but its child cross-terms cancel and therefore it forgets child
order.  Exact word factorization retains one additional degree-2 datum.

For a word w define its antisymmetric ordered-pair area

    area(w) = (N12-N21, N13-N31, N23-N32) in Lambda^2 Z^3.

For a balanced state T=(u,v), set

    H(T) = area(u)+area(v).

If the actual inflated pair sigma(T) factors, in order, into normalized child
states R_1,...,R_m (orientation signs arbitrary), then

    Lambda^2(M) H(T) + 2 C_sigma p(T)
      = sum_r H(R_r) + 2 sum_{r<s} p(R_r) wedge p(R_s),

where C_sigma has columns area(sigma(a)) and p(T) is the common Parikh vector.

The identity is exact over Z.  Unlike the K2 signed intertwiner, the final
cross term depends on the *ordered child word*.  It is therefore a finite
necessary condition for a proposed signed derived substitution to be the actual
zero-return factorization.
"""

from __future__ import annotations

from typing import Sequence

from .bpa import State, Substitution, alphabet_size, children, parikh
from .defect_intertwiner import exterior_square, k2_wedge, n2
from .fixed_vector import matvec as _matvec
from .intertwiner import IntMatrix, substitution_incidence

Area = tuple[int, int, int]


def word_area(word: Sequence[int]) -> Area:
    """Return (N12-N21, N13-N31, N23-N32) for a three-letter word."""
    full = n2(word, 3)
    return (
        full[1] - full[3],
        full[2] - full[6],
        full[5] - full[7],
    )


def wedge(x: Sequence[int], y: Sequence[int]) -> Area:
    """Exterior product in basis e1^e2,e1^e3,e2^e3."""
    if len(x) != 3 or len(y) != 3:
        raise ValueError("wedge currently expects two length-three vectors")
    return (
        x[0] * y[1] - x[1] * y[0],
        x[0] * y[2] - x[2] * y[0],
        x[1] * y[2] - x[2] * y[1],
    )


def state_midarea(state: State) -> Area:
    """H(T)=area(u)+area(v)."""
    u, v = state
    au = word_area(u)
    av = word_area(v)
    return tuple(au[i] + av[i] for i in range(3))  # type: ignore[return-value]


def state_area_difference(state: State) -> Area:
    """area(u)-area(v), which equals 2*K2(T) for a balanced state."""
    u, v = state
    au = word_area(u)
    av = word_area(v)
    return tuple(au[i] - av[i] for i in range(3))  # type: ignore[return-value]


def substitution_internal_area(sigma: Substitution) -> IntMatrix:
    """Columns are area(sigma(a)); currently for a three-letter alphabet."""
    if alphabet_size(sigma) != 3:
        raise ValueError("internal-area implementation currently requires three letters")
    cols = tuple(word_area(sigma[a]) for a in (1, 2, 3))
    return tuple(tuple(cols[j][i] for j in range(3)) for i in range(3))


def substitution_area(word: Sequence[int], sigma: Substitution) -> Area:
    """Compute area(sigma(word)) using the affine exterior-square formula."""
    if alphabet_size(sigma) != 3:
        raise ValueError("substitution_area currently requires three letters")
    m = substitution_incidence(sigma)
    ext = exterior_square(m)
    internal = substitution_internal_area(sigma)
    a = word_area(word)
    p = parikh(word, 3)
    linear = _matvec(ext, a)
    correction = _matvec(internal, p)
    return tuple(linear[i] + correction[i] for i in range(3))  # type: ignore[return-value]


def ordered_cross_area(child_states: Sequence[State]) -> Area:
    """sum_{r<s} p(R_r) wedge p(R_s), retaining child order."""
    parikhs = [parikh(state[0], 3) for state in child_states]
    out = [0, 0, 0]
    for r in range(len(parikhs)):
        for s in range(r + 1, len(parikhs)):
            term = wedge(parikhs[r], parikhs[s])
            for i in range(3):
                out[i] += term[i]
    return tuple(out)  # type: ignore[return-value]


def midarea_factorization_residual(
    sigma: Substitution,
    parent: State,
    child_states: Sequence[State],
) -> Area:
    """Left minus right side of the exact mid-area factorization identity.

    Orientation signs are intentionally absent: swapping a child exchanges its
    two side words and leaves H(child) and its Parikh vector unchanged.
    """
    if alphabet_size(sigma) != 3:
        raise ValueError("mid-area implementation currently requires three letters")
    p = parikh(parent[0], 3)
    if p != parikh(parent[1], 3):
        raise ValueError("parent must be balanced")
    for child in child_states:
        if parikh(child[0], 3) != parikh(child[1], 3):
            raise ValueError("every child must be balanced")

    ext = exterior_square(substitution_incidence(sigma))
    internal = substitution_internal_area(sigma)
    h_parent = state_midarea(parent)
    left_linear = _matvec(ext, h_parent)
    left_internal = _matvec(internal, p)
    left = tuple(left_linear[i] + 2 * left_internal[i] for i in range(3))

    child_sum = [0, 0, 0]
    for child in child_states:
        h = state_midarea(child)
        for i in range(3):
            child_sum[i] += h[i]
    cross = ordered_cross_area(child_states)
    right = tuple(child_sum[i] + 2 * cross[i] for i in range(3))
    return tuple(left[i] - right[i] for i in range(3))  # type: ignore[return-value]


def actual_midarea_residual(sigma: Substitution, parent: State) -> Area:
    """Residual on the true zero-return factorization; theorem says it is zero."""
    return midarea_factorization_residual(sigma, parent, children(sigma, parent))


def verify_actual_midarea_identity(sigma: Substitution, parent: State) -> bool:
    return actual_midarea_residual(sigma, parent) == (0, 0, 0)


def midarea_system_residuals(
    sigma: Substitution,
    states: Sequence[State],
    child_words: Sequence[Sequence[int]],
) -> tuple[Area, ...]:
    """Residuals for a proposed ordered derived substitution on ``states``."""
    if len(states) != len(child_words):
        raise ValueError("one proposed child word is required per state")
    out: list[Area] = []
    for parent, word in enumerate(child_words):
        if any(child < 0 or child >= len(states) for child in word):
            raise ValueError("proposed child index lies outside state set")
        out.append(
            midarea_factorization_residual(
                sigma,
                states[parent],
                tuple(states[child] for child in word),
            )
        )
    return tuple(out)


def verify_k2_area_relation(state: State) -> bool:
    q = k2_wedge(state)
    return state_area_difference(state) == tuple(2 * x for x in q)
