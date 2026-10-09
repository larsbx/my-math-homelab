"""Valuation ascent: a non-Archimedean candidate mechanism for T2.

For a vertex `(i, j, t)` of the box graph write `t = <ell, w>`, `w in Z^3`,
and `nu(w) = max{k : w in M^k Z^3}` (the M-adic valuation; `w = 0` has
`nu = infinity`). In a catch-up-free substitution every hit is a simultaneous
birth (Lemma P), and by Proposition P' levels are M-adic valuations
(docs/p1b-vertex-coincidence-box-2026-10-02.md §5.6b).

*Valuation ascent* (VA) for `sigma`: every nonzero-offset vertex descending
from a recurrent vertex has a child with offset zero or with strictly larger
valuation. Nonzero offsets of the box graph are finitely many, so their
valuations are bounded by some `K_0`; VA therefore forces offset zero within
`K_0 + 1` levels from every recurrent vertex, which is T2 (§5.6c). VA is a
candidate, not a theorem; this module decides it exactly per substitution and
reports, for each vertex, the least depth at which a descendant has offset zero
or larger valuation (the *ascent depth*), so a failure of one-step VA is
measured rather than only flagged. The Archimedean analogue (one-step descent
of the contracting size) is refuted in §5.2 of that note.
"""

from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from psc.one_tile import catch_up_free, in_image_lattice
from psc.overlap_obstruction import recurrent_sccs
from psc.overlap_seed_patch import SeedOverlapAutomaton, SeedOverlapTables, build_seed_overlap_tables
from psc.perron_field3 import CubicElt
from psc.vertex_coincidence import build_box_graph, length_matrix, offset_vector


comptime NU_INFINITY = -1


def m_valuation(m: Mat3, w: List[Int]) raises -> Int:
    """`max{k : w in M^k Z^3}`, or `NU_INFINITY` for `w = 0`. Finite for
    `w != 0` exactly when `|det M| > 1`; a unimodular `M` raises, since then
    `M Z^3 = Z^3` and every vector has infinite valuation."""
    if w[0] == 0 and w[1] == 0 and w[2] == 0:
        return NU_INFINITY
    var d = m.det()
    if abs(d) <= 1:
        raise Error("M-adic valuation is undefined for a unimodular incidence matrix")
    var adj = m.adjugate()
    var v = w.copy()
    var k = 0
    while in_image_lattice(m, v):
        var u = adj.apply(v)
        for i in range(3):
            v[i] = u[i] // d
        k += 1
    return k


struct ValuationAscentVerdict(Copyable, Movable, Writable):
    var catch_up_free: Bool
    var vertices: Int  # nonzero-offset vertices descending from the recurrent part
    var one_step_failures: Int  # those with no child of offset zero or larger valuation
    var max_valuation: Int  # K_0 over those vertices
    var max_ascent_depth: Int  # largest least depth to offset zero or larger valuation
    var failures_by_valuation: List[Int]  # one-step failures indexed by nu(w)

    def __init__(out self):
        self.catch_up_free = False
        self.vertices = 0
        self.one_step_failures = 0
        self.max_valuation = 0
        self.max_ascent_depth = 0
        self.failures_by_valuation = List[Int]()

    def write_to[W: Writer](self, mut w: W):
        w.write(
            "catch_up_free=", self.catch_up_free, " vertices=", self.vertices,
            " one_step_failures=", self.one_step_failures, " K0=", self.max_valuation,
            " max_ascent_depth=", self.max_ascent_depth, " failures_by_nu=",
        )
        for k in range(len(self.failures_by_valuation)):
            w.write(" ", k, ":", self.failures_by_valuation[k])


def _recurrent_closure(a: SeedOverlapAutomaton) raises -> List[Bool]:
    """Vertices reachable from a vertex lying on a cycle."""
    var mark = List[Bool](length=a.size(), fill=False)
    var queue = List[Int]()
    var comps = recurrent_sccs(a)
    for c in range(len(comps)):
        for k in range(len(comps[c])):
            mark[comps[c][k]] = True
            queue.append(comps[c][k])
    var head = 0
    while head < len(queue):
        var v = queue[head]
        head += 1
        for k in range(len(a.adj[v])):
            var u = a.adj[v][k]
            if not mark[u]:
                mark[u] = True
                queue.append(u)
    return mark^


def _ascent_depth(a: SeedOverlapAutomaton, nu: List[Int], v: Int) raises -> Int:
    """Least depth of a descendant of `v` with offset zero or `nu > nu(v)`."""
    var seen = Dict[Int, Bool]()
    seen[v] = True
    var frontier: List[Int] = [v]
    var depth = 0
    while len(frontier) > 0:
        depth += 1
        var next = List[Int]()
        for f in range(len(frontier)):
            var x = frontier[f]
            for k in range(len(a.adj[x])):
                var u = a.adj[x][k]
                if nu[u] == NU_INFINITY or nu[u] > nu[v]:
                    return depth
                if u not in seen:
                    seen[u] = True
                    next.append(u)
        frontier = next^
    raise Error("valuation ascent: a vertex never reaches offset zero (PPVC fails)")


def _ascends_in_one_step(a: SeedOverlapAutomaton, nu: List[Int], v: Int) -> Bool:
    for k in range(len(a.adj[v])):
        var u = a.adj[v][k]
        if nu[u] == NU_INFINITY or nu[u] > nu[v]:
            return True
    return False


def valuation_ascent(sigma: List[List[Int]]) raises -> ValuationAscentVerdict:
    var out = ValuationAscentVerdict()
    out.catch_up_free = catch_up_free(sigma)
    var tables = build_seed_overlap_tables(sigma)
    var a = build_box_graph(tables)
    if a.capped:
        raise Error("valuation ascent: box graph capped, no verdict")
    var m = Mat3(substitution_incidence(sigma))
    var lengths = length_matrix(tables)
    var nu = List[Int]()
    for v in range(a.size()):
        nu.append(m_valuation(m, offset_vector(lengths, a.states[v].shift)))
    var closure = _recurrent_closure(a)
    for v in range(a.size()):
        if not closure[v] or nu[v] == NU_INFINITY:
            continue
        out.vertices += 1
        if nu[v] > out.max_valuation:
            out.max_valuation = nu[v]
        var d = 1 if _ascends_in_one_step(a, nu, v) else _ascent_depth(a, nu, v)
        if d > 1:
            out.one_step_failures += 1
            while len(out.failures_by_valuation) <= nu[v]:
                out.failures_by_valuation.append(0)
            out.failures_by_valuation[nu[v]] += 1
        if d > out.max_ascent_depth:
            out.max_ascent_depth = d
    return out^


def letter_classes(m: Mat3) -> List[Int]:
    """For `|det M| = 2`: the class of each `e_c` in `Z^3 / M Z^3 = Z/2`
    (`1` for an *E* letter, `0` for a *Z* letter)."""
    var out = List[Int]()
    for c in range(3):
        var e: List[Int] = [0, 0, 0]
        e[c] = 1
        out.append(0 if in_image_lattice(m, e) else 1)
    return out^


def lemma_e_shape(sigma: List[List[Int]]) raises -> Bool:
    """Lemma E's shape (docs/p1b-vertex-coincidence-box-2026-10-02.md §5.6e):
    every image of length at least 2 is `E Z* E` and every image of length 1
    is a `Z` letter. For `|det M| = 2` it is equivalent to catch-up-freeness;
    other determinants raise."""
    var m = Mat3(substitution_incidence(sigma))
    if abs(m.det()) != 2:
        raise Error("Lemma E is stated for |det M| = 2")
    var chi = letter_classes(m)
    for a in range(len(sigma)):
        ref w = sigma[a]
        var n = len(w)
        if n == 1:
            if chi[w[0]] != 0:
                return False
            continue
        if chi[w[0]] != 1 or chi[w[n - 1]] != 1:
            return False
        for p in range(1, n - 1):
            if chi[w[p]] != 0:
                return False
    return True
