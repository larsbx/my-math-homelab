# multiset_b3_localization.mojo
#
# First executable B3 handoff from a multiplicity-bearing critical-relation
# root to the existing characteristic-zero localization calculus.
#
# Scope is intentionally exact and narrow:
#
#   A_{2,1}(C) = C^3(C+2), p = 5, c = -2.
#
# The modular simple-root and p^2 lift are provenance.  Factor and dyadic
# Krawczyk replay produce a finite candidate only.  Acceptance additionally
# requires the repository proof-backend gate to be open.  This module does not accept a general algebraic factor,
# choose a non-rational complex embedding, or import an equidistribution claim.

from dynamics.critical_relation_bridge import verify_linear_factor_provenance
from certificates.krawczyk_witness import verify_bigq_p21_krawczyk_c_minus_2
from arithmetic.rat_backend_plan import current_q_backend_status, q_backend_blocks_proof_acceptance


struct RationalB3RootHandle(ImplicitlyCopyable):
    var integer_root: Int
    var preperiod: Int
    var period: Int
    var prime: Int
    var half_width_den_power: Int
    var factor_provenance_accepted: Bool
    var squarefree_factor_is_c_plus_two: Bool
    var dyadic_box_constructed: Bool
    var localization_unique: Bool
    var exact_type_verified_over_z: Bool
    var rational_embedding_selected: Bool
    var backend_proof_gate_open: Bool
    var rejected: Bool

    def __init__(
        out self,
        integer_root: Int,
        preperiod: Int,
        period: Int,
        prime: Int,
        half_width_den_power: Int,
        factor_provenance_accepted: Bool,
        squarefree_factor_is_c_plus_two: Bool,
        dyadic_box_constructed: Bool,
        localization_unique: Bool,
        exact_type_verified_over_z: Bool,
        rational_embedding_selected: Bool,
        backend_proof_gate_open: Bool,
        rejected: Bool,
    ):
        self.integer_root = integer_root
        self.preperiod = preperiod
        self.period = period
        self.prime = prime
        self.half_width_den_power = half_width_den_power
        self.factor_provenance_accepted = factor_provenance_accepted
        self.squarefree_factor_is_c_plus_two = squarefree_factor_is_c_plus_two
        self.dyadic_box_constructed = dyadic_box_constructed
        self.localization_unique = localization_unique
        self.exact_type_verified_over_z = exact_type_verified_over_z
        self.rational_embedding_selected = rational_embedding_selected
        self.backend_proof_gate_open = backend_proof_gate_open
        self.rejected = rejected

    def arithmetic_replay_accepted(self) -> Bool:
        return (
            not self.rejected and
            self.integer_root == -2 and
            self.preperiod == 2 and self.period == 1 and
            self.prime == 5 and
            self.half_width_den_power >= 1 and
            self.factor_provenance_accepted and
            self.squarefree_factor_is_c_plus_two and
            self.dyadic_box_constructed and
            self.localization_unique and
            self.exact_type_verified_over_z and
            self.rational_embedding_selected
        )

    def accepted(self) -> Bool:
        return self.arithmetic_replay_accepted() and self.backend_proof_gate_open

    def proof_grade_accepted(self) -> Bool:
        return self.accepted()

    def accepts_general_algebraic_factor(self) -> Bool:
        return False

    def accepts_nonrational_complex_embedding(self) -> Bool:
        return False

    def imports_distributional_bridge(self) -> Bool:
        return False


def rejected_rational_b3_root_handle() -> RationalB3RootHandle:
    return RationalB3RootHandle(
        0, 0, 0, 0, 0,
        False, False, False, False, False, False, False, True,
    )


def c_minus_2_exact_type_2_1_over_z() -> Bool:
    # Replay Q_0=0, Q_{n+1}=Q_n^2-2 through the first return.
    var q0 = 0
    var q1 = q0 * q0 - 2
    var q2 = q1 * q1 - 2
    var q3 = q2 * q2 - 2
    return (
        q0 == 0 and q1 == -2 and q2 == 2 and q3 == 2 and
        q0 != q1 and q0 != q2 and q1 != q2
    )


def verify_c_minus_2_b3_root_handle(
    prime: Int, half_width_den_power: Int
) -> RationalB3RootHandle:
    if prime != 5 or half_width_den_power < 1:
        return rejected_rational_b3_root_handle()

    var provenance = verify_linear_factor_provenance(-2, 2, 1, prime)
    var localization = verify_bigq_p21_krawczyk_c_minus_2(
        half_width_den_power
    )
    if not provenance.accepted() or not localization.arithmetic_replay_accepted():
        return rejected_rational_b3_root_handle()

    var backend = current_q_backend_status()
    var backend_gate_open = not q_backend_blocks_proof_acceptance(backend)
    return RationalB3RootHandle(
        -2,
        2,
        1,
        prime,
        half_width_den_power,
        provenance.accepted(),
        True,
        True,
        localization.contraction_verified,
        c_minus_2_exact_type_2_1_over_z(),
        True,
        backend_gate_open,
        False,
    )


def multiset_b3_localization_smoke() -> Bool:
    var replay = verify_c_minus_2_b3_root_handle(5, 8)
    var wrong_prime = verify_c_minus_2_b3_root_handle(7, 8)
    var invalid_box = verify_c_minus_2_b3_root_handle(5, -1)
    return (
        replay.arithmetic_replay_accepted() and not replay.accepted() and
        not replay.proof_grade_accepted() and
        not replay.backend_proof_gate_open and replay.integer_root == -2 and
        replay.factor_provenance_accepted and
        replay.localization_unique and
        replay.exact_type_verified_over_z and
        not replay.accepts_general_algebraic_factor() and
        not replay.accepts_nonrational_complex_embedding() and
        not replay.imports_distributional_bridge() and
        not wrong_prime.accepted() and wrong_prime.rejected and
        not invalid_box.accepted() and invalid_box.rejected
    )
