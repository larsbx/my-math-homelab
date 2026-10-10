"""Exact regressions for the polynomial line mode (psc.poly_line).

docs/p1a-a1-prime-2026-10-05.md §3l. Polynomial arithmetic against
evaluation, the polynomial prover's soundness under assumptions, and
agreement with the affine line verifier wherever both apply.
"""

from std.testing import assert_equal, assert_false, assert_true
from mojo_smoke.claims import require_contract
from psc.cone_witness import ConeFamily, Prover, WitnessStep, aff_const, aff_eval, search_witness_line, verify_witness_line
from psc.poly_line import (
    Poly,
    PolyStep,
    poly_add,
    poly_const,
    poly_degree,
    poly_eval,
    poly_from_aff,
    mono_var,
    poly_mul,
    poly_scale,
    poly_nonneg_under,
    poly_steps,
    poly_sub,
    poly_vanishes_under,
    enumerate_point_paths,
    PointPaths,
    whole_region_lift,
    holds_under,
    lift_key,
    PolyLift,
    probe_points,
    solve_lift,
    steps_at,
    vanishes_under,
    verify_witness_poly,
)
from psc.product_lift import ProductLift, full_lift, lift_affine, lift_form, lift_point, lifted_monomial, mccormick_box_forms, mccormick_forms, product_lift_of, product_substitution, rlt_forms
from odd_letter_family_certificate import O, Y, Z, shape_family, _subst_var


def _forms(c_lo: Int, c_hi: Int, a: Int, m: Int) -> List[List[Int]]:
    """Every affine form over m variables with constant in c_lo..c_hi and
    coefficients in -a..a."""
    var out = List[List[Int]]()
    var span = 2 * a + 1
    var count = 1
    for _ in range(m):
        count *= span
    for c in range(c_lo, c_hi + 1):
        for code in range(count):
            var f = List[Int]([c])
            var r = code
            for _ in range(m):
                f.append(r % span - a)
                r //= span
            out.append(f^)
    return out^


def test_polynomial_arithmetic_matches_evaluation() raises:
    """For a stride of affine forms a, b, c over three variables, P = a b + c
    and Q = P a evaluate as the products do at every point of [0, 3]^3, with
    degrees at most 2 and 3."""
    var forms = _forms(-2, 2, 1, 3)
    var n = len(forms)
    var checked = 0
    for i in range(0, n, 7):
        for j in range(i, n, 11):
            var k = (i + 3 * j) % n
            var a = poly_from_aff(forms[i])
            var p = poly_add(poly_mul(a, poly_from_aff(forms[j])), poly_from_aff(forms[k]))
            var q = poly_mul(p, a)
            assert_true(poly_degree(p) <= 2)
            assert_true(poly_degree(q) <= 3)
            for x in range(4):
                for y in range(4):
                    for z in range(4):
                        var ns = List[Int]([x, y, z])
                        var va = aff_eval(forms[i], ns)
                        var vp = va * aff_eval(forms[j], ns) + aff_eval(forms[k], ns)
                        assert_equal(poly_eval(p, ns), vp)
                        assert_equal(poly_eval(q, ns), vp * va)
                        assert_equal(poly_eval(poly_sub(p, p), ns), 0)
            checked += 1
    assert_true(checked > 100)


def test_polynomial_prover_is_sound() raises:
    """Whenever poly_nonneg_under proves P = U V + W >= 0 or P U >= 0 under
    one or two assumptions with coefficients in -1..1, P is >= 0 at every
    point of [0, 5]^2 where they hold; it proves some, and vanishing needs
    both signs."""
    var assume = _forms(-1, 1, 1, 2)
    var targets = _forms(-2, 2, 2, 2)
    var proved = 0
    for i in range(len(assume)):
        for j in range(i, len(assume)):
            var pv = Prover(List[List[Int]]([assume[i].copy(), assume[j].copy()]))
            for k in range(0, len(targets), 3):
                var u = poly_from_aff(assume[i])
                var p = poly_add(poly_mul(u, poly_from_aff(targets[k])), poly_from_aff(targets[(7 * k + 3) % len(targets)]))
                var r = poly_mul(p, u)
                var ok_p = poly_nonneg_under(p, pv)
                var ok_r = poly_nonneg_under(r, pv)
                if ok_p:
                    proved += 1
                for x in range(6):
                    for y in range(6):
                        var ns = List[Int]([x, y])
                        if aff_eval(assume[i], ns) < 0 or aff_eval(assume[j], ns) < 0:
                            continue
                        if ok_p:
                            assert_true(poly_eval(p, ns) >= 0)
                        if ok_r:
                            assert_true(poly_eval(r, ns) >= 0)
    assert_true(proved > 1000)
    var a = List[Int]([-3, 2, -4])
    assert_true(poly_vanishes_under(poly_from_aff(a), Prover(List[List[Int]]([a.copy(), List[Int]([3, -2, 4])]))))
    assert_false(poly_vanishes_under(poly_from_aff(a), Prover(List[List[Int]]([a.copy()]))))


def test_polynomial_mode_agrees_with_line_mode() raises:
    """On the line-mode family (z^a y^b, y^(b+1) z^(a+1)), a = b + 2 + n1,
    b = 2 + n2, the line path verifies in polynomial mode too, every
    single-offset perturbation that line mode rejects is rejected, and the
    path instantiated at points of [0, 4]^2 verifies on the point family."""
    var subst = List[List[Int]]()
    subst.append(List[Int]([3, 1, 1]))
    subst.append(List[Int]([1, 0, 1]))
    subst.append(List[Int]([2, 0, 1]))
    subst.append(List[Int]([4, 1, 1]))
    var fam = shape_family(List[Int]([Z, Y]), List[Int]([Y, Z]), subst)
    var w = search_witness_line(fam, O, Y, 3, 6, Y, Z)
    assert_true(w.found)
    assert_true(verify_witness_line(fam, O, Y, w.steps))
    var ps = poly_steps(w.steps)
    assert_true(verify_witness_poly(fam, O, Y, ps, Prover()))
    var rejected = 0
    for l in range(len(ps)):
        for side in range(2):
            var bent = w.steps.copy()
            if side == 0:
                bent[l].off_a[0] += 1
            else:
                bent[l].off_b[0] += 1
            var line_ok = verify_witness_line(fam, O, Y, bent)
            assert_equal(verify_witness_poly(fam, O, Y, poly_steps(bent), Prover()), line_ok)
            if not line_ok:
                rejected += 1
    assert_true(rejected >= 1)
    for n1 in range(5):
        for n2 in range(5):
            var ns = List[Int]([n1, n2])
            var at = List[List[Int]]()
            for k in range(len(subst)):
                at.append(List[Int]([aff_eval(subst[k], ns)]))
            var point = shape_family(List[Int]([Z, Y]), List[Int]([Y, Z]), at)
            assert_true(verify_witness_line(point, O, Y, steps_at(ps, ns)))


def _line_family_at(ns: List[Int]) raises -> ConeFamily:
    var subst = List[List[Int]]()
    subst.append(List[Int]([3 + ns[0] + ns[1]]))
    subst.append(List[Int]([1 + ns[1]]))
    subst.append(List[Int]([2 + ns[1]]))
    subst.append(List[Int]([4 + ns[0] + ns[1]]))
    return shape_family(List[Int]([Z, Y]), List[Int]([Y, Z]), subst)


def test_linear_lift_solves_point_paths() raises:
    """On the line-mode family, at the base points (1, 2) and (2, 1): every
    enumerated point path verifies on the point family, and some solves
    (solve_lift) to a polynomial path whose end offset is zero and which
    verify_witness_poly accepts on the region its offset bounds carve; the
    solved path, instantiated at every point of [0, 5]^2 inside that region,
    verifies on the point family."""
    var subst = List[List[Int]]()
    subst.append(List[Int]([3, 1, 1]))
    subst.append(List[Int]([1, 0, 1]))
    subst.append(List[Int]([2, 0, 1]))
    subst.append(List[Int]([4, 1, 1]))
    var fam = shape_family(List[Int]([Z, Y]), List[Int]([Y, Z]), subst)
    for base in range(2):
        var ns = List[Int]([1, 2]) if base == 0 else List[Int]([2, 1])
        var point = _line_family_at(ns)
        var paths = enumerate_point_paths(point, O, Y, 3, 6, Y, Z, 50, 20000)
        assert_true(len(paths) >= 1)
        var solved = 0
        for k in range(len(paths)):
            assert_true(verify_witness_line(point, O, Y, paths[k]))
            var lr = solve_lift(fam, point, ns, O, Y, paths[k])
            if not lr.ok:
                continue
            solved += 1
            for i in range(3):
                assert_true(poly_vanishes_under(lr.gamma[i], Prover()))
            assert_true(verify_witness_poly(fam, O, Y, lr.steps, Prover(lr.ineqs.copy())))
            for x in range(6):
                for y in range(6):
                    var at = List[Int]([x, y])
                    var inside = True
                    for f in range(len(lr.ineqs)):
                        if aff_eval(lr.ineqs[f], at) < 0:
                            inside = False
                    if inside:
                        assert_true(verify_witness_line(_line_family_at(at), O, Y, steps_at(lr.steps, at)))
        assert_true(solved >= 1)


def _tail_bilinear(forms: List[List[Int]], i: Int, j: Int) raises -> Poly:
    """`A + B e` over (n_0, n_1, e): forms i and j as A and B."""
    var tail = poly_from_aff(List[Int]([0, 0, 0, 1]))
    return poly_add(poly_from_aff(forms[i]), poly_mul(poly_from_aff(forms[j]), tail))


def test_product_lift_round_trip() raises:
    """Over (a, b, e) with tail e: for P = A + B e with A, B affine (all 135 forms with constant in -2..2 and coefficients in -1..1 as
    A, each paired with a B), the lifted affine form at (n, q(n)) equals P at n on [0, 4]^3, the
    lift has exactly the products that occur, and the zy|yz quantities
    2a - 2b + ae and f(-1) = ae + a - 2b + 2 lift to (0, 2, -2, 0, 1) and
    (2, 1, -2, 0, 1) over (n, q_a)."""
    var forms = _forms(-2, 2, 1, 3)
    var checked = 0
    for i in range(len(forms)):
        var j = (5 * i + 7) % len(forms)
        var p = _tail_bilinear(forms, i, j)
        var lift = product_lift_of(List[Poly]([p.copy()]), 3, 2)
        var want = List[Int]()
        for k in range(3):
            if forms[j][k + 1] != 0:
                want.append(k)
        assert_equal(len(lift.prods), len(want))
        for k in range(len(want)):
            assert_equal(lift.prods[k], want[k])
        var f = lift_affine(lift, p)
        for x in range(5):
            for y in range(5):
                for z in range(5):
                    var ns = List[Int]([x, y, z])
                    assert_equal(aff_eval(f, lift_point(lift, ns)), poly_eval(p, ns))
                    assert_equal(aff_eval(lift_form(lift, forms[i]), lift_point(lift, ns)), aff_eval(forms[i], ns))
        checked += 1
    assert_equal(checked, 135)
    var ae = poly_mul(poly_from_aff(List[Int]([0, 1, 0, 0])), poly_from_aff(List[Int]([0, 0, 0, 1])))
    var md = poly_add(poly_from_aff(List[Int]([0, 2, -2, 0])), ae)
    var f1 = poly_add(poly_from_aff(List[Int]([2, 1, -2, 0])), ae)
    var lift = product_lift_of(List[Poly]([md.copy(), f1.copy()]), 3, 2)
    assert_equal(len(lift.prods), 1)
    assert_equal(lift.slot(0), 4)
    assert_true(lift_affine(lift, md) == List[Int]([0, 2, -2, 0, 1]))
    assert_true(lift_affine(lift, f1) == List[Int]([2, 1, -2, 0, 1]))


def test_mccormick_envelope_holds_at_real_points() raises:
    """With every product of (a, b, e) lifted (e^2 included), for lower
    bounds in 0..2 per variable, every McCormick form is >= 0 at the real
    point over each n in [lo, lo + 4]^3, and is 0 where n_j = lo_j or e = lo_e."""
    var full = List[Poly]()
    for j in range(3):
        var unit = List[Int](length=4, fill=0)
        unit[j + 1] = 1
        full.append(poly_mul(poly_from_aff(List[Int]([0, 0, 0, 1])), poly_from_aff(unit)))
    var lift = product_lift_of(full, 3, 2)
    assert_equal(len(lift.prods), 3)
    for code in range(27):
        var lo = List[Int]([code % 3, (code // 3) % 3, code // 9])
        var env = mccormick_forms(lift, lo)
        assert_equal(len(env), 3)
        for x in range(lo[0], lo[0] + 5):
            for y in range(lo[1], lo[1] + 5):
                for z in range(lo[2], lo[2] + 5):
                    var ns = List[Int]([x, y, z])
                    var pt = lift_point(lift, ns)
                    for k in range(3):
                        var v = aff_eval(env[k], pt)
                        assert_true(v >= 0)
                        assert_equal(v, (ns[k] - lo[k]) * (z - lo[2]))


def _lift_raises(p: Poly, m: Int, e: Int) -> Bool:
    try:
        _ = product_lift_of(List[Poly]([p.copy()]), m, e)
    except:
        return True
    return False


def test_product_lift_fails_closed() raises:
    """With tail e = n_2 of three variables, n_0 n_1, n_0^2, n_0 n_1 n_2,
    e^3 and a variable n_3 raise, a tail outside the variables raises, and
    lift_affine raises on a product its lift does not carry."""
    var n0 = poly_from_aff(List[Int]([0, 1, 0, 0]))
    var n1 = poly_from_aff(List[Int]([0, 0, 1, 0]))
    var e = poly_from_aff(List[Int]([0, 0, 0, 1]))
    assert_false(_lift_raises(poly_add(poly_mul(n0, e), poly_mul(e, e)), 3, 2))
    assert_true(_lift_raises(poly_mul(n0, n1), 3, 2))
    assert_true(_lift_raises(poly_mul(n0, n0), 3, 2))
    assert_true(_lift_raises(poly_mul(poly_mul(n0, n1), e), 3, 2))
    assert_true(_lift_raises(poly_mul(poly_mul(e, e), e), 3, 2))
    var n3 = Poly()
    n3.add_term(mono_var(3), 1)
    assert_true(_lift_raises(n3, 3, 2))
    assert_true(_lift_raises(poly_const(1), 3, 3))
    var lift = product_lift_of(List[Poly]([poly_mul(n0, e)]), 3, 2)
    var raised = False
    try:
        _ = lift_affine(lift, poly_add(poly_mul(n1, e), poly_scale(n0, 2)))
    except:
        raised = True
    assert_true(raised)


def _old_point(ns: List[Int], k: Int, repl: List[Int], lift: ProductLift) raises -> List[Int]:
    """The real point a substitution `n_k := repl` came from, given the new
    one's `n`: `n_k` replaced by `repl` at the new real point."""
    var old = ns.copy()
    old[k] = aff_eval(repl, lift_point(lift, ns))
    return lift_point(lift, old)


def test_product_substitution_keeps_points_real() raises:
    """Over (n_0, n_1, e = n_2) with every product lifted: for n_0 := 0, 2,
    n_0 + 1, 2 + n_1 + 2 e, n_1 := 3, n_1 + n_0, e := 0, 3, e + 1, 3 + 2 e,
    every affine form F over (n, q) with constant 0 and coefficients in
    -1..1, rewritten by n_k := L and then the product coordinates' forms,
    takes at each new real point of [0, 3]^3 the value F has at the old real
    point; e := e + n_0 and a replacement naming a product coordinate are
    refused."""
    var lift = full_lift(3, 2)
    var w = lift.width()
    # rows: k, then L's constant and coefficients of n_0, n_1, e
    var specs = List[List[Int]]([List[Int]([0, 0, 0, 0, 0]), List[Int]([0, 2, 0, 0, 0]), List[Int]([0, 1, 1, 0, 0]), List[Int]([0, 2, 0, 1, 2]), List[Int]([1, 3, 0, 0, 0]), List[Int]([1, 0, 1, 1, 0]), List[Int]([2, 0, 0, 0, 0]), List[Int]([2, 3, 0, 0, 0]), List[Int]([2, 1, 0, 0, 1]), List[Int]([2, 3, 0, 0, 2])])
    var ks = List[Int]()
    var repls = List[List[Int]]()
    for t in range(len(specs)):
        ks.append(specs[t][0])
        var r = aff_const(w, 0)
        for i in range(4):
            r[i] = specs[t][i + 1]
        repls.append(r^)
    var forms = _forms(0, 0, 1, w)
    var checked = 0
    for t in range(len(ks)):
        var ps = product_substitution(lift, ks[t], repls[t])
        assert_true(ps.ok)
        for f in range(0, len(forms), 7):
            var g = _subst_var(List[List[Int]]([forms[f].copy()]), ks[t], repls[t])
            for i in range(len(ps.vars)):
                g = _subst_var(g, ps.vars[i], ps.forms[i])
            for code in range(64):
                var ns = List[Int]([code % 4, (code // 4) % 4, code // 16])
                assert_equal(aff_eval(g[0], lift_point(lift, ns)), aff_eval(forms[f], _old_point(ns, ks[t], repls[t], lift)))
                checked += 1
    assert_true(checked > 0)
    var mixed = aff_const(w, 0)
    mixed[1] = 1
    mixed[3] = 1
    assert_false(product_substitution(lift, 2, mixed).ok)
    var through_q = aff_const(w, 0)
    through_q[4] = 1
    assert_false(product_substitution(lift, 0, through_q).ok)


def test_mccormick_box_forms_hold_at_real_points() raises:
    """On every box lo <= n <= hi (lo in 0..1, hi = lo + 2 where bounded,
    every pattern of bounded coordinates) each envelope form of every q_j is
    >= 0 at every real point of the box, and there are
    (1 + [n_j bounded]) (1 + [e bounded]) of them per j."""
    var lift = full_lift(3, 2)
    for lo0 in range(2):
        for lo2 in range(2):
            for mask in range(8):
                var lo = List[Int]([lo0, 1, lo2])
                var hi = List[Int]([lo0 + 2, 3, lo2 + 2])
                var bounded = List[Bool]([mask & 1 != 0, mask & 2 != 0, mask & 4 != 0])
                var forms = mccormick_box_forms(lift, lo, hi, bounded)
                var want = 0
                for j in range(3):
                    want += (2 if bounded[j] else 1) * (2 if bounded[2] else 1)
                assert_equal(len(forms), want)
                for a in range(lo[0], lo[0] + 3):
                    for b in range(lo[1], lo[1] + 3):
                        for e in range(lo[2], lo[2] + 3):
                            var x = lift_point(lift, List[Int]([a, b, e]))
                            for f in range(len(forms)):
                                assert_true(aff_eval(forms[f], x) >= 0)


def test_lifted_conditions_fail_closed() raises:
    """With a lift, holds_under proves a polynomial by its form over (n, q):
    n_0 e and e^2 + n_1 hold on the orthant, -n_0 e does not, n_0 n_1 (not a
    product with e) is refused even though it is >= 0, and vanishing needs
    the lifted form to vanish; lifted_monomial sends n_j e to q_j and leaves
    any other monomial."""
    var lift = full_lift(3, 2)
    var n0 = poly_from_aff(List[Int]([0, 1, 0, 0]))
    var n1 = poly_from_aff(List[Int]([0, 0, 1, 0]))
    var e = poly_from_aff(List[Int]([0, 0, 0, 1]))
    var none = Prover()
    assert_true(holds_under(poly_mul(n0, e), none, lift))
    assert_true(holds_under(poly_add(poly_mul(e, e), n1), none, lift))
    assert_false(holds_under(poly_scale(poly_mul(n0, e), -1), none, lift))
    assert_false(holds_under(poly_mul(n0, n1), none, lift))
    assert_true(poly_nonneg_under(poly_mul(n0, n1), none))
    # q_0 = n_0 e vanishes where q_0 <= 0 is assumed
    var q0_le_0 = List[Int](length=7, fill=0)
    q0_le_0[4] = -1
    assert_true(vanishes_under(poly_mul(n0, e), Prover(List[List[Int]]([q0_le_0^])), lift))
    assert_false(vanishes_under(poly_mul(n0, e), none, lift))
    assert_equal(lifted_monomial(lift, mono_var(0) | (mono_var(2) << 5)), mono_var(3))
    assert_equal(lifted_monomial(lift, mono_var(2) | (mono_var(2) << 5)), mono_var(5))
    var n0n1 = mono_var(0) | (mono_var(1) << 5)
    assert_equal(lifted_monomial(lift, n0n1), n0n1)
    assert_equal(lifted_monomial(lift, mono_var(1)), mono_var(1))


def test_rlt_forms_are_products_at_real_points() raises:
    """Over (n_0, n_1, e = n_2) with every product lifted: for every form g
    over n with constant in -2..2 and coefficients in -1..1, lo_e in 0..2
    and hi_e = lo_e + 2, rlt_forms gives exactly (e - lo_e) g and
    (hi_e - e) g at every real point of [0, 4]^3 (so each is >= 0 wherever
    g >= 0 and lo_e <= e <= hi_e), exactly the first form when e is
    unbounded, and raises on a form naming a product coordinate and on one
    naming n_1 in a lift without q_1."""
    var lift = full_lift(3, 2)
    var w = lift.width()
    var gs = _forms(-2, 2, 1, 3)
    var checked = 0
    for gi in range(len(gs)):
        var g = lift_form(lift, gs[gi])
        for lo in range(3):
            var hi = lo + 2
            var both = rlt_forms(lift, g, lo, hi, True)
            assert_equal(len(both), 2)
            assert_equal(rlt_forms(lift, g, lo, 0, False), List[List[Int]]([both[0].copy()]))
            for code in range(125):
                var ns = List[Int]([code % 5, (code // 5) % 5, code // 25])
                var x = lift_point(lift, ns)
                var gv = aff_eval(g, x)
                assert_equal(aff_eval(both[0], x), (ns[2] - lo) * gv)
                assert_equal(aff_eval(both[1], x), (hi - ns[2]) * gv)
                checked += 1
    assert_equal(checked, 125 * 3 * len(gs))
    var named = aff_const(w, 1)
    named[4] = 1
    var raised = 0
    try:
        _ = rlt_forms(lift, named, 0, 0, False)
    except:
        raised += 1
    # without q_1 in the lift, a form naming n_1 has no expansion
    var partial = ProductLift(3, 2, List[Int]([0, 2]))
    try:
        _ = rlt_forms(partial, List[Int]([0, 0, 1, 0, 0, 0]), 0, 0, False)
    except:
        raised += 1
    assert_equal(raised, 2)


def test_lift_key_prefers_the_whole_region() raises:
    """With a lift over (n_0, n_1, e = n_2) on the region n_0 >= 2, e <= 5:
    probe_points from the real point (3, 1, 2) are real points of the region
    (n_0 and e never leave it), and lift_key ranks a lift whose end offset
    vanishes everywhere above one whose end offset n_0 - 3 vanishes on a
    slice only, and among lifts of equal extent the one with the smaller
    offsets (copied constants such as 30 cost more) first; whole_region_lift
    holds for the lifts with a zero end offset and not for the slice, nor
    for a zero end offset carved by a form failing at a probe point."""
    var lift = full_lift(3, 2)
    var w = lift.width()
    var lo0 = aff_const(w, -2)
    lo0[1] = 1
    var hi_e = aff_const(w, 5)
    hi_e[3] = -1
    var region = List[List[Int]]([lo0^, hi_e^])
    var probes = probe_points(List[Int]([3, 1, 2]), lift, region)
    assert_true(len(probes) > 0)
    for p in probes:
        assert_equal(p, lift_point(lift, List[Int](p[:3])))
        for f in region:
            assert_true(aff_eval(f, p) >= 0)
    var whole = PolyLift()
    whole.ok = True
    for _ in range(3):
        whole.gamma.append(Poly())
    var slice = whole.copy()
    slice.gamma[1] = poly_from_aff(List[Int]([-3, 1, 0, 0]))
    assert_true(lift_key(whole, probes, lift) > lift_key(slice, probes, lift))
    var cheap = whole.copy()
    cheap.steps.append(PolyStep(0, poly_const(1), 0, poly_const(0)))
    var dear = whole.copy()
    dear.steps.append(PolyStep(0, poly_const(30), 0, poly_const(0)))
    assert_true(lift_key(cheap, probes, lift) > lift_key(dear, probes, lift))
    assert_true(lift_key(whole, probes, lift) > lift_key(cheap, probes, lift))
    assert_true(whole_region_lift(whole, probes, lift) and whole_region_lift(dear, probes, lift))
    assert_false(whole_region_lift(slice, probes, lift))
    var carved = whole.copy()
    var cut = aff_const(w, probes[0][0] - 1)
    cut[1] = -1  # n_0 <= n_0(probes[0]) - 1: fails at probes[0]
    carved.ineqs.append(cut^)
    assert_false(whole_region_lift(carved, probes, lift))


def _same_steps(a: List[WitnessStep], b: List[WitnessStep]) -> Bool:
    if len(a) != len(b):
        return False
    for l in range(len(a)):
        if a[l].seg_a != b[l].seg_a or a[l].seg_b != b[l].seg_b or a[l].off_a != b[l].off_a or a[l].off_b != b[l].off_b:
            return False
    return True


def _path(offs: List[Int]) -> List[WitnessStep]:
    """A point path from (seg_a, off_a, seg_b, off_b) quadruples."""
    var out = List[WitnessStep]()
    for l in range(0, len(offs), 4):
        out.append(WitnessStep(offs[l], List[Int]([offs[l + 1]]), offs[l + 2], List[Int]([offs[l + 3]])))
    return out^


def test_point_paths_resume_the_enumeration() raises:
    """Pinned against the enumeration as it stood at 5c43b85 (before
    PointPaths): at the line-mode family's points (1, 2) and (2, 1)
    (bound 3, level 6) the 20,000-node enumeration yields 264 and 216
    paths (20 and 15 distinct; the search reaches a path more than once)
    and the 12,000-node one their first 120 and 40 (as many distinct),
    every one of level 4 and verified by verify_witness_line; the first
    node to close a path closes 8, with steps (0 0 | 1 0), (2 3 | 2 5),
    (2 1 | 1 1), (1 t | 1 t+2) for t = 0, 4, 1, 3, 0, 2, 2, 4 at (1, 2) and
    the same with (2 2 | 2 5), (2 0 | 1 1) at (2, 1). PointPaths yields
    the paths in that order, and a path cap k keeps the first 8 ceil(k / 8)
    (every node that closes a path here closes 8), none at k = 0."""
    var counts = List[List[Int]]([List[Int]([264, 120]), List[Int]([216, 40])])
    var distinct = List[Int]([20, 15])
    for base in range(2):
        var point = _line_family_at(List[Int]([1, 2]) if base == 0 else List[Int]([2, 1]))
        var first = List[List[WitnessStep]]()
        for t in [0, 4, 1, 3, 0, 2, 2, 4]:
            first.append(_path(List[Int]([0, 0, 1, 0, 2, 3 - base, 2, 5, 2, 1 - base, 1, 1, 1, t, 1, t + 2])))
        var full = List[List[WitnessStep]]()
        for b in range(2):
            var nodes = 20000 if b == 0 else 12000
            var all = enumerate_point_paths(point, O, Y, 3, 6, Y, Z, 1 << 30, nodes)
            assert_equal(len(all), counts[base][b])
            for k in range(len(first)):
                assert_true(_same_steps(all[k], first[k]))
            var new = 0
            for k in range(len(all)):
                assert_equal(len(all[k]), 4)
                assert_true(verify_witness_line(point, O, Y, all[k]))
                var seen = False
                for j in range(k):
                    seen = seen or _same_steps(all[j], all[k])
                new += 0 if seen else 1
                if b == 1:
                    assert_true(_same_steps(all[k], full[k]))
            assert_equal(new, distinct[base])
            var it = PointPaths(O, Y, 3, 6, Y, Z, nodes)
            var k = 0
            while it.next(point):
                assert_true(k < len(all) and _same_steps(it.path, all[k]))
                k += 1
            assert_equal(k, len(all))
            for cap in range(25):
                var some = enumerate_point_paths(point, O, Y, 3, 6, Y, Z, cap, nodes)
                assert_equal(len(some), min(8 * ((cap + 7) // 8), len(all)))
                for j in range(len(some)):
                    assert_true(_same_steps(some[j], all[j]))
            if b == 0:
                full = all^


def main() raises:
    test_polynomial_arithmetic_matches_evaluation()
    print("[PASS] test_polynomial_arithmetic_matches_evaluation")
    test_polynomial_prover_is_sound()
    print("[PASS] test_polynomial_prover_is_sound")
    test_polynomial_mode_agrees_with_line_mode()
    print("[PASS] test_polynomial_mode_agrees_with_line_mode")
    test_linear_lift_solves_point_paths()
    print("[PASS] test_linear_lift_solves_point_paths")
    test_product_lift_round_trip()
    print("[PASS] test_product_lift_round_trip")
    test_mccormick_envelope_holds_at_real_points()
    print("[PASS] test_mccormick_envelope_holds_at_real_points")
    test_product_lift_fails_closed()
    print("[PASS] test_product_lift_fails_closed")
    test_product_substitution_keeps_points_real()
    print("[PASS] test_product_substitution_keeps_points_real")
    test_mccormick_box_forms_hold_at_real_points()
    print("[PASS] test_mccormick_box_forms_hold_at_real_points")
    test_lifted_conditions_fail_closed()
    print("[PASS] test_lifted_conditions_fail_closed")
    test_rlt_forms_are_products_at_real_points()
    print("[PASS] test_rlt_forms_are_products_at_real_points")
    test_lift_key_prefers_the_whole_region()
    print("[PASS] test_lift_key_prefers_the_whole_region")
    test_point_paths_resume_the_enumeration()
    print("[PASS] test_point_paths_resume_the_enumeration")
    require_contract("psc.poly_line, the polynomial line mode of Theorem K's tail cells: polynomial products and sums evaluate as the products of their affine factors on [0, 3]^3, poly_nonneg_under is sound under every pair of assumptions with coefficients in -1..1 on [0, 5]^2 for products U V + W and (U V + W) U, vanishing needs both signs, and verify_witness_poly agrees with verify_witness_line on the line-mode family (z^a y^b, y^(b+1) z^(a+1)) and on its single-offset perturbations, the path holding at every point of [0, 4]^2 once instantiated; the point-path enumeration returns only verified paths, and solve_lift solves some to a path with a zero end offset that verify_witness_poly accepts on its carved region and that holds at every point of [0, 5]^2 inside it; psc.product_lift makes A + B e affine over (n, q) with q_j = n_j e, agreeing with the polynomial at every real point of [0, 4]^3 and lifting the zy|yz quantities 2a - 2b + ae and f(-1) exactly, its McCormick forms equal (n_j - lo_j)(e - lo_e) >= 0 at every real point above each lower bound in 0..2, and any other degree-2 monomial, any degree 3, a variable past the lift or an absent product raises; product_substitution keeps every affine form over (n, q) equal at corresponding real points of [0, 3]^3 through n_k := constant, shift or affine combination and e := c + lam e, refusing e := e + n_0 and a replacement naming a product coordinate, the box McCormick envelope (both bounds where present) is >= 0 at every real point of its box, and lifted conditions are proved by their (n, q) forms, refusing n_0 n_1 and needing the lifted form to vanish; rlt_forms equals (e - lo_e) g and (hi_e - e) g at every real point of [0, 4]^3 for every form g over n with constant in -2..2 and coefficients in -1..1 (lo_e in 0..2), only the (e - lo_e) g form when e is unbounded, raising on a form naming a product coordinate or an n_k whose q_k is not in the lift; probe_points returns real points of their region, and lift_key ranks a lift with a zero end offset above one vanishing on a slice, and the smaller offsets first at equal extent, whole_region_lift holding for the zero end offsets and not for the slice, nor for a zero end offset carved by a form failing at a probe point; at the line-mode family's points (1, 2) and (2, 1) the point-path enumeration yields 264 and 216 verified level-4 paths (20 and 15 distinct) in 20,000 nodes and the first 120 and 40 of them (as many distinct) in 12,000, the first node to close a path closing the 8 pinned paths, PointPaths yields them in the same order, and a path cap k in 0..24 keeps the first 8 ceil(k / 8) of them (none at k = 0)")
