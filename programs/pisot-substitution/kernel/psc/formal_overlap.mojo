"""Formal (potential) overlap graph, compared with the realized seed-patch graph.

A *potential overlap* is a state `(i, j, t)` of `psc.overlap_seed_patch` with
`t = sum_a w_a l_a`, `w in Z^3`, not required to be reachable from any seed.
The *formal overlap graph* is the inflation closure of the potential overlaps
of Proposition V's box (`psc.vertex_coincidence.box_radii` /
`box_start_states`), which contains every overlap lying on a cycle; the
*realized graph* is the swap-seed closure. A *formal carrier* is a recurrent
SCC of the formal graph with its coincidence vertices deleted: the maximal set
carrying coincidence-free (producer-free) cycles. This is the sound object
behind the ledger's "formal producer-free cycles"
(`archive/2026-10-06/status-snapshots/completion-ledger-2026-09-11.md` §V), whose original instrument is not
in the repository; a carrier, not a simple cycle, is counted, because the
number of simple cycles is not canonical.

Carriers, and every path from a carrier to a coincidence, do not depend on
which cycle-containing region seeds the closure: the docs prove this for the
forward-closed region `K_T` (`docs/formal-overlap-carriers-2026-10-04.md`
§2), which the independent oracle uses, while this kernel reuses the box.
Every predicate is exact. `carriers_inside_box` records the a-posteriori
receipt that every carrier vertex is a box seed.

A carrier is either wholly realized or wholly unrealized: the realized graph
is forward closed and a carrier is strongly connected. That is checked, and
the realized carriers are cross-checked against the realized graph's own
carriers. Capped graphs fail closed. Independent oracle:
reference/psc_research/formal_overlap.py.
"""

from psc.overlap_obstruction import recurrent_sccs
from psc.overlap_seed_patch import (
    OverlapState,
    SeedOverlapAutomaton,
    SeedOverlapTables,
    build_overlap_graph_from_seeds,
    build_seed_overlap_graph_from_tables,
    first_coincidence_depths,
    first_depths,
    first_left_aligned_depths,
)
from psc.perron_field3 import CubicElt
from psc.vertex_coincidence import box_radii, box_start_states


comptime FORMAL_STATE_CAP = 400000


struct FormalCarrier(Copyable, Movable):
    """One recurrent coincidence-free SCC of the formal overlap graph."""

    var members: List[Int]
    var internal_edges: Int
    var realized: Bool
    var closed: Bool
    var aligned: Bool
    var direct_producer: Bool
    var death_depth: Int
    var aligned_depth: Int
    var proper_aligned_depth: Int

    def __init__(
        out self,
        var members: List[Int],
        internal_edges: Int,
        realized: Bool,
        closed: Bool,
        aligned: Bool,
        direct_producer: Bool,
        death_depth: Int,
        aligned_depth: Int,
        proper_aligned_depth: Int,
    ):
        self.members = members^
        self.internal_edges = internal_edges
        self.realized = realized
        self.closed = closed
        self.aligned = aligned
        self.direct_producer = direct_producer
        self.death_depth = death_depth
        self.aligned_depth = aligned_depth
        self.proper_aligned_depth = proper_aligned_depth

    def size(self) -> Int:
        return len(self.members)

    def cyclomatic(self) -> Int:
        """`|E| - |V| + 1`: the rank of the carrier's cycle space."""
        return self.internal_edges - len(self.members) + 1


struct FormalSurvey(Copyable, Movable):
    """The formal graph, the realized graph and the formal carriers."""

    var formal: SeedOverlapAutomaton
    var realized_states: Int
    var box: List[Int]
    var seeds: Int
    var nonproductive: Int
    var carriers: List[FormalCarrier]
    var carriers_inside_box: Bool

    def __init__(
        out self,
        var formal: SeedOverlapAutomaton,
        realized_states: Int,
        var box: List[Int],
        seeds: Int,
        nonproductive: Int,
        var carriers: List[FormalCarrier],
        carriers_inside_box: Bool,
    ):
        self.formal = formal^
        self.realized_states = realized_states
        self.box = box^
        self.seeds = seeds
        self.nonproductive = nonproductive
        self.carriers = carriers^
        self.carriers_inside_box = carriers_inside_box


def _coincidence_free(a: SeedOverlapAutomaton) -> SeedOverlapAutomaton:
    """The same vertices with every edge into or out of a coincidence removed."""
    var adj = List[List[Int]]()
    for v in range(a.size()):
        var row = List[Int]()
        if not a.states[v].is_coincidence():
            for k in range(len(a.adj[v])):
                var w = a.adj[v][k]
                if not a.states[w].is_coincidence():
                    row.append(w)
        adj.append(row^)
    return SeedOverlapAutomaton(a.states, adj, a.capped)


def recurrent_coincidence_free_sccs(a: SeedOverlapAutomaton) raises -> List[List[Int]]:
    """SCCs of the coincidence-free subgraph that carry a cycle."""
    return recurrent_sccs(_coincidence_free(a))


def _least_depth(comp: List[Int], depths: List[Int]) -> Int:
    """The least nonnegative `depths[v]` over `comp`, `-1` if there is none."""
    var out = -1
    for i in range(len(comp)):
        var d = depths[comp[i]]
        if d >= 0 and (out < 0 or d < out):
            out = d
    return out


def survey_formal_overlaps(
    tables: SeedOverlapTables, max_states: Int = FORMAL_STATE_CAP
) raises -> FormalSurvey:
    var cache = Dict[CubicElt, Int]()
    var box = box_radii(tables)
    var seeds = box_start_states(tables, box, cache)
    var formal = build_overlap_graph_from_seeds(tables, seeds, cache, max_states)
    if formal.capped:
        raise Error("formal overlap graph capped: no verdict")
    var realized = build_seed_overlap_graph_from_tables(tables)
    if realized.capped:
        raise Error("realized overlap graph capped: no verdict")

    var in_realized = Dict[OverlapState, Bool]()
    for v in range(realized.size()):
        in_realized[realized.states[v]] = True
    var in_seeds = Dict[OverlapState, Bool]()
    for s in range(len(seeds)):
        in_seeds[seeds[s]] = True

    var depth = first_coincidence_depths(formal)
    var aligned_depths = first_left_aligned_depths(formal)
    var proper_target = List[Bool]()
    for v in range(formal.size()):
        proper_target.append(formal.states[v].shift.is_zero() and not formal.states[v].is_coincidence())
    var proper_depths = first_depths(formal, proper_target)
    var nonproductive = 0
    for v in range(formal.size()):
        if depth[v] < 0:
            nonproductive += 1

    var comps = recurrent_coincidence_free_sccs(formal)
    var member = List[Int](length=formal.size(), fill=-1)
    for k in range(len(comps)):
        for i in range(len(comps[k])):
            member[comps[k][i]] = k

    var inside = True
    var carriers = List[FormalCarrier]()
    var realized_count = 0
    for k in range(len(comps)):
        ref comp = comps[k]
        var n_real = 0
        var internal = 0
        var closed = True
        var aligned = False
        var direct = False
        for i in range(len(comp)):
            var v = comp[i]
            var s = formal.states[v]
            if s in in_realized:
                n_real += 1
            inside = inside and s in in_seeds
            aligned = aligned or s.shift.is_zero()
            for j in range(len(formal.adj[v])):
                var w = formal.adj[v][j]
                if member[w] == k:
                    internal += 1
                else:
                    closed = False
                    direct = direct or formal.states[w].is_coincidence()
        if n_real != 0 and n_real != len(comp):
            raise Error("formal carrier is partly realized: realized graph not forward closed")
        if n_real > 0:
            realized_count += 1
        carriers.append(
            FormalCarrier(
                comp.copy(), internal, n_real > 0, closed, aligned, direct,
                _least_depth(comp, depth), _least_depth(comp, aligned_depths),
                _least_depth(comp, proper_depths),
            )
        )

    var realized_comps = recurrent_coincidence_free_sccs(realized)
    if len(realized_comps) != realized_count:
        raise Error("realized carriers disagree with the realized formal carriers")

    return FormalSurvey(
        formal^, realized.size(), box^, len(seeds), nonproductive, carriers^, inside
    )


def aligned_pair_depth(s: FormalSurvey) raises -> Int:
    """`S(sigma)`: the largest first-coincidence depth of the six aligned pairs
    `(i, j, 0)`, `i != j`, or `-1` if one of them is nonproductive.

    They are the only offset-zero states that are not coincidences, and `t = 0`
    is genuine and in every contraction region, so all six are formal seeds;
    a missing one is an impossible state and raises. With `L` the first
    offset-zero depth of a state and `D` its coincidence depth, `D <= L + S`
    (docs/formal-productivity-reduction-2026-10-04.md)."""
    var depth = first_coincidence_depths(s.formal)
    var found = 0
    var out = 0
    for v in range(s.formal.size()):
        var x = s.formal.states[v]
        if x.shift.is_zero() and not x.is_coincidence():
            found += 1
            if depth[v] < 0:
                out = -1
            elif out >= 0 and depth[v] > out:
                out = depth[v]
    if found != 6:
        raise Error("formal graph does not hold exactly the six aligned pairs")
    return out
