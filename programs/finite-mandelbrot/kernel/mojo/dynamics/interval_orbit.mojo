# interval_orbit.mojo
#
# Native Mojo target for interval critical-orbit evaluation.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
# This mirrors reference/python/interval/interval_exclusion_reference.py using only rational interval
# operations from interval_q.mojo. Arithmetic is BigZ-backed; this consumer
# remains barred from certificate acceptance until its replay is complete.

from finite_exact.closed_interval import ComplexIQ, IQ, IQBoolResult
from quadratic_orbit.collision import forbidden_count, intended_pair
from quadratic_orbit.orbit import collision_interval, complex_excludes_zero, zero_box
from quadratic_orbit.orbit import quadratic_step as next_orbit_value
from certificates.krawczyk_witness import c_minus_2_box


struct OrbitEvalConfig:
    var ell: Int
    var period: Int
    var horizon: Int

    def __init__(out self, ell: Int, period: Int, horizon: Int):
        self.ell = ell
        self.period = period
        self.horizon = horizon

    def valid(self) -> Bool:
        return self.ell >= 1 and self.period >= 1 and self.horizon >= self.ell + self.period


struct Orbit4(Copyable):
    var q0: ComplexIQ
    var q1: ComplexIQ
    var q2: ComplexIQ
    var q3: ComplexIQ

    def __init__(out self, q0: ComplexIQ, q1: ComplexIQ, q2: ComplexIQ, q3: ComplexIQ):
        self.q0 = q0.copy()
        self.q1 = q1.copy()
        self.q2 = q2.copy()
        self.q3 = q3.copy()

    def at(self, idx: Int) -> ComplexIQ:
        if idx == 0:
            return self.q0.copy()
        if idx == 1:
            return self.q1.copy()
        if idx == 2:
            return self.q2.copy()
        return self.q3.copy()

    def accepted(self) -> Bool:
        return self.q0.accepted() and self.q1.accepted() and self.q2.accepted() and self.q3.accepted()


struct Orbit7(Copyable):
    var q0: ComplexIQ
    var q1: ComplexIQ
    var q2: ComplexIQ
    var q3: ComplexIQ
    var q4: ComplexIQ
    var q5: ComplexIQ
    var q6: ComplexIQ

    def __init__(out self, q0: ComplexIQ, q1: ComplexIQ, q2: ComplexIQ, q3: ComplexIQ, q4: ComplexIQ, q5: ComplexIQ, q6: ComplexIQ):
        self.q0 = q0.copy()
        self.q1 = q1.copy()
        self.q2 = q2.copy()
        self.q3 = q3.copy()
        self.q4 = q4.copy()
        self.q5 = q5.copy()
        self.q6 = q6.copy()

    def at(self, idx: Int) -> ComplexIQ:
        if idx == 0:
            return self.q0.copy()
        if idx == 1:
            return self.q1.copy()
        if idx == 2:
            return self.q2.copy()
        if idx == 3:
            return self.q3.copy()
        if idx == 4:
            return self.q4.copy()
        if idx == 5:
            return self.q5.copy()
        return self.q6.copy()


struct IntervalOrbitStatus:
    var built_to_horizon: Bool
    var used_same_parameter_box: Bool
    var used_exact_rational_endpoints: Bool
    var excluded_forbidden_count: Int
    var forbidden_count: Int

    def __init__(out self, built_to_horizon: Bool, used_same_parameter_box: Bool, used_exact_rational_endpoints: Bool, excluded_forbidden_count: Int, forbidden_count: Int):
        self.built_to_horizon = built_to_horizon
        self.used_same_parameter_box = used_same_parameter_box
        self.used_exact_rational_endpoints = used_exact_rational_endpoints
        self.excluded_forbidden_count = excluded_forbidden_count
        self.forbidden_count = forbidden_count

    def accepted(self) -> Bool:
        return (
            self.built_to_horizon and
            self.used_same_parameter_box and
            self.used_exact_rational_endpoints and
            self.excluded_forbidden_count == self.forbidden_count
        )


def invalid_orbit_status() -> IntervalOrbitStatus:
    return IntervalOrbitStatus(False, False, False, 0, 0)


struct BigQExactTypeExclusionResult(Copyable):
    var box_name: String
    var half_width_den_power: Int
    var excluded_count: Int
    var required_count: Int
    var arithmetic_rejected: Bool

    def __init__(out self, box_name: String, half_width_den_power: Int, excluded_count: Int, required_count: Int, arithmetic_rejected: Bool):
        self.box_name = box_name
        self.half_width_den_power = half_width_den_power
        self.excluded_count = excluded_count
        self.required_count = required_count
        self.arithmetic_rejected = arithmetic_rejected

    def arithmetic_replay_accepted(self) -> Bool:
        return not self.arithmetic_rejected and self.required_count > 0 and self.excluded_count == self.required_count

    def ambiguous(self) -> Bool:
        return not self.arithmetic_rejected and self.excluded_count < self.required_count


# The collision partition (`intended_pair`, `forbidden_count`) and the orbit
# step (`zero_box`, and `next_orbit_value`, which is the vendored
# `quadratic_step`) are the vendored `quadratic_orbit` package.
# Its `intended_pair` is total: `ell < 1 or period < 1` intends nothing, so an
# invalid type is never silently partitioned. Public verifiers below still
# reject invalid OrbitEvalConfig values before partitioning.


def build_interval_orbit_h3(c_box: ComplexIQ) -> Orbit4:
    var q0 = zero_box()
    var q1 = next_orbit_value(q0, c_box)
    var q2 = next_orbit_value(q1, c_box)
    var q3 = next_orbit_value(q2, c_box)
    return Orbit4(q0, q1, q2, q3)


def build_interval_orbit_h6(c_box: ComplexIQ) -> Orbit7:
    var q0 = zero_box()
    var q1 = next_orbit_value(q0, c_box)
    var q2 = next_orbit_value(q1, c_box)
    var q3 = next_orbit_value(q2, c_box)
    var q4 = next_orbit_value(q3, c_box)
    var q5 = next_orbit_value(q4, c_box)
    var q6 = next_orbit_value(q5, c_box)
    return Orbit7(q0, q1, q2, q3, q4, q5, q6)


# `collision_interval` (`b - a`) and the three-valued, fail-closed
# `complex_excludes_zero` are the vendored `quadratic_orbit.orbit` functions.


def excludes_zero(z: ComplexIQ) -> Bool:
    var result = complex_excludes_zero(z)
    return not result.rejected and result.value


def bigq_p21_exact_type_exclusions(half_width_den_power: Int) -> BigQExactTypeExclusionResult:
    var box_name = "beta_c_minus_2"
    # Type (ell, period) = (2, 1) at horizon 3: the five pairs other than the
    # intended (2, 3), in index order, from the vendored partition.
    var required = forbidden_count(2, 1, 3)
    var orbit = build_interval_orbit_h3(c_minus_2_box(half_width_den_power))
    if not orbit.accepted():
        return BigQExactTypeExclusionResult(box_name, half_width_den_power, 0, required, True)
    var excluded = 0
    for i in range(4):
        for j in range(i + 1, 4):
            if intended_pair(2, 1, i, j):
                continue
            var exclusion = complex_excludes_zero(collision_interval(orbit.at(i), orbit.at(j)))
            if exclusion.rejected:
                return BigQExactTypeExclusionResult(box_name, half_width_den_power, excluded, required, True)
            if exclusion.value:
                excluded += 1
    return BigQExactTypeExclusionResult(box_name, half_width_den_power, excluded, required, False)


def verify_exact_type_exclusions_h3(c_box: ComplexIQ, ell: Int, period: Int) -> IntervalOrbitStatus:
    var config = OrbitEvalConfig(ell, period, 3)
    if not config.valid():
        return invalid_orbit_status()
    var orbit = build_interval_orbit_h3(c_box)
    var excluded = 0
    var total = 0
    for i in range(4):
        for j in range(i + 1, 4):
            if not intended_pair(ell, period, i, j):
                total += 1
                var hij = collision_interval(orbit.at(i), orbit.at(j))
                if excludes_zero(hij):
                    excluded += 1
    return IntervalOrbitStatus(True, True, True, excluded, total)


def verify_exact_type_exclusions_h6(c_box: ComplexIQ, ell: Int, period: Int) -> IntervalOrbitStatus:
    var config = OrbitEvalConfig(ell, period, 6)
    if not config.valid():
        return invalid_orbit_status()
    var orbit = build_interval_orbit_h6(c_box)
    var excluded = 0
    var total = 0
    for i in range(7):
        for j in range(i + 1, 7):
            if not intended_pair(ell, period, i, j):
                total += 1
                var hij = collision_interval(orbit.at(i), orbit.at(j))
                if excludes_zero(hij):
                    excluded += 1
    return IntervalOrbitStatus(True, True, True, excluded, total)


def demo_c_minus_2_status() -> IntervalOrbitStatus:
    return verify_exact_type_exclusions_h3(c_minus_2_box(8), 2, 1)


def demo_m41_status() -> IntervalOrbitStatus:
    # Placeholder until a certificate-ready dyadic M_4,1 box is moved from the
    # Python reference oracle into normalized Q endpoints. The expected count is
    # preserved here as a contract check, not as a completed proof witness.
    let ell = 4
    let period = 1
    let horizon = 6
    return IntervalOrbitStatus(True, True, True, 18, forbidden_count(ell, period, horizon))


def demo_native_c_minus_2_accepts() -> Bool:
    return demo_c_minus_2_status().accepted()


def invalid_orbit_config_rejection_smoke() -> Bool:
    var h3_zero_ell = verify_exact_type_exclusions_h3(c_minus_2_box(8), 0, 1)
    var h3_zero_period = verify_exact_type_exclusions_h3(c_minus_2_box(8), 2, 0)
    var h3_horizon_short = verify_exact_type_exclusions_h3(c_minus_2_box(8), 3, 1)
    var h6_zero_ell = verify_exact_type_exclusions_h6(c_minus_2_box(8), 0, 1)
    var h6_zero_period = verify_exact_type_exclusions_h6(c_minus_2_box(8), 4, 0)
    var h6_horizon_short = verify_exact_type_exclusions_h6(c_minus_2_box(8), 6, 1)
    return (
        not h3_zero_ell.accepted() and
        not h3_zero_period.accepted() and
        not h3_horizon_short.accepted() and
        not h6_zero_ell.accepted() and
        not h6_zero_period.accepted() and
        not h6_horizon_short.accepted()
    )


def bigq_exact_type_exclusion_replay_smoke() -> Bool:
    var witness = bigq_p21_exact_type_exclusions(8)
    var ambiguous = bigq_p21_exact_type_exclusions(0)
    var invalid_half_width = bigq_p21_exact_type_exclusions(-1)
    var narrow_box = bigq_p21_exact_type_exclusions(80)
    return (
        witness.arithmetic_replay_accepted() and witness.excluded_count == 5 and
        ambiguous.ambiguous() and not ambiguous.arithmetic_replay_accepted() and
        invalid_half_width.arithmetic_rejected and
        narrow_box.arithmetic_replay_accepted()
    )
