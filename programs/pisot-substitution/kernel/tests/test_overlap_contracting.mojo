"""Exact regressions for the contracting lower bound (manuscript Proposition 5.42)."""

from std.testing import assert_equal, assert_true
from finite_exact.rat_q import Q, q_rejected
from mojo_smoke.claims import require_contract, require_claim
from psc.exact import q_int, q_poly
from psc.overlap_contracting import (
    ContractingBound,
    ContractingBoundCache,
    bound_key,
    digit_set,
)
from psc.field3 import discriminant, field_norm
from psc.overlap_seed_patch import (
    build_seed_overlap_graph_from_tables,
    build_seed_overlap_tables,
    first_left_aligned_depths,
)
from psc.perron_field3 import CubicElt
from psc.real_root_sign import count_real_roots, isolate_real_roots, sign_at_isolated_root, tarski_query


def make_sigma(w0: List[Int], w1: List[Int], w2: List[Int]) -> List[List[Int]]:
    var sigma = List[List[Int]]()
    sigma.append(w0.copy())
    sigma.append(w1.copy())
    sigma.append(w2.copy())
    return sigma^


def tau_sigma() -> List[List[Int]]:
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2, 1]
    var a2: List[Int] = [0, 0, 1]
    return make_sigma(a0, a1, a2)


def tribonacci_sigma() -> List[List[Int]]:
    var a0: List[Int] = [0, 1]
    var a1: List[Int] = [0, 2]
    var a2: List[Int] = [0]
    return make_sigma(a0, a1, a2)


def totally_real_sigma() -> List[List[Int]]:
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2]
    var a2: List[Int] = [0, 2, 2]
    return make_sigma(a0, a1, a2)


def test_sturm_tarski_counts_and_signs() raises:
    # x^2 - 2: roots +-sqrt2; count in (-2, 2) is 2, in (0, 2) is 1; sign of x at the positive root is +1
    var p: List[Int] = [-2, 0, 1]
    var P = q_poly(p)
    assert_equal(count_real_roots(P, q_int(-2), q_int(2)), 2)
    assert_equal(count_real_roots(P, q_int(0), q_int(2)), 1)
    var x: List[Int] = [0, 1]
    assert_equal(sign_at_isolated_root(P, q_poly(x), q_int(0), q_int(2)), 1)
    assert_equal(sign_at_isolated_root(P, q_poly(x), q_int(-2), q_int(0)), -1)
    var boxes = isolate_real_roots(P, q_int(-2), q_int(2), 2)
    assert_equal(len(boxes), 2)
    # x^2 - 3 at the positive root of x^2 - 2 is negative
    var y: List[Int] = [-3, 0, 1]
    assert_equal(sign_at_isolated_root(P, q_poly(y), q_int(0), q_int(2)), -1)
    # A rejected coefficient raises before the vendored qpoly arithmetic sees it.
    var bad = q_poly(x)
    bad[0] = q_rejected()
    var raised = False
    try:
        _ = tarski_query(P, bad, q_int(0), q_int(2))
    except:
        raised = True
    assert_true(raised)


def check_bound(sigma: List[List[Int]], expect_complex: Bool, expect_max_m0: Int) raises:
    var tables = build_seed_overlap_tables(sigma)
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var cb = ContractingBound(tables)
    assert_equal(cb.is_complex, expect_complex)
    assert_equal(discriminant(tables.field) < 0, expect_complex)
    assert_true(field_norm(tables.field, CubicElt(0, 1, 0)).eq(q_int(-tables.field.chi0)))
    var left = first_left_aligned_depths(graph)
    var worst = 0
    for i in range(graph.size()):
        var m0 = cb.least_level(graph, graph.states[i].shift)
        assert_true(m0 >= 0)
        assert_true(m0 <= left[i])
        assert_equal(m0 == 0, graph.states[i].shift.is_zero())
        if m0 > worst:
            worst = m0
    assert_equal(worst, expect_max_m0)


def test_bound_pins_exact_values() raises:
    check_bound(tribonacci_sigma(), True, 2)
    check_bound(tau_sigma(), True, 4)
    check_bound(totally_real_sigma(), False, 2)


def test_defining_inequality_not_its_relaxation() raises:
    # Referee counter-calibration: for 0->1, 1->22, 2->102 the Cauchy-Schwarz
    # relaxation of the complex-pair test returns 5 on the reachable scaled
    # offset (-16, -4, 5); the defining inequality first holds at level 6.
    var a0: List[Int] = [1]
    var a1: List[Int] = [2, 2]
    var a2: List[Int] = [1, 0, 2]
    var tables = build_seed_overlap_tables(make_sigma(a0, a1, a2))
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    var t = CubicElt(-16, -4, 5)
    var reachable = False
    for i in range(graph.size()):
        if graph.states[i].shift == t:
            reachable = True
    assert_true(reachable)
    var cb = ContractingBound(tables)
    assert_true(cb.is_complex)
    assert_equal(cb.least_level(graph, t), 6)


def test_capped_graph_is_rejected() raises:
    var tables = build_seed_overlap_tables(tau_sigma())
    var capped = build_seed_overlap_graph_from_tables(tables, 1)
    var cb = ContractingBound(tables)
    var caught = False
    try:
        _ = cb.least_level(capped, CubicElt(1, 0, 0))
    except:
        caught = True
    assert_true(caught)


def reordered_pair() -> List[List[List[Int]]]:
    """`0->1, 1->2, 2->01` and `0->1, 1->2, 2->10`: one cubic, two digit sets.

    Reordering the image of 2 leaves the incidence matrix, and so the
    characteristic cubic, untouched. It does move the prefix positions, and
    with them the single-inflation increments the bound is built from. The
    pair is the counterexample to keying a bound on its cubic alone.
    """
    var first: List[List[Int]] = [[1], [2], [0, 1]]
    var second: List[List[Int]] = [[1], [2], [1, 0]]
    var both = List[List[List[Int]]]()
    both.append(first^)
    both.append(second^)
    return both^


def test_the_cache_answers_as_a_freshly_built_bound_does() raises:
    """Every reachable shift of every specimen, cached against built fresh.

    The cache is a memo over an exact procedure, so the only contract it has
    is identity: the same complexity verdict and the same least level, on
    every shift, as a bound built for that specimen alone.
    """
    var sigmas = List[List[List[Int]]]()
    sigmas.append(tribonacci_sigma())
    sigmas.append(tau_sigma())
    sigmas.append(totally_real_sigma())
    var cache = ContractingBoundCache()
    var compared = 0
    for s in range(len(sigmas)):
        var tables = build_seed_overlap_tables(sigmas[s])
        var graph = build_seed_overlap_graph_from_tables(tables, 20000)
        var fresh = ContractingBound(tables)
        var slot = cache.slot(tables)
        assert_equal(cache.slot(tables), slot)          # a second sighting is the same slot
        assert_equal(cache.is_complex(slot), fresh.is_complex)
        for i in range(graph.size()):
            var t = graph.states[i].shift
            assert_equal(cache.least_level(slot, graph, t), fresh.least_level(graph, t))
            assert_equal(cache.least_level(slot, graph, t), fresh.least_level(graph, t))
            compared += 1
    assert_equal(cache.distinct_bounds(), len(sigmas))
    assert_true(compared > 0)
    assert_true(cache.distinct_levels() <= compared)


def test_the_key_separates_a_shared_cubic_with_different_digits() raises:
    """Two specimens share a cubic and must still not share a bound."""
    var pair = reordered_pair()
    var first = build_seed_overlap_tables(pair[0])
    var second = build_seed_overlap_tables(pair[1])
    assert_equal(first.field.chi0, second.field.chi0)
    assert_equal(first.field.chi1, second.field.chi1)
    assert_equal(first.field.chi2, second.field.chi2)
    assert_true(bound_key(first) != bound_key(second))
    var cache = ContractingBoundCache()
    assert_true(cache.slot(first) != cache.slot(second))
    assert_equal(cache.distinct_bounds(), 2)


def test_a_cached_bound_still_rejects_a_capped_graph() raises:
    """Fail-closed is a property of the answer, so caching may not soften it."""
    var tables = build_seed_overlap_tables(tau_sigma())
    var capped = build_seed_overlap_graph_from_tables(tables, 1)
    var whole = build_seed_overlap_graph_from_tables(tables, 20000)
    var cache = ContractingBoundCache()
    var slot = cache.slot(tables)
    var t = CubicElt(1, 0, 0)
    var caught = False
    try:
        _ = cache.least_level(slot, capped, t)
    except:
        caught = True
    assert_true(caught)
    # And still after the level is cached: a memo hit is not an answer about a
    # partial graph, so the refusal must precede the lookup, not follow it.
    _ = cache.least_level(slot, whole, t)
    var caught_again = False
    try:
        _ = cache.least_level(slot, capped, t)
    except:
        caught_again = True
    assert_true(caught_again)


def main() raises:
    test_sturm_tarski_counts_and_signs()
    print("[PASS] test_sturm_tarski_counts_and_signs")
    test_bound_pins_exact_values()
    print("[PASS] test_bound_pins_exact_values")
    test_defining_inequality_not_its_relaxation()
    print("[PASS] test_defining_inequality_not_its_relaxation")
    test_capped_graph_is_rejected()
    print("[PASS] test_capped_graph_is_rejected")
    test_the_cache_answers_as_a_freshly_built_bound_does()
    print("[PASS] test_the_cache_answers_as_a_freshly_built_bound_does")
    test_the_key_separates_a_shared_cubic_with_different_digits()
    print("[PASS] test_the_key_separates_a_shared_cubic_with_different_digits")
    test_a_cached_bound_still_rejects_a_capped_graph()
    print("[PASS] test_a_cached_bound_still_rejects_a_capped_graph")
    print("7 contracting-bound Mojo tests passed.")
    require_claim("OverlapBadSCCNormalForm")
    require_contract("manuscript Proposition 5.42: the contracting bound is decided by exact Sturm-Tarski counting, and a capped graph is rejected")
