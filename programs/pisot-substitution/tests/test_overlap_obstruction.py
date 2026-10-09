from __future__ import annotations

import pytest

from psc_research.overlap_graph import OverlapGraph
from psc_research.overlap_obstruction import (
    common_child_start_count,
    nonproductive_sink_sccs,
    sccs,
)


class _Graph:
    def __init__(self, adj: list[list[int]], bad: list[int], capped: bool = False):
        self.states = list(range(len(adj)))
        self.adj = adj
        self._bad = bad
        self.capped = capped

    def nonproductive(self) -> list[int]:
        if self.capped:
            raise RuntimeError("productivity undefined on a capped graph")
        return list(self._bad)


def _determinant_two_sigma() -> dict[int, tuple[int, ...]]:
    # 1-based Python version of the canonical Mojo regression substitution.
    return {1: (2,), 2: (1, 3, 2), 3: (1, 1, 2)}


def test_common_child_starts_are_exactly_zero_shift_children() -> None:
    g = OverlapGraph(_determinant_two_sigma())
    assert not g.capped
    for state in g.states:
        if g.is_coincidence(state):
            continue
        zero_shift = sum(1 for child in g.children(state) if not any(child[2]))
        assert common_child_start_count(g, state) == zero_shift


def test_extracts_closed_recurrent_core_not_transient_bad_vertices() -> None:
    # 0 is the coincidence target, 1 reaches it.  The bad path 2 -> 3 enters
    # the closed recurrent core 3 <-> 4.  Only {3,4} is the obstruction SCC.
    g = _Graph([[], [0], [3], [4], [3]], bad=[2, 3, 4])
    sinks = nonproductive_sink_sccs(g)
    assert len(sinks) == 1
    assert set(sinks[0]) == {3, 4}


def test_multiple_bad_sinks_are_all_retained() -> None:
    g = _Graph([[0], [2], [1], [3]], bad=[0, 1, 2, 3])
    sinks = nonproductive_sink_sccs(g)
    assert {frozenset(c) for c in sinks} == {frozenset({0}), frozenset({1, 2}), frozenset({3})}


def test_capped_queries_fail_closed() -> None:
    g = _Graph([[0]], bad=[0], capped=True)
    with pytest.raises(RuntimeError):
        sccs(g)
    with pytest.raises(RuntimeError):
        nonproductive_sink_sccs(g)
