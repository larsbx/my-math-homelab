"""The Dumont-Thomas numeration of a fixed point, as an automaton.

A primitive substitution `tau` prolongable at `c` has a fixed point
`u = tau^inf(c)`, and every position `n < |tau^k(c)|` has exactly one
decomposition along the prefix tree of `tau^k(c)`; its digits are the
Dumont-Thomas representation of `n`, and the letter reached after the last
digit is `u_n`. Read as an automaton the states are the letters, so the
positions carrying a given letter are a recognisable set -- the presentation a
first-order decision procedure over this numeration would quantify over.

The numeration is `substitution_dynamics.dumont_thomas`, over any alphabet; this
module is its view on substitutions given as image lists, which the PSC
census and numeration modules pass around. What it establishes is finite and
checkable: the automaton reproduces the fixed point letter by letter,
admissible digit words of length `k` are in bijection with positions of
`tau^k(c)`, and the words ending at a letter are counted by the incidence
matrix. What it does *not* supply is the step from a recognisable set to a
decision procedure for first-order statements, which needs recognisability of
addition in the numeration; that is an imported theorem, gated in
`docs/automatic-sequence-route-literature-gate-2026-09-17.md`.
"""

from finite_automata.dfa import Dfa
from finite_exact.bigint_z import BigZ
from substitution_dynamics import dumont_thomas as sd
from substitution_dynamics.substitution import Substitution


def _sub(tau: List[List[Int]]) -> Substitution:
    # Trusted constructor over len(tau) letters: unvalidated, as before.
    return Substitution(tau.copy(), len(tau))


def power_substitution(sigma: List[List[Int]], power: Int) raises -> List[List[Int]]:
    """`sigma^power`, so a substitution prolongable only at a power becomes one
    prolongable at a letter, which is what the numeration needs."""
    return _sub(sigma).power(power).images.copy()


def prolongable_form(sigma: List[List[Int]]) raises -> List[List[Int]]:
    """The power of `sigma` that its least prolongable point makes prolongable."""
    return sd.prolongable_form(_sub(sigma)).images.copy()


def max_image_length(tau: List[List[Int]]) -> Int:
    return sd.max_image_length(_sub(tau))


def image_lengths(tau: List[List[Int]], level: Int) raises -> List[Int]:
    """`|tau^level(a)|` for each letter `a`, checked against wrapping."""
    return sd.image_lengths(_sub(tau), level)


def levels_to_cover(tau: List[List[Int]], letter: Int, position: Int) raises -> Int:
    """The least `k` with `position < |tau^k(letter)|`."""
    return sd.levels_to_cover(_sub(tau), letter, position)


def digits(tau: List[List[Int]], letter: Int, position: Int) raises -> List[Int]:
    """The Dumont-Thomas digits of `position`, most significant first."""
    return sd.digits(_sub(tau), letter, position)


def letter_at(tau: List[List[Int]], letter: Int, position: Int) raises -> Int:
    """`u_position` for the fixed point of `tau` at `letter`, by the digits."""
    return sd.letter_at(_sub(tau), letter, position)


def letter_of_digits(tau: List[List[Int]], letter: Int, path: List[Int]) raises -> Int:
    """Where an admissible digit word ends, which is the letter it names."""
    return sd.letter_of_digits(_sub(tau), letter, path)


def numeration_automaton(tau: List[List[Int]], letter: Int) raises -> Dfa:
    """Admissible digit words from `letter`."""
    return sd.numeration_automaton(_sub(tau), letter)


def letter_automaton(tau: List[List[Int]], letter: Int, target: Int) raises -> Dfa:
    """Admissible digit words from `letter` that end at `target`."""
    return sd.letter_automaton(_sub(tau), letter, target)


def positions_of_length(tau: List[List[Int]], letter: Int, level: Int) raises -> BigZ:
    """`|tau^level(letter)|` counted through the automaton, exactly."""
    return sd.positions_of_length(_sub(tau), letter, level)


def occurrences_of_length(
    tau: List[List[Int]], letter: Int, target: Int, level: Int
) raises -> BigZ:
    """How many positions of `tau^level(letter)` carry `target`."""
    return sd.occurrences_of_length(_sub(tau), letter, target, level)
