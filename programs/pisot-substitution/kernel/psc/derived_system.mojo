"""Mojo-native derived substitution for a finite strict BPA component.

Construction validates the mathematical contract once, interns normalized
balanced states once, and then stores every derived child as an integer state ID
plus one orientation bit. Hot derived-word expansion therefore avoids string
keys and Pair copies; strings are confined to the one-time interning boundary.
"""

from psc.bpa import apply_substitution, coincidence_boundaries, decompose, normalise
from psc.words import Pair, is_balanced


struct OrientedSymbol(Copyable, Movable, Equatable, Writable):
    var state_id: Int
    var sign: Int

    def __init__(out self, state_id: Int, sign: Int):
        self.state_id = state_id
        self.sign = sign

    def __eq__(self, other: OrientedSymbol) -> Bool:
        return self.state_id == other.state_id and self.sign == other.sign

    def __ne__(self, other: OrientedSymbol) -> Bool:
        return not (self == other)

    def write_to[W: Writer](self, mut w: W):
        w.write("(", self.state_id, ",", self.sign, ")")


struct BlockPosition(Copyable, Movable, Equatable):
    """Right-continuous position in an oriented derived word.

    `state_id == -1` and `sign == 0` encode the terminal boundary.
    """

    var block_index: Int
    var offset: Int
    var state_id: Int
    var sign: Int

    def __init__(out self, block_index: Int, offset: Int, state_id: Int, sign: Int):
        self.block_index = block_index
        self.offset = offset
        self.state_id = state_id
        self.sign = sign

    def __eq__(self, other: BlockPosition) -> Bool:
        return (
            self.block_index == other.block_index
            and self.offset == other.offset
            and self.state_id == other.state_id
            and self.sign == other.sign
        )

    def __ne__(self, other: BlockPosition) -> Bool:
        return not (self == other)

    def terminal(self) -> Bool:
        return self.state_id == -1


struct DerivedSystem(Copyable, Movable):
    """Strict derived substitution indexed by compact integer state IDs."""

    var states: List[Pair]
    var images: List[List[Int]]
    var child_signs: List[List[Int]]
    var block_lengths: List[Int]

    def __init__(
        out self,
        states: List[Pair],
        images: List[List[Int]],
        child_signs: List[List[Int]],
        block_lengths: List[Int],
    ):
        self.states = states.copy()
        self.images = images.copy()
        self.child_signs = child_signs.copy()
        self.block_lengths = block_lengths.copy()

    def size(self) -> Int:
        return len(self.states)


def build_derived_system(
    sigma: List[List[Int]], comp: List[Pair]
) raises -> DerivedSystem:
    """Validate and intern a finite strict child-closed irreducible component."""
    if len(comp) == 0:
        raise Error("strict component must be nonempty")

    var states = List[Pair]()
    var lengths = List[Int]()
    var index = Dict[String, Int]()

    # One-time normalization/interning boundary. Downstream hot loops use Int IDs.
    for i in range(len(comp)):
        var state = normalise(comp[i])
        if not is_balanced(state):
            raise Error("strict component contains an unbalanced state")
        if state.is_coincidence():
            raise Error("strict component contains a coincidence state")
        var boundaries = coincidence_boundaries(state.u, state.v)
        if len(boundaries) != 2 or boundaries[0] != 0 or boundaries[1] != state.length():
            raise Error("strict component contains a reducible balanced state")
        var key = state.key()
        if key in index:
            raise Error("strict component contains duplicate normalized states")
        index[key] = len(states)
        lengths.append(state.length())
        states.append(state.copy())

    var images = List[List[Int]]()
    var signs = List[List[Int]]()
    for parent_id in range(len(states)):
        var parent = states[parent_id].copy()
        var top = apply_substitution(sigma, parent.u)
        var bottom = apply_substitution(sigma, parent.v)
        var raw_children = decompose(top, bottom)
        if len(raw_children) == 0:
            raise Error("strict state has no balanced child factorization")

        var child_ids = List[Int]()
        var child_signs = List[Int]()
        for j in range(len(raw_children)):
            var raw = raw_children[j].copy()
            var child = normalise(raw)
            if child.is_coincidence():
                raise Error("strict component has a coincidence child")
            var key = child.key()
            if key not in index:
                raise Error("strict component has a noncoincident child outside the component")
            var sign = 1
            if raw != child:
                sign = -1
            child_ids.append(index[key])
            child_signs.append(sign)
        images.append(child_ids^)
        signs.append(child_signs^)

    return DerivedSystem(states, images, signs, lengths)


def oriented_derived_word(
    system: DerivedSystem,
    parent_id: Int,
    depth: Int,
    parent_sign: Int = 1,
) raises -> List[OrientedSymbol]:
    """Expand `tau^depth(parent)` using integer IDs and accumulated orientation."""
    if parent_id < 0 or parent_id >= system.size():
        raise Error("parent state ID lies outside derived system")
    if depth < 0:
        raise Error("derived depth must be nonnegative")
    if parent_sign != 1 and parent_sign != -1:
        raise Error("parent orientation must be +/-1")

    var word = List[OrientedSymbol]()
    word.append(OrientedSymbol(parent_id, parent_sign))
    for _ in range(depth):
        var next = List[OrientedSymbol]()
        for i in range(len(word)):
            var state_id = word[i].state_id
            var inherited_sign = word[i].sign
            for j in range(len(system.images[state_id])):
                next.append(
                    OrientedSymbol(
                        system.images[state_id][j],
                        inherited_sign * system.child_signs[state_id][j],
                    )
                )
        word = next^
    return word^


def physical_length(system: DerivedSystem, word: List[OrientedSymbol]) raises -> Int:
    var total = 0
    for i in range(len(word)):
        var state_id = word[i].state_id
        if state_id < 0 or state_id >= system.size():
            raise Error("oriented word contains an invalid state ID")
        total += system.block_lengths[state_id]
    return total


def locate_physical_cut(
    system: DerivedSystem, word: List[OrientedSymbol], cut: Int
) raises -> BlockPosition:
    """Locate one physical cut by streaming block lengths; no boundary array."""
    if cut < 0:
        raise Error("physical cut must be nonnegative")
    var cursor = 0
    for i in range(len(word)):
        var state_id = word[i].state_id
        var end = cursor + system.block_lengths[state_id]
        if cut < end:
            return BlockPosition(i, cut - cursor, state_id, word[i].sign)
        cursor = end
    if cut == cursor:
        return BlockPosition(len(word), 0, -1, 0)
    raise Error("physical cut lies outside derived word")


def packed_symbol(system: DerivedSystem, symbol: OrientedSymbol) raises -> Int:
    """Pack `(state_id, sign)` to a nonnegative Int; reserve 2*n as sentinel."""
    if symbol.state_id < 0 or symbol.state_id >= system.size():
        raise Error("cannot pack invalid state ID")
    if symbol.sign == 1:
        return 2 * symbol.state_id
    if symbol.sign == -1:
        return 2 * symbol.state_id + 1
    raise Error("cannot pack a non-orientation sign")


def context_around_block(
    system: DerivedSystem,
    word: List[OrientedSymbol],
    block_index: Int,
    radius: Int,
) raises -> List[Int]:
    """Pack left then right radius-R derived contexts into one compact Int list.

    Sentinel value `2*system.size()` marks exterior positions. The result has
    fixed length `2*radius`, suitable for a future compact state key.
    """
    if radius < 0:
        raise Error("context radius must be nonnegative")
    if block_index < 0 or block_index > len(word):
        raise Error("block index lies outside derived word")
    var sentinel = 2 * system.size()
    var out = List[Int]()
    for delta in range(radius, 0, -1):
        var idx = block_index - delta
        if idx < 0:
            out.append(sentinel)
        else:
            out.append(packed_symbol(system, word[idx]))
    for delta in range(radius):
        var idx = block_index + delta
        if idx >= len(word):
            out.append(sentinel)
        else:
            out.append(packed_symbol(system, word[idx]))
    return out^
