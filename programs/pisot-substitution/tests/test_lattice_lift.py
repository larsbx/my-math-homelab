from psc_research.lattice_lift import (
    integral_image_certificate,
    meanarea_lattice_certificate,
)
from psc_research.meanarea_integrality import (
    child_incidence,
    forced_meanarea_solution,
    omega_matrix,
    parikh_matrix,
    solution_denominators,
    sylvester_matrix,
)
from psc_research.factorization_degree2 import substitution_internal_area
from psc_research.defect_intertwiner import exterior_square
from psc_research.intertwiner import matmul, substitution_incidence
from psc_research.synthetic_degree2 import SIGMA, SIGNED_CHILDREN, STATES


def proposed_child_words():
    return tuple(tuple(child for child, _sign in word) for word in SIGNED_CHILDREN)


def test_gf_template_has_exact_nonintegral_cramer_certificate():
    cert = meanarea_lattice_certificate(SIGMA, STATES, proposed_child_words())
    assert cert.determinant == -16
    assert cert.cramer_numerators == (-8, 8, -24, -24, -8, -24, -8, -8, 40)
    assert cert.reduced_denominators == (2, 2, 2, 2, 2, 2, 2, 2, 2)
    assert cert.obstruction_coordinates == tuple(range(9))
    assert not cert.is_integral


def test_cramer_denominators_match_fraction_solver():
    cert = meanarea_lattice_certificate(SIGMA, STATES, proposed_child_words())
    rational = forced_meanarea_solution(SIGMA, STATES, proposed_child_words())
    assert tuple(sorted(set(cert.reduced_denominators))) == solution_denominators(rational)


def test_direct_operator_rhs_certificate_matches_candidate_helper():
    words = proposed_child_words()
    m = substitution_incidence(SIGMA)
    n = child_incidence(3, words)
    p = parikh_matrix(STATES)
    omega = omega_matrix(STATES, words)
    internal = matmul(substitution_internal_area(SIGMA), p)
    rhs_matrix = tuple(
        tuple(omega[i][j] - internal[i][j] for j in range(3))
        for i in range(3)
    )
    rhs = tuple(rhs_matrix[i][j] for i in range(3) for j in range(3))
    operator = sylvester_matrix(exterior_square(m), n)
    assert integral_image_certificate(operator, rhs) == meanarea_lattice_certificate(
        SIGMA, STATES, words
    )


def test_integral_image_certificate_accepts_known_integer_solution():
    operator = ((2, 1), (1, 1))
    x = (3, -2)
    rhs = (
        operator[0][0] * x[0] + operator[0][1] * x[1],
        operator[1][0] * x[0] + operator[1][1] * x[1],
    )
    cert = integral_image_certificate(operator, rhs)
    assert cert.determinant == 1
    assert cert.is_integral
    assert cert.reduced_denominators == (1, 1)
    assert cert.obstruction_coordinates == ()
