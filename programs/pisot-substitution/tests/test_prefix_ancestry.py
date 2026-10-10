from psc_research.bpa import apply_substitution_n, coincidence_boundaries
from psc_research.examples import EXAMPLES
from psc_research.prefix_ancestry import (
    asynchronous_inflated_prefix_step,
    multilevel_prefix_ancestry,
    top_zero_return_ancestry,
)


def test_asynchronous_step_reconstructs_independent_prefix_differences():
    sigma = EXAMPLES["smith"]
    top = (1, 2, 3, 1)
    bottom = (3, 1, 2)
    top_image = apply_substitution_n(sigma, top, 1)
    bottom_image = apply_substitution_n(sigma, bottom, 1)
    for i in range(len(top_image) + 1):
        for j in range(len(bottom_image) + 1):
            step = asynchronous_inflated_prefix_step(sigma, top, bottom, i, j)
            assert sum(step.source_difference) == step.top_source_cut - step.bottom_source_cut
            assert sum(step.output_difference) == i - j


def test_multilevel_path_has_exact_affine_chaining():
    sigma = EXAMPLES["tribonacci"]
    state = ((1, 2), (2, 1))
    depth = 6
    top = apply_substitution_n(sigma, state[0], depth)
    bottom = apply_substitution_n(sigma, state[1], depth)
    cut = 51
    assert cut in coincidence_boundaries(top, bottom, 3)
    path = top_zero_return_ancestry(sigma, state, depth, cut)
    assert path.depth == depth
    assert path.ends_at_zero
    assert len(path.defects) == depth + 1
    for left, right in zip(path.steps, path.steps[1:]):
        assert left.output_difference == right.source_difference


def test_tribonacci_has_a_genuine_nonzero_ancestry_cycle():
    # This is a negative control for the overstrong claim that Pisot alone
    # forbids nonzero affine ancestry cycles.  The cut is an actual zero return
    # in a genuine PIP substitution, and its ancestry repeats a length-3 defect
    # loop before eventually reaching the top zero.
    sigma = EXAMPLES["tribonacci"]
    state = ((1, 2), (2, 1))
    path = top_zero_return_ancestry(sigma, state, 6, 51)
    assert path.defects == (
        (1, -1, 0),
        (0, 1, -1),
        (-1, 0, 1),
        (1, -1, 0),
        (0, 1, -1),
        (0, 0, 1),
        (0, 0, 0),
    )
    assert path.repeated_defects(nonzero_only=True) == (
        (0, 1, -1),
        (1, -1, 0),
    )
    assert path.corrections[:3] == (
        (0, 0, 0),
        (-1, 0, 0),
        (1, 0, 0),
    )


def test_explicit_asynchronous_top_cuts_chain_too():
    sigma = EXAMPLES["flipped_tribonacci"]
    state = ((1, 2), (2, 1))
    top = apply_substitution_n(sigma, state[0], 4)
    bottom = apply_substitution_n(sigma, state[1], 4)
    path = multilevel_prefix_ancestry(
        sigma,
        state,
        4,
        top_cut=len(top) // 2,
        bottom_cut=len(bottom) // 2 + 1,
    )
    assert len(path.steps) == 4
    for left, right in zip(path.steps, path.steps[1:]):
        assert left.output_difference == right.source_difference
