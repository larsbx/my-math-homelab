"""Level-scaled symbolic renewal addresses for the G1b-2 program.

This module augments the labelled first-return representation with exact
substitution ancestry for an interior zero-return cut of sigma^depth(pair).
It deliberately stays in integer/symbolic coordinates. No inverse incidence
matrix, Euclidean stable projection, lattice assumption, or unit determinant is
used.

For a selected zero-return cut, desubstitution gives a prefix defect delta at
the source level plus two finite substitution-digit paths. Their partial-image
correction c satisfies the exact certificate

    M^depth delta + c = 0.

The record stores only the *relative* source-index displacement, source defect,
source letters, and digit paths. Absolute source indices and inflated word
length are not part of the address. The address is auxiliary data and must be
retained together with the labelled return word: distinct labelled returns can
share the same relative address.

Inflated words are never materialized. `RenewalAddressTables` precomputes all
three image lengths and image Parikh columns for levels `0..depth` once.
`RenewalPairCensusState` then validates one labelled first return once and
caches its source-supertiling boundaries and prefix Parikh vectors. A census can
reuse both layers across every candidate cut: each cut needs only logarithmic
source lookup plus the level-linear symbolic digit descent. Consumers that also
need source-local context can use `certified_renewal_cut_from_state`, which
returns the relative address together with the source locations found during
that same certification pass. The address-only API performs one independent
certification pass rather than extracting a nontrivial field from a live
aggregate, which this Mojo version forbids.
"""

from psc.renewal import Diff3, strict_first_return_word
from psc.words import Pair


struct _SourceLocation(Copyable, Movable):
    var index: Int
    var letter: Int
    var offset: Int

    def __init__(out self, index: Int, letter: Int, offset: Int):
        self.index = index
        self.letter = letter
        self.offset = offset


struct _SideAddress(Copyable, Movable):
    var digits: List[Int]
    var prefix: Diff3

    def __init__(out self, digits: List[Int], prefix: Diff3):
        self.digits = digits.copy()
        self.prefix = prefix.copy()


struct RenewalAddressTables(Copyable, Movable):
    """Reusable substitution-local tables through one requested depth.

    `lengths[3*level+a] = |sigma^level(a)|`.
    `parikhs[9*level+3*a+i]` is coordinate `i` of
    `Parikh(sigma^level(a))`, equivalently column `a` of `M^level`.

    The ordered substitution itself is retained because digit descent depends
    on child order, not merely on the incidence matrix.
    """

    var sigma: List[List[Int]]
    var depth: Int
    var lengths: List[Int]
    var parikhs: List[Int]

    def __init__(
        out self,
        sigma: List[List[Int]],
        depth: Int,
        lengths: List[Int],
        parikhs: List[Int],
    ):
        self.sigma = sigma.copy()
        self.depth = depth
        self.lengths = lengths.copy()
        self.parikhs = parikhs.copy()

    def image_length(self, level: Int, letter: Int) raises -> Int:
        if level < 0 or level > self.depth:
            raise Error("renewal-address table level lies outside 0..depth")
        if letter < 0 or letter >= 3:
            raise Error("renewal-address table letter lies outside 0..2")
        return self.lengths[3 * level + letter]

    def image_parikh(self, level: Int, letter: Int) raises -> Diff3:
        if level < 0 or level > self.depth:
            raise Error("renewal-address table level lies outside 0..depth")
        if letter < 0 or letter >= 3:
            raise Error("renewal-address table letter lies outside 0..2")
        var k = 9 * level + 3 * letter
        return Diff3(self.parikhs[k], self.parikhs[k + 1], self.parikhs[k + 2])


struct _PreparedSourceSide(Copyable, Movable):
    """One source word with cached inflated boundaries and prefix Parikh data."""

    var letters: List[Int]
    var boundaries: List[Int]
    var prefixes: List[Int]

    def __init__(
        out self,
        letters: List[Int],
        boundaries: List[Int],
        prefixes: List[Int],
    ):
        self.letters = letters.copy()
        self.boundaries = boundaries.copy()
        self.prefixes = prefixes.copy()

    def source_length(self) -> Int:
        return len(self.letters)

    def inflated_length(self) -> Int:
        return self.boundaries[len(self.boundaries) - 1]

    def prefix_at(self, index: Int) raises -> Diff3:
        if index < 0 or index > self.source_length():
            raise Error("renewal-address source prefix index is out of range")
        var k = 3 * index
        return Diff3(self.prefixes[k], self.prefixes[k + 1], self.prefixes[k + 2])


struct RenewalPairCensusState(Copyable, Movable):
    """Reusable source-pair metadata for a many-cut renewal census.

    Construction validates the strict labelled first-return contract once,
    prepares both source sides once, and binds them to one substitution/depth
    table. No `LabelledReturnWord` is rebuilt by per-cut address queries.
    """

    var tables: RenewalAddressTables
    var top: _PreparedSourceSide
    var bottom: _PreparedSourceSide
    var inflated_length: Int

    def __init__(
        out self,
        tables: RenewalAddressTables,
        top: _PreparedSourceSide,
        bottom: _PreparedSourceSide,
        inflated_length: Int,
    ):
        self.tables = RenewalAddressTables(
            tables.sigma,
            tables.depth,
            tables.lengths,
            tables.parikhs,
        )
        self.top = _PreparedSourceSide(top.letters, top.boundaries, top.prefixes)
        self.bottom = _PreparedSourceSide(
            bottom.letters, bottom.boundaries, bottom.prefixes
        )
        self.inflated_length = inflated_length

    def source_length(self) -> Int:
        return self.top.source_length()


struct RelativeRenewalAddress(Copyable, Movable):
    """Relative symbolic address of one inflated interior renewal cut.

    `top_digits` and `bottom_digits` are flat `(parent_letter, child_index)`
    pairs, one pair per substitution level. Child letters are determined by
    sigma and are therefore not duplicated in the record.
    """

    var level: Int
    var source_index_delta: Int
    var source_defect: Diff3
    var top_source_letter: Int
    var bottom_source_letter: Int
    var top_digits: List[Int]
    var bottom_digits: List[Int]
    var scaled_defect: Diff3
    var correction: Diff3

    def __init__(
        out self,
        level: Int,
        source_index_delta: Int,
        source_defect: Diff3,
        top_source_letter: Int,
        bottom_source_letter: Int,
        top_digits: List[Int],
        bottom_digits: List[Int],
        scaled_defect: Diff3,
        correction: Diff3,
    ):
        self.level = level
        self.source_index_delta = source_index_delta
        self.source_defect = source_defect.copy()
        self.top_source_letter = top_source_letter
        self.bottom_source_letter = bottom_source_letter
        self.top_digits = top_digits.copy()
        self.bottom_digits = bottom_digits.copy()
        self.scaled_defect = scaled_defect.copy()
        self.correction = correction.copy()

    def digit_levels(self) -> Int:
        return len(self.top_digits) // 2

    def certificate_closes(self) -> Bool:
        return (
            self.scaled_defect.x + self.correction.x == 0
            and self.scaled_defect.y + self.correction.y == 0
            and self.scaled_defect.z + self.correction.z == 0
        )


struct CertifiedRenewalCut(Copyable, Movable):
    """Certified address plus the two source locations used to construct it.

    Absolute source indices are deliberately kept outside
    `RelativeRenewalAddress`; they are plumbing for consumers that need local
    source context and are not part of the relative mathematical address.
    The wrapper constructs the address directly from its components, so there
    is no additional whole-address copy in the joint-census path.
    """

    var address: RelativeRenewalAddress
    var top_source_index: Int
    var bottom_source_index: Int

    def __init__(
        out self,
        level: Int,
        source_index_delta: Int,
        source_defect: Diff3,
        top_source_letter: Int,
        bottom_source_letter: Int,
        top_digits: List[Int],
        bottom_digits: List[Int],
        scaled_defect: Diff3,
        correction: Diff3,
        top_source_index: Int,
        bottom_source_index: Int,
    ):
        self.address = RelativeRenewalAddress(
            level,
            source_index_delta,
            source_defect,
            top_source_letter,
            bottom_source_letter,
            top_digits,
            bottom_digits,
            scaled_defect,
            correction,
        )
        self.top_source_index = top_source_index
        self.bottom_source_index = bottom_source_index


def _validate_sigma(sigma: List[List[Int]]) raises:
    if len(sigma) != 3:
        raise Error("renewal-address kernel requires a three-letter substitution")
    for a in range(3):
        if len(sigma[a]) == 0:
            raise Error("renewal-address substitution must be non-erasing")
        for j in range(len(sigma[a])):
            if sigma[a][j] < 0 or sigma[a][j] >= 3:
                raise Error("renewal-address substitution letter lies outside 0..2")


def _add(a: Diff3, b: Diff3) -> Diff3:
    return Diff3(a.x + b.x, a.y + b.y, a.z + b.z)


def _sub(a: Diff3, b: Diff3) -> Diff3:
    return Diff3(a.x - b.x, a.y - b.y, a.z - b.z)


def _append_diff(mut out: List[Int], x: Int, y: Int, z: Int):
    out.append(x)
    out.append(y)
    out.append(z)


def build_renewal_address_tables(
    sigma: List[List[Int]], depth: Int
) raises -> RenewalAddressTables:
    """Precompute image lengths and Parikh columns once for `0..depth`."""
    _validate_sigma(sigma)
    if depth < 0:
        raise Error("renewal-address depth must be nonnegative")

    var current_lengths: List[Int] = [1, 1, 1]
    var current_parikhs: List[Int] = [1, 0, 0, 0, 1, 0, 0, 0, 1]
    var all_lengths = current_lengths.copy()
    var all_parikhs = current_parikhs.copy()

    for _ in range(depth):
        var next_lengths: List[Int] = [0, 0, 0]
        var next_parikhs: List[Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
        for a in range(3):
            for j in range(len(sigma[a])):
                var child = sigma[a][j]
                next_lengths[a] += current_lengths[child]
                next_parikhs[3 * a] += current_parikhs[3 * child]
                next_parikhs[3 * a + 1] += current_parikhs[3 * child + 1]
                next_parikhs[3 * a + 2] += current_parikhs[3 * child + 2]
        for a in range(3):
            all_lengths.append(next_lengths[a])
        for k in range(9):
            all_parikhs.append(next_parikhs[k])
        current_lengths = next_lengths^
        current_parikhs = next_parikhs^

    return RenewalAddressTables(sigma, depth, all_lengths, all_parikhs)


def _prepare_source_side(
    word: List[Int], tables: RenewalAddressTables
) raises -> _PreparedSourceSide:
    var boundaries = List[Int]()
    var prefixes = List[Int]()
    boundaries.append(0)
    _append_diff(prefixes, 0, 0, 0)

    var cursor = 0
    var x = 0
    var y = 0
    var z = 0
    for i in range(len(word)):
        var a = word[i]
        if a < 0 or a >= 3:
            raise Error("renewal-address word letter lies outside 0..2")
        cursor += tables.image_length(tables.depth, a)
        boundaries.append(cursor)
        if a == 0:
            x += 1
        elif a == 1:
            y += 1
        else:
            z += 1
        _append_diff(prefixes, x, y, z)

    return _PreparedSourceSide(word, boundaries, prefixes)


def build_renewal_pair_census_state(
    tables: RenewalAddressTables, pair: Pair
) raises -> RenewalPairCensusState:
    """Validate and prepare one source pair once for many cut queries."""
    if tables.depth <= 0:
        raise Error("renewal-address depth must be positive")

    var checked = strict_first_return_word(pair)
    if not checked.first_return:
        raise Error("renewal-address source pair is not a first return")

    var top = _prepare_source_side(pair.u, tables)
    var bottom = _prepare_source_side(pair.v, tables)
    var top_length = top.inflated_length()
    var bottom_length = bottom.inflated_length()
    if top_length != bottom_length:
        raise Error("balanced renewal pair has unequal inflated side lengths")

    return RenewalPairCensusState(tables, top, bottom, top_length)


def _locate_prepared_source(
    side: _PreparedSourceSide, cut: Int
) raises -> _SourceLocation:
    if cut < 0 or cut >= side.inflated_length():
        raise Error("renewal-address cut must select a source supertile")

    var lo = 0
    var hi = side.source_length()
    while lo < hi:
        var mid = (lo + hi) // 2
        if side.boundaries[mid + 1] <= cut:
            lo = mid + 1
        else:
            hi = mid
    var index = lo
    return _SourceLocation(
        index,
        side.letters[index],
        cut - side.boundaries[index],
    )


def _prefix_inside_source_letter(
    tables: RenewalAddressTables,
    source_letter: Int,
    offset: Int,
) raises -> _SideAddress:
    """Descend one cut through sigma^depth(source_letter) using cached tables."""
    if tables.depth <= 0:
        raise Error("renewal-address symbolic path requires positive depth")
    if offset < 0 or offset >= tables.image_length(tables.depth, source_letter):
        raise Error("renewal-address within-supertile offset is out of range")

    var digits = List[Int]()
    var prefix = Diff3(0, 0, 0)
    var current_letter = source_letter
    var residual = offset
    var level = tables.depth

    while level > 0:
        var child_start = 0
        var found = False
        for j in range(len(tables.sigma[current_letter])):
            var child = tables.sigma[current_letter][j]
            var block_length = tables.image_length(level - 1, child)
            if residual < child_start + block_length:
                digits.append(current_letter)
                digits.append(j)
                residual -= child_start
                current_letter = child
                found = True
                break
            prefix = _add(prefix, tables.image_parikh(level - 1, child))
            child_start += block_length
        if not found:
            raise Error("renewal-address digit descent failed to select a child")
        level -= 1

    if residual != 0:
        raise Error("renewal-address leaf residual must vanish")
    return _SideAddress(digits, prefix)


def _scale_defect(tables: RenewalAddressTables, defect: Diff3) raises -> Diff3:
    var c0 = tables.image_parikh(tables.depth, 0)
    var c1 = tables.image_parikh(tables.depth, 1)
    var c2 = tables.image_parikh(tables.depth, 2)
    return Diff3(
        defect.x * c0.x + defect.y * c1.x + defect.z * c2.x,
        defect.x * c0.y + defect.y * c1.y + defect.z * c2.y,
        defect.x * c0.z + defect.y * c1.z + defect.z * c2.z,
    )


def same_relative_address(a: RelativeRenewalAddress, b: RelativeRenewalAddress) -> Bool:
    return (
        a.level == b.level
        and a.source_index_delta == b.source_index_delta
        and a.source_defect == b.source_defect
        and a.top_source_letter == b.top_source_letter
        and a.bottom_source_letter == b.bottom_source_letter
        and a.top_digits == b.top_digits
        and a.bottom_digits == b.bottom_digits
        and a.scaled_defect == b.scaled_defect
        and a.correction == b.correction
    )


def certified_renewal_cut_from_state(
    state: RenewalPairCensusState, cut: Int
) raises -> CertifiedRenewalCut:
    """Certify one cut and retain source locations from that same pass."""
    if cut <= 0 or cut >= state.inflated_length:
        raise Error("renewal-address cut must be interior")

    var top = _locate_prepared_source(state.top, cut)
    var bottom = _locate_prepared_source(state.bottom, cut)
    var top_side = _prefix_inside_source_letter(
        state.tables, top.letter, top.offset
    )
    var bottom_side = _prefix_inside_source_letter(
        state.tables, bottom.letter, bottom.offset
    )

    var top_prefix = state.top.prefix_at(top.index)
    var bottom_prefix = state.bottom.prefix_at(bottom.index)
    var defect = _sub(top_prefix, bottom_prefix)
    var source_index_delta = top.index - bottom.index
    if defect.x + defect.y + defect.z != source_index_delta:
        raise Error("renewal-address source displacement/defect identity failed")

    var scaled = _scale_defect(state.tables, defect)
    var correction = _sub(top_side.prefix, bottom_side.prefix)
    var closure = _add(scaled, correction)
    if not closure.is_zero():
        raise Error("renewal-address cut is not a zero return")

    return CertifiedRenewalCut(
        state.tables.depth,
        source_index_delta,
        defect,
        top.letter,
        bottom.letter,
        top_side.digits,
        bottom_side.digits,
        scaled,
        correction,
        top.index,
        bottom.index,
    )


def renewal_cut_address_from_state(
    state: RenewalPairCensusState, cut: Int
) raises -> RelativeRenewalAddress:
    """Address one cut without rebuilding source-pair metadata.

    This intentionally performs its own single certification pass rather than
    extracting `address` from `CertifiedRenewalCut`: moving a nontrivial field
    out of a live aggregate is not legal in the pinned Mojo toolchain.
    """
    if cut <= 0 or cut >= state.inflated_length:
        raise Error("renewal-address cut must be interior")

    var top = _locate_prepared_source(state.top, cut)
    var bottom = _locate_prepared_source(state.bottom, cut)
    var top_side = _prefix_inside_source_letter(
        state.tables, top.letter, top.offset
    )
    var bottom_side = _prefix_inside_source_letter(
        state.tables, bottom.letter, bottom.offset
    )

    var top_prefix = state.top.prefix_at(top.index)
    var bottom_prefix = state.bottom.prefix_at(bottom.index)
    var defect = _sub(top_prefix, bottom_prefix)
    var source_index_delta = top.index - bottom.index
    if defect.x + defect.y + defect.z != source_index_delta:
        raise Error("renewal-address source displacement/defect identity failed")

    var scaled = _scale_defect(state.tables, defect)
    var correction = _sub(top_side.prefix, bottom_side.prefix)
    var closure = _add(scaled, correction)
    if not closure.is_zero():
        raise Error("renewal-address cut is not a zero return")

    return RelativeRenewalAddress(
        state.tables.depth,
        source_index_delta,
        defect,
        top.letter,
        bottom.letter,
        top_side.digits,
        bottom_side.digits,
        scaled,
        correction,
    )


def renewal_cut_address_with_tables(
    tables: RenewalAddressTables, pair: Pair, cut: Int
) raises -> RelativeRenewalAddress:
    """One-off address using precomputed substitution tables.

    Many-cut callers should additionally build `RenewalPairCensusState` once
    and use `renewal_cut_address_from_state` for each candidate cut.
    """
    var state = build_renewal_pair_census_state(tables, pair)
    return renewal_cut_address_from_state(state, cut)


def renewal_cut_address(
    sigma: List[List[Int]], pair: Pair, depth: Int, cut: Int
) raises -> RelativeRenewalAddress:
    """Convenience wrapper for one address; census callers should prepare state."""
    var tables = build_renewal_address_tables(sigma, depth)
    var state = build_renewal_pair_census_state(tables, pair)
    return renewal_cut_address_from_state(state, cut)
