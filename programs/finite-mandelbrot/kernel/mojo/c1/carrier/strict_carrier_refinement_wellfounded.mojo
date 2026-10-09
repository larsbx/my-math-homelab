# C1 strict carrier refinement well-foundedness scaffold.
#
# This file is finite-combinatorial only. It does not use metric diameter,
# analytic points, or rank-2 circle/locus primitives.

struct CarrierMeasure:
    var unresolved_wake_slots: Int
    var carrier_vertices: Int
    var boundary_candidates: Int
    var missing_links: Int

    fn __init__(inout self, unresolved_wake_slots: Int, carrier_vertices: Int, boundary_candidates: Int, missing_links: Int):
        self.unresolved_wake_slots = unresolved_wake_slots
        self.carrier_vertices = carrier_vertices
        self.boundary_candidates = boundary_candidates
        self.missing_links = missing_links

    fn valid(self) -> Bool:
        return self.unresolved_wake_slots >= 0 and self.carrier_vertices >= 0 and self.boundary_candidates >= 0 and self.missing_links >= 0


struct RefinementStep:
    var before: CarrierMeasure
    var after: CarrierMeasure
    var discharges_unresolved_slot: Bool
    var yields_boundary_equality: Bool
    var yields_missing_link: Bool
    var yields_opposite_side_separation: Bool
    var relabeling_only: Bool

    fn __init__(inout self, before: CarrierMeasure, after: CarrierMeasure, discharges_unresolved_slot: Bool, yields_boundary_equality: Bool, yields_missing_link: Bool, yields_opposite_side_separation: Bool, relabeling_only: Bool):
        self.before = before
        self.after = after
        self.discharges_unresolved_slot = discharges_unresolved_slot
        self.yields_boundary_equality = yields_boundary_equality
        self.yields_missing_link = yields_missing_link
        self.yields_opposite_side_separation = yields_opposite_side_separation
        self.relabeling_only = relabeling_only


fn lex_decreases(before: CarrierMeasure, after: CarrierMeasure) -> Bool:
    if not before.valid() or not after.valid():
        return False
    if after.unresolved_wake_slots < before.unresolved_wake_slots:
        return True
    if after.unresolved_wake_slots > before.unresolved_wake_slots:
        return False
    if after.carrier_vertices < before.carrier_vertices:
        return True
    if after.carrier_vertices > before.carrier_vertices:
        return False
    if after.boundary_candidates < before.boundary_candidates:
        return True
    if after.boundary_candidates > before.boundary_candidates:
        return False
    return after.missing_links < before.missing_links


fn has_productive_outcome(step: RefinementStep) -> Bool:
    return step.discharges_unresolved_slot or step.yields_boundary_equality or step.yields_missing_link or step.yields_opposite_side_separation


fn accepted_strict_refinement(step: RefinementStep) -> Bool:
    if step.relabeling_only:
        return False
    if not step.before.valid() or not step.after.valid():
        return False
    if lex_decreases(step.before, step.after):
        return True
    return has_productive_outcome(step)


fn proves_c1(_step: RefinementStep) -> Bool:
    return False


fn proves_singleton_fiber(_step: RefinementStep) -> Bool:
    return False


fn rank2_circle_primitive_available() -> Bool:
    return False


fn demo_relabeling_rejected() -> Bool:
    var m = CarrierMeasure(2, 3, 1, 0)
    var step = RefinementStep(m, m, False, False, False, False, True)
    return not accepted_strict_refinement(step)


fn demo_descent_accepted() -> Bool:
    var before = CarrierMeasure(2, 3, 1, 0)
    var after = CarrierMeasure(1, 3, 1, 0)
    var step = RefinementStep(before, after, True, False, False, False, False)
    return accepted_strict_refinement(step)
