"""Regressions for the deterministic sweep layer.

They pin the reproducibility of the pseudo-random source, the agreement of the
generic primitivity decision with the fixed-size three-letter one, the two
budgets of the bounded balanced-pair builder, and the exact tallies of a small
sweep -- so an exploratory search stays replayable and a resource limit stays
distinguishable from a mathematical verdict.
"""

from std.testing import assert_equal, assert_false, assert_true

from finite_linear_algebra.mat3 import Mat3
from psc.bounded_bpa import BUDGET_LENGTH, BUDGET_NONE, BUDGET_STATES, build_bounded
from psc.boundary_sync import (
    SweepConfig,
    component_is_caught,
    component_is_productive,
    is_primitive_substitution,
    produces_single_tile_coincidence,
    random_substitution,
    run_sweep,
    substitution_key,
    synchronizing_cut_count,
)
from mojo_smoke.claims import require_contract, require_claim
from finite_linear_algebra.integer_matrix import is_positive, is_primitive, matmul, wielandt_bound
from psc.pisot import is_primitive as mat3_is_primitive
from psc.prng import SplitMix64
from substitution_dynamics.automaton import build, recurrent_noncoincident_sccs
from substitution_dynamics.substitution import Substitution


def tribonacci() raises -> Substitution:
    var images: List[List[Int]] = [[0, 1], [0, 2], [0]]
    return Substitution.checked(images^)


def test_the_generator_is_reproducible_from_its_seed() raises:
    var left = SplitMix64(1729)
    var right = SplitMix64(1729)
    var other = SplitMix64(1730)
    var differs = False
    for _ in range(64):
        var value = left.next_bits()
        assert_equal(value, right.next_bits())
        differs = differs or value != other.next_bits()
    assert_true(differs)


def test_bounded_draws_stay_inside_their_range() raises:
    var rng = SplitMix64(7)
    var seen_low = False
    var seen_high = False
    for _ in range(512):
        var value = rng.between(2, 4)
        assert_true(value >= 2 and value <= 4)
        seen_low = seen_low or value == 2
        seen_high = seen_high or value == 4
    assert_true(seen_low and seen_high)
    assert_equal(rng.below(1), 0)


def test_generic_primitivity_agrees_with_the_three_letter_kernel() raises:
    """Exhaustive over the 512 zero-one incidence matrices."""
    assert_equal(wielandt_bound(3), 5)
    for code in range(512):
        var entries = List[Int]()
        var rest = code
        for _ in range(9):
            entries.append(rest % 2)
            rest //= 2
        assert_equal(is_primitive(entries, 3), mat3_is_primitive(Mat3(entries)))
    var positive: List[Int] = [1, 1, 1, 1]
    assert_true(is_positive(positive))
    var identity: List[Int] = [1, 0, 0, 1]
    assert_equal(matmul(identity, identity, 2), identity)


def test_the_bounded_builder_matches_the_canonical_one_when_complete() raises:
    var sigma = tribonacci()
    var canonical = build(sigma, 20000)
    var bounded = build_bounded(sigma, 20000, 20000)
    assert_true(bounded.complete())
    assert_equal(bounded.exhausted, BUDGET_NONE)
    assert_false(bounded.graph.capped)
    assert_equal(bounded.graph.size(), canonical.size())
    for i in range(canonical.size()):
        assert_equal(bounded.graph.states[i].key(), canonical.states[i].key())
        assert_equal(bounded.graph.adj[i], canonical.adj[i])
    assert_true(bounded.longest_state >= 1)


def test_each_budget_reports_itself_and_fails_closed() raises:
    var sigma = tribonacci()
    var few_states = build_bounded(sigma, 1, 20000)
    assert_false(few_states.complete())
    assert_equal(few_states.exhausted, BUDGET_STATES)
    assert_true(few_states.graph.capped)
    var short_states = build_bounded(sigma, 20000, 1)
    assert_false(short_states.complete())
    assert_equal(short_states.exhausted, BUDGET_LENGTH)
    assert_true(short_states.graph.capped)


def test_productivity_and_catching_agree_on_tribonacci() raises:
    var sigma = tribonacci()
    assert_true(is_primitive_substitution(sigma))
    assert_equal(substitution_key(sigma), "01/02/0")
    var a = build(sigma, 20000)
    var comps = recurrent_noncoincident_sccs(a)
    assert_true(len(comps) > 0)
    for ci in range(len(comps)):
        assert_true(component_is_productive(sigma, a, comps[ci], 1))
        assert_true(component_is_caught(sigma, a, comps[ci], 1))
    ref seed = a.states[0]
    assert_true(produces_single_tile_coincidence(sigma, seed, 1))
    assert_true(synchronizing_cut_count(sigma, seed, 1) > 0)


def test_the_sweep_is_reproducible_and_misses_nothing_productive() raises:
    var sizes: List[Int] = [3, 4]
    var config = SweepConfig(1729, 120, sizes^, 2, 4, 2000, 20000, 1)
    var first = run_sweep(config)
    var second = run_sweep(config)
    assert_equal(first.trials, second.trials)
    assert_equal(first.primitive, second.primitive)
    assert_equal(first.components, second.components)
    assert_equal(first.productive, second.productive)
    assert_equal(first.caught, second.caught)
    assert_equal(first.trials, 120)
    assert_equal(first.primitive, 76)
    assert_equal(first.capped, 0)
    assert_equal(first.length_exhausted, 58)
    assert_equal(first.components, 19)
    assert_equal(first.productive, 19)
    assert_equal(first.caught, 19)
    assert_equal(first.productive_but_missed, 0)
    # An inconclusive specimen contributes no component, so the conclusive
    # specimens are exactly the primitive ones neither budget stopped.
    assert_true(first.primitive > first.length_exhausted + first.capped)


def test_a_random_substitution_is_well_formed() raises:
    var rng = SplitMix64(99)
    for _ in range(32):
        var sigma = random_substitution(rng, 3, 2, 4)
        assert_equal(sigma.size, 3)
        for a in range(3):
            assert_true(len(sigma.images[a]) >= 2 and len(sigma.images[a]) <= 4)
            for j in range(len(sigma.images[a])):
                assert_true(sigma.images[a][j] >= 0 and sigma.images[a][j] < 3)


def main() raises:
    test_the_generator_is_reproducible_from_its_seed()
    print("[PASS] test_the_generator_is_reproducible_from_its_seed")
    test_bounded_draws_stay_inside_their_range()
    print("[PASS] test_bounded_draws_stay_inside_their_range")
    test_generic_primitivity_agrees_with_the_three_letter_kernel()
    print("[PASS] test_generic_primitivity_agrees_with_the_three_letter_kernel")
    test_the_bounded_builder_matches_the_canonical_one_when_complete()
    print("[PASS] test_the_bounded_builder_matches_the_canonical_one_when_complete")
    test_each_budget_reports_itself_and_fails_closed()
    print("[PASS] test_each_budget_reports_itself_and_fails_closed")
    test_productivity_and_catching_agree_on_tribonacci()
    print("[PASS] test_productivity_and_catching_agree_on_tribonacci")
    test_the_sweep_is_reproducible_and_misses_nothing_productive()
    print("[PASS] test_the_sweep_is_reproducible_and_misses_nothing_productive")
    test_a_random_substitution_is_well_formed()
    print("[PASS] test_a_random_substitution_is_well_formed")
    print("8 boundary-synchronization tests passed.")
    require_claim("SinkSCCReduction")
    require_contract("the seeded sweep is reproducible from its seed alone, and an exhausted budget reports itself rather than a verdict")
