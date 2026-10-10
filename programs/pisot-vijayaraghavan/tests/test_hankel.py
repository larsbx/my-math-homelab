from fractions import Fraction
from itertools import product
from random import Random

import pytest

from kernel.pv.hankel import (
    admissible_hankel_size,
    determinant,
    dodgson_sides,
    hankel_exponent,
    hankel_minor,
    recurrence_coefficients,
    recurrence_residuals,
)
from kernel.pv.identities import defect, hankel3
from kernel.pv_exact import hankel_minor as bareiss_hankel_minor


def extend_recurrence(initial, coefficients, length):
    values = list(initial)
    order = len(coefficients)
    while len(values) < length:
        start = len(values) - order
        values.append(sum(coefficients[j] * values[start + j] for j in range(order)))
    return values


def test_ratio_difference_is_the_normalized_defect():
    for a0, a1, a2 in product((-7, -2, 1, 3, 9), repeat=3):
        assert Fraction(a2, a1) - Fraction(a1, a0) == Fraction(
            defect(a0, a1, a2), a0 * a1
        )


def test_determinant_pivoting_and_empty_convention():
    assert determinant([]) == 1
    assert determinant([[0, 2], [3, 4]]) == -6
    assert determinant([[0, 1, 0], [0, 0, 1], [1, 0, 0]]) == 1
    assert determinant([[1, 2], [2, 4]]) == 0
    with pytest.raises(ValueError):
        determinant([[1, 2]])


def test_general_dodgson_including_zero_and_signed_singular_layers():
    for values in product((-1, 0, 1), repeat=5):
        assert hankel_minor(values, 0, 3) == hankel3(*values)
        assert dodgson_sides(values, 0, 2)[0] == dodgson_sides(values, 0, 2)[1]
    rng = Random(20261005)
    for order in range(1, 6):
        for _ in range(100):
            values = [rng.randrange(-4, 5) for _ in range(2 * order + 1)]
            assert hankel_minor(values, 0, order + 1) == bareiss_hankel_minor(
                values, 0, order + 1
            )
            left, right = dodgson_sides(values, 0, order)
            assert left == right


def test_rank_one_multilinearity_has_only_zero_or_one_main_columns():
    for size in range(2, 6):
        u = [Fraction(i + 1, 3) for i in range(size)]
        v = [Fraction(2 * j + 1, 5) for j in range(size)]
        error = [
            [Fraction((i + 2) * (j + 3), 7) + (i == j) for j in range(size)]
            for i in range(size)
        ]
        main = [[u[i] * v[j] for j in range(size)] for i in range(size)]
        expanded = Fraction(0)
        for main_columns in product((False, True), repeat=size):
            term = determinant([
                [main[i][j] if main_columns[j] else error[i][j] for j in range(size)]
                for i in range(size)
            ])
            if sum(main_columns) >= 2:
                assert term == 0
            expanded += term
        assert expanded == determinant([
            [main[i][j] + error[i][j] for j in range(size)] for i in range(size)
        ])


@pytest.mark.parametrize(
    ("gamma", "expected"),
    [(-4, 2), (Fraction(-1, 10), 2), (0, 3), (Fraction(1, 3), 3),
     (Fraction(1, 2), 4), (Fraction(2, 3), 5), (Fraction(3, 4), 6),
     (Fraction(7, 10), 5), (Fraction(99, 100), 102)],
)
def test_exact_strict_threshold_and_minimal_size(gamma, expected):
    size = admissible_hankel_size(gamma)
    assert size == expected
    assert hankel_exponent(gamma, size) < 0
    if size > 2:
        assert hankel_exponent(gamma, size - 1) >= 0


def test_all_reciprocal_integer_thresholds_are_strict():
    for m in range(1, 21):
        gamma = 1 - Fraction(1, m)
        assert hankel_exponent(gamma, m + 1) == 0
        assert admissible_hankel_size(gamma) == m + 2
    for gamma in (1, 2):
        with pytest.raises(ValueError):
            admissible_hankel_size(gamma)


def test_integer_boundary_gamma_zero_lucas_layer_stays_nonzero():
    values = extend_recurrence([2, 1], [1, 1], 40)
    for n in range(30):
        assert hankel_minor(values, n, 2) == 5 * (-1) ** n
        assert hankel_minor(values, n, 3) == 0


def test_integer_boundary_gamma_half_cubic_trace_layer_stays_nonzero():
    values = extend_recurrence([3, 3, 9], [1, 0, 3], 40)
    for n in range(30):
        assert hankel_minor(values, n, 3) == -135
        assert hankel_minor(values, n, 4) == 0
        assert recurrence_coefficients(values, n, 3) == (1, 0, 3)


def test_rational_rank_one_boundary_control_for_every_sampled_m():
    # Sum of powers of 2^m and the m scaled roots of unity; no floating point.
    for m in range(1, 7):
        size = m + 1
        values = [
            Fraction(2 ** (m * n)) + (Fraction(m, 2 ** n) if n % m == 0 else 0)
            for n in range(2 * m + 16)
        ]
        initial = hankel_minor(values, 0, size)
        assert initial != 0
        for n in range(8):
            assert hankel_minor(values, n, size) == initial * (-1) ** ((m - 1) * n)
            assert hankel_minor(values, n, size + 1) == 0


@pytest.mark.parametrize(
    ("initial", "coefficients"),
    [([1], [2]), ([2, 1], [1, 1]), ([0, 1], [-1, 0]),
     ([1, 4], [-4, 4]), ([3, 3, 9], [1, 0, 3]),
     ([1, 8, 36], [8, -12, 6]), ([4, 17, 87, 503], [-210, 247, -101, 17])],
)
def test_overlap_coefficients_are_stable_and_det_ratio_matches(initial, coefficients):
    order = len(coefficients)
    values = extend_recurrence(initial, coefficients, 35)
    for n in range(20):
        pivot = hankel_minor(values, n, order)
        assert pivot != 0
        assert hankel_minor(values, n, order + 1) == 0
        assert recurrence_coefficients(values, n, order) == tuple(coefficients)
        assert hankel_minor(values, n + 1, order) == (
            (-1) ** (order - 1) * coefficients[0] * pivot
        )
    assert not any(recurrence_residuals(values, coefficients))


def test_singular_lower_layer_requires_descent_instead_of_division():
    values = [2 ** n for n in range(20)]
    assert hankel_minor(values, 0, 3) == hankel_minor(values, 0, 2) == 0
    with pytest.raises(ValueError, match="singular lower"):
        recurrence_coefficients(values, 0, 2)
    assert recurrence_coefficients(values, 0, 1) == (2,)
    # A nonzero left-edge entry may disappear in the zero-tail descent case.
    zero_tail = [5] + [0] * 10
    assert all(hankel_minor(zero_tail, n, 2) == 0 for n in range(9))
    assert zero_tail[0] != 0 and not any(recurrence_residuals(zero_tail, (), 1))


def test_sparse_vanishing_shifts_do_not_meet_the_bridge_hypothesis():
    values = [0 if n % 2 == 0 else 2 ** (((n - 1) // 2) ** 2) for n in range(25)]
    for n in range(20):
        minor = hankel_minor(values, n, 3)
        assert (minor == 0) == (n % 2 == 0)
    # At an even shift D_2 != 0 and D_3 == 0 can produce a local candidate.
    # Its failure at later equations is precisely why all shifts are required.
    coefficients = recurrence_coefficients(values, 0, 2)
    assert any(recurrence_residuals(values, coefficients))


def test_a_prefix_candidate_does_not_certify_its_unseen_extension():
    observed = [2 ** n for n in range(10)]
    coefficients = recurrence_coefficients(observed, 0, 1)
    assert not any(recurrence_residuals(observed, coefficients))
    extended = observed + [2 ** 10 + 1]
    assert recurrence_residuals(extended, coefficients)[-1] == 1
    with pytest.raises(ValueError, match="next Hankel layer"):
        recurrence_coefficients(extended, 8, 1)


def test_exact_rational_inputs_and_validation():
    values = [Fraction(2, 3) ** n for n in range(10)]
    assert recurrence_coefficients(values, 0, 1) == (Fraction(2, 3),)
    # Even an integer window can have noninteger local coefficients. The
    # lattice proof requires an infinite integer tail, not just this window.
    assert recurrence_coefficients([9, 6, 4], 0, 1) == (Fraction(2, 3),)
    with pytest.raises(ValueError):
        hankel_minor([1], 0, 2)
    with pytest.raises(ValueError):
        recurrence_coefficients([1, 2], 0, 1)
    with pytest.raises(ValueError):
        hankel_minor([1, 2, 3], -1, 1)
    with pytest.raises(TypeError):
        admissible_hankel_size("0.5")
