"""Conformance of the degree-`n` Pisot screen."""

from __future__ import annotations

import random
import sys
from cProfile import Profile
from fractions import Fraction
from itertools import product
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "reference"))

from psc_research import pisot_screen as ps  # noqa: E402

# Pisot numbers, by minimal polynomial, low-degree-first.
GOLDEN = [-1, -1, 1]              # x^2 - x - 1,        1.618...
SILVER = [-1, -2, 1]              # x^2 - 2x - 1,       2.414...
GOLDEN_SQUARED = [1, -3, 1]       # x^2 - 3x + 1,       2.618..., reciprocal pair
TWO_PLUS_ROOT_THREE = [1, -4, 1]  # x^2 - 4x + 1,       3.732..., reciprocal pair
PLASTIC = [-1, -1, 0, 1]          # x^3 - x - 1,        1.3247..., smallest Pisot
TRIBONACCI = [-1, -1, -1, 1]      # x^3 - x^2 - x - 1,  1.839...
QUARTIC = [-1, 0, 0, -1, 1]       # x^4 - x^3 - 1,      1.380...

SALEM = [1, -1, -1, -1, 1]        # conjugates on the unit circle, not Pisot
CYCLOTOMIC = [1, 0, 0, 0, 1]      # every root on the unit circle


def _roots(coeffs, iterations: int = 700):
    """Durand-Kerner, used only as an independent oracle in tests."""
    n = len(coeffs) - 1
    values = [complex(c) for c in coeffs]
    guesses = [(0.4 + 0.9j) ** k for k in range(n)]

    def at(x: complex) -> complex:
        acc = 0j
        for c in reversed(values):
            acc = acc * x + c
        return acc

    for _ in range(iterations):
        nxt = []
        for i, zi in enumerate(guesses):
            d = 1 + 0j
            for j, zj in enumerate(guesses):
                if i != j:
                    d *= zi - zj
            nxt.append(zi - at(zi) / d if abs(d) > 1e-300 else zi)
        guesses = nxt
    return guesses


def _oracle(coeffs, tol: float = 1e-6) -> str:
    roots = _roots(coeffs)
    if any(abs(abs(z) - 1) <= tol for z in roots):
        return ps.NOT_PISOT                  # a conjugate on the circle disqualifies
    outside = [z for z in roots if abs(z) > 1 + tol]
    if len(outside) != 1:
        return ps.NOT_PISOT
    beta = outside[0]
    return ps.PISOT if abs(beta.imag) < 1e-6 and beta.real > 1 else ps.NOT_PISOT


# --- the pinned classifications -------------------------------------------------


def test_known_pisot_minimal_polynomials():
    for coeffs in (GOLDEN, SILVER, GOLDEN_SQUARED, TWO_PLUS_ROOT_THREE,
                   PLASTIC, TRIBONACCI, QUARTIC, [-2, 1]):
        assert ps.screen(coeffs) == ps.PISOT, coeffs


def test_reciprocal_pisot_polynomials_are_not_refused():
    # Both have root pairs {beta, 1/beta}, which empties a Routh row. Without
    # the auxiliary-derivative rule the array stops and these are refused,
    # although 2.618... and 3.732... are perfectly ordinary Pisot numbers.
    for coeffs in (GOLDEN_SQUARED, TWO_PLUS_ROOT_THREE):
        assert ps.routh_right_half_plane_count(ps.halfplane_transform(coeffs)) == 1
        assert ps.screen(coeffs) == ps.PISOT


def test_a_conjugate_on_the_unit_circle_is_not_pisot():
    # The Routh count alone reports one root outside for a Salem polynomial and
    # would call it Pisot; the unit-circle test is what rejects it. Rejects,
    # not refuses: the verdict here is NOT_PISOT, and REFUSED means something
    # else entirely -- an array that did not resolve.
    for coeffs in (SALEM, CYCLOTOMIC, [1, 0, 1], [-1, 0, 1]):
        assert ps.has_root_on_unit_circle(coeffs), coeffs
        assert ps.screen(coeffs) == ps.NOT_PISOT, coeffs
    assert ps.roots_outside_unit_circle(SALEM) == 1


def test_non_pisot_classifications():
    for coeffs in ([-3, -1, 1],        # x^2 - x - 3, conjugate outside
                   [-3, 0, 1],         # x^2 - 3, both roots outside
                   [2, 1],             # x + 2, the lone root is below -1
                   [1, 1]):            # x + 1, root on the circle
        assert ps.screen(coeffs) == ps.NOT_PISOT, coeffs


def test_the_screen_refuses_what_it_cannot_accept():
    for coeffs in ([1, 2],             # not monic
                   [3],                # degree zero
                   []):                # empty
        assert ps.screen(coeffs) == ps.REFUSED, coeffs


# --- the method -----------------------------------------------------------------


def test_poly_gcd_preserves_exact_values_and_inputs_across_coefficient_types():
    # The first two polynomials share exactly x - 1. Scaling either polynomial
    # by a nonzero rational must leave its monic gcd unchanged.
    cases = (
        ([3, -4, -1, 2], [-2, 1, 1], [-1, 1]),
        ([Fraction(c, 6) for c in (3, -4, -1, 2)],
         [Fraction(2 * c, 5) for c in (-2, 1, 1)], [-1, 1]),
        ([Fraction(3), -4, Fraction(-1), 2, 0],
         [-2, Fraction(1), 1, 0], [-1, 1]),
        ([], [], []),
        ([Fraction(0), 0], [0], []),
        ([], [-2, 2, 0], [-1, 1]),
        ([-2, Fraction(2), 0], [], [-1, 1]),
        ([Fraction(7, 3)], [Fraction(-2, 5)], [1]),
        ([1, 0, 1], [-1, 1], [1]),
    )
    for a, b, expected in cases:
        before_a, before_b = list(a), list(b)
        result = ps._poly_gcd(a, b)
        assert result == expected, (a, b)
        assert all(type(c) is Fraction for c in result)
        assert a == before_a and b == before_b


def test_poly_gcd_canonicalizes_fraction_subclasses_before_arithmetic():
    class ArithmeticTrap(Fraction):
        def __truediv__(self, other):
            raise AssertionError("subclass arithmetic must not reach the gcd")

    # An isinstance fast path would retain this subclass and call its override.
    a = [ArithmeticTrap(-3), ArithmeticTrap(3), ArithmeticTrap(0)]
    b = [ArithmeticTrap(0)]
    result = ps._poly_gcd(a, b)
    assert result == [Fraction(-1), Fraction(1)]
    assert all(type(c) is Fraction for c in result)
    assert all(type(c) is ArithmeticTrap for c in a + b)


def test_poly_gcd_does_not_reconstruct_exact_fraction_coefficients():
    # Zero polynomials require no arithmetic constructors, so the profile
    # isolates redundant construction while normalizing already exact inputs.
    a, b = [Fraction(0), Fraction(0)], [Fraction(0)]
    with Profile() as profile:
        assert ps._poly_gcd(a, b) == []
    assert not any(entry.code is Fraction.__new__.__code__
                   for entry in profile.getstats())


def test_poly_rem_cached_degree_matches_scan_after_multi_zero_cancellation():
    def repeated_degree_scan(a, b):
        """Reference the pre-optimization exact polynomial remainder loop."""
        a, db = list(a), ps.degree(b)
        while ps.degree(a) >= db >= 0:
            da = ps.degree(a)
            factor = a[da] / b[db]
            for i in range(db + 1):
                a[da - db + i] -= factor * b[i]
            a[da] = Fraction(0)
        return a[:db] if db > 0 else []

    divisor = [Fraction(1, 2), Fraction(-3, 4), Fraction(2, 3)]
    expected = [Fraction(5, 7), Fraction(-11, 13)]
    # dividend = expected + x^3 * divisor.  Cancelling its leading term also
    # zeros coefficients 4 and 3, so the cached degree must cross three zero
    # coefficients in one descent before recognizing the degree-1 remainder.
    dividend = expected + [Fraction(0)] + divisor

    assert ps._poly_rem(dividend, divisor) == expected
    assert ps._poly_rem(dividend, divisor) == repeated_degree_scan(
        dividend, divisor
    )


def _dense_division_remainder(a, b):
    """Independent exact division: solve quotient coefficients, then subtract q*b.

    No production degree helper, cached reciprocal, sparse terms or mutable
    remainder is used. Preserve the oracle's untrimmed remainder layout and
    its legacy empty result for a zero or constant divisor.
    """
    db = next((i for i in range(len(b) - 1, -1, -1) if b[i] != 0), -1)
    if db <= 0:
        return []
    quotient = [Fraction(0)] * max(0, len(a) - db)
    for shift in range(len(quotient) - 1, -1, -1):
        contributions = sum(
            (quotient[j] * b[shift + db - j]
             for j in range(shift + 1, min(len(quotient), shift + db + 1))),
            Fraction(0),
        )
        quotient[shift] = (a[shift + db] - contributions) / b[db]
    return [
        a[k] - sum((quotient[j] * b[k - j]
                    for j in range(min(k + 1, len(quotient)))), Fraction(0))
        for k in range(min(db, len(a)))
    ]


def test_poly_rem_sparse_rational_divisor_matches_independent_division():
    divisor = [Fraction(2, 3), Fraction(0), Fraction(-5, 7), Fraction(0),
               Fraction(0), Fraction(-11, 13), Fraction(0)]
    quotient = [Fraction(3, 5), Fraction(0), Fraction(-7, 11), Fraction(2, 9)]
    expected = [Fraction(-2, 17), Fraction(0), Fraction(4, 19), Fraction(0),
                Fraction(0)]
    dividend = expected + [Fraction(0)] * (len(quotient) + 5 - len(expected))
    # A dense convolution supplies a known identity a = q*b + r. The negative,
    # non-unit rational leading coefficient exercises the cached reciprocal;
    # the gaps exercise skipped terms, and the final zero is outside degree(b).
    for i, q in enumerate(quotient):
        for j, c in enumerate(divisor[:6]):
            dividend[i + j] += q * c
    snapshot = (list(dividend), list(divisor))
    result = ps._poly_rem(dividend, divisor)
    assert result == expected == _dense_division_remainder(dividend, divisor)
    assert all(type(c) is Fraction for c in result)
    assert (dividend, divisor) == snapshot


def test_poly_rem_matches_independent_division_on_deterministic_grid():
    polys = [[]] + [list(c) for n in range(1, 4)
                    for c in product((-1, 0, 1), repeat=n)]
    encodings = (
        lambda p: [Fraction(c) for c in p],
        lambda p: [Fraction(c, i + 2) for i, c in enumerate(p)],
        lambda p: [value for i, c in enumerate(p)
                   for value in (Fraction(c, i + 2), Fraction(0), Fraction(0))][:-2],
    )
    for encode in encodings:
        for a, b in product(polys, repeat=2):
            a, b = encode(a), encode(b)
            snapshot = (list(a), list(b))
            expected = _dense_division_remainder(a, b)
            result = ps._poly_rem(a, b)
            assert result == expected, (a, b)
            assert all(type(c) is Fraction for c in result)
            assert (a, b) == snapshot


def test_poly_rem_sparse_path_reduces_exact_arithmetic_work():
    # Count arithmetic dispatch, not wall time. This fails on the dense-loop
    # baseline while pinning the work avoided by the optimization itself.
    divisor = [Fraction(-2, 3), Fraction(0), Fraction(0), Fraction(0),
               Fraction(5, 7)]
    dividend = [Fraction(i + 1, i + 2) for i in range(13)]
    with Profile() as profile:
        result = ps._poly_rem(dividend, divisor)
    assert result == _dense_division_remainder(dividend, divisor)
    calls = {entry.code: entry.callcount for entry in profile.getstats()}
    assert calls.get(Fraction._div.__code__, 0) == 0
    assert calls.get(Fraction._sub.__code__, 0) == 18  # 9 steps, 2 nonzero terms


def _ordinary_fraction_horner(coeffs, x: Fraction) -> Fraction:
    """Unoptimized reference for direct equivalence checks."""
    acc = Fraction(0)
    for c in reversed(coeffs):
        acc = acc * x + Fraction(c)
    return acc


def test_evaluate_matches_ordinary_fraction_horner_on_fast_and_fallback_paths():
    fast_coeffs = [-7, 3, 0, -5, 2]
    fast_x = Fraction(7, 5)
    assert fast_x.denominator > 1
    assert all(type(c) is int for c in fast_coeffs)
    assert ps.evaluate(fast_coeffs, fast_x) == _ordinary_fraction_horner(fast_coeffs, fast_x)

    mixed_coeffs = [Fraction(2, 3), -4, Fraction(-5, 7), 3]
    mixed_x = Fraction(-11, 6)
    assert mixed_x.denominator > 1
    assert any(type(c) is Fraction for c in mixed_coeffs)
    assert ps.evaluate(mixed_coeffs, mixed_x) == _ordinary_fraction_horner(mixed_coeffs, mixed_x)


def test_the_transform_sends_the_unit_circle_to_the_imaginary_axis():
    for coeffs in (GOLDEN, PLASTIC, TRIBONACCI, QUARTIC, SALEM):
        q = ps.halfplane_transform(coeffs)
        for z in _roots(coeffs):
            if abs(z + 1) < 1e-9:
                continue                     # z = -1 maps to infinity
            w = (z - 1) / (z + 1)
            value = sum(complex(c) * w ** k for k, c in enumerate(q))
            assert abs(value) < 1e-6, (coeffs, z)


def test_the_count_outside_matches_an_independent_root_finder():
    for coeffs in (GOLDEN, SILVER, PLASTIC, TRIBONACCI, QUARTIC, [-3, 0, 1], [-1, 2, 1]):
        outside = ps.roots_outside_unit_circle(coeffs)
        if outside is None:
            continue
        expected = sum(1 for z in _roots(coeffs) if abs(z) > 1 + 1e-6)
        assert outside == expected, coeffs


def test_the_screen_agrees_with_the_root_finder_on_random_polynomials():
    random.seed(31)
    agreed = pisot = refused = 0
    for _ in range(300):
        n = random.randint(1, 6)
        coeffs = [random.randint(-4, 4) for _ in range(n)] + [1]
        if coeffs[0] == 0:
            continue
        verdict = ps.screen(coeffs)
        if verdict == ps.REFUSED:
            refused += 1
            continue
        assert verdict == _oracle(coeffs), coeffs
        agreed += 1
        pisot += verdict == ps.PISOT
    assert agreed > 250 and pisot > 20 and refused < 40


def test_a_refusal_is_never_a_negative_result():
    assert ps.screen([1, 2]) == ps.REFUSED
    assert ps.screen([1, 2]) != ps.NOT_PISOT
    assert not ps.refusal_means_not_pisot()


def test_a_refusal_is_never_a_unit_circle_result_either():
    # x^3 - 3x^2 - 3x - 3 is genuinely Pisot, and this method still refuses it:
    # its image 4w^3 + 12w - 8 has second Routh row [0, -8], a first-column zero
    # in a row that is not itself zero. That singularity has classical remedies
    # and none is implemented here. Crucially the refusal proves nothing about
    # the unit circle -- q(iy) has constant real part -8, so there is no root on
    # the imaginary axis at all.
    coeffs = ps.known_first_column_refusal()
    assert coeffs == [-3, -3, -3, 1]
    assert ps.halfplane_transform(coeffs) == [Fraction(-8), Fraction(12), Fraction(0), Fraction(4)]
    assert ps.routh_right_half_plane_count(ps.halfplane_transform(coeffs)) is None
    assert ps.screen(coeffs) == ps.REFUSED
    assert not ps.has_root_on_unit_circle(coeffs)      # the refusal is not circle evidence
    assert not ps.refusal_means_root_on_unit_circle()
    assert _oracle(coeffs) == ps.PISOT                 # and the specimen really is Pisot


def test_the_pisot_verdict_requires_the_others_strictly_inside():
    # A Salem polynomial has exactly one root outside the closed disc, real and
    # greater than one. Only the strict-interior clause separates it from Pisot.
    outside = [z for z in _roots(SALEM) if abs(z) > 1 + 1e-6]
    assert len(outside) == 1
    assert abs(outside[0].imag) < 1e-6 and outside[0].real > 1
    assert ps.screen(SALEM) == ps.NOT_PISOT


# --- irreducibility, decided only where the test can decide it ------------------


def test_irreducibility_is_decided_below_degree_four_and_refused_above():
    assert ps.irreducibility(GOLDEN) == "irreducible"
    assert ps.irreducibility(PLASTIC) == "irreducible"
    # x - 2 is irreducible: every linear polynomial is, and every linear
    # polynomial has a rational root, so the root test must not decide degree one.
    assert ps.irreducibility([-2, 1]) == "irreducible"
    assert ps.irreducibility([2, 1]) == "irreducible"
    assert ps.irreducibility([0, -1, 1]) == "reducible"       # x^2 - x = x(x - 1)
    # A product of two irreducible quadratics has no rational root, so the
    # rational-root test proves nothing at degree four.
    assert ps.irreducibility([1, 0, 2, 0, 1]) == "refused"    # (x^2 + 1)^2
    assert ps.irreducibility(SALEM) == "refused"
    assert not ps.screen_decides_irreducibility()


def test_screening_and_irreducibility_are_independent():
    # Pisot root location on a reducible polynomial: x^2 - x - 6 = (x - 3)(x + 2)
    # has roots 3 and -2, so it is reducible and not Pisot; x^3 - x^2 - x - 1
    # is irreducible and Pisot. Neither property implies the other.
    assert ps.irreducibility([-6, -1, 1]) == "reducible"
    assert ps.screen(TRIBONACCI) == ps.PISOT and ps.irreducibility(TRIBONACCI) == "irreducible"
    assert ps.screen([-2, 1]) == ps.PISOT and ps.irreducibility([-2, 1]) == "irreducible"
