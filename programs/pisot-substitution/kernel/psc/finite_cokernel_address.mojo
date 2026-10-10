"""Finite cokernel diagnostics for the open G1b-2 renewal-finiteness gate.

This module tests a non-unimodular arithmetic refinement suggested by the
residual middle-ancestry collisions retained by the joint-local census.  It is
a finite diagnostic only; it does not assert renewal finiteness or promote a
finite quotient to a complete state space.

For one fixed substitution, each exact renewal address determines two intrinsic
within-supertile prefix translations in Z^3: one on the top side and one on the
bottom side.  Their difference is the existing correction vector.  For a fixed
k >= 1 we compare each side in the finite cokernel

    Z^3 / M^k Z^3.

No stable-space projection, floating inverse, or unimodularity assumption is
used.  Membership in M^k Z^3 is tested exactly by Cramer's-rule divisibility for
the three integer columns of M^k.  In the canonical det(M)=2 regression the
cokernel has order 2^k.

The symbolic synchronous-extension quotient is applied first.  Cokernel counts
refer only to the residual projection-collision pairs left after that quotient.
"""

from finite_graph.union_find import find_root, union
from psc.joint_local_census import ObservationKey
from psc.joint_local_type import JointLocalType, same_joint_local_type
from psc.loop_quotient_census import (
    AddressedJointLocalSample,
    address_is_one_synchronous_extension,
)
from psc.renewal import Diff3
from psc.renewal_address import (
    RelativeRenewalAddress,
    RenewalAddressTables,
    build_renewal_address_tables,
    same_relative_address,
)


struct CokernelLattice(Copyable, Movable):
    """Integer columns of M^k and the exact nonzero determinant."""

    var level: Int
    var c0: Diff3
    var c1: Diff3
    var c2: Diff3
    var determinant: Int

    def __init__(
        out self,
        level: Int,
        c0: Diff3,
        c1: Diff3,
        c2: Diff3,
        determinant: Int,
    ):
        self.level = level
        self.c0 = c0.copy()
        self.c1 = c1.copy()
        self.c2 = c2.copy()
        self.determinant = determinant

    def order(self) -> Int:
        if self.determinant < 0:
            return -self.determinant
        return self.determinant


struct SidewisePrefixTranslation(Copyable, Movable):
    """Exact top/bottom prefix translations before finite quotienting."""

    var top: Diff3
    var bottom: Diff3

    def __init__(out self, top: Diff3, bottom: Diff3):
        self.top = top.copy()
        self.bottom = bottom.copy()


struct SidewiseCokernelAudit(Copyable, Movable):
    """Residual collision accounting after symbolic and cokernel refinements."""

    var sample_count: Int
    var projection_collision_pair_count: Int
    var symbolic_quotiented_pair_count: Int
    var residual_pair_count: Int
    var same_depth_residual_pair_count: Int
    var cokernel_level: Int
    var cokernel_order: Int
    var cokernel_surviving_pair_count: Int
    var cokernel_separated_pair_count: Int
    var same_depth_cokernel_surviving_pair_count: Int
    var exact_sidewise_surviving_pair_count: Int
    var first_cokernel_survivor_left: Int
    var first_cokernel_survivor_right: Int

    def __init__(
        out self,
        sample_count: Int,
        projection_collision_pair_count: Int,
        symbolic_quotiented_pair_count: Int,
        residual_pair_count: Int,
        same_depth_residual_pair_count: Int,
        cokernel_level: Int,
        cokernel_order: Int,
        cokernel_surviving_pair_count: Int,
        cokernel_separated_pair_count: Int,
        same_depth_cokernel_surviving_pair_count: Int,
        exact_sidewise_surviving_pair_count: Int,
        first_cokernel_survivor_left: Int,
        first_cokernel_survivor_right: Int,
    ):
        self.sample_count = sample_count
        self.projection_collision_pair_count = projection_collision_pair_count
        self.symbolic_quotiented_pair_count = symbolic_quotiented_pair_count
        self.residual_pair_count = residual_pair_count
        self.same_depth_residual_pair_count = same_depth_residual_pair_count
        self.cokernel_level = cokernel_level
        self.cokernel_order = cokernel_order
        self.cokernel_surviving_pair_count = cokernel_surviving_pair_count
        self.cokernel_separated_pair_count = cokernel_separated_pair_count
        self.same_depth_cokernel_surviving_pair_count = (
            same_depth_cokernel_surviving_pair_count
        )
        self.exact_sidewise_surviving_pair_count = exact_sidewise_surviving_pair_count
        self.first_cokernel_survivor_left = first_cokernel_survivor_left
        self.first_cokernel_survivor_right = first_cokernel_survivor_right

    def has_cokernel_survivor(self) -> Bool:
        return self.cokernel_surviving_pair_count > 0


def _add(a: Diff3, b: Diff3) -> Diff3:
    return Diff3(a.x + b.x, a.y + b.y, a.z + b.z)


def _sub(a: Diff3, b: Diff3) -> Diff3:
    return Diff3(a.x - b.x, a.y - b.y, a.z - b.z)


def _det_columns(a: Diff3, b: Diff3, c: Diff3) -> Int:
    return (
        a.x * (b.y * c.z - b.z * c.y)
        - b.x * (a.y * c.z - a.z * c.y)
        + c.x * (a.y * b.z - a.z * b.y)
    )


def build_cokernel_lattice(
    tables: RenewalAddressTables, level: Int
) raises -> CokernelLattice:
    if level <= 0 or level > tables.depth:
        raise Error("cokernel level must lie in 1..prepared depth")
    var c0 = tables.image_parikh(level, 0)
    var c1 = tables.image_parikh(level, 1)
    var c2 = tables.image_parikh(level, 2)
    var determinant = _det_columns(c0, c1, c2)
    if determinant == 0:
        raise Error("finite cokernel requires full-rank incidence power")
    return CokernelLattice(level, c0, c1, c2, determinant)


def same_cokernel_class(
    lattice: CokernelLattice, a: Diff3, b: Diff3
) -> Bool:
    """Exact equality in Z^3 / M^k Z^3 by integer divisibility."""
    var v = _sub(a, b)
    var n0 = _det_columns(v, lattice.c1, lattice.c2)
    var n1 = _det_columns(lattice.c0, v, lattice.c2)
    var n2 = _det_columns(lattice.c0, lattice.c1, v)
    return (
        n0 % lattice.determinant == 0
        and n1 % lattice.determinant == 0
        and n2 % lattice.determinant == 0
    )


def _side_prefix_from_digits(
    tables: RenewalAddressTables,
    source_letter: Int,
    digits: List[Int],
    address_level: Int,
) raises -> Diff3:
    if address_level <= 0 or address_level > tables.depth:
        raise Error("sidewise prefix address level lies outside prepared tables")
    if len(digits) != 2 * address_level:
        raise Error("sidewise prefix digit length does not match address level")
    if source_letter < 0 or source_letter >= 3:
        raise Error("sidewise prefix source letter lies outside 0..2")

    var prefix = Diff3(0, 0, 0)
    var current = source_letter
    var level = address_level
    for t in range(address_level):
        var parent = digits[2 * t]
        var child_index = digits[2 * t + 1]
        if parent != current:
            raise Error("sidewise prefix digit parent does not follow substitution path")
        if child_index < 0 or child_index >= len(tables.sigma[parent]):
            raise Error("sidewise prefix child index lies outside parent image")

        for j in range(child_index):
            var skipped = tables.sigma[parent][j]
            prefix = _add(prefix, tables.image_parikh(level - 1, skipped))
        current = tables.sigma[parent][child_index]
        level -= 1

    return prefix^


def sidewise_prefix_translation(
    tables: RenewalAddressTables, address: RelativeRenewalAddress
) raises -> SidewisePrefixTranslation:
    """Reconstruct both exact within-supertile prefixes and recheck correction."""
    var top = _side_prefix_from_digits(
        tables,
        address.top_source_letter,
        address.top_digits,
        address.level,
    )
    var bottom = _side_prefix_from_digits(
        tables,
        address.bottom_source_letter,
        address.bottom_digits,
        address.level,
    )
    if _sub(top, bottom) != address.correction:
        raise Error("sidewise prefix translations do not reproduce correction")
    return SidewisePrefixTranslation(top, bottom)


def _rotate_hash(x: UInt64) -> UInt64:
    return (x << 7) | (x >> 57)


def _mix_hash(state: UInt64, value: UInt64) -> UInt64:
    return _rotate_hash(state) ^ value


def _projection_fingerprint(projection: JointLocalType) -> UInt64:
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


def audit_sidewise_cokernel(
    samples: List[AddressedJointLocalSample],
    sigma: List[List[Int]],
    cokernel_level: Int,
) raises -> SidewiseCokernelAudit:
    """Refine residual same-specimen collisions by paired finite cokernel classes."""
    if cokernel_level <= 0:
        raise Error("sidewise cokernel level must be positive")

    var prepared_depth = cokernel_level
    for i in range(len(samples)):
        if samples[i].depth > prepared_depth:
            prepared_depth = samples[i].depth
    var tables = build_renewal_address_tables(sigma, prepared_depth)
    var lattice = build_cokernel_lattice(tables, cokernel_level)

    if len(samples) == 0:
        return SidewiseCokernelAudit(
            0, 0, 0, 0, 0, cokernel_level, lattice.order(), 0, 0, 0, 0, -1, -1
        )

    var specimen_id = samples[0].specimen_id
    var source_radius = samples[0].projection.source_radius
    var digit_window = samples[0].projection.digit_window
    for i in range(len(samples)):
        if samples[i].specimen_id != specimen_id:
            raise Error("sidewise cokernel audit requires one specimen provenance")
        if samples[i].address.level != samples[i].depth:
            raise Error("sidewise cokernel sample depth/address level mismatch")
        if (
            samples[i].projection.source_radius != source_radius
            or samples[i].projection.digit_window != digit_window
        ):
            raise Error("sidewise cokernel audit cannot mix projection bounds")

    var translations = List[SidewisePrefixTranslation]()
    for i in range(len(samples)):
        translations.append(sidewise_prefix_translation(tables, samples[i].address))

    var seen = Dict[ObservationKey, Int](capacity=len(samples))
    var unique = List[Int]()
    for i in range(len(samples)):
        var key = ObservationKey(
            samples[i].specimen_id, samples[i].depth, samples[i].cut
        )
        if key in seen:
            var prior = seen[key]
            if (
                not same_joint_local_type(
                    samples[i].projection, samples[prior].projection
                )
                or not same_relative_address(samples[i].address, samples[prior].address)
            ):
                raise Error("duplicate sidewise-cokernel observation has conflicting evidence")
            continue
        seen[key.copy()] = i
        unique.append(i)

    var next_member = List[Int]()
    var parent = List[Int]()
    for i in range(len(samples)):
        next_member.append(-1)
        parent.append(i)

    var heads = Dict[UInt64, Int](capacity=len(unique))
    var group_representatives = List[Int]()
    var group_counts = List[Int]()
    var next_group = List[Int]()
    var group_member_head = List[Int]()
    var projection_collisions = 0

    for q in range(len(unique)):
        var i = unique[q]
        var fingerprint = _projection_fingerprint(samples[i].projection)
        var group = -1
        if fingerprint in heads:
            group = heads[fingerprint]

        var matched = -1
        while group >= 0:
            if same_joint_local_type(
                samples[i].projection,
                samples[group_representatives[group]].projection,
            ):
                matched = group
                break
            group = next_group[group]

        if matched < 0:
            matched = len(group_representatives)
            group_representatives.append(i)
            group_counts.append(0)
            group_member_head.append(-1)
            if fingerprint in heads:
                next_group.append(heads[fingerprint])
            else:
                next_group.append(-1)
            heads[fingerprint] = matched

        projection_collisions += group_counts[matched]
        group_counts[matched] += 1
        next_member[i] = group_member_head[matched]
        group_member_head[matched] = i

    for g in range(len(group_representatives)):
        if group_counts[g] < 2:
            continue
        var left = group_member_head[g]
        while left >= 0:
            var right = next_member[left]
            while right >= 0:
                if samples[left].depth + 1 == samples[right].depth:
                    if address_is_one_synchronous_extension(
                        samples[left].address, samples[right].address
                    ):
                        union(parent, left, right)
                elif samples[right].depth + 1 == samples[left].depth:
                    if address_is_one_synchronous_extension(
                        samples[right].address, samples[left].address
                    ):
                        union(parent, left, right)
                right = next_member[right]
            left = next_member[left]

    var symbolic_quotiented = 0
    var residual_pairs = 0
    var same_depth_residual = 0
    var cokernel_survivors = 0
    var cokernel_separated = 0
    var same_depth_cokernel_survivors = 0
    var exact_sidewise_survivors = 0
    var first_survivor_left = -1
    var first_survivor_right = -1

    for g in range(len(group_representatives)):
        if group_counts[g] < 2:
            continue
        var left = group_member_head[g]
        while left >= 0:
            var right = next_member[left]
            while right >= 0:
                if find_root(parent, left) == find_root(parent, right):
                    symbolic_quotiented += 1
                else:
                    residual_pairs += 1
                    var same_depth = samples[left].depth == samples[right].depth
                    if same_depth:
                        same_depth_residual += 1

                    var exact_same = (
                        translations[left].top == translations[right].top
                        and translations[left].bottom == translations[right].bottom
                    )
                    if exact_same:
                        exact_sidewise_survivors += 1

                    var same_finite = (
                        same_cokernel_class(
                            lattice, translations[left].top, translations[right].top
                        )
                        and same_cokernel_class(
                            lattice,
                            translations[left].bottom,
                            translations[right].bottom,
                        )
                    )
                    if same_finite:
                        cokernel_survivors += 1
                        if same_depth:
                            same_depth_cokernel_survivors += 1
                        if first_survivor_left < 0:
                            first_survivor_left = left
                            first_survivor_right = right
                    else:
                        cokernel_separated += 1
                right = next_member[right]
            left = next_member[left]

    if symbolic_quotiented + residual_pairs != projection_collisions:
        raise Error("sidewise cokernel symbolic accounting failed")
    if cokernel_survivors + cokernel_separated != residual_pairs:
        raise Error("sidewise cokernel refinement accounting failed")
    if exact_sidewise_survivors > cokernel_survivors:
        raise Error("exact sidewise survivors must survive every finite cokernel")

    return SidewiseCokernelAudit(
        len(unique),
        projection_collisions,
        symbolic_quotiented,
        residual_pairs,
        same_depth_residual,
        cokernel_level,
        lattice.order(),
        cokernel_survivors,
        cokernel_separated,
        same_depth_cokernel_survivors,
        exact_sidewise_survivors,
        first_survivor_left,
        first_survivor_right,
    )
