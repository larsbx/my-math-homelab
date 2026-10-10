from __future__ import annotations

import pytest

from psc_research.overlap_graph import OverlapGraph
from psc_research.overlap_obstruction import common_child_start_count
from psc_research.overlap_recurrence import zero_shift_free_recurrent_sccs
from psc_research.overlap_zipper import (
    is_strict_zipper,
    ordered_child_occurrences,
    zero_shift_occurrence_count,
    zipper_steps,
)


def _determinant_two_sigma() -> dict[int, tuple[int, ...]]:
    return {1: (2,), 2: (1, 3, 2), 3: (1, 1, 2)}


def test_ordered_occurrences_preserve_all_child_occurrences() -> None:
    g = OverlapGraph(_determinant_two_sigma())
    assert not g.capped
    saw_strict = False
    saw_boundary_tie = False

    for state in g.states:
        if g.is_coincidence(state):
            continue
        occurrences = ordered_child_occurrences(g, state)
        assert len(occurrences) == len(g.children(state))
        steps = zipper_steps(occurrences)
        assert len(steps) == len(occurrences) - 1
        assert all(step in (1, 2, 3) for step in steps)

        zero_count = zero_shift_occurrence_count(occurrences)
        assert zero_count == common_child_start_count(g, state)

        first_zero = int(not any(occurrences[0].state[2]))
        assert zero_count == first_zero + sum(step == 3 for step in steps)
        assert is_strict_zipper(occurrences) == (zero_count == 0)
        saw_strict |= zero_count == 0
        saw_boundary_tie |= zero_count > 0

    # The regression substitution exercises both branches of the local
    # boundary/zipper dictionary.
    assert saw_strict
    assert saw_boundary_tie


class _Graph:
    def __init__(self, states, adj, capped: bool = False):
        self.states = states
        self.adj = adj
        self.capped = capped

    @staticmethod
    def is_coincidence(state) -> bool:
        return state[0] == state[1] and not any(state[2])


def test_zero_shift_free_recurrence_is_one_sided_and_fail_closed() -> None:
    z = (0, 0, 0)
    one = (1, 0, 0)
    two = (2, 0, 0)
    states = [
        (1, 1, z),   # coincidence, removed
        (1, 2, one), # nonzero-shift self-cycle, retained
        (2, 3, z),   # zero-shift self-cycle, removed
        (3, 1, two), # feeds the removed zero-shift state
    ]
    g = _Graph(states, [[], [1], [2], [2]])
    comps = zero_shift_free_recurrent_sccs(g)
    assert [set(comp) for comp in comps] == [{1}]

    with pytest.raises(RuntimeError):
        zero_shift_free_recurrent_sccs(_Graph(states, [[], [1], [2], [2]], capped=True))
