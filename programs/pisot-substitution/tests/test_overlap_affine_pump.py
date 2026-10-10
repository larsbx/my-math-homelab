from __future__ import annotations

import pytest

from psc_research.overlap_affine_pump import (
    AffinePumpCertificate,
    first_zero_shift_free_affine_pump,
    occurrence_edges,
    verify_affine_pump,
)
from psc_research.overlap_graph import OverlapGraph


def _determinant_two_sigma() -> dict[int, tuple[int, ...]]:
    return {1: (2,), 2: (1, 3, 2), 3: (1, 1, 2)}


def test_every_ordered_occurrence_satisfies_affine_recurrence() -> None:
    g = OverlapGraph(_determinant_two_sigma())
    assert not g.capped
    count = 0
    for parent_index, state in enumerate(g.states):
        edges = occurrence_edges(g, parent_index)
        if not g.is_coincidence(state):
            assert edges
        assert [edge.occurrence_ordinal for edge in edges] == list(range(len(edges)))
        count += len(edges)
    assert count > len(g.states)


def test_extracted_affine_pump_replays_or_absence_is_exact() -> None:
    g = OverlapGraph(_determinant_two_sigma())
    certificate = first_zero_shift_free_affine_pump(g)
    # Golden negative for the overstrong claim that zero-shift-free recurrence
    # is impossible. This productive graph is not a closed bad component.
    assert certificate is not None
    assert len(certificate.edges) == 6
    assert verify_affine_pump(g, certificate)
    assert all(any(g.states[index][2]) for index in certificate.state_indices)


def test_tampering_and_caps_fail_closed() -> None:
    g = OverlapGraph(_determinant_two_sigma())
    certificate = first_zero_shift_free_affine_pump(g)
    if certificate is not None:
        bad = AffinePumpCertificate(certificate.state_indices[:-1], certificate.edges)
        assert not verify_affine_pump(g, bad)

    g.capped = True
    with pytest.raises(RuntimeError):
        occurrence_edges(g, 0)
    with pytest.raises(RuntimeError):
        first_zero_shift_free_affine_pump(g)
