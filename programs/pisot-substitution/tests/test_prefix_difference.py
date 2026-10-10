import pytest

from psc_research.bpa import build_bpa, coincidence_boundaries
from psc_research.examples import EXAMPLES
from psc_research.prefix_difference import (
    aligned_zero_return_source_cut,
    component_block_bound,
    image_prefix_lengths,
    inflated_prefix_lift,
    possible_local_corrections,
    source_offset_bound_from_corrections,
    strict_child_closed,
    verify_uniform_return_gap,
    zero_return_lifts,
)


NON_PISOT_STRICT = {1: (2,), 2: (1, 2, 3), 3: (2,)}
STRICT_COMPONENT = (
    ((1, 2), (2, 1)),
    ((2, 3), (3, 2)),
)


def test_exact_inflation_identity_on_named_bpa_states_and_all_output_cuts():
    for sigma in EXAMPLES.values():
        graph = build_bpa(sigma, max_states=2500)
        # This test is about the exact local identity, not exhaustive census
        # coverage. A deterministic prefix of the sorted state set exercises
        # many different image-length and source-index misalignments cheaply.
        for state in sorted(graph)[:40]:
            u, v = state
            total = sum(len(sigma[a]) for a in u)
            assert total == sum(len(sigma[a]) for a in v)
            for cut in range(total + 1):
                lift = inflated_prefix_lift(sigma, state, cut)
                assert sum(lift.source_difference) == lift.source_index_offset


def test_prefix_lift_rejects_unbalanced_state():
    sigma = EXAMPLES["tribonacci"]
    with pytest.raises(ValueError, match="balanced state"):
        inflated_prefix_lift(sigma, ((1,), (2,)), 0)


def test_zero_return_ancestry_uses_finite_local_correction_alphabet():
    for sigma in EXAMPLES.values():
        correction_alphabet = set(possible_local_corrections(sigma))
        offset_bound = source_offset_bound_from_corrections(sigma)
        graph = build_bpa(sigma, max_states=2500)
        for state in sorted(graph)[:80]:
            for lift in zero_return_lifts(sigma, state):
                assert lift.is_zero_return
                assert lift.local_difference in correction_alphabet
                assert abs(lift.source_index_offset) <= offset_bound
                assert sum(lift.source_difference) == lift.source_index_offset


def test_doubly_source_aligned_zero_returns_are_exactly_inherited_cuts():
    for sigma in EXAMPLES.values():
        graph = build_bpa(sigma, max_states=2500)
        for state in sorted(graph)[:80]:
            u, v = state
            old_cuts = set(coincidence_boundaries(u, v, 3))
            upos = image_prefix_lengths(sigma, u)
            inherited_output = {upos[k] for k in old_cuts}
            for lift in zero_return_lifts(sigma, state):
                source_cut = aligned_zero_return_source_cut(sigma, state, lift.output_cut)
                assert (source_cut is not None) == (lift.output_cut in inherited_output)
                if source_cut is not None:
                    assert source_cut in old_cuts
                    assert lift.top_source_index == source_cut
                    assert lift.bottom_source_index == source_cut
                    assert lift.top_offset == 0
                    assert lift.bottom_offset == 0
                    assert lift.source_difference == (0, 0, 0)
                    assert lift.local_difference == (0, 0, 0)


def test_interior_zero_returns_of_irreducible_parent_are_misaligned_somewhere():
    # Every BPA vertex is irreducible by construction. Therefore its only old
    # zero returns are the two endpoints. Any interior cut created in sigma(T)
    # is newborn and cannot be a source-image boundary on both sides.
    for sigma in EXAMPLES.values():
        graph = build_bpa(sigma, max_states=2500)
        for state in sorted(graph)[:80]:
            u, v = state
            assert coincidence_boundaries(u, v, 3) == [0, len(u)]
            total = sum(len(sigma[a]) for a in u)
            for lift in zero_return_lifts(sigma, state):
                if 0 < lift.output_cut < total:
                    assert not lift.source_aligned_on_both_sides
                    assert aligned_zero_return_source_cut(sigma, state, lift.output_cut) is None


def test_nonpisot_negative_control_is_strict_child_closed():
    assert strict_child_closed(NON_PISOT_STRICT, STRICT_COMPONENT)
    assert component_block_bound(STRICT_COMPONENT) == 2


def test_strict_child_closed_rejects_unbalanced_vacuous_component():
    sigma = {1: (1, 1), 2: (2, 1)}
    comp = [((1, 1, 2), (2, 1, 2))]
    assert not strict_child_closed(sigma, comp)
    with pytest.raises(ValueError, match="balanced"):
        verify_uniform_return_gap(sigma, comp, max_depth=1)


def test_strict_component_has_uniform_zero_return_gap_across_iterates():
    # The theorem is not Pisot-specific. This negative-control component is
    # genuinely closed and nonproductive, so it is a good calibration that
    # dense zero returns alone do not prove C4.
    assert verify_uniform_return_gap(NON_PISOT_STRICT, STRICT_COMPONENT, max_depth=6)
