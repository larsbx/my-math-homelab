"""Orientation cocycle hidden by normalized balanced-pair states.

The BPA identifies (u,v) with (v,u) by lexicographic normalization.  For proof
work this quotient hides one bit of data at every child occurrence: whether the
raw child has the normalized orientation or the swapped orientation.

Those signs form a Z/2 edge cocycle.  On a closed component the cocycle is
trivial exactly when one can choose an orientation for every normalized state so
that every child occurrence preserves the chosen orientation.  Otherwise the
natural object is the oriented double cover.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Mapping, Sequence

from .bpa import (
    State,
    Substitution,
    alphabet_size,
    apply_substitution,
    decompose_pair,
    normalize_state,
)


@dataclass(frozen=True)
class OrientedEdge:
    parent: State
    child: State
    sign: int  # +1 raw child = normalized child; -1 raw child is swapped
    position: int  # child occurrence within the reduction of sigma(parent)

    def __post_init__(self) -> None:
        if self.sign not in (-1, 1):
            raise ValueError("orientation sign must be +/-1")
        if self.position < 0:
            raise ValueError("child position must be nonnegative")


def swap_state(state: State) -> State:
    u, v = state
    return (v, u)


def oriented_children(sigma: Substitution, state: State) -> tuple[tuple[State, int], ...]:
    """Return normalized children together with raw-to-normalized signs."""
    size = alphabet_size(sigma)
    u, v = state
    su = apply_substitution(sigma, u)
    sv = apply_substitution(sigma, v)
    raw = decompose_pair(su, sv, size)
    out: list[tuple[State, int]] = []
    for child in raw:
        normalized = normalize_state(child)
        sign = 1 if child == normalized else -1
        out.append((normalized, sign))
    return tuple(out)


def orientation_edges(sigma: Substitution, comp: Sequence[State]) -> tuple[OrientedEdge, ...]:
    """All signed child occurrences whose normalized child lies in ``comp``.

    For the strict closed component used by C4 every child occurrence is in the
    component, but this routine intentionally filters rather than assuming
    closure so it can also serve as a diagnostic on ordinary recurrent SCCs.
    """
    states = set(comp)
    out: list[OrientedEdge] = []
    for parent in comp:
        for position, (child, sign) in enumerate(oriented_children(sigma, parent)):
            if child in states:
                out.append(OrientedEdge(parent, child, sign, position))
    return tuple(out)


def strict_orientation_edges(
    sigma: Substitution, comp: Sequence[State]
) -> tuple[OrientedEdge, ...]:
    """Signed edges for a strict closed nonproductive component.

    Raises when any child is a coincidence or leaves the component.
    """
    states = set(comp)
    out: list[OrientedEdge] = []
    for parent in comp:
        for position, (child, sign) in enumerate(oriented_children(sigma, parent)):
            u, v = child
            if u == v:
                raise ValueError("component has a coincidence child")
            if child not in states:
                raise ValueError("component has a noncoincident child outside the component")
            out.append(OrientedEdge(parent, child, sign, position))
    return tuple(out)


def solve_orientation_gauge(
    states: Sequence[State], edges: Sequence[OrientedEdge]
) -> dict[State, int] | None:
    """Solve g(child)=g(parent)*sign on every edge.

    Returns one +/-1 gauge per connected component when the cocycle is
    trivializable, otherwise ``None``.  The constraint is symmetric, so the
    propagation graph may be treated as undirected even though child edges are
    directed.
    """
    state_set = set(states)
    adjacency: dict[State, list[tuple[State, int]]] = {state: [] for state in states}
    for edge in edges:
        if edge.parent not in state_set or edge.child not in state_set:
            raise ValueError("edge endpoint lies outside supplied state set")
        adjacency[edge.parent].append((edge.child, edge.sign))
        adjacency[edge.child].append((edge.parent, edge.sign))

    gauge: dict[State, int] = {}
    for root in states:
        if root in gauge:
            continue
        gauge[root] = 1
        stack = [root]
        while stack:
            parent = stack.pop()
            for child, sign in adjacency[parent]:
                required = gauge[parent] * sign
                if child not in gauge:
                    gauge[child] = required
                    stack.append(child)
                elif gauge[child] != required:
                    return None
    return gauge


def cocycle_is_trivial(states: Sequence[State], edges: Sequence[OrientedEdge]) -> bool:
    return solve_orientation_gauge(states, edges) is not None


def lift_edge(edge: OrientedEdge, parent_orientation: int) -> tuple[State, int]:
    """Lift one normalized edge to the oriented double cover."""
    if parent_orientation not in (-1, 1):
        raise ValueError("parent orientation must be +/-1")
    return (edge.child, parent_orientation * edge.sign)


def verify_oriented_factorization(sigma: Substitution, state: State) -> bool:
    """Check that signed normalized children reconstruct sigma(state) exactly."""
    u, v = state
    top: list[int] = []
    bottom: list[int] = []
    for child, sign in oriented_children(sigma, state):
        raw = child if sign == 1 else swap_state(child)
        top.extend(raw[0])
        bottom.extend(raw[1])
    return tuple(top) == apply_substitution(sigma, u) and tuple(bottom) == apply_substitution(sigma, v)
