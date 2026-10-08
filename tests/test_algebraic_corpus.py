"""The algebraic corpus: Julia parameters whose `c` is a root handle, not a rational.

The rabbit, co-rabbit, airplane and Kokopelli centres are irrational, so the
Gaussian-rational corpus cannot hold them. `reference/algebraic_corpus.py`
names each by an integer polynomial and a rational box, and every claim a row
makes is checked here: the polynomial is an exact-period Gleason factor, the
box isolates exactly one of its roots (Krawczyk-Moore, the accepted import
`KrawczykMooreUniqueness`), boxes on one polynomial are disjoint, declared
conjugates have conjugate boxes, and the declared trap is a trap at every
parameter in the box. Which component a box sits in is the ungated import
`ParameterRayLandingCorrespondence`; nothing checked here depends on it.
"""

from __future__ import annotations

import sys
from fractions import Fraction as F
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
for plane in ("vendor/python", "reference"):
    sys.path.insert(0, str(ROOT / plane))

import algebraic_corpus as ac  # noqa: E402
from closed_interval import ComplexBox  # noqa: E402

ROWS = ac.ALGEBRAIC_CORPUS
BY_KEY = {r.key: r for r in ROWS}


@pytest.mark.parametrize("row", ROWS, ids=[r.key for r in ROWS])
def test_row_checks(row: ac.AlgebraicParameter) -> None:
    assert ac.row_errors(row, ROWS) == []


def test_the_named_rows_are_present() -> None:
    assert set(BY_KEY) == {"rabbit", "co_rabbit", "airplane", "kokopelli", "kokopelli_conjugate"}
    assert BY_KEY["co_rabbit"].conjugate_of == "rabbit"
    assert BY_KEY["kokopelli_conjugate"].conjugate_of == "kokopelli"


def test_every_root_of_the_period_three_factor_is_a_row() -> None:
    """c^3 + 2c^2 + c + 1 has three roots; three disjoint isolating boxes account for all of them."""
    cubic = [r for r in ROWS if r.handle.polynomial == (1, 1, 2, 1)]
    assert len(cubic) == ac.degree(cubic[0].handle.polynomial) == 3


def test_gleason_exact_period() -> None:
    assert ac.exact_period_factor((1, 1, 2, 1), 3)
    assert ac.exact_period_factor((1, 0, 2, 3, 3, 3, 1), 4)
    assert not ac.exact_period_factor((1, 1), 3)  # c + 1 is period 2
    assert not ac.exact_period_factor((1, 1, 2, 1), 4)


def test_krawczyk_refuses_a_box_with_no_root_or_two() -> None:
    cubic = (1, 1, 2, 1)
    assert not ac.isolates(cubic, ComplexBox.of(F(1), F(2), F(1), F(2)))
    assert not ac.isolates(cubic, ComplexBox.of(F(-2), F(1), F(-1), F(1)))


@pytest.mark.parametrize(
    "change",
    [
        {"period": 4},
        {"polynomial": (1, 0, 2, 3, 3, 3, 1)},
        {"box": ComplexBox.of(F(1), F(2), F(1), F(2))},
        {"conjugate_of": "airplane"},
        {"trap": (ComplexBox.of(F(1), F(2), F(1), F(2)), 3)},
    ],
)
def test_corrupted_rows_are_refused(change: dict) -> None:
    row = BY_KEY["co_rabbit"]
    handle = row.handle
    if "polynomial" in change:
        handle = ac.RootHandle(change["polynomial"], handle.box)
    if "box" in change:
        handle = ac.RootHandle(handle.polynomial, change["box"])
    corrupted = ac.AlgebraicParameter(
        key=row.key, name=row.name, handle=handle, period=change.get("period", row.period),
        root_angles=row.root_angles, conjugate_of=change.get("conjugate_of", row.conjugate_of),
        trap=change.get("trap", row.trap), note=row.note,
    )
    assert ac.row_errors(corrupted, ROWS) != []


def test_root_angles_are_periodic_of_the_row_period() -> None:
    """The angle pair is the row's identification, through the ungated import
    `ParameterRayLandingCorrespondence`; what is checked is only that both angles
    have the row's exact period."""
    for row in ROWS:
        assert all(ac.angle_period(a) == row.period for a in row.root_angles), row.key


def test_bezout_certificates_cover_every_proper_divisor_and_check() -> None:
    for row in ROWS:
        certs = ac.period_certificates(row.handle.polynomial, row.period)
        assert [d for d, _ in certs] == [d for d in range(1, row.period) if row.period % d == 0]
        assert all(ac.certifies_coprime(row.handle.polynomial, ac.gleason(d), c) for d, c in certs)


def test_a_wrong_bezout_certificate_is_refused() -> None:
    cubic = (1, 1, 2, 1)
    a, b, n = ac.bezout_certificate(cubic, ac.gleason(1))
    assert ac.certifies_coprime(cubic, ac.gleason(1), (a, b, n))
    assert not ac.certifies_coprime(cubic, ac.gleason(1), (a, b, n + 1))
    assert not ac.certifies_coprime(cubic, ac.gleason(1), (a, b, 0))
    assert not ac.certifies_coprime((0, 1, 1), ac.gleason(1), (a, b, n))  # c(c + 1) shares the root 0


def test_identification_is_marked_ungated() -> None:
    """No gate of this repository covers parameter-ray correspondence; the rows must say so."""
    assert ac.IDENTIFICATION_TAG != "RationalRayLanding"
    assert ac.IDENTIFICATION_STATUS == "NOT_GATED"
