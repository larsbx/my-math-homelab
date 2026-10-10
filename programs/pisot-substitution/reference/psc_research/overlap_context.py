"""Seed-relative one-step prefix-suffix context diagnostics.

This oracle records the symbolic proper prefix and suffix surrounding both
children of an ordered overlap occurrence.  Equality of the affine child
state alone is deliberately not treated as equality of periodic-patch
context, and neither condition licenses symbolic pump deletion.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from psc_research.overlap_affine_pump import occurrence_edges


@dataclass(frozen=True)
class PairedPrefixSuffixContext:
    top_parent: int
    bottom_parent: int
    top_child_index: int
    bottom_child_index: int
    top_prefix: tuple[int, ...]
    top_suffix: tuple[int, ...]
    bottom_prefix: tuple[int, ...]
    bottom_suffix: tuple[int, ...]


@dataclass(frozen=True)
class AffineContextMismatch:
    child_index: int
    first_parent_index: int
    first_occurrence_ordinal: int
    second_parent_index: int
    second_occurrence_ordinal: int
    first_context: PairedPrefixSuffixContext
    second_context: PairedPrefixSuffixContext


def occurrence_context(g: Any, parent_index: int, occurrence_ordinal: int) -> PairedPrefixSuffixContext:
    """Return the exact one-step paired prefix-suffix address."""
    if g.capped:
        raise RuntimeError("overlap context is undefined for a capped seed-patch graph")
    edges = occurrence_edges(g, parent_index)
    if not 0 <= occurrence_ordinal < len(edges):
        raise RuntimeError("overlap context occurrence ordinal is out of range")
    edge = edges[occurrence_ordinal]
    top_parent, bottom_parent, _ = g.states[parent_index]
    top_word = tuple(g.sigma[top_parent])
    bottom_word = tuple(g.sigma[bottom_parent])
    i, j = edge.top_child_index, edge.bottom_child_index
    return PairedPrefixSuffixContext(
        top_parent,
        bottom_parent,
        i,
        j,
        top_word[:i],
        top_word[i + 1 :],
        bottom_word[:j],
        bottom_word[j + 1 :],
    )


def first_affine_context_mismatch(g: Any) -> AffineContextMismatch | None:
    """Find the first equal affine child state with unequal one-step context.

    This is a finite seed-patch diagnostic.  Absence is not a completeness or
    recognizability theorem; a mismatch is a countermodel to using the affine
    state alone as the symbolic context of an occurrence.
    """
    if g.capped:
        raise RuntimeError("context comparison is undefined for a capped seed-patch graph")
    first: dict[int, tuple[int, int, PairedPrefixSuffixContext]] = {}
    for parent_index in range(len(g.states)):
        for edge in occurrence_edges(g, parent_index):
            context = occurrence_context(g, parent_index, edge.occurrence_ordinal)
            prior = first.get(edge.child_index)
            if prior is None:
                first[edge.child_index] = (parent_index, edge.occurrence_ordinal, context)
            elif prior[2] != context:
                return AffineContextMismatch(
                    edge.child_index,
                    prior[0],
                    prior[1],
                    parent_index,
                    edge.occurrence_ordinal,
                    prior[2],
                    context,
                )
    return None
