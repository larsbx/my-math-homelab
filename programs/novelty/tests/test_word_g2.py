import json
import random
import unittest
from itertools import permutations, product

from support import ROOT, load

G = load("experiments/n2/word_g2.py", "word_g2")
C, WD = G.C, G.WD
GUARDS_CLAIM = "WordDefectG2Data"
GUARDS_CONTRACT = "WordDefectG2Data certificates and equivariance"
DATA = ROOT / "data/n2/word-g2-v1.json"


def rand(ell, rng):
    while True:
        a = tuple(rng.randrange(ell) for _ in range(C.DIM))
        if C.norm(a, ell):
            return a


def g_u(u, ell):
    """The linear map (a, b) -> (a, (u b) e4) in coordinates a = x[:4], b = x[4:] read as a quaternion."""
    images = []
    for e in C.BASIS:
        a, b = e[:4] + (0,) * 4, e[4:] + (0,) * 4
        images.append(tuple((s + t) % ell for s, t in zip(a, C.mul(C.mul(u, b, ell), C.BASIS[4], ell))))
    return C.transpose(images)


def is_automorphism(g, ell):
    return all(C.apply(g, C.mul(a, b, ell), ell) == C.mul(C.apply(g, a, ell), C.apply(g, b, ell), ell)
               for a in C.BASIS for b in C.BASIS)


class TestEquivariance(unittest.TestCase):
    def test_automorphisms_conjugate_word_defects_and_preserve_both_forms(self):
        """W(g a) = g W(a) g^-1 for g in Aut(C), so the characteristic polynomial is G2 data; g preserves phi, psi."""
        for ell in (3, 5, 7):
            rng = random.Random(ell)
            units = [v + (0,) * 4 for v in product(range(ell), repeat=4)
                     if C.norm(v + (0,) * 4, ell) == 1 and sum(map(bool, v)) >= 2]
            for u in rng.sample(units, 3):
                g = g_u(u, ell)
                self.assertTrue(is_automorphism(g, ell))
                for n in (3, 4, 5):
                    letters = [rand(ell, rng) for _ in range(n)]
                    moved = [C.apply(g, a, ell) for a in letters]
                    self.assertEqual(C.matmul(WD.word_defect(moved, ell), g, ell),
                                     C.matmul(g, WD.word_defect(letters, ell), ell))
                    self.assertEqual(G.forms_agree([G.pure(a) for a in letters], [G.pure(a) for a in moved], ell),
                                     (True, True))


class TestFourFormNormalization(unittest.TestCase):
    def test_skew_sum_is_twelve_psi_and_psi_has_content_four(self):
        """Theorem 3.32 (proof), exhaustive over Z. Both sides of sum_sigma sgn t(((p1 p2) p3) p4) = 12 psi are
        multilinear in (p1, ..., p4) on 1-perp, so checking every quadruple of basis vectors e1..e7 proves it, and
        the basis values of psi, {0, 4, -4}, give psi content 4: nonzero mod every odd ell, while the unnormalized
        skew-sum vanishes mod 3. The proof therefore compares Q' with psi through the dimension of the invariant
        space, not a normalization. Lift: e_i e_j = +-e_k, so over Z every intermediate product is a signed basis
        vector, |trace| <= 2 and |psi| <= 4, and the centred residue mod P is the integer value."""
        P = (1 << 61) - 1
        lift = lambda x: x if x <= P // 2 else x - P
        self.assertTrue(all(s in (1, -1) for _, s in C.STRUCTURE.values()))
        trace = lambda x: lift(2 * x[0] % P)
        perms = [(perm, (-1) ** sum(perm[i] > perm[j] for i in range(4) for j in range(i + 1, 4)))
                 for perm in permutations(range(4))]
        values = set()
        for ps in product(C.BASIS[1:], repeat=4):
            skew = sum(sgn * trace(C.mul(C.mul(C.mul(ps[a], ps[b], P), ps[c], P), ps[d], P)) for (a, b, c, d), sgn in perms)
            psi = lift(G.psi(*ps, P))
            self.assertEqual(skew, 12 * psi, ps)
            values.add(psi)
        self.assertEqual(values, {0, 4, -4})


class TestCertificates(unittest.TestCase):
    def test_neither_form_alone_fixes_the_characteristic_polynomial(self):
        certificates = json.loads(DATA.read_text(encoding="utf-8"))["certificates"]
        for key, expected in (("phi_only", (True, False, False)), ("psi_only", (False, True, False))):
            cert = certificates[key]
            letters = [tuple(a) for a in cert["letters"]]
            reflections = [tuple(u) for u in cert["reflections"]]
            self.assertEqual(G.compare(letters, reflections, cert["ell"]), expected, key)


class TestCensus(unittest.TestCase):
    def test_committed_census_is_current_and_both_forms_always_suffice(self):
        text = DATA.read_text(encoding="utf-8")
        self.assertEqual(text, G.render())
        rows = json.loads(text)["rows"]
        self.assertTrue(all("both_changed" not in r and r["both_same"] > 0 for r in rows))


if __name__ == "__main__":
    unittest.main()
