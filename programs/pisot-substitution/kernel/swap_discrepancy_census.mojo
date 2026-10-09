"""Exact swap-discrepancy census over the alphabet-3 PIP corpus.

For every primitive irreducible Pisot substitution on {0,1,2} with images of
length at most 3 (exact Sturm-sequence screening), builds `B_sigma` from the
three swap seeds under a cap of 20000 states and reports the maximum
discrepancy and the longest reachable state.  Finite evidence only: the
bounded-discrepancy theorem is proved in
sources/issue-45/g1b1-bounded-discrepancy-reconstruction.md and no
computation verifies its constant `D_sigma`.
"""

from psc.bpa import build
from psc.corpus import STATE_CAP, pip_corpus
from psc.histogram import Histogram, max_int
from psc.swap_discrepancy import max_reachable_discrepancy, max_state_length


def main() raises:
    var corpus = pip_corpus()
    var n_capped = 0
    var longest = 0
    var histogram = Histogram(64)

    for s in range(len(corpus)):
        ref spec = corpus[s]
        var a = build(spec.sigma, STATE_CAP)
        if a.capped:
            n_capped += 1
            print("CAPPED specimen:", spec.label())
            continue
        histogram.record(max_reachable_discrepancy(a))
        longest = max_int(longest, max_state_length(a))

    print("PIP specimens:", len(corpus), " capped:", n_capped)
    print("maximum reachable discrepancy:", histogram.maximum())
    print("longest reachable state:", longest)
    print(histogram.line("discrepancy histogram:"))
