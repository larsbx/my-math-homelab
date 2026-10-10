"""Sofic directive shifts over a finite set of substitutions.

A directive shift is a finite set `S = {sigma_0, ..., sigma_{k-1}}` of
substitutions over one alphabet together with a deterministic automaton over
the labels `0..k-1`: `transitions[q * k + label]` is the target state, `-1`
when the label is forbidden from `q`. A full shift has one state.

Conventions (docs/sadic-kernel-g2-slice.md): a directive word
`w = w_0 ... w_{n-1}` has composite `sigma_w = sigma_{w_0} o ... o sigma_{w_{n-1}}`
(the vendored `substitution_dynamics.sadic.directive_composite`).

Named families follow V. Berthe, W. Steiner, J. M. Thuswaldner, "Geometry,
dynamics, and arithmetic of S-adic shifts", Ann. Inst. Fourier 69 (2019),
equations (3.1) and (3.4), with letters shifted to 0-based.

Reference oracle: `reference/sadic_reference`.
"""

from substitution_dynamics.sadic import apply_directive, directive_composite
from substitution_dynamics.substitution import Substitution


struct DirectiveShift(Copyable, Movable):
    var name: String
    var substitutions: List[Substitution]
    var transitions: List[Int]
    var states: Int
    var initial: Int

    def __init__(
        out self,
        name: String,
        var substitutions: List[Substitution],
        var transitions: List[Int],
        states: Int,
        initial: Int,
    ):
        # Trusted constructor: no validation. Prefer `DirectiveShift.checked`.
        self.name = name
        self.substitutions = substitutions^
        self.transitions = transitions^
        self.states = states
        self.initial = initial

    @staticmethod
    def checked(
        name: String, substitutions: List[Substitution], transitions: List[Int], initial: Int
    ) raises -> DirectiveShift:
        """Validate and construct: at least one substitution, one alphabet, a
        complete transition table with targets in range."""
        var k = len(substitutions)
        if k == 0:
            raise Error("directive shift needs at least one substitution")
        for i in range(1, k):
            if substitutions[i].size != substitutions[0].size:
                raise Error("directive shift substitutions must share one alphabet")
        if len(transitions) == 0 or len(transitions) % k != 0:
            raise Error("transition table must have one row of " + String(k) + " entries per state")
        var states = len(transitions) // k
        for t in transitions:
            if t < -1 or t >= states:
                raise Error("transition target out of range: " + String(t))
        if initial < 0 or initial >= states:
            raise Error("initial state out of range")
        return DirectiveShift(name, substitutions.copy(), transitions.copy(), states, initial)

    @staticmethod
    def full(name: String, substitutions: List[Substitution]) raises -> DirectiveShift:
        var row = List[Int]()
        for _ in range(len(substitutions)):
            row.append(0)
        return DirectiveShift.checked(name, substitutions, row, 0)

    def size(self) -> Int:
        return self.substitutions[0].size

    def labels(self) -> Int:
        return len(self.substitutions)

    def run(self, word: List[Int], state: Int) raises -> Int:
        """The state reached reading `word` from `state`, or -1."""
        var q = state
        for label in word:
            if label < 0 or label >= self.labels():
                raise Error("directive label out of range: " + String(label))
            if q < 0:
                return -1
            q = self.transitions[q * self.labels() + label]
        return q

    def admits(self, word: List[Int]) raises -> Bool:
        return self.run(word, self.initial) >= 0

    def admits_somewhere(self, word: List[Int]) raises -> Bool:
        for q in range(self.states):
            if self.run(word, q) >= 0:
                return True
        return False

    def selected(self, word: List[Int]) raises -> List[Substitution]:
        var out = List[Substitution]()
        for label in word:
            if label < 0 or label >= self.labels():
                raise Error("directive label out of range: " + String(label))
            out.append(self.substitutions[label].copy())
        return out^

    def composite(self, word: List[Int]) raises -> Substitution:
        """`sigma_{w_0} o ... o sigma_{w_{n-1}}`."""
        return directive_composite(self.selected(word))

    def image(self, word: List[Int], letter: Int) raises -> List[Int]:
        """`sigma_w(letter)` without forming the composite."""
        var w: List[Int] = [letter]
        if len(word) == 0:
            return w^
        return apply_directive(self.selected(word), w)


def arnoux_rauzy(d: Int) raises -> DirectiveShift:
    """BST19 (3.1): `alpha_i(i) = i`, `alpha_i(j) = j i`; full shift on d labels."""
    if d < 2:
        raise Error("Arnoux-Rauzy substitutions need at least two letters")
    var subs = List[Substitution]()
    for i in range(d):
        var images = List[List[Int]]()
        for j in range(d):
            if j == i:
                images.append([i])
            else:
                images.append([j, i])
        subs.append(Substitution.checked(images))
    return DirectiveShift.full("arnoux-rauzy-" + String(d), subs)


def brun3() raises -> DirectiveShift:
    """BST19 (3.4): the Brun substitutions `beta_1, beta_2, beta_3`; full shift."""
    var b1: List[List[Int]] = [[0], [1, 2], [2]]
    var b2: List[List[Int]] = [[0], [2], [1, 2]]
    var b3: List[List[Int]] = [[2], [0], [1, 2]]
    var subs = List[Substitution]()
    subs.append(Substitution.checked(b1))
    subs.append(Substitution.checked(b2))
    subs.append(Substitution.checked(b3))
    return DirectiveShift.full("brun-3", subs)


def words_of_length(labels: Int, n: Int) -> List[List[Int]]:
    """Every word of length n over `0..labels-1`, lexicographically."""
    var out = List[List[Int]]()
    out.append(List[Int]())
    for _ in range(n):
        var next = List[List[Int]]()
        for w in out:
            for a in range(labels):
                var v = w.copy()
                v.append(a)
                next.append(v^)
        out = next^
    return out^


def admissible_words(shift: DirectiveShift, n: Int) raises -> List[List[Int]]:
    """Words of length n labelling a path from the initial state, lexicographically."""
    var out = List[List[Int]]()
    for w in words_of_length(shift.labels(), n):
        if shift.admits(w):
            out.append(w.copy())
    return out^
