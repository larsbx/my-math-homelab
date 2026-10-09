"""Certificate: boundary hitting on a whole line of catch-up-free substitutions.

docs/p1b-symbolic-line-2026-10-07.md (Theorem L), docs/p1-seed-strength-2026-10-08.md
§5 (Theorem L') and docs/p1b-boundary-hitting-progress-2026-10-08.md §4
(Theorem L''). A line is a family in Theorem E's normal form

    sigma_n(x) = x y^p s_x,   sigma_n(c) = c y^q s_c,   sigma_n(y) = t y^r s_y,

of class A, B, C or D (`class_ending`), with `p, q, r` affine in `n`; letters
`x = 0`, `c = 1`, `y = 2`, and `|det M| = 2` is required. Theorem L's line is
class B with p = 2n + 2, q = n, r = n + 1. The certificate has three parts:

1. `psc.symbolic_line.symbolic_line_graph` computes the swap-seed overlap
   graph for every `n >= q0` at once and certifies `q0`; every vertex of it
   must have an offset-zero descendant.
2. Every `n < q0` whose member is PIP is decided by the exact kernel
   (`build_seed_overlap_tables_screened`, `build_seed_overlap_graph_from_tables`,
   `first_left_aligned_depths`): every seed-reachable vertex must have an
   offset-zero descendant.
3. A cross-check, not part of the proof: at `q0` and `q0 + 5` the symbolic
   graph with `n` substituted must equal the exact graph, vertex for vertex.

A failure of any part raises. Usage: `mojo run -I . symbolic_line_certificate.mojo`
(Theorem L's line), `... SLOPE K BRANCH` (the class B line p = SLOPE n + K,
q = n, r = n + BRANCH), `... CLASS AP BP AQ BQ AR BR` (p = AP n + BP, ...,
CLASS one of A B C D), or `... lines` (every line in `certified_lines()`);
`pixi run symbolic-line-certificate` runs the first. Any other argument shape
raises. A listed line must also reproduce its pinned verdict;
`.github/workflows/class-b-lines-evidence.yml` runs every listed line, and
`tests/test_line_certificate_workflow.py` keeps its matrix equal to the list.
"""

from std.collections import Dict
from std.sys import argv
from finite_linear_algebra.mat3 import Mat3
from finite_linear_algebra.scalar import q_int
from psc.bpa import substitution_incidence
from psc.exact import q_string
from psc.overlap_seed_patch import (
    build_seed_overlap_graph_from_tables,
    build_seed_overlap_tables_screened,
    first_left_aligned_depths,
)
from psc.pisot import CubicScreen
from psc.param_poly import QX, qx_affine, qx_affine2, qx_at
from psc.symbolic_line import Line, SymbolicLineGraph, offset_zero_reachable, symbolic_line_graph
from psc.vertex_coincidence import length_matrix, offset_vector
from a1_normal_form_census import C, CLASS_A, CLASS_B, CLASS_C, CLASS_D, X, Y, class_ending, class_member


# A line of Theorem E: class CLASS_A..CLASS_D with p, q, r affine in the line
# parameter n. Every member is in Theorem E's normal form, so Corollary E2 gives
# strong coincidence for every pair wherever |det M| = 2.
struct ClassLine(Copyable, Movable):
    var cls: Int
    var coef: List[Int]  # [a_p, b_p, a_q, b_q, a_r, b_r]: p = a_p n + b_p, ...
    var by_norm: Bool  # certify in norm mode (psc.symbolic_line.Line.by_norm), as wedge edges are

    def __init__(out self, cls: Int, coef: List[Int], by_norm: Bool = False) raises:
        if cls < CLASS_A or cls > CLASS_D or len(coef) != 6:
            raise Error("a class line is a class A..D and six affine coefficients")
        self.cls = cls
        self.coef = coef.copy()
        self.by_norm = by_norm

    def run(self, i: Int, n: Int) -> Int:
        """The y-run of letter i (x, c, y) = (p, q, r) at parameter n."""
        return self.coef[2 * i] * n + self.coef[2 * i + 1]

    def admissible(self, n: Int) -> Bool:
        """Inside the class's normal form (p, q, r >= 0) and, in classes A-C,
        Lemma P1's necessary PIP condition p > q."""
        var p = self.run(0, n)
        var q = self.run(1, n)
        return n >= 0 and p >= 0 and q >= 0 and self.run(2, n) >= 0 and (self.cls == CLASS_D or p > q)

    def member(self, n: Int) raises -> List[List[Int]]:
        return class_member(self.cls, self.run(0, n), self.run(1, n), self.run(2, n))

    def line(self) raises -> Line:
        var e = class_ending(self.cls)  # (s_x, s_c, t, s_y)
        var runs = List[QX]()
        for i in range(3):
            runs.append(qx_affine(self.coef[2 * i + 1], self.coef[2 * i]))
        return Line([X, C, e[2]], [e[0], e[1], e[3]], runs, Y, self.by_norm)

    def key(self) -> List[Int]:
        var out = List[Int]([self.cls])
        out.extend(self.coef.copy())
        return out^

    def describe(self) -> String:
        var out = String("class ") + String(chr(ord("A") + self.cls)) + (" line (norm mode)" if self.by_norm else " line")
        var names = ["p", "q", "r"]
        for i in range(3):
            out += " " + names[i] + " = " + String(self.coef[2 * i]) + "n + " + String(self.coef[2 * i + 1])
        return out^


# A line of class B: p = slope q + k, r = q + branch (|r - q| = 1 is Lemma P1's
# determinant-2 condition). The default is Theorem L's line.
def class_b(slope: Int = 2, k: Int = 2, branch: Int = 1) raises -> ClassLine:
    return ClassLine(CLASS_B, [slope, k, 1, 0, 1, branch])


def class_b_line(slope: Int = 2, k: Int = 2, branch: Int = 1) raises -> Line:
    return class_b(slope, k, branch).line()


def exact_hits(sigma: List[List[Int]]) raises -> Int:
    """Vertices of the exact seed-reachable graph, raising unless all have an
    offset-zero descendant."""
    var g = build_seed_overlap_graph_from_tables(build_seed_overlap_tables_screened(sigma), 200000)
    if g.capped:
        raise Error("exact seed graph capped: an exhausted budget, not a verdict")
    var depths = first_left_aligned_depths(g)
    for i in range(len(depths)):
        if depths[i] < 0:
            raise Error("a seed-reachable vertex has no offset-zero descendant")
    return g.size()


def exact_vertex_keys(sigma: List[List[Int]]) raises -> List[String]:
    var tables = build_seed_overlap_tables_screened(sigma)
    var g = build_seed_overlap_graph_from_tables(tables, 200000)
    var lm = length_matrix(tables)
    var out = List[String]()
    for i in range(g.size()):
        var s = g.states[i]
        var w = offset_vector(lm, s.shift)
        out.append(String(s.top) + "|" + String(s.bottom) + "|" + String(w[0]) + "," + String(w[1]) + "," + String(w[2]))
    return out^


def symbolic_vertex_keys(g: SymbolicLineGraph, q: Int, b: Int = 0) raises -> List[String]:
    var out = List[String]()
    for i in range(g.size()):
        ref v = g.vertices[i]
        var key = String(v.top) + "|" + String(v.bottom) + "|"
        for k in range(3):
            var x = qx_at(v.w[k], q, b)
            key += q_string(x) + ("," if k < 2 else "")
        out.append(key^)
    return out^


def same_set(a: List[String], b: List[String]) -> Bool:
    if len(a) != len(b):
        return False
    var seen = Dict[String, Int]()
    for i in range(len(a)):
        seen[a[i]] = 1
    for i in range(len(b)):
        if b[i] not in seen:
            return False
    return True


struct LineVerdict(Copyable, Movable):
    var q0: Int
    var symbolic_vertices: Int
    var queries: Int
    var finite_members: Int
    var finite_non_pip: Int
    var finite_outside: Int

    def __init__(out self):
        self.q0 = -1
        self.symbolic_vertices = 0
        self.queries = 0
        self.finite_members = 0
        self.finite_non_pip = 0
        self.finite_outside = 0


def certify(spec: ClassLine) raises -> LineVerdict:
    """Every PIP member of the line has every seed-reachable overlap hitting
    offset zero, and `|det M| = 2` (the hypothesis of Corollary E2)."""
    var out = LineVerdict()
    var g = symbolic_line_graph(spec.line())
    if not g.pip:
        raise Error("the line's PIP property was not certified")
    var good = offset_zero_reachable(g)
    for i in range(len(good)):
        if not good[i]:
            raise Error("a symbolic seed-reachable vertex has no offset-zero descendant")
    out.symbolic_vertices = g.size()
    out.queries = g.queries
    var n = 0
    while not g.threshold.lt(q_int(n)):
        n += 1
    out.q0 = n
    var screen = CubicScreen()
    if abs(Mat3(substitution_incidence(spec.member(out.q0))).det()) != 2:
        raise Error("the line's determinant is not +-2, so Corollary E2 does not apply")
    for q in range(out.q0):
        if not spec.admissible(q):
            out.finite_outside += 1
            continue
        var sigma = spec.member(q)
        var m = Mat3(substitution_incidence(sigma))
        if not screen.is_pip(m):
            out.finite_non_pip += 1
            continue
        if abs(m.det()) != 2:
            raise Error("a PIP member has |det M| != 2")
        _ = exact_hits(sigma)
        out.finite_members += 1
    for q in [out.q0, out.q0 + 5]:
        if not same_set(symbolic_vertex_keys(g, q), exact_vertex_keys(spec.member(q))):
            raise Error("cross-check: the symbolic graph differs from the exact graph")
    return out^


def certify_class_b_line(slope: Int = 2, k: Int = 2, branch: Int = 1) raises -> LineVerdict:
    return certify(class_b(slope, k, branch))


# A wedge of Theorem E: p, q, r affine in two parameters a, b >= 0. With an
# integer base point and a unimodular pair of directions, the integer points
# (a, b) are exactly the integer points of a cone in the (q, r) plane.
struct ClassWedge(Copyable, Movable):
    var cls: Int
    var coef: List[Int]  # [c0_p, ca_p, cb_p, c0_q, ca_q, cb_q, c0_r, ca_r, cb_r]

    def __init__(out self, cls: Int, coef: List[Int]) raises:
        if cls < CLASS_A or cls > CLASS_D or len(coef) != 9:
            raise Error("a class wedge is a class A..D and nine affine coefficients")
        self.cls = cls
        self.coef = coef.copy()

    def run(self, i: Int, a: Int, b: Int) -> Int:
        return self.coef[3 * i] + self.coef[3 * i + 1] * a + self.coef[3 * i + 2] * b

    def member(self, a: Int, b: Int) raises -> List[List[Int]]:
        return class_member(self.cls, self.run(0, a, b), self.run(1, a, b), self.run(2, a, b))

    def line(self) raises -> Line:
        var e = class_ending(self.cls)
        var runs = List[QX]()
        for i in range(3):
            runs.append(qx_affine2(self.coef[3 * i], self.coef[3 * i + 1], self.coef[3 * i + 2]))
        return Line([X, C, e[2]], [e[0], e[1], e[3]], runs, Y)

    def edge_a(self, i: Int) raises -> ClassLine:
        """The boundary line a = i, parametrised by b."""
        var c = List[Int]()
        for k in range(3):
            c.append(self.coef[3 * k + 2])
            c.append(self.coef[3 * k] + self.coef[3 * k + 1] * i)
        return ClassLine(self.cls, c, True)

    def edge_b(self, j: Int) raises -> ClassLine:
        """The boundary line b = j, parametrised by a."""
        var c = List[Int]()
        for k in range(3):
            c.append(self.coef[3 * k + 1])
            c.append(self.coef[3 * k] + self.coef[3 * k + 2] * j)
        return ClassLine(self.cls, c, True)

    def key(self) -> List[Int]:
        var out = List[Int]([self.cls])
        out.extend(self.coef.copy())
        return out^

    def describe(self) -> String:
        var out = String("class ") + String(chr(ord("A") + self.cls)) + " wedge"
        var names = ["p", "q", "r"]
        for i in range(3):
            out += " " + names[i] + " = " + String(self.coef[3 * i]) + " + " + String(self.coef[3 * i + 1]) + "a + " + String(self.coef[3 * i + 2]) + "b"
        return out^


struct WedgeVerdict(Copyable, Movable):
    var a0: Int
    var b0: Int
    var symbolic_vertices: Int
    var queries: Int

    def __init__(out self):
        self.a0 = -1
        self.b0 = -1
        self.symbolic_vertices = 0
        self.queries = 0


def wedge_edges(spec: ClassWedge, a0: Int, b0: Int) raises -> List[ClassLine]:
    """The boundary lines a = i < a0 and b = j < b0: every integer point of the
    wedge outside the quadrant a >= a0, b >= b0 lies on one of them."""
    var out = List[ClassLine]()
    for i in range(a0):
        out.append(spec.edge_a(i))
    for j in range(b0):
        out.append(spec.edge_b(j))
    return out^


def certify_wedge(spec: ClassWedge) raises -> WedgeVerdict:
    """The wedge's core: every PIP member in the quadrant a >= a0, b >= b0 has
    every seed-reachable overlap hitting offset zero, and `|det M| = 2`. The
    rest of the wedge lies on `wedge_edges`, each certified as a line; a pinned
    wedge's edges must be pinned lines (`tests/test_symbolic_line.mojo`), so
    the two together cover every integer point."""
    var out = WedgeVerdict()
    var g = symbolic_line_graph(spec.line())
    if not g.pip:
        raise Error("the wedge's PIP property was not certified")
    var good = offset_zero_reachable(g)
    for i in range(len(good)):
        if not good[i]:
            raise Error("a symbolic seed-reachable vertex has no offset-zero descendant")
    out.symbolic_vertices = g.size()
    out.queries = g.queries
    var n = 0
    while not g.threshold.lt(q_int(n)):
        n += 1
    out.a0 = n
    out.b0 = g.b_floor
    if abs(Mat3(substitution_incidence(spec.member(out.a0, out.b0))).det()) != 2:
        raise Error("the wedge's determinant is not +-2, so Corollary E2 does not apply")
    for ab in [(out.a0, out.b0), (out.a0 + 5, out.b0 + 3)]:
        if not same_set(symbolic_vertex_keys(g, ab[0], ab[1]), exact_vertex_keys(spec.member(ab[0], ab[1]))):
            raise Error("cross-check: the symbolic wedge graph differs from the exact graph")
    return out^


# The lines certified so far: class, then a_p, b_p, a_q, b_q, a_r, b_r
# (p = a_p n + b_p, ...), then the pinned verdict: q0, symbolic vertices, PIP
# members below q0, non-PIP members below q0, parameters below q0 outside the
# admissible cone. Class B rows are Theorem L (first) and Theorem L' of
# docs/p1-seed-strength-2026-10-08.md; rows of classes A, C, D are Theorem L''
# of docs/p1b-boundary-hitting-progress-2026-10-08.md.
comptime PIN_FIELDS = 12


def certified_lines() -> List[List[Int]]:
    return [
        [CLASS_B, 2, 2, 1, 0, 1, 1, 52, 119, 52, 0, 0],
        [CLASS_B, 1, 1, 1, 0, 1, 1, 14, 121, 14, 0, 0],
        [CLASS_B, 1, 2, 1, 0, 1, 1, 11, 77, 11, 0, 0],
        [CLASS_B, 1, 3, 1, 0, 1, 1, 22, 79, 22, 0, 0],
        [CLASS_B, 1, 1, 1, 0, 1, -1, 20, 166, 19, 0, 1],
        [CLASS_B, 1, 2, 1, 0, 1, -1, 16, 144, 14, 1, 1],
        [CLASS_B, 1, 3, 1, 0, 1, -1, 32, 131, 30, 1, 1],
        [CLASS_B, 2, 0, 1, 0, 1, 1, 20, 76, 19, 0, 1],
        [CLASS_B, 2, 1, 1, 0, 1, 1, 17, 84, 17, 0, 0],
        [CLASS_B, 2, 3, 1, 0, 1, 1, 14, 123, 14, 0, 0],
        [CLASS_B, 2, 4, 1, 0, 1, 1, 15, 123, 15, 0, 0],
        [CLASS_B, 2, 0, 1, 0, 1, -1, 34, 124, 33, 0, 1],
        [CLASS_B, 2, 1, 1, 0, 1, -1, 87, 274, 85, 1, 1],
        [CLASS_B, 2, 2, 1, 0, 1, -1, 107, 255, 104, 2, 1],
        [CLASS_B, 2, 3, 1, 0, 1, -1, 128, 248, 124, 3, 1],
        [CLASS_A, 2, 0, 1, 0, 1, -1, 39, 281, 38, 0, 1],
        [CLASS_A, 2, 0, 1, 0, 1, 1, 20, 210, 19, 0, 1],
        [CLASS_A, 2, 1, 1, 0, 1, -1, 87, 365, 85, 1, 1],
        [CLASS_A, 2, 1, 1, 0, 1, 1, 19, 194, 19, 0, 0],
        [CLASS_A, 2, 2, 1, 0, 1, -1, 107, 325, 104, 2, 1],
        [CLASS_A, 2, 2, 1, 0, 1, 1, 52, 230, 52, 0, 0],
        [CLASS_A, 2, 3, 1, 0, 1, -1, 128, 303, 124, 3, 1],
        [CLASS_A, 2, 3, 1, 0, 1, 1, 14, 260, 14, 0, 0],
        [CLASS_C, 1, 1, 1, 0, 1, -2, 36, 279, 33, 1, 2],
        [CLASS_C, 1, 1, 1, 0, 1, 0, 17, 169, 17, 0, 0],
        [CLASS_C, 1, 2, 1, 0, 1, -3, 37, 238, 32, 2, 3],
        [CLASS_C, 1, 2, 1, 0, 1, -1, 23, 182, 22, 0, 1],
        [CLASS_C, 1, 3, 1, 0, 1, -4, 39, 229, 32, 3, 4],
        [CLASS_C, 1, 3, 1, 0, 1, -2, 36, 188, 34, 0, 2],
        [CLASS_D, 1, -1, 1, 0, 1, -1, 22, 150, 19, 2, 1],
        [CLASS_D, 1, -1, 1, 0, 1, 0, 17, 128, 15, 1, 1],
        [CLASS_D, 1, -1, 1, 0, 1, 1, 26, 111, 23, 2, 1],
        [CLASS_D, 1, -1, 1, 0, 1, 2, 38, 105, 34, 3, 1],
        [CLASS_D, 1, -1, 1, 0, 1, 3, 43, 105, 38, 4, 1],
        [CLASS_D, 1, -1, 1, 0, 1, 4, 97, 105, 91, 5, 1],
        [CLASS_D, 1, -1, 1, 0, 2, -3, 14, 105, 11, 1, 2],
        [CLASS_D, 1, -1, 1, 0, 2, -2, 12, 113, 10, 1, 1],
        [CLASS_D, 1, 1, 1, 0, 1, -1, 24, 250, 23, 0, 1],
        [CLASS_D, 1, 1, 1, 0, 1, 0, 19, 246, 19, 0, 0],
        [CLASS_D, 1, 1, 1, 0, 1, 1, 21, 181, 21, 0, 0],
        [CLASS_D, 1, 1, 1, 0, 1, 2, 22, 132, 22, 0, 0],
        [CLASS_D, 1, 1, 1, 0, 1, 3, 18, 97, 17, 1, 0],
        [CLASS_D, 1, 1, 1, 0, 1, 4, 49, 93, 47, 2, 0],
        [CLASS_D, 1, 1, 1, 0, 2, -1, 22, 93, 21, 0, 1],
        [CLASS_D, 1, 1, 1, 0, 2, 0, 15, 93, 15, 0, 0],
        [CLASS_D, 1, 1, 1, 0, 2, 1, 14, 113, 14, 0, 0],
        [CLASS_D, 1, 1, 1, 0, 2, 2, 10, 193, 10, 0, 0],
    ]


def part(xs: List[Int], lo: Int, hi: Int) -> List[Int]:
    var out = List[Int]()
    for i in range(lo, hi):
        out.append(xs[i])
    return out^


# Lines certified in norm mode, the boundary lines of the wedges of
# certified_wedges(); same row layout as certified_lines().
def certified_norm_lines() -> List[List[Int]]:
    return [
        [CLASS_D, 3, 4, 3, 5, 4, 7, 3, 105, 3, 0, 0],
        [CLASS_D, 3, 5, 3, 6, 4, 8, 3, 105, 3, 0, 0],
        [CLASS_D, 3, 6, 3, 7, 4, 9, 2, 105, 2, 0, 0],
        [CLASS_D, 3, 7, 3, 8, 4, 10, 2, 105, 2, 0, 0],
        [CLASS_D, 3, 8, 3, 9, 4, 11, 3, 105, 3, 0, 0],
        [CLASS_D, 3, 9, 3, 10, 4, 12, 2, 105, 2, 0, 0],
        [CLASS_D, 3, 10, 3, 11, 4, 13, 2, 105, 2, 0, 0],
        [CLASS_D, 3, 11, 3, 12, 4, 14, 2, 105, 2, 0, 0],
        [CLASS_D, 3, 12, 3, 13, 4, 15, 2, 105, 2, 0, 0],
        [CLASS_D, 3, 13, 3, 14, 4, 16, 2, 105, 2, 0, 0],
        [CLASS_D, 3, 14, 3, 15, 4, 17, 4, 105, 4, 0, 0],
        [CLASS_D, 3, 15, 3, 16, 4, 18, 10, 105, 10, 0, 0],
        [CLASS_D, 3, 16, 3, 17, 4, 19, 12, 105, 12, 0, 0],
        [CLASS_D, 3, 17, 3, 18, 4, 20, 19, 105, 19, 0, 0],
        [CLASS_D, 3, 18, 3, 19, 4, 21, 20, 105, 20, 0, 0],
        [CLASS_D, 1, 4, 1, 5, 1, 7, 17, 105, 17, 0, 0],
        [CLASS_D, 1, 7, 1, 8, 1, 11, 16, 105, 16, 0, 0],
        [CLASS_D, 1, 10, 1, 11, 1, 15, 16, 105, 16, 0, 0],
        [CLASS_D, 1, 13, 1, 14, 1, 19, 16, 105, 16, 0, 0],
        [CLASS_D, 1, 16, 1, 17, 1, 23, 16, 105, 16, 0, 0],
        [CLASS_D, 1, 19, 1, 20, 1, 27, 16, 105, 16, 0, 0],
        [CLASS_D, 1, 22, 1, 23, 1, 31, 15, 105, 15, 0, 0],
        [CLASS_D, 2, 12, 2, 13, 3, 18, 1, 105, 1, 0, 0],
        [CLASS_D, 1, 3, 1, 4, 2, 5, 4, 105, 4, 0, 0],
        [CLASS_D, 1, 5, 1, 6, 2, 8, 4, 105, 4, 0, 0],
        [CLASS_D, 1, 7, 1, 8, 2, 11, 5, 105, 5, 0, 0],
        [CLASS_D, 1, 9, 1, 10, 2, 14, 4, 105, 4, 0, 0],
        [CLASS_D, 1, 11, 1, 12, 2, 17, 4, 105, 4, 0, 0],
        [CLASS_D, 1, 13, 1, 14, 2, 20, 4, 105, 4, 0, 0],
        [CLASS_D, 1, 15, 1, 16, 2, 23, 4, 105, 4, 0, 0],
        [CLASS_D, 2, 3, 2, 4, 3, 5, 6, 105, 6, 0, 0],
        [CLASS_D, 2, 4, 2, 5, 3, 7, 5, 105, 5, 0, 0],
        [CLASS_D, 2, 5, 2, 6, 3, 9, 5, 105, 5, 0, 0],
        [CLASS_D, 2, 6, 2, 7, 3, 11, 5, 105, 5, 0, 0],
        [CLASS_D, 2, 7, 2, 8, 3, 13, 5, 105, 5, 0, 0],
        [CLASS_D, 2, 8, 2, 9, 3, 15, 5, 105, 5, 0, 0],
        [CLASS_D, 2, 9, 2, 10, 3, 17, 5, 105, 5, 0, 0],
        [CLASS_D, 3, 12, 3, 11, 4, 15, 2, 93, 2, 0, 0],
        [CLASS_D, 1, 12, 1, 11, 1, 15, 1, 93, 1, 0, 0],
        [CLASS_D, 1, 15, 1, 14, 1, 19, 1, 93, 1, 0, 0],
        [CLASS_D, 1, 18, 1, 17, 1, 23, 1, 93, 1, 0, 0],
        [CLASS_D, 2, 14, 2, 13, 3, 18, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 17, 2, 16, 3, 22, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 20, 2, 19, 3, 26, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 23, 2, 22, 3, 30, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 26, 2, 25, 3, 34, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 29, 2, 28, 3, 38, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 32, 2, 31, 3, 42, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 35, 2, 34, 3, 46, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 38, 2, 37, 3, 50, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 41, 2, 40, 3, 54, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 44, 2, 43, 3, 58, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 47, 2, 46, 3, 62, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 50, 2, 49, 3, 66, 11, 93, 11, 0, 0],
        [CLASS_D, 2, 53, 2, 52, 3, 70, 12, 93, 12, 0, 0],
        [CLASS_D, 2, 56, 2, 55, 3, 74, 11, 93, 11, 0, 0],
        [CLASS_D, 3, 14, 3, 13, 4, 18, 1, 93, 1, 0, 0],
        [CLASS_D, 3, 16, 3, 15, 4, 21, 1, 93, 1, 0, 0],
        [CLASS_D, 3, 18, 3, 17, 4, 24, 10, 93, 10, 0, 0],
        [CLASS_D, 3, 20, 3, 19, 4, 27, 5, 93, 5, 0, 0],
        [CLASS_D, 3, 22, 3, 21, 4, 30, 4, 93, 4, 0, 0],
        [CLASS_D, 3, 24, 3, 23, 4, 33, 1, 93, 1, 0, 0],
        [CLASS_D, 3, 26, 3, 25, 4, 36, 1, 93, 1, 0, 0],
        [CLASS_D, 3, 28, 3, 27, 4, 39, 1, 93, 1, 0, 0],
        [CLASS_D, 3, 30, 3, 29, 4, 42, 1, 93, 1, 0, 0],
        [CLASS_D, 3, 32, 3, 31, 4, 45, 1, 93, 1, 0, 0],
        [CLASS_D, 3, 34, 3, 33, 4, 48, 1, 93, 1, 0, 0],
        [CLASS_D, 3, 36, 3, 35, 4, 51, 1, 93, 1, 0, 0],
        [CLASS_D, 3, 38, 3, 37, 4, 54, 1, 93, 1, 0, 0],
        [CLASS_D, 3, 40, 3, 39, 4, 57, 1, 93, 1, 0, 0],
        [CLASS_D, 3, 42, 3, 41, 4, 60, 1, 93, 1, 0, 0],
        [CLASS_D, 1, -1, 1, -2, 2, -4, 8, 93, 6, 0, 2],
        [CLASS_D, 1, 1, 1, 0, 2, -1, 10, 93, 9, 0, 1],
        [CLASS_D, 1, 3, 1, 2, 2, 2, 8, 93, 8, 0, 0],
        [CLASS_D, 2, -1, 2, -2, 3, -4, 17, 93, 15, 0, 2],
        [CLASS_D, 2, 0, 2, -1, 3, -2, 15, 93, 14, 0, 1],
        [CLASS_D, 2, 1, 2, 0, 3, 0, 13, 93, 13, 0, 0],
        [CLASS_D, 2, 2, 2, 1, 3, 2, 10, 93, 10, 0, 0],
        [CLASS_D, 2, 3, 2, 2, 3, 4, 8, 93, 8, 0, 0],
        [CLASS_D, 2, 4, 2, 3, 3, 6, 6, 93, 6, 0, 0],
        [CLASS_D, 2, 5, 2, 4, 3, 8, 5, 93, 5, 0, 0],
        [CLASS_D, 2, 6, 2, 5, 3, 10, 4, 93, 4, 0, 0],
        [CLASS_D, 2, 7, 2, 6, 3, 12, 4, 93, 4, 0, 0],
        [CLASS_D, 2, 8, 2, 7, 3, 14, 4, 93, 4, 0, 0],
        [CLASS_D, 2, 9, 2, 8, 3, 16, 4, 93, 4, 0, 0],
        [CLASS_D, 2, 10, 2, 9, 3, 18, 4, 93, 4, 0, 0],
        [CLASS_D, 2, 11, 2, 10, 3, 20, 4, 93, 4, 0, 0],
        [CLASS_D, 2, 12, 2, 11, 3, 22, 3, 93, 3, 0, 0],
        [CLASS_D, 2, 13, 2, 12, 3, 24, 3, 93, 3, 0, 0],
    ]


def spec_of(row: List[Int], by_norm: Bool = False) raises -> ClassLine:
    return ClassLine(row[0], part(row, 1, 7), by_norm)


def pinned(spec: ClassLine) -> List[Int]:
    """The pinned verdict of a listed line, or an empty list; a norm-mode line
    is looked up in certified_norm_lines()."""
    var lines = certified_norm_lines() if spec.by_norm else certified_lines()
    for i in range(len(lines)):
        if part(lines[i], 0, 7) == spec.key():
            return lines[i].copy()
    return List[Int]()


def pinned(slope: Int, k: Int, branch: Int) raises -> List[Int]:
    return pinned(class_b(slope, k, branch))


def check_pinned(v: LineVerdict, pin: List[Int]) raises:
    """A listed line must reproduce its pinned verdict exactly."""
    if len(pin) != PIN_FIELDS or List[Int]([v.q0, v.symbolic_vertices, v.finite_members, v.finite_non_pip, v.finite_outside]) != part(pin, 7, PIN_FIELDS):
        raise Error("the line's verdict differs from its pinned verdict in certified_lines()")


# The wedges certified so far: class, the nine affine coefficients of
# (p, q, r) in (a, b), then the pinned verdict of the core: a0, b0, symbolic
# vertices. Each edge (`wedge_edges`) is a pinned line in certified_lines().
# Theorem W of docs/p1b-boundary-hitting-progress-2026-10-08.md.
comptime WEDGE_PIN_FIELDS = 13


def certified_wedges() -> List[List[Int]]:
    return [
        [CLASS_D, 4, 1, 3, 5, 1, 3, 7, 1, 4, 15, 7, 105],
        [CLASS_D, 12, 3, 2, 13, 3, 2, 18, 4, 3, 1, 0, 105],
        [CLASS_D, 3, 2, 1, 4, 2, 1, 5, 3, 2, 7, 7, 105],
        [CLASS_D, 12, 1, 3, 11, 1, 3, 15, 1, 4, 1, 3, 93],
        [CLASS_D, 14, 3, 2, 13, 3, 2, 18, 4, 3, 15, 15, 93],
        [CLASS_D, -1, 2, 1, -2, 2, 1, -4, 3, 2, 3, 15, 93],
    ]


def wedge_pinned(spec: ClassWedge) -> List[Int]:
    var rows = certified_wedges()
    for i in range(len(rows)):
        if part(rows[i], 0, 10) == spec.key():
            return rows[i].copy()
    return List[Int]()


def wedge_of(row: List[Int]) raises -> ClassWedge:
    return ClassWedge(row[0], part(row, 1, 10))


def check_wedge_pinned(v: WedgeVerdict, pin: List[Int]) raises:
    if len(pin) != WEDGE_PIN_FIELDS or List[Int]([v.a0, v.b0, v.symbolic_vertices]) != part(pin, 10, WEDGE_PIN_FIELDS):
        raise Error("the wedge's verdict differs from its pinned verdict in certified_wedges()")


def report(spec: ClassLine) raises:
    var v = certify(spec)
    print(spec.describe(), "(Theorem E normal form):")
    print("  symbolic graph for every n >=", v.q0, ":", v.symbolic_vertices, "vertices, all with an offset-zero descendant;", v.queries, "certified sign reads")
    print("  n <", v.q0, ":", v.finite_members, "PIP members decided exactly, all hitting;", v.finite_non_pip, "not PIP;", v.finite_outside, "outside the admissible cone")
    print("  cross-check at q0 and q0 + 5: symbolic graph = exact graph")
    var pin = pinned(spec)
    if len(pin) > 0:
        check_pinned(v, pin)
        print("  pinned verdict reproduced")


def report_wedge(spec: ClassWedge) raises:
    var v = certify_wedge(spec)
    print(spec.describe(), "(Theorem E normal form):")
    print("  symbolic graph for every a >=", v.a0, "and b >=", v.b0, ":", v.symbolic_vertices, "vertices, all with an offset-zero descendant;", v.queries, "certified sign reads")
    print("  cross-check at (a0, b0) and (a0 + 5, b0 + 3): symbolic graph = exact graph")
    var edges = wedge_edges(spec, v.a0, v.b0)
    print("  boundary lines, each to be certified as a line:", len(edges))
    for i in range(len(edges)):
        var k = edges[i].key()
        var line = String("    norm ") + String(chr(ord("A") + k[0]))
        for j in range(1, 7):
            line += " " + String(k[j])
        print(line)
    var pin = wedge_pinned(spec)
    if len(pin) > 0:
        check_wedge_pinned(v, pin)
        print("  pinned verdict reproduced")


def class_of(name: String) raises -> Int:
    for c in range(CLASS_A, CLASS_D + 1):
        if name == String(chr(ord("A") + c)):
            return c
    raise Error("a class is one of A, B, C, D")


def mode_of(args: List[String]) raises -> String:
    """`default` (no argument), `line` (three integers: a class B line),
    `class` (a class letter and six integers) or `lines`; any other shape
    raises, so a typo never silently certifies the default line instead."""
    if len(args) == 0:
        return "default"
    if len(args) == 1 and args[0] == "lines":
        return "lines"
    if len(args) == 3:
        for i in range(3):
            _ = Int(args[i])  # raises unless an integer
        return "line"
    if len(args) == 7:
        _ = class_of(args[0])
        for i in range(1, 7):
            _ = Int(args[i])
        return "class"
    if len(args) == 8 and args[0] == "norm":
        _ = class_of(args[1])
        for i in range(2, 8):
            _ = Int(args[i])
        return "norm"
    if len(args) == 11 and args[0] == "wedge":
        _ = class_of(args[1])
        for i in range(2, 11):
            _ = Int(args[i])
        return "wedge"
    raise Error("usage: symbolic_line_certificate.mojo [SLOPE K BRANCH | [norm] CLASS AP BP AQ BQ AR BR | wedge CLASS P0 PA PB Q0 QA QB R0 RA RB | lines]")


def spec_from(args: List[String], mode: String) raises -> ClassLine:
    if mode == "line":
        return class_b(Int(args[0]), Int(args[1]), Int(args[2]))
    var at = 1 if mode == "norm" else 0
    var coef = List[Int]()
    for i in range(at + 1, at + 7):
        coef.append(Int(args[i]))
    return ClassLine(class_of(args[at]), coef, mode == "norm")


def main() raises:
    var argv_ = argv()
    var args = List[String]()
    for i in range(1, len(argv_)):
        args.append(String(argv_[i]))
    var mode = mode_of(args)
    if mode == "wedge":
        var coef = List[Int]()
        for i in range(2, 11):
            coef.append(Int(args[i]))
        report_wedge(ClassWedge(class_of(args[1]), coef))
        return
    if mode == "lines":
        var lines = certified_lines()
        for i in range(len(lines)):
            report(spec_of(lines[i]))
        var norm_lines = certified_norm_lines()
        for i in range(len(norm_lines)):
            report(spec_of(norm_lines[i], True))
        var wedges = certified_wedges()
        for i in range(len(wedges)):
            report_wedge(wedge_of(wedges[i]))
        print("certified lines:", len(lines), " in norm mode:", len(norm_lines), " wedges:", len(wedges))
        return
    report(class_b() if mode == "default" else spec_from(args, mode))
