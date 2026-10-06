"""Repository invariants that are cheap to state and expensive to lose."""

import re
import tokenize
from pathlib import Path

import pytest
from vendoring.check_vendored_sync import vendored_directories

ROOT = Path(__file__).resolve().parents[1]


#: The package directories this repository copies rather than writes.
#: Their invariants are upstream's to keep, and `pixi run vendored` checks
#: that the copies are faithful. What is scanned below is this repository's
#: own executable surface, and the boundary is read from the manifest, by the
#: vendored checker that pins it, so it cannot drift by editing a glob.
VENDORED = {ROOT / directory for directory in vendored_directories(ROOT)}


def own_sources(directory: str, pattern: str) -> list[Path]:
    return sorted(
        path
        for path in (ROOT / directory).rglob(pattern)
        if not any(parent in VENDORED for parent in path.parents)
    )


MOJO = own_sources("kernel", "*.mojo")
PYTHON = [path for plane in ("reference", "oracles", "tools") for path in own_sources(plane, "*.py")]

#: Rank-2 forbidden constructors. `docs/terminology-registry.md` allows these
#: words in prose about a higher layer, but not as identifiers in the
#: executable core.
FORBIDDEN_IDENTIFIERS = ("circle", "disk", "arc", "circumference", "polar_angle")

#: Analytic transcendental primitives. The finite core has no access to them.
FORBIDDEN_CALLS = ("math.sin", "math.cos", "math.atan", "math.exp", "math.log", "math.sqrt", "cmath")


def declares(word: str, code: str) -> bool:
    """Does the code declare a name with `word` as one of its components?

    A component, not a substring: `search_radius` contains "arc" and is
    nobody's circle primitive. A scan that blocked it would be a gate people
    route around, which is worse than no gate.
    """
    return bool(re.search(rf"\b(def|fn|struct|var|alias)\s+(\w+_)?{word}(_\w+)?\b", code, re.IGNORECASE))


@pytest.mark.parametrize("path", MOJO + PYTHON, ids=lambda p: p.name)
def test_no_forbidden_rank2_identifiers(path):
    text = path.read_text(encoding="utf-8")
    code = "\n".join(line for line in text.splitlines() if not line.strip().startswith(("#", '"""')))
    for word in FORBIDDEN_IDENTIFIERS:
        assert not declares(word, code), f"{path.name}: {word} is not a rank-2 constructor"


def test_the_identifier_ban_is_about_components_not_substrings():
    """The ban is on building a circle, not on the letters. A name that merely
    contains one of the words -- `search`, which contains "arc" -- is not a
    rank-2 constructor, and a scan that blocked it would be a gate people
    route around."""
    assert not any(declares(word, "def search_radius(c):\n    pass\n") for word in FORBIDDEN_IDENTIFIERS)
    assert declares("circle", "def unit_circle(c):\n    pass\n")
    assert declares("arc", "fn arc_length(x):\n    pass\n")
    assert declares("disk", "var disk = 1\n")


@pytest.mark.parametrize("path", MOJO + PYTHON, ids=lambda p: p.name)
def test_no_analytic_transcendental_calls(path):
    text = path.read_text(encoding="utf-8")
    for call in FORBIDDEN_CALLS:
        assert call not in text, f"{path.name}: {call} is outside the finite core"


def code_tokens(path) -> tuple[list[str], list[str]]:
    """The numbers and names a Python file actually executes.

    Read with `tokenize` rather than as text, so that prose is prose: a
    docstring citing "section 2.4" is a citation, not a decimal literal, and
    a scan that cannot tell the difference forbids writing the citation down.
    """
    with path.open("rb") as handle:
        tokens = list(tokenize.tokenize(handle.readline))
    return (
        [token.string for token in tokens if token.type == tokenize.NUMBER],
        [token.string for token in tokens if token.type == tokenize.NAME],
    )


@pytest.mark.parametrize("path", PYTHON, ids=lambda p: p.name)
def test_no_float_arithmetic_in_the_reference_oracle(path):
    """Certificate-relevant numbers are exact rationals, never floats."""
    numbers, names = code_tokens(path)
    assert "float" not in names, f"{path.name}: float is outside the finite core"
    for number in numbers:
        assert "." not in number and "e" not in number.lower(), f"{path.name}: {number} is a float literal"


def test_the_float_scan_reads_code_and_not_prose(tmp_path):
    """Both directions, because the scan used to fail on its own citations."""
    prose = tmp_path / "prose.py"
    prose.write_text('"""See section 2.4 of the spec."""\nx = 3\n', encoding="utf-8")
    assert code_tokens(prose) == (["3"], ["x"])
    literal = tmp_path / "literal.py"
    literal.write_text("x = 2.4\ny = float(1)\n", encoding="utf-8")
    numbers, names = code_tokens(literal)
    assert "2.4" in numbers and "float" in names


def test_the_scan_covers_this_repository_and_not_its_copies():
    """The boundary is stated, not implied: every own source is scanned, and
    no vendored file is."""
    scanned = {path.relative_to(ROOT).as_posix() for path in MOJO + PYTHON}
    assert {"kernel/julia_orbit.mojo", "kernel/corpus_replay.mojo", "kernel/smoke_tests.mojo"} <= scanned
    assert {"reference/julia_reference.py", "reference/parameter_corpus.py", "reference/gaussian_q.py"} <= scanned
    # A vendored file and a file this repository writes can share a basename:
    # the reference-check policy is ours, the engine beside it is upstream's.
    assert "tools/check_references.py" in scanned
    assert not scanned & {
        "vendor/mojo/finite_exact/rat_q.mojo",
        "vendor/mojo/quadratic_orbit/orbit.mojo",
        "vendor/mojo/quadratic_orbit/preperiodic.mojo",
        "vendor/mojo/angle_doubling/angle.mojo",
        "vendor/mojo/projective/chart.mojo",
        "vendor/mojo/finite_linear_algebra/qpoly.mojo",
        "vendor/mojo/substitution_dynamics/tuning.mojo",
        "vendor/mojo/finite_graph/scc.mojo",
        "vendor/mojo/mojo_smoke/report.mojo",
        "vendor/python/vendoring/check_vendored_sync.py",
        "vendor/python/references/check_references.py",
    }
    assert {path.name for path in VENDORED} == {
        "finite_exact", "quadratic_orbit", "angle_doubling", "projective",
        "finite_linear_algebra", "substitution_dynamics", "finite_graph",
        "mojo_smoke", "vendoring", "references", "closed_interval",
        "exact_arithmetic_audit", "claim_governance", "polyglot_envelope",
    }
