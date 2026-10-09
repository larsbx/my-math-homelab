#!/usr/bin/env python3
"""Inventory governed claims, source statements, and all named local Lean proofs.

This is governance tooling, not a mathematical oracle. Status comes from the
existing claim policy; an inventoried statement is not thereby reviewed or
proved. Actual axiom closure is checked by ProofBankAudit.lean after Lake builds.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import os
import stat
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import make_ledger  # noqa: E402
from claim_governance.checks.claims import statement_pattern  # noqa: E402
from claim_governance.policy import load_policy  # noqa: E402
from claim_governance.repo import Repo  # noqa: E402

PROJECT = Path("proof/PscVerif")
STANDARD_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}


def prepare_audit_workspace(root: Path, target: Path) -> None:
    """Copy source/configuration only; never carry local compiled caches."""
    project = root / PROJECT
    if target.resolve().is_relative_to(project.resolve()):
        raise ValueError("Audit workspace must be outside the source project")
    if target.exists() and any(target.iterdir()):
        raise ValueError("Audit workspace must be empty")
    sources = [project / name for name in ("lean-toolchain", "lakefile.toml", "lake-manifest.json")]
    sources += sorted(project.glob("*.lean")) + sorted((project / "PscVerif").rglob("*.lean"))
    target.mkdir(parents=True, exist_ok=True)
    for path in sources:
        copied = target / path.relative_to(project)
        copied.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(path, copied)


def ignored_build_artifact(path: str, package: str) -> bool:
    """Only generated caches may escape the dependency source refusal check."""
    name = Path(path).name
    if path.lower().endswith(".lean") or name.lower() in {"lakefile.toml", "lean-toolchain", "lake-manifest.json"}:
        return False
    # ProofWidgets' frontend cache is not a Lean/Lake input. Its pinned build
    # writes dist/ and node_modules/ beside the sources rather than under .lake.
    if package == "proofwidgets" and path.startswith(("widget/dist/", "widget/node_modules/")):
        return True
    if package == "proofwidgets" and path.count("/") == 1 and path.startswith("widget/") \
            and path.endswith((".log.json", ".hash")):
        return True
    # Lake emits module setup receipts in its IR cache and downloads Reservoir
    # build barrels beside build/. These are generated artifacts, not sources.
    if path in {".lake/build.barrel", ".lake/build.barrel.trace"}:
        return True
    if path.startswith(".lake/build/ir/") and path.endswith(".setup.json"):
        return True
    if Path(path).suffix.lower() in {".toml", ".json", ".yaml", ".yml", ".cfg", ".ini", ".py", ".sh"}:
        return False
    return path.startswith((".lake/build/", ".lake/config/"))


def check_tracked_bytes(checkout: Path, package: str) -> None:
    """Compare actual files with HEAD even when index flags hide differences."""
    tree = subprocess.run(["git", "--no-replace-objects", "-C", str(checkout), "ls-tree", "-rz", "--full-tree", "HEAD"],
                          capture_output=True)
    if tree.returncode:
        raise ValueError(f"Lake checkout has an unreadable pinned tree: {package}")
    for entry in filter(None, tree.stdout.split(b"\0")):
        meta, path_bytes = entry.split(b"\t", 1)
        mode, kind, expected = meta.split()
        path = checkout / os.fsdecode(path_bytes)
        info = path.lstat()
        if kind != b"blob":
            raise ValueError(f"Lake checkout has an unsupported tree entry: {package}/{path}")
        if mode == b"120000" and stat.S_ISLNK(info.st_mode):
            contents = os.fsencode(os.readlink(path))
        elif mode in {b"100644", b"100755"} and stat.S_ISREG(info.st_mode):
            if bool(info.st_mode & 0o111) != (mode == b"100755"):
                raise ValueError(f"Lake checkout has changed tracked permissions: {package}/{path}")
            contents = path.read_bytes()
        else:
            raise ValueError(f"Lake checkout has changed tracked file type: {package}/{path}")
        actual = hashlib.sha1(b"blob " + str(len(contents)).encode() + b"\0" + contents).hexdigest().encode()
        if actual != expected:
            raise ValueError(f"Lake checkout has changed tracked bytes: {package}/{path}")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def lean_code(text: str) -> str:
    """Blank nested Lean comments and strings, preserving positions and lines."""
    out = list(text)
    i, depth, quoted = 0, 0, False
    while i < len(text):
        if depth:
            if text.startswith("/-", i):
                depth += 1
                out[i:i+2] = "  "
                i += 2
                continue
            if text.startswith("-/", i):
                depth -= 1
                out[i:i+2] = "  "
                i += 2
                continue
        elif quoted:
            if text[i] == "\\":
                out[i] = " "
                i += 1
                if i < len(text):
                    out[i] = "\n" if text[i] == "\n" else " "
                    i += 1
                continue
            if text[i] == '"':
                quoted = False
        elif text.startswith("/-", i):
            depth = 1
            out[i:i+2] = "  "
            i += 2
            continue
        elif text.startswith("--", i):
            end = text.find("\n", i)
            end = len(text) if end < 0 else end
            out[i:end] = " " * (end-i)
            i = end
            continue
        elif text[i] == '"':
            quoted = True
        else:
            i += 1
            continue
        out[i] = "\n" if text[i] == "\n" else " "
        i += 1
    if depth or quoted:
        raise ValueError("Unterminated Lean comment or string")
    return "".join(out)


def lean_declarations(root: Path) -> list[dict]:
    result = []
    project = root / PROJECT
    # The root module is part of the compiled import closure too. The adjacent
    # ProofBankAudit.lean is a replay script, not a library module.
    root_module = project / "PscVerif.lean"
    paths = ([root_module] if root_module.is_file() else [])
    paths += sorted((project / "PscVerif").rglob("*.lean"))
    for path in paths:
        text = path.read_text(encoding="utf-8")
        code = lean_code(text)
        # Lean's pinned Parser.Command.declModifiers accepts visibility,
        # protected, meta/noncomputable, unsafe and partial/nonrec, with
        # arbitrary intervening whitespace. Blank balanced attribute lists so
        # multiline attributes cannot conceal the following declaration.
        masked = list(code)
        i = 0
        while i < len(code):
            if not code.startswith("@[", i):
                i += 1
                continue
            depth, end = 1, i + 2
            while end < len(code) and depth:
                if code[end] == "[": depth += 1
                elif code[end] == "]": depth -= 1
                end += 1
            if depth:
                raise ValueError(f"Unterminated Lean attribute: {path}")
            masked[i:end] = ["\n" if c == "\n" else " " for c in code[i:end]]
            i = end
        code = "".join(masked)
        headers = re.compile(
            r"(?m)^[ \t]*(?P<modifiers>(?:(?:private|public|protected|meta|noncomputable|unsafe|partial|nonrec)\s+)*)"
            r"(?:theorem|lemma)\s+(?P<name>[^\s(:]+)"
        )
        matches = list(headers.finditer(code))
        # A scoped command or future grammar form must refuse inventory, not
        # silently drop its named proof. The compiled audit's extra generated
        # theorems cannot alone detect such a source-inventory omission.
        for token in re.finditer(r"\b(?:theorem|lemma)\s+[^\s(:]+", code):
            if not any(match.start() <= token.start() < match.end() for match in matches):
                number = code.count("\n", 0, token.start()) + 1
                raise ValueError(f"Unaccounted Lean proof header: {path}:{number}")
        declarations = {code.count("\n", 0, match.start()) + 1:
                        (match["name"], "private" in match["modifiers"].split()) for match in matches}
        module = ".".join(path.relative_to(project).with_suffix("").parts)
        stack: list[str | None] = []
        for number, line in enumerate(code.splitlines(), 1):
            opening = re.match(r"\s*(namespace|section)(?:\s+(\S+))?\s*$", line)
            if opening:
                stack.append(opening[2] if opening[1] == "namespace" else None)
            elif re.match(r"\s*end(?:\s+\S+)?\s*$", line):
                if not stack:
                    raise ValueError(f"Unmatched namespace/section end: {path}:{number}")
                stack.pop()
            if number in declarations:
                identifier, private = declarations[number]
                name = ".".join([s for s in stack if s] + [identifier])
                result.append({"name": name, "module": module, "private": private,
                               "source": path.relative_to(root).as_posix(),
                               "line": number, "declaration": text.splitlines()[number-1].strip()})
        if stack:
            raise ValueError(f"Unclosed namespace/section: {path}")
    if not result or len({(d["module"], d["name"]) for d in result}) != len(result):
        raise ValueError("Empty or duplicate Lean declaration inventory")
    return result


def check_imports(root: Path) -> None:
    project = root / PROJECT
    paths = {"PscVerif": project / "PscVerif.lean"}
    paths.update({".".join(p.relative_to(project).with_suffix("").parts): p
                  for p in (project / "PscVerif").rglob("*.lean")})
    reached, pending = set(), ["PscVerif"]
    while pending:
        mod = pending.pop()
        if mod in reached:
            continue
        reached.add(mod)
        code = lean_code(paths[mod].read_text(encoding="utf-8"))
        for match in re.finditer(r"(?m)^\s*(?:public\s+)?import\s+(PscVerif(?:\.\S+)?)\s*$", code):
            if match[1] not in paths:
                raise ValueError(f"Missing local Lean import: {match[1]}")
            pending.append(match[1])
    if set(paths) != reached:
        raise ValueError(f"Lean modules outside the root import closure: {sorted(set(paths)-reached)}")


def check_pins(root: Path, require_packages: bool = False) -> dict:
    project = root / PROJECT
    pin = (project / "lean-toolchain").read_text().strip()
    if not re.fullmatch(r"leanprover/lean4:v[0-9]+\.[0-9]+\.[0-9]+(?:-rc[0-9]+)?", pin):
        raise ValueError("lean-toolchain must name an exact Lean release")
    config = tomllib.loads((project / "lakefile.toml").read_text())
    manifest = json.loads((project / "lake-manifest.json").read_text())
    packages = manifest["packages"]
    by_name = {p["name"]: p for p in packages}
    if not packages or len(by_name) != len(packages):
        raise ValueError("Empty or duplicate Lake package manifest")
    for package in packages:
        if package.get("type") != "git" or not re.fullmatch(r"[0-9a-f]{40}", package.get("rev", "")):
            raise ValueError(f"Unpinned Lake dependency: {package['name']}")
        checkout = project / manifest["packagesDir"] / package["name"]
        if require_packages or checkout.exists():
            run = subprocess.run(["git", "--no-replace-objects", "-C", str(checkout), "rev-parse", "HEAD"], capture_output=True, text=True)
            if run.returncode or run.stdout.strip() != package["rev"]:
                raise ValueError(f"Lake checkout does not match its manifest pin: {package['name']}")
            status = subprocess.run(
                ["git", "--no-replace-objects", "-C", str(checkout), "status", "--porcelain",
                 "--untracked-files=all", "--ignore-submodules=none"],
                capture_output=True, text=True,
            )
            if status.returncode or status.stdout.strip():
                raise ValueError(f"Lake checkout has tracked or untracked changes or unreadable status: {package['name']}")
            ignored = subprocess.run(
                ["git", "--no-replace-objects", "-C", str(checkout), "ls-files", "--others", "--ignored",
                 "--exclude-standard", "-z"], capture_output=True, text=True,
            )
            if ignored.returncode:
                raise ValueError(f"Lake checkout has unreadable ignored-file status: {package['name']}")
            for path in filter(None, ignored.stdout.split("\0")):
                if not ignored_build_artifact(path, package["name"]):
                    raise ValueError(f"Lake checkout has an ignored input outside permitted build artifacts: {package['name']}/{path}")
            check_tracked_bytes(checkout, package["name"])
    for requirement in config.get("require", []):
        package = by_name.get(requirement["name"])
        if package is None or requirement.get("rev") != package["rev"] or requirement.get("git") != package["url"] or package.get("inputRev") != package["rev"]:
            raise ValueError(f"Lake direct dependency must match its manifest URL and revision: {requirement['name']}")
    mathlib = project / manifest["packagesDir"] / "mathlib" / "lean-toolchain"
    if mathlib.exists() and mathlib.read_text().strip() != pin:
        raise ValueError("Mathlib's Lean release differs from lean-toolchain")
    return {"lean": pin, "packages": [{"name": p["name"], "rev": p["rev"], "url": p["url"]} for p in packages]}


def statement_inventory(root: Path) -> list[dict]:
    policy = load_policy(root / "claim_governance.toml")
    repo = Repo(root, policy.scan.exclude)
    base = statement_pattern(policy.claims.statement_kinds)
    # The existing status scanner omits italic statements and Greek result names.
    extra = re.compile(
        r"(?im)^[ \t]*(?:#{1,6}[ \t]+(?:[0-9]+[a-z]?(?:\.[0-9]+[a-z]?)*\.?[ \t]+)?|\*\*|\*|>[ \t]*\*\*)"
        r"(?:Lemma|Theorem|Proposition|Corollary)(?:[ \t]+[\w′″'’]+(?:\.[\w′″'’]+)*)?[ \t]*(?:[:.(*)]|$)"
    )
    found = []
    for rel in repo.files(policy.claims.paths):
        text, masked = repo.text(rel), repo.masked(rel)
        matches = {m.start(): m for p in (base, extra) for m in p.finditer(masked)}
        lines = text.splitlines()
        for start in sorted(matches):
            number = text.count("\n", 0, start) + 1
            # Patterns may include preceding blank whitespace; select the statement line.
            while number <= len(lines) and not lines[number-1].strip():
                number += 1
            found.append({"source": rel, "line": number, "statement_heading": lines[number-1].strip()})
    return found


def bank(root: Path = ROOT) -> dict:
    pins = check_pins(root)
    check_imports(root)
    formal = lean_declarations(root)
    names = {d["name"] for d in formal}
    cfg = tomllib.loads((root / "proof/proof-bank.toml").read_text())
    policy = tomllib.loads((root / "claim_governance.toml").read_text())
    claims = {c["name"]: c for c in policy["claim"]}
    overrides = {c["claim"]: c for c in cfg.get("evidence", [])}
    expected = set(claims) - set(make_ledger.TABLE)
    if set(overrides) != expected or len(overrides) != len(cfg.get("evidence", [])):
        raise ValueError(f"Non-ledger evidence inventory mismatch: missing={sorted(expected-set(overrides))}, extra={sorted(set(overrides)-expected)}")
    supports: dict[str, dict] = {}
    for support in cfg.get("lean_support", []):
        if support["claim"] not in claims or support["claim"] in supports:
            raise ValueError(f"Unknown or duplicate Lean support claim: {support['claim']}")
        if support["coverage"] not in {"partial", "full"} or not set(support["declarations"]) <= names:
            raise ValueError(f"Invalid Lean support binding: {support['claim']}")
        if any(sum(d["name"] == name for d in formal) != 1 for name in support["declarations"]):
            raise ValueError(f"Ambiguous Lean support binding: {support['claim']}")
        supports[support["claim"]] = support
    entries = []
    for name, claim in sorted(claims.items()):
        node = make_ledger.TABLE.get(name)
        source = node[2] if node else overrides[name]["source"]
        if not source.strip():
            raise ValueError(f"Empty evidence locator: {name}")
        if not node and not (root / source.split(",", 1)[0]).is_file():
            raise ValueError(f"Missing non-ledger evidence source: {name}")
        entries.append({"name": name, "status": claim["status"], "source": source,
                        "dependencies": list(node[3]) if node else [], "ledger_node": bool(node),
                        "lean_support": supports.get(name, {"coverage": "none", "declarations": [],
                                                             "note": "No complete Lean proof is registered for this claim."})})
    inputs = [root / "claim_governance.toml", root / "tools/make_ledger.py",
              root / "tools/make_proof_bank.py", root / "tools/check_lean.sh",
              root / "tools/setup_lean.sh", root / "proof/proof-bank.toml"]
    inputs += sorted((root / PROJECT).glob("*.toml")) + [root / PROJECT / "lean-toolchain", root / PROJECT / "lake-manifest.json"]
    inputs += sorted((root / PROJECT).glob("*.lean"))
    inputs += sorted((root / PROJECT / "PscVerif").rglob("*.lean"))
    return {"format": "psc-proof-bank-v1", "scope": "All governed claims, apparent source statement openings under the claim policy, and named theorems/lemmas in every local Lean module.",
            "authority": "Inventory only; claim statuses retain their existing authority. Source openings may be proposals or repeated statements, not new reviewed theorems.",
            "pins": pins, "claims": entries, "lean_declarations": formal,
            "source_statements": statement_inventory(root),
            "input_digests": {p.relative_to(root).as_posix(): digest(p) for p in sorted(set(inputs))}}


def markdown(data: dict) -> str:
    lines = ["# Proof bank", "", "Generated by `python3 tools/make_proof_bank.py`; do not hand-edit.", "",
             f"Inventories **{len(data['claims'])} governed claims**, **{len(data['lean_declarations'])} named Lean proofs** and **{len(data['source_statements'])} source statement openings**. Inventory completeness does not assert that open premises are proved or that every note has been reviewed.", "",
             "Provision Lean/Lake with `./tools/setup_lean.sh`; verify with `./tools/check_lean.sh`. The remote session hook and CI use the same scripts. Each verification invokes Lean/Lake through the explicit checked-in Elan toolchain and rejects executable version mismatches, copies only project sources/configuration into an isolated workspace, checks freshly cloned pinned dependencies, disables caller Lake caches/configuration, and downloads Mathlib artifacts from the fixed upstream source-hash cache into an empty temporary directory. Local compiled artifacts and their metadata never enter verification. The upstream cache and pinned compiler remain explicit trust inputs. PSC is compiled there and a fresh audit inspects every compiled local declaration, rejecting local or nonstandard axioms. Standard axioms: `propext`, `Classical.choice`, `Quot.sound`.", "",
             "## Governed claims", "", "A partial Lean binding proves only the listed algebraic component. A source-only claim is not presented as machine-checked. Dependencies are the existing proof-ledger sufficiency edges; empty dependencies for a non-ledger claim do not assert independence.", "",
             "| Claim | Status | Lean coverage | Evidence |", "|---|---|---|---|"]
    for c in data["claims"]:
        source = c["source"].replace("|", "\\|").replace("\n", " ")
        lines.append(f"| {c['name']} | {c['status']} | {c['lean_support']['coverage']} | {source} |")
    lines += ["", "## Named Lean proofs", "", "Each declaration below must be present in a fresh compiled-environment audit. Generated helpers and definitions are audited too.", "",
              "| Source name | Module | Private modifier | Source |", "|---|---|---|---|"]
    for d in data["lean_declarations"]:
        lines.append(f"| `{d['name']}` | `{d['module']}` | {'yes' if d['private'] else 'no'} | [{d['source']}:{d['line']}](../{d['source']}#L{d['line']}) |")
    lines += ["", "## Source statement inventory", "", "These are apparent statement openings, including open targets, imported results and repeated headings. Their inclusion grants no proof status. Exact machine-readable locators are in [`proof-bank.json`](../proof/proof-bank.json).", "",
              "| Source | Statement opening |", "|---|---|"]
    for d in data["source_statements"]:
        label = d["statement_heading"].replace("|", "\\|").replace("`", "")
        lines.append(f"| [{d['source']}:{d['line']}](../{d['source']}#L{d['line']}) | {label} |")
    return "\n".join(lines) + "\n"


def check_audit(text: str, expected: set[tuple[str, str]]) -> tuple[int, int]:
    declarations: dict[str, tuple[str, str, str]] = {}
    receipt = None
    for line in text.splitlines():
        if line.startswith("PSC_AXIOMS\t"):
            fields = line.split("\t")
            if len(fields) != 6 or fields[1] not in {"theorem", "declaration"} \
                    or not all(fields[2:5]) or fields[3] in declarations \
                    or not (fields[2] == "PscVerif" or fields[2].startswith("PscVerif.")):
                raise ValueError("Malformed or duplicate Lean audit declaration")
            if set(filter(None, fields[5].split(","))) - STANDARD_AXIOMS:
                raise ValueError(f"Nonstandard axioms in {fields[3]}: {fields[5]}")
            if receipt is not None:
                raise ValueError("Lean declarations after completion receipt")
            declarations[fields[3]] = (fields[1], fields[2], fields[4])
        elif line.startswith("PSC_AUDIT_COMPLETE\t"):
            fields = line.split("\t")
            if receipt is not None or len(fields) != 3:
                raise ValueError("Malformed or duplicate Lean audit completion receipt")
            receipt = (int(fields[1]), int(fields[2]))
    theorems = {n for n, (kind, _, _) in declarations.items() if kind == "theorem"}
    reached = {(module, user_name) for kind, module, user_name in declarations.values() if kind == "theorem"}
    if receipt != (len(declarations), len(theorems)) or not theorems or not expected <= reached:
        raise ValueError(f"Incomplete Lean audit: missing={sorted(expected-reached)}, receipt={receipt}")
    return receipt


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--pins-only", action="store_true")
    parser.add_argument("--require-packages", action="store_true")
    parser.add_argument("--audit-log", type=Path)
    parser.add_argument("--prepare-audit-workspace", type=Path)
    args = parser.parse_args(argv)
    try:
        if args.pins_only:
            check_pins(ROOT, args.require_packages)
            print("Lean release and Lake dependency pins agree")
            return 0
        data = bank()
        artifacts = {ROOT / "proof/proof-bank.json": json.dumps(data, ensure_ascii=False, indent=2)+"\n",
                     ROOT / "docs/proof-bank.md": markdown(data)}
        for path, text in artifacts.items():
            if args.check:
                if not path.is_file() or path.read_text(encoding="utf-8") != text:
                    raise ValueError(f"Stale proof bank: {path.relative_to(ROOT)}; run tools/make_proof_bank.py")
            else:
                path.write_text(text, encoding="utf-8")
        if args.prepare_audit_workspace:
            prepare_audit_workspace(ROOT, args.prepare_audit_workspace)
            print("Prepared isolated Lean workspace from source/configuration only")
        if args.audit_log:
            counts = check_audit(args.audit_log.read_text(encoding="utf-8"),
                                 {(d["module"], d["name"]) for d in data["lean_declarations"]})
            print(f"Lean axiom audit: {counts[0]} declarations, {counts[1]} theorems; all named proofs reached")
        print(f"Proof bank: {len(data['claims'])} claims, {len(data['lean_declarations'])} named Lean proofs, {len(data['source_statements'])} source openings")
        return 0
    except (ValueError, KeyError, OSError) as exc:
        print(f"Proof bank rejected: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
