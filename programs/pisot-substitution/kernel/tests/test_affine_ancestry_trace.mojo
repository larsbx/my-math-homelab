"""Exact regressions for order-sensitive affine renewal ancestry."""

from std.testing import assert_equal, assert_false, assert_true
from psc.affine_ancestry_trace import affine_ancestry_trace, affine_ancestry_trace_with_tables, build_affine_trace_tables, common_terminal_trace_length, first_proper_repeated_affine_state, first_repeated_affine_state, is_affine_pump_extension, proper_affine_splice_matches_certified_address, same_affine_state
from mojo_smoke.claims import require_claim
from psc.joint_local_type import same_joint_local_type
from psc.loop_quotient_census import addressed_samples_through_depth
from psc.renewal import Diff3
from psc.renewal_address import RelativeRenewalAddress, build_renewal_address_tables, build_renewal_pair_census_state, renewal_cut_address_from_state
from psc.words import Pair


def sigma() -> List[List[Int]]:
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2, 1]
    var a2: List[Int] = [0, 0, 1]
    var out = List[List[Int]]()
    out.append(a0^)
    out.append(a1^)
    out.append(a2^)
    return out^


def seed_pair() -> Pair:
    var u: List[Int] = [0, 1]
    var v: List[Int] = [1, 0]
    return Pair(u, v)


def test_every_canonical_trace_closes() raises:
    var substitution = sigma()
    var samples = addressed_samples_through_depth(substitution, seed_pair(), 0, 7, 2, 1)
    var tables = build_affine_trace_tables(substitution)
    assert_equal(len(samples), 601)
    for i in range(len(samples)):
        var trace = affine_ancestry_trace_with_tables(tables, samples[i].address)
        assert_equal(trace.depth(), samples[i].depth)
        assert_true(trace.closes())


def test_exact_sidewise_survivor_has_order_sensitive_trace() raises:
    var substitution = sigma()
    var samples = addressed_samples_through_depth(substitution, seed_pair(), 0, 7, 2, 1)
    var tables = build_affine_trace_tables(substitution)
    var left = -1
    var right = -1
    for i in range(len(samples)):
        if samples[i].depth == 7 and samples[i].cut == 14:
            left = i
        elif samples[i].depth == 5 and samples[i].cut == 14:
            right = i
    assert_true(left >= 0)
    assert_true(right >= 0)
    assert_true(same_joint_local_type(samples[left].projection, samples[right].projection))
    var longer = affine_ancestry_trace_with_tables(tables, samples[left].address)
    var shorter = affine_ancestry_trace_with_tables(tables, samples[right].address)
    assert_equal(longer.depth(), 7)
    assert_equal(shorter.depth(), 5)
    # The prior abelian collision also shares its source affine state; only the
    # ordered intermediate trace can distinguish or expose a pump relation.
    assert_true(same_affine_state(longer, 0, shorter, 0))
    var terminal = common_terminal_trace_length(longer, shorter)
    assert_equal(terminal, 6)
    var repeated = first_repeated_affine_state(longer)
    assert_equal(repeated[0], 0)
    assert_equal(repeated[1], 2)
    assert_true(is_affine_pump_extension(longer, shorter))
    var proper = first_proper_repeated_affine_state(longer)
    assert_equal(proper[0], 1)
    assert_equal(proper[1], 3)
    assert_true(
        proper_affine_splice_matches_certified_address(
            tables,
            samples[left].address,
            samples[right].address,
            proper[0],
            proper[1],
        )
    )


def test_right_edge_affine_loops_splice_to_certified_addresses() raises:
    var substitution = sigma()
    var pair = seed_pair()
    var short_tables = build_renewal_address_tables(substitution, 3)
    var long_tables = build_renewal_address_tables(substitution, 4)
    var short_state = build_renewal_pair_census_state(short_tables, pair)
    var long_state = build_renewal_pair_census_state(long_tables, pair)
    var affine_tables = build_affine_trace_tables(substitution)
    for j in range(3):
        var short_cut = short_state.inflated_length - 3 + j
        var long_cut = long_state.inflated_length - 3 + j
        var short_address = renewal_cut_address_from_state(short_state, short_cut)
        var long_address = renewal_cut_address_from_state(long_state, long_cut)
        var trace = affine_ancestry_trace_with_tables(affine_tables, long_address)
        var proper = first_proper_repeated_affine_state(trace)
        assert_equal(proper[0], 1)
        assert_equal(proper[1], 2)
        assert_true(
            proper_affine_splice_matches_certified_address(
                affine_tables, long_address, short_address, proper[0], proper[1]
            )
        )


def test_nonrepeat_splice_fails_closed() raises:
    var substitution = sigma()
    var samples = addressed_samples_through_depth(substitution, seed_pair(), 0, 5, 2, 1)
    var index = -1
    for i in range(len(samples)):
        if samples[i].depth == 5 and samples[i].cut == 14:
            index = i
    assert_true(index >= 0)
    var tables = build_affine_trace_tables(substitution)
    var trace = affine_ancestry_trace_with_tables(tables, samples[index].address)
    var proper = first_proper_repeated_affine_state(trace)
    assert_equal(proper[0], -1)
    assert_equal(proper[1], -1)
    assert_false(
        proper_affine_splice_matches_certified_address(
            tables, samples[index].address, samples[index].address, 1, 2
        )
    )


def test_stale_stored_certificate_fails_closed() raises:
    var substitution = sigma()
    var samples = addressed_samples_through_depth(substitution, seed_pair(), 0, 2, 2, 1)
    var stale_correction = Diff3(
        samples[0].address.correction.x + 1,
        samples[0].address.correction.y,
        samples[0].address.correction.z,
    )
    var stale = RelativeRenewalAddress(
        samples[0].address.level,
        samples[0].address.source_index_delta,
        samples[0].address.source_defect,
        samples[0].address.top_source_letter,
        samples[0].address.bottom_source_letter,
        samples[0].address.top_digits,
        samples[0].address.bottom_digits,
        samples[0].address.scaled_defect,
        stale_correction,
    )
    var caught = False
    try:
        _ = affine_ancestry_trace(substitution, stale)
    except:
        caught = True
    assert_true(caught)


def main() raises:
    test_every_canonical_trace_closes()
    print("[PASS] test_every_canonical_trace_closes")
    test_exact_sidewise_survivor_has_order_sensitive_trace()
    print("[PASS] test_exact_sidewise_survivor_has_order_sensitive_trace")
    test_stale_stored_certificate_fails_closed()
    print("[PASS] test_stale_stored_certificate_fails_closed")
    test_right_edge_affine_loops_splice_to_certified_addresses()
    print("[PASS] test_right_edge_affine_loops_splice_to_certified_addresses")
    test_nonrepeat_splice_fails_closed()
    print("[PASS] test_nonrepeat_splice_fails_closed")
    print("5 affine-ancestry-trace Mojo tests passed.")
    require_claim("G1b2RenewalFiniteness")
