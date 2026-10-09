"""Finite identity and boundary controls; no infinite-tail certification."""

from fractions import Fraction
from itertools import product
from math import isqrt

import pytest

from kernel.pv.hankel import recurrence_coefficients, recurrence_residuals
from kernel.pv.reconstruction import (
    backward_error_window,
    linear_defect_sides,
    normalized_defects,
    ratio_telescope,
    scaled_telescope,
)
from kernel.pv_exact import defect, next_e


def test_linear_residual_identity_for_arbitrary_trial_parameters():
    for a, b, c in product((-7, -1, 2, 9), repeat=3):
        for alpha in (-2, 0, Fraction(7, 3)):
            left, right = linear_defect_sides(a, b, c, alpha)
            assert left == right == Fraction(defect(a, b, c), a)


def test_all_finite_windows_telescope_with_absolute_indices():
    values = [Fraction((-1) ** n * (n * n + 3), n + 1) for n in range(12)]
    for start in range(len(values) - 1):
        for stop in range(start, len(values) - 1):
            assert ratio_telescope(values, start, stop)[0] == (
                ratio_telescope(values, start, stop)[1]
            )
        for stop in range(start, len(values)):
            for alpha in (Fraction(7, 3), Fraction(-2, 5)):
                left, right = scaled_telescope(values, alpha, start, stop)
                assert left == right
                left, right = backward_error_window(
                    values, alpha, Fraction(5, 7), start, stop
                )
                assert left == right


def test_unbounded_quadratic_rounding_tail_can_have_limit_one():
    values = list(range(3, 35))
    deltas = normalized_defects(values)
    for n, delta in enumerate(deltas, start=3):
        assert delta == Fraction(-1, n)
        assert next_e(n, n + 1) == n + 2
        assert Fraction(n + 1, n) - 1 == Fraction(1, n)
    # The recurrence has a repeated root at one; it is not an expanding
    # exponential witness despite increasing integers and small defects.
    assert recurrence_coefficients(values, 0, 2) == (-1, 2)


def test_wrong_amplitude_does_not_permit_dropping_the_terminal_term():
    values = [2**n for n in range(25)]
    assert not any(normalized_defects(values))
    assert scaled_telescope(values, 2, 3, 24) == (0, 0)
    # All d_k vanish, but the error for trial amplitude 3 is nonzero.
    # The entire answer is the terminal contribution in the finite formula.
    assert backward_error_window(values, 2, 3, 3, 24) == (-16, -16)


def test_finite_geometric_error_tail_retains_its_remainder():
    alpha, beta = Fraction(2), Fraction(1, 3)
    values = [alpha**n + beta**n for n in range(30)]
    for start in range(8):
        assert values[start + 1] / values[start] >= Fraction(7, 6)
        for stop in range(start, 25):
            terminal = alpha ** (start - stop) * beta**stop
            finite_sum = -sum(
                alpha ** (start - k - 1) * (beta - alpha) * beta**k
                for k in range(start, stop)
            )
            assert finite_sum == beta**start - terminal
            assert backward_error_window(values, alpha, 1, start, stop) == (
                beta**start, terminal + finite_sum
            )


def test_defect_expansion_matches_large_integer_perturbations():
    alpha, amplitude = 3, 7
    for n in (0, 1, 11, 200):
        for e0, e1, e2 in product((-2, 0, 5), repeat=3):
            a = amplitude * alpha**n + e0
            b = amplitude * alpha ** (n + 1) + e1
            c = amplitude * alpha ** (n + 2) + e2
            assert defect(a, b, c) == (
                amplitude * alpha**n * (e2 + alpha**2 * e0 - 2 * alpha * e1)
                + e0 * e2 - e1**2
            )


@pytest.mark.parametrize(
    ("unit_root", "coefficients"), [(1, (-2, 3)), (-1, (2, 1))]
)
def test_bounded_unit_root_errors_fail_the_vanishing_defect_hypothesis(
    unit_root, coefficients
):
    values = [2**n + unit_root**n for n in range(30)]
    deltas = normalized_defects(values)
    assert not any(recurrence_residuals(values, coefficients))
    for n in range(20):
        assert recurrence_coefficients(values, n, 2) == coefficients
        assert defect(*values[n:n + 3]) == (2 - unit_root) ** 2 * (2 * unit_root)**n
        assert abs(deltas[n]) >= Fraction(1, 2)


def test_abel_unit_pole_controls_retain_exact_finite_tail_terms():
    t = Fraction(9, 10)
    for length in range(1, 20):
        constant_sum = sum(t**n for n in range(length))
        alternating_radial_sum = sum((-1)**n * (-t)**n for n in range(length))
        assert (1 - t) * constant_sum == 1 - t**length
        assert alternating_radial_sum == constant_sum
        repeated_pole_sum = sum(n * t**n for n in range(length))
        assert (1 - t) ** 2 * repeated_pole_sum == (
            t - length * t**length + (length - 1) * t ** (length + 1)
        )


def test_rational_square_sum_boundary_blocks_are_not_pv_counterexamples():
    # Artificial errors with O(n^-1/2): every block has mass 3.
    for j in range(20):
        block_length = 3 * 4**j
        error = Fraction(1, 2**j)
        assert block_length * error**2 == 3
    # Artificial errors with o(n^-1/2): grouped masses still dominate 3/k.
    for k in range(1, 20):
        mass = Fraction(0)
        for j in range((k - 1)**2 + 1, k**2 + 1):
            ceiling = isqrt(j - 1) + 1
            assert ceiling == k
            mass += 3 * 4**j * Fraction(1, 2**j * ceiling)**2
        assert mass == Fraction(3 * (2 * k - 1), k**2)
        assert mass >= Fraction(3, k)


def test_reconstruction_window_validation_and_exact_input_boundary():
    assert normalized_defects([1, 2]) == ()
    for start, stop in ((-1, 1), (2, 1), (0, 3)):
        with pytest.raises(ValueError):
            scaled_telescope([1, 2, 4], 2, start, stop)
    with pytest.raises(ValueError):
        ratio_telescope([1, 2, 4], 0, 2)
    with pytest.raises(ValueError):
        backward_error_window([1, 2, 4], 0, 1, 0, 2)
    with pytest.raises(ValueError):
        scaled_telescope([1, 2, 4], 0, 0, 2)
    with pytest.raises(TypeError):
        normalized_defects([1, "2", 4])
    with pytest.raises(TypeError):
        scaled_telescope([1, 2, 4], "2", 0, 2)
    with pytest.raises(ZeroDivisionError):
        linear_defect_sides(0, 1, 2, 3)
