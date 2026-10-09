"""Exact bounded collision censuses for the G1b-2 joint-local program.

This module audits a finite corpus of *certified* renewal cuts. It does not
promote corpus separation to a theorem. A collision means two distinct observed
cuts have the same bounded `JointLocalType`; the witness is retained so the
identification can be classified as harmful, benign recurrence, or unresolved.

Candidate cuts are generated independently by materializing the requested
finite inflation and streaming the aligned Parikh-difference walk. Every
reported zero return is then re-certified by `joint_local_type`, so disagreement
between the oracle and the address layer fails closed rather than being skipped.
"""

from psc.joint_local_type import JointLocalType, joint_local_type, same_joint_local_type
from psc.legal_tower import apply_substitution_n
from psc.renewal_address import (
    RelativeRenewalAddress,
    build_renewal_address_tables,
    build_renewal_pair_census_state,
)
from psc.words import Pair, is_balanced


struct JointLocalSample(Copyable, Movable):
    """One certified corpus observation and its bounded projection."""

    var specimen_id: Int
    var depth: Int
    var cut: Int
    var projection: JointLocalType

    def __init__(
        out self,
        specimen_id: Int,
        depth: Int,
        cut: Int,
        projection: JointLocalType,
    ):
        self.specimen_id = specimen_id
        self.depth = depth
        self.cut = cut
        self.projection = projection.copy()


struct ProjectionAudit(Copyable, Movable):
    """Pairwise collision summary retaining the first exact witness indices."""

    var sample_count: Int
    var collision_pair_count: Int
    var first_left: Int
    var first_right: Int

    def __init__(
        out self,
        sample_count: Int,
        collision_pair_count: Int,
        first_left: Int,
        first_right: Int,
    ):
        self.sample_count = sample_count
        self.collision_pair_count = collision_pair_count
        self.first_left = first_left
        self.first_right = first_right

    def has_collision(self) -> Bool:
        return self.collision_pair_count > 0


struct ObservationKey(Copyable, Movable, Equatable, Hashable):
    """Compact exact identity for one corpus observation."""

    var specimen_id: Int
    var depth: Int
    var cut: Int

    def __init__(out self, specimen_id: Int, depth: Int, cut: Int):
        self.specimen_id = specimen_id
        self.depth = depth
        self.cut = cut


def zero_return_cuts(
    sigma: List[List[Int]], pair: Pair, depth: Int
) raises -> List[Int]:
    """Independent finite oracle for interior aligned zero-return positions."""
    if depth < 0:
        raise Error("joint-local census depth must be nonnegative")
    if not is_balanced(pair):
        raise Error("joint-local census source pair must be balanced")

    var top = apply_substitution_n(sigma, pair.u, depth)
    var bottom = apply_substitution_n(sigma, pair.v, depth)
    if len(top) != len(bottom):
        raise Error("balanced pair inflated to unequal side lengths")

    var out = List[Int]()
    var x = 0
    var y = 0
    var z = 0
    for i in range(len(top)):
        var a = top[i]
        if a == 0:
            x += 1
        elif a == 1:
            y += 1
        elif a == 2:
            z += 1
        else:
            raise Error("joint-local census requires letters in 0..2")

        var b = bottom[i]
        if b == 0:
            x -= 1
        elif b == 1:
            y -= 1
        elif b == 2:
            z -= 1
        else:
            raise Error("joint-local census requires letters in 0..2")

        var cut = i + 1
        if cut < len(top) and x == 0 and y == 0 and z == 0:
            out.append(cut)

    if x != 0 or y != 0 or z != 0:
        raise Error("inflated census pair failed final balance check")
    return out^


def _validate_projection_bounds(source_radius: Int, digit_window: Int) raises:
    if source_radius < 0 or digit_window < 0:
        raise Error("joint-local census radius and digit window must be nonnegative")


def append_samples_at_depth(
    mut out: List[JointLocalSample],
    sigma: List[List[Int]],
    pair: Pair,
    specimen_id: Int,
    depth: Int,
    source_radius: Int,
    digit_window: Int,
) raises:
    """Append every oracle zero return at one depth, re-certifying each cut."""
    if depth <= 0:
        raise Error("joint-local sample depth must be positive")
    _validate_projection_bounds(source_radius, digit_window)
    var tables = build_renewal_address_tables(sigma, depth)
    var state = build_renewal_pair_census_state(tables, pair)
    var cuts = zero_return_cuts(sigma, pair, depth)
    for i in range(len(cuts)):
        var cut = cuts[i]
        var projection = joint_local_type(
            state, cut, source_radius, digit_window
        )
        out.append(JointLocalSample(specimen_id, depth, cut, projection))


def samples_through_depth(
    sigma: List[List[Int]],
    pair: Pair,
    specimen_id: Int,
    max_depth: Int,
    source_radius: Int,
    digit_window: Int,
) raises -> List[JointLocalSample]:
    if max_depth <= 0:
        raise Error("joint-local census max_depth must be positive")
    _validate_projection_bounds(source_radius, digit_window)
    var out = List[JointLocalSample]()
    for depth in range(1, max_depth + 1):
        append_samples_at_depth(
            out,
            sigma,
            pair,
            specimen_id,
            depth,
            source_radius,
            digit_window,
        )
    return out^


def _rotate_hash(x: UInt64) -> UInt64:
    return (x << 7) | (x >> 57)


def _mix_hash(state: UInt64, value: UInt64) -> UInt64:
    return _rotate_hash(state) ^ value


def _projection_fingerprint(projection: JointLocalType) -> UInt64:
    """Fast bucket fingerprint; full equality always resolves hash collisions."""
    var h = hash(projection.source_radius)
    h = _mix_hash(h, hash(projection.digit_window))
    h = _mix_hash(h, hash(projection.source_index_delta))
    h = _mix_hash(h, hash(projection.source_defect.x))
    h = _mix_hash(h, hash(projection.source_defect.y))
    h = _mix_hash(h, hash(projection.source_defect.z))
    h = _mix_hash(h, hash(projection.top_source_letter))
    h = _mix_hash(h, hash(projection.bottom_source_letter))
    h = _mix_hash(h, hash(projection.source_context))
    h = _mix_hash(h, hash(projection.top_head))
    h = _mix_hash(h, hash(projection.top_tail))
    h = _mix_hash(h, hash(projection.bottom_head))
    h = _mix_hash(h, hash(projection.bottom_tail))
    return h


def audit_projection(samples: List[JointLocalSample]) raises -> ProjectionAudit:
    """Count exact collisions with near-linear expected-time state interning.

    All accepted samples must use one common `(source_radius, digit_window)`
    configuration; mixed-bound corpora are incomparable evidence and fail
    closed before interning.

    A `UInt64` fingerprint only chooses a hash bucket. Each bucket is a linked
    list of interned representative sample indices, and `same_joint_local_type`
    resolves every candidate match exactly. Hash collisions therefore affect
    performance only, never the mathematical collision count.

    Repeated copies of one `(specimen_id, depth, cut)` observation are ignored
    only after their projections are checked for exact equality. A duplicate
    identity carrying a different projection is contradictory corpus evidence
    and fails closed. `sample_count` reports the deduplicated audited population,
    not the number of raw input records.
    """
    if len(samples) > 0:
        var source_radius = samples[0].projection.source_radius
        var digit_window = samples[0].projection.digit_window
        for i in range(1, len(samples)):
            if (
                samples[i].projection.source_radius != source_radius
                or samples[i].projection.digit_window != digit_window
            ):
                raise Error("joint-local audit cannot mix projection bounds")

    var collisions = 0
    var first_left = -1
    var first_right = -1
    var unique_count = 0

    var heads = Dict[UInt64, Int](capacity=len(samples))
    var representatives = List[Int]()
    var counts = List[Int]()
    var next_group = List[Int]()
    var seen = Dict[ObservationKey, Int](capacity=len(samples))

    for i in range(len(samples)):
        var observation = ObservationKey(
            samples[i].specimen_id, samples[i].depth, samples[i].cut
        )
        if observation in seen:
            var prior = seen[observation]
            if not same_joint_local_type(
                samples[i].projection, samples[prior].projection
            ):
                raise Error(
                    "duplicate joint-local observation identity has conflicting projection"
                )
            continue
        seen[observation.copy()] = i
        unique_count += 1

        var fingerprint = _projection_fingerprint(samples[i].projection)
        var group = -1
        if fingerprint in heads:
            group = heads[fingerprint]

        var matched_group = -1
        while group >= 0:
            var representative = representatives[group]
            if same_joint_local_type(
                samples[i].projection, samples[representative].projection
            ):
                matched_group = group
                break
            group = next_group[group]

        if matched_group >= 0:
            collisions += counts[matched_group]
            if first_left < 0:
                first_left = representatives[matched_group]
                first_right = i
            counts[matched_group] += 1
        else:
            var new_group = len(representatives)
            representatives.append(i)
            counts.append(1)
            if fingerprint in heads:
                next_group.append(heads[fingerprint])
            else:
                next_group.append(-1)
            heads[fingerprint] = new_group

    return ProjectionAudit(unique_count, collisions, first_left, first_right)


def digit_pair_insertion_at(
    shorter: List[Int],
    longer: List[Int],
    parent: Int,
    child_index: Int,
    pair_position: Int,
) -> Bool:
    """Check one exact insertion at a nominated substitution-level position."""
    if len(shorter) % 2 != 0 or len(longer) != len(shorter) + 2:
        return False
    var levels = len(shorter) // 2
    if pair_position < 0 or pair_position > levels:
        return False
    var pos = 2 * pair_position
    if longer[pos] != parent or longer[pos + 1] != child_index:
        return False
    for k in range(pos):
        if longer[k] != shorter[k]:
            return False
    for k in range(pos, len(shorter)):
        if longer[k + 2] != shorter[k]:
            return False
    return True


def one_digit_pair_insertion(
    shorter: List[Int], longer: List[Int], parent: Int, child_index: Int
) -> Bool:
    """Whether `longer` is `shorter` with one exact digit pair inserted."""
    if len(shorter) % 2 != 0 or len(longer) != len(shorter) + 2:
        return False
    for pair_position in range(len(shorter) // 2 + 1):
        if digit_pair_insertion_at(
            shorter, longer, parent, child_index, pair_position
        ):
            return True
    return False


def synchronous_digit_pair_insertion(
    top_shorter: List[Int],
    top_longer: List[Int],
    bottom_shorter: List[Int],
    bottom_longer: List[Int],
    parent: Int,
    child_index: Int,
) -> Bool:
    """Require the same loop digit to be inserted at the same ancestry level."""
    if len(top_shorter) != len(bottom_shorter):
        return False
    if len(top_longer) != len(bottom_longer):
        return False
    if len(top_shorter) % 2 != 0:
        return False
    for pair_position in range(len(top_shorter) // 2 + 1):
        if (
            digit_pair_insertion_at(
                top_shorter,
                top_longer,
                parent,
                child_index,
                pair_position,
            )
            and digit_pair_insertion_at(
                bottom_shorter,
                bottom_longer,
                parent,
                child_index,
                pair_position,
            )
        ):
            return True
    return False


def address_is_one_loop_extension(
    shorter: RelativeRenewalAddress,
    longer: RelativeRenewalAddress,
    parent: Int,
    child_index: Int,
) -> Bool:
    """Classify one synchronous regular cross-level address recurrence.

    Scaled defect/correction are intentionally not equated: they live at
    different substitution levels. The invariant source data must match, and
    both symbolic sides must acquire the nominated digit at one common
    substitution-level position.
    """
    return (
        longer.level == shorter.level + 1
        and longer.source_index_delta == shorter.source_index_delta
        and longer.source_defect == shorter.source_defect
        and longer.top_source_letter == shorter.top_source_letter
        and longer.bottom_source_letter == shorter.bottom_source_letter
        and synchronous_digit_pair_insertion(
            shorter.top_digits,
            longer.top_digits,
            shorter.bottom_digits,
            longer.bottom_digits,
            parent,
            child_index,
        )
    )
