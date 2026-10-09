# bigint_adapter.mojo
#
# Backend adapter boundary for proof-grade finite-regime arithmetic.
#
# The certificate calculus requires unbounded integer arithmetic. This module
# defines the adapter contract. The selected phase-one implementation is the
# Mojo-native dynamic-limb `BigZ` in `bigint_z.mojo`.
# Current Int64-backed demos remain useful for smoke tests, but must never be
# treated as proof-grade.


struct BigIntBackendStatus(ImplicitlyCopyable):
    var backend_name: String
    var has_unbounded_storage: Bool
    var has_exact_add_sub_mul: Bool
    var has_exact_order: Bool
    var has_euclidean_gcd: Bool
    var has_exact_divisibility: Bool
    var has_canonical_serialization: Bool
    var allows_certificate_acceptance: Bool

    def __init__(out self, backend_name: String, has_unbounded_storage: Bool, has_exact_add_sub_mul: Bool, has_exact_order: Bool, has_euclidean_gcd: Bool, has_exact_divisibility: Bool, has_canonical_serialization: Bool, allows_certificate_acceptance: Bool):
        self.backend_name = backend_name
        self.has_unbounded_storage = has_unbounded_storage
        self.has_exact_add_sub_mul = has_exact_add_sub_mul
        self.has_exact_order = has_exact_order
        self.has_euclidean_gcd = has_euclidean_gcd
        self.has_exact_divisibility = has_exact_divisibility
        self.has_canonical_serialization = has_canonical_serialization
        self.allows_certificate_acceptance = allows_certificate_acceptance

    def proof_ready(self) -> Bool:
        return (
            self.has_unbounded_storage and
            self.has_exact_add_sub_mul and
            self.has_exact_order and
            self.has_euclidean_gcd and
            self.has_exact_divisibility and
            self.has_canonical_serialization and
            self.allows_certificate_acceptance
        )

    def integer_backend_ready(self) -> Bool:
        # Integer readiness is deliberately weaker than proof readiness.  It
        # permits BigZ-backed rational migration without accepting any
        # certificate before the rational and replay layers are complete.
        return (
            self.has_unbounded_storage and
            self.has_exact_add_sub_mul and
            self.has_exact_order and
            self.has_euclidean_gcd and
            self.has_exact_divisibility and
            self.has_canonical_serialization
        )


def int64_demo_backend_status() -> BigIntBackendStatus:
    return BigIntBackendStatus(
        "Int64DemoBackend",
        False,
        True,
        True,
        True,
        True,
        True,
        False,
    )


def pending_bigint_backend_status() -> BigIntBackendStatus:
    return BigIntBackendStatus(
        "PendingBigIntBackend",
        False,
        False,
        False,
        False,
        False,
        False,
        False,
    )


def dynamic_limb_phase_one_backend_status() -> BigIntBackendStatus:
    # Dynamic storage and exact ring/order operations are implemented. GCD,
    # exact division, and canonical serialization remain mandatory blockers.
    return BigIntBackendStatus(
        "MojoDynamicLimbBigZPhaseOne",
        True,
        True,
        True,
        False,
        False,
        False,
        False,
    )


def dynamic_limb_phase_two_backend_status() -> BigIntBackendStatus:
    # Dynamic arithmetic, Euclidean gcd, and exact divisibility are compiled.
    # Canonical serialization remains the final integer-backend blocker.
    return BigIntBackendStatus(
        "MojoDynamicLimbBigZPhaseTwo",
        True,
        True,
        True,
        True,
        True,
        False,
        False,
    )


def dynamic_limb_bigz_backend_status() -> BigIntBackendStatus:
    # All integer-backend requirements are compiled. This permits migration of
    # rational consumers; it does not by itself accept a certificate.
    return BigIntBackendStatus(
        "MojoDynamicLimbBigZ",
        True,
        True,
        True,
        True,
        True,
        True,
        False,
    )


# Target adapter operations for the real backend. These are comments until a
# concrete Mojo-compatible bigint source is selected.
#
# struct Z:
#     fn zero() -> Z
#     fn one() -> Z
#     fn from_i64(x: Int64) -> Z
#     fn add(self, other: Z) -> Z
#     fn sub(self, other: Z) -> Z
#     fn mul(self, other: Z) -> Z
#     fn neg(self) -> Z
#     fn abs(self) -> Z
#     fn eq(self, other: Z) -> Bool
#     fn lt(self, other: Z) -> Bool
#     fn div_exact(self, other: Z) -> Z
#     fn gcd(self, other: Z) -> Z
#     fn canonical_bytes(self) -> String
#
# The adapter must be deterministic across platforms. Canonical serialization is
# required because certificate hashes cannot depend on host integer formatting.


def bigint_backend_blocks_proof_acceptance(status: BigIntBackendStatus) -> Bool:
    return not status.proof_ready()


def bigint_adapter_phase_one_smoke() -> Bool:
    var status = dynamic_limb_phase_one_backend_status()
    return (
        status.has_unbounded_storage and status.has_exact_add_sub_mul and status.has_exact_order and
        not status.has_euclidean_gcd and not status.has_exact_divisibility and
        not status.has_canonical_serialization and not status.allows_certificate_acceptance and
        bigint_backend_blocks_proof_acceptance(status)
    )


def bigint_adapter_phase_two_smoke() -> Bool:
    var status = dynamic_limb_phase_two_backend_status()
    return (
        status.has_unbounded_storage and status.has_exact_add_sub_mul and status.has_exact_order and
        status.has_euclidean_gcd and status.has_exact_divisibility and
        not status.has_canonical_serialization and not status.allows_certificate_acceptance and
        bigint_backend_blocks_proof_acceptance(status)
    )


def bigint_adapter_complete_smoke() -> Bool:
    var status = dynamic_limb_bigz_backend_status()
    return (
        status.integer_backend_ready() and
        not status.allows_certificate_acceptance and
        not status.proof_ready() and
        bigint_backend_blocks_proof_acceptance(status)
    )
