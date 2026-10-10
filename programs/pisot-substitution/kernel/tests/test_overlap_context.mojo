"""Finite context-equality calibration for ordered seed-patch occurrences."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_claim
from psc.overlap_context import (
    first_affine_context_mismatch,
    occurrence_context,
    same_context,
)
from psc.overlap_seed_patch import (
    SeedOverlapAutomaton,
    build_seed_overlap_graph_from_tables,
    build_seed_overlap_tables,
)


def determinant_two_sigma() -> List[List[Int]]:
    var sigma = List[List[Int]]()
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2, 1]
    var a2: List[Int] = [0, 0, 1]
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def test_golden_affine_context_mismatch() raises:
    var tables = build_seed_overlap_tables(determinant_two_sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var mismatches = first_affine_context_mismatch(tables, graph)
    assert_equal(len(mismatches), 1)
    var mismatch = mismatches[0].copy()
    assert_equal(mismatch.child_index, 9)
    assert_equal(mismatch.first_parent_index, 0)
    assert_equal(mismatch.second_parent_index, 3)
    assert_true(not same_context(mismatch.first_context, mismatch.second_context))
    assert_true(
        same_context(
            mismatch.first_context,
            occurrence_context(
                tables,
                graph,
                mismatch.first_parent_index,
                mismatch.first_occurrence_ordinal,
            ),
        )
    )


def test_cap_fails_closed() raises:
    var tables = build_seed_overlap_tables(determinant_two_sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var capped = SeedOverlapAutomaton(graph.states, graph.adj, True)
    var caught = False
    try:
        _ = first_affine_context_mismatch(tables, capped)
    except:
        caught = True
    assert_true(caught)


def main() raises:
    test_golden_affine_context_mismatch()
    print("[PASS] test_golden_affine_context_mismatch")
    test_cap_fails_closed()
    print("[PASS] test_cap_fails_closed")
    print("2 overlap-context Mojo tests passed.")
    require_claim("OneStepContextEquality")
