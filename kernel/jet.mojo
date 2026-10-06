# jet.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md, section 1.
# Statements: docs/preperiodic-certificates.md, section 4.
#
# Truncated Taylor jets over Q(i), exactly. A jet of order `m` at a point is
# the coefficient list of
#
#     g(w + e) = a_0 + a_1 e + ... + a_m e^m   (mod e^(m+1))
#
# Pushing the seed jet `(w, 1, 0, ..., 0)` through `z -> z^2 + c` gives every
# derivative of `f^n` at `w` at once, because truncated multiplication is a
# finite convolution and that is all the map needs. No polynomial in `z` is
# ever formed.
#
# The jet arithmetic is the vendored finite_polynomial.truncated_jet over
# ComplexBoxRing; every coefficient here is a singleton box, so it is exact
# over Q(i). This module keeps the quadratic family's own steps.
#
# This is the Mojo side of a differential pair; reference/jet.py is the Python
# side.

from finite_exact.closed_interval import ComplexIQ
from finite_exact.rat_q import Q
from finite_polynomial.coefficient_ring import ComplexBoxRing
from finite_polynomial.truncated_jet import (
    TruncatedJet,
    jet_add,
    jet_constant,
    jet_mul,
    jet_seed,
    jet_sub,
    jet_vanishing_order,
)

comptime Jet = TruncatedJet[ComplexBoxRing]


def jet_step(state: Jet, c: ComplexIQ) -> Jet:
    """`z^2 + c` on a jet."""
    return jet_add(jet_mul(state, state), jet_constant(ComplexBoxRing(), c, state.order()))


def jet_orbit(point: ComplexIQ, c: ComplexIQ, steps: Int, order: Int) -> Jet:
    """The jet of `f_c^steps` at `point`, to the stated order."""
    var state = jet_seed(ComplexBoxRing(), point, order)
    for _ in range(steps):
        state = jet_step(state, c)
    return state^


def jet_residual(point: ComplexIQ, c: ComplexIQ, preperiod: Int, period: Int, order: Int) -> Jet:
    """The jet of `R^c_{l,k} = f^(l+k) - f^l` at `point`."""
    return jet_sub(jet_orbit(point, c, preperiod + period, order), jet_orbit(point, c, preperiod, order))


def jet_smoke() -> Bool:
    """Multiplicities the Python side computes, recomputed here."""
    var c_zero = ComplexIQ.singleton(Q.zero(), Q.zero())
    var critical = ComplexIQ.singleton(Q.zero(), Q.zero())
    # c = 0, the critical point at type (1, 1): a double root.
    if jet_vanishing_order(jet_residual(critical, c_zero, 1, 1, 6)) != 2:
        return False
    # c = 0, the fixed point 1 at type (0, 1): simple.
    if jet_vanishing_order(jet_residual(ComplexIQ.singleton(Q(1, 1), Q.zero()), c_zero, 0, 1, 6)) != 1:
        return False
    # c = i, the Misiurewicz critical point at type (2, 2): a double root.
    var c_dendrite = ComplexIQ.singleton(Q.zero(), Q(1, 1))
    if jet_vanishing_order(jet_residual(critical, c_dendrite, 2, 2, 6)) != 2:
        return False
    # The parabolic cases the branching recursion refuses.
    var c_cusp = ComplexIQ.singleton(Q(1, 4), Q.zero())
    if jet_vanishing_order(jet_residual(ComplexIQ.singleton(Q(1, 2), Q.zero()), c_cusp, 0, 1, 6)) != 2:
        return False
    var c_minus = ComplexIQ.singleton(Q(-3, 4), Q.zero())
    if jet_vanishing_order(jet_residual(ComplexIQ.singleton(Q(-1, 2), Q.zero()), c_minus, 0, 2, 6)) != 3:
        return False
    # lambda = i gives c = 1/4 + i/2 and z0 = i/2.  The fourth
    # iterate is tangent to the identity to order q+1 = 5.
    var c_q4 = ComplexIQ.singleton(Q(1, 4), Q(1, 2))
    var z_q4 = ComplexIQ.singleton(Q.zero(), Q(1, 2))
    if jet_vanishing_order(jet_residual(z_q4, c_q4, 0, 4, 9)) != 5:
        return False
    # Order one is too low to see a double root, and says nothing rather than
    # zero.
    if jet_vanishing_order(jet_residual(critical, c_dendrite, 2, 2, 1)) != -1:
        return False
    # The first two coefficients are the value and the derivative.
    var point = ComplexIQ.singleton(Q(1, 3), Q.zero())
    var state = jet_orbit(point, c_zero, 2, 2)
    if not state.coeffs[0].re.lo.eq(Q(1, 81)):
        return False
    return state.coeffs[1].re.lo.eq(Q(4, 27))
