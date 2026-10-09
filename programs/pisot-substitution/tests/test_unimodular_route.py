"""Oracle cross-check of the unimodular route gate.

`docs/unimodular-route-gate-2026-09-17.md` Lemma 1: `|det M_sigma| = 1` forbids
`sigma^n(ab)` from being a proper power, because `M^n in GL_A(Z)` would put
`e_a + e_b` in `k Z^A`.  These tests are the independently written Python side
of `kernel/tests/test_unimodular_route.mojo`.
"""
from __future__ import annotations

from psc_research.overlap_collar import is_proper_power, patch_power_level
from psc_research.pip_screen import charpoly, mat, pip_corpus

COLLAPSE_LEVEL = 6
LETTERS = (1, 2, 3)
SEED_PAIRS = tuple((a, b) for a in LETTERS for b in LETTERS if a < b)


def _determinant(sigma: dict[int, tuple[int, ...]]) -> int:
    return charpoly(mat(sigma))[2]


def _collapses(sigma: dict[int, tuple[int, ...]], level: int = COLLAPSE_LEVEL) -> bool:
    return any(patch_power_level(sigma, a, b, level) is not None for a, b in SEED_PAIRS)


def test_determinant_split_of_the_corpus() -> None:
    """The split of the exact 4,554-member corpus: only `|det M| in {1, 2}`
    occurs, and every collapsing specimen is non-unit."""
    corpus = pip_corpus()
    assert len(corpus) == 4554

    by_determinant: dict[int, int] = {}
    collapsing: dict[int, int] = {}
    for sigma in corpus:
        d = _determinant(sigma)
        by_determinant[d] = by_determinant.get(d, 0) + 1
        if _collapses(sigma):
            collapsing[d] = collapsing.get(d, 0) + 1

    assert by_determinant == {1: 1980, -1: 648, 2: 1926}
    assert collapsing == {2: 120}
    assert sum(n for d, n in by_determinant.items() if abs(d) == 1) == 2628


def test_unimodularity_forbids_a_collapsing_seed_patch() -> None:
    """Lemma 1 is level-free, so the unimodular branch stays clean past the
    level the census tests."""
    for sigma in pip_corpus():
        if abs(_determinant(sigma)) == 1:
            assert not _collapses(sigma, level=8)


def test_a_non_unit_collapse_exhibits_the_forbidden_divisibility() -> None:
    """The section 3.2 countermodel of `docs/p1-overlap-collar-2026-09-16.md`:
    `sigma(2) sigma(3) = 3 131 = (31)^2`, whose Parikh identity
    `M(e_2 + e_3) = 2 P(31)` a unimodular `M` could not satisfy."""
    sigma = {1: (2, 1, 3), 2: (3,), 3: (1, 3, 1)}
    assert _determinant(sigma) == 2
    assert patch_power_level(sigma, 2, 3, COLLAPSE_LEVEL) == 1

    patch = sigma[2] + sigma[3]
    assert is_proper_power(patch)
    period = (3, 1)
    for letter in LETTERS:
        assert patch.count(letter) == 2 * period.count(letter)
