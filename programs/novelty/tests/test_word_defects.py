import json
import random
import unittest

from support import ROOT, load

W = load("experiments/n2/word_defects.py", "word_defects")
C, R = W.C, W.R
GUARDS_CLAIM = "WordDefectNotClassical"
GUARDS_CONTRACT = "WordDefectLengthThreeClassical inner-product reductions"


def rand(ell, rng):
    return tuple(rng.randrange(ell) for _ in range(C.DIM))


class TestCertificate(unittest.TestCase):
    def test_rotation_fixing_one_changes_a_length_four_defect(self):
        """h = s_e1 s_(e1 + e4) fixes 1, has determinant 1, preserves the Gram matrix of (1, letters),
        and changes the characteristic polynomial of the length-4 word defect over F_3."""
        cert = W.certificate()
        ell = cert["ell"]
        letters = [tuple(a) for a in cert["letters"]]
        u, w = (tuple(r) for r in cert["reflections"])
        h = C.matmul(W.reflection(u, ell), W.reflection(w, ell), ell)
        self.assertEqual(C.apply(h, C.BASIS[0], ell), C.BASIS[0])
        self.assertEqual(C.echelon([list(r) for r in h], ell)[1], 1)
        images = W.moved(letters, [u, w], ell)
        gram = lambda vs: [[R.bilinear(s, t, ell) for t in vs] for s in vs]
        self.assertEqual(gram([C.BASIS[0]] + letters), gram([C.BASIS[0]] + images))
        self.assertTrue(cert["differ"])

    def test_committed_census_is_current(self):
        self.assertEqual((ROOT / "data/n2/word-defects-v1.json").read_text(encoding="utf-8"), W.render())


class TestLengthThreeReductions(unittest.TestCase):
    def test_inner_products_with_the_value_are_gram_data(self):
        """For v = (ab)c every inner product among a, conj(b), c, v reduces to the Gram matrix of (1, a, b, c);
        bab = B(a, conj b) b - N(b) conj(a) is the key identity."""
        for ell in (3, 5, 7, 11):
            rng = random.Random(ell)
            for _ in range(300):
                a, b, c = rand(ell, rng), rand(ell, rng), rand(ell, rng)
                cj = lambda x: C.conj(x, ell)
                bil = lambda x, y: R.bilinear(x, y, ell)
                tr = lambda x: bil(x, C.BASIS[0])
                nb = C.norm(b, ell)
                bab = C.mul(C.mul(b, a, ell), b, ell)
                self.assertEqual(bab, tuple((bil(a, cj(b)) * s - nb * t) % ell for s, t in zip(b, cj(a))))
                v = C.mul(C.mul(a, b, ell), c, ell)
                self.assertEqual(bil(a, v), C.norm(a, ell) * bil(cj(c), b) % ell)
                self.assertEqual(bil(cj(b), v), (bil(a, cj(b)) * tr(C.mul(c, b, ell)) - nb * tr(C.mul(c, cj(a), ell))) % ell)
                self.assertEqual(bil(c, v), C.norm(c, ell) * tr(C.mul(a, b, ell)) % ell)

    def test_length_three_defects_are_invariant_over_f11_and_f13(self):
        """Proposition 3.26 covers characteristic 0 and characteristic > 8; sampled here."""
        for ell in (11, 13):
            rng = random.Random(100 + ell)
            pure = lambda: (0,) + tuple(rng.randrange(ell) for _ in range(C.DIM - 1))
            done = 0
            while done < 40:
                letters = [rand(ell, rng) for _ in range(3)]
                reflections = [pure(), pure()]
                if not all(C.norm(a, ell) for a in letters + reflections):
                    continue
                done += 1
                self.assertEqual(C.charpoly(W.word_defect(letters, ell), ell),
                                 C.charpoly(W.word_defect(W.moved(letters, reflections, ell), ell), ell))


if __name__ == "__main__":
    unittest.main()
