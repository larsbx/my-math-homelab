"""Exact census of the A1' normal form: does the hard tail scale?

Proposition D of docs/p1a-a1-prime-2026-10-05.md. On the catch-up-free
`|det M| = 2` class the surviving aligned template of Theorem C forces the odd
letter set to be exactly the bad edge `{x, c}`, so with `y` the third letter

    sigma(x) = x y^p s_x,   sigma(c) = c y^q s_c,   sigma(y) = t y^r s_y

with `p, q, r >= 0` and `s_x, s_c, t, s_y` in `{x, c}`. The parameters are
unbounded, so the family reaches substitutions past every censused specimen
domain, and this census asks A1' of each member: is the bad edge `{x, c}`
eventually coincident?

The decision is `psc.coincidence_formula.coincidence_level`, the canonical
exact procedure, finite by the Pisot property -- so a negative would be a
verdict and not an exhausted budget. The screen is `psc.pisot.is_pip`, exact.
Nothing is reimplemented here: the driver only enumerates, screens, and folds.

What the census reports, and why those columns: the level histogram, the
deepest level, and the members at level at least `DEEP_LEVEL`. The point of the
sweep is whether that **tail moves** as the parameter bound grows. If the deep
members are the same few at every bound while only the shallow counts grow,
then the hard cases do not scale with the parameters, which is what a uniform
level bound would have to exploit. A growing tail would say the opposite.

Residual-vs-merged is reported too (`first_letter_merge_level`): under this
normal form `h` fixes both `x` and `c`, so no member may be merged, and a
merged one would contradict Proposition A. The driver raises if it sees one.

Usage: `mojo run -I . a1_normal_form_census.mojo [bound]` (default 5), or
`pixi run a1-normal-form-census`. A bound beyond `MAX_BOUND` is refused rather
than silently truncated.
"""

from std.sys import argv
from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from psc.coincidence_formula import coincidence_level, first_letter_merge_level
from psc.histogram import Histogram
from psc.pisot import CubicScreen

comptime MAX_BOUND = 14
comptime DEEP_LEVEL = 4
comptime LEVEL_CAP = 64

# Letters: 0 = x (the bad-edge letter), 1 = c (the hub), 2 = y (the only even one).
comptime X = 0
comptime C = 1
comptime Y = 2


def normal_form(p: Int, q: Int, r: Int, sx: Int, sc: Int, t: Int, sy: Int) raises -> List[List[Int]]:
    """`sigma(x) = x y^p s_x`, `sigma(c) = c y^q s_c`, `sigma(y) = t y^r s_y`."""
    var sigma = List[List[Int]]()
    var img_x = List[Int]([X])
    for _ in range(p):
        img_x.append(Y)
    img_x.append(sx)
    var img_c = List[Int]([C])
    for _ in range(q):
        img_c.append(Y)
    img_c.append(sc)
    var img_y = List[Int]([t])
    for _ in range(r):
        img_y.append(Y)
    img_y.append(sy)
    sigma.append(img_x^)
    sigma.append(img_c^)
    sigma.append(img_y^)
    return sigma^


struct DeepMember(Copyable, Movable, Writable):
    var level: Int
    var p: Int
    var q: Int
    var r: Int
    var sx: Int
    var sc: Int
    var t: Int
    var sy: Int

    def __init__(out self, level: Int, p: Int, q: Int, r: Int, sx: Int, sc: Int, t: Int, sy: Int):
        self.level = level
        self.p = p
        self.q = q
        self.r = r
        self.sx = sx
        self.sc = sc
        self.t = t
        self.sy = sy

    def write_to[W: Writer](self, mut w: W):
        var name = List[String](["x", "c", "y"])
        w.write("level ", self.level, "  sigma(x)=x")
        for _ in range(self.p):
            w.write("y")
        w.write(name[self.sx], " sigma(c)=c")
        for _ in range(self.q):
            w.write("y")
        w.write(name[self.sc], " sigma(y)=", name[self.t])
        for _ in range(self.r):
            w.write("y")
        w.write(name[self.sy], "  (p,q,r)=(", self.p, ",", self.q, ",", self.r, ")")


struct NormalFormCensus(Copyable, Movable):
    var members: Int
    var levels: Histogram
    var deep: List[DeepMember]
    var max_level: Int

    def __init__(out self) raises:
        self.members = 0
        self.levels = Histogram(LEVEL_CAP)
        self.deep = List[DeepMember]()
        self.max_level = -1


def census(bound: Int) raises -> NormalFormCensus:
    if bound < 0 or bound > MAX_BOUND:
        raise Error("the A1' normal-form bound must lie in 0..", String(MAX_BOUND))
    var screen = CubicScreen()
    var out = NormalFormCensus()
    for p in range(bound + 1):
        for q in range(bound + 1):
            for r in range(bound + 1):
                for sx in range(2):
                    for sc in range(2):
                        for t in range(2):
                            for sy in range(2):
                                var sigma = normal_form(p, q, r, sx, sc, t, sy)
                                var m = Mat3(substitution_incidence(sigma))
                                if not screen.is_pip(m):
                                    continue
                                if abs(m.det()) != 2:
                                    continue
                                out.members += 1
                                # Proposition A: h fixes x and c here, so the
                                # pair can never be merged.
                                if first_letter_merge_level(sigma, X, C) >= 0:
                                    raise Error("a normal-form member merged at the endpoint, against Proposition A")
                                var lev = coincidence_level(sigma, X, C)
                                if lev < 0:
                                    raise Error("A1' REFUTED: the bad edge is not eventually coincident")
                                out.levels.record(lev)
                                if lev > out.max_level:
                                    out.max_level = lev
                                if lev >= DEEP_LEVEL:
                                    out.deep.append(DeepMember(lev, p, q, r, sx, sc, t, sy))
    return out^


def main() raises:
    var args = argv()
    var bound = Int(String(args[1])) if len(args) > 1 else 5
    var r = census(bound)
    print("A1' normal-form census, parameter bound p,q,r <=", bound)
    print("PIP members with |det M| = 2:", r.members)
    print("members merged at the endpoint: 0 (Proposition A forbids any; one would have raised)")
    print("A1' refutations:", 0, " (a negative would have raised: the decision is exact and finite)")
    print("coincidence level histogram:")
    for k in range(LEVEL_CAP):
        if r.levels.count(k) != 0:
            print("    level", k, ":", r.levels.count(k), "members")
    print("deepest level:", r.max_level)
    print("members at level >=", DEEP_LEVEL, ":", len(r.deep))
    for i in range(len(r.deep)):
        print("   ", r.deep[i])
    print()
    print("The tail is the point: run this at two bounds and compare the")
    print("level-", DEEP_LEVEL, "-and-up rows. Identical rows mean the hard cases do not")
    print("scale with the parameters; a growing tail would mean they do.")


# ---------------------------------------------------------------------------
# Theorem E (docs/p1a-a1-prime-2026-10-05.md §3b): the certificate behind the
# proof. Everything below checks a *named* position or an explicit finite
# list; nothing searches.
# ---------------------------------------------------------------------------

# One ending tuple per mirror class under x <-> c, as (s_x, s_c, t, s_y).
comptime CLASS_A = 0  # (x, x, x, c): sigma(y) = x y^r c
comptime CLASS_B = 1  # (x, x, c, x): sigma(y) = c y^r x
comptime CLASS_C = 2  # (x, x, c, c): sigma(y) = c y^r c
comptime CLASS_D = 3  # (c, x, c, c): sigma(x) = x y^p c


def class_ending(cls: Int) raises -> List[Int]:
    if cls == CLASS_A:
        return List[Int]([X, X, X, C])
    if cls == CLASS_B:
        return List[Int]([X, X, C, X])
    if cls == CLASS_C:
        return List[Int]([X, X, C, C])
    if cls == CLASS_D:
        return List[Int]([C, X, C, C])
    raise Error("Theorem E has four classes")


def class_member(cls: Int, p: Int, q: Int, r: Int) raises -> List[List[Int]]:
    var e = class_ending(cls)
    return normal_form(p, q, r, e[0], e[1], e[2], e[3])


struct NamedWitness(Copyable, Movable):
    """A lemma's witness: shared tile at `position` of `sigma^level(x)` and
    `sigma^level(c)`. `level == 0` means the point is outside every lemma."""

    var level: Int
    var position: Int

    def __init__(out self, level: Int, position: Int):
        self.level = level
        self.position = position


def lemma_witness(cls: Int, p: Int, q: Int, r: Int) raises -> NamedWitness:
    """The position Lemma L_BC, L_D or L_A names, or level 0 outside its region.

    L_BC (classes B, C; level 2): p > q, r >= 1, q >= 1. Position
      (p + 2) + q (r + 2) + 1.
    L_D (class D; level 2): |p - q| = 1, min(p, q) >= 1, r >= 2. Position
      p + 3 when p = q + 1, p + 4 when p = q - 1.
    L_A (class A; level 3): p > q, |r - q| = 1, except (1, 0, 1) and the lines
      (p, 1, 0), p >= 3, and (p, 2, 1), p >= 4. Position p + q + 6 + q(r + 2)
      when r = q + 1, p + q + 5 + q(r + 2) when r = q - 1."""
    if cls == CLASS_B or cls == CLASS_C:
        if p > q and r >= 1 and q >= 1:
            return NamedWitness(2, (p + 2) + q * (r + 2) + 1)
        return NamedWitness(0, 0)
    if cls == CLASS_D:
        if abs(p - q) == 1 and min(p, q) >= 1 and r >= 2:
            return NamedWitness(2, p + 3 if p == q + 1 else p + 4)
        return NamedWitness(0, 0)
    if cls == CLASS_A:
        if not (p > q and abs(r - q) == 1):
            return NamedWitness(0, 0)
        if r == q + 1:
            if p == q + 1 and q == 0:
                return NamedWitness(0, 0)
            return NamedWitness(3, p + q + 6 + q * (r + 2))
        if p > q + 1 and (q == 1 or q == 2):
            return NamedWitness(0, 0)
        return NamedWitness(3, p + q + 5 + q * (r + 2))
    raise Error("Theorem E has four classes")


def _apply(sigma: List[List[Int]], w: List[Int]) -> List[Int]:
    var out = List[Int]()
    for k in range(len(w)):
        for c in range(len(sigma[w[k]])):
            out.append(sigma[w[k]][c])
    return out^


def _power_image(sigma: List[List[Int]], letter: Int, level: Int) -> List[Int]:
    var w = List[Int]([letter])
    for _ in range(level):
        w = _apply(sigma, w)
    return w^


def shared_tile_at(sigma: List[List[Int]], level: Int, position: Int) -> Bool:
    """Position `position` of `sigma^level(x)` and `sigma^level(c)` carries the
    same letter after equal Parikh prefixes. Equal Parikh prefixes have equal
    length, so one position indexes both words."""
    return shared_tile_between(sigma, X, C, level, position)


def shared_tile_between(sigma: List[List[Int]], a: Int, b: Int, level: Int, position: Int) -> Bool:
    """The same test for the pair `{a, b}`: position `position` of
    `sigma^level(a)` and `sigma^level(b)` is a shared tile."""
    var u = _power_image(sigma, a, level)
    var w = _power_image(sigma, b, level)
    if position >= len(u) or position >= len(w):
        return False
    var pu = List[Int](length=3, fill=0)
    var pw = List[Int](length=3, fill=0)
    for k in range(position):
        pu[u[k]] += 1
        pw[w[k]] += 1
    return pu == pw and u[position] == w[position]


def f_at(m: Mat3, t: Int) -> Int:
    """`det(t I - M)`, the characteristic polynomial at `t`."""
    var e = List[Int]()
    for i in range(3):
        for j in range(3):
            e.append((t if i == j else 0) - m.e[3 * i + j])
    return Mat3(e).det()


def residual_points(cls: Int) raises -> List[List[Int]]:
    """The PIP points of a class that no lemma covers: 27 in all."""
    var out = List[List[Int]]()
    if cls == CLASS_A:
        out.append(List[Int]([1, 0, 1]))
        out.append(List[Int]([4, 2, 1]))
        out.append(List[Int]([5, 2, 1]))
    elif cls == CLASS_B:
        for n in range(1, 12):
            out.append(List[Int]([n, 0, 1]))
        out.append(List[Int]([2, 1, 0]))
    elif cls == CLASS_C:
        out.append(List[Int]([1, 0, 0]))
        out.append(List[Int]([3, 1, 0]))
        out.append(List[Int]([5, 2, 0]))
        out.append(List[Int]([7, 3, 0]))
    elif cls == CLASS_D:
        out.append(List[Int]([1, 0, 0]))
        out.append(List[Int]([1, 0, 1]))
        out.append(List[Int]([1, 0, 2]))
        out.append(List[Int]([2, 1, 0]))
        out.append(List[Int]([2, 1, 1]))
        out.append(List[Int]([3, 2, 0]))
        out.append(List[Int]([3, 2, 1]))
        out.append(List[Int]([4, 3, 1]))
    else:
        raise Error("Theorem E has four classes")
    return out^


struct TheoremECheck(Copyable, Movable):
    var lemma_verified: Int
    var lemma_failed: Int
    var pip_points: Int
    var pisot_conditions_held: Int
    var residual_found: Int
    var residual_unexpected: Int

    def __init__(out self):
        self.lemma_verified = 0
        self.lemma_failed = 0
        self.pip_points = 0
        self.pisot_conditions_held = 0
        self.residual_found = 0
        self.residual_unexpected = 0


def _in_residual(cls: Int, p: Int, q: Int, r: Int) raises -> Bool:
    var pts = residual_points(cls)
    for k in range(len(pts)):
        if pts[k][0] == p and pts[k][1] == q and pts[k][2] == r:
            return True
    return False


def theorem_e_check(bound: Int) raises -> TheoremECheck:
    """Over every `|det M| = 2` point of the four classes with parameters at
    most `bound`: each lemma's named position is a shared tile, every PIP point
    satisfies `f(1) < 0` and `f(-1) < 0`, and the PIP points outside the lemmas
    are exactly the listed residual ones."""
    if bound < 0 or bound > MAX_BOUND:
        raise Error("the Theorem E bound must lie in 0..", String(MAX_BOUND))
    var screen = CubicScreen()
    var out = TheoremECheck()
    for cls in range(4):
        for p in range(bound + 1):
            for q in range(bound + 1):
                for r in range(bound + 1):
                    var sigma = class_member(cls, p, q, r)
                    var m = Mat3(substitution_incidence(sigma))
                    if abs(m.det()) != 2:
                        continue
                    var pip = screen.is_pip(m)
                    if pip:
                        out.pip_points += 1
                        if f_at(m, 1) < 0 and f_at(m, -1) < 0:
                            out.pisot_conditions_held += 1
                    var wit = lemma_witness(cls, p, q, r)
                    if wit.level > 0:
                        if shared_tile_at(sigma, wit.level, wit.position):
                            out.lemma_verified += 1
                        else:
                            out.lemma_failed += 1
                    elif pip:
                        if _in_residual(cls, p, q, r):
                            out.residual_found += 1
                        else:
                            out.residual_unexpected += 1
    return out^


# ---------------------------------------------------------------------------
# Proposition Y (docs/p1a-a1-prime-2026-10-05.md §3c): the two sigma(x) = y
# families of the |O| = 2 class whose H-cycles are not closed by Theorem E,
# by a single-letter image, or by Barge-Diamond. Named positions only.
# ---------------------------------------------------------------------------

comptime FAMILY_F1 = 0  # sigma(x) = y, sigma(c) = c y^q c, sigma(y) = x y^r c; det M = -2
comptime FAMILY_F2 = 1  # sigma(x) = y, sigma(c) = x y^q x, sigma(y) = x y^r c; det M = 2


def y_family_member(fam: Int, q: Int, r: Int) raises -> List[List[Int]]:
    if fam != FAMILY_F1 and fam != FAMILY_F2:
        raise Error("Proposition Y has two families")
    var end = C if fam == FAMILY_F1 else X
    var img_c = List[Int]([end])
    for _ in range(q):
        img_c.append(Y)
    img_c.append(end)
    var img_y = List[Int]([X])
    for _ in range(r):
        img_y.append(Y)
    img_y.append(C)
    var sigma = List[List[Int]]()
    sigma.append(List[Int]([Y]))
    sigma.append(img_c^)
    sigma.append(img_y^)
    return sigma^


def y_family_residue(fam: Int) raises -> List[List[Int]]:
    """The PIP points `(q, r)` with `r <= 1`, where Lemma L_y names nothing."""
    var out = List[List[Int]]()
    if fam == FAMILY_F1:
        out.append(List[Int]([2, 1]))
    elif fam == FAMILY_F2:
        out.append(List[Int]([1, 1]))
        out.append(List[Int]([2, 1]))
    else:
        raise Error("Proposition Y has two families")
    return out^


struct YFamilyCheck(Copyable, Movable):
    var points: Int
    var det_held: Int
    var pip_points: Int
    var pisot_conditions_held: Int
    var ly_verified: Int
    var ly_failed: Int
    var lcy_verified: Int
    var lcy_failed: Int
    var pip_outside_lcy: Int
    var residual_found: Int
    var residual_unexpected: Int

    def __init__(out self):
        self.points = 0
        self.det_held = 0
        self.pip_points = 0
        self.pisot_conditions_held = 0
        self.ly_verified = 0
        self.ly_failed = 0
        self.lcy_verified = 0
        self.lcy_failed = 0
        self.pip_outside_lcy = 0
        self.residual_found = 0
        self.residual_unexpected = 0


def _in_y_residue(fam: Int, q: Int, r: Int) raises -> Bool:
    var pts = y_family_residue(fam)
    for k in range(len(pts)):
        if pts[k][0] == q and pts[k][1] == r:
            return True
    return False


def y_family_check(fam: Int, bound: Int) raises -> YFamilyCheck:
    """Over every `(q, r)` with both at most `bound`: `det M` is the family's
    constant; every PIP point satisfies `f(1) < 0` and `f(-1) < 0`; Lemma L_y's
    position 2 is a shared tile of `{x, y}` at level 2 whenever `r >= 2`; in
    family F1, Lemma L_cy's position `q + r^2 + r + 1` is a shared tile of
    `{c, y}` at level 2 whenever `q > r >= 1`, and no PIP point lies outside
    that region; the PIP points with `r <= 1` are exactly the listed residue."""
    if bound < 0 or bound > MAX_BOUND:
        raise Error("the Proposition Y bound must lie in 0..", String(MAX_BOUND))
    var want_det = -2 if fam == FAMILY_F1 else 2
    var screen = CubicScreen()
    var out = YFamilyCheck()
    for q in range(bound + 1):
        for r in range(bound + 1):
            var sigma = y_family_member(fam, q, r)
            var m = Mat3(substitution_incidence(sigma))
            out.points += 1
            if m.det() == want_det:
                out.det_held += 1
            var pip = screen.is_pip(m)
            if pip:
                out.pip_points += 1
                if f_at(m, 1) < 0 and f_at(m, -1) < 0:
                    out.pisot_conditions_held += 1
            if r >= 2:
                if shared_tile_between(sigma, X, Y, 2, 2):
                    out.ly_verified += 1
                else:
                    out.ly_failed += 1
            elif pip:
                if _in_y_residue(fam, q, r):
                    out.residual_found += 1
                else:
                    out.residual_unexpected += 1
            if fam == FAMILY_F1:
                if q > r and r >= 1:
                    if shared_tile_between(sigma, C, Y, 2, q + r * r + r + 1):
                        out.lcy_verified += 1
                    else:
                        out.lcy_failed += 1
                elif pip:
                    out.pip_outside_lcy += 1
    return out^


# ---------------------------------------------------------------------------
# The swap family (docs/p1a-a1-prime-2026-10-05.md §3c): the one part of the
# |O| = 2 class that §3c's reduction does not close. h swaps x and c, so the
# pair {x, c} is its own H-image and no transfer reaches it. This is an exact
# sweep -- the decision is coincidence_level, so a negative would raise -- and
# not the proof, which is Theorem H in swap_family_certificate.mojo.
# ---------------------------------------------------------------------------


def swap_member(p: Int, q: Int, r: Int, sx: Int, sc: Int, t: Int, sy: Int) raises -> List[List[Int]]:
    """`sigma(x) = c y^p s_x`, `sigma(c) = x y^q s_c`, `sigma(y) = t y^r s_y`."""
    var sigma = normal_form(p, q, r, sx, sc, t, sy)
    sigma[X][0] = C
    sigma[C][0] = X
    return sigma^


struct SwapCensus(Copyable, Movable):
    var members: Int
    var per_ending: List[Int]
    var levels: Histogram
    var max_level: Int

    def __init__(out self) raises:
        self.members = 0
        self.per_ending = List[Int](length=16, fill=0)
        self.levels = Histogram(LEVEL_CAP)
        self.max_level = -1


def swap_census(bound: Int) raises -> SwapCensus:
    """Every PIP member with `|det M| = 2` and `p, q, r <= bound`, with its
    `{x, c}` coincidence level. Ending index `8 s_x + 4 s_c + 2 t + s_y`."""
    if bound < 0 or bound > MAX_BOUND:
        raise Error("the swap-family bound must lie in 0..", String(MAX_BOUND))
    var screen = CubicScreen()
    var out = SwapCensus()
    for sx in range(2):
        for sc in range(2):
            for t in range(2):
                for sy in range(2):
                    for p in range(bound + 1):
                        for q in range(bound + 1):
                            for r in range(bound + 1):
                                var sigma = swap_member(p, q, r, sx, sc, t, sy)
                                var m = Mat3(substitution_incidence(sigma))
                                if abs(m.det()) != 2 or not screen.is_pip(m):
                                    continue
                                var lev = coincidence_level(sigma, X, C)
                                if lev < 0:
                                    raise Error("SC REFUTED in the swap family: {x, c} is not eventually coincident")
                                out.members += 1
                                out.per_ending[8 * sx + 4 * sc + 2 * t + sy] += 1
                                out.levels.record(lev)
                                if lev > out.max_level:
                                    out.max_level = lev
    return out^
