"""`B_sigma` under a state-count *and* a state-length budget.

The builder is `substitution_dynamics.balanced_pair_algorithm`, re-exported here
for the exploratory sweeps (`target_aware_bpa.mojo`,
`bpa_total_length_sweep.mojo`, `psc/boundary_sync.mojo`). The canonical
builder caps the number of reachable states, which is the right contract
inside the standing PIP regime: there bounded discrepancy keeps every
reachable balanced pair short. An exploratory sweep visits substitutions with
no discrepancy bound, where the states themselves grow like `beta^n`, so
`build_bounded` stops on either budget and reports which one. A bounded
automaton is a partial prefix of the graph: like a capped one it must never
be read as a counterexample or as a proof.
"""

from substitution_dynamics.balanced_pair_algorithm import (
    BUDGET_LENGTH,
    BUDGET_NONE,
    BUDGET_STATES,
    BoundedAutomaton,
    build_bounded,
)
