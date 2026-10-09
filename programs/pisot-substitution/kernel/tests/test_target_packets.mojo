"""Exact occurrence/factorization contracts, without a theorem promotion."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_contract
from psc.bpa import build, recurrent_noncoincident_sccs, apply_substitution, coincidence_boundaries
from psc.derived_system import build_derived_system
from psc.target_packets import (
    build_packets, target_free_sccs, cycle_for_scc, replay_path, replay_edge,
    accumulated_forcing, target_distances, shortest_root, success_path,
    potential_values, monovariant_counterexample,
)
from psc.words import Pair


def test_real_addresses_and_zero_are_not_enough() raises:
    var sigma: List[List[Int]] = [[1], [0, 2], [2, 0, 2]]
    var a = build(sigma)
    var g = build_packets(sigma, a)
    var zeros = 0
    var successes = 0
    for i in range(len(g.packets)):
        ref p = g.packets[i]
        if p.residual.is_zero():
            zeros += 1
        if p.success:
            successes += 1
            assert_true(p.interior)
            assert_equal(p.top_letter, p.bottom_letter)
            assert_true(p.key.factor_edge >= 0)
            assert_equal(p.key.top, 0)
            assert_equal(p.key.bottom, 0)
            assert_true(p.top_address.global_position > 0)
    assert_true(zeros > successes)
    assert_true(successes > 0)
    assert_true(g.split_count > 0)
    for i in range(len(g.edges)):
        assert_true(replay_edge(g, i))
    # Mutations must be detected even when the residual remains zero.
    var successful_edge = -1
    for i in range(len(g.edges)):
        if g.packets[g.edges[i].destination].success:
            successful_edge = i
            break
    assert_true(successful_edge >= 0)
    var dst = g.edges[successful_edge].destination
    var bad = g.copy()
    bad.packets[dst].top_address.global_position += 1
    assert_true(not replay_edge(bad, successful_edge))
    bad = g.copy()
    bad.packets[dst].top_letter = (bad.packets[dst].top_letter + 1) % 3
    assert_true(not replay_edge(bad, successful_edge))
    bad = g.copy()
    bad.packets[dst].interior = False
    assert_true(not replay_edge(bad, successful_edge))


def test_target_filter_and_shortest_depth() raises:
    var sigma: List[List[Int]] = [[1], [2], [0, 2, 1]]
    var a = build(sigma)
    var g = build_packets(sigma, a)
    var d = target_distances(g)
    var comps = recurrent_noncoincident_sccs(a)
    assert_true(len(comps) > 0)
    for i in range(len(comps)):
        var root = shortest_root(g, d, comps[i])
        assert_true(root >= 0)
        var path = success_path(g, d, root)
        assert_equal(len(path), d.depth[root])
        assert_true(replay_path(g, path))
    var specific = build_packets(sigma, a, target=2)
    var successes = 0
    var wrong_targets = 0
    for i in range(len(specific.packets)):
        if specific.packets[i].success:
            successes += 1
            assert_equal(specific.packets[i].top_letter, 2)
            assert_equal(specific.packets[i].bottom_letter, 2)
        ref p = specific.packets[i]
        if p.interior and p.residual.is_zero() and p.top_letter == p.bottom_letter and p.top_letter != 2:
            wrong_targets += 1
            assert_true(not p.success)
    assert_true(successes > 0)
    assert_true(wrong_targets > 0)


def test_target_free_cycles_and_monovariant_counterexamples() raises:
    # Primitive, non-Pisot strict calibration from hierarchy_offset.mojo.
    var sigma: List[List[Int]] = [[1], [0, 1, 2], [1]]
    var a = build(sigma)
    var g = build_packets(sigma, a)
    var comps = target_free_sccs(g)
    var reversed = 0
    for i in range(len(g.packets)):
        if g.packets[i].key.sign == -1:
            reversed += 1
    assert_true(reversed > 0)
    assert_true(len(comps) > 0)
    for i in range(len(comps)):
        var path = cycle_for_scc(g, comps[i])
        assert_true(replay_path(g, path, True))
        var forcing = accumulated_forcing(g, path)
        assert_equal(len(forcing), 3)
    var values = potential_values(g, [1, 0, 0], False)
    var witness = monovariant_counterexample(g, values, True)
    assert_true(len(witness) > 0)
    assert_true(replay_path(g, witness))
    var e = g.edges[witness[len(witness) - 1]].copy()
    assert_true(values[e.destination] >= values[e.source])
    var d = target_distances(g)
    var sources = recurrent_noncoincident_sccs(a)
    for i in range(len(sources)):
        assert_equal(shortest_root(g, d, sources[i]), -1)


def test_strong_gf_fails_only_actual_factorization() raises:
    # Existing synthetic_degree2.py golden, translated to zero-based letters.
    var sigma: List[List[Int]] = [[1], [2], [0, 2, 1]]
    var states = List[Pair]()
    states.append(Pair([0, 2, 1], [1, 2, 0]))
    states.append(Pair([1, 0, 1, 2, 2], [2, 0, 1, 2, 1]))
    states.append(Pair([0, 1, 1, 2, 0, 2, 2, 2, 1], [2, 0, 1, 2, 2, 1, 1, 0, 2]))
    var expected_counts: List[Int] = [1, 2, 5]
    for i in range(len(states)):
        assert_equal(len(coincidence_boundaries(states[i].u, states[i].v)), 2)
        var top = apply_substitution(sigma, states[i].u)
        var bottom = apply_substitution(sigma, states[i].v)
        var cuts = coincidence_boundaries(top, bottom)
        assert_equal(len(cuts) - 1, expected_counts[i])
        # The third actual word produces a diagonal 2/2, unlike the template.
        if i == 2:
            var diagonal = False
            for j in range(1, len(cuts) - 1):
                var k = cuts[j]
                if top[k] == 2 and bottom[k] == 2:
                    diagonal = True
            assert_true(diagonal)
    var caught = False
    try:
        _ = build_derived_system(sigma, states)
    except:
        caught = True
    assert_true(caught)
    # The actual graph is accepted, including its G/F endpoint maps.
    var actual = build_packets(sigma, build(sigma))
    assert_true(len(actual.edges) > 0)


def test_caps_fail_closed() raises:
    var sigma: List[List[Int]] = [[0, 1], [0, 2], [0]]
    var a = build(sigma)
    var caught = False
    try:
        _ = build_packets(sigma, a, packet_cap=1)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:
        _ = build_packets(sigma, a, edge_cap=1)
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:
        _ = build_packets(sigma, build(sigma, 1))
    except:
        caught = True
    assert_true(caught)


def test_fake_terminal_edges_are_not_realizable() raises:
    var sigma: List[List[Int]] = [[0, 1], [0, 2], [0]]
    var a = build(sigma)
    var terminal = -1
    for s in range(a.size()):
        if a.states[s].is_coincidence():
            terminal = s
            break
    assert_true(terminal >= 0)
    # A claimed complete graph cannot invent child edges after a terminal.
    a.adj[terminal].append(0)
    var caught = False
    try:
        _ = build_packets(sigma, a)
    except:
        caught = True
    assert_true(caught)


def test_documented_seed_and_naive_pair_negatives() raises:
    # PIP; chi=x^3-2x^2-x+1, discriminant 49; first-letter map is a permutation.
    var sigma: List[List[Int]] = [[1], [0, 2], [2, 0, 2]]
    var a = build(sigma)
    var g = build_packets(sigma, a)
    var distances = target_distances(g)
    var root = shortest_root(g, distances, [0])
    assert_true(root >= 0)
    assert_equal(distances.depth[root], 2)
    # Independently expand whole words: no interior cut after one inflation.
    var top = apply_substitution(sigma, [0, 1])
    var bottom = apply_substitution(sigma, [1, 0])
    assert_equal(top, [1, 0, 2])
    assert_equal(bottom, [0, 2, 1])
    assert_equal(coincidence_boundaries(top, bottom), [0, 3])
    top = apply_substitution(sigma, top)
    bottom = apply_substitution(sigma, bottom)
    assert_equal(top, [0, 2, 1, 2, 0, 2])
    assert_equal(bottom, [1, 2, 0, 2, 0, 2])
    assert_equal(coincidence_boundaries(top, bottom), [0, 3, 4, 5, 6])
    assert_true(top[3] == bottom[3])
    # The second letters agree, but their preceding prefixes do not balance.
    assert_true(top[1] == bottom[1])
    assert_true(top[0] != bottom[0])
    # Naive off-diagonal letter inflation cannot exhaust both sides here.
    assert_equal(len(sigma[0]), 1)
    assert_equal(len(sigma[1]), 2)
    assert_true(len(sigma[0]) != len(sigma[1]))
    # Repeating a genuine cycle must not overflow accumulated integer forcing.
    var comps = target_free_sccs(g)
    var cycle = cycle_for_scc(g, comps[0])
    var repeated = List[Int]()
    for _ in range(40):
        for i in range(len(cycle)):
            repeated.append(cycle[i])
    var forcing = accumulated_forcing(g, repeated)
    var large = False
    for i in range(3):
        if forcing[i].num.limb_count() > 3:
            large = True
    assert_true(large)


def test_synchronizing_targets_are_actual_interior_boundaries() raises:
    var sigma: List[List[Int]] = [[0, 1], [0, 2], [0]]
    var g = build_packets(sigma, build(sigma), synchronize=True)
    var non_diagonal_success = False
    for i in range(len(g.packets)):
        ref p = g.packets[i]
        if p.success and p.top_letter != p.bottom_letter:
            assert_true(p.interior and p.residual.is_zero())
            non_diagonal_success = True
    assert_true(non_diagonal_success)
    for i in range(len(g.edges)):
        assert_true(replay_edge(g, i))


def main() raises:
    test_real_addresses_and_zero_are_not_enough()
    test_target_filter_and_shortest_depth()
    test_target_free_cycles_and_monovariant_counterexamples()
    test_strong_gf_fails_only_actual_factorization()
    test_caps_fail_closed()
    test_fake_terminal_edges_are_not_realizable()
    test_documented_seed_and_naive_pair_negatives()
    test_synchronizing_targets_are_actual_interior_boundaries()
    print("[PASS] target packets: addresses, orientation, cycles, depths, replay, caps")
    require_contract("target-aware BPA diagnostics use actual ordered factorization and occurrence addresses; zero residual alone is insufficient; SCCs, shortest existential paths and monovariant counterexamples remain finite diagnostics")
