"""Exact regressions for the symbolic cone engine (psc.symbolic_cone) and the
class B sector certificate (class_b_cone_certificate).

docs/p1b-symbolic-cone-2026-10-08.md. The region sign reader is checked on a
positive polynomial that needs Polya's multiplier and on one that changes sign,
signs at beta against concrete exact signs, the cone engine against Theorem L's
line, and the sector cover and its coverage pinned.
"""

from std.testing import assert_equal, assert_false, assert_true
from finite_linear_algebra.scalar import q_int
from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from mojo_smoke.claims import require_contract
from psc.symbolic_cone import (
    rouche_disc,
    Region,
    certify_cone,
)
from psc.param_poly import (
    qx_add,
    qx_affine2,
    qx_at,
    qx_const,
    qx_mul,
    qx_sub,
    tp_at_q,
    tp_const,
    tp_norm,
    tp_sub,
    tp_t,
)
from psc.symbolic_line import Eventual, LineField
from class_b_cone_certificate import (
    Aff,
    CoverTally,
    Family,
    class_b_cone,
    cover,
    contains,
    coverage_gaps,
    minus_branch,
    plus_branch,
)
from psc.pisot import CubicScreen


def test_region_signs() raises:
    var region = Region(0, 0)
    # s1^2 - s1 s2 + s2^2 + 1 > 0: a negative coefficient, cleared by Polya's multiplier
    var s1 = qx_affine2(0, 0, 1)
    var s2 = qx_affine2(0, 1, 0)
    var d = qx_sub(s1, s2)
    var f = qx_add(qx_add(qx_mul(d, d), qx_mul(s1, s2)), qx_const(1))
    assert_equal(region.sign(f), 1)
    assert_true(region.polya >= 1)
    assert_equal(region.try_sign(d), 2)  # changes sign: not certified
    assert_equal(region.sign(qx_const(-3)), -1)
    var at5 = Region(5, 0)
    assert_equal(at5.try_sign(qx_affine2(-5, 0, 1)), 2)  # s1 - 5 vanishes on the boundary: not strict
    var at6 = Region(6, 0)
    assert_equal(at6.sign(qx_affine2(-5, 0, 1)), 1)


def test_signs_at_beta_agree_with_concrete_signs() raises:
    """Sector A+: q + 2 < beta < q + 4 on the region, and the parametric signs equal
    the exact signs at a member."""
    var f = Family("A+", Aff(11, 2, 1), Aff(6, 1, 1), Aff(7, 1, 1), 0, 0)
    var cone = class_b_cone(f)
    var region = Region(2, 2)
    var cert = certify_cone(cone, region)
    assert_true(cert.holds)
    var below = tp_sub(tp_t(), tp_const(qx_affine2(8, 1, 1)))  # beta - (q + 2) > 0
    var above = tp_sub(tp_t(), tp_const(qx_affine2(10, 1, 1)))  # beta - (q + 4) < 0
    assert_equal(cone.sign_at_beta(below, region), 1)
    assert_equal(cone.sign_at_beta(above, region), -1)
    var field = LineField(tp_at_q(cone.chi, 4, 9))
    var ev = Eventual()
    assert_equal(field.sign_at_beta(tp_at_q(below, 4, 9), ev), 1)
    assert_equal(field.sign_at_beta(tp_at_q(above, 4, 9), ev), -1)


def test_asymmetric_corners_and_family_axes() raises:
    """Boundary zeros refuse strict certification; s1 = b and s2 = a."""
    var region = Region(2, 5)
    assert_equal(region.try_sign(qx_affine2(-2, 0, 1)), 2)  # s1 - 2
    assert_equal(region.sign(qx_affine2(-4, 1, 0)), 1)  # s2 - 4
    assert_equal(region.try_sign(qx_affine2(-5, 1, 0)), 2)  # s2 - 5
    assert_equal(region.sign(qx_affine2(-1, 0, 1)), 1)  # s1 - 1
    var reverse = Region(5, 2)
    assert_equal(reverse.sign(qx_affine2(-2, 0, 1)), 1)
    assert_equal(reverse.try_sign(qx_affine2(-4, 1, 0)), 2)
    var aff = Aff(5, 7, 11)
    assert_true(qx_at(aff.poly(), 3, 2).eq(q_int(52)))
    for pt in [(0, 5), (7, 0), (2, 9), (9, 2)]:
        assert_true(qx_at(aff.poly(), pt[1], pt[0]).eq(q_int(aff.at(pt[0], pt[1]))))
        assert_true(qx_at(aff.fix1(2).poly(), pt[1], 0).eq(q_int(aff.at(2, pt[1]))))
        assert_true(qx_at(aff.fix2(5).poly(), 0, pt[0]).eq(q_int(aff.at(pt[0], 5))))
    var f = Family("A+", Aff(11, 2, 1), Aff(6, 1, 1), Aff(7, 1, 1), 0, 0)
    var cone = class_b_cone(f)
    for pt in [(2, 5), (5, 2), (9, 4)]:
        var coeff = Mat3(substitution_incidence(f.sigma(pt[0], pt[1]))).charpoly()
        for k in range(4):
            assert_true(qx_at(cone.chi[k], pt[1], pt[0]).eq(q_int(coeff[k])))
    assert_false(qx_at(cone.chi[1], 2, 5).eq(qx_at(cone.chi[1], 5, 2)))


def test_rouche_puts_two_roots_in_the_disc() raises:
    """On sector A+, `|c2| - 1 - |c1| - |c0| = j - 4 >= 1`: Rouche certifies the
    two non-Perron roots in the open disc with plain region signs. With
    `c2 = -s1`, `c1 = s2`, `c0 = -2` the margin `s1 - s2 - 3` changes sign on
    every region, so Rouche declines and the caller falls back to Jury."""
    var cone = class_b_cone(Family("A+", Aff(11, 2, 1), Aff(6, 1, 1), Aff(7, 1, 1), 0, 0))
    var region = Region(2, 2)
    assert_true(rouche_disc(cone.chi, region))
    var mixed = tp_norm([qx_const(-2), qx_affine2(0, 1, 0), qx_affine2(0, 0, -1), qx_const(1)])
    var wide = Region(4, 4)
    assert_false(rouche_disc(mixed, wide))


def test_a_family_off_the_class_is_refused() raises:
    """`p = q` violates Lemma P1, and the cone is not certified PIP."""
    var f = Family("p=q", Aff(0, 1, 0), Aff(0, 1, 0), Aff(1, 1, 0), 0, 0)
    var region = Region(4, 0)
    var refused: Bool
    try:
        refused = not certify_cone(class_b_cone(f), region).holds
    except:
        refused = True
    assert_true(refused)


def test_the_cone_engine_reproduces_theorem_l() raises:
    var screen = CubicScreen()
    var tally = CoverTally()
    cover(Family("C+2", Aff(2, 2, 0), Aff(0, 1, 0), Aff(1, 1, 0), 0, 0), screen, tally)
    assert_equal(tally.regions, 1)
    assert_equal(tally.largest, 119)
    assert_equal(tally.finite, 6)


def test_the_branch_decompositions_cover_their_regions() raises:
    assert_equal(coverage_gaps(plus_branch(), True, 200), 0)
    assert_equal(coverage_gaps(minus_branch(), False, 200), 0)


def test_membership_is_solved_exactly() raises:
    """Far from the apex, with no search bound: (1500, 1000, 1001) is A+ at s = (495, 499)."""
    var a = Family("A+", Aff(11, 2, 1), Aff(6, 1, 1), Aff(7, 1, 1), 0, 0)
    assert_true(contains(a, 1500, 1000, 1001))
    assert_false(contains(a, 1500, 1000, 999))  # wrong branch
    assert_false(contains(a, 2000, 1000, 1001))  # j = q: outside the sector
    var line = Family("C+2", Aff(2, 2, 0), Aff(0, 1, 0), Aff(1, 1, 0), 0, 0)
    assert_true(contains(line, 2002, 1000, 1001))
    assert_false(contains(line, 2003, 1000, 1001))


def test_sector_a_plus() raises:
    var screen = CubicScreen()
    var tally = CoverTally()
    cover(Family("A+", Aff(11, 2, 1), Aff(6, 1, 1), Aff(7, 1, 1), 0, 0), screen, tally)
    assert_equal(tally.regions, 5)
    assert_equal(tally.finite, 4)
    assert_equal(tally.largest, 74)


def main() raises:
    test_region_signs()
    print("[PASS] test_region_signs")
    test_asymmetric_corners_and_family_axes()
    print("[PASS] test_asymmetric_corners_and_family_axes")
    require_contract("Theorem C coordinate regression: Region(2, 5) and Region(5, 2) distinguish strict positive signs from boundary zeros and sign changes; cone Aff/fix1/fix2 evaluate on the intended axis; asymmetric class-B characteristic polynomials match the concrete integer incidence matrix under (a, b) = (s2, s1)")
    test_signs_at_beta_agree_with_concrete_signs()
    print("[PASS] test_signs_at_beta_agree_with_concrete_signs")
    test_rouche_puts_two_roots_in_the_disc()
    print("[PASS] test_rouche_puts_two_roots_in_the_disc")
    test_a_family_off_the_class_is_refused()
    print("[PASS] test_a_family_off_the_class_is_refused")
    test_the_cone_engine_reproduces_theorem_l()
    print("[PASS] test_the_cone_engine_reproduces_theorem_l")
    test_the_branch_decompositions_cover_their_regions()
    print("[PASS] test_the_branch_decompositions_cover_their_regions")
    test_membership_is_solved_exactly()
    print("[PASS] test_membership_is_solved_exactly")
    test_sector_a_plus()
    print("[PASS] test_sector_a_plus")
    require_contract("Symbolic cone certificate (class B sectors): region signs certified by shifted coefficients with Polya's multiplier, a sign-changing polynomial left undecided; parametric signs at beta on certified brackets agree with exact signs at a member; Rouche (|c2| > 1 + |c1| + |c0|) certifies the disc on sector A+ and declines a sign-changing margin; a p = q family is refused; the cone engine reproduces Theorem L's 119-vertex line from q >= 6; the two branch decompositions leave no gap up to q = 200, family membership solved exactly; sector A+ (q + 5 <= p <= 2q - 1, r = q + 1) is covered by 5 symbolic regions of 74 vertices and 4 exact members, every vertex hitting")
