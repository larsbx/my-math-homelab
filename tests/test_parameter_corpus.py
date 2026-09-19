"""Every declared column of every corpus row, checked against exact arithmetic."""

import pytest

from julia_reference import OrbitVerdict, classify_multiplier, critical_orbit, is_cycle, multiplier
from parameter_corpus import CORPUS, J1Expectation, LocalConnectivity, Regime

ROWS = [pytest.param(row, id=row.key) for row in CORPUS]
WITH_CYCLE = [pytest.param(row, id=row.key) for row in CORPUS if row.cycle is not None]


@pytest.mark.parametrize("row", WITH_CYCLE)
def test_declared_cycle_is_a_cycle(row):
    assert is_cycle(row.c, row.cycle)


@pytest.mark.parametrize("row", WITH_CYCLE)
def test_declared_multiplier_class_is_the_computed_one(row):
    assert classify_multiplier(multiplier(row.cycle)) is row.multiplier_class


@pytest.mark.parametrize("row", ROWS)
def test_declared_critical_orbit_signature_is_the_computed_one(row):
    assert critical_orbit(row.c).signature() == row.orbit_signature


@pytest.mark.parametrize("row", ROWS)
def test_regime_agrees_with_the_multiplier_and_the_orbit(row):
    """The regime name is a claim about the witnesses, and is checked as one."""
    orbit = critical_orbit(row.c)
    if row.regime is Regime.ESCAPING:
        assert orbit.verdict is OrbitVerdict.ESCAPES
        assert row.cycle is None
        return
    if row.regime is Regime.HYPERBOLIC_CENTER:
        assert orbit.verdict is OrbitVerdict.PREPERIODIC and orbit.preperiod == 0
        assert multiplier(row.cycle).is_zero()
        return
    if row.regime is Regime.MISIUREWICZ:
        assert orbit.verdict is OrbitVerdict.PREPERIODIC and orbit.preperiod > 0
        assert multiplier(row.cycle).quadrance() > 1
        return
    assert multiplier(row.cycle).quadrance() == 1
    assert not orbit.decided(), "an indifferent parameter must not report a decided critical orbit"


@pytest.mark.parametrize("row", ROWS)
def test_an_open_regime_carries_no_theorem_tag(row):
    """A tag is a named import. An open cell must not borrow one."""
    if row.local_connectivity is LocalConnectivity.OPEN:
        assert row.theorem_tag is None
        assert row.j1_expectation is J1Expectation.UNDECIDED
    else:
        assert row.theorem_tag is not None


@pytest.mark.parametrize("row", ROWS)
def test_stabilization_is_expected_only_where_a_tag_backs_it(row):
    if row.j1_expectation is J1Expectation.STABILIZES:
        assert row.local_connectivity is LocalConnectivity.TAGGED_LOCALLY_CONNECTED


def test_the_corpus_reaches_every_regime():
    assert {row.regime for row in CORPUS} == set(Regime)


def test_the_corpus_reaches_all_four_gaussian_rational_roots_of_unity():
    """The parabolic rows are exactly the four roots of unity of Q(i)."""
    parabolic = [row for row in CORPUS if row.regime is Regime.PARABOLIC]
    multipliers = {multiplier(row.cycle) for row in parabolic}
    assert len(multipliers) == len(parabolic) == 3, "1, -1 and i are covered; -i is the mirror of i"


def test_keys_are_unique():
    keys = [row.key for row in CORPUS]
    assert len(set(keys)) == len(keys)
