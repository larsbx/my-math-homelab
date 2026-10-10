"""Exact regressions for the seed-patch overlap diagnostic."""

from std.testing import assert_equal, assert_false, assert_true
from psc.bpa import build, nonproductive_states, substitution_incidence
from finite_linear_algebra.mat3 import Mat3
from mojo_smoke.claims import require_claim, require_contract
from psc.overlap_obstruction import common_child_start_count, nonproductive_sink_sccs
from psc.overlap_seed_patch import (
    OverlapState,
    PerronCache,
    SeedOverlapAutomaton,
    SeedOverlapTables,
    build_seed_overlap_graph,
    build_seed_overlap_graph_from_tables,
    build_seed_overlap_tables,
    first_coincidence_depths,
    first_left_aligned_depths,
    incidence_key,
    nonproductive_overlap_states,
    overlap_children,
    seed_overlap_states,
    strong_coincidence_depth,
    strong_coincidence_depth_from,
)
from psc.perron_field3 import (
    MAX_CERTIFIED_COLUMN_SUM,
    CubicElt,
    build_perron_field3,
    sign_at_perron,
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


def identity_sigma() -> List[List[Int]]:
    var a0: List[Int] = [0]
    var a1: List[Int] = [1]
    var a2: List[Int] = [2]
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


def test_perron_order_is_exact_on_basic_elements() raises:
    var sigma = determinant_two_sigma()
    var m = Mat3(substitution_incidence(sigma))
    var field = build_perron_field3(m)
    assert_equal(sign_at_perron(field, CubicElt()), 0)
    assert_equal(sign_at_perron(field, CubicElt(1, 0, 0)), 1)
    assert_equal(sign_at_perron(field, CubicElt(-1, 0, 0)), -1)
    assert_equal(sign_at_perron(field, CubicElt(-1, 1, 0)), 1)  # beta - 1

    # Codex review found that rational midpoint isolation could overflow before
    # resolving this near-Perron linear form. The Sturm--Tarski implementation
    # must classify it exactly without denominator growth.
    assert_equal(sign_at_perron(field, CubicElt(-152138, 67035, 0)), -1)


def test_canonical_seed_overlap_graph_is_productive() raises:
    var sigma = determinant_two_sigma()
    var tables = build_seed_overlap_tables(sigma)
    var seeds = seed_overlap_states(tables)
    assert_equal(len(seeds), 9)

    var graph = build_seed_overlap_graph(sigma, 20000)
    assert_false(graph.capped)
    assert_equal(graph.size(), 628)
    assert_equal(len(nonproductive_overlap_states(graph)), 0)
    assert_equal(len(nonproductive_sink_sccs(graph)), 0)

    # Compare only the finite productivity verdict. Equality of the two graph
    # constructions is not yet a theorem or asserted by this test.
    var bpa = build(sigma, 20000)
    assert_false(bpa.capped)
    assert_equal(len(nonproductive_states(bpa)), 0)

    print("canonical seed-overlap initial states:", len(seeds))
    print("canonical seed-overlap graph states:", graph.size())


def test_capped_productivity_query_fails_closed() raises:
    var graph = build_seed_overlap_graph(determinant_two_sigma(), 1)
    assert_true(graph.capped)
    var caught = False
    try:
        _ = nonproductive_overlap_states(graph)
    except:
        caught = True
    assert_true(caught)


def test_non_pip_substitution_is_rejected() raises:
    var caught = False
    try:
        _ = build_seed_overlap_tables(identity_sigma())
    except:
        caught = True
    assert_true(caught)


def test_large_incidence_is_rejected_before_unchecked_pip_arithmetic() raises:
    # This primitive PIP family has characteristic polynomial x^3-n*x^2-1.
    # A large n would overflow the legacy fixed-width primitivity/charpoly
    # predicates.  The overlap kernel must reject it before calling them.
    var large = Mat3([0, 0, 1, 1, 0, 0, 0, 1, Int.MAX])
    var caught = False
    try:
        _ = build_perron_field3(large)
    except:
        caught = True
    assert_true(caught)


def test_first_coincidence_depths_pin_exact_values() raises:
    var graph = build_seed_overlap_graph(determinant_two_sigma(), 20000)
    var depths = first_coincidence_depths(graph)
    assert_equal(len(depths), 628)
    var worst = 0
    var zeros = 0
    for i in range(len(depths)):
        assert_true(depths[i] >= 0)
        if depths[i] > worst:
            worst = depths[i]
        if depths[i] == 0:
            zeros += 1
    assert_equal(worst, 16)
    assert_equal(zeros, 2)


def test_left_aligned_and_strong_coincidence_depths_pin_exact_values() raises:
    var sigma = determinant_two_sigma()
    var graph = build_seed_overlap_graph(sigma, 20000)
    var tables = build_seed_overlap_tables(sigma)
    var left = first_left_aligned_depths(graph)
    var coinc = first_coincidence_depths(graph)
    assert_equal(len(left), 628)
    var worst = 0
    var zeros = 0
    for i in range(len(left)):
        assert_true(left[i] >= 0)
        assert_true(left[i] <= coinc[i])
        if left[i] > worst:
            worst = left[i]
        if left[i] == 0:
            zeros += 1
    assert_equal(worst, 15)
    assert_equal(zeros, 7)
    var prefix = strong_coincidence_depth(graph, tables, False)
    var suffix = strong_coincidence_depth(graph, tables, True)
    assert_equal(prefix, 6)
    assert_equal(suffix, 1)
    assert_equal(strong_coincidence_depth_from(coinc, graph, tables, False), 6)
    assert_equal(strong_coincidence_depth_from(coinc, graph, tables, True), 1)
    var from_tables = build_seed_overlap_graph_from_tables(tables, 20000)
    assert_equal(from_tables.size(), graph.size())
    var capped = build_seed_overlap_graph_from_tables(tables, 1)
    assert_true(capped.capped)
    var fake: List[Int] = [0]
    var caught = False
    try:
        _ = strong_coincidence_depth_from(fake, capped, tables, False)
    except:
        caught = True
    assert_true(caught)
    for i in range(len(coinc)):
        assert_true(coinc[i] <= left[i] + prefix)


def test_common_child_starts_are_exactly_zero_shift_children() raises:
    var sigma = determinant_two_sigma()
    var tables = build_seed_overlap_tables(sigma)
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    assert_false(graph.capped)

    for i in range(graph.size()):
        if graph.states[i].is_coincidence():
            continue
        var cs = overlap_children(tables, graph.states[i])
        var zero_shift_children = 0
        for j in range(len(cs)):
            if cs[j].shift.is_zero():
                zero_shift_children += 1
        assert_equal(
            common_child_start_count(tables, graph.states[i]), zero_shift_children
        )


def test_nonproductive_sink_obstruction_is_extracted_exactly() raises:
    # Synthetic complete graph: 0 is a coincidence, 1 reaches it, 2 feeds the
    # closed bad SCC {3,4}.  The obstruction extractor must discard the
    # transient bad vertex 2 and return the recurrent child-closed core.
    var states = List[OverlapState]()
    states.append(OverlapState(0, 0, CubicElt()))
    states.append(OverlapState(0, 1, CubicElt(1, 0, 0)))
    states.append(OverlapState(1, 2, CubicElt(2, 0, 0)))
    states.append(OverlapState(1, 2, CubicElt(3, 0, 0)))
    states.append(OverlapState(2, 0, CubicElt(4, 0, 0)))

    var adj = List[List[Int]]()
    var a0 = List[Int]()
    var a1: List[Int] = [0]
    var a2: List[Int] = [3]
    var a3: List[Int] = [4]
    var a4: List[Int] = [3]
    adj.append(a0^)
    adj.append(a1^)
    adj.append(a2^)
    adj.append(a3^)
    adj.append(a4^)

    var graph = SeedOverlapAutomaton(states, adj, False)
    var bad = nonproductive_overlap_states(graph)
    assert_equal(len(bad), 3)
    assert_true(_contains_int(bad, 2))
    assert_true(_contains_int(bad, 3))
    assert_true(_contains_int(bad, 4))

    var sinks = nonproductive_sink_sccs(graph)
    assert_equal(len(sinks), 1)
    assert_equal(len(sinks[0]), 2)
    assert_true(_contains_int(sinks[0], 3))
    assert_true(_contains_int(sinks[0], 4))
    assert_false(_contains_int(sinks[0], 2))

    var capped = SeedOverlapAutomaton(states, adj, True)
    var caught = False
    try:
        _ = nonproductive_sink_sccs(capped)
    except:
        caught = True
    assert_true(caught)


def reordered_pair() -> List[List[List[Int]]]:
    """`0->1, 1->2, 2->01` and `0->1, 1->2, 2->10`.

    The two differ only in the order of the image of 2, so they share an
    incidence matrix -- and with it a Perron field and tile lengths -- while
    their prefix positions differ: over `01` the child `1` starts at the
    length of tile 0, over `10` the child `0` starts at the length of tile 1.
    The pair is what separates the part of a build that may be shared from the
    part that may not.
    """
    var first: List[List[Int]] = [[1], [2], [0, 1]]
    var second: List[List[Int]] = [[1], [2], [1, 0]]
    var both = List[List[List[Int]]]()
    both.append(first^)
    both.append(second^)
    return both^


def assert_same_tables(a: SeedOverlapTables, b: SeedOverlapTables) raises:
    assert_equal(a.field.chi0, b.field.chi0)
    assert_equal(a.field.chi1, b.field.chi1)
    assert_equal(a.field.chi2, b.field.chi2)
    for letter in range(3):
        assert_true(a.lengths.at(letter) == b.lengths.at(letter))
    assert_equal(len(a.prefix_starts), len(b.prefix_starts))
    for i in range(len(a.prefix_starts)):
        assert_equal(a.prefix_starts[i], b.prefix_starts[i])
    assert_equal(len(a.prefix_positions), len(b.prefix_positions))
    for i in range(len(a.prefix_positions)):
        assert_true(a.prefix_positions[i] == b.prefix_positions[i])


def test_the_perron_cache_rebuilds_the_tables_it_shares() raises:
    """A cached build is the build: same field, same lengths, same positions.

    Sharing is keyed on the incidence matrix, which is exactly what the field
    and the tile lengths are read from. The prefix positions are not: they are
    recomputed per substitution, and the reordered pair below would be wrong
    if they were shared, so the test pins both halves at once -- one matrix
    built once, two sets of positions that differ.
    """
    var pair = reordered_pair()
    assert_equal(incidence_key(pair[0]), incidence_key(pair[1]))
    var cache = PerronCache()
    for i in range(len(pair)):
        assert_same_tables(cache.tables_for(pair[i]), build_seed_overlap_tables(pair[i]))
    assert_equal(cache.distinct_matrices(), 1)
    var first = cache.tables_for(pair[0])
    var second = cache.tables_for(pair[1])
    var differ = False
    for i in range(len(first.prefix_positions)):
        if not (first.prefix_positions[i] == second.prefix_positions[i]):
            differ = True
    assert_true(differ)
    # The canonical specimen goes through the cache unchanged as well.
    assert_same_tables(
        cache.tables_for(determinant_two_sigma()),
        build_seed_overlap_tables(determinant_two_sigma()),
    )
    assert_equal(cache.distinct_matrices(), 2)


def test_the_perron_cache_refuses_what_a_bare_build_refuses() raises:
    """Validation is not something a cache may skip on a second sighting."""
    var cache = PerronCache()
    _ = cache.tables_for(determinant_two_sigma())
    var caught = False
    try:
        _ = cache.tables_for(identity_sigma())
    except:
        caught = True
    assert_true(caught)


def tail_heavy_sigma(tail: Int) -> List[List[Int]]:
    """`0 -> 1, 1 -> 2, 2 -> 0 2^tail`: PIP with an image of length `tail + 1`
    for `tail = 2, 5, 6`, so it probes the domain boundary on PIP inputs."""
    var a: List[Int] = [1]
    var b: List[Int] = [2]
    var c: List[Int] = [0]
    for _ in range(tail):
        c.append(2)
    var sigma = List[List[Int]]()
    sigma.append(a^)
    sigma.append(b^)
    sigma.append(c^)
    return sigma^


def test_the_certified_domain_ends_at_column_sum_six() raises:
    """A PIP matrix with column sum six builds; one with column sum seven is
    refused before the unchecked predicates, although it is PIP too."""
    assert_equal(MAX_CERTIFIED_COLUMN_SUM, 6)
    _ = build_perron_field3(Mat3(substitution_incidence(tail_heavy_sigma(5))))
    var caught = False
    try:
        _ = build_perron_field3(Mat3(substitution_incidence(tail_heavy_sigma(6))))
    except:
        caught = True
    assert_true(caught)


def test_the_perron_cache_keeps_refusing_after_a_failed_build() raises:
    """A refused build must leave no cache entry behind: the second sighting
    of the same incidence matrix raises again instead of reading a slot that
    was never filled."""
    var cache = PerronCache()
    for _ in range(2):
        var caught = False
        try:
            _ = cache.tables_for(tail_heavy_sigma(6))
        except:
            caught = True
        assert_true(caught)
    assert_equal(cache.distinct_matrices(), 0)
    assert_same_tables(
        cache.tables_for(determinant_two_sigma()),
        build_seed_overlap_tables(determinant_two_sigma()),
    )
    assert_equal(cache.distinct_matrices(), 1)


def cube_image_sigma() -> List[List[Int]]:
    """`0 -> 1, 1 -> 222, 2 -> 0222`: PIP, determinant 3, total image length 8."""
    var a: List[Int] = [1]
    var b: List[Int] = [2, 2, 2]
    var c: List[Int] = [0, 2, 2, 2]
    var sigma = List[List[Int]]()
    sigma.append(a^)
    sigma.append(b^)
    sigma.append(c^)
    return sigma^


def test_the_cube_image_specimen_has_a_productive_depth_19_overlap_graph() raises:
    """The finite certificate behind the bounded-gap termination argument of
    docs/bpa-termination-by-overlap-depth-2026-10-02.md: the overlap graph
    from all three swap seeds is finite, uncapped and productive, with
    maximum first-coincidence depth exactly 19."""
    var tables = build_seed_overlap_tables(cube_image_sigma())
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    assert_false(graph.capped)
    assert_equal(graph.size(), 1142)
    assert_equal(len(nonproductive_overlap_states(graph)), 0)
    var depths = first_coincidence_depths(graph)
    var worst = 0
    for v in range(len(depths)):
        assert_true(depths[v] >= 0)
        if depths[v] > worst:
            worst = depths[v]
    assert_equal(worst, 19)


def test_the_cube_image_specimen_reaches_a_half_coincidence_by_depth_17() raises:
    """The certificate behind the half-coincidence strengthening (Proposition 3
    of docs/bpa-termination-by-overlap-depth-2026-10-02.md): every vertex has
    an offset-zero descendant, at depth at most 17."""
    var graph = build_seed_overlap_graph_from_tables(build_seed_overlap_tables(cube_image_sigma()), 20000)
    var left = first_left_aligned_depths(graph)
    var worst = 0
    for v in range(len(left)):
        assert_true(left[v] >= 0)
        if left[v] > worst:
            worst = left[v]
    assert_equal(worst, 17)


def main() raises:
    test_perron_order_is_exact_on_basic_elements()
    print("[PASS] test_perron_order_is_exact_on_basic_elements")
    test_canonical_seed_overlap_graph_is_productive()
    print("[PASS] test_canonical_seed_overlap_graph_is_productive")
    test_capped_productivity_query_fails_closed()
    print("[PASS] test_capped_productivity_query_fails_closed")
    test_non_pip_substitution_is_rejected()
    print("[PASS] test_non_pip_substitution_is_rejected")
    test_large_incidence_is_rejected_before_unchecked_pip_arithmetic()
    print("[PASS] test_large_incidence_is_rejected_before_unchecked_pip_arithmetic")
    test_first_coincidence_depths_pin_exact_values()
    print("[PASS] test_first_coincidence_depths_pin_exact_values")
    test_left_aligned_and_strong_coincidence_depths_pin_exact_values()
    print("[PASS] test_left_aligned_and_strong_coincidence_depths_pin_exact_values")
    test_common_child_starts_are_exactly_zero_shift_children()
    print("[PASS] test_common_child_starts_are_exactly_zero_shift_children")
    test_nonproductive_sink_obstruction_is_extracted_exactly()
    print("[PASS] test_nonproductive_sink_obstruction_is_extracted_exactly")
    test_the_perron_cache_rebuilds_the_tables_it_shares()
    print("[PASS] test_the_perron_cache_rebuilds_the_tables_it_shares")
    test_the_perron_cache_refuses_what_a_bare_build_refuses()
    print("[PASS] test_the_perron_cache_refuses_what_a_bare_build_refuses")
    test_the_certified_domain_ends_at_column_sum_six()
    print("[PASS] test_the_certified_domain_ends_at_column_sum_six")
    test_the_perron_cache_keeps_refusing_after_a_failed_build()
    print("[PASS] test_the_perron_cache_keeps_refusing_after_a_failed_build")
    test_the_cube_image_specimen_has_a_productive_depth_19_overlap_graph()
    print("[PASS] test_the_cube_image_specimen_has_a_productive_depth_19_overlap_graph")
    test_the_cube_image_specimen_reaches_a_half_coincidence_by_depth_17()
    print("[PASS] test_the_cube_image_specimen_reaches_a_half_coincidence_by_depth_17")
    print("15 seed-patch-overlap Mojo tests passed.")
    require_claim("SwapOverlapFiniteness")
    require_claim("AlignedOverlapsAreStrongCoincidence")
    require_claim("BoundaryCoincidenceCriterion")
    require_contract("0 -> 1, 1 -> 222, 2 -> 0222 has an uncapped productive seed-patch overlap graph of 1142 states with maximum first-coincidence depth 19")
    require_contract("every seed-patch overlap of 0 -> 1, 1 -> 222, 2 -> 0222 has an offset-zero descendant, with maximum first left-aligned depth 17")
