"""A near-realizable three-state degree-2 obstruction template.

The template deliberately passes the current linear-algebra, orientation,
endpoint-signature, actual-substitution-endpoint, and per-state balanced-word
tests. It fails only when the chosen substitution is required to factor each
inflated balanced pair into the proposed signed child states.

This is a falsification artifact for proof strategies, not a PSC counterexample.
"""

from __future__ import annotations

from .bpa import (
    State,
    Substitution,
    apply_substitution,
    decompose_pair,
    endpoint_maps,
    normalize_state,
    parikh,
)
from .defect_intertwiner import exterior_square, k2_wedge
from .endpoint_core import class_of, synchronizes
from .intertwiner import IntMatrix, matmul, substitution_incidence


SIGMA: Substitution = {
    1: (2,),
    2: (3,),
    3: (1, 3, 2),
}

N: IntMatrix = (
    (0, 0, 1),
    (1, 0, 1),
    (0, 1, 1),
)

S: IntMatrix = (
    (0, 0, -1),
    (1, 0, 1),
    (0, -1, -1),
)

A: IntMatrix = (
    (0, 0, 0),
    (1, 0, 1),
    (0, 0, 0),
)

B: IntMatrix = (
    (0, 0, 1),
    (0, 0, 0),
    (0, 1, 1),
)

P: IntMatrix = (
    (1, 1, 2),
    (1, 2, 3),
    (1, 2, 4),
)

Q: IntMatrix = (
    (1, -1, 1),
    (1, 1, 3),
    (-1, 3, 3),
)

STATES: tuple[State, ...] = (
    ((1, 3, 2), (2, 3, 1)),
    ((2, 1, 2, 3, 3), (3, 1, 2, 3, 2)),
    ((1, 2, 2, 3, 1, 3, 3, 3, 2), (3, 1, 2, 3, 3, 2, 2, 1, 3)),
)

# Ordered signed child words for the abstract derived substitution.
# Each pair is (child_index, orientation_sign).
SIGNED_CHILDREN: tuple[tuple[tuple[int, int], ...], ...] = (
    ((1, 1),),
    ((2, -1),),
    ((0, -1), (1, 1), (2, -1)),
)


def _add(a: IntMatrix, b: IntMatrix) -> IntMatrix:
    return tuple(tuple(x + y for x, y in zip(ra, rb)) for ra, rb in zip(a, b))


def _sub(a: IntMatrix, b: IntMatrix) -> IntMatrix:
    return tuple(tuple(x - y for x, y in zip(ra, rb)) for ra, rb in zip(a, b))


def state_parikh_matrix() -> IntMatrix:
    cols = tuple(parikh(state[0], 3) for state in STATES)
    return tuple(tuple(col[i] for col in cols) for i in range(3))


def state_k2_matrix() -> IntMatrix:
    cols = tuple(k2_wedge(state) for state in STATES)
    return tuple(tuple(col[i] for col in cols) for i in range(3))


def states_are_irreducible() -> bool:
    """No state has a proper balanced prefix cut."""
    for u, v in STATES:
        for k in range(1, len(u)):
            if parikh(u[:k], 3) == parikh(v[:k], 3):
                return False
    return True


def signed_counts_from_words() -> tuple[IntMatrix, IntMatrix]:
    positive = [[0] * 3 for _ in range(3)]
    negative = [[0] * 3 for _ in range(3)]
    for parent, word in enumerate(SIGNED_CHILDREN):
        for child, sign in word:
            if sign == 1:
                positive[child][parent] += 1
            else:
                negative[child][parent] += 1
    return (
        tuple(tuple(row) for row in positive),
        tuple(tuple(row) for row in negative),
    )


def endpoint_maps_zero_based() -> tuple[tuple[int, ...], tuple[int, ...]]:
    plus, minus = endpoint_maps(SIGMA)
    return (
        tuple(plus[a] - 1 for a in sorted(plus)),
        tuple(minus[a] - 1 for a in sorted(minus)),
    )


def endpoint_type_pair() -> tuple[tuple[int, ...], tuple[int, ...]]:
    plus, minus = endpoint_maps_zero_based()
    return class_of(plus).representative, class_of(minus).representative


def endpoint_constraints_hold() -> bool:
    """Actual G/F endpoint maps fit the synthetic child selectors exactly."""
    plus, minus = endpoint_maps_zero_based()
    plus_pairs = tuple((state[0][0] - 1, state[1][0] - 1) for state in STATES)
    minus_pairs = tuple((state[0][-1] - 1, state[1][-1] - 1) for state in STATES)

    if any(synchronizes(plus, a, b) for a, b in plus_pairs):
        return False
    if any(synchronizes(minus, a, b) for a, b in minus_pairs):
        return False

    first_child = tuple(word[0][0] for word in SIGNED_CHILDREN)
    last_child = tuple(word[-1][0] for word in SIGNED_CHILDREN)

    for parent in range(3):
        a, b = plus_pairs[parent]
        if frozenset((plus[a], plus[b])) != frozenset(plus_pairs[first_child[parent]]):
            return False
        a, b = minus_pairs[parent]
        if frozenset((minus[a], minus[b])) != frozenset(minus_pairs[last_child[parent]]):
            return False
    return True


def actual_signed_children(state: State) -> tuple[tuple[State, int], ...]:
    u, v = state
    raw = decompose_pair(apply_substitution(SIGMA, u), apply_substitution(SIGMA, v), 3)
    out: list[tuple[State, int]] = []
    for child in raw:
        normalized = normalize_state(child)
        sign = 1 if child == normalized else -1
        out.append((normalized, sign))
    return tuple(out)


def proposed_signed_children_as_states(parent: int) -> tuple[tuple[State, int], ...]:
    return tuple((STATES[child], sign) for child, sign in SIGNED_CHILDREN[parent])


def factorization_realizes_template() -> bool:
    return all(
        actual_signed_children(STATES[parent]) == proposed_signed_children_as_states(parent)
        for parent in range(3)
    )


def actual_factorization_has_coincidence() -> bool:
    return any(
        child[0] == child[1]
        for state in STATES
        for child, _sign in actual_signed_children(state)
    )


def verify_synthetic_template() -> bool:
    """Check every constraint claimed before the deliberate factorization failure."""
    if substitution_incidence(SIGMA) != N:
        return False
    if _add(A, B) != N or _sub(A, B) != S:
        return False
    pos, neg = signed_counts_from_words()
    if pos != A or neg != B:
        return False
    if state_parikh_matrix() != P or state_k2_matrix() != Q:
        return False
    if not states_are_irreducible():
        return False
    if matmul(P, N) != matmul(N, P):
        return False
    if matmul(Q, S) != matmul(exterior_square(N), Q):
        return False
    if endpoint_type_pair() != ((1, 2, 0), (1, 0, 0)):
        return False
    if not endpoint_constraints_hold():
        return False
    return not factorization_realizes_template() and actual_factorization_has_coincidence()
