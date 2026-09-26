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
    branching_multiplicity,
    certifies_all_roots,
    certify,
    enumerate_roots,
    exact_multiplicity,
    exact_residual_derivative,
    is_exact_root,
    exact_type,
    excludes,
    isolates,
    krawczyk_image,
    midpoint,
    refine_until_certified,
    residual,
    residual_derivative,
    search_box,
    search_radius,
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


# --- exactly representable roots -------------------------------------------

EXACT_CASES = [
    ("c=0, the critical point is a double root of its own residual", GQ(F(0), F(0)), GQ(F(0), F(0)), 1, 1, 2),
    ("c=0, the fixed point 1 is simple", GQ(F(1), F(0)), GQ(F(0), F(0)), 0, 1, 1),
    ("c=-1, the critical point is on the 2-cycle and simple there", GQ(F(0), F(0)), GQ(F(-1), F(0)), 0, 2, 1),
    ("c=i, the Misiurewicz critical point is a double root", GQ(F(0), F(0)), GQ(F(0), F(1)), 2, 2, 2),
]


@pytest.mark.parametrize("label,z,c,l,k,multiplicity", EXACT_CASES, ids=[case[0] for case in EXACT_CASES])
def test_a_named_root_is_decided_by_identity(label, z, c, l, k, multiplicity):
    """No enclosure, no contraction, no import: an identity over `Q(i)`."""
    assert is_exact_root(z, c, l, k)
    assert exact_multiplicity(z, c, l, k) == multiplicity


def test_the_critical_point_doubles_the_multiplicity_and_nothing_else_does():
    """`R_{l,k} = R_{l-1,k} . f`, and `f` is two-to-one only at `0`."""
    c = GQ(F(0), F(1))
    assert exact_multiplicity(GQ(F(0), F(0)), c, 2, 2) == 2
    # The image of the critical point has the same residual one step shorter,
    # at preperiod one, and is a simple root there.
    assert exact_multiplicity(point_step(GQ(F(0), F(0)), c), c, 1, 2) == 1


PARABOLIC = [
    ("c=1/4, multiplier one, one petal", GQ(F(1, 4), F(0)), GQ(F(1, 2), F(0)), 0, 1, 2),
    ("c=-3/4, multiplier minus one, two petals", GQ(F(-3, 4), F(0)), GQ(F(-1, 2), F(0)), 0, 2, 3),
    ("c=1/4+i/2, multiplier i, order-five fourth-iterate contact", GQ(F(1, 4), F(1, 2)), GQ(F(0), F(1, 2)), 0, 4, 5),
]


@pytest.mark.parametrize("label,c,fixed,l,k,multiplicity", PARABOLIC, ids=[case[0] for case in PARABOLIC])
def test_the_parabolic_case_the_recursion_refuses_is_answered_by_the_jet(label, c, fixed, l, k, multiplicity):
    """`R'` vanishes at a parabolic cycle, so the branching recursion has no
    base case and says so. The jet has no case analysis and answers."""
    assert is_exact_root(fixed, c, l, k)
    assert exact_residual_derivative(fixed, c, l, k).is_zero()
    assert branching_multiplicity(fixed, c, l, k) is None
    assert exact_multiplicity(fixed, c, l, k) == multiplicity


@pytest.mark.parametrize("label,z,c,l,k,multiplicity", EXACT_CASES, ids=[case[0] for case in EXACT_CASES])
def test_the_two_routes_agree_wherever_both_are_defined(label, z, c, l, k, multiplicity):
    """The recursion is the account and the jet is the computation. Where the
    account applies they have to give the same number, and do."""
    assert branching_multiplicity(z, c, l, k) == exact_multiplicity(z, c, l, k) == multiplicity


def test_a_flat_jet_is_a_budget_not_a_multiplicity():
    """Asked to too low an order, the jet says nothing rather than zero."""
    c, critical = GQ(F(0), F(1)), GQ(F(0), F(0))
    assert exact_multiplicity(critical, c, 2, 2, order=1) is None
    assert exact_multiplicity(critical, c, 2, 2, order=2) == 2


def test_a_point_that_is_not_a_root_has_no_multiplicity():
    c = GQ(F(0), F(0))
    assert not is_exact_root(GQ(F(2), F(0)), c, 0, 1)
    assert exact_multiplicity(GQ(F(2), F(0)), c, 0, 1) is None


# --- enumeration -----------------------------------------------------------

ENUMERATIONS = [
    ("c=0, the fixed points", GQ(F(0), F(0)), 0, 1, ()),
    ("c=0, preperiod one", GQ(F(0), F(0)), 1, 1, (GQ(F(0), F(0)),)),
    ("c=-1, the fixed points", GQ(F(-1), F(0)), 0, 1, ()),
    ("c=-1, period two", GQ(F(-1), F(0)), 0, 2, ()),
    ("c=i, the fixed points", GQ(F(0), F(1)), 0, 1, ()),
    ("c=i, period two", GQ(F(0), F(1)), 0, 2, ()),
]


@pytest.mark.parametrize("label,c,l,k,named", ENUMERATIONS, ids=[case[0] for case in ENUMERATIONS])
def test_every_root_is_accounted_for(label, c, l, k, named):
    box_c = ComplexBox.singleton(c.re, c.im)
    found = enumerate_roots(box_c, l, k)
    assert certifies_all_roots(found, box_c, named)
    assert len(found.isolated) + sum(
        exact_multiplicity(root, c, l, k) for root in named
    ) == found.degree()


def test_the_search_box_is_where_the_roots_have_to_be():
    """A preperiodic point has a bounded orbit, so its quadrance never passes
    the escape bound and both coordinates are inside the box."""
    for c, expected in ((ComplexBox.singleton(0), F(2)), (ComplexBox.singleton(-1), F(2))):
        assert search_radius(c) == expected
        box = search_box(c)
        assert box.re.lo == -expected and box.re.hi == expected


def test_an_exhausted_budget_is_reported_and_not_guessed_past():
    """A shallow search leaves clusters undecided, and the count refuses."""
    c = ComplexBox.singleton(0)
    shallow = enumerate_roots(c, 0, 1, max_depth=2)
    assert not certifies_all_roots(shallow, c)
    assert len(shallow.isolated) < shallow.degree()


def test_a_parameter_that_is_not_a_point_is_refused():
    wide = ComplexBox.of(F(-1, 16), F(1, 16), F(-1, 16), F(1, 16))
    found = enumerate_roots(wide, 0, 1, max_depth=3)
    assert not certifies_all_roots(found, wide)


def test_a_named_root_that_is_not_one_fails_the_count():
    c = ComplexBox.singleton(0)
    found = enumerate_roots(c, 0, 1)
    assert not certifies_all_roots(found, c, (GQ(F(2), F(0)),))
