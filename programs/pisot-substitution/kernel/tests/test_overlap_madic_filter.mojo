"""Exact regressions for the strict-zipper M-adic prefix filter."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_contract
from psc.overlap_madic_filter import (
    audit_madic_zero_class,
    madic_zero_class_candidates,
    zero_class_survival_proves_hit,
)


def determinant_two_sigma() -> List[List[Int]]:
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2, 1]
    var a2: List[Int] = [0, 0, 1]
    var sigma = List[List[Int]]()
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def tribonacci_sigma() -> List[List[Int]]:
    var a0: List[Int] = [0, 1]
    var a1: List[Int] = [0, 2]
    var a2: List[Int] = [0]
    var sigma = List[List[Int]]()
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def test_nonunit_filter_is_nontrivial_on_golden_regression() raises:
    # At level two the two inflated words have lengths 7 and 5, hence 35
    # occurrence-labelled proper-prefix pairs. Exactly 11 have difference in
    # M^2 Z^3. This is a finite-place compatibility filter only.
    var audit = audit_madic_zero_class(determinant_two_sigma(), 1, 2, 2, 100)
    assert_equal(audit.top_prefix_count, 7)
    assert_equal(audit.bottom_prefix_count, 5)
    assert_equal(audit.pair_count, 35)
    assert_equal(audit.zero_class_count, 11)

    var candidates = madic_zero_class_candidates(
        determinant_two_sigma(), 1, 2, 2, 100
    )
    assert_equal(len(candidates), 11)
    for i in range(len(candidates)):
        assert_true(candidates[i].top_position >= 0)
        assert_true(candidates[i].bottom_position >= 0)


def test_unimodular_filter_specializes_to_trivial() raises:
    # det(M)=1 for Tribonacci, so M^m Z^3=Z^3 and every prefix difference
    # survives the finite-cokernel filter, exactly as the theorem requires.
    var audit = audit_madic_zero_class(tribonacci_sigma(), 0, 1, 2, 100)
    assert_equal(audit.top_prefix_count, 4)
    assert_equal(audit.bottom_prefix_count, 3)
    assert_equal(audit.pair_count, 12)
    assert_equal(audit.zero_class_count, 12)


def test_word_cap_refuses_incomplete_filter() raises:
    var caught = False
    try:
        _ = audit_madic_zero_class(determinant_two_sigma(), 1, 2, 2, 6)
    except:
        caught = True
    assert_true(caught)


def test_zero_class_survival_is_not_a_hit_claim() raises:
    assert_true(not zero_class_survival_proves_hit())


def main() raises:
    test_nonunit_filter_is_nontrivial_on_golden_regression()
    print("[PASS] test_nonunit_filter_is_nontrivial_on_golden_regression")
    test_unimodular_filter_specializes_to_trivial()
    print("[PASS] test_unimodular_filter_specializes_to_trivial")
    test_word_cap_refuses_incomplete_filter()
    print("[PASS] test_word_cap_refuses_incomplete_filter")
    test_zero_class_survival_is_not_a_hit_claim()
    print("[PASS] test_zero_class_survival_is_not_a_hit_claim")
    print("4 strict-zipper M-adic filter tests passed.")
    require_contract("strict-zipper level-m hit implies zero class in Z^3 / M^m Z^3")
