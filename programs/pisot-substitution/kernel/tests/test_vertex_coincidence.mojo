"""Exact regressions for the box-graph decision of PeriodicPairVertexCoincidence
(Proposition V of docs/p1b-vertex-coincidence-box-2026-10-02.md), and of formal
productivity on the same automaton (Theorem Omega of
docs/pds-certificate-from-the-box-automaton-2026-10-07.md)."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_claim, require_contract
from psc.corpus import Specimen, image_words_up_to, pip_corpus, screened_triples
from psc.overlap_obstruction import recurrent_sccs
from psc.overlap_seed_patch import build_seed_overlap_graph_from_tables, build_seed_overlap_tables
from psc.periodic_pair import centre_offset, interior_occurrences
from psc.vertex_coincidence import box_radii, build_box_graph, decide_vertex_coincidence, decide_vertex_coincidence_from


def sigma_of(a: List[Int], b: List[Int], c: List[Int]) -> List[List[Int]]:
    var sigma = List[List[Int]]()
    sigma.append(a.copy())
    sigma.append(b.copy())
    sigma.append(c.copy())
    return sigma^


def tribonacci() -> List[List[Int]]:
    return sigma_of([0, 1], [0, 2], [0])


def cube_image() -> List[List[Int]]:
    return sigma_of([1], [2, 2, 2], [0, 2, 2, 2])


def golden_pump() -> List[List[Int]]:
    return sigma_of([1], [0, 2, 1], [0, 0, 1])


def plastic() -> List[List[Int]]:
    return sigma_of([1], [2], [1, 0])


def assert_holds(
    sigma: List[List[Int]], recurrent: Int, deepest: Int, coincidence_depth: Int, aligned_depth: Int
) raises:
    var v = decide_vertex_coincidence(sigma)
    assert_equal(v.capped, False)
    assert_equal(v.holds, True)
    assert_equal(v.recurrent, recurrent)
    assert_equal(v.deepest, deepest)
    assert_equal(v.productive, True)
    assert_equal(v.coincidence_depth, coincidence_depth)
    assert_equal(v.aligned_depth, aligned_depth)


def test_named_specimens_hold_for_every_r() raises:
    """Recurrent counts and depths agree with an independent floating-point
    oracle that uses different bounds and a different start set (the recurrent
    part does not depend on the start superset)."""
    assert_holds(tribonacci(), 14, 3, 8, 1)
    assert_holds(cube_image(), 1166, 17, 51, 7)
    assert_holds(golden_pump(), 716, 15, 39, 6)
    assert_holds(plastic(), 74, 14, 33, 15)


def test_the_box_holds_every_aligned_pair() raises:
    """Theorem Omega reads S(sigma) off the box: the six aligned pairs
    (i, j, 0), i != j, are box vertices (w = 0 obeys every radius)."""
    var box = build_box_graph(build_seed_overlap_tables(cube_image()))
    var aligned = 0
    for i in range(box.size()):
        if box.states[i].shift.is_zero() and not box.states[i].is_coincidence():
            aligned += 1
    assert_equal(aligned, 6)


def assert_seed_graph_misses(sigma: List[List[Int]], missing: Int) raises:
    var tables = build_seed_overlap_tables(sigma)
    var seed = build_seed_overlap_graph_from_tables(tables, 200000)
    assert_equal(seed.capped, False)
    var box = build_box_graph(tables)
    var members = Dict[String, Bool]()
    for i in range(seed.size()):
        members[String(seed.states[i])] = True
    var comps = recurrent_sccs(box)
    var out = 0
    for c in range(len(comps)):
        for k in range(len(comps[c])):
            if String(box.states[comps[c][k]]) not in members:
                out += 1
    assert_equal(out, missing)


def test_the_seed_graph_is_not_a_formal_certificate() raises:
    """Counter-calibration: the swap-seed graph misses box cycle vertices
    (unrealized carriers), so seed productivity alone does not give formal
    productivity, and the literature route of Theorem Omega needs the box."""
    assert_seed_graph_misses(tribonacci(), 0)
    assert_seed_graph_misses(cube_image(), 38)
    assert_seed_graph_misses(golden_pump(), 100)
    assert_seed_graph_misses(plastic(), 16)


def test_every_integral_centre_offset_lies_in_the_box() raises:
    """Step 1 of Proposition V against Theorem B: every integral centre offset of
    an interior-occurrence pair has |w_m| <= R_m."""
    var specimens = List[List[List[Int]]]()
    specimens.append(tribonacci())
    specimens.append(golden_pump())
    var depths: List[Int] = [6, 4]
    var checked = 0
    for s in range(len(specimens)):
        var sigma = specimens[s].copy()
        var radii = box_radii(build_seed_overlap_tables(sigma))
        for r in range(1, depths[s] + 1):
            for i in range(3):
                var top = interior_occurrences(sigma, i, r)
                for j in range(3):
                    var bottom = interior_occurrences(sigma, j, r)
                    for p in range(len(top)):
                        for q in range(len(bottom)):
                            var w = centre_offset(sigma, r, top[p].prefix, bottom[q].prefix)
                            if len(w) != 3:
                                continue
                            checked += 1
                            for m in range(3):
                                assert_true(w[m] <= radii[m] and -w[m] <= radii[m])
    assert_true(checked > 0)


def test_seed_graph_cycles_lie_in_the_box_graph() raises:
    """Every vertex on a cycle of the seed-patch graph is a vertex of the box graph."""
    var tables = build_seed_overlap_tables(cube_image())
    var seed = build_seed_overlap_graph_from_tables(tables, 20000)
    assert_equal(seed.capped, False)
    var box = build_box_graph(tables)
    assert_equal(box.capped, False)
    var members = Dict[String, Bool]()
    for i in range(box.size()):
        members[String(box.states[i])] = True
    var comps = recurrent_sccs(seed)
    var recurrent = 0
    for c in range(len(comps)):
        for k in range(len(comps[c])):
            recurrent += 1
            assert_true(String(seed.states[comps[c][k]]) in members)
    assert_true(recurrent > 0)


def assert_slice(
    corpus: List[Specimen], n: Int, recurrent: Int, deepest: Int, states: Int, coincidence_depth: Int
) raises:
    var rec = 0
    var deep = -1
    var total = 0
    var coin = -1
    for s in range(n):
        var v = decide_vertex_coincidence(corpus[s].sigma)
        assert_equal(v.capped, False)
        assert_equal(v.holds, True)
        assert_equal(v.productive, True)
        rec += v.recurrent
        total += v.states
        deep = max(deep, v.deepest)
        coin = max(coin, v.coincidence_depth)
    assert_equal(rec, recurrent)
    assert_equal(deep, deepest)
    assert_equal(total, states)
    assert_equal(coin, coincidence_depth)


def test_census_slices_are_pinned() raises:
    """The census kernel, without the parallel fold, on the first 300 standing
    specimens and the first 100 specimens with images of length <= 4: every
    one holds for every r; recurrent totals, deepest K_V and box-graph sizes
    are pinned (the full standing census is pinned in CI)."""
    assert_slice(pip_corpus(), 300, 59372, 17, 5221392, 51)
    assert_slice(screened_triples(image_words_up_to(4), 12), 100, 14180, 15, 1116030, 38)


def test_a_capped_box_graph_is_never_a_verdict() raises:
    var v = decide_vertex_coincidence_from(build_seed_overlap_tables(golden_pump()), 10)
    assert_equal(v.capped, True)
    assert_equal(v.holds, False)
    assert_equal(v.productive, False)


def main() raises:
    test_named_specimens_hold_for_every_r()
    print("[PASS] test_named_specimens_hold_for_every_r")
    test_the_box_holds_every_aligned_pair()
    print("[PASS] test_the_box_holds_every_aligned_pair")
    test_the_seed_graph_is_not_a_formal_certificate()
    print("[PASS] test_the_seed_graph_is_not_a_formal_certificate")
    test_every_integral_centre_offset_lies_in_the_box()
    print("[PASS] test_every_integral_centre_offset_lies_in_the_box")
    test_seed_graph_cycles_lie_in_the_box_graph()
    print("[PASS] test_seed_graph_cycles_lie_in_the_box_graph")
    test_a_capped_box_graph_is_never_a_verdict()
    print("[PASS] test_a_capped_box_graph_is_never_a_verdict")
    test_census_slices_are_pinned()
    print("[PASS] test_census_slices_are_pinned")
    require_claim("BoxCycleContainment")
    require_claim("BoxAutomatonPDSCertificate")
    require_contract("box-graph vertex coincidence (Proposition V): tribonacci 14/3, cube 1166/17, golden pump 716/15 hold for every r; every integral centre offset and every seed-graph cycle vertex lies in the box; a capped box graph is not a verdict; census slices pinned: first 300 standing specimens 59372 recurrent, K_V 17, 5221392 states; first 100 images-of-length-4 specimens 14180 recurrent, K_V 15, 1116030 states")
    require_contract("box-automaton formal productivity (Theorem Omega): every box vertex reaches a coincidence on tribonacci D 8 S 1, cube D 51 S 7, golden pump D 39 S 6, plastic D 33 S 15; the box holds the six aligned pairs; the seed graph misses 0/38/100/16 box cycle vertices; census slices productive with box D 51 and 38; a capped box graph is not productive")
    require_claim("BoxAutomatonCertificate")
    require_claim("BoundedPureDiscreteSpectrum")
