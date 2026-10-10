"""Exact catch-up analysis: is the cross-letter rigidity a one-tile question?

docs/p1b-vertex-coincidence-box-2026-10-02.md §5.6b. A *new* common vertex
arises on an edge `p -> u` into an offset-zero child `u` whose point `y` was
not already common at `p`'s level. If the top child index is 0, `y` is the
start of `p`'s top tile: it was already a vertex of tiling A and is *caught*
by B's subdivision (a catch-up); likewise for a bottom index 0. If both
indices are positive, `y` is born in both tilings at once (a simultaneous
birth). Both indices 0 would make `p` itself offset zero, so `y` would not be
new.

A catch-up into `y` happens at `p`'s left region endpoint: if the top index
is 0 then `y = 0` lies in the closure of `p`'s region, so `t_p <= 0` and the
left end is `0` (symmetrically for the bottom). So it is a step of `p`'s
*leftmost chain* -- the child whose region contains the parent's left end --
into offset zero. With `CU` the set of vertices whose leftmost chain reaches
offset zero:

    a vertex can reach a catch-up hit  <=>  it has a descendant in CU.

`CU` is the one-tile event: the left endpoint, a vertex of one tiling at
integral offset `s` inside a tile `b` of the other, is an eventual
subdivision boundary of `b`.

Right endpoints are the mirror image: reversing every image word (`mirror`)
reverses both tilings, so a catch-up at a right endpoint of `sigma` is a
left-endpoint catch-up of `mirror(sigma)`; `two_sided` checks both per
recurrent vertex. All signs are exact (`cached_sign`); a capped graph raises.
"""

from finite_linear_algebra.mat3 import Mat3, identity3
from psc.bpa import sigma3, substitution_incidence
from psc.leftmost_chain import leftmost_step
from psc.overlap_obstruction import recurrent_sccs
from psc.overlap_seed_patch import (
    OverlapState,
    SeedOverlapAutomaton,
    SeedOverlapTables,
    build_seed_overlap_tables,
    cached_sign,
    interior_overlap_cached,
)
from psc.perron_field3 import CubicElt, cubic_add_checked, cubic_mul_beta, cubic_sub_checked
from psc.vertex_coincidence import build_box_graph

comptime CU_UNKNOWN = 0
comptime CU_ACTIVE = 1
comptime CU_HITS = 2
comptime CU_MISSES = 3


def in_image_lattice(m: Mat3, v: List[Int]) -> Bool:
    """`v` lies in `M Z^3` iff `adj(M) v = det(M) M^{-1} v` is divisible by
    `det M` (`M` is invertible: PIP)."""
    var d = abs(m.det())
    var u = m.adjugate().apply(v)
    for i in range(3):
        if u[i] % d != 0:
            return False
    return True


def catch_up_free(sigma: List[List[Int]]) -> Bool:
    """No proper nonempty prefix of an image has its abelianisation in
    `M Z^3`. Then no edge anywhere in the overlap graph is a catch-up hit
    (Lemma P, docs/p1b-vertex-coincidence-box-2026-10-02.md §5.6b): a hit from
    `w` through child indices `(i, j)` needs `M w = ab(P_i) - ab(P_j)`, and
    for a catch-up one index is 0 and the other prefix is proper and
    nonempty. Suffixes give the same test, since `ab(suffix) = M e_a - ab(prefix)`."""
    var m = Mat3(substitution_incidence(sigma))
    for a in range(len(sigma)):
        var v: List[Int] = [0, 0, 0]
        for i in range(len(sigma[a]) - 1):
            v[sigma[a][i]] += 1
            if in_image_lattice(m, v):
                return False
    return True


def _odd_shaped(sigma: List[List[Int]], odd: List[Bool]) -> Bool:
    """Every image is one even letter, or odd . even* . odd."""
    for a in range(len(sigma)):
        var x = sigma[a].copy()
        if len(x) == 1:
            if odd[x[0]]:
                return False
            continue
        if not odd[x[0]] or not odd[x[len(x) - 1]]:
            return False
        for i in range(1, len(x) - 1):
            if odd[x[i]]:
                return False
    return True


def odd_letter_sets(sigma: List[List[Int]]) -> List[Int]:
    """Proposition C: the nonempty letter sets `O` (as bit masks) for which every
    image is a single letter outside `O` or an `O`-letter, letters outside
    `O`, and an `O`-letter. Such an `O` makes every column even and every
    proper prefix odd for the parity `f = sum over O`, so `M Z^3 <= ker f`
    excludes every proper prefix: `sigma` is catch-up-free. When
    `|det M| = 2` the converse holds with `ker f = M Z^3`."""
    var out = List[Int]()
    for mask in range(1, 8):
        var odd = List[Bool](length=3, fill=False)
        for c in range(3):
            odd[c] = (mask >> c) & 1 == 1
        if _odd_shaped(sigma, odd):
            out.append(mask)
    return out^


def _key(v: List[Int]) -> String:
    return String(v[0], ",", v[1], ",", v[2])


def level_is_valuation(sigma: List[List[Int]], n: Int) -> Bool:
    """Proposition P' at depth `n`: inside every `sigma^n(a)`, each interior
    vertex of exact level `k` (a boundary of the level-`k` supertiles but not
    of the level-`k+1` ones) sits at an abelianised position `v` with
    `max{k' <= n : v in M^k' Z^3} = k`. This holds iff `sigma` is
    catch-up-free (`catch_up_free`)."""
    var m = Mat3(substitution_incidence(sigma))
    var tau = sigma3(sigma)
    var powers: List[Mat3] = [identity3()]
    for _ in range(n):
        powers.append(powers[len(powers) - 1] * m)
    for a in range(len(sigma)):
        var level = Dict[String, Int]()
        var points = List[List[Int]]()
        for k in range(n, -1, -1):
            var x = tau.apply_n([a], n - k)
            var u: List[Int] = [0, 0, 0]
            for j in range(len(x) - 1):
                u[x[j]] += 1
                var v = powers[k].apply(u)
                var key = _key(v)
                if key not in level:
                    level[key] = k
                    points.append(v^)
        for p in range(len(points)):
            var val = 0
            for k in range(1, n + 1):
                if in_image_lattice(powers[k], points[p]):
                    val = k
            if val != level.get(_key(points[p]), -1):
                return False
    return True


def leftmost_child(
    tables: SeedOverlapTables, mut cache: Dict[CubicElt, Int], state: OverlapState
) raises -> OverlapState:
    """The child whose region contains `state`'s left region endpoint
    (`state` must have nonzero offset).

    One implementation, in `psc.leftmost_chain`, which also keeps the two child
    indices the step used and the sign lemma they satisfy."""
    return leftmost_step(tables, cache, state).child


struct OneTileVerdict(Copyable, Movable, Writable):
    var recurrent: Int
    var in_cu: Int
    var reach_cu: Int
    var short: Int  # vertices not reaching CU whose nonzero forward closure has <= 2 vertices

    def __init__(out self):
        self.recurrent = 0
        self.in_cu = 0
        self.reach_cu = 0
        self.short = 0

    def write_to[W: Writer](self, mut w: W):
        w.write("recurrent=", self.recurrent, " in_cu=", self.in_cu, " reach_cu=", self.reach_cu, " short=", self.short)


def _recurrent_nonzero(a: SeedOverlapAutomaton) raises -> List[Int]:
    """Indices of the recurrent vertices of `a` with nonzero offset."""
    var out = List[Int]()
    var comps = recurrent_sccs(a)
    for c in range(len(comps)):
        for k in range(len(comps[c])):
            if not a.states[comps[c][k]].shift.is_zero():
                out.append(comps[c][k])
    return out^


def _cu_marks(tables: SeedOverlapTables, a: SeedOverlapAutomaton) raises -> List[Int]:
    """CU by memoised leftmost chains (a functional graph on nonzero offsets)."""
    var cache = Dict[CubicElt, Int]()
    var n = a.size()
    var index = Dict[OverlapState, Int]()
    for i in range(n):
        index[a.states[i]] = i
    var mark = List[Int](length=n, fill=CU_UNKNOWN)
    for i in range(n):
        if a.states[i].shift.is_zero():
            mark[i] = CU_HITS
    for start in range(n):
        if mark[start] != CU_UNKNOWN:
            continue
        var path = List[Int]()
        var x = start
        var verdict: Int
        while True:
            if mark[x] == CU_HITS or mark[x] == CU_MISSES:
                verdict = mark[x]
                break
            if mark[x] == CU_ACTIVE:
                verdict = CU_MISSES  # the chain cycles without reaching offset zero
                break
            mark[x] = CU_ACTIVE
            path.append(x)
            var child = leftmost_child(tables, cache, a.states[x])
            if child not in index:
                raise Error("leftmost child lies outside the closed box graph")
            x = index[child]
        for k in range(len(path)):
            mark[path[k]] = verdict
    return mark^


def _reaches_cu(a: SeedOverlapAutomaton, mark: List[Int]) -> List[Bool]:
    """Vertices with a descendant (themselves included) in CU at nonzero offset."""
    var n = a.size()
    var good = List[Bool](length=n, fill=False)
    var parents = List[List[Int]]()
    for _ in range(n):
        parents.append(List[Int]())
    for i in range(n):
        for j in range(len(a.adj[i])):
            parents[a.adj[i][j]].append(i)
    var queue = List[Int]()
    for i in range(n):
        if mark[i] == CU_HITS and not a.states[i].shift.is_zero():
            good[i] = True
            queue.append(i)
    var head = 0
    while head < len(queue):
        var k = queue[head]
        head += 1
        for j in range(len(parents[k])):
            var p = parents[k][j]
            if not good[p]:
                good[p] = True
                queue.append(p)
    return good^


def nonzero_closure_size(a: SeedOverlapAutomaton, v: Int, cap: Int) -> Int:
    """Size of the nonzero-offset forward closure of `v` (itself included),
    or `cap + 1` once it exceeds `cap`."""
    var seen: List[Int] = [v]
    var head = 0
    while head < len(seen):
        var x = seen[head]
        head += 1
        for j in range(len(a.adj[x])):
            var y = a.adj[x][j]
            if a.states[y].shift.is_zero() or y in seen:
                continue
            if len(seen) == cap:
                return cap + 1
            seen.append(y)
    return len(seen)


def _short_closure(a: SeedOverlapAutomaton, v: Int) -> Bool:
    """`v` is a fixed point or lies on a 2-cycle of the inflation, with every
    other child at offset zero."""
    return nonzero_closure_size(a, v, 2) <= 2


def reaches_hit_kind(a: SeedOverlapAutomaton, diagonal: Bool) -> List[Bool]:
    """Nonzero-offset vertices with a descendant (themselves included) that
    has an offset-zero child `(c, d, 0)` with `c == d` (`diagonal`) or
    `c != d`, through nonzero-offset vertices only."""
    var n = a.size()
    var good = List[Bool](length=n, fill=False)
    var parents = List[List[Int]]()
    for _ in range(n):
        parents.append(List[Int]())
    for i in range(n):
        for j in range(len(a.adj[i])):
            parents[a.adj[i][j]].append(i)
    var queue = List[Int]()
    for i in range(n):
        if a.states[i].shift.is_zero():
            continue
        for j in range(len(a.adj[i])):
            var y = a.states[a.adj[i][j]]
            if y.shift.is_zero() and (y.top == y.bottom) == diagonal and not good[i]:
                good[i] = True
                queue.append(i)
    var head = 0
    while head < len(queue):
        var k = queue[head]
        head += 1
        for j in range(len(parents[k])):
            var p = parents[k][j]
            if not good[p] and not a.states[p].shift.is_zero():
                good[p] = True
                queue.append(p)
    return good^


def one_tile_from(tables: SeedOverlapTables, a: SeedOverlapAutomaton) raises -> OneTileVerdict:
    """Count the recurrent non-offset-zero vertices of the box graph `a` that lie
    in CU, that have a descendant in CU, and, among those that have none, the
    short ones (`_short_closure`)."""
    if a.capped:
        raise Error("one-tile analysis is undefined on a capped graph")
    var mark = _cu_marks(tables, a)
    var good = _reaches_cu(a, mark)
    var rec = _recurrent_nonzero(a)
    var v = OneTileVerdict()
    for k in range(len(rec)):
        v.recurrent += 1
        if mark[rec[k]] == CU_HITS:
            v.in_cu += 1
        if good[rec[k]]:
            v.reach_cu += 1
        elif _short_closure(a, rec[k]):
            v.short += 1
    return v^


def mirror(sigma: List[List[Int]]) -> List[List[Int]]:
    """Every image word reversed: the substitution of the mirrored tilings."""
    var out = List[List[Int]]()
    for a in range(len(sigma)):
        var w = List[Int]()
        for i in range(len(sigma[a]) - 1, -1, -1):
            w.append(sigma[a][i])
        out.append(w^)
    return out^


def one_tile(sigma: List[List[Int]]) raises -> OneTileVerdict:
    var tables = build_seed_overlap_tables(sigma)
    return one_tile_from(tables, build_box_graph(tables))


struct TwoSidedVerdict(Copyable, Movable, Writable):
    var recurrent: Int
    var reach_left: Int
    var reach_right: Int
    var reach_either: Int

    def __init__(out self):
        self.recurrent = 0
        self.reach_left = 0
        self.reach_right = 0
        self.reach_either = 0

    def write_to[W: Writer](self, mut w: W):
        w.write("recurrent=", self.recurrent, " reach_left=", self.reach_left, " reach_right=", self.reach_right, " reach_either=", self.reach_either)


def two_sided(sigma: List[List[Int]]) raises -> TwoSidedVerdict:
    """Per recurrent vertex: can it reach a catch-up at a left endpoint (CU of
    `sigma`) or at a right endpoint (CU of the mirror, through the vertex map
    `(a, b, t) -> (a, b, l_a - l_b - t)`)? Mirroring `x -> -x` maps the
    children of a pair to the children of its image, so the recurrent parts
    correspond; but offset zero is not counted and mirroring exchanges left-
    and right-aligned vertices, so the nonzero counts differ (Tribonacci: 14
    and 8), hence the per-vertex map. A recurrent vertex whose image is
    missing from the mirror's box graph raises."""
    var tables = build_seed_overlap_tables(sigma)
    var a = build_box_graph(tables)
    var mtables = build_seed_overlap_tables(mirror(sigma))
    var m = build_box_graph(mtables)
    if a.capped or m.capped:
        raise Error("one-tile analysis is undefined on a capped graph")
    var good = _reaches_cu(a, _cu_marks(tables, a))
    var mgood = _reaches_cu(m, _cu_marks(mtables, m))
    var mindex = Dict[OverlapState, Int]()
    for i in range(m.size()):
        mindex[m.states[i]] = i
    var rec = _recurrent_nonzero(a)
    var v = TwoSidedVerdict()
    for k in range(len(rec)):
        var st = a.states[rec[k]]
        var image = OverlapState(
            st.top,
            st.bottom,
            cubic_sub_checked(cubic_sub_checked(mtables.lengths.at(st.top), mtables.lengths.at(st.bottom)), st.shift),
        )
        if image not in mindex:
            raise Error("mirror image of a recurrent vertex lies outside the mirror's box graph")
        var left = good[rec[k]]
        var right = mgood[mindex[image]]
        v.recurrent += 1
        if left:
            v.reach_left += 1
        if right:
            v.reach_right += 1
        if left or right:
            v.reach_either += 1
    return v^
