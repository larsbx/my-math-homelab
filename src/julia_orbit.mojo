# julia_orbit.mojo
#
# Exact finite verdicts for f_c(z) = z^2 + c at a Gaussian-rational parameter.
# Specification: docs/rational-interval-arithmetic-spec.md.
#
# A Gaussian-rational parameter is a rank-2 singleton box: two exact rational
# coordinates, with polynomial operations and a quadrance scalar. No circle,
# disk, arc, or polar angle is available here, and the escape test is a
# quadrance compared against a rational bound rather than a radius.
#
# Every routine is a checker. It consumes a parameter and, where one is
# required, a witness, and returns what exact arithmetic decides. Nothing
# searches for a witness, and an exhausted budget returns CAPPED, which is a
# statement about the budget and not a classification.
#
# This is the Mojo side of a differential pair; tools/julia_reference.py is
# the Python side, and tests/test_mojo_replay.py compares the two.

from finite_exact.rat_q import Q, q_max
from finite_exact.closed_interval import ComplexIQ

alias ORBIT_ESCAPES = 0
alias ORBIT_PREPERIODIC = 1
alias ORBIT_CAPPED = 2

alias MULT_NONE = -1
alias MULT_SUPERATTRACTING = 0
alias MULT_ATTRACTING = 1
alias MULT_PARABOLIC = 2
alias MULT_IRRATIONALLY_INDIFFERENT = 3
alias MULT_REPELLING = 4


def gaussian_q(re_num: Int64, re_den: Int64, im_num: Int64, im_den: Int64) -> ComplexIQ:
    """A Gaussian-rational coordinate record as a rank-2 singleton box."""
    return ComplexIQ.singleton(Q(re_num, re_den), Q(im_num, im_den))


def is_singleton(z: ComplexIQ) -> Bool:
    if not z.accepted():
        return False
    return z.re.lo.eq(z.re.hi) and z.im.lo.eq(z.im.hi)


def singleton_eq(a: ComplexIQ, b: ComplexIQ) -> Bool:
    if not (is_singleton(a) and is_singleton(b)):
        return False
    return a.re.lo.eq(b.re.lo) and a.im.lo.eq(b.im.lo)


def julia_step(z: ComplexIQ, c: ComplexIQ) -> ComplexIQ:
    """`f_c(z) = z^2 + c`."""
    return z.square().add(c)


def escape_bound_quadrance(c: ComplexIQ) -> Q:
    """`max(4, N(c))`.

    The classical criterion is |z| > max(2, |c|). Squaring both sides keeps
    the test inside the rank-2 layer: no square root, and no radius.
    """
    var quadrance = c.quadrance()
    if not quadrance.accepted():
        return Q(0, 1)
    return q_max(Q(4, 1), quadrance.hi)


def escapes_at(z: ComplexIQ, c: ComplexIQ) -> Bool:
    """Does the whole box lie beyond the escape bound?

    The bound is compared against the lower endpoint of the quadrance, so a
    box that merely touches the bound does not certify escape.
    """
    var quadrance = z.quadrance()
    if not quadrance.accepted():
        return False
    return escape_bound_quadrance(c).lt(quadrance.lo)


struct OrbitOutcome(Copyable, Movable):
    """What a bounded exact run of the critical orbit established."""

    var kind: Int
    var escape_index: Int
    var preperiod: Int
    var period: Int
    var steps_taken: Int
    var rejected: Bool

    def __init__(out self, kind: Int, escape_index: Int, preperiod: Int, period: Int, steps_taken: Int, rejected: Bool):
        self.kind = kind
        self.escape_index = escape_index
        self.preperiod = preperiod
        self.period = period
        self.steps_taken = steps_taken
        self.rejected = rejected

    def decided(self) -> Bool:
        return (not self.rejected) and self.kind != ORBIT_CAPPED

    def is_preperiodic(self, preperiod: Int, period: Int) -> Bool:
        if not self.decided() or self.kind != ORBIT_PREPERIODIC:
            return False
        return self.preperiod == preperiod and self.period == period

    def escapes_at_index(self, index: Int) -> Bool:
        if not self.decided() or self.kind != ORBIT_ESCAPES:
            return False
        return self.escape_index == index

    def is_capped(self) -> Bool:
        return (not self.rejected) and self.kind == ORBIT_CAPPED


def orbit_capped(steps: Int) -> OrbitOutcome:
    return OrbitOutcome(ORBIT_CAPPED, -1, -1, -1, steps, False)


def orbit_rejected() -> OrbitOutcome:
    return OrbitOutcome(ORBIT_CAPPED, -1, -1, -1, -1, True)


def iterate_from_zero(c: ComplexIQ, steps: Int) -> ComplexIQ:
    """`z_steps`, recomputed from `z_0 = 0`. Allocation-free by construction."""
    var z = gaussian_q(0, 1, 0, 1)
    for _ in range(steps):
        z = julia_step(z, c)
    return z.copy()


def critical_orbit(c: ComplexIQ, horizon: Int) -> OrbitOutcome:
    """Run z_0 = 0, z_{n+1} = z_n^2 + c exactly for at most `horizon` steps.

    Exact arithmetic makes the repeat test an equality rather than a
    proximity test, so PREPERIODIC is a decided fact and not a tolerance. It
    is also why the horizon is a real budget: squaring doubles the coordinate
    size, so an orbit that neither escapes nor repeats costs O(2^n) digits at
    step n. Every parabolic and every irrationally indifferent parameter
    exhausts the budget by construction, and says so.

    Earlier terms are recomputed rather than stored. At these horizons the
    arithmetic is dominated by the size of the last term, and recomputation
    keeps the kernel allocation-free.
    """
    if horizon < 1 or not is_singleton(c):
        return orbit_rejected()
    for n in range(horizon + 1):
        var z = iterate_from_zero(c, n)
        if not z.accepted():
            return orbit_rejected()
        if escapes_at(z, c):
            return OrbitOutcome(ORBIT_ESCAPES, n, -1, -1, n, False)
        for first in range(n):
            if singleton_eq(iterate_from_zero(c, first), z):
                return OrbitOutcome(ORBIT_PREPERIODIC, -1, first, n - first, n, False)
    return orbit_capped(horizon)


def is_cycle_of_length_one(c: ComplexIQ, z: ComplexIQ) -> Bool:
    return singleton_eq(julia_step(z, c), z)


def multiplier_of_fixed_point(z: ComplexIQ) -> ComplexIQ:
    """`lam = f'(z) = 2z`, the one-cycle case of `lam = 2^k prod z_j`."""
    return z.add(z)


def multiplier_of_two_cycle(a: ComplexIQ, b: ComplexIQ) -> ComplexIQ:
    """`lam = 4 a b`."""
    var product = a.mul(b)
    return product.add(product).add(product.add(product))


def is_gaussian_root_of_unity(lam: ComplexIQ) -> Bool:
    """The rational multiplier dichotomy: a quadrance-1 element of Q(i) is a
    root of unity exactly when it is one of 1, -1, i, -i. See
    docs/julia-program-design-analysis-2026-09-19.md, section 6."""
    if singleton_eq(lam, gaussian_q(1, 1, 0, 1)):
        return True
    if singleton_eq(lam, gaussian_q(-1, 1, 0, 1)):
        return True
    if singleton_eq(lam, gaussian_q(0, 1, 1, 1)):
        return True
    return singleton_eq(lam, gaussian_q(0, 1, -1, 1))


def classify_multiplier(lam: ComplexIQ) -> Int:
    """Classify a Gaussian-rational multiplier exactly.

    The indifferent case splits by the dichotomy above, so parabolic versus
    irrationally indifferent needs no bound on the period. What the dichotomy
    does not decide is Siegel versus Cremer: that turns on the Brjuno
    condition for the rotation number, which is not a finite test on the
    multiplier.
    """
    if singleton_eq(lam, gaussian_q(0, 1, 0, 1)):
        return MULT_SUPERATTRACTING
    var quadrance = lam.quadrance()
    if not quadrance.accepted():
        return MULT_REPELLING
    var one = Q(1, 1)
    if quadrance.hi.lt(one):
        return MULT_ATTRACTING
    if one.lt(quadrance.lo):
        return MULT_REPELLING
    if is_gaussian_root_of_unity(lam):
        return MULT_PARABOLIC
    return MULT_IRRATIONALLY_INDIFFERENT
