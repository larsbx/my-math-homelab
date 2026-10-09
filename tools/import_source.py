#!/usr/bin/env python3
"""Import one locked source into the workspace.

    python3 tools/import_source.py SOURCE_ID GIT_URL_OR_PATH [--root .]

history:        unsquashed subtree merge of the locked commit under its root; the
                source head becomes the merge's second parent, so every original
                commit keeps its id. Merge the resulting PR with a merge commit.
metadata_only:  writes PROGRAM.toml only; no source content is fetched or published.
                Re-running after switching the lock to history upgrades the root.

Programs then receive the PROGRAM.toml rendered from the lock, in a separate commit.
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "kernel"))
from workspace import MANIFEST, load_sources, render_manifest  # noqa: E402


def run(root: Path, *args: str) -> None:
    subprocess.run(["git", "-C", str(root), *args], check=True, capture_output=True, text=True)


def import_source(root: Path, source_id: str, url: str, trailers: tuple[str, ...] = ()) -> None:
    source = next(s for s in load_sources(root) if s.id == source_id)
    footer = "\n\n" + "\n".join(trailers) if trailers else ""
    if source.root is None:
        raise SystemExit(f"{source_id}: import = none")
    if source.imports == "history":
        run(root, "fetch", "--no-tags", url, source.commit)
        run(root, "merge", "-s", "ours", "--no-commit", "--allow-unrelated-histories", source.commit)
        run(root, "rm", "-rq", "--ignore-unmatch", "--", source.root)  # a metadata_only root being upgraded
        run(root, "read-tree", f"--prefix={source.root}/", "-u", source.commit)
        run(root, "commit", "-m",
            f"Import {source.repository}@{source.commit[:12]} under {source.root}/\n\n"
            f"Unsquashed subtree merge; all {source.commits} source commits keep their ids.\n"
            f"Source authority: {source.authority}.{footer}")
    if source.kind == "program":
        manifest = root / source.root / MANIFEST
        manifest.parent.mkdir(parents=True, exist_ok=True)
        manifest.write_text(render_manifest(source), encoding="utf-8")
        run(root, "add", str(manifest.relative_to(root)))
        run(root, "commit", "-m", f"Bind {source.id} program manifest to its source lock{footer}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("source_id")
    parser.add_argument("url")
    parser.add_argument("--trailer", action="append", default=[], help="commit message trailer")
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args(argv)
    import_source(args.root.resolve(), args.source_id, args.url, tuple(args.trailer))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
