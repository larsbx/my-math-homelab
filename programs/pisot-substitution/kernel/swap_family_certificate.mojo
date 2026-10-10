"""Certificate: the swap family satisfies strong coincidence for `{x, c}`.

docs/p1a-a1-prime-2026-10-05.md §3d. The swap family is

    sigma(x) = c y^p s_x,   sigma(c) = x y^q s_c,   sigma(y) = t y^r s_y,

the one part of the catch-up-free `|det M| = 2`, two-odd-letter class that
§3c's reduction (Theorem G) leaves open. Ten of its sixteen endings carry PIP
members with `|det M| = 2`; on each, `|det M| = 2` is one or two affine planes
in `(p, q, r)`, and Lemma P1 (`f(1) < 0`, `f(-1) < 0`) puts every PIP point of
a plane into a quadrant `base + u g_u + v g_v`, `u, v >= 0` (the note proves
this per branch; `coverage_check` re-checks it on a bounded box).

Each quadrant is covered by recursion: try a parametric witness path
(`psc.cone_witness`) on the region; failing that, cut it if `f(1)` or `f(-1)`
is provably nonnegative on it; failing that, split it into a line, a line and
a smaller quadrant (a line into a point and a shorter line). Every region
ends as a certified cone, a cut, a single point, or -- at the depth limit -- a
failure, which is reported and never counted as covered. Single points are
screened exactly and decided by `coincidence_level`; a non-coincident PIP
point would raise.

Usage: `mojo run -I . swap_family_certificate.mojo`, or
`pixi run swap-family-certificate`.
"""

from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from psc.coincidence_formula import coincidence_level
from psc.cone_witness import (
    ConeFamily,
    Segment,
    WitnessStep,
    aff_nonneg,
    letter_segment,
    run_segment,
    search_witness,
    verify_witness,
    witness_position,
)
from psc.corpus import pip_corpus
from psc.one_tile import catch_up_free, odd_letter_sets
from psc.pisot import CubicScreen
from a1_normal_form_census import C, X, Y, f_at, shared_tile_between, swap_member

comptime OFFSET_BOUND = 3
comptime MAX_LEVEL = 5
comptime MAX_DEPTH = 8

comptime FREE_NONE = 0
comptime FREE_U = 1
comptime FREE_V = 2
comptime FREE_UV = 3

comptime KIND_CONE = 0
comptime KIND_CUT = 1
comptime KIND_POINT = 2
comptime KIND_FAILED = 3


struct Branch(Copyable, Movable):
    """An ending `(s_x, s_c, t, s_y)` and a quadrant of one of its
    `|det M| = 2` planes: `(p, q, r) = base + u g_u + v g_v`."""

    var name: String
    var ending: List[Int]
    var base: List[Int]
    var gu: List[Int]
    var gv: List[Int]

    def __init__(out self, name: String, var ending: List[Int], var base: List[Int], var gu: List[Int], var gv: List[Int]):
        self.name = name
        self.ending = ending^
        self.base = base^
        self.gu = gu^
        self.gv = gv^


def _swap_letter(a: Int) -> Int:
    return C if a == X else X


def mirror(b: Branch) -> Branch:
    """`x <-> c` maps the ending to `(swap s_c, swap s_x, swap t, swap s_y)`
    and `(p, q, r)` to `(q, p, r)`."""
    var e = List[Int]([_swap_letter(b.ending[1]), _swap_letter(b.ending[0]), _swap_letter(b.ending[2]), _swap_letter(b.ending[3])])
    return Branch(
        b.name + " mirrored",
        e^,
        List[Int]([b.base[1], b.base[0], b.base[2]]),
        List[Int]([b.gu[1], b.gu[0], b.gu[2]]),
        List[Int]([b.gv[1], b.gv[0], b.gv[2]]),
    )


def branches() -> List[Branch]:
    """The five classes, two plane branches each, then their mirrors."""
    var out = List[Branch]()
    # S1 (x,x,x,x): det 2(q - r); f(-1) = 2(p - q) < 0 gives q = p + 1 + v.
    out.append(Branch("S1 r=q+1", List[Int]([X, X, X, X]), List[Int]([0, 1, 2]), List[Int]([1, 1, 1]), List[Int]([0, 1, 1])))
    out.append(Branch("S1 r=q-1", List[Int]([X, X, X, X]), List[Int]([0, 1, 0]), List[Int]([1, 1, 1]), List[Int]([0, 1, 1])))
    # S2 (x,x,x,c), S3 (x,x,c,x): det 2(p - r); f(-1) = q - p < 0 gives p = q + 1 + v.
    out.append(Branch("S2 r=p+1", List[Int]([X, X, X, C]), List[Int]([1, 0, 2]), List[Int]([1, 1, 1]), List[Int]([1, 0, 1])))
    out.append(Branch("S2 r=p-1", List[Int]([X, X, X, C]), List[Int]([1, 0, 0]), List[Int]([1, 1, 1]), List[Int]([1, 0, 1])))
    out.append(Branch("S3 r=p+1", List[Int]([X, X, C, X]), List[Int]([1, 0, 2]), List[Int]([1, 1, 1]), List[Int]([1, 0, 1])))
    out.append(Branch("S3 r=p-1", List[Int]([X, X, C, X]), List[Int]([1, 0, 0]), List[Int]([1, 1, 1]), List[Int]([1, 0, 1])))
    # S4 (x,x,c,c): det 2(2p - q - r); f(-1) = 4(q - p) < 0 gives p = q + 1 + v.
    out.append(Branch("S4 q+r=2p+1", List[Int]([X, X, C, C]), List[Int]([1, 0, 3]), List[Int]([1, 1, 1]), List[Int]([1, 0, 2])))
    out.append(Branch("S4 q+r=2p-1", List[Int]([X, X, C, C]), List[Int]([1, 0, 1]), List[Int]([1, 1, 1]), List[Int]([1, 0, 2])))
    # S5 (x,c,x,x): det 2(q - p); no inequality needed.
    out.append(Branch("S5 q=p+1", List[Int]([X, C, X, X]), List[Int]([0, 1, 0]), List[Int]([1, 1, 0]), List[Int]([0, 0, 1])))
    out.append(Branch("S5 p=q+1", List[Int]([X, C, X, X]), List[Int]([1, 0, 0]), List[Int]([1, 1, 0]), List[Int]([0, 0, 1])))
    var n = len(out)
    for i in range(n):
        out.append(mirror(out[i]))
    return out^


def _gens(b: Branch, free: Int) -> List[List[Int]]:
    var g = List[List[Int]]()
    if free == FREE_U or free == FREE_UV:
        g.append(b.gu.copy())
    if free == FREE_V or free == FREE_UV:
        g.append(b.gv.copy())
    return g^


def cone_family(ending: List[Int], base: List[Int], gens: List[List[Int]]) raises -> ConeFamily:
    """The swap family over the cone `base + sum n_k gens[k]`."""
    var m = len(gens)
    var forms = List[List[Int]]()
    for i in range(3):
        var f = List[Int]([base[i]])
        for k in range(m):
            f.append(gens[k][i])
        forms.append(f^)
    var images = List[List[Segment]]()
    var first = List[Int]([C, X, ending[2]])
    var last = List[Int]([ending[0], ending[1], ending[3]])
    for a in range(3):
        var img = List[Segment]()
        img.append(letter_segment(m, first[a]))
        img.append(run_segment(forms[a].copy()))
        img.append(letter_segment(m, last[a]))
        images.append(img^)
    return ConeFamily(m, images^)


def _point(base: List[Int], gens: List[List[Int]], ns: List[Int]) -> List[Int]:
    var p = base.copy()
    for k in range(len(gens)):
        for i in range(3):
            p[i] += ns[k] * gens[k][i]
    return p^


def _member(ending: List[Int], pt: List[Int]) raises -> List[List[Int]]:
    return swap_member(pt[0], pt[1], pt[2], ending[0], ending[1], ending[2], ending[3])


def _f_form(ending: List[Int], base: List[Int], gens: List[List[Int]], t: Int) raises -> List[Int]:
    """`f(t) = det(tI - M)` on the cone as an affine form. The parameters sit
    only in the `y`-row of `M`, so it is affine; the form is checked at
    `base + g_j + g_k` and `base + 2 g_k` and refused if it is not."""
    var m = len(gens)
    var zero = List[Int](length=m, fill=0)
    var f0 = f_at(Mat3(substitution_incidence(_member(ending, base))), t)
    var form = List[Int]([f0])
    for k in range(m):
        var e = zero.copy()
        e[k] = 1
        form.append(f_at(Mat3(substitution_incidence(_member(ending, _point(base, gens, e)))), t) - f0)
    for j in range(m):
        for k in range(m):
            var e = zero.copy()
            e[j] += 1
            e[k] += 1
            var want = f0 + form[j + 1] + form[k + 1]
            if f_at(Mat3(substitution_incidence(_member(ending, _point(base, gens, e)))), t) != want:
                raise Error("f(t) is not affine on the cone")
    return form^


struct CoverRecord(Copyable, Movable):
    var kind: Int
    var base: List[Int]
    var free: Int
    var level: Int  # cone: witness level; point: coincidence level, 0 if not PIP
    var cut_at: Int  # cut: which t of f(t) is nonnegative
    var steps: List[WitnessStep]

    def __init__(out self, kind: Int, var base: List[Int], free: Int, level: Int, cut_at: Int, var steps: List[WitnessStep]):
        self.kind = kind
        self.base = base^
        self.free = free
        self.level = level
        self.cut_at = cut_at
        self.steps = steps^


struct BranchCover(Copyable, Movable):
    var branch: Branch
    var records: List[CoverRecord]
    var cones: Int
    var cuts: Int
    var points: Int
    var pip_points: Int
    var failed: Int

    def __init__(out self, var branch: Branch):
        self.branch = branch^
        self.records = List[CoverRecord]()
        self.cones = 0
        self.cuts = 0
        self.points = 0
        self.pip_points = 0
        self.failed = 0


def cover_branch(b: Branch) raises -> BranchCover:
    var out = BranchCover(b.copy())
    var screen = CubicScreen()
    # explicit stack of (u0, v0, free, depth)
    var su = List[Int]([0])
    var sv = List[Int]([0])
    var sf = List[Int]([FREE_UV])
    var sd = List[Int]([MAX_DEPTH])
    while len(su) > 0:
        var u0 = su.pop()
        var v0 = sv.pop()
        var free = sf.pop()
        var depth = sd.pop()
        var base = b.base.copy()
        for i in range(3):
            base[i] += u0 * b.gu[i] + v0 * b.gv[i]
        if free == FREE_NONE:
            var sigma = _member(b.ending, base)
            var lev = 0
            if screen.is_pip(Mat3(substitution_incidence(sigma))):
                lev = coincidence_level(sigma, X, C)
                if lev < 0:
                    raise Error("SC REFUTED in the swap family at a residual point")
                out.pip_points += 1
            out.records.append(CoverRecord(KIND_POINT, base^, free, lev, 0, List[WitnessStep]()))
            out.points += 1
            continue
        var gens = _gens(b, free)
        var cut = 0
        if aff_nonneg(_f_form(b.ending, base, gens, 1)):
            cut = 1
        elif aff_nonneg(_f_form(b.ending, base, gens, -1)):
            cut = -1
        if cut != 0:
            out.records.append(CoverRecord(KIND_CUT, base^, free, 0, cut, List[WitnessStep]()))
            out.cuts += 1
            continue
        var fam = cone_family(b.ending, base, gens)
        var w = search_witness(fam, X, C, OFFSET_BOUND, MAX_LEVEL)
        if w.found:
            if not verify_witness(fam, X, C, w.steps):
                raise Error("a witness path the search found does not verify")
            out.records.append(CoverRecord(KIND_CONE, base^, free, len(w.steps), 0, w.steps.copy()))
            out.cones += 1
            continue
        if depth == 0:
            out.records.append(CoverRecord(KIND_FAILED, base^, free, 0, 0, List[WitnessStep]()))
            out.failed += 1
            continue
        if free == FREE_UV:
            # the line u = u0, the line v = v0 with u > u0, the quadrant beyond
            su.append(u0 + 1); sv.append(v0 + 1); sf.append(FREE_UV); sd.append(depth - 1)
            su.append(u0 + 1); sv.append(v0); sf.append(FREE_U); sd.append(depth - 1)
            su.append(u0); sv.append(v0); sf.append(FREE_V); sd.append(depth - 1)
        elif free == FREE_U:
            su.append(u0 + 1); sv.append(v0); sf.append(FREE_U); sd.append(depth - 1)
            su.append(u0); sv.append(v0); sf.append(FREE_NONE); sd.append(depth - 1)
        else:
            su.append(u0); sv.append(v0 + 1); sf.append(FREE_V); sd.append(depth - 1)
            su.append(u0); sv.append(v0); sf.append(FREE_NONE); sd.append(depth - 1)
    return out^


def cover_all() raises -> List[BranchCover]:
    var bs = branches()
    var out = List[BranchCover]()
    for i in range(len(bs)):
        out.append(cover_branch(bs[i]))
    return out^


def numeric_check(cov: BranchCover, samples: Int) raises -> Int:
    """Instantiate every cone at the sample points `n_k < samples`, and check
    the named position is a shared tile of the actual words. Returns the
    number of checks; raises on a failure."""
    var checks = 0
    for i in range(len(cov.records)):
        ref rec = cov.records[i]
        if rec.kind != KIND_CONE:
            continue
        var gens = _gens(cov.branch, rec.free)
        var fam = cone_family(cov.branch.ending, rec.base, gens)
        var m = len(gens)
        var total = 1
        for _ in range(m):
            total *= samples
        for idx in range(total):
            var ns = List[Int]()
            var rest = idx
            for _ in range(m):
                ns.append(rest % samples)
                rest //= samples
            var sigma = fam.instantiate(ns)
            var pos = witness_position(fam, X, C, rec.steps, ns)
            if not shared_tile_between(sigma, X, C, rec.level, pos):
                raise Error("a certified cone fails at a sample point: ", cov.branch.name)
            checks += 1
    return checks


def _in_record(cov: BranchCover, rec: CoverRecord, pt: List[Int], bound: Int) -> Bool:
    var gens = _gens(cov.branch, rec.free)
    if len(gens) == 0:
        return rec.base == pt
    if len(gens) == 1:
        for n in range(bound + 2):
            if _point(rec.base, gens, List[Int]([n])) == pt:
                return True
        return False
    for n1 in range(bound + 2):
        for n2 in range(bound + 2):
            if _point(rec.base, gens, List[Int]([n1, n2])) == pt:
                return True
    return False


struct CoverageCheck(Copyable, Movable):
    var pip_members: Int
    var in_cones: Int
    var in_points: Int
    var in_cuts: Int
    var uncovered: Int

    def __init__(out self):
        self.pip_members = 0
        self.in_cones = 0
        self.in_points = 0
        self.in_cuts = 0
        self.uncovered = 0


def coverage_check(covers: List[BranchCover], bound: Int) raises -> CoverageCheck:
    """Every PIP swap member with `|det M| = 2` and `p, q, r <= bound` lies in a
    certified cone or is a decided point of some branch of its ending. A PIP
    member in a cut region would contradict Lemma P1 and is counted apart."""
    var screen = CubicScreen()
    var out = CoverageCheck()
    for sx in range(2):
        for sc in range(2):
            for t in range(2):
                for sy in range(2):
                    var e = List[Int]([sx, sc, t, sy])
                    for p in range(bound + 1):
                        for q in range(bound + 1):
                            for r in range(bound + 1):
                                var pt = List[Int]([p, q, r])
                                var m = Mat3(substitution_incidence(_member(e, pt)))
                                if abs(m.det()) != 2 or not screen.is_pip(m):
                                    continue
                                out.pip_members += 1
                                var kind = -1
                                for i in range(len(covers)):
                                    if covers[i].branch.ending != e:
                                        continue
                                    for j in range(len(covers[i].records)):
                                        ref rec = covers[i].records[j]
                                        if rec.kind == KIND_FAILED:
                                            continue
                                        if _in_record(covers[i], rec, pt, bound):
                                            if kind != KIND_CONE and kind != KIND_POINT:
                                                kind = rec.kind
                                if kind == KIND_CONE:
                                    out.in_cones += 1
                                elif kind == KIND_POINT:
                                    out.in_points += 1
                                elif kind == KIND_CUT:
                                    out.in_cuts += 1
                                else:
                                    out.uncovered += 1
    return out^


comptime ROW_IDENTITY = 0  # no length-one image, h fixes both odd letters: Theorem E
comptime ROW_EQUAL = 1  # no length-one image, h(x) = h(c): Lemma T alone
comptime ROW_SWAP = 2  # no length-one image, h swaps them: Theorem H
comptime ROW_Y_CONSTANT = 3  # sigma(x) = y, h(c) = h(y) = c: Lemma T alone
comptime ROW_THREE_CYCLE = 4  # sigma(x) = y, h(c) = x, h(y) = c: Barge-Diamond
comptime ROW_F2 = 5  # sigma(x) = y, h(c) = h(y) = x: Proposition Y
comptime ROW_F1 = 6  # sigma(x) = y, h(c) = c, h(y) = x: Proposition Y


# One odd letter o (Proposition O): images are a single non-o letter or o w o.
comptime ONE_NONE_SHORT = 0  # h is constant o: Lemma T alone
comptime ONE_SHORT_NOT_O = 1  # sigma(a) = b with a != o: Lemma T alone
comptime ONE_SHORT_O = 2  # sigma(o) = b: the pair {o, b} is H-fixed, open
comptime ONE_TWO_SHORT = 3  # sigma(o) = z, sigma(z) = y: Barge-Diamond


struct TwoOddSurvey(Copyable, Movable):
    var catch_up_free: Int
    var one_odd: Int
    var two_odd: Int
    var rows: List[Int]
    var one_rows: List[Int]

    def __init__(out self):
        self.catch_up_free = 0
        self.one_odd = 0
        self.two_odd = 0
        self.rows = List[Int](length=7, fill=0)
        self.one_rows = List[Int](length=4, fill=0)


def two_odd_survey() raises -> TwoOddSurvey:
    """Sort the catch-up-free corpus specimens by the rows of §3c.1's table,
    naming the odd letters `x, c` so that a length-one image is `sigma(x)`.
    Raises if a specimen fits no row, or is catch-up-free without an odd set
    or with `|det M| != 2`."""
    var out = TwoOddSurvey()
    var corpus = pip_corpus()
    for k in range(len(corpus)):
        ref sp = corpus[k]
        if not catch_up_free(sp.sigma):
            continue
        out.catch_up_free += 1
        if abs(sp.incidence.det()) != 2:
            raise Error("a catch-up-free corpus specimen has |det M| != 2")
        var masks = odd_letter_sets(sp.sigma)
        if len(masks) != 1:
            raise Error("a catch-up-free corpus specimen has no unique odd set")
        var odd = List[Int]()
        var even = -1
        for a in range(3):
            if (masks[0] >> a) & 1 == 1:
                odd.append(a)
            else:
                even = a
        if len(odd) == 1:
            out.one_odd += 1
            var shorts = 0
            var o_short = False
            for a in range(3):
                if len(sp.sigma[a]) == 1:
                    shorts += 1
                    if a == odd[0]:
                        o_short = True
            if shorts == 0:
                out.one_rows[ONE_NONE_SHORT] += 1
            elif shorts == 2:
                out.one_rows[ONE_TWO_SHORT] += 1
            elif o_short:
                out.one_rows[ONE_SHORT_O] += 1
            else:
                out.one_rows[ONE_SHORT_NOT_O] += 1
            continue
        if len(odd) != 2:
            raise Error("Lemma D0 forbids three odd letters")
        out.two_odd += 1
        var x = odd[0]
        var c = odd[1]
        if len(sp.sigma[c]) == 1:
            x = odd[1]
            c = odd[0]
        var hx = sp.sigma[x][0]
        var hc = sp.sigma[c][0]
        var hy = sp.sigma[even][0]
        if len(sp.sigma[even]) == 1 or len(sp.sigma[c]) == 1:
            raise Error("a length-one image outside the table")
        if len(sp.sigma[x]) > 1:
            if hx == x and hc == c:
                out.rows[ROW_IDENTITY] += 1
            elif hx == hc:
                out.rows[ROW_EQUAL] += 1
            elif hx == c and hc == x:
                out.rows[ROW_SWAP] += 1
            else:
                raise Error("a first-letter map outside the table")
        else:
            if hx != even:
                raise Error("a length-one image that is not the even letter")
            if hc == c and hy == c:
                out.rows[ROW_Y_CONSTANT] += 1
            elif hc == x and hy == c:
                out.rows[ROW_THREE_CYCLE] += 1
            elif hc == x and hy == x:
                out.rows[ROW_F2] += 1
            elif hc == c and hy == x:
                out.rows[ROW_F1] += 1
            else:
                raise Error("a first-letter map outside the table")
    return out^


def main() raises:
    var covers = cover_all()
    var failed = 0
    for i in range(len(covers)):
        ref cov = covers[i]
        failed += cov.failed
        print(cov.branch.name, ": cones", cov.cones, " cuts", cov.cuts, " points", cov.points, " (PIP", cov.pip_points, ")  failed", cov.failed)
        for j in range(len(cov.records)):
            ref rec = cov.records[j]
            var free = String("point") if rec.free == FREE_NONE else (String("u") if rec.free == FREE_U else (String("v") if rec.free == FREE_V else String("u,v")))
            if rec.kind == KIND_CONE:
                print("    cone  at (", rec.base[0], ",", rec.base[1], ",", rec.base[2], ") free", free, " witness level", rec.level)
            elif rec.kind == KIND_CUT:
                print("    cut   at (", rec.base[0], ",", rec.base[1], ",", rec.base[2], ") free", free, " f(", rec.cut_at, ") >= 0")
            elif rec.kind == KIND_POINT:
                print("    point (", rec.base[0], ",", rec.base[1], ",", rec.base[2], ")", " coincidence level" if rec.level > 0 else " not PIP", rec.level if rec.level > 0 else 0)
            else:
                print("    FAILED at (", rec.base[0], ",", rec.base[1], ",", rec.base[2], ") free", free)
    var sv = two_odd_survey()
    print("corpus: catch-up-free", sv.catch_up_free, "; one odd letter", sv.one_odd, "; two odd letters", sv.two_odd)
    print("  rows (identity, h(x)=h(c), swap, y-constant, 3-cycle, F2, F1):", sv.rows[0], sv.rows[1], sv.rows[2], sv.rows[3], sv.rows[4], sv.rows[5], sv.rows[6])
    print("  one odd letter (no short image, short sigma(a) with a != o, short sigma(o), two short):", sv.one_rows[0], sv.one_rows[1], sv.one_rows[2], sv.one_rows[3])
    var cc = coverage_check(covers, 10)
    print("coverage at p,q,r <= 10:", cc.pip_members, "PIP members;", cc.in_cones, "in cones,", cc.in_points, "decided points,", cc.in_cuts, "in cuts,", cc.uncovered, "uncovered")
    if failed != 0 or cc.uncovered != 0 or cc.in_cuts != 0:
        raise Error("the swap-family certificate is incomplete")
