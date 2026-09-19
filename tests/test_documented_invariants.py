"""Repository invariants that are cheap to state and expensive to lose."""

import re
import tomllib
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]


def vendored_directories() -> set[Path]:
    """The package directories this repository copies rather than writes.

    Their invariants are upstream's to keep, and `pixi run vendored` checks
    that the copies are faithful. What is scanned below is this repository's
    own executable surface, and the boundary is read from the manifest so it
    cannot drift by editing a glob.
    """
    manifest = tomllib.loads((ROOT / "vendored.toml").read_text(encoding="utf-8"))
    return {ROOT / pkg["root"] / pkg["name"] for pkg in manifest.get("package", [])}


VENDORED = vendored_directories()


def own_sources(directory: str, pattern: str) -> list[Path]:
    return sorted(
        path
        for path in (ROOT / directory).rglob(pattern)
        if not any(parent in VENDORED for parent in path.parents)
    )


MOJO = own_sources("src", "*.mojo")
PYTHON = own_sources("tools", "*.py")

#: Rank-2 forbidden constructors. `docs/terminology-registry.md` allows these
#: words in prose about a higher layer, but not as identifiers in the
#: executable core.
FORBIDDEN_IDENTIFIERS = ("circle", "disk", "arc", "circumference", "polar_angle")

#: Analytic transcendental primitives. The finite core has no access to them.
FORBIDDEN_CALLS = ("math.sin", "math.cos", "math.atan", "math.exp", "math.log", "math.sqrt", "cmath")


@pytest.mark.parametrize("path", MOJO + PYTHON, ids=lambda p: p.name)
def test_no_forbidden_rank2_identifiers(path):
    text = path.read_text(encoding="utf-8")
    code = "\n".join(line for line in text.splitlines() if not line.strip().startswith(("#", '"""')))
    for word in FORBIDDEN_IDENTIFIERS:
        assert not re.search(rf"\b(def|fn|struct|var|alias)\s+\w*{word}\w*\b", code, re.IGNORECASE), (
            f"{path.name}: {word} is not a rank-2 constructor"
        )


@pytest.mark.parametrize("path", MOJO + PYTHON, ids=lambda p: p.name)
def test_no_analytic_transcendental_calls(path):
    text = path.read_text(encoding="utf-8")
    for call in FORBIDDEN_CALLS:
        assert call not in text, f"{path.name}: {call} is outside the finite core"


@pytest.mark.parametrize("path", PYTHON, ids=lambda p: p.name)
def test_no_float_arithmetic_in_the_reference_oracle(path):
    """Certificate-relevant numbers are exact rationals, never floats."""
    text = path.read_text(encoding="utf-8")
    assert "float(" not in text
    assert not re.search(r"\b\d+\.\d+\b", text), f"{path.name}: decimal literal"


def test_the_scan_covers_this_repository_and_not_its_copies():
    """The boundary is stated, not implied: every own source is scanned, and
    no vendored file is."""
    names = {path.name for path in MOJO + PYTHON}
    assert {"julia_orbit.mojo", "corpus_replay.mojo", "smoke_tests.mojo"} <= names
    assert {"julia_reference.py", "parameter_corpus.py", "gaussian_q.py"} <= names
    assert not names & {"rat_q.mojo", "bigint_z.mojo", "orbit.mojo", "report.mojo", "check_vendored_sync.py"}
    assert len(VENDORED) == 4
