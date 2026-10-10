import pytest

from psc_research import build_bpa, recurrent_noncoincident_sccs
from psc_research.intertwiner import (
    build_scc_intertwiner,
    rational_rank,
    verify_intertwining,
)


# Negative control already used by the TLA+ suite. It is primitive but not in
# the standing PIP regime: columns 1 and 3 of its incidence matrix coincide, so
# the characteristic polynomial is reducible/singular. It has a genuine strict
# closed nonproductive two-state BPA component and therefore calibrates why the
# irreducibility hypothesis is essential in the rank-three theorem.
NON_PISOT_NEGATIVE = {1: (2,), 2: (1, 2, 3), 3: (2,)}


def strict_closed_components(sigma):
    graph = build_bpa(sigma, max_states=2000)
    out = []
    for comp in recurrent_noncoincident_sccs(graph):
        try:
            out.append(build_scc_intertwiner(sigma, comp))
        except ValueError:
            pass
    return out


def test_negative_control_has_exact_two_state_intertwiner():
    components = strict_closed_components(NON_PISOT_NEGATIVE)
    assert len(components) == 1
    data = components[0]

    assert len(data.states) == 2
    assert verify_intertwining(data)
    assert rational_rank(data.parikh_matrix) == 2
    assert rational_rank(data.substitution_incidence) == 2

    # In column convention, each of the two states produces both states once.
    assert data.incidence == ((1, 1), (1, 1))


def test_productive_component_is_rejected_as_not_strict_nonproductive():
    tribonacci = {1: (1, 2), 2: (1, 3), 3: (1,)}
    graph = build_bpa(tribonacci, max_states=2000)
    comps = recurrent_noncoincident_sccs(graph)
    assert comps
    # Tribonacci's recurrent component has a coincidence escape, so it is not
    # the strict no-leakage object required by the C4 intertwiner theorem.
    with pytest.raises(ValueError):
        build_scc_intertwiner(tribonacci, comps[0])
