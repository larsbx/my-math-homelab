"""The real Markov partition, its transition matrix, and the bridge it feeds.

Statements: `docs/tiling-connections-2026-09-20.md`. The cases that matter are
the ones a theorem there asserts -- the partition property of section 2.2, the
denominator growth of section 3.1, and the five-parameter classification of
section 3.3 -- plus the refusals, because a tool that answers for a parameter
with no finite critical orbit is worse than one that answers nothing.
"""

from __future__ import annotations

import random
import shutil
import subprocess
from fractions import Fraction as F
from pathlib import Path

import pytest

import markov
from gaussian_q import GQ
from julia_reference import OrbitVerdict, critical_orbit
from markov import (
    characteristic_polynomial,
    covering_row_block,
    evaluate,
    gaussian_pcf_parameters,
    growth_bracket,
    image,
    partition,
    postcritical_points,
)

ROOT = Path(__file__).resolve().parents[1]
TRANSCRIPT_DRIVER = ROOT / "src" / "markov_transcript.mojo"

#: The parameters the Mojo driver prints, in its order.
DRIVER_PARAMETERS = (F(0), F(-1), F(-2), F(1, 4), F(-3, 4), F(1))

#: The driver's step budget, declared by the driver.
MOJO_HORIZON = 64

PCF_REAL = (F(0), F(-1), F(-2))


# --- the postcritical set ---------------------------------------------------


@pytest.mark.parametrize(
    "c, expected",
    [(F(0), (F(0),)), (F(-1), (F(-1), F(0))), (F(-2), (F(-2), F(0), F(2)))],
)
def test_the_postcritical_set_is_what_the_orbit_says(c, expected):
    assert postcritical_points(c) == expected


@pytest.mark.parametrize("c", [F(1), F(1, 4), F(-3, 4), F(-7, 4), F(1, 2)])
def test_a_parameter_without_a_finite_orbit_gets_no_partition(c):
    assert postcritical_points(c) is None
    assert partition(c) is None


def test_the_horizon_refuses_rather_than_guessing():
    """One step is not enough to see the orbit of `-2` close."""
    assert postcritical_points(F(-2), horizon=1) is None


def test_a_single_point_is_not_a_partition():
    """`c = 0` has a one-point postcritical set: a fact, not a failure."""
    assert postcritical_points(F(0)) == (F(0),)
    assert partition(F(0)) is None


# --- section 2.2: the partition is Markov -----------------------------------


@pytest.mark.parametrize("c", [F(-1), F(-2)])
def test_zero_is_a_partition_point(c):
    assert F(0) in postcritical_points(c)


@pytest.mark.parametrize("c", [F(-1), F(-2)])
def test_each_image_endpoint_is_a_partition_point(c):
    part = partition(c)
    for lo, hi in part.intervals():
        for endpoint in image(c, lo, hi):
            assert endpoint in part.points


@pytest.mark.parametrize("c", [F(-1), F(-2)])
def test_each_image_is_exactly_the_union_of_the_intervals_it_covers(c):
    part = partition(c)
    pieces = part.intervals()
    for row, (lo, hi) in zip(part.matrix, pieces):
        covered = [piece for piece, bit in zip(pieces, row) if bit]
        assert covered, "a monotone image of a non-degenerate interval covers something"
        assert (covered[0][0], covered[-1][1]) == image(c, lo, hi)


@pytest.mark.parametrize("c", [F(-1), F(-2)])
def test_each_row_is_a_consecutive_block(c):
    for row in partition(c).matrix:
        assert covering_row_block(row) is not None


@pytest.mark.parametrize("c", [F(-1), F(-2)])
def test_the_union_of_the_intervals_is_forward_invariant(c):
    part = partition(c)
    low, high = part.points[0], part.points[-1]
    for lo, hi in part.intervals():
        left, right = image(c, lo, hi)
        assert low <= left and right <= high


@pytest.mark.parametrize(
    "c, matrix", [(F(-1), ((1,),)), (F(-2), ((1, 1), (1, 1)))]
)
def test_the_transition_matrix_is_what_the_note_records(c, matrix):
    assert partition(c).matrix == matrix


# --- the characteristic polynomial ------------------------------------------


def cubic_by_traces(matrix) -> tuple[F, ...]:
    """`det(x I - A)` for `3x3`, by the closed form `Mat3.charpoly` uses.

    An independent oracle: the same coefficients from traces and a determinant
    rather than from the Faddeev-LeVerrier recurrence.
    """
    def at(i, j):
        return F(matrix[i][j])

    trace = sum(at(i, i) for i in range(3))
    squared = sum(at(i, k) * at(k, i) for i in range(3) for k in range(3))
    determinant = sum(
        at(0, i) * (at(1, (i + 1) % 3) * at(2, (i + 2) % 3) - at(1, (i + 2) % 3) * at(2, (i + 1) % 3))
        for i in range(3)
    )
    return (-determinant, (trace * trace - squared) / 2, -trace, F(1))


def test_the_recurrence_agrees_with_the_closed_form_on_cubics():
    generator = random.Random(20260920)
    for _ in range(64):
        matrix = tuple(tuple(generator.randint(-3, 3) for _ in range(3)) for _ in range(3))
        assert characteristic_polynomial(matrix) == cubic_by_traces(matrix)


@pytest.mark.parametrize("size", [1, 2, 3, 4, 5])
def test_the_polynomial_is_monic_and_integral(size):
    generator = random.Random(size)
    matrix = tuple(tuple(generator.randint(0, 2) for _ in range(size)) for _ in range(size))
    coefficients = characteristic_polynomial(matrix)
    assert len(coefficients) == size + 1
    assert coefficients[-1] == 1
    assert all(coefficient.denominator == 1 for coefficient in coefficients)


@pytest.mark.parametrize("size", [1, 2, 3, 4])
def test_the_polynomial_vanishes_at_an_eigenvalue_the_matrix_declares(size):
    """A constant row sum is an eigenvalue, by the all-ones vector."""
    matrix = tuple(tuple(1 for _ in range(size)) for _ in range(size))
    assert evaluate(characteristic_polynomial(matrix), size) == 0


@pytest.mark.parametrize("c, expected", [(F(-1), (F(-1), F(1))), (F(-2), (F(0), F(-2), F(1)))])
def test_the_measured_polynomials(c, expected):
    assert characteristic_polynomial(partition(c).matrix) == expected


def entry_sum_of_power(matrix, power: int) -> int:
    """The number of admissible paths with `power` edges: note section 5."""
    size = len(matrix)
    current = [[1 if i == j else 0 for j in range(size)] for i in range(size)]
    for _ in range(power):
        current = [
            [sum(current[i][k] * matrix[k][j] for k in range(size)) for j in range(size)]
            for i in range(size)
        ]
    return sum(sum(row) for row in current)


@pytest.mark.parametrize("steps", range(6))
def test_the_path_count_at_the_chebyshev_parameter(steps):
    assert entry_sum_of_power(partition(F(-2)).matrix, steps) == 2 ** (steps + 1)


@pytest.mark.parametrize("steps", range(6))
def test_the_path_count_at_the_basilica_parameter(steps):
    assert entry_sum_of_power(partition(F(-1)).matrix, steps) == 1


def test_the_chebyshev_roots_are_zero_and_two():
    """Monic of degree two and vanishing at `0` and `2`, so those are all its
    roots and the largest is `2` -- which section 6 of the note reads, via the
    minimal polynomial `x - 2`, as a trivial Pisot number."""
    coefficients = characteristic_polynomial(partition(F(-2)).matrix)
    assert len(coefficients) == 3 and coefficients[-1] == 1
    assert evaluate(coefficients, 0) == 0
    assert evaluate(coefficients, 2) == 0


def test_the_basilica_root_is_one_and_so_is_not_a_pisot_candidate():
    """A Pisot number is above `1`; this root is `1`."""
    coefficients = characteristic_polynomial(partition(F(-1)).matrix)
    assert len(coefficients) == 2 and coefficients[-1] == 1
    assert evaluate(coefficients, 1) == 0


# --- the growth bracket -----------------------------------------------------


def test_the_bracket_is_a_sign_change_and_nothing_else():
    coefficients = characteristic_polynomial(((1, 1), (1, 0)))
    assert coefficients == (F(-1), F(-1), F(1))
    lo, hi = growth_bracket(coefficients)
    assert evaluate(coefficients, lo) * evaluate(coefficients, hi) <= 0
    assert lo <= F(1618034, 1000000) <= hi


def test_an_exact_root_is_returned_as_itself():
    lo, hi = growth_bracket(characteristic_polynomial(((1, 1), (1, 1))))
    assert lo <= 2 <= hi


def test_a_bracket_is_refused_where_no_sign_change_exists():
    assert growth_bracket((F(1), F(0), F(1))) is None


def test_the_bracket_narrows_when_asked_to():
    coefficients = characteristic_polynomial(((1, 1), (1, 0)))
    wide = growth_bracket(coefficients, width=F(1, 4))
    narrow = growth_bracket(coefficients, width=F(1, 1 << 30))
    assert narrow[1] - narrow[0] < wide[1] - wide[0]


# --- section 3: which parameters there are ----------------------------------


def test_the_gaussian_classification():
    assert gaussian_pcf_parameters() == ((-2, 0), (-1, 0), (0, -1), (0, 0), (0, 1))


@pytest.mark.parametrize("c", [F(1, 2), F(-3, 4), F(1, 3), F(-13, 16), F(5, 7)])
def test_a_denominator_above_one_squares_every_step(c):
    """Section 3.1, executed: the denominators double in exponent, so no
    orbit value can ever recur."""
    denominator, z = c.denominator, F(0)
    assert denominator > 1
    for step in range(1, 6):
        z = z * z + c
        assert z.denominator == denominator ** (2 ** (step - 1))


@pytest.mark.parametrize("c", [F(3), F(-3), F(5), F(-4)])
def test_a_large_parameter_escapes(c):
    """Section 3.2 on the line, where the quadrance is the square."""
    assert c * c > markov.PCF_QUADRANCE_BOUND
    assert postcritical_points(c) is None


# --- the budget, and the oracle it has to agree with -------------------------


@pytest.mark.parametrize(
    "value, budget, fits",
    [
        (F(10 ** 9 - 1), 1, True),
        (F(10 ** 9), 1, False),
        (F(-(10 ** 9)), 1, False),
        (F(1, 10 ** 9), 1, False),
        (F(10 ** 18 - 1), 2, True),
        (F(0), 1, True),
    ],
)
def test_the_budget_is_the_limb_count_bigz_would_store(value, budget, fits):
    """A `BigZ` limb is base `10^9`, which is what makes the budget the same
    quantity on both sides of the pair."""
    assert markov.within_limb_budget(value, budget) is fits


def test_the_budget_refuses_rather_than_growing():
    assert postcritical_points(F(1, 4), limb_budget=1) is None
    assert postcritical_points(F(1, 4), limb_budget=4096) is None


def test_the_budget_does_not_touch_a_parameter_that_closes():
    assert postcritical_points(F(-2), limb_budget=1) == (F(-2), F(0), F(2))


@pytest.mark.parametrize(
    "c", [F(0), F(-1), F(-2), F(1), F(2), F(-3), F(1, 4), F(-3, 4), F(-7, 4), F(1, 2), F(-13, 16)]
)
def test_the_partition_agrees_with_the_orbit_oracle(c):
    """`tools/markov.py` runs its own loop on the line; it must decide what
    `tools/julia_reference.py` decides over `Q(i)`."""
    finite = critical_orbit(GQ(c, F(0))).verdict is OrbitVerdict.PREPERIODIC
    assert (postcritical_points(c) is not None) == finite


# --- the differential pair --------------------------------------------------


def python_transcript() -> list[str]:
    return [markov.transcript_line(c, horizon=MOJO_HORIZON) for c in DRIVER_PARAMETERS]


def test_the_transcript_is_the_shape_the_driver_prints():
    lines = python_transcript()
    assert lines[0] == "c=0/1 none"
    assert lines[2].startswith("c=-2/1 points=-2/1,0/1,2/1 matrix=1111 poly=")
    assert all(line.startswith("c=") for line in lines)


@pytest.mark.skipif(shutil.which("mojo") is None, reason="no Mojo toolchain")
def test_the_kernel_and_the_oracle_print_the_same_transcript():
    result = subprocess.run(
        ["mojo", str(TRANSCRIPT_DRIVER)], capture_output=True, text=True, check=True, cwd=ROOT
    )
    assert result.stdout.splitlines() == python_transcript()
