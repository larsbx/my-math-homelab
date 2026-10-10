"""Canonical Mojo regressions for the relative hierarchy-offset state."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_contract, require_claim
from psc.derived_system import (
    OrientedSymbol,
    build_derived_system,
    context_around_block,
    oriented_derived_word,
)
from psc.hierarchy_offset import (
    Vec3,
    relative_hierarchy_offset,
    relative_hierarchy_offset_from_defect,
)
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


def test_derived_system_interns_once_and_tracks_orientation() raises:
    var system = build_derived_system(sigma(), component())
    assert_equal(system.size(), 2)
    assert_equal(system.images[0][0], 0)
    assert_equal(system.images[0][1], 1)
    assert_equal(system.child_signs[0][0], -1)
    assert_equal(system.child_signs[0][1], 1)
    assert_equal(system.images[1][0], 0)
    assert_equal(system.images[1][1], 1)
    assert_equal(system.child_signs[1][0], 1)
    assert_equal(system.child_signs[1][1], -1)

    var depth1 = oriented_derived_word(system, 0, 1)
    assert_equal(depth1[0], OrientedSymbol(0, -1))
    assert_equal(depth1[1], OrientedSymbol(1, 1))

    var depth2 = oriented_derived_word(system, 0, 2)
    assert_equal(len(depth2), 4)
    assert_equal(depth2[0], OrientedSymbol(0, 1))
    assert_equal(depth2[1], OrientedSymbol(1, -1))
    assert_equal(depth2[2], OrientedSymbol(0, 1))
    assert_equal(depth2[3], OrientedSymbol(1, -1))


def test_relative_offset_is_compact_and_bounded() raises:
    var system = build_derived_system(sigma(), component())
    var state = relative_hierarchy_offset(
        sigma(),
        system,
        0,
        1,
        1,
        2,
        Vec3(0, 0, 0),
        1,
    )
    assert_equal(state.defect, Vec3(-1, 0, 0))
    assert_equal(state.cut_delta, -1)
    assert_equal(state.block_index_delta, -1)
    assert_equal(state.top_block_offset, 1)
    assert_equal(state.bottom_block_offset, 0)
    assert_equal(state.top_state_id, 0)
    assert_equal(state.top_orientation, -1)
    assert_equal(state.bottom_state_id, 1)
    assert_equal(state.bottom_orientation, 1)
    # Packed context: sentinel=4, A-=1, B+=2.
    assert_equal(state.top_context, [4, 1])
    assert_equal(state.bottom_context, [1, 2])
    assert_true(abs(state.block_index_delta) <= abs(state.cut_delta))


def test_hot_constructor_matches_verification_wrapper() raises:
    var system = build_derived_system(sigma(), component())
    var checked = relative_hierarchy_offset(
        sigma(),
        system,
        0,
        1,
        1,
        2,
        Vec3(0, 0, 0),
        1,
    )
    var hot = relative_hierarchy_offset_from_defect(
        system,
        0,
        1,
        1,
        2,
        Vec3(-1, 0, 0),
        Vec3(0, 0, 0),
        1,
    )
    assert_equal(hot.defect, checked.defect)
    assert_equal(hot.cut_delta, checked.cut_delta)
    assert_equal(hot.block_index_delta, checked.block_index_delta)
    assert_equal(hot.top_block_offset, checked.top_block_offset)
    assert_equal(hot.bottom_block_offset, checked.bottom_block_offset)
    assert_equal(hot.top_state_id, checked.top_state_id)
    assert_equal(hot.bottom_state_id, checked.bottom_state_id)
    assert_equal(hot.top_orientation, checked.top_orientation)
    assert_equal(hot.bottom_orientation, checked.bottom_orientation)
    assert_equal(hot.top_context, checked.top_context)
    assert_equal(hot.bottom_context, checked.bottom_context)


def test_reversed_parent_swaps_physical_sides_and_orientation() raises:
    var system = build_derived_system(sigma(), component())
    var state = relative_hierarchy_offset(
        sigma(),
        system,
        0,
        1,
        2,
        1,
        Vec3(0, 0, 0),
        1,
        -1,
    )
    assert_equal(state.defect, Vec3(1, 0, 0))
    assert_equal(state.cut_delta, 1)
    assert_equal(state.block_index_delta, 1)
    assert_equal(state.top_state_id, 1)
    assert_equal(state.top_orientation, -1)
    assert_equal(state.bottom_state_id, 0)
    assert_equal(state.bottom_orientation, 1)


def test_context_packing_uses_one_sentinel() raises:
    var system = build_derived_system(sigma(), component())
    var word = oriented_derived_word(system, 0, 1)
    var context = context_around_block(system, word, 0, 2)
    assert_equal(context, [4, 4, 1, 2])


def main() raises:
    test_derived_system_interns_once_and_tracks_orientation()
    print("[PASS] test_derived_system_interns_once_and_tracks_orientation")
    test_relative_offset_is_compact_and_bounded()
    print("[PASS] test_relative_offset_is_compact_and_bounded")
    test_hot_constructor_matches_verification_wrapper()
    print("[PASS] test_hot_constructor_matches_verification_wrapper")
    test_reversed_parent_swaps_physical_sides_and_orientation()
    print("[PASS] test_reversed_parent_swaps_physical_sides_and_orientation")
    test_context_packing_uses_one_sentinel()
    print("[PASS] test_context_packing_uses_one_sentinel")
    print("5 hierarchy-offset Mojo tests passed.")
    require_claim("OrientationMonodromy")
    require_contract("the derived system interns each normalized state once and packs relative context with one sentinel")
