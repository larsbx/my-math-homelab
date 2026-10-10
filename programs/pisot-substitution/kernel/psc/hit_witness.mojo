"""Occurrence-level certificates for the existing finite-box catch-up contract.

All outgoing hit occurrences are targets, not one selected hit path. Reverse
BFS decides existence at arbitrary depth on the complete Proposition V graph.
Left and right endpoints are checked directly, without building a mirror graph.
Equal-letter coincidences are absorbing: their identical subdivisions cannot
introduce unequal birth levels. Capped graphs have no verdict.
"""

from psc.one_tile import _recurrent_nonzero
from psc.overlap_seed_patch import (
    OverlapState, SeedOverlapAutomaton, SeedOverlapTables, cached_sign,
    interior_overlap_cached,
)
from psc.perron_field3 import CubicElt, cubic_add_checked, cubic_mul_beta, cubic_sub_checked


def vertex_label(st: OverlapState) -> String:
    """Stable identity in the canonical integral power basis, never a graph ID."""
    return String(st.top, ",", st.bottom, ",", st.shift.a0, ",", st.shift.a1, ",", st.shift.a2)


struct Occurrence(ImplicitlyCopyable, Copyable, Movable):
    var top_index: Int
    var bottom_index: Int
    var child: OverlapState

    def __init__(out self, i: Int, j: Int, child: OverlapState):
        self.top_index = i
        self.bottom_index = j
        self.child = child


def hit_kind(tables: SeedOverlapTables, parent: OverlapState, e: Occurrence, right: Bool) raises -> Int:
    """0 no hit, 1 inherited common endpoint, 2 new simultaneous, 3 catch-up.

    For a left endpoint, index zero inherits the parent's boundary; for a
    right endpoint, the last child inherits it. Two inherited endpoints are
    already common and must never count as a new hit.
    """
    var aligned = e.child.shift.is_zero()
    var old_a = e.top_index == 0
    var old_b = e.bottom_index == 0
    if right:
        aligned = e.child.shift == cubic_sub_checked(
            tables.lengths.at(e.child.top), tables.lengths.at(e.child.bottom)
        )
        old_a = e.top_index == len(tables.sigma[parent.top]) - 1
        old_b = e.bottom_index == len(tables.sigma[parent.bottom]) - 1
    if not aligned:
        return 0
    if old_a and old_b:
        return 1
    if old_a != old_b:
        return 3
    return 2


def occurrences(
    tables: SeedOverlapTables, parent: OverlapState, mut cache: Dict[CubicElt, Int]
) raises -> List[Occurrence]:
    """Every interior-overlap child occurrence, preserving duplicate type edges."""
    var out = List[Occurrence]()
    var scaled = cubic_mul_beta(tables.field, parent.shift)
    for i in range(len(tables.sigma[parent.top])):
        for j in range(len(tables.sigma[parent.bottom])):
            var shift = cubic_sub_checked(
                cubic_add_checked(scaled, tables.prefix(parent.bottom, j)),
                tables.prefix(parent.top, i),
            )
            var child = OverlapState(tables.sigma[parent.top][i], tables.sigma[parent.bottom][j], shift)
            if interior_overlap_cached(tables, cache, child):
                out.append(Occurrence(i, j, child))
    return out^


def _edge_depths(parents: List[List[Int]], target: List[Bool]) -> List[Int]:
    """Distance to a target *edge*: target tails have distance 1, not 0."""
    var dist = List[Int](length=len(target), fill=-1)
    var queue = List[Int]()
    for v in range(len(target)):
        if target[v]:
            dist[v] = 1
            queue.append(v)
    var head = 0
    while head < len(queue):
        var v = queue[head]
        head += 1
        for p in parents[v]:
            if dist[p] < 0:
                dist[p] = dist[v] + 1
                queue.append(p)
    return dist^


struct HitAnalysis(Copyable, Movable):
    var left: List[Int]   # least depth of a new catch-up, -1 iff none at any depth
    var right: List[Int]
    var new_left: List[Int]  # least depth of any new hit (inherited endpoints excluded)
    var new_right: List[Int]
    var recurrent: List[Int]  # stable graph traversal order, nonzero offsets only

    def __init__(out self):
        self.left = List[Int]()
        self.right = List[Int]()
        self.new_left = List[Int]()
        self.new_right = List[Int]()
        self.recurrent = List[Int]()


def analyze_hits(tables: SeedOverlapTables, a: SeedOverlapAutomaton) raises -> HitAnalysis:
    if a.capped:
        raise Error("hit witnesses are undefined on a capped box graph")
    var n = a.size()
    var parents = List[List[Int]]()
    var lc = List[Bool](length=n, fill=False)
    var rc = List[Bool](length=n, fill=False)
    var lh = List[Bool](length=n, fill=False)
    var rh = List[Bool](length=n, fill=False)
    for _ in range(n):
        parents.append(List[Int]())
    # Prefix corrections and right-endpoint alignments are substitution-local.
    var corrections = List[List[CubicElt]]()
    var right_offsets = List[CubicElt]()
    for top in range(3):
        for bottom in range(3):
            right_offsets.append(cubic_sub_checked(
                tables.lengths.at(top), tables.lengths.at(bottom)
            ))
            var row = List[CubicElt]()
            for i in range(len(tables.sigma[top])):
                for j in range(len(tables.sigma[bottom])):
                    row.append(cubic_sub_checked(tables.prefix(bottom, j), tables.prefix(top, i)))
            corrections.append(row^)
    for v in range(n):
        for u in a.adj[v]:
            parents[u].append(v)
        var st = a.states[v]
        if st.is_coincidence():
            continue
        var scaled = cubic_mul_beta(tables.field, st.shift)
        for i in range(len(tables.sigma[st.top])):
            for j in range(len(tables.sigma[st.bottom])):
                var shift = cubic_add_checked(
                    scaled,
                    corrections[3 * st.top + st.bottom][i * len(tables.sigma[st.bottom]) + j],
                )
                var top = tables.sigma[st.top][i]
                var bottom = tables.sigma[st.bottom][j]
                var e = Occurrence(i, j, OverlapState(top, bottom, shift))
                # Aligned positive-length tiles necessarily overlap. No sign
                # query is needed for these target predicates.
                if not shift.is_zero() and shift != right_offsets[3 * top + bottom]:
                    continue
                var found = False
                for u in a.adj[v]:
                    if a.states[u] == e.child:
                        found = True
                        break
                if not found:
                    raise Error("complete graph lost an aligned child occurrence")
                var l = hit_kind(tables, st, e, False)
                var r = hit_kind(tables, st, e, True)
                lh[v] = lh[v] or l >= 2
                rh[v] = rh[v] or r >= 2
                lc[v] = lc[v] or l == 3
                rc[v] = rc[v] or r == 3
    var out = HitAnalysis()
    out.left = _edge_depths(parents, lc)
    out.right = _edge_depths(parents, rc)
    out.new_left = _edge_depths(parents, lh)
    out.new_right = _edge_depths(parents, rh)
    var rec = _recurrent_nonzero(a)
    var recurrent = List[Bool](length=n, fill=False)
    for v in rec:
        recurrent[v] = True
    for v in range(n):
        if recurrent[v]:
            out.recurrent.append(v)
    return out^


def witness_path(
    tables: SeedOverlapTables, a: SeedOverlapAutomaton, source: Int,
    dist: List[Int], right: Bool, catch_only: Bool,
) raises -> List[Occurrence]:
    """One replayable witness AFTER all-path existence was decided by BFS."""
    if a.capped or len(dist) != a.size() or source < 0 or source >= a.size():
        raise Error("invalid witness request")
    if dist[source] < 1:
        raise Error("requested hit has no witness")
    var path = List[Occurrence]()
    var v = source
    var cache = Dict[CubicElt, Int]()
    while True:
        var es = occurrences(tables, a.states[v], cache)
        var found = False
        for e in es:
            if dist[v] == 1:
                var kind = hit_kind(tables, a.states[v], e, right)
                if (kind == 3 if catch_only else kind >= 2):
                    path.append(e)
                    return path^
            else:
                for u in a.adj[v]:
                    if a.states[u] == e.child and dist[u] == dist[v] - 1:
                        path.append(e)
                        v = u
                        found = True
                        break
                if found:
                    break
        if not found:
            raise Error("hit distance has no replayable occurrence path")


def replay_births(
    tables: SeedOverlapTables, source: OverlapState, path: List[Occurrence], right: Bool
) raises -> List[Int]:
    """Replay addresses and give birth levels relative to the source level 0.

    A left boundary is last born when the address last leaves child 0; a
    right boundary when it last leaves the last child. This handles arbitrarily
    long inherited tails without carrying unbounded history in the automaton.
    A returned 0 means the boundary already existed at the source level:
    its actual birth could precede that level. This never changes the new
    hit's equality/inequality verdict, since one birth is the terminal level.
    """
    if len(path) == 0:
        raise Error("a new hit needs a nonempty path")
    var parent = source
    var born: List[Int] = [0, 0]
    var cache = Dict[CubicElt, Int]()
    for k in range(len(path)):
        var e = path[k]
        if (
            e.top_index < 0 or e.top_index >= len(tables.sigma[parent.top])
            or e.bottom_index < 0 or e.bottom_index >= len(tables.sigma[parent.bottom])
        ):
            raise Error("hit path address lies outside its parent image")
        # Validate every occurrence from the original substitution, not IDs.
        var expected = OverlapState(
            tables.sigma[parent.top][e.top_index],
            tables.sigma[parent.bottom][e.bottom_index],
            cubic_sub_checked(
                cubic_add_checked(
                    cubic_mul_beta(tables.field, parent.shift),
                    tables.prefix(parent.bottom, e.bottom_index),
                ),
                tables.prefix(parent.top, e.top_index),
            ),
        )
        if expected != e.child or not interior_overlap_cached(tables, cache, e.child):
            raise Error("hit path occurrence does not replay")
        var endpoint_a = len(tables.sigma[parent.top]) - 1 if right else 0
        var endpoint_b = len(tables.sigma[parent.bottom]) - 1 if right else 0
        if e.top_index != endpoint_a:
            born[0] = k + 1
        if e.bottom_index != endpoint_b:
            born[1] = k + 1
        if k == len(path) - 1 and hit_kind(tables, parent, e, right) < 2:
            raise Error("witness ends at an inherited endpoint or a non-hit")
        parent = e.child
    return born^


def simultaneous_closure(
    tables: SeedOverlapTables, a: SeedOverlapAutomaton, source: Int
) raises -> List[Int]:
    """Replayable negative certificate: full forward closure has no catch-up edge.

    Recompute every occurrence and compare with the graph, preserving
    multiplicities. A missing non-hit edge could hide a later witness, so
    absence is never certified from a partial closure. Coincidences are the
    only explicitly justified absorbing states.
    """
    if a.capped or source < 0 or source >= a.size():
        raise Error("invalid simultaneous-only certificate request")
    var index = Dict[OverlapState, Int]()
    for v in range(a.size()):
        index[a.states[v]] = v
    var seen = List[Bool](length=a.size(), fill=False)
    var queue: List[Int] = [source]
    seen[source] = True
    var cache = Dict[CubicElt, Int]()
    var head = 0
    while head < len(queue):
        var v = queue[head]
        head += 1
        if a.states[v].is_coincidence():
            if len(a.adj[v]) != 0:
                raise Error("coincidence is not absorbing in the canonical graph")
            continue
        var es = occurrences(tables, a.states[v], cache)
        if len(es) != len(a.adj[v]):
            raise Error("negative certificate graph is not occurrence-complete")
        for k in range(len(es)):
            var e = es[k]
            if e.child not in index or index[e.child] != a.adj[v][k]:
                raise Error("negative certificate lost a child occurrence")
            if hit_kind(tables, a.states[v], e, False) == 3 or hit_kind(tables, a.states[v], e, True) == 3:
                raise Error("simultaneous-only certificate contains a catch-up")
            var u = index[e.child]
            if not seen[u]:
                seen[u] = True
                queue.append(u)
    return queue^
