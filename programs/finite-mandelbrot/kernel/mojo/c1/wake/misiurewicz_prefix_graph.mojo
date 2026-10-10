# C1 obstruction extractor on Misiurewicz prefix graphs (round-two item R5).
# This file is terminology-governed by docs/C1_misiurewicz_prefix_graph.md; the
# term `prefix obstruction` is registered in docs/terminology-registry.md.
#
# Route F1 of docs/C1_F1_obstruction_extraction.md asks for a finite obstruction
# object that a rational-ray catalogue can see. The overlap route of
# larsbx/pisot-substitution-conjecture-research already extracts one on a finite
# graph (docs/p1-overlap-minimal-obstruction-2026-09-14.md,
# mojo/psc/overlap_obstruction.mojo). This runs the same pipeline on the graphs
# the exact-type catalogue of kernel/mojo/certificates/misiurewicz_catalogue.mojo supplies:
#
#   vertices      the forward orbit closure of a catalogue under doubling
#   pairs         the unordered non-diagonal pairs of vertices
#   productive    separated by the prefix now, or with a productive successor
#   nonproductive the rest: the pairs no iterate ever separates
#   sinks         the sink components of the nonproductive set, of two kinds
#   dichotomy     each *cyclic* sink is a boundary or an interior obstruction
#
# Productivity is computed backwards from the separated pairs, exactly as the
# overlap route computes it backwards from the coincidences. Forward closedness
# of the nonproductive set is then a lemma, not a computation: a nonproductive
# pair cannot have a productive successor, because a separation reached from the
# successor is reached from the pair one step earlier.
#
# Doubling is a function, so the pair graph has out-degree at most one and each
# component falls into exactly one cycle. The sink components are therefore the
# cycles, and no strongly-connected-component search is needed; this is where
# the mirror is simpler than the overlap route, whose graph branches.
#
# A merging pair, whose two points share an image, has no successor and is never
# separated, so it is nonproductive. Counting it productive would be the
# substantive error: those two addresses are precisely the ones doubling can
# never tell apart.
#
# A merging pair has no outgoing edge, so its component is a singleton nothing
# leaves: it is a **terminal sink**, not a transient vertex. The nonproductive
# set therefore has sinks of two kinds, and `merging` counts the terminal ones
# exactly. They are kept out of the boundary and interior counts on purpose,
# because that dichotomy asks whether a *cycle* meets a separator boundary and a
# terminal pair has no cycle to ask about. Forcing it into either bucket would
# report a third phenomenon, two addresses with a common image, as one of the
# two the overlap route named.
#
# The dichotomy transfers term by term from the overlap route. A cycle is a
# boundary obstruction when some point on it is a separator endpoint, so the
# object may lie on the separation line itself: the `BoundaryEqualityCandidate`
# of docs/C1_canonical_carrier_content.md and the aligned obstruction of the
# overlap route, where a child start coincides. Otherwise it is an interior
# obstruction: no separator boundary is ever hit, which is `CarrierTooCoarse`
# and the strict-zipper case, where one side advances at every step.
#
# Bounds and fail-closed behaviour: one constant governs the graph. Vertices
# live in `Z/den`, so `MAX_PREFIX_GRAPH_DENOMINATOR` caps the vertex count and
# the pair count together. A denominator past it, a malformed separator, and an
# out-of-range point are refused rather than computed. Rejection is sticky and
# is never an empty answer: an empty obstruction set is a positive verdict about
# a complete graph, so a bounded search that failed must not read as one. That
# is UW-2: a bounded failed search is not persistent evidence.
#
# Scope: this decides one prefix. It does not decide persistent non-separation,
# which quantifies over every prefix, and an empty obstruction set is not fibre
# triviality, which for this class is the imported tag `KnownTrivialFiberClass`.
# No PF-critical or full-rank check appears here, for the same reason it appears
# nowhere in the overlap route: those are proved invariants of the output, not
# filters this code applies.

from certificates.misiurewicz_catalogue import catalogue, catalogue_denominator

comptime MAX_PREFIX_GRAPH_DENOMINATOR = 256

# A point is on an open side of a separator, or it is one of the two rays.
comptime LEFT_SIDE = 0
comptime RIGHT_SIDE = 1
comptime ON_SEPARATOR = -1

# docs/C1_admissible_separator_codes.md: LandingTag ::= RationalRayLanding
# | ParabolicLanding | HyperbolicBoundaryLanding. A generic landing tag is
# forbidden, so an untagged or unknown code is refused rather than assumed.
comptime RATIONAL_RAY_LANDING = 1
comptime PARABOLIC_LANDING = 2
comptime HYPERBOLIC_BOUNDARY_LANDING = 3


def accepted_landing_tag(tag: Int) -> Bool:
    return tag == RATIONAL_RAY_LANDING or tag == PARABOLIC_LANDING or tag == HYPERBOLIC_BOUNDARY_LANDING


struct PrefixExtraction(Copyable, Movable):
    """The result of one extraction.

    The nonproductive set has sink components of two kinds. `boundary` and
    `interior` count the cyclic sinks, split by the dichotomy. `merging` counts
    the terminal sinks, the pairs whose two points share an image and which
    therefore have no outgoing edge. `sink_components` is the total.

    `nonproductive_codes` is the set the counts summarise, and `cycle_codes`
    the pairs lying on a cyclic sink, both as pair codes: `_code` packs an
    unordered pair into one Int, so a reader decodes a code as
    `(code // den, code % den)`. They are the same objects the counts are taken
    from, computed in the same pass, so a caller that wants the pairs does not
    re-run the pipeline to get them.

    A rejected extraction carries no counts and no pairs."""

    var vertices: Int
    var undecided: Int
    var nonproductive: Int
    var merging: Int
    var boundary: Int
    var interior: Int
    var rejected: Bool
    var nonproductive_codes: List[Int]
    var cycle_codes: List[Int]

    def __init__(out self, vertices: Int, undecided: Int, nonproductive: Int,
                 merging: Int, boundary: Int, interior: Int, rejected: Bool,
                 nonproductive_codes: List[Int], cycle_codes: List[Int]):
        self.vertices = vertices
        self.undecided = undecided
        self.nonproductive = nonproductive
        self.merging = merging
        self.boundary = boundary
        self.interior = interior
        self.rejected = rejected
        self.nonproductive_codes = nonproductive_codes.copy()
        self.cycle_codes = cycle_codes.copy()

    def accepted(self) -> Bool:
        return not self.rejected

    def cycles(self) -> Int:
        """The cyclic sinks, the ones the dichotomy classifies."""
        return self.boundary + self.interior

    def terminal_sinks(self) -> Int:
        """The sinks with no outgoing edge. A merging pair is exactly such a
        component, so this is `merging`, named for what it is in the graph."""
        return self.merging

    def sink_components(self) -> Int:
        """Every sink component of the nonproductive set, of both kinds."""
        return self.cycles() + self.terminal_sinks()

    def obstruction_free(self) -> Bool:
        """No pair survives doubling undecided. Only an accepted extraction can
        be obstruction free, and the test is the whole nonproductive set rather
        than its sinks, because a merging pair is nonproductive without lying on
        any cycle."""
        return self.accepted() and self.nonproductive == 0


def rejected_extraction() -> PrefixExtraction:
    return PrefixExtraction(0, 0, 0, 0, 0, 0, True, List[Int](), List[Int]())


# --- the finite objects ---------------------------------------------------------


# Regime correspondence: misiurewicz-prefix-obstruction
def forward_closure(seed: List[Int], den: Int) -> List[Int]:
    """The forward orbit closure of `seed` under doubling in `Z/den`, ascending.
    Empty when the denominator is past the bound or a point is out of range."""
    var out = List[Int]()
    if den <= 0 or den > MAX_PREFIX_GRAPH_DENOMINATOR or len(seed) == 0:
        return out^
    var present = List[Bool]()
    for _ in range(den):
        present.append(False)
    for i in range(len(seed)):
        if seed[i] < 0 or seed[i] >= den:
            return List[Int]()
        present[seed[i]] = True
    # Doubling maps Z/den into itself, so one sweep to a fixpoint suffices and
    # the loop below runs at most den times.
    var changed = True
    while changed:
        changed = False
        for point in range(den):
            if present[point]:
                var image = (2 * point) % den
                if not present[image]:
                    present[image] = True
                    changed = True
    for point in range(den):
        if present[point]:
            out.append(point)
    return out^


def side(point: Int, low: Int, high: Int, den: Int) -> Int:
    """`RIGHT_SIDE` on the arc running counterclockwise from the first ray to the
    second, `LEFT_SIDE` on the complement, and `ON_SEPARATOR` when the point *is*
    one of the two rays. Exchanging the rays names the complementary side and
    leaves the two `ON_SEPARATOR` cases alone."""
    if point == low or point == high:
        return ON_SEPARATOR
    var offset = ((point - low) % den + den) % den
    var width = ((high - low) % den + den) % den
    if offset < width:
        return RIGHT_SIDE
    return LEFT_SIDE


def separated(a: Int, b: Int, lows: List[Int], highs: List[Int], den: Int) -> Bool:
    """Separated exactly when some separator puts both points on *open* sides and
    those sides are opposite.

    Differing labels are not enough. A point equal to either ray is a structural
    equality case and never a separation proof, which is the strict interval
    condition of docs/C1_wake_membership_soundness.md and the rule of
    docs/C1_side_assignment_witnesses.md that only Left and Right may prove
    separation. A pair one of whose points lies on the ray stays undecided."""
    for i in range(len(lows)):
        var first = side(a, lows[i], highs[i], den)
        var second = side(b, lows[i], highs[i], den)
        if first != ON_SEPARATOR and second != ON_SEPARATOR and first != second:
            return True
    return False


def hits_endpoint(point: Int, lows: List[Int], highs: List[Int]) -> Bool:
    for i in range(len(lows)):
        if point == lows[i] or point == highs[i]:
            return True
    return False


def _code(a: Int, b: Int, den: Int) -> Int:
    """A pair is stored as one Int so the graph needs no nested lists. The lower
    point comes first, so each unordered pair has exactly one code."""
    if a < b:
        return a * den + b
    return b * den + a


def _successor_code(code: Int, den: Int) -> Int:
    """The image of a pair under doubling, or `-1` when the two points merge."""
    var a = (2 * (code // den)) % den
    var b = (2 * (code % den)) % den
    if a == b:
        return -1
    return _code(a, b, den)


# --- the extractor --------------------------------------------------------------


# Regime correspondence: misiurewicz-prefix-obstruction
def extract(seed: List[Int], lows: List[Int], highs: List[Int], tags: List[Int], den: Int) -> PrefixExtraction:
    """Run the pipeline on the forward closure of `seed` in `Z/den` under a
    declared separator prefix. Fails closed on a mismatched or malformed
    separator list, an untagged or unknown landing tag, an out-of-range point,
    and a denominator past the bound."""
    if den <= 0 or den > MAX_PREFIX_GRAPH_DENOMINATOR or len(seed) == 0:
        return rejected_extraction()
    if len(lows) != len(highs) or len(lows) != len(tags):
        return rejected_extraction()
    for i in range(len(lows)):
        if lows[i] < 0 or highs[i] < 0 or lows[i] >= den or highs[i] >= den:
            return rejected_extraction()
        if lows[i] == highs[i]:
            return rejected_extraction()
        if not accepted_landing_tag(tags[i]):
            return rejected_extraction()
    var vertices = forward_closure(seed, den)
    if len(vertices) == 0:
        return rejected_extraction()

    # Every unordered non-diagonal pair of vertices, with the productive ones
    # seeded from the pairs the prefix already separates.
    var codes = List[Int]()
    var productive = List[Bool]()
    for _ in range(den * den):
        productive.append(False)
    var is_pair = List[Bool]()
    for _ in range(den * den):
        is_pair.append(False)
    var undecided = 0
    for i in range(len(vertices)):
        for j in range(i + 1, len(vertices)):
            var code = _code(vertices[i], vertices[j], den)
            codes.append(code)
            is_pair[code] = True
            if separated(vertices[i], vertices[j], lows, highs, den):
                productive[code] = True
            else:
                undecided += 1

    # Productivity backwards from the separated pairs, to a fixpoint. A merging
    # pair has no successor, so it never becomes productive.
    var changed = True
    while changed:
        changed = False
        for i in range(len(codes)):
            var code = codes[i]
            if not productive[code]:
                var image = _successor_code(code, den)
                if image >= 0 and productive[image]:
                    productive[code] = True
                    changed = True

    # The nonproductive set, its merging pairs, and its sink cycles.
    var nonproductive = 0
    var merging = 0
    var nonproductive_codes = List[Int]()
    for i in range(len(codes)):
        if not productive[codes[i]]:
            nonproductive += 1
            nonproductive_codes.append(codes[i])
            if _successor_code(codes[i], den) < 0:
                merging += 1

    var seen = List[Bool]()
    var on_walk = List[Bool]()
    for _ in range(den * den):
        seen.append(False)
        on_walk.append(False)
    var boundary = 0
    var interior = 0
    var cycle_codes = List[Int]()
    for i in range(len(codes)):
        var start = codes[i]
        if productive[start] or seen[start]:
            continue
        # Walk forward. Doubling is a function, so the walk either leaves the
        # nonproductive set or closes into the unique cycle of this component.
        # `on_walk` is allocated once and cleared entry by entry below, so the
        # whole classification stays linear in the number of pairs.
        var walk = List[Int]()
        var point = start
        while point >= 0 and is_pair[point] and not productive[point] and not on_walk[point]:
            walk.append(point)
            on_walk[point] = True
            point = _successor_code(point, den)
        var closed = point >= 0 and on_walk[point]
        var found_new = closed and not seen[point]
        for k in range(len(walk)):
            seen[walk[k]] = True
            on_walk[walk[k]] = False
        if found_new:
            # Classify the cycle: it starts where the walk met itself.
            var at = 0
            for k in range(len(walk)):
                if walk[k] == point:
                    at = k
            var touches = False
            for k in range(at, len(walk)):
                var pair_code = walk[k]
                cycle_codes.append(pair_code)
                if hits_endpoint(pair_code // den, lows, highs):
                    touches = True
                if hits_endpoint(pair_code % den, lows, highs):
                    touches = True
            if touches:
                boundary += 1
            else:
                interior += 1

    return PrefixExtraction(len(vertices), undecided, nonproductive, merging,
                            boundary, interior, False, nonproductive_codes, cycle_codes)


# Regime correspondence: misiurewicz-prefix-obstruction
def extract_catalogue(preperiod: Int, period: Int, lows: List[Int], highs: List[Int],
                      tags: List[Int]) -> PrefixExtraction:
    """The extractor on the catalogue of an exact type under a *declared* prefix.

    There is deliberately no default prefix and no function that builds one from
    the catalogue's addresses. Pairing consecutive points of the closure would
    invent the co-landing evidence admissibility requires, and would also make
    every vertex its own arc, so the result would restate the construction rather
    than test anything."""
    var den = catalogue_denominator(preperiod, period)
    if den < 0 or den > MAX_PREFIX_GRAPH_DENOMINATOR:
        return rejected_extraction()
    return extract(catalogue(preperiod, period), lows, highs, tags, den)


def period_orbit(period: Int, den: Int) -> List[Int]:
    """The period-`period` orbit of doubling in `Z/den`, ascending, when the
    denominator admits one. These rays are periodic, and the addresses of a
    Misiurewicz catalogue are strictly preperiodic, so an orbit here never
    contains a point the catalogue is asked to separate."""
    var out = List[Int]()
    if den <= 0 or period < 1 or period > 30:
        return out^
    var odd = (1 << period) - 1
    if odd <= 0 or den % odd != 0:
        return out^
    var scale = den // odd
    var present = List[Bool]()
    for _ in range(den):
        present.append(False)
    var point = scale % den
    for _ in range(period):
        present[point] = True
        point = (2 * point) % den
    for value in range(den):
        if present[value]:
            out.append(value)
    return out^


# --- non-claims ---------------------------------------------------------------


def obstruction_free_proves_fibre_triviality() -> Bool:
    # An empty obstruction set is a fact about one finite prefix graph. Fibre
    # triviality for this class is the imported tag KnownTrivialFiberClass.
    return False


def extractor_decides_persistent_nonseparation() -> Bool:
    # Persistent non-separation quantifies over every prefix. This runs one.
    return False


def bounded_refusal_is_evidence_of_no_obstruction() -> Bool:
    # UW-2. A rejected extraction says nothing either way, which is why
    # obstruction_free() requires acceptance.
    return False


# --- smoke ------------------------------------------------------------------------


def misiurewicz_prefix_graph_smoke() -> Bool:
    # A point on a ray is never separation evidence, at any denominator. This is
    # the strict interval condition, checked exhaustively on small circles.
    var dens: List[Int] = [4, 6, 14, 24]
    for d in range(len(dens)):
        var den = dens[d]
        for low in range(den):
            for high in range(den):
                if low == high:
                    continue
                if side(low, low, high, den) != ON_SEPARATOR:
                    return False
                if side(high, low, high, den) != ON_SEPARATOR:
                    return False
                var one_low: List[Int] = [low]
                var one_high: List[Int] = [high]
                if separated(low, high, one_low, one_high, den):
                    return False

    # The forward closure of the catalogue of type (1, 3) over the denominator 14.
    var closure = forward_closure(catalogue(1, 3), 14)
    var expected: List[Int] = [1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13]
    if len(closure) != len(expected):
        return False
    for i in range(len(expected)):
        if closure[i] != expected[i]:
            return False

    # A declared period-three prefix: the rays 2/14, 4/14, 8/14, which are the
    # periodic addresses 1/7, 2/7, 4/7. They are periodic and the catalogue is
    # strictly preperiodic, so the prefix is not built from the points it is
    # asked to separate.
    var orbit = period_orbit(3, 14)
    var orbit_expected: List[Int] = [2, 4, 8]
    if len(orbit) != 3:
        return False
    for i in range(3):
        if orbit[i] != orbit_expected[i]:
            return False
    var cat = catalogue(1, 3)
    for i in range(len(orbit)):
        for j in range(len(cat)):
            if orbit[i] == cat[j]:
                return False

    var lows: List[Int] = [2, 4, 8]
    var highs: List[Int] = [4, 8, 2]
    var tags: List[Int] = [RATIONAL_RAY_LANDING, RATIONAL_RAY_LANDING, RATIONAL_RAY_LANDING]
    var found = extract_catalogue(1, 3, lows, highs, tags)
    if not found.accepted():
        return False
    if found.vertices != 12 or found.undecided != 37 or found.nonproductive != 20:
        return False
    if found.merging != 2 or found.boundary != 2 or found.interior != 0:
        return False
    # This prefix does not decide the class, and must not read as if it did.
    if found.obstruction_free():
        return False

    # The pairs the counts are taken from. Every reported code decodes to two
    # distinct vertices of the graph and is genuinely unseparated now, and the
    # cyclic ones are a subset closed under doubling: a cycle's successor is on
    # the same cycle. That is what lets a reader draw the obstruction rather
    # than re-derive it.
    if len(found.nonproductive_codes) != found.nonproductive:
        return False
    for i in range(len(found.nonproductive_codes)):
        var code = found.nonproductive_codes[i]
        var a = code // 14
        var b = code % 14
        if a == b or a >= b:
            return False
        if separated(a, b, lows, highs, 14):
            return False
        var in_closure = 0
        for v in range(len(closure)):
            if closure[v] == a or closure[v] == b:
                in_closure += 1
        if in_closure != 2:
            return False
    if len(found.cycle_codes) == 0 or len(found.cycle_codes) > found.nonproductive:
        return False
    for i in range(len(found.cycle_codes)):
        var image = _successor_code(found.cycle_codes[i], 14)
        var on_cycle = False
        for j in range(len(found.cycle_codes)):
            if found.cycle_codes[j] == image:
                on_cycle = True
        if not on_cycle:
            return False
    # A refusal reports no pairs at all.
    if len(rejected_extraction().nonproductive_codes) != 0:
        return False
    if len(rejected_extraction().cycle_codes) != 0:
        return False

    # The nonproductive set has sinks of two kinds, and `merging` counts the
    # terminal ones exactly.
    if found.terminal_sinks() != found.merging:
        return False
    if found.sink_components() != found.cycles() + found.merging:
        return False

    var empty = List[Int]()

    # Type (2, 1) over the denominator 4 with no separator: six nonproductive
    # pairs, two of them terminal sinks, and no cycle at all. obstruction_free
    # must still be false, which is why it tests the whole nonproductive set
    # rather than only the cyclic sinks.
    var bare = extract(catalogue(2, 1), empty, empty, empty, 4)
    if not bare.accepted() or bare.nonproductive != 6 or bare.merging != 2:
        return False
    if bare.cycles() != 0 or bare.terminal_sinks() != 2 or bare.sink_components() != 2:
        return False
    if bare.obstruction_free():
        return False

    # The negative control the correction to N3 asked for. It is a control on
    # this extractor, not on the class: it pins two verdicts that are decided by
    # hand, so an extractor that always answered either one fails it.
    #
    # Over the denominator 21 the forward closure of 9 is {9, 15, 18}, which is
    # the period-three orbit 3/7 -> 6/7 -> 5/7. The declared separator is the
    # pair 1/7 and 2/7, the two rays that co-land at the root of the
    # period-three component; over 21 they are 3 and 6. That co-landing is an
    # imported classical fact about a root, and neither ray is a point of the
    # orbit, so the prefix is not derived from what it is asked to separate.
    #
    # Every point of the orbit is strictly outside the arc from 3 to 6, so no
    # separator ever puts two of them on opposite sides; doubling carries the
    # orbit onto itself, so all three pairs are nonproductive and lie on one
    # cycle; and no point of the orbit is 3 or 6, so the cycle meets no
    # separator boundary and the dichotomy must call it interior. That is the
    # whole argument, and the extractor has to reproduce it.
    var control_seed: List[Int] = [9]
    var wake_low: List[Int] = [3]
    var wake_high: List[Int] = [6]
    var wake_tag: List[Int] = [RATIONAL_RAY_LANDING]
    var coarse = extract(control_seed, wake_low, wake_high, wake_tag, 21)
    if not coarse.accepted():
        return False
    if coarse.vertices != 3 or coarse.undecided != 3 or coarse.nonproductive != 3:
        return False
    if coarse.merging != 0 or coarse.boundary != 0 or coarse.interior != 1:
        return False
    if coarse.obstruction_free():
        return False

    # The other direction, decided the same way. Add the declared co-landing
    # pair 1/3 and 2/3, the rays at the root of the period-two component, which
    # over 21 are 7 and 14. The arc from 7 to 14 holds 9 and neither 15 nor 18,
    # so that separator splits the orbit, and the one pair it leaves undecided
    # is separated one doubling later. An extractor that always reported an
    # obstruction fails here.
    var refined_lows: List[Int] = [3, 7]
    var refined_highs: List[Int] = [6, 14]
    var refined_tags: List[Int] = [RATIONAL_RAY_LANDING, RATIONAL_RAY_LANDING]
    var refined = extract(control_seed, refined_lows, refined_highs, refined_tags, 21)
    if not (refined.accepted() and refined.obstruction_free()):
        return False
    if refined.nonproductive != 0 or refined.undecided != 1 or refined.vertices != 3:
        return False
    # The control is about the prefix, not the orbit: the same three points are
    # an obstruction under one declared prefix and clean under the other.
    if coarse.vertices != refined.vertices:
        return False

    # Fail closed. Each of these is a refusal, never an empty obstruction set.
    var pair_low: List[Int] = [2]
    var pair_high: List[Int] = [3]
    var untagged: List[Int] = [0]
    var unknown_tag: List[Int] = [99]
    var good_tag: List[Int] = [RATIONAL_RAY_LANDING]
    var same_ray: List[Int] = [3]
    var out_of_range: List[Int] = [14]
    if extract(cat, pair_low, pair_high, untagged, 14).accepted():
        return False
    if extract(cat, pair_low, pair_high, unknown_tag, 14).accepted():
        return False
    if extract(cat, same_ray, same_ray, good_tag, 14).accepted():
        return False
    if extract(cat, pair_low, out_of_range, good_tag, 14).accepted():
        return False
    if extract(cat, pair_low, pair_high, empty, 14).accepted():
        return False
    if extract(cat, empty, empty, empty, 0).accepted():
        return False
    if extract(cat, empty, empty, empty, MAX_PREFIX_GRAPH_DENOMINATOR + 1).accepted():
        return False
    if extract_catalogue(4, 5, empty, empty, empty).accepted():
        return False
    if rejected_extraction().obstruction_free():
        return False

    # A tagged separator is accepted; an untagged one is not, and the tag is the
    # caller's declared hypothesis rather than anything computed here.
    if not accepted_landing_tag(RATIONAL_RAY_LANDING):
        return False
    if not accepted_landing_tag(PARABOLIC_LANDING) or not accepted_landing_tag(HYPERBOLIC_BOUNDARY_LANDING):
        return False
    if accepted_landing_tag(0) or accepted_landing_tag(99) or accepted_landing_tag(-1):
        return False

    return (
        not obstruction_free_proves_fibre_triviality() and
        not extractor_decides_persistent_nonseparation() and
        not bounded_refusal_is_evidence_of_no_obstruction()
    )
