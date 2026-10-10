"""Exploratory helper regressions: exact enumeration window for G_O types."""
from fractions import Fraction
import pytest

from psc_research.oa_overlap_graph import fixed_point_prefix, oa_types, oa_window, prolongable_power
from psc_research.overlap_graph import OverlapGraph

TRIB = {1: (1, 2), 2: (1, 3), 3: (1,)}
WIDE = {1: (2,), 2: (3,), 3: (1, 3, 3)}  # large l_max / l_min ratio


def _setup(sigma, n=6000):
    g = OverlapGraph(sigma)
    q, c = prolongable_power(sigma)
    return g, fixed_point_prefix(sigma, q, c, n)


def test_window_is_least_integer_above_exact_bound():
    g, u = _setup(WIDE)
    F = g.F
    l_min = min(g.l, key=lambda x: sum(F.sign(F.sub(x, y)) for y in g.l))
    l_max = max(g.l, key=lambda x: sum(F.sign(F.sub(x, y)) for y in g.l))
    for k in (1, 8, 24):
        n = oa_window(g, u, k)
        bound = l_max
        for a in u[:k]:
            bound = F.add(bound, g.l[a - 1])
        scale = lambda m: tuple(x * m for x in l_min)
        assert F.sign(F.sub(scale(n), bound)) > 0
        assert F.sign(F.sub(scale(n - 1), bound)) <= 0


def test_heuristic_window_was_too_small_and_is_rejected():
    g, u = _setup(WIDE)
    assert oa_window(g, u, 24) > 14 + 24
    with pytest.raises(ValueError):
        oa_types(g, u, 24, 14 + 24)
    with pytest.raises(ValueError):
        oa_types(g, u[:10], 1)  # prefix too short for the window (6)


def test_tribonacci_level_zero_types_included_in_seed_graph():
    g, u = _setup(TRIB)
    seed = set(g.states)
    oa = oa_types(g, u, 1)
    assert oa and all(s in seed for s in oa if not OverlapGraph.is_coincidence(s))


def test_contracting_lower_bound_is_below_left_aligned_depth():
    from psc_research.overlap_contracting import ContractingBound, discriminant, field_norm
    from psc_research.overlap_graph import first_left_aligned_depths

    real = {1: (2,), 2: (1, 3), 3: (1, 3, 3)}
    for sigma, complex_pair, max_m0 in ((TRIB, True, 2), ({1: (2,), 2: (1, 3, 2), 3: (1, 1, 2)}, True, 4), (real, False, 2)):
        g = OverlapGraph(sigma)
        cb = ContractingBound(g)
        assert cb.complex == complex_pair == (discriminant(g.F) < 0)
        assert field_norm(g.F, g.F.beta) == g.F.D  # N(beta) = D
        b = first_left_aligned_depths(g)
        m0 = [cb.least_level(s[2]) for s in g.states]
        assert all(0 <= m <= bb for m, bb in zip(m0, b))
        assert max(m0) == max_m0
        assert all((m == 0) == (not any(s[2])) for m, s in zip(m0, g.states))
    # Referee counter-calibration: the Cauchy-Schwarz relaxation of the complex-pair
    # test returns 5 on this reachable offset; the defining inequality first holds at 6.
    g = OverlapGraph({1: (2,), 2: (3, 3), 3: (2, 1, 3)})
    t = (Fraction(-8), Fraction(-2), Fraction(5, 2))
    assert any(s[2] == t for s in g.states)
    assert ContractingBound(g).least_level(t) == 6
