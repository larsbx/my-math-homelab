"""Radius-m symbolic collars of seed-patch occurrences.

An occurrence path from a swap seed is an actual pair of tiles in the
inflated periodic patches sigma^n((ab)^Z) and sigma^n((ba)^Z).  Its
radius-m collar records the m letters on each side of each tile in its
patch.  The collar of a child occurrence is a function of the parent's
collar and the child indices (the collar recursion), so the collared
occurrence graph at any radius is finite and projects onto the seed-patch
overlap graph.

Three finite diagnostics are defined on it.  An unresolved collision is a
collared state reached by occurrences with different one-step ancestry
(parent letters and child indices): the collar does not determine the
parent occurrence.  The separation radius is the least radius with no
unresolved collision; a survivor at the tested radius is retained, not
explained away.  The lift of an affine pump replays an occurrence-labelled
cycle on the fibre over its first state and reports the eventual period of
the collar.  A collision that no radius separates has a structural source:
a seed pair whose iterated patch collapses to a proper power, hence to a
periodic word with two parsings into images (patch_power_level).  None of
this proves a recognizability radius for the periodic patches, nor overlap
productivity.  Capped graphs and out-of-range data
fail closed.  Independent oracle: reference/psc_research/overlap_collar.py.
"""

from psc.overlap_affine_pump import AffineOccurrenceEdge, AffinePumpCertificate, occurrence_edges, verify_affine_pump
from psc.overlap_seed_patch import (
    OverlapState,
    SeedOverlapAutomaton,
    SeedOverlapTables,
    interior_overlap,
)
from psc.perron_field3 import cubic_sub_checked

# Words over {0,1,2} are keyed by their base-4 digits shifted by one, which
# distinguishes lengths; 31 letters fit in one Int.
comptime MAX_WORD_KEY_LENGTH = 31


struct Collar(Copyable, Movable):
    var left: List[Int]
    var right: List[Int]

    def __init__(out self, left: List[Int], right: List[Int]):
        self.left = left.copy()
        self.right = right.copy()


struct CollaredState(Copyable, Movable):
    var state_index: Int
    var top: Collar
    var bottom: Collar

    def __init__(out self, state_index: Int, top: Collar, bottom: Collar):
        self.state_index = state_index
        self.top = top.copy()
        self.bottom = bottom.copy()


struct CollaredKey(ImplicitlyCopyable, Copyable, Movable, Equatable, Hashable):
    var state_index: Int
    var top_left: Int
    var top_right: Int
    var bottom_left: Int
    var bottom_right: Int

    def __init__(
        out self,
        state_index: Int,
        top_left: Int,
        top_right: Int,
        bottom_left: Int,
        bottom_right: Int,
    ):
        self.state_index = state_index
        self.top_left = top_left
        self.top_right = top_right
        self.bottom_left = bottom_left
        self.bottom_right = bottom_right


struct CollaredEdge(ImplicitlyCopyable, Copyable, Movable):
    """An actual child occurrence between collared states, with its one-step
    ancestry label (parent letters and child indices)."""

    var parent: Int
    var ordinal: Int
    var child: Int
    var top_parent: Int
    var top_child_index: Int
    var bottom_parent: Int
    var bottom_child_index: Int

    def __init__(
        out self,
        parent: Int,
        ordinal: Int,
        child: Int,
        top_parent: Int,
        top_child_index: Int,
        bottom_parent: Int,
        bottom_child_index: Int,
    ):
        self.parent = parent
        self.ordinal = ordinal
        self.child = child
        self.top_parent = top_parent
        self.top_child_index = top_child_index
        self.bottom_parent = bottom_parent
        self.bottom_child_index = bottom_child_index

    def label_key(self) -> Int:
        # Child indices are below 2^20 and letters below 3; the key is injective.
        return ((self.top_parent * 4 + self.bottom_parent) << 40) + (self.top_child_index << 20) + self.bottom_child_index


struct CollaredGraph(Copyable, Movable):
    var radius: Int
    var states: List[CollaredState]
    var edges: List[CollaredEdge]
    var out_edges: List[List[Int]]

    def __init__(
        out self,
        radius: Int,
        states: List[CollaredState],
        edges: List[CollaredEdge],
        out_edges: List[List[Int]],
    ):
        self.radius = radius
        self.states = states.copy()
        self.edges = edges.copy()
        self.out_edges = out_edges.copy()

    def size(self) -> Int:
        return len(self.states)

    def fibre(self, state_index: Int) -> List[Int]:
        var out = List[Int]()
        for k in range(len(self.states)):
            if self.states[k].state_index == state_index:
                out.append(k)
        return out^


struct LiftedOrbit(ImplicitlyCopyable, Copyable, Movable):
    var start: Int
    var preperiod: Int
    var period: Int

    def __init__(out self, start: Int, preperiod: Int, period: Int):
        self.start = start
        self.preperiod = preperiod
        self.period = period


def word_key(word: List[Int]) raises -> Int:
    if len(word) > MAX_WORD_KEY_LENGTH:
        raise Error("collar word exceeds the exact key length")
    var key = 0
    for k in range(len(word)):
        if word[k] < 0 or word[k] > 2:
            raise Error("collar letter lies outside 0..2")
        key = key * 4 + word[k] + 1
    return key


def _image(sigma: List[List[Int]], word: List[Int]) raises -> List[Int]:
    var out = List[Int]()
    for k in range(len(word)):
        if word[k] < 0 or word[k] >= len(sigma):
            raise Error("collar letter lies outside the alphabet")
        for j in range(len(sigma[word[k]])):
            out.append(sigma[word[k]][j])
    return out^


def _slice(word: List[Int], start: Int, stop: Int) -> List[Int]:
    var out = List[Int]()
    for k in range(start, stop):
        out.append(word[k])
    return out^


def seed_collar(letter: Int, partner: Int, radius: Int) raises -> Collar:
    """Collar of `letter` in the periodic word alternating `letter` and `partner`."""
    if radius < 0:
        raise Error("collar radius must be nonnegative")
    var right = List[Int]()
    var left = List[Int]()
    for k in range(radius):
        right.append(partner if k % 2 == 0 else letter)
    for k in range(radius):
        left.append(right[radius - 1 - k])
    return Collar(left, right)


def inflate_collar(
    sigma: List[List[Int]], collar: Collar, letter: Int, child_index: Int, radius: Int
) raises -> Collar:
    """Collar of the `child_index`-th child of a tile `letter` with collar `collar`.

    Every image has at least one letter, so the inflated collar supplies the
    `radius` letters on each side however short the parent image is."""
    if radius < 0:
        raise Error("collar radius must be nonnegative")
    if letter < 0 or letter >= len(sigma):
        raise Error("collar letter lies outside the alphabet")
    if child_index < 0 or child_index >= len(sigma[letter]):
        raise Error("collar child index lies outside the parent image")
    var left = _image(sigma, collar.left)
    for k in range(child_index):
        left.append(sigma[letter][k])
    var right = _slice(sigma[letter], child_index + 1, len(sigma[letter]))
    var right_image = _image(sigma, collar.right)
    for k in range(len(right_image)):
        right.append(right_image[k])
    if len(left) < radius or len(right) < radius:
        raise Error("inflated collar is shorter than its radius")
    return Collar(_slice(left, len(left) - radius, len(left)), _slice(right, 0, radius))


def _key(state: CollaredState) raises -> CollaredKey:
    return CollaredKey(
        state.state_index,
        word_key(state.top.left),
        word_key(state.top.right),
        word_key(state.bottom.left),
        word_key(state.bottom.right),
    )


def collared_seeds(
    tables: SeedOverlapTables, graph: SeedOverlapAutomaton, radius: Int
) raises -> List[CollaredState]:
    """The seed overlaps with the collars of their tiles in (ab)^Z and (ba)^Z."""
    if graph.capped:
        raise Error("collared seeds are undefined for a capped seed-patch graph")
    var index = Dict[OverlapState, Int](capacity=graph.size())
    for k in range(graph.size()):
        index[graph.states[k]] = k
    var out = List[CollaredState]()
    for a in range(3):
        for b in range(a + 1, 3):
            var top_types: List[Int] = [a, b]
            var bottom_types: List[Int] = [b, a]
            var top_starts = [tables.lengths.at(a).scale(0), tables.lengths.at(a)]
            var bottom_starts = [tables.lengths.at(b).scale(0), tables.lengths.at(b)]
            for i in range(2):
                for j in range(2):
                    var state = OverlapState(
                        top_types[i],
                        bottom_types[j],
                        cubic_sub_checked(bottom_starts[j], top_starts[i]),
                    )
                    if not interior_overlap(tables, state):
                        continue
                    if state not in index:
                        raise Error("seed overlap is absent from the seed-patch graph")
                    var top_partner = b if top_types[i] == a else a
                    var bottom_partner = b if bottom_types[j] == a else a
                    out.append(
                        CollaredState(
                            index[state],
                            seed_collar(top_types[i], top_partner, radius),
                            seed_collar(bottom_types[j], bottom_partner, radius),
                        )
                    )
    return out^


def build_collared_graph(
    tables: SeedOverlapTables,
    graph: SeedOverlapAutomaton,
    radius: Int,
    max_states: Int = 200000,
) raises -> CollaredGraph:
    """Breadth-first closure of the collared seeds under actual child occurrences."""
    if graph.capped:
        raise Error("collared graph is undefined for a capped seed-patch graph")
    if max_states <= 0:
        raise Error("collared state cap must be positive")
    # Occurrence edges depend only on the overlap state: computed once per state
    # and shared by every collared state in its fibre.
    var edges_of = List[List[AffineOccurrenceEdge]]()
    for k in range(graph.size()):
        edges_of.append(occurrence_edges(tables, graph, k))
    var states = List[CollaredState]()
    var index = Dict[CollaredKey, Int]()
    var edges = List[CollaredEdge]()
    var out_edges = List[List[Int]]()
    var queue = collared_seeds(tables, graph, radius)
    var head = 0
    while head < len(queue):
        var current = queue[head].copy()
        head += 1
        var key = _key(current)
        if key in index:
            continue
        if len(states) >= max_states:
            raise Error("collared occurrence graph exceeded its state cap")
        index[key] = len(states)
        states.append(current.copy())
        var parent = graph.states[current.state_index]
        ref occurrences = edges_of[current.state_index]
        for o in range(len(occurrences)):
            queue.append(
                CollaredState(
                    occurrences[o].child_index,
                    inflate_collar(tables.sigma, current.top, parent.top, occurrences[o].top_child_index, radius),
                    inflate_collar(tables.sigma, current.bottom, parent.bottom, occurrences[o].bottom_child_index, radius),
                )
            )
    for k in range(len(states)):
        out_edges.append(List[Int]())
        var parent = graph.states[states[k].state_index]
        ref occurrences = edges_of[states[k].state_index]
        for o in range(len(occurrences)):
            var child = CollaredState(
                occurrences[o].child_index,
                inflate_collar(tables.sigma, states[k].top, parent.top, occurrences[o].top_child_index, radius),
                inflate_collar(tables.sigma, states[k].bottom, parent.bottom, occurrences[o].bottom_child_index, radius),
            )
            var child_key = _key(child)
            if child_key not in index:
                raise Error("closed collared graph lost a reachable child")
            out_edges[k].append(len(edges))
            edges.append(
                CollaredEdge(
                    k,
                    occurrences[o].occurrence_ordinal,
                    index[child_key],
                    parent.top,
                    occurrences[o].top_child_index,
                    parent.bottom,
                    occurrences[o].bottom_child_index,
                )
            )
    return CollaredGraph(radius, states, edges, out_edges)


def unresolved_collisions(cg: CollaredGraph) raises -> List[Int]:
    """Collared states reached by occurrences of different one-step ancestry, ascending."""
    var label = List[Int]()
    var ambiguous = List[Bool]()
    for _ in range(cg.size()):
        label.append(-1)
        ambiguous.append(False)
    for e in range(len(cg.edges)):
        var child = cg.edges[e].child
        var key = cg.edges[e].label_key()
        if label[child] < 0:
            label[child] = key
        elif label[child] != key:
            ambiguous[child] = True
    var out = List[Int]()
    for k in range(cg.size()):
        if ambiguous[k]:
            out.append(k)
    return out^


def separation_radius(
    tables: SeedOverlapTables,
    graph: SeedOverlapAutomaton,
    max_radius: Int,
    max_states: Int = 200000,
) raises -> Int:
    """Least radius up to `max_radius` at which every occurrence's one-step ancestry
    is determined by its collar; -1 if a collision survives at `max_radius`.

    A finer collar determines the coarser one, so resolution is monotone in the radius."""
    if max_radius < 0:
        raise Error("separation radius search needs a nonnegative bound")
    for m in range(max_radius + 1):
        if len(unresolved_collisions(build_collared_graph(tables, graph, m, max_states))) == 0:
            return m
    return -1


def lift_affine_pump(
    tables: SeedOverlapTables,
    graph: SeedOverlapAutomaton,
    cg: CollaredGraph,
    certificate: AffinePumpCertificate,
) raises -> List[LiftedOrbit]:
    """Replay an occurrence-labelled cycle from every collared state over its first
    state; the collar is eventually periodic, with the reported preperiod and period
    measured in traversals of the cycle.  The certificate is first replayed in full
    against the seed-patch graph (every field of every edge), so only a verified
    affine pump is lifted."""
    var n = len(certificate.state_indices)
    if n == 0 or len(certificate.edges) != n:
        raise Error("affine pump certificate is malformed")
    for k in range(n):
        if certificate.edges[k].parent_index != certificate.state_indices[k] or certificate.edges[k].child_index != certificate.state_indices[(k + 1) % n]:
            raise Error("affine pump certificate edges do not close over its states")
    if not verify_affine_pump(tables, graph, certificate):
        raise Error("affine pump certificate does not replay on the seed-patch graph")
    var out = List[LiftedOrbit]()
    var fibre = cg.fibre(certificate.state_indices[0])
    if len(fibre) == 0:
        raise Error("affine pump certificate starts outside the collared graph")
    for f in range(len(fibre)):
        var visit = Dict[Int, Int]()
        var current = fibre[f]
        var steps = 0
        while current not in visit:
            visit[current] = steps
            steps += 1
            for e in range(len(certificate.edges)):
                if cg.states[current].state_index != certificate.edges[e].parent_index:
                    raise Error("affine pump certificate leaves the fibre it is lifted from")
                var next = -1
                for o in range(len(cg.out_edges[current])):
                    var edge = cg.edges[cg.out_edges[current][o]]
                    if edge.ordinal == certificate.edges[e].occurrence_ordinal:
                        if (
                            cg.states[edge.child].state_index != certificate.edges[e].child_index
                            or edge.top_child_index != certificate.edges[e].top_child_index
                            or edge.bottom_child_index != certificate.edges[e].bottom_child_index
                        ):
                            raise Error("affine pump certificate edge disagrees with the collared occurrence it names")
                        next = edge.child
                        break
                if next < 0:
                    raise Error("collared graph has no edge for a certified occurrence")
                current = next
        out.append(LiftedOrbit(fibre[f], visit[current], steps - visit[current]))
    return out^


def is_proper_power(word: List[Int]) -> Bool:
    """Whether `word` is u^k for a shorter u and k >= 2."""
    var n = len(word)
    for p in range(1, n // 2 + 1):
        if n % p != 0:
            continue
        var periodic = True
        for i in range(p, n):
            if word[i] != word[i - p]:
                periodic = False
                break
        if periodic:
            return True
    return False


def patch_power_level(sigma: List[List[Int]], a: Int, b: Int, max_level: Int) raises -> Int:
    """Least n in 1..max_level with sigma^n(ab) a proper power, else -1.

    Then the level-n periodic patch (sigma^n(ab))^Z has a period shorter than the image
    of the seed period, so it admits two parsings into images of the level-(n-1) patch,
    shifted by that period: the same bi-infinite context with two ancestries, which no
    collar radius separates."""
    if max_level < 1:
        raise Error("patch power search needs a positive level bound")
    if a == b:
        raise Error("a swap seed needs two distinct letters")
    var word: List[Int] = [a, b]
    for n in range(1, max_level + 1):
        word = _image(sigma, word)
        if is_proper_power(word):
            return n
    return -1


def collapsing_seed_pair_count(sigma: List[List[Int]], max_level: Int) raises -> Int:
    """The number of seed pairs a < b whose patch collapses to a proper power by `max_level`."""
    var count = 0
    for a in range(3):
        for b in range(a + 1, 3):
            if patch_power_level(sigma, a, b, max_level) >= 0:
                count += 1
    return count


def legal_factors(sigma: List[List[Int]], length: Int) raises -> Dict[Int, Bool]:
    """Keys (word_key) of all factors of length at most `length` of the language of `sigma`."""
    if length < 1 or length > MAX_WORD_KEY_LENGTH:
        raise Error("legal factor length lies outside 1..31")
    var known = Dict[Int, Bool]()
    var words = List[List[Int]]()
    for a in range(len(sigma)):
        var w: List[Int] = [a]
        known[word_key(w)] = True
        words.append(w^)
    var head = 0
    while head < len(words):
        var image = _image(sigma, words[head])
        head += 1
        for n in range(1, length + 1):
            for i in range(0, len(image) - n + 1):
                var factor = _slice(image, i, i + n)
                var key = word_key(factor)
                if key not in known:
                    known[key] = True
                    words.append(factor^)
    return known^


def _collared_word(collar: Collar, letter: Int) -> List[Int]:
    var out = collar.left.copy()
    out.append(letter)
    for k in range(len(collar.right)):
        out.append(collar.right[k])
    return out^


def legal_collared_count(
    tables: SeedOverlapTables, graph: SeedOverlapAutomaton, cg: CollaredGraph
) raises -> Int:
    """Collared states whose two collared tiles are both factors of the language."""
    var legal = legal_factors(tables.sigma, 2 * cg.radius + 1)
    var count = 0
    for k in range(cg.size()):
        var state = graph.states[cg.states[k].state_index]
        if word_key(_collared_word(cg.states[k].top, state.top)) in legal and word_key(_collared_word(cg.states[k].bottom, state.bottom)) in legal:
            count += 1
    return count
