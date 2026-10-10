from psc_research.endpoint_core import (
    all_maps,
    canonical_map,
    classify_maps,
    functional_cycle_lengths,
    is_recurrent_pair,
    nonsynchronizing_pairs,
    recurrent_nonsynchronizing_core,
    steps_to_recurrent_core,
    synchronizes,
)


def test_three_letter_maps_have_seven_conjugacy_classes():
    classes = classify_maps(3)
    assert [item.representative for item in classes] == [
        (0, 0, 0),
        (0, 0, 1),
        (0, 0, 2),
        (0, 1, 2),
        (0, 2, 1),
        (1, 0, 0),
        (1, 2, 0),
    ]
    assert [item.size for item in classes] == [3, 6, 6, 1, 3, 6, 2]
    assert sum(item.size for item in classes) == 27


def test_only_two_three_letter_map_classes_are_globally_synchronizing():
    classes = classify_maps(3)
    syncing = [item.representative for item in classes if item.globally_synchronizing]
    assert syncing == [(0, 0, 0), (0, 0, 1)]


def test_recurrent_off_diagonal_cores_are_exact():
    expected = {
        (0, 0, 0): (),
        (0, 0, 1): (),
        (0, 0, 2): ((0, 2), (2, 0)),
        (0, 1, 2): ((0, 1), (0, 2), (1, 0), (1, 2), (2, 0), (2, 1)),
        (0, 2, 1): ((0, 1), (0, 2), (1, 0), (1, 2), (2, 0), (2, 1)),
        (1, 0, 0): ((0, 1), (1, 0)),
        (1, 2, 0): ((0, 1), (0, 2), (1, 0), (1, 2), (2, 0), (2, 1)),
    }
    assert {
        item.representative: item.recurrent_core for item in classify_maps(3)
    } == expected


def test_transient_nonsynchronizing_pairs_are_not_in_recurrent_core():
    # 0 and 2 are distinct fixed points; 1 is a leaf flowing into 0.
    h = (0, 0, 2)
    assert not synchronizes(h, 1, 2)
    assert (1, 2) in nonsynchronizing_pairs(h)
    assert not is_recurrent_pair(h, (1, 2))
    assert is_recurrent_pair(h, (0, 2))
    assert recurrent_nonsynchronizing_core(h) == ((0, 2), (2, 0))
    assert steps_to_recurrent_core(h, 1, 2) == 1
    assert steps_to_recurrent_core(h, 0, 2) == 0


def test_every_three_letter_nonsynchronizing_pair_enters_core_within_one_step():
    observed = set()
    for h in all_maps(3):
        for a in range(3):
            for b in range(3):
                if a == b:
                    continue
                steps = steps_to_recurrent_core(h, a, b)
                if steps is not None:
                    assert steps <= 1
                    observed.add(steps)
    assert observed == {0, 1}


def test_canonicalization_is_invariant_under_relabeling():
    # 0 <-> 1 with 2 flowing into 0; the second map is a relabeling of it.
    assert canonical_map((1, 0, 0)) == (1, 0, 0)
    assert canonical_map((2, 2, 1)) == (1, 0, 0)


def test_functional_cycle_lengths_distinguish_core_cycle_shapes():
    assert functional_cycle_lengths((0, 0, 0)) == (1,)
    assert functional_cycle_lengths((0, 0, 2)) == (1, 1)
    assert functional_cycle_lengths((0, 1, 2)) == (1, 1, 1)
    assert functional_cycle_lengths((0, 2, 1)) == (1, 2)
    assert functional_cycle_lengths((1, 0, 0)) == (2,)
    assert functional_cycle_lengths((1, 2, 0)) == (3,)
