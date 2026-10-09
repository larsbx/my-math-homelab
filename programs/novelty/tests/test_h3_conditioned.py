import copy
import gzip
import hashlib
import json
import unittest
from fractions import Fraction
from itertools import combinations, permutations

from support import ROOT, load

H = load("experiments/n2/h3_conditioned.py", "h3_conditioned")
G = load("experiments/n2/word_g2.py", "word_g2_conditioned")
from n1 import cayley_dickson as cd

GUARDS_CLAIM = "H3ConditionedIntegral"
GUARDS_CONTRACT = "H3ConditionedIntegral integer arithmetic, quotient, conditioning, controls and certificates"


class TestArithmetic(unittest.TestCase):
    def test_integer_products_and_operator_orientation_against_recursive_kernel(self):
        gens = H.generators(3, 3, 1)
        params = (Fraction(-1),) * 3
        for x in gens:
            for y in gens:
                product = cd.mul(tuple(map(Fraction, x)), tuple(map(Fraction, y)), params)
                self.assertEqual(H.mul(x, y), product)
                self.assertEqual(H.norm(product), 9)
        letters = tuple(gens[i] for i in (0, 1, 2, 0, 4))
        value, operator = H.evaluate(letters)
        oracle_value = letters[0]
        for a in letters[1:]:
            oracle_value = cd.mul(oracle_value, a, params)
        self.assertEqual(value, oracle_value)
        for j, e in enumerate(H.C.BASIS):
            image = e
            for a in reversed(letters):
                image = cd.mul(a, image, params)
            self.assertEqual(tuple(row[j] for row in operator), image)
        self.assertEqual(H.norm(value), 3 ** len(letters))

    def test_dim_q_over_rationals_including_boundaries(self):
        one, x, y = H.C.BASIS[:3]
        self.assertEqual(H.rank_q((one, one, one, one)), 1)
        self.assertEqual(H.rank_q((one, x, x, H.mul(x, x))), 2)
        self.assertEqual(H.rank_q((one, x, y, H.mul(x, y))), 4)
        labels = H.Labels((x, y, H.conj(x), H.conj(y)), 2)
        self.assertEqual(labels((0, 0))[1], (2,))
        self.assertEqual(labels((0, 1))[1], (4,))

    def test_all_word_form_coordinates_have_pinned_sign_and_polarization(self):
        gens = H.generators(3, 3, 1)
        labels = H.Labels(gens, 5)
        # Both distinct and repeated generator indices, including odd permutations.
        for ids in ((0, 2, 1, 4, 3), (3, 0, 2, 1, 5), (0, 0, 1, 2, 1)):
            ps = [H.pure(gens[i]) for i in ids]
            classical, extra = labels(ids)
            triples = tuple(H.phi(*(ps[i] for i in t)) for t in combinations(range(5), 3))
            quadruples = tuple(H.psi(*(ps[i] for i in t)) for t in combinations(range(5), 4))
            self.assertEqual(extra, triples + quadruples)
            for ell in (3, 5, 7):
                pm = [tuple(t % ell for t in p) for p in ps]
                self.assertEqual(tuple(t % ell for t in triples),
                                 tuple(G.phi(*(pm[i] for i in t), ell) for t in combinations(range(5), 3)))
                self.assertEqual(tuple(t % ell for t in quadruples),
                                 tuple(G.psi(*(pm[i] for i in t), ell) for t in combinations(range(5), 4)))
            self.assertEqual(classical[0], 2)


class TestSampling(unittest.TestCase):
    def test_shell_and_sha256_sample_contract(self):
        for p in (3, 5):
            shell = H.shell(p)
            self.assertEqual(list(shell), H.PILOT.shell(p))
            self.assertEqual(len(shell), 16 * (p ** 3 + 1))
            self.assertEqual(tuple(sorted(set(shell))), shell)
        gens = H.generators(3, 3, 1)
        self.assertEqual(H.digest(gens), "sha256:810eccfe40424b2f02b59ee937b5497d50e5a49e4ecf0e64ab45e5fb2f011cf9")
        self.assertEqual(gens[3:], tuple(H.conj(g) for g in gens[:3]))
        self.assertEqual(len(set(gens)), 6)
        for x in gens:
            self.assertEqual(H.norm(x), 3)
            self.assertEqual(H.mul(x, H.conj(x)), (3,) + (0,) * 7)
        with self.assertRaises(ValueError):
            H.generators(3, 0, 1)
        with self.assertRaises(ValueError):
            H.shell(-1)

    def test_enumeration_count_order_reduction_and_value_norm(self):
        gens = H.generators(3, 2, 1)
        for n in (2, 4, 5):
            rows = list(H.enumerate_words(gens, n))
            self.assertEqual(len(rows), 4 * 3 ** (n - 1))
            self.assertEqual([r[0] for r in rows], sorted(r[0] for r in rows))
            self.assertTrue(all(H.reduced(ids, 2) and H.norm(v) == 3 ** n for ids, v, op in rows))


class TestQuotientAndStatistics(unittest.TestCase):
    def test_operator_alias_multiplicities_do_not_enter_collision_counts(self):
        gens = H.COMPLEX + tuple(H.conj(x) for x in H.COMPLEX)
        rows = list(H.enumerate_words(gens, 4))
        by_value = {}
        for ids, value, op in rows:
            # Composition on this complex line is multiplicative on all C.
            self.assertEqual(op, H.left(value))
            by_value.setdefault(value, []).append(ids)
        row, cert = H.analyse(gens, 4, "complex-p5-m2-n4", "negative_control")
        self.assertEqual(row["operator_classes"], len(by_value))
        self.assertGreater(row["raw_operator_collision_pairs"], 0)
        self.assertEqual(row["raw_value_only_pairs"], 0)
        self.assertEqual(row["quotient_value_only_pairs"], 0)
        self.assertGreater(row["ambiguous_enriched_classes"], 0)
        self.assertEqual(H.replay({"rows": [cert], "controls": H.negative_controls()}), 0)
        committed = json.loads(H.OUT.read_text())
        self.assertEqual(json.loads(H.compact(row)), next(r for r in committed["rows"] if r["id"] == row["id"]))

    def test_moments_and_permutation_null_against_exhaustive_small_graph(self):
        # Five quotient units in a single Gram/trace block; two collision edges.
        vs, labels = (1, 1, 2, 3, 3), (0, 0, 1, 1, 2)
        records = [{"value": (0, v), "first_label": ((7,), (label,)), "first": (i,)}
                   for i, (v, label) in enumerate(zip(vs, labels))]
        collision_edges = [(i, j) for i, j in combinations(range(5), 2) if vs[i] == vs[j]]
        observed = sum(labels[i] == labels[j] for i, j in collision_edges)
        expectation = Fraction(sum(sum(p[i] == p[j] for i, j in collision_edges)
                                   for p in permutations(labels)), 120)
        stats = H.matched_controls(records, "first")
        self.assertEqual(stats["collision_pairs"], len(collision_edges))
        self.assertEqual(stats["collision_same_extra"], observed)
        self.assertEqual(Fraction(stats["permuted_label_expected_same"]), expectation)
        self.assertEqual(stats["enrichment_ratio"], "4")
        self.assertEqual(H.moments(records, "first", False)["collision_rate"], "1/5")
        self.assertEqual(H.moments(records, "first", True)["collision_rate"], "1/2")
        self.assertIsNone(H.matched_controls(records[:1], "first")["enrichment_ratio"])


class TestCertificates(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.bundle = H.read_certificates()
        cls.summary = json.loads(H.OUT.read_text())

    def test_all_certificates_are_bound_to_evidence_and_pair_counts(self):
        self.assertEqual("sha256:" + hashlib.sha256(gzip.decompress(H.CERTS.read_bytes())).hexdigest(), self.summary["certificate_digest"])
        for row, cert in zip(self.summary["rows"], self.bundle["rows"], strict=True):
            self.assertEqual(row["id"], cert["id"])
            self.assertEqual(row["generators"], cert["generators"])
            self.assertEqual(row["quotient_value_only_pairs"],
                             sum(H.choose2(len(f["classes"])) for f in cert["collision_fibres"]))
        self.assertEqual(self.summary["status"], "bounded experiment; H3 open")
        records = json.loads((ROOT / "research/ledger.json").read_text())["records"]
        self.assertEqual(dict(records["H3ConditionedIntegral"]["evidence"])["digest"],
                         "sha256:" + hashlib.sha256(H.OUT.read_bytes()).hexdigest())
        self.assertEqual(records["DefectStratifiedCollisions"]["kind"], "pending_dependency")
        self.assertEqual(records["WordDefectG2Data"]["kind"], "bounded_experiment")

    def test_real_collision_and_mutations(self):
        row = next(r for r in self.bundle["rows"] if r["collision_fibres"])
        sample = copy.deepcopy({"rows": [row], "controls": self.bundle["controls"]})
        sample["rows"][0]["collision_fibres"] = sample["rows"][0]["collision_fibres"][:1]
        self.assertGreater(H.replay(sample), 0)
        for mutation in ("value", "operator", "duplicate", "word", "multiplicity"):
            bad = copy.deepcopy(sample)
            fibre = bad["rows"][0]["collision_fibres"][0]
            if mutation == "value":
                fibre["value"][0] += 1
            elif mutation == "operator":
                fibre["classes"][0][1] = fibre["classes"][1][0]
            elif mutation == "duplicate":
                fibre["classes"][1] = fibre["classes"][0]
            elif mutation == "word":
                fibre["classes"][0][0] = len(row["generators"]) ** row["length"]
            else:
                fibre["classes"][0][2] = 0
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                H.replay(bad)

    def test_single_form_and_pilot_controls_remain_falsifiers(self):
        controls = H.negative_controls()
        self.assertTrue(controls["pilot_length_three"]["values_equal"])
        self.assertFalse(controls["pilot_length_three"]["operators_equal"])
        self.assertEqual([(c["phi_preserved"], c["psi_preserved"], c["charpoly_preserved"])
                          for k, c in sorted(controls["finite_field_form_only"].items())],
                         [(True, False, False), (False, True, False)])


if __name__ == "__main__":
    unittest.main()
