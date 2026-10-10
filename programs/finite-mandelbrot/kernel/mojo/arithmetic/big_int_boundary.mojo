# big_int_boundary.mojo
#
# Backend boundary for arbitrary-size integer arithmetic.
#
# This file intentionally does not choose a concrete bigint implementation.
# It defines the operations the finite-regime Mandelbrot verifier is allowed
# to depend on. Implementations may bind this interface to a Mojo-native bigint,
# GMP-compatible backend, or a formally verified extracted backend.
#
# Hard invariant: no analytic functions enter this layer. This is signed integer
# arithmetic plus order, divisibility, and Euclidean gcd only.

from finite_exact.integer_gcd import gcd_i64


struct BigIntLike:
    var small: Int64

    fn __init__(inout self, value: Int64):
        self.small = value

    fn zero() -> BigIntLike:
        return BigIntLike(0)

    fn one() -> BigIntLike:
        return BigIntLike(1)

    fn neg_one() -> BigIntLike:
        return BigIntLike(-1)

    fn add(self, other: BigIntLike) -> BigIntLike:
        return BigIntLike(self.small + other.small)

    fn sub(self, other: BigIntLike) -> BigIntLike:
        return BigIntLike(self.small - other.small)

    fn mul(self, other: BigIntLike) -> BigIntLike:
        return BigIntLike(self.small * other.small)

    fn neg(self) -> BigIntLike:
        return BigIntLike(-self.small)

    fn abs(self) -> BigIntLike:
        if self.small < 0:
            return BigIntLike(-self.small)
        return self

    fn is_zero(self) -> Bool:
        return self.small == 0

    fn eq(self, other: BigIntLike) -> Bool:
        return self.small == other.small

    fn lt(self, other: BigIntLike) -> Bool:
        return self.small < other.small

    fn le(self, other: BigIntLike) -> Bool:
        return self.small <= other.small


fn gcd_bigint_stub(a: BigIntLike, b: BigIntLike) raises -> BigIntLike:
    # Stub over Int64 storage. Replace with backend bigint gcd before using
    # this verifier at high degree or high refinement depth.
    return BigIntLike(gcd_i64(a.small, b.small))


struct BigIntBackendContract:
    var has_unbounded_storage: Bool
    var has_exact_add_sub_mul: Bool
    var has_exact_order: Bool
    var has_euclidean_gcd: Bool
    var has_exact_divisibility: Bool

    fn __init__(inout self):
        # Current scaffold uses Int64 storage, so unbounded storage is false.
        self.has_unbounded_storage = False
        self.has_exact_add_sub_mul = True
        self.has_exact_order = True
        self.has_euclidean_gcd = True
        self.has_exact_divisibility = False


fn backend_ready_for_certificates(contract: BigIntBackendContract) -> Bool:
    return (
        contract.has_unbounded_storage and
        contract.has_exact_add_sub_mul and
        contract.has_exact_order and
        contract.has_euclidean_gcd and
        contract.has_exact_divisibility
    )
