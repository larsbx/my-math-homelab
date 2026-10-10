from psc_research.cut_germ import (
    CutContext,
    cut_context,
    decorated_prefix_ancestry,
    germ_space_upper_bound,
    repeated_germ_level_pairs,
)
from psc_research.examples import EXAMPLES


NON_PISOT_STRICT = {1: (2,), 2: (1, 2, 3), 3: (2,)}
SEED = ((1, 2), (2, 1))


def test_cut_context_is_fixed_width_and_remembers_word_ends():
    word = (1, 2, 3)
    assert cut_context(word, 0, 2) == CutContext((0, 0), (1, 2))
    assert cut_context(word, 1, 2) == CutContext((0, 1), (2, 3))
    assert cut_context(word, 3, 2) == CutContext((2, 3), (0, 0))
    assert cut_context(word, 2, 0) == CutContext((), ())


def test_germ_space_bound_is_finite_and_monotone_in_radius():
    small = germ_space_upper_bound(
        defect_count=7,
        correction_count=5,
        letter_count=3,
        max_image_length=3,
        radius=1,
    )
    large = germ_space_upper_bound(
        defect_count=7,
        correction_count=5,
        letter_count=3,
        max_image_length=3,
        radius=2,
    )
    assert small == 7 * 5 * 9 * 4**4
    assert large == 7 * 5 * 9 * 4**8
    assert large > small


def test_tribonacci_has_repeated_radius1_cut_germ_despite_being_pisot():
    # Pisot + a repeated finite local ancestry state is not itself a
    # contradiction.  This productive legal-seed example repeats the complete
    # radius-1 germ at levels 1 and 4.
    germs = decorated_prefix_ancestry(
        EXAMPLES["tribonacci"],
        SEED,
        depth=6,
        top_cut=51,
        radius=1,
    )
    pairs = repeated_germ_level_pairs(germs)
    assert (1, 4) in pairs
    low = next(item.germ for item in germs if item.level == 1)
    high = next(item.germ for item in germs if item.level == 4)
    assert low == high
    assert low.source_difference == (1, -1, 0)
    assert low.correction == (0, 0, 0)
    assert low.top_offset == 0
    assert low.bottom_offset == 0
    assert low.top_context == CutContext((2,), (1,))
    assert low.bottom_context == CutContext((3,), (1,))


def test_nonpisot_strict_component_has_repeated_misaligned_nonzero_germ():
    # Strict closure + repeated decorated germs is also not enough without the
    # Pisot hypothesis.  At depth 7, cut 10 repeats the same nonzero,
    # doubly-misaligned radius-1 germ at levels 5 and 7.
    germs = decorated_prefix_ancestry(
        NON_PISOT_STRICT,
        SEED,
        depth=7,
        top_cut=10,
        radius=1,
    )
    assert (5, 7) in repeated_germ_level_pairs(germs)
    germ = next(item.germ for item in germs if item.level == 5)
    assert germ == next(item.germ for item in germs if item.level == 7)
    assert germ.source_difference == (1, 0, 0)
    assert germ.correction == (0, -1, 0)
    assert (germ.top_offset, germ.bottom_offset) == (1, 2)
    assert not germ.source_aligned_on_both_sides
    assert germ.top_context == CutContext((1,), (2,))
    assert germ.bottom_context == CutContext((2,), (3,))
