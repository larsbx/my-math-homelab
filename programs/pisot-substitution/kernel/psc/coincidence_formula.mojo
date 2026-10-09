"""Strong coincidence as a formula, and the automaton that eliminates it.

## The formula

For letters `i, j` of a substitution `sigma`, strong coincidence asks

    SC(i, j)  ==  exists k, exists p :
                      p < |sigma^k(i)|,  p < |sigma^k(j)|,
                      sigma^k(i)[p] = sigma^k(j)[p],
                      l(sigma^k(i)[0..p)) = l(sigma^k(j)[0..p))

with `l` the Parikh (abelianisation) map, and `sigma` satisfies the condition
when `SC(i, j)` holds for every pair. The last conjunct is what makes this the
*strong* condition rather than a statement about letters alone: the two
occurrences must be reached after prefixes carrying the same number of each
letter, which is exactly the balanced-pair condition of `psc.bpa` and the
offset-zero condition of the overlap graph.

## Why the four automata already here do not assemble it

`psc.dumont_thomas`, `psc.numeration_addition` and `psc.numeration_conversion`
give admissibility, the letter map, addition and the conversion between the two
numerations -- the first-order theory of positions with `+` and the letter
predicates. The Parikh conjunct is not in that theory: a counting function
`n -> |u[0..n)|_a` is not in general first-order definable from `+` and the
letter predicates, which is why Walnut counts with linear representations
rather than with formulas. So the condition cannot be assembled from what was
built, and needs its own automaton.

What rescues it is that the formula never needs either count -- only that the
two are *equal*. The difference of two Parikh vectors over prefixes reached by
the same number of substitution steps stays bounded, by the Pisot property, and
a bounded integer vector is a finite-state quantity even though neither count
is.

## The automaton

Read a Dumont-Thomas path in `sigma^k(i)` and one in `sigma^k(j)` on two
tracks, synchronously, most significant digit first. At the step whose weights
are at level `m`, a path digit `d` from letter `a` skips the first `d` child
blocks of `sigma(a)`, contributing `M^m e_b` for each skipped letter `b`, where
`M[i][j]` counts letter `i` in `sigma(j)`. Accumulating with
`x <- M x + s` therefore leaves `x` equal to the Parikh vector of the prefix
(`psc.pisot_state.incidence_step`), and the automaton carries the difference

    delta <- M delta + (s_top - s_bottom),   delta_0 = 0,

alongside the two letters the paths have reached. An inadmissible digit on
either track falls into the rejecting sink, and a word is accepted exactly when
`delta = 0` and the two letters agree. Equal Parikh vectors force equal lengths,
so an accepted word is one position `p`, read in both images at once, and its
length is the level `k`. `SC(i, j)` is therefore the language being non-empty,
and the shortest accepted word is the least level at which the pair coincides,
with the two paths naming the position. The existential quantifiers are
discharged by one breadth-first search, which is the whole of the elimination.

## Finiteness is a theorem here, not an import

`M` is primitive with irreducible characteristic polynomial, screened by
`powered_field`, so its eigenvalues are the three distinct roots
`beta, beta_2, beta_3` of that cubic with `beta > 1 > |beta_2|, |beta_3|`.
Write `delta` in the eigenbasis as `a_1 u_1 + a_2 u_2 + a_3 u_3`; the step acts
coordinatewise as `a_r <- lambda_r a_r + t_r` with `|t_r|` bounded over the
finitely many `t` a step can contribute.

* For `r = 2, 3` the map contracts and `a_r` starts at zero, so
  `|a_r| <= max|t_r| / (1 - |lambda_r|)` for the whole run, with nothing to
  enforce.
* For `r = 1` the map expands, and acceptance pins it: with `v` the left Perron
  eigenvector, `v^T delta' = beta v^T delta + v^T t` exactly, so a state that
  can still reach `delta = 0` after `r` further steps satisfies
  `|v^T delta| <= sum_(m<r) beta^(-1-m) |v^T t| < max|v^T t| / (beta - 1)`.
  That is the reserve of `psc.pisot_state`, at `slack = 1`, and here it is an
  identity rather than an estimate, because `v^T` really is an eigenvector
  functional and not an asymptotic ratio.

So every kept state is a point of `Z^3` inside a bounded region, of which there
are finitely many, and the letters are three each. The exploration terminates
for every specimen it accepts, and the state cap is a guard against a defect in
this file, not a budget: exceeding it raises rather than refusing, because
unlike the explorations of `psc.numeration_addition` and
`psc.numeration_conversion` there is no theorem left to import that could make
an honest search come back empty-handed.

## What lives where

The construction -- path pairs, the Parikh-difference recursion, the state
interning, the whole-language build and the witness search -- is
`substitution_dynamics.strong_coincidence`, over an explicit alphabet and
generic over the caller's `DifferenceBound`. What is specific to this
repository is the bound itself: `PerronReserve` below steps with
`psc.pisot_state.incidence_step` and prunes with the Perron-field reserve
`within_reserve`, both in `Q(beta)` through `psc.perron_field3`, which is the
finiteness argument above made executable. The package refuses nothing on
its own account; the reserve is what makes its state cap a guard.

## What is and is not claimed

That this decides `SC(i, j)` for a specimen it is run on. Not that any
substitution family satisfies it: the condition is checked, per specimen, and
its agreement with the overlap graph's first-coincidence depths is the census's
business (`kernel/coincidence_formula_census.mojo`). Strong coincidence for the
alphabet-3 Pisot family is open, and nothing here changes that.
"""

from finite_linear_algebra.mat3 import Mat3
from finite_automata.dfa import Dfa, Witness
from psc.bpa import substitution_incidence
from psc.dumont_thomas import max_image_length
from psc.numeration_addition import powered_field
from psc.perron_field3 import CubicElt, PerronField3, TileLengths3, perron_tile_lengths_in
from psc.pisot_state import completion_reserve, incidence_step, within_reserve
from psc.words import ALPHABET
from substitution_dynamics import strong_coincidence as sd
from substitution_dynamics.strong_coincidence import (
    DifferenceBound,
    DifferenceStep,
    STATE_CAP,
    pair_paths,
)
from substitution_dynamics.substitution import Substitution


def _sub(sigma: List[List[Int]]) -> Substitution:
    # Trusted constructor over len(sigma) letters: unvalidated, as before.
    return Substitution(sigma.copy(), len(sigma))


struct IncidenceStep(DifferenceStep):
    """`M x + s` through `psc.pisot_state.incidence_step`, whose entry bounds
    are the ones the Perron-field comparison is stated for."""

    var incidence: Mat3

    def __init__(out self, sigma: List[List[Int]]):
        self.incidence = Mat3(substitution_incidence(sigma))

    def advance(self, delta: List[Int], contribution: List[Int]) raises -> List[Int]:
        return incidence_step(self.incidence, delta, contribution)


struct PerronReserve(DifferenceBound):
    """The exact reserve of the finiteness argument: a difference whose value
    at the left Perron eigenvector, times `beta - 1`, leaves
    `slack (radix - 1) sum_b v_b` can no longer be completed to zero."""

    var step: IncidenceStep
    var field: PerronField3
    var eigenvector: TileLengths3
    var reserve: CubicElt

    def __init__(out self, sigma: List[List[Int]], slack: Int) raises:
        if len(sigma) != ALPHABET:
            raise Error("this state carries one coefficient per letter of three")
        self.step = IncidenceStep(sigma)
        self.field = powered_field(sigma)
        self.eigenvector = perron_tile_lengths_in(self.field, self.step.incidence)
        self.reserve = completion_reserve(self.eigenvector, max_image_length(sigma), slack)

    def advance(self, delta: List[Int], contribution: List[Int]) raises -> List[Int]:
        return self.step.advance(delta, contribution)

    def admits(self, delta: List[Int]) raises -> Bool:
        return within_reserve(self.field, self.eigenvector, delta, self.reserve)


def coincidence_automaton(sigma: List[List[Int]], top: Int, bottom: Int) raises -> Dfa:
    """Pairs of paths of one length reaching one letter after prefixes of one
    Parikh vector, over digit pairs packed as `p + radix q`.

    The whole language. `coincidence_witness` answers the emptiness question
    without building it, and is what a caller that only wants the verdict should
    use; this is for the questions that need the automaton itself."""
    return coincidence_automaton_with(sigma, top, bottom, 1, STATE_CAP)


def parikh_equality_automaton(
    sigma: List[List[Int]], top: Int, bottom: Int
) raises -> Dfa:
    """Pairs of admissible paths of one length whose prefixes carry one Parikh
    vector, saying nothing about the letters they reach.

    This is the recognisable relation the condition needs beyond the
    numeration's own signature, and the one the elimination of
    `psc.coincidence_elimination` adds to the theory: the letter conjunct comes
    from the Dumont-Thomas letter map through the automata kernel, not from
    here. `coincidence_automaton` is this relation with the letters required to
    agree in the accepting condition instead, built directly; that the two
    routes give one language is what the regression checks."""
    return _build(sigma, top, bottom, 1, STATE_CAP, False)


def coincidence_automaton_with(
    sigma: List[List[Int]], top: Int, bottom: Int, slack: Int, cap: Int
) raises -> Dfa:
    """The construction with the pruning bound named, so a regression can widen
    it and see that the language does not move. `slack = 1` is the derived
    bound; anything larger only admits states a minimisation merges back."""
    return _build(sigma, top, bottom, slack, cap, True)


def _build(
    sigma: List[List[Int]],
    top: Int,
    bottom: Int,
    slack: Int,
    cap: Int,
    letters_must_agree: Bool,
) raises -> Dfa:
    var s = _sub(sigma)
    sd.require_letter_pair(s, top, bottom)
    return sd.coincidence_automaton(
        s, top, bottom, PerronReserve(sigma, slack), cap, letters_must_agree
    )


def coincidence_witness(sigma: List[List[Int]], top: Int, bottom: Int) raises -> Witness:
    """A shortest pair of paths witnessing `SC(top, bottom)`, or the fact that
    there is none. The word's length is the level, and `pair_paths` splits it
    into the two paths that name the position."""
    return coincidence_witness_with(sigma, top, bottom, 1, STATE_CAP)


def coincidence_witness_with(
    sigma: List[List[Int]], top: Int, bottom: Int, slack: Int, cap: Int
) raises -> Witness:
    """Breadth-first over the same state space, stopping at the first accepting
    state rather than building the whole language first: same answer as
    `witness(coincidence_automaton(...))`, which the regression checks."""
    var s = _sub(sigma)
    sd.require_letter_pair(s, top, bottom)
    return sd.coincidence_witness(s, top, bottom, PerronReserve(sigma, slack), cap)


def coincidence_level(sigma: List[List[Int]], top: Int, bottom: Int) raises -> Int:
    """The least `k` with a coincidence of the pair inside `sigma^k`, or `-1`.

    `-1` is a decided negative, not an exhausted budget: the language is empty."""
    var found = coincidence_witness(sigma, top, bottom)
    return -1 if found.empty else len(found.word)


def first_letter_merge_level(sigma: List[List[Int]], top: Int, bottom: Int) -> Int:
    """The least `n` with `h^n(top) = h^n(bottom)`, `h(a) = sigma(a)[0]` the
    first-letter map, or `-1`. Then `sigma^n(top)` and `sigma^n(bottom)` start
    with one letter, a coincidence at the left end, so `n` bounds the level.
    On three letters two orbits of `h` that ever meet do so within two steps."""
    return sd.first_letter_merge_level(_sub(sigma), top, bottom)


def balanced_proper_prefix_pairs(sigma: List[List[Int]], top: Int, bottom: Int) -> Int:
    """The number of pairs `(p, q)` of nonempty proper prefixes of
    `sigma(top)`, `sigma(bottom)` with `ab(p) = ab(q)`: the offset-zero children
    of the aligned overlap `(top, bottom, 0)` other than its leftmost one."""
    return sd.balanced_proper_prefix_pairs(_sub(sigma), top, bottom)


def strong_coincidence_level(sigma: List[List[Int]]) raises -> Int:
    """The least `k` at which *every* pair of distinct letters has coincided,
    which is the largest per-pair level, or `-1` if some pair never does.

    A pair of equal letters coincides at level zero and is not asked about."""
    var worst = 0
    for i in range(ALPHABET):
        for j in range(i + 1, ALPHABET):
            var here = coincidence_level(sigma, i, j)
            if here < 0:
                return -1
            if here > worst:
                worst = here
    return worst


def path_prefix_parikh(
    sigma: List[List[Int]], letter: Int, path: List[Int]
) raises -> List[Int]:
    """The Parikh vector of what a Dumont-Thomas path skips: the prefix of
    `sigma^|path|(letter)` before the position the path names.

    Independent of the automaton, so a witness can be checked rather than
    trusted. The position itself is the sum of the coordinates."""
    var s = _sub(sigma)
    if letter < 0 or letter >= s.size:
        raise Error("a path starts at a letter of the substitution")
    return sd.path_prefix_parikh(s, IncidenceStep(sigma), letter, path)


def path_letter(sigma: List[List[Int]], letter: Int, path: List[Int]) raises -> Int:
    """The letter a path reaches, which is the one standing at its position."""
    return sd.path_letter(_sub(sigma), letter, path)
