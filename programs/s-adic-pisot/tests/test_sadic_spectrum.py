"""Contracts of the oracle's spectral, periodic and balanced-pair layers.
Literals are pinned independently by kernel/tests/test_sadic_spectrum.mojo."""

import hashlib
from itertools import product
from pathlib import Path

from sadic_reference import compose_all, full_shift, prefix_matrix
from sadic_reference.bpa import CAPPED, FAILS, TERMINATES, balanced_pair_algorithm, split
from sadic_reference.periodic import brun_unordered, is_lyndon, periodic_admissible, periodic_words
from sadic_reference.spectrum import (
    Inconclusive,
    charpoly,
    disc_zero_count,
    irreducibility_verdict,
    kronecker_factor,
    pisot_verdict,
    primitivity_exponent,
)

TRIBONACCI = (-1, -1, -1, 1)


def _product(a, b):
    out = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            out[i + j] += x * y
    return tuple(out)
BRUN4 = brun_unordered(4)
TAU = (0, 4, 8, 9)  # beta_12 o beta_23 o beta_34 o beta_41 (BST23 section 6.5), 0-based labels


def test_charpoly():
    assert charpoly(((1, 1), (1, 0))) == (-1, -1, 1)
    assert charpoly(((1, 1, 1), (1, 0, 0), (0, 1, 0))) == TRIBONACCI
    assert charpoly(prefix_matrix(BRUN4, TAU)) == (1, -4, 6, -5, 1)


def test_disc_zero_count():
    assert disc_zero_count((-1, -1, 1)) == 1
    assert disc_zero_count((-1, -1, 0, 1)) == 2  # plastic number
    assert disc_zero_count(TRIBONACCI) == 2
    assert disc_zero_count((-1, -1, -1, -1, 1)) == 3
    assert disc_zero_count((-2, 0, 0, 1)) == 0
    assert disc_zero_count((-2, -2, -1, 1)) == 2  # a first-column zero, removed by w + k
    for p in ((1, -1, -1, -1, 1), (1, 0, 1), (1, -3, 1)):  # Salem, circle, reciprocal pair
        try:
            disc_zero_count(p)
        except Inconclusive:
            continue
        raise AssertionError(f"{p} must be inconclusive")


def test_pisot_verdict():
    assert pisot_verdict(TRIBONACCI) == 1
    assert pisot_verdict((1, -4, 6, -5, 1)) == 1
    assert pisot_verdict((1, -3, 1)) == 1  # reciprocal quadratic, |t| > 2
    assert pisot_verdict((1, -1, 1)) == 0  # reciprocal quadratic, roots on the circle
    assert pisot_verdict((1, -1, -1, -1, 1)) == 0  # Salem quartic, Lemma R
    assert pisot_verdict((-2, 0, 0, 1)) == 0


def test_irreducibility_verdict():
    assert irreducibility_verdict(TRIBONACCI) == (1, 0)
    assert irreducibility_verdict((-1, -1, -1, -1, 1)) == (1, 2)
    assert irreducibility_verdict((1, -4, 6, -5, 1)) == (1, 2)
    assert irreducibility_verdict((-1, 0, 1)) == (0, 1)
    assert irreducibility_verdict((0, 1, 1)) == (0, 1)
    # z^4 + 1 splits modulo every prime, so no prime certifies it; the
    # exhaustive factor search does
    assert irreducibility_verdict((1, 0, 0, 0, 1)) == (1, 0)
    # a Brun d = 5 period-5 characteristic polynomial: (z^2 - z + 1)(z^3 - 5z^2 + 4z - 1)
    assert irreducibility_verdict((-1, 5, -10, 10, -6, 1)) == (0, 2)
    assert kronecker_factor((-1, 5, -10, 10, -6, 1), 2) == (1, -1, 1)
    # a product of two irreducible cubics: no root, no quadratic factor
    assert irreducibility_verdict(_product((-1, -1, 0, 1), (-1, 0, -1, 1))) == (0, 3)


def test_primitivity_exponent():
    wielandt = ((0, 1, 0), (0, 0, 1), (1, 1, 0))
    assert primitivity_exponent(wielandt) == 5  # attains (d - 1)^2 + 1
    assert primitivity_exponent(((0, 1), (1, 0))) == -1
    assert primitivity_exponent(prefix_matrix(BRUN4, TAU)) == 2


def test_brun_unordered_family():
    assert BRUN4.labels == 12
    assert compose_all(BRUN4, TAU) == ((0, 1, 2, 3, 0), (0, 1), (0, 1, 2), (0, 1, 2, 3))
    assert BRUN4.admits(TAU) and periodic_admissible(BRUN4, TAU)
    assert not periodic_admissible(BRUN4, (0, 8))  # beta_01 then beta_23: (6.10) forbids
    assert [len(periodic_words(BRUN4, n)) for n in range(1, 6)] == [12, 6, 20, 60, 204]


def test_lyndon():
    assert is_lyndon((0, 1)) and not is_lyndon((1, 0)) and not is_lyndon((0, 0))


def test_balanced_pair_algorithm():
    fibonacci = ((0, 1), (0,))
    thue_morse = ((0, 1), (1, 0))
    assert balanced_pair_algorithm(fibonacci) == TERMINATES
    assert balanced_pair_algorithm(thue_morse) == FAILS
    assert balanced_pair_algorithm(compose_all(BRUN4, TAU)) == TERMINATES
    assert balanced_pair_algorithm(fibonacci, max_states=1) == CAPPED
    assert split((0, 1, 1, 0), (1, 0, 0, 1), 2) == [((0, 1), (1, 0)), ((0, 1), (1, 0))]


PSC_CORPUS = Path(__file__).parent / "data" / "psc-pip-corpus.txt"


def psc_corpus_lines() -> list[str]:
    """The pinned PSC corpus, its data lines checked against the digest in its header."""
    lines = PSC_CORPUS.read_text(encoding="utf-8").splitlines()
    digest = next(l.split(": ")[1] for l in lines if l.startswith("# sha256 of the data lines: "))
    data = [l for l in lines if not l.startswith("#")]
    assert hashlib.sha256("".join(l + "\n" for l in data).encode()).hexdigest() == digest
    return data


def test_iota_embedding_reproduces_the_psc_corpus():
    # Per instance, in PSC's enumeration order: embed each substitution as the
    # periodic directive sequence of a one-label full shift and certify it
    # through the S-adic verdicts; the result is PSC's pinned corpus line by line.
    words = [w for n in (1, 2, 3) for w in product(range(3), repeat=n)]
    certified = []
    for images in product(words, repeat=3):
        shift = full_shift("iota", (images,))
        m = prefix_matrix(shift, (0,))
        f = charpoly(m)
        if primitivity_exponent(m) > 0 and irreducibility_verdict(f)[0] == 1 and pisot_verdict(f) == 1:
            certified.append("|".join("".join(map(str, w)) for w in images))
    assert certified == psc_corpus_lines()
    assert len(certified) == 4554


def _joint_balance(words, size):
    """Balance of the set of all factors of the given words."""
    best = 0
    for length in range(1, max(map(len, words)) + 1):
        for a in range(size):
            counts = [w[s:s + length].count(a) for w in words for s in range(len(w) - length + 1)]
            if counts:
                best = max(best, max(counts) - min(counts))
    return best


def _swap_walk_sup(x, y, size):
    u, v = x + y, y + x
    return max(max(abs(u[:j].count(a) - v[:j].count(a)) for a in range(size)) for j in range(len(u) + 1))


def test_lemma_s_on_arnoux_rauzy_and_brun_images():
    # docs/t1-uniform-overlap-finiteness.md, Lemma S: the swap walk of (xy, yx)
    # is bounded by the balance of the factors of x and y
    from sadic_reference import arnoux_rauzy, brun3, image
    for shift in (arnoux_rauzy(3), brun3()):
        for n in range(1, 5):
            for w in product(range(shift.labels), repeat=n):
                for a in range(3):
                    for b in range(a + 1, 3):
                        x, y = image(shift, w, a), image(shift, w, b)
                        assert _swap_walk_sup(x, y, 3) <= _joint_balance([x, y], 3)


def test_brun_orbits_partition_the_periodic_words():
    # relabelling letters permutes the Brun family and preserves admissibility,
    # so orbit sizes sum to the word counts, and the budget-free verdicts are
    # orbit invariants. Balanced-pair outcomes depend on the budgets; here
    # every Pisot representative terminates, matching the full d = 4 census
    from sadic_reference.periodic import brun_orbit_words, periodic_verdict
    for n, count in zip(range(1, 7), [12, 6, 20, 60, 204, 670]):
        orbits = brun_orbit_words(4, n)
        assert sum(size for _, size in orbits) == count
    weighted = {}
    for w, size in brun_orbit_words(4, 6):
        v = periodic_verdict(BRUN4, w, 20000, 2000)
        weighted[v] = weighted.get(v, 0) + size
    assert weighted == {"not-primitive": 410, "irreducible:0": 12, "bpa:terminates": 248}
    assert [len(brun_orbit_words(4, n)) for n in range(1, 7)] == [1, 1, 2, 5, 10, 35]


def test_theorem_b_brun_composites_are_in_the_mirror_barge_class():
    # docs/sadic-g6-brun-higher-census.md, Theorem B: for every admissible
    # unordered Brun word w using every letter, sigma_w is constant on initial
    # letters (all images start with the first label's p) and its final-letter
    # map is the identity. Checked exhaustively on periodic words.
    from sadic_reference.periodic import brun_pairs, final_letters, in_mirror_barge_class, initial_letters
    for d, top in ((3, 7), (4, 6), (5, 5)):
        shift = brun_unordered(d)
        pairs = brun_pairs(d)
        checked = 0
        for n in range(1, top + 1):
            for w in periodic_words(shift, n):
                letters = {x for t in w for x in pairs[t]}
                sigma = compose_all(shift, w)
                assert final_letters(sigma) == tuple(range(d))
                if len(letters) == d:
                    assert initial_letters(sigma) == (pairs[w[0]][0],) * d
                    assert in_mirror_barge_class(sigma)
                    checked += 1
        assert checked > 0
    # the converse direction of primitivity: a primitive composite uses every letter
    from sadic_reference.spectrum import primitivity_exponent
    shift = brun_unordered(4)
    for w in periodic_words(shift, 6):
        if primitivity_exponent(prefix_matrix(shift, w)) > 0:
            assert {x for t in w for x in brun_pairs(4)[t]} == set(range(4))


def test_brun_five_periodic_point():
    # Theorem C witness: beta_12 beta_23 beta_31 beta_14 beta_45 beta_51 (1-based)
    from sadic_reference.periodic import periodic_verdict
    shift = brun_unordered(5)
    w = (0, 5, 8, 2, 15, 16)
    assert periodic_admissible(shift, w)
    assert compose_all(shift, w)[1] == (0, 1)
    assert periodic_verdict(shift, w, 200000, 20000) == "bpa:terminates"


def test_brun_six_periodic_point():
    # Theorem C witness for d = 6: beta_12 beta_23 beta_31 beta_14 beta_42 beta_25 beta_56 beta_61
    from sadic_reference.periodic import periodic_verdict
    shift = brun_unordered(6)
    w = (0, 6, 10, 2, 16, 8, 24, 25)
    assert periodic_admissible(shift, w)
    assert periodic_verdict(shift, w, 200000, 20000) == "bpa:terminates"


def test_brun_seven_periodic_point():
    # Theorem C witness for d = 7:
    # beta_12 beta_23 beta_31 beta_14 beta_45 beta_51 beta_16 beta_62 beta_24 beta_47 beta_71
    from sadic_reference.periodic import periodic_verdict
    shift = brun_unordered(7)
    w = (0, 7, 12, 2, 21, 24, 4, 31, 8, 23, 36)
    assert periodic_admissible(shift, w)
    assert periodic_verdict(shift, w, 100000, 10000) == "bpa:terminates"


def test_brun_pisot_periodic_points():
    # Corollary B'' and Theorem C' (docs/sadic-g6-brun-higher-census.md §5):
    # for d = 7..10 a periodic Brun point whose composite is primitive, with an
    # irreducible Pisot characteristic polynomial, in the mirror Barge class
    from sadic_reference.periodic import in_mirror_barge_class
    from sadic_reference.spectrum import primitivity_exponent
    for d, w, f in (
        (7, (0, 7, 12, 2, 21, 24, 4, 35, 36), (-1, 7, -24, 47, -56, 39, -14, 1)),
        (8, (0, 0, 8, 16, 24, 28, 1, 18, 40, 48, 49), (1, -8, 28, -57, 77, -73, 45, -16, 1)),
        (9, (0, 9, 16, 2, 27, 32, 4, 45, 48, 6, 63, 64), (-1, 9, -40, 108, -192, 230, -184, 92, -24, 1)),
        (10, (0, 9, 1, 20, 27, 3, 40, 50, 54, 6, 67, 43, 80, 81), (1, -11, 54, -158, 309, -425, 417, -286, 127, -30, 1)),
    ):
        shift = brun_unordered(d)
        assert periodic_admissible(shift, w)
        m = prefix_matrix(shift, w)
        assert primitivity_exponent(m) >= 0
        assert charpoly(m) == f
        assert irreducibility_verdict(f)[0] == 1
        assert pisot_verdict(f) == 1
        assert in_mirror_barge_class(compose_all(shift, w))


def test_brun_full_classes_and_pip_counts():
    # kernel/brun_witness.mojo `pip`: classes of periodic words using every
    # letter, and those whose composite is primitive, irreducible and Pisot;
    # the Mojo enumeration (brun_classes) pins the same counts
    from sadic_reference.periodic import brun_full_classes, is_pip
    shift = brun_unordered(5)
    counts = []
    for n in range(1, 8):
        classes = brun_full_classes(5, n)
        counts.append((len(classes), sum(is_pip(shift, w) for w in classes)))
    assert counts == [(0, 0), (0, 0), (0, 0), (0, 0), (1, 0), (3, 3), (20, 18)]
