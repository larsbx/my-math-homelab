# julia_orbit.mojo
#
# Exact finite verdicts for f_c(z) = z^2 + c at a Gaussian-rational parameter.
# Specification: docs/rational-interval-arithmetic-spec.md.
#
# A Gaussian-rational parameter is a rank-2 singleton box: two exact rational
# coordinates, with polynomial operations and a quadrance scalar.
# No circle, disk, arc, or polar angle is available here, and the escape test
# is a quadrance compared against a rational bound rather than a radius: the
# vendored `quadratic_orbit.escape_criterion`, as is the multiplier
# trichotomy (`quadratic_orbit.multiplier_classification`) that the
# classification below refines.
#
# Every routine is a checker. It consumes a parameter and, where one is
# required, a witness, and returns what exact arithmetic decides. Nothing
# searches for a witness, and an exhausted budget returns CAPPED, which is a
# statement about the budget and not a classification.
#
# This is the Mojo side of a differential pair; reference/julia_reference.py is
# the Python side, and tests/test_mojo_replay.py compares the two.

from finite_exact.closed_interval import ComplexIQ, gaussian_singleton as gaussian_q
from quadratic_orbit.escape_criterion import escapes
from quadratic_orbit.multiplier_classification import MULTIPLIER_ATTRACTING, MULTIPLIER_INDIFFERENT, MULTIPLIER_REPELLING, multiplier_regime
from quadratic_orbit.orbit import orbit_term, quadratic_step, zero_box

alias ORBIT_ESCAPES = 0
alias ORBIT_PREPERIODIC = 1
alias ORBIT_CAPPED = 2

alias MULT_NONE = -1
alias MULT_SUPERATTRACTING = 0
alias MULT_ATTRACTING = 1
alias MULT_PARABOLIC = 2
alias MULT_IRRATIONALLY_INDIFFERENT = 3
alias MULT_REPELLING = 4


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
    if horizon < 1 or not c.is_singleton():
        return orbit_rejected()
    for n in range(horizon + 1):
        var z = orbit_term(zero_box(), c, n)
        if not z.accepted():
            return orbit_rejected()
        if escapes(z, c):
            return OrbitOutcome(ORBIT_ESCAPES, n, -1, -1, n, False)
        for first in range(n):
            if orbit_term(zero_box(), c, first).singleton_eq(z):
                return OrbitOutcome(ORBIT_PREPERIODIC, -1, first, n - first, n, False)
    return orbit_capped(horizon)


def is_cycle_of_length_one(c: ComplexIQ, z: ComplexIQ) -> Bool:
    return quadratic_step(z, c).singleton_eq(z)


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
    return (
        lam.singleton_eq(gaussian_q(1, 1, 0, 1)) or lam.singleton_eq(gaussian_q(-1, 1, 0, 1)) or
        lam.singleton_eq(gaussian_q(0, 1, 1, 1)) or lam.singleton_eq(gaussian_q(0, 1, -1, 1))
    )


def classify_multiplier(lam: ComplexIQ) -> Int:
    """Classify a Gaussian-rational multiplier exactly.

    The vendored trichotomy decides attracting, indifferent or repelling; zero
    is the superattracting case of the first, and the indifferent case splits
    by the dichotomy above, so parabolic versus irrationally indifferent needs
    no bound on the period. What the dichotomy does not decide is Siegel
    versus Cremer: that turns on the Brjuno condition for the rotation number,
    which is not a finite test on the multiplier. A box the trichotomy leaves
    undecided, and a refusal, classify as nothing (`MULT_NONE`).
    """
    var regime = multiplier_regime(lam)
    if regime == MULTIPLIER_ATTRACTING:
        return MULT_SUPERATTRACTING if lam.singleton_eq(gaussian_q(0, 1, 0, 1)) else MULT_ATTRACTING
    if regime == MULTIPLIER_REPELLING:
        return MULT_REPELLING
    if regime == MULTIPLIER_INDIFFERENT:
        return MULT_PARABOLIC if is_gaussian_root_of_unity(lam) else MULT_IRRATIONALLY_INDIFFERENT
    return MULT_NONE
