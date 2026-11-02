"""Independent historical graph6 corpus and domination-number negative controls."""
from __future__ import annotations

from copy import deepcopy
import sys
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/"tools"))
from math_adapters.vizing_domination import (
    check_mapping, decode_graph6, domination_number,
    find_isomorphism, verify_casebase,
)

HISTORICAL = ["I?r@`aii_","I?r@`_iy_","I?r@`biI_","I?r@`aIm_","I?r@`aya_","I?r@`aaj_","I?r@`amg_","I?r@`agio","I?r@`aji?","I?r?`rgIo","I?r@``gYo","I?r@`bhIO","I?r@obgIo","IGR@`bgIo","IOb@`bgIo","I?r@`bgIo"]


def source_fixture():
    return {
        "schema_version": 1,
        "kind": "historical_casebase_only",
        "promotion_status": "blocked_pending_authoritative_census",
        "classes": [
            {"entry_ids": [1], "representative_graph6": HISTORICAL[0]},
            {"entry_ids": list(range(2, 16)),
             "representative_graph6": HISTORICAL[1]},
            {"entry_ids": [16], "representative_graph6": HISTORICAL[15]},
        ],
    }


class HistoricalVDResearch(unittest.TestCase):
    def test_independent_census_and_witnesses(self):
        out = verify_casebase(chr(10).join(HISTORICAL)+chr(10), source_fixture(),
                              source_commit="a"*40,
                              sources_sha256={"graph6":"b"*64,"classes":"c"*64})
        self.assertEqual((out["n_graphs"], out["iso_classes"],
                          out["group_sizes"]), (16,3,[1,1,14]))
        self.assertEqual(len(out["gamma_witnesses"]),16)
        self.assertTrue(all(x["domination_number"]==4
                            for x in out["gamma_witnesses"]))
        self.assertFalse(out["census_complete"])
        self.assertFalse(out["vizing_conjecture_proved"])
        self.assertIn("491-entry",out["scope"])

    def test_identical_graphs_have_exact_bijection(self):
        a=decode_graph6(HISTORICAL[1])
        b=decode_graph6(HISTORICAL[8])
        self.assertTrue(check_mapping(a,b,find_isomorphism(a,b)))
        c=decode_graph6(HISTORICAL[0])
        self.assertIsNone(find_isomorphism(c,a))

    def test_histogram_wrong_promotion_rejected(self):
        bad=source_fixture()
        bad["promotion_status"]="proved"
        with self.assertRaisesRegex(ValueError,"promoted"):
            verify_casebase(chr(10).join(HISTORICAL),bad,
                            source_commit="a"*40,
                            sources_sha256={"graph6":"b"*64,"classes":"c"*64})

    def test_duplicate_class_or_misassignment_rejected(self):
        bad=source_fixture()
        bad["classes"][1]["entry_ids"]=[1,*range(2,16)]
        with self.assertRaises(ValueError):
            verify_casebase(chr(10).join(HISTORICAL),bad,
                            source_commit="a"*40,
                            sources_sha256={"graph6":"b"*64,"classes":"c"*64})

    def test_exact_graph6_decode_rejects_modified_padding(self):
        malformed=HISTORICAL[0][:-1]+"~"
        with self.assertRaisesRegex(ValueError,"padding"):
            decode_graph6(malformed)

    def test_domination_is_exact_not_computed_by_source_oracle(self):
        isolated=(0,0,0)
        self.assertEqual(domination_number(isolated)[0],3)
        triangle=(6,5,3)
        self.assertEqual(domination_number(triangle)[0],1)


if __name__ == "__main__":
    unittest.main()
