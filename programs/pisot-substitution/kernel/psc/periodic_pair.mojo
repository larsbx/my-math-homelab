"""Exact interior-occurrence pair certificates for the strict-zipper route.

Theorem B of docs/p1b-strict-zipper-periodic-pair-2026-10-02.md: two interior
occurrences sigma^r(i) = P i U and sigma^r(j) = Q j V (P, U, Q, V nonempty)
give the offset

    w0 = (M^r - I)^{-1} (pi(P) - pi(Q)).

When w0 is integral, the overlap v0 = (i, j, w0) contains the common centre
of the two Phi^r-fixed tilings and lies on an r-cycle of the overlap graph, and
v0 has an offset-zero descendant exactly when the two tilings share a vertex,
exactly when M^m w0 lies in P_m(i) - P_m(j) for some m.

`certify_pair` decides that per pair, without a depth cap standing in for a
proof:

- the offset is computed over Z with the adjugate, and replayed as
  (M^r - I) w0 == pi(P) - pi(Q);
- the r-cycle is replayed child by child in the exact Perron field, through
  interior overlaps only, back to v0;
- the descendant closure of v0 is finite (manuscript Theorem 4.22), so a
  complete closure with no offset-zero vertex is a strict-zipper certificate,
  and a reachable offset-zero vertex at depth m is a shared vertex;
- a shared vertex is re-derived independently over Z, as the least m with
  M^m w0 in D_m(i, j), and the two depths must agree.

A capped closure is reported as capped and is never a verdict. Acceptance is
by exact integer and Z[beta] equality; no adelic coordinate is computed, so
the local-field bindings of the adelic note's section 8 are not needed for, and
not claimed by, these verdicts.
"""

from finite_linear_algebra.mat3 import Mat3, identity3
from psc.bpa import substitution_incidence
from finite_exact.checked_int import checked_add, checked_mul, checked_sub
from finite_linear_algebra.integer_matrix import matmul
from psc.overlap_seed_patch import (
    OverlapState,
    SeedOverlapTables,
    build_overlap_graph_from_seeds,
    build_seed_overlap_tables,
    first_left_aligned_depths,
    interior_overlap_cached,
)
from psc.perron_field3 import (
    CubicElt,
    cubic_add_checked,
    cubic_mul_beta,
    cubic_scale_checked,
    cubic_sub_checked,
)

comptime PAIR_NOT_INTEGRAL = 0
comptime PAIR_SHARED_VERTEX = 1
comptime PAIR_STRICT_ZIPPER = 2
comptime PAIR_CAPPED = 3


struct InteriorOccurrence(Copyable, Movable):
    """`sigma^r(letter) = P letter U` with `P`, `U` nonempty; `index = |P|`."""

    var letter: Int
    var index: Int
    var prefix: List[Int]

    def __init__(out self, letter: Int, index: Int, prefix: List[Int]):
        self.letter = letter
        self.index = index
        self.prefix = prefix.copy()


struct PairVerdict(Copyable, Movable):
    """The certificate for one ordered pair of interior occurrences.

    `depth` is the first offset-zero depth for `PAIR_SHARED_VERTEX` and `-1`
    otherwise; `closure_size` is the size of the descendant closure of v0
    (complete unless `PAIR_CAPPED`)."""

    var kind: Int
    var offset: List[Int]
    var depth: Int
    var closure_size: Int

    def __init__(out self, kind: Int, offset: List[Int], depth: Int, closure_size: Int):
        self.kind = kind
        self.offset = offset.copy()
        self.depth = depth
        self.closure_size = closure_size


struct PairCensus(Copyable, Movable, Writable):
    var pairs: Int
    var integral: Int
    var shared: Int
    var strict_zipper: Int
    var capped: Int
    var deepest: Int

    def __init__(out self):
        self.pairs = 0
        self.integral = 0
        self.shared = 0
        self.strict_zipper = 0
        self.capped = 0
        self.deepest = 0

    def write_to[W: Writer](self, mut w: W):
        w.write(
            "pairs=", self.pairs, " integral=", self.integral, " shared=", self.shared,
            " strict_zipper=", self.strict_zipper, " capped=", self.capped,
            " deepest=", self.deepest,
        )


def _checked_apply(m: Mat3, v: List[Int]) raises -> List[Int]:
    var out = List[Int]()
    for i in range(3):
        var s = 0
        for k in range(3):
            s = checked_add(s, checked_mul(m.at(i, k), v[k]))
        out.append(s)
    return out^


def incidence_power(sigma: List[List[Int]], r: Int) raises -> Mat3:
    if r < 0:
        raise Error("incidence power must be non-negative")
    var m = Mat3(substitution_incidence(sigma))
    var p = identity3()
    for _ in range(r):
        # Checked: an unrepresentable product or sum raises, as before.
        p = Mat3(matmul(m.e, p.e, 3))
    return p^


def _image(sigma: List[List[Int]], letter: Int, level: Int, word_cap: Int) raises -> List[Int]:
    var w: List[Int] = [letter]
    for _ in range(level):
        var nxt = List[Int]()
        for k in range(len(w)):
            for c in range(len(sigma[w[k]])):
                nxt.append(sigma[w[k]][c])
                if len(nxt) > word_cap:
                    raise Error("periodic-pair image exceeds its word cap")
        w = nxt^
    return w^


def interior_occurrences(
    sigma: List[List[Int]], letter: Int, r: Int, word_cap: Int = 200000
) raises -> List[InteriorOccurrence]:
    """Every occurrence of `letter` in `sigma^r(letter)` that is neither first nor last."""
    if r < 1:
        raise Error("interior occurrences need r >= 1")
    var w = _image(sigma, letter, r, word_cap)
    var out = List[InteriorOccurrence]()
    var parikh: List[Int] = [0, 0, 0]
    for k in range(len(w)):
        if w[k] == letter and k > 0 and k < len(w) - 1:
            out.append(InteriorOccurrence(letter, k, parikh))
        parikh[w[k]] += 1
    return out^


def centre_offset(sigma: List[List[Int]], r: Int, top: List[Int], bottom: List[Int]) raises -> List[Int]:
    """`(M^r - I)^{-1}(top - bottom)` when integral, else an empty list.

    The integral answer is replayed against `(M^r - I) w0 == top - bottom`."""
    var n = incidence_power(sigma, r)
    var e = List[Int]()
    for k in range(9):
        e.append(checked_sub(n.e[k], identity3().e[k]))
    var a = Mat3(e)
    var det = a.det()
    if det == 0:
        raise Error("M^r - I is singular: sigma is not Pisot irreducible")
    var diff = List[Int]()
    for k in range(3):
        diff.append(checked_sub(top[k], bottom[k]))
    var y = _checked_apply(a.adjugate(), diff)
    var w = List[Int]()
    for k in range(3):
        if y[k] % det != 0:
            return List[Int]()
        w.append(y[k] // det)
    if _checked_apply(a, w) != diff:
        raise Error("centre offset failed its exact replay")
    return w^


def _position(tables: SeedOverlapTables, w: List[Int]) raises -> CubicElt:
    var x = CubicElt()
    for a in range(3):
        x = cubic_add_checked(x, cubic_scale_checked(tables.lengths.at(a), w[a]))
    return x


def image_sizes(sigma: List[List[Int]], levels: Int) raises -> List[List[Int]]:
    """`sizes[n][a] = |sigma^n(a)|` for `0 <= n <= levels`."""
    var sizes = List[List[Int]]()
    sizes.append([1, 1, 1])
    for n in range(1, levels + 1):
        var row = List[Int]()
        for a in range(3):
            var s = 0
            for c in range(len(sigma[a])):
                s = checked_add(s, sizes[n - 1][sigma[a][c]])
            row.append(s)
        sizes.append(row^)
    return sizes^


def _child_path(sigma: List[List[Int]], letter: Int, r: Int, index: Int) raises -> List[Int]:
    """Child indices, top level first, of position `index` in `sigma^r(letter)`."""
    var sizes = image_sizes(sigma, r - 1 if r > 0 else 0)
    var path = List[Int]()
    var x = letter
    var k = index
    for t in range(r):
        var block = sizes[r - 1 - t].copy()
        var c = 0
        while k >= block[sigma[x][c]]:
            k -= block[sigma[x][c]]
            c += 1
        path.append(c)
        x = sigma[x][c]
    if k != 0:
        raise Error("occurrence index does not resolve to a tile")
    return path^


def replay_cycle(
    tables: SeedOverlapTables,
    r: Int,
    top: InteriorOccurrence,
    bottom: InteriorOccurrence,
    start: OverlapState,
) raises:
    """Replay the r-step descendant chain of `start` through the two occurrences.

    Every intermediate state must be an interior overlap and the chain must
    close on `start`; otherwise the certificate is refused."""
    var cache = Dict[CubicElt, Int]()
    var ti = _child_path(tables.sigma, top.letter, r, top.index)
    var bi = _child_path(tables.sigma, bottom.letter, r, bottom.index)
    var s = start
    for t in range(r):
        if not interior_overlap_cached(tables, cache, s):
            raise Error("periodic-pair chain left the overlap graph")
        var shifted = cubic_add_checked(
            cubic_mul_beta(tables.field, s.shift), tables.prefix(s.bottom, bi[t])
        )
        s = OverlapState(
            tables.sigma[s.top][ti[t]],
            tables.sigma[s.bottom][bi[t]],
            cubic_sub_checked(shifted, tables.prefix(s.top, ti[t])),
        )
    if s != start:
        raise Error("periodic-pair chain does not close on its start")


def _prefix_keys(sigma: List[List[Int]], letter: Int, level: Int, word_cap: Int) raises -> Dict[Int, Bool]:
    var keys = Dict[Int, Bool]()
    var parikh: List[Int] = [0, 0, 0]
    var w = _image(sigma, letter, level, word_cap)
    for k in range(len(w)):
        keys[_key(parikh)] = True
        parikh[w[k]] += 1
    return keys^


def _key(v: List[Int]) -> Int:
    return v[0] + (v[1] << 21) + (v[2] << 42)


def integer_hit_depth(
    sigma: List[List[Int]], i: Int, j: Int, w0: List[Int], max_level: Int, word_cap: Int = 200000
) raises -> Int:
    """Least m <= max_level with M^m w0 in P_m(i) - P_m(j), else -1. Exact over Z."""
    var m = Mat3(substitution_incidence(sigma))
    var w = w0.copy()
    for level in range(max_level + 1):
        var bottom = _prefix_keys(sigma, j, level, word_cap)
        var parikh: List[Int] = [0, 0, 0]
        var top = _image(sigma, i, level, word_cap)
        for k in range(len(top)):
            var v = List[Int]()
            var ok = True
            for a in range(3):
                var x = checked_sub(parikh[a], w[a])
                ok = ok and x >= 0
                v.append(x)
            if ok and _key(v) in bottom:
                return level
            parikh[top[k]] += 1
        w = _checked_apply(m, w)
    return -1


def certify_pair(
    tables: SeedOverlapTables,
    r: Int,
    top: InteriorOccurrence,
    bottom: InteriorOccurrence,
    max_states: Int = 20000,
) raises -> PairVerdict:
    var w0 = centre_offset(tables.sigma, r, top.prefix, bottom.prefix)
    if len(w0) == 0:
        return PairVerdict(PAIR_NOT_INTEGRAL, w0, -1, 0)
    var v0 = OverlapState(top.letter, bottom.letter, _position(tables, w0))
    var cache = Dict[CubicElt, Int]()
    if not interior_overlap_cached(tables, cache, v0):
        raise Error("centre-difference offset is not an overlap: Theorem B violated")
    replay_cycle(tables, r, top, bottom, v0)
    var seeds: List[OverlapState] = [v0]
    var closure = build_overlap_graph_from_seeds(tables, seeds, cache, max_states)
    if closure.capped:
        return PairVerdict(PAIR_CAPPED, w0, -1, closure.size())
    if closure.states[0] != v0:
        raise Error("descendant closure does not start at v0")
    var depth = first_left_aligned_depths(closure)[0]
    if depth < 0:
        return PairVerdict(PAIR_STRICT_ZIPPER, w0, -1, closure.size())
    if integer_hit_depth(tables.sigma, top.letter, bottom.letter, w0, depth) != depth:
        raise Error("Z[beta] and integer offset-zero depths disagree")
    return PairVerdict(PAIR_SHARED_VERTEX, w0, depth, closure.size())


def periodic_pair_census(sigma: List[List[Int]], max_r: Int, max_states: Int = 20000) raises -> PairCensus:
    """Every ordered pair of interior occurrences with distinct letters, r <= max_r."""
    var tables = build_seed_overlap_tables(sigma)
    var census = PairCensus()
    for r in range(1, max_r + 1):
        var occ = List[List[InteriorOccurrence]]()
        for a in range(3):
            occ.append(interior_occurrences(sigma, a, r))
        for i in range(3):
            for j in range(3):
                if i == j:
                    continue
                for p in range(len(occ[i])):
                    for q in range(len(occ[j])):
                        census.pairs += 1
                        var v = certify_pair(tables, r, occ[i][p], occ[j][q], max_states)
                        if v.kind == PAIR_NOT_INTEGRAL:
                            continue
                        census.integral += 1
                        if v.kind == PAIR_SHARED_VERTEX:
                            census.shared += 1
                            if v.depth > census.deepest:
                                census.deepest = v.depth
                        elif v.kind == PAIR_STRICT_ZIPPER:
                            census.strict_zipper += 1
                        else:
                            census.capped += 1
    return census^
