# exact_type_exclusion.mojo
#
# Same-box exact-type exclusion contract.
#
# This module encodes the rule surfaced by the squarefree-only correction:
# localization and forbidden-collision exclusions must be checked on the same
# dyadic complex box. A certificate that localizes on one box and excludes on
# another is invalid, even if both facts are separately true.


struct BoxId:
    var id: Int64

    fn __init__(inout self, id: Int64):
        self.id = id

    fn eq(self, other: BoxId) -> Bool:
        return self.id == other.id


struct Pair:
    var i: Int64
    var j: Int64

    fn __init__(inout self, i: Int64, j: Int64):
        self.i = i
        self.j = j


fn is_intended_pair(ell: Int64, k: Int64, i: Int64, j: Int64) -> Bool:
    if i < ell:
        return False
    if j <= i:
        return False
    return ((j - i) % k) == 0


fn count_total_pairs(horizon: Int64) -> Int64:
    return (horizon * (horizon + 1)) // 2


fn count_intended_pairs(ell: Int64, k: Int64, horizon: Int64) -> Int64:
    var count: Int64 = 0
    for i in range(0, horizon + 1):
        for j in range(i + 1, horizon + 1):
            if is_intended_pair(ell, k, i, j):
                count += 1
    return count


fn count_forbidden_pairs(ell: Int64, k: Int64, horizon: Int64) -> Int64:
    return count_total_pairs(horizon) - count_intended_pairs(ell, k, horizon)


struct LocalizationResult:
    var box_id: BoxId
    var krawczyk_inclusion_checked: Bool
    var unique_squarefree_root: Bool

    fn __init__(
        inout self,
        box_id: BoxId,
        krawczyk_inclusion_checked: Bool,
        unique_squarefree_root: Bool,
    ):
        self.box_id = box_id
        self.krawczyk_inclusion_checked = krawczyk_inclusion_checked
        self.unique_squarefree_root = unique_squarefree_root


struct ForbiddenExclusionBatch:
    var box_id: BoxId
    var ell: Int64
    var k: Int64
    var horizon: Int64
    var expected_forbidden_count: Int64
    var checked_forbidden_count: Int64
    var all_interval_exclusions_checked: Bool

    fn __init__(
        inout self,
        box_id: BoxId,
        ell: Int64,
        k: Int64,
        horizon: Int64,
        expected_forbidden_count: Int64,
        checked_forbidden_count: Int64,
        all_interval_exclusions_checked: Bool,
    ):
        self.box_id = box_id
        self.ell = ell
        self.k = k
        self.horizon = horizon
        self.expected_forbidden_count = expected_forbidden_count
        self.checked_forbidden_count = checked_forbidden_count
        self.all_interval_exclusions_checked = all_interval_exclusions_checked


fn forbidden_batch_shape_valid(batch: ForbiddenExclusionBatch) -> Bool:
    if batch.horizon < batch.ell + batch.k:
        return False
    var expected = count_forbidden_pairs(batch.ell, batch.k, batch.horizon)
    return (
        expected == batch.expected_forbidden_count and
        expected == batch.checked_forbidden_count
    )


struct JointBoxWitness:
    var localization: LocalizationResult
    var exclusions: ForbiddenExclusionBatch

    fn __init__(
        inout self,
        localization: LocalizationResult,
        exclusions: ForbiddenExclusionBatch,
    ):
        self.localization = localization
        self.exclusions = exclusions


fn joint_box_witness_valid(w: JointBoxWitness) -> Bool:
    return (
        w.localization.box_id.eq(w.exclusions.box_id) and
        w.localization.krawczyk_inclusion_checked and
        w.localization.unique_squarefree_root and
        forbidden_batch_shape_valid(w.exclusions) and
        w.exclusions.all_interval_exclusions_checked
    )


fn demo_m41_forbidden_count_h6() -> Int64:
    # For M_{4,1}: ell=4, k=1, H=6.
    # Total pairs = 21. Intended tail pairs are (4,5), (4,6), (5,6).
    # Forbidden = 18.
    return count_forbidden_pairs(4, 1, 6)


fn demo_c_minus_2_forbidden_count_h3() -> Int64:
    # For c=-2: ell=2, k=1, H=3.
    # Total pairs = 6. Intended pair is (2,3). Forbidden = 5.
    return count_forbidden_pairs(2, 1, 3)
