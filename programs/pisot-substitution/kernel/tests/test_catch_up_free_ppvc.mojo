"""Exact regressions for the catch-up-free PPVC census (catch_up_free_ppvc_census).

docs/p1b-catch-up-free-ppvc-2026-10-07.md. PPVC is decided by the canonical
box graph (`psc.vertex_coincidence`), so a failing member would be a verdict;
the census raises on one, and on a capped graph. These pins fix the members the
note names, the small-bound census, and the refusals.
"""

from std.testing import assert_equal, assert_false, assert_raises, assert_true
from catch_up_free_ppvc_census import (
    FAMILY_E,
    FAMILY_K,
    FAMILY_SWAP,
    FAMILY_Y,
    census,
    in_certified_domain,
    words_over_yz,
)
from a1_normal_form_census import CLASS_B, CLASS_D, class_member
from mojo_smoke.claims import require_contract
from psc.vertex_coincidence import decide_vertex_coincidence


def test_named_members_hold_at_the_recorded_depth() raises:
    """Class D (1,0,0) is the deepest Theorem E member at bound 4; class B
    (2,1,2) is a bulk member at depth 4."""
    var d = decide_vertex_coincidence(class_member(CLASS_D, 1, 0, 0))
    assert_true(d.holds)
    assert_false(d.capped)
    assert_equal(d.deepest, 13)
    var b = decide_vertex_coincidence(class_member(CLASS_B, 2, 1, 2))
    assert_true(b.holds)
    assert_equal(b.deepest, 4)


def test_the_bound_two_census_holds_on_every_family() raises:
    var c = census(2)
    assert_equal(c.families[FAMILY_E].decided, 17)
    assert_equal(c.families[FAMILY_SWAP].decided, 40)
    assert_equal(c.families[FAMILY_Y].decided, 6)
    assert_equal(c.families[FAMILY_K].decided, 5)
    assert_equal(c.families[FAMILY_E].deepest, 13)
    assert_equal(c.families[FAMILY_SWAP].deepest, 14)
    for f in range(4):
        assert_equal(c.families[f].skipped, 0)


def test_words_and_domain_helpers() raises:
    assert_equal(len(words_over_yz(3)), 15)  # 1 + 2 + 4 + 8
    var long_image: List[List[Int]] = [[0, 2, 2, 2, 2, 2, 1], [1, 0], [1, 2]]
    assert_false(in_certified_domain(long_image))
    assert_true(in_certified_domain(class_member(CLASS_B, 2, 1, 2)))


def test_the_bound_is_refused_rather_than_truncated() raises:
    with assert_raises():
        _ = census(7)
    with assert_raises():
        _ = census(-1)


def main() raises:
    test_named_members_hold_at_the_recorded_depth()
    print("[PASS] test_named_members_hold_at_the_recorded_depth")
    test_the_bound_two_census_holds_on_every_family()
    print("[PASS] test_the_bound_two_census_holds_on_every_family")
    test_words_and_domain_helpers()
    print("[PASS] test_words_and_domain_helpers")
    test_the_bound_is_refused_rather_than_truncated()
    print("[PASS] test_the_bound_is_refused_rather_than_truncated")
    require_contract("Catch-up-free PPVC census (finite, exact): PeriodicPairVertexCoincidence decided by the Proposition V box graph on every PIP |det M| = 2 member of Theorem E's classes A-D, the swap family, Proposition Y's F1/F2 and Theorem K's family; at bound 2 the counts are 17, 40, 6 and 5 decided, none skipped, all holding, deepest first offset-zero depth over recurrent vertices 13 (Theorem E classes) and 14 (swap family); class D (1,0,0) holds at depth 13 and class B (2,1,2) at depth 4; a failing or capped member raises; bounds outside 0..6 are refused")
