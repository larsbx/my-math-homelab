# Finite BigZ/Q landing-target association replay for c=-2.
#
# This composes exact arithmetic and symbolic address data only. The named
# classical correspondence is not proved or accepted here, so this module
# cannot accept a theorem import, a certificate, C1, or residual closure.

from finite_exact.bigint_z import bigz_add, bigz_from_i64, bigz_mul
from dynamics.bigq_ray_address import BigQRayOrbitStatus, verify_bigq_one_half_orbit
from dynamics.interval_orbit import BigQExactTypeExclusionResult, bigq_p21_exact_type_exclusions
from certificates.krawczyk_witness import BigQKrawczykResult, verify_bigq_p21_krawczyk_c_minus_2


struct BigQLandingCorrespondenceRule(Copyable):
    var source_citation_key: String
    var critical_orbit_preperiod_offset: Int
    var period_preserved: Bool

    def __init__(out self, source_citation_key: String, critical_orbit_preperiod_offset: Int, period_preserved: Bool):
        self.source_citation_key = source_citation_key
        self.critical_orbit_preperiod_offset = critical_orbit_preperiod_offset
        self.period_preserved = period_preserved

    def metadata_matches_p21(self) -> Bool:
        return (
            self.source_citation_key == "SchleicherRationalParameterRays" and
            self.critical_orbit_preperiod_offset == 1 and self.period_preserved
        )


struct BigQLandingTargetAssociation(Copyable):
    var box_name: String
    var half_width_den_power: Int
    var localization: BigQKrawczykResult
    var exclusions: BigQExactTypeExclusionResult
    var rays: BigQRayOrbitStatus
    var correspondence: BigQLandingCorrespondenceRule
    var ell: Int
    var period: Int

    def __init__(out self, box_name: String, half_width_den_power: Int, localization: BigQKrawczykResult, exclusions: BigQExactTypeExclusionResult, rays: BigQRayOrbitStatus, correspondence: BigQLandingCorrespondenceRule, ell: Int, period: Int):
        self.box_name = box_name
        self.half_width_den_power = half_width_den_power
        self.localization = localization.copy()
        self.exclusions = exclusions.copy()
        self.rays = rays.copy()
        self.correspondence = correspondence.copy()
        self.ell = ell
        self.period = period

    def finite_replay_associated(self) -> Bool:
        return (
            self.box_name == "beta_c_minus_2" and
            self.exclusions.box_name == self.box_name and
            self.exclusions.half_width_den_power == self.half_width_den_power and
            self.localization.arithmetic_replay_accepted() and
            self.exclusions.arithmetic_replay_accepted() and
            self.rays.arithmetic_replay_accepted() and
            self.correspondence.metadata_matches_p21() and
            self.rays.preperiod + self.correspondence.critical_orbit_preperiod_offset == self.ell and
            self.rays.period == self.period and self.ell == 2 and self.period == 1
        )

    def theorem_import_accepted(self) -> Bool:
        # A citation key is metadata, never executable evidence of its theorem.
        return False

    def certificate_accepted(self) -> Bool:
        return False


def bigq_schleicher_correspondence_metadata() -> BigQLandingCorrespondenceRule:
    return BigQLandingCorrespondenceRule("SchleicherRationalParameterRays", 1, True)


# Regime correspondence: landing-association-replay
def verify_bigq_c_minus_2_landing_target_association(half_width_den_power: Int) -> BigQLandingTargetAssociation:
    var beyond_i64 = bigz_add(bigz_from_i64(9223372036854775807), bigz_from_i64(1))
    return BigQLandingTargetAssociation(
        "beta_c_minus_2",
        half_width_den_power,
        verify_bigq_p21_krawczyk_c_minus_2(half_width_den_power),
        bigq_p21_exact_type_exclusions(half_width_den_power),
        verify_bigq_one_half_orbit(beyond_i64, bigz_mul(beyond_i64, bigz_from_i64(2))),
        bigq_schleicher_correspondence_metadata(),
        2,
        1,
    )


def bigq_landing_target_replay_smoke() -> Bool:
    var association = verify_bigq_c_minus_2_landing_target_association(8)
    var narrow = verify_bigq_c_minus_2_landing_target_association(80)
    var ambiguous = verify_bigq_c_minus_2_landing_target_association(0)
    var rejected = verify_bigq_c_minus_2_landing_target_association(-1)
    return (
        association.finite_replay_associated() and narrow.finite_replay_associated() and
        not ambiguous.finite_replay_associated() and not rejected.finite_replay_associated() and
        not association.theorem_import_accepted() and not association.certificate_accepted()
    )
