# taylor.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md, section 2.5.
# Statements: docs/taylor-models.md.
#
# A Taylor model: an exact jet in the local variable plus a rigorous interval
# remainder, over a box centred at the origin.
#
#     for every z = centre + e with e in domain,   g(z) in p(e) + remainder
#
# A plain enclosure treats every occurrence of a variable as independent, so
# widths inflate through an iterated map. A model carries the correlation in
# the jet and absorbs only what the truncation drops.
#
# The model and its arithmetic are the vendored finite_polynomial.taylor_model
# (Berz and Makino, 1998); this module keeps the quadratic family's own steps.
#
# This is the Mojo side of a differential pair; reference/taylor.py is the Python
# side.

from finite_exact.closed_interval import ComplexIQ, IQ
from finite_exact.rat_q import Q
from finite_polynomial import (
    TaylorModel,
    enclosure_power,
    taylor_add_constant,
    taylor_square,
)
from finite_polynomial import taylor_variable as box_variable
from finite_polynomial.coefficient_ring import ComplexBoxRing


def taylor_variable(centre: ComplexIQ, radius: Q, order: Int) -> TaylorModel:
    """The identity on the box of that radius around the centre, exactly."""
    return box_variable(centre, ComplexIQ(IQ(radius.neg(), radius), IQ(radius.neg(), radius)), order)


def taylor_step(model: TaylorModel, c: ComplexIQ) -> TaylorModel:
    """`z^2 + c` on a model: the square keeps the tail it truncates as a
    remainder, `(p + I)^2 = pp_low + [pp_high + 2 p I + I^2]`."""
    return taylor_add_constant(taylor_square(model), c)


def taylor_orbit(model: TaylorModel, c: ComplexIQ, steps: Int) -> TaylorModel:
    var state = model.copy()
    for _ in range(steps):
        state = taylor_step(state, c)
    return state^


def taylor_smoke() -> Bool:
    """The guarantee at a point, and the measured win over a plain enclosure."""
    var c = ComplexIQ.singleton(Q.zero(), Q.zero())
    var centre = ComplexIQ.singleton(Q(-1, 1), Q.zero())
    # The identity model is exact: zero remainder, and the enclosure is the box.
    var model = taylor_variable(centre, Q(1, 64), 3)
    if not ComplexBoxRing().is_zero(model.remainder):
        return False
    # One step at c = 0 from -1: p = (1, -2, 1) exactly, so an order-3 model
    # truncates nothing and the remainder stays zero.
    var once = taylor_step(model, c)
    if not once.polynomial.coeffs[0].re.lo.eq(Q(1, 1)):
        return False
    if not once.polynomial.coeffs[1].re.lo.eq(Q(-2, 1)):
        return False
    if not once.polynomial.coeffs[2].re.lo.eq(Q(1, 1)):
        return False
    if not ComplexBoxRing().is_zero(once.remainder):
        return False
    # The centre's own orbit is inside the enclosure at every step.
    var state = taylor_variable(centre, Q(1, 64), 3)
    var point = centre.copy()
    for _ in range(4):
        state = taylor_step(state, c)
        point = point.square().add(c)
        var box = state.enclosure()
        var inside = point.subset_of(box)
        if inside.rejected or not inside.value:
            return False
    # Powers use the sharp square: a box straddling both axes has a strictly
    # narrower square than product.
    var straddling = ComplexIQ(IQ(Q(-1, 8), Q(1, 8)), IQ(Q(-1, 8), Q(1, 8)))
    var sharp = enclosure_power(straddling, 2)
    var loose = straddling.mul(straddling)
    var tighter = sharp.subset_of(loose)
    if tighter.rejected or not tighter.value:
        return False
    var reverse = loose.subset_of(sharp)
    return not reverse.value
