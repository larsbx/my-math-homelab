from __future__ import annotations

import pytest

from psc_research.overlap_context import (
    first_affine_context_mismatch,
    occurrence_context,
)
from psc_research.overlap_graph import OverlapGraph


def _determinant_two_sigma() -> dict[int, tuple[int, ...]]:
    return {1: (2,), 2: (1, 3, 2), 3: (1, 1, 2)}


def test_equal_affine_state_does_not_imply_equal_symbolic_context() -> None:
    graph = OverlapGraph(_determinant_two_sigma())
    mismatch = first_affine_context_mismatch(graph)
    assert mismatch is not None
    assert mismatch.first_context != mismatch.second_context
    assert mismatch.first_context == occurrence_context(
        graph, mismatch.first_parent_index, mismatch.first_occurrence_ordinal
    )
    assert mismatch.second_context == occurrence_context(
        graph, mismatch.second_parent_index, mismatch.second_occurrence_ordinal
    )


def test_context_diagnostic_fails_closed_on_cap_and_bad_ordinal() -> None:
    graph = OverlapGraph(_determinant_two_sigma())
    with pytest.raises(RuntimeError):
        occurrence_context(graph, 0, 10_000)
    graph.capped = True
    with pytest.raises(RuntimeError):
        first_affine_context_mismatch(graph)
