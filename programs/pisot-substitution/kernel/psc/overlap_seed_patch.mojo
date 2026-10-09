"""Exact one-dimensional seed-patch overlap graph for G1b-2 diagnostics.

The graph starts from the same two-letter seed superpositions ``(ab, ba)`` used
by the repository balanced-pair automaton. A state records two tile types and
the exact displacement of the bottom tile start from the top tile start as an
element of ``Z[beta]``. Inflation is exact in the cubic Perron field.

This is intentionally called a *seed-patch overlap graph*. It is not yet
identified with the complete realized-overlap graph appearing in the general
overlap-coincidence literature; that realization/dictionary statement remains
a theorem target. Capped construction and arithmetic overflow are inconclusive
and fail closed.
"""

from psc.bpa import substitution_incidence
from finite_linear_algebra.mat3 import Mat3
from psc.perron_field3 import (
    CubicElt,
    PerronField3,
    TileLengths3,
    build_perron_field3,
    cubic_add_checked,
    cubic_mul_beta,
    cubic_sub_checked,
    left_perron_tile_lengths,
    perron_tile_lengths_in,
    screened_perron_field3,
    sign_at_perron,
)


struct OverlapState(ImplicitlyCopyable, Copyable, Movable, Equatable, Hashable, Writable):
    var top: Int
    var bottom: Int
    var shift: CubicElt

    def __init__(out self, top: Int, bottom: Int, shift: CubicElt):
        self.top = top
        self.bottom = bottom
        self.shift = shift

    def __eq__(self, other: OverlapState) -> Bool:
        return self.top == other.top and self.bottom == other.bottom and self.shift == other.shift

    def __ne__(self, other: OverlapState) -> Bool:
        return not (self == other)

    def is_coincidence(self) -> Bool:
        return self.top == self.bottom and self.shift.is_zero()

    def write_to[W: Writer](self, mut w: W):
        w.write("(", self.top, ",", self.bottom, ",", self.shift, ")")


struct SeedOverlapTables(Copyable, Movable):
    var sigma: List[List[Int]]
    var field: PerronField3
    var lengths: TileLengths3
    var prefix_starts: List[Int]
    var prefix_positions: List[CubicElt]

    def __init__(
        out self,
        sigma: List[List[Int]],
        field: PerronField3,
        lengths: TileLengths3,
        prefix_starts: List[Int],
        prefix_positions: List[CubicElt],
    ):
        self.sigma = sigma.copy()
        self.field = field
        self.lengths = lengths
        self.prefix_starts = prefix_starts.copy()
        self.prefix_positions = prefix_positions.copy()

    def prefix(self, parent: Int, child_index: Int) raises -> CubicElt:
        if parent < 0 or parent >= 3:
            raise Error("overlap parent letter lies outside 0..2")
        if child_index < 0 or child_index >= len(self.sigma[parent]):
            raise Error("overlap child index lies outside parent image")
        return self.prefix_positions[self.prefix_starts[parent] + child_index]


struct SeedOverlapAutomaton(Copyable, Movable):
    var states: List[OverlapState]
    var adj: List[List[Int]]
    var capped: Bool

    def __init__(
        out self,
        states: List[OverlapState],
        adj: List[List[Int]],
        capped: Bool,
    ):
        self.states = states.copy()
        self.adj = adj.copy()
        self.capped = capped

    def size(self) -> Int:
        return len(self.states)


def _validate_sigma(sigma: List[List[Int]]) raises:
    if len(sigma) != 3:
        raise Error("seed-patch overlap graph requires three substitution images")
    for a in range(3):
        if len(sigma[a]) == 0:
            raise Error("seed-patch overlap graph requires a non-erasing substitution")
        for j in range(len(sigma[a])):
            if sigma[a][j] < 0 or sigma[a][j] >= 3:
                raise Error("seed-patch overlap letter lies outside 0..2")


def build_seed_overlap_tables(sigma: List[List[Int]]) raises -> SeedOverlapTables:
    _validate_sigma(sigma)
    var m = Mat3(substitution_incidence(sigma))
    return _tables_from(sigma, build_perron_field3(m), left_perron_tile_lengths(m))


def build_seed_overlap_tables_screened(sigma: List[List[Int]]) raises -> SeedOverlapTables:
    """`build_seed_overlap_tables` outside the audited image-length domain.

    The field comes from `screened_perron_field3`, which screens the
    characteristic polynomial exactly instead of running the matrix-level
    predicate that `build_perron_field3` is certified for, and the tile lengths
    from `perron_tile_lengths_in`, which re-checks that field against the
    matrix. All later arithmetic is checked and raises on overflow."""
    _validate_sigma(sigma)
    var m = Mat3(substitution_incidence(sigma))
    var field = screened_perron_field3(m)
    return _tables_from(sigma, field, perron_tile_lengths_in(field, m))


def _tables_from(
    sigma: List[List[Int]], field: PerronField3, lengths: TileLengths3
) raises -> SeedOverlapTables:
    """The prefix positions of `sigma` over an already-built field and lengths.

    The scaling check stays here: it is what ties the positions to the field,
    and it must run for every substitution, not once per incidence matrix."""
    var starts: List[Int] = [0]
    var positions = List[CubicElt]()
    for parent in range(3):
        var cursor = CubicElt()
        for j in range(len(sigma[parent])):
            positions.append(cursor)
            cursor = cubic_add_checked(cursor, lengths.at(sigma[parent][j]))
        if cursor != cubic_mul_beta(field, lengths.at(parent)):
            raise Error("substitution image length disagrees with Perron scaling")
        starts.append(len(positions))
    return SeedOverlapTables(sigma, field, lengths, starts, positions)


def incidence_key(sigma: List[List[Int]]) -> String:
    """The incidence matrix of `sigma`, row major, as a dictionary key."""
    var entries = substitution_incidence(sigma)
    var key = String("")
    for i in range(len(entries)):
        key += String(entries[i]) + ","
    return key^


struct PerronCache(Copyable, Movable):
    """The Perron field and tile lengths of an incidence matrix, kept once.

    `build_seed_overlap_tables` reads the cubic field and the left-Perron tile
    lengths off the incidence matrix, and everything else it builds -- the
    prefix positions -- off the images in order. The first part is essentially
    the whole cost, at about 628 of the 632 microseconds a build takes, since
    it isolates the Perron root and decides signs exactly.

    Over the standing corpus 4,554 specimens carry only 348 distinct incidence
    matrices, so that work is repeated about thirteen times over for each
    matrix that occurs. Here it is done once per matrix, and the prefix
    positions are still computed per substitution, which they must be: two
    substitutions can share an incidence matrix while their images differ in
    order, and then their prefix positions differ. Keying whole tables by the
    incidence matrix would be wrong for exactly that reason.
    """

    var index: Dict[String, Int]
    var fields: List[PerronField3]
    var lengths: List[TileLengths3]

    def __init__(out self):
        self.index = Dict[String, Int]()
        self.fields = List[PerronField3]()
        self.lengths = List[TileLengths3]()

    def tables_for(mut self, sigma: List[List[Int]]) raises -> SeedOverlapTables:
        """`build_seed_overlap_tables`, reusing the field and lengths of an
        incidence matrix already seen."""
        _validate_sigma(sigma)
        var key = incidence_key(sigma)
        if key not in self.index:
            # Build before indexing: a refused build must leave no entry
            # pointing at a slot that was never filled.
            var m = Mat3(substitution_incidence(sigma))
            var field = build_perron_field3(m)
            var lengths = left_perron_tile_lengths(m)
            self.index[key] = len(self.fields)
            self.fields.append(field^)
            self.lengths.append(lengths^)
        var slot = self.index[key]
        return _tables_from(sigma, self.fields[slot], self.lengths[slot])

    def distinct_matrices(self) -> Int:
        return len(self.fields)


def cached_sign(
    tables: SeedOverlapTables,
    mut cache: Dict[CubicElt, Int],
    x: CubicElt,
) raises -> Int:
    if x in cache:
        return cache[x]
    # Graph construction needs only the exact sign. The exact Sturm--Tarski
    # oracle over machine integers is cheaper than a rational-interval
    # enclosure over unbounded rationals, and both are exact, so the
    # interval-first path is reserved for the margin audit, which reports
    # interval certification (psc.overlap_interval_audit).
    var s = sign_at_perron(tables.field, x)
    cache[x] = s
    return s


def interior_overlap_cached(
    tables: SeedOverlapTables,
    mut cache: Dict[CubicElt, Int],
    state: OverlapState,
) raises -> Bool:
    if state.top < 0 or state.top >= 3 or state.bottom < 0 or state.bottom >= 3:
        raise Error("overlap state tile type lies outside 0..2")
    # Top interval [0,l_top], bottom [shift, shift+l_bottom].
    var right_of_top_start = cubic_add_checked(
        state.shift, tables.lengths.at(state.bottom)
    )
    var left_of_top_end = cubic_sub_checked(
        state.shift, tables.lengths.at(state.top)
    )
    return (
        cached_sign(tables, cache, right_of_top_start) > 0
        and cached_sign(tables, cache, left_of_top_end) < 0
    )


def interior_overlap(tables: SeedOverlapTables, state: OverlapState) raises -> Bool:
    var cache = Dict[CubicElt, Int]()
    return interior_overlap_cached(tables, cache, state)


def seed_overlap_states_cached(
    tables: SeedOverlapTables, mut cache: Dict[CubicElt, Int]
) raises -> List[OverlapState]:
    var out = List[OverlapState]()
    for a in range(3):
        for b in range(a + 1, 3):
            var top_types: List[Int] = [a, b]
            var bottom_types: List[Int] = [b, a]
            var top_starts: List[CubicElt] = [CubicElt(), tables.lengths.at(a)]
            var bottom_starts: List[CubicElt] = [CubicElt(), tables.lengths.at(b)]
            for i in range(2):
                for j in range(2):
                    var state = OverlapState(
                        top_types[i],
                        bottom_types[j],
                        cubic_sub_checked(bottom_starts[j], top_starts[i]),
                    )
                    if interior_overlap_cached(tables, cache, state):
                        out.append(state)
    return out^


def seed_overlap_states(tables: SeedOverlapTables) raises -> List[OverlapState]:
    var cache = Dict[CubicElt, Int]()
    return seed_overlap_states_cached(tables, cache)


def overlap_children_cached(
    tables: SeedOverlapTables,
    mut cache: Dict[CubicElt, Int],
    state: OverlapState,
) raises -> List[OverlapState]:
    if not interior_overlap_cached(tables, cache, state):
        raise Error("cannot inflate a non-overlap state")
    var out = List[OverlapState]()
    var scaled_shift = cubic_mul_beta(tables.field, state.shift)
    for i in range(len(tables.sigma[state.top])):
        var top_child = tables.sigma[state.top][i]
        var top_prefix = tables.prefix(state.top, i)
        for j in range(len(tables.sigma[state.bottom])):
            var bottom_child = tables.sigma[state.bottom][j]
            var bottom_prefix = tables.prefix(state.bottom, j)
            var shifted = cubic_add_checked(scaled_shift, bottom_prefix)
            var child = OverlapState(
                top_child,
                bottom_child,
                cubic_sub_checked(shifted, top_prefix),
            )
            if interior_overlap_cached(tables, cache, child):
                out.append(child)
    return out^


def overlap_children(
    tables: SeedOverlapTables, state: OverlapState
) raises -> List[OverlapState]:
    var cache = Dict[CubicElt, Int]()
    return overlap_children_cached(tables, cache, state)


def build_seed_overlap_graph(
    sigma: List[List[Int]], max_states: Int = 20000
) raises -> SeedOverlapAutomaton:
    """`build_seed_overlap_graph_from_tables` with the exact tables built here."""
    return build_seed_overlap_graph_from_tables(build_seed_overlap_tables(sigma), max_states)


def build_seed_overlap_graph_from_tables(
    tables: SeedOverlapTables, max_states: Int = 20000
) raises -> SeedOverlapAutomaton:
    """Breadth-first closure of the swap-seed overlaps under inflation.

    Takes the substitution's exact tables so a census builds them once per
    specimen and shares them with the endpoint scans."""
    var sign_cache = Dict[CubicElt, Int]()
    var seeds = seed_overlap_states_cached(tables, sign_cache)
    return build_overlap_graph_from_seeds(tables, seeds, sign_cache, max_states)


def build_overlap_graph_from_seeds(
    tables: SeedOverlapTables,
    seeds: List[OverlapState],
    mut sign_cache: Dict[CubicElt, Int],
    max_states: Int = 20000,
) raises -> SeedOverlapAutomaton:
    """Breadth-first closure under inflation of an arbitrary set of overlaps.

    The swap seeds give the seed-patch graph; a level-zero overlap set read off
    a fixed-point prefix gives the corresponding Sirvent--Solomyak overlap
    graph (`psc.oa_overlap_types`). Both closures are the same exact kernel, so
    a type of one graph is a type of the other exactly when the states agree."""
    if max_states <= 0:
        raise Error("seed-patch overlap state cap must be positive")
    var states = List[OverlapState]()
    var adj = List[List[Int]]()
    var index = Dict[OverlapState, Int](capacity=max_states)
    var queue = seeds.copy()
    var capped = False
    var head = 0

    while head < len(queue):
        var state = queue[head]
        head += 1
        if state in index:
            continue
        if len(states) >= max_states:
            capped = True
            break
        index[state] = len(states)
        states.append(state)
        adj.append(List[Int]())
        if state.is_coincidence():
            continue
        var cs = overlap_children_cached(tables, sign_cache, state)
        for i in range(len(cs)):
            queue.append(cs[i])

    if capped:
        return SeedOverlapAutomaton(states, adj, True)

    for i in range(len(states)):
        if states[i].is_coincidence():
            continue
        var cs = overlap_children_cached(tables, sign_cache, states[i])
        for j in range(len(cs)):
            if cs[j] not in index:
                raise Error("terminated overlap graph lost a reachable child")
            adj[i].append(index[cs[j]])
    return SeedOverlapAutomaton(states, adj, False)


def nonproductive_overlap_states(a: SeedOverlapAutomaton) raises -> List[Int]:
    """States from which no exact tile coincidence is reachable.

    A capped automaton is an incomplete prefix of the graph. Productivity is
    undefined there, so the query fails closed instead of turning an
    inconclusive cap into false nonproductivity evidence.
    """
    if a.capped:
        raise Error("overlap productivity is undefined for a capped partial graph")
    var good = List[Bool]()
    for i in range(a.size()):
        good.append(a.states[i].is_coincidence())
    var changed = True
    while changed:
        changed = False
        for i in range(a.size()):
            if good[i]:
                continue
            for j in range(len(a.adj[i])):
                if good[a.adj[i][j]]:
                    good[i] = True
                    changed = True
                    break
    var out = List[Int]()
    for i in range(a.size()):
        if not good[i]:
            out.append(i)
    return out^

def first_depths(a: SeedOverlapAutomaton, target: List[Bool]) raises -> List[Int]:
    """Shortest number of inflations from each vertex to a target vertex, `-1` if none.

    Reverse breadth-first search from the target vertices; fails closed on a
    capped graph like `nonproductive_overlap_states`."""
    if a.capped:
        raise Error("first-target depth is undefined for a capped partial graph")
    var n = a.size()
    if len(target) != n:
        raise Error("target mask length disagrees with the overlap graph size")
    var parents = List[List[Int]]()
    for _ in range(n):
        parents.append(List[Int]())
    for i in range(n):
        for j in range(len(a.adj[i])):
            parents[a.adj[i][j]].append(i)
    var dist = List[Int]()
    var queue = List[Int]()
    for i in range(n):
        if target[i]:
            dist.append(0)
            queue.append(i)
        else:
            dist.append(-1)
    var head = 0
    while head < len(queue):
        var k = queue[head]
        head += 1
        for j in range(len(parents[k])):
            var p = parents[k][j]
            if dist[p] < 0:
                dist[p] = dist[k] + 1
                queue.append(p)
    return dist^


def first_coincidence_depths(a: SeedOverlapAutomaton) raises -> List[Int]:
    """Shortest number of inflations from each vertex to a coincidence, `-1` if none."""
    var target = List[Bool]()
    for i in range(a.size()):
        target.append(a.states[i].is_coincidence())
    return first_depths(a, target)


def first_left_aligned_depths(a: SeedOverlapAutomaton) raises -> List[Int]:
    """Least number of inflations after which a vertex has an offset-zero descendant.

    Offset zero (coincidences included) is a boundary coincidence: a sub-tile
    of the inflated top tile and a sub-tile of the inflated bottom tile have
    the same left endpoint.  `-1` if no descendant is ever left-aligned."""
    var target = List[Bool]()
    for i in range(a.size()):
        target.append(a.states[i].shift.is_zero())
    return first_depths(a, target)


def strong_coincidence_depth(
    a: SeedOverlapAutomaton, tables: SeedOverlapTables, suffix: Bool
) raises -> Int:
    """`strong_coincidence_depth_from` with the coincidence depths computed here."""
    return strong_coincidence_depth_from(first_coincidence_depths(a), a, tables, suffix)


def strong_coincidence_depth_from(
    depths: List[Int], a: SeedOverlapAutomaton, tables: SeedOverlapTables, suffix: Bool
) raises -> Int:
    """Largest first-coincidence depth over the endpoint-aligned non-coincidence vertices.

    `depths` must be `first_coincidence_depths(a)`; passing it in lets a census
    reuse one reverse search for the prefix and suffix scans.

    Left-aligned vertices `(i, j, 0)` (prefix form, `suffix == False`) are
    productive iff the pair is eventually coincident in the sense of Barge and
    Diamond; right-aligned vertices `(i, j, l_i - l_j)` iff the pair is
    eventually coincident for the reversed substitution.  The graph is seeded
    with one orientation per unordered pair and exchanging the two tilings
    preserves depths, so each pair is counted in the orientation that occurs.
    Returns `-1` if some aligned vertex is nonproductive, and raises if there
    is no aligned vertex."""
    if a.capped:
        raise Error("strong-coincidence depth is undefined for a capped partial graph")
    if len(depths) != a.size():
        raise Error("coincidence depth vector length disagrees with the overlap graph size")
    var worst = -2
    for i in range(a.size()):
        var st = a.states[i]
        if st.is_coincidence():
            continue
        var aligned: Bool
        if suffix:
            aligned = st.shift == tables.lengths.at(st.top) - tables.lengths.at(st.bottom)
        else:
            aligned = st.shift.is_zero()
        if not aligned:
            continue
        if depths[i] < 0:
            return -1
        if depths[i] > worst:
            worst = depths[i]
    if worst < 0:
        raise Error("no endpoint-aligned overlap vertex found")
    return worst
