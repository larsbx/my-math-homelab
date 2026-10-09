"""Conformance for kernel/workspace.py: one valid baseline, one rejecting mutation per rule."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT / "kernel"), str(ROOT / "tools")]
from import_source import import_source  # noqa: E402
from workspace import verify  # noqa: E402


def git(root: Path, *args: str) -> str:
    return subprocess.run(["git", "-C", str(root), "-c", "user.name=t", "-c", "user.email=t@t", *args],
                          check=True, capture_output=True, text=True).stdout.strip()


def repo(path: Path, files: dict[str, str], commits: int = 1) -> str:
    git(path.parent, "init", "-q", "-b", "main", path.name)
    git(path, "config", "user.name", "t")
    git(path, "config", "user.email", "t@t")
    for n in range(commits):
        for name, text in files.items():
            (path / name).parent.mkdir(parents=True, exist_ok=True)
            (path / name).write_text(f"{text}{n}")
        git(path, "add", "-A")
        git(path, "-c", "user.name=t", "-c", "user.email=t@t", "commit", "-qm", f"c{n}")
    return git(path, "rev-parse", "HEAD")


def lock(id_: str, kind: str, commit: str, imports: str, visibility: str = "public",
         commits: int = 2, files: int = 2) -> str:
    return (f'[[source]]\nid = "{id_}"\nkind = "{kind}"\nrepository = "o/{id_}"\n'
            f'visibility = "{visibility}"\ncommit = "{commit}"\ncommits = {commits}\nfiles = {files}\n'
            f'import = "{imports}"\nauthority = "retained"\n\n')


@pytest.fixture
def workspace(tmp_path: Path) -> Path:
    alpha = repo(tmp_path / "alpha", {"README.md": "a", "kernel/x.py": "x"}, commits=2)
    shared = repo(tmp_path / "lib", {"README.md": "l", "src/l.py": "l"}, commits=2)
    secret = repo(tmp_path / "secret", {"README.md": "s"})
    ws = tmp_path / "ws"
    repo(ws, {"README.md": "ws"})
    (ws / "policy").mkdir()
    (ws / "policy/source-locks.toml").write_text(
        "version = 1\n\n" + lock("alpha", "program", alpha, "history")
        + lock("secret", "program", secret, "metadata_only", "private", 1, 1)
        + lock("lib", "shared", shared, "history"))
    (ws / "ESTATE.toml").write_text(
        '[[program]]\nid = "alpha"\nroot = "programs/alpha"\n\n'
        '[[program]]\nid = "secret"\nroot = "programs/secret"\n\n'
        '[[shared_component]]\nid = "lib"\nroot = "shared/lib"\n')
    git(ws, "add", "-A")
    git(ws, "commit", "-qm", "scaffold")
    for id_, src in (("alpha", "alpha"), ("secret", "secret"), ("lib", "lib")):
        import_source(ws, id_, str(tmp_path / src))
    return ws


def commit_all(ws: Path) -> None:
    git(ws, "add", "-A")
    git(ws, "commit", "-qm", "mutation")


def test_baseline_passes(workspace: Path) -> None:
    assert verify(workspace) == []


def test_history_is_preserved(workspace: Path) -> None:
    alpha = git(workspace.parent / "alpha", "rev-parse", "HEAD")
    parents = git(workspace, "log", "--merges", "--format=%P").split()
    assert alpha in parents and git(workspace, "rev-list", "--count", alpha) == "2"


@pytest.mark.parametrize("path", ["programs/alpha/kernel/x.py", "shared/lib/src/l.py"])
def test_rejects_edited_import(workspace: Path, path: str) -> None:
    (workspace / path).write_text("edited")
    commit_all(workspace)
    assert any("differs from source" in e for e in verify(workspace))


def test_rejects_uncommitted_edit(workspace: Path) -> None:
    (workspace / "programs/alpha/README.md").write_text("dirty")
    assert any("working tree" in e for e in verify(workspace))


def test_rejects_extra_file_in_import(workspace: Path) -> None:
    (workspace / "programs/alpha/new.py").write_text("n")
    commit_all(workspace)
    assert any("differs from source" in e for e in verify(workspace))


def test_rejects_private_content(workspace: Path) -> None:
    (workspace / "programs/secret/README.md").write_text("leak")
    commit_all(workspace)
    assert any("private root publishes content" in e for e in verify(workspace))


def test_rejects_private_history_import(workspace: Path) -> None:
    locks = workspace / "policy/source-locks.toml"
    locks.write_text(locks.read_text().replace('"metadata_only"', '"history"'))
    assert any("disclosure decision" in e for e in verify(workspace))


def test_rejects_manifest_drift(workspace: Path) -> None:
    manifest = workspace / "programs/alpha/PROGRAM.toml"
    manifest.write_text(manifest.read_text().replace('"retained"', '"transferred"'))
    commit_all(workspace)
    assert any("PROGRAM.toml disagrees" in e for e in verify(workspace))


def test_rejects_wrong_commit_count(workspace: Path) -> None:
    locks = workspace / "policy/source-locks.toml"
    locks.write_text(locks.read_text().replace("commits = 2", "commits = 3", 1))
    assert any("history is not" in e for e in verify(workspace))


def test_rejects_unlocked_root(workspace: Path) -> None:
    (workspace / "programs/rogue").mkdir()
    (workspace / "programs/rogue/x").write_text("x")
    assert any("rogue has no source lock" in e for e in verify(workspace))


def test_rejects_estate_disagreement(workspace: Path) -> None:
    estate = workspace / "ESTATE.toml"
    estate.write_text(estate.read_text().replace('id = "secret"\nroot = "programs/secret"\n', 'id = "secret"\nroot = "programs/other"\n'))
    assert any("ESTATE.toml program entries disagree" in e for e in verify(workspace))


def test_rejects_authority_transfer(workspace: Path) -> None:
    locks = workspace / "policy/source-locks.toml"
    locks.write_text(locks.read_text().replace('authority = "retained"', 'authority = "transferred"', 1))
    assert any("decision record" in e for e in verify(workspace))


def test_repository_passes() -> None:
    assert verify(ROOT) == [], "the checked-in workspace must verify"
