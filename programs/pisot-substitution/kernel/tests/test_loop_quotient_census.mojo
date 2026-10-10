"""Exact finite regressions for the G1b-2 observed loop quotient."""

from std.testing import assert_equal, assert_false, assert_true
from mojo_smoke.claims import require_claim
from psc.loop_quotient_census import (
    AddressedJointLocalSample,
    addressed_samples_through_depth,
    append_addressed_samples_at_depth,
    audit_projection_modulo_loop,
    audit_projection_modulo_synchronous_extensions,
    audit_synchronous_residual_scaled_defect_residue,
    synchronous_any_digit_pair_insertion,
)
from psc.words import Pair


def nonunimodular_pisot_sigma() -> List[List[Int]]:
    # 0 -> 1, 1 -> 021, 2 -> 001; det(M)=2.
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2, 1]
    var a2: List[Int] = [0, 0, 1]
    var sigma = List[List[Int]]()
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def seed_pair() -> Pair:
    var u: List[Int] = [0, 1]
    var v: List[Int] = [1, 0]
    return Pair(u, v)


def test_known_loop_quotient_removes_staircase_collisions() raises:
    # PR #52 pinned exactly three collisions at window D-2 for each depth cap
    # D=3..7. Their full addresses form the known synchronous (1,2) recurrence.
    var depth_caps: List[Int] = [3, 4, 5, 6, 7]
    var sample_counts: List[Int] = [16, 43, 107, 255, 601]

    for q in range(len(depth_caps)):
        var max_depth = depth_caps[q]
        var samples = addressed_samples_through_depth(
            nonunimodular_pisot_sigma(),
            seed_pair(),
            0,
            max_depth,
            2,
            max_depth - 2,
        )
        var audit = audit_projection_modulo_loop(samples, 1, 2)
        assert_equal(audit.sample_count, sample_counts[q])
        assert_equal(audit.projection_collision_pair_count, 3)
        assert_equal(audit.direct_extension_edge_count, 3)
        assert_equal(audit.quotiented_collision_pair_count, 3)
        assert_equal(audit.residual_collision_pair_count, 0)
        assert_false(audit.has_residual_collision())


def test_wrong_loop_label_preserves_known_residuals() raises:
    var samples = addressed_samples_through_depth(
        nonunimodular_pisot_sigma(), seed_pair(), 0, 3, 2, 1
    )
    var audit = audit_projection_modulo_loop(samples, 0, 0)
    assert_equal(audit.projection_collision_pair_count, 3)
    assert_equal(audit.direct_extension_edge_count, 0)
    assert_equal(audit.quotiented_collision_pair_count, 0)
    assert_equal(audit.residual_collision_pair_count, 3)
    assert_true(audit.has_residual_collision())
    assert_true(audit.first_residual_left >= 0)
    assert_true(audit.first_residual_right >= 0)


def test_loop_quotient_rejects_mixed_projection_bounds() raises:
    var window_one = addressed_samples_through_depth(
        nonunimodular_pisot_sigma(), seed_pair(), 0, 2, 2, 1
    )
    var window_two = addressed_samples_through_depth(
        nonunimodular_pisot_sigma(), seed_pair(), 1, 2, 2, 2
    )
    window_one.append(window_two[0].copy())

    var caught = False
    try:
        _ = audit_projection_modulo_loop(window_one, 1, 2)
    except:
        caught = True
    assert_true(caught)


def test_loop_quotient_does_not_cross_specimen_provenance() raises:
    # The canonical coarse projection has three depth-2/depth-3 staircase
    # collisions. Assign the two depths to different specimen provenance IDs.
    # Their address digit encodings remain syntactically related, but the audit
    # must not infer a recurrence edge across provenance domains.
    var samples = List[AddressedJointLocalSample]()
    append_addressed_samples_at_depth(
        samples,
        nonunimodular_pisot_sigma(),
        seed_pair(),
        0,
        2,
        2,
        1,
    )
    append_addressed_samples_at_depth(
        samples,
        nonunimodular_pisot_sigma(),
        seed_pair(),
        1,
        3,
        2,
        1,
    )
    var audit = audit_projection_modulo_synchronous_extensions(samples)
    assert_equal(audit.projection_collision_pair_count, 3)
    assert_equal(audit.direct_extension_edge_count, 0)
    assert_equal(audit.quotiented_collision_pair_count, 0)
    assert_equal(audit.residual_collision_pair_count, 3)


def test_any_synchronous_extension_allows_distinct_side_digits() raises:
    # Both sides insert one pair at the same ancestry level, but the inserted
    # top and bottom digit pairs differ. This is still an exact synchronous
    # symbolic extension and should be tested before arithmetic refinements.
    var top_short: List[Int] = [0, 0, 2, 0]
    var top_long: List[Int] = [0, 0, 1, 2, 2, 0]
    var bottom_short: List[Int] = [1, 0, 2, 0]
    var bottom_long: List[Int] = [1, 0, 0, 1, 2, 0]
    assert_true(
        synchronous_any_digit_pair_insertion(
            top_short, top_long, bottom_short, bottom_long
        )
    )


def test_fixed_window_diagnostic_preserves_accounting() raises:
    # A fixed one-level window is deliberately too coarse as depth grows. First
    # quotient only the known same-digit (1,2) family, then quotient every exact
    # observed one-level synchronous symbolic extension. Remaining pairs stay as
    # explicit witnesses for the next refinement.
    var samples = addressed_samples_through_depth(
        nonunimodular_pisot_sigma(), seed_pair(), 0, 7, 2, 1
    )
    var nominated = audit_projection_modulo_loop(samples, 1, 2)
    var synchronous = audit_projection_modulo_synchronous_extensions(samples)

    assert_equal(
        nominated.quotiented_collision_pair_count
        + nominated.residual_collision_pair_count,
        nominated.projection_collision_pair_count,
    )
    assert_equal(
        synchronous.quotiented_collision_pair_count
        + synchronous.residual_collision_pair_count,
        synchronous.projection_collision_pair_count,
    )
    assert_equal(
        synchronous.projection_collision_pair_count,
        nominated.projection_collision_pair_count,
    )
    assert_true(
        synchronous.quotiented_collision_pair_count
        >= nominated.quotiented_collision_pair_count
    )
    assert_true(
        synchronous.residual_collision_pair_count
        <= nominated.residual_collision_pair_count
    )

    print("fixed-window depth-7 raw collisions:", nominated.projection_collision_pair_count)
    print(
        "fixed-window depth-7 nominated-loop quotiented pairs:",
        nominated.quotiented_collision_pair_count,
    )
    print(
        "fixed-window depth-7 nominated-loop residual collisions:",
        nominated.residual_collision_pair_count,
    )
    print(
        "fixed-window depth-7 all-synchronous direct edges:",
        synchronous.direct_extension_edge_count,
    )
    print(
        "fixed-window depth-7 all-synchronous quotiented pairs:",
        synchronous.quotiented_collision_pair_count,
    )
    print(
        "fixed-window depth-7 all-synchronous residual collisions:",
        synchronous.residual_collision_pair_count,
    )
    if synchronous.has_residual_collision():
        var left = synchronous.first_residual_left
        var right = synchronous.first_residual_right
        print("fixed-window first residual left index:", left)
        print("fixed-window first residual right index:", right)
        print("fixed-window first residual left depth:", samples[left].depth)
        print("fixed-window first residual left cut:", samples[left].cut)
        print("fixed-window first residual right depth:", samples[right].depth)
        print("fixed-window first residual right cut:", samples[right].cut)
        print(
            "fixed-window first residual left source-index delta:",
            samples[left].address.source_index_delta,
        )
        print(
            "fixed-window first residual right source-index delta:",
            samples[right].address.source_index_delta,
        )
        print("fixed-window first residual left top digits:", samples[left].address.top_digits)
        print("fixed-window first residual left bottom digits:", samples[left].address.bottom_digits)
        print("fixed-window first residual right top digits:", samples[right].address.top_digits)
        print("fixed-window first residual right bottom digits:", samples[right].address.bottom_digits)

    # Since det(M)=2, probe finite 2-primary residues of the exact scaled defect
    # only after the symbolic quotient. These exact bounded-corpus counts are
    # pinned as regression data, not promoted to a completeness statement.
    var moduli: List[Int] = [2, 4, 8, 16, 32]
    var expected_survivors: List[Int] = [11520, 10944, 6694, 4652, 4652]
    var expected_separated: List[Int] = [0, 576, 4826, 6868, 6868]
    var previous_survivors = synchronous.residual_collision_pair_count
    for q in range(len(moduli)):
        var modulus = moduli[q]
        var residue = audit_synchronous_residual_scaled_defect_residue(
            samples, modulus
        )
        assert_equal(
            residue.residual_collision_pair_count,
            synchronous.residual_collision_pair_count,
        )
        assert_equal(
            residue.residue_surviving_residual_pair_count
            + residue.residue_separated_residual_pair_count,
            residue.residual_collision_pair_count,
        )
        assert_equal(
            residue.residue_surviving_residual_pair_count,
            expected_survivors[q],
        )
        assert_equal(
            residue.residue_separated_residual_pair_count,
            expected_separated[q],
        )
        assert_true(
            residue.residue_surviving_residual_pair_count <= previous_survivors
        )
        previous_survivors = residue.residue_surviving_residual_pair_count
        print("scaled-defect residue modulus:", modulus)
        print(
            "scaled-defect residue surviving residual pairs:",
            residue.residue_surviving_residual_pair_count,
        )
        print(
            "scaled-defect residue separated residual pairs:",
            residue.residue_separated_residual_pair_count,
        )
        if residue.has_residue_survivor():
            var rleft = residue.first_residue_surviving_left
            var rright = residue.first_residue_surviving_right
            print("scaled-defect first survivor left depth:", samples[rleft].depth)
            print("scaled-defect first survivor left cut:", samples[rleft].cut)
            print("scaled-defect first survivor right depth:", samples[rright].depth)
            print("scaled-defect first survivor right cut:", samples[rright].cut)
            print(
                "scaled-defect first survivor left vector:",
                samples[rleft].address.scaled_defect.x,
                samples[rleft].address.scaled_defect.y,
                samples[rleft].address.scaled_defect.z,
            )
            print(
                "scaled-defect first survivor right vector:",
                samples[rright].address.scaled_defect.x,
                samples[rright].address.scaled_defect.y,
                samples[rright].address.scaled_defect.z,
            )


def test_residue_modulus_one_is_rejected() raises:
    var samples = addressed_samples_through_depth(
        nonunimodular_pisot_sigma(), seed_pair(), 0, 3, 2, 1
    )
    var caught = False
    try:
        _ = audit_synchronous_residual_scaled_defect_residue(samples, 1)
    except:
        caught = True
    assert_true(caught)


def test_invalid_residue_modulus_is_rejected_on_empty_corpus() raises:
    var empty = List[AddressedJointLocalSample]()

    var caught_one = False
    try:
        _ = audit_synchronous_residual_scaled_defect_residue(empty, 1)
    except:
        caught_one = True
    assert_true(caught_one)

    var caught_negative = False
    try:
        _ = audit_synchronous_residual_scaled_defect_residue(empty, -2)
    except:
        caught_negative = True
    assert_true(caught_negative)


def main() raises:
    test_known_loop_quotient_removes_staircase_collisions()
    print("[PASS] test_known_loop_quotient_removes_staircase_collisions")
    test_wrong_loop_label_preserves_known_residuals()
    print("[PASS] test_wrong_loop_label_preserves_known_residuals")
    test_loop_quotient_rejects_mixed_projection_bounds()
    print("[PASS] test_loop_quotient_rejects_mixed_projection_bounds")
    test_loop_quotient_does_not_cross_specimen_provenance()
    print("[PASS] test_loop_quotient_does_not_cross_specimen_provenance")
    test_any_synchronous_extension_allows_distinct_side_digits()
    print("[PASS] test_any_synchronous_extension_allows_distinct_side_digits")
    test_fixed_window_diagnostic_preserves_accounting()
    print("[PASS] test_fixed_window_diagnostic_preserves_accounting")
    test_residue_modulus_one_is_rejected()
    print("[PASS] test_residue_modulus_one_is_rejected")
    test_invalid_residue_modulus_is_rejected_on_empty_corpus()
    print("[PASS] test_invalid_residue_modulus_is_rejected_on_empty_corpus")
    print("8 loop-quotient-census Mojo tests passed.")
    require_claim("G1b2RenewalFiniteness")
