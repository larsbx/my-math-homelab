"""Exact regressions for the swap-family certificate (swap_family_certificate)
and the parametric witness paths behind it (psc.cone_witness).

docs/p1a-a1-prime-2026-10-05.md §3d. A witness path certifies a shared tile on
a whole cone at once, by affine identities and coefficient-sign inequalities;
the cover splits each `|det M| = 2` quadrant into such cones, Lemma P1 cuts and
single points decided exactly. These pins fix the cover cell for cell, check
the machinery against a hand-proved lemma (Theorem E's L_D), and check that it
fails closed on a tampered path and on an exhausted search.
"""

from std.testing import assert_equal, assert_false, assert_true
from a1_normal_form_census import C, X, Y, f_at, swap_member
from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from mojo_smoke.claims import require_contract
from psc.cone_witness import (
    ConeFamily,
    Segment,
    WitnessStep,
    aff_const,
    letter_segment,
    run_segment,
    search_witness,
    verify_witness,
    witness_position,
)
from psc.pisot import is_pip
from swap_family_certificate import (
    BranchCover,
    FREE_NONE,
    KIND_CONE,
    KIND_CUT,
    KIND_POINT,
    branches,
    coverage_check,
    cover_all,
    numeric_check,
    two_odd_survey,
)


def _class_d_cone() raises -> ConeFamily:
    """Theorem E's class D on the cone p = q + 1, q >= 1, r >= 2:
    sigma(x) = x y^p c, sigma(c) = c y^q x, sigma(y) = c y^r c, with
    (p, q, r) = (2, 1, 2) + n1 (1, 1, 0) + n2 (0, 0, 1)."""
    var m = 2
    var imgs = List[List[Segment]]()
    var ix = List[Segment]()
    ix.append(letter_segment(m, X))
    ix.append(run_segment(List[Int]([2, 1, 0])))
    ix.append(letter_segment(m, C))
    var ic = List[Segment]()
    ic.append(letter_segment(m, C))
    ic.append(run_segment(List[Int]([1, 1, 0])))
    ic.append(letter_segment(m, X))
    var iy = List[Segment]()
    iy.append(letter_segment(m, C))
    iy.append(run_segment(List[Int]([2, 0, 1])))
    iy.append(letter_segment(m, C))
    imgs.append(ix^)
    imgs.append(ic^)
    imgs.append(iy^)
    return ConeFamily(m, imgs^)


def test_a_witness_path_reproves_lemma_l_d() raises:
    """The search finds a level-2 path on Lemma L_D's cone, it verifies, and at
    every sample point it names position p + 3, which is the lemma's."""
    var fam = _class_d_cone()
    var w = search_witness(fam, X, C, 3, 5)
    assert_true(w.found)
    assert_equal(len(w.steps), 2)
    assert_true(verify_witness(fam, X, C, w.steps))
    for n1 in range(4):
        for n2 in range(4):
            var p = 2 + n1
            assert_equal(witness_position(fam, X, C, w.steps, List[Int]([n1, n2])), p + 3)


def test_the_machinery_fails_closed() raises:
    """A search capped below the witness level finds nothing, which is not a
    verdict; a path with one offset moved, or cut short, does not verify."""
    var fam = _class_d_cone()
    var capped = search_witness(fam, X, C, 3, 1)
    assert_false(capped.found)
    var w = search_witness(fam, X, C, 3, 5)
    var bad = w.steps.copy()
    bad[1].off_a = bad[1].off_a.copy()
    bad[1].off_a[0] += 1
    assert_false(verify_witness(fam, X, C, bad))
    var short = List[WitnessStep]()
    short.append(w.steps[0].copy())
    assert_false(verify_witness(fam, X, C, short))
    assert_false(verify_witness(fam, X, C, List[WitnessStep]()))


def _sum_level(cov: BranchCover, kind: Int) -> Int:
    var s = 0
    for j in range(len(cov.records)):
        if cov.records[j].kind == kind:
            s += cov.records[j].level
    return s


def test_the_cover_closes_every_branch(covers: List[BranchCover]) raises:
    """Twenty branches (ten endings, two planes each, mirrors run directly),
    no failure: 42 certified cones, 6 Lemma P1 cuts, 22 single points of which
    20 are PIP. The per-branch rows are pinned for the five classes; each
    mirror row must equal its class's row."""
    assert_equal(len(covers), 20)
    var cones = List[Int]([1, 3, 3, 3, 3, 3, 1, 1, 2, 1])
    var cuts = List[Int]([0, 0, 0, 0, 0, 0, 0, 0, 1, 2])
    var points = List[Int]([0, 2, 1, 2, 1, 1, 0, 0, 3, 1])
    var pips = List[Int]([0, 2, 1, 2, 1, 1, 0, 0, 3, 0])
    var cone_levels = List[Int]([3, 10, 9, 12, 9, 11, 4, 4, 8, 3])
    var t_cones = 0
    var t_cuts = 0
    var t_points = 0
    var t_pip = 0
    for i in range(20):
        ref cov = covers[i]
        var k = i % 10
        assert_equal(cov.failed, 0)
        assert_equal(cov.cones, cones[k])
        assert_equal(cov.cuts, cuts[k])
        assert_equal(cov.points, points[k])
        assert_equal(cov.pip_points, pips[k])
        assert_equal(_sum_level(cov, KIND_CONE), cone_levels[k])
        t_cones += cov.cones
        t_cuts += cov.cuts
        t_points += cov.points
        t_pip += cov.pip_points
    assert_equal(t_cones, 42)
    assert_equal(t_cuts, 6)
    assert_equal(t_points, 22)
    assert_equal(t_pip, 20)


def test_the_residual_points_are_decided_coincident(covers: List[BranchCover]) raises:
    """The ten PIP points of the five classes, with their exact levels; the
    mirrors carry the same levels at `(q, p, r)`."""
    var want = List[List[Int]]()
    # (branch index, p, q, r, level)
    want.append(List[Int]([1, 0, 1, 0, 4]))
    want.append(List[Int]([1, 0, 2, 1, 4]))
    want.append(List[Int]([2, 1, 0, 2, 5]))
    want.append(List[Int]([3, 1, 0, 0, 6]))
    want.append(List[Int]([3, 2, 0, 1, 5]))
    want.append(List[Int]([4, 1, 0, 2, 4]))
    want.append(List[Int]([5, 1, 0, 0, 5]))
    want.append(List[Int]([8, 0, 1, 0, 7]))
    want.append(List[Int]([8, 0, 1, 1, 6]))
    want.append(List[Int]([8, 0, 1, 2, 6]))
    var found = 0
    for k in range(len(want)):
        for half in range(2):
            ref cov = covers[want[k][0] + 10 * half]
            var p = want[k][1] if half == 0 else want[k][2]
            var q = want[k][2] if half == 0 else want[k][1]
            var hit = False
            for j in range(len(cov.records)):
                ref rec = cov.records[j]
                if rec.kind == KIND_POINT and rec.base == List[Int]([p, q, want[k][3]]):
                    assert_equal(rec.level, want[k][4])
                    hit = True
            assert_true(hit)
            found += 1
    assert_equal(found, 20)


def test_every_cut_is_lemma_p1(covers: List[BranchCover]) raises:
    """A cut region's `f(1)` or `f(-1)` is nonnegative at every sampled point,
    so it holds no PIP member."""
    var checked = 0
    for i in range(len(covers)):
        ref cov = covers[i]
        for j in range(len(cov.records)):
            ref rec = cov.records[j]
            if rec.kind != KIND_CUT:
                continue
            assert_true(rec.free != FREE_NONE)
            var g = cov.branch.gu.copy() if rec.free == 1 else cov.branch.gv.copy()
            for n in range(12):
                var e = cov.branch.ending.copy()
                var sigma = swap_member(rec.base[0] + n * g[0], rec.base[1] + n * g[1], rec.base[2] + n * g[2], e[0], e[1], e[2], e[3])
                var m = Mat3(substitution_incidence(sigma))
                assert_true(f_at(m, rec.cut_at) >= 0)
                assert_false(is_pip(m))
                checked += 1
    assert_equal(checked, 72)


def test_every_cone_names_real_shared_tiles(covers: List[BranchCover]) raises:
    """Independent of the affine argument: instantiate each cone at its
    sample points and check the named position on the actual words."""
    var checks = 0
    for i in range(len(covers)):
        checks += numeric_check(covers[i], 3)
    assert_equal(checks, 246)


def test_coverage_against_the_exact_screen(covers: List[BranchCover]) raises:
    """Every PIP swap member with `|det M| = 2` and `p, q, r <= 10` lies in a
    certified cone or is a decided point; none is in a cut or uncovered."""
    var cc = coverage_check(covers, 10)
    assert_equal(cc.pip_members, 892)
    assert_equal(cc.in_cones, 872)
    assert_equal(cc.in_points, 20)
    assert_equal(cc.in_cuts, 0)
    assert_equal(cc.uncovered, 0)


def test_the_six_excluded_endings_have_no_pip_member() raises:
    """(x,c,x,c), (x,c,c,x): det 0. (c,x,x,x), (c,x,c,c): det in 4Z.
    (c,x,x,c), (c,x,c,x): (1,-1,0) M = -2 (1,-1,0)."""
    var excluded = List[List[Int]]()
    excluded.append(List[Int]([X, C, X, C]))
    excluded.append(List[Int]([X, C, C, X]))
    excluded.append(List[Int]([C, X, X, X]))
    excluded.append(List[Int]([C, X, C, C]))
    excluded.append(List[Int]([C, X, X, C]))
    excluded.append(List[Int]([C, X, C, X]))
    for k in range(len(excluded)):
        var e = excluded[k].copy()
        for p in range(7):
            for q in range(7):
                for r in range(7):
                    var m = Mat3(substitution_incidence(swap_member(p, q, r, e[0], e[1], e[2], e[3])))
                    assert_false(abs(m.det()) == 2 and is_pip(m))
                    if k < 2:
                        assert_equal(m.det(), 0)
                    elif k < 4:
                        assert_equal(m.det() % 4, 0)
                    else:
                        for j in range(3):
                            assert_equal(m.e[j] - m.e[3 + j], -2 * (1 if j == 0 else (-1 if j == 1 else 0)))


def test_the_branch_table_is_the_ten_endings() raises:
    """Five classes, two planes each, and their mirrors: ten distinct endings."""
    var bs = branches()
    assert_equal(len(bs), 20)
    var seen = List[Int]()
    for i in range(len(bs)):
        var e = bs[i].ending.copy()
        var key = 8 * e[0] + 4 * e[1] + 2 * e[2] + e[3]
        var dup = False
        for j in range(len(seen)):
            if seen[j] == key:
                dup = True
        if not dup:
            seen.append(key)
    assert_equal(len(seen), 10)


def test_the_corpus_two_odd_letter_specimens_fit_the_table() raises:
    """All 210 catch-up-free corpus specimens have |det M| = 2 and one odd set;
    18 have one odd letter and 192 two, and those 192 fall into §3c.1's rows:
    30 Theorem E, 90 h(x) = h(c), 36 swap, 12 y-constant, 18 three-cycle,
    6 F2, 0 F1 (F1 needs an image of length at least 4)."""
    var sv = two_odd_survey()
    assert_equal(sv.catch_up_free, 210)
    assert_equal(sv.one_odd, 18)
    assert_equal(sv.two_odd, 192)
    var want = List[Int]([30, 90, 36, 12, 18, 6, 0])
    for k in range(7):
        assert_equal(sv.rows[k], want[k])
    # Proposition O's rows for the 18 with one odd letter: 6 with no image of
    # length one, 12 with a short sigma(a), a != o; none in the open row.
    var want1 = List[Int]([6, 12, 0, 0])
    for k in range(4):
        assert_equal(sv.one_rows[k], want1[k])


def main() raises:
    test_a_witness_path_reproves_lemma_l_d()
    print("[PASS] test_a_witness_path_reproves_lemma_l_d")
    test_the_machinery_fails_closed()
    print("[PASS] test_the_machinery_fails_closed")
    test_the_branch_table_is_the_ten_endings()
    print("[PASS] test_the_branch_table_is_the_ten_endings")
    test_the_six_excluded_endings_have_no_pip_member()
    print("[PASS] test_the_six_excluded_endings_have_no_pip_member")
    test_the_corpus_two_odd_letter_specimens_fit_the_table()
    print("[PASS] test_the_corpus_two_odd_letter_specimens_fit_the_table")
    var covers = cover_all()
    test_the_cover_closes_every_branch(covers)
    print("[PASS] test_the_cover_closes_every_branch")
    test_the_residual_points_are_decided_coincident(covers)
    print("[PASS] test_the_residual_points_are_decided_coincident")
    test_every_cut_is_lemma_p1(covers)
    print("[PASS] test_every_cut_is_lemma_p1")
    test_every_cone_names_real_shared_tiles(covers)
    print("[PASS] test_every_cone_names_real_shared_tiles")
    test_coverage_against_the_exact_screen(covers)
    print("[PASS] test_coverage_against_the_exact_screen")
    require_contract("Swap-family certificate (Theorem H, strong coincidence for {x,c} on sigma(x) = c y^p s_x, sigma(c) = x y^q s_c, sigma(y) = t y^r s_y with |det M| = 2): psc.cone_witness constant-offset witness paths verify by affine identities and coefficient-sign inequalities, reprove Theorem E's L_D at level 2 with position p + 3, and fail closed on a capped search, a moved offset, a truncated or empty path; six endings have no PIP member (two det 0, two det in 4Z, two with eigenvalue -2 on (1,-1,0)); the cover of the twenty plane branches of the ten other endings has no failure and consists of 42 certified cones, 6 Lemma P1 cuts (f(1) or f(-1) >= 0, 72 sampled points, none PIP) and 22 single points, 20 PIP and decided coincident at levels 4 to 7; 246 sampled cone points name real shared tiles; all 892 PIP members with p,q,r <= 10 lie in a cone (872) or are decided points (20); the 210 catch-up-free corpus specimens all have |det M| = 2 and a unique odd set, 18 with one odd letter and 192 with two, sorted into the rows identity 30, h(x) = h(c) 90, swap 36, y-constant 12, three-cycle 18, F2 6, F1 0; of the 18 with one odd letter, 6 have no image of length one and 12 a short sigma(a) with a != o, so none is in the open row of Proposition O, sigma(o) a single letter")
