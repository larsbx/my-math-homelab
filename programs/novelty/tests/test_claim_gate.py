import json, pathlib, subprocess, sys, unittest
ROOT=pathlib.Path(__file__).parents[1]
GUARDS_CONTRACT = "research registries (candidates, hypotheses, obligations, theorems) validate and promote nothing to novelty"
class TestClaimGate(unittest.TestCase):
    def test_repository_ledgers_validate(self):
        p=subprocess.run([sys.executable,str(ROOT/"scripts/check_registry.py")],cwd=ROOT,text=True,capture_output=True)
        self.assertEqual(p.returncode,0,p.stdout+p.stderr); self.assertIn("9 theorems",p.stdout); self.assertIn("5 novelty candidates",p.stdout)
    def test_every_candidate_has_hypotheses_and_obligations(self):
        cs={x["id"] for x in json.loads((ROOT/"research/candidates.json").read_text())["candidates"]}
        hs={x["candidate"] for x in json.loads((ROOT/"research/hypotheses.json").read_text())["hypotheses"]}
        vs={x["candidate"] for x in json.loads((ROOT/"research/obligations.json").read_text())["obligations"]}
        self.assertEqual(cs,hs); self.assertEqual(cs,vs)
    def test_only_promoted_hypotheses_are_verified(self):
        hs=json.loads((ROOT/"research/hypotheses.json").read_text())["hypotheses"]
        verified={h["id"] for h in hs if h["status"]=="verified"}
        self.assertEqual(verified,{"N1-H09","N2-H06","N2-H07","N2-H08","N2-H09","N2-H10","N2-H11","N3-H06","N3-H07"})
        self.assertTrue(all(h["verified_by"] for h in hs if h["status"]=="verified"))
    def test_no_novelty_candidate_is_a_novelty_claim(self):
        ns=json.loads((ROOT/"research/novelty_candidates.json").read_text())["contributions"]
        self.assertTrue(all(n["status"]=="candidate contribution" for n in ns))
if __name__=="__main__": unittest.main()
