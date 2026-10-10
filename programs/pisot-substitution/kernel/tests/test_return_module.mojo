"""Exact regressions for the return-module index (Theorem R of
docs/p1b-periodic-pair-fibre-literature-gate-2026-10-02.md)."""

from std.testing import assert_equal
from mojo_smoke.claims import require_contract
from psc.corpus import pip_corpus, pip_corpus_total_length
from psc.return_lattice import factor_set
from psc.return_module import cycle_vectors, lattice_index, return_module_index


def sigma_of(a: List[Int], b: List[Int], c: List[Int]) -> List[List[Int]]:
    var sigma = List[List[Int]]()
    sigma.append(a.copy())
    sigma.append(b.copy())
    sigma.append(c.copy())
    return sigma^


def test_named_specimens_have_the_full_return_module() raises:
    assert_equal(return_module_index(sigma_of([0, 1], [0, 2], [0])), 1)
    assert_equal(return_module_index(sigma_of([1], [2, 2, 2], [0, 2, 2, 2])), 1)
    assert_equal(return_module_index(sigma_of([1], [0, 2, 1], [0, 0, 1])), 1)


def test_every_digraph_on_three_letters_has_index_zero_or_one() raises:
    """The finite lemma behind Theorem R for three letters: over all 512
    digraphs on {0,1,2}, the cycle lattice has rank below 3 (index 0) or is
    all of Z^3 (index 1); 303 and 209 of them respectively. So on three
    letters a return module of rank 3 is Z^3."""
    var counts: List[Int] = [0, 0]
    for bits in range(512):
        var edge = List[List[Bool]]()
        for a in range(3):
            var row = List[Bool]()
            for c in range(3):
                row.append(((bits >> (3 * a + c)) & 1) == 1)
            edge.append(row^)
        var index = lattice_index(cycle_vectors(edge))
        assert_equal(index == 0 or index == 1, True)
        counts[index] += 1
    assert_equal(counts[0], 303)
    assert_equal(counts[1], 209)


def test_dekkings_height_two_substitution_has_rank_two() raises:
    """`0 -> 010, 1 -> 201, 2 -> 102` (Dekking height 2; det M = 0, so not
    irreducible): 0 occupies every other position and r_0 = r_1 + r_2. Its
    two-letter graph is 0 <-> 1, 0 <-> 2, so the return module has rank 2."""
    var sigma = sigma_of([0, 1, 0], [2, 0, 1], [1, 0, 2])
    var pairs = factor_set(sigma, 2)
    var words = List[Int]()
    for k in range(len(pairs)):
        words.append(3 * pairs[k][0] + pairs[k][1])
    sort(words)
    assert_equal(words, [1, 2, 3, 6])  # 01, 02, 10, 20
    assert_equal(return_module_index(sigma), 0)


def test_a_singular_specimen_has_rank_below_three() raises:
    """`0 -> 1, 1 -> 2, 2 -> 101` is primitive but its incidence matrix is
    singular; its two-letter graph is 0 <-> 1 <-> 2 with no loop or
    triangle, so the return module has rank 2: index 0."""
    assert_equal(return_module_index(sigma_of([1], [2], [1, 0, 1])), 0)


def test_every_corpus_specimen_has_the_full_return_module() raises:
    var n = 0
    for s in pip_corpus():
        assert_equal(return_module_index(s.sigma), 1)
        n += 1
    assert_equal(n, 4554)


def test_every_total_length_eight_specimen_has_the_full_return_module() raises:
    var n = 0
    for s in pip_corpus_total_length(8):
        assert_equal(return_module_index(s.sigma), 1)
        n += 1
    assert_equal(n, 24486)


def main() raises:
    test_named_specimens_have_the_full_return_module()
    print("[PASS] test_named_specimens_have_the_full_return_module")
    test_every_digraph_on_three_letters_has_index_zero_or_one()
    print("[PASS] test_every_digraph_on_three_letters_has_index_zero_or_one")
    test_dekkings_height_two_substitution_has_rank_two()
    print("[PASS] test_dekkings_height_two_substitution_has_rank_two")
    test_a_singular_specimen_has_rank_below_three()
    print("[PASS] test_a_singular_specimen_has_rank_below_three")
    test_every_corpus_specimen_has_the_full_return_module()
    print("[PASS] test_every_corpus_specimen_has_the_full_return_module")
    test_every_total_length_eight_specimen_has_the_full_return_module()
    print("[PASS] test_every_total_length_eight_specimen_has_the_full_return_module")
    require_contract("return-module index: 1 on all 4554 corpus and 24486 total-length-8 PIP specimens (Theorem R), index 0 or 1 on all 512 three-letter digraphs (303/209), 0 on two singular controls")
