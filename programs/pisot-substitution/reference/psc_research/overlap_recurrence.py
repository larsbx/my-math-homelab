"""Independent oracle for zero-shift-free recurrent overlap cycles."""
from __future__ import annotations

from typing import Any

from psc_research.overlap_obstruction import sccs


def _has_cycle(g: Any, comp: list[int]) -> bool:
    if len(comp) > 1:
        return True
    return bool(comp) and comp[0] in g.adj[comp[0]]


def zero_shift_free_recurrent_sccs(g: Any) -> list[list[int]]:
    """Cycles after deleting coincidences and offset-zero overlap states.

    Right-aligned states are intentionally retained: this is the prefix/left
    boundary diagnostic only, not a two-sided alignment-free query.
    """
    if g.capped:
        raise RuntimeError("zero-shift-free recurrence is undefined for a capped partial graph")

    kept = [not g.is_coincidence(state) and any(state[2]) for state in g.states]
    adj = [
        [child for child in g.adj[i] if kept[child]] if kept[i] else []
        for i in range(len(g.states))
    ]

    class _Filtered:
        def __init__(self) -> None:
            self.states = g.states
            self.adj = adj
            self.capped = False

    filtered = _Filtered()
    return [
        comp
        for comp in sccs(filtered)
        if comp and kept[comp[0]] and _has_cycle(filtered, comp)
    ]
