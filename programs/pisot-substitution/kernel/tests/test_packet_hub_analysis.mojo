"""Golden ordered-hub and offset counter-calibrations for C4 candidate routes."""

from std.testing import assert_equal, assert_true, assert_false
from mojo_smoke.claims import require_contract
from psc.bounded_bpa import build_bounded
from psc.bpa import sigma3, substitution_incidence
from psc.target_packets import PacketGraph, build_packets, replay_path, target_free_sccs
from psc.packet_hub_analysis import (
    ordered_hub_word, packet_support, support_child_closed, compatible_support_phase,
    local_factor_offset, nonzero_cut_subgraph_recurrent, offset_increase_in_scc,
    cycle_hub_word, factor_hub_residual,
)
from psc.hierarchy_offset import Vec3, relative_hierarchy_offset
from psc.derived_system import build_derived_system
from psc.words import Pair
from psc.pisot import is_pip
from finite_linear_algebra.mat3 import Mat3


def fixture_packets(sigma: List[List[Int]]) raises -> PacketGraph:
    var a = build_bounded(sigma3(sigma), 20000, 10000)
    assert_true(a.complete())
    return build_packets(sigma, a.graph)


def test_pip_hub_coherence_does_not_make_offset_descend() raises:
    var sigma: List[List[Int]] = [[1], [0, 2], [2, 0, 2]]
    assert_true(is_pip(Mat3(substitution_incidence(sigma))))
    var g = fixture_packets(sigma)
    var comps = target_free_sccs(g)
    assert_equal(len(comps), 4)
    assert_equal(len(comps[0]), 2)
    assert_equal(packet_support(g, comps[0]), [7, 8])
    assert_equal(compatible_support_phase(g, [7, 8], 0), 1)
    assert_equal(compatible_support_phase(g, [7, 8], 1), 1)
    assert_equal(compatible_support_phase(g, [7, 8], 2), -1)
    assert_false(support_child_closed(g, [7, 8]))
    assert_equal(ordered_hub_word(g, 7, 0), [1])
    assert_equal(ordered_hub_word(g, 8, 0), [1, -1, 1, -1, -1, -1])
    assert_equal(ordered_hub_word(g, 9, 0), [1, -1, 1])
    assert_equal(g.factors[19].ordinal, 2)
    assert_equal(g.factors[19].start, 7)
    assert_equal(g.factors[19].end, 10)
    assert_equal(g.factors[19].total, 13)
    assert_equal(g.factors[16].ordinal, 0)
    var cycle: List[Int] = [396, 820]
    assert_true(replay_path(g, cycle, True))
    assert_equal(cycle_hub_word(g, cycle, 0), [1, 1])
    assert_equal(cycle_hub_word(g, cycle, 1), [1, 1])
    var aligned = local_factor_offset(g, 209)
    var misaligned = local_factor_offset(g, 429)
    assert_equal(aligned.defect, Vec3(-1, 1, 0))
    assert_equal(misaligned.defect, Vec3(1, -1, 1))
    assert_equal(aligned.cut_delta, 0)
    assert_equal(misaligned.cut_delta, 1)
    assert_equal(aligned.block_index_delta, 0)
    assert_equal(misaligned.block_index_delta, 0)
    assert_equal(aligned.top_block_offset, 4)
    assert_equal(aligned.bottom_block_offset, 4)
    assert_equal(misaligned.top_block_offset, 2)
    assert_equal(misaligned.bottom_block_offset, 1)
    assert_equal(aligned.top_context, [20, 17])
    assert_equal(misaligned.top_context, [11, 14])
    assert_true(aligned.physically_aligned())
    assert_false(misaligned.physically_aligned())
    assert_false(g.packets[209].success)
    assert_false(g.packets[429].success)
    assert_equal(offset_increase_in_scc(g, comps[0]), 396)
    # The aligned packet is inside an irreducible block, not a balanced cut.
    assert_equal(g.packets[209].key.top, 4)
    assert_false(g.packets[209].interior)
    for i in range(len(comps)):
        assert_false(nonzero_cut_subgraph_recurrent(g, comps[i]))
    # Returning to alignment in every finite cycle still allows target avoidance.
    # A positive increase around this two-cycle also forbids any strictly
    # decreasing function of the repeating local offset snapshot.


def test_nonpisot_control_matches_the_strict_hierarchy_constructor() raises:
    var sigma: List[List[Int]] = [[1], [0, 1, 2], [1]]
    var g = fixture_packets(sigma)
    var comps = target_free_sccs(g)
    assert_equal(packet_support(g, comps[0]), [0, 2])
    assert_true(support_child_closed(g, [0, 2]))
    assert_equal(compatible_support_phase(g, [0, 2], 1), 1)
    assert_equal(ordered_hub_word(g, 0, 1), [1, 1])
    assert_equal(ordered_hub_word(g, 2, 1), [1, 1])
    var states = List[Pair]()
    states.append(g.bpa.states[0].copy())
    states.append(g.bpa.states[2].copy())
    var strict = build_derived_system(sigma, states)
    for i in range(len(comps[0])):
        var pid = comps[0][i]
        ref p = g.packets[pid]
        ref f = g.factors[p.key.factor_edge]
        var off = local_factor_offset(g, pid)
        var parent_id = 0 if f.parent == 0 else 1
        var verified = relative_hierarchy_offset(sigma, strict, parent_id, 1,
            p.top_address.global_position, p.bottom_address.global_position,
            off.correction, 1, p.key.sign * f.sign)
        assert_equal(off.defect, verified.defect)
        assert_equal(off.correction, verified.correction)
        assert_equal(off.cut_delta, verified.cut_delta)
        assert_equal(off.block_index_delta, verified.block_index_delta)
        assert_equal(off.top_block_offset, verified.top_block_offset)
        assert_equal(off.bottom_block_offset, verified.bottom_block_offset)
        assert_equal(off.top_orientation, verified.top_orientation)
        assert_equal(off.bottom_orientation, verified.bottom_orientation)
        assert_equal(off.top_state_id, 0 if verified.top_state_id == 0 else 2)
        assert_equal(off.bottom_state_id, 0 if verified.bottom_state_id == 0 else 2)
        for j in range(2):
            var symbol = verified.top_context[j]
            var mapped = 2 * g.bpa.size() if symbol == 4 else symbol
            if symbol == 2 or symbol == 3:
                mapped = symbol + 2
            assert_equal(off.top_context[j], mapped)
            assert_equal(off.bottom_context[j], mapped)
    assert_false(nonzero_cut_subgraph_recurrent(g, comps[0]))


def test_gf_control_has_no_compatible_common_hub() raises:
    var sigma: List[List[Int]] = [[1], [2], [0, 2, 1]]
    var g = fixture_packets(sigma)
    var comps = target_free_sccs(g)
    var support = packet_support(g, comps[0])
    assert_equal(support, [1, 2, 3, 5, 6])
    for hub in range(3):
        assert_equal(compatible_support_phase(g, support, hub), -1)
    assert_false(support_child_closed(g, support))
    assert_equal(factor_hub_residual(g, 11, 2), 0)
    assert_equal(ordered_hub_word(g, 6, 2), [-1, 0])
    assert_false(nonzero_cut_subgraph_recurrent(g, comps[0]))


def test_undefined_and_invalid_domains_are_distinct() raises:
    var sigma: List[List[Int]] = [[1], [0, 2], [2, 0, 2]]
    var g = fixture_packets(sigma)
    assert_equal(factor_hub_residual(g, 18, 0), -1)
    var rejected = False
    try:
        _ = factor_hub_residual(g, 18, 3)
    except:
        rejected = True
    assert_true(rejected)
    rejected = False
    try:
        _ = local_factor_offset(g, 0)
    except:
        rejected = True
    assert_true(rejected)


def main() raises:
    test_pip_hub_coherence_does_not_make_offset_descend()
    test_nonpisot_control_matches_the_strict_hierarchy_constructor()
    test_gf_control_has_no_compatible_common_hub()
    test_undefined_and_invalid_domains_are_distinct()
    print("4 ordered-hub/offset counter-calibration tests passed.")
    require_contract("ordered actual hub words retain undefined children; PIP occurrence cycle defeats hub-guarded physical-offset descent; strict hierarchy coordinates agree on the non-Pisot control")
