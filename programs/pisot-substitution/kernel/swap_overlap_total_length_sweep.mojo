"""Exploratory exhaustive sweep: the overlap survey over the total-length class.

This is not a census. The repository's censuses survey the canonical 4554
corpus (`AGENTS.md`, "The census library"); this run applies the survey of
`swap_overlap_census.mojo` unchanged to a different finite class, the 24486
PIP substitutions on {0,1,2} whose images have total length at most
`TOTAL_LENGTH_CAP = 8` (`psc.corpus.pip_corpus_total_length`), the domain of a
lost earlier sweep (docs/lost-depth-indexed-formulation-2026-10-01.md).

Enumeration is exhaustive and deterministic (no seed, no stride). Budgets:
`STATE_CAP` overlap states per graph and the collar caps of the survey. A
specimen that exhausts a budget is reported, and the run then exits non-zero:
an exhausted budget is not a verdict. A complete run is finite evidence about
this class only; it does not reconstruct the lost sweep's criterion and does
not close any level.
"""

from psc.corpus import STATE_CAP, TOTAL_LENGTH_CAP, pip_corpus_total_length
from swap_overlap_census import survey


def main() raises:
    print(
        "exploratory sweep: PIP substitutions with total image length <=",
        TOTAL_LENGTH_CAP,
        " overlap state cap:", STATE_CAP,
    )
    survey(pip_corpus_total_length(TOTAL_LENGTH_CAP))
