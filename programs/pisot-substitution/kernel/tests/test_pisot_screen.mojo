"""Exact regressions for the degree-`n` Pisot screen.

The cross-check in `test_the_screen_agrees_with_the_cubic_decider` is the
substantive one: `psc.pisot.is_pisot_charpoly` settles cubics by Sturm counting
plus the determinant identity `beta * |beta_2|^2 = det`, which shares no step
with the Moebius-plus-Routh method here. Agreement across every irreducible
monic cubic with coefficients in `[-4, 4]` is therefore evidence, not an echo.
"""

from std.testing import assert_equal, assert_false, assert_true
from finite_exact.rat_q import Q
from finite_linear_algebra.scalar import q_int
from mojo_smoke.claims import require_contract
from psc.exact import q_poly
from psc.pisot import is_pisot_charpoly, poly_degree
from psc.pisot_screen import (
    IRREDUCIBILITY_REFUSED,
    IRREDUCIBLE,
    REDUCIBLE,
    ROUTH_UNDECIDED,
    SCREEN_NOT_PISOT,
    SCREEN_PISOT,
    SCREEN_REFUSED,
    halfplane_transform,
    has_root_on_unit_circle,
    irreducibility,
    known_first_column_refusal,
    refusal_means_not_pisot,
    refusal_means_root_on_unit_circle,
    roots_outside_unit_circle,
    routh_right_half_plane_count,
    screen,
    screen_decides_irreducibility,
)


def golden() -> List[Int]:
    var c: List[Int] = [-1, -1, 1]              # x^2 - x - 1,       1.618...
    return c^


def silver() -> List[Int]:
    var c: List[Int] = [-1, -2, 1]              # x^2 - 2x - 1,      2.414...
    return c^


def golden_squared() -> List[Int]:
    var c: List[Int] = [1, -3, 1]               # x^2 - 3x + 1,      reciprocal pair
    return c^


def two_plus_root_three() -> List[Int]:
    var c: List[Int] = [1, -4, 1]               # x^2 - 4x + 1,      reciprocal pair
    return c^


def plastic() -> List[Int]:
    var c: List[Int] = [-1, -1, 0, 1]           # x^3 - x - 1,       smallest Pisot
    return c^


def tribonacci() -> List[Int]:
    var c: List[Int] = [-1, -1, -1, 1]          # x^3 - x^2 - x - 1, 1.839...
    return c^


def quartic() -> List[Int]:
    var c: List[Int] = [-1, 0, 0, -1, 1]        # x^4 - x^3 - 1,     1.380...
    return c^


def salem() -> List[Int]:
    var c: List[Int] = [1, -1, -1, -1, 1]       # conjugates on the unit circle
    return c^


def cyclotomic() -> List[Int]:
    var c: List[Int] = [1, 0, 0, 0, 1]          # every root on the unit circle
    return c^


def test_known_pisot_minimal_polynomials() raises:
    var known = List[List[Int]]()
    known.append(golden())
    known.append(silver())
    known.append(golden_squared())
    known.append(two_plus_root_three())
    known.append(plastic())
    known.append(tribonacci())
    known.append(quartic())
    var linear: List[Int] = [-2, 1]             # x - 2
    known.append(linear^)
    for i in range(len(known)):
        assert_equal(screen(known[i]), SCREEN_PISOT)


def test_reciprocal_pisot_polynomials_are_not_refused() raises:
    # Both have root pairs {beta, 1/beta}, which empties a Routh row. Without
    # the auxiliary-derivative rule the array stops and these are refused,
    # although 2.618... and 3.732... are perfectly ordinary Pisot numbers.
    var reciprocal = List[List[Int]]()
    reciprocal.append(golden_squared())
    reciprocal.append(two_plus_root_three())
    for i in range(len(reciprocal)):
        var count = routh_right_half_plane_count(halfplane_transform(reciprocal[i]))
        assert_equal(count, 1)
        assert_equal(screen(reciprocal[i]), SCREEN_PISOT)


def test_a_conjugate_on_the_unit_circle_is_not_pisot() raises:
    # The Routh count alone reports one root outside for a Salem polynomial and
    # would call it Pisot; the unit-circle test is what rejects it. Rejects, not
    # refuses: the verdict here is SCREEN_NOT_PISOT, and SCREEN_REFUSED means
    # something else entirely -- an array that did not resolve. This is also
    # what makes the strict-interior clause of the `screen` contract load-bearing:
    # a Salem polynomial has exactly one root outside the closed disc, real and
    # greater than one, and is still not Pisot.
    var on_circle = List[List[Int]]()
    on_circle.append(salem())
    on_circle.append(cyclotomic())
    var sum_of_squares: List[Int] = [1, 0, 1]   # x^2 + 1
    var difference: List[Int] = [-1, 0, 1]      # x^2 - 1
    on_circle.append(sum_of_squares^)
    on_circle.append(difference^)
    for i in range(len(on_circle)):
        assert_true(has_root_on_unit_circle(on_circle[i]))
        assert_equal(screen(on_circle[i]), SCREEN_NOT_PISOT)
    assert_equal(roots_outside_unit_circle(salem()), 1)


def test_non_pisot_classifications() raises:
    var rejected = List[List[Int]]()
    var conjugate_outside: List[Int] = [-3, -1, 1]   # x^2 - x - 3
    var both_outside: List[Int] = [-3, 0, 1]         # x^2 - 3
    var below_minus_one: List[Int] = [2, 1]          # x + 2
    var root_at_minus_one: List[Int] = [1, 1]        # x + 1
    rejected.append(conjugate_outside^)
    rejected.append(both_outside^)
    rejected.append(below_minus_one^)
    rejected.append(root_at_minus_one^)
    for i in range(len(rejected)):
        assert_equal(screen(rejected[i]), SCREEN_NOT_PISOT)


def test_the_screen_refuses_what_it_cannot_accept() raises:
    var not_monic: List[Int] = [1, 2]
    var constant: List[Int] = [3]
    var empty = List[Int]()
    assert_equal(screen(not_monic), SCREEN_REFUSED)
    assert_equal(screen(constant), SCREEN_REFUSED)
    assert_equal(screen(empty), SCREEN_REFUSED)


def test_a_refusal_is_never_a_negative_result() raises:
    var not_monic: List[Int] = [1, 2]
    assert_equal(screen(not_monic), SCREEN_REFUSED)
    assert_true(screen(not_monic) != SCREEN_NOT_PISOT)
    assert_false(refusal_means_not_pisot())


def test_a_refusal_is_never_a_unit_circle_result_either() raises:
    """`x^3 - 3x^2 - 3x - 3` is Pisot, refused, and has no root on the circle.

    Its image `4w^3 + 12w - 8` has second Routh row `[0, -8]`: a first-column
    zero in a row that is not itself zero. That singularity has classical
    remedies and none is implemented here, so the screen refuses a genuine
    Pisot polynomial. The refusal proves nothing about the unit circle either,
    since `q(iy)` has constant real part `-8` and so no axis root at all.
    """
    var coeffs = known_first_column_refusal()
    var expected: List[Int] = [-3, -3, -3, 1]
    assert_equal(len(coeffs), len(expected))
    for i in range(len(expected)):
        assert_equal(coeffs[i], expected[i])
    var image = halfplane_transform(coeffs)
    var image_expected: List[Int] = [-8, 12, 0, 4]
    assert_equal(len(image), len(image_expected))
    for i in range(len(image_expected)):
        assert_true(image[i].eq(q_int(image_expected[i])))
    assert_equal(routh_right_half_plane_count(image), ROUTH_UNDECIDED)
    assert_equal(screen(coeffs), SCREEN_REFUSED)
    assert_false(has_root_on_unit_circle(coeffs))   # the refusal is not circle evidence
    assert_false(refusal_means_root_on_unit_circle())


def test_the_transform_drops_degree_exactly_at_a_root_of_minus_one() raises:
    # z = -1 is the one point the Moebius map sends to infinity, so the image
    # loses a degree there and nowhere else.
    var root_at_minus_one: List[Int] = [1, 1]        # x + 1
    assert_equal(poly_degree(halfplane_transform(root_at_minus_one)), 0)
    assert_equal(poly_degree(halfplane_transform(plastic())), 3)
    assert_equal(roots_outside_unit_circle(root_at_minus_one), ROUTH_UNDECIDED)


def test_the_screen_agrees_with_the_cubic_decider() raises:
    """Every irreducible monic cubic with coefficients in `[-4, 4]`.

    `is_pisot_charpoly` is restricted to irreducible cubics by construction, so
    reducible ones are outside the comparison rather than counterexamples to it.
    """
    var compared = 0
    var pisot = 0
    for c0 in range(-4, 5):
        for c1 in range(-4, 5):
            for c2 in range(-4, 5):
                var coeffs: List[Int] = [c0, c1, c2, 1]
                if irreducibility(coeffs) != IRREDUCIBLE:
                    continue
                if has_root_on_unit_circle(coeffs):
                    continue
                var verdict = screen(coeffs)
                if verdict == SCREEN_REFUSED:
                    continue
                compared += 1
                if is_pisot_charpoly(coeffs):
                    pisot += 1
                    assert_equal(verdict, SCREEN_PISOT)
                else:
                    assert_equal(verdict, SCREEN_NOT_PISOT)
    assert_equal(compared, 504)
    assert_equal(pisot, 75)


def test_irreducibility_is_decided_below_degree_four_and_refused_above() raises:
    assert_equal(irreducibility(golden()), IRREDUCIBLE)
    assert_equal(irreducibility(plastic()), IRREDUCIBLE)
    # x - 2 is irreducible: every linear polynomial is, and every linear
    # polynomial has a rational root, so the root test must not decide degree one.
    var minus_two: List[Int] = [-2, 1]
    var plus_two: List[Int] = [2, 1]
    assert_equal(irreducibility(minus_two), IRREDUCIBLE)
    assert_equal(irreducibility(plus_two), IRREDUCIBLE)
    var factors: List[Int] = [0, -1, 1]              # x^2 - x = x(x - 1)
    assert_equal(irreducibility(factors), REDUCIBLE)
    # A product of two irreducible quadratics has no rational root, so the
    # rational-root test proves nothing at degree four.
    var quadratic_square: List[Int] = [1, 0, 2, 0, 1]   # (x^2 + 1)^2
    assert_equal(irreducibility(quadratic_square), IRREDUCIBILITY_REFUSED)
    assert_equal(irreducibility(salem()), IRREDUCIBILITY_REFUSED)
    assert_false(screen_decides_irreducibility())


def test_screening_and_irreducibility_are_independent() raises:
    # x^2 - x - 6 = (x - 3)(x + 2) is reducible and not Pisot; x^3 - x^2 - x - 1
    # is irreducible and Pisot. Neither property implies the other.
    var reducible: List[Int] = [-6, -1, 1]
    var linear: List[Int] = [-2, 1]
    assert_equal(irreducibility(reducible), REDUCIBLE)
    assert_equal(screen(tribonacci()), SCREEN_PISOT)
    assert_equal(irreducibility(tribonacci()), IRREDUCIBLE)
    assert_equal(screen(linear), SCREEN_PISOT)
    assert_equal(irreducibility(linear), IRREDUCIBLE)


def test_the_cubic_decider_is_still_the_one_used_for_pip() raises:
    # The screen does not replace `is_pisot_charpoly`; it extends the reach of
    # the same question to degrees the cubic identity cannot address.
    assert_true(is_pisot_charpoly(plastic()))
    assert_equal(screen(quartic()), SCREEN_PISOT)
    assert_equal(poly_degree(q_poly(quartic())), 4)


def main() raises:
    test_known_pisot_minimal_polynomials()
    print("[PASS] test_known_pisot_minimal_polynomials")
    test_reciprocal_pisot_polynomials_are_not_refused()
    print("[PASS] test_reciprocal_pisot_polynomials_are_not_refused")
    test_a_conjugate_on_the_unit_circle_is_not_pisot()
    print("[PASS] test_a_conjugate_on_the_unit_circle_is_not_pisot")
    test_non_pisot_classifications()
    print("[PASS] test_non_pisot_classifications")
    test_the_screen_refuses_what_it_cannot_accept()
    print("[PASS] test_the_screen_refuses_what_it_cannot_accept")
    test_a_refusal_is_never_a_negative_result()
    print("[PASS] test_a_refusal_is_never_a_negative_result")
    test_a_refusal_is_never_a_unit_circle_result_either()
    print("[PASS] test_a_refusal_is_never_a_unit_circle_result_either")
    test_the_transform_drops_degree_exactly_at_a_root_of_minus_one()
    print("[PASS] test_the_transform_drops_degree_exactly_at_a_root_of_minus_one")
    test_the_screen_agrees_with_the_cubic_decider()
    print("[PASS] test_the_screen_agrees_with_the_cubic_decider")
    test_irreducibility_is_decided_below_degree_four_and_refused_above()
    print("[PASS] test_irreducibility_is_decided_below_degree_four_and_refused_above")
    test_screening_and_irreducibility_are_independent()
    print("[PASS] test_screening_and_irreducibility_are_independent")
    test_the_cubic_decider_is_still_the_one_used_for_pip()
    print("[PASS] test_the_cubic_decider_is_still_the_one_used_for_pip")
    print("12 Pisot-screen Mojo tests passed.")
    require_contract("the degree-n Pisot screen is exact and fail-closed: a refusal is never a negative result, and the cubic decider stays canonical for PIP")
