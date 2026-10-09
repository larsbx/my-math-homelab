"""Exact regressions for the contraction-rate depth laws (psc.depth_law)."""

from std.testing import assert_equal
from mojo_smoke.claims import require_contract
from psc.depth_law import MuSquared, judge, standard_laws


def sigma_of(a: List[Int], b: List[Int], c: List[Int]) -> List[List[Int]]:
    var sigma = List[List[Int]]()
    sigma.append(a.copy())
    sigma.append(b.copy())
    sigma.append(c.copy())
    return sigma^


def verdicts(sigma: List[List[Int]], k_v: Int) raises -> List[Int]:
    """Per standard law: 1 holds, -1 violates, 0 undecided."""
    var laws = standard_laws()
    var mu = MuSquared(sigma)
    var out = List[Int]()
    for l in range(len(laws)):
        judge(laws[l], mu, k_v)
        out.append(1 if laws[l].holds == 1 else (-1 if laws[l].violates == 1 else 0))
    return out^


def test_a_fast_contraction_floor_violates_the_ratio_laws() raises:
    """`0 -> 2220, 1 -> 100, 2 -> 0012` (unimodular, mu ~ 0.5098) has
    K_V = 6: K_V log(1/mu) ~ 4.04 exceeds both 3.2 and 4, while the affine
    law holds trivially (K_V <= 7)."""
    var v = verdicts(sigma_of([2, 2, 2, 0], [1, 0, 0], [0, 0, 1, 2]), 6)
    assert_equal(v, [-1, -1, 1])


def test_the_plastic_class_and_the_deepest_length_four_specimen_hold() raises:
    """Plastic number (mu ~ 0.8688, K_V = 14): ratio ~ 1.97; the deepest
    images-of-length-4 specimen `0 -> 001, 1 -> 0200, 2 -> 000` (mu ~ 0.9651,
    K_V = 26): ratio ~ 0.93. Both hold every law."""
    assert_equal(verdicts(sigma_of([1], [2], [0, 1]), 14), [1, 1, 1])
    assert_equal(verdicts(sigma_of([0, 0, 1], [0, 2, 0, 0], [0, 0, 0]), 26), [1, 1, 1])


def test_the_affine_law_is_violated_where_it_should_be() raises:
    """A hypothetical depth makes the affine law fail: the plastic class with
    a hypothetical K_V = 23 would need (23 - 7) log(1/0.8688) ~ 2.25 <= 1."""
    var v = verdicts(sigma_of([1], [2], [0, 1]), 23)
    assert_equal(v[2], -1)


def main() raises:
    test_a_fast_contraction_floor_violates_the_ratio_laws()
    print("[PASS] test_a_fast_contraction_floor_violates_the_ratio_laws")
    test_the_plastic_class_and_the_deepest_length_four_specimen_hold()
    print("[PASS] test_the_plastic_class_and_the_deepest_length_four_specimen_hold")
    test_the_affine_law_is_violated_where_it_should_be()
    print("[PASS] test_the_affine_law_is_violated_where_it_should_be")
    require_contract("depth laws decided exactly from a rational bracket of mu^2: a fast-contraction floor (K_V = 6, mu ~ 0.51) violates K_V <= 3.2/log(1/mu) and 4/log(1/mu); the plastic class (K_V 14) and the deepest length-4 specimen (K_V 26) hold all three; a deficient depth violates K_V <= 7 + 1/log(1/mu)")
