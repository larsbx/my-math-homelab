"""Every declared column of every corpus row, checked against exact arithmetic."""

import pytest

from julia_reference import OrbitVerdict, classify_multiplier, critical_orbit, is_cycle, multiplier
from box_classifier import is_trap
from closed_interval import ComplexBox
from gaussian_q import GQ
from markov import gaussian_pcf_parameters
from parameter_corpus import BY_KEY, CORPUS, TRAPS, J1Expectation, LocalConnectivity, Regime

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


@pytest.mark.parametrize("row", ROWS)
def test_every_escaping_verdict_carries_a_certificate(row):
    """An `ESCAPES` verdict is only as good as the reason behind it.

    The criterion in `kernel/julia_orbit.mojo` fires at `t > max(4, m)`, which is
    exactly where a rational growth ratio exists, so a verdict without a
    certificate would mean the two disagree.
    """
    orbit = critical_orbit(row.c)
    if orbit.verdict is OrbitVerdict.ESCAPES:
        assert orbit.certificate is not None and orbit.certificate.valid()
        assert orbit.certificate.ratio > 1
    else:
        assert orbit.certificate is None


@pytest.mark.parametrize("key", sorted(TRAPS))
def test_every_declared_trap_verifies(key):
    """A trap is a witness, and a witness that is not checked is a claim."""
    row = next(row for row in CORPUS if row.key == key)
    corners, period = TRAPS[key]
    assert is_trap(ComplexBox.of(*corners), ComplexBox.singleton(row.c.re, row.c.im), period)


def test_a_trap_is_declared_exactly_where_there_is_an_interior_to_trap():
    """A row with empty interior has nothing to trap, so a trap there would be
    a mistake. A row with an interior may have one, including the parabolic
    row: its petal is invariant without being strictly invariant, which is the
    case the certificate used to miss."""
    with_interior = {Regime.HYPERBOLIC_CENTER, Regime.PARABOLIC}
    for row in CORPUS:
        if row.key in TRAPS:
            assert row.regime in with_interior
    assert Regime.PARABOLIC in {BY_KEY[key].regime for key in TRAPS}


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


# --- completeness for the one property that has a classification -------------


def test_the_corpus_holds_every_postcritically_finite_parameter_of_q_i():
    """Both directions, against the theorem rather than against a count.

    Section 3.3 of `docs/tiling-connections-2026-09-20.md` classifies them:
    `c` in `Q(i)` has a finite critical orbit exactly for the five below. A
    corpus that held four of them was not wrong about any row, which is why
    nothing caught it until the classification existed. This is the check that
    would have.
    """
    classified = set(gaussian_pcf_parameters())
    present = {
        (row.c.re.numerator, row.c.im.numerator)
        for row in CORPUS
        if critical_orbit(row.c).verdict is OrbitVerdict.PREPERIODIC
    }
    assert present == classified
    assert all(
        row.c.re.denominator == 1 and row.c.im.denominator == 1
        for row in CORPUS
        if critical_orbit(row.c).verdict is OrbitVerdict.PREPERIODIC
    )


def conjugated(z: GQ) -> GQ:
    """`x - i y`. A helper here rather than a method, because nothing in the
    executable layer conjugates anything and an unused kernel is a liability."""
    return GQ.of(z.re, -z.im)


def test_the_conjugate_pair_carries_conjugate_witnesses():
    """`i` and `-i` are complex conjugates, so their cycles and multipliers
    are too. A row written by hand is a row that can drift from its twin."""
    dendrite, conjugate = BY_KEY["dendrite"], BY_KEY["dendrite_conjugate"]
    assert conjugate.c == conjugated(dendrite.c)
    assert {conjugated(z) for z in conjugate.cycle} == set(dendrite.cycle)
    assert multiplier(conjugate.cycle) == conjugated(multiplier(dendrite.cycle))
    assert conjugate.regime is dendrite.regime
    assert conjugate.orbit_signature == dendrite.orbit_signature
    assert conjugate.theorem_tag == dendrite.theorem_tag
