from psc_research import build_bpa, recurrent_noncoincident_sccs
from psc_research.orientation import OrientedEdge, strict_orientation_edges
from psc_research.orientation_spectrum import (
    build_orientation_incidence,
    parallel_signs_are_consistent,
    solve_constant_phase_gauge,
)


NEGATIVE = {1: (2,), 2: (1, 2, 3), 3: (2,)}
A = ((1, 2), (2, 1))
B = ((2, 3), (3, 2))


def negative_component():
    graph = build_bpa(NEGATIVE, max_states=2000)
    for comp in recurrent_noncoincident_sccs(graph):
        if set(comp) == {A, B}:
            return (A, B)
    raise AssertionError("expected negative-control strict component")


def test_negative_control_even_odd_incidence_blocks():
    data = build_orientation_incidence(NEGATIVE, negative_component())
    assert data.positive == ((0, 1), (1, 0))
    assert data.negative == ((1, 0), (0, 1))
    assert data.unsigned == ((1, 1), (1, 1))
    assert data.signed == ((-1, 1), (1, -1))
    assert data.cover == (
        (0, 1, 1, 0),
        (1, 0, 0, 1),
        (1, 0, 0, 1),
        (0, 1, 1, 0),
    )


def test_negative_control_cover_parikh_kills_odd_sector():
    data = build_orientation_incidence(NEGATIVE, negative_component())
    assert data.parikh_cover == (
        (1, 0, 1, 0),
        (1, 1, 1, 1),
        (0, 1, 0, 1),
    )


def test_negative_control_is_anti_gauge_not_trivial_gauge():
    comp = negative_component()
    edges = strict_orientation_edges(NEGATIVE, comp)
    assert parallel_signs_are_consistent(edges)
    assert solve_constant_phase_gauge(comp, edges, +1) is None
    anti = solve_constant_phase_gauge(comp, edges, -1)
    assert anti is not None
    assert anti[A] == -anti[B]


def test_mixed_parallel_signs_are_detected():
    edges = (
        OrientedEdge(A, B, +1, 0),
        OrientedEdge(A, B, -1, 1),
    )
    assert not parallel_signs_are_consistent(edges)


def test_negative_control_orientation_edges_are_strict():
    comp = negative_component()
    edges = strict_orientation_edges(NEGATIVE, comp)
    assert len(edges) == 4
