"""Canonical Mojo regressions for the system-level good-edge bridge."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_claim
from psc.derived_system import DerivedSystem, build_derived_system
from psc.good_edge_system import (
    candidate_good_edge_count,
    candidate_good_edge_mask,
    candidate_good_edge_phase,
    unique_candidate_hub,
)
from psc.words import Pair


def sigma() -> List[List[Int]]:
    # Primitive non-Pisot strict calibration: 1->2, 2->123, 3->2.
    return [[1], [0, 1, 2], [1]]


def prefix_map() -> List[Int]:
    return [1, 0, 1]


def component() -> List[Pair]:
    var out = List[Pair]()
    var au: List[Int] = [0, 1]
    var av: List[Int] = [1, 0]
    var bu: List[Int] = [1, 2]
    var bv: List[Int] = [2, 1]
    out.append(Pair(au, av))
    out.append(Pair(bu, bv))
    return out^


def malformed_empty_child_system() -> DerivedSystem:
    """Public-constructor negative control: valid-looking state, no child word."""
    var states = List[Pair]()
    var au: List[Int] = [0, 1]
    var av: List[Int] = [1, 0]
    states.append(Pair(au, av))

    var images = List[List[Int]]()
    images.append(List[Int]())
    var signs = List[List[Int]]()
    signs.append(List[Int]())
    var lengths: List[Int] = [2]
    return DerivedSystem(states, images, signs, lengths)


def test_nonpisot_control_has_one_finite_compatible_good_edge() raises:
    var system = build_derived_system(sigma(), component())
    var h = prefix_map()
    # Only edge {0,2} (id 1) is compatible with both state first pairs.
    assert_equal(candidate_good_edge_phase(system, h, 0), -1)
    assert_equal(candidate_good_edge_phase(system, h, 1), 1)
    assert_equal(candidate_good_edge_phase(system, h, 2), -1)
    assert_equal(candidate_good_edge_mask(system, h), 2)
    assert_equal(candidate_good_edge_count(system, h), 1)
    assert_equal(unique_candidate_hub(system, h), 1)


def test_actual_first_child_residual_is_part_of_the_contract() raises:
    var system = build_derived_system(sigma(), component())
    var h = prefix_map()
    assert_equal(candidate_good_edge_mask(system, h), 2)

    # Corrupt only the first raw-child orientation of A. Endpoint-only viability
    # still predicts phase 1, but the actual derived first-child occurrence now
    # has the wrong hub residual, so no candidate good edge survives.
    system.child_signs[0][0] = 1
    assert_equal(candidate_good_edge_phase(system, h, 1), -1)
    assert_equal(candidate_good_edge_mask(system, h), 0)
    assert_equal(candidate_good_edge_count(system, h), 0)
    assert_equal(unique_candidate_hub(system, h), -1)


def test_malformed_system_fails_before_endpoint_early_rejection() raises:
    var system = malformed_empty_child_system()
    # Type G has no admissible selector phase, so the old implementation returned
    # mask 0 before ever noticing that the derived child word was malformed.
    var type_g: List[Int] = [1, 2, 0]
    var caught = False
    try:
        _ = candidate_good_edge_mask(system, type_g)
    except:
        caught = True
    assert_true(caught)


def main() raises:
    test_nonpisot_control_has_one_finite_compatible_good_edge()
    print("[PASS] test_nonpisot_control_has_one_finite_compatible_good_edge")
    test_actual_first_child_residual_is_part_of_the_contract()
    print("[PASS] test_actual_first_child_residual_is_part_of_the_contract")
    test_malformed_system_fails_before_endpoint_early_rejection()
    print("[PASS] test_malformed_system_fails_before_endpoint_early_rejection")
    print("3 system good-edge Mojo tests passed.")
    require_claim("GlobalEndpointSync")
