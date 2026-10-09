"""The leftmost chain is functional, and its cycles are prefix-vs-interior pairs.

docs/p1b-leftmost-chain-periodic-pair-2026-10-05.md, Proposition LC. The
leftmost child -- the child whose region contains the parent's left end -- is a
*function* on nonzero-offset vertices, so the leftmost chain of a vertex is
eventually periodic and `CU` (docs/p1b-vertex-coincidence-box-2026-10-02.md
section 5.6b) is exactly the set of vertices whose chain leaves the nonzero
offsets. Every terminal cycle of that function therefore witnesses a vertex
that is *not* in `CU`, and this module certifies the shape of those witnesses:

- the offset keeps one strict sign along the whole chain, so the index used on
  the side whose tile starts later is `0` at every step (`certify_sign`);
- over a cycle of length `r` the composite index on that side is `0`, giving a
  **prefix** occurrence `sigma^r(i) = i U` with `U` nonempty, so `i` lies on a
  cycle of the first-letter map `a -> sigma(a)[0]`;
- the composite index on the other side is strictly interior, giving an
  **interior** occurrence `sigma^r(j) = Q j V` with `Q`, `V` nonempty.

So a terminal leftmost cycle is the half-degenerate companion of Theorem B
(`psc.periodic_pair`): there both occurrences are interior and the common
centre is interior to both tiles; here one occurrence is a prefix, the centre
is a vertex of one tiling of infinite level and interior to every level tile of
the other, and the centre is never a common vertex.

The offset vector is `w0 = (I - M^r)^{-1} pi(Q)` on the sign-negative side, by
the same cycle equation `psc.periodic_pair` uses, so `pi(Q)` lies in
`(I - M^r) Z^3`. `M^r` leaves the exact integer range well before the longest
cycles observed, so a cycle whose `r` exceeds `max_integral_r` is reported as
*not certified over Z* rather than assumed: an uncomputed offset is never a
verdict. The sign and occurrence-shape certificate is exact at every `r`.

`psc.one_tile` keeps the `CU` census and now takes its leftmost step from here,
so there is one implementation of the step.
"""

from psc.overlap_seed_patch import (
    OverlapState,
    SeedOverlapAutomaton,
    SeedOverlapTables,
    cached_sign,
    interior_overlap_cached,
)
from psc.periodic_pair import centre_offset, image_sizes
from psc.perron_field3 import (
    CubicElt,
    cubic_add_checked,
    cubic_mul_beta,
    cubic_scale_checked,
    cubic_sub_checked,
)

comptime LC_OK = 0
comptime LC_SIGN_FLIPS = 1
comptime LC_NOT_PREFIX = 2
comptime LC_NOT_INTERIOR = 3


struct LeftmostStep(Copyable, Movable):
    """One leftmost step: the child and the two child indices that produced it."""

    var child: OverlapState
    var top_index: Int
    var bottom_index: Int

    def __init__(out self, child: OverlapState, top_index: Int, bottom_index: Int):
        self.child = child
        self.top_index = top_index
        self.bottom_index = bottom_index


def leftmost_step(
    tables: SeedOverlapTables, mut cache: Dict[CubicElt, Int], state: OverlapState
) raises -> LeftmostStep:
    """The child whose region contains `state`'s left region endpoint, with its
    indices. `state` must have nonzero offset: an offset-zero vertex is already
    a common vertex and takes no catch-up step.

    The sign of the offset decides which tile starts later, and the child on
    that side is its index `0`. The surviving child keeps the parent's sign, so
    the chain never crosses zero -- it either lands on zero (a catch-up hit) or
    keeps the sign forever."""
    var s = cached_sign(tables, cache, state.shift)
    if s == 0:
        raise Error("leftmost child of an offset-zero vertex is not a catch-up step")
    var scaled = cubic_mul_beta(tables.field, state.shift)
    if s < 0:
        # The left end is the top tile's start: top index 0, bottom index covering it.
        var top = tables.sigma[state.top][0]
        for j in range(len(tables.sigma[state.bottom])):
            var child = OverlapState(
                top, tables.sigma[state.bottom][j], cubic_add_checked(scaled, tables.prefix(state.bottom, j))
            )
            if cached_sign(tables, cache, child.shift) <= 0 and interior_overlap_cached(tables, cache, child):
                return LeftmostStep(child, 0, j)
    else:
        # The left end is the bottom tile's start: bottom index 0, top index covering it.
        var bottom = tables.sigma[state.bottom][0]
        for i in range(len(tables.sigma[state.top])):
            var child = OverlapState(
                tables.sigma[state.top][i], bottom, cubic_sub_checked(scaled, tables.prefix(state.top, i))
            )
            if cached_sign(tables, cache, child.shift) >= 0 and interior_overlap_cached(tables, cache, child):
                return LeftmostStep(child, i, 0)
    raise Error("no child covers the parent's left endpoint")


struct LeftmostCycle(Copyable, Movable, Writable):
    """A terminal cycle of the leftmost-step function, as a periodic pair.

    `sign` is the common offset sign; the *prefix* side is the top when
    `sign < 0` and the bottom when `sign > 0`. `prefix_index` is that side's
    composite index in `sigma^r`, which Proposition LC puts at `0`, and
    `interior_index` is the other side's, which it puts strictly inside.
    `offset` is `w0` over Z when `r` is within the exact integer range, and is
    empty otherwise."""

    var r: Int
    var sign: Int
    var sign_flips: Int
    var prefix_letter: Int
    var interior_letter: Int
    var prefix_index: Int
    var prefix_length: Int
    var interior_index: Int
    var interior_length: Int
    var interior_parikh: List[Int]
    var offset: List[Int]

    def __init__(
        out self,
        r: Int,
        sign: Int,
        sign_flips: Int,
        prefix_letter: Int,
        interior_letter: Int,
        prefix_index: Int,
        prefix_length: Int,
        interior_index: Int,
        interior_length: Int,
        var interior_parikh: List[Int],
        var offset: List[Int],
    ):
        self.r = r
        self.sign = sign
        self.sign_flips = sign_flips
        self.prefix_letter = prefix_letter
        self.interior_letter = interior_letter
        self.prefix_index = prefix_index
        self.prefix_length = prefix_length
        self.interior_index = interior_index
        self.interior_length = interior_length
        self.interior_parikh = interior_parikh^
        self.offset = offset^

    def is_prefix_vs_interior(self) -> Bool:
        """Proposition LC's shape: index `0` with a nonempty tail on the prefix
        side, and a strictly interior index on the other."""
        if self.prefix_index != 0 or self.prefix_length < 2:
            return False
        return self.interior_index > 0 and self.interior_index < self.interior_length - 1

    def write_to[W: Writer](self, mut w: W):
        w.write(
            "r=",
            self.r,
            " sign=",
            self.sign,
            " prefix=",
            self.prefix_letter,
            "@",
            self.prefix_index,
            "/",
            self.prefix_length,
            " interior=",
            self.interior_letter,
            "@",
            self.interior_index,
            "/",
            self.interior_length,
        )


struct LeftmostCycleCensus(Copyable, Movable, Writable):
    var cycles: Int
    var prefix_vs_interior: Int
    var sign_constant: Int
    var offsets_certified: Int
    var offsets_beyond_range: Int
    var offset_failures: Int
    var max_r: Int
    var capped: Bool

    def __init__(out self):
        self.cycles = 0
        self.prefix_vs_interior = 0
        self.sign_constant = 0
        self.offsets_certified = 0
        self.offsets_beyond_range = 0
        self.offset_failures = 0
        self.max_r = 0
        self.capped = False

    def holds(self) -> Bool:
        """Proposition LC's certificate: every cycle kept its sign and had the
        prefix-vs-interior shape. A capped graph is never a verdict."""
        return (
            not self.capped
            and self.offset_failures == 0
            and self.sign_constant == self.cycles
            and self.prefix_vs_interior == self.cycles
        )

    def merge(mut self, other: LeftmostCycleCensus):
        self.cycles += other.cycles
        self.prefix_vs_interior += other.prefix_vs_interior
        self.sign_constant += other.sign_constant
        self.offsets_certified += other.offsets_certified
        self.offsets_beyond_range += other.offsets_beyond_range
        self.offset_failures += other.offset_failures
        if other.max_r > self.max_r:
            self.max_r = other.max_r
        if other.capped:
            self.capped = True

    def write_to[W: Writer](self, mut w: W):
        w.write(
            "cycles=",
            self.cycles,
            " sign_constant=",
            self.sign_constant,
            " prefix_vs_interior=",
            self.prefix_vs_interior,
            " offsets(certified/beyond/failed)=",
            self.offsets_certified,
            "/",
            self.offsets_beyond_range,
            "/",
            self.offset_failures,
            " max_r=",
            self.max_r,
            " capped=",
            self.capped,
        )


def _position(tables: SeedOverlapTables, w: List[Int]) raises -> CubicElt:
    var x = CubicElt()
    for a in range(3):
        x = cubic_add_checked(x, cubic_scale_checked(tables.lengths.at(a), w[a]))
    return x


def terminal_leftmost_cycles(
    tables: SeedOverlapTables, a: SeedOverlapAutomaton, max_integral_r: Int = 12
) raises -> List[LeftmostCycle]:
    """Every terminal cycle of the leftmost-step function on the nonzero-offset
    vertices of `a`, each read off as a periodic pair.

    Each nonzero-offset vertex is walked once: the chain either reaches offset
    zero (the vertex is in `CU`), meets settled ground, or closes on itself and
    is recorded. `max_integral_r` bounds the cycle length for which `M^r` stays
    inside the exact integer range; a longer cycle is recorded with an empty
    offset."""
    var cache = Dict[CubicElt, Int]()
    var index = Dict[OverlapState, Int]()
    for i in range(a.size()):
        index[a.states[i]] = i
    var seen = List[Int](length=a.size(), fill=0)  # 0 fresh, 1 on the walk, 2 settled
    var out = List[LeftmostCycle]()
    for start in range(a.size()):
        if seen[start] != 0 or a.states[start].shift.is_zero():
            continue
        var path = List[Int]()
        var steps = List[LeftmostStep]()
        var depth = Dict[Int, Int]()
        var x = start
        while True:
            if a.states[x].shift.is_zero() or seen[x] == 2:
                break
            if seen[x] == 1:
                out.append(
                    _read_cycle(tables, cache, a, path, steps, depth[x], max_integral_r)
                )
                break
            seen[x] = 1
            depth[x] = len(path)
            path.append(x)
            var step = leftmost_step(tables, cache, a.states[x])
            var nxt = step.child
            steps.append(step^)
            x = index[nxt]
        for k in range(len(path)):
            seen[path[k]] = 2
    return out^


def _read_cycle(
    tables: SeedOverlapTables,
    mut cache: Dict[CubicElt, Int],
    a: SeedOverlapAutomaton,
    path: List[Int],
    steps: List[LeftmostStep],
    first: Int,
    max_integral_r: Int,
) raises -> LeftmostCycle:
    """Compose the cycle `path[first:]` into its two occurrences."""
    var r = len(path) - first
    var head = a.states[path[first]]
    var sign = cached_sign(tables, cache, head.shift)
    var sizes = image_sizes(tables.sigma, r)
    var top_index = 0
    var bottom_index = 0
    var top_parikh: List[Int] = [0, 0, 0]
    var bottom_parikh: List[Int] = [0, 0, 0]
    var flips = 0
    for t in range(first, len(path)):
        var cur = a.states[path[t]]
        if cached_sign(tables, cache, cur.shift) != sign:
            flips += 1
        var step = steps[t].copy()
        var below = len(path) - 1 - t  # levels of subdivision still to come
        for c in range(step.top_index):
            top_index += sizes[below][tables.sigma[cur.top][c]]
            top_parikh = _add_parikh(top_parikh, _letter_parikh(tables.sigma, cur.top, c, below))
        for c in range(step.bottom_index):
            bottom_index += sizes[below][tables.sigma[cur.bottom][c]]
            bottom_parikh = _add_parikh(
                bottom_parikh, _letter_parikh(tables.sigma, cur.bottom, c, below)
            )
    var top_length = sizes[r][head.top]
    var bottom_length = sizes[r][head.bottom]
    var interior_parikh = bottom_parikh.copy() if sign < 0 else top_parikh.copy()
    var offset = List[Int]()
    if flips == 0 and r <= max_integral_r:
        # The cycle equation (I - M^r) w0 = +-pi(Q); see the module docstring.
        var zero: List[Int] = [0, 0, 0]
        var w0 = (
            centre_offset(tables.sigma, r, zero, interior_parikh)
            if sign < 0
            else centre_offset(tables.sigma, r, interior_parikh, zero)
        )
        if len(w0) == 3 and _position(tables, w0) == head.shift:
            offset = w0^
    if sign < 0:
        return LeftmostCycle(
            r, sign, flips, head.top, head.bottom, top_index, top_length, bottom_index,
            bottom_length, interior_parikh^, offset^,
        )
    return LeftmostCycle(
        r, sign, flips, head.bottom, head.top, bottom_index, bottom_length, top_index,
        top_length, interior_parikh^, offset^,
    )


def _letter_parikh(sigma: List[List[Int]], parent: Int, child: Int, levels: Int) raises -> List[Int]:
    """Parikh vector of `sigma^levels(sigma(parent)[child])`, i.e. `M^levels e_c`."""
    var v: List[Int] = [0, 0, 0]
    v[sigma[parent][child]] = 1
    for _ in range(levels):
        var nxt: List[Int] = [0, 0, 0]
        for a in range(3):
            if v[a] != 0:
                for c in range(len(sigma[a])):
                    nxt[sigma[a][c]] += v[a]
        v = nxt^
    return v^


def _add_parikh(a: List[Int], b: List[Int]) -> List[Int]:
    var out = List[Int]()
    for k in range(3):
        out.append(a[k] + b[k])
    return out^


def certify_leftmost_cycles(
    tables: SeedOverlapTables, a: SeedOverlapAutomaton, max_integral_r: Int = 12
) raises -> LeftmostCycleCensus:
    """Proposition LC on one box graph: every terminal leftmost cycle keeps one
    offset sign and is a prefix-vs-interior occurrence pair."""
    var v = LeftmostCycleCensus()
    if a.capped:
        v.capped = True
        return v^
    var cycles = terminal_leftmost_cycles(tables, a, max_integral_r)
    for k in range(len(cycles)):
        v.cycles += 1
        if cycles[k].r > v.max_r:
            v.max_r = cycles[k].r
        if cycles[k].sign_flips == 0:
            v.sign_constant += 1
        if cycles[k].is_prefix_vs_interior():
            v.prefix_vs_interior += 1
        if len(cycles[k].offset) == 3:
            v.offsets_certified += 1
        elif cycles[k].r > max_integral_r:
            v.offsets_beyond_range += 1
        else:
            # Inside the integral range and still no offset: the cycle equation
            # failed its exact replay. That is a refutation, not a pass, so it
            # is counted in neither column and `holds()` goes false.
            v.offset_failures += 1
    return v^
