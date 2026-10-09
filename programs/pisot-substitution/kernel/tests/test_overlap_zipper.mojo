"""Exact regressions for ordered overlap child occurrences."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_claim
from psc.overlap_obstruction import common_child_start_count
from psc.overlap_recurrence import zero_shift_free_recurrent_sccs
from psc.overlap_seed_patch import (
    OverlapState,
    SeedOverlapAutomaton,
    build_seed_overlap_graph_from_tables,
    build_seed_overlap_tables,
    overlap_children,
)
from psc.overlap_zipper import (
    is_strict_zipper,
    ordered_child_occurrences,
    zero_shift_occurrence_count,
    zipper_steps,
)
from psc.perron_field3 import CubicElt


def determinant_two_sigma() -> List[List[Int]]:
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2, 1]
    var a2: List[Int] = [0, 0, 1]
    var sigma = List[List[Int]]()
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def _contains_int(xs: List[Int], x: Int) -> Bool:
    for i in range(len(xs)):
        if xs[i] == x:
            return True
    return False


def test_ordered_occurrences_preserve_all_child_occurrences() raises:
    var tables = build_seed_overlap_tables(determinant_two_sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    assert_true(not graph.capped)
    var saw_strict = False
    var saw_boundary_tie = False

    for i in range(graph.size()):
        if graph.states[i].is_coincidence():
            continue
        var occurrences = ordered_child_occurrences(tables, graph.states[i])
        var children = overlap_children(tables, graph.states[i])
        assert_equal(len(occurrences), len(children))

        var steps = zipper_steps(occurrences)
        assert_equal(len(steps), len(occurrences) - 1)
        var diagonal = 0
        for j in range(len(steps)):
            assert_true(steps[j] == 1 or steps[j] == 2 or steps[j] == 3)
            if steps[j] == 3:
                diagonal += 1

        var zero_count = zero_shift_occurrence_count(occurrences)
        assert_equal(zero_count, common_child_start_count(tables, graph.states[i]))
        var first_zero = 1 if occurrences[0].state.shift.is_zero() else 0
        assert_equal(zero_count, first_zero + diagonal)
        assert_equal(is_strict_zipper(occurrences), zero_count == 0)
        if zero_count == 0:
            saw_strict = True
        else:
            saw_boundary_tie = True

    assert_true(saw_strict)
    assert_true(saw_boundary_tie)


def test_zero_shift_free_recurrence_is_one_sided_and_fail_closed() raises:
    # Vertex 0 is a coincidence. Vertex 1 is a nonzero-shift self-cycle and
    # must survive. Vertex 2 has zero shift and is deleted even though it has a
    # self-loop. Vertex 3 feeds only the deleted vertex and is not recurrent in
    # the induced graph.
    var states = List[OverlapState]()
    states.append(OverlapState(0, 0, CubicElt()))
    states.append(OverlapState(0, 1, CubicElt(1, 0, 0)))
    states.append(OverlapState(1, 2, CubicElt()))
    states.append(OverlapState(2, 0, CubicElt(2, 0, 0)))

    var adj = List[List[Int]]()
    var a0 = List[Int]()
    var a1: List[Int] = [1]
    var a2: List[Int] = [2]
    var a3: List[Int] = [2]
    adj.append(a0^)
    adj.append(a1^)
    adj.append(a2^)
    adj.append(a3^)

    var graph = SeedOverlapAutomaton(states, adj, False)
    var comps = zero_shift_free_recurrent_sccs(graph)
    assert_equal(len(comps), 1)
    assert_equal(len(comps[0]), 1)
    assert_true(_contains_int(comps[0], 1))

    var capped = SeedOverlapAutomaton(states, adj, True)
    var caught = False
    try:
        _ = zero_shift_free_recurrent_sccs(capped)
    except:
        caught = True
    assert_true(caught)


def main() raises:
    test_ordered_occurrences_preserve_all_child_occurrences()
    print("[PASS] test_ordered_occurrences_preserve_all_child_occurrences")
    test_zero_shift_free_recurrence_is_one_sided_and_fail_closed()
    print("[PASS] test_zero_shift_free_recurrence_is_one_sided_and_fail_closed")
    print("2 ordered-overlap-zipper Mojo tests passed.")
    require_claim("OverlapBoundaryZipperDichotomy")
