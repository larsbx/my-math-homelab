"""Mojo-first labelled first-return representation for the G1b-2 program.

A balanced pair `(u,v)` determines the aligned prefix-difference walk

    d_k = Parikh(u[:k]) - Parikh(v[:k]).

The cumulative difference walk is not a complete state description: a diagonal
step `(a,a)` has zero increment for every letter `a`, so distinct labelled pairs
can have exactly the same `d_k` sequence. G1b-2 must therefore retain the
ordered top/bottom transition labels rather than quotient to the unlabelled walk.

This module is deliberately compact and streaming:
- each transition label `(top,bottom)` is packed as one Int in `0..8`;
- path coordinates are stored flat as `x,y,z` triples, avoiding per-vertex
  object allocation;
- balance / first-return checks are performed during the same pass;
- no Parikh vectors or sliced subwords are allocated in the hot constructor.

It is instrumentation for the renewal-finiteness proof. Finiteness of this
representation is NOT asserted here.
"""

from psc.words import Pair


struct Diff3(Copyable, Movable, Equatable, Writable):
    var x: Int
    var y: Int
    var z: Int

    def __init__(out self, x: Int, y: Int, z: Int):
        self.x = x
        self.y = y
        self.z = z

    def __eq__(self, other: Diff3) -> Bool:
        return self.x == other.x and self.y == other.y and self.z == other.z

    def __ne__(self, other: Diff3) -> Bool:
        return not (self == other)

    def is_zero(self) -> Bool:
        return self.x == 0 and self.y == 0 and self.z == 0

    def write_to[W: Writer](self, mut w: W):
        w.write("(", self.x, ",", self.y, ",", self.z, ")")


struct LocalRenewalType(Copyable, Movable, Equatable, Writable):
    """One labelled radius-1 type around a nonterminal difference vertex.

    `left_label` is the transition entering the vertex and `right_label` is the
    transition leaving it. Both are packed ordered top/bottom letter pairs.
    """

    var defect: Diff3
    var left_label: Int
    var right_label: Int

    def __init__(out self, defect: Diff3, left_label: Int, right_label: Int):
        # `defect` is an immutable argument; copy the tiny fixed-size value
        # explicitly rather than attempting an ownership transfer.
        self.defect = defect.copy()
        self.left_label = left_label
        self.right_label = right_label

    def __eq__(self, other: LocalRenewalType) -> Bool:
        return (
            self.defect == other.defect
            and self.left_label == other.left_label
            and self.right_label == other.right_label
        )

    def __ne__(self, other: LocalRenewalType) -> Bool:
        return not (self == other)

    def write_to[W: Writer](self, mut w: W):
        w.write("{d=", self.defect, ",L=", self.left_label, ",R=", self.right_label, "}")


struct LabelledReturnWord(Copyable, Movable):
    """Exact labelled prefix-difference path of one equal-length word pair.

    `labels[k] = 3*u[k] + v[k]`.
    `path` is flat and has length `3*(n+1)`:

        path[3*k : 3*k+3] = d_k.

    `first_return` means the word is nonempty, the final defect is zero, and no
    interior defect is zero. The empty balanced pair is therefore not a return.
    """

    var labels: List[Int]
    var path: List[Int]
    var first_return: Bool

    def __init__(out self, labels: List[Int], path: List[Int], first_return: Bool):
        self.labels = labels.copy()
        self.path = path.copy()
        self.first_return = first_return

    def length(self) -> Int:
        return len(self.labels)

    def defect_at(self, k: Int) raises -> Diff3:
        if k < 0 or k > self.length():
            raise Error("renewal path index outside 0..length")
        return Diff3(self.path[3 * k], self.path[3 * k + 1], self.path[3 * k + 2])

    def balanced(self) -> Bool:
        var n = self.length()
        return (
            self.path[3 * n] == 0
            and self.path[3 * n + 1] == 0
            and self.path[3 * n + 2] == 0
        )


def _validate_letter(a: Int) raises:
    if a < 0 or a >= 3:
        raise Error("renewal letter lies outside 0..2")


def pack_step_label(top: Int, bottom: Int) raises -> Int:
    """Pack an ordered alphabet-3 pair into `0..8`."""
    _validate_letter(top)
    _validate_letter(bottom)
    return 3 * top + bottom


def label_top(code: Int) raises -> Int:
    if code < 0 or code >= 9:
        raise Error("renewal step label lies outside 0..8")
    return code // 3


def label_bottom(code: Int) raises -> Int:
    if code < 0 or code >= 9:
        raise Error("renewal step label lies outside 0..8")
    return code % 3


def _append_diff(mut path: List[Int], x: Int, y: Int, z: Int):
    path.append(x)
    path.append(y)
    path.append(z)


def labelled_return_word(pair: Pair) raises -> LabelledReturnWord:
    """Stream the exact labelled difference walk of `pair` in O(n).

    Equal side length is required because this is the aligned balanced-pair
    renewal representation used by the BPA. The result may be unbalanced or
    reducible; callers can inspect `balanced()` / `first_return` or use
    `strict_first_return_word` for the fail-closed strict contract.
    """
    if len(pair.u) != len(pair.v):
        raise Error("renewal word requires equal side lengths")

    var labels = List[Int]()
    var path = List[Int]()
    var x = 0
    var y = 0
    var z = 0
    _append_diff(path, x, y, z)
    var interior_zero = False

    for k in range(len(pair.u)):
        var a = pair.u[k]
        var b = pair.v[k]
        labels.append(pack_step_label(a, b))

        if a == 0:
            x += 1
        elif a == 1:
            y += 1
        else:
            z += 1

        if b == 0:
            x -= 1
        elif b == 1:
            y -= 1
        else:
            z -= 1

        _append_diff(path, x, y, z)
        if k + 1 < len(pair.u) and x == 0 and y == 0 and z == 0:
            interior_zero = True

    var balanced = x == 0 and y == 0 and z == 0
    var nonempty = len(pair.u) > 0
    return LabelledReturnWord(labels, path, nonempty and balanced and not interior_zero)


def strict_first_return_word(pair: Pair) raises -> LabelledReturnWord:
    """Fail closed unless `pair` is a nonempty irreducible balanced return."""
    if pair.length() <= 0:
        raise Error("strict renewal word must be nonempty")
    var out = labelled_return_word(pair)
    if not out.balanced():
        raise Error("strict renewal word must be balanced")
    if not out.first_return:
        raise Error("strict renewal word has an interior zero return")
    return out^


def same_unlabelled_path(a: LabelledReturnWord, b: LabelledReturnWord) -> Bool:
    """Compare only cumulative difference vertices, deliberately ignoring labels."""
    return a.path == b.path


def same_labelled_return(a: LabelledReturnWord, b: LabelledReturnWord) -> Bool:
    return a.path == b.path and a.labels == b.labels


def local_types(word: LabelledReturnWord) raises -> List[LocalRenewalType]:
    """Return exact `(d_k, incoming label, outgoing label)` types for 0<k<n."""
    var out = List[LocalRenewalType]()
    var n = word.length()
    for k in range(1, n):
        out.append(LocalRenewalType(word.defect_at(k), word.labels[k - 1], word.labels[k]))
    return out^


def max_l1_defect(word: LabelledReturnWord) -> Int:
    """Maximum `|x|+|y|+|z|` along the path, computed from flat storage."""
    var maximum = 0
    for k in range(word.length() + 1):
        var x = word.path[3 * k]
        var y = word.path[3 * k + 1]
        var z = word.path[3 * k + 2]
        if x < 0:
            x = -x
        if y < 0:
            y = -y
        if z < 0:
            z = -z
        var s = x + y + z
        if s > maximum:
            maximum = s
    return maximum
