"""Offline conformance for the homelab AKN research registration/scheduler."""
from hashlib import sha256
import json
from pathlib import Path
import sys
import tempfile
import tomllib
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/"tools"))
import research_schedule as rs  # noqa: E402


def snapshots():
    base = {
        "number": 22, "state": "open", "draft": False, "merged": False,
        "base_branch": "main", "head_repo": "larsbx/tiling-theory-research",
        "head_branch": "research/akn-radius2-exact-feasibility",
        "head_sha": "b0c07fd04862895ef512ede4b2f668f3f328e407",
        "html_url": "https://github.com/larsbx/tiling-theory-research/pull/22",
        "updated_at": "2026-11-01T16:06:56Z"
    }
    next_pr = dict(base, number=23, draft=True,
                   base_branch=base["head_branch"],
                   head_branch="research/akn-chamber-conjugacy-certificate",
                   head_sha="b1b956bef47813e7f299b6f3dbcd7b6b0c9bf951")
    return {22: base, 23: next_pr}


class ResearchScheduleContract(unittest.TestCase):
    def test_registry_preserves_source_authority_and_lock(self):
        study = rs.load_study()
        self.assertEqual(study["program"], "tiling-theory")
        self.assertEqual(study["authority"], "source_retained")
        self.assertFalse(study["auto_merge"])
        self.assertFalse(study["auto_claim_promotion"])
        self.assertFalse(study["boundary_strata_exhaustive"])
        self.assertEqual(study["status_cron_utc"], "7 4 * * *")
        self.assertEqual(study["full_cron_utc"], "17 4 * * 1")
        self.assertEqual(study["source_research_pr"], 23)
        self.assertEqual(study["source_next_issue"], 24)

    def test_workflow_matches_schedule_contract(self):
        study = rs.load_study()
        workflow = (ROOT/".github/workflows/akn-math-research.yml").read_text()
        self.assertIn("cron: '" + study["status_cron_utc"] + "'", workflow)
        self.assertIn("cron: '" + study["full_cron_utc"] + "'", workflow)
        self.assertIn("  pull_request:", workflow)
        self.assertIn("tools/research_schedule.py", workflow)
        self.assertIn("if: always()", workflow)
        self.assertNotIn("contents: write", workflow)
        self.assertNotIn("pull-requests: write", workflow)

    def test_accepts_exact_source_head_only(self):
        study = rs.load_study()
        self.assertEqual(rs.select_source(study, snapshots()),
                         "b1b956bef47813e7f299b6f3dbcd7b6b0c9bf951")
        for mutation in ("head_repo", "head_sha", "base_branch", "state"):
            with self.subTest(mutation=mutation):
                prs = snapshots()
                prs[23][mutation] = {
                    "head_repo": "someone-else/tiling-theory-research",
                    "head_sha": "not-a-commit",
                    "base_branch": "main",
                    "state": "closed",
                }[mutation]
                with self.assertRaises(AssertionError):
                    rs.select_source(study, prs)

    def test_after_merge_research_switches_to_verified_source_main(self):
        study = rs.load_study()
        prs = snapshots()
        prs[22].update(state="closed", merged=True)
        prs[23].update(state="closed", merged=True, base_branch="main")
        self.assertIsNone(rs.select_source(study, prs))
        prs[23].update(state="open", merged=False)
        self.assertEqual(rs.select_source(study, prs), prs[23]["head_sha"])
        prs[22].update(merged=False)
        with self.assertRaises(AssertionError):
            rs.select_source(study, prs)

    def test_status_cycle_writes_machine_readable_evidence_without_network(self):
        payload = {"source_head_sha": snapshots()[23]["head_sha"],
                   "source_prs": {}, "source_issue": {"state": "open"},
                   "exact_head_action_runs": {}}
        with tempfile.TemporaryDirectory() as tmp:
            with patch.object(rs, "snapshot", return_value=payload):
                code = rs.run("status", Path(tmp))
            self.assertEqual(code, 0)
            saved = json.loads((Path(tmp)/"research-cycle.json").read_text())
            self.assertEqual(saved["status"], "status_recorded")
            self.assertFalse(saved["automatic_merge"])
            self.assertFalse(saved["automatic_theorem_promotion"])

    def test_full_cycle_requires_exact_verification(self):
        payload = {"source_head_sha": snapshots()[23]["head_sha"],
                   "source_fetch_ref": "refs/pull/23/head"}
        with tempfile.TemporaryDirectory() as tmp:
            checkout = Path(tmp)/"checkout"
            evidence = Path(tmp)/"evidence"
            with patch.object(rs, "snapshot", return_value=payload):
                with patch.object(rs, "execute_full", return_value={
                    "generic": "generic_candidate_verified",
                    "singular_strata_complete": False
                }):
                    result = rs.run("full", evidence, checkout)
            self.assertEqual(result, 0)
            saved = json.loads((evidence/"research-cycle.json").read_text())
            self.assertEqual(saved["status"], "finite_generic_candidate_verified")
            self.assertFalse(saved["verified_experiment"]["singular_strata_complete"])

    def test_complete_singular_handoff_requires_head_and_artifact_digests(self):
        sha = snapshots()[23]["head_sha"]
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root/"atlas_strata_driver.py").touch()
            evidence = root/"exact-singular"
            evidence.mkdir()
            replay = json.dumps({
                "all_singular_strata_covered": True, "strata_counts": [1, 2, 3],
                "orbits": {}, "boundary_convention_decided": False,
                "next_obligation": "review singular selections",
            }).encode()
            (evidence/"singular-strata.json").write_bytes(b"packet")
            (evidence/"singular-replay.json").write_bytes(replay)
            record = {
                "source_revision": sha, "state": "verified_finite_singular_atlas",
                "packet_sha256": sha256(b"packet").hexdigest(),
                "replay_sha256": sha256(replay).hexdigest(),
            }
            path = evidence/"singular-run.json"
            path.write_text(json.dumps(record))
            with patch.object(rs, "command") as command:
                def replay_singular(head):
                    return rs.execute_singular(rs.load_study(), head, root, root,
                                               root, root/"generic.json")

                self.assertTrue(replay_singular(sha)["singular_strata_complete"])
                self.assertIn(str(root/"atlas_strata_driver.py"), command.call_args.args[0])
                with self.assertRaisesRegex(RuntimeError, "exact-head"):
                    replay_singular("a"*40)
                (evidence/"singular-strata.json").write_bytes(b"tampered")
                with self.assertRaisesRegex(RuntimeError, "checksum mismatch"):
                    replay_singular(sha)

    def test_status_failure_retains_unaccepted_evidence(self):
        with tempfile.TemporaryDirectory() as tmp:
            with patch.object(rs, "snapshot", side_effect=RuntimeError("source offline")):
                code = rs.run("status", Path(tmp))
            self.assertEqual(code, 1)
            saved = json.loads((Path(tmp)/"research-cycle.json").read_text())
            self.assertEqual(saved["status"], "incomplete")
            self.assertIn("source offline", saved["error"])
            self.assertTrue((Path(tmp)/"traceback.txt").is_file())


if __name__ == "__main__":
    unittest.main()
