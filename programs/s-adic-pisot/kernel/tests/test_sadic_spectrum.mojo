"""Regressions for kernel/sadic/{spectrum,periodic}.mojo
(docs/sadic-kernel-g2-spectrum.md). Literals are pinned independently by
tests/test_sadic_spectrum.py against the Python oracle."""

from std.testing import assert_equal, assert_false, assert_raises, assert_true

from mojo_smoke.claims import require_claim
from substitution_dynamics.barge_class import in_mirror_class
from substitution_dynamics.substitution import Substitution
from sadic.cocycle import prefix_matrix
from sadic.directive import DirectiveShift, words_of_length
from sadic.periodic import (
    brun_classes, brun_orbit_words, is_pip,
    BPA_CAPPED, BPA_FAILS, BPA_TERMINATES, brun_unordered, bpa_verdict, is_lyndon,
    periodic_admissible, periodic_verdict, periodic_words, primitivity_exponent,
)
from sadic.spectrum import charpoly, disc_zero_count, irreducibility_verdict, pisot_verdict


def same(a: List[Int], b: List[Int]) -> Bool:
    if len(a) != len(b):
        return False
    for i in range(len(a)):
        if a[i] != b[i]:
            return False
    return True


def tau() -> List[Int]:
    return [0, 4, 8, 9]


def test_charpoly() raises:
    var fib: List[Int] = [1, 1, 1, 0]
    var trib: List[Int] = [1, 1, 1, 1, 0, 0, 0, 1, 0]
    var e1: List[Int] = [-1, -1, 1]
    var e2: List[Int] = [-1, -1, -1, 1]
    var e3: List[Int] = [1, -4, 6, -5, 1]
    assert_true(same(charpoly(fib, 2), e1))
    assert_true(same(charpoly(trib, 3), e2))
    assert_true(same(charpoly(prefix_matrix(brun_unordered(4), tau()), 4), e3))
    var extreme: List[Int] = [Int.MIN]
    with assert_raises():
        _ = charpoly(extreme, 1)  # -Int.MIN is not representable: refuse


def test_disc_zero_count() raises:
    var cases: List[List[Int]] = [[-1, -1, 1], [-1, -1, 0, 1], [-1, -1, -1, 1], [-1, -1, -1, -1, 1], [-2, 0, 0, 1], [-2, -2, -1, 1]]
    var counts: List[Int] = [1, 2, 2, 3, 0, 2]
    # a Brun d = 6 period-7 characteristic polynomial whose recursion passes
    # 64-bit coefficients (|a_0 p_i| ~ 1.5e19): exact only in BigZ
    var wide: List[Int] = [1, -6, 16, -24, 20, -9, 1]
    assert_equal(disc_zero_count(wide), 5)
    assert_equal(pisot_verdict(wide), 1)
    for i in range(len(cases)):
        assert_equal(disc_zero_count(cases[i]), counts[i])
    var singular: List[List[Int]] = [[1, -1, -1, -1, 1], [1, 0, 1], [1, -3, 1]]
    for p in singular:
        with assert_raises():
            _ = disc_zero_count(p)


def test_pisot_verdict() raises:
    var polys: List[List[Int]] = [[-1, -1, -1, 1], [1, -4, 6, -5, 1], [1, -3, 1], [1, -1, 1], [1, -1, -1, -1, 1], [-2, 0, 0, 1]]
    var verdicts: List[Int] = [1, 1, 1, 0, 0, 0]
    for i in range(len(polys)):
        assert_equal(pisot_verdict(polys[i]), verdicts[i])


def test_irreducibility_verdict() raises:
    # z^4 + 1 has no prime certificate (it splits mod every p); the factor
    # search excludes every quadratic factor. The quintic is a Brun d = 5
    # characteristic polynomial, (z^2 - z + 1)(z^3 - 5z^2 + 4z - 1); the sextic
    # is (z^3 - z - 1)(z^3 - z^2 - 1).
    var polys: List[List[Int]] = [
        [-1, -1, -1, 1], [-1, -1, -1, -1, 1], [1, -4, 6, -5, 1], [-1, 0, 1], [0, 1, 1],
        [1, 0, 0, 0, 1], [-1, 5, -10, 10, -6, 1], [1, 1, 1, -1, -1, -1, 1],
    ]
    var verdicts: List[Int] = [1, 1, 1, 0, 0, 1, 0, 0]
    var witnesses: List[Int] = [0, 2, 2, 1, 1, 0, 2, 3]
    for i in range(len(polys)):
        var v = irreducibility_verdict(polys[i])
        assert_equal(v.verdict, verdicts[i])
        assert_equal(v.witness, witnesses[i])


def test_primitivity_exponent() raises:
    var wielandt: List[Int] = [0, 1, 0, 0, 0, 1, 1, 1, 0]
    var swap: List[Int] = [0, 1, 1, 0]
    assert_equal(primitivity_exponent(wielandt, 3), 5)
    assert_equal(primitivity_exponent(swap, 2), -1)
    assert_equal(primitivity_exponent(prefix_matrix(brun_unordered(4), tau()), 4), 2)
    # only the zero pattern is powered: huge entries cannot overflow
    var huge: List[Int] = [Int.MAX, 0, 0, Int.MAX]
    assert_equal(primitivity_exponent(huge, 2), -1)


def test_brun_unordered() raises:
    var b = brun_unordered(4)
    assert_equal(b.labels(), 12)
    var t = b.composite(tau())
    var expected: List[List[Int]] = [[0, 1, 2, 3, 0], [0, 1], [0, 1, 2], [0, 1, 2, 3]]
    for a in range(4):
        assert_true(same(t.images[a], expected[a]))
    assert_true(periodic_admissible(b, tau()))
    var forbidden: List[Int] = [0, 8]
    assert_false(periodic_admissible(b, forbidden))
    var counts: List[Int] = [12, 6, 20, 60, 204]
    for n in range(1, 6):
        assert_equal(len(periodic_words(b, n)), counts[n - 1])
    var lyndon: List[Int] = [0, 1]
    var rotated: List[Int] = [1, 0]
    var power: List[Int] = [0, 0]
    assert_true(is_lyndon(lyndon))
    assert_false(is_lyndon(rotated))
    assert_false(is_lyndon(power))


def test_bpa_verdict() raises:
    var fib: List[List[Int]] = [[0, 1], [0]]
    var tm: List[List[Int]] = [[0, 1], [1, 0]]
    assert_equal(bpa_verdict(Substitution.checked(fib), 20000, 400), BPA_TERMINATES)
    assert_equal(bpa_verdict(Substitution.checked(tm), 20000, 400), BPA_FAILS)
    assert_equal(bpa_verdict(Substitution.checked(fib), 1, 400), BPA_CAPPED)
    # BST23 section 6.5: the Brun d = 4 periodic point tau
    assert_equal(periodic_verdict(brun_unordered(4), tau(), 20000, 2000), "bpa:terminates")
    require_claim("BrunFourPeriodicPointBPA")


def digits(w: List[Int]) -> String:
    var out = String("")
    for x in w:
        out += String(x)
    return out


def psc_corpus_lines() raises -> List[String]:
    """Data lines of tests/data/psc-pip-corpus.txt (PSC's pinned corpus; the
    pytest twin also checks their digest)."""
    var out = List[String]()
    with open("../tests/data/psc-pip-corpus.txt", "r") as f:
        for line in f.read().split("\n"):
            if line.byte_length() > 0 and not line.startswith("#"):
                out.append(String(line))
    return out^


def test_iota_embedding_reproduces_the_psc_corpus() raises:
    # Per instance, in PSC's enumeration order: each substitution is embedded
    # as the periodic directive sequence of a one-label full shift and certified
    # through the S-adic verdicts; the result is PSC's pinned corpus line by line.
    var words = List[List[Int]]()
    for n in range(1, 4):
        for w in words_of_length(3, n):
            words.append(w.copy())
    var expected = psc_corpus_lines()
    var certified = List[String]()
    var one: List[Int] = [0]
    for a in words:
        for b in words:
            for c in words:
                var images: List[List[Int]] = [a.copy(), b.copy(), c.copy()]
                var subs = List[Substitution]()
                subs.append(Substitution.checked(images))
                var shift = DirectiveShift.full("iota", subs)
                var m = prefix_matrix(shift, one)
                if primitivity_exponent(m, 3) < 0:
                    continue
                var f = charpoly(m, 3)
                if irreducibility_verdict(f).verdict == 1 and pisot_verdict(f) == 1:
                    certified.append(digits(a) + "|" + digits(b) + "|" + digits(c))
    assert_equal(len(expected), 4554)
    assert_equal(len(certified), len(expected))
    for i in range(len(expected)):
        assert_equal(certified[i], expected[i])
    require_claim("IotaEmbeddingPSCCorpus")


def test_brun_orbits() raises:
    # orbit sizes partition the periodic words; pinned with the oracle
    var words: List[Int] = [12, 6, 20, 60, 204, 670]
    var orbit_counts: List[Int] = [1, 1, 2, 5, 10, 35]
    for n in range(1, 7):
        var orbits = brun_orbit_words(4, n)
        var covered = 0
        for e in orbits:
            covered += e[len(e) - 1]
        assert_equal(covered, words[n - 1])
        assert_equal(len(orbits), orbit_counts[n - 1])


def test_theorem_b() raises:
    # docs/sadic-g6-brun-higher-census.md, Theorem B: an admissible unordered
    # Brun word using every letter has a composite constant on initial letters
    # (all images start with the first label's p) whose final-letter map is the
    # identity; so its reversal is in Barge's class.
    for d in range(3, 6):
        var shift = brun_unordered(d)
        var top = 7 if d == 3 else (6 if d == 4 else 5)
        var checked = 0
        for n in range(1, top + 1):
            for w in periodic_words(shift, n):
                var used = List[Bool]()
                for _ in range(d):
                    used.append(False)
                for t in w:
                    var i = t // (d - 1)
                    var j0 = t % (d - 1)
                    used[i] = True
                    used[j0 if j0 < i else j0 + 1] = True
                var all_used = True
                for u in used:
                    if not u:
                        all_used = False
                var sigma = shift.composite(w)
                for a in range(d):
                    assert_equal(sigma.images[a][len(sigma.images[a]) - 1], a)
                if all_used:
                    var first = w[0] // (d - 1)
                    for a in range(d):
                        assert_equal(sigma.images[a][0], first)
                    assert_true(in_mirror_class(sigma))
                    checked += 1
        assert_true(checked > 0)
    require_claim("BrunCompositesMirrorBargeClass")


def test_brun_five_periodic_point() raises:
    # docs/sadic-g6-brun-higher-census.md, Theorem C: a d = 5 periodic Pisot
    # point whose composite passes the balanced pair algorithm,
    # beta_12 beta_23 beta_31 beta_14 beta_45 beta_51 (1-based)
    var w: List[Int] = [0, 5, 8, 2, 15, 16]
    var b = brun_unordered(5)
    assert_true(periodic_admissible(b, w))
    assert_equal(periodic_verdict(b, w, 200000, 20000), "bpa:terminates")
    require_claim("BrunFivePeriodicPointBPA")


def test_brun_six_periodic_point() raises:
    # Theorem C, d = 6: beta_12 beta_23 beta_31 beta_14 beta_42 beta_25
    # beta_56 beta_61 (1-based) passes the balanced pair algorithm
    var w: List[Int] = [0, 6, 10, 2, 16, 8, 24, 25]
    var b = brun_unordered(6)
    assert_true(periodic_admissible(b, w))
    assert_equal(periodic_verdict(b, w, 200000, 20000), "bpa:terminates")
    require_claim("BrunSixPeriodicPointBPA")


def test_brun_seven_periodic_point() raises:
    # Theorem C, d = 7: beta_12 beta_23 beta_31 beta_14 beta_45 beta_51
    # beta_16 beta_62 beta_24 beta_47 beta_71 (1-based) passes the balanced
    # pair algorithm
    var w: List[Int] = [0, 7, 12, 2, 21, 24, 4, 31, 8, 23, 36]
    var b = brun_unordered(7)
    assert_true(periodic_admissible(b, w))
    assert_equal(periodic_verdict(b, w, 100000, 10000), "bpa:terminates")
    require_claim("BrunSevenPeriodicPointBPA")


def test_brun_pisot_periodic_points() raises:
    # Corollary B'' and Theorem C' (docs/sadic-g6-brun-higher-census.md §5):
    # for d = 7..10 a periodic Brun point whose composite is primitive, with an
    # irreducible Pisot characteristic polynomial, in the mirror Barge class
    var words = List[List[Int]]()
    var polys = List[List[Int]]()
    words.append([0, 7, 12, 2, 21, 24, 4, 35, 36])
    polys.append([-1, 7, -24, 47, -56, 39, -14, 1])
    words.append([0, 0, 8, 16, 24, 28, 1, 18, 40, 48, 49])
    polys.append([1, -8, 28, -57, 77, -73, 45, -16, 1])
    words.append([0, 9, 16, 2, 27, 32, 4, 45, 48, 6, 63, 64])
    polys.append([-1, 9, -40, 108, -192, 230, -184, 92, -24, 1])
    words.append([0, 9, 1, 20, 27, 3, 40, 50, 54, 6, 67, 43, 80, 81])
    polys.append([1, -11, 54, -158, 309, -425, 417, -286, 127, -30, 1])
    for k in range(len(words)):
        var d = 7 + k
        var b = brun_unordered(d)
        assert_true(periodic_admissible(b, words[k]))
        var m = prefix_matrix(b, words[k])
        assert_true(primitivity_exponent(m, d) >= 0)
        var f = charpoly(m, d)
        assert_true(same(f, polys[k]))
        assert_equal(irreducibility_verdict(f).verdict, 1)
        assert_equal(pisot_verdict(f), 1)
        assert_true(in_mirror_class(b.composite(words[k])))
    require_claim("BrunPisotPeriodicPoints")


def test_brun_classes() raises:
    # kernel/brun_witness.mojo `pip`: classes of periodic words using every
    # letter under rotation and letter permutation, and those whose composite
    # is primitive, irreducible and Pisot. The PIP counts equal the orbit
    # census (docs/sadic-g6-brun-higher-census.md §4); the oracle pins d = 5,
    # periods 1-7 (tests/test_sadic_spectrum.py, tools/cross_check.py)
    var cases: List[List[Int]] = [
        [5, 1, 0, 0], [5, 2, 0, 0], [5, 3, 0, 0], [5, 4, 0, 0], [5, 5, 1, 0],
        [5, 6, 3, 3], [5, 7, 20, 18], [5, 8, 136, 125], [6, 7, 3, 1], [6, 8, 36, 12],
    ]
    for c in cases:
        var shift = brun_unordered(c[0])
        var classes = brun_classes(c[0], c[1])
        var kept = 0
        for w in classes:
            assert_true(periodic_admissible(shift, w))
            if is_pip(shift, w):
                kept += 1
        assert_equal(len(classes), c[2])
        assert_equal(kept, c[3])
    require_claim("BrunClassEnumeration")


def main() raises:
    test_charpoly()
    test_disc_zero_count()
    test_pisot_verdict()
    test_irreducibility_verdict()
    test_primitivity_exponent()
    test_brun_unordered()
    test_bpa_verdict()
    test_brun_orbits()
    test_brun_classes()
    test_theorem_b()
    test_brun_five_periodic_point()
    test_brun_six_periodic_point()
    test_brun_seven_periodic_point()
    test_brun_pisot_periodic_points()
    test_iota_embedding_reproduces_the_psc_corpus()
    print("sadic spectrum and periodic layer: all assertions passed")
