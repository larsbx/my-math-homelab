#!/usr/bin/env python3
"""Python reference for kernel/mojo/c1/wake/misiurewicz_prefix_graph.mojo.

Integer arithmetic only, everything inside `Z/den`.

The obstruction extractor of `docs/p1-overlap-minimal-obstruction-2026-09-14.md`
in `larsbx/pisot-substitution-conjecture-research`, run on the finite graphs the
exact-type catalogue supplies. The pipeline is the one route F1 describes
abstractly in `docs/C1_F1_obstruction_extraction.md`:

    vertices   forward orbit closure of a catalogue under doubling
    pairs      the unordered non-diagonal pairs of vertices
    nonprod    the pairs no iterate of doubling ever separates
    sinks      the sink components of the nonproductive set, of two kinds
    dichotomy  each *cyclic* sink is a boundary or an interior obstruction

A separator is a pair of distinct rays *with a landing tag*. Admissibility
(`docs/C1_admissible_separator_codes.md`) requires both rays to be landed by
accepted theorem tags and the pair declared co-landing, and it forbids a generic
landing tag. Nothing here invents that evidence: a separator arrives tagged or
it is refused. There is deliberately no function that builds a prefix out of
addresses alone, because no such function could supply the co-landing evidence.

A point equal to either ray of a separator is `ON_SEPARATOR`, never a side.
`docs/C1_wake_membership_soundness.md` and `docs/C1_side_assignment_witnesses.md`
both forbid using that case as separation evidence, so it can never discharge a
pair.

Doubling is a function, so the pair graph has out-degree at most one and each
component either falls into one cycle or ends at a merging pair; no
strongly-connected-component search is needed. A merging pair has no outgoing
edge, so it is a terminal sink rather than a transient vertex, and it is counted
by `merging` instead of being forced into the boundary/interior dichotomy, which
asks whether a cycle meets a separator boundary.

`main` replays the pinned declared prefixes and the refusal battery.
Usage: misiurewicz_prefix_graph_reference.py
"""

from __future__ import annotations

import sys

try:
    from . import misiurewicz_catalogue_reference as mc
except ImportError:  # direct script execution
    import misiurewicz_catalogue_reference as mc

# One bound governs the graph: the denominator. Vertices live in `Z/den`, so it
# caps the vertex count, and the pair count is at most den (den - 1) / 2. The
# Mojo module carries the same constant, so the two agree on every refusal.
MAX_PREFIX_GRAPH_DENOMINATOR = 256


# --- the finite objects ---------------------------------------------------------


def forward_closure(seed: list[int], den: int) -> list[int] | None:
    """The forward orbit closure of `seed` under doubling in `Z/den`, ascending,
    or None when it would exceed the vertex bound or the seed is out of range."""
    if den <= 0 or den > MAX_PREFIX_GRAPH_DENOMINATOR or any(x < 0 or x >= den for x in seed):
        return None
    seen, stack = set(seed), list(seed)
    while stack:
        point = (2 * stack.pop()) % den
        if point not in seen:
            seen.add(point)
            stack.append(point)
    return sorted(seen)


LEFT, RIGHT, ON_SEPARATOR = 0, 1, -1

# docs/C1_admissible_separator_codes.md: LandingTag ::= RationalRayLanding
# | ParabolicLanding | HyperbolicBoundaryLanding. A generic tag is forbidden.
RATIONAL_RAY_LANDING, PARABOLIC_LANDING, HYPERBOLIC_BOUNDARY_LANDING = 1, 2, 3
ACCEPTED_LANDING_TAGS = (RATIONAL_RAY_LANDING, PARABOLIC_LANDING, HYPERBOLIC_BOUNDARY_LANDING)


def accepted_landing_tag(tag: int) -> bool:
    return tag in ACCEPTED_LANDING_TAGS


def side(point: int, separator: tuple[int, int, int], den: int) -> int:
    """`RIGHT` on the arc running counterclockwise from the first ray to the
    second, `LEFT` on the complement, and `ON_SEPARATOR` when the point *is*
    one of the two rays. Exchanging the rays names the complementary side and
    leaves the two `ON_SEPARATOR` cases alone."""
    low, high = separator[0], separator[1]
    if point == low or point == high:
        return ON_SEPARATOR
    return RIGHT if ((point - low) % den) < ((high - low) % den) else LEFT


def signature(point: int, separators: list[tuple[int, int, int]], den: int) -> tuple[int, ...]:
    return tuple(side(point, s, den) for s in separators)


def separated(a: int, b: int, separators: list[tuple[int, int, int]], den: int) -> bool:
    """Separated exactly when some separator puts both points on *open* sides
    and those sides are opposite. Differing signatures are not enough: a point
    on a separator is a structural equality case, never a separation proof, so a
    pair one of whose points lies on the ray stays undecided by that separator."""
    for sep in separators:
        left, right = side(a, sep, den), side(b, sep, den)
        if left != ON_SEPARATOR and right != ON_SEPARATOR and left != right:
            return True
    return False


def successor(pair: tuple[int, int], den: int) -> tuple[int, int] | None:
    """The image of an unordered pair under doubling, or None when the two points
    share an image. Such a pair has no outgoing edge, so it is a terminal sink of
    the graph; the finite fact that decides it is `b - a == den / 2`."""
    a, b = (2 * pair[0]) % den, (2 * pair[1]) % den
    return None if a == b else (min(a, b), max(a, b))


def undecided_pairs(vertices: list[int], separators: list[tuple[int, int]], den: int) -> list[tuple[int, int]]:
    """The pairs the prefix does not separate *at this step*.

    This is one step, not the verdict: an undecided pair whose successor is
    separated is still productive. The verdict is `nonproductive`."""
    return sorted((a, b) for i, a in enumerate(vertices) for b in vertices[i + 1:]
                  if not separated(a, b, separators, den))


def nonproductive(vertices: list[int], separators: list[tuple[int, int]], den: int) -> set[tuple[int, int]]:
    """The pairs no iterate of doubling ever separates.

    A pair is productive when it is separated now, or when its successor is
    productive; the fixpoint below is that definition read backwards from the
    separated pairs, which is how `nonproductive_overlap_states` works on the
    overlap graph. Forward closedness is then a lemma rather than a computation:
    a nonproductive pair cannot have a productive successor, since a separation
    reached from the successor is reached from the pair one step earlier.

    A merging pair, whose two points share an image, has no successor and is
    never separated, so it is nonproductive. Treating it as productive would be
    the substantive error: those two addresses are exactly the ones the dynamics
    can never tell apart, so they are an obstruction, not a discharge."""
    pairs = [(a, b) for i, a in enumerate(vertices) for b in vertices[i + 1:]]
    productive = {p for p in pairs if separated(p[0], p[1], separators, den)}
    while True:
        grown = {p for p in pairs
                 if p not in productive and (s := successor(p, den)) is not None and s in productive}
        if not grown:
            return {p for p in pairs if p not in productive}
        productive |= grown


def sink_cycles(invariant: set[tuple[int, int]], den: int) -> list[tuple[tuple[int, int], ...]]:
    """The *cyclic* sink components of the nonproductive set. Doubling is a
    function, so the pair graph has out-degree at most one and each component
    either falls into one cycle or ends at a merging pair; no
    strongly-connected-component search is needed. A merging pair is a terminal
    sink, counted by `merging`, since it has no cycle for the dichotomy.

    Each cycle is rotated to start at its least pair and the list is sorted, so
    the answer does not depend on traversal order."""
    seen: set[tuple[int, int]] = set()
    found: list[tuple[tuple[int, int], ...]] = []
    for start in sorted(invariant):
        if start in seen:
            continue
        order: dict[tuple[int, int], int] = {}
        walk, point = [], start
        while point in invariant and point not in order:
            order[point] = len(walk)
            walk.append(point)
            point = successor(point, den)
        if point in order:
            cycle = walk[order[point]:]
            if not set(cycle) & seen:
                least = cycle.index(min(cycle))
                found.append(tuple(cycle[least:] + cycle[:least]))
        seen |= set(walk)
    return sorted(found)


def endpoints(separators: list[tuple[int, int, int]]) -> set[int]:
    return {e for s in separators for e in (s[0], s[1])}


def is_boundary(cycle: tuple[tuple[int, int], ...], separators: list[tuple[int, int, int]]) -> bool:
    """The dichotomy. A cycle is a boundary obstruction when some point on it is
    a separator endpoint: the object may lie on the separation line itself, which
    is the `BoundaryEqualityCandidate` of the carrier vocabulary and the aligned
    obstruction of the overlap route. Otherwise it is an interior obstruction,
    no separator boundary is ever hit, which is `CarrierTooCoarse`: the prefix is
    not fine enough, and the strict-zipper case of the overlap route."""
    ends = endpoints(separators)
    return any(a in ends or b in ends for (a, b) in cycle)


# --- the extractor --------------------------------------------------------------


class Extraction:
    """A rejected extraction carries no counts. `rejected` is sticky: a bounded
    search that failed is not evidence that no obstruction exists."""

    __slots__ = ("vertices", "undecided", "nonproductive", "merging",
                 "boundary", "interior", "cycles", "rejected")

    def __init__(self, vertices=0, undecided=0, nonproductive=0, merging=0,
                 boundary=(), interior=(), rejected=False):
        self.vertices = vertices
        self.undecided = undecided
        self.nonproductive = nonproductive
        self.merging = merging
        self.boundary = tuple(boundary)
        self.interior = tuple(interior)
        self.cycles = tuple(sorted(self.boundary + self.interior))
        self.rejected = rejected

    @property
    def accepted(self) -> bool:
        return not self.rejected

    @property
    def terminal_sinks(self) -> int:
        """Sinks with no outgoing edge: exactly the merging pairs."""
        return self.merging

    @property
    def sink_components(self) -> int:
        """Every sink component, cyclic and terminal."""
        return len(self.cycles) + self.terminal_sinks

    @property
    def obstruction_free(self) -> bool:
        """No pair survives: nothing the prefix leaves undecided stays undecided
        under doubling. Only an accepted extraction can be obstruction free, so a
        bounded search that failed never reads as a clean verdict. The test is
        the whole nonproductive set, not just its sinks, because a merging pair
        is nonproductive without lying on any cycle."""
        return self.accepted and self.nonproductive == 0

    def __repr__(self) -> str:
        if self.rejected:
            return "Extraction(rejected)"
        return (f"Extraction(vertices={self.vertices}, undecided={self.undecided}, "
                f"nonproductive={self.nonproductive}, merging={self.merging}, "
                f"boundary={len(self.boundary)}, interior={len(self.interior)})")


def rejected_extraction() -> Extraction:
    return Extraction(rejected=True)


def extract(seed: list[int], separators: list[tuple[int, int, int]], den: int) -> Extraction:
    """Run the pipeline on the forward closure of `seed` in `Z/den`. Fails closed
    on a malformed separator, an untagged or generically tagged separator, an
    out-of-range point, and the bound."""
    if den <= 0 or den > MAX_PREFIX_GRAPH_DENOMINATOR or not seed:
        return rejected_extraction()
    for sep in separators:
        if len(sep) != 3:
            return rejected_extraction()
        low, high, tag = sep
        if low < 0 or high < 0 or low >= den or high >= den or low == high:
            return rejected_extraction()
        if not accepted_landing_tag(tag):
            return rejected_extraction()
    vertices = forward_closure(seed, den)
    if vertices is None:
        return rejected_extraction()
    undecided = undecided_pairs(vertices, separators, den)
    bad = nonproductive(vertices, separators, den)
    cycles = sink_cycles(bad, den)
    boundary = [c for c in cycles if is_boundary(c, separators)]
    interior = [c for c in cycles if not is_boundary(c, separators)]
    return Extraction(
        vertices=len(vertices),
        undecided=len(undecided),
        nonproductive=len(bad),
        merging=sum(1 for p in bad if successor(p, den) is None),
        boundary=boundary,
        interior=interior,
    )


def extract_catalogue(preperiod: int, period: int, separators: list[tuple[int, int, int]]) -> Extraction:
    """The extractor on the catalogue of an exact type under a *declared* prefix.

    There is deliberately no default. Building a prefix from the catalogue's own
    addresses, for instance by pairing consecutive points of the closure, would
    invent the co-landing evidence admissibility requires, and would also make
    every vertex its own arc, so that the result restates the construction
    instead of testing anything."""
    den = mc.catalogue_denominator(preperiod, period)
    if den < 0:
        return rejected_extraction()
    return extract(mc.catalogue(preperiod, period), separators, den)


def period_pair_prefix(period: int, den: int, tag: int = RATIONAL_RAY_LANDING) -> list[tuple[int, int, int]]:
    """Consecutive rays of one period-`period` orbit of doubling in `Z/den`,
    tagged by the caller.

    The tag is the caller's hypothesis, not a fact computed here: the finite core
    checks the shape of a code and attaches the theorem tag for the classical
    landing, exactly as `docs/C1_admissible_separator_codes.md` divides the work.
    The rays are periodic and the graph's Misiurewicz points are strictly
    preperiodic, so no vertex of the catalogue is ever an endpoint and the prefix
    is not built from the points it is asked to separate."""
    if den <= 0 or period < 1:
        return []
    orbit = sorted({(pow(2, i, den) * (den // (2 ** period - 1))) % den
                    for i in range(period)}) if (2 ** period - 1) and den % (2 ** period - 1) == 0 else []
    if len(orbit) < 2:
        return []
    return [(orbit[i], orbit[(i + 1) % len(orbit)], tag) for i in range(len(orbit))]


# --- non-claims -----------------------------------------------------------------


def obstruction_free_proves_fibre_triviality() -> bool:
    """An empty obstruction set is a fact about one finite prefix graph. Fibre
    triviality for this class is the imported tag `KnownTrivialFiberClass`."""
    return False


def extractor_decides_persistent_nonseparation() -> bool:
    """Persistent non-separation quantifies over every prefix. This runs one."""
    return False


# --- the regression -------------------------------------------------------------


def main() -> int:
    """Replay the declared prefixes and the refusal battery.

    There is no sweep claiming every exact type is obstruction free. The prefix
    that would have produced one was built from the catalogue's own addresses,
    which both invented the co-landing evidence admissibility requires and made
    the answer a restatement of the construction."""
    # A point on a ray is never separation evidence, at any denominator.
    for den in (4, 6, 14, 24):
        for low in range(den):
            for high in range(den):
                if low == high:
                    continue
                sep = [(low, high, RATIONAL_RAY_LANDING)]
                if side(low, sep[0], den) != ON_SEPARATOR or side(high, sep[0], den) != ON_SEPARATOR:
                    print(f"FAIL: a ray of ({low}, {high}) mod {den} was given a side")
                    return 1
                if separated(low, high, sep, den):
                    print(f"FAIL: ({low}, {high}) mod {den} separated by the ray it lies on")
                    return 1

    # A declared period-k prefix on a catalogue it does not contain.
    prefix = period_pair_prefix(3, 14)
    if [s[:2] for s in prefix] != [(2, 4), (4, 8), (8, 2)]:
        print(f"FAIL: the period-three prefix over 14 is {prefix}")
        return 1
    if endpoints(prefix) & set(mc.catalogue(1, 3)):
        print("FAIL: a periodic ray coincided with a strictly preperiodic address")
        return 1
    found = extract_catalogue(1, 3, prefix)
    if not found.accepted:
        print(f"FAIL: the declared prefix was refused: {found}")
        return 1
    if (found.vertices, found.undecided, found.nonproductive) != (12, 37, 20):
        print(f"FAIL: pinned counts moved: {found}")
        return 1
    if (found.merging, len(found.boundary), len(found.interior)) != (2, 2, 0):
        print(f"FAIL: pinned dichotomy moved: {found}")
        return 1
    if found.obstruction_free:
        print("FAIL: this prefix does not decide the class and must not read as clean")
        return 1

    # The negative control: two verdicts decided by hand, so an extractor that
    # always answered either one fails. Over 21 the closure of 9 is the orbit
    # 3/7 -> 6/7 -> 5/7. Under the declared co-landing pair 1/7, 2/7 -- the rays
    # at the root of the period-three component, 3 and 6 over 21 -- every point
    # of the orbit is strictly outside the arc, doubling carries the orbit onto
    # itself, and no point is a ray, so the three pairs form one cycle that
    # meets no separator boundary: exactly one interior obstruction. Adding the
    # declared pair 1/3, 2/3, which is 7 and 14 over 21, splits the orbit and
    # leaves nothing undecided one step later.
    control_seed = [9]
    coarse = extract(control_seed, [(3, 6, RATIONAL_RAY_LANDING)], 21)
    if (coarse.vertices, coarse.undecided, coarse.nonproductive) != (3, 3, 3):
        print(f"FAIL: the coarse control moved: {coarse}")
        return 1
    if (coarse.merging, len(coarse.boundary), len(coarse.interior)) != (0, 0, 1):
        print(f"FAIL: the coarse control's dichotomy moved: {coarse}")
        return 1
    if coarse.obstruction_free:
        print("FAIL: a prefix that separates nothing on the orbit read as clean")
        return 1
    refined = extract(control_seed, [(3, 6, RATIONAL_RAY_LANDING), (7, 14, RATIONAL_RAY_LANDING)], 21)
    if not refined.obstruction_free or refined.nonproductive or refined.undecided != 1:
        print(f"FAIL: the refined control moved: {refined}")
        return 1
    if endpoints([(3, 6, RATIONAL_RAY_LANDING), (7, 14, RATIONAL_RAY_LANDING)]) & set(forward_closure(control_seed, 21) or []):
        print("FAIL: the control's rays are points of the orbit they separate")
        return 1

    # Refusals. Each is a refusal, never an empty obstruction set.
    refusals = [
        extract(mc.catalogue(1, 3), [(2, 3, 0)], 14),                   # untagged
        extract(mc.catalogue(1, 3), [(2, 3, 99)], 14),                  # generic tag
        extract(mc.catalogue(1, 3), [(3, 3, RATIONAL_RAY_LANDING)], 14),  # one ray twice
        extract(mc.catalogue(1, 3), [(1, 14, RATIONAL_RAY_LANDING)], 14),  # ray out of range
        extract(mc.catalogue(1, 3), [], 0),                             # no denominator
        extract([99], [], 14),                                          # seed out of range
        extract(mc.catalogue(1, 3), [], MAX_PREFIX_GRAPH_DENOMINATOR + 1),
        rejected_extraction(),
    ]
    for bad in refusals:
        if bad.accepted or bad.obstruction_free:
            print("FAIL: a refusal read as an accepted or obstruction-free result")
            return 1

    print(f"OK: the declared period-three prefix leaves {found.nonproductive} nonproductive pairs "
          f"and {len(found.boundary)} boundary obstructions on exact type (1, 3); "
          f"the negative control is one interior obstruction coarse and clean refined; "
          f"{len(refusals)} refusals all stayed refusals.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
