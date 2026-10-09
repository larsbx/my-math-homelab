"""Certificate: boundary hitting on sectors of Theorem E's class B, by symbolic cones.

docs/p1b-symbolic-cone-2026-10-08.md. Class B is

    sigma(x) = x y^p x,   sigma(c) = c y^q x,   sigma(y) = c y^r x,   |r - q| = 1,

letters `x = 0`, `c = 1`, `y = 2`. A *family* gives `(p, q, r)` as affine
functions of `s = (s1, s2)` with integer coefficients, `s` ranging over
`{s1 >= l1, s2 >= l2}` (a coordinate with zero coefficients everywhere does not
range). `cover` proves, for every PIP member of a family, that every overlap
reachable from a swap seed has an offset-zero descendant:

1. the symbolic cone graph (`psc.symbolic_cone`) on the shifted region
   `{s >= l + (n, n)}` for the least `n` in `shifts()` at which every decision
   certifies; every vertex must have an offset-zero descendant;
2. the strips left over (`s1 = l1 + k` or `s2 = l2 + k`, `k < n`) as
   one-parameter families, recursively;
3. on a line, the finitely many points below its certified region by the
   exact kernel (`symbolic_line_certificate.exact_hits`).

A cross-check, not part of the proof: on each certified region the symbolic
graph at one integer point equals the exact graph there. An undecided region at
every shift raises; so does a vertex without an offset-zero descendant.

Usage: `mojo run -I . class_b_cone_certificate.mojo [all | plus | minus | gaps]`
(default `all`), or `pixi run class-b-cone-certificate`.
"""

from std.sys import argv
from finite_linear_algebra.mat3 import Mat3
from finite_linear_algebra.scalar import q_int
from psc.bpa import substitution_incidence
from psc.exact import q_string
from psc.pisot import CubicScreen
from psc.symbolic_cone import (
    Bracket,
    Cone,
    ConeGraph,
    Frac2,
    Region,
    cone_offset_zero_reachable,
    r2_add,
    r2_const,
    r2_div,
    r2_sub,
    symbolic_cone_graph,
)
from psc.param_poly import (
    QX,
    qx_add,
    qx_affine2,
    qx_at,
    qx_const,
    qx_sub,
)
from symbolic_line_certificate import exact_hits, exact_vertex_keys, same_set
from a1_normal_form_census import CLASS_B, class_member



def shifts() -> List[Int]:
    """The shifts `n` tried, in order, for a family's symbolic region."""
    return [0, 1, 2, 3, 4, 6, 8, 12, 16, 24]


struct Aff(Copyable, Movable):
    """`c0 + c1 s1 + c2 s2`."""

    var c0: Int
    var c1: Int
    var c2: Int

    def __init__(out self, c0: Int, c1: Int, c2: Int):
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2

    def at(self, s1: Int, s2: Int) -> Int:
        return self.c0 + self.c1 * s1 + self.c2 * s2

    def poly(self) -> QX:
        return qx_affine2(self.c0, self.c2, self.c1)

    def fix1(self, v: Int) -> Aff:
        return Aff(self.c0 + self.c1 * v, 0, self.c2)

    def fix2(self, v: Int) -> Aff:
        return Aff(self.c0 + self.c2 * v, self.c1, 0)


struct Family(Copyable, Movable):
    var name: String
    var p: Aff
    var q: Aff
    var r: Aff
    var l1: Int
    var l2: Int

    def __init__(out self, name: String, var p: Aff, var q: Aff, var r: Aff, l1: Int, l2: Int):
        self.name = name
        self.p = p^
        self.q = q^
        self.r = r^
        self.l1 = l1
        self.l2 = l2

    def uses(self, i: Int) -> Bool:
        if i == 1:
            return self.p.c1 != 0 or self.q.c1 != 0 or self.r.c1 != 0
        return self.p.c2 != 0 or self.q.c2 != 0 or self.r.c2 != 0

    def sigma(self, s1: Int, s2: Int) raises -> List[List[Int]]:
        return class_member(CLASS_B, self.p.at(s1, s2), self.q.at(s1, s2), self.r.at(s1, s2))

    def label(self, s1: Int, s2: Int) -> String:
        return "(" + String(self.p.at(s1, s2)) + "," + String(self.q.at(s1, s2)) + "," + String(self.r.at(s1, s2)) + ")"


def class_b_cone(f: Family) raises -> Cone:
    """The cone of a family, with brackets of beta from the fixed-point form
    `beta = r + 1 + (q - r) / beta + p / (beta - 2)` of the eigen-equation
    (`ell_y = 1`, `ell_c = 1 + (q - r) / beta`, `ell_x = p / (beta - 2)`): iterates
    `x0 = r + 1`, `x_{k+1} = g(x_k)`, alternating sides of beta. They are only
    proposals; `psc.symbolic_cone.certify_cone` certifies each bracket."""
    var p = f.p.poly()
    var q = f.q.poly()
    var r = f.r.poly()
    var x0 = r2_const(qx_add(r, qx_const(1)))
    var xs = List[Frac2]()
    xs.append(x0.copy())
    for _ in range(3):
        ref x = xs[len(xs) - 1]
        var nxt = r2_add(r2_add(x0, r2_div(r2_const(qx_sub(q, r)), x)), r2_div(r2_const(p), r2_sub(x, r2_const(qx_const(2)))))
        xs.append(nxt^)
    var brs = List[Bracket]()
    brs.append(Bracket(xs[2].copy(), xs[1].copy()))
    brs.append(Bracket(xs[2].copy(), xs[3].copy()))
    return Cone([0, 1, 1], [0, 0, 0], [p.copy(), q.copy(), r.copy()], 2, brs^)


def cone_vertex_keys(g: ConeGraph, s1: Int, s2: Int) -> List[String]:
    var out = List[String]()
    for i in range(g.size()):
        ref v = g.vertices[i]
        var key = String(v.top) + "|" + String(v.bottom) + "|"
        for k in range(3):
            key += q_string(qx_at(v.w[k], s2, s1)) + ("," if k < 2 else "")
        out.append(key^)
    return out^


def _note(mut tally: CoverTally, line: String):
    tally.log.append(line)
    if tally.verbose:
        print(line, flush=True)


struct CoverTally(Copyable, Movable):
    var regions: Int  # symbolic regions certified
    var finite: Int  # PIP members decided by the exact kernel
    var non_pip: Int  # points of a family that are not PIP (outside class B)
    var largest: Int  # the largest symbolic graph
    var log: List[String]
    var verbose: Bool

    def __init__(out self, verbose: Bool = False):
        self.verbose = verbose
        self.regions = 0
        self.finite = 0
        self.non_pip = 0
        self.largest = 0
        self.log = List[String]()


def _clip(s: String) -> String:
    var n = s.byte_length()
    return String(s[byte=0 : n if n < 160 else 160])


def _try_region(f: Family, n1: Int, n2: Int, mut tally: CoverTally) raises -> Bool:
    var g: ConeGraph
    try:
        g = symbolic_cone_graph(class_b_cone(f), Region(n1, n2))
    except e:
        _note(tally, f.name + ": s >= (" + String(n1) + ", " + String(n2) + ") undecided: " + _clip(String(e)))
        return False
    if not g.pip:
        return False
    var good = cone_offset_zero_reachable(g)
    for i in range(len(good)):
        if not good[i]:
            raise Error("a symbolic seed-reachable vertex has no offset-zero descendant on ", f.name)
    var c1 = n1 + 1 if f.uses(1) else 0
    var c2 = n2 + 2 if f.uses(2) else 0
    if not same_set(cone_vertex_keys(g, c1, c2), exact_vertex_keys(f.sigma(c1, c2))):
        raise Error("cross-check: the symbolic graph differs from the exact graph on ", f.name, " at ", f.label(c1, c2))
    tally.regions += 1
    if g.size() > tally.largest:
        tally.largest = g.size()
    _note(tally, f.name + ": s >= (" + String(n1) + ", " + String(n2) + "), " + String(g.size()) + " vertices")
    return True


def _decide_point(f: Family, s1: Int, s2: Int, mut screen: CubicScreen, mut tally: CoverTally) raises:
    var sigma = f.sigma(s1, s2)
    var m = Mat3(substitution_incidence(sigma))
    if abs(m.det()) != 2 or not screen.is_pip(m):
        tally.non_pip += 1
        return
    var n = exact_hits(sigma)
    tally.finite += 1
    _note(tally, f.name + ": exact " + f.label(s1, s2) + ", " + String(n) + " vertices")


def cover(f: Family, mut screen: CubicScreen, mut tally: CoverTally) raises:
    """Every PIP member of the family hits from every seed; see the module docstring."""
    var u1 = f.uses(1)
    var u2 = f.uses(2)
    if not u1 and not u2:
        _decide_point(f, 0, 0, screen, tally)
        return
    if u1 and u2:
        for k in range(len(shifts())):
            var n = shifts()[k]
            if _try_region(f, f.l1 + n, f.l2 + n, tally):
                for j in range(n):
                    cover(Family(f.name + " s1=" + String(f.l1 + j), f.p.fix1(f.l1 + j), f.q.fix1(f.l1 + j), f.r.fix1(f.l1 + j), 0, f.l2), screen, tally)
                    cover(Family(f.name + " s2=" + String(f.l2 + j), f.p.fix2(f.l2 + j), f.q.fix2(f.l2 + j), f.r.fix2(f.l2 + j), f.l1 + n, 0), screen, tally)
                return
        raise Error("no shift certifies the cone ", f.name)
    var lo = f.l1 if u1 else f.l2
    for k in range(len(shifts())):
        var n = shifts()[k]
        if _try_region(f, lo + n if u1 else 0, lo + n if u2 else 0, tally):
            for j in range(n):
                _decide_point(f, lo + j if u1 else 0, lo + j if u2 else 0, screen, tally)
            return
    raise Error("no shift certifies the line ", f.name)


def plus_branch() -> List[Family]:
    """The `r = q + 1` families.

    Together they contain every `(p, q)` with `q < p <= max(2q + 13, (5q + 10) / 2)`:

    - `J+j`, `p = q + j` for `j = 1..4`;
    - `A+`, `(q, p) = (6, 11) + s1 (1, 2) + s2 (1, 1)`: `5 <= p - q <= q - 1`;
    - `C+c`, `p = 2q + c` for `c = 0..13`;
    - `B+`, `(q, p) = (18, 50) + s1 (1, 2) + s2 (2, 5)`: `p >= 2q + 14`, `2p <= 5q + 10`
      (unimodular generators, so every lattice point of the sector).
    """
    var out = List[Family]()
    for j in range(1, 5):
        out.append(Family("J+" + String(j), Aff(j, 1, 0), Aff(0, 1, 0), Aff(1, 1, 0), 0, 0))
    out.append(Family("A+", Aff(11, 2, 1), Aff(6, 1, 1), Aff(7, 1, 1), 0, 0))
    for c in range(14):
        out.append(Family("C+" + String(c), Aff(c, 2, 0), Aff(0, 1, 0), Aff(1, 1, 0), 0, 0))
    out.append(Family("B+", Aff(50, 2, 5), Aff(18, 1, 2), Aff(19, 1, 2), 0, 0))
    return out^


def minus_branch() -> List[Family]:
    """The `r = q - 1` families.

    Together they contain every `(p, q)` with `1 <= q < p` and `p <= 2q + 7` or
    `2p <= 5q - 5`; `j = p - q`:

    - `J-j`, `j = 1..4`;
    - `A-`, `(q, j) = (12, 5) + s1 (2, 1) + s2 (1, 0)`: `j >= 5`, `2j <= q - 2`;
    - `M-d`, `2j = q + d` for `d = -1..3` (step `(q, j) += (2, 1)`);
    - `B-`, `(q, j) = (16, 10) + s1 (1, 1) + s2 (2, 1)`: `2j >= q + 4`, `j <= q - 6`;
    - `C-c`, `p = 2q + c` for `c = -5..7`;
    - `D-`, `(q, p) = (21, 50) + s1 (1, 2) + s2 (2, 5)`: `p >= 2q + 8`, `2p <= 5q - 5`.
    """
    var out = List[Family]()
    for j in range(1, 5):
        out.append(Family("J-" + String(j), Aff(j + 1, 1, 0), Aff(1, 1, 0), Aff(0, 1, 0), 0, 0))
    out.append(Family("A-", Aff(17, 3, 1), Aff(12, 2, 1), Aff(11, 2, 1), 0, 0))
    for d in range(-1, 4):
        var q0 = 1 if d % 2 != 0 else 2  # q = 2 s + q0 >= 1 with q + d even
        var j0 = (q0 + d) // 2
        out.append(Family("M-" + String(d), Aff(q0 + j0, 3, 0), Aff(q0, 2, 0), Aff(q0 - 1, 2, 0), 0, 0))
    out.append(Family("B-", Aff(26, 2, 3), Aff(16, 1, 2), Aff(15, 1, 2), 0, 0))
    for c in range(-5, 8):
        var q0 = 1 if 2 + c > 1 else 1 - c  # q >= 1 and p = 2q + c > q
        out.append(Family("C-" + String(c), Aff(2 * q0 + c, 2, 0), Aff(q0, 1, 0), Aff(q0 - 1, 1, 0), 0, 0))
    out.append(Family("D-", Aff(50, 2, 5), Aff(21, 1, 2), Aff(20, 1, 2), 0, 0))
    return out^


def contains(f: Family, p: Int, q: Int, r: Int) -> Bool:
    """Whether `(p, q, r)` is the member of `f` at some `s >= (l1, l2)`, by an
    exact solve of the affine equations `(p, q) = c0 + s1 c1 + s2 c2`."""
    var u1 = f.uses(1)
    var u2 = f.uses(2)
    var dp = p - f.p.c0
    var dq = q - f.q.c0
    var s1 = 0
    var s2 = 0
    if u1 and u2:
        var det = f.p.c1 * f.q.c2 - f.p.c2 * f.q.c1
        if det == 0:
            return False
        var n1 = dp * f.q.c2 - f.p.c2 * dq
        var n2 = f.p.c1 * dq - dp * f.q.c1
        if n1 % det != 0 or n2 % det != 0:
            return False
        s1 = n1 // det
        s2 = n2 // det
    elif u1 or u2:
        var cp = f.p.c1 if u1 else f.p.c2
        var cq = f.q.c1 if u1 else f.q.c2
        var num = dq if cq != 0 else dp
        var den = cq if cq != 0 else cp
        if den == 0 or num % den != 0:
            return False
        s1 = num // den if u1 else 0
        s2 = num // den if u2 else 0
    if (u1 and s1 < f.l1) or (u2 and s2 < f.l2):
        return False
    return f.p.at(s1, s2) == p and f.q.at(s1, s2) == q and f.r.at(s1, s2) == r


def coverage_gaps(fams: List[Family], plus: Bool, qmax: Int) -> Int:
    """Points of the branch's claimed region with `q <= qmax` that no family contains."""
    var gaps = 0
    for q in range(1 if not plus else 0, qmax + 1):
        var r = q + 1 if plus else q - 1
        for p in range(q + 1, 3 * q + 13):
            var claimed = (p <= 2 * q + 13 or 2 * p <= 5 * q + 10) if plus else (p <= 2 * q + 7 or 2 * p <= 5 * q - 5)
            if not claimed:
                continue
            var hit = False
            for i in range(len(fams)):
                if contains(fams[i], p, q, r):
                    hit = True
                    break
            if not hit:
                gaps += 1
    return gaps


def main() raises:
    var args = argv()
    var which = String(args[1]) if len(args) > 1 else "all"
    var fams = List[Family]()
    if which == "all":
        fams = plus_branch()
        fams.extend(minus_branch())
    elif which == "plus":
        fams = plus_branch()
    elif which == "minus":
        fams = minus_branch()
    elif which == "gaps":
        print("coverage gaps up to q = 200: plus", coverage_gaps(plus_branch(), True, 200), " minus", coverage_gaps(minus_branch(), False, 200))
        return
    elif which == "A":
        fams.append(Family("A+", Aff(11, 2, 1), Aff(6, 1, 1), Aff(7, 1, 1), 0, 0))
    elif which == "B":
        fams.append(Family("B+", Aff(50, 2, 5), Aff(18, 1, 2), Aff(19, 1, 2), 0, 0))
    elif which == "L":
        fams.append(Family("C+2", Aff(2, 2, 0), Aff(0, 1, 0), Aff(1, 1, 0), 0, 0))
    var screen = CubicScreen()
    var tally = CoverTally(True)
    for i in range(len(fams)):
        cover(fams[i], screen, tally)
    print("regions", tally.regions, "finite", tally.finite, "non-PIP", tally.non_pip, "largest", tally.largest)
