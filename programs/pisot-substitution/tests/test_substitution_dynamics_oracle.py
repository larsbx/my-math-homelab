"""Oracle constants shared with tests/test_substitution_dynamics.mojo in
larsbx/finite-math-kernels (vendored here as kernel/substitution_dynamics/).

The Mojo package is alphabet-generic; the Python oracle is the independent
reference. Both must report the same automaton counts off the alphabet-3
corpus. The oracle uses 1-based letters, the Mojo package 0-based.
"""

from psc_research import bpa

FIBONACCI = {1: (1, 2), 2: (1,)}
FOUR_LETTER = {1: (1, 2), 2: (1, 3), 3: (1, 4), 4: (1,)}
TRIBONACCI = {1: (1, 2), 2: (1, 3), 3: (1,)}


def counts(sigma):
    graph = bpa.build_bpa(sigma, 10000)
    good = {s for s in graph if s[0] == s[1]}
    changed = True
    while changed:
        changed = False
        for state, kids in graph.items():
            if state not in good and any(k in good for k in kids):
                good.add(state)
                changed = True
    return (
        len(graph),
        len(bpa._tarjan(graph)),
        len(bpa.recurrent_noncoincident_sccs(graph)),
        len(graph) - len(good),
        len(bpa.seed_states(bpa.alphabet_size(sigma))),
    )


def test_fibonacci_constants_match_mojo_package():
    assert counts(FIBONACCI) == (2, 2, 1, 0, 1)


def test_four_letter_constants_match_mojo_package():
    assert counts(FOUR_LETTER) == (15, 6, 1, 0, 6)


def test_tribonacci_constants_match_both_kernels():
    assert counts(TRIBONACCI) == (6, 3, 1, 0, 3)


def test_boundaries_off_alphabet_three():
    assert bpa.coincidence_boundaries((1, 2, 2, 1), (2, 1, 1, 2), 2) == [0, 2, 4]
    assert bpa.coincidence_boundaries((1, 2, 3, 4), (4, 3, 2, 1), 4) == [0, 4]
