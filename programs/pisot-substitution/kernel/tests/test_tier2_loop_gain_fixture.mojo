"""Regressions for Tier-2 exact cubic gain fixtures."""

from std.testing import assert_equal, assert_true

from mojo_smoke.claims import require_contract
from psc.overlap_affine_pump import first_zero_shift_free_affine_pump
from psc.overlap_seed_patch import (
    SeedOverlapAutomaton,
    build_seed_overlap_graph_from_tables,
    build_seed_overlap_tables,
)
from psc.tier2_loop_gain_fixture import (
    affine_forcing_fixture_for_component,
    cubic_gain_coordinates,
    zero_shift_free_affine_forcing_fixtures,
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


def test_affine_forcing_channel_is_exact_and_occurrence_labelled() raises:
    var tables = build_seed_overlap_tables(determinant_two_sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    assert_true(not graph.capped)

    var fixtures = zero_shift_free_affine_forcing_fixtures(tables, graph)
    assert_true(len(fixtures) > 0)
    for f in range(len(fixtures)):
        assert_equal(fixtures[f].gain_channel, "affine_forcing")
        assert_true(len(fixtures[f].state_indices) > 0)
        assert_true(len(fixtures[f].edges) > 0)
        for j in range(len(fixtures[f].edges)):
            var edge = fixtures[f].edges[j].copy()
            var coords = cubic_gain_coordinates(edge.gain)
            assert_equal(len(coords), 3)
            assert_true(edge.occurrence_ordinal >= 0)

    # The existing six-edge golden pump must live inside one exported recurrent
    # component fixture. This checks the adapter preserves the occurrence labels
    # already replayed by overlap_affine_pump.
    var pumps = first_zero_shift_free_affine_pump(tables, graph)
    assert_equal(len(pumps), 1)
    var found_component = False
    for f in range(len(fixtures)):
        var contains_start = False
        for k in range(len(fixtures[f].state_indices)):
            if fixtures[f].state_indices[k] == pumps[0].state_indices[0]:
                contains_start = True
        if not contains_start:
            continue
        found_component = True
        for k in range(len(pumps[0].edges)):
            var wanted = pumps[0].edges[k].copy()
            var found_edge = False
            for j in range(len(fixtures[f].edges)):
                var got = fixtures[f].edges[j].copy()
                if (
                    got.source_index == wanted.parent_index
                    and got.target_index == wanted.child_index
                    and got.occurrence_ordinal == wanted.occurrence_ordinal
                    and got.gain == wanted.forcing
                ):
                    found_edge = True
            assert_true(found_edge)
    assert_true(found_component)


def test_component_order_is_canonical_and_caps_fail_closed() raises:
    var tables = build_seed_overlap_tables(determinant_two_sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var fixtures = zero_shift_free_affine_forcing_fixtures(tables, graph)
    assert_true(len(fixtures) > 0)

    # Reverse the component input; fixture state order remains graph-index order.
    var component = fixtures[0].state_indices.copy()
    var reversed = List[Int]()
    for i in range(len(component) - 1, -1, -1):
        reversed.append(component[i])
    var replay = affine_forcing_fixture_for_component(tables, graph, reversed)
    assert_equal(len(replay.state_indices), len(component))
    for i in range(len(component)):
        assert_equal(replay.state_indices[i], component[i])

    var capped = SeedOverlapAutomaton(graph.states, graph.adj, True)
    var caught = False
    try:
        _ = zero_shift_free_affine_forcing_fixtures(tables, capped)
    except:
        caught = True
    assert_true(caught)


def main() raises:
    test_affine_forcing_channel_is_exact_and_occurrence_labelled()
    print("[PASS] test_affine_forcing_channel_is_exact_and_occurrence_labelled")
    test_component_order_is_canonical_and_caps_fail_closed()
    print("[PASS] test_component_order_is_canonical_and_caps_fail_closed")
    print("2 Tier-2 loop-gain fixture Mojo tests passed.")
    require_contract("tier2-loop-gain-v1 affine_forcing fixture channel")
