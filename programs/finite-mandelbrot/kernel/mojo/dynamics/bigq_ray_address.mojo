# Normalized BigZ-backed finite rational ray-address dynamics.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Addresses are exact symbolic fractions modulo one, not measured angles.
# Rejected Q values and values outside [0, 1) fail closed.
#
# The address is the vendored `rational_dynamics` ReducedFraction, and doubling
# and equality are its `double_mod_one` and `fraction_equal`. This module keeps
# only the address contract: the input is normalized as a `Q` first (so a
# negative denominator flips the sign, as before), and anything negative or at
# least one is refused before it becomes an address.

from finite_exact.bigint_z import BigZ, bigz_add, bigz_from_i64, bigz_mul
from finite_exact.rat_q import Q, q_from_bigz
from rational_dynamics.rational import (
    ReducedFraction,
    double_mod_one,
    fraction_equal,
    fraction_from_i64,
    reduce_fraction,
    rejected_fraction,
)


# Regime correspondence: rational-ray-address
struct BigQRayAddr(Copyable):
    var value: ReducedFraction
    var rejected: Bool

    def __init__(out self, value: ReducedFraction, rejected: Bool):
        self.value = value.copy()
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected and self.value.accepted()


struct BigQRayOrbitStatus(Copyable):
    var preperiod: Int
    var period: Int
    var arithmetic_rejected: Bool
    var orbit_verified: Bool

    def __init__(out self, preperiod: Int, period: Int, arithmetic_rejected: Bool, orbit_verified: Bool):
        self.preperiod = preperiod
        self.period = period
        self.arithmetic_rejected = arithmetic_rejected
        self.orbit_verified = orbit_verified

    def arithmetic_replay_accepted(self) -> Bool:
        return (
            not self.arithmetic_rejected and self.preperiod >= 0 and
            self.period >= 1 and self.orbit_verified
        )


def rejected_bigq_ray_addr() -> BigQRayAddr:
    return BigQRayAddr(rejected_fraction(), True)


def make_bigq_ray_addr(num: BigZ, den: BigZ) -> BigQRayAddr:
    var value = q_from_bigz(num, den)
    if value.rejected or value.num.sign < 0 or not value.lt(Q.one()):
        return rejected_bigq_ray_addr()
    var address = reduce_fraction(value.num, value.den)
    if address.rejected:
        return rejected_bigq_ray_addr()
    return BigQRayAddr(address, False)


def bigq_ray_addr_equal(a: BigQRayAddr, b: BigQRayAddr) -> Bool:
    return a.accepted() and b.accepted() and fraction_equal(a.value, b.value)


def bigq_double_ray_addr(address: BigQRayAddr) -> BigQRayAddr:
    if not address.accepted():
        return rejected_bigq_ray_addr()
    # On an address in [0, 1), doubling modulo one stays in [0, 1).
    var doubled = double_mod_one(address.value)
    if doubled.rejected:
        return rejected_bigq_ray_addr()
    return BigQRayAddr(doubled, False)


# Regime correspondence: rational-ray-address
def verify_bigq_one_half_orbit(num: BigZ, den: BigZ) -> BigQRayOrbitStatus:
    var start = make_bigq_ray_addr(num, den)
    var tail = bigq_double_ray_addr(start)
    var repeated = bigq_double_ray_addr(tail)
    var zero = make_bigq_ray_addr(bigz_from_i64(0), bigz_from_i64(1))
    if not start.accepted() or not tail.accepted() or not repeated.accepted() or not zero.accepted():
        return BigQRayOrbitStatus(1, 1, True, False)
    return BigQRayOrbitStatus(
        1, 1, False,
        fraction_equal(start.value, fraction_from_i64(1, 2)) and bigq_ray_addr_equal(tail, zero) and
        bigq_ray_addr_equal(repeated, tail),
    )


def bigq_ray_address_replay_smoke() -> Bool:
    var beyond_i64 = bigz_add(bigz_from_i64(9223372036854775807), bigz_from_i64(1))
    var orbit = verify_bigq_one_half_orbit(beyond_i64, bigz_mul(beyond_i64, bigz_from_i64(2)))
    var malformed = make_bigq_ray_addr(bigz_from_i64(1), bigz_from_i64(0))
    var out_of_range = make_bigq_ray_addr(bigz_from_i64(2), bigz_from_i64(2))
    return (
        orbit.arithmetic_replay_accepted() and orbit.preperiod == 1 and orbit.period == 1 and
        malformed.rejected and out_of_range.rejected
    )
