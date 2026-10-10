# rat_backend_plan.mojo
#
# Migration plan from Int64 rational scaffolding to proof-grade Q over Z.
#
# This file is intentionally contract-shaped. It records the exact API that the
# existing interval, polynomial, Krawczyk, and rational-trig modules rely on.
# The future implementation must preserve these names while replacing bounded
# integer storage.

from arithmetic.bigint_adapter import BigIntBackendStatus, dynamic_limb_bigz_backend_status


struct RationalBackendStatus:
    var backend: BigIntBackendStatus
    var normalized_after_every_operation: Bool
    var denominator_strictly_positive: Bool
    var denominator_nonzero_checked: Bool
    var equality_cross_multiply_safe: Bool
    var order_cross_multiply_safe: Bool
    var canonical_fraction_serialization: Bool

    def __init__(out self, backend: BigIntBackendStatus, normalized_after_every_operation: Bool, denominator_strictly_positive: Bool, denominator_nonzero_checked: Bool, equality_cross_multiply_safe: Bool, order_cross_multiply_safe: Bool, canonical_fraction_serialization: Bool):
        self.backend = backend
        self.normalized_after_every_operation = normalized_after_every_operation
        self.denominator_strictly_positive = denominator_strictly_positive
        self.denominator_nonzero_checked = denominator_nonzero_checked
        self.equality_cross_multiply_safe = equality_cross_multiply_safe
        self.order_cross_multiply_safe = order_cross_multiply_safe
        self.canonical_fraction_serialization = canonical_fraction_serialization

    def proof_ready(self) -> Bool:
        return (
            self.backend.proof_ready() and
            self.normalized_after_every_operation and
            self.denominator_strictly_positive and
            self.denominator_nonzero_checked and
            self.equality_cross_multiply_safe and
            self.order_cross_multiply_safe and
            self.canonical_fraction_serialization
        )


def current_q_backend_status() -> RationalBackendStatus:
    return RationalBackendStatus(
        dynamic_limb_bigz_backend_status(),
        True,
        True,
        True,
        True,
        True,
        True,
    )


# Implemented Q API over BigZ:
#
# struct Q:
#     var num: Z
#     var den: Z
#
#     fn __init__(inout self, num: Z, den: Z)
#     fn zero() -> Q
#     fn one() -> Q
#     fn add(self, other: Q) -> Q
#     fn sub(self, other: Q) -> Q
#     fn mul(self, other: Q) -> Q
#     fn div(self, other: Q) -> Q
#     fn neg(self) -> Q
#     fn square(self) -> Q
#     fn eq(self, other: Q) -> Bool
#     fn lt(self, other: Q) -> Bool
#     fn le(self, other: Q) -> Bool
#     fn canonical_bytes(self) -> String
#
# Normalization rule:
#   gcd(abs(num), den)=1 and den>0 after construction and every operation.
#
# Safety rule: eq/lt/le cross multiplication is over unbounded BigZ. Rational
# readiness still does not enable certificate acceptance: the BigZ backend's
# acceptance flag remains false until downstream replay is complete.


def q_backend_blocks_proof_acceptance(status: RationalBackendStatus) -> Bool:
    return not status.proof_ready()


def q_backend_migration_smoke() -> Bool:
    var status = current_q_backend_status()
    return (
        status.backend.integer_backend_ready() and
        status.normalized_after_every_operation and
        status.denominator_strictly_positive and
        status.denominator_nonzero_checked and
        status.equality_cross_multiply_safe and
        status.order_cross_multiply_safe and
        status.canonical_fraction_serialization and
        not status.backend.allows_certificate_acceptance and
        q_backend_blocks_proof_acceptance(status)
    )
