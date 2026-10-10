# C1 canonical content refinement order scaffold.
#
# This file is intentionally finite and combinatorial. It does not use metric
# diameter, circles, disks, arcs, circumference, or analytic locus objects.

struct ContentMeasure:
    var atom_count: Int
    var unresolved_obligation_count: Int
    var boundary_candidate_count: Int
    var missing_link_count: Int

    fn __init__(inout self, atom_count: Int, unresolved_obligation_count: Int, boundary_candidate_count: Int, missing_link_count: Int):
        self.atom_count = atom_count
        self.unresolved_obligation_count = unresolved_obligation_count
        self.boundary_candidate_count = boundary_candidate_count
        self.missing_link_count = missing_link_count


struct ContentRefinementStep:
    var old_measure: ContentMeasure
    var new_measure: ContentMeasure
    var kind: String
    var content_changed: Bool
    var display_label_only: Bool
    var theorem_or_catalogue_link_named: Bool

    fn __init__(inout self, old_measure: ContentMeasure, new_measure: ContentMeasure, kind: String, content_changed: Bool, display_label_only: Bool, theorem_or_catalogue_link_named: Bool):
        self.old_measure = old_measure
        self.new_measure = new_measure
        self.kind = kind
        self.content_changed = content_changed
        self.display_label_only = display_label_only
        self.theorem_or_catalogue_link_named = theorem_or_catalogue_link_named


fn accepted_order_kind(kind: String) -> Bool:
    return (
        kind == "ObligationDischarge" or
        kind == "CarrierSplit" or
        kind == "BoundaryCandidateDischarge" or
        kind == "MissingLinkExposure"
    )


fn obligation_discharge(old: ContentMeasure, new: ContentMeasure) -> Bool:
    return new.unresolved_obligation_count < old.unresolved_obligation_count


fn carrier_split_progress(old: ContentMeasure, new: ContentMeasure) -> Bool:
    return (
        new.atom_count > old.atom_count and
        new.unresolved_obligation_count <= old.unresolved_obligation_count and
        new.boundary_candidate_count <= old.boundary_candidate_count
    )


fn boundary_candidate_discharge(old: ContentMeasure, new: ContentMeasure) -> Bool:
    return new.boundary_candidate_count < old.boundary_candidate_count


fn missing_link_exposure(step: ContentRefinementStep) -> Bool:
    return step.theorem_or_catalogue_link_named and step.kind == "MissingLinkExposure"


fn canonical_content_refines(step: ContentRefinementStep) -> Bool:
    if step.display_label_only:
        return False
    if not step.content_changed:
        return False
    if not accepted_order_kind(step.kind):
        return False
    if step.kind == "ObligationDischarge":
        return obligation_discharge(step.old_measure, step.new_measure)
    if step.kind == "CarrierSplit":
        return carrier_split_progress(step.old_measure, step.new_measure)
    if step.kind == "BoundaryCandidateDischarge":
        return boundary_candidate_discharge(step.old_measure, step.new_measure)
    if step.kind == "MissingLinkExposure":
        return missing_link_exposure(step)
    return False


fn proves_c1() -> Bool:
    return False


fn rank2_circle_primitive_available() -> Bool:
    return False
