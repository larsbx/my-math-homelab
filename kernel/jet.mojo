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
# This is the Mojo side of a differential pair; reference/jet.py is the Python
# side.

from finite_exact.closed_interval import ComplexIQ, IQ
from finite_exact.rat_q import Q
from quadratic_orbit.orbit import quadratic_step


def jet_zero() -> ComplexIQ:
    return ComplexIQ.singleton(Q.zero(), Q.zero())


def jet_constant(value: ComplexIQ, order: Int) -> List[ComplexIQ]:
    """`(value, 0, ..., 0)`: a jet that does not vary."""
    var out = List[ComplexIQ]()
    out.append(value.copy())
    for _ in range(order):
        out.append(jet_zero())
    return out^


def jet_seed(point: ComplexIQ, order: Int) -> List[ComplexIQ]:
    """`(point, 1, 0, ..., 0)`: the variable itself, expanded at `point`."""
    var out = List[ComplexIQ]()
    out.append(point.copy())
    if order >= 1:
        out.append(ComplexIQ.singleton(Q(1, 1), Q.zero()))
    for _ in range(order - 1):
        out.append(jet_zero())
    return out^


def jet_sub(left: List[ComplexIQ], right: List[ComplexIQ]) -> List[ComplexIQ]:
    var out = List[ComplexIQ]()
    for index in range(len(left)):
        out.append(left[index].sub(right[index]))
    return out^


def jet_convolve(left: List[ComplexIQ], right: List[ComplexIQ]) -> List[ComplexIQ]:
    """The full product. Nothing is dropped.

    `jet_mul` truncates it; a Taylor model keeps the tail as an interval
    instead, which is the whole difference between the two
    (`docs/taylor-models.md`).
    """
    var out = List[ComplexIQ]()
    for n in range(len(left) + len(right) - 1):
        var total = jet_zero()
        for i in range(len(left)):
            var j = n - i
            if j >= 0 and j < len(right):
                total = total.add(left[i].mul(right[j]))
        out.append(total.copy())
    return out^


def jet_mul(left: List[ComplexIQ], right: List[ComplexIQ]) -> List[ComplexIQ]:
    """Truncated convolution. Dropping is exact, not an approximation: the
    coefficients above the order are not part of the object."""
    var full = jet_convolve(left, right)
    var out = List[ComplexIQ]()
    for n in range(len(left)):
        out.append(full[n].copy())
    return out^


def jet_step(state: List[ComplexIQ], c: ComplexIQ) -> List[ComplexIQ]:
    """`z^2 + c` on a jet."""
    var squared = jet_mul(state, state)
    var out = List[ComplexIQ]()
    out.append(squared[0].add(c))
    for index in range(1, len(squared)):
        out.append(squared[index].copy())
    return out^


def jet_orbit(point: ComplexIQ, c: ComplexIQ, steps: Int, order: Int) -> List[ComplexIQ]:
    """The jet of `f_c^steps` at `point`, to the stated order."""
    var state = jet_seed(point, order)
    for _ in range(steps):
        state = jet_step(state, c)
    return state^


def jet_residual(point: ComplexIQ, c: ComplexIQ, preperiod: Int, period: Int, order: Int) -> List[ComplexIQ]:
    """The jet of `R^c_{l,k} = f^(l+k) - f^l` at `point`."""
    return jet_sub(jet_orbit(point, c, preperiod + period, order), jet_orbit(point, c, preperiod, order))


def jet_is_zero(value: ComplexIQ) -> Bool:
    if not value.accepted():
        return False
    return (
        value.re.lo.eq(Q.zero()) and value.re.hi.eq(Q.zero())
        and value.im.lo.eq(Q.zero()) and value.im.hi.eq(Q.zero())
    )


def jet_vanishing_order(state: List[ComplexIQ]) -> Int:
    """The least index with a nonzero coefficient, or `-1`.

    `-1` is a budget that ran out, never a multiplicity: a jet flat to the
    order computed says the order is *above* that and nothing more.
    """
    for index in range(len(state)):
        if not jet_is_zero(state[index]):
            return index
    return -1


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
    if not state[0].re.lo.eq(Q(1, 81)):
        return False
    return state[1].re.lo.eq(Q(4, 27))
