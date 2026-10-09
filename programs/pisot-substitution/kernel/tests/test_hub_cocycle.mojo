"""Canonical Mojo regressions for the Barge-Diamond hub-side cocycle."""

from std.testing import assert_equal, assert_false, assert_true
from mojo_smoke.claims import require_claim
from psc.derived_system import build_derived_system
from psc.hub_cocycle import (
    build_hub_cocycle,
    hub_gauge_preserves_perron_phase,
    hub_residual_edges,
    orientation_signed_edges,
    support_is_strongly_connected,
)
from finite_graph.signing import perron_phase
from psc.words import Pair


def sigma() -> List[List[Int]]:
    # Primitive non-Pisot strict calibration: 1->2, 2->123, 3->2.
    return [[1], [0, 1, 2], [1]]


def component() -> List[Pair]:
    var out = List[Pair]()
    var au: List[Int] = [0, 1]
    var av: List[Int] = [1, 0]
    var bu: List[Int] = [1, 2]
    var bv: List[Int] = [2, 1]
    out.append(Pair(au, av))
    out.append(Pair(bu, bv))
    return out^


def test_hub_side_is_defined_on_every_state_and_occurrence() raises:
    var system = build_derived_system(sigma(), component())
    var hc = build_hub_cocycle(system, 1)
    assert_equal(hc.canonical_sides, [1, 0])
    assert_equal(hc.physical_child_sides[0], [0, 0])
    assert_equal(hc.physical_child_sides[1], [1, 1])


def test_hub_residual_is_orientation_sign_after_vertex_gauge() raises:
    var system = build_derived_system(sigma(), component())
    var hc = build_hub_cocycle(system, 1)
    assert_equal(hc.residual_bits[0], [1, 1])
    assert_equal(hc.residual_bits[1], [1, 1])

    var original = orientation_signed_edges(system)
    var gauged = hub_residual_edges(system, hc)
    assert_equal(len(original), 4)
    assert_equal(len(gauged), 4)
    assert_equal(original[0].bit, 1)
    assert_equal(original[1].bit, 0)
    assert_equal(original[2].bit, 0)
    assert_equal(original[3].bit, 1)
    for i in range(4):
        assert_equal(gauged[i].bit, 1)


def test_hub_gauge_preserves_perron_phase() raises:
    var system = build_derived_system(sigma(), component())
    assert_true(support_is_strongly_connected(system))
    var original = orientation_signed_edges(system)
    var hc = build_hub_cocycle(system, 1)
    var gauged = hub_residual_edges(system, hc)
    assert_equal(perron_phase(system.size(), original), 1)
    assert_equal(perron_phase(system.size(), gauged), 1)
    assert_true(hub_gauge_preserves_perron_phase(system, 1))


def test_scc_precondition_detects_disconnected_support() raises:
    var system = build_derived_system(sigma(), component())
    var self0: List[Int] = [0]
    var self1: List[Int] = [1]
    var sign0: List[Int] = [1]
    var sign1: List[Int] = [1]
    system.images[0] = self0^
    system.images[1] = self1^
    system.child_signs[0] = sign0^
    system.child_signs[1] = sign1^
    assert_false(support_is_strongly_connected(system))


def main() raises:
    test_hub_side_is_defined_on_every_state_and_occurrence()
    print("[PASS] test_hub_side_is_defined_on_every_state_and_occurrence")
    test_hub_residual_is_orientation_sign_after_vertex_gauge()
    print("[PASS] test_hub_residual_is_orientation_sign_after_vertex_gauge")
    test_hub_gauge_preserves_perron_phase()
    print("[PASS] test_hub_gauge_preserves_perron_phase")
    test_scc_precondition_detects_disconnected_support()
    print("[PASS] test_scc_precondition_detects_disconnected_support")
    print("4 hub-cocycle Mojo tests passed.")
    require_claim("OrientationMonodromy")
