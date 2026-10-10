"""Finite one-step birth-event types for newborn balanced boundaries.

For a finite strict component C, every interior boundary of ``tau_C(T)`` is a
newborn zero return inside ``sigma(T)``. Because every newborn boundary at an
arbitrary derived depth lies inside one occurrence of some one-step word
``tau_C(T)``, these finitely many parent/split types form a complete birth-event
alphabet.

The catalog is stored in the canonical normalized orientation of each parent.
Deep occurrences additionally carry the accumulated Z/2 parent orientation.
When an occurrence is reversed, its physical source defect/correction are
negated, top/bottom source data and endpoint-pair coordinates are swapped, and
all child occurrence signs are reversed. This distinction is essential: the
normalized derived word alone does not remember physical top/bottom data.
"""

from __future__ import annotations

from dataclasses import dataclass, replace
from typing import Sequence

from .bpa import State, Substitution, apply_substitution, endpoint_maps, normalize_state, sync_pairs
from .derived_factorization import (
    DerivedSubstitution,
    derived_block_boundaries,
    newborn_derived_boundary_indices,
    strict_derived_substitution,
)
from .orientation import oriented_children
from .prefix_difference import Vector, inflated_prefix_lift


@dataclass(frozen=True)
class NewbornBirthEvent:
    """One canonical internal split of ``tau_C(parent)`` with sigma-side data."""

    parent: State
    split_index: int
    physical_cut: int
    left_child: State
    right_child: State
    left_orientation_sign: int
    right_orientation_sign: int
    source_difference: Vector
    correction: Vector
    top_source_index: int
    bottom_source_index: int
    top_offset: int
    bottom_offset: int
    left_endpoint_pair: tuple[int, int]
    right_endpoint_pair: tuple[int, int]
    left_synchronizing: bool
    right_synchronizing: bool

    @property
    def key(self) -> tuple[State, int]:
        return (self.parent, self.split_index)

    @property
    def source_aligned_on_both_sides(self) -> bool:
        return self.top_offset == 0 and self.bottom_offset == 0

    @property
    def endpoint_nonsynchronizing(self) -> bool:
        return not self.left_synchronizing and not self.right_synchronizing


@dataclass(frozen=True)
class NewbornOccurrence:
    """Physical occurrence of a one-step event in ``tau_C^depth(parent)``."""

    depth: int
    source_block_index: int
    source_state: State
    parent_orientation: int
    split_index: int
    derived_boundary_index: int
    event: NewbornBirthEvent

    def __post_init__(self) -> None:
        if self.parent_orientation not in (-1, 1):
            raise ValueError("parent orientation must be +/-1")


def strict_birth_event_catalog(
    sigma: Substitution,
    comp: Sequence[State],
) -> tuple[NewbornBirthEvent, ...]:
    """Return every canonical one-step newborn split type of a strict component."""
    tau = strict_derived_substitution(sigma, comp)
    plus, minus = endpoint_maps(sigma)
    plus_sync = sync_pairs(plus)
    minus_sync = sync_pairs(minus)

    out: list[NewbornBirthEvent] = []
    for parent in sorted(tau):
        normalized_children = tau[parent]
        signed_children = oriented_children(sigma, parent)
        if tuple(child for child, _sign in signed_children) != normalized_children:
            raise AssertionError("orientation child order disagrees with derived substitution")

        physical_boundaries = derived_block_boundaries(normalized_children)
        top = apply_substitution(sigma, parent[0])
        bottom = apply_substitution(sigma, parent[1])
        if len(top) != len(bottom):
            raise AssertionError("balanced parent images have unequal length")

        for split in range(1, len(normalized_children)):
            cut = physical_boundaries[split]
            if not (0 < cut < len(top)):
                raise AssertionError("internal derived split is not an interior physical cut")
            lift = inflated_prefix_lift(sigma, parent, cut)
            if not lift.is_zero_return:
                raise AssertionError("derived child boundary is not a zero return")

            left_pair = (top[cut - 1], bottom[cut - 1])
            right_pair = (top[cut], bottom[cut])
            left_child, left_sign = signed_children[split - 1]
            right_child, right_sign = signed_children[split]

            out.append(
                NewbornBirthEvent(
                    parent=parent,
                    split_index=split,
                    physical_cut=cut,
                    left_child=left_child,
                    right_child=right_child,
                    left_orientation_sign=left_sign,
                    right_orientation_sign=right_sign,
                    source_difference=lift.source_difference,
                    correction=lift.local_difference,
                    top_source_index=lift.top_source_index,
                    bottom_source_index=lift.bottom_source_index,
                    top_offset=lift.top_offset,
                    bottom_offset=lift.bottom_offset,
                    left_endpoint_pair=left_pair,
                    right_endpoint_pair=right_pair,
                    left_synchronizing=left_pair in minus_sync,
                    right_synchronizing=right_pair in plus_sync,
                )
            )
    return tuple(out)


def event_by_key(catalog: Sequence[NewbornBirthEvent]) -> dict[tuple[State, int], NewbornBirthEvent]:
    out: dict[tuple[State, int], NewbornBirthEvent] = {}
    for event in catalog:
        if event.key in out:
            raise ValueError("duplicate newborn birth-event key")
        out[event.key] = event
    return out


def orient_birth_event(event: NewbornBirthEvent, parent_orientation: int) -> NewbornBirthEvent:
    """Transform a canonical event into the physical orientation of an occurrence."""
    if parent_orientation not in (-1, 1):
        raise ValueError("parent orientation must be +/-1")
    if parent_orientation == 1:
        return event
    return replace(
        event,
        left_orientation_sign=-event.left_orientation_sign,
        right_orientation_sign=-event.right_orientation_sign,
        source_difference=tuple(-x for x in event.source_difference),
        correction=tuple(-x for x in event.correction),
        top_source_index=event.bottom_source_index,
        bottom_source_index=event.top_source_index,
        top_offset=event.bottom_offset,
        bottom_offset=event.top_offset,
        left_endpoint_pair=(event.left_endpoint_pair[1], event.left_endpoint_pair[0]),
        right_endpoint_pair=(event.right_endpoint_pair[1], event.right_endpoint_pair[0]),
    )


def oriented_derived_word(
    sigma: Substitution,
    tau: DerivedSubstitution,
    parent: State,
    depth: int,
    *,
    parent_orientation: int = 1,
) -> tuple[tuple[State, int], ...]:
    """Expand normalized derived letters while retaining accumulated orientation."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    if parent_orientation not in (-1, 1):
        raise ValueError("parent orientation must be +/-1")
    normalized_parent = normalize_state(parent)
    if normalized_parent not in tau:
        raise ValueError("parent lies outside derived substitution")

    word: tuple[tuple[State, int], ...] = ((normalized_parent, parent_orientation),)
    for _ in range(depth):
        expanded: list[tuple[State, int]] = []
        for state, orientation in word:
            signed = oriented_children(sigma, state)
            if tuple(child for child, _sign in signed) != tau[state]:
                raise AssertionError("signed children disagree with derived substitution")
            expanded.extend((child, orientation * sign) for child, sign in signed)
        word = tuple(expanded)
    return word


def newborn_occurrences(
    sigma: Substitution,
    tau: DerivedSubstitution,
    parent: State,
    depth: int,
    catalog: Sequence[NewbornBirthEvent],
    *,
    parent_orientation: int = 1,
) -> tuple[NewbornOccurrence, ...]:
    """Expand every depth-n newborn boundary with its physical orientation data."""
    if depth < 1:
        raise ValueError("newborn occurrences require depth >= 1")
    events = event_by_key(catalog)
    source_word = oriented_derived_word(
        sigma,
        tau,
        parent,
        depth - 1,
        parent_orientation=parent_orientation,
    )
    output_index = 0
    out: list[NewbornOccurrence] = []
    for source_index, (state, orientation) in enumerate(source_word):
        image = tau[state]
        for split in range(1, len(image)):
            key = (state, split)
            if key not in events:
                raise ValueError("catalog is missing a derived newborn split type")
            out.append(
                NewbornOccurrence(
                    depth=depth,
                    source_block_index=source_index,
                    source_state=state,
                    parent_orientation=orientation,
                    split_index=split,
                    derived_boundary_index=output_index + split,
                    event=orient_birth_event(events[key], orientation),
                )
            )
        output_index += len(image)

    expected = newborn_derived_boundary_indices(tau, parent, depth)
    actual = tuple(item.derived_boundary_index for item in out)
    if actual != expected:
        raise AssertionError("birth-event expansion disagrees with derived newborn boundaries")
    return tuple(out)


def strict_catalog_is_endpoint_nonsynchronizing(
    sigma: Substitution,
    comp: Sequence[State],
) -> bool:
    """Necessary endpoint condition for a strict child-closed component.

    Synchronization is symmetric under swapping the two sides, so it is enough
    to check the canonical catalog even though deep occurrences may be reversed.
    """
    return all(event.endpoint_nonsynchronizing for event in strict_birth_event_catalog(sigma, comp))
