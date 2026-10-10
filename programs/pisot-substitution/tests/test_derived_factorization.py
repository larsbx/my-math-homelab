from psc_research.derived_factorization import (
    derived_block_boundaries,
    derived_boundary_address,
    direct_normalized_factorization,
    direct_zero_return_boundaries,
    inherited_derived_boundary_indices,
    iterate_derived,
    newborn_derived_boundary_indices,
    strict_derived_substitution,
    verify_derived_factorization,
)


SIGMA = {1: (2,), 2: (1, 2, 3), 3: (2,)}
A = ((1, 2), (2, 1))
B = ((2, 3), (3, 2))
COMP = (A, B)
REDUCIBLE = ((1, 2, 2, 3), (2, 1, 3, 2))


def test_strict_component_defines_exact_ordered_derived_substitution():
    tau = strict_derived_substitution(SIGMA, COMP)
    assert tau == {A: (A, B), B: (A, B)}


def test_recursive_derived_word_equals_direct_zero_return_factorization():
    tau = strict_derived_substitution(SIGMA, COMP)
    for depth in range(6):
        derived = iterate_derived(tau, A, depth)
        direct = direct_normalized_factorization(SIGMA, A, depth)
        assert derived == direct
        assert derived_block_boundaries(derived) == direct_zero_return_boundaries(
            SIGMA, A, depth
        )
    assert verify_derived_factorization(SIGMA, COMP, A, max_depth=5)
    assert verify_derived_factorization(SIGMA, COMP, B, max_depth=5)


def test_inherited_and_newborn_cuts_are_substitution_boundaries_in_tau():
    tau = strict_derived_substitution(SIGMA, COMP)
    assert inherited_derived_boundary_indices(tau, A, 1) == (0, 2)
    assert newborn_derived_boundary_indices(tau, A, 1) == (1,)
    assert inherited_derived_boundary_indices(tau, A, 2) == (0, 2, 4)
    assert newborn_derived_boundary_indices(tau, A, 2) == (1, 3)
    assert inherited_derived_boundary_indices(tau, A, 3) == (0, 2, 4, 6, 8)
    assert newborn_derived_boundary_indices(tau, A, 3) == (1, 3, 5, 7)


def test_physical_zero_return_has_canonical_derived_context_address():
    address = derived_boundary_address(
        SIGMA,
        COMP,
        A,
        depth=3,
        physical_cut=10,
        radius=2,
    )
    assert address.block_index == 5
    assert address.left_state == A
    assert address.right_state == B
    assert address.left_context == (B, A)
    assert address.right_context == (B, A)


def test_strict_derived_substitution_rejects_missing_children():
    try:
        strict_derived_substitution(SIGMA, (A,))
    except ValueError as exc:
        assert "outside the component" in str(exc)
    else:
        raise AssertionError("missing strict child was accepted")


def test_strict_derived_substitution_rejects_reducible_balanced_state():
    # REDUCIBLE is the concatenation of the two irreducible states A and B.
    # Treating it as one derived letter would already break the depth-0
    # identity: direct factorization returns (A,B), not (REDUCIBLE,).
    assert direct_normalized_factorization(SIGMA, REDUCIBLE, 0) == (A, B)
    try:
        strict_derived_substitution(SIGMA, (REDUCIBLE, A, B))
    except ValueError as exc:
        assert "reducible balanced state" in str(exc)
    else:
        raise AssertionError("reducible balanced state was accepted")
