# C1 canonical carrier content scaffold.
#
# This file is deliberately finite and combinatorial. It does not introduce
# metric diameter, analytic loci, rank-2 circle objects, or singleton fibers.

struct CarrierAtom:
    var kind: String
    var normalized_id: String
    var payload_tag: String

    fn __init__(inout self, kind: String, normalized_id: String, payload_tag: String):
        self.kind = kind
        self.normalized_id = normalized_id
        self.payload_tag = payload_tag


struct CarrierObligation:
    var kind: String
    var normalized_target: String
    var status: String

    fn __init__(inout self, kind: String, normalized_target: String, status: String):
        self.kind = kind
        self.normalized_target = normalized_target
        self.status = status


struct CanonicalCarrierContent:
    var atom_count: Int
    var unresolved_obligation_count: Int
    var boundary_candidate_count: Int
    var missing_link_count: Int
    var content_fingerprint: String

    fn __init__(inout self, atom_count: Int, unresolved_obligation_count: Int, boundary_candidate_count: Int, missing_link_count: Int, content_fingerprint: String):
        self.atom_count = atom_count
        self.unresolved_obligation_count = unresolved_obligation_count
        self.boundary_candidate_count = boundary_candidate_count
        self.missing_link_count = missing_link_count
        self.content_fingerprint = content_fingerprint


fn allowed_atom_kind(kind: String) -> Bool:
    if kind == "RootHandleRef":
        return True
    if kind == "RayAddressSetRef":
        return True
    if kind == "DyadicBoxRef":
        return True
    if kind == "SeparatorRef":
        return True
    if kind == "SideWitnessRef":
        return True
    if kind == "BoundaryCandidateRef":
        return True
    if kind == "ObligationRef":
        return True
    return False


fn allowed_obligation_kind(kind: String) -> Bool:
    if kind == "LandingTagMissing":
        return True
    if kind == "CatalogueLinkMissing":
        return True
    if kind == "WakeOrderUnderdetermined":
        return True
    if kind == "BoundaryEqualityCandidate":
        return True
    if kind == "CarrierTooCoarse":
        return True
    return False


fn allowed_obligation_status(status: String) -> Bool:
    if status == "open":
        return True
    if status == "discharged":
        return True
    if status == "rerouted":
        return True
    return False


fn valid_atom(atom: CarrierAtom) -> Bool:
    if not allowed_atom_kind(atom.kind):
        return False
    if len(atom.normalized_id) == 0:
        return False
    if len(atom.payload_tag) == 0:
        return False
    return True


fn valid_obligation(obligation: CarrierObligation) -> Bool:
    if not allowed_obligation_kind(obligation.kind):
        return False
    if not allowed_obligation_status(obligation.status):
        return False
    if len(obligation.normalized_target) == 0:
        return False
    return True


fn same_canonical_content(a: CanonicalCarrierContent, b: CanonicalCarrierContent) -> Bool:
    if a.atom_count != b.atom_count:
        return False
    if a.unresolved_obligation_count != b.unresolved_obligation_count:
        return False
    if a.boundary_candidate_count != b.boundary_candidate_count:
        return False
    if a.missing_link_count != b.missing_link_count:
        return False
    return a.content_fingerprint == b.content_fingerprint


fn productive_content_change(before: CanonicalCarrierContent, after: CanonicalCarrierContent) -> Bool:
    if after.unresolved_obligation_count < before.unresolved_obligation_count:
        return True
    if after.boundary_candidate_count < before.boundary_candidate_count:
        return True
    if after.missing_link_count < before.missing_link_count:
        return True
    if after.atom_count > before.atom_count and after.content_fingerprint != before.content_fingerprint:
        return True
    return False


fn renaming_only_by_content(before: CanonicalCarrierContent, after: CanonicalCarrierContent) -> Bool:
    return same_canonical_content(before, after)


fn rank2_circle_primitive_available() -> Bool:
    return False


fn proves_c1() -> Bool:
    return False


fn proves_singleton_fiber() -> Bool:
    return False
