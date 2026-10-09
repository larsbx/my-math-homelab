"""Finite obstruction extraction for the seed-patch overlap graph.

This module is deliberately structural.  It does not prove overlap
productivity.  If productivity fails on a complete finite overlap graph, it
extracts the closed recurrent noncoincidence SCCs in which any counterexample
must eventually live.

It also exposes the exact boundary event that separates an aligned obstruction
from a genuinely interior one: equality of a top and bottom substituted child
start is equivalent to an offset-zero child.

All queries fail closed on a capped graph: a capped graph is an incomplete
prefix and cannot certify either productivity or a recurrent obstruction.
"""

from psc.overlap_seed_patch import (
    OverlapState,
    SeedOverlapAutomaton,
    SeedOverlapTables,
    nonproductive_overlap_states,
)
from psc.perron_field3 import cubic_add_checked, cubic_mul_beta
from finite_graph.scc import has_cycle as graph_has_cycle, sccs as graph_sccs


def common_child_start_count(
    tables: SeedOverlapTables, state: OverlapState
) raises -> Int:
    """Count exact top/bottom substituted child starts that coincide.

    A top child ``i`` starts at ``p_i``.  A bottom child ``j`` starts at
    ``beta*t + q_j`` for parent shift ``t``.  Equality is therefore exactly
    the condition that the corresponding child overlap has shift zero.  Both
    child intervals have positive length, so every equality is a genuine
    interior overlap child, not a boundary-touching artefact.
    """
    if state.top < 0 or state.top >= 3 or state.bottom < 0 or state.bottom >= 3:
        raise Error("overlap state tile type lies outside 0..2")
    var scaled_shift = cubic_mul_beta(tables.field, state.shift)
    var count = 0
    for i in range(len(tables.sigma[state.top])):
        var top_start = tables.prefix(state.top, i)
        for j in range(len(tables.sigma[state.bottom])):
            var bottom_start = cubic_add_checked(
                scaled_shift, tables.prefix(state.bottom, j)
            )
            if top_start == bottom_start:
                count += 1
    return count


def overlap_sccs(a: SeedOverlapAutomaton) raises -> List[List[Int]]:
    """Strongly connected components of a complete overlap graph.

    The components are `finite_graph.scc.sccs` of the child edges; this layer
    adds only the refusal of a capped graph, which keeps the overlap
    obstruction independent of balanced-pair finiteness.
    """
    if a.capped:
        raise Error("overlap SCCs are undefined for a capped partial graph")
    return graph_sccs(a.adj)


def has_cycle(a: SeedOverlapAutomaton, comp: List[Int]) -> Bool:
    """An SCC carries a cycle: it has two vertices or a self-loop."""
    if len(comp) == 0:
        return False
    return graph_has_cycle(a.adj, comp)


def recurrent_sccs(a: SeedOverlapAutomaton) raises -> List[List[Int]]:
    """The SCCs of `a` that carry a cycle (the recurrent part)."""
    var all = overlap_sccs(a)
    var out = List[List[Int]]()
    for k in range(len(all)):
        if has_cycle(a, all[k]):
            out.append(all[k].copy())
    return out^


def nonproductive_sink_sccs(a: SeedOverlapAutomaton) raises -> List[List[Int]]:
    """Closed recurrent SCCs consisting entirely of nonproductive overlaps.

    A nonproductive vertex cannot have a productive child: a coincidence
    reachable from that child would also be reachable from the parent.  Hence
    the nonproductive set is forward closed.  In a finite complete graph, any
    infinite child path from a nonproductive vertex eventually enters a sink
    SCC of the nonproductive subgraph.  Those sink SCCs are exactly the
    components returned here.

    For a genuine overlap graph every noncoincidence overlap has at least one
    child occurrence (the inflated intersection is nonempty), so nonempty
    nonproductivity implies that at least one returned component exists.
    Synthetic graph tests may omit that geometric out-degree invariant; this
    function therefore reports what is present rather than silently inventing
    a recurrent component.
    """
    if a.capped:
        raise Error("overlap obstruction is undefined for a capped partial graph")

    var bad_indices = nonproductive_overlap_states(a)
    var bad = List[Bool]()
    for _ in range(a.size()):
        bad.append(False)
    for i in range(len(bad_indices)):
        bad[bad_indices[i]] = True

    var all = overlap_sccs(a)
    var out = List[List[Int]]()
    for k in range(len(all)):
        ref comp = all[k]
        if len(comp) == 0 or not has_cycle(a, comp):
            continue

        var member = List[Bool]()
        for _ in range(a.size()):
            member.append(False)
        var all_bad = True
        for i in range(len(comp)):
            member[comp[i]] = True
            if not bad[comp[i]]:
                all_bad = False
        if not all_bad:
            continue

        var closed = True
        for i in range(len(comp)):
            var v = comp[i]
            for j in range(len(a.adj[v])):
                if not member[a.adj[v][j]]:
                    closed = False
        if closed:
            out.append(comp.copy())
    return out^
