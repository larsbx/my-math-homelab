#!/usr/bin/env python3
"""Verify the my-math-homelab workspace against its source locks.

Canonical executable for this repository's one owned boundary: the claim that
every imported program or shared component is an exact, history-preserving copy
of its locked source, and that private sources publish nothing beyond metadata.
It issues no mathematical verdict; each source repository retains its authority.

    python3 kernel/workspace.py [--root .]
"""
from __future__ import annotations

import argparse
import subprocess
import sys
import tomllib
from dataclasses import dataclass
from pathlib import Path

LOCKS = "policy/source-locks.toml"
MANIFEST = "PROGRAM.toml"
COLLECTIONS = {"program": "programs", "shared": "shared"}
IMPORTS = {"history", "metadata_only", "none"}


@dataclass(frozen=True)
class Source:
    id: str
    kind: str
    repository: str
    visibility: str
    commit: str
    imports: str
    authority: str
    commits: int | None = None
    files: int | None = None

    @property
    def root(self) -> str | None:
        collection = COLLECTIONS.get(self.kind)
        return f"{collection}/{self.id}" if collection and self.imports != "none" else None


def load_sources(root: Path) -> tuple[Source, ...]:
    rows = tomllib.loads((root / LOCKS).read_text(encoding="utf-8"))["source"]
    return tuple(
        Source(id=r["id"], kind=r["kind"], repository=r["repository"], visibility=r["visibility"],
               commit=r["commit"], imports=r["import"], authority=r["authority"],
               commits=r.get("commits"), files=r.get("files"))
        for r in rows
    )


def render_manifest(source: Source) -> str:
    """The PROGRAM.toml a program root carries: identity plus its locked source."""
    status = "verified" if source.imports == "history" else source.imports
    return (
        "version = 1\n\n"
        f'[program]\nid = "{source.id}"\n\n'
        f'[source]\nrepository = "{source.repository}"\ncommit = "{source.commit}"\n'
        f'authority = "{source.authority}"\nimport_status = "{status}"\n'
    )


def git(root: Path, *args: str) -> str:
    return subprocess.run(["git", "-C", str(root), *args], check=True,
                          capture_output=True, text=True).stdout


def tree(root: Path, rev: str, prefix: str = "") -> dict[str, str]:
    """path -> 'mode type sha' for every entry below prefix at rev."""
    spec = f"{rev}:{prefix}" if prefix else rev
    lines = git(root, "ls-tree", "-r", "-z", spec).split("\0")
    return dict(reversed(line.split("\t", 1)) for line in lines if line)


def is_ancestor(root: Path, commit: str) -> bool:
    return subprocess.run(["git", "-C", str(root), "merge-base", "--is-ancestor", commit, "HEAD"],
                          capture_output=True).returncode == 0


def check_source(root: Path, source: Source) -> list[str]:
    where = f"{source.id}:"
    if source.imports not in IMPORTS:
        return [f"{where} unknown import mode {source.imports!r}"]
    if source.authority != "retained":
        return [f"{where} authority transfer requires a decision record; lock must say retained"]
    if source.visibility == "private" and source.imports == "history":
        return [f"{where} private source imported without a disclosure decision"]
    if source.root is None:
        stray = [c for c in COLLECTIONS.values() if (root / c / source.id).exists()]
        return [f"{where} not imported but {c}/{source.id} exists" for c in stray]

    errors: list[str] = []
    head = tree(root, "HEAD", source.root) if (root / source.root).is_dir() else {}
    if not head:
        return [f"{where} missing root {source.root}"]
    if source.kind == "program":
        manifest = root / source.root / MANIFEST
        if not manifest.is_file() or manifest.read_text(encoding="utf-8") != render_manifest(source):
            errors.append(f"{where} {MANIFEST} disagrees with its lock")
    published = {p: e for p, e in head.items() if not (source.kind == "program" and p == MANIFEST)}

    if source.imports == "metadata_only":
        if published:
            errors.append(f"{where} private root publishes content: {sorted(published)[:3]}")
        return errors

    if not is_ancestor(root, source.commit):
        return errors + [f"{where} locked commit {source.commit[:12]} is not an ancestor of HEAD"]
    if int(git(root, "rev-list", "--count", source.commit)) != source.commits:
        errors.append(f"{where} history is not the locked {source.commits} commits")
    locked = tree(root, source.commit)
    if len(locked) != source.files:
        errors.append(f"{where} locked tree has {len(locked)} files, lock says {source.files}")
    changed = sorted(p for p in locked.keys() | published.keys() if locked.get(p) != published.get(p))
    if changed:
        errors.append(f"{where} imported tree differs from source: {changed[:3]}")
    dirty = git(root, "status", "--porcelain", "--", source.root)
    if dirty:
        errors.append(f"{where} working tree differs from HEAD: {dirty.splitlines()[:3]}")
    return errors


def check_workspace(root: Path, sources: tuple[Source, ...]) -> list[str]:
    estate = tomllib.loads((root / "ESTATE.toml").read_text(encoding="utf-8"))
    ids = [s.id for s in sources]
    declared = {
        "program": {p["id"]: p["root"] for p in estate.get("program", [])},
        "shared": {c["id"]: c["root"] for c in estate.get("shared_component", [])},
    }
    expected = {kind: {s.id: s.root for s in sources if s.kind == kind and s.root}
                for kind in COLLECTIONS}
    errors = [f"duplicate source id: {i}" for i in sorted({i for i in ids if ids.count(i) > 1})]
    errors += [f"ESTATE.toml {kind} entries disagree with {LOCKS}"
               for kind in COLLECTIONS if declared[kind] != expected[kind]]
    for collection in COLLECTIONS.values():
        known = {s.id for s in sources if s.root and s.root.startswith(collection + "/")}
        present = {p.name for p in (root / collection).iterdir()} if (root / collection).is_dir() else set()
        errors += [f"{collection}/{name} has no source lock" for name in sorted(present - known)]
    return errors


def verify(root: Path) -> list[str]:
    sources = load_sources(root)
    return check_workspace(root, sources) + [e for s in sources for e in check_source(root, s)]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args(argv).root.resolve()
    errors = verify(root)
    for error in errors:
        print(f"workspace check failed: {error}", file=sys.stderr)
    if not errors:
        print(f"workspace verified: {len(load_sources(root))} sources match their locks")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
