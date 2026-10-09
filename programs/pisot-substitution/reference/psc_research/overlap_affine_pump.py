"""Exact occurrence-labelled affine pump certificates for overlap zippers.

The canonical implementation is ``kernel/psc/overlap_affine_pump.mojo``.  This
module is an independently written Python oracle.  A certificate proves only
that an actual ordered child-occurrence cycle satisfies the iterated affine
offset recurrence.  It does not prove that the cycle is child-closed,
nonproductive, globally realizable, or forbidden by the PIP hypotheses.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from psc_research.overlap_recurrence import zero_shift_free_recurrent_sccs
from psc_research.overlap_zipper import ordered_child_occurrences


@dataclass(frozen=True)
class AffineOccurrenceEdge:
    parent_index: int
    occurrence_ordinal: int
    child_index: int
    top_child_index: int
    bottom_child_index: int
    top_prefix: Any
    bottom_prefix: Any
    forcing: Any


@dataclass(frozen=True)
class AffinePumpCertificate:
    state_indices: tuple[int, ...]
    edges: tuple[AffineOccurrenceEdge, ...]


def _state_index(g: Any, state: Any) -> int:
    try:
        return g.states.index(state)
    except ValueError as exc:
        raise RuntimeError("ordered child occurrence is absent from the seed-patch graph") from exc


def occurrence_edges(g: Any, parent_index: int) -> list[AffineOccurrenceEdge]:
    """Return all actual child occurrences, in prefix-grid order."""
    if g.capped:
        raise RuntimeError("affine occurrence edges are undefined for a capped graph")
    if not 0 <= parent_index < len(g.states):
        raise RuntimeError("affine occurrence parent index is out of range")
    parent = g.states[parent_index]
    if g.is_coincidence(parent):
        return []
    out: list[AffineOccurrenceEdge] = []
    for ordinal, occurrence in enumerate(ordered_child_occurrences(g, parent)):
        top_prefix = g.prefix[(parent[0], occurrence.top_index)]
        bottom_prefix = g.prefix[(parent[1], occurrence.bottom_index)]
        forcing = g.F.sub(bottom_prefix, top_prefix)
        expected = g.F.add(g.F.mul(g.F.beta, parent[2]), forcing)
        if occurrence.state[2] != expected:
            raise RuntimeError("ordered child violates the exact affine offset recurrence")
        out.append(
            AffineOccurrenceEdge(
                parent_index,
                ordinal,
                _state_index(g, occurrence.state),
                occurrence.top_index,
                occurrence.bottom_index,
                top_prefix,
                bottom_prefix,
                forcing,
            )
        )
    return out


def first_zero_shift_free_affine_pump(g: Any) -> AffinePumpCertificate | None:
    """Extract one deterministic occurrence-labelled cycle, if one exists."""
    if g.capped:
        raise RuntimeError("affine pump extraction is undefined for a capped graph")
    for component in zero_shift_free_recurrent_sccs(g):
        members = set(component)
        current = min(component)
        seen: dict[int, int] = {}
        states: list[int] = []
        edges: list[AffineOccurrenceEdge] = []
        while current not in seen:
            seen[current] = len(states)
            states.append(current)
            internal = [edge for edge in occurrence_edges(g, current) if edge.child_index in members]
            if not internal:
                raise RuntimeError("recurrent component has no internal occurrence edge")
            edge = internal[0]
            edges.append(edge)
            current = edge.child_index
        start = seen[current]
        return AffinePumpCertificate(tuple(states[start:]), tuple(edges[start:]))
    return None


def verify_affine_pump(g: Any, certificate: AffinePumpCertificate) -> bool:
    """Replay occurrence order and the exact iterated affine cycle identity."""
    if g.capped:
        raise RuntimeError("affine pump verification is undefined for a capped graph")
    if not certificate.state_indices or len(certificate.state_indices) != len(certificate.edges):
        return False
    shift = g.states[certificate.state_indices[0]][2]
    for k, edge in enumerate(certificate.edges):
        parent_index = certificate.state_indices[k]
        child_index = certificate.state_indices[(k + 1) % len(certificate.state_indices)]
        if edge.parent_index != parent_index or edge.child_index != child_index:
            return False
        actual = occurrence_edges(g, parent_index)
        if not 0 <= edge.occurrence_ordinal < len(actual):
            return False
        if actual[edge.occurrence_ordinal] != edge:
            return False
        shift = g.F.add(g.F.mul(g.F.beta, shift), edge.forcing)
        if shift != g.states[child_index][2] or not any(shift):
            return False
    return shift == g.states[certificate.state_indices[0]][2]
