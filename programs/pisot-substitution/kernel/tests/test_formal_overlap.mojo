"""Regressions for the formal-overlap carrier survey (`psc.formal_overlap`)."""

from std.testing import assert_equal, assert_false, assert_true
from mojo_smoke.claims import require_contract
from psc.formal_overlap import aligned_pair_depth, recurrent_coincidence_free_sccs, survey_formal_overlaps
from psc.overlap_obstruction import recurrent_sccs
from psc.vertex_coincidence import build_box_graph
from psc.overlap_seed_patch import OverlapState, build_seed_overlap_graph_from_tables, build_seed_overlap_tables


def sigma_of(a: List[Int], b: List[Int], c: List[Int]) -> List[List[Int]]:
    return [a.copy(), b.copy(), c.copy()]


def test_plastic_has_realized_and_unrealized_carriers() raises:
    """0 -> 1, 1 -> 2, 2 -> 01 (corpus specimen `1 2 4`): one realized aligned
    carrier and one unrealized strict carrier, both exiting to coincidence."""
    var s = survey_formal_overlaps(build_seed_overlap_tables(sigma_of([1], [2], [0, 1])))
    assert_equal(s.nonproductive, 0)
    assert_true(s.carriers_inside_box)
    assert_equal(len(s.carriers), 2)
    var seen_realized = False
    var seen_unrealized = False
    for c in range(2):
        ref x = s.carriers[c]
        assert_false(x.closed)
        assert_false(x.direct_producer)
        if x.realized:
            seen_realized = True
            assert_equal(x.size(), 58)
            assert_equal(x.cyclomatic(), 19)
            assert_true(x.aligned)
            assert_equal(x.death_depth, 4)
            assert_equal(x.aligned_depth, 0)
            assert_equal(x.proper_aligned_depth, 0)
        else:
            seen_unrealized = True
            assert_equal(x.size(), 16)
            assert_equal(x.cyclomatic(), 3)
            assert_false(x.aligned)
            assert_equal(x.death_depth, 6)
            # The first offset-zero descendant is the coincidence itself; an
            # aligned noncoincident pair is reached only later, at depth 9.
            assert_equal(x.aligned_depth, 6)
            assert_equal(x.proper_aligned_depth, 9)
    assert_true(seen_realized and seen_unrealized)


def test_realized_carriers_are_the_realized_graphs_own() raises:
    """The realized graph's recurrent coincidence-free SCCs are exactly the
    realized formal carriers, member for member."""
    var tables = build_seed_overlap_tables(sigma_of([1], [2], [0, 1]))
    var s = survey_formal_overlaps(tables)
    var realized = build_seed_overlap_graph_from_tables(tables)
    var own = recurrent_coincidence_free_sccs(realized)
    assert_equal(len(own), 1)
    var formal_members = Dict[OverlapState, Bool]()
    for c in range(len(s.carriers)):
        if s.carriers[c].realized:
            for i in range(len(s.carriers[c].members)):
                formal_members[s.formal.states[s.carriers[c].members[i]]] = True
    assert_equal(len(own[0]), len(formal_members))
    for i in range(len(own[0])):
        assert_true(realized.states[own[0][i]] in formal_members)


def test_aligned_remainder_is_bounded_by_the_six_aligned_pairs() raises:
    """`D <= L + S(sigma)` for every carrier: after the first offset-zero
    descendant only a coincidence or one of the six states `(i, j, 0)` can
    have been reached, and each of those dies within `S(sigma)`."""
    var s = survey_formal_overlaps(build_seed_overlap_tables(sigma_of([1], [2], [0, 1])))
    var bound = aligned_pair_depth(s)
    assert_equal(bound, 14)  # loose here: the carriers have D - L <= 4
    for c in range(len(s.carriers)):
        ref x = s.carriers[c]
        assert_true(x.aligned_depth <= x.death_depth)
        assert_true(x.death_depth <= x.aligned_depth + bound)


def _box_recurrent_states(sigma: List[List[Int]]) raises -> Dict[OverlapState, Bool]:
    """Non-coincidence vertices on cycles of the Proposition V box graph."""
    var a = build_box_graph(build_seed_overlap_tables(sigma))
    var comps = recurrent_sccs(a)
    var out = Dict[OverlapState, Bool]()
    for c in range(len(comps)):
        for k in range(len(comps[c])):
            if not a.states[comps[c][k]].is_coincidence():
                out[a.states[comps[c][k]]] = True
    return out^


def test_carriers_are_the_box_graphs_recurrent_vertices() raises:
    """Gap check between the two constructions: the formal carriers (region
    `K_T`, coincidences deleted) cover exactly the recurrent non-coincidence
    vertices of Proposition V's box graph, state for state."""
    var sigmas: List[List[List[Int]]] = [sigma_of([1], [2], [0, 1]), sigma_of([1], [2, 2], [0, 1, 2])]
    for k in range(len(sigmas)):
        var box = _box_recurrent_states(sigmas[k])
        var s = survey_formal_overlaps(build_seed_overlap_tables(sigmas[k]))
        var n = 0
        for c in range(len(s.carriers)):
            for i in range(len(s.carriers[c].members)):
                n += 1
                assert_true(s.formal.states[s.carriers[c].members[i]] in box)
        assert_equal(n, len(box))


def test_single_realized_carrier_specimen() raises:
    """0 -> 1, 1 -> 2, 2 -> 02 (corpus specimen `1 2 5`): no unrealized carrier."""
    var s = survey_formal_overlaps(build_seed_overlap_tables(sigma_of([1], [2], [0, 2])))
    assert_equal(len(s.carriers), 1)
    assert_true(s.carriers[0].realized)
    assert_equal(s.carriers[0].size(), 22)
    assert_equal(s.carriers[0].death_depth, 4)


def test_non_pisot_input_fails_closed() raises:
    """0 -> 1, 1 -> 012, 2 -> 1 is not Pisot: no contraction box exists, and
    the survey raises (at the Perron-field construction) instead of reporting."""
    var raised = False
    try:
        _ = survey_formal_overlaps(build_seed_overlap_tables(sigma_of([1], [0, 1, 2], [1])))
    except:
        raised = True
    assert_true(raised)


def main() raises:
    test_plastic_has_realized_and_unrealized_carriers()
    test_realized_carriers_are_the_realized_graphs_own()
    test_aligned_remainder_is_bounded_by_the_six_aligned_pairs()
    test_carriers_are_the_box_graphs_recurrent_vertices()
    test_single_realized_carrier_specimen()
    test_non_pisot_input_fails_closed()
    print("[PASS] formal overlap carriers: box, realization split, aligned depths, D <= L + S, box-graph agreement, cross-check, fail-closed")
    require_contract("formal overlap carriers are the recurrent coincidence-free SCCs of the closure of a Pisot-contraction box of potential overlaps; each is wholly realized or wholly unrealized, the realized ones are the swap-seed graph's own, together they are exactly the recurrent non-coincidence vertices of the Proposition V box graph, and a non-Pisot input fails closed")
