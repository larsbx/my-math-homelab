# C1 NoRenamingAsRefinement scaffold.
#
# This file is a finite carrier-governance scaffold. It does not prove C1,
# MLC, local connectivity, singleton fibers, or any rank-2 locus statement.

@value
struct CarrierContent:
    var carrier_vertex_count: Int
    var unresolved_wake_slot_count: Int
    var boundary_candidate_count: Int
    var missing_link_count: Int
    var separator_reference_count: Int

    fn __init__(
        inout self,
        carrier_vertex_count: Int,
        unresolved_wake_slot_count: Int,
        boundary_candidate_count: Int,
        missing_link_count: Int,
        separator_reference_count: Int,
    ):
        self.carrier_vertex_count = carrier_vertex_count
        self.unresolved_wake_slot_count = unresolved_wake_slot_count
        self.boundary_candidate_count = boundary_candidate_count
        self.missing_link_count = missing_link_count
        self.separator_reference_count = separator_reference_count


@value
struct CarrierPresentation:
    var display_name_id: Int
    var content: CarrierContent

    fn __init__(inout self, display_name_id: Int, content: CarrierContent):
        self.display_name_id = display_name_id
        self.content = content


@value
struct RefinementCertificate:
    var measure_decreases: Bool
    var opposite_side_separation: Bool
    var boundary_equality_refinement: Bool
    var missing_theorem_catalogue_link: Bool

    fn __init__(
        inout self,
        measure_decreases: Bool,
        opposite_side_separation: Bool,
        boundary_equality_refinement: Bool,
        missing_theorem_catalogue_link: Bool,
    ):
        self.measure_decreases = measure_decreases
        self.opposite_side_separation = opposite_side_separation
        self.boundary_equality_refinement = boundary_equality_refinement
        self.missing_theorem_catalogue_link = missing_theorem_catalogue_link


fn same_content(a: CarrierContent, b: CarrierContent) -> Bool:
    return (
        a.carrier_vertex_count == b.carrier_vertex_count
        and a.unresolved_wake_slot_count == b.unresolved_wake_slot_count
        and a.boundary_candidate_count == b.boundary_candidate_count
        and a.missing_link_count == b.missing_link_count
        and a.separator_reference_count == b.separator_reference_count
    )


fn renaming_only(a: CarrierPresentation, b: CarrierPresentation) -> Bool:
    # Different display names do not matter if finite content is identical.
    return same_content(a.content, b.content)


fn productive_certificate(cert: RefinementCertificate) -> Bool:
    return (
        cert.measure_decreases
        or cert.opposite_side_separation
        or cert.boundary_equality_refinement
        or cert.missing_theorem_catalogue_link
    )


fn accepted_strict_refinement(
    before: CarrierPresentation,
    after: CarrierPresentation,
    cert: RefinementCertificate,
) -> Bool:
    if renaming_only(before, after):
        return False
    return productive_certificate(cert)


fn proves_c1() -> Bool:
    return False


fn rank2_circle_primitive_available() -> Bool:
    return False


fn demo_renaming_rejected() -> Bool:
    let content = CarrierContent(3, 2, 1, 0, 4)
    let before = CarrierPresentation(10, content)
    let after = CarrierPresentation(99, content)
    let cert = RefinementCertificate(True, False, False, False)
    return not accepted_strict_refinement(before, after, cert)


fn demo_content_change_requires_productive_certificate() -> Bool:
    let before = CarrierPresentation(1, CarrierContent(3, 2, 1, 0, 4))
    let after = CarrierPresentation(2, CarrierContent(2, 1, 1, 0, 4))
    let cert = RefinementCertificate(True, False, False, False)
    return accepted_strict_refinement(before, after, cert)
