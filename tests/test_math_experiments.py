"""Independent replay acceptance and adversarial controls, offline and bounded."""
from copy import deepcopy
from hashlib import sha1, sha256
from itertools import product
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/"tools"))
import math_experiments as executor
import math_research_portfolio as portfolio
from experiments import ab_gram as gram
from experiments.ab_enumeration import enumerate_bicycles
from experiments import arithmetic_bicycle as ab


class IndependentExperiment(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.spec, = executor.load_adapters()
        cls.baseline = ab.evaluate(cls.spec, ROOT)

    def test_pinned_scope_and_counterexample(self):
        r = self.baseline
        self.assertEqual((r["matrix_count"], r["modulus_case_count"], r["enumerated_vector_states"]),
                         (12, 36, 27990))
        by_id = {c["id"]: c for c in r["cases"]}
        self.assertEqual(by_id["index5-a1"]["arithmetic_signature"], [[0,1],[1,1],[1,1],[2,5]])
        for id_, orders in (("index5-a1", [1,1,5]), ("index5-a2", [5,5,5])):
            self.assertEqual([m["enumerated_order"] for m in by_id[id_]["moduli"]], orders)
            self.assertFalse(by_id[id_]["corrected_surjective_domain"])
        for id_ in ("rank-one-no-unit-basis", "rank-two-no-unit-basis"):
            for side in ("source", "target"):
                c = by_id[id_+"/"+side]
                self.assertTrue(c["corrected_surjective_domain"])
                self.assertFalse(c["has_unit_maximal_minor"])
        self.assertEqual([r["source_claim_statuses"][c] for c in ab.RETRACTED], ["retracted"]*3)
        self.assertTrue(all(not p["general_theorem_verified_by_adapter"] for p in r["surjective_pair_checks"]))

    def test_independent_methods_on_complete_tiny_boxes(self):
        # Covers negative entries, zero/rank-deficient/redundant rows and composite rings.
        for rank, width in ((0,2),(1,2),(2,2)):
            for values in product((-1,0,1), repeat=rank*width):
                rows = [list(values[i*width:(i+1)*width]) for i in range(rank)]
                for n in (2,3,4,6):
                    witnesses = [list(x) for x in enumerate_bicycles(rows,width,n)]
                    check = gram.gram_quotient(rows,width,n)
                    self.assertEqual(len(witnesses), check["bicycle_order"], (rows,n))
                    self.assertTrue(gram.verify_witnesses(rows,width,n,witnesses,check["bicycle_order"]))

    def test_dropping_kernel_quotient_is_detected(self):
        rows = [[1,2],[0,5]]
        check = gram.gram_quotient(rows,2,5)
        self.assertEqual((check["gram_kernel_order"],check["transpose_kernel_order"],check["bicycle_order"]),
                         (25,5,5))
        with self.assertRaisesRegex(ValueError, "Smith quotient"):
            gram.verify_witnesses(rows,2,5,[[0,0],[1,2],[2,4],[3,1],[4,3]],25)
        scalar = gram.gram_quotient([[2]],1,4)
        self.assertEqual((scalar["gram_kernel_order"],scalar["transpose_kernel_order"]), (4,2))

    def test_malicious_witness_mutations(self):
        rows, n = [[1,2],[0,5]], 5
        witnesses = [list(x) for x in enumerate_bicycles(rows,2,n)]
        for name, bad in (("omission",witnesses[:-1]), ("duplication", witnesses[:-1]+[witnesses[0]]),
                          ("noncycle", witnesses[:-1]+[[1,1]]),
                          ("out-of-range", witnesses[:-1]+[[5,0]]),
                          ("boolean", witnesses[:-1]+[[True,2]])):
            with self.subTest(name=name), self.assertRaises(ValueError):
                gram.verify_witnesses(rows,2,n,bad,5)
        # Scalar 2 modulo 2: 1 is a cycle but is NOT a cut.
        with self.assertRaisesRegex(ValueError,"cut lattice"):
            gram.verify_witnesses([[2]],1,2,[[1]],1)
        with self.assertRaises(ValueError):
            gram.verify_witnesses(rows,2,10,witnesses,5)

    def copied_input(self, temp):
        root = Path(temp)
        shutil.copytree(ROOT/"policy/fixtures", root/"policy/fixtures")
        return root

    def rehash_snapshot(self, root, spec, path):
        manifest_path = root/spec["manifest"]
        manifest = json.loads(manifest_path.read_text())
        raw = (manifest_path.parent/"source"/path).read_bytes()
        row = next(s for s in manifest["snapshots"] if s["path"] == path)
        row.update(sha256=sha256(raw).hexdigest(),
                   git_blob_sha1=sha1(b"blob "+str(len(raw)).encode()+b"\0"+raw).hexdigest())
        manifest_path.write_text(ab.canonical(manifest))
        spec["manifest_sha256"] = sha256(manifest_path.read_bytes()).hexdigest()

    def test_source_hash_manifest_and_revision_mutations(self):
        for name in ("snapshot", "manifest", "revision", "traversal"):
            with self.subTest(name=name), tempfile.TemporaryDirectory() as temp:
                root = self.copied_input(temp)
                spec = deepcopy(self.spec)
                path = root/spec["manifest"]
                if name == "snapshot":
                    (path.parent/"source/proof/claims.toml").write_text("malicious source mutation")
                elif name == "manifest":
                    path.write_bytes(path.read_bytes()+b" ")
                elif name == "revision":
                    spec["source_revision"] = "a"*40
                else:
                    m = json.loads(path.read_text());m["snapshots"][0]["path"] = "../../outside"
                    path.write_text(ab.canonical(m));spec["manifest_sha256"] = sha256(path.read_bytes()).hexdigest()
                with self.assertRaises(ValueError):
                    ab.evaluate(spec,root)

    def test_rehashed_retracted_claim_cannot_be_resurrected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = self.copied_input(temp);spec = deepcopy(self.spec)
            p = root/Path(spec["manifest"]).parent/"source/proof/claims.toml"
            p.write_text(p.read_text().replace('status = "retracted"','status = "proved"',1))
            self.rehash_snapshot(root,spec,"proof/claims.toml")
            with self.assertRaisesRegex(ValueError,"retracted claim"):
                ab.evaluate(spec,root)

    def test_rehashed_wrong_expected_order_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root=self.copied_input(temp);spec=deepcopy(self.spec)
            p=root/Path(spec["manifest"]).parent/"source/conformance/fixtures/realization-dependence-v1.json"
            data=json.loads(p.read_text());data["cases"][0]["expected_orders"]["5"]=5
            p.write_text(ab.canonical(data));self.rehash_snapshot(root,spec,"conformance/fixtures/realization-dependence-v1.json")
            with self.assertRaisesRegex(ValueError,"expected order"):
                ab.evaluate(spec,root)

    def test_budget_exhaustion_is_inconclusive_before_enumeration(self):
        for limit in executor.LIMITS:
            if limit in ("cpu_seconds","wall_seconds","memory_mb","output_bytes"):
                continue
            spec=deepcopy(self.spec);spec[limit]=1
            with self.subTest(limit=limit), patch.object(ab,"enumerate_bicycles") as enumerator:
                with self.assertRaises(ab.Inconclusive):
                    ab.evaluate(spec,ROOT)
                enumerator.assert_not_called()

    def test_malformed_noninteger_inputs_rejected(self):
        for value in (True, 1.5, "1"):
            with self.assertRaisesRegex(ValueError,"exact integers"):
                ab.preflight([{"matrix":[[value]],"columns":1,"moduli":[5]}], self.spec)

    def test_registry_refuses_unreviewed_executor_or_unbounded_caps(self):
        original=(ROOT/"policy/math-experiments.toml").read_text()
        for bad in (original.replace('id = "arithmetic-bicycle-v1"','id = "shell-source"'),
                    original.replace('memory_mb = 256','memory_mb = 999999'),
                    original.replace('automatic_claim_promotion = false','automatic_claim_promotion = true')):
            with tempfile.TemporaryDirectory() as temp:
                root=Path(temp);(root/"policy").mkdir();(root/"policy/math-experiments.toml").write_text(bad)
                with self.assertRaises(ValueError):executor.load_adapters(root)

    def test_isolated_real_worker_is_deterministic_and_failure_free(self):
        with tempfile.TemporaryDirectory() as temp:
            first=executor.execute(self.spec,Path(temp)/"first")
            second=executor.execute(self.spec,Path(temp)/"second")
            self.assertEqual(first,second)
            self.assertEqual(first["state"],"verified_finite")
            self.assertFalse(first["automatic_claim_promotion"])
            self.assertFalse(first["independent_mathematical_claim_verified"])
            self.assertEqual(first["mathematical_theorems_promoted"],0)
            self.assertEqual(first["implementation_sha256"],executor.implementation_hashes())
            receipt=json.loads((ROOT/"docs/research/evidence/arithmetic-bicycle-v1.json").read_text())
            self.assertEqual(json.loads((Path(temp)/"first/worker.stdout.json").read_text()),receipt)

    def test_worker_startup_timeout_and_malformed_output_preserve_non_success(self):
        for reason in ("startup","timeout","malformed","signal"):
            with self.subTest(reason=reason), tempfile.TemporaryDirectory() as temp:
                child=Mock(pid=999999)
                child.wait.side_effect = [subprocess.TimeoutExpired("worker",30),0] if reason=="timeout" else None
                child.wait.return_value = -9 if reason=="signal" else 0
                factory = patch.object(executor.subprocess,"Popen",side_effect=OSError("missing worker")) if reason=="startup" else patch.object(executor.subprocess,"Popen",return_value=child)
                with factory as popen, patch.object(executor.os,"killpg"), patch.object(executor,"revision",return_value={"homelab_revision":"a"*40,"homelab_working_tree_clean":True}):
                    r=executor.execute(self.spec,Path(temp))
                self.assertEqual(r["state"],"failure" if reason=="malformed" else "inconclusive")
                self.assertFalse(r["scope_complete"])
                self.assertTrue((Path(temp)/"experiment.json").is_file())
                if reason!="startup":
                    kwargs=popen.call_args.kwargs
                    self.assertEqual(set(kwargs["env"]),{"LANG","PYTHONHASHSEED"})
                    self.assertIn("-I",popen.call_args.args[0])


    def test_forged_worker_provenance_and_promotion_are_rejected(self):
        base = {"schema":"HOMELAB-MATH-EXPERIMENT-1", "adapter": self.spec["id"],
                "source_repository":self.spec["source_repository"], "source_revision":self.spec["source_revision"],
                "input_sha256":self.spec["manifest_sha256"], "implementation_sha256":executor.implementation_hashes(),
                "automatic_claim_promotion":False, "mathematical_theorems_promoted":0,
                "independent_mathematical_claim_verified":False, "source_authority":"retained",
                **deepcopy(self.baseline)}
        for mutation in ({"source_revision":"d"*40}, {"automatic_claim_promotion":True},
                         {"mathematical_theorems_promoted":1}, {"scope_complete":False},
                         {"homelab_revision":"f"*40}, {"state":"theorem_proved"}):
            fake={**base,**mutation}
            def launch(*args,**kwargs):
                kwargs["stdout"].write(ab.canonical(fake).encode())
                child=Mock();child.wait.return_value=0
                return child
            with tempfile.TemporaryDirectory() as temp, patch.object(executor.subprocess,"Popen",side_effect=launch), patch.object(executor,"revision",return_value={"homelab_revision":"a"*40,"homelab_working_tree_clean":True}):
                result=executor.execute(self.spec,Path(temp))
                self.assertEqual(result["state"],"failure",mutation)
                self.assertFalse(result["scope_complete"])
                self.assertFalse(result["automatic_claim_promotion"])

    def test_cannot_write_imported_trees(self):
        for prefix in ("programs/arithmetic-bicycle","shared/finite-math-kernels"):
            with self.assertRaisesRegex(ValueError,"imported source trees"):
                executor.execute(self.spec,ROOT/prefix/"evidence")

    def test_daily_never_executes_and_weekly_shards_execute_once(self):
        tracks,_,_=portfolio.registry()
        def observed(t,lock,mode):
            return {"head_sha":"b"*40,"evidence_state":"source_ci_pending",
                    "research_stage":"pinned_independent_finite_adapter_registered",
                    "next_research_obligation":"review pending CI"}
        def experiment(*args,**kwargs):
            return {"state":"verified_finite","source_revision":self.spec["source_revision"],
                    "next_mathematical_obligation":"ABC-RD-01"}
        with tempfile.TemporaryDirectory() as temp, patch.object(portfolio,"observe",side_effect=observed), patch.object(executor,"execute",side_effect=experiment) as run:
            portfolio.run("daily",Path(temp)/"daily")
            run.assert_not_called()
            for shard in range(4):
                self.assertEqual(portfolio.run("weekly",Path(temp)/str(shard),shard=shard),0)
            self.assertEqual(run.call_count,1)
            self.assertEqual(run.call_args.kwargs["observed_source_head"],"b"*40)
            record=json.loads((Path(temp)/"0/arithmetic-bicycle.json").read_text())
            self.assertEqual(record["evidence_state"],"source_ci_pending")
            self.assertEqual(record["experiment_source_revision"],self.spec["source_revision"])

    def test_weekly_experiment_failure_is_nonzero_and_retained(self):
        for state in ("inconclusive","failure"):
            with tempfile.TemporaryDirectory() as temp, patch.object(portfolio,"observe",return_value={
                "head_sha":"c"*40,"evidence_state":"source_evidence_recorded","research_stage":"registered",
                "next_research_obligation":"source obligation"}), patch.object(executor,"execute",return_value={
                    "state":state,"source_revision":self.spec["source_revision"],"next_mathematical_obligation":"diagnose"}):
                code=portfolio.run("weekly",Path(temp),select_ids=["arithmetic-bicycle"])
                self.assertEqual(code,1)
                record=json.loads((Path(temp)/"arithmetic-bicycle.json").read_text())
                self.assertEqual(record["experiment_execution"],state)
                self.assertFalse(record["finite_experiment_verified"])


if __name__ == "__main__":
    unittest.main()
