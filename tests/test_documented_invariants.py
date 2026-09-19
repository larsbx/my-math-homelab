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
    scanned = {path.relative_to(ROOT).as_posix() for path in MOJO + PYTHON}
    assert {"src/julia_orbit.mojo", "src/corpus_replay.mojo", "src/smoke_tests.mojo"} <= scanned
    assert {"tools/julia_reference.py", "tools/parameter_corpus.py", "tools/gaussian_q.py"} <= scanned
    # A vendored file and a file this repository writes can share a basename:
    # the reference-check policy is ours, the engine beside it is upstream's.
    assert "tools/check_references.py" in scanned
    assert not scanned & {
        "src/finite_exact/rat_q.mojo",
        "src/quadratic_orbit/orbit.mojo",
        "src/mojo_smoke/report.mojo",
        "tools/vendoring/check_vendored_sync.py",
        "tools/references/check_references.py",
    }
    assert {path.name for path in VENDORED} == {
        "finite_exact", "quadratic_orbit", "mojo_smoke", "vendoring", "references",
    }
