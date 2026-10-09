"""Ternary specimens of the published literature, replayed on `B_sigma`.

Pins `docs/motivations/ternary-literature-context-2026-10-07.md` §2: for each
listed substitution, the PIP screen and the all-seed balanced-pair automaton
(size, noncoincident states, longest state, every state reaching a
coincidence). The comparison with published counts depends on the seed
convention; these are this repository's numbers. One listed specimen,
`123, 1, 1132`, has `det M = 0` and is pinned as outside the PIP regime.
"""

from std.testing import assert_equal, assert_false, assert_true
from finite_linear_algebra.mat3 import Mat3
from mojo_smoke.claims import require_contract
from psc.bpa import build, substitution_incidence
from psc.pisot import is_pip
from substitution_dynamics.automaton import nonproductive_states


def sigma_of(a: List[Int], b: List[Int], c: List[Int]) -> List[List[Int]]:
    var sigma = List[List[Int]]()
    sigma.append(a.copy())
    sigma.append(b.copy())
    sigma.append(c.copy())
    return sigma^


def assert_terminates_with_coincidence(
    sigma: List[List[Int]], states: Int, noncoincident: Int, longest: Int
) raises:
    assert_true(is_pip(Mat3(substitution_incidence(sigma))))
    var a = build(sigma, 200000)
    assert_false(a.capped)
    assert_equal(a.size(), states)
    var nc = 0
    var mx = 0
    for i in range(a.size()):
        if not a.states[i].is_coincidence():
            nc += 1
        mx = max(mx, len(a.states[i].u))
    assert_equal(nc, noncoincident)
    assert_equal(mx, longest)
    assert_equal(len(nonproductive_states(a)), 0)


def test_sirvent_solomyak() raises:
    """Non-unimodular 1 -> 12, 2 -> 223, 3 -> 11 and unimodular
    1 -> 1111112223, 2 -> 2231111, 3 -> 311122 (letters shifted to 0..2)."""
    assert_terminates_with_coincidence(sigma_of([0, 1], [1, 1, 2], [0, 0]), 562, 560, 1676)
    assert_terminates_with_coincidence(
        sigma_of([0, 0, 0, 0, 0, 0, 1, 1, 1, 2], [1, 1, 2, 0, 0, 0, 0], [2, 0, 0, 0, 1, 1]), 259, 257, 137
    )


def test_rauzy_fractal_examples() raises:
    assert_terminates_with_coincidence(sigma_of([0, 1], [2, 0], [0]), 11, 10, 8)
    assert_terminates_with_coincidence(sigma_of([0, 1], [1, 2], [2, 0, 1]), 33, 30, 16)
    assert_terminates_with_coincidence(sigma_of([0, 1, 2], [0], [2, 0]), 9, 7, 5)


def test_reducible_listed_specimen_is_outside_pip() raises:
    """1 -> 123, 2 -> 1, 3 -> 1132: rows 2 and 3 of M agree, det M = 0."""
    assert_false(is_pip(Mat3(substitution_incidence(sigma_of([0, 1, 2], [0], [0, 0, 2, 1])))))


def test_benchmarks() raises:
    """Tribonacci, Kol(3,1) and the Arnoux-Rauzy product s1 s2 s3."""
    assert_terminates_with_coincidence(sigma_of([0, 1], [0, 2], [0]), 6, 5, 4)
    assert_terminates_with_coincidence(sigma_of([0, 1, 2], [0, 1], [1]), 7, 5, 3)
    assert_terminates_with_coincidence(
        sigma_of([0, 1, 0, 2, 0, 1, 0], [1, 0, 2, 0, 1, 0], [2, 0, 1, 0]), 8, 5, 4
    )


def main() raises:
    test_sirvent_solomyak()
    test_rauzy_fractal_examples()
    test_reducible_listed_specimen_is_outside_pip()
    test_benchmarks()
    require_contract("all-seed balanced-pair termination with coincidence on published ternary specimens")
