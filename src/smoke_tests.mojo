# smoke_tests.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md.
#
# Smoke-test harness for the finite-regime Julia computation layer.
#
# Each case is named after the contract it checks, and a name that is a
# governed term is used in the sense that term carries in
# docs/terminology-registry.md; naming a case asserts nothing beyond the
# verdict the case returned. Cases are independent and all of them run, so one
# failure does not hide the next.

from finite_exact.rat_q import Q, bigq_storage_smoke, demo_q_normalization, demo_q_order, q_cancellation_smoke
from finite_exact.closed_interval import bigq_interval_conformance_smoke, demo_complex_quadrance_point, demo_interval_mul
from corpus_replay import corpus_replay_smoke, rejected_configuration_smoke
from box_classifier import box_classifier_smoke
from escape_certificate import escape_certificate_smoke
from julia_orbit import (
    MULT_IRRATIONALLY_INDIFFERENT,
    MULT_PARABOLIC,
    MULT_REPELLING,
    classify_multiplier,
    escape_bound_quadrance,
    escapes_at,
    gaussian_q,
    is_gaussian_root_of_unity,
)
from mojo_smoke.report import SmokeReport, smoke_report_smoke


def escape_bound_smoke() -> Bool:
    """`max(4, N(c))`, and a box on the bound does not certify escape."""
    if not escape_bound_quadrance(gaussian_q(0, 1, 0, 1)).eq(Q(4, 1)):
        return False
    if not escape_bound_quadrance(gaussian_q(3, 1, 4, 1)).eq(Q(25, 1)):
        return False
    var c = gaussian_q(1, 1, 0, 1)
    if escapes_at(gaussian_q(2, 1, 0, 1), c):
        return False
    return escapes_at(gaussian_q(5, 1, 0, 1), c)


def multiplier_dichotomy_smoke() -> Bool:
    """A quadrance-1 Gaussian rational is parabolic exactly when it is one of
    the four roots of unity; (3 + 4i)/5 is the witness that the other case is
    not empty."""
    if not is_gaussian_root_of_unity(gaussian_q(0, 1, -1, 1)):
        return False
    var niven = gaussian_q(3, 5, 4, 5)
    if is_gaussian_root_of_unity(niven):
        return False
    if classify_multiplier(niven) != MULT_IRRATIONALLY_INDIFFERENT:
        return False
    if classify_multiplier(gaussian_q(0, 1, 1, 1)) != MULT_PARABOLIC:
        return False
    return classify_multiplier(gaussian_q(4, 1, 4, 1)) == MULT_REPELLING


def run_smoke_tests() -> Bool:
    var report = SmokeReport()
    _ = report.record("BigQ storage", bigq_storage_smoke())
    _ = report.record("Q normalization", demo_q_normalization())
    _ = report.record("Q order", demo_q_order())
    _ = report.record("Q cancellation", q_cancellation_smoke())
    _ = report.record("interval multiplication", demo_interval_mul())
    _ = report.record("complex quadrance", demo_complex_quadrance_point())
    _ = report.record("interval conformance", bigq_interval_conformance_smoke())
    _ = report.record("escape bound", escape_bound_smoke())
    _ = report.record("escape certificate", escape_certificate_smoke())
    _ = report.record("box classifier", box_classifier_smoke())
    _ = report.record("rational multiplier dichotomy", multiplier_dichotomy_smoke())
    _ = report.record("parameter corpus replay", corpus_replay_smoke())
    _ = report.record("rejected orbit configuration", rejected_configuration_smoke())
    _ = report.record("smoke reporter", smoke_report_smoke())
    report.print_summary("finite-regime Julia smoke suite")
    return report.all_passed()


def require_smoke_success(ok: Bool) raises:
    if not ok:
        raise Error("finite-regime Julia smoke tests: FAIL")


def main() raises:
    require_smoke_success(run_smoke_tests())
    print("finite-regime Julia smoke tests: PASS")
