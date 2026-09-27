"""Taylor models: the guarantee, and what it costs.

The statements are in `docs/taylor-models.md`. The soundness cases sample
points of the box and check their iterates against the enclosure, which is
what catches a soundness proof written down wrongly.
"""

from __future__ import annotations

import random
from fractions import Fraction as F

import pytest

import jet
import taylor
from box_classifier import step as box_step
from gaussian_q import GQ
from interval_box import ComplexBox
from julia_reference import step as point_step

CASES = [
    ("escaping", GQ.of(0), GQ(F(-1), F(17320508, 10000000)), F(1, 1000)),
    ("basilica", GQ.of(-1), GQ(F(1, 2), F(0)), F(1, 32)),
    ("repelling", GQ.of(0), GQ(F(-1), F(0)), F(1, 64)),
]


def holds(box: ComplexBox, z: GQ) -> bool:
    return box.re.lo <= z.re <= box.re.hi and box.im.lo <= z.im <= box.im.hi


@pytest.mark.parametrize("label,c,centre,radius", CASES, ids=[case[0] for case in CASES])
@pytest.mark.parametrize("order", [1, 2, 4])
def test_the_guarantee_holds_on_sampled_points(label, c, centre, radius, order):
    """Every point of the box has its iterates inside the enclosure."""
    rng = random.Random(len(label) * order)
    model = taylor.variable(centre, radius, order)
    for steps in range(1, 5):
        model = taylor.step(model, c)
        box = model.enclosure()
        for _ in range(12):
            offset = GQ(F(rng.randint(-8, 8), 8) * radius, F(rng.randint(-8, 8), 8) * radius)
            z = centre + offset
            for _ in range(steps):
                z = point_step(z, c)
            assert holds(box, z)


def test_the_identity_model_is_exact():
    model = taylor.variable(GQ(F(1, 3), F(0)), F(1, 8), 3)
    assert model.remainder.re.lo == model.remainder.re.hi == 0
    assert model.polynomial[0] == GQ(F(1, 3), F(0))
    assert model.polynomial[1] == GQ.of(1)
    assert all(coefficient.is_zero() for coefficient in model.polynomial[2:])


def test_one_step_at_a_high_enough_order_truncates_nothing():
    """`f(-1 + e) = 1 - 2e + e^2` exactly, so an order-three model keeps a
    zero remainder: nothing was dropped, so nothing had to be added back."""
    model = taylor.step(taylor.variable(GQ(F(-1), F(0)), F(1, 64), 3), GQ.of(0))
    assert model.polynomial[:3] == (GQ.of(1), GQ.of(-2), GQ.of(1))
    assert model.remainder.re.lo == model.remainder.re.hi == 0
    assert model.remainder.im.lo == model.remainder.im.hi == 0


def test_a_low_order_truncates_and_pays_for_it():
    """At order one the square term is dropped from the jet and appears in the
    remainder instead, which is the whole difference from `reference/jet.py`."""
    model = taylor.step(taylor.variable(GQ(F(-1), F(0)), F(1, 64), 1), GQ.of(0))
    assert model.polynomial == (GQ.of(1), GQ.of(-2))
    assert model.remainder.re.width() > 0


def test_powers_use_the_sharp_square():
    straddling = ComplexBox.of(F(-1, 8), F(1, 8), F(-1, 8), F(1, 8))
    sharp, loose = taylor.power(straddling, 2), straddling.mul(straddling)
    assert sharp.subset_of(loose) and not loose.subset_of(sharp)
    assert taylor.power(straddling, 0).re.lo == 1
    assert not taylor.power(straddling, -1).accepted()


def test_term_by_term_evaluation_beats_horner():
    """Section 3. Horner is the required form for a variable that occurs once
    and the wrong one for a polynomial over a centred box."""
    def horner(coefficients, domain):
        accumulated = taylor.singleton(coefficients[-1])
        for coefficient in reversed(coefficients[:-1]):
            accumulated = accumulated.mul(domain).add(taylor.singleton(coefficient))
        return accumulated

    for _, c, centre, radius in CASES:
        model = taylor.variable(centre, radius, 4)
        for _ in range(6):
            model = taylor.step(model, c)
        assert model.enclosure().re.width() <= horner(model.polynomial, model.domain).add(model.remainder).re.width()


@pytest.mark.parametrize("label,c,centre,radius,tighter", [
    ("escaping", GQ.of(0), GQ(F(-1), F(17320508, 10000000)), F(1, 1000), True),
    ("repelling", GQ.of(0), GQ(F(-1), F(0)), F(1, 64), False),
])
def test_the_measured_verdict_is_what_the_note_records(label, c, centre, radius, tighter):
    """Taylor models are not uniformly better, and the note says so. This pins
    both directions so the claim cannot quietly become a boast."""
    model = taylor.variable(centre, radius, 4)
    plain = ComplexBox.of(centre.re - radius, centre.re + radius, centre.im - radius, centre.im + radius)
    parameter = ComplexBox.singleton(c.re, c.im)
    for _ in range(6):
        model, plain = taylor.step(model, c), box_step(plain, parameter)
    assert (model.enclosure().re.width() < plain.re.width()) is tighter


def test_refusals_are_values():
    model = taylor.variable(GQ(F(0), F(0)), F(1, 8), 2)
    assert not taylor.orbit(model, GQ.of(0), -1).accepted()
    broken = taylor.TaylorModel(model.centre, ComplexBox.refused(), model.polynomial, ComplexBox.refused())
    assert not broken.accepted()
    assert not broken.enclosure().accepted()
    assert not taylor.add(broken, model).accepted()
    assert not taylor.mul(broken, model).accepted()
