"""Exact hit certificates: all-path decisions, birth replay and negative closures."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_contract
from psc.hit_witness import analyze_hits, hit_kind, occurrences, replay_births, simultaneous_closure, vertex_label, witness_path
from psc.one_tile import one_tile_from, two_sided
from psc.overlap_seed_patch import OverlapState, SeedOverlapTables, build_seed_overlap_tables
from psc.perron_field3 import CubicElt, cubic_add_checked, cubic_mul_beta
from psc.vertex_coincidence import build_box_graph


def sigma_of(a: List[Int], b: List[Int], c: List[Int]) -> List[List[Int]]:
    return [a.copy(), b.copy(), c.copy()]


def _scale(tables: SeedOverlapTables, x: CubicElt, n: Int) raises -> CubicElt:
    var y = x
    for _ in range(n):
        y = cubic_mul_beta(tables.field, y)
    return y


def _boundary_births(tables: SeedOverlapTables, letter: Int, start: CubicElt, n: Int) raises -> Dict[CubicElt, Int]:
    """Independent finite-word oracle: boundary sets at all levels, rescaled
    to the same level n. No overlap graph, child indices or hit predicates."""
    var out = Dict[CubicElt, Int]()
    var word: List[Int] = [letter]
    for m in range(n + 1):
        var cursor = CubicElt()
        for j in range(len(word) + 1):
            var point = cubic_add_checked(start, _scale(tables, cursor, n - m))
            if point not in out:
                out[point] = m
            if j < len(word):
                cursor = cubic_add_checked(cursor, tables.lengths.at(word[j]))
        var longer = List[Int]()
        for c in word:
            for d in tables.sigma[c]:
                longer.append(d)
        word = longer^
    return out^


def _word_catch_up(tables: SeedOverlapTables, st: OverlapState, n: Int) raises -> Bool:
    var top = _boundary_births(tables, st.top, CubicElt(), n)
    var bottom = _boundary_births(tables, st.bottom, _scale(tables, st.shift, n), n)
    for item in top.items():
        if item.key in bottom and item.value != bottom[item.key]:
            return True
    return False


def check_specimen(sigma: List[List[Int]], expected_recurrent: Int, expected_either: Int) raises:
    var tables = build_seed_overlap_tables(sigma)
    var a = build_box_graph(tables)
    var h = analyze_hits(tables, a)
    var legacy = one_tile_from(tables, a)
    var mirrored = two_sided(sigma)
    var left = 0
    var right = 0
    var either = 0
    for k in range(len(h.recurrent)):
        var v = h.recurrent[k]
        left += Int(h.left[v] > 0)
        right += Int(h.right[v] > 0)
        either += Int(h.left[v] > 0 or h.right[v] > 0)
        if k < 16:
            for n in range(1, 5):
                var predicted = (h.left[v] > 0 and h.left[v] <= n) or (h.right[v] > 0 and h.right[v] <= n)
                assert_equal(predicted, _word_catch_up(tables, a.states[v], n))
            if h.left[v] > 0:
                var p = witness_path(tables, a, v, h.left, False, True)
                assert_equal(len(p), h.left[v])
                var b = replay_births(tables, a.states[v], p, False)
                assert_true(b[0] != b[1])
            if h.right[v] > 0:
                var p = witness_path(tables, a, v, h.right, True, True)
                assert_equal(len(p), h.right[v])
                var b = replay_births(tables, a.states[v], p, True)
                assert_true(b[0] != b[1])
    assert_equal(len(h.recurrent), expected_recurrent)
    assert_equal(either, expected_either)
    assert_equal(left, legacy.reach_cu)
    assert_equal(left, mirrored.reach_left)
    assert_equal(right, mirrored.reach_right)
    assert_equal(either, mirrored.reach_either)


def test_direct_endpoints_and_word_oracle() raises:
    check_specimen(sigma_of([0, 1], [0, 2], [0]), 14, 14)
    check_specimen(sigma_of([1], [2], [0, 1]), 68, 68)
    check_specimen(sigma_of([1], [0, 2, 1], [0, 0, 1]), 714, 714)
    check_specimen(sigma_of([1], [1, 2], [0, 2, 2]), 14, 12)
    check_specimen(sigma_of([1], [0, 1, 2], [0, 1, 0]), 694, 0)


def check_hit_control(sigma: List[List[Int]], source: OverlapState, first: Int, catch_depth: Int) raises:
    var tables = build_seed_overlap_tables(sigma)
    var a = build_box_graph(tables)
    var h = analyze_hits(tables, a)
    var found = False
    for v in h.recurrent:
        if a.states[v] != source:
            continue
        found = True
        assert_equal(h.new_left[v], first)
        assert_equal(h.left[v], catch_depth)
        assert_equal(h.new_right[v], first)
        assert_equal(h.right[v], catch_depth)
        var p = witness_path(tables, a, v, h.new_left, False, False)
        var b = replay_births(tables, a.states[v], p, False)
        assert_equal(b[0], first)
        assert_equal(b[1], first)  # the selected first path is simultaneous
        var q = witness_path(tables, a, v, h.left, False, True)
        var c = replay_births(tables, a.states[v], q, False)
        assert_equal(len(q), catch_depth)
        assert_true(c[0] != c[1])
        assert_equal(vertex_label(a.states[v]), vertex_label(source))
    assert_true(found)


def test_alternative_and_later_hits() raises:
    # 1/2/022, vertex (2,2,-1): two different shortest paths, both depth 2.
    check_hit_control(sigma_of([1], [2], [0, 2, 2]), OverlapState(2, 2, CubicElt(-1)), 2, 2)
    # 1/2/012, vertex (1,2,-1): first hit at 2, catch-up only later, at 3,
    # for BOTH endpoints. This cannot be rescued by an earlier opposite-end hit.
    check_hit_control(sigma_of([1], [2], [0, 1, 2]), OverlapState(1, 2, CubicElt(-1)), 2, 3)


def test_simultaneous_only_and_tampering() raises:
    var tables = build_seed_overlap_tables(sigma_of([1], [1, 2], [0, 2, 2]))
    var a = build_box_graph(tables)
    var h = analyze_hits(tables, a)
    var negative = 0
    for v in h.recurrent:
        if h.left[v] >= 0 or h.right[v] >= 0:
            continue
        negative += 1
        var closure = simultaneous_closure(tables, a, v)
        print("NEGATIVE", vertex_label(a.states[v]), "closure", len(closure))
        var p = witness_path(tables, a, v, h.new_left, False, False)
        var b = replay_births(tables, a.states[v], p, False)
        assert_equal(b[0], b[1])
        assert_equal(len(p), 1)
        var broken = a.copy()
        broken.adj[v] = List[Int]()
        var refused = False
        try:
            _ = simultaneous_closure(tables, broken, v)
        except:
            refused = True
        assert_true(refused)
        p[0].child.shift = cubic_add_checked(p[0].child.shift, CubicElt(1))
        refused = False
        try:
            _ = replay_births(tables, a.states[v], p, False)
        except:
            refused = True
        assert_true(refused)
    assert_equal(negative, 2)
    var capped = build_box_graph(tables, 1)
    assert_true(capped.capped)
    var refused = False
    try:
        _ = analyze_hits(tables, capped)
    except:
        refused = True
    assert_true(refused)


def test_inherited_boundaries_and_identical_tiles() raises:
    var tables = build_seed_overlap_tables(sigma_of([0, 1], [0, 2], [0]))
    var cache = Dict[CubicElt, Int]()
    var st = OverlapState(0, 1, CubicElt())
    var es = occurrences(tables, st, cache)
    assert_equal(es[0].top_index, 0)
    assert_equal(es[0].bottom_index, 0)
    assert_equal(hit_kind(tables, st, es[0], False), 1)
    # Absorbing coincidences can have new simultaneous boundaries, but can
    # never have a catch-up at either endpoint, at any subsequent depth.
    for letter in range(3):
        var coin = OverlapState(letter, letter, CubicElt())
        for e in occurrences(tables, coin, cache):
            assert_true(e.child.is_coincidence())
            assert_true(hit_kind(tables, coin, e, False) != 3)
            assert_true(hit_kind(tables, coin, e, True) != 3)


def main() raises:
    test_direct_endpoints_and_word_oracle()
    print("[PASS] direct endpoints agree with CU/mirror and independent finite-word births")
    test_alternative_and_later_hits()
    print("[PASS] alternative shortest and later catch-up witnesses survive a simultaneous first path")
    test_simultaneous_only_and_tampering()
    print("[PASS] simultaneous-only closures, tamper rejection and cap refusal")
    test_inherited_boundaries_and_identical_tiles()
    print("[PASS] inherited endpoints are not new; identical tiles cannot catch up")
    require_contract("finite-box all-path hit witnesses: direct left/right catch-up agrees with CU/mirror; finite-word boundary birth oracle at depths 1..4; alternative shortest and later witnesses; stable power-basis labels; simultaneous-only child-complete closures; malformed occurrence, missing edge and capped graph refused")
