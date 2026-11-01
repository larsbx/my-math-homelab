"""Homelab AKN research coordinator: status, exact-head execution, evidence.

The source tiling-theory repository retains all theorem/claim authority. This
coordinator NEVER edits imported programs, merges PRs, or promotes claims.
Python standard library only; can run as a scheduled GitHub Actions job.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tomllib
import traceback
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "policy" / "research-schedules.toml"
LOCKS = ROOT / "policy" / "source-locks.toml"
HEX40 = re.compile(r"^[0-9a-f]{40}$")


def load_study():
    data = tomllib.loads(REGISTRY.read_text(encoding="utf-8"))
    assert data["version"] == 1
    study, = data["study"]
    assert study["id"] == "akn-generic-atlas-and-singular-strata"
    assert study["program"] == "tiling-theory"
    assert study["claim_namespace"] == "TT"
    assert study["authority"] == "source_retained"
    assert study["claim_status"] == "unpromoted-research"
    assert study["execution_strategy"] == "fetch_exact_pr_head"
    assert not study["auto_merge"] and not study["auto_claim_promotion"]
    assert study["source_parent_pr"] == 22
    assert study["source_research_pr"] == 23
    assert study["source_next_issue"] == 24
    assert HEX40.fullmatch(study["source_head_at_registration"])
    assert 0 <= study["max_depth"] <= 15
    assert 0 <= study["max_nodes"] <= 100000
    assert study["boundary_strata_exhaustive"] is False
    locks = tomllib.loads(LOCKS.read_text(encoding="utf-8"))
    source, = (x for x in locks["source"] if x["id"] == study["program"])
    assert source["repository"] == study["source_repository"]
    assert source["authority"] == "retained"
    assert source["import"] == "history"
    return study


def api_get(url):
    headers = {"Accept": "application/vnd.github+json",
               "User-Agent": "my-math-homelab-research-coordinator",
               "X-GitHub-Api-Version": "2022-11-28"}
    token = os.environ.get("GH_TOKEN")
    if token:
        headers["Authorization"] = "Bearer " + token
    with urlopen(Request(url, headers=headers), timeout=25) as response:
        return json.load(response)


def compact_pr(pr):
    head = pr["head"]
    return {
        "number": pr["number"],
        "state": pr["state"],
        "draft": bool(pr["draft"]),
        "merged": bool(pr.get("merged", False)),
        "base_branch": pr["base"]["ref"],
        "head_repo": head["repo"]["full_name"],
        "head_branch": head["ref"],
        "head_sha": head["sha"],
        "html_url": pr["html_url"],
        "updated_at": pr["updated_at"],
    }


def select_source(study, prs):
    """Return exact open PR head; after merge transition to validated main."""
    assert set(prs) == {22, 23}, "both source PRs must be observed"
    first, second = prs[22], prs[23]
    for pr in (first, second):
        assert pr["head_repo"] == study["source_repository"], (
            "unexpected forked PR source; refusing to execute unreviewed code"
        )
        assert HEX40.fullmatch(pr["head_sha"])
    assert second["number"] == 23 and first["number"] == 22
    assert first["state"] == "open" or first["merged"], (
        "parent PR #22 closed unmerged: research baseline requires review"
    )
    if first["state"] == "open":
        assert first["head_branch"] == "research/akn-radius2-exact-feasibility"
    if second["state"] == "open":
        assert second["head_branch"] == "research/akn-chamber-conjugacy-certificate"
        allowed_bases = (first["head_branch"], "main") if first["merged"] else (
            first["head_branch"],)
        assert second["base_branch"] in allowed_bases, (
            "stacked PR unexpectedly retargeted: mathematical review required"
        )
        return second["head_sha"]
    assert second["merged"] and second["state"] == "closed", (
        "source PR #23 closed without merge: replan before executing"
    )
    return None  # main must be inspected separately after the merger


def snapshot(study):
    base = "https://api.github.com/repos/" + study["source_repository"]
    raw = {number: api_get(base + f"/pulls/{number}")
           for number in (study["source_parent_pr"],
                          study["source_research_pr"])}
    prs = {number: compact_pr(pr) for number, pr in raw.items()}
    issue = api_get(base + "/issues/" + str(study["source_next_issue"]))
    selected = select_source(study, prs)
    if selected is None:
        main = api_get(base + "/branches/main")
        selected = main["commit"]["sha"]
        assert HEX40.fullmatch(selected)
        fetch_ref = "refs/heads/main"
        revision_origin = "merged_default_branch"
    else:
        fetch_ref = "refs/pull/23/head"
        revision_origin = "open_research_pr_head"
    runs = {}
    for number, pr in prs.items():
        try:
            response = api_get(base + "/actions/runs?head_sha="
                               + pr["head_sha"] + "&per_page=100")
            runs[str(number)] = [{
                "id": x["id"], "name": x["name"],
                "status": x["status"], "conclusion": x["conclusion"],
                "head_sha": x["head_sha"], "html_url": x["html_url"]
            } for x in response["workflow_runs"] if x["head_sha"] == pr["head_sha"]]
        except Exception as exc:
            # No status is ever treated as 'passing' when it was unavailable.
            runs[str(number)] = {"status": "unavailable",
                                 "reason": str(exc)[:500]}
    return {
        "source_head_sha": selected,
        "source_fetch_ref": fetch_ref,
        "source_revision_origin": revision_origin,
        "source_head_changed_since_registration":
            selected != study["source_head_at_registration"],
        "source_prs": {str(k): v for k, v in prs.items()},
        "source_issue": {
            "number": issue["number"], "state": issue["state"],
            "html_url": issue["html_url"], "title": issue["title"]},
        "exact_head_action_runs": runs,
    }


def command(argv, *, cwd=None, stdout_file=None):
    """Execute without a shell and never suppress failure diagnostics."""
    p = subprocess.run(argv, cwd=cwd, check=False,
                       capture_output=True, text=True,
                       env={k: v for k, v in os.environ.items()
                            if k not in ("GH_TOKEN", "GITHUB_TOKEN", "GH_ENTERPRISE_TOKEN")})
    if stdout_file is not None:
        stdout_file.write_text(p.stdout, encoding="utf-8")
        stdout_file.with_suffix(".stderr.txt").write_text(
            p.stderr, encoding="utf-8")
    if p.returncode:
        raise RuntimeError(
            f"command exited {p.returncode}: {argv[0]} "
            f"{p.stderr[-2500:]}"
        )
    return p.stdout.strip()


def execute_full(study, sha, fetch_ref, out, checkout):
    """Run an inspected exact source revision; preserve evidence under out."""
    assert fetch_ref in ("refs/pull/23/head", "refs/heads/main")
    assert HEX40.fullmatch(sha)
    checkout.mkdir(parents=True, exist_ok=True)
    command(["git", "init", "-q", str(checkout)])
    source = "https://github.com/" + study["source_repository"] + ".git"
    command(["git", "-C", str(checkout), "fetch", "--depth=1",
             source, fetch_ref])
    found = command(["git", "-C", str(checkout), "rev-parse", "FETCH_HEAD"])
    if found != sha:
        raise RuntimeError(
            "source ref advanced between GitHub API inspection and fetch; "
            "refusing mixed-revision research evidence"
        )
    command(["git", "-C", str(checkout), "checkout", "--detach", sha])
    code = checkout / "research" / "akn"
    assert (code / "atlas_research_driver.py").is_file(), (
        "source revision lacks the registered research driver"
    )
    exact = out / "exact-generic"
    exact.mkdir(exist_ok=True)
    driver = [sys.executable, str(code / "atlas_research_driver.py"),
              "--max-depth", str(study["max_depth"]),
              "--max-nodes", str(study["max_nodes"]), "--require-full",
              "--out", str(exact.resolve())]
    command(driver, cwd=checkout, stdout_file=out / "generic-stdout.txt")
    verdict = json.loads((exact / "research-run.json").read_text())
    if verdict["state"] != "generic_candidate_verified":
        raise RuntimeError("full independent generic candidate verification not complete")
    packet = exact / "chambers.json"
    if not packet.is_file():
        raise RuntimeError("full witness packet missing")
    singular = out / "singular-plane-probes.json"
    command([sys.executable, str(code / "atlas_singular_probe.py"),
             "--packet", str(packet.resolve()), "--out", str(singular.resolve())],
            cwd=checkout, stdout_file=out / "singular-stdout.txt")
    replay = out / "singular-independent-replay.json"
    command([sys.executable, str(code / "atlas_singular_check.py"),
             str(singular.resolve()), "--out", str(replay.resolve())],
            cwd=checkout, stdout_file=out / "singular-replay-stdout.txt")
    result = json.loads(replay.read_text())
    assert result["exact_interior_plane_probes_verified"] == study[
        "singular_plane_probes"]
    assert result["all_singular_strata_covered"] is False
    assert result["boundary_convention_decided"] is False
    summary = json.loads((exact / "independent-replay.json").read_text())
    assert summary["coverage_verified_generic"] is True
    assert summary["independently_counted_regions"] == study[
        "expected_generic_regions"]
    assert summary["icosahedral_star_orbits"] == study[
        "expected_icosahedral_orbits"]
    assert summary["stabilizer_subgroup_conjugacy_types"] == study[
        "expected_stabilizer_conjugacy_types"]
    return {
        "generic": verdict["state"],
        "generic_regions": summary["independently_counted_regions"],
        "star_orbits": summary["icosahedral_star_orbits"],
        "stabilizer_conjugacy_types":
            summary["stabilizer_subgroup_conjugacy_types"],
        "singular_plane_probes": result["exact_interior_plane_probes_verified"],
        "singular_strata_complete": False,
        "next_obligation": (
            "Issue #24: exhaustive exact lower-dimensional singular-stratum "
            "enumeration and independent boundary-convention verification"),
    }


def run(mode, out, checkout=None):
    study = load_study()
    out.mkdir(parents=True, exist_ok=True)
    record = {
        "schema": "HOMELAB-MATH-RESEARCH-CYCLE-1",
        "study": study["id"],
        "mode": mode,
        "started_at_utc": datetime.now(timezone.utc).isoformat(),
        "research_authority": "larsbx/tiling-theory-research",
        "automatic_theorem_promotion": False,
        "automatic_merge": False,
        "status": "running",
        "baseline": {
            "registration_head": study["source_head_at_registration"],
            "source_import_root": "programs/tiling-theory",
            "coordinator_edits_imported_tree": False,
        },
    }
    target = out / "research-cycle.json"

    def persist():
        target.write_text(json.dumps(record, sort_keys=True, indent=2) + "\n",
                          encoding="utf-8")

    persist()
    try:
        snap = snapshot(study)
        record.update(snap)
        if mode == "full":
            if checkout is None:
                raise ValueError("full mode requires --checkout outside imported trees")
            evidence = execute_full(study, snap["source_head_sha"],
                                    snap["source_fetch_ref"], out, checkout)
            record["verified_experiment"] = evidence
            record["status"] = "finite_generic_candidate_verified"
        else:
            record["status"] = "status_recorded"
        record["next_obligation"] = (
            "Review source PR #22 and #23 exact-head CI and finish issue #24 "
            "singular-stratum proof; never promote finite evidence automatically."
        )
    except Exception as exc:
        record["status"] = "incomplete"
        record["error"] = f"{type(exc).__name__}: {exc}"
        record["next_obligation"] = (
            "Investigate exact GitHub/source and research cycle failure. "
            "Preserve partial evidence; do not accept mathematical claims."
        )
        (out / "traceback.txt").write_text(traceback.format_exc(),
                                           encoding="utf-8")
    finally:
        record["finished_at_utc"] = datetime.now(timezone.utc).isoformat()
        persist()
    return 0 if record["status"] in (
        "status_recorded", "finite_generic_candidate_verified") else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=("status", "full"), required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--checkout", type=Path)
    args = parser.parse_args()
    raise SystemExit(run(args.mode, args.out.resolve(),
                         args.checkout.resolve() if args.checkout else None))


if __name__ == "__main__":
    main()
