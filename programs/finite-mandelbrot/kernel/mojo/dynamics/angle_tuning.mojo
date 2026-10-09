# Exact tuning of a rational ray address by a hyperbolic component.
#
# Douady's tuning substitutes the binary expansion of an angle by the two
# root-ray blocks of a component. Let the component have root rays
# `theta_- < theta_+`, both of period `n`, and let `theta` be a periodic angle
# of period `q`. Write the `q` binary digits of `theta`; replace each `0` by
# the `n` digits of `theta_-` and each `1` by the `n` digits of `theta_+`. The
# resulting `n q` digits are the period of the tuned angle, so the tuned angle
# is that word read as an integer over `2^(n q) - 1`.
#
# This module is the Mojo-side derivation of the tuned angles that
# `C1_residual_directive_carrier` checks its star product against. Those
# instances used to appear there only as literals, computed elsewhere: the
# substitution side was executed here and the angle side was not, so the
# agreement of the two was asserted rather than derived. `tuned_angle` closes
# that: the smoke now tunes the angle and compares.
#
# Addresses are the vendored `rational_dynamics` `ReducedFraction` (upstream
# finite-math-kernels, exact over BigZ): `address` admits `Int64` input in
# `[0, 1)`, doubling is `double_mod_one`, equality `fraction_equal`, and the
# digits of an address are `rational_dynamics.doubling.binary_digits`. The
# tuned denominator `2^(n q) - 1` is refused unless `n q` stays inside
# `TUNING_PERIOD_LIMIT`; that bound is this module's contract, because callers
# read tuned addresses back as `Int64`. The period search is bounded by the
# same limit: refusing a period past it costs at most `TUNING_PERIOD_LIMIT`
# doublings, where the vendored uncapped order would have to finish its
# search first. There is no floating point and no measured angle here; these
# are finite symbolic addresses.
#
# Scope: tuning is an operation on addresses. It locates no parameter in the
# plane, and the landing of the tuned ray is the imported theorem tag, not a
# property computed here.

from finite_exact.bigint_z import BigZ, bigz_add, bigz_from_i64, bigz_lt, bigz_mul, bigz_sub
from rational_dynamics.doubling import binary_digits
from rational_dynamics.integers import bigz_is_even
from rational_dynamics.rational import (
    ReducedFraction,
    double_mod_one,
    fraction_equal,
    fraction_from_i64,
    reduce_fraction,
    rejected_fraction,
)

# `2^62 - 1` is the largest tuned denominator that fits `Int64`, so a period
# product beyond 62 is refused.
comptime TUNING_PERIOD_LIMIT = 62


struct BinaryBlock(Copyable, Movable):
    """The leading binary digits of an address, or a rejection."""

    var digits: List[Int]
    var rejected: Bool

    def __init__(out self, digits: List[Int], rejected: Bool):
        self.digits = digits.copy()
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected

    def length(self) -> Int:
        return len(self.digits)


def rejected_block() -> BinaryBlock:
    return BinaryBlock(List[Int](), True)


def address(num: Int64, den: Int64) -> ReducedFraction:
    """The reduced address `num/den`, refused outside `[0, 1)` or for a
    non-positive denominator."""
    if den <= 0 or num < 0 or num >= den:
        return rejected_fraction()
    return fraction_from_i64(num, den)


def address_period(start: ReducedFraction) -> Int:
    """Exact period of a periodic address under doubling modulo one, or `-1`.

    Refuses a rejected address, zero, an address whose reduced denominator is
    even (those are strictly preperiodic, not periodic), and a period beyond
    `TUNING_PERIOD_LIMIT`, after at most that many doublings."""
    if start.rejected or start.num.is_zero() or bigz_is_even(start.den):
        return -1
    var current = double_mod_one(start)
    for period in range(1, TUNING_PERIOD_LIMIT + 1):
        if fraction_equal(current, start):
            return period
        current = double_mod_one(current)
    return -1


def angle_period(num: Int64, den: Int64) -> Int:
    """`address_period` of `num/den`; refuses an address outside `(0, 1)`."""
    return address_period(address(num, den))


def address_block(t: ReducedFraction, length: Int) -> BinaryBlock:
    """The first `length` binary digits of an address: the vendored `binary_digits`."""
    var block = binary_digits(t, length)
    if block.rejected:
        return rejected_block()
    return BinaryBlock(block.digits, False)


def binary_block(num: Int64, den: Int64, length: Int) -> BinaryBlock:
    """The first `length` binary digits of `num/den`. Refuses a malformed
    address and a negative length."""
    return address_block(address(num, den), length)


def _digits_to_numerator(digits: List[Int]) -> BigZ:
    """Read a binary word as an integer, most significant digit first."""
    var value = bigz_from_i64(0)
    for i in range(len(digits)):
        value = bigz_add(bigz_add(value, value), bigz_from_i64(Int64(digits[i])))
    return value^


def _period_denominator(period: Int) -> BigZ:
    """`2^period - 1`, the denominator of an address of that exact period."""
    var power = bigz_from_i64(1)
    for _ in range(period):
        power = bigz_add(power, power)
    return bigz_sub(power, bigz_from_i64(1))


def _strictly_before(a: ReducedFraction, b: ReducedFraction) -> Bool:
    """`a < b` for two accepted reduced addresses, by exact cross multiplication."""
    if a.rejected or b.rejected:
        return False
    return bigz_lt(bigz_mul(a.num, b.den), bigz_mul(b.num, a.den))


def tuned_angle(
    root_minus_num: Int64,
    root_minus_den: Int64,
    root_plus_num: Int64,
    root_plus_den: Int64,
    num: Int64,
    den: Int64,
) -> ReducedFraction:
    """`theta` tuned by the component with root rays `theta_- < theta_+`.

    Refuses a root pair whose two periods disagree, a root pair that is not
    strictly ordered, a non-periodic argument, and a period product beyond
    `TUNING_PERIOD_LIMIT`. The result is a reduced address.

    The ordering is part of what a component is, and the substitution is not
    symmetric in the two rays: the lower ray supplies the block for a zero
    digit and the upper ray the block for a one. So an equal or swapped pair
    is malformed input, not a component read the other way round, and it is
    refused rather than silently tuned to a different address."""
    var lower_ray = address(root_minus_num, root_minus_den)
    var upper_ray = address(root_plus_num, root_plus_den)
    var root_period = address_period(lower_ray)
    if root_period < 1 or address_period(upper_ray) != root_period:
        return rejected_fraction()
    if not _strictly_before(lower_ray, upper_ray):
        return rejected_fraction()
    var theta = address(num, den)
    var angle_length = address_period(theta)
    if angle_length < 1:
        return rejected_fraction()
    if angle_length > TUNING_PERIOD_LIMIT // root_period:
        return rejected_fraction()

    var lower = address_block(lower_ray, root_period)
    var upper = address_block(upper_ray, root_period)
    var angle = address_block(theta, angle_length)
    if lower.rejected or upper.rejected or angle.rejected:
        return rejected_fraction()

    var word = List[Int]()
    for i in range(angle.length()):
        ref block = upper.digits if angle.digits[i] == 1 else lower.digits
        for j in range(len(block)):
            word.append(block[j])
    return reduce_fraction(_digits_to_numerator(word), _period_denominator(root_period * angle_length))


def tunes_to(
    root_minus_num: Int64,
    root_minus_den: Int64,
    root_plus_num: Int64,
    root_plus_den: Int64,
    num: Int64,
    den: Int64,
    expected_num: Int64,
    expected_den: Int64,
) -> Bool:
    """Whether tuning `num/den` by the given component yields `expected`."""
    return fraction_equal(
        tuned_angle(root_minus_num, root_minus_den, root_plus_num, root_plus_den, num, den),
        address(expected_num, expected_den),
    )


# --- non-claims ---------------------------------------------------------------


def tuning_locates_a_parameter() -> Bool:
    # Tuning maps addresses to addresses. Associating a parameter with the
    # tuned address needs a landing theorem tag and an adapter, not this.
    return False


# --- smoke ------------------------------------------------------------------------


def angle_tuning_smoke() -> Bool:
    # Periods under doubling: 1/3 has period two, 1/7 three, 7/15 four, 2/5 four.
    if angle_period(1, 3) != 2 or angle_period(1, 7) != 3:
        return False
    if angle_period(7, 15) != 4 or angle_period(2, 5) != 4:
        return False
    # A strictly preperiodic address has no period, and neither has 0 or 1.
    if angle_period(1, 2) != -1 or angle_period(1, 6) != -1:
        return False
    if angle_period(0, 1) != -1 or angle_period(1, 1) != -1 or angle_period(1, 0) != -1:
        return False

    # The root blocks the substitution uses.
    var one_third: List[Int] = [0, 1]
    var two_thirds: List[Int] = [1, 0]
    var one_seventh: List[Int] = [0, 0, 1]
    var seven_fifteenths: List[Int] = [0, 1, 1, 1]
    if binary_block(1, 3, 2).digits != one_third:
        return False
    if binary_block(2, 3, 2).digits != two_thirds:
        return False
    if binary_block(1, 7, 3).digits != one_seventh:
        return False
    if binary_block(7, 15, 4).digits != seven_fifteenths:
        return False
    if binary_block(1, 0, 2).accepted() or binary_block(1, 3, -1).accepted():
        return False

    # The tuned instances the residual directive carrier checks its star
    # product against, derived here rather than quoted: the doubling component
    # (1/3, 2/3), the rabbit (1/7, 2/7), and the primitive period-four
    # component (7/15, 8/15).
    if not tunes_to(1, 3, 2, 3, 1, 3, 2, 5):
        return False
    if not tunes_to(1, 3, 2, 3, 2, 5, 7, 17):
        return False
    if not tunes_to(7, 15, 8, 15, 1, 3, 8, 17):
        return False
    if not tunes_to(1, 7, 2, 7, 1, 3, 10, 63):
        return False
    if not tunes_to(1, 7, 2, 7, 3, 7, 82, 511):
        return False

    # Tuning by the doubling component fixes nothing and is not the identity.
    if tunes_to(1, 3, 2, 3, 1, 3, 1, 3):
        return False
    # Fail closed: an unordered root pair. The two rays are not
    # interchangeable, so a swapped pair would otherwise tune to a different
    # address (3/5 rather than 2/5) and an equal pair is not a component at
    # all.
    if tuned_angle(2, 3, 1, 3, 1, 3).accepted():
        return False
    if tuned_angle(1, 3, 1, 3, 1, 3).accepted():
        return False
    if tuned_angle(2, 7, 1, 7, 1, 3).accepted():
        return False
    # Fail closed: mismatched root periods, a non-periodic argument, and a
    # period product past the bound.
    if tuned_angle(1, 3, 1, 7, 1, 3).accepted():
        return False
    if tuned_angle(1, 3, 2, 3, 1, 6).accepted():
        return False
    if tuned_angle(1, 2047, 2, 2047, 1, 2047).accepted():
        return False
    return not tuning_locates_a_parameter()
