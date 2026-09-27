"""The escape certificate: the polynomial identities, the branch trap, and the
growth it claims.

The certificate replaces an imported implication with a derived one, so the
cases below are about the derivation, not about any orbit: the two forms are
what the proof in `docs/escape-criterion.md` manipulates, and the branch trap
is a mistake the first draft of that proof actually made.
"""

from __future__ import annotations

import math
from fractions import Fraction as F

import pytest

from escape_certificate import (
    EscapeCertificate,
    best_ratio,
    certificate_holds,
    escape_certificate,
    growth_form,
    threshold_form,
)

SAMPLE = [(F(t, td), F(m, md)) for t in (9, 41, 97, 400) for td in (1, 4) for m in (0, 3, 37) for md in (1, 8)]


@pytest.mark.parametrize("t,m", SAMPLE)
@pytest.mark.parametrize("ratio", [F(1), F(9, 4), F(4), F(25, 16)])
def test_growth_form_is_the_square_free_rearrangement(t, m, ratio):
    assert growth_form(t, m, ratio) == (t * t + m - ratio * t) ** 2 - 4 * t * t * m


@pytest.mark.parametrize("t", [F(5), F(9), F(41, 7), F(100)])
@pytest.mark.parametrize("ratio", [F(1), F(9, 4), F(4), F(25, 16)])
def test_the_forms_meet_on_the_diagonal(t, ratio):
    """`G(t, t, r) = t^2 T(t, r)`: the worst parameter is `m = t`, and there the
    growth form is the threshold form."""
    assert growth_form(t, t, ratio) == t * t * threshold_form(t, ratio)


@pytest.mark.parametrize(
    "ratio,threshold",
    [(F(1), F(4)), (F(4), F(9)), (F(9), F(16)), (F(16), F(25))],
)
def test_the_threshold_is_the_square_of_one_plus_the_root(ratio, threshold):
    """`T` vanishes at `(sqrt(r) ± 1)^2`; for a square ratio both are rational."""
    assert threshold_form(threshold, ratio) == 0


def test_the_lower_branch_is_rejected():
    """`T > 0` holds on both sides of the parabola, and the lower side is false.

    `t = 163/31`, `m = 98/19`, `r = 263/19` satisfies `T > 0` and fails the
    claim; the first draft of the certificate omitted the vertex condition and
    accepted it. Random search found it in seconds, which is the argument for
    having this test at all.
    """
    t, m, ratio = F(163, 31), F(98, 19), F(263, 19)
    assert threshold_form(t, ratio) > 0
    assert not certificate_holds(t, m, ratio)
    worst_next = float(t) ** 2 - 2 * float(t) * math.sqrt(float(m)) + float(m)
    assert worst_next < float(ratio * t)


@pytest.mark.parametrize("t,m", [(F(5), F(4)), (F(9), F(4)), (F(100), F(1)), (F(401, 100), F(4))])
def test_a_certificate_claims_no_more_than_the_worst_phase_allows(t, m):
    """The claimed growth never exceeds `t^2 - 2 t sqrt(m) + m`, which is what
    the worst alignment of `c` against `z^2` actually leaves."""
    cert = escape_certificate(t, m)
    assert cert is not None and cert.valid()
    worst_next = float(t) ** 2 - 2 * float(t) * math.sqrt(float(m)) + float(m)
    assert float(cert.next_quadrance_bound()) <= worst_next + 1e-9


@pytest.mark.parametrize("t,m", [(F(5), F(4)), (F(9), F(4)), (F(37, 4), F(15, 8))])
def test_a_certificate_carries_its_own_successor(t, m):
    """One certificate covers the forward orbit: the hypotheses survive the step."""
    cert = escape_certificate(t, m)
    assert cert is not None
    for _ in range(6):
        cert = cert.successor()
        assert cert.valid()
        assert cert.quadrance > t


@pytest.mark.parametrize("t,m", [(F(4), F(4)), (F(4), F(0)), (F(3), F(1)), (F(1), F(1)), (F(0), F(0))])
def test_no_certificate_at_or_below_the_classical_threshold(t, m):
    """At `t = 4` the admissible ratios are empty, which is why the criterion in
    `kernel/julia_orbit.mojo` is a strict inequality."""
    assert escape_certificate(t, m) is None


def test_a_missing_certificate_is_not_a_claim_of_boundedness():
    """`c = 1/4` has a bounded critical orbit and no certificate; `c = 1` has an
    unbounded one whose early terms also have none. Absence says nothing."""
    assert escape_certificate(F(1, 16), F(1, 16)) is None
    assert escape_certificate(F(4), F(1)) is None


@pytest.mark.parametrize("t", [F(401, 100), F(41, 10), F(5), F(9), F(100)])
def test_every_quadrance_past_the_threshold_admits_a_ratio(t):
    """The admissible interval is `(1, (sqrt(t) - 1)^2)`, nonempty exactly when
    `t > 4`, so the classical threshold and the certificate agree on where they
    apply."""
    ratio = best_ratio(t, t)
    assert ratio is not None and ratio > 1
    assert certificate_holds(t, t, ratio)


@pytest.mark.parametrize("t", [F(9), F(16), F(25)])
def test_the_best_ratio_approaches_the_exact_bound(t):
    """For a square `t` the supremum is `(sqrt(t) - 1)^2` and bisection reaches it."""
    exact = (F(int(math.isqrt(int(t)))) - 1) ** 2
    ratio = best_ratio(t, F(0))
    assert ratio is not None and ratio <= exact
    assert exact - ratio <= F(1, 2 ** 20)


def test_a_hand_built_certificate_is_checked_not_believed():
    assert not EscapeCertificate(F(5), F(4), F(3)).valid()
    assert not EscapeCertificate(F(5), F(9), F(3, 2)).valid()
    assert EscapeCertificate(F(9), F(4), F(2)).valid()
