"""Finite relative hierarchy-offset state for asynchronous C4 cut ancestry.

This is the canonical Mojo implementation. The hot representation is compact:
- the strict derived component is already interned to Int state IDs;
- ancestry defect/correction are fixed three-scalar vectors;
- orientation is a single +/-1 bit;
- derived contexts are packed Int symbols with one sentinel value.

Absolute block indices are discarded. Their difference is bounded by the
physical cut displacement, which equals the sum of the Parikh defect. In the
PIP strict regime the ancestry defect comes from the finite alphabet proved by
PR #30, so the resulting relative state space is finite at fixed context radius.

The primary constructor consumes an already-certified ancestry defect. This is
the intended hot path: callers walking an ancestry tower already have that
defect and should not re-expand sigma^k(u), sigma^k(v) merely to recompute it.
A slower verification wrapper remains available for independent cross-checks.
"""

from psc.derived_system import (
    DerivedSystem,
    context_around_block,
    locate_physical_cut,
    oriented_derived_word,
    physical_length,
)
from psc.legal_tower import apply_substitution_n


struct Vec3(Copyable, Movable, Equatable, Writable):
    var x: Int
    var y: Int
    var z: Int

    def __init__(out self, x: Int, y: Int, z: Int):
        self.x = x
        self.y = y
        self.z = z

    def __eq__(self, other: Vec3) -> Bool:
        return self.x == other.x and self.y == other.y and self.z == other.z

    def __ne__(self, other: Vec3) -> Bool:
        return not (self == other)

    def total(self) -> Int:
        return self.x + self.y + self.z

    def write_to[W: Writer](self, mut w: W):
        w.write("(", self.x, ",", self.y, ",", self.z, ")")


struct RelativeHierarchyOffset(Copyable, Movable):
    var defect: Vec3
    var correction: Vec3
    var cut_delta: Int
    var block_index_delta: Int
    var top_block_offset: Int
    var bottom_block_offset: Int
    var top_state_id: Int
    var bottom_state_id: Int
    var top_orientation: Int
    var bottom_orientation: Int
    var top_context: List[Int]
    var bottom_context: List[Int]

    def __init__(
        out self,
        defect: Vec3,
        correction: Vec3,
        cut_delta: Int,
        block_index_delta: Int,
        top_block_offset: Int,
        bottom_block_offset: Int,
        top_state_id: Int,
        bottom_state_id: Int,
        top_orientation: Int,
        bottom_orientation: Int,
        top_context: List[Int],
        bottom_context: List[Int],
    ):
        self.defect = defect.copy()
        self.correction = correction.copy()
        self.cut_delta = cut_delta
        self.block_index_delta = block_index_delta
        self.top_block_offset = top_block_offset
        self.bottom_block_offset = bottom_block_offset
        self.top_state_id = top_state_id
        self.bottom_state_id = bottom_state_id
        self.top_orientation = top_orientation
        self.bottom_orientation = bottom_orientation
        self.top_context = top_context.copy()
        self.bottom_context = bottom_context.copy()

    def same_derived_block_address(self) -> Bool:
        return (
            self.block_index_delta == 0
            and self.top_block_offset == self.bottom_block_offset
        )

    def physically_aligned(self) -> Bool:
        return self.cut_delta == 0


def _abs(x: Int) -> Int:
    if x < 0:
        return -x
    return x


def prefix_difference3(
    top: List[Int], bottom: List[Int], top_cut: Int, bottom_cut: Int
) raises -> Vec3:
    """Parikh(top[:top_cut])-Parikh(bottom[:bottom_cut]) without allocations."""
    if top_cut < 0 or top_cut > len(top) or bottom_cut < 0 or bottom_cut > len(bottom):
        raise Error("prefix cut lies outside a word")
    var x = 0
    var y = 0
    var z = 0
    for i in range(top_cut):
        if top[i] == 0:
            x += 1
        elif top[i] == 1:
            y += 1
        elif top[i] == 2:
            z += 1
        else:
            raise Error("hierarchy-offset kernel requires three-letter words")
    for i in range(bottom_cut):
        if bottom[i] == 0:
            x -= 1
        elif bottom[i] == 1:
            y -= 1
        elif bottom[i] == 2:
            z -= 1
        else:
            raise Error("hierarchy-offset kernel requires three-letter words")
    return Vec3(x, y, z)


def relative_hierarchy_offset_from_defect(
    system: DerivedSystem,
    parent_id: Int,
    source_depth: Int,
    top_cut: Int,
    bottom_cut: Int,
    defect: Vec3,
    correction: Vec3,
    radius: Int,
    parent_sign: Int = 1,
) raises -> RelativeHierarchyOffset:
    """Hot constructor from ancestry data already certified by the cut walk.

    This path deliberately does not materialize sigma^k(u) or sigma^k(v). It
    uses only the derived component, the two physical cut coordinates, and the
    defect/correction already produced by ancestry descent.
    """
    if parent_id < 0 or parent_id >= system.size():
        raise Error("parent state ID lies outside derived system")
    if source_depth < 0 or radius < 0:
        raise Error("source depth and radius must be nonnegative")
    if parent_sign != 1 and parent_sign != -1:
        raise Error("parent orientation must be +/-1")
    if top_cut < 0 or bottom_cut < 0:
        raise Error("asynchronous source cuts must be nonnegative")

    var cut_delta = top_cut - bottom_cut
    if defect.total() != cut_delta:
        raise Error("cut displacement does not equal total Parikh defect")

    var derived = oriented_derived_word(
        system, parent_id, source_depth, parent_sign
    )
    var reconstructed_length = physical_length(system, derived)
    if top_cut > reconstructed_length or bottom_cut > reconstructed_length:
        raise Error("asynchronous source cut lies outside the derived word")

    var top_pos = locate_physical_cut(system, derived, top_cut)
    var bottom_pos = locate_physical_cut(system, derived, bottom_cut)
    var block_delta = top_pos.block_index - bottom_pos.block_index
    if _abs(block_delta) > _abs(cut_delta):
        raise Error("derived block-index displacement exceeds physical cut displacement")

    var top_context = context_around_block(
        system, derived, top_pos.block_index, radius
    )
    var bottom_context = context_around_block(
        system, derived, bottom_pos.block_index, radius
    )

    return RelativeHierarchyOffset(
        defect,
        correction,
        cut_delta,
        block_delta,
        top_pos.offset,
        bottom_pos.offset,
        top_pos.state_id,
        bottom_pos.state_id,
        top_pos.sign,
        bottom_pos.sign,
        top_context,
        bottom_context,
    )


def relative_hierarchy_offset(
    sigma: List[List[Int]],
    system: DerivedSystem,
    parent_id: Int,
    source_depth: Int,
    top_cut: Int,
    bottom_cut: Int,
    correction: Vec3,
    radius: Int,
    parent_sign: Int = 1,
) raises -> RelativeHierarchyOffset:
    """Verification wrapper that independently recomputes the ancestry defect."""
    if parent_id < 0 or parent_id >= system.size():
        raise Error("parent state ID lies outside derived system")
    if source_depth < 0 or radius < 0:
        raise Error("source depth and radius must be nonnegative")
    if parent_sign != 1 and parent_sign != -1:
        raise Error("parent orientation must be +/-1")

    var parent = system.states[parent_id].copy()
    var top_base = parent.u.copy()
    var bottom_base = parent.v.copy()
    if parent_sign == -1:
        top_base = parent.v.copy()
        bottom_base = parent.u.copy()

    var top = apply_substitution_n(sigma, top_base, source_depth)
    var bottom = apply_substitution_n(sigma, bottom_base, source_depth)
    if top_cut < 0 or top_cut > len(top) or bottom_cut < 0 or bottom_cut > len(bottom):
        raise Error("asynchronous source cut lies outside an iterated side")

    var defect = prefix_difference3(top, bottom, top_cut, bottom_cut)
    return relative_hierarchy_offset_from_defect(
        system,
        parent_id,
        source_depth,
        top_cut,
        bottom_cut,
        defect,
        correction,
        radius,
        parent_sign,
    )


def state_space_upper_bound(
    defect_count: Int,
    correction_count: Int,
    max_abs_cut_delta: Int,
    component_size: Int,
    max_block_length: Int,
    radius: Int,
) raises -> Int:
    """Coarse explicit bound for the packed relative hierarchy state alphabet."""
    if (
        defect_count < 0
        or correction_count < 0
        or max_abs_cut_delta < 0
        or component_size < 0
        or max_block_length < 0
        or radius < 0
    ):
        raise Error("state-space parameters must be nonnegative")
    if defect_count == 0 or correction_count == 0:
        return 0
    if component_size == 0 or max_block_length == 0:
        raise Error("nonempty state space requires component states and block length")

    # Two orientations for each component state plus one exterior sentinel.
    var symbol_count = 2 * component_size + 1
    var context_factor = 1
    for _ in range(4 * radius):
        context_factor *= symbol_count
    return (
        defect_count
        * correction_count
        * (2 * max_abs_cut_delta + 1)
        * max_block_length
        * max_block_length
        * symbol_count
        * symbol_count
        * context_factor
    )
