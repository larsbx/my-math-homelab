"""Exact recurrence diagnostics for the overlap-productivity zipper branch.

A strict left-boundary zipper obstruction from issue #84 would contain a
directed cycle avoiding coincidences and every offset-zero overlap.  This
module asks for precisely that finite signature by deleting those vertices and
taking SCCs of the induced graph.  It does not delete right-aligned overlaps:
the suffix boundary case is a distinct obstruction and must not be silently
conflated with zero-shift avoidance.

This is a diagnostic constraint, not a proof that every such cycle can occur
in a closed nonproductive component.
"""

from psc.overlap_obstruction import has_cycle, overlap_sccs
from psc.overlap_seed_patch import SeedOverlapAutomaton


def zero_shift_free_recurrent_sccs(
    a: SeedOverlapAutomaton
) raises -> List[List[Int]]:
    """Cycles after deleting coincidences and offset-zero overlap states.

    "Zero-shift-free" is deliberately one-sided terminology.  A retained state
    may still be right-aligned; suffix alignment is not removed by this query.
    """
    if a.capped:
        raise Error("zero-shift-free recurrence is undefined for a capped partial graph")

    var kept = List[Bool]()
    for i in range(a.size()):
        kept.append(not a.states[i].is_coincidence() and not a.states[i].shift.is_zero())

    var adj = List[List[Int]]()
    for i in range(a.size()):
        var row = List[Int]()
        if kept[i]:
            for j in range(len(a.adj[i])):
                var child = a.adj[i][j]
                if kept[child]:
                    row.append(child)
        adj.append(row^)

    var filtered = SeedOverlapAutomaton(a.states, adj, False)
    var comps = overlap_sccs(filtered)
    var out = List[List[Int]]()
    for i in range(len(comps)):
        if len(comps[i]) == 0:
            continue
        var representative = comps[i][0]
        if kept[representative] and has_cycle(filtered, comps[i]):
            out.append(comps[i].copy())
    return out^
