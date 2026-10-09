"""Exact regressions for radius-m collars of seed-patch occurrences."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_claim
from psc.overlap_affine_pump import AffinePumpCertificate, first_zero_shift_free_affine_pump, occurrence_edges
from psc.overlap_collar import (
    Collar,
    build_collared_graph,
    collapsing_seed_pair_count,
    collared_seeds,
    inflate_collar,
    is_proper_power,
    legal_collared_count,
    legal_factors,
    lift_affine_pump,
    patch_power_level,
    seed_collar,
    separation_radius,
    unresolved_collisions,
    word_key,
)
from psc.perron_field3 import CubicElt
from psc.overlap_seed_patch import (
    SeedOverlapAutomaton,
    build_seed_overlap_graph_from_tables,
    build_seed_overlap_tables,
    seed_overlap_states,
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


def same_word(a: List[Int], b: List[Int]) -> Bool:
    if len(a) != len(b):
        return False
    for k in range(len(a)):
        if a[k] != b[k]:
            return False
    return True


def patch_collar(
    sigma: List[List[Int]], a: Int, b: Int, letters: List[Int], child_indices: List[Int], radius: Int
) raises -> Collar:
    """The collar read directly off the inflated periodic patch sigma^n((ab)^Z)."""
    var word = List[Int]()
    for _ in range(2 * radius + 3):
        word.append(a)
        word.append(b)
    var pos = 2 * (radius + 1) + (1 if letters[0] != a else 0)
    for step in range(len(letters)):
        assert_equal(word[pos], letters[step])
        if step + 1 == len(letters):
            break
        var next_pos = child_indices[step]
        var image = List[Int]()
        for k in range(len(word)):
            if k < pos:
                next_pos += len(sigma[word[k]])
            for j in range(len(sigma[word[k]])):
                image.append(sigma[word[k]][j])
        word = image^
        pos = next_pos
    var left = List[Int]()
    var right = List[Int]()
    for k in range(pos - radius, pos):
        left.append(word[k])
    for k in range(pos + 1, pos + 1 + radius):
        right.append(word[k])
    return Collar(left, right)


def test_collar_recursion_matches_the_inflated_periodic_patch() raises:
    var sigma = determinant_two_sigma()
    var radii: List[Int] = [0, 1, 3, 5]
    for a in range(3):
        for b in range(a + 1, 3):
            # Two ancestry paths: a -> first child -> first child, and b -> last child -> first child.
            var paths_letters = List[List[Int]]()
            var paths_children = List[List[Int]]()
            var l1: List[Int] = [a, sigma[a][0], sigma[sigma[a][0]][0]]
            var c1: List[Int] = [0, 0, 0]
            var last = len(sigma[b]) - 1
            var l2: List[Int] = [b, sigma[b][last], sigma[sigma[b][last]][0]]
            var c2: List[Int] = [last, 0, 0]
            paths_letters.append(l1^)
            paths_children.append(c1^)
            paths_letters.append(l2^)
            paths_children.append(c2^)
            for p in range(2):
                for r in range(len(radii)):
                    var radius = radii[r]
                    var letters = paths_letters[p].copy()
                    var partner = b if letters[0] == a else a
                    var collar = seed_collar(letters[0], partner, radius)
                    for step in range(len(letters) - 1):
                        collar = inflate_collar(sigma, collar, letters[step], paths_children[p][step], radius)
                    var direct = patch_collar(sigma, a, b, letters, paths_children[p], radius)
                    assert_true(same_word(collar.left, direct.left))
                    assert_true(same_word(collar.right, direct.right))


def test_affine_state_alone_leaves_collisions_and_radius_one_resolves_them() raises:
    var tables = build_seed_overlap_tables(determinant_two_sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var affine = build_collared_graph(tables, graph, 0)
    assert_equal(affine.size(), 628)
    assert_equal(graph.size(), 628)
    assert_equal(len(unresolved_collisions(affine)), 269)
    var edge_count = 0
    for k in range(graph.size()):
        edge_count += len(occurrence_edges(tables, graph, k))
    assert_equal(len(affine.edges), edge_count)
    var collared = build_collared_graph(tables, graph, 1)
    assert_equal(collared.size(), 1866)
    var largest_fibre = 0
    for k in range(graph.size()):
        var fibre = len(collared.fibre(k))
        if fibre > largest_fibre:
            largest_fibre = fibre
    assert_equal(largest_fibre, 15)
    assert_equal(len(unresolved_collisions(collared)), 0)
    assert_equal(separation_radius(tables, graph, 3), 1)
    assert_equal(len(collared_seeds(tables, graph, 1)), len(seed_overlap_states(tables)))


def test_golden_pump_lifts_to_an_eventually_constant_collar() raises:
    var tables = build_seed_overlap_tables(determinant_two_sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var certificates = first_zero_shift_free_affine_pump(tables, graph)
    assert_equal(len(certificates), 1)
    assert_equal(len(certificates[0].edges), 6)
    var radii: List[Int] = [1, 2, 4]
    var fibre_sizes: List[Int] = [11, 12, 16]
    for r in range(len(radii)):
        var orbits = lift_affine_pump(tables, graph, build_collared_graph(tables, graph, radii[r]), certificates[0])
        assert_equal(len(orbits), fibre_sizes[r])
        var seen_zero = False
        var seen_one = False
        for o in range(len(orbits)):
            assert_equal(orbits[o].period, 1)
            assert_true(orbits[o].preperiod == 0 or orbits[o].preperiod == 1)
            seen_zero = seen_zero or orbits[o].preperiod == 0
            seen_one = seen_one or orbits[o].preperiod == 1
        assert_true(seen_zero and seen_one)


def test_most_collared_tiles_are_legal_factors() raises:
    var sigma = determinant_two_sigma()
    var legal = legal_factors(sigma, 2)
    assert_equal(len(legal), 9)
    var w02: List[Int] = [0, 2]
    var w12: List[Int] = [1, 2]
    var w22: List[Int] = [2, 2]
    assert_true(word_key(w02) in legal)
    assert_true(word_key(w12) not in legal)
    assert_true(word_key(w22) not in legal)
    var tables = build_seed_overlap_tables(sigma)
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    assert_equal(legal_collared_count(tables, graph, build_collared_graph(tables, graph, 1)), 1854)


def collapsing_sigma() -> List[List[Int]]:
    # sigma(1)sigma(2) = 2 020 = (20)^2: the level-one patch of the pair {1,2} is (20)^Z.
    var a0: List[Int] = [1, 0, 2]
    var a1: List[Int] = [2]
    var a2: List[Int] = [0, 2, 0]
    var sigma = List[List[Int]]()
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def test_a_collision_surviving_every_radius_comes_from_a_collapsing_patch() raises:
    var sigma = collapsing_sigma()
    var tables = build_seed_overlap_tables(sigma)
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    assert_equal(graph.size(), 126)
    assert_equal(separation_radius(tables, graph, 8), -1)
    var collared = build_collared_graph(tables, graph, 8)
    var survivors = unresolved_collisions(collared)
    assert_equal(len(survivors), 3)
    var witness = collared.states[survivors[0]].copy()
    assert_equal(graph.states[witness.state_index].top, 2)
    assert_equal(graph.states[witness.state_index].bottom, 0)
    for k in range(8):  # the periodic word (20)^Z around both tiles
        assert_equal(witness.top.left[k], 2 if k % 2 == 0 else 0)
        assert_equal(witness.bottom.right[k], 2 if k % 2 == 0 else 0)
    var w2020: List[Int] = [2, 0, 2, 0]
    var w202: List[Int] = [2, 0, 2]
    assert_true(is_proper_power(w2020))
    assert_true(not is_proper_power(w202))
    assert_equal(patch_power_level(sigma, 1, 2, 6), 1)
    assert_equal(patch_power_level(sigma, 0, 2, 6), -1)
    assert_equal(collapsing_seed_pair_count(sigma, 6), 1)
    assert_equal(collapsing_seed_pair_count(determinant_two_sigma(), 6), 0)
    var caught = False
    try:
        _ = patch_power_level(sigma, 0, 1, 0)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:  # (a, a) is not a swap seed, and sigma(a)sigma(a) is always a power
        _ = patch_power_level(sigma, 1, 1, 6)
    except:
        caught = True
    assert_true(caught)


def late_separating_sigma() -> List[List[Int]]:
    """`0 -> 1, 1 -> 2, 2 -> 022102`: PIP with total image length 8."""
    var a0: List[Int] = [1]
    var a1: List[Int] = [2]
    var a2: List[Int] = [0, 2, 2, 1, 0, 2]
    var sigma = List[List[Int]]()
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def test_a_non_collapsing_collision_can_need_radius_nine() raises:
    """A collision can outlive radius 8 without any collapsing patch: here no
    seed patch is a proper power through level 14, one collision survives at
    radius 8, and radius 9 resolves every ancestry."""
    var sigma = late_separating_sigma()
    var tables = build_seed_overlap_tables(sigma)
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    assert_equal(graph.size(), 31)
    assert_equal(collapsing_seed_pair_count(sigma, 14), 0)
    assert_equal(separation_radius(tables, graph, 8), -1)
    assert_equal(len(unresolved_collisions(build_collared_graph(tables, graph, 8))), 1)
    assert_equal(separation_radius(tables, graph, 12), 9)


def test_fail_closed() raises:
    var sigma = determinant_two_sigma()
    var tables = build_seed_overlap_tables(sigma)
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var caught = False
    try:
        _ = seed_collar(0, 1, -1)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:
        _ = inflate_collar(sigma, seed_collar(0, 1, 1), 0, 1, 1)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:
        _ = build_collared_graph(tables, graph, 1, 100)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:  # a negative radius must not yield an empty collar
        _ = inflate_collar(sigma, seed_collar(0, 1, 1), 0, 0, -1)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:  # radius-1 neighbours with length-one images cannot supply radius 2
        var short_left: List[Int] = [0]
        var short_right: List[Int] = [0]
        _ = inflate_collar(sigma, Collar(short_left, short_right), 0, 0, 2)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:  # later state entries corrupted behind a valid first state and valid edges
        var certificates = first_zero_shift_free_affine_pump(tables, graph)
        var corrupted_states = List[Int]()
        for k in range(len(certificates[0].state_indices)):
            corrupted_states.append(certificates[0].state_indices[0] if k == 0 else -1)
        _ = lift_affine_pump(tables, graph, build_collared_graph(tables, graph, 1), AffinePumpCertificate(corrupted_states, certificates[0].edges))
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:  # a stale child index behind a valid state cycle and ordinal
        var certificates = first_zero_shift_free_affine_pump(tables, graph)
        var stale_edges = certificates[0].edges.copy()
        stale_edges[0].top_child_index += 1
        _ = lift_affine_pump(tables, graph, build_collared_graph(tables, graph, 1), AffinePumpCertificate(certificates[0].state_indices, stale_edges))
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:  # a forged forcing term behind valid states, ordinals and child indices
        var certificates = first_zero_shift_free_affine_pump(tables, graph)
        var forged_edges = certificates[0].edges.copy()
        assert_true(not forged_edges[2].forcing.is_zero())  # the third edge advances the bottom child
        forged_edges[2].forcing = CubicElt()
        _ = lift_affine_pump(tables, graph, build_collared_graph(tables, graph, 1), AffinePumpCertificate(certificates[0].state_indices, forged_edges))
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:  # a certificate from another graph has no starting fibre here
        var other_tables = build_seed_overlap_tables(collapsing_sigma())
        var other = build_seed_overlap_graph_from_tables(other_tables, 20000)
        var certificates = first_zero_shift_free_affine_pump(other_tables, other)
        assert_equal(len(certificates), 1)
        _ = lift_affine_pump(tables, graph, build_collared_graph(tables, graph, 1), certificates[0])
    except:
        caught = True
    assert_true(caught)
    var capped = SeedOverlapAutomaton(graph.states, graph.adj, True)
    caught = False
    try:
        _ = build_collared_graph(tables, capped, 1)
    except:
        caught = True
    assert_true(caught)


def main() raises:
    test_collar_recursion_matches_the_inflated_periodic_patch()
    print("[PASS] test_collar_recursion_matches_the_inflated_periodic_patch")
    test_affine_state_alone_leaves_collisions_and_radius_one_resolves_them()
    print("[PASS] test_affine_state_alone_leaves_collisions_and_radius_one_resolves_them")
    test_golden_pump_lifts_to_an_eventually_constant_collar()
    print("[PASS] test_golden_pump_lifts_to_an_eventually_constant_collar")
    test_most_collared_tiles_are_legal_factors()
    print("[PASS] test_most_collared_tiles_are_legal_factors")
    test_a_collision_surviving_every_radius_comes_from_a_collapsing_patch()
    print("[PASS] test_a_collision_surviving_every_radius_comes_from_a_collapsing_patch")
    test_a_non_collapsing_collision_can_need_radius_nine()
    print("[PASS] test_a_non_collapsing_collision_can_need_radius_nine")
    test_fail_closed()
    print("[PASS] test_fail_closed")
    print("7 overlap-collar Mojo tests passed.")
    require_claim("PeriodicPatchCollar")
    require_claim("FiniteCollarDeath")
