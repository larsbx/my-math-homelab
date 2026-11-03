"""Public homelab must never export private-source revision or evidence."""
from __future__ import annotations

import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import math_research_portfolio as portfolio


class PrivateSourceIsolation(unittest.TestCase):
    def test_all_current_private_sources_explicitly_isolated(self):
        tracks, locks, _ = portfolio.registry()
        isolated = {
            x["id"] for x in tracks
            if x.get("source_access_policy") == "private_isolated"
        }
        self.assertEqual(isolated, {
            "closure-fiber", "finite-julia", "giant-fibers"
        })
        for id_ in isolated:
            # The historical source-lock declaration is stale. It must
            # not authorize publishing current private data.
            self.assertEqual(locks[id_]["visibility"], "public")

    def test_daily_cycle_never_attempts_private_api_access(self):
        for id_ in ("closure-fiber", "finite-julia", "giant-fibers"):
            with self.subTest(programme=id_), tempfile.TemporaryDirectory() as tmp:
                with patch.object(portfolio, "observe",
                                  side_effect=AssertionError("private data accessed")):
                    code = portfolio.run(
                        "daily", Path(tmp), select_ids=[id_])
                self.assertEqual(code, 0)
                record = json.loads(
                    (Path(tmp)/(id_+".json")).read_text())
                self.assertEqual(record["evidence_state"],
                                 "private_source_isolated")
                self.assertFalse(record["source_contents_retrieved"])
                self.assertNotIn("head_sha", record)
                self.assertNotIn("exact_head_workflow_runs", record)
                self.assertNotIn("source_evidence", record)
                summary = json.loads(
                    (Path(tmp)/"portfolio-index.json").read_text())
                self.assertEqual(summary["private_sources_isolated"], [id_])
                self.assertEqual(summary["unreadable_sources"], [])

    def test_public_lane_refuses_private_metadata_even_if_authorized(self):
        tracks, locks, _ = portfolio.registry()
        public = next(t for t in tracks if t["id"] == "arithmetic-bicycle")
        with patch.object(portfolio, "get_json", return_value={
                "private": True,
                "full_name": public["source_repository"],
                "default_branch": "main",
        }):
            with self.assertRaisesRegex(ValueError, "private repository"):
                portfolio.observe(public, locks[public["id"]], "daily")


if __name__ == "__main__":
    unittest.main()
