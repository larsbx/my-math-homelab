"""Repository invariants that are cheap to state and expensive to lose."""

import re
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
MOJO = sorted((ROOT / "src").glob("*.mojo"))
PYTHON = sorted((ROOT / "tools").glob("*.py"))

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
