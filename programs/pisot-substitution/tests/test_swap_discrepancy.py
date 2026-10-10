import pytest

from psc_research.bpa import apply_substitution_n, build_bpa, decompose_pair, seed_states
from psc_research.examples import EXAMPLES
from psc_research.swap_discrepancy import (
    discrepancy,
    max_reachable_discrepancy,
    swap_walk_profile,
    swap_walk_sup,
)

TAU = {1: (2,), 2: (1, 3, 2), 3: (1, 1, 2)}


def test_discrepancy_of_swap_seed_is_one():
    assert discrepancy(((1, 2), (2, 1)), 3) == 1


@pytest.mark.parametrize(
    "state",
    [
        ((0,), (0,)),
        ((4,), (4,)),
        ((0,), (1,)),
        ((1,), (4,)),
    ],
)
def test_discrepancy_rejects_labels_outside_alphabet(state):
    with pytest.raises(ValueError, match=r"outside 1\.\.3"):
        discrepancy(state, 3)


def test_level_zero_swap_walk_is_the_seed():
    assert swap_walk_sup(EXAMPLES["tribonacci"], 1, 2, 0) == 1


def test_blocks_of_inflated_seed_inherit_the_swap_walk_bound():
    # The reduction step of the bounded-discrepancy theorem: every block of
    # red(sigma^n(ab), sigma^n(ba)) has discrepancy at most the swap-walk sup.
    for sigma in (EXAMPLES["tribonacci"], EXAMPLES["flipped_tribonacci"], TAU):
        for (a, b), _ in seed_states(3):
            for n in range(0, 9):
                u = apply_substitution_n(sigma, (a, b), n)
                v = apply_substitution_n(sigma, (b, a), n)
                sup = swap_walk_sup(sigma, a, b, n)
                assert all(discrepancy(block, 3) <= sup for block in decompose_pair(u, v, 3))


def test_reachable_discrepancy_matches_exact_census_values():
    assert max_reachable_discrepancy(build_bpa(EXAMPLES["tribonacci"]), 3) == 1
    assert max_reachable_discrepancy(build_bpa(TAU), 3) == 5


def test_swap_walk_profile_is_flat_on_tribonacci():
    assert set(swap_walk_profile(EXAMPLES["tribonacci"], range(0, 16)).values()) == {1}


def test_common_tile_fractions_pin_exact_values():
    from psc_research.swap_discrepancy import common_tile_count

    trib = [common_tile_count(EXAMPLES["tribonacci"], 1, 2, n) for n in range(0, 6)]
    assert trib == [(0, 2), (1, 4), (3, 7), (7, 13), (16, 24), (33, 44)]
    tau = [common_tile_count(TAU, 1, 2, n) for n in range(0, 6)]
    assert tau == [(0, 2), (1, 4), (4, 10), (11, 22), (26, 50), (62, 114)]


def test_overlap_graph_oracle_reproduces_canonical_counts():
    from psc_research.overlap_graph import OverlapGraph

    g = OverlapGraph(TAU)
    assert len(g.seeds()) == 9 and len(g.states) == 628 and not g.capped
    assert g.nonproductive() == []
    t = OverlapGraph(EXAMPLES["tribonacci"])
    assert len(t.states) == 29 and t.nonproductive() == []


def test_first_coincidence_depths_pin_exact_values():
    from psc_research.overlap_graph import OverlapGraph, first_coincidence_depths

    t = first_coincidence_depths(OverlapGraph(EXAMPLES["tribonacci"]))
    assert min(t) == 0 and max(t) == 4 and len(t) == 29
    d = first_coincidence_depths(OverlapGraph(TAU))
    assert min(d) == 0 and max(d) == 16 and len(d) == 628


def test_left_aligned_and_strong_coincidence_depths_pin_exact_values():
    from psc_research.overlap_graph import (
        OverlapGraph,
        first_coincidence_depths,
        first_left_aligned_depths,
        is_left_aligned,
        strong_coincidence_depths,
    )

    for sigma, n, max_left, zeros, prefix, suffix in (
        (EXAMPLES["tribonacci"], 29, 3, 7, {1}, {3, 4}),
        (TAU, 628, 15, 7, {1, 5, 6}, {1}),
    ):
        g = OverlapGraph(sigma)
        left, coinc = first_left_aligned_depths(g), first_coincidence_depths(g)
        assert len(left) == n and max(left) == max_left
        assert sum(1 for s in g.states if is_left_aligned(s)) == zeros == left.count(0)
        assert all(0 <= b <= c for b, c in zip(left, coinc))
        pre, suf = strong_coincidence_depths(g), strong_coincidence_depths(g, suffix=True)
        assert set(pre.values()) == prefix and set(suf.values()) == suffix
        # a coincidence is reached through the first offset-zero descendant
        assert all(c <= b + max(pre.values()) for b, c in zip(left, coinc))


def test_depths_fail_closed_on_capped_graph():
    from psc_research.overlap_graph import (
        OverlapGraph,
        first_coincidence_depths,
        first_left_aligned_depths,
        strong_coincidence_depths,
    )

    g = OverlapGraph(TAU, max_states=1)
    assert g.capped
    for f in (first_coincidence_depths, first_left_aligned_depths, strong_coincidence_depths):
        with pytest.raises(RuntimeError):
            f(g)
