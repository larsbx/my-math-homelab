"""The coincidence formula, decided the way the route planned to decide it.

`psc.coincidence_formula` answers `SC(i, j)` with one purpose-built automaton:
its accepting condition is the conjunction, wired in by hand. This module is
the other procedure: *write the formula* and let the automata kernel eliminate
its quantifiers.

## The formula, and which automaton discharges which conjunct

Over two tracks of Dumont-Thomas digits packed as `p + radix q`, with `P` on
track zero in `sigma^k(i)` and `Q` on track one in `sigma^k(j)`:

    SC(i, j)  ==  exists P, Q of one length :
                      adm_i(P)                      -- numeration_automaton(sigma, i)
                  and adm_j(Q)                      -- numeration_automaton(sigma, j)
                  and (or over letters a :          -- letter_automaton, both tracks
                          end_i(P) = a and end_j(Q) = a)
                  and parikh_i(P) = parikh_j(Q)     -- parikh_equality_automaton

The assembly -- `cylinder`, `intersection`, `union`, `minimised`, and
`project` for the existential -- is
`substitution_dynamics.strong_coincidence`, over any alphabet. The last
conjunct is the one the numeration's own signature does not give, and it is
the one this repository supplies: `psc.coincidence_formula`'s
Parikh-equality relation, pruned by the Perron-field reserve. A counting
function `n -> |u[0..n)|_a` is not in general first-order definable from `+`
and the letter predicates -- Walnut counts with linear representations, not
formulas -- so the theory is extended by the *equality* of two such counts,
which stays recognisable where neither count does.

## Why run it when the answer is already known

Because agreeing is evidence and assembling is not the same as asserting. The
direct automaton reads its letters off its own state; the assembly reads them
off the Dumont-Thomas letter map, through the product, the union and the
subset construction. `same_language` between the two says that the kernel's
Boolean algebra, the letter map and the hand-wired condition are one thing.
`coincident_positions` projects the pair away and leaves the recognisable
*set* of paths in `sigma^k(i)` at which the pair coincides.

## What it still does not do

Decide the family. `SC` is decidable per substitution, and "every
substitution in this family" is a different quantifier: the family statement
is `Pi_1` over a recursively enumerable family, so a counterexample would be
found by search and no finite computation certifies the positive case without
a uniform argument. The gate says which uniform arguments exist (two letters,
Barge-Diamond) and that three letters is open.
"""

from finite_automata.dfa import Dfa, Witness, is_empty, witness
from psc.coincidence_formula import parikh_equality_automaton
from substitution_dynamics import strong_coincidence as sd
from substitution_dynamics.strong_coincidence import OTHER_TRACK, PATH_TRACK, TRACKS
from substitution_dynamics.substitution import Substitution


def _sub(sigma: List[List[Int]]) -> Substitution:
    # Trusted constructor over len(sigma) letters: unvalidated, as before.
    return Substitution(sigma.copy(), len(sigma))


def reaching_one_letter(sigma: List[List[Int]], top: Int, bottom: Int) raises -> Dfa:
    """`or over letters a : end_top(P) = a and end_bottom(Q) = a`, built out of
    the Dumont-Thomas letter map and nothing else."""
    return sd.reaching_one_letter(_sub(sigma), top, bottom)


def coincidence_by_elimination(
    sigma: List[List[Int]], top: Int, bottom: Int
) raises -> Dfa:
    """The formula above, assembled conjunct by conjunct and minimised, with
    the Parikh relation applied last."""
    var s = _sub(sigma)
    sd.require_letter_pair(s, top, bottom)
    return sd.coincidence_by_elimination(
        s, top, bottom, parikh_equality_automaton(sigma, top, bottom)
    )


def eliminated_witness(
    sigma: List[List[Int]], top: Int, bottom: Int
) raises -> Witness:
    """The existential discharged: a shortest pair of paths satisfying the
    formula, or the fact that there is none."""
    return witness(coincidence_by_elimination(sigma, top, bottom))


def holds_by_elimination(
    sigma: List[List[Int]], top: Int, bottom: Int
) raises -> Bool:
    """`SC(top, bottom)`, decided by emptiness of the assembled language."""
    return not is_empty(coincidence_by_elimination(sigma, top, bottom))


def coincident_positions(
    sigma: List[List[Int]], top: Int, bottom: Int
) raises -> Dfa:
    """The paths in `sigma^k(top)` at which the pair coincides, with the other
    path quantified away by the subset construction."""
    return sd.coincident_positions(coincidence_by_elimination(sigma, top, bottom))
