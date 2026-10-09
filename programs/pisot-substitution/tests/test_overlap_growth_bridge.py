from __future__ import annotations

import pytest

from psc_research.overlap_graph import OverlapGraph
from psc_research.overlap_growth_bridge import occurrence_multiplicity_at_level


SIGMA = {1: (2,), 2: (1, 3, 2), 3: (1, 1, 2)}


def test_multiple_edge_update_counts_occurrences() -> None:
    g = OverlapGraph(SIGMA)
    levels = [occurrence_multiplicity_at_level(g, n) for n in range(4)]
    assert [sum(v) for v in levels] == [9, 21, 34, 67]
    assert any(value > 1 for value in levels[1])
    for n in range(3):
        manual = [0] * len(g.states)
        for parent, multiplicity in enumerate(levels[n]):
            for child in g.adj[parent]:
                manual[child] += multiplicity
        assert tuple(manual) == levels[n + 1]

    # Independent direct inflation: do not read the stored adjacency.  Carry
    # actual state occurrences and recompute every overlapping child from its
    # two substituted tile partitions.
    direct = {state: g.seeds().count(state) for state in set(g.seeds())}
    for n in range(4):
        projected = [0] * len(g.states)
        for state, multiplicity in direct.items():
            projected[g.index[state]] += multiplicity
        assert tuple(projected) == levels[n]
        children = {}
        for state, multiplicity in direct.items():
            if g.is_coincidence(state):
                continue
            for child in g.children(state):
                children[child] = children.get(child, 0) + multiplicity
        direct = children


def test_growth_bridge_fails_closed() -> None:
    g = OverlapGraph(SIGMA)
    with pytest.raises(RuntimeError):
        occurrence_multiplicity_at_level(g, -1)
    with pytest.raises(RuntimeError):
        occurrence_multiplicity_at_level(g, 4, max_count=1)
    g.capped = True
    with pytest.raises(RuntimeError):
        occurrence_multiplicity_at_level(g, 1)
