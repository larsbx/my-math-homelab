"""Allowlisted, credential-free local experiments for the governed weekly shards.

No source repository scripts are executed. All child inputs are pinned local
data snapshots. This is an evidence boundary, never mathematical claim authority.
"""
from __future__ import annotations

import argparse
from hashlib import sha256
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import tempfile
import tomllib

ROOT = Path(__file__).resolve().parents[1]
ADAPTER_ID = "arithmetic-bicycle-v1"
# Policy is not a command language. Adding a runner requires changing this code.
EXECUTORS = {ADAPTER_ID: "tools/experiments/arithmetic_bicycle.py"}
IMPLEMENTATIONS = ("tools/math_experiments.py", "tools/experiments/__init__.py",
                   "tools/experiments/arithmetic_bicycle.py", "tools/experiments/ab_enumeration.py",
                   "tools/experiments/ab_gram.py")
LIMITS = {"max_rows": 2, "max_columns": 4, "max_modulus": 26, "max_entry_abs": 100,
          "max_vectors_per_case": 200000, "max_vectors_total": 1000000,
          "max_input_bytes": 131072, "cpu_seconds": 10, "wall_seconds": 30,
          "memory_mb": 256, "output_bytes": 4194304}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def load_adapters(root=ROOT):
    policy = tomllib.loads((root / "policy/math-experiments.toml").read_text(encoding="utf-8"))
    require(policy["version"] == 1 and policy["contract"] == "homelab-independent-finite-experiment-v1",
            "unsupported experiment contract")
    require(policy["authority"] == "source_retained" and policy["automatic_claim_promotion"] is False,
            "experiments cannot acquire claim authority")
    adapters = policy["adapter"]
    require(len(adapters) == 1 and adapters[0]["id"] == ADAPTER_ID, "unreviewed executor registration")
    for spec in adapters:
        require(spec["program"] == "arithmetic-bicycle" and spec["source_repository"] ==
                "larsbx/arithmetic-bicycle-conjecture-research", "wrong programme authority")
        require(re.fullmatch(r"[0-9a-f]{40}", spec["source_revision"]) is not None, "immutable SHA required")
        require(spec["manifest"] == "policy/fixtures/arithmetic-bicycle/manifest.json", "unexpected fixture path")
        require(re.fullmatch(r"[0-9a-f]{64}", spec["manifest_sha256"]) is not None, "input hash missing")
        require(spec["execution"] == "weekly_shard_only", "duplicate scheduling refused")
        require(all(type(spec[k]) is int and 0 < spec[k] <= cap for k, cap in LIMITS.items()),
                "resource cap exceeds reviewed executor ceiling")
    return adapters


def implementation_hashes(root=ROOT):
    return {p: sha256((root/p).read_bytes()).hexdigest() for p in IMPLEMENTATIONS}


def revision(root=ROOT):
    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args], text=True).strip()
    return {"homelab_revision": git("rev-parse", "HEAD"),
            "homelab_working_tree_clean": not bool(git("status", "--porcelain"))}


def execute(spec, out, observed_source_head=None):
    """One bounded child per registered programme; retain all non-success states."""
    out = out.resolve()
    for name in ("programs", "shared"):
        boundary = (ROOT/name).resolve()
        require(out != boundary and boundary not in out.parents, "cannot write inside imported source trees")
    require(spec == next(a for a in load_adapters() if a["id"] == spec["id"]),
            "execution spec must match reviewed registry")
    if observed_source_head is not None:
        require(re.fullmatch(r"[0-9a-f]{40}", observed_source_head) is not None, "invalid observed head")
    out.mkdir(parents=True, exist_ok=True)
    record = {"schema": "HOMELAB-MATH-EXPERIMENT-1", "adapter": spec["id"],
              "source_repository": spec["source_repository"], "source_revision": spec["source_revision"],
              "input_sha256": spec["manifest_sha256"], "implementation_sha256": implementation_hashes(),
              "registry_sha256": sha256((ROOT/"policy/math-experiments.toml").read_bytes()).hexdigest(),
              **revision(), "observed_current_source_head": observed_source_head,
              "observed_head_matches_fixture_revision": observed_source_head == spec["source_revision"],
              "execution_scope": "pinned_fixtures_only", "state": "inconclusive", "scope_complete": False,
              "source_authority": "retained", "automatic_claim_promotion": False,
              "mathematical_theorems_promoted": 0, "independent_mathematical_claim_verified": False,
              "resource_limits": {k: spec[k] for k in LIMITS},
              "next_mathematical_obligation": "Investigate incomplete replay; no acceptance."}
    # Temporary output files enforce RLIMIT_FSIZE instead of an unbounded pipe.
    # Source subprocesses do not exist; even the local child gets NO inherited credentials.
    with tempfile.TemporaryDirectory(prefix="homelab-experiment-") as temp:
        stdout, stderr = Path(temp)/"stdout", Path(temp)/"stderr"
        with stdout.open("wb") as so, stderr.open("wb") as se:
            try:
                child = subprocess.Popen([sys.executable, "-I", "-B", str(ROOT/EXECUTORS[spec["id"]])],
                                         cwd=temp, env={"LANG": "C.UTF-8", "PYTHONHASHSEED": "0"},
                                         stdin=subprocess.DEVNULL, stdout=so, stderr=se, start_new_session=True)
                try:
                    code = child.wait(timeout=spec["wall_seconds"])
                except subprocess.TimeoutExpired:
                    os.killpg(child.pid, signal.SIGKILL)
                    child.wait()
                    code = None
            except OSError as exc:
                code = None
                record["startup_error"] = f"{type(exc).__name__}: {exc}"
        raw = stdout.read_bytes()
        diagnostics = stderr.read_bytes()
        (out/"worker.stdout.json").write_bytes(raw)
        (out/"worker.stderr.txt").write_bytes(diagnostics)
        record["worker_exit_code"] = code
        record["worker_stdout_sha256"] = sha256(raw).hexdigest()
        record["worker_stderr_sha256"] = sha256(diagnostics).hexdigest()
        try:
            if code is None or code < 0:
                record["error"] = "wall/resource limit or signal interrupted complete replay"
            else:
                require(len(raw) <= spec["output_bytes"], "oversized worker evidence")
                result = json.loads(raw)
                for key in ("schema", "adapter", "source_repository", "source_revision", "input_sha256",
                            "implementation_sha256", "automatic_claim_promotion", "mathematical_theorems_promoted",
                            "independent_mathematical_claim_verified", "source_authority"):
                    require(type(result[key]) is type(record[key]) and result[key] == record[key],
                            "worker evidence binding mismatch: " + key)
                require(result["state"] in ("verified_finite", "failure", "inconclusive"), "unknown verdict")
                require(code == {"verified_finite": 0, "failure": 1, "inconclusive": 2}[result["state"]],
                        "exit status disagrees with verdict")
                require(result["scope_complete"] is (result["state"] == "verified_finite"), "partial success refused")
                allowed_overlap = {"schema", "adapter", "source_repository", "source_revision", "input_sha256",
                                   "implementation_sha256", "automatic_claim_promotion", "mathematical_theorems_promoted",
                                   "independent_mathematical_claim_verified", "source_authority", "state", "scope_complete",
                                   "next_mathematical_obligation"}
                require(not (set(result) & (set(record) - allowed_overlap)), "worker overwrote coordinator provenance")
                record.update(result)
        except Exception as exc:
            record.update(state="failure", scope_complete=False, error=f"{type(exc).__name__}: {exc}")
    (out/"experiment.json").write_text(json.dumps(record, indent=2, sort_keys=True)+"\n", encoding="utf-8")
    return record


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--adapter", choices=tuple(EXECUTORS), default=ADAPTER_ID)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    spec = next(a for a in load_adapters() if a["id"] == args.adapter)
    result = execute(spec, args.out)
    print(json.dumps({"adapter": spec["id"], "state": result["state"],
                      "source_revision": result["source_revision"]}, sort_keys=True))
    raise SystemExit(0 if result["state"] == "verified_finite" else 2 if result["state"] == "inconclusive" else 1)


if __name__ == "__main__":
    main()
