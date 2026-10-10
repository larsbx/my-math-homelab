from fractions import Fraction

import pytest

from psc_research.defect_intertwiner import exterior_square
from psc_research.intertwiner import substitution_incidence
from psc_research.meanarea_integrality import (
    actual_meanarea_matrix,
    characteristic_resultant_formula,
    cubic_coefficients,
    determinant_fraction_free,
    forced_meanarea_solution,
    forced_side_areas_pass_bounds,
    integral_solution,
    solution_denominators,
    solution_is_integral,
    sylvester_determinant_for_substitution,
    sylvester_matrix,
    sylvester_operator_determinant_formula,
)
from psc_research.synthetic_degree2 import SIGMA, SIGNED_CHILDREN, STATES


def proposed_child_words():
    return tuple(tuple(child for child, _sign in word) for word in SIGNED_CHILDREN)


def companion(t: int, u: int, d: int):
    """Column companion of x^3-Tx^2+Ux-d."""
    return (
        (0, 0, d),
        (1, 0, -u),
        (0, 1, t),
    )


def test_balanced_states_have_integral_actual_meanarea():
    j = actual_meanarea_matrix(STATES)
    assert all(isinstance(x, int) for row in j for x in row)


def test_actual_meanarea_rejects_unbalanced_states_even_if_area_sum_is_even():
    malformed = (((1,), (2,)),) * 3
    with pytest.raises(ValueError, match="balanced"):
        actual_meanarea_matrix(malformed)


def test_synthetic_child_order_forces_half_integral_meanarea():
    solution = forced_meanarea_solution(SIGMA, STATES, proposed_child_words())
    assert solution == (
        (Fraction(1, 2), Fraction(-1, 2), Fraction(3, 2)),
        (Fraction(3, 2), Fraction(1, 2), Fraction(3, 2)),
        (Fraction(1, 2), Fraction(1, 2), Fraction(-5, 2)),
    )
    assert solution_denominators(solution) == (2,)
    assert not solution_is_integral(solution)
    assert not forced_side_areas_pass_bounds(STATES, solution)


def test_integral_extraction_rejects_half_integral_solution():
    solution = forced_meanarea_solution(SIGMA, STATES, proposed_child_words())
    with pytest.raises(ValueError, match="not integral"):
        integral_solution(solution)


def test_sylvester_operator_sign_is_not_the_resultant_sign():
    m = substitution_incidence(SIGMA)
    t, u, d = cubic_coefficients(m)
    assert (t, u, d) == (1, -1, 1)
    direct = determinant_fraction_free(sylvester_matrix(exterior_square(m), m))
    resultant = characteristic_resultant_formula(t, u, d)
    operator_formula = sylvester_operator_determinant_formula(t, u, d)
    assert direct == -16
    assert resultant == 16
    assert operator_formula == -16
    assert direct == operator_formula == -resultant
    assert sylvester_determinant_for_substitution(SIGMA) == direct


def test_closed_determinant_formula_matches_many_companion_matrices():
    cases = (
        (1, -1, 1),
        (3, -3, -8),
        (2, 1, 1),
        (0, -2, 3),
        (-1, 2, -1),
        (4, 3, 2),
        (2, -3, 5),
    )
    for t, u, d in cases:
        m = companion(t, u, d)
        direct = determinant_fraction_free(sylvester_matrix(exterior_square(m), m))
        assert direct == sylvester_operator_determinant_formula(t, u, d)
        assert direct == -characteristic_resultant_formula(t, u, d)


def test_forced_solver_rejects_nonintertwining_child_incidence():
    bad_words = ((0,), (1,), (2,))
    with pytest.raises(ValueError, match=r"P\*N=M\*P"):
        forced_meanarea_solution(SIGMA, STATES, bad_words)


def test_sylvester_operator_is_nonsingular_for_synthetic_pip():
    assert sylvester_determinant_for_substitution(SIGMA) != 0
