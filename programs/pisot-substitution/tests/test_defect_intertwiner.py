import pytest

from psc_research import build_bpa, recurrent_noncoincident_sccs
from psc_research.defect_intertwiner import (
    build_k2_intertwiner,
    build_k3_intertwiner,
    k2_wedge,
    k3_full,
    lowest_nonzero_defect_degree,
    tensor_cube,
)
from psc_research.intertwiner import matmul, substitution_incidence


NEGATIVE = {1: (2,), 2: (1, 2, 3), 3: (2,)}
A = ((1, 2), (2, 1))
B = ((2, 3), (3, 2))

SEED0 = (
    (1, 2, 2, 3, 3, 1, 2),
    (2, 3, 1, 1, 2, 2, 3),
)
TRIBONACCI = {1: (1, 2), 2: (1, 3), 3: (1,)}


def negative_component():
    graph = build_bpa(NEGATIVE, max_states=2000)
    for comp in recurrent_noncoincident_sccs(graph):
        if set(comp) == {A, B}:
            return (A, B)
    raise AssertionError("expected negative-control strict component")


def test_k2_signed_intertwiner_on_negative_control():
    data = build_k2_intertwiner(NEGATIVE, negative_component())
    assert data.defect_matrix == (
        (1, 0),
        (0, 0),
        (0, 1),
    )
    assert data.exterior_square == (
        (-1, 0, 1),
        (0, 0, 0),
        (1, 0, -1),
    )


def test_unsigned_normalized_interface_fails_but_signed_interface_holds():
    data = build_k2_intertwiner(NEGATIVE, negative_component())
    q2 = data.defect_matrix
    phi2_q2 = matmul(data.exterior_square, q2)

    # The normalized unsigned SCC incidence forgets that a swapped raw child
    # contributes -K2. This is the orientation bug in the archived quotient
    # interface: Q2*N is not the substituted defect.
    assert matmul(q2, data.orientation.unsigned) != phi2_q2

    # The exact relation uses S=A-B.
    assert matmul(q2, data.orientation.signed) == phi2_q2


def test_negative_control_first_defect_is_degree_two():
    assert lowest_nonzero_defect_degree(negative_component()) == 2


def test_seed0_first_defect_is_degree_three():
    assert k2_wedge(SEED0) == (0, 0, 0)
    assert any(k3_full(SEED0))
    assert lowest_nonzero_defect_degree((SEED0,)) == 3


def test_seed0_k3_transforms_by_tensor_cube_when_k2_zero():
    m = substitution_incidence(TRIBONACCI)
    cube = tensor_cube(m)
    k3 = k3_full(SEED0)
    column = tuple((x,) for x in k3)
    expected = tuple(matmul(cube, column)[i][0] for i in range(27))

    from psc_research.bpa import apply_substitution

    inflated = (
        apply_substitution(TRIBONACCI, SEED0[0]),
        apply_substitution(TRIBONACCI, SEED0[1]),
    )
    assert k3_full(inflated) == expected


def test_k3_pure_intertwiner_rejects_nonzero_k2_component():
    with pytest.raises(ValueError, match="K2=0"):
        build_k3_intertwiner(NEGATIVE, negative_component())
