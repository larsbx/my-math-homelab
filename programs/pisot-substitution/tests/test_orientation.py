import pytest

from psc_research import build_bpa, recurrent_noncoincident_sccs
from psc_research.orientation import (
    OrientedEdge,
    cocycle_is_trivial,
    oriented_children,
    solve_orientation_gauge,
    strict_orientation_edges,
    verify_oriented_factorization,
)


NEGATIVE = {1: (2,), 2: (1, 2, 3), 3: (2,)}
A = ((1, 2), (2, 1))
B = ((2, 3), (3, 2))


def negative_closed_component():
    graph = build_bpa(NEGATIVE, max_states=2000)
    for comp in recurrent_noncoincident_sccs(graph):
        if set(comp) == {A, B}:
            return comp
    raise AssertionError("expected two-state negative-control component")


def test_signed_children_reconstruct_raw_inflation():
    assert oriented_children(NEGATIVE, A) == ((A, -1), (B, 1))
    assert oriented_children(NEGATIVE, B) == ((A, 1), (B, -1))
    assert verify_oriented_factorization(NEGATIVE, A)
    assert verify_oriented_factorization(NEGATIVE, B)


def test_negative_control_has_nontrivial_orientation_monodromy():
    comp = negative_closed_component()
    edges = strict_orientation_edges(NEGATIVE, comp)
    # Each state has a negative self-loop, so no global orientation gauge can
    # make every child occurrence orientation-preserving.
    assert not cocycle_is_trivial(comp, edges)
    assert solve_orientation_gauge(comp, edges) is None


def test_positive_cycle_is_gauge_trivial():
    edges = (
        OrientedEdge(A, B, 1, 0),
        OrientedEdge(B, A, 1, 0),
    )
    gauge = solve_orientation_gauge((A, B), edges)
    assert gauge is not None
    assert gauge[A] == gauge[B]


def test_strict_orientation_rejects_coincidence_escape():
    tribonacci = {1: (1, 2), 2: (1, 3), 3: (1,)}
    graph = build_bpa(tribonacci, max_states=2000)
    comps = recurrent_noncoincident_sccs(graph)
    assert comps
    with pytest.raises(ValueError):
        strict_orientation_edges(tribonacci, comps[0])
