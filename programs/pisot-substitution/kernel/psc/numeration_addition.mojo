"""Addition in the numeration a substitution carries, as a finite automaton.

A decision procedure over an automatic sequence needs three automata: the one
saying which digit words are admissible, the one giving the letter at a
position, and the one recognising

    { (x, y, z) : val(x) + val(y) = val(z) }

over digit triples. The first two are in `psc.dumont_thomas`. This module
builds the third.

The construction is the one the Pisot property licenses, carried out here as
exact integer state exploration. Read a triple most significant first and let
`s = x + y - z` at each position. The running difference is kept as a vector
`v` over the window `(U_(j+2), U_(j+1), U_j)`, so that

    sum over i >= j of s_i U_i  =  v0 U_(j+2) + v1 U_(j+1) + v2 U_j

and moving the window down one place, with
`U_(j+3) = -c2 U_(j+2) - c1 U_(j+1) - c0 U_j`, turns that into

    v <- (v1 - c2 v0,  v2 - c1 v0,  -c0 v0 + s)

which is the transition. A word is accepted when what is left evaluates to
zero: `v0 U_2 + v1 U_1 + v2 U_0 = 0`. Padding with `(0, 0, 0)` fixes the zero
state, so leading zeros neither add nor remove an acceptance.

Without pruning that exploration diverges, and it must: the window step is
multiplication by the expanding root, so the coefficients of a state that can
never be completed grow without bound. What keeps the set finite is the
Pisot property, applied as a *reachability* test rather than assumed: the
digits still to come can only contribute so much, so a state whose value
already exceeds that reserve can never be completed to zero and is sent to a
rejecting sink. The comparison is exact -- the value is a cubic element and
`sign_at_perron` decides its sign at the Perron root by Sturm-Tarski counting,
with no float anywhere.

The bound is deliberately generous. Pruning too little only adds states, which
the cap catches; pruning too much would drop a true triple, so the regression
checks acceptance on every sum below a stated bound rather than trusting the
constant.

That the reachable set is finite at all is the content of the imported theorem
(`docs/automatic-sequence-route-literature-gate-2026-09-17.md`), not of this
code. So the exploration carries a cap, and exceeding it is an *outcome*, not
an error: `AdditionResult` carries it as a refusal, the way a bounded search in
this repository reports an exhausted budget. Malformed input still raises,
because that is an impossible state rather than an inconclusive search, and the
two must not reach a caller through the same channel -- a caller that caught
both would be free to report a defect as inconclusive evidence.

An automaton returned here is a construction whose boundedness was observed on
this input, never a proof that addition is recognisable in general.
"""

from finite_linear_algebra.mat3 import Mat3
from finite_automata.dfa import BoundedAutomaton, Dfa, refusal
from psc.bpa import substitution_incidence
from psc.linear_numeration import basis, basis_obeys_recurrence, recurrence
from psc.perron_field3 import CubicElt, PerronField3, cubic_sub_checked, screened_perron_field3, sign_at_perron


def _key(a: Int, b: Int, c: Int) -> String:
    return String(a) + "," + String(b) + "," + String(c)




# This module's stated executable domain for powered substitutions: entries at
# most 64, the documented bound that psc.coincidence_level_bound relies on and
# kernel/tests/test_coincidence_level_bound.mojo pins. Narrower than the
# screened field's own arithmetic bound on purpose.
comptime POWERED_ENTRY_BOUND = 64


def powered_field(tau: List[List[Int]]) raises -> PerronField3:
    """The cubic field of a substitution that may be a power of another.

    `build_perron_field3` is deliberately not used here. That entry point is
    certified only for image lengths at most six, the audited domain of the
    overlap kernel's legacy unchecked predicates, and a substitution made
    prolongable by raising it to a power legitimately leaves that domain: a
    cube of three-letter images has images up to length 27. Sending a powered
    matrix through it would be asking a function for an answer outside the
    domain it states, and it rightly refuses.

    What the field actually needs is the characteristic polynomial, so the
    screen here is on that polynomial, with the same exact tests the corpus
    screen uses: irreducibility by rational roots, and the Pisot property by
    Sturm counting. Both take coefficients, and neither is the unchecked
    matrix-level predicate the other domain restricts. The construction lives in
    `psc.perron_field3.screened_perron_field3`, shared with the overlap kernel's
    wide-domain entry point; the entry bound is this module's own,
    `POWERED_ENTRY_BOUND`."""
    return screened_perron_field3(Mat3(substitution_incidence(tau)), POWERED_ENTRY_BOUND)


def _completable(field: PerronField3, v0: Int, v1: Int, v2: Int, reserve: Int) raises -> Bool:
    """Whether a state's value can still be cancelled by the digits to come.

    The window coefficients `(v0, v1, v2)` weigh `U_(j+2), U_(j+1), U_j`, whose
    ratios are `beta^2, beta, 1`, so the value is the cubic element
    `v2 + v1 beta + v0 beta^2`. The digits below position `j` can contribute at
    most `reserve` in those units, and a state past that is dead."""
    var value = CubicElt(v2, v1, v0)
    var high = CubicElt(reserve, 0, 0)
    if sign_at_perron(field, cubic_sub_checked(high, value)) < 0:
        return False
    var low = CubicElt(-reserve, 0, 0)
    if sign_at_perron(field, cubic_sub_checked(value, low)) < 0:
        return False
    return True


comptime AdditionResult = BoundedAutomaton


def addition_automaton(
    tau: List[List[Int]], letter: Int, radix: Int, cap: Int
) raises -> AdditionResult:
    """The addition relation over digit triples packed as `x + radix y + radix^2 z`.

    Raises on malformed input -- a radix below two, a non-positive cap, a basis
    that does not obey its own recurrence -- because those are impossible
    states, not inconclusive searches. A state set past `cap` comes back as a
    refusal instead, which is what it is."""
    if radix < 2:
        raise Error("a digit alphabet has at least two digits")
    if cap < 1:
        raise Error("a state cap is positive")
    if not basis_obeys_recurrence(tau, letter, 12):
        raise Error("the basis does not obey the characteristic recurrence")
    var u = basis(tau, letter, 3)
    var c = recurrence(tau)
    var field = powered_field(tau)
    # A digit sum lies in [-(radix-1), 2(radix-1)], and the digits below the
    # current position can contribute a bounded multiple of that; three times
    # the largest digit sum is past any reachable reserve for a Pisot basis.
    var reserve = 6 * (radix - 1)

    # State 0 is the zero window; state 1 is the rejecting sink a pruned
    # transition falls into, and it absorbs.
    var keys: List[String] = [_key(0, 0, 0), String("dead")]
    var v0: List[Int] = [0, 0]
    var v1: List[Int] = [0, 0]
    var v2: List[Int] = [0, 0]
    var dead: List[Bool] = [False, True]
    var delta = List[Int]()
    var letters = radix * radix * radix

    var done = 0
    while done < len(keys):
        for packed in range(letters):
            if dead[done]:
                delta.append(1)
                continue
            var x = packed % radix
            var y = (packed // radix) % radix
            var z = packed // (radix * radix)
            var s = x + y - z
            var n0 = v1[done] - c[2] * v0[done]
            var n1 = v2[done] - c[1] * v0[done]
            var n2 = -c[0] * v0[done] + s
            if not _completable(field, n0, n1, n2, reserve):
                delta.append(1)
                continue
            var key = _key(n0, n1, n2)
            var at = -1
            for i in range(len(keys)):
                if keys[i] == key:
                    at = i
            if at < 0:
                if len(keys) >= cap:
                    return refusal(letters)
                keys.append(key)
                v0.append(n0)
                v1.append(n1)
                v2.append(n2)
                dead.append(False)
                at = len(keys) - 1
            delta.append(at)
        done += 1

    var accepting = List[Bool]()
    for i in range(len(keys)):
        accepting.append(
            not dead[i] and v0[i] * u[2] + v1[i] * u[1] + v2[i] * u[0] == 0
        )
    return BoundedAutomaton(Dfa(letters, delta, accepting), len(keys), False)


def triple_word(
    radix: Int, x: List[Int], y: List[Int], z: List[Int]
) raises -> List[Int]:
    """Three digit words as one word over the packed triple alphabet, left
    padded with zeros to a common length."""
    var width = len(x)
    if len(y) > width:
        width = len(y)
    if len(z) > width:
        width = len(z)
    var out = List[Int]()
    for i in range(width):
        var xi = x[i - (width - len(x))] if i >= width - len(x) else 0
        var yi = y[i - (width - len(y))] if i >= width - len(y) else 0
        var zi = z[i - (width - len(z))] if i >= width - len(z) else 0
        if xi >= radix or yi >= radix or zi >= radix:
            raise Error("a digit lies outside the alphabet")
        out.append(xi + radix * yi + radix * radix * zi)
    return out^
