"""Exact regressions for Theorem K's open family (odd_letter_family_certificate)
and for the opaque segments and many-letter runs of psc.cone_witness.

docs/p1a-a1-prime-2026-10-05.md §3f. The family is sigma(o) = y,
sigma(y) = o w_1 o, sigma(z) = o w_2 o. Lemma Φ1 (w_1 begins with y) and Lemma
Φ2 (w_1 begins with z and the Parikh walks of w_1 and w_2 + e_y cross) name
explicit witness paths; what they leave is the non-crossing pairs, which the
census decides exactly. The delta split (§3g) and the run-shape cover (§3h)
close whole infinite subfamilies. The pattern tree is an exploratory partial cover: its
certified leaves are proofs on whole regions, its open leaves are reported,
and these tests check that no closed leaf mislabels a member.
"""

from std.testing import assert_equal, assert_false, assert_true
from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from mojo_smoke.claims import require_contract
from psc.coincidence_formula import coincidence_level
from psc.cone_witness import aff_const, aff_scale, aff_eval, apply_step, WitnessStep, monotone_paths_meet, Prover, _q_eval, _q_lin, _q_nonneg_under, _qa, search_crossing, search_witness, search_witness_line, verify_crossing, verify_witness, verify_witness_line, witness_position
from std.collections import Dict
from psc.pisot import is_pip
from a1_normal_form_census import f_at, shared_tile_between
from psc.poly_line import lift_path_poly, lifts_to_zero, probe_points, verify_witness_poly, whole_region_lift
from psc.product_lift import full_lift, lift_form, lift_point, mccormick_box_forms
from psc.farkas_lp import farkas_certificate, farkas_refutes, lp_infeasible
from finite_exact.rat_q import Q
from odd_letter_family_certificate import (
    A_RUN,
    A_TAIL,
    A_Z,
    LEAF_CERTIFIED,
    LEAF_CUT,
    LEAF_EMPTY,
    LEAF_FAILED,
    LEAF_NOT_MEMBER,
    O,
    Pattern,
    Y,
    Z,
    any_word,
    cover_family,
    NO_DELTA,
    RunPattern,
    cover_shape,
    pattern_matches,
    refine_pattern,
    cover_pattern,
    common_points,
    residue_members,
    RUN_TREE_SPLITS,
    RUN_TREE_PEEL,
    RUN_TREE_BUDGET,
    crossing,
    delta_census,
    shape_family,
    solve_constraint,
    family_census,
    phi_census,
    family_of,
    identity_subst,
    leaf_index,
    member_sigma,
    concrete_family,
    reveal_census,
    impose_nonneg,
    impose_equal,
    cover_pattern_guided,
    tighten,
    propagate_bounds,
    search_point,
    fm_infeasible,
    fm_bounds,
    zcap_cover,
    mccormick_cut,
    pisot_carve_forms,
    z_floor_forms,
    _aff_times,
    _pattern_starts,
    _step,
    _words,
    LINE_CAP,
    MAX_LEVEL,
    Q_OFFSET_BOUND,
    pattern_family,
    point_subst,
    GuidedRegion,
    _point_search,
    _q_lift_start,
    _with_envelope,
    _assume_empty,
    _value_split,
    _affine_value_split,
    _satisfies,
    _certify_at,
    _lazy_lift,
    _carving_forms,
    _new_forms,
    ShapeCover,
    GUIDED_PEEL_LIMIT,
)


def _count(w: List[Int], letter: Int) -> Int:
    var n = 0
    for k in range(len(w)):
        if w[k] == letter:
            n += 1
    return n


def test_det_is_twice_the_z_difference() raises:
    """The determinant is 2 (Z_1 - Z_2) for every pair of words, so membership forces
    |Z_1 - Z_2| = 1."""
    var words = _words(4)
    for a in range(len(words)):
        for b in range(len(words)):
            var m = Mat3(substitution_incidence(member_sigma(words[a], words[b])))
            assert_equal(m.det(), 2 * (_count(words[a], Z) - _count(words[b], Z)))


def test_crossing_is_the_walk_meeting() raises:
    """`crossing` finds (i, k), i, k >= 1, with pi(w1[:i]) = pi(w2[:k]) + e_y
    exactly when one exists, compared with a brute force over all (i, k)."""
    var words = _words(5)
    for a in range(len(words)):
        for b in range(len(words)):
            ref w1 = words[a]
            ref w2 = words[b]
            var brute = False
            for i in range(1, len(w1) + 1):
                for k in range(1, len(w2) + 1):
                    var dy = 0
                    var dz = 0
                    for j in range(i):
                        dy += 1 if w1[j] == Y else 0
                        dz += 1 if w1[j] == Z else 0
                    for j in range(k):
                        dy -= 1 if w2[j] == Y else 0
                        dz -= 1 if w2[j] == Z else 0
                    if dy == 1 and dz == 0:
                        brute = True
            assert_equal(crossing(w1, w2)[0] >= 0, brute)


def test_the_census_reduces_the_family_to_non_crossing_pairs() raises:
    """|w_1|, |w_2| <= 5: every Lemma Φ1 and Φ2 path verifies and names a
    shared tile of the actual words; the non-crossing members are decided
    coincident, at levels 3 to 6."""
    var c = family_census(5)
    assert_equal(c.members, 532)
    assert_equal(c.lemma_failed, 0)
    assert_equal(c.by_phi1, 274)
    assert_equal(c.by_phi2, 138)
    assert_equal(c.non_crossing, 120)
    assert_equal(c.max_level, 6)
    var total = 0
    for k in range(16):
        total += c.levels[k]
    assert_equal(total, 120)
    assert_equal(c.levels[0] + c.levels[1] + c.levels[2], 0)


def test_an_opaque_cone_proves_lemma_phi1() raises:
    """With w_1 = y^(1+n) z T_1 and w_2 = T_2, T_i opaque words, the search
    finds a level-3 path on the whole region -- every primitive w_1 beginning
    with y -- and it names real shared tiles at sample points."""
    var p1 = Pattern(List[Int]([A_RUN, A_Z, A_TAIL]), List[Int]([1, 0, 0]))
    var p2 = any_word()
    var fam = family_of(p1, p2, identity_subst(5))
    var w = search_witness(fam, O, Y, 3, 6, True)
    assert_true(w.found)
    assert_equal(len(w.steps), 3)
    assert_true(verify_witness(fam, O, Y, w.steps))
    for k in range(6):
        var ns = List[Int](length=5, fill=0)
        if k < 5:
            ns[k] = 2
        var sigma = fam.instantiate(ns)
        var pos = witness_position(fam, O, Y, w.steps, ns)
        assert_true(shared_tile_between(sigma, O, Y, len(w.steps), pos))


def test_the_pattern_tree_is_a_sound_partial_cover() raises:
    """Depth 6: the counts are pinned, open leaves are reported rather than
    covered, and against every PIP member with |w_i| <= 5 no empty, cut or
    non-member leaf holds a member, and a certified leaf's level bounds the
    member's exact level."""
    var cov = cover_family(6, 4)
    assert_equal(cov.certified, 14)
    assert_equal(cov.empty, 8)
    assert_equal(cov.cut, 19)
    assert_equal(cov.not_member, 1)
    assert_equal(cov.failed, 34)
    var words = _words(5)
    var in_certified = 0
    var in_open = 0
    for a in range(len(words)):
        for b in range(len(words)):
            var sigma = member_sigma(words[a], words[b])
            var m = Mat3(substitution_incidence(sigma))
            if abs(m.det()) != 2 or not is_pip(m):
                continue
            var li = leaf_index(cov, words[a], words[b], 6)
            assert_true(li >= 0)
            var kind = cov.leaves[li].kind
            assert_false(kind == LEAF_EMPTY or kind == LEAF_CUT or kind == LEAF_NOT_MEMBER)
            if kind == LEAF_CERTIFIED:
                assert_true(coincidence_level(sigma, O, Y) <= cov.leaves[li].level)
                in_certified += 1
            elif kind == LEAF_FAILED:
                in_open += 1
    assert_equal(in_certified, 413)
    assert_equal(in_open, 119)


def test_lemmas_phi4_and_phi5_hold_on_every_member() raises:
    """Lemma Φ4: Z_1 = Z_2 + 1 forces Y_1 >= Y_2, and Z_1 = Z_2 - 1 forces
    Y_1 <= Y_2 and Z_2 >= 2 (f(-1) = (1 + Z_2)(Y_2 - Y_1 - 1) and
    f(1) = (Z_2 - 1)(Y_1 - Y_2 - 1) respectively). Lemma Φ5: with
    Z_1 = Z_2 + 1, a non-crossing w_1 is u y^(Y_1 - Y_2) with
    pi(u) = pi(w_2) + e_z. Checked on all 2,136 members with |w_i| <= 6."""
    var d = delta_census(6, False)
    assert_equal(d.members, 2136)
    assert_equal(d.sign_violations, 0)
    assert_equal(d.non_crossing, 388)
    assert_equal(d.shape_violations, 0)


def test_lemmas_phi6_to_phi8_close_the_delta_ez_cell() raises:
    """At |w_i| <= 7 every Lemma Φ6, Φ7 or Φ8 path verifies and names a shared
    tile of the words (1,180 of the 1,267 non-crossing members); in the cell
    delta = e_z the only member left is (zz, z), decided at level 6, and the
    word pair (z, empty) is not PIP. The residue of the other cells is
    decided exactly, at levels 3 to 6."""
    var p = phi_census(7)
    assert_equal(p.non_crossing, 1267)
    assert_equal(p.by_lemma, 1180)
    assert_equal(p.lemma_failed, 0)
    assert_equal(p.cell_ez_residue, 1)
    assert_equal(p.residue_levels[3], 38)
    assert_equal(p.residue_levels[4], 42)
    assert_equal(p.residue_levels[5], 6)
    assert_equal(p.residue_levels[6], 1)
    assert_equal(coincidence_level(member_sigma(List[Int]([Z, Z]), List[Int]([Z])), O, Y), 6)
    assert_false(is_pip(Mat3(substitution_incidence(member_sigma(List[Int]([Z]), List[Int]())))))


def _key(v: List[Int]) -> String:
    var out = String("")
    for k in range(len(v)):
        out += String(v[k]) + ","
    return out


def test_the_constraint_substitutions_partition_the_solutions() raises:
    """The equation sum_pos n - sum_neg n = target over n >= 0: the regions solve_constraint
    returns hit every solution in a box exactly once, for several targets."""
    var pos = List[Int]([0, 2])
    var neg = List[Int]([1, 3])
    var box = 5
    for target in range(-3, 4):
        var regions = solve_constraint(identity_subst(4), pos, neg, target)
        var hits = Dict[String, Int]()
        for r in range(len(regions)):
            ref f = regions[r]
            for idx in range(1296):  # 6^4 points of the free variables
                var ns = List[Int]()
                var rest = idx
                var dead_moved = False
                for j in range(4):
                    ns.append(rest % 6)
                    rest //= 6
                    var live = False
                    for k in range(4):
                        if f[k][j + 1] != 0:
                            live = True
                    if not live and ns[j] != 0:
                        dead_moved = True
                if dead_moved:
                    continue  # a variable the region fixed: one representative
                var img = List[Int]()
                var inside = True
                for k in range(4):
                    var v = f[k][0]
                    for j in range(4):
                        v += f[k][j + 1] * ns[j]
                    if v < 0 or v > box:
                        inside = False
                    img.append(v)
                if not inside:
                    continue
                assert_equal(img[0] + img[2] - img[1] - img[3], target)
                var key = _key(img)
                if key in hits:
                    hits[key] = hits[key] + 1
                else:
                    hits[key] = 1
        var solutions = 0
        for idx in range(1296):
            var v = List[Int]()
            var rest = idx
            for _ in range(4):
                v.append(rest % 6)
                rest //= 6
            if v[0] + v[2] - v[1] - v[3] != target:
                continue
            solutions += 1
            var key = _key(v)
            assert_true(key in hits)
        assert_equal(len(hits), solutions)
        for e in hits.items():
            assert_equal(e.value, 1)


def test_the_quadratic_pisot_identities() raises:
    """The identities f(1) = Z_2 (Delta - 1) - 2 Y_2 - Delta - 3 when Z_1 = Z_2 + 1, and
    f(-1) = Z_2 (|Delta| - 1) - 2 Y_1 - |Delta| + 3 when Z_1 = Z_2 - 1, exactly,
    for the substitution with w_1 = y^Y_1 z^Z_1 and w_2 = y^Y_2 z^Z_2."""
    for y2 in range(5):
        for z2 in range(1, 5):
            for d in range(5):
                var w1 = List[Int]()
                var w2 = List[Int]()
                for _ in range(y2 + d):
                    w1.append(Y)
                for _ in range(z2 + 1):
                    w1.append(Z)
                for _ in range(y2):
                    w2.append(Y)
                for _ in range(z2):
                    w2.append(Z)
                var m = Mat3(substitution_incidence(member_sigma(w1, w2)))
                assert_equal(f_at(m, 1), z2 * (d - 1) - 2 * y2 - d - 3)
                var v1 = List[Int]()
                var v2 = List[Int]()
                for _ in range(y2):
                    v1.append(Y)
                for _ in range(z2 - 1):
                    v1.append(Z)
                for _ in range(y2 + d):
                    v2.append(Y)
                for _ in range(z2):
                    v2.append(Z)
                var m2 = Mat3(substitution_incidence(member_sigma(v1, v2)))
                if z2 >= 2:
                    assert_equal(f_at(m2, -1), z2 * (d - 1) - 2 * y2 - d + 3)


def test_line_mode_reaches_offsets_affine_along_the_delta_line() raises:
    """On (z^a y^b, y^(b+1) z^(a+1)) with a = b + 2 + n1, b = 2 + n2 the line
    search finds a path and it verifies on the whole region. That line mode
    is needed somewhere is pinned by test_shape_cells_that_close, whose
    Delta = -1 cell uses it."""
    var subst = List[List[Int]]()
    subst.append(List[Int]([3, 1, 1]))  # a - 1 = b + 1 + n1 = 3 + n1 + n2
    subst.append(List[Int]([1, 0, 1]))  # b - 1 = 1 + n2
    subst.append(List[Int]([2, 0, 1]))  # b + 1 - 1
    subst.append(List[Int]([4, 1, 1]))  # a + 1 - 1
    var fam = shape_family(List[Int]([Z, Y]), List[Int]([Y, Z]), subst)
    var w = search_witness_line(fam, O, Y, 3, 6, Y, Z)
    assert_true(w.found)
    assert_true(verify_witness_line(fam, O, Y, w.steps))


def test_shape_cells_that_close() raises:
    """Whole infinite shape families, every Delta: (zy | ε), (zy | z) and
    (zy | yz) with Z_1 = Z_2 + 1 close with no open region; (zy | yz) with
    Z_1 = Z_2 - 1 closes at Delta = -1 (line mode needed)."""
    var zy = List[Int]([Z, Y])
    var c0 = cover_shape(zy, List[Int](), 1, NO_DELTA, 4)
    assert_equal(c0.open, 0)
    assert_equal(c0.certified, 1)
    for d in range(1, 5):
        var c1 = cover_shape(zy, List[Int]([Z]), 1, d, 4, d == 4)
        assert_equal(c1.open, 0)
        var c2 = cover_shape(zy, List[Int]([Y, Z]), 1, d, 4, d == 4)
        assert_equal(c2.open, 0)
    var c3 = cover_shape(zy, List[Int]([Y, Z]), -1, -1, 4)
    assert_equal(c3.open, 0)
    assert_true(c3.line_certified >= 1)


def test_pattern_refinement_partitions_the_word_pairs() raises:
    """Refining the root z* | * three times over: every word pair with w_1
    beginning with z, both words of length <= 5, lies in exactly one leaf."""
    var leaves = List[RunPattern]()
    var frontier = List[RunPattern]()
    frontier.append(RunPattern(List[Int]([Z]), True, List[Int](), True))
    for _ in range(4):
        var nxt = List[RunPattern]()
        for k in range(len(frontier)):
            var kids = refine_pattern(frontier[k])
            if len(kids) == 0:
                leaves.append(frontier[k].copy())
            for j in range(len(kids)):
                nxt.append(kids[j].copy())
        frontier = nxt^
    for k in range(len(frontier)):
        leaves.append(frontier[k].copy())
    var words = _words(5)
    var pairs = 0
    for a in range(len(words)):
        if len(words[a]) == 0 or words[a][0] != Z:
            continue
        for b in range(len(words)):
            var hits = 0
            for k in range(len(leaves)):
                if pattern_matches(leaves[k], words[a], words[b]):
                    hits += 1
            assert_equal(hits, 1)
            pairs += 1
    assert_equal(pairs, 31 * 63)


def test_run_patterns_with_a_tail_close() raises:
    """Induction on runs, cell Z_1 = Z_2 + 1, Delta = 1 (Theorem Xi): the nine
    closed leaves of the cell's run tree close with no open region; those with
    an opaque tail are infinite families with unboundedly many runs."""
    var zy = List[Int]([Z, Y])
    var cases = List[RunPattern]()
    cases.append(RunPattern(zy.copy(), False, zy.copy(), True))
    cases.append(RunPattern(zy.copy(), False, List[Int]([Y, Z]), True))
    cases.append(RunPattern(zy.copy(), True, List[Int]([Z]), False))
    cases.append(RunPattern(zy.copy(), True, List[Int]([Y]), False))
    cases.append(RunPattern(List[Int]([Z, Y, Z]), True, zy.copy(), False))
    cases.append(RunPattern(List[Int]([Z, Y, Z]), True, List[Int]([Y, Z]), False))
    for k in range(len(cases)):
        var c = cover_pattern(cases[k], 1, 1, RUN_TREE_SPLITS, False, RUN_TREE_PEEL, RUN_TREE_BUDGET)
        assert_equal(c.open, 0)
        assert_true(c.certified >= 1)
    # The rest of the cell's closed leaves: no member, or one point decided.
    var rest = List[RunPattern]()
    rest.append(RunPattern(List[Int]([Z]), False, List[Int]([Z]), True))
    rest.append(RunPattern(List[Int]([Z]), False, List[Int]([Y]), True))
    rest.append(RunPattern(List[Int]([Z]), True, List[Int](), False))
    for k in range(len(rest)):
        assert_equal(cover_pattern(rest[k], 1, 1, RUN_TREE_SPLITS, False, RUN_TREE_PEEL, RUN_TREE_BUDGET).open, 0)
    # Negative control: the doubly open pattern is not closed at this budget.
    var both = cover_pattern(RunPattern(zy.copy(), True, zy.copy(), True), 1, 1, RUN_TREE_SPLITS, False, RUN_TREE_PEEL, RUN_TREE_BUDGET)
    assert_true(both.open > 0)


def _parikh_yz(w: List[Int], n: Int) -> List[Int]:
    var out = List[Int]([0, 0])
    for k in range(n):
        out[0 if w[k] == Y else 1] += 1
    return out^


def test_the_residue_is_mostly_one_excursion() raises:
    """Common points agree with their definition, and of the 87 residual
    members at |w_i| <= 7, 51 have only the start point t = 1: their walks
    separate at once and meet no more."""
    var words = _words(4)
    for a in range(len(words)):
        for b in range(len(words)):
            var n = 0
            for t in range(1, len(words[a])):
                if t > len(words[b]):
                    break
                var p1 = _parikh_yz(words[a], t)
                var p2 = _parikh_yz(words[b], t - 1)
                if p1[0] == p2[0] and p1[1] == p2[1] + 1:
                    n += 1
            assert_equal(common_points(words[a], words[b]), n)
    var residue = residue_members(7)
    assert_equal(len(residue), 87)
    var hist = List[Int](length=8, fill=0)
    for k in range(len(residue)):
        hist[common_points(residue[k].w1, residue[k].w2)] += 1
    assert_equal(hist[0], 6)
    assert_equal(hist[1], 51)
    assert_equal(hist[2], 22)
    assert_equal(hist[3] + hist[4] + hist[5], 8)


def _path(start: List[Int], w: List[Int]) -> List[List[Int]]:
    """The monotone lattice path of `w` from `start`, coordinates (y, z)."""
    var out = List[List[Int]]()
    out.append(start.copy())
    for k in range(len(w)):
        var p = out[k].copy()
        p[0 if w[k] == Y else 1] += 1
        out.append(p^)
    return out^


def _first_meeting(pp: List[List[Int]], qq: List[List[Int]]) -> Int:
    """Least level at which the two paths share a point, or -1."""
    var best = -1
    for i in range(len(pp)):
        for k in range(len(qq)):
            if pp[i][0] == qq[k][0] and pp[i][1] == qq[k][1]:
                var n = pp[i][0] + pp[i][1]
                if best < 0 or n < best:
                    best = n
    return best


def test_lemma_x_on_every_small_pair_of_monotone_paths() raises:
    """Lemma X by brute force against psc.cone_witness.monotone_paths_meet: for every
    pair of monotone paths of at most 4 steps, Q starting in a box around P's
    start, Q starting weakly on one side of P and ending strictly on the other
    forces a shared point before the last common level; with a weak end, at or
    before it. A weak end alone can leave the only shared point at the last
    common level -- the negative control for strictness at a word's end."""
    var words = _words(4)
    var strict_cases = 0
    var weak_only_at_end = 0
    for a in range(len(words)):
        var pp = _path(List[Int]([0, 0]), words[a])
        ref p0 = pp[0]
        ref p1 = pp[len(pp) - 1]
        for b in range(len(words)):
            for qy in range(-2, 3):
                for qz in range(-2, 3):
                    var qq = _path(List[Int]([qy, qz]), words[b])
                    ref q0 = qq[0]
                    ref q1 = qq[len(qq) - 1]
                    var nlo = max(p0[0] + p0[1], q0[0] + q0[1])
                    var nhi = min(p1[0] + p1[1], q1[0] + q1[1])
                    if nlo > nhi:
                        continue
                    var strict = monotone_paths_meet(p0, p1, q0, q1, False)
                    var weak = monotone_paths_meet(p0, p1, q0, q1, True)
                    var meet = _first_meeting(pp, qq)
                    if strict:
                        strict_cases += 1
                        assert_true(meet >= nlo and meet < nhi)
                    if weak:
                        assert_true(meet >= nlo and meet <= nhi)
                        if meet == nhi and not strict:
                            weak_only_at_end += 1
    assert_true(strict_cases > 1000)
    assert_true(weak_only_at_end > 0)


def test_crossing_closures_are_shared_tiles() raises:
    """Wherever the cone search closes a residual member by Lemma X, the exact
    decider finds the shared tile within two levels of the path's end; on the
    87 residual members at |w_i| <= 7 every one but (zz, z) closes this way."""
    var res = residue_members(7)
    var closed = 0
    for r in range(len(res)):
        ref m = res[r]
        var sigma = member_sigma(m.w1, m.w2)
        var fam = concrete_family(sigma)
        var c = search_crossing(fam, O, Y, 12, 4, Y, Z, Y, Z)
        if not c.found:
            assert_equal(len(m.w1), 2)
            continue
        assert_true(verify_crossing(fam, O, Y, c.steps, c.close[0], Y, Z))
        var lev = coincidence_level(sigma, O, Y)
        assert_true(lev >= 0 and lev <= len(c.steps) + 2)
        closed += 1
    assert_equal(closed, 86)


def test_lemma_phi5_prime_the_short_suffix_of_w2() raises:
    """Lemma Phi5': with Z_2 = Z_1 + 1 and the walks not crossing, Delta <= 0,
    |w_2| = |w_1| + 1 - Delta, and the suffix of w_2 after its first
    |w_1| - 1 letters holds at least two z; on every member with |w_i| <= 7."""
    var words = _words(7)
    var checked = 0
    for a in range(len(words)):
        ref w1 = words[a]
        if len(w1) < 2 or w1[0] != Z:
            continue
        for b in range(len(words)):
            ref w2 = words[b]
            if _count(w2, Z) != _count(w1, Z) + 1 or crossing(w1, w2)[0] >= 0:
                continue
            if not is_pip(Mat3(substitution_incidence(member_sigma(w1, w2)))):
                continue
            var dy = _count(w1, Y) - _count(w2, Y)
            assert_true(dy <= 0)
            assert_equal(len(w2), len(w1) + 1 - dy)
            var zs = 0
            for k in range(len(w1) - 1, len(w2)):
                zs += 1 if w2[k] == Z else 0
            assert_true(zs >= 2)
            checked += 1
    assert_true(checked > 100)


def test_reveal_census_needs_at_most_two_runs_to_length_7() raises:
    """With the suffix of Lemma Phi5 / Phi5', the synchronized and lagged
    cuts, every non-crossing PIP member whose longer word has length 5, 6 or
    7 has a Lemma X certificate reading at most its first two runs."""
    var h5 = reveal_census(5, 6, 8)
    assert_equal(h5[0], 0)
    assert_equal(h5[1], 77)
    assert_equal(h5[2], 4)
    var h6 = reveal_census(6, 6, 8)
    assert_equal(h6[1], 255)
    assert_equal(h6[2], 13)
    var h7 = reveal_census(7, 6, 8)
    assert_equal(h7[0], 0)
    assert_equal(h7[1], 825)
    assert_equal(h7[2], 54)
    for r in range(3, len(h7)):
        assert_equal(h7[r], 0)


def test_cover_pattern_closes_regions_by_lemma_x() raises:
    """On the doubly open pattern zyz* y^Delta | zyz* (Lemma Phi5 suffix,
    Delta = 1) the cone search certifies regions by Lemma X, each verified on
    the whole region (a failed verification raises)."""
    var zyz = List[Int]([Z, Y, Z])
    var c = cover_pattern(RunPattern(zyz.copy(), True, zyz.copy(), True, List[Int]([Y])), 1, 1, RUN_TREE_SPLITS, False, RUN_TREE_PEEL, 100)
    assert_true(c.crossing_certified >= 1)


def _live_vars(forms: List[List[Int]], m: Int) -> List[Int]:
    var out = List[Int]()
    for k in range(m):
        for i in range(len(forms)):
            if forms[i][k + 1] != 0:
                out.append(k)
                break
    return out^


def test_impose_nonneg_partitions_exactly() raises:
    """For every form a_0 + a_1 n_1 + a_2 n_2 with a_0 in -4..4 and a_1, a_2 in
    -3..3, the regions of impose_nonneg hit each point of the box [0, 5]^2 with
    F >= 0 exactly once, never a point with F < 0, and carry F with
    nonnegative coefficients."""
    var B = 5
    for a0 in range(-4, 5):
        for a1 in range(-3, 4):
            for a2 in range(-3, 4):
                var F = List[Int]([a0, a1, a2])
                var forms = identity_subst(2)
                forms.append(F.copy())
                var regs = impose_nonneg(forms, 2)
                var hits = List[Int](length=(B + 1) * (B + 1), fill=0)
                for r in range(len(regs)):
                    ref g = regs[r]
                    for k in range(len(g[2])):
                        assert_true(g[2][k] >= 0)
                    var lv = _live_vars(g, 2)
                    var span = 1
                    for _ in range(len(lv)):
                        span *= 3 * B + 1
                    for code in range(span):
                        var ns = List[Int](length=2, fill=0)
                        var x = code
                        for j in range(len(lv)):
                            ns[lv[j]] = x % (3 * B + 1)
                            x //= 3 * B + 1
                        var p0 = aff_eval(g[0], ns)
                        var p1 = aff_eval(g[1], ns)
                        assert_true(a0 + a1 * p0 + a2 * p1 >= 0)
                        if p0 <= B and p1 <= B:
                            hits[p0 * (B + 1) + p1] += 1
                for p0 in range(B + 1):
                    for p1 in range(B + 1):
                        var want = 1 if a0 + a1 * p0 + a2 * p1 >= 0 else 0
                        assert_equal(hits[p0 * (B + 1) + p1], want)


def test_guided_partition_closes_a_doubly_open_pattern() raises:
    """zy* y | zy* in the cell Z_1 = Z_2 + 1, Delta = 1 (Lemma Phi5 suffix):
    both words keep an opaque tail, the blind cover leaves regions open, and
    the certificate-guided partition closes it -- every carved region checked
    again by the ordinary verifier."""
    var zy = List[Int]([Z, Y])
    var c = cover_pattern_guided(RunPattern(zy.copy(), True, zy.copy(), True, List[Int]([Y])), 1, 1, 2000)
    assert_equal(c.open, 0)
    assert_false(c.budget_exhausted)
    assert_true(c.certified >= 50)


def test_impose_equal_partitions_exactly() raises:
    """For every form E = a_0 + a_1 n_1 + a_2 n_2 with a_0 in -4..4 and
    a_1, a_2 in -2..2, the regions of impose_equal hit each point of the box
    [0, 6]^2 with E = 0 exactly once and no other point."""
    var B = 6
    for a0 in range(-4, 5):
        for a1 in range(-2, 3):
            for a2 in range(-2, 3):
                var forms = identity_subst(2)
                forms.append(List[Int]([a0, a1, a2]))
                var regs = impose_equal(forms, 2)
                var hits = List[Int](length=(B + 1) * (B + 1), fill=0)
                for r in range(len(regs)):
                    ref g = regs[r]
                    var lv = _live_vars(g, 2)
                    var span = 1
                    for _ in range(len(lv)):
                        span *= 3 * B + 1
                    for code in range(span):
                        var ns = List[Int](length=2, fill=0)
                        var x = code
                        for j in range(len(lv)):
                            ns[lv[j]] = x % (3 * B + 1)
                            x //= 3 * B + 1
                        var p0 = aff_eval(g[0], ns)
                        var p1 = aff_eval(g[1], ns)
                        assert_equal(a0 + a1 * p0 + a2 * p1, 0)
                        if p0 <= B and p1 <= B:
                            hits[p0 * (B + 1) + p1] += 1
                for p0 in range(B + 1):
                    for p1 in range(B + 1):
                        var want = 1 if a0 + a1 * p0 + a2 * p1 == 0 else 0
                        assert_equal(hits[p0 * (B + 1) + p1], want)


def _small_forms(c_lo: Int, c_hi: Int, a: Int) -> List[List[Int]]:
    var out = List[List[Int]]()
    for c in range(c_lo, c_hi + 1):
        for a1 in range(-a, a + 1):
            for a2 in range(-a, a + 1):
                out.append(List[Int]([c, a1, a2]))
    return out^


def test_tighten_keeps_the_integer_points() raises:
    """tighten(F) >= 0 exactly where F >= 0 on the box [0, 6]^2, for every
    F = a_0 + a_1 n_1 + a_2 n_2 with a_0 in -6..6 and a_1, a_2 in -3..3."""
    var forms = _small_forms(-6, 6, 3)
    for k in range(len(forms)):
        var t = tighten(forms[k])
        for p0 in range(7):
            for p1 in range(7):
                var ns = List[Int]([p0, p1])
                assert_equal(aff_eval(forms[k], ns) >= 0, aff_eval(t, ns) >= 0)


def test_the_prover_is_sound_on_its_regions() raises:
    """Whenever the prover shows F >= 0 (affine) or Q >= 0 (Q = U V + W)
    under one or two assumptions, F or Q is >= 0 at every point of the box
    [0, 5]^2 where the assumptions hold; with no assumptions it is the
    coefficient-sign test, and it proves an assumption, twice an
    assumption, and an assumption's tightening's source."""
    var assume = _small_forms(-1, 1, 1)
    var targets = _small_forms(-2, 2, 2)
    var proved = 0
    for i in range(len(assume)):
        for j in range(i, len(assume)):
            var pv = Prover(List[List[Int]]([assume[i].copy(), assume[j].copy()]))
            for k in range(len(targets)):
                var q = _q_lin(_aff_times(assume[i], targets[k]), _qa(targets[(7 * k + 3) % len(targets)]), 1)
                var aff_ok = pv.nonneg(targets[k])
                var q_ok = _q_nonneg_under(q, pv)
                if aff_ok:
                    proved += 1
                for p0 in range(6):
                    for p1 in range(6):
                        var ns = List[Int]([p0, p1])
                        if aff_eval(assume[i], ns) < 0 or aff_eval(assume[j], ns) < 0:
                            continue
                        if aff_ok:
                            assert_true(aff_eval(targets[k], ns) >= 0)
                        if q_ok:
                            assert_true(_q_eval(q, ns) >= 0)
    assert_true(proved > 10000)
    assert_true(Prover().nonneg(List[Int]([0, 1, 2])))
    assert_false(Prover().nonneg(List[Int]([1, -1, 2])))
    var a = List[Int]([-3, 2, -4])
    var pv = Prover(List[List[Int]]([tighten(a)]))
    assert_true(pv.nonneg(a))
    assert_true(pv.nonneg(List[Int]([-4, 3, -4])))
    assert_true(Prover(List[List[Int]]([a.copy()])).nonneg(List[Int]([-6, 4, -8])))
    assert_true(Prover(List[List[Int]]([a.copy(), List[Int]([3, -2, 4])])).vanishes(a))


def test_mccormick_quadrants_hold_no_pip_member() raises:
    """For s = +1 and s = -1, a two-parameter family of counts (Y_1, Z_1,
    Y_2, Z_2) and every point p of [0, 6]^2 where Lemma P1's f >= 0: the
    quadrant G_1, G_2, G_3 >= 0 of pisot_carve_forms contains p, mccormick_cut
    accepts it under its tightened forms, and f >= 0 at every box point in it."""
    var carved = 0
    for s in [1, -1]:
        var counts = List[List[Int]]()
        if s == 1:
            # Y_1 = Y_2 + 1 + n_1, Z_1 = Z_2 + 1, Y_2 = n_2, Z_2 = 1 + n_1 + n_2
            counts.append(List[Int]([1, 1, 1]))
            counts.append(List[Int]([2, 1, 1]))
            counts.append(List[Int]([0, 0, 1]))
            counts.append(List[Int]([1, 1, 1]))
        else:
            # Y_1 = n_2, Z_1 = Z_2 - 1, Y_2 = Y_1 + 1 + n_1, Z_2 = 2 + n_1 + n_2
            counts.append(List[Int]([0, 0, 1]))
            counts.append(List[Int]([1, 1, 1]))
            counts.append(List[Int]([1, 1, 1]))
            counts.append(List[Int]([2, 1, 1]))
        for p0 in range(7):
            for p1 in range(7):
                var ns = List[Int]([p0, p1])
                var g = pisot_carve_forms(counts, s, ns)
                if len(g) == 0:
                    continue
                carved += 1
                var tight = List[List[Int]]()
                for k in range(3):
                    assert_true(aff_eval(g[k], ns) >= 0)
                    tight.append(tighten(g[k]))
                assert_true(mccormick_cut(counts, s, g, Prover(tight^)))
                for r0 in range(7):
                    for r1 in range(7):
                        var rs = List[Int]([r0, r1])
                        if aff_eval(g[0], rs) < 0 or aff_eval(g[1], rs) < 0 or aff_eval(g[2], rs) < 0:
                            continue
                        var z2 = aff_eval(counts[3], rs)
                        var d = aff_eval(counts[0], rs) - aff_eval(counts[2], rs)
                        var f = z2 * (d - 1) - 2 * aff_eval(counts[2], rs) - d - 3 if s == 1 else z2 * (-d - 1) - 2 * aff_eval(counts[0], rs) + d + 3
                        assert_true(f >= 0)
    assert_true(carved > 20)


def test_z_floor_forms_keep_every_pip_member() raises:
    """For s = +1 (Y_2 = n_1, Z_2 = n_2, Delta = 2 + n_3) and s = -1 (Y_1 =
    n_1, Z_2 = n_2, Delta = -2 - n_3) and floors 2..5: every point of
    [0, 9]^3 with Z_2 >= floor and Lemma P1's f <= -1 satisfies the three
    z_floor_forms, and the linear region is strictly larger (it holds points
    with f >= 0), so a cover of it proves more than the PIP claim needs."""
    var relaxed = 0
    for s in [1, -1]:
        var counts = List[List[Int]]()
        if s == 1:
            counts.append(List[Int]([2, 1, 0, 1]))
            counts.append(List[Int]([1, 0, 1, 0]))
            counts.append(List[Int]([0, 1, 0, 0]))
            counts.append(List[Int]([0, 0, 1, 0]))
        else:
            counts.append(List[Int]([0, 1, 0, 0]))
            counts.append(List[Int]([-1, 0, 1, 0]))
            counts.append(List[Int]([2, 1, 0, 1]))
            counts.append(List[Int]([0, 0, 1, 0]))
        for floor in range(2, 6):
            var g = z_floor_forms(counts, s, floor)
            assert_equal(len(g), 3)
            for a in range(10):
                for b in range(10):
                    for c in range(10):
                        var ns = List[Int]([a, b, c])
                        var z2 = aff_eval(counts[3], ns)
                        if z2 < floor or (s == -1 and z2 < 1):
                            continue
                        var d = aff_eval(counts[0], ns) - aff_eval(counts[2], ns)
                        var f = z2 * (d - 1) - 2 * aff_eval(counts[2], ns) - d - 3 if s == 1 else z2 * (-d - 1) - 2 * aff_eval(counts[0], ns) + d + 3
                        var inside = aff_eval(g[0], ns) >= 0 and aff_eval(g[1], ns) >= 0 and aff_eval(g[2], ns) >= 0
                        if f <= -1:
                            assert_true(inside)
                        elif inside:
                            relaxed += 1
    assert_true(relaxed > 0)


def test_bound_propagation_is_exact_on_integers() raises:
    """For systems of three forms a_0 + a_1 n_1 + a_2 n_2 (a_0 in -3..3,
    a_1, a_2 in -2..2; a deterministic stride through the triples), every
    point of [0, 8]^2 satisfying the system lies in the propagated box, and
    a system declared empty has no such point; some systems are empty only
    through three forms at once. search_point returns only satisfying points,
    finds one whenever [0, 7]^2 holds one, and declares empty only systems
    without a point; it proves a system empty that propagation does not."""
    var forms = _small_forms(-3, 3, 2)
    var n = len(forms)
    var empties = 0
    for i in range(0, n, 3):
        for j in range(i, n, 5):
            for k in range(j, n, 7):
                var sys = List[List[Int]]([forms[i].copy(), forms[j].copy(), forms[k].copy()])
                var box = propagate_bounds(sys, 2)
                if box.empty:
                    empties += 1
                var search = search_point(sys, 2)
                var found = search.point.copy()
                if search.empty:
                    assert_true(len(found) == 0)
                if len(found) > 0:
                    assert_true(aff_eval(sys[0], found) >= 0 and aff_eval(sys[1], found) >= 0 and aff_eval(sys[2], found) >= 0)
                for p0 in range(9):
                    for p1 in range(9):
                        var ns = List[Int]([p0, p1])
                        if aff_eval(sys[0], ns) < 0 or aff_eval(sys[1], ns) < 0 or aff_eval(sys[2], ns) < 0:
                            continue
                        assert_false(box.empty)
                        assert_false(search.empty)
                        if p0 < 8 and p1 < 8:
                            assert_true(len(found) > 0)
                        for t in range(2):
                            assert_true(ns[t] >= box.lo[t])
                            if box.bounded[t]:
                                assert_true(ns[t] <= box.hi[t])
    assert_true(empties > 100)
    # n_1 <= 0, n_2 <= 1 - n_1, n_2 >= 3 + n_1 - n_1: empty only via all three
    var three = List[List[Int]]([List[Int]([0, -1, 0]), List[Int]([1, -1, -1]), List[Int]([-3, 1, 1])])
    assert_true(propagate_bounds(three, 2).empty)
    # n_1 + n_2 = 1 and n_1 = n_2: the bounds [0, 1] never cross, but no
    # integer point exists; the exhaustive search proves it
    var half = List[List[Int]]([List[Int]([-1, 1, 1]), List[Int]([1, -1, -1]), List[Int]([0, 1, -1]), List[Int]([0, -1, 1])])
    assert_false(propagate_bounds(half, 2).empty)
    assert_true(search_point(half, 2).empty)


def test_bounded_z2_closes_for_every_delta() raises:
    """With Z_2 bounded, the tail is finitely many fully revealed run
    patterns symbolic in Delta: for s = +1, Z_2 <= 1, all 24 patterns close
    (every Delta >= 1); for s = -1, Z_2 <= 2, all 20 (every Delta <= 0)."""
    var p = zcap_cover(1, 1, 5000)
    assert_equal(p.patterns, 24)
    assert_equal(p.closed, 24)
    var m = zcap_cover(-1, 2, 5000)
    assert_equal(m.patterns, 20)
    assert_equal(m.closed, 20)


def test_fourier_motzkin_is_sound() raises:
    """fm_infeasible declares empty only systems without an integer point:
    for a stride of three-form systems over three variables (constants
    -3..3, coefficients -1..1), none declared infeasible has a point in
    [0, 6]^3; and it refutes x_1 >= x_0 + 6, x_2 >= 1, x_1 + x_2 <= x_0 + 6
    (sum -1), which bound propagation cannot, x_0 being unbounded; and
    fm_bounds, the projection on one variable, keeps every point in its
    interval."""
    var forms = List[List[Int]]()
    for c in range(-3, 4):
        for a in range(-1, 2):
            for b in range(-1, 2):
                for d in range(-1, 2):
                    forms.append(List[Int]([c, a, b, d]))
    var n = len(forms)
    var refuted = 0
    for i in range(0, n, 5):
        for j in range(i, n, 7):
            for k in range(j, n, 11):
                var sys = List[List[Int]]([forms[i].copy(), forms[j].copy(), forms[k].copy()])
                # projected bounds hold at every point of the box in the region
                for v in range(3):
                    var b = fm_bounds(sys, 3, v)
                    for x in range(7):
                        for y in range(7):
                            for z in range(7):
                                var q = List[Int]([x, y, z])
                                if aff_eval(sys[0], q) >= 0 and aff_eval(sys[1], q) >= 0 and aff_eval(sys[2], q) >= 0:
                                    assert_false(b.empty)
                                    assert_true(q[v] >= b.lo[0])
                                    if b.bounded[0]:
                                        assert_true(q[v] <= b.hi[0])
                if not fm_infeasible(sys, 3):
                    continue
                refuted += 1
                for x in range(7):
                    for y in range(7):
                        for z in range(7):
                            var p = List[Int]([x, y, z])
                            assert_false(aff_eval(sys[0], p) >= 0 and aff_eval(sys[1], p) >= 0 and aff_eval(sys[2], p) >= 0)
    assert_true(refuted > 100)
    var wedge = List[List[Int]]([List[Int]([-6, -1, 1, 0]), List[Int]([-1, 0, 0, 1]), List[Int]([6, 1, -1, -1])])
    assert_false(propagate_bounds(wedge, 3).empty)
    assert_true(fm_infeasible(wedge, 3))


def test_the_real_point_search_is_exact() raises:
    """_point_search on lifted systems over (n, q), q_j = n_j e (2 and 3
    run variables, the last the tail e; 2-4 forms with constants in -3..3
    and coefficients in -1..1 by a seeded LCG, plus e <= 1..3, and on every
    other system n_k <= 4 for the other run variables): a point it returns
    is real and satisfies every form; it finds one whenever a real point
    with n in [0, 6]^m satisfies the system, and on the systems with every
    n bounded it reports empty exactly when none does -- 452 of them only
    because the point must be real (search_point finds a non-real one). A
    hand case: n_0 <= 0 and q_0 >= 1 hold at (0, 0, 1, 0), but at no real
    point."""
    var seed = 20261007
    var found = 0
    var empty = 0
    var real_only = 0
    for mn in [2, 3]:
        var lift = full_lift(mn, mn - 1)
        var w = lift.width()
        for t in range(1500):
            var sys = List[List[Int]]()
            for _ in range(2 + t % 3):
                var f = List[Int]()
                for k in range(w + 1):
                    seed = (seed * 1103515245 + 12345) % 2147483648
                    f.append(seed % 7 - 3 if k == 0 else seed % 3 - 1)
                sys.append(f^)
            var cap = aff_const(w, 1 + t % 3)
            cap[mn] = -1
            sys.append(cap^)
            var bounded = t % 2 == 0
            if bounded:
                for k in range(mn - 1):
                    var f = aff_const(w, 4)
                    f[k + 1] = -1
                    sys.append(f^)
            var ps = _point_search(GuidedRegion(List[List[Int]](), sys.copy(), 0, lift=lift.copy()), w)
            if len(ps.point) > 0:
                found += 1
                assert_false(ps.empty)
                assert_equal(ps.point, lift_point(lift, List[Int](ps.point[:mn])))
                assert_true(_satisfies(sys, ps.point))
            if ps.empty:
                empty += 1
                if len(search_point(sys, w).point) > 0:
                    real_only += 1
            var any = False
            var size = 7 ** mn
            for code in range(size):
                var ns = List[Int]()
                var c = code
                for _ in range(mn):
                    ns.append(c % 7)
                    c //= 7
                if _satisfies(sys, lift_point(lift, ns)):
                    any = True
                    break
            if any:
                assert_true(len(ps.point) > 0)
            elif bounded:
                assert_true(ps.empty)
    assert_equal(List[Int]([found, empty, real_only]), List[Int]([1665, 1313, 452]))
    var lift = full_lift(2, 1)
    var hand = List[List[Int]]([List[Int]([0, -1, 0, 0, 0]), List[Int]([-1, 0, 0, 1, 0]), List[Int]([3, 0, -1, 0, 0])])
    assert_true(_satisfies(hand, List[Int]([0, 0, 1, 0])))
    assert_true(_point_search(GuidedRegion(List[List[Int]](), hand.copy(), 0, lift=lift.copy()), 4).empty)


def test_the_farkas_lp_agrees_with_fourier_motzkin() raises:
    """psc.farkas_lp on 3,000 seeded systems c + A x >= 0, x >= 0 over 3
    variables (3-6 forms, constants -4..4, coefficients -2..2): it finds a
    Farkas certificate exactly when uncapped Fourier-Motzkin finds the
    system empty (1,747 of them), each certificate passes farkas_refutes,
    and no point of [0, 6]^3 satisfies a refuted system; the zero vector and
    a negated certificate fail the check, and a form of the wrong width or
    a multiplier vector not one per form raises. On the 16 forms over (n, q) of a
    region of the zy | yzyz q-lift (n_1, n_3, n_5 live), Fourier-Motzkin
    passes its row cap and claims nothing while a checked certificate
    refutes the polyhedron."""
    var seed = 20261010
    var refuted = 0
    for t in range(3000):
        var sys = List[List[Int]]()
        for _ in range(3 + t % 4):
            var f = List[Int]()
            for k in range(4):
                seed = (seed * 1103515245 + 12345) % 2147483648
                f.append(seed % 9 - 4 if k == 0 else seed % 5 - 2)
            sys.append(f^)
        var y = farkas_certificate(sys, 3)
        assert_equal(len(y) > 0, fm_infeasible(sys, 3))
        if len(y) == 0:
            continue
        refuted += 1
        assert_true(farkas_refutes(sys, 3, y))
        var neg = List[Q]()
        var zero = List[Q]()
        for v in y:
            neg.append(v.neg())
            zero.append(Q.zero())
        assert_false(farkas_refutes(sys, 3, neg))
        assert_false(farkas_refutes(sys, 3, zero))
        for code in range(343):
            assert_false(_satisfies(sys, List[Int]([code % 7, (code // 7) % 7, code // 49])))
    assert_equal(refuted, 1747)
    # a form of the wrong width, or a multiplier vector not one per form, raises
    var one = List[List[Int]]([List[Int]([-1, 1, 0, 0])])
    var wide = List[List[Int]]([List[Int]([-1, 1, 0])])
    var raised = 0
    try:
        _ = farkas_refutes(wide, 3, List[Q]([Q.zero()]))
    except:
        raised += 1
    try:
        _ = farkas_refutes(one, 3, List[Q]())
    except:
        raised += 1
    assert_equal(raised, 2)
    var region = List[List[Int]]([List[Int]([6, 0, 2, 0, -1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-2, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-8, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-13, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([13, 0, -1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-7, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-8, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([15, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([14, 0, -1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-5, 0, -1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([5, 0, 1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-7, 0, -1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([18, 0, 4, 0, -3, 0, -3, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-11, 0, -4, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([11, 0, 4, 0, -2, 0, -3, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-9, 0, -3, 0, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0])])
    assert_false(fm_infeasible(region, 14))
    assert_true(lp_infeasible(region, 14))


def test_the_envelope_refutes_only_regions_without_a_real_point() raises:
    """The q-lift envelope (_with_envelope: McCormick forms on the box and
    the RLT cuts (e - lo_e) g, (hi_e - e) g of every assumption g over n
    alone) against brute force, on 4,000 seeded lifted regions over (n, q),
    q_j = n_j e (2 and 3 run variables, the last the tail e): 2-4 forms over
    n (constants -3..3, coefficients -1..1), one form over (n, q)
    (coefficients -1..1), e >= 1 and, on every other region, e <= 2..4 and
    n_k <= 4. Every real point with n in [0, 6]^m that satisfies the
    region satisfies every envelope form, and a region _assume_empty
    refutes with its envelope has no real point with n in [0, 6]^m (only
    these are checked on the unbounded regions; on the bounded ones, whose
    real points all lie in [0, 6]^m, the check is exhaustive). Of 4,000
    regions 1,378 hold a real point and 2,597 are refuted, 274 of them only
    once the envelope is added; 10 bounded regions without a real point
    are not refuted (the envelope is not complete). A hand case:
    n_0 + n_1 <= 2, q_0 + q_1 >= 3e, e >= 1 has no real point (e (n_0 + n_1)
    >= 3e), its polyhedron and its McCormick box envelope are both feasible,
    and the RLT cut of 2 - n_0 - n_1 refutes it."""
    var seed = 20261008
    var refuted = 0
    var only_with = 0
    var with_point = 0
    var missed = 0
    for mn in [2, 3]:
        var lift = full_lift(mn, mn - 1)
        var w = lift.width()
        for t in range(2000):
            var sys = List[List[Int]]()
            for i in range(3 + t % 3):
                var f = List[Int]()
                for k in range(w + 1):
                    seed = (seed * 1103515245 + 12345) % 2147483648
                    var c = seed % 7 - 3 if k == 0 else seed % 3 - 1
                    # the last form may name products; the others are over n
                    f.append(c if k <= mn or i == 2 + t % 3 else 0)
                sys.append(f^)
            var floor = aff_const(w, -1)
            floor[mn] = 1
            sys.append(floor^)
            var bounded = t % 2 == 0
            if bounded:
                var cap = aff_const(w, 2 + t % 3)
                cap[mn] = -1
                sys.append(cap^)
                for k in range(mn - 1):
                    var f = aff_const(w, 4)
                    f[k + 1] = -1
                    sys.append(f^)
            var reg = GuidedRegion(List[List[Int]](), sys.copy(), 0, lift=lift.copy())
            var env = _with_envelope(reg, w)
            var empty = _assume_empty(env.assume, w)
            if empty:
                refuted += 1
                if not _assume_empty(sys, w):
                    only_with += 1
            var any = False
            for code in range(7 ** mn):
                var ns = List[Int]()
                var c = code
                for _ in range(mn):
                    ns.append(c % 7)
                    c //= 7
                var x = lift_point(lift, ns)
                if _satisfies(sys, x):
                    any = True
                    assert_true(_satisfies(env.assume, x))
            if any:
                with_point += 1
                assert_false(empty)
            elif bounded and not empty:
                missed += 1
    assert_equal(List[Int]([refuted, only_with, with_point, missed]), List[Int]([2597, 274, 1378, 10]))
    var lift = full_lift(3, 2)
    var hand = List[List[Int]]([List[Int]([2, -1, -1, 0, 0, 0, 0]), List[Int]([0, 0, 0, -3, 1, 1, 0]), List[Int]([-1, 0, 0, 1, 0, 0, 0])])
    assert_false(_assume_empty(hand, 6))
    var box = hand.copy()
    box.extend(mccormick_box_forms(lift, List[Int]([0, 0, 1]), List[Int]([2, 2, 0]), List[Bool]([True, True, False])))
    assert_false(_assume_empty(box, 6))
    assert_true(_assume_empty(_with_envelope(GuidedRegion(List[List[Int]](), hand.copy(), 0, lift=lift.copy()), 6).assume, 6))


def test_the_value_split_partitions_the_real_points() raises:
    """_value_split on 2,000 seeded lifted regions over (n, q) (2 and 3
    run variables, the last the tail e; 2-4 forms with constants -3..5 and
    coefficients -1..1, the first over n alone, and e >= 1) whose slots
    are the run variables: when it splits, every piece fixes the same
    variable, each to a distinct value, and a real point with n in [0, 6]^m
    lies in exactly one piece (the variable taking that piece's value) when
    it lies in the region and in none otherwise -- the pieces partition the
    region's real points.
    915 regions are split."""
    var seed = 20261009
    var split = 0
    for mn in [2, 3]:
        var lift = full_lift(mn, mn - 1)
        var w = lift.width()
        var slots = List[List[Int]]()
        for k in range(mn):
            var f = aff_const(w, 0)
            f[k + 1] = 1
            slots.append(f^)
        for t in range(1000):
            var sys = List[List[Int]]()
            for i in range(2 + t % 3):
                var f = List[Int]()
                for k in range(w + 1):
                    seed = (seed * 1103515245 + 12345) % 2147483648
                    var c = seed % 9 - 3 if k == 0 else seed % 3 - 1
                    f.append(c if k <= mn or i > 0 else 0)
                sys.append(f^)
            var floor = aff_const(w, -1)
            floor[mn] = 1
            sys.append(floor^)
            var reg = GuidedRegion(slots.copy(), sys.copy(), 0, lift=lift.copy())
            var pieces = _value_split(reg, w)
            if len(pieces) == 0:
                continue
            split += 1
            # the split variable is the slot each piece makes constant
            var k = -1
            for i in range(mn):
                var fixed = True
                for j in range(1, w + 1):
                    if pieces[0].subst[i][j] != 0:
                        fixed = False
                if fixed:
                    k = i
            assert_true(k >= 0)
            # every piece fixes n_k, each to its own value
            var values = List[Int]()
            for p in pieces:
                for j in range(1, w + 1):
                    assert_equal(p.subst[k][j], 0)
                assert_false(p.subst[k][0] in values)
                values.append(p.subst[k][0])
            for code in range(7 ** mn):
                var ns = List[Int]()
                var c = code
                for _ in range(mn):
                    ns.append(c % 7)
                    c //= 7
                var x = lift_point(lift, ns)
                var hits = 0
                for p in pieces:
                    if p.subst[k][0] == ns[k] and _satisfies(p.assume, x):
                        hits += 1
                assert_equal(hits, 1 if _satisfies(sys, x) else 0)
    assert_equal(split, 915)


def _form_of(text: String, w: Int) raises -> List[Int]:
    """An affine form over `w` variables from its trace text, e.g.
    `-2 +1n0 -3n2` (`_form_str`'s layout)."""
    var f = aff_const(w, 0)
    var parts = text.split(" ")
    f[0] = Int(String(parts[0]))
    for i in range(1, len(parts)):
        var t = String(parts[i])
        var at = t.find("n")
        f[Int(String(t[byte=at + 1 :])) + 1] += Int(String(t[byte=0:at]))
    return f^


def test_the_affine_value_split_partitions_the_real_points() raises:
    """_affine_value_split on 400 seeded lifted regions over (n, q) (2 and
    3 run variables, the last the tail e; 2-3 forms with constants -3..5 and
    coefficients -1..1, and a band c e + a <= n_0 <= c e + a + w with
    c in 0..2, a, w in 0..2) whose slots are the run variables: when it
    splits, every piece substitutes the same n_k := v + c e (one slope c,
    distinct v), and a real point with n in [0, 9]^m lies in exactly one
    piece (n_k - c e taking that piece's v) when it lies in the region and
    in none otherwise -- the pieces partition the region's real points.
    Every region is split (the band bounds n_0 - c e), 137 of them along a
    slope c > 0."""
    var seed = 20261008
    var split = 0
    var sloped = 0
    for mn in [2, 3]:
        var lift = full_lift(mn, mn - 1)
        var w = lift.width()
        var e = mn - 1
        var slots = List[List[Int]]()
        for k in range(mn):
            var f = aff_const(w, 0)
            f[k + 1] = 1
            slots.append(f^)
        for t in range(200):
            var sys = List[List[Int]]()
            for _ in range(2 + t % 2):
                var f = List[Int]()
                for k in range(w + 1):
                    seed = (seed * 1103515245 + 12345) % 2147483648
                    f.append(seed % 9 - 3 if k == 0 else seed % 3 - 1)
                sys.append(f^)
            var c = t % 3
            var a = (t // 3) % 3
            var band = aff_const(w, -a)  # n_0 - c e - a >= 0
            band[1] += 1
            band[e + 1] -= c
            var top = aff_scale(band, -1)  # n_0 - c e - a <= w
            top[0] += (t // 9) % 3
            sys.append(band^)
            sys.append(top^)
            var reg = GuidedRegion(slots.copy(), sys.copy(), 0, lift=lift.copy())
            var pieces = _affine_value_split(reg, w)
            if len(pieces) == 0:
                continue
            split += 1
            # the split variable is the slot each piece makes free of itself
            var k = -1
            for i in range(mn):
                if pieces[0].subst[i][i + 1] == 0:
                    k = i
            assert_true(k >= 0)
            var slope = pieces[0].subst[k][e + 1]
            if slope > 0:
                sloped += 1
            var values = List[Int]()
            for p in pieces:
                for j in range(1, w + 1):
                    assert_equal(p.subst[k][j], slope if j == e + 1 and k != e else 0)
                assert_false(p.subst[k][0] in values)
                values.append(p.subst[k][0])
            for code in range(10**mn):
                var ns = List[Int]()
                var r = code
                for _ in range(mn):
                    ns.append(r % 10)
                    r //= 10
                var x = lift_point(lift, ns)
                var hits = 0
                for p in pieces:
                    if p.subst[k][0] + slope * ns[e] == ns[k] and _satisfies(p.assume, x):
                        hits += 1
                assert_equal(hits, 1 if _satisfies(sys, x) else 0)
    assert_equal(List[Int]([split, sloped]), List[Int]([400, 137]))


def test_the_affine_value_split_refutes_the_zy_yzy_region() raises:
    """The last open region of the q-lift cover of zy | yzy (s = -1,
    Delta <= -2, Z_2 >= 4), rebuilt from its trace: variables n_0..n_5 with
    tail e = n_2 and q_j = n_j e at n_(6+j), slots (n_0, n_1, 5 + n_1 + e -
    n_4, 1 + n_0, n_4, 4 + e) and its 30 traced forms. With its envelope its polyhedron
    has a rational point (no checked Farkas certificate), and _value_split,
    whose probes carry no envelope, bounds no variable. _affine_value_split,
    whose probes carry their envelope, bounds n_0 to the single value 3
    (n_0 >= 4 and n_0 <= 2 each refuted with their envelopes), and the
    piece n_0 := 3 (q_0 := 3 e) with its envelope is refuted by a checked
    Farkas certificate."""
    var src = List[String](["4 +1n2 -1n4", "-6 -5n0 +2n1 -1n2 -1n6", "-2 +1n0", "-8 +4n0 -2n2 +1n6", "-8 +4n1 -2n2 +1n7", "16 +8n2 -4n4 +1n8 -1n10", "-8 +4n0 -2n2 +1n6", "4 -1n0 +1n1 +1n2 -1n4", "4 +6n0 -1n1 +1n2 +1n6", "3 +6n0 -2n1 +1n2 +1n6", "16 -4n0 +4n1 +8n2 -4n4 -1n6 +1n7 +1n8 -1n10", "3 -1n0 +1n2 -1n4", "-2 +1n0 -2n2 +1n6", "-7 +1n1 -7n2 +1n7", "4 +5n2 -1n4 +1n8 -1n10", "-2 +1n0 -2n2 +1n6", "4 -1n0 +1n1 +5n2 -1n4 -1n6 +1n7 +1n8 -1n10", "3 -1n0 +4n2 -1n4 -1n6 +1n8 -1n10", "6 +5n0 -1n1 +1n2 +1n6", "10 -6n0 +1n1 +2n2 -1n4 -1n6", "9 -6n0 +1n1 +2n2 -1n4 -1n6", "-2 +1n0 -1n2 +1n4", "-2 +1n0 -3n2 +1n4 +1n6 -1n8 +1n10", "0 -2n2 +1n6", "0 -8n2 +1n7", "0 +4n2 +1n8 -1n10", "0 -2n2 +1n6", "0 +4n2 -1n6 +1n7 +1n8 -1n10", "0 +3n2 -1n6 +1n8 -1n10", "0 -2n2 +1n6 -1n8 +1n10"])
    var assume = List[List[Int]]()
    for t in src:
        assume.append(_form_of(t, 12))
    var slots = List[List[Int]]()
    for t in ["0 +1n0", "0 +1n1", "5 +1n1 +1n2 -1n4", "1 +1n0", "0 +1n4", "4 +1n2"]:
        slots.append(_form_of(String(t), 12))
    var reg = _with_envelope(GuidedRegion(slots^, assume^, 4, lift=full_lift(6, 2)), 12)
    assert_false(lp_infeasible(reg.assume, 12))
    assert_equal(len(_value_split(reg, 12)), 0)
    var pieces = _affine_value_split(reg, 12)
    assert_equal(len(pieces), 1)
    assert_equal(pieces[0].subst[0], aff_const(12, 3))
    assert_equal(pieces[0].subst[3], aff_const(12, 4))
    assert_true(lp_infeasible(_with_envelope(pieces[0], 12).assume, 12))


def test_the_q_lift_closes_zy_yzy() raises:
    """s = -1, Delta <= -2, Z_2 >= 4: the q-lift cover of zy | yzy closes,
    121 regions (49 certified, 44 by polynomial paths, 2 cut, 59 without a
    real member), none open; its last region is settled by the affine value
    split (test_the_affine_value_split_refutes_the_zy_yzy_region)."""
    var pat = RunPattern(List[Int]([Z, Y]), False, List[Int]([Y, Z, Y]), False)
    var c = cover_pattern_guided(pat, -1, -2, 5000, True, False, z_floor=4, q_lift=True)
    assert_false(c.budget_exhausted)
    assert_equal(List[Int]([c.regions, c.certified, c.poly_certified, c.cut, c.not_member, c.decided, c.open]), List[Int]([121, 49, 44, 2, 59, 0, 0]))


def test_every_zy_yz_member_lies_in_the_q_lift_claim() raises:
    """An independent check of the q-lift closure of zy | yz (s = -1,
    Z_2 = a + 1 >= 4): every PIP non-crossing member w_1 = z^a y^b,
    w_2 = y^(b+2+e) z^(a+1) with 3 <= a <= 9, b < 50, e <= 6 (1,772 of them)
    is a real point of the q-lift's start region -- n = (a-1, b-1, 0, 0, e),
    q_j = n_j e, its slots (a-1, b-1, b+1+e, a, e) -- and the region assumes
    Lemma P1 and the floor as the hand-lifted forms -1 - f(-1) >= 0
    (f(-1) = q_0 + n_0 - 2 n_1 + e + 1) and n_0 - 2 >= 0, which hold there:
    f(-1) of the member's matrix is <= -1 and is the lifted form's value, and
    Z_2 = a + 1 >= 4 -- so the cover's claim reaches it; and the
    members with a <= 7, b <= 8 (39 of them) are decided coincident by
    coincidence_level, independent of every cover step. The cover does not
    report its certified regions, so membership in a certified region is
    not checked here."""
    var pat = RunPattern(List[Int]([Z, Y]), False, List[Int]([Y, Z]), False)
    var start = _q_lift_start(pat, -1, _pattern_starts(pat, -1, -2, True)[0], 4)
    # -1 - f(-1) >= 0 with f(-1) = ae + a - 2b + 2 = q_0 + n_0 - 2 n_1 + e + 1
    # (a = n_0 + 1, b = n_1 + 1, ae = q_0 + e), and Z_2 - 4 = n_0 - 2 >= 0
    var p1 = List[Int]([-2, -1, 2, 0, 0, -1, -1, 0, 0, 0, 0])
    var floor = List[Int]([-2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_true(p1 in start.assume and floor in start.assume)
    var members = 0
    var decided = 0
    for a in range(3, 10):
        for b in range(50):
            for e in range(7):
                var sigma = _zy_yz_member(a, b, e)
                if len(sigma) == 0:
                    continue
                members += 1
                var x = lift_point(start.lift, List[Int]([a - 1, b - 1, 0, 0, e]))
                assert_true(_satisfies(start.assume, x))
                # Lemma P1 and the floor, lifted by hand, hold at x and are assumed
                var fm = f_at(Mat3(substitution_incidence(sigma)), -1)
                assert_true(fm <= -1 and a + 1 >= 4)
                assert_equal(aff_eval(p1, x), -1 - fm)
                assert_equal(aff_eval(floor, x), a + 1 - 4)
                var slots = List[Int]()
                for f in start.subst:
                    slots.append(aff_eval(f, x))
                assert_equal(slots, List[Int]([a - 1, b - 1, b + 1 + e, a, e]))
                if a <= 7 and b <= 8:
                    assert_true(coincidence_level(sigma, O, Y) > 0)
                    decided += 1
    assert_equal(List[Int]([members, decided]), List[Int]([1772, 39]))


def _zy_yz_path(a: Int, b: Int, e: Int, m: Int, t: Int) -> List[WitnessStep]:
    """The four-level path of the s = -1 leaf zy | yz (0-based positions into
    sigma(y) = o z^a y^b o and sigma(z) = o y^(b+2+e) z^(a+1) o):
    (y, z, -e_o) -> (y, z, a e_z - (a+2) e_y) -> (y, y, -4 e_o) -> (y, y, 0)."""
    var k = m + 2 * b - 2 * a - a * e
    return List[WitnessStep]([_step(0, 1), _step(b + 2 + e, b + 3 + e), _step(1 + a + k, 1 + m), _step(a + t + 5, a + t + 1)])


def _zy_yz_member(a: Int, b: Int, e: Int) raises -> List[List[Int]]:
    """sigma for w_1 = z^a y^b, w_2 = y^(b+2+e) z^(a+1) if it is PIP and
    non-crossing (a member of the s = -1 leaf zy | yz), else empty."""
    var w1 = List[Int]()
    var w2 = List[Int]()
    for _ in range(a):
        w1.append(Z)
    for _ in range(b):
        w1.append(Y)
    for _ in range(b + 2 + e):
        w2.append(Y)
    for _ in range(a + 1):
        w2.append(Z)
    var sigma = member_sigma(w1, w2)
    if not is_pip(Mat3(substitution_incidence(sigma))) or crossing(w1, w2)[0] >= 0:
        return List[List[Int]]()
    return sigma^


def _zy_yz_census(a_hi: Int, b_hi: Int, e_hi: Int) raises -> List[Int]:
    """[members, covered] over w_1 = z^a y^b, w_2 = y^(b+2+e) z^(a+1),
    3 <= a <= a_hi, b < b_hi, 0 <= e <= e_hi, PIP and non-crossing. On each
    member the level-2 offset M d = (-4, 2a - 2b + ae, -a) and Lemma P1's
    f(-1) = ae + a - 2b + 2 hold, so the level-3 gap is k - m = 2 - a - f(-1);
    a member is covered when the explicit path verifies for some m, t."""
    var members = 0
    var covered = 0
    for a in range(3, a_hi + 1):
        for b in range(b_hi):
            for e in range(e_hi + 1):
                var sigma = _zy_yz_member(a, b, e)
                if len(sigma) == 0:
                    continue
                var mat = Mat3(substitution_incidence(sigma))
                members += 1
                var d = List[Int]([0, -(a + 2), a])
                var md = List[Int](length=3, fill=0)
                for i in range(3):
                    for j in range(3):
                        md[i] += mat.e[3 * i + j] * d[j]
                assert_equal(md, List[Int]([-4, 2 * a - 2 * b + a * e, -a]))
                var f = f_at(mat, -1)
                assert_equal(f, a * e + a - 2 * b + 2)
                assert_true(f <= -1)
                assert_equal(2 * b - 2 * a - a * e, 2 - a - f)
                var fam = concrete_family(sigma)
                var hit = False
                for m in range(b + 2 + e):
                    var k = m + 2 * b - 2 * a - a * e
                    if k < 0 or k >= b:
                        continue
                    for t in range(3):
                        var steps = _zy_yz_path(a, b, e, m, t)
                        if not verify_witness(fam, O, Y, steps):
                            continue
                        # the level-2 state is (y, z, d)
                        var s1 = apply_step(fam, O, Y, List[Int]([0, 0, 0]), steps[0])
                        var s2 = apply_step(fam, s1.a, s1.b, s1.gamma, steps[1])
                        assert_equal(s1.gamma, List[Int]([-1, 0, 0]))
                        assert_true(s2.a == Y and s2.b == Z)
                        assert_equal(s2.gamma, d)
                        if a + b + e <= 12:
                            assert_true(shared_tile_between(sigma, O, Y, 4, witness_position(fam, O, Y, steps, List[Int]())))
                        hit = True
                        break
                    if hit:
                        break
                if hit:
                    covered += 1
    return List[Int]([members, covered])


def test_the_zy_yz_leaf_path_with_s_minus_one() raises:
    """The s = -1 leaf zy | yz, w_1 = z^a y^b, w_2 = y^(b+2+e) z^(a+1): the
    level-2 offset d = a e_z - (a+2) e_y has M d = (-4, 2a - 2b + ae, -a),
    the level-3 positions k (in y^b) and m (in y^(b+2+e)) need
    k - m = 2 - a - f(-1), and the explicit four-level path verifies exactly
    on 312 of the 1,026 PIP non-crossing members with 3 <= a <= 8, b < 40,
    e <= 5 -- and on 1,134 of 4,913 with a <= 11, b < 80, e <= 8, the
    brute-force figure."""
    assert_equal(_zy_yz_census(8, 40, 5), List[Int]([1026, 312]))
    assert_equal(_zy_yz_census(11, 80, 8), List[Int]([4913, 1134]))


def test_the_q_lift_closes_the_zy_yz_tail_leaf() raises:
    """The s = -1 tail leaf zy | yz (Delta = -2 - e <= -2, Z_2 >= 4) over
    (n, q), q_j = n_j e. At the real point a = 62, b = 436, e = 13 the point
    search with the bound 4 off the line and the line offset free finds the
    zy | yz path (0|1, 0|0), (2|2, 388|0), (2|1, 0|58), (2|2, 4|0); lifted
    with the product coordinates its end offset vanishes on the whole
    region, and verify_witness_poly proves it over (n, q) on its carved
    region but not as a polynomial. The q-lift cover then closes the leaf:
    42 regions, 34 certified (18 by polynomial paths), 1 cut, 8 without a
    real member, none open (104 regions before lifts were chosen by their
    extent and implied equalities substituted eagerly). The default cover
    is unchanged: z_floor alone leaves 1 open region of 16."""
    var pat = RunPattern(List[Int]([Z, Y]), False, List[Int]([Y, Z]), False)
    var starts = _pattern_starts(pat, -1, -2, True)
    assert_equal(len(starts), 1)
    var lift = full_lift(5, 4)
    var sub = List[List[Int]]()
    for i in range(len(starts[0])):
        sub.append(lift_form(lift, starts[0][i]))
    var fam = pattern_family(pat, sub)
    var ns = lift_point(lift, List[Int]([61, 435, 0, 0, 13]))
    var point = pattern_family(pat, point_subst(sub, ns))
    var wp = search_witness_line(point, O, Y, Q_OFFSET_BOUND, MAX_LEVEL, Y, Z, LINE_CAP)
    assert_true(wp.found)
    var want = List[List[Int]]([List[Int]([0, 0, 1, 0]), List[Int]([2, 388, 2, 0]), List[Int]([2, 0, 1, 58]), List[Int]([2, 4, 2, 0])])
    assert_equal(len(wp.steps), len(want))
    for l in range(len(want)):
        assert_equal(List[Int]([wp.steps[l].seg_a, wp.steps[l].off_a[0], wp.steps[l].seg_b, wp.steps[l].off_b[0]]), want[l])
    assert_true(verify_witness_line(point, O, Y, wp.steps))
    var lr = lift_path_poly(fam, point, ns, O, Y, wp.steps, Y, Z, lift, probe_points(ns, lift, List[List[Int]]()))
    assert_true(lr.ok and lr.a == lr.b and lifts_to_zero(lr.gamma, lift))
    var prover = Prover(lr.ineqs.copy())
    assert_true(verify_witness_poly(fam, O, Y, lr.steps, prover, lift))
    assert_false(verify_witness_poly(fam, O, Y, lr.steps, prover))
    var c = cover_pattern_guided(pat, -1, -2, 5000, True, False, z_floor=4, q_lift=True)
    assert_false(c.budget_exhausted)
    assert_equal(c.open, 0)
    assert_equal(List[Int]([c.regions, c.certified, c.poly_certified, c.cut, c.not_member, c.decided]), List[Int]([42, 34, 18, 1, 8, 0]))
    var plain = cover_pattern_guided(pat, -1, -2, 5000, True, False, z_floor=4)
    assert_equal(List[Int]([plain.regions, plain.certified, plain.line_certified, plain.crossing_certified, plain.cut, plain.not_member, plain.open]), List[Int]([16, 6, 4, 1, 2, 3, 1]))


def test_lifts_chosen_by_extent_close_the_s_plus_one_staircases() raises:
    """s = +1, Delta = 2 + e >= 2, Z_2 >= 3, w_1 closing with y^(2+e): the
    q-lift cover over (n, q) closes zy +y^(2+e) | zyzy (17 regions, 9
    certified, 2 by polynomial paths, 1 cut, 6 without a real member) and
    zy +y^(2+e) | yzyz (2 regions, both certified), none open. Before lifts
    were chosen by their extent (lift_key) both climbed a staircase: the
    first lift found pinned a run length (Y_2 for zyzy) to its value at the
    base point, and each carved region was a slice."""
    var zyzy = RunPattern(List[Int]([Z, Y]), False, List[Int]([Z, Y, Z, Y]), False)
    zyzy.tail_run1 = 2
    var c = cover_pattern_guided(zyzy, 1, 2, 5000, True, False, z_floor=3, q_lift=True)
    assert_false(c.budget_exhausted)
    assert_equal(List[Int]([c.regions, c.certified, c.poly_certified, c.cut, c.not_member, c.decided, c.open]), List[Int]([17, 9, 2, 1, 6, 0, 0]))
    var yzyz = RunPattern(List[Int]([Z, Y]), False, List[Int]([Y, Z, Y, Z]), False)
    yzyz.tail_run1 = 2
    c = cover_pattern_guided(yzyz, 1, 2, 5000, True, False, z_floor=3, q_lift=True)
    assert_false(c.budget_exhausted)
    assert_equal(List[Int]([c.regions, c.certified, c.poly_certified, c.cut, c.not_member, c.decided, c.open]), List[Int]([2, 2, 0, 1, 0, 0, 0]))


def test_the_deep_lazy_lift_certifies_a_zy_yzyz_region() raises:
    """A region the zy | yzyz q-lift (s = -1, Delta <= -2, Z_2 >= 4) reported
    open with no certificate (#1198 of the run at 5c43b85: 117 forms over
    (n, q), e = n_2, past the peel limit), at its real base point
    n = (3, 71, 15, 4, 3, 2, 2). With the shared 5,000-node point-path
    enumeration no certificate lifts. The deep lazy lift (_lazy_lift with
    deep, bound 4 off the line) stops at a whole-region lift (its end
    offset lifts to the zero form over (n, q) and its carving forms hold at
    every probe point) whose forms the region implies, so it carves
    nothing, and _certify_at(deep=True) certifies the region by a
    polynomial path pushing no complement, verified on the whole
    polyhedron and at the base point."""
    var pat = RunPattern(List[Int]([Z, Y]), False, List[Int]([Y, Z, Y, Z]), False)
    var subst = List[List[Int]]([List[Int]([0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([5, 0, 1, 1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([4, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])])
    var assume = List[List[Int]]([List[Int]([4, 0, 0, 1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-6, 0, 2, -1, -5, 0, -5, 0, 0, 0, 0, -1, 0, -1, 0]), List[Int]([-2, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-4, 0, 4, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([16, 0, 0, 8, 0, -4, 0, 0, 0, 0, 1, 0, -1, 0, 0]), List[Int]([-8, 0, 0, -2, 4, 0, 4, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([4, 0, 1, 1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([3, 0, 0, 1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-6, 0, 3, -2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([12, 0, 0, 7, 0, -3, 0, 0, 0, 0, 1, 0, -1, 0, 0]), List[Int]([-6, 0, 0, -2, 3, 0, 3, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([12, 0, 3, 7, -3, -3, -3, 0, 0, 1, 1, -1, -1, -1, 0]), List[Int]([9, 0, 0, 6, -3, -3, -3, 0, 0, 0, 1, -1, -1, -1, 0]), List[Int]([7, 0, -1, 1, 6, 0, 6, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([-2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([6, 0, -2, 1, 6, 0, 6, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([4, 0, -2, 1, 6, 0, 6, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([-4, 0, 1, -1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-1, 0, 2, 0, -6, 0, -7, 0, 0, 0, 0, -1, 0, -1, 0]), List[Int]([1, 0, -1, 0, 6, 0, 7, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([0, 0, 1, 0, 0, 0, -7, 0, 0, 0, 0, 0, 0, -1, 0]), List[Int]([-1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-8, 0, 2, -4, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([-2, 0, 0, -1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1, 0]), List[Int]([8, 0, 0, 6, 0, -2, 0, 0, 0, 0, 1, 0, -1, 0, 0]), List[Int]([-4, 0, 0, -2, 2, 0, 2, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([8, 0, 2, 6, -2, -2, -2, 0, 0, 1, 1, -1, -1, -1, 0]), List[Int]([6, 0, 0, 5, -2, -2, -2, 0, 0, 0, 1, -1, -1, -1, 0]), List[Int]([-4, 0, 2, -2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([-8, 0, 2, -6, 2, 0, 2, 0, 0, 1, -1, 1, 0, 1, 0]), List[Int]([-2, 0, 0, -1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1, 0]), List[Int]([1, 0, -2, 1, 6, 0, 6, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([-10, 0, 2, -5, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([-1, 0, 2, -1, -6, 0, -6, 0, 0, 0, 0, -1, 0, -1, 0]), List[Int]([-4, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-20, 0, 1, -3, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-21, 0, 1, -3, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([54, 0, -2, -27, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([4, 0, 0, -4, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0]), List[Int]([8, 0, 0, -4, -2, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]), List[Int]([0, 0, 0, 0, 0, -2, 0, 0, 0, 0, 0, 0, 1, 0, 0]), List[Int]([2, 0, 0, -1, 0, 0, -2, 0, 0, 0, 0, 0, 0, 1, 0]), List[Int]([-8, 0, 0, 2, 0, 2, 0, 0, 0, 0, 1, 0, -1, 0, 0]), List[Int]([4, 0, 0, -2, -2, 0, -2, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([-8, 0, -2, 2, 2, 2, 2, 0, 0, 1, 1, -1, -1, -1, 0]), List[Int]([-6, 0, 0, 1, 2, 2, 2, 0, 0, 0, 1, -1, -1, -1, 0]), List[Int]([4, 0, -2, -2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([8, 0, -2, -2, -2, 0, -2, 0, 0, 1, -1, 1, 0, 1, 0]), List[Int]([2, 0, 0, -1, 0, 0, -2, 0, 0, 0, 0, 0, 0, 1, 0]), List[Int]([8, 0, 0, -4, -2, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]), List[Int]([40, 0, -2, -14, 0, 2, 0, 0, 0, 1, -3, 0, -1, 0, 0]), List[Int]([42, 0, -2, -15, 0, 2, 0, 0, 0, 1, -3, 0, -1, 0, 0]), List[Int]([3, 0, 0, 1, -1, 0, -2, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([6, 0, -2, 1, 5, 0, 12, 0, 0, 0, 0, 1, 0, 2, 0]), List[Int]([-1, 0, 3, 0, -5, -1, -12, 0, 0, 0, 0, -1, 0, -2, 0]), List[Int]([2, 0, 1, 1, -6, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0]), List[Int]([90, 0, -3, -30, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([9, 0, 0, -6, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0]), List[Int]([12, 0, 0, -4, -3, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]), List[Int]([0, 0, 0, 0, 0, -3, 0, 0, 0, 0, 0, 0, 1, 0, 0]), List[Int]([3, 0, 0, -1, 0, 0, -3, 0, 0, 0, 0, 0, 0, 1, 0]), List[Int]([-12, 0, 0, 1, 0, 3, 0, 0, 0, 0, 1, 0, -1, 0, 0]), List[Int]([6, 0, 0, -2, -3, 0, -3, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([-12, 0, -3, 1, 3, 3, 3, 0, 0, 1, 1, -1, -1, -1, 0]), List[Int]([-9, 0, 0, 0, 3, 3, 3, 0, 0, 0, 1, -1, -1, -1, 0]), List[Int]([6, 0, -3, -2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([12, 0, -3, -1, -3, 0, -3, 0, 0, 1, -1, 1, 0, 1, 0]), List[Int]([3, 0, 0, -1, 0, 0, -3, 0, 0, 0, 0, 0, 0, 1, 0]), List[Int]([12, 0, 0, -4, -3, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]), List[Int]([60, 0, -3, -11, 0, 3, 0, 0, 0, 1, -3, 0, -1, 0, 0]), List[Int]([63, 0, -3, -12, 0, 3, 0, 0, 0, 1, -3, 0, -1, 0, 0]), List[Int]([-9, 0, 0, 0, 3, 0, 6, 0, 0, 0, 1, -1, 0, -2, 0]), List[Int]([1, 0, 0, 1, -1, -1, -2, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-7, 0, 3, -1, -5, -1, -12, 0, 0, 0, 0, -1, 0, -2, 0]), List[Int]([1, 0, 1, 1, -6, -1, 0, 0, 0, 0, 0, -1, 0, 0, 0]), List[Int]([180, 0, -5, -36, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([25, 0, 0, -10, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0]), List[Int]([20, 0, 0, -4, -5, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]), List[Int]([0, 0, 0, 0, 0, -5, 0, 0, 0, 0, 0, 0, 1, 0, 0]), List[Int]([5, 0, 0, -1, 0, 0, -5, 0, 0, 0, 0, 0, 0, 1, 0]), List[Int]([-20, 0, 0, -1, 0, 5, 0, 0, 0, 0, 1, 0, -1, 0, 0]), List[Int]([10, 0, 0, -2, -5, 0, -5, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([-20, 0, -5, -1, 5, 5, 5, 0, 0, 1, 1, -1, -1, -1, 0]), List[Int]([-15, 0, 0, -2, 5, 5, 5, 0, 0, 0, 1, -1, -1, -1, 0]), List[Int]([10, 0, -5, -2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([20, 0, -5, 1, -5, 0, -5, 0, 0, 1, -1, 1, 0, 1, 0]), List[Int]([5, 0, 0, -1, 0, 0, -5, 0, 0, 0, 0, 0, 0, 1, 0]), List[Int]([20, 0, 0, -4, -5, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]), List[Int]([100, 0, -5, -5, 0, 5, 0, 0, 0, 1, -3, 0, -1, 0, 0]), List[Int]([105, 0, -5, -6, 0, 5, 0, 0, 0, 1, -3, 0, -1, 0, 0]), List[Int]([-15, 0, 0, -2, 5, 0, 10, 0, 0, 0, 1, -1, 0, -2, 0]), List[Int]([-5, 0, 0, -4, 5, 5, 10, 0, 0, 0, 1, -1, -1, -2, 0]), List[Int]([-3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([-3, 0, 3, -1, -5, -1, -13, 0, 0, 0, 0, -1, 0, -2, 0]), List[Int]([3, 0, -2, 1, 5, 1, 13, 0, 0, 0, 0, 1, 0, 2, 0]), List[Int]([4, 0, 0, 0, 7, 0, -7, 0, 0, 0, 0, 1, 0, -1, 0]), List[Int]([-4, 0, 1, 0, -7, 0, 7, 0, 0, 0, 0, -1, 0, 1, 0]), List[Int]([-1, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0]), List[Int]([384, 0, -8, -48, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([64, 0, 0, -16, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0]), List[Int]([32, 0, 0, -4, -8, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]), List[Int]([24, 0, 0, -3, 0, -8, 0, 0, 0, 0, 0, 0, 1, 0, 0]), List[Int]([8, 0, 0, -1, 0, 0, -8, 0, 0, 0, 0, 0, 0, 1, 0]), List[Int]([-32, 0, 0, -4, 0, 8, 0, 0, 0, 0, 1, 0, -1, 0, 0]), List[Int]([16, 0, 0, -2, -8, 0, -8, 0, 0, 0, 0, 1, 0, 1, 0]), List[Int]([-32, 0, -8, -4, 8, 8, 8, 0, 0, 1, 1, -1, -1, -1, 0]), List[Int]([-24, 0, 0, -5, 8, 8, 8, 0, 0, 0, 1, -1, -1, -1, 0]), List[Int]([16, 0, -8, -2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]), List[Int]([32, 0, -8, 4, -8, 0, -8, 0, 0, 1, -1, 1, 0, 1, 0]), List[Int]([8, 0, 0, -1, 0, 0, -8, 0, 0, 0, 0, 0, 0, 1, 0]), List[Int]([32, 0, 0, -4, -8, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]), List[Int]([160, 0, -8, 4, 0, 8, 0, 0, 0, 1, -3, 0, -1, 0, 0]), List[Int]([168, 0, -8, 3, 0, 8, 0, 0, 0, 1, -3, 0, -1, 0, 0]), List[Int]([-24, 0, 0, -5, 8, 0, 16, 0, 0, 0, 1, -1, 0, -2, 0]), List[Int]([-8, 0, 0, -7, 8, 8, 16, 0, 0, 0, 1, -1, -1, -2, 0]), List[Int]([24, 0, 0, -3, 0, -8, 0, 0, 0, 0, 0, 0, 1, 0, 0]), List[Int]([8, 0, 0, -1, -8, 0, 8, 0, 0, 0, 0, 1, 0, -1, 0])])
    assert_equal(len(assume), 117)
    var ns = List[Int]([3, 71, 15, 4, 3, 2, 2, 45, 1065, 225, 60, 45, 30, 30])
    var lift = full_lift(7, 2)
    assert_equal(lift_point(lift, List[Int](ns[:7])), ns)
    var reg = GuidedRegion(subst^, assume^, GUIDED_PEEL_LIMIT, 0, False, lift^)
    assert_true(_satisfies(reg.assume, ns))
    var fam = pattern_family(pat, reg.subst)
    var stack = List[GuidedRegion]()
    var out = ShapeCover()
    assert_false(_certify_at(pat, fam, reg, ns, stack, out, False))
    assert_equal(len(stack), 0)
    var probes = probe_points(ns, reg.lift, reg.assume)
    var lr = _lazy_lift(fam, pattern_family(pat, point_subst(reg.subst, ns)), ns, reg, probes, True)
    assert_true(lr.ok and lr.a == lr.b and whole_region_lift(lr, probes, reg.lift))
    assert_equal(len(_new_forms(_carving_forms(lr.ineqs), reg)), 0)
    assert_true(_certify_at(pat, fam, reg, ns, stack, out, False, True))
    assert_equal(List[Int]([out.certified, out.poly_certified, len(stack)]), List[Int]([1, 1, 0]))


def main() raises:
    test_det_is_twice_the_z_difference()
    print("[PASS] test_det_is_twice_the_z_difference")
    test_crossing_is_the_walk_meeting()
    print("[PASS] test_crossing_is_the_walk_meeting")
    test_the_census_reduces_the_family_to_non_crossing_pairs()
    print("[PASS] test_the_census_reduces_the_family_to_non_crossing_pairs")
    test_an_opaque_cone_proves_lemma_phi1()
    print("[PASS] test_an_opaque_cone_proves_lemma_phi1")
    test_the_pattern_tree_is_a_sound_partial_cover()
    print("[PASS] test_the_pattern_tree_is_a_sound_partial_cover")
    test_lemmas_phi4_and_phi5_hold_on_every_member()
    print("[PASS] test_lemmas_phi4_and_phi5_hold_on_every_member")
    test_lemmas_phi6_to_phi8_close_the_delta_ez_cell()
    print("[PASS] test_lemmas_phi6_to_phi8_close_the_delta_ez_cell")
    test_the_constraint_substitutions_partition_the_solutions()
    print("[PASS] test_the_constraint_substitutions_partition_the_solutions")
    test_the_quadratic_pisot_identities()
    print("[PASS] test_the_quadratic_pisot_identities")
    test_line_mode_reaches_offsets_affine_along_the_delta_line()
    print("[PASS] test_line_mode_reaches_offsets_affine_along_the_delta_line")
    test_shape_cells_that_close()
    print("[PASS] test_shape_cells_that_close")
    test_pattern_refinement_partitions_the_word_pairs()
    print("[PASS] test_pattern_refinement_partitions_the_word_pairs")
    test_run_patterns_with_a_tail_close()
    print("[PASS] test_run_patterns_with_a_tail_close")
    test_the_residue_is_mostly_one_excursion()
    print("[PASS] test_the_residue_is_mostly_one_excursion")
    test_lemma_x_on_every_small_pair_of_monotone_paths()
    print("[PASS] test_lemma_x_on_every_small_pair_of_monotone_paths")
    test_crossing_closures_are_shared_tiles()
    print("[PASS] test_crossing_closures_are_shared_tiles")
    test_lemma_phi5_prime_the_short_suffix_of_w2()
    print("[PASS] test_lemma_phi5_prime_the_short_suffix_of_w2")
    test_reveal_census_needs_at_most_two_runs_to_length_7()
    print("[PASS] test_reveal_census_needs_at_most_two_runs_to_length_7")
    test_cover_pattern_closes_regions_by_lemma_x()
    print("[PASS] test_cover_pattern_closes_regions_by_lemma_x")
    test_impose_nonneg_partitions_exactly()
    print("[PASS] test_impose_nonneg_partitions_exactly")
    test_impose_equal_partitions_exactly()
    print("[PASS] test_impose_equal_partitions_exactly")
    test_guided_partition_closes_a_doubly_open_pattern()
    print("[PASS] test_guided_partition_closes_a_doubly_open_pattern")
    test_tighten_keeps_the_integer_points()
    print("[PASS] test_tighten_keeps_the_integer_points")
    test_the_prover_is_sound_on_its_regions()
    print("[PASS] test_the_prover_is_sound_on_its_regions")
    test_mccormick_quadrants_hold_no_pip_member()
    print("[PASS] test_mccormick_quadrants_hold_no_pip_member")
    test_z_floor_forms_keep_every_pip_member()
    print("[PASS] test_z_floor_forms_keep_every_pip_member")
    test_bound_propagation_is_exact_on_integers()
    print("[PASS] test_bound_propagation_is_exact_on_integers")
    test_fourier_motzkin_is_sound()
    print("[PASS] test_fourier_motzkin_is_sound")
    test_bounded_z2_closes_for_every_delta()
    print("[PASS] test_bounded_z2_closes_for_every_delta")
    test_the_zy_yz_leaf_path_with_s_minus_one()
    print("[PASS] test_the_zy_yz_leaf_path_with_s_minus_one")
    test_the_q_lift_closes_the_zy_yz_tail_leaf()
    print("[PASS] test_the_q_lift_closes_the_zy_yz_tail_leaf")
    test_the_deep_lazy_lift_certifies_a_zy_yzyz_region()
    print("[PASS] test_the_deep_lazy_lift_certifies_a_zy_yzyz_region")
    test_the_real_point_search_is_exact()
    print("[PASS] test_the_real_point_search_is_exact")
    test_every_zy_yz_member_lies_in_the_q_lift_claim()
    print("[PASS] test_every_zy_yz_member_lies_in_the_q_lift_claim")
    test_the_farkas_lp_agrees_with_fourier_motzkin()
    print("[PASS] test_the_farkas_lp_agrees_with_fourier_motzkin")
    test_the_envelope_refutes_only_regions_without_a_real_point()
    print("[PASS] test_the_envelope_refutes_only_regions_without_a_real_point")
    test_the_value_split_partitions_the_real_points()
    print("[PASS] test_the_value_split_partitions_the_real_points")
    test_the_affine_value_split_partitions_the_real_points()
    print("[PASS] test_the_affine_value_split_partitions_the_real_points")
    test_the_affine_value_split_refutes_the_zy_yzy_region()
    print("[PASS] test_the_affine_value_split_refutes_the_zy_yzy_region")
    test_the_q_lift_closes_zy_yzy()
    print("[PASS] test_the_q_lift_closes_zy_yzy")
    test_lifts_chosen_by_extent_close_the_s_plus_one_staircases()
    print("[PASS] test_lifts_chosen_by_extent_close_the_s_plus_one_staircases")
    require_contract("Theorem K's open family sigma(o) = y, sigma(y) = o w_1 o, sigma(z) = o w_2 o: det M = 2 (Z_1 - Z_2); the crossing test agrees with brute force; at |w_i| <= 5 there are 532 PIP members, Lemma Phi1 (w_1 begins with y) names verified level-2/3 paths on 274 and Lemma Phi2 (the Parikh walks of w_1 and w_2 + e_y cross) on 138, none failing, and the 120 non-crossing members are decided coincident at levels 3 to 6; an opaque-tail cone w_1 = y^(1+n) z T_1, w_2 = T_2 carries a level-3 path naming real shared tiles; the exploratory pattern tree at depth 6 has 14 certified, 8 empty, 19 Lemma P1 cut, 1 non-member and 34 open leaves, no closed leaf holds a PIP member it should not, and of the 532 members 413 lie in certified leaves (each at most the leaf level) and 119 in open ones; Lemma Phi4 (Pisot signs of Y_1 - Y_2 against Z_1 - Z_2) and Lemma Phi5 (the Z_1 = Z_2 + 1 non-crossing shape w_1 = u y^(Y_1 - Y_2), pi(u) = pi(w_2) + e_z) hold on all 2,136 members with |w_i| <= 6; at |w_i| <= 7 the Lemma Phi6-Phi8 paths verify on 1,180 of the 1,267 non-crossing members with none failing, the delta = e_z cell leaves only (zz, z) at level 6, (z, empty) is not PIP, and the other cells leave 87 members decided at levels 3 to 6; the run-shape cover: solve_constraint partitions the solutions of sum_pos n - sum_neg n = target exactly (every box solution hit once, targets -3..3), the quadratic Lemma P1 identities f(1) = Z_2 (Delta - 1) - 2 Y_2 - Delta - 3 (Z_1 = Z_2 + 1) and f(-1) = Z_2 (|Delta| - 1) - 2 Y_1 - |Delta| + 3 (Z_1 = Z_2 - 1) hold, a line-mode path (offsets affine along e_z - e_y) verifies on (z^a y^b, y^(b+1) z^(a+1)), a >= b + 2, and the shape cells (zy | eps), (zy | z), (zy | yz) with Z_1 = Z_2 + 1 close for Delta = 1, 2, 3 and the tail Delta >= 4 with no open region, while (zy | yz) with Z_1 = Z_2 - 1 closes at Delta = -1 using line mode; induction on runs: refining a run pattern's opaque tail (it ends, or one more run of the other letter and a new tail) partitions the word pairs (31 * 63 pairs with w_1 beginning with z, |w_i| <= 5, each in exactly one leaf), the patterns (zy | zy*), (zy | yz*), (zy* | z), (zy* | y), (zyz* | zy), (zyz* | yz), (z | z*), (z | y*), (z* | eps) -- the nine closed leaves of the run tree -- with Z_1 = Z_2 + 1, Delta = 1 close with no open region (each an infinite family with unboundedly many runs) while (zy* | zy*) does not at the same budget, and common points match their definition, 51 of the 87 residual members at |w_i| <= 7 having only t = 1; Lemma X (monotone lattice paths whose endpoints cross, or touch with a letter following, share a point) holds on every pair of paths of at most 4 steps, a weak end at a word end can leave the only shared point at the last level, the cone search closes 86 of the 87 residual members at |w_i| <= 7 by Lemma X, each confirmed by the exact level, Lemma Phi5' (Z_2 = Z_1 + 1, non-crossing: Delta <= 0, |w_2| = |w_1| + 1 - Delta, at least two z in the last 2 - Delta letters of w_2) holds on every member with |w_i| <= 7, the reveal census needs at most two revealed runs at longer-word lengths 5..7 (77/4, 255/13, 825/54), and cover_pattern certifies regions of zyz* y | zyz* by Lemma X; the certificate-guided partition: impose_nonneg covers {F >= 0} exactly (every form a_0 + a_1 n_1 + a_2 n_2, a_0 in -4..4, a_1, a_2 in -3..3, on the box [0, 5]^2) with F coefficientwise nonnegative on every region, impose_equal covers {E = 0} exactly (a_1, a_2 in -2..2, box [0, 6]^2), and cover_pattern_guided closes the doubly open pattern zy* y | zy* at Z_1 = Z_2 + 1, Delta = 1 with every carved region re-verified under its own inequalities; tighten keeps the integer points of every form a_0 + a_1 n_1 + a_2 n_2 (a_0 in -6..6, a_1, a_2 in -3..3) on [0, 6]^2, the Prover (affine, and quadratic U V + W) is sound under every pair of assumptions with coefficients in -1..1 on [0, 5]^2, and every McCormick quadrant of Lemma P1 that pisot_carve_forms opens in two-parameter families for s = +1 and s = -1 contains its point, passes mccormick_cut under its tightened forms, and holds no point with f < 0; integer bound propagation keeps every satisfying point of [0, 8]^2 in its box for a stride of three-form systems and declares empty only systems without one, and the exact point search returns only satisfying points, finds one whenever [0, 7]^2 holds one, and proves emptiness only of systems without a point; Fourier-Motzkin declares empty only systems without an integer point (a stride of three-form systems on [0, 6]^3) and refutes a wedge propagation cannot, its projections keeping every point in their intervals; with Z_2 bounded the tails close for every Delta: s = +1, Z_2 <= 1 (24 fully revealed run patterns) and s = -1, Z_2 <= 2 (20); z_floor_forms (Lemma P1 linearized at the McCormick corner (floor, b_lo)) keep every point of [0, 9]^3 with Z_2 >= floor and f <= -1, floors 2..5, s = +1 and s = -1, and the linear region holds points with f >= 0; the s = -1 leaf zy | yz (w_1 = z^a y^b, w_2 = y^(b+2+e) z^(a+1)): on every PIP non-crossing member the level-2 offset d = a e_z - (a+2) e_y has M d = (-4, 2a - 2b + ae, -a), f(-1) = ae + a - 2b + 2 <= -1 and the level-3 gap is k - m = 2 - a - f(-1), and the explicit path (y, z, -e_o) -> (y, z, d) -> (y, y, -4 e_o) -> (y, y, 0) verifies exactly on 312 of the 1,026 members with 3 <= a <= 8, b < 40, e <= 5 and on 1,134 of 4,913 with a <= 11, b < 80, e <= 8; the q-lift (cover_pattern_guided(q_lift=True): variables (n, q), q_j = n_j e, Lemma P1 as the affine form f <= -1 over (n, q), McCormick box envelopes, real base points, lifted certificates proved on the whole polyhedron): at a = 62, b = 436, e = 13 the free-line point search (bound 4) finds that path, its lift has a zero end offset over (n, q) and verifies there but not as a polynomial, and the cover closes zy | yz at Delta <= -2, Z_2 >= 4 with no open region (42 regions, 34 certified, 18 by polynomial paths, 1 cut, 8 without a real member), while the default z_floor cover of the same leaf is unchanged (16 regions, 1 open); the q-lift's real-point search (_point_search) on 3,000 seeded lifted systems over (n, q) with 2 or 3 run variables, e <= 1..3 and 2-4 small forms returns only real points (q_j = n_j e) satisfying every form, finds one whenever a real point with n in [0, 6]^m does, and with every n bounded reports empty exactly when no real point exists (1,665 found, 1,313 empty, 452 of them empty only because the point must be real), and refutes n_0 <= 0, q_0 >= 1 although its polyhedron holds (0, 0, 1, 0); every one of the 1,772 PIP non-crossing members of zy | yz with 3 <= a <= 9, b < 50, e <= 6 is a real point of the q-lift start region (slots (a-1, b-1, b+1+e, a, e)), whose assumptions include the hand-lifted forms -1 - f(-1) >= 0 and Z_2 >= 4, each holding there with f(-1) of the member's matrix <= -1 equal to the lifted value, and the 39 with a <= 7, b <= 8 are decided coincident by coincidence_level; the cover does not report its certified regions, so per-region membership is not checked; with lifts chosen by their extent on probe points of the region (the candidate tree's lift competing with solve_lift) and implied equalities substituted eagerly, the q-lift closes the s = +1 tail leaves zy +y^(2+e) | zyzy (17 regions, 9 certified, 2 by polynomial paths, 1 cut, 6 without a real member) and zy +y^(2+e) | yzyz (2 regions, both certified) at Delta >= 2, Z_2 >= 3, which climbed staircases before; psc.farkas_lp finds a checked Farkas certificate on exactly the 1,747 of 3,000 seeded three-variable systems that uncapped Fourier-Motzkin finds empty, none with a point in [0, 6]^3, the zero vector and negated certificates failing the check and a form of the wrong width or a multiplier vector not one per form raising, and refutes a 16-form q-lift region of zy | yzyz on which capped Fourier-Motzkin claims nothing; the q-lift envelope with RLT cuts (e - lo_e) g, (hi_e - e) g holds at every real point of [0, 6]^m of 4,000 seeded lifted regions and makes _assume_empty refute 2,597 of them (274 only with the envelope), none holding a real point of [0, 6]^m (on the bounded regions, whose real points all lie there, none at all), 10 bounded regions without a real point left unrefuted, and refutes n_0 + n_1 <= 2, q_0 + q_1 >= 3e, e >= 1, which its polyhedron and its McCormick box envelope do not; and _value_split, bounding a variable by checked certificates, splits 915 of 2,000 seeded lifted regions into pieces fixing one variable to distinct values, each real point of [0, 6]^m in exactly one piece when it lies in the region and in none otherwise; _affine_value_split, bounding a form n_k - c e (c in 0..3) by checked certificates on probes that carry their envelope, splits all 400 seeded lifted regions with a band c e + a <= n_0 <= c e + a + w (137 of them along a slope c > 0) into pieces n_k := v + c e, each real point of [0, 9]^m in exactly one piece when it lies in the region and in none otherwise; on the last open region of the q-lift cover of zy | yzy (30 traced forms, LP-feasible with its envelope, not split by _value_split) it fixes n_0 = 3 and that piece is refuted by a checked Farkas certificate; and the q-lift cover closes zy | yzy at Delta <= -2, Z_2 >= 4 with no open region (121 regions, 49 certified, 44 by polynomial paths, 2 cut, 59 without a real member); on a region of the zy | yzyz q-lift reported open with no certificate (117 forms over (n, q), base point n = (3, 71, 15, 4, 3, 2, 2)) the shared 5,000-node point-path enumeration lifts no certificate, while the deep lazy lift stops at a whole-region lift (end offset lifting to zero) whose forms the region already implies, so it carves nothing, and _certify_at(deep=True) certifies the region by a polynomial path pushing no complement, verified on the polyhedron and at the base point")
