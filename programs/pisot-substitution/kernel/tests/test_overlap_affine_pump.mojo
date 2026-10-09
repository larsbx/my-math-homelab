"""Exact regressions for occurrence-labelled overlap affine pumps."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_claim
from psc.overlap_affine_pump import (
    AffinePumpCertificate,
    first_zero_shift_free_affine_pump,
    occurrence_edges,
    verify_affine_pump,
)
from psc.overlap_seed_patch import (
    SeedOverlapAutomaton,
    build_seed_overlap_graph_from_tables,
    build_seed_overlap_tables,
)


def determinant_two_sigma() -> List[List[Int]]:
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2, 1]
    var a2: List[Int] = [0, 0, 1]
    var sigma = List[List[Int]]()
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def test_affine_edges_and_golden_pump() raises:
    var tables = build_seed_overlap_tables(determinant_two_sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    assert_true(not graph.capped)
    var count = 0
    for i in range(graph.size()):
        var edges = occurrence_edges(tables, graph, i)
        if not graph.states[i].is_coincidence():
            assert_true(len(edges) > 0)
        for j in range(len(edges)):
            assert_equal(edges[j].occurrence_ordinal, j)
        count += len(edges)
    assert_true(count > graph.size())

    # Golden negative for the overstrong claim that zero-shift-free recurrence
    # is impossible.  This productive non-unimodular graph has a six-edge
    # occurrence-labelled cycle; it is not a bad closed component.
    var certificates = first_zero_shift_free_affine_pump(tables, graph)
    assert_equal(len(certificates), 1)
    assert_equal(len(certificates[0].edges), 6)
    assert_true(verify_affine_pump(tables, graph, certificates[0]))
    for i in range(len(certificates[0].state_indices)):
        assert_true(not graph.states[certificates[0].state_indices[i]].shift.is_zero())


def test_caps_fail_closed() raises:
    var tables = build_seed_overlap_tables(determinant_two_sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var capped = SeedOverlapAutomaton(graph.states, graph.adj, True)
    var caught = False
    try:
        _ = occurrence_edges(tables, capped, 0)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:
        _ = first_zero_shift_free_affine_pump(tables, capped)
    except:
        caught = True
    assert_true(caught)


def main() raises:
    test_affine_edges_and_golden_pump()
    print("[PASS] test_affine_edges_and_golden_pump")
    test_caps_fail_closed()
    print("[PASS] test_caps_fail_closed")
    print("2 overlap affine-pump Mojo tests passed.")
    require_claim("OrderedAffineCycleIdentity")
