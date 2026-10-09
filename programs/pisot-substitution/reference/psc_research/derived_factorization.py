"""Derived substitution carried by a strict balanced-pair component.

If C is a finite strict child-closed set of normalized irreducible balanced
states, each state T has an ordered normalized child word tau_C(T). Recursive
balanced-pair factorization then gives exactly

    factor_states(sigma^n(T)) = tau_C^n(T)

for every n. This module makes that word-level statement executable and gives
zero-return boundaries canonical addresses in the derived substitution word.

Side-swap orientation is intentionally omitted here: swapping a raw child does
not change its normalized state label or its physical block length. The Z/2
orientation cocycle remains a separate decoration when raw word identities are
needed.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Mapping, Sequence

from .bpa import (
    State,
    Substitution,
    alphabet_size,
    apply_substitution_n,
    children,
    coincidence_boundaries,
    decompose_pair,
    normalize_state,
    parikh,
)

DerivedWord = tuple[State, ...]
DerivedSubstitution = Mapping[State, DerivedWord]


@dataclass(frozen=True)
class DerivedBoundaryAddress:
    """Canonical location of a physical zero return in tau_C^depth(parent)."""

    depth: int
    physical_cut: int
    block_index: int
    left_state: State | None
    right_state: State | None
    left_context: tuple[State | None, ...]
    right_context: tuple[State | None, ...]


def strict_derived_substitution(
    sigma: Substitution,
    comp: Sequence[State],
) -> dict[State, DerivedWord]:
    """Return tau_C(T)=the ordered normalized children of every strict state."""
    size = alphabet_size(sigma)
    states = {normalize_state(state) for state in comp}
    if not states:
        raise ValueError("strict component must be nonempty")
    tau: dict[State, DerivedWord] = {}
    for state in states:
        u, v = state
        if u == v:
            raise ValueError("strict component contains a coincidence state")
        if parikh(u, size) != parikh(v, size):
            raise ValueError("strict component contains an unbalanced state")
        if coincidence_boundaries(u, v, size) != [0, len(u)]:
            raise ValueError("strict component contains a reducible balanced state")
        cs = tuple(children(sigma, state))
        if not cs:
            raise ValueError("strict state has no balanced child factorization")
        for child in cs:
            cu, cv = child
            if cu == cv:
                raise ValueError("strict component has a coincidence child")
            if child not in states:
                raise ValueError("strict component has a noncoincident child outside the component")
        tau[state] = cs
    return tau


def apply_derived(tau: DerivedSubstitution, word: Sequence[State]) -> DerivedWord:
    out: list[State] = []
    for state in word:
        if state not in tau:
            raise ValueError("derived word contains a state outside tau")
        out.extend(tau[state])
    return tuple(out)


def iterate_derived(tau: DerivedSubstitution, state: State, depth: int) -> DerivedWord:
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    normalized = normalize_state(state)
    if normalized not in tau:
        raise ValueError("parent state lies outside tau")
    word: DerivedWord = (normalized,)
    for _ in range(depth):
        word = apply_derived(tau, word)
    return word


def direct_normalized_factorization(
    sigma: Substitution,
    state: State,
    depth: int,
) -> DerivedWord:
    """Factor sigma^depth(state) directly at every zero return."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    size = alphabet_size(sigma)
    u, v = normalize_state(state)
    if parikh(u, size) != parikh(v, size):
        raise ValueError("direct factorization requires a balanced state")
    top = apply_substitution_n(sigma, u, depth)
    bottom = apply_substitution_n(sigma, v, depth)
    return tuple(normalize_state(child) for child in decompose_pair(top, bottom, size))


def verify_derived_factorization(
    sigma: Substitution,
    comp: Sequence[State],
    parent: State,
    max_depth: int,
) -> bool:
    """Finite regression for factor_states(sigma^n(T))=tau_C^n(T)."""
    if max_depth < 0:
        raise ValueError("max_depth must be nonnegative")
    tau = strict_derived_substitution(sigma, comp)
    return all(
        direct_normalized_factorization(sigma, parent, depth)
        == iterate_derived(tau, parent, depth)
        for depth in range(max_depth + 1)
    )


def derived_block_boundaries(word: Sequence[State]) -> tuple[int, ...]:
    """Physical zero-return cuts obtained by concatenating derived block lengths."""
    cuts = [0]
    for state in word:
        u, v = state
        if len(u) != len(v):
            raise ValueError("derived state sides must have equal length")
        cuts.append(cuts[-1] + len(u))
    return tuple(cuts)


def derived_context(
    word: Sequence[State],
    boundary_index: int,
    radius: int,
) -> tuple[tuple[State | None, ...], tuple[State | None, ...]]:
    """Fixed-width derived-state context around a boundary between blocks."""
    if radius < 0:
        raise ValueError("derived context radius must be nonnegative")
    if boundary_index < 0 or boundary_index > len(word):
        raise ValueError("derived boundary index lies outside word")
    left_raw = tuple(word[max(0, boundary_index - radius) : boundary_index])
    right_raw = tuple(word[boundary_index : min(len(word), boundary_index + radius)])
    left = (None,) * (radius - len(left_raw)) + left_raw
    right = right_raw + (None,) * (radius - len(right_raw))
    return left, right


def derived_boundary_address(
    sigma: Substitution,
    comp: Sequence[State],
    parent: State,
    depth: int,
    physical_cut: int,
    *,
    radius: int,
) -> DerivedBoundaryAddress:
    """Address one physical zero return by its derived block boundary index."""
    tau = strict_derived_substitution(sigma, comp)
    word = iterate_derived(tau, parent, depth)
    cuts = derived_block_boundaries(word)
    try:
        index = cuts.index(physical_cut)
    except ValueError as exc:
        raise ValueError("physical cut is not a derived zero-return boundary") from exc
    left_context, right_context = derived_context(word, index, radius)
    return DerivedBoundaryAddress(
        depth=depth,
        physical_cut=physical_cut,
        block_index=index,
        left_state=word[index - 1] if index > 0 else None,
        right_state=word[index] if index < len(word) else None,
        left_context=left_context,
        right_context=right_context,
    )


def inherited_derived_boundary_indices(
    tau: DerivedSubstitution,
    parent: State,
    depth: int,
) -> tuple[int, ...]:
    """Boundaries of tau^depth(parent) inherited from level depth-1.

    These are exactly the boundaries between the words tau(S) for consecutive
    letters S of tau^(depth-1)(parent), expressed as block indices in the depth
    word. All other interior block boundaries are newborn at this derived
    level.
    """
    if depth < 1:
        raise ValueError("inherited derived boundaries require depth >= 1")
    source = iterate_derived(tau, parent, depth - 1)
    out = [0]
    for state in source:
        out.append(out[-1] + len(tau[state]))
    return tuple(out)


def newborn_derived_boundary_indices(
    tau: DerivedSubstitution,
    parent: State,
    depth: int,
) -> tuple[int, ...]:
    if depth < 1:
        raise ValueError("newborn derived boundaries require depth >= 1")
    word = iterate_derived(tau, parent, depth)
    inherited = set(inherited_derived_boundary_indices(tau, parent, depth))
    return tuple(index for index in range(1, len(word)) if index not in inherited)


def direct_zero_return_boundaries(
    sigma: Substitution,
    state: State,
    depth: int,
) -> tuple[int, ...]:
    """Physical zero returns of sigma^depth(state), for theorem cross-checks."""
    size = alphabet_size(sigma)
    u, v = normalize_state(state)
    top = apply_substitution_n(sigma, u, depth)
    bottom = apply_substitution_n(sigma, v, depth)
    return tuple(coincidence_boundaries(top, bottom, size))
