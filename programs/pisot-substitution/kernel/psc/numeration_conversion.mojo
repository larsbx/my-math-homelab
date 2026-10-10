"""Converting between the two numerations a substitution carries.

The route needs its automata to speak one numeration, and the two this
repository builds are not the same presentation. A Dumont-Thomas path digit
weighs a child block, whose length depends on the letters along the path; a
greedy digit weighs `U_j = |tau^j(c)|` alone. `agrees_with_path_digits` decides
per specimen whether they coincide, and over the sampled corpus they mostly do
not. So the letter map of `psc.dumont_thomas`, which is indexed by path digits,
and the addition relation of `psc.numeration_addition`, which is recognised
over greedy digits, cannot appear in one formula until something relates them.

This module is that something. It builds

    C = { (P, G) : P an admissible path word from `c`, |G| = |P|,
                   val_path(P) = val_greedy(G) }

as a synchronous two-track automaton, and then carries the letter map across
it: `greedy_letter_automaton` is the set of digit words whose value is a
position of the fixed point carrying a given letter. With that, the letter map
and addition live in the same numeration.

## The state is three integers, and the step is the incidence matrix

Write `L_m` for the vector `L_m(b) = |tau^m(b)|`. One substitution step is
exactly one level of it:

    L_(m+1)(b) = sum over t of L_m(tau(b)[t]) = sum over b' of M[b'][b] L_m(b')

so `L_(m+1) = M^T L_m` with `M` the incidence matrix. That identity is what
makes the state small. Read both tracks most significant first and let `A_j` be
the running difference after the step whose weights are at level `j`. Keep it
as a coefficient vector against the *current* level,

    A_j = x . L_j,

and one step down is then a matrix-vector product with integer entries:

    A_(j-1) = x . L_j + s . L_(j-1) = (M x + s) . L_(j-1),  so  x <- M x + s

where `s[b]` is what this step contributes at level `j-1`: the path digit `p`
skips the first `p` child blocks of `tau(a)`, contributing one `L_(j-1)` of
each letter it skips, and the greedy digit `g` subtracts `g` copies of
`L_(j-1)(c)`. The state carries `a`, the letter the path has reached, because
the next step's blocks are its image. An inadmissible path digit falls into the
rejecting sink, and since `L_0 = (1, 1, 1)` a word is accepted exactly when the
coordinates of `x` sum to zero.

The window of three levels that `psc.numeration_addition` keeps is the right
state there, where every weight is a shift of one sequence `U`. Here three
letters each carry their own weight, and a window of three levels times three
letters would be *nine* coefficients for a value with only three degrees of
freedom: the same difference would be reached in many representations, none of
which the exploration could identify, and it diverges rather than closing. The
identity above is what removes that redundancy.

## The pruning, and what it assumes

The step is multiplication by the incidence matrix, so without pruning the
exploration diverges for the honest reason: coefficients of a state that can
never be completed grow like the expanding root. The Pisot property bounds what
the digits still to come can contribute, so a state whose value is already past
that reserve is dead. The two contracting eigendirections stay bounded by
themselves -- that is the Pisot property doing the other half of the work -- and
the reserve bounds the third.

Measuring "past the reserve" needs the value as a real number, and the three
letters' weights are not commensurable: `L_m(b)` grows like `v_b beta^m` with
`v` the left Perron eigenvector, whose entries lie in `Z[beta]` and differ
between letters. So the test is exact rather than scalar.
`perron_tile_lengths_in` constructs and verifies that eigenvector in the same
cubic field, and `psc.pisot_state` decides the comparison there: it is the
same algebra three explorations in this repository need, so it lives in one
place rather than three.

Like the bound in `psc.numeration_addition`, this one is deliberately generous,
and for a reason worth naming: the weights here are only *asymptotically*
`v_b beta^m`, since `L_m(b)` is not `v_b beta^m` at a finite level, so the
reserve is an estimate rather than an identity and the constant has to be
measured. (Where a state's weights are exactly the eigenvector's --
`psc.coincidence_formula` -- the same reserve at `slack = 1` is a theorem and
nothing has to be measured.) Pruning too little is the safe direction: it adds
states, which the cap catches, while pruning too much drops an answer nothing
catches. The regressions check acceptance on every position below a stated
bound rather than trusting the constant.

That a finite state set exists at all is the imported theorem, gated in
`docs/automatic-sequence-route-literature-gate-2026-09-17.md`. Exceeding the
cap is therefore an outcome and not an error: `BoundedAutomaton` carries it as
a refusal. Malformed input still raises.

## What this is not

`C` relates a path word to *any* digit word of the same length with the same
value, not only to the greedy one. Greedy-normality is a separate language -- a
lexicographic condition against the expansion of one -- and it is not built
here, so `greedy_letter_automaton` accepts every representation of a position
carrying the letter, greedy or not. For a decision procedure that is the useful
side of the choice, since normalisation is its own automaton there too; for a
claim about digits it is a thing that has to be said.
"""

from finite_linear_algebra.mat3 import Mat3
from finite_automata.dfa import (
    BoundedAutomaton,
    Dfa,
    cylinder,
    intersection,
    minimised,
    project,
    refusal,
    widened,
)
from psc.bpa import substitution_incidence
from psc.dumont_thomas import letter_automaton, max_image_length
from psc.linear_numeration import basis_obeys_recurrence
from psc.numeration_addition import powered_field
from psc.perron_field3 import perron_tile_lengths_in
from psc.pisot_state import completion_reserve, incidence_step, within_reserve


comptime SLACK = 3
"""How much wider than the computed reserve the pruning test is drawn.

Pruning too little only adds states, which the cap catches; pruning too much
would drop a true pair, which no cap catches. The factor sits on the safe side
of that asymmetry, because the ratios the reserve is computed from are the
limiting ones and the levels are finite. The regressions decide whether it was
enough, and `test_the_pruning_bound_does_not_decide_the_language` checks that
narrowing or widening it leaves the same minimal automaton."""


def _key(letter: Int, x: List[Int]) -> String:
    var out = String(letter)
    for i in range(len(x)):
        out += "," + String(x[i])
    return out


def conversion_automaton(
    tau: List[List[Int]], letter: Int, radix: Int, cap: Int
) raises -> BoundedAutomaton:
    """`{ (P, G) : val_path(P) = val_greedy(G) }` over pairs packed as
    `p + radix g`, the path on track zero.

    Raises on malformed input -- a radix too small to hold a path digit, a
    non-positive cap, a basis that does not obey its own recurrence. A state set
    past `cap` comes back as a refusal, which is what it is."""
    return conversion_automaton_with(tau, letter, radix, cap, SLACK)


def conversion_automaton_with(
    tau: List[List[Int]], letter: Int, radix: Int, cap: Int, slack: Int
) raises -> BoundedAutomaton:
    """The construction with the pruning bound named, so a regression can vary
    it and see that the language does not move."""
    if len(tau) != 3:
        raise Error("this state carries one coefficient per letter of three")
    if radix < max_image_length(tau):
        raise Error("the alphabet is too small to hold a path digit")
    if radix < 2:
        raise Error("a digit alphabet has at least two digits")
    if cap < 1:
        raise Error("a state cap is positive")
    if slack < 1:
        raise Error("a pruning bound is positive")
    if letter < 0 or letter >= len(tau):
        raise Error("the numeration starts at a letter of the substitution")
    if not basis_obeys_recurrence(tau, letter, 12):
        raise Error("the basis does not obey the characteristic recurrence")
    var m = Mat3(substitution_incidence(tau))
    var field = powered_field(tau)
    var v = perron_tile_lengths_in(field, m)
    var reserve = completion_reserve(v, radix, slack)

    # State 0 is the zero difference at the starting letter; state 1 is the
    # rejecting sink an inadmissible or hopeless transition falls into.
    var zero = List[Int](length=3, fill=0)
    var keys: List[String] = [_key(letter, zero), String("dead")]
    var index = Dict[String, Int]()
    index[keys[0]] = 0
    var at_letter: List[Int] = [letter, -1]
    var coefficients: List[List[Int]] = [zero.copy(), zero.copy()]
    var dead: List[Bool] = [False, True]
    var delta = List[Int]()
    var letters = radix * radix

    var done = 0
    while done < len(keys):
        for packed in range(letters):
            if dead[done]:
                delta.append(1)
                continue
            var p = packed % radix
            var g = packed // radix
            var a = at_letter[done]
            if p >= len(tau[a]):
                delta.append(1)
                continue
            var s = List[Int](length=3, fill=0)
            for t in range(p):
                s[tau[a][t]] += 1
            s[letter] -= g
            var next = incidence_step(m, coefficients[done], s)
            if not within_reserve(field, v, next, reserve):
                delta.append(1)
                continue
            var reached = tau[a][p]
            var key = _key(reached, next)
            var at = index.get(key, -1)
            if at < 0:
                if len(keys) >= cap:
                    return refusal(letters)
                keys.append(key)
                index[key] = len(keys) - 1
                at_letter.append(reached)
                coefficients.append(next.copy())
                dead.append(False)
                at = len(keys) - 1
            delta.append(at)
        done += 1

    var accepting = List[Bool]()
    for i in range(len(keys)):
        if dead[i]:
            accepting.append(False)
            continue
        ref x = coefficients[i]
        accepting.append(x[0] + x[1] + x[2] == 0)
    return BoundedAutomaton(Dfa(letters, delta, accepting), len(keys), False)


def letter_in_conversion(
    conversion: Dfa, tau: List[List[Int]], letter: Int, target: Int, radix: Int
) raises -> Dfa:
    """The letter map carried across a conversion already built.

    Separate from `greedy_letter_automaton` because the conversion is the
    expensive half and a caller asking about every letter should pay for it
    once."""
    if target < 0 or target >= len(tau):
        raise Error("the target is not a letter of the substitution")
    if conversion.letters != radix * radix:
        raise Error("the conversion is not over this pair alphabet")
    var path = cylinder(
        widened(letter_automaton(tau, letter, target), radix), 2, 0, radix
    )
    return minimised(project(intersection(conversion, path), 2, 0))


def greedy_letter_automaton(
    tau: List[List[Int]], letter: Int, target: Int, radix: Int, cap: Int
) raises -> BoundedAutomaton:
    """The letter map of the fixed point, over digit words of the linear
    numeration rather than over Dumont-Thomas paths.

    `letter_automaton` gives the positions carrying `target` as path words; this
    intersects that condition into the conversion on the path track and then
    discharges the path by the subset construction, leaving a condition on the
    digit word alone. The result is minimised, because it is the object a
    formula would be written against and its size is what is worth reporting.

    A refused conversion refuses here too, rather than being reported as an
    empty language."""
    var conversion = conversion_automaton(tau, letter, radix, cap)
    if conversion.refused:
        return refusal(radix)
    return BoundedAutomaton(
        letter_in_conversion(conversion.automaton, tau, letter, target, radix),
        conversion.explored,
        False,
    )


def pair_word(radix: Int, path: List[Int], greedy: List[Int]) raises -> List[Int]:
    """A path word and a digit word as one word over the packed pair alphabet,
    left padded with zeros to a common length.

    Padding is sound on both tracks: a leading zero digit weighs nothing, and a
    leading zero path digit stays at `c`, because a prolongable substitution
    begins `c`'s image with `c`."""
    var width = len(path)
    if len(greedy) > width:
        width = len(greedy)
    var out = List[Int]()
    for i in range(width):
        var p = path[i - (width - len(path))] if i >= width - len(path) else 0
        var g = greedy[i - (width - len(greedy))] if i >= width - len(greedy) else 0
        if p < 0 or g < 0 or p >= radix or g >= radix:
            raise Error("a digit lies outside the alphabet")
        out.append(p + radix * g)
    return out^
