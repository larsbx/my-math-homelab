"""Estate-wide, fail-closed research registry and exact-revision evidence cycles.

Daily: source head, claim/evidence-file provenance, PRs, issues and CI status.
Weekly: the same per-program facts plus reproducible *research obligations*.
The source repos alone own mathematical claim status. This tool DOES NOT run
unreviewed source code, claim that CI proves a theorem, or edit imported trees.
Tiling-theory retains its specialist. Reviewed local finite adapters execute
once in their weekly shard; all other adapter gaps remain explicit.

Usage:
  python tools/math_research_portfolio.py --mode daily --out /tmp/math-daily
  python tools/math_research_portfolio.py --mode weekly --shard 0 --out /tmp/math-0
  python tools/math_research_portfolio.py --mode validate
"""
from __future__ import annotations

import argparse
import base64
from datetime import datetime, timezone
from hashlib import sha1, sha256
import json
import os
from pathlib import Path
import re
import sys
import tomllib
import traceback
from urllib.parse import quote
from urllib.request import Request, urlopen

import math_experiments

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "policy/math-research-portfolio.toml"
LOCKS = ROOT / "policy/source-locks.toml"
HEX40 = re.compile(r"^[0-9a-f]{40}$")
REPO = re.compile(r"^larsbx/[A-Za-z0-9_.-]+$")
TRACK_ID = re.compile(r"^[a-z][a-z0-9-]+$")
SHARD_COUNT = 4


def registry(root=ROOT):
    """Prove one-to-one coverage of ALL active source locks; refuse drift."""
    policy = tomllib.loads((root/"policy/math-research-portfolio.toml").read_text())
    locks = tomllib.loads((root/"policy/source-locks.toml").read_text())
    assert policy["version"] == 1 and policy["contract"] == "math-estate-research-v1"
    assert policy["authority"] == "source_retained"
    assert policy["automatic_claim_promotion"] is False
    assert policy["automatic_merge"] is False
    assert policy["daily_cron_utc"] == "43 4 * * *"
    assert policy["weekly_cron_utc"] == "47 5 * * 2"
    active = {x["id"]: x for x in locks["source"]
              if x["kind"] in ("program", "shared")
              and x["import"] == "history"}
    assert len(active) > 0
    tracks = policy["track"]
    assert len({t["id"] for t in tracks}) == len(tracks)
    assert {t["id"] for t in tracks} == set(active), (
        "Every active source lock must be registered exactly once; no phantom sources"
    )
    adapters = {a["program"]: a for a in math_experiments.load_adapters(root)}
    assert set(adapters) <= set(active), "experiment has no active source"
    for track in tracks:
        id_ = track["id"]
        lock = active[id_]
        assert TRACK_ID.fullmatch(id_) and REPO.fullmatch(track["source_repository"])
        assert lock["repository"] == track["source_repository"]
        assert lock["kind"] == track["kind"]
        assert lock["authority"] == "retained"
        assert HEX40.fullmatch(lock["commit"])
        assert track["claim_authority"] == "source_retained"
        assert track["automatic_merge"] is False
        assert track["automatic_claim_promotion"] is False
        assert track["objective"].strip() and track["next_research_obligation"].strip()
        assert track["claim_namespace"].strip()
        path = track["research_evidence_path"]
        assert path and not path.startswith("/")
        assert all(segment not in (".", "..", "") for segment in path.split("/"))
        assert track["mode"] in ("specialized_akn", "source_evidence", "independent_finite", "exact_fixture_adapter")
        if id_ == "tiling-theory":
            assert track["mode"] == "specialized_akn"
            assert track["independent_experiment"] == "scheduled_by_akn_specialist"
        elif id_ in adapters:
            adapter = adapters[id_]
            assert adapter["source_repository"] == track["source_repository"]
            assert track["mode"] == "independent_finite"
            assert track["independent_experiment"] == adapter["id"]
        elif id_ == "vizing-domination":
            assert track["mode"] == "exact_fixture_adapter"
            assert track["independent_experiment"] == "homelab_vizing_historical_casebase_v1"
        else:
            assert track["mode"] == "source_evidence"
            assert track["independent_experiment"] == "requires_separate_verified_adapter"
    return sorted(tracks, key=lambda t: t["id"]), active, policy


def get_json(url):
    headers = {"User-Agent": "my-math-homelab-portfolio",
               "Accept": "application/vnd.github+json",
               "X-GitHub-Api-Version": "2022-11-28"}
    token = os.environ.get("GH_TOKEN")
    if token:
        headers["Authorization"] = "Bearer " + token
    with urlopen(Request(url, headers=headers), timeout=30) as response:
        return json.load(response)


def resource(repo, endpoint):
    return get_json("https://api.github.com/repos/" + repo + "/" + endpoint)


def git_blob_sha1(raw):
    """Independently recompute the exact Git blob hash from API file bytes."""
    return sha1(b"blob " + str(len(raw)).encode("ascii") + bytes([0]) + raw).hexdigest()


def evidence_file(repo, rev, path):
    # Do not fetch a path from a mutable default branch: all proofs are SHA-bound.
    assert HEX40.fullmatch(rev)
    info = resource(repo, "contents/" + "/".join(quote(s, safe="") for s in path.split("/"))
                    + "?ref=" + rev)
    assert info["type"] == "file" and info["encoding"] == "base64"
    raw = base64.b64decode(info["content"], validate=False)
    assert git_blob_sha1(raw) == info["sha"], (
        "independent exact source blob digest disagrees with GitHub"
    )
    return {"path": path, "git_blob_sha1": info["sha"],
            "sha256": sha256(raw).hexdigest(),
            "bytes": len(raw), "at_commit": rev}


def verified_source_json(repo, rev, path):
    """Fetch source JSON only from an immutable commit; replay Git blob hash."""
    assert HEX40.fullmatch(rev)
    uri = "contents/" + "/".join(quote(s, safe="") for s in path.split("/"))
    info = resource(repo, uri + "?ref=" + rev)
    assert info["type"] == "file" and info["encoding"] == "base64"
    raw = base64.b64decode(info["content"], validate=False)
    assert git_blob_sha1(raw) == info["sha"], "source fixture Git blob mismatch"
    return json.loads(raw), sha256(raw).hexdigest()


def verified_source_text(repo, rev, path):
    """Read immutable text fixture and replay Git blob checksum."""
    assert HEX40.fullmatch(rev)
    uri = "contents/" + "/".join(quote(s, safe="") for s in path.split("/"))
    info = resource(repo, uri + "?ref=" + rev)
    assert info["type"] == "file" and info["encoding"] == "base64"
    raw = base64.b64decode(info["content"], validate=False)
    assert git_blob_sha1(raw) == info["sha"], "text source Git blob mismatch"
    return raw.decode("utf-8"), sha256(raw).hexdigest()


def _compact_runs(runs, commit):
    result = []
    for x in runs:
        if x["head_sha"] != commit:
            continue
        result.append({"name": x["name"],
                       "status": x["status"], "conclusion": x["conclusion"],
                       "url": x["html_url"], "run_id": x["id"]})
    return result


def _next_action(track, runs, prs):
    if any(r["conclusion"] in ("failure", "timed_out", "action_required")
           for r in runs):
        return "Reproduce and diagnose failed exact-head source CI before changing mathematical claims."
    if any(r["status"] != "completed" for r in runs):
        return "Inspect pending source CI; queued/in-progress is not mathematical verification."
    if any(r["conclusion"] != "success" for r in runs):
        return "Investigate cancelled, skipped or inconclusive exact-head checks; do not assume acceptance."
    if prs:
        return "Review open PR hypotheses and exact-head evidence, then " + track["next_research_obligation"]
    return track["next_research_obligation"]


def observe(track, lock, mode):
    """Evidence-bound source audit; no imported-tree writes or unverified code."""
    repo = track["source_repository"]
    metadata = get_json("https://api.github.com/repos/" + repo)
    assert metadata["full_name"].lower() == repo.lower()
    branch = metadata["default_branch"]
    assert re.fullmatch(r"[A-Za-z0-9._/-]+", branch) and ".." not in branch
    ref = resource(repo, "git/ref/heads/" + quote(branch, safe="/"))
    head = ref["object"]["sha"]
    assert HEX40.fullmatch(head)
    paths = list(dict.fromkeys(["README.md", "ESTATE.toml",
                                track["research_evidence_path"]]))
    files = [evidence_file(repo, head, p) for p in paths]
    pulls = resource(repo, "pulls?state=open&per_page=30&sort=updated&direction=desc")
    prs = [{"number": p["number"], "title": p["title"][:240],
            "head_sha": p["head"]["sha"], "base": p["base"]["ref"],
            "draft": p["draft"], "url": p["html_url"]}
           for p in pulls]
    issues = resource(repo, "issues?state=open&per_page=30&sort=updated&direction=desc")
    open_issues = [{"number": i["number"], "title": i["title"][:240],
                    "url": i["html_url"]}
                   for i in issues if "pull_request" not in i]
    actions_status = "available"
    try:
        actions = resource(repo, "actions/runs?per_page=50&head_sha=" + head)
        runs = _compact_runs(actions["workflow_runs"], head)
    except Exception as exc:
        runs = []
        actions_status = "unavailable: " + str(exc)[:180]
    state = "source_evidence_recorded"
    if not runs or actions_status != "available":
        state = "exact_head_ci_unverified"
    elif any(r["conclusion"] in ("failure", "timed_out", "action_required")
             for r in runs):
        state = "source_ci_regression_observed"
    elif any(r["status"] != "completed" for r in runs):
        state = "source_ci_pending"
    elif any(r["conclusion"] != "success" for r in runs):
        state = "exact_head_ci_unverified"
    research_stage = ("specialized_exact_experiment_scheduled_elsewhere"
                      if track["mode"] == "specialized_akn"
                      else "pinned_independent_finite_adapter_registered"
                      if track["mode"] == "independent_finite"
                      else "independent_finite_fixture_adapter_registered"
                      if track["mode"] == "exact_fixture_adapter"
                      else "independent_experiment_adapter_not_yet_registered")
    return {
        "schema": "HOMELAB-MATH-PROGRAM-EVIDENCE-1",
        "id": track["id"], "kind": track["kind"],
        "claim_namespace": track["claim_namespace"],
        "source_repository": repo, "default_branch": branch,
        "head_sha": head,
        "locked_import_sha": lock["commit"],
        "source_has_advanced_since_import": head != lock["commit"],
        "source_authority": "retained",
        "objective": track["objective"],
        "mode": mode, "research_stage": research_stage,
        "evidence_state": state,
        "source_evidence": files,
        "source_prs_open": prs,
        "source_prs_truncated": len(prs) == 30,
        "source_issues_open": open_issues,
        "source_issues_truncated": len(issues) == 30,
        "exact_head_actions_status": actions_status,
        "exact_head_workflow_runs": runs,
        "observed_action_run_limit": 50,
        # The first page is not an exhaustive required-checks audit.
        "observed_runs_all_succeeded": bool(runs) and all(
            r["status"] == "completed" and r["conclusion"] == "success" for r in runs),
        "complete_required_ci_gate_verified": False,
        "independent_mathematical_claim_verified": False,
        "next_research_obligation": _next_action(track, runs, prs),
        "reproducible_research_adapter": track["independent_experiment"],
        "new_research_question_proposed": False,
        "automatic_claim_promotion": False,
        "automatic_merge": False,
    }


def select(tracks, mode, shard=None, select_ids=None):
    assert mode in ("daily", "weekly")
    if shard is not None:
        assert mode == "weekly" and 0 <= shard < SHARD_COUNT
        tracks = [t for i, t in enumerate(tracks) if i % SHARD_COUNT == shard]
    if select_ids:
        valid = {t["id"] for t in tracks}
        assert set(select_ids) <= valid, "unknown source or wrong shard"
        tracks = [t for t in tracks if t["id"] in select_ids]
    return tracks


def run(mode, out, shard=None, select_ids=None):
    tracks, locks, _ = registry()
    selected = select(tracks, mode, shard, select_ids)
    assert selected
    out = math_experiments.safe_output(out)
    out.mkdir(parents=True, exist_ok=True)
    rows, failed = [], []
    for t in selected:
        try:
            record = observe(t, locks[t["id"]], mode)
            if t["mode"] == "independent_finite":
                record["experiment_execution"] = "weekly_only_not_run_in_daily"
                if mode == "weekly":
                    spec = next(a for a in math_experiments.load_adapters()
                                if a["id"] == t["independent_experiment"])
                    experiment = math_experiments.execute(
                        spec, out/t["id"], observed_source_head=record["head_sha"])
                    record["experiment_execution"] = experiment["state"]
                    record["experiment_evidence"] = t["id"] + "/experiment.json"
                    record["experiment_source_revision"] = experiment["source_revision"]
                    record["finite_experiment_verified"] = experiment["state"] == "verified_finite"
                    if experiment["state"] != "verified_finite":
                        failed.append(t["id"])
                    # Keep exact-head CI and mathematical replay as separate dimensions.
                    record["next_finite_experiment_obligation"] = experiment["next_mathematical_obligation"]
            elif mode == "weekly" and t["id"] == "vizing-domination":
                from math_adapters.vizing_domination import verify_casebase
                graph6, graph6_sha = verified_source_text(
                    t["source_repository"], record["head_sha"],
                    "conformance/fixtures/casebase_graph6.txt")
                classes, classes_sha = verified_source_json(
                    t["source_repository"], record["head_sha"],
                    "conformance/fixtures/casebase_classes.json")
                verified = verify_casebase(
                    graph6, classes, source_commit=record["head_sha"],
                    sources_sha256={"graph6": graph6_sha, "classes": classes_sha})
                (out/"vizing-domination-exact-adapter.json").write_text(
                    json.dumps(verified, sort_keys=True, indent=2)+chr(10),
                    encoding="utf-8")
                record["independent_exact_finite_adapter"] = {
                    "schema": verified["schema"],
                    "result": verified["verdict"],
                    "historical_entries": verified["n_graphs"],
                    "classes": verified["iso_classes"],
                    "source_sha256": verified["source_sha256"],
                    "proof_scope": verified["scope"],
                }
                record["research_stage"] = "independent_finite_fixture_replayed"
                record["independent_finite_fixture_verified"] = True
                record["independent_mathematical_claim_verified"] = False
                record["next_research_obligation"] = verified[
                    "next_research_obligation"]
        except Exception as exc:
            failed.append(t["id"])
            record = {
                "schema": "HOMELAB-MATH-PROGRAM-EVIDENCE-1",
                "id": t["id"], "source_repository": t["source_repository"],
                "evidence_state": "incomplete",
                "research_stage": "unverified",
                "independent_mathematical_claim_verified": False,
                "automatic_claim_promotion": False,
                "automatic_merge": False,
                "error": f"{type(exc).__name__}: {exc}",
                "next_research_obligation":
                    "Investigate unavailable source provenance; do not assume research acceptance.",
            }
            (out/(t["id"] + ".traceback.txt")).write_text(
                traceback.format_exc(), encoding="utf-8")
        (out/(t["id"] + ".json")).write_text(
            json.dumps(record, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        rows.append({"id": t["id"], "source_repository": t["source_repository"],
                     "state": record["evidence_state"],
                     "research_stage": record["research_stage"],
                     "experiment_state": record.get("experiment_execution"),
                     "experiment_source_revision": record.get("experiment_source_revision"),
                     "exact_sha": record.get("head_sha"),
                     "next_obligation": record["next_research_obligation"]})
    summary = {
        "schema": "HOMELAB-MATH-PORTFOLIO-CYCLE-1",
        "mode": mode, "shard": shard,
        "observed_at_utc": datetime.now(timezone.utc).isoformat(),
        "selected_count": len(rows),
        "registered_count": len(tracks),
        "sources_with_errors": sorted(set(failed)),
        "unreadable_sources": [r["id"] for r in rows if r["state"] == "incomplete"],
        "source_authority_retained": True,
        "imported_trees_modified": False,
        "mathematical_theorems_promoted": 0,
        "rows": rows,
    }
    (out/"portfolio-index.json").write_text(
        json.dumps(summary, sort_keys=True, indent=2)+"\n", encoding="utf-8")
    return 1 if failed else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=("validate", "daily", "weekly"), required=True)
    parser.add_argument("--out", type=Path)
    parser.add_argument("--shard", type=int)
    parser.add_argument("--select", action="append", dest="select_ids")
    args = parser.parse_args()
    if args.mode == "validate":
        tracks, _, _ = registry()
        print(json.dumps({"registered": len(tracks), "ids":
                          [t["id"] for t in tracks]}, indent=2))
        return
    if args.out is None:
        parser.error("--out required for daily/weekly modes")
    raise SystemExit(run(args.mode, args.out, args.shard, args.select_ids))


if __name__ == "__main__":
    main()
