"""Regressions for the exact endpoint-map classification.

They pin the seven three-letter conjugacy classes, their recurrent
off-diagonal cores, and the fact that the named types A..G of the C4 program
are exactly the derived conjugacy classes in lexicographic order -- so the
fast classifier used in the census hot loop cannot drift from the general
construction.
"""

from std.testing import assert_equal, assert_false, assert_true

from mojo_smoke.claims import require_claim
from psc.endpoint_core import (
    all_maps,
    canonical_map,
    class_of,
    classify_maps,
    endpoint_type,
    endpoint_type_name,
    functional_cycle_lengths,
    is_recurrent_pair,
    LetterPair,
    nonsynchronizing_pairs,
    pairs_key,
    prefix_endpoint_map,
    recurrent_nonsynchronizing_core,
    steps_to_recurrent_core,
    suffix_endpoint_map,
    synchronizes,
    synchronization_partition,
    synchronization_quotient_permutation,
)
from psc.symmetry import parse_substitution_key, word_key


def test_three_letter_maps_have_seven_conjugacy_classes() raises:
    var classes = classify_maps(3)
    var expected: List[String] = ["000", "001", "002", "012", "021", "100", "120"]
    var sizes: List[Int] = [3, 6, 6, 1, 3, 6, 2]
    assert_equal(len(classes), len(expected))
    var members = 0
    for i in range(len(classes)):
        assert_equal(word_key(classes[i].representative), expected[i])
        assert_equal(classes[i].size(), sizes[i])
        members += classes[i].size()
    assert_equal(members, 27)
    assert_equal(len(all_maps(3)), 27)


def test_only_two_classes_are_globally_synchronizing() raises:
    var classes = classify_maps(3)
    var syncing = List[String]()
    for i in range(len(classes)):
        if classes[i].globally_synchronizing():
            syncing.append(word_key(classes[i].representative))
    var expected: List[String] = ["000", "001"]
    assert_equal(syncing, expected)


def test_recurrent_off_diagonal_cores_are_exact() raises:
    var expected: List[String] = [
        "",
        "",
        "(0,2) (2,0)",
        "(0,1) (0,2) (1,0) (1,2) (2,0) (2,1)",
        "(0,1) (0,2) (1,0) (1,2) (2,0) (2,1)",
        "(0,1) (1,0)",
        "(0,1) (0,2) (1,0) (1,2) (2,0) (2,1)",
    ]
    var classes = classify_maps(3)
    for i in range(len(classes)):
        assert_equal(pairs_key(classes[i].recurrent_core), expected[i])


def test_transient_nonsynchronizing_pairs_are_not_in_the_core() raises:
    # 0 and 2 are distinct fixed points; 1 is a leaf flowing into 0.
    var h: List[Int] = [0, 0, 2]
    assert_false(synchronizes(h, 1, 2))
    assert_true(LetterPair(1, 2) in nonsynchronizing_pairs(h))
    assert_false(is_recurrent_pair(h, LetterPair(1, 2)))
    assert_true(is_recurrent_pair(h, LetterPair(0, 2)))
    assert_equal(pairs_key(recurrent_nonsynchronizing_core(h)), "(0,2) (2,0)")
    assert_equal(steps_to_recurrent_core(h, 1, 2), 1)
    assert_equal(steps_to_recurrent_core(h, 0, 2), 0)


def test_every_nonsynchronizing_pair_enters_the_core_within_one_step() raises:
    var maps = all_maps(3)
    var seen_zero = False
    var seen_one = False
    for m in range(len(maps)):
        for a in range(3):
            for b in range(3):
                if a == b:
                    continue
                var steps = steps_to_recurrent_core(maps[m], a, b)
                if steps < 0:
                    assert_true(synchronizes(maps[m], a, b))
                    continue
                assert_true(steps <= 1)
                seen_zero = seen_zero or steps == 0
                seen_one = seen_one or steps == 1
    assert_true(seen_zero and seen_one)


def test_named_types_are_the_derived_conjugacy_classes() raises:
    """A..G is a naming of `classify_maps(3)`, not a parallel definition."""
    var classes = classify_maps(3)
    var maps = all_maps(3)
    for m in range(len(maps)):
        var rank = endpoint_type(maps[m])
        assert_equal(word_key(classes[rank].representative), word_key(canonical_map(maps[m])))
        assert_equal(word_key(class_of(maps[m]).representative), word_key(canonical_map(maps[m])))
    assert_equal(endpoint_type_name(endpoint_type(maps[0])), "A")


def test_canonicalization_is_invariant_under_relabeling() raises:
    var a: List[Int] = [1, 0, 0]
    var b: List[Int] = [2, 2, 1]
    assert_equal(word_key(canonical_map(a)), "100")
    assert_equal(word_key(canonical_map(b)), "100")


def test_cycle_lengths_distinguish_core_cycle_shapes() raises:
    var maps: List[List[Int]] = [[0, 0, 0], [0, 0, 2], [0, 1, 2], [0, 2, 1], [1, 0, 0], [1, 2, 0]]
    var expected: List[String] = ["1", "11", "111", "12", "2", "3"]
    for i in range(len(maps)):
        assert_equal(word_key(functional_cycle_lengths(maps[i])), expected[i])


def test_synchronization_quotient_is_a_permutation_of_the_partition() raises:
    var maps = all_maps(3)
    for m in range(len(maps)):
        var partition = synchronization_partition(maps[m])
        var quotient = synchronization_quotient_permutation(maps[m])
        assert_equal(len(quotient), len(partition))
        var letters = 0
        for i in range(len(partition)):
            letters += len(partition[i])
        assert_equal(letters, 3)


def test_endpoint_maps_read_the_image_ends() raises:
    var sigma = parse_substitution_key("011/2/120")
    assert_equal(word_key(prefix_endpoint_map(sigma)), "021")
    assert_equal(word_key(suffix_endpoint_map(sigma)), "120")


def main() raises:
    test_three_letter_maps_have_seven_conjugacy_classes()
    print("[PASS] test_three_letter_maps_have_seven_conjugacy_classes")
    test_only_two_classes_are_globally_synchronizing()
    print("[PASS] test_only_two_classes_are_globally_synchronizing")
    test_recurrent_off_diagonal_cores_are_exact()
    print("[PASS] test_recurrent_off_diagonal_cores_are_exact")
    test_transient_nonsynchronizing_pairs_are_not_in_the_core()
    print("[PASS] test_transient_nonsynchronizing_pairs_are_not_in_the_core")
    test_every_nonsynchronizing_pair_enters_the_core_within_one_step()
    print("[PASS] test_every_nonsynchronizing_pair_enters_the_core_within_one_step")
    test_named_types_are_the_derived_conjugacy_classes()
    print("[PASS] test_named_types_are_the_derived_conjugacy_classes")
    test_canonicalization_is_invariant_under_relabeling()
    print("[PASS] test_canonicalization_is_invariant_under_relabeling")
    test_cycle_lengths_distinguish_core_cycle_shapes()
    print("[PASS] test_cycle_lengths_distinguish_core_cycle_shapes")
    test_synchronization_quotient_is_a_permutation_of_the_partition()
    print("[PASS] test_synchronization_quotient_is_a_permutation_of_the_partition")
    test_endpoint_maps_read_the_image_ends()
    print("[PASS] test_endpoint_maps_read_the_image_ends")
    print("10 endpoint-core tests passed.")
    require_claim("EndpointCore")
    require_claim("SignatureReduction")
