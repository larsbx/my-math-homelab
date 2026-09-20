"""Preperiodic certificates, against the points they are about.

The statements are in `docs/preperiodic-certificates.md`. These cases check
the corpus witnesses, the two refusals the certificate has to make, and the
one thing the exclusion certificate must never do, which is claim something
about a box whose enclosure merely met the origin.
"""

from __future__ import annotations

import random
from fractions import Fraction as F

import pytest

from gaussian_q import GQ
from interval_box import ComplexBox
from julia_reference import step as point_step
from parameter_corpus import BY_KEY, PREPERIODIC
from preperiodic import (
    RootVerdict,
    certify,
    exact_type,
    excludes,
    isolates,
    krawczyk_image,
    midpoint,
    refine_until_certified,
    residual,
    residual_derivative,
    singleton_reciprocal,
)

WITNESSES = [
    (key, corners, l, k, label)
    for key, rows in PREPERIODIC.items()
    for corners, l, k, label in rows
]


def parameter(key: str) -> ComplexBox:
    row = BY_KEY[key]
    return ComplexBox.singleton(row.c.re, row.c.im)


@pytest.mark.parametrize("key,corners,l,k,label", WITNESSES, ids=[w[4] for w in WITNESSES])
def test_every_witness_isolates_a_root_of_exactly_its_type(key, corners, l, k, label):
    c, box = parameter(key), ComplexBox.of(*corners)
    assert certify(box, c, l, k).verdict is RootVerdict.ISOLATED
    assert exact_type(box, c, l, k), "a smaller type was not excluded"


@pytest.mark.parametrize("key,corners,l,k,label", WITNESSES, ids=[w[4] for w in WITNESSES])
def test_isolation_and_exclusion_are_mutually_exclusive(key, corners, l, k, label):
    c, box = parameter(key), ComplexBox.of(*corners)
    assert not excludes(box, c, l, k)


def test_a_rational_root_makes_the_residual_exactly_zero():
    """The certificate is about boxes, but where the root is a Gaussian
    rational the residual at the point is exactly zero, and the arithmetic
    says so without rounding."""
    c0 = ComplexBox.singleton(0)
    for point, l, k in ((F(1), 0, 1), (F(-1), 1, 1), (F(0), 0, 1)):
        singleton = ComplexBox.singleton(point)
        image = residual(singleton, c0, l, k)
        assert image.re.lo == image.re.hi == 0
        assert image.im.lo == image.im.hi == 0


def test_exclusion_is_a_proof_about_every_point_of_the_box():
    """Where the certificate excludes, sampled points really are not roots."""
    c = ComplexBox.singleton(0)
    box = ComplexBox.of(F(15, 8), F(17, 8), F(-1, 8), F(1, 8))
    assert excludes(box, c, 0, 1)
    rng = random.Random(11)
    for _ in range(200):
        z = GQ(
            F(rng.randint(120, 136), 64) + F(rng.randint(0, 7), 512),
            F(rng.randint(-8, 8), 64),
        )
        if not (box.re.lo <= z.re <= box.re.hi and box.im.lo <= z.im <= box.im.hi):
            continue
        assert point_step(z, GQ(F(0), F(0))) != z


def test_the_critical_point_is_never_isolable_above_preperiod_zero():
    """`R'(0) = 0` whenever `l >= 1`, because the chain rule puts the factor
    `2 f^0(0) = 0` in both products. At `c = i` the critical point has type
    (2, 2) and the certificate declines rather than guessing."""
    c = ComplexBox.singleton(0, 1)
    box = ComplexBox.of(F(-1, 16), F(1, 16), F(-1, 16), F(1, 16))
    derivative = residual_derivative(midpoint(box), c, 2, 2)
    assert derivative.re.lo == 0 and derivative.im.lo == 0
    assert not singleton_reciprocal(derivative).accepted()
    assert not isolates(box, c, 2, 2)
    assert not krawczyk_image(box, c, 2, 2).accepted()


@pytest.mark.parametrize("bad", [(-1, 1), (0, 0), (0, -2)])
def test_a_malformed_type_is_refused_as_a_value(bad):
    l, k = bad
    c = ComplexBox.singleton(0)
    box = ComplexBox.of(F(7, 8), F(9, 8), F(-1, 8), F(1, 8))
    assert not residual(box, c, l, k).accepted()
    assert not isolates(box, c, l, k)
    assert certify(box, c, l, k).verdict is RootVerdict.UNKNOWN


def test_refinement_decides_a_box_the_whole_of_which_no_single_certificate_can():
    """A box holding two roots decides neither certificate, and subdividing
    it reaches boxes that do. The budget is reported, never guessed past."""
    c = ComplexBox.singleton(0)
    both_roots = ComplexBox.of(F(-1, 4), F(5, 4), F(-1, 4), F(1, 4))
    assert certify(both_roots, c, 0, 1).verdict is RootVerdict.UNKNOWN
    assert refine_until_certified(both_roots, c, 0, 1, max_depth=0) == (both_roots,)
    assert len(refine_until_certified(both_roots, c, 0, 1, max_depth=4)) < 16


def test_wrapping_costs_resolution_and_refinement_buys_it_back():
    """The same point, the same type, two box sizes: the certificate is about
    the enclosure, so the wider one can fail where the narrower succeeds."""
    c = ComplexBox.singleton(0)
    wide = ComplexBox.of(F(7, 8), F(9, 8), F(-1, 8), F(1, 8))
    narrow = ComplexBox.of(F(63, 64), F(65, 64), F(-1, 64), F(1, 64))
    assert not isolates(wide, c, 1, 1)
    assert isolates(narrow, c, 1, 1)
