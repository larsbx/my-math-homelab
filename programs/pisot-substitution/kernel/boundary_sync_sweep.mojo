"""Exploratory sweep: does boundary synchronization catch productivity?

Draws primitive substitutions on three or four letters with images of length
two to four from a fixed seed (`psc.prng`), builds `B_sigma` under state and
length budgets (`psc.bounded_bpa`), and compares two verdicts on every
recurrent noncoincident component: productive within one inflation, and caught
by a synchronizing zero-return cut within one inflation. A productive
component with no synchronizing cut is printed as an exact witness.

Most drawn substitutions are not Pisot, so their balanced-pair graphs are
infinite and exhaust the length budget; those specimens are reported as
inconclusive and contribute to no verdict. This is a randomized search, not a
census: it is reproducible from its seed and eliminates nothing outside the
substitutions it visits. The exhaustive statement over the standing PIP corpus
is `c3_census.mojo`.
"""

from psc.boundary_sync import SweepConfig, run_sweep


def default_config() -> SweepConfig:
    var sizes: List[Int] = [3, 4]
    return SweepConfig(1729, 500, sizes^, 2, 4, 2000, 20000, 1)


def main() raises:
    var config = default_config()
    var tally = run_sweep(config, report=True)
    print("boundary-synchronization sweep (exploratory)")
    print(
        "seed:", config.seed, " iterate level:", config.max_iterate,
        " state cap:", config.max_states, " length cap:", config.max_length,
    )
    tally.print_lines()
