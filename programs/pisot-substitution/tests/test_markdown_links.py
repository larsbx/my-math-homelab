"""Every relative link in a tracked Markdown file resolves, so a directory move cannot strand a reference.

archive/ is excluded: its records are verbatim and may name paths of the layout they were written in.
"""

from __future__ import annotations

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LINK = re.compile(r"\]\(([^)#\s]+)(?:#[^)]*)?\)")
EXTERNAL = re.compile(r"[A-Za-z][A-Za-z0-9+.-]*:|<")


def markdown() -> list[Path]:
    out = subprocess.run(["git", "ls-files", "*.md"], cwd=ROOT, capture_output=True, text=True, check=True).stdout
    return [ROOT / rel for rel in out.split() if not rel.startswith("archive/")]


def test_relative_links_resolve():
    broken = [
        f"{path.relative_to(ROOT)}:{number}: {target}"
        for path in markdown()
        for number, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1)
        for target in LINK.findall(line)
        if not EXTERNAL.match(target) and not (path.parent / target).exists()
    ]
    assert not broken, "\n".join(broken)
