"""Canonical Mojo regressions for labelled G1b-2 first-return words."""

from std.testing import assert_equal, assert_false, assert_true
from mojo_smoke.claims import require_claim
from psc.renewal import (
    Diff3,
    label_bottom,
    label_top,
    labelled_return_word,
    local_types,
    max_l1_defect,
    pack_step_label,
    same_labelled_return,
    same_unlabelled_path,
    strict_first_return_word,
)
from psc.words import Pair


def collision_pair_a() -> Pair:
    # 001 / 100. Middle transition is diagonal 0/0.
    var u: List[Int] = [0, 0, 1]
    var v: List[Int] = [1, 0, 0]
    return Pair(u, v)


def collision_pair_b() -> Pair:
    # 021 / 120. Same cumulative differences; middle transition is diagonal 2/2.
    var u: List[Int] = [0, 2, 1]
    var v: List[Int] = [1, 2, 0]
    return Pair(u, v)


def test_step_label_roundtrip() raises:
    for a in range(3):
        for b in range(3):
            var code = pack_step_label(a, b)
            assert_equal(label_top(code), a)
            assert_equal(label_bottom(code), b)


def test_unlabelled_path_collision_keeps_distinct_labels() raises:
    var a = strict_first_return_word(collision_pair_a())
    var b = strict_first_return_word(collision_pair_b())

    assert_true(a.first_return)
    assert_true(b.first_return)
    assert_equal(a.length(), 3)
    assert_equal(b.length(), 3)
    assert_true(same_unlabelled_path(a, b))
    assert_false(same_labelled_return(a, b))

    # d_0=0, d_1=d_2=(1,-1,0), d_3=0 for both words.
    assert_equal(a.defect_at(0), Diff3(0, 0, 0))
    assert_equal(a.defect_at(1), Diff3(1, -1, 0))
    assert_equal(a.defect_at(2), Diff3(1, -1, 0))
    assert_equal(a.defect_at(3), Diff3(0, 0, 0))
    assert_equal(b.path, a.path)

    # The zero-increment middle label is the lost datum: 0/0 versus 2/2.
    assert_equal(a.labels, [1, 0, 3])
    assert_equal(b.labels, [1, 8, 3])
    assert_equal(max_l1_defect(a), 2)
    assert_equal(max_l1_defect(b), 2)


def test_local_types_preserve_two_transition_window() raises:
    var a = strict_first_return_word(collision_pair_a())
    var b = strict_first_return_word(collision_pair_b())
    var ta = local_types(a)
    var tb = local_types(b)
    assert_equal(len(ta), 2)
    assert_equal(len(tb), 2)
    assert_equal(ta[0].defect, tb[0].defect)
    assert_equal(ta[0].left_label, tb[0].left_label)
    assert_true(ta[0].right_label != tb[0].right_label)


def test_empty_pair_is_balanced_but_not_a_first_return() raises:
    var u = List[Int]()
    var v = List[Int]()
    var p = Pair(u, v)
    var word = labelled_return_word(p)
    assert_true(word.balanced())
    assert_false(word.first_return)
    assert_equal(word.length(), 0)

    var caught = False
    try:
        _ = strict_first_return_word(p)
    except:
        caught = True
    assert_true(caught)


def test_reducible_balanced_pair_is_not_a_strict_first_return() raises:
    var u: List[Int] = [0, 1]
    var v: List[Int] = [0, 1]
    var p = Pair(u, v)
    var word = labelled_return_word(p)
    assert_true(word.balanced())
    assert_false(word.first_return)

    var caught = False
    try:
        _ = strict_first_return_word(p)
    except:
        caught = True
    assert_true(caught)


def test_unbalanced_pair_fails_closed_for_strict_contract() raises:
    var u: List[Int] = [0]
    var v: List[Int] = [1]
    var p = Pair(u, v)
    var word = labelled_return_word(p)
    assert_false(word.balanced())
    assert_false(word.first_return)

    var caught = False
    try:
        _ = strict_first_return_word(p)
    except:
        caught = True
    assert_true(caught)


def main() raises:
    test_step_label_roundtrip()
    print("[PASS] test_step_label_roundtrip")
    test_unlabelled_path_collision_keeps_distinct_labels()
    print("[PASS] test_unlabelled_path_collision_keeps_distinct_labels")
    test_local_types_preserve_two_transition_window()
    print("[PASS] test_local_types_preserve_two_transition_window")
    test_empty_pair_is_balanced_but_not_a_first_return()
    print("[PASS] test_empty_pair_is_balanced_but_not_a_first_return")
    test_reducible_balanced_pair_is_not_a_strict_first_return()
    print("[PASS] test_reducible_balanced_pair_is_not_a_strict_first_return")
    test_unbalanced_pair_fails_closed_for_strict_contract()
    print("[PASS] test_unbalanced_pair_fails_closed_for_strict_contract")
    print("6 labelled-renewal Mojo tests passed.")
    require_claim("G1b2RenewalFiniteness")
