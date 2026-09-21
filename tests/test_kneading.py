"""Kneading data from the critical cut, and the pattern it lands on.

Statements: `docs/kneading-and-tuning.md`. Every constant pinned here is also
pinned by `kneading_smoke` in `src/kneading.mojo`, so the oracle and the
kernel agree on values and not merely on shapes -- and the kernel's copy goes
on to build the substitution with the vendored tuning layer, which is the
half of the bridge a Python test cannot reach.
"""

from __future__ import annotations

from fractions import Fraction as F

import pytest

import kneading
from interval_box import ComplexBox
from kneading import (
    CRITICAL_CUT,
    critical_itinerary,
    parity_twist,
    superattracting_period,
    tuning_prefix,
    tuning_substitution,
)
from separator import NEGATIVE, POSITIVE, UNDECIDED, side

#: `tests/substitution_dynamics/test_tuning.mojo` in `larsbx/finite-math-kernels`
#: pins these from combinatorics that never mention a Julia set.
PERIOD_DOUBLING_PREFIX = (1,)
PERIOD_DOUBLING_TWIST = True
PERIOD_DOUBLING_SUBSTITUTION = ((1, 1), (1, 0))


# --- section 1: the cut ---------------------------------------------------


def test_the_cut_is_the_vertical_one_and_not_the_real_axis():
    """A real iterate is off `x = 0` and on `y = 0`; that is the whole reason
    the ray certificates' cut decides nothing here."""
    real_point = ComplexBox.singleton(F(-1))
    assert side(CRITICAL_CUT, real_point) == NEGATIVE
    assert side(kneading.Cut.of(0, 1, 0), real_point) == UNDECIDED


def test_the_critical_point_is_on_the_cut():
    assert side(CRITICAL_CUT, ComplexBox.singleton(0)) == UNDECIDED


# --- section 2: the letter convention -------------------------------------


def test_the_left_side_is_one():
    assert kneading.LETTER == {NEGATIVE: 1, POSITIVE: 0}


def test_the_convention_reproduces_the_constant_pinned_upstream():
    """The test the convention would fail under the other choice.

    `f'(x) = 2x` is negative on the left, so the left step is the
    orientation-reversing one and the parity twist has to count it.
    """
    prefix = tuning_prefix(F(-1))
    assert prefix == PERIOD_DOUBLING_PREFIX
    assert parity_twist(prefix) is PERIOD_DOUBLING_TWIST
    assert tuning_substitution(prefix) == PERIOD_DOUBLING_SUBSTITUTION


def test_the_other_convention_would_not_reach_the_constant():
    """Stated as a failing case rather than as a sentence: reading the left
    side as `0` gives a different prefix and a different twist."""
    flipped = tuple(1 - letter for letter in tuning_prefix(F(-1)))
    assert flipped == (0,)
    assert parity_twist(flipped) is False
    assert tuning_substitution(flipped) != PERIOD_DOUBLING_SUBSTITUTION


# --- section 3: the theorem -----------------------------------------------


@pytest.mark.parametrize("c, period", [(F(0), 1), (F(-1), 2)])
def test_a_superattracting_parameter_is_decided_until_it_returns(c, period):
    """Decided at every step below the period, undecided at the period."""
    assert superattracting_period(c) == period
    assert critical_itinerary(c, period - 1) is not None
    assert critical_itinerary(c, period) is None


@pytest.mark.parametrize("c, expected", [(F(0), ()), (F(-1), (1,))])
def test_the_prefix_has_length_one_below_the_period(c, expected):
    assert tuning_prefix(c) == expected
    assert len(tuning_prefix(c)) == superattracting_period(c) - 1


def test_an_empty_prefix_is_not_a_pattern():
    """`c = 0` again: one point is not a structure, here as in the partition."""
    assert tuning_prefix(F(0)) == ()
    assert tuning_substitution(()) is None


@pytest.mark.parametrize("c", [F(-2), F(1, 4), F(-3, 4), F(-7, 4), F(1)])
def test_a_parameter_that_never_returns_has_no_prefix(c):
    assert superattracting_period(c) is None
    assert tuning_prefix(c) is None


# --- the itinerary beyond the five ----------------------------------------


@pytest.mark.parametrize(
    "c, word",
    [
        (F(-2), (1, 0, 0, 0, 0, 0, 0, 0)),
        (F(-7, 4), (1, 0, 1, 1, 0, 1, 1, 0)),
        (F(-3, 2), (1, 0, 1, 1, 1, 1, 1, 0)),
    ],
)
def test_measured_kneading_prefixes(c, word):
    assert critical_itinerary(c, len(word)) == word


def test_the_chebyshev_sequence_is_one_then_zeros():
    """`0, -2, 2, 2, ...`: one step left, then the fixed point on the right."""
    assert critical_itinerary(F(-2), 12) == (1,) + (0,) * 11


# --- fail-closed ----------------------------------------------------------


def test_a_word_with_a_gap_is_no_word():
    assert critical_itinerary(F(0), 1) is None
    assert critical_itinerary(F(-1), 2) is None


def test_a_negative_request_is_refused():
    assert critical_itinerary(F(-2), -1) is None


def test_a_zero_step_request_is_the_empty_word():
    assert critical_itinerary(F(-2), 0) == ()


def test_the_budget_refuses_rather_than_growing():
    """An escaping parameter outgrows the budget; it does not get a shorter
    word for it."""
    assert critical_itinerary(F(1), 40, bit_budget=64) is None


def test_the_parity_twist_counts_ones():
    assert parity_twist(()) is False
    assert parity_twist((1,)) is True
    assert parity_twist((1, 1)) is False
    assert parity_twist((1, 0, 1, 1)) is True
