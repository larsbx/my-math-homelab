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
# This is the Mojo side of a differential pair; reference/taylor.py is the Python
# side.

from finite_exact.closed_interval import ComplexIQ, IQ
from finite_exact.rat_q import Q
from jet import jet_constant, jet_convolve, jet_is_zero, jet_seed, jet_zero


def taylor_zero_box() -> ComplexIQ:
    return ComplexIQ.singleton(Q.zero(), Q.zero())


def taylor_refused() -> ComplexIQ:
    return ComplexIQ.singleton(Q(1, 0), Q(1, 0))


def box_power(box: ComplexIQ, exponent: Int) -> ComplexIQ:
    """`box^exponent` by repeated squaring, with the sharp square.

    Not `box * box`: a product treats its two arguments as independent, so
    `X * X` is wider than `X^2` -- specification section 2.5, one level down.
    """
    if exponent < 0 or not box.accepted():
        return taylor_refused()
    var result = ComplexIQ.singleton(Q(1, 1), Q.zero())
    var base = box.copy()
    var remaining = exponent
    while remaining > 0:
        if remaining % 2 == 1:
            result = result.mul(base)
        remaining = remaining // 2
        if remaining > 0:
            base = base.square()
    return result.copy()


def evaluate(coefficients: List[ComplexIQ], domain: ComplexIQ) -> ComplexIQ:
    """Enclose the polynomial over the domain, term by term.

    **Not** Horner. Horner is tighter where the variable occurs once; here it
    occurs in every term, and its nesting multiplies the same box by itself
    repeatedly. Term by term with sharp powers is tighter on a box centred at
    the origin, which is the only kind of domain a model has.
    """
    if not domain.accepted() or len(coefficients) == 0:
        return taylor_refused()
    var total = coefficients[0].copy()
    for degree in range(1, len(coefficients)):
        if not jet_is_zero(coefficients[degree]):
            total = total.add(coefficients[degree].mul(box_power(domain, degree)))
    return total.copy()


struct TaylorModel(Copyable):
    """`p` in the local variable, plus a remainder, over a domain."""

    var centre: ComplexIQ
    var domain: ComplexIQ
    var polynomial: List[ComplexIQ]
    var remainder: ComplexIQ

    def __init__(out self, centre: ComplexIQ, domain: ComplexIQ, polynomial: List[ComplexIQ], remainder: ComplexIQ):
        self.centre = centre.copy()
        self.domain = domain.copy()
        self.polynomial = polynomial.copy()
        self.remainder = remainder.copy()

    def order(self) -> Int:
        return len(self.polynomial) - 1

    def accepted(self) -> Bool:
        return self.domain.accepted() and self.remainder.accepted()

    def enclosure(self) -> ComplexIQ:
        """`Enc(p) + remainder`: the correlation was kept until this moment."""
        if not self.accepted():
            return taylor_refused()
        return evaluate(self.polynomial, self.domain).add(self.remainder)


def taylor_variable(centre: ComplexIQ, radius: Q, order: Int) -> TaylorModel:
    """The identity on the box of that radius around the centre, exactly."""
    var domain = ComplexIQ(IQ(radius.neg(), radius), IQ(radius.neg(), radius))
    return TaylorModel(centre, domain, jet_seed(centre, order), taylor_zero_box())


def taylor_step(model: TaylorModel, c: ComplexIQ) -> TaylorModel:
    """`z^2 + c` on a model.

    `(p + I)^2 = pq_low + [pq_high + 2 p I + I^2]`, and every term of the
    bracket is enclosed rather than dropped: the tail the truncation discards
    is added back as an interval.
    """
    if not (model.accepted() and c.accepted()):
        return TaylorModel(model.centre, taylor_refused(), model.polynomial, taylor_refused())
    var order = model.order()
    var full = jet_convolve(model.polynomial, model.polynomial)
    var low = List[ComplexIQ]()
    for index in range(order + 1):
        low.append(full[index].copy())
    var high = List[ComplexIQ]()
    for index in range(order + 1, len(full)):
        high.append(full[index].copy())

    var tail = taylor_zero_box()
    if len(high) > 0:
        tail = evaluate(high, model.domain).mul(box_power(model.domain, order + 1))
    var enclosed = evaluate(model.polynomial, model.domain)
    var cross = enclosed.mul(model.remainder)
    cross = cross.add(cross).add(model.remainder.mul(model.remainder))

    low[0] = low[0].add(c)
    return TaylorModel(model.centre, model.domain, low, tail.add(cross))


def taylor_orbit(model: TaylorModel, c: ComplexIQ, steps: Int) -> TaylorModel:
    var state = model.copy()
    for _ in range(steps):
        state = taylor_step(state, c)
    return state.copy()


def taylor_smoke() -> Bool:
    """The guarantee at a point, and the measured win over a plain enclosure."""
    var c = ComplexIQ.singleton(Q.zero(), Q.zero())
    var centre = ComplexIQ.singleton(Q(-1, 1), Q.zero())
    # The identity model is exact: zero remainder, and the enclosure is the box.
    var model = taylor_variable(centre, Q(1, 64), 3)
    if not jet_is_zero(model.remainder):
        return False
    # One step at c = 0 from -1: p = (1, -2, 1) exactly, so an order-3 model
    # truncates nothing and the remainder stays zero.
    var once = taylor_step(model, c)
    if not once.polynomial[0].re.lo.eq(Q(1, 1)):
        return False
    if not once.polynomial[1].re.lo.eq(Q(-2, 1)):
        return False
    if not once.polynomial[2].re.lo.eq(Q(1, 1)):
        return False
    if not jet_is_zero(once.remainder):
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
    var sharp = box_power(straddling, 2)
    var loose = straddling.mul(straddling)
    var tighter = sharp.subset_of(loose)
    if tighter.rejected or not tighter.value:
        return False
    var reverse = loose.subset_of(sharp)
    return not reverse.value
