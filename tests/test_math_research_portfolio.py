"""Research portfolio conformance: coverage, provable evidence, fail-closed states."""
from __future__ import annotations

from copy import deepcopy
from hashlib import sha1
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/"tools"))

import math_research_portfolio as portfolio


class ResearchPortfolio(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tracks, cls.locks, cls.policy = portfolio.registry()

    def test_exactly_all_active_homelab_sources_are_registered(self):
        self.assertEqual(len(self.tracks), 16)
        self.assertEqual(len(self.locks), 16)
        self.assertEqual(len({t["claim_namespace"] for t in self.tracks}), 16)
        self.assertEqual(
            len([x for x in self.tracks if x["kind"] == "program"]), 14)
        self.assertEqual(
            len([x for x in self.tracks if x["kind"] == "shared"]), 2)
        self.assertEqual(
            [t["id"] for t in self.tracks if t["mode"] == "specialized_akn"],
            ["tiling-theory"])
        self.assertTrue(all(not t["automatic_claim_promotion"]
                            and not t["automatic_merge"] for t in self.tracks))

    def test_weekly_shards_cover_each_source_once(self):
        chunks = [portfolio.select(self.tracks, "weekly", shard=i)
                  for i in range(4)]
        flattened = [p["id"] for batch in chunks for p in batch]
        self.assertEqual(len(flattened), 16)
        self.assertEqual(set(flattened), {x["id"] for x in self.tracks})
        self.assertEqual([len(c) for c in chunks], [4]*4)
        with self.assertRaises(AssertionError):
            portfolio.select(self.tracks, "daily", shard=0)
        with self.assertRaises(AssertionError):
            portfolio.select(self.tracks, "weekly", shard=4)

    def test_github_workflow_schedules_match_registry(self):
        text = (ROOT/".github/workflows/math-estate-research.yml").read_text()
        self.assertIn(self.policy["daily_cron_utc"], text)
        self.assertIn(self.policy["weekly_cron_utc"], text)
        self.assertIn("matrix:", text)
        self.assertIn("shard: [0, 1, 2, 3]", text)
        self.assertIn("if: always()", text)
        self.assertNotIn("contents: write", text)
        self.assertNotIn("pull-requests: write", text)

    def test_known_git_blob_sha_and_independent_bytes(self):
        # This is Git's documented blob SHA1 for 'hello world\\n'.
        raw = b"hello world" + bytes([10])
        self.assertEqual(portfolio.git_blob_sha1(raw),
                         "3b18e512dba79e4c8300dd08aeb37f8e728b8dad")
        with patch.object(portfolio, "resource") as api:
            import base64
            api.return_value = {
                "type": "file", "encoding": "base64",
                "content": base64.b64encode(raw).decode(),
                "sha": portfolio.git_blob_sha1(raw)
            }
            proof = portfolio.evidence_file(
                "larsbx/repo", "a"*40, "README.md")
            self.assertEqual(proof["at_commit"], "a"*40)
            self.assertEqual(proof["bytes"], len(raw))
            api.return_value["sha"] = "b"*40
            with self.assertRaises(AssertionError):
                portfolio.evidence_file("larsbx/repo", "a"*40, "README.md")

    def test_nonexclusive_status_does_not_become_accepted_theorem(self):
        t = self.tracks[0]
        sha = "c"*40
        def fake_json(url):
            return {"full_name": t["source_repository"], "default_branch": "main"}
        def fake_resource(repo, path):
            if path.startswith("git/ref/heads/"):
                return {"object": {"sha": sha}}
            if path.startswith("pulls?"):
                return [{"number": 5, "title": "Exact lemma pilot",
                         "head": {"sha": "a"*40}, "base": {"ref": "main"},
                         "draft": False, "html_url": "https://github.com/a/b/pull/5"}]
            if path.startswith("issues?"):
                return [{"number": 3, "title": "Open proof obligation",
                         "html_url": "https://github.com/a/b/issues/3"}]
            if path.startswith("actions/runs"):
                return {"workflow_runs": [
                    {"head_sha": sha, "name": "finite evidence",
                     "status": "queued", "conclusion": None,
                     "html_url": "https://github.com/a/b/actions/runs/1",
                     "id": 1},
                    {"head_sha": "d"*40, "name": "irrelevant old head",
                     "status": "completed", "conclusion": "success",
                     "html_url": "https://github.com/a/b/actions/runs/2",
                     "id": 2},
                ]}
            raise AssertionError(path)
        with patch.object(portfolio, "get_json", side_effect=fake_json):
            with patch.object(portfolio, "resource", side_effect=fake_resource):
                with patch.object(portfolio, "evidence_file", return_value={
                    "path": "README.md", "at_commit": sha}):
                    result = portfolio.observe(t, self.locks[t["id"]], "weekly")
        self.assertEqual(result["evidence_state"], "source_ci_pending")
        self.assertFalse(result["observed_runs_all_succeeded"])
        self.assertFalse(result["complete_required_ci_gate_verified"])
        self.assertFalse(result["independent_mathematical_claim_verified"])
        self.assertIn("pending", result["next_research_obligation"])
        self.assertEqual(len(result["exact_head_workflow_runs"]), 1)

    def test_weekly_execution_records_undecidable_errors(self):
        selected = portfolio.select(self.tracks, "weekly", shard=0)
        with tempfile.TemporaryDirectory() as directory:
            with patch.object(portfolio, "observe", side_effect=RuntimeError("API unreachable")):
                result = portfolio.run("weekly", Path(directory), shard=0)
            self.assertEqual(result, 1)
            manifest = json.loads(
                (Path(directory)/"portfolio-index.json").read_text())
            self.assertEqual(len(manifest["unreadable_sources"]), 4)
            self.assertEqual(manifest["mathematical_theorems_promoted"], 0)
            self.assertEqual(manifest["selected_count"], len(selected))
            for row in manifest["rows"]:
                self.assertEqual(row["state"], "incomplete")
                saved = json.loads(
                    (Path(directory)/(row["id"]+".json")).read_text())
                self.assertFalse(saved["independent_mathematical_claim_verified"])

    def test_missing_new_repo_registration_rejected(self):
        # Simulates a new ESTATE/source-lock programme not in registry.
        import tomllib
        from unittest.mock import mock_open
        old = portfolio.LOCKS.read_text()
        new_source = [
            "[[source]]", 'id = "new-math"', 'kind = "program"',
            'repository = "larsbx/new-math"', 'visibility = "public"',
            'commit = "' + "a"*40 + '"', 'commits = 1', 'files = 1',
            'import = "history"', 'authority = "retained"'
        ]
        altered = old + chr(10) + chr(10).join(new_source) + chr(10)
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root/"policy").mkdir()
            (root/"policy/math-research-portfolio.toml").write_text(
                portfolio.REGISTRY.read_text())
            (root/"policy/source-locks.toml").write_text(altered)
            (root/"policy/math-experiments.toml").write_text(
                (ROOT/"policy/math-experiments.toml").read_text())
            with self.assertRaises(AssertionError):
                portfolio.registry(root)


if __name__ == "__main__":
    unittest.main()
