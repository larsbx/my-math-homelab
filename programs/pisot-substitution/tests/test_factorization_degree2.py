from psc_research.bpa import children
from psc_research.factorization_degree2 import (
    actual_midarea_residual,
    midarea_factorization_residual,
    midarea_system_residuals,
    state_area_difference,
    substitution_area,
    verify_actual_midarea_identity,
    verify_k2_area_relation,
    word_area,
)
from psc_research.synthetic_degree2 import SIGMA, SIGNED_CHILDREN, STATES


def proposed_child_words():
    return tuple(tuple(child for child, _sign in word) for word in SIGNED_CHILDREN)


def test_area_substitution_formula_matches_direct_words():
    for state in STATES:
        for word in state:
            inflated = tuple(x for letter in word for x in SIGMA[letter])
            assert substitution_area(word, SIGMA) == word_area(inflated)


def test_k2_is_half_the_side_area_difference():
    for state in STATES:
        assert verify_k2_area_relation(state)
        assert all(x % 2 == 0 for x in state_area_difference(state))


def test_true_zero_return_factorizations_have_zero_midarea_residual():
    for state in STATES:
        assert verify_actual_midarea_identity(SIGMA, state)
        assert actual_midarea_residual(SIGMA, state) == (0, 0, 0)
        assert midarea_factorization_residual(SIGMA, state, children(SIGMA, state)) == (
            0,
            0,
            0,
        )


def test_synthetic_proposed_child_word_fails_at_absolute_degree_two():
    assert midarea_system_residuals(SIGMA, STATES, proposed_child_words()) == (
        (0, 0, -4),
        (0, -4, -4),
        (-4, -8, -12),
    )


def test_child_order_is_visible_to_midarea_constraint():
    # For T2 the proposed underlying children are T0,T1,T2.  Permuting the
    # child order changes the cross-wedge term even though unsigned incidence is
    # identical.
    parent = STATES[2]
    forward = midarea_factorization_residual(SIGMA, parent, (STATES[0], STATES[1], STATES[2]))
    swapped = midarea_factorization_residual(SIGMA, parent, (STATES[1], STATES[0], STATES[2]))
    assert forward != swapped
