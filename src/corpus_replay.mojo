# corpus_replay.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md.
#
# The Mojo kernel, run against the generated corpus.
#
# Every row states the verdict the kernel must return. This file recomputes
# each verdict from src/julia_orbit.mojo and compares, and it prints the same
# verdicts as a transcript so tests/test_mojo_replay.py can compare them
# against tools/julia_reference.py. A row is checked twice, by two
# implementations, and neither one is allowed to be the reason the other is
# believed.

from finite_exact.closed_interval import ComplexIQ
from julia_orbit import (
    MULT_NONE,
    ORBIT_CAPPED,
    ORBIT_ESCAPES,
    ORBIT_PREPERIODIC,
    classify_multiplier,
    critical_orbit,
    is_cycle_of_length_one,
    multiplier_of_fixed_point,
    multiplier_of_two_cycle,
    singleton_eq,
)
from quadratic_orbit.orbit import quadratic_step
from parameter_corpus import CORPUS_SIZE, CorpusRow, MOJO_HORIZON, corpus_row


def cycle_is_valid(row: CorpusRow) -> Bool:
    """Is the declared witness an exact cycle of f_c with distinct elements?"""
    if row.cycle_length == 0:
        return True
    if row.cycle_length == 1:
        return is_cycle_of_length_one(row.c, row.cycle_a)
    if row.cycle_length != 2:
        return False
    if singleton_eq(row.cycle_a, row.cycle_b):
        return False
    if not singleton_eq(quadratic_step(row.cycle_a, row.c), row.cycle_b):
        return False
    return singleton_eq(quadratic_step(row.cycle_b, row.c), row.cycle_a)


def observed_multiplier_class(row: CorpusRow) -> Int:
    if row.cycle_length == 1:
        return classify_multiplier(multiplier_of_fixed_point(row.cycle_a))
    if row.cycle_length == 2:
        return classify_multiplier(multiplier_of_two_cycle(row.cycle_a, row.cycle_b))
    return MULT_NONE


def orbit_matches(row: CorpusRow) -> Bool:
    var outcome = critical_orbit(row.c, MOJO_HORIZON)
    if row.orbit_kind == ORBIT_ESCAPES:
        return outcome.escapes_at_index(row.orbit_index_a)
    if row.orbit_kind == ORBIT_PREPERIODIC:
        return outcome.is_preperiodic(row.orbit_index_a, row.orbit_index_b)
    return outcome.is_capped()


def row_replays(row: CorpusRow) -> Bool:
    if not cycle_is_valid(row):
        return False
    if observed_multiplier_class(row) != row.multiplier_class:
        return False
    return orbit_matches(row)


def orbit_kind_name(kind: Int) -> String:
    if kind == ORBIT_ESCAPES:
        return "ESCAPES"
    if kind == ORBIT_PREPERIODIC:
        return "PREPERIODIC"
    return "CAPPED"


def transcript_line(row: CorpusRow) -> String:
    """What the kernel decides, in the order tests/test_mojo_replay.py expects."""
    var outcome = critical_orbit(row.c, MOJO_HORIZON)
    var first = -1
    var second = -1
    if outcome.kind == ORBIT_ESCAPES and outcome.decided():
        first = outcome.escape_index
    elif outcome.kind == ORBIT_PREPERIODIC and outcome.decided():
        first = outcome.preperiod
        second = outcome.period
    var kind = ORBIT_CAPPED if not outcome.decided() else outcome.kind
    return (
        row.key
        + "\t"
        + orbit_kind_name(kind)
        + "\t"
        + String(first)
        + "\t"
        + String(second)
        + "\t"
        + String(observed_multiplier_class(row))
    )


def corpus_replay_smoke() -> Bool:
    """Every corpus row replays under the Mojo kernel."""
    for index in range(CORPUS_SIZE):
        if not row_replays(corpus_row(index)):
            return False
    return True


def rejected_configuration_smoke() -> Bool:
    """A non-positive horizon is rejected rather than answered."""
    var row = corpus_row(0)
    var outcome = critical_orbit(row.c, 0)
    return outcome.rejected and not outcome.decided()
