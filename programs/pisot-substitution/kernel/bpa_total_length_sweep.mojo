"""Exploratory exhaustive sweep: bounded balanced-pair automata on a wider slice.

Not a census (`AGENTS.md`, "The census library"). Builds `B_sigma`
(`psc.bounded_bpa.build_bounded`) under the shared `STATE_CAP` and a
state-length budget `MAX_STATE_LENGTH` for every PIP substitution on
{0,1,2} with total image length at most `TOTAL_LENGTH_CAP` and longest image
at most `MAX_LONGEST_IMAGE`: 14670 specimens, whose longest-image <= 3 part is
the standing corpus. It tests, as finite evidence only, a lost note's claim
that Level 2 (finite BPA) was closed for this slice
(docs/lost-depth-indexed-formulation-2026-10-01.md §3).

Enumeration is exhaustive and deterministic (no seed, no stride). Budgets:
`STATE_CAP` states per automaton, and `MAX_STATE_LENGTH` letters per state,
about twice the longest state reached on the standing corpus (48020,
docs/proof-ladder.md); a state-count cap alone does not bound the memory of a
single geometrically growing state. Termination within both budgets is finite
BPA for that specimen; an exhausted build is inconclusive and is named with
the budget it exhausted, and the run then exits non-zero. A clean run proves nothing about G1 / G1b-2 in general.
"""

from psc.bounded_bpa import BUDGET_LENGTH, build_bounded
from psc.bpa import nonproductive_states
from substitution_dynamics.substitution import Substitution
from psc.corpus import STATE_CAP, TOTAL_LENGTH_CAP, pip_corpus_total_length, report_progress
from psc.histogram import max_int


comptime MAX_LONGEST_IMAGE = 4
comptime MAX_STATE_LENGTH = 100000


def main() raises:
    print(
        "exploratory sweep: B_sigma for PIP substitutions with total image length <=",
        TOTAL_LENGTH_CAP, " longest image <=", MAX_LONGEST_IMAGE, " state cap:", STATE_CAP,
        " state length cap:", MAX_STATE_LENGTH,
    )
    var corpus = pip_corpus_total_length(TOTAL_LENGTH_CAP)
    var specimens = List[Int](length=MAX_LONGEST_IMAGE + 1, fill=0)
    var terminated = List[Int](length=MAX_LONGEST_IMAGE + 1, fill=0)
    var largest = List[Int](length=MAX_LONGEST_IMAGE + 1, fill=0)
    var nonproductive = List[Int](length=MAX_LONGEST_IMAGE + 1, fill=0)
    var longest_state = List[Int](length=MAX_LONGEST_IMAGE + 1, fill=0)
    var n_capped = 0
    var n_failed = 0
    var visited = 0
    for s in range(len(corpus)):
        ref spec = corpus[s]
        var longest = spec.longest_image()
        if longest > MAX_LONGEST_IMAGE:
            continue
        specimens[longest] += 1
        visited += 1
        try:
            var a = build_bounded(Substitution.checked(spec.sigma), STATE_CAP, MAX_STATE_LENGTH)
            if not a.complete():
                n_capped += 1
                var budget = "state length" if a.exhausted == BUDGET_LENGTH else "state count"
                print("CAPPED specimen:", spec.label(), " budget:", budget)
                continue
            terminated[longest] += 1
            largest[longest] = max_int(largest[longest], a.graph.size())
            longest_state[longest] = max_int(longest_state[longest], a.longest_state)
            if len(nonproductive_states(a.graph)) > 0:
                nonproductive[longest] += 1
                print("NON-PRODUCTIVE specimen:", spec.label())
        except e:
            n_failed += 1
            print("FAILED specimen:", spec.label(), " ", e)
        report_progress(visited)

    print("specimens:", visited, " capped:", n_capped, " failed:", n_failed)
    for longest in range(1, MAX_LONGEST_IMAGE + 1):
        print(
            "longest image", longest,
            ": specimens:", specimens[longest],
            " terminated:", terminated[longest],
            " largest |B_sigma|:", largest[longest],
            " longest state:", longest_state[longest],
            " non-productive:", nonproductive[longest],
        )
    if n_capped > 0 or n_failed > 0:
        raise Error(
            "incomplete sweep: " + String(n_capped) + " capped and "
            + String(n_failed) + " failed specimens"
        )
