"""Measure a serialized clean Lean build and preserve its axiom-audit output.

Linux only: wait4 reports each build's largest child-process RSS, not aggregate
memory. Build local modules in import order so each measurement compiles exactly
one new module. Run both revisions on the same machine with the same toolchain;
wall times are serialized build times, not Lake's default parallel build times.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time


def run(command, cwd, log):
    start = time.monotonic_ns()
    with log.open("w") as output:
        process = subprocess.Popen(command, cwd=cwd, stdout=output, stderr=subprocess.STDOUT)
        try:
            _, status, usage = os.wait4(process.pid, 0)
        except BaseException:
            process.kill()
            process.wait()
            raise
        process.returncode = os.waitstatus_to_exitcode(status)
    result = {"command": command, "exit_code": process.returncode,
              "wall_ns": time.monotonic_ns() - start, "max_rss_kib": usage.ru_maxrss}
    print(json.dumps(result), flush=True)
    if process.returncode:
        raise RuntimeError(f"command failed; see {log}")
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root, output = args.root.resolve(), args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    proof = root / "proof" / "langlands"
    lake = shutil.which("lake")
    if lake is None:
        raise RuntimeError("lake not found")
    sources = {".".join(path.relative_to(proof).with_suffix("").parts): path
               for path in proof.rglob("*.lean") if ".lake" not in path.parts and path.name != "Audit.lean"}
    order, visiting, done = [], set(), set()

    def visit(module):
        if module in done:
            return
        if module in visiting:
            raise RuntimeError(f"import cycle: {module}")
        visiting.add(module)
        for dependency in re.findall(r"^import\s+(\S+)", sources[module].read_text(), re.MULTILINE):
            if dependency in sources:
                visit(dependency)
        visiting.remove(module)
        done.add(module)
        order.append(module)

    visit("LanglandsOracles.Pseudocharacter")
    for module in sorted(sources):
        visit(module)
    metadata = {
        "revision": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip(),
        "source_sha256": {module: hashlib.sha256(path.read_bytes()).hexdigest()
                          for module, path in sorted(sources.items())},
        "lean_toolchain": (proof / "lean-toolchain").read_text().strip(),
        "lean_version": subprocess.check_output([lake, "env", "lean", "--version"], cwd=proof, text=True).strip(),
        "machine": list(os.uname()),
        "meminfo": Path("/proc/meminfo").read_text(),
        "cpuinfo": Path("/proc/cpuinfo").read_text(),
        "rss_scope": "largest child process; not aggregate concurrent memory",
        "schedule": "serialized modules in import order; no shared project build cache",
    }
    (output / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n")
    run([lake, "clean"], proof, output / "clean.log")
    start = time.monotonic_ns()
    builds = {module: run([lake, "build", module], proof, output / f"{module}.log") for module in order}
    builds["default_targets"] = run([lake, "build"], proof, output / "default_targets.log")
    summary = {"revision": metadata["revision"], "clean_build_wall_ns": time.monotonic_ns() - start,
               "max_rss_kib": max(result["max_rss_kib"] for result in builds.values()), "builds": builds}
    (output / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    run([lake, "env", "lean", "Audit.lean"], proof, output / "audit.log")


if __name__ == "__main__":
    main()
