"""Overlap types of the Sirvent--Solomyak graph, compared with the seed patch.

For a fixed point `u` of a prolongable power `tau = sigma^q` and a prefix
`W = u[:k]`, the literature overlap graph `G_O(T, x(W))` has vertices the
overlap types of the tiling pair `(T, T - g(W))`. Its level-zero types are
read off the pair `(u, S^k u)`: the top tile at `g(u[:i])` and the bottom tile
at `g(u[:m]) - g(W)`, so the offset is the integer combination
`<l, pi(u[i:m]) - pi(W)>` of the exact tile lengths. Only tiles within a
window of each other can overlap, and the window is decided exactly in
`Q(beta)`: `n` consecutive tiles span at least `n * l_min`, while two
overlapping tiles lie within `g(W) + l_max` of each other.

Closing those level-zero types under inflation uses the same exact kernel as
the seed-patch graph (`psc.overlap_seed_patch`), so the two graphs are
comparable vertex by vertex. Productivity of an overlap depends only on its
type, so an inclusion `types(G_O) subset of types(O_sigma)` transfers
seed-patch productivity to the literature graph.

This is exploratory. The level-zero types come from a finite prefix of `u`,
which is an uncertified factor set: a computed inclusion is evidence about
that prefix, not a theorem about the whole tiling.
"""

from psc.overlap_seed_patch import (
    OverlapState,
    SeedOverlapAutomaton,
    SeedOverlapTables,
    build_overlap_graph_from_seeds,
    build_seed_overlap_graph_from_tables,
    interior_overlap_cached,
    nonproductive_overlap_states,
)
from psc.perron_field3 import (
    CubicElt,
    cubic_add_checked,
    cubic_scale_checked,
    cubic_sub_checked,
    sign_at_perron,
)
from psc.words import ALPHABET
from substitution_dynamics import dumont_thomas as sd_dumont_thomas
from substitution_dynamics.dumont_thomas import ProlongablePoint
from substitution_dynamics.substitution import Substitution


def prolongable_points(sigma: List[List[Int]]) -> List[ProlongablePoint]:
    """Every `(q, c)` with `q <= |A|` minimal for its cycle of the first-letter
    map, in increasing `q` then `c`: exactly the cycles of `sigma_+`."""
    # Trusted constructor over len(sigma) letters: unvalidated, as before.
    return sd_dumont_thomas.prolongable_points(Substitution(sigma.copy(), len(sigma)))


def prolongable_point(sigma: List[List[Int]]) raises -> ProlongablePoint:
    """The least prolongable `(q, c)`; every substitution with a non-erasing
    image has one, because the first-letter map of a finite alphabet has a
    cycle."""
    return sd_dumont_thomas.prolongable_point(Substitution(sigma.copy(), len(sigma)))


def fixed_point_prefix(
    sigma: List[List[Int]], point: ProlongablePoint, min_length: Int
) -> List[Int]:
    """A prefix of the fixed point of `sigma^q` starting at `c`, at least
    `min_length` letters long."""
    # Trusted constructor over len(sigma) letters: unvalidated, as before.
    var tau = Substitution(sigma.copy(), len(sigma))
    var u: List[Int] = [point.letter]
    while len(u) < min_length:
        u = tau.apply_n(u, point.power)
    return u^


def parikh_prefix_sums(w: List[Int]) -> List[Int]:
    """Row-major `(|w| + 1) x 3` table with row `i` the Parikh vector of `w[:i]`."""
    var out = List[Int](length=ALPHABET * (len(w) + 1), fill=0)
    for i in range(len(w)):
        for a in range(ALPHABET):
            out[ALPHABET * (i + 1) + a] = out[ALPHABET * i + a]
        out[ALPHABET * (i + 1) + w[i]] += 1
    return out^


def tile_length_combination(
    tables: SeedOverlapTables, coefficients: List[Int]
) raises -> CubicElt:
    """`<l, coefficients>`: the exact translation of an integer letter vector."""
    var total = CubicElt()
    for a in range(ALPHABET):
        if coefficients[a] != 0:
            total = cubic_add_checked(
                total, cubic_scale_checked(tables.lengths.at(a), coefficients[a])
            )
    return total^


def extremal_tile_length(tables: SeedOverlapTables, largest: Bool) raises -> CubicElt:
    var best = tables.lengths.at(0)
    for a in range(1, ALPHABET):
        var candidate = tables.lengths.at(a)
        if (sign_at_perron(tables.field, cubic_sub_checked(candidate, best)) > 0) == largest:
            best = candidate^
    return best^


def oa_window(tables: SeedOverlapTables, u: List[Int], k: Int) raises -> Int:
    """Least `n` with `n * l_min > g(u[:k]) + l_max`, decided exactly in `Q(beta)`.

    Tiles more than `n` letters apart cannot overlap: `n` consecutive tiles
    span at least `n * l_min`, and two overlapping tiles of the pair lie
    within `g(W) + l_max` of each other."""
    if k < 0 or k > len(u):
        raise Error("overlap prefix length lies outside the fixed-point prefix")
    var l_min = extremal_tile_length(tables, False)
    var l_max = extremal_tile_length(tables, True)
    var bound = l_max
    for i in range(k):
        bound = cubic_add_checked(bound, tables.lengths.at(u[i]))
    var window = 1
    var span = l_min
    while sign_at_perron(tables.field, cubic_sub_checked(span, bound)) <= 0:
        window += 1
        span = cubic_add_checked(span, l_min)
    return window


def oa_level_zero_states(
    tables: SeedOverlapTables,
    mut sign_cache: Dict[CubicElt, Int],
    u: List[Int],
    k: Int,
    window: Int,
) raises -> List[OverlapState]:
    """The level-zero overlap types of `(u, S^k u)` inside the exact window.

    A window below the exact bound, or a prefix too short to hold two windows,
    would silently drop overlaps, so both fail closed."""
    var needed = oa_window(tables, u, k)
    if window < needed:
        raise Error(
            "overlap window " + String(window) + " lies below the exact bound "
            + String(needed)
        )
    if 2 * window >= len(u):
        raise Error("fixed-point prefix is too short for the overlap window")

    var prefix = parikh_prefix_sums(u)
    var seen = Dict[OverlapState, Bool]()
    var out = List[OverlapState]()
    for i in range(window, len(u) - window):
        for m in range(i - window, i + window):
            var coefficients = List[Int](length=ALPHABET, fill=0)
            for a in range(ALPHABET):
                coefficients[a] = (
                    prefix[ALPHABET * m + a]
                    - prefix[ALPHABET * i + a]
                    - prefix[ALPHABET * k + a]
                )
            var state = OverlapState(u[i], u[m], tile_length_combination(tables, coefficients))
            if state in seen:
                continue
            seen[state] = True
            if interior_overlap_cached(tables, sign_cache, state):
                out.append(state)
    return out^


def oa_type_graph(
    tables: SeedOverlapTables,
    u: List[Int],
    k: Int,
    max_states: Int = 20000,
) raises -> SeedOverlapAutomaton:
    """The level-zero types of `(u, S^k u)` closed under exact inflation."""
    var sign_cache = Dict[CubicElt, Int]()
    var seeds = oa_level_zero_states(
        tables, sign_cache, u, k, oa_window(tables, u, k)
    )
    return build_overlap_graph_from_seeds(tables, seeds, sign_cache, max_states)


struct TypeInclusionReport(Copyable, Movable):
    """How the literature overlap types sit inside the seed-patch vertex types."""

    var power: Int
    var letter: Int
    var prefix_length: Int
    var oa_types: Int
    var seed_types: Int
    var oa_minus_seed: Int
    var seed_minus_oa: Int
    var oa_all_productive: Bool
    var missing_all_productive: Bool

    def __init__(
        out self,
        point: ProlongablePoint,
        prefix_length: Int,
        oa_types: Int,
        seed_types: Int,
        oa_minus_seed: Int,
        seed_minus_oa: Int,
        oa_all_productive: Bool,
        missing_all_productive: Bool,
    ):
        self.power = point.power
        self.letter = point.letter
        self.prefix_length = prefix_length
        self.oa_types = oa_types
        self.seed_types = seed_types
        self.oa_minus_seed = oa_minus_seed
        self.seed_minus_oa = seed_minus_oa
        self.oa_all_productive = oa_all_productive
        self.missing_all_productive = missing_all_productive

    def includes(self) -> Bool:
        """Every noncoincidence literature type is a seed-patch vertex type."""
        return self.oa_minus_seed == 0

    def json_fields(self) -> String:
        return (
            "\"q\":" + String(self.power) + ",\"c\":" + String(self.letter)
            + ",\"k\":" + String(self.prefix_length)
            + ",\"oa_types\":" + String(self.oa_types)
            + ",\"seed_types\":" + String(self.seed_types)
            + ",\"oa_minus_seed\":" + String(self.oa_minus_seed)
            + ",\"seed_minus_oa\":" + String(self.seed_minus_oa)
            + ",\"oa_all_productive\":" + String(1 if self.oa_all_productive else 0)
            + ",\"missing_all_productive\":" + String(1 if self.missing_all_productive else 0)
        )


def productive_mask(a: SeedOverlapAutomaton) raises -> List[Bool]:
    var good = List[Bool](length=a.size(), fill=True)
    var bad = nonproductive_overlap_states(a)
    for i in range(len(bad)):
        good[bad[i]] = False
    return good^


def type_inclusion_report(
    tables: SeedOverlapTables,
    seed_graph: SeedOverlapAutomaton,
    u: List[Int],
    point: ProlongablePoint,
    k: Int,
    max_states: Int = 20000,
) raises -> TypeInclusionReport:
    """Compare the closed literature types of `(u, S^k u)` with the seed patch."""
    var oa = oa_type_graph(tables, u, k, max_states)
    var good = productive_mask(oa)

    var seed_index = Dict[OverlapState, Int](capacity=seed_graph.size())
    for i in range(seed_graph.size()):
        seed_index[seed_graph.states[i]] = i
    var oa_index = Dict[OverlapState, Int](capacity=oa.size())
    for i in range(oa.size()):
        oa_index[oa.states[i]] = i

    var missing = 0
    var missing_productive = True
    var oa_productive = True
    for i in range(oa.size()):
        if not good[i]:
            oa_productive = False
        if oa.states[i].is_coincidence():
            continue
        if oa.states[i] not in seed_index:
            missing += 1
            if not good[i]:
                missing_productive = False

    var extra = 0
    for i in range(seed_graph.size()):
        if not seed_graph.states[i].is_coincidence() and seed_graph.states[i] not in oa_index:
            extra += 1

    return TypeInclusionReport(
        point, k, oa.size(), seed_graph.size(), missing, extra,
        oa_productive, missing_productive,
    )


struct UnionProbeReport(Copyable, Movable):
    """The closure of every level-zero type found over a family of prefixes.

    When no single prefix gives inclusion, the question becomes whether the
    whole family is productive and how it relates to the seed patch. A
    nonproductive union type is the event worth keeping; a union that is
    productive but not contained is a gap in the dictionary, not a
    counterexample to productivity."""

    var points: Int
    var union_types: Int
    var union_noncoincidence: Int
    var union_minus_seed: Int
    var seed_minus_union: Int
    var union_all_productive: Bool

    def __init__(
        out self,
        points: Int,
        union_types: Int,
        union_noncoincidence: Int,
        union_minus_seed: Int,
        seed_minus_union: Int,
        union_all_productive: Bool,
    ):
        self.points = points
        self.union_types = union_types
        self.union_noncoincidence = union_noncoincidence
        self.union_minus_seed = union_minus_seed
        self.seed_minus_union = seed_minus_union
        self.union_all_productive = union_all_productive

    def json_fields(self) -> String:
        return (
            "\"points\":" + String(self.points)
            + ",\"union_types\":" + String(self.union_types)
            + ",\"union_noncoincidence\":" + String(self.union_noncoincidence)
            + ",\"union_minus_seed\":" + String(self.union_minus_seed)
            + ",\"seed_minus_union\":" + String(self.seed_minus_union)
            + ",\"union_all_productive\":" + String(1 if self.union_all_productive else 0)
        )


def union_probe(
    tables: SeedOverlapTables,
    seed_graph: SeedOverlapAutomaton,
    sigma: List[List[Int]],
    min_prefix: Int,
    max_k: Int,
    max_states: Int = 20000,
) raises -> UnionProbeReport:
    """Close the level-zero types of every prolongable point and every prefix
    length up to `max_k` at once, and compare that closure with the seed patch."""
    var sign_cache = Dict[CubicElt, Int]()
    var seen = Dict[OverlapState, Bool]()
    var seeds = List[OverlapState]()
    var points = prolongable_points(sigma)
    for p in range(len(points)):
        var u = fixed_point_prefix(sigma, points[p], min_prefix)
        for k in range(1, max_k + 1):
            var level_zero = oa_level_zero_states(
                tables, sign_cache, u, k, oa_window(tables, u, k)
            )
            for i in range(len(level_zero)):
                if level_zero[i] not in seen:
                    seen[level_zero[i]] = True
                    seeds.append(level_zero[i])

    var union = build_overlap_graph_from_seeds(tables, seeds, sign_cache, max_states)
    var good = productive_mask(union)
    var union_index = Dict[OverlapState, Int](capacity=union.size())
    for i in range(union.size()):
        union_index[union.states[i]] = i
    var seed_index = Dict[OverlapState, Int](capacity=seed_graph.size())
    for i in range(seed_graph.size()):
        seed_index[seed_graph.states[i]] = i

    var noncoincidence = 0
    var missing = 0
    var all_productive = True
    for i in range(union.size()):
        all_productive = all_productive and good[i]
        if union.states[i].is_coincidence():
            continue
        noncoincidence += 1
        if union.states[i] not in seed_index:
            missing += 1
    var extra = 0
    for i in range(seed_graph.size()):
        if not seed_graph.states[i].is_coincidence() and seed_graph.states[i] not in union_index:
            extra += 1

    return UnionProbeReport(
        len(points), union.size(), noncoincidence, missing, extra, all_productive
    )


struct InclusionWitness(Copyable, Movable):
    """The first prolongable point and prefix length giving type inclusion."""

    var power: Int
    var letter: Int
    var prefix_length: Int
    var found: Bool

    def __init__(out self, power: Int, letter: Int, prefix_length: Int, found: Bool):
        self.power = power
        self.letter = letter
        self.prefix_length = prefix_length
        self.found = found

    def key(self) -> String:
        if not self.found:
            return "none"
        return (
            "(" + String(self.power) + "," + String(self.letter) + ","
            + String(self.prefix_length) + ")"
        )


def least_inclusion_k(
    tables: SeedOverlapTables,
    seed_graph: SeedOverlapAutomaton,
    u: List[Int],
    point: ProlongablePoint,
    max_k: Int,
    max_states: Int = 20000,
) raises -> Int:
    """Least `k <= max_k` whose prefix gives type inclusion, or `0` for none."""
    for k in range(1, max_k + 1):
        if type_inclusion_report(tables, seed_graph, u, point, k, max_states).includes():
            return k
    return 0


def extended_inclusion_witness(
    tables: SeedOverlapTables,
    seed_graph: SeedOverlapAutomaton,
    sigma: List[List[Int]],
    min_prefix: Int,
    max_k: Int,
    max_states: Int = 20000,
) raises -> InclusionWitness:
    """The first `(q, c, k)` giving inclusion, scanning prolongable points in
    increasing power then letter, and prefix lengths in increasing order."""
    var points = prolongable_points(sigma)
    for p in range(len(points)):
        var u = fixed_point_prefix(sigma, points[p], min_prefix)
        var k = least_inclusion_k(tables, seed_graph, u, points[p], max_k, max_states)
        if k > 0:
            return InclusionWitness(points[p].power, points[p].letter, k, True)
    return InclusionWitness(0, 0, 0, False)
