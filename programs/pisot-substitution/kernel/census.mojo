"""Exhaustive census of primitive irreducible Pisot substitutions on {1,2,3}
with images of length at most 3.

For each PIP specimen it builds `B_sigma` and reports:
  * termination of the construction within the state cap  (hypothesis G1, in scope);
  * productivity: every reachable balanced pair reaches a coincidence
    (the SCC Producer conjecture, in scope).

Neither is a proof. A clean sweep is elimination of counterexamples over a
finite corpus; G1 and SCC Producer both remain open for alphabet 3.

The outer corpus fold may use MAX worker threads. Set `PSC_CENSUS_WORKERS`
to a positive integer; the default is one worker, preserving the historical
execution shape. Worker-count invariance is pinned by
`tests/test_parallel_census.mojo`.
"""

from std.os import getenv

from psc.corpus import pip_corpus
from psc.parallel_census import replay_failure, run_bpa_census


def main() raises:
    var corpus = pip_corpus()
    var workers = atol(getenv("PSC_CENSUS_WORKERS", "1"))
    var result = run_bpa_census(corpus, len(corpus), workers)

    # Preserve the old diagnostic order. If a worker failed, replay the first
    # failing specimen sequentially after printing only earlier diagnostics;
    # the kernel error remains an execution failure rather than a census row.
    if result.failed_index >= 0:
        for i in range(len(result.nonproductive_indices)):
            var index = result.nonproductive_indices[i]
            if index >= result.failed_index:
                break
            print("NON-PRODUCTIVE specimen:", corpus[index].label())
        replay_failure(corpus, result.failed_index)

    for i in range(len(result.nonproductive_indices)):
        print(
            "NON-PRODUCTIVE specimen:",
            corpus[result.nonproductive_indices[i]].label(),
        )

    print("PIP specimens (images of length <= 3):", len(corpus))
    print(
        "  B_sigma construction terminated:",
        result.terminated,
        " capped:",
        result.capped,
    )
    print("  largest |B_sigma|:", result.max_size)
    print(
        "  productive:",
        result.productive,
        "  non-productive:",
        result.nonproductive,
    )
