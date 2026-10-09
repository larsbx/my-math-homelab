"""Exact regressions for Proposition LC (psc.leftmost_chain).

docs/p1b-leftmost-chain-periodic-pair-2026-10-05.md. Every terminal cycle of
the leftmost-step function keeps one offset sign and is a prefix-vs-interior
occurrence pair. The pins below cover the three regimes the proposition has to
survive: a unimodular specimen with no cycle at all, the catch-up-free class
where cycles are forced, and the smallest witness, whose offset is checked
against its closed form by hand.
"""

from std.testing import assert_equal, assert_false, assert_true
from mojo_smoke.claims import require_claim, require_contract
from leftmost_chain_census import LeftmostCensus, require_complete_census
from psc.leftmost_chain import (
    certify_leftmost_cycles,
    leftmost_step,
    terminal_leftmost_cycles,
)
from psc.one_tile import catch_up_free, one_tile
from psc.overlap_seed_patch import OverlapState, build_seed_overlap_tables, cached_sign
from psc.periodic_pair import centre_offset
from psc.perron_field3 import CubicElt
from psc.vertex_coincidence import build_box_graph


def sigma_of(a: List[Int], b: List[Int], c: List[Int]) -> List[List[Int]]:
    var sigma = List[List[Int]]()
    sigma.append(a.copy())
    sigma.append(b.copy())
    sigma.append(c.copy())
    return sigma^


def test_tribonacci_has_no_terminal_cycle() raises:
    """A unimodular specimen: Lemma P is void, every nonzero-offset vertex
    reaches a catch-up, so the proposition is vacuous and must say so rather
    than inventing a cycle."""
    var sigma = sigma_of([0, 1], [0, 2], [0])
    assert_false(catch_up_free(sigma))
    var tables = build_seed_overlap_tables(sigma)
    var a = build_box_graph(tables)
    var v = certify_leftmost_cycles(tables, a)
    assert_equal(v.cycles, 0)
    assert_equal(v.max_r, 0)
    assert_true(v.holds())
    # Every recurrent vertex is in CU, which is the same statement from the
    # other side (psc.one_tile).
    var q = one_tile(sigma)
    assert_equal(q.in_cu, q.recurrent)


def test_smallest_witness_is_a_prefix_vs_interior_pair() raises:
    """`0 -> 1, 1 -> 12, 2 -> 022` has two cycles of length one.

    By hand: the first-letter map is `0 -> 1, 1 -> 1, 2 -> 0`, so `1` is its
    fixed point and `sigma(1) = 1 . 2` is a prefix occurrence with a nonempty
    tail. `sigma(2) = 0 . 2 . 2` is an interior occurrence of `2` at index 1
    with `Q = "0"` and `V = "2"`. The incidence matrix has characteristic
    polynomial `x^3 - 3x^2 + 2x - 1`, `det(I - M) = -1`, and the cycle equation
    `(I - M) w0 = ab(Q) = e_0` gives `w0 = (0, 1, -1)` exactly, so the offset
    is `ell_1 - ell_2`, which is negative."""
    var sigma = sigma_of([1], [1, 2], [0, 2, 2])
    assert_false(catch_up_free(sigma))
    var tables = build_seed_overlap_tables(sigma)
    var a = build_box_graph(tables)
    var v = certify_leftmost_cycles(tables, a)
    assert_true(v.holds())
    assert_equal(v.cycles, 2)
    assert_equal(v.sign_constant, 2)
    assert_equal(v.prefix_vs_interior, 2)
    assert_equal(v.offsets_certified, 2)
    assert_equal(v.offsets_beyond_range, 0)
    assert_equal(v.offset_failures, 0)
    assert_equal(v.max_r, 1)

    var cycles = terminal_leftmost_cycles(tables, a)
    assert_equal(len(cycles), 2)
    var signs = 0
    for k in range(len(cycles)):
        assert_equal(cycles[k].r, 1)
        assert_true(cycles[k].is_prefix_vs_interior())
        # the prefix side is letter 1 at index 0 of sigma(1) = "12"
        assert_equal(cycles[k].prefix_letter, 1)
        assert_equal(cycles[k].prefix_index, 0)
        assert_equal(cycles[k].prefix_length, 2)
        # the interior side is letter 2 at index 1 of sigma(2) = "022"
        assert_equal(cycles[k].interior_letter, 2)
        assert_equal(cycles[k].interior_index, 1)
        assert_equal(cycles[k].interior_length, 3)
        # ab(Q) = e_0, and (I - M) w0 = ab(Q) with w0 = (0, 1, -1)
        assert_equal(cycles[k].interior_parikh, List[Int]([1, 0, 0]))
        assert_equal(len(cycles[k].offset), 3)
        signs += cycles[k].sign
    # the two cycles are each other's mirror image, so the signs cancel
    assert_equal(signs, 0)

    # The closed form, independently of the graph walk.
    var zero: List[Int] = [0, 0, 0]
    var q: List[Int] = [1, 0, 0]
    assert_equal(centre_offset(sigma, 1, zero, q), List[Int]([0, 1, -1]))


def test_the_catch_up_free_class_is_forced_to_have_cycles() raises:
    """Lemma P puts no vertex of a catch-up-free specimen in CU, so every
    nonzero-offset vertex must run into a terminal cycle. Both pinned
    catch-up-free specimens have two, of length 6 and 15."""
    var short = sigma_of([1], [0, 1, 2], [0, 1, 0])
    assert_true(catch_up_free(short))
    var ts = build_seed_overlap_tables(short)
    var vs = certify_leftmost_cycles(ts, build_box_graph(ts))
    assert_true(vs.holds())
    assert_equal(vs.cycles, 2)
    assert_equal(vs.prefix_vs_interior, 2)
    assert_equal(vs.offsets_certified, 2)
    assert_equal(vs.max_r, 6)

    var long = sigma_of([1], [2, 2], [0, 1, 2])
    assert_true(catch_up_free(long))
    var tl = build_seed_overlap_tables(long)
    var vl = certify_leftmost_cycles(tl, build_box_graph(tl))
    assert_true(vl.holds())
    assert_equal(vl.cycles, 2)
    assert_equal(vl.prefix_vs_interior, 2)
    assert_equal(vl.max_r, 15)
    # r = 15 is past the exact integer range for M^r, so the offsets are
    # reported as uncomputed rather than assumed, and the shape certificate
    # still stands on its own.
    assert_equal(vl.offsets_certified, 0)
    assert_equal(vl.offsets_beyond_range, 2)
    assert_equal(vl.offset_failures, 0)


def test_an_uncomputed_offset_is_never_a_pass() raises:
    """Dropping the integral range to zero must move every offset into the
    `beyond` column and leave `holds()` resting on the shape alone -- never on
    an offset that was not computed."""
    var sigma = sigma_of([1], [1, 2], [0, 2, 2])
    var tables = build_seed_overlap_tables(sigma)
    var a = build_box_graph(tables)
    var v = certify_leftmost_cycles(tables, a, 0)
    assert_equal(v.offsets_certified, 0)
    assert_equal(v.offsets_beyond_range, 2)
    assert_equal(v.offset_failures, 0)
    assert_true(v.holds())


def test_the_leftmost_step_keeps_its_sign_and_zeroes_one_index() raises:
    """Lemma S, per step, on every nonzero-offset vertex of two box graphs:
    the child's offset keeps the parent's sign or is zero, and the index on the
    side whose tile starts later is 0."""
    var specimens = List[List[List[Int]]]()
    specimens.append(sigma_of([0, 1], [0, 2], [0]))
    specimens.append(sigma_of([1], [1, 2], [0, 2, 2]))
    specimens.append(sigma_of([1], [0, 1, 2], [0, 1, 0]))
    var steps = 0
    for s in range(len(specimens)):
        var tables = build_seed_overlap_tables(specimens[s])
        var a = build_box_graph(tables)
        var cache = Dict[CubicElt, Int]()
        for i in range(a.size()):
            if a.states[i].shift.is_zero():
                continue
            var sign = cached_sign(tables, cache, a.states[i].shift)
            var step = leftmost_step(tables, cache, a.states[i])
            var child_sign = cached_sign(tables, cache, step.child.shift)
            assert_true(child_sign == 0 or child_sign == sign)
            if sign < 0:
                assert_equal(step.top_index, 0)
            else:
                assert_equal(step.bottom_index, 0)
            steps += 1
    assert_true(steps > 1000)


def test_a_capped_graph_is_not_a_verdict() raises:
    """A box graph that hit its cap reports as capped, and `holds()` is false
    however the cycle columns came out."""
    var sigma = sigma_of([1], [1, 2], [0, 2, 2])
    var tables = build_seed_overlap_tables(sigma)
    var capped = build_box_graph(tables, 4)
    assert_true(capped.capped)
    var v = certify_leftmost_cycles(tables, capped)
    assert_true(v.capped)
    assert_false(v.holds())
    assert_equal(v.cycles, 0)


def test_the_census_completion_gate_refuses_incomplete_or_failed_results() raises:
    var complete = LeftmostCensus()
    complete.specimens = 1
    complete.cycles = 2
    complete.sign_constant = 2
    complete.prefix_vs_interior = 2
    # A deliberately uncomputed offset is separate from a failed replay.
    complete.offsets_beyond_range = 2
    require_complete_census(complete)
    for failure_case in range(4):
        var bad = complete.copy()
        if failure_case == 0:
            bad.capped = 1
        elif failure_case == 1:
            bad.sign_constant = 1
        elif failure_case == 2:
            bad.prefix_vs_interior = 1
        else:
            bad.offset_failures = 1
        var refused = False
        try:
            require_complete_census(bad)
        except:
            refused = True
        assert_true(refused)


def main() raises:
    test_tribonacci_has_no_terminal_cycle()
    print("[PASS] test_tribonacci_has_no_terminal_cycle")
    test_smallest_witness_is_a_prefix_vs_interior_pair()
    print("[PASS] test_smallest_witness_is_a_prefix_vs_interior_pair")
    test_the_catch_up_free_class_is_forced_to_have_cycles()
    print("[PASS] test_the_catch_up_free_class_is_forced_to_have_cycles")
    test_an_uncomputed_offset_is_never_a_pass()
    print("[PASS] test_an_uncomputed_offset_is_never_a_pass")
    test_the_leftmost_step_keeps_its_sign_and_zeroes_one_index()
    print("[PASS] test_the_leftmost_step_keeps_its_sign_and_zeroes_one_index")
    test_a_capped_graph_is_not_a_verdict()
    print("[PASS] test_a_capped_graph_is_not_a_verdict")
    test_the_census_completion_gate_refuses_incomplete_or_failed_results()
    print("[PASS] test_the_census_completion_gate_refuses_incomplete_or_failed_results")
    require_contract("leftmost-chain census completion: a capped graph, inconsistent sign/shape counts, or failed integral replay raises; offsets beyond the replay range remain explicitly uncomputed")
    require_claim("LeftmostChainCycleStructure")
    require_claim("LeftmostChainG1Certificate")
    require_contract("Proposition LC (leftmost-chain periodic pairs): the leftmost step keeps the parent's offset sign or lands on zero and zeroes the index on the side whose tile starts later (Lemma S, checked per step on three box graphs); every terminal leftmost cycle is a prefix-vs-interior occurrence pair. Pins: Tribonacci 01/02/0 has 0 cycles and in_cu = recurrent; 1/12/022 has 2 cycles of length 1, prefix letter 1 at 0 of sigma(1) (length 2), interior letter 2 at 1 of sigma(2) (length 3), ab(Q) = e_0, and (I - M) w0 = ab(Q) with w0 = (0, 1, -1) re-derived from the closed form; catch-up-free 1/012/010 has 2 cycles with r = 6 and both offsets certified over Z, 1/22/012 has 2 cycles with r = 15 whose offsets are past the exact integer range and are reported as uncomputed, never as a pass; max_integral_r = 0 moves every offset to the beyond column; a capped box graph is capped and holds() is false")
