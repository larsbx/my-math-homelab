"""Regression for PR #12 review: finite mathematical success cannot hide bad CI."""
from __future__ import annotations

from copy import deepcopy
from pathlib import Path
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"tools"))
from math_research_portfolio import attach_verified_finite_adapter


class FiniteResultPriority(unittest.TestCase):
    EVIDENCE={
        "schema":"FINITE-REPLAY-TEST","verdict":"finite_specimens_verified",
        "next_research_obligation":"Investigate the next exact lemma.",
    }

    def test_finite_success_does_not_override_failed_source_ci(self):
        for evidence_state,primary in [
            ("source_ci_regression_observed","Fix failing exact-head CI"),
            ("source_ci_pending","Inspect queued exact-head CI"),
            ("exact_head_ci_unverified","Required checks were not available"),
        ]:
            with self.subTest(state=evidence_state):
                record={"evidence_state":evidence_state,
                        "next_research_obligation":primary}
                attach_verified_finite_adapter(
                    record,self.EVIDENCE,scope_fields={"specimens":6})
                self.assertEqual(record["next_research_obligation"],primary)
                self.assertEqual(record["mathematical_next_research_obligation"],
                                 "Investigate the next exact lemma.")
                self.assertTrue(record["independent_finite_fixture_verified"])
                self.assertFalse(record["independent_mathematical_claim_verified"])

    def test_successful_observed_ci_allows_math_followup_but_not_proof(self):
        record={"evidence_state":"source_evidence_recorded",
                "next_research_obligation":"Review open PR"}
        attach_verified_finite_adapter(
            record,self.EVIDENCE,scope_fields={})
        self.assertEqual(record["next_research_obligation"],
                         self.EVIDENCE["next_research_obligation"])
        self.assertFalse(record["independent_mathematical_claim_verified"])


if __name__=="__main__":
    unittest.main()
