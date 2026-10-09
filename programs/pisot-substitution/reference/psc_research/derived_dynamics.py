"""Graph-period and cyclic-class tools for derived substitutions.

A strict recurrent BPA component gives a finite non-erasing substitution tau_C
whose incidence graph is strongly connected.  This module computes the graph
period h and the standard cyclic decomposition.  For each class, tau_C^h
restricts to a primitive substitution on that class.

The PIP-specific aperiodicity argument is mathematical and documented in
``docs/c4-derived-recognizability.md``: if one such primitive restriction were
periodic, a power of its Perron eigenvalue beta^h would be an integer, which is
impossible for a non-rational Pisot beta because every algebraic conjugate would
have the same positive integer power while having modulus < 1.
"""

from __future__ import annotations

from collections import deque
from math import gcd
from typing import Hashable, Mapping, TypeVar

S = TypeVar("S", bound=Hashable)
DerivedMap = Mapping[S, tuple[S, ...]]


def validate_non_erasing_substitution(tau: DerivedMap[S]) -> None:
    if not tau:
        raise ValueError("derived substitution must be nonempty")
    alphabet = set(tau)
    for state, word in tau.items():
        if not word:
            raise ValueError(f"derived substitution erases {state!r}")
        unknown = [child for child in word if child not in alphabet]
        if unknown:
            raise ValueError(f"derived word references states outside alphabet: {unknown!r}")


def derived_adjacency(tau: DerivedMap[S]) -> dict[S, frozenset[S]]:
    validate_non_erasing_substitution(tau)
    return {state: frozenset(word) for state, word in tau.items()}


def _reachable(adjacency: Mapping[S, frozenset[S]], root: S) -> set[S]:
    seen = {root}
    stack = [root]
    while stack:
        state = stack.pop()
        for child in adjacency[state]:
            if child not in seen:
                seen.add(child)
                stack.append(child)
    return seen


def is_strongly_connected(tau: DerivedMap[S]) -> bool:
    adjacency = derived_adjacency(tau)
    alphabet = set(adjacency)
    root = next(iter(alphabet))
    if _reachable(adjacency, root) != alphabet:
        return False
    reverse: dict[S, set[S]] = {state: set() for state in alphabet}
    for parent, children in adjacency.items():
        for child in children:
            reverse[child].add(parent)
    frozen_reverse = {state: frozenset(parents) for state, parents in reverse.items()}
    return _reachable(frozen_reverse, root) == alphabet


def graph_period(tau: DerivedMap[S]) -> int:
    """GCD of directed cycle lengths for a strongly connected substitution graph.

    For any rooted distance labeling d, the period is

        gcd{ d(u)+1-d(v) : edge u->v }.

    Absolute values are taken inside the gcd.  This is the standard period of an
    irreducible nonnegative matrix / strongly connected directed graph.
    """
    adjacency = derived_adjacency(tau)
    if not is_strongly_connected(tau):
        raise ValueError("graph period requires a strongly connected substitution")
    root = next(iter(adjacency))
    distance: dict[S, int] = {root: 0}
    queue: deque[S] = deque([root])
    while queue:
        parent = queue.popleft()
        for child in adjacency[parent]:
            if child not in distance:
                distance[child] = distance[parent] + 1
                queue.append(child)
    period = 0
    for parent, children in adjacency.items():
        for child in children:
            period = gcd(period, abs(distance[parent] + 1 - distance[child]))
    if period == 0:
        raise AssertionError("strongly connected non-erasing graph has no cycle period")
    return period


def cyclic_class_labels(tau: DerivedMap[S]) -> dict[S, int]:
    """Return the canonical root-relative class in Z/hZ for each state."""
    adjacency = derived_adjacency(tau)
    h = graph_period(tau)
    root = next(iter(adjacency))
    labels: dict[S, int] = {root: 0}
    queue: deque[S] = deque([root])
    while queue:
        parent = queue.popleft()
        expected = (labels[parent] + 1) % h
        for child in adjacency[parent]:
            if child not in labels:
                labels[child] = expected
                queue.append(child)
            elif labels[child] != expected:
                raise AssertionError("edge violates cyclic-class labeling")
    return labels


def apply_derived_generic(tau: DerivedMap[S], word: tuple[S, ...]) -> tuple[S, ...]:
    validate_non_erasing_substitution(tau)
    out: list[S] = []
    for state in word:
        if state not in tau:
            raise ValueError("word contains symbol outside derived substitution")
        out.extend(tau[state])
    return tuple(out)


def iterate_derived_generic(tau: DerivedMap[S], state: S, depth: int) -> tuple[S, ...]:
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    if state not in tau:
        raise ValueError("state lies outside derived substitution")
    word = (state,)
    for _ in range(depth):
        word = apply_derived_generic(tau, word)
    return word


def cyclic_power_restrictions(tau: DerivedMap[S]) -> tuple[dict[S, tuple[S, ...]], ...]:
    """Restrict tau^h to each cyclic class of a strongly connected graph."""
    labels = cyclic_class_labels(tau)
    h = graph_period(tau)
    classes: list[list[S]] = [[] for _ in range(h)]
    for state, label in labels.items():
        classes[label].append(state)

    restrictions: list[dict[S, tuple[S, ...]]] = []
    for class_index, states in enumerate(classes):
        state_set = set(states)
        restricted: dict[S, tuple[S, ...]] = {}
        for state in states:
            word = iterate_derived_generic(tau, state, h)
            if any(child not in state_set for child in word):
                raise AssertionError("tau^h leaves its cyclic class")
            restricted[state] = word
        if graph_period(restricted) != 1:
            raise AssertionError("cyclic-class power restriction is not primitive")
        restrictions.append(restricted)
    return tuple(restrictions)


def primitive_by_graph(tau: DerivedMap[S]) -> bool:
    """Exact graph criterion for primitivity of a nonnegative incidence matrix."""
    return is_strongly_connected(tau) and graph_period(tau) == 1
