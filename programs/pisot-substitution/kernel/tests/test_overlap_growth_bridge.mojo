"""Exact regressions for the seed-relative multiple-edge growth bridge."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_contract
from psc.overlap_growth_bridge import (
    OccurrenceMultiplicity,
    inflate_occurrence_multiplicity,
    occurrence_multiplicity_at_level,
    seed_occurrence_multiplicity,
)
from psc.overlap_seed_patch import (
    SeedOverlapAutomaton,
    build_seed_overlap_graph_from_tables,
    build_seed_overlap_tables,
)


def sigma() -> List[List[Int]]:
    var out = List[List[Int]]()
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2, 1]
    var a2: List[Int] = [0, 0, 1]
    out.append(a0^)
    out.append(a1^)
    out.append(a2^)
    return out^


def test_multiple_edges_are_occurrences_not_types() raises:
    var tables = build_seed_overlap_tables(sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var c0 = occurrence_multiplicity_at_level(tables, graph, 0)
    var c1 = occurrence_multiplicity_at_level(tables, graph, 1)
    assert_equal(c0.total(), 9)
    assert_equal(c1.total(), 21)
    assert_equal(occurrence_multiplicity_at_level(tables, graph, 2).total(), 34)
    assert_equal(occurrence_multiplicity_at_level(tables, graph, 3).total(), 67)
    var manual = List[Int]()
    for _ in range(graph.size()):
        manual.append(0)
    for parent in range(graph.size()):
        for e in range(len(graph.adj[parent])):
            manual[graph.adj[parent][e]] += c0.counts[parent]
    assert_equal(c1.level, 1)
    assert_equal(len(c1.counts), graph.size())
    var repeated = False
    for i in range(graph.size()):
        assert_equal(c1.counts[i], manual[i])
        if c1.counts[i] > 1:
            repeated = True
    assert_true(repeated)


def test_iterated_update_composes_exactly() raises:
    var tables = build_seed_overlap_tables(sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var direct = occurrence_multiplicity_at_level(tables, graph, 3)
    var stepped = seed_occurrence_multiplicity(tables, graph, 1_000_000_000)
    for _ in range(3):
        stepped = inflate_occurrence_multiplicity(graph, stepped, 1_000_000_000)
    assert_equal(direct.level, stepped.level)
    assert_equal(direct.total(), stepped.total())
    for i in range(graph.size()):
        assert_equal(direct.counts[i], stepped.counts[i])


def test_fail_closed() raises:
    var tables = build_seed_overlap_tables(sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var caught = False
    try:
        _ = occurrence_multiplicity_at_level(tables, graph, -1)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:
        _ = occurrence_multiplicity_at_level(tables, graph, 4, 1)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:
        var bad: List[Int] = [1]
        _ = inflate_occurrence_multiplicity(graph, OccurrenceMultiplicity(0, bad, 10), 10)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:
        var capped = SeedOverlapAutomaton(graph.states, graph.adj, True)
        _ = occurrence_multiplicity_at_level(tables, capped, 1)
    except:
        caught = True
    assert_true(caught)


def main() raises:
    test_multiple_edges_are_occurrences_not_types()
    print("[PASS] test_multiple_edges_are_occurrences_not_types")
    test_iterated_update_composes_exactly()
    print("[PASS] test_iterated_update_composes_exactly")
    test_fail_closed()
    print("[PASS] test_fail_closed")
    print("3 overlap-growth-bridge Mojo tests passed.")
    require_contract("residual overlap multiplicities count multiple child occurrences exactly under inflation, compose across levels, and fail closed on invalid levels, caps, or capped graphs")
