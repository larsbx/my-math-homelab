"""The three-valued classifier: what each verdict is allowed to mean.

Soundness is the whole point, so the cases below are about the certificates
rather than about any picture: a verdict must survive refinement, a trap must
be verified before it is trusted, and `UNKNOWN` must carry nothing.
"""

from __future__ import annotations

from fractions import Fraction as F

import pytest

from box_classifier import (
    BoxVerdict,
    census,
    classify,
    escape_bound_quadrance,
    escapes,
    grid,
    is_trap,
    step,
    trap_candidate,
)
from interval_box import ComplexBox

C0 = ComplexBox.singleton(0)
C_BASILICA = ComplexBox.singleton(-1)
C_DENDRITE = ComplexBox.singleton(0, 1)
C_CAULIFLOWER = ComplexBox.singleton(F(1, 4))

TRAP_C0 = ComplexBox.of(F(-1, 4), F(1, 4), F(-1, 4), F(1, 4))
TRAP_BASILICA = ComplexBox.of(F(-1, 8), F(1, 8), F(-1, 8), F(1, 8))


def test_a_trap_is_forward_invariant():
    """The certificate's content: once inside, the image stays inside."""
    image = TRAP_C0
    for _ in range(8):
        image = step(image, C0)
        assert image.subset_of(TRAP_C0)


@pytest.mark.parametrize("trap,c,period", [(TRAP_C0, C0, 1), (TRAP_BASILICA, C_BASILICA, 2)])
def test_the_pinned_traps_verify(trap, c, period):
    assert is_trap(trap, c, period)


def test_a_trap_needs_strict_containment():
    """`f(B) = B` is not a trap: equality leaves no room and certifies nothing."""
    unit = ComplexBox.of(F(-1), F(1), F(-1), F(1))
    assert not is_trap(unit, C0, 1)


@pytest.mark.parametrize("period", [0, -1])
def test_a_nonpositive_period_is_refused(period):
    assert not is_trap(TRAP_C0, C0, period)


def test_the_parabolic_parameter_has_no_trap():
    """A parabolic basin has no strictly invariant box, and the classifier says
    so rather than inventing one: it is the fail-closed case, not a defect."""
    seed = ComplexBox.of(F(1, 4), F(3, 4), F(-1, 4), F(1, 4))
    assert trap_candidate(C_CAULIFLOWER, 1, seed) is None


def test_escape_is_tested_on_the_whole_box():
    """A box half past the bound does not escape; one entirely past it does."""
    straddling = ComplexBox.of(F(1), F(3), F(0), F(0))
    beyond = ComplexBox.of(F(5), F(6), F(0), F(0))
    assert escape_bound_quadrance(C0) == 4
    assert not escapes(straddling, C0)
    assert escapes(beyond, C0)


def test_an_unverified_trap_is_ignored_not_believed():
    """A wrong witness costs an UNKNOWN, never an IN."""
    fake = ComplexBox.of(F(-1), F(1), F(-1), F(1))
    result = classify(ComplexBox.of(F(-1, 16), F(1, 16), F(-1, 16), F(1, 16)), C0, fake, 1)
    assert result.verdict is not BoxVerdict.IN


@pytest.mark.parametrize(
    "box,c,trap,period,expected",
    [
        (ComplexBox.of(F(-1, 8), F(1, 8), F(-1, 8), F(1, 8)), C0, TRAP_C0, 1, BoxVerdict.IN),
        (ComplexBox.of(F(3), F(4), F(3), F(4)), C0, TRAP_C0, 1, BoxVerdict.OUT),
        (ComplexBox.of(F(15, 16), F(17, 16), F(0), F(1, 16)), C0, TRAP_C0, 1, BoxVerdict.UNKNOWN),
        (ComplexBox.of(F(-1, 16), F(1, 16), F(-1, 16), F(1, 16)), C_BASILICA, TRAP_BASILICA, 2, BoxVerdict.IN),
    ],
)
def test_known_boxes_get_the_expected_verdict(box, c, trap, period, expected):
    assert classify(box, c, trap, period).verdict is expected


@pytest.mark.parametrize("c,trap,period", [(C0, TRAP_C0, 1), (C_BASILICA, TRAP_BASILICA, 2)])
def test_a_decided_verdict_survives_refinement(c, trap, period):
    """Both certificates are inherited by sub-boxes, so refinement can turn an
    UNKNOWN into a decision but never a decision into something else."""
    for box in grid(F(2), 3):
        parent = classify(box, c, trap, period)
        if not parent.decided():
            continue
        for quarter in box.quarters():
            child = classify(quarter, c, trap, period)
            assert child.verdict is parent.verdict


def test_unknown_carries_nothing():
    result = classify(ComplexBox.of(F(15, 16), F(17, 16), F(0), F(1, 16)), C0, TRAP_C0, 1)
    assert result.verdict is BoxVerdict.UNKNOWN
    assert result.certificate is None and result.trap is None


def test_out_carries_a_certificate_and_in_carries_its_trap():
    out = classify(ComplexBox.of(F(3), F(4), F(3), F(4)), C0, TRAP_C0, 1)
    inside = classify(ComplexBox.of(F(-1, 8), F(1, 8), F(-1, 8), F(1, 8)), C0, TRAP_C0, 1)
    assert out.certificate is not None and out.certificate.valid()
    assert inside.trap is not None and is_trap(inside.trap, C0, 1)


def test_a_zero_horizon_decides_nothing():
    assert classify(ComplexBox.of(F(3), F(4), F(3), F(4)), C0, TRAP_C0, 1, horizon=0).verdict is BoxVerdict.UNKNOWN


def test_the_grid_tiles_the_square():
    boxes = grid(F(2), 2)
    assert len(boxes) == 16
    assert all(box.width() == 1 for box in boxes)


def test_an_empty_interior_is_never_certified_in():
    """`c = i` is a dendrite: no box can be trapped, and none is claimed."""
    result = census(C_DENDRITE, 3, None, 1, horizon=6)
    assert result.inside == 0 and result.out > 0 and result.unknown > 0


def test_the_residual_is_reported_not_hidden():
    """Every box lands in exactly one column, and the columns sum to the grid."""
    result = census(C0, 3, TRAP_C0, 1, horizon=6)
    assert result.total() == 64 and result.unknown > 0
