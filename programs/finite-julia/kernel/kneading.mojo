# kneading.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md, section 2.4.
# Statements and the identification: docs/kneading-and-tuning.md.
#
# The critical itinerary: which side of the line `x = 0` each iterate of the
# critical point is on, read off the enclosure and three-valued. An undecided
# step is the critical point itself, and it ends the word rather than being
# skipped, because a word with a gap in it is not a word.
#
# This is the side of the pair that completes the bridge: it hands the word to
# the vendored `substitution_dynamics/tuning.mojo` and returns the
# substitution that layer builds from it. reference/kneading.py is the Python
# oracle and carries its own copy of the two combinatorial one-liners, because
# an oracle that imports what it checks is not an oracle.

from finite_exact.closed_q import ComplexIQ
from finite_exact.rat_q import Q
from quadratic_orbit.orbit import quadratic_step
from separator import Cut, side, side_negative, side_undecided
from substitution_dynamics.substitution import Substitution
from substitution_dynamics.tuning import TuningPattern


def critical_cut() -> Cut:
    """The line `x = 0`, through the critical point.

    Not the real axis of `separator.real_axis_cut`: for a real parameter the
    critical orbit lies on that line, so it decides nothing there.
    """
    return Cut.of(Q.one(), Q.zero(), Q.zero())


def letter_of(where: Int) -> Int:
    """The left side is `1`.

    `f'(x) = 2x` is negative there, so a step through `x < 0` is the
    orientation-reversing one, and the parity the tuning layer reads is the
    parity of the reversals. Note, section 2.
    """
    if where == side_negative():
        return 1
    return 0


def critical_itinerary(c: Q, steps: Int) -> List[Int]:
    """The first `steps` letters, or an empty list as the refusal.

    A caller cannot tell a refusal from a zero-step request, which is why
    `tuning_prefix` below asks for the period first and never asks for zero.
    """
    var cut = critical_cut()
    var parameter = ComplexIQ.singleton(c, Q.zero())
    var box = ComplexIQ.singleton(Q.zero(), Q.zero())
    var word = List[Int]()
    for _ in range(steps):
        box = quadratic_step(box, parameter)
        if not box.accepted():
            return List[Int]()
        var where = side(cut, box)
        if where == side_undecided():
            return List[Int]()
        word.append(letter_of(where))
    return word^


def tuning_prefix(c: Q, period: Int) -> List[Int]:
    """The word `A'` for a superattracting parameter of the given period.

    The period is the caller's, because deciding it is the critical-orbit
    verdict's job and `kernel/julia_orbit.mojo` already does that. Section 3 of
    the note is what makes the length `period - 1` the right request: the
    iterates before the return are all off the cut, and the return is on it.
    """
    if period < 2:
        return List[Int]()
    return critical_itinerary(c, period - 1)


def tuning_substitution(c: Q, period: Int) raises -> Substitution:
    """The kernels' substitution, from this repository's dynamics.

    The whole of the bridge: a word computed from an orbit goes in, and
    `TuningPattern.dgp` builds the object the substitution and tiling layer
    consumes. A prefix the boundary rejects raises rather than returning
    something, which is upstream's refusal and not this module's to soften.
    """
    return TuningPattern.dgp(tuning_prefix(c, period)).substitution()


def kneading_smoke() -> Bool:
    """The period-doubling pattern, computed from `z^2 - 1`.

    `tau = ((1, 1), (1, 0))` is pinned upstream from combinatorics that never
    mention a Julia set; this case reaches it from an orbit. Under the other
    letter convention the prefix would be `(0,)` and this would fail, which is
    the point of computing it rather than describing it.
    """
    var basilica = Q(-1, 1)
    var prefix = tuning_prefix(basilica, 2)
    if len(prefix) != 1 or prefix[0] != 1:
        return False
    try:
        var tau = tuning_substitution(basilica, 2)
        if tau.size != 2:
            return False
        var zero = tau.image(0)
        var one = tau.image(1)
        if len(zero) != 2 or zero[0] != 1 or zero[1] != 1:
            return False
        if len(one) != 2 or one[0] != 1 or one[1] != 0:
            return False
    except:
        return False

    # The Chebyshev endpoint is Misiurewicz: a sequence, never a pattern.
    var chebyshev = critical_itinerary(Q(-2, 1), 4)
    if len(chebyshev) != 4:
        return False
    if chebyshev[0] != 1 or chebyshev[1] != 0 or chebyshev[2] != 0 or chebyshev[3] != 0:
        return False

    # The critical point is on the cut at `c = 0`, so there is no first letter.
    return len(critical_itinerary(Q.zero(), 1)) == 0
