from psc_research.legal_cut_context import (
    SourceSupertileBlock,
    bad_context_position_upper_bound,
    context_inside_one_source_supertile,
    count_forces_single_supertile_context,
    level_n_source_blocks,
    single_supertile_zero_returns,
    zero_return_count_lower_bound,
)
from psc_research.examples import EXAMPLES


NON_PISOT_STRICT = {1: (2,), 2: (1, 2, 3), 3: (2,)}


def test_level_n_source_blocks_are_exact_for_tribonacci_illegal_swap_seed():
    sigma = EXAMPLES["tribonacci"]
    assert level_n_source_blocks(sigma, (2, 3), 3) == (
        SourceSupertileBlock(0, 2, 0, 6),
        SourceSupertileBlock(1, 3, 6, 10),
    )
    assert level_n_source_blocks(sigma, (3, 2), 3) == (
        SourceSupertileBlock(0, 3, 0, 4),
        SourceSupertileBlock(1, 2, 4, 10),
    )


def test_context_containment_uses_full_radius_on_both_sides():
    blocks = (
        SourceSupertileBlock(0, 1, 0, 6),
        SourceSupertileBlock(1, 2, 6, 10),
    )
    assert context_inside_one_source_supertile(blocks, 2, 2)
    assert context_inside_one_source_supertile(blocks, 4, 2)
    assert not context_inside_one_source_supertile(blocks, 5, 2)
    assert not context_inside_one_source_supertile(blocks, 6, 2)
    assert context_inside_one_source_supertile(blocks, 8, 2)


def test_deep_context_can_be_legal_even_when_parent_swap_word_is_not():
    # Tribonacci's language contains neither bigram 23 nor 32, so the seed
    # (23,32) is not itself a pair of legal language words.  Nevertheless at
    # depth 3, zero-return cut 2 has a radius-2 neighborhood contained inside a
    # single level-3 letter supertile on each side.  Under primitivity those
    # neighborhoods are legal hull contexts, so recognizability may be invoked
    # locally there.
    sigma = EXAMPLES["tribonacci"]
    state = ((2, 3), (3, 2))
    assert single_supertile_zero_returns(sigma, state, depth=3, radius=2) == (2,)


def test_counting_bound_is_depth_independent_in_source_word_size():
    state = ((1, 2), (2, 1))
    assert bad_context_position_upper_bound(state, radius=1) == 18
    assert zero_return_count_lower_bound(total_length=256, max_gap=2) == 129
    assert count_forces_single_supertile_context(
        state=state,
        total_length=256,
        max_zero_return_gap=2,
        radius=1,
    )


def test_strict_negative_control_realizes_the_counting_conclusion():
    # The primitive non-Pisot strict component has gap 2 at every depth.  At
    # depth 7 the elementary count already forces legal radius-1 contexts, and
    # direct extraction finds many of them.  This confirms that the lemma is a
    # legality bridge, not a Pisot contradiction by itself.
    state = ((1, 2), (2, 1))
    cuts = single_supertile_zero_returns(
        NON_PISOT_STRICT,
        state,
        depth=7,
        radius=1,
    )
    assert cuts
    assert count_forces_single_supertile_context(
        state=state,
        total_length=256,
        max_zero_return_gap=2,
        radius=1,
    )
