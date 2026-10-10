"""Exact regressions for the unimodular route gate.

`docs/unimodular-route-gate-2026-09-17.md` Lemma 1 proves that a unimodular
substitution has no collapsing seed patch at any level: `sigma^n(ab) = u^k`
with `k >= 2` forces `e_a + e_b = k M^(-n) P(u)` in `k Z^A`, impossible for
`a != b`.  These tests guard the corpus shadow of that lemma and the exact
divisibility a non-unit collapse exhibits.
"""

from std.testing import assert_equal, assert_true
from psc.bpa import substitution_incidence
from mojo_smoke.claims import require_claim
from psc.corpus import (
    REGIME_NONUNIMODULAR,
    arithmetic_regime,
    pip_corpus,
)
from psc.overlap_collar import collapsing_seed_pair_count, is_proper_power, patch_power_level
from finite_linear_algebra.mat3 import Mat3

comptime COLLAPSE_LEVEL = 6


def collapsing_sigma() -> List[List[Int]]:
    """The section 3.2 countermodel of `docs/p1-overlap-collar-2026-09-16.md`:
    `sigma(1) sigma(2) = 2 020 = (20)^2`, so the level-one patch of the pair
    `{1,2}` is `(20)^Z` and no collar radius separates its ancestries."""
    var a0: List[Int] = [1, 0, 2]
    var a1: List[Int] = [2]
    var a2: List[Int] = [0, 2, 0]
    var sigma = List[List[Int]]()
    sigma.append(a0^)
    sigma.append(a1^)
    sigma.append(a2^)
    return sigma^


def letter_counts(word: List[Int]) -> List[Int]:
    """The Parikh vector of `word` over `{0,1,2}`."""
    var counts = List[Int](length=3, fill=0)
    for i in range(len(word)):
        counts[word[i]] += 1
    return counts^


def test_unimodularity_forbids_a_collapsing_seed_patch() raises:
    """Lemma 1 on the exact corpus: every collapsing specimen is non-unit."""
    var corpus = pip_corpus()
    var unimodular = 0
    var non_unit = 0
    var unimodular_collapsing = 0
    var non_unit_collapsing = 0
    for s in range(len(corpus)):
        ref spec = corpus[s]
        var collapsing = collapsing_seed_pair_count(spec.sigma, COLLAPSE_LEVEL) > 0
        if arithmetic_regime(spec.incidence) == REGIME_NONUNIMODULAR:
            non_unit += 1
            non_unit_collapsing += 1 if collapsing else 0
        else:
            unimodular += 1
            unimodular_collapsing += 1 if collapsing else 0
            # Lemma 1 is a theorem, so this is a kernel check, not a statistic.
            assert_true(not collapsing)
    assert_equal(len(corpus), 4554)
    assert_equal(unimodular, 2628)
    assert_equal(non_unit, 1926)
    assert_equal(unimodular_collapsing, 0)
    assert_equal(non_unit_collapsing, 120)


def test_a_non_unit_collapse_exhibits_the_divisibility_lemma_1_forbids() raises:
    """The witness has `|det M| = 2`, and its collapse is exactly the
    divisibility `M(e_1 + e_2) = 2 P(20)` that `M in GL_A(Z)` would refute."""
    var sigma = collapsing_sigma()
    var m = Mat3(substitution_incidence(sigma))
    assert_equal(m.det(), 2)
    assert_equal(arithmetic_regime(m), REGIME_NONUNIMODULAR)
    assert_equal(patch_power_level(sigma, 1, 2, COLLAPSE_LEVEL), 1)

    var patch = List[Int]()
    for j in range(1, 3):
        ref image = sigma[j]
        for i in range(len(image)):
            patch.append(image[i])
    assert_true(is_proper_power(patch))
    var counts = letter_counts(patch)
    var period: List[Int] = [2, 0]
    var period_counts = letter_counts(period)
    for a in range(3):
        # M(e_1 + e_2) = k P(u) with k = 2: the coordinate that Lemma 1 pins to
        # `e_1 + e_2` through `M^(-1)`, which no unimodular M can divide by 2.
        assert_equal(counts[a], 2 * period_counts[a])


def main() raises:
    test_unimodularity_forbids_a_collapsing_seed_patch()
    print("[PASS] test_unimodularity_forbids_a_collapsing_seed_patch")
    test_a_non_unit_collapse_exhibits_the_divisibility_lemma_1_forbids()
    print("[PASS] test_a_non_unit_collapse_exhibits_the_divisibility_lemma_1_forbids")
    print("2 unimodular-route Mojo tests passed.")
    require_claim("UnimodularNoPatchCollapse")
    require_claim("CorpusDeterminantSplit")
