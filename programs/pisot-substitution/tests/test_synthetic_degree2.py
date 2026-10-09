from psc_research.intertwiner import substitution_incidence
from psc_research.synthetic_degree2 import (
    A,
    B,
    N,
    P,
    Q,
    S,
    SIGMA,
    STATES,
    actual_factorization_has_coincidence,
    actual_signed_children,
    endpoint_constraints_hold,
    endpoint_maps_zero_based,
    endpoint_type_pair,
    factorization_realizes_template,
    proposed_signed_children_as_states,
    signed_counts_from_words,
    state_k2_matrix,
    state_parikh_matrix,
    states_are_irreducible,
    verify_synthetic_template,
)


def test_synthetic_template_passes_all_prefactorization_constraints():
    assert verify_synthetic_template()
    assert substitution_incidence(SIGMA) == N
    assert state_parikh_matrix() == P
    assert state_k2_matrix() == Q
    assert states_are_irreducible()
    assert signed_counts_from_words() == (A, B)


def test_actual_substitution_has_required_nonsynchronizing_endpoint_types():
    assert endpoint_maps_zero_based() == ((1, 2, 0), (1, 2, 1))
    # Canonical endpoint classes are G/F.
    assert endpoint_type_pair() == ((1, 2, 0), (1, 0, 0))
    assert endpoint_constraints_hold()


def test_abstract_signed_child_word_has_expected_incidence():
    assert N == (
        (0, 0, 1),
        (1, 0, 1),
        (0, 1, 1),
    )
    assert S == (
        (0, 0, -1),
        (1, 0, 1),
        (0, -1, -1),
    )
    assert proposed_signed_children_as_states(0) == ((STATES[1], 1),)
    assert proposed_signed_children_as_states(1) == ((STATES[2], -1),)
    assert proposed_signed_children_as_states(2) == (
        (STATES[0], -1),
        (STATES[1], 1),
        (STATES[2], -1),
    )


def test_actual_zero_return_factorization_is_the_precise_failure():
    actual = tuple(actual_signed_children(state) for state in STATES)
    assert tuple(len(children) for children in actual) == (1, 2, 5)
    assert not factorization_realizes_template()
    assert actual_factorization_has_coincidence()

    # The coincidence is produced by the third synthetic state under the actual
    # substitution; the first two inflated states have no coincidence child.
    assert not any(child[0] == child[1] for child, _sign in actual[0])
    assert not any(child[0] == child[1] for child, _sign in actual[1])
    assert any(child == ((3,), (3,)) for child, _sign in actual[2])


def test_actual_factorization_does_not_accidentally_use_proposed_children():
    for parent, state in enumerate(STATES):
        assert actual_signed_children(state) != proposed_signed_children_as_states(parent)
