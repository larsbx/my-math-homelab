"""Independent edge-count and alias oracles for the existing H3 contract."""
import json
import unittest
from collections import defaultdict
from fractions import Fraction
from itertools import combinations, permutations, product
from unittest.mock import patch

from support import ROOT, load

H = load("experiments/n2/h3_conditioned.py", "h3_conditioned_audit")

GUARDS_CLAIM = "H3ConditionedIntegral"
GUARDS_CONTRACT = "Explicit H3 alias enumeration, representative sensitivity and permutation expectation"


class TestIndependentH3Audit(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gens = H.generators(1, 7, 1)
        labels = H.Labels(cls.gens, 4)
        cls.aliases = defaultdict(list)
        # A Cartesian traversal does not use the driver's prefix enumerator.
        for word in product(range(14), repeat=4):
            if any(b == (a + 7) % 14 for a, b in zip(word, word[1:])):
                continue
            value, operator = H.evaluate(tuple(cls.gens[i] for i in word))
            cls.aliases[value, operator].append((word, labels(word)))
        cls.records = H.quotient(cls.gens, 4)

    def test_first_last_and_ambiguity_against_all_aliases(self):
        """Cartesian word evaluation pins every quotient class and both extremal representatives."""
        self.assertEqual(sum(map(len, self.aliases.values())), 30758)
        self.assertEqual(len(self.records), len(self.aliases))
        self.assertEqual(len(self.records), 114)
        for record in self.records:
            aliases = self.aliases[record["value"], record["product"]]
            self.assertEqual(record["count"], len(aliases))
            self.assertEqual((record["first"], record["first_label"]), min(aliases))
            self.assertEqual((record["last"], record["last_label"]), max(aliases))
            self.assertEqual(record["ambiguous_classical"], len({label[0] for _, label in aliases}) > 1)
            self.assertEqual(record["ambiguous_enriched"], len({label for _, label in aliases}) > 1)

    def test_both_policies_against_explicit_edges_and_unequal_alias_weights(self):
        """Direct pairs pin moments and controls; changing alias weights leaves quotient statistics fixed."""
        summary = json.loads((ROOT / "data/n2/h3-conditioned-v1.json").read_text())
        row = next(r for r in summary["rows"] if r["id"] == "exploratory-unit-p1")
        all_edges = list(combinations(self.records, 2))
        self.assertEqual(sum(a["value"] == b["value"] for a, b in all_edges), 350)
        for policy in ("first", "last"):
            key = policy + "_label"
            for enriched in (False, True):
                edges = [(a, b) for a, b in all_edges
                         if (a[key] == b[key] if enriched else a[key][0] == b[key][0])]
                stats = H.moments(self.records, policy, enriched)
                self.assertEqual(stats["eligible_pairs"], len(edges))
                self.assertEqual(stats["value_only_pairs"], sum(a["value"] == b["value"] for a, b in edges))
            matched = [(a, b) for a, b in all_edges
                       if a[key][0] == b[key][0] and a["value"][0] == b["value"][0]]
            colliding = [(a, b) for a, b in matched if a["value"] == b["value"]]
            controls = [(a, b) for a, b in matched if a["value"] != b["value"]]
            stats = H.matched_controls(self.records, policy)
            self.assertEqual(stats["eligible_pairs"], len(matched))
            self.assertEqual(stats["collision_pairs"], len(colliding))
            self.assertEqual(stats["collision_same_extra"], sum(a[key][1] == b[key][1] for a, b in colliding))
            self.assertEqual(stats["noncollision_pairs"], len(controls))
            self.assertEqual(stats["noncollision_same_extra"], sum(a[key][1] == b[key][1] for a, b in controls))
            self.assertEqual(json.loads(H.compact(stats)), row["policies"][policy]["matched_control"])
        # Deliberately unequal new word weights, on genuine nonzero-collision classes.
        weighted = []
        for i, ((value, operator), aliases) in enumerate(self.aliases.items()):
            for word, _ in aliases:
                weighted.extend([(word, value, operator)] * (1 + i % 3))
        weighted.sort(key=lambda item: item[0])
        with patch.object(H, "enumerate_words", return_value=iter(weighted)):
            reweighted, _ = H.analyse(self.gens, 4, "audit-reweighted")
        self.assertNotEqual(reweighted["words"], row["words"])
        self.assertNotEqual(reweighted["raw_value_only_pairs"], row["raw_value_only_pairs"])
        self.assertEqual(reweighted["quotient_value_only_pairs"], row["quotient_value_only_pairs"])
        self.assertEqual(json.loads(H.compact(reweighted["policies"])), row["policies"])

    def test_multiple_block_null_against_every_label_permutation(self):
        """Enumerate 3! times 4! permutations: labels stay inside their Gram/trace blocks."""
        groups = [((1, 1, 2), (0, 0, 1)), ((3, 4, 4, 5), (0, 1, 1, 2))]
        records = []
        for block, (values, labels) in enumerate(groups):
            for value, label in zip(values, labels):
                records.append({"value": (0, value), "first": (len(records),),
                                "first_label": ((block,), (label,))})
        total = 0
        trials = 0
        for assignments in product(*(permutations(labels) for _, labels in groups)):
            for (values, _), assignment in zip(groups, assignments):
                total += sum(values[i] == values[j] and assignment[i] == assignment[j]
                             for i, j in combinations(range(len(values)), 2))
            trials += 1
        stats = H.matched_controls(records, "first")
        self.assertEqual(Fraction(stats["permuted_label_expected_same"]), Fraction(total, trials))
        self.assertEqual(Fraction(total, trials), Fraction(1, 2))
        self.assertEqual(stats["blocks_with_collisions"], 2)
        self.assertEqual(stats["informative_blocks"], 2)


if __name__ == "__main__":
    unittest.main()
