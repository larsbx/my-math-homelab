# C1_separator_codes.mojo
#
# Finite separator-code grammar for the C1 proof track.
# This module does not encode analytic curves or generic boundary landings.

from dynamics.ray_address import RayAddr


struct LandingTagCode:
    var name: String

    fn __init__(inout self, name: String):
        self.name = name

    fn admissible(self) -> Bool:
        return (
            self.name == "RationalRayLanding" or
            self.name == "ParabolicLanding" or
            self.name == "HyperbolicBoundaryLanding"
        )

    fn generic_forbidden(self) -> Bool:
        return self.name == "GenericBoundaryLanding" or self.name == "MLCBinding"


struct TwoRaySeparatorCode:
    var left: RayAddr
    var right: RayAddr
    var landing_tag: LandingTagCode
    var endpoint_compatible: Bool

    fn __init__(inout self, left: RayAddr, right: RayAddr, landing_tag: LandingTagCode, endpoint_compatible: Bool):
        self.left = left
        self.right = right
        self.landing_tag = landing_tag
        self.endpoint_compatible = endpoint_compatible

    fn distinct_rays(self) -> Bool:
        return self.left.num != self.right.num or self.left.den != self.right.den

    fn admissible(self) -> Bool:
        return (
            self.left.shape_valid() and
            self.right.shape_valid() and
            self.distinct_rays() and
            self.landing_tag.admissible() and
            not self.landing_tag.generic_forbidden() and
            self.endpoint_compatible
        )


struct ComponentArcSeparatorCode:
    var root_handle_id: String
    var component_id: String
    var landing_tag: LandingTagCode

    fn __init__(inout self, root_handle_id: String, component_id: String, landing_tag: LandingTagCode):
        self.root_handle_id = root_handle_id
        self.component_id = component_id
        self.landing_tag = landing_tag

    fn admissible(self) -> Bool:
        return (
            len(self.root_handle_id) > 0 and
            len(self.component_id) > 0 and
            self.landing_tag.name == "HyperbolicBoundaryLanding" and
            not self.landing_tag.generic_forbidden()
        )


struct FairEnumerationWitnessCode:
    var enumerates_two_ray_codes: Bool
    var enumerates_component_arc_codes: Bool
    var bounded_by_size_prefix: Bool
    var claims_stabilization: Bool

    fn __init__(inout self, enumerates_two_ray_codes: Bool, enumerates_component_arc_codes: Bool, bounded_by_size_prefix: Bool, claims_stabilization: Bool):
        self.enumerates_two_ray_codes = enumerates_two_ray_codes
        self.enumerates_component_arc_codes = enumerates_component_arc_codes
        self.bounded_by_size_prefix = bounded_by_size_prefix
        self.claims_stabilization = claims_stabilization

    fn valid_for_C1(self) -> Bool:
        return (
            self.enumerates_two_ray_codes and
            self.enumerates_component_arc_codes and
            self.bounded_by_size_prefix and
            not self.claims_stabilization
        )


fn demo_rational_two_ray_separator() -> Bool:
    var left = RayAddr(9, 56)
    var right = RayAddr(11, 56)
    var tag = LandingTagCode("RationalRayLanding")
    var code = TwoRaySeparatorCode(left, right, tag, True)
    return code.admissible()


fn must_reject_generic_separator() -> Bool:
    var left = RayAddr(9, 56)
    var right = RayAddr(11, 56)
    var tag = LandingTagCode("GenericBoundaryLanding")
    var code = TwoRaySeparatorCode(left, right, tag, True)
    return not code.admissible()


fn demo_fair_enumeration_witness() -> Bool:
    var w = FairEnumerationWitnessCode(True, True, True, False)
    return w.valid_for_C1()
