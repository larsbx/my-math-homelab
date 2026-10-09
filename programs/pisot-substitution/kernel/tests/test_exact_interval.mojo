"""Regressions for the PSC exact-interval layer over `finite_exact` and the Perron enclosures."""

from std.testing import assert_equal, assert_false, assert_true
from psc.bpa import substitution_incidence
from finite_linear_algebra.mat3 import Mat3
from mojo_smoke.claims import require_contract
from psc.overlap_interval_audit import audit_seed_overlap_interval_margins
from psc.perron_field3 import CubicElt, PerronField3, build_perron_field3, sign_at_perron
from psc.perron_root_sign import perron_sign_by_enclosure
from psc.perron_interval import (
    cubic_perron_interval,
    interval_sign_at_perron,
    perron_root_interval,
    perron_sign_decision,
)
from finite_exact.bigint_z import bigz_add, bigz_from_i64
from finite_exact.closed_interval import IQ
from finite_exact.rat_q import Q, q_from_bigz
from psc.exact import contains_zero, eval_int_poly_at_q, integer_interval, interval_horner_int, q_sign, q_string, strict_sign


def determinant_two_sigma() -> List[List[Int]]:
    var a0: List[Int] = [1]
    var a1: List[Int] = [0, 2, 1]
    var a2: List[Int] = [0, 0, 1]
    var sigma = List[List[Int]]()
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def test_exact_rational_normalization_and_order() raises:
    assert_true(Q(2, 4).eq(Q(1, 2)))
    assert_true(Q(1, -2).eq(Q(-1, 2)))
    assert_true(Q(2, 3).lt(Q(3, 4)))
    assert_true(Q(1, 3).add(Q(1, 6)).eq(Q(1, 2)))
    assert_true(Q(2, 3).mul(Q(9, 4)).eq(Q(3, 2)))


def test_natural_interval_extension_contains_point_values() raises:
    # p(x)=x^2-2 on x in [1,2] has natural extension [-1,2].
    var x = integer_interval(1, 2)
    var coeffs: List[Int] = [-2, 0, 1]
    var box = interval_horner_int(coeffs, x)
    assert_true(box.lo.eq(Q(-1, 1)))
    assert_true(box.hi.eq(Q(2, 1)))
    assert_true(contains_zero(box))
    assert_equal(strict_sign(box), 0)

    var positive_coeffs: List[Int] = [1, 1]
    var positive = interval_horner_int(positive_coeffs, x)
    assert_equal(strict_sign(positive), 1)


def test_interval_division_across_zero_fails_closed() raises:
    var numerator = integer_interval(1, 2)
    var denominator = IQ(Q(-1, 1), Q(1, 1))
    var quotient = numerator.mul(denominator.reciprocal())
    assert_true(denominator.reciprocal().rejected)
    assert_true(quotient.rejected)
    var caught = False
    try:
        _ = strict_sign(quotient)
    except:
        caught = True
    assert_true(caught)


def test_unbounded_rational_arithmetic_does_not_overflow() raises:
    # The retired fixed-width layer raised here; finite_exact carries the value.
    var beyond = q_from_bigz(bigz_add(bigz_from_i64(Int64.MAX), bigz_from_i64(1)), bigz_from_i64(1))
    var total = Q(Int64.MAX, 1).add(Q(1, 1))
    assert_true(total.accepted())
    assert_true(total.eq(beyond))
    assert_true(Q(Int64.MAX, 1).lt(total))
    assert_true(Q(Int64.MAX, 1).mul(Q(1, Int64.MAX)).eq(Q.one()))


def test_perron_root_has_exact_rational_bracket() raises:
    var sigma = determinant_two_sigma()
    var field = build_perron_field3(Mat3(substitution_incidence(sigma)))
    var box = perron_root_interval(field, 10)
    assert_true(Q(2, 1).lt(box.lo))
    assert_true(box.hi.lt(Q(3, 1)))

    var chi: List[Int] = [field.chi0, field.chi1, field.chi2, 1]
    var flo = q_sign(eval_int_poly_at_q(chi, box.lo))
    var fhi = q_sign(eval_int_poly_at_q(chi, box.hi))
    assert_true(flo != 0)
    assert_true(fhi != 0)
    assert_true(flo != fhi)


def test_symbolic_zero_is_not_a_strict_interval_certificate() raises:
    var sigma = determinant_two_sigma()
    var field = build_perron_field3(Mat3(substitution_incidence(sigma)))
    var zero = perron_sign_decision(field, CubicElt(), 6)
    assert_equal(zero.sign, 0)
    assert_false(zero.interval_certified)


def test_interval_first_perron_sign_certifies_easy_and_falls_back_near_root() raises:
    var sigma = determinant_two_sigma()
    var field = build_perron_field3(Mat3(substitution_incidence(sigma)))

    # beta-1 is separated from zero by even a coarse rational enclosure.
    assert_equal(interval_sign_at_perron(field, CubicElt(-1, 1, 0), 6), 1)
    var easy = perron_sign_decision(field, CubicElt(-1, 1, 0), 6)
    assert_equal(easy.sign, 1)
    assert_true(easy.interval_certified)

    # This Codex counter-calibration lies extremely close to the Perron root.
    # A modest interval box must remain honest and say "unknown"; the exact
    # Sturm--Tarski fallback then supplies the negative sign.
    var near = CubicElt(-152138, 67035, 0)
    assert_equal(interval_sign_at_perron(field, near, 10), 0)
    var decided = perron_sign_decision(field, near, 10)
    assert_equal(decided.sign, -1)
    assert_false(decided.interval_certified)

    var enclosure = cubic_perron_interval(field, near, 10)
    assert_true(contains_zero(enclosure))


def test_canonical_overlap_margin_interval_calibration() raises:
    # Finite canonical calibration only: these constants describe this one
    # seed-patch graph and this fixed ten-refinement Perron enclosure.
    var audit = audit_seed_overlap_interval_margins(
        determinant_two_sigma(), 10, 20000
    )
    assert_equal(audit.state_count, 628)
    assert_equal(audit.margin_count, 1256)
    assert_equal(audit.interval_certified_count, 1256)
    assert_equal(audit.fallback_count, 0)
    assert_true(audit.has_uniform_interval_lower_margin)
    assert_true(
        audit.minimum_interval_lower_margin.eq(Q(231, 16384))
    )
    print("canonical overlap margins:", audit.margin_count)
    print("interval-certified margins:", audit.interval_certified_count)
    print("algebraic-fallback margins:", audit.fallback_count)
    print(
        "minimum certified rational overlap margin:",
        q_string(audit.minimum_interval_lower_margin),
    )
    assert_equal(q_string(audit.minimum_interval_lower_margin), "231/16384")
    assert_equal(q_string(Q(-1000000001, 1)), "-1000000001")
    assert_equal(q_string(Q(1, 0)), "rejected")


def test_coarse_overlap_audit_withholds_partial_minimum() raises:
    # A deliberately coarse Perron enclosure exercises the mixed path. Exact
    # fallback preserves positivity, but a subset minimum is not exposed.
    var audit = audit_seed_overlap_interval_margins(
        determinant_two_sigma(), 0, 20000
    )
    assert_true(audit.interval_certified_count > 0)
    assert_true(audit.fallback_count > 0)
    assert_false(audit.has_uniform_interval_lower_margin)
    assert_true(audit.minimum_interval_lower_margin.eq(Q.zero()))


def test_the_two_sign_oracles_agree_wherever_both_decide() raises:
    """Differential check of the fixed-width oracle against the rational one.

    The two share no method: `sign_at_perron` counts sign variations in a
    signed-remainder chain over machine integers, `interval_sign_at_perron`
    encloses beta in a rational interval and brackets the quadratic over it.
    Every coefficient triple on which both return a strict sign must return
    the same one, and neither may call a nonzero element zero.
    """
    var fields = List[PerronField3]()
    fields.append(PerronField3(-1, -1, 0))   # x^3 - x - 1
    fields.append(PerronField3(-1, 0, -1))   # x^3 - x^2 - 1
    fields.append(PerronField3(-1, -1, -1))  # x^3 - x^2 - x - 1
    var compared = 0
    for f in range(len(fields)):
        ref field = fields[f]
        for a0 in range(-4, 5):
            for a1 in range(-4, 5):
                for a2 in range(-4, 5):
                    var x = CubicElt(a0, a1, a2)
                    if x.is_zero():
                        continue
                    var boxed = interval_sign_at_perron(field, x, 24)
                    var exact = sign_at_perron(field, x)
                    assert_true(exact == 1 or exact == -1)
                    if boxed != 0:
                        assert_equal(boxed, exact)
                        compared += 1
    assert_true(compared > 2000)


def test_coefficients_of_one_sign_are_decided_by_positivity_alone() raises:
    """beta > 1 > 0, so a nonzero one-signed quadratic cannot change sign at it.

    This is the shortcut `sign_at_perron` takes before building any remainder,
    and it has to agree with the chain it skips -- including the cases where
    the leading or constant coefficient vanishes.
    """
    var field = PerronField3(-1, -1, 0)
    assert_equal(sign_at_perron(field, CubicElt(0, 0, 7)), 1)
    assert_equal(sign_at_perron(field, CubicElt(3, 0, 0)), 1)
    assert_equal(sign_at_perron(field, CubicElt(1, 2, 3)), 1)
    assert_equal(sign_at_perron(field, CubicElt(0, 0, -7)), -1)
    assert_equal(sign_at_perron(field, CubicElt(-3, 0, 0)), -1)
    assert_equal(sign_at_perron(field, CubicElt(-1, -2, -3)), -1)
    assert_equal(sign_at_perron(field, CubicElt()), 0)


def test_a_mixed_sign_element_still_goes_through_the_remainder_chain() raises:
    """`beta^2 - p beta + p` changes sign on the enclosure of beta for every
    p >= 6, so no coefficient test and no endpoint bracket can settle it; the
    answer is the chain's, and the rational oracle confirms it."""
    var field = PerronField3(-1, -1, 0)
    for p in [6, 100, 10000, 100000]:
        var x = CubicElt(p, -p, 1)
        assert_equal(sign_at_perron(field, x), -1)
        assert_equal(interval_sign_at_perron(field, x, 24), -1)


def test_the_perron_sign_has_no_coefficient_ceiling() raises:
    """`sign_at_perron` decides every element whose coordinates fit in `Int`.

    Its machine-integer rung stops at about `2 * 10^6`, where the cubic form in
    the terminal resultant leaves `Int`. Past that the question goes to the
    rational enclosure instead of being refused, so the ceiling belongs to the
    rung and not to the function. `beta^2 - p beta + p` is negative at beta for
    every `p >= 6` and is settled by no coefficient test and no endpoint
    bracket, so each case here really does reach past the shortcuts.
    """
    var field = PerronField3(-1, -1, 0)
    for p in [100000, 10000000, 1000000000000, 4611686018427387904]:
        var x = CubicElt(p, -p, 1)
        assert_equal(sign_at_perron(field, x), -1)
        assert_equal(
            perron_sign_by_enclosure(field.chi0, field.chi1, field.chi2, p, -p, 1), -1
        )


def test_the_enclosure_decides_where_the_machine_rung_cannot() raises:
    """The unbounded oracle on its own, at sizes the chain cannot reach.

    Both signs, at a magnitude where the chain's terminal resultant would need
    roughly `10^54`, and the zero element, which is exactly zero and is the one
    element that has no sign.
    """
    assert_equal(perron_sign_by_enclosure(-1, -1, 0, 10**18, -(10**18), 1), -1)
    assert_equal(perron_sign_by_enclosure(-1, -1, 0, -(10**18), 10**18, -1), 1)
    assert_equal(perron_sign_by_enclosure(-1, -1, 0, 0, 0, 0), 0)
    # beta - 1 > 0 and beta^2 - 2 < 0 for the plastic root, at any scale
    assert_equal(perron_sign_by_enclosure(-1, -1, 0, -(10**15), 10**15, 0), 1)
    assert_equal(perron_sign_by_enclosure(-1, -1, 0, -(2 * 10**15), 0, 10**15), -1)


def main() raises:
    test_exact_rational_normalization_and_order()
    print("[PASS] test_exact_rational_normalization_and_order")
    test_natural_interval_extension_contains_point_values()
    print("[PASS] test_natural_interval_extension_contains_point_values")
    test_interval_division_across_zero_fails_closed()
    print("[PASS] test_interval_division_across_zero_fails_closed")
    test_unbounded_rational_arithmetic_does_not_overflow()
    print("[PASS] test_unbounded_rational_arithmetic_does_not_overflow")
    test_perron_root_has_exact_rational_bracket()
    print("[PASS] test_perron_root_has_exact_rational_bracket")
    test_symbolic_zero_is_not_a_strict_interval_certificate()
    print("[PASS] test_symbolic_zero_is_not_a_strict_interval_certificate")
    test_interval_first_perron_sign_certifies_easy_and_falls_back_near_root()
    print("[PASS] test_interval_first_perron_sign_certifies_easy_and_falls_back_near_root")
    test_canonical_overlap_margin_interval_calibration()
    print("[PASS] test_canonical_overlap_margin_interval_calibration")
    test_coarse_overlap_audit_withholds_partial_minimum()
    print("[PASS] test_coarse_overlap_audit_withholds_partial_minimum")
    test_the_two_sign_oracles_agree_wherever_both_decide()
    print("[PASS] test_the_two_sign_oracles_agree_wherever_both_decide")
    test_coefficients_of_one_sign_are_decided_by_positivity_alone()
    print("[PASS] test_coefficients_of_one_sign_are_decided_by_positivity_alone")
    test_a_mixed_sign_element_still_goes_through_the_remainder_chain()
    print("[PASS] test_a_mixed_sign_element_still_goes_through_the_remainder_chain")
    test_the_perron_sign_has_no_coefficient_ceiling()
    print("[PASS] test_the_perron_sign_has_no_coefficient_ceiling")
    test_the_enclosure_decides_where_the_machine_rung_cannot()
    print("[PASS] test_the_enclosure_decides_where_the_machine_rung_cannot")
    print("14 exact-interval Mojo tests passed.")
    require_contract("the exact rational and closed-interval layer: an unknown containment or sign is never promoted, and a coarse audit withholds a partial minimum")
