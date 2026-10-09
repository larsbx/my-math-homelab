"""Conformance of the exact-type catalogue with docs/C1_misiurewicz_catalogue.md."""

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))


DOC = ROOT / "docs" / "C1_misiurewicz_catalogue.md"
SRC = ROOT / "kernel/mojo/certificates/misiurewicz_catalogue.mojo"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


# --- documentation and governance ----------------------------------------------


def test_catalogue_term_is_declared_with_genealogy_and_leaks():
    body = text(DOC)
    assert body.splitlines()[2].startswith("Status:")
    assert "Terminology declaration: exact-type catalogue" in body
    for field in ("Genealogy:", "Bridge claim:", "Known leaks:", "Use discipline:"):
        assert field in body
    assert "definition-only" in body
    assert "exact-type catalogue" in text(ROOT / "docs" / "terminology-registry.md")


def test_non_claims_return_false_in_mojo():
    src = text(SRC)
    for name in ("catalogue_is_a_set_of_parameters", "catalogue_proves_fibre_triviality"):
        block = src[src.index(f"def {name}() -> Bool:"):]
        assert "return False" in block.split("\n\n")[0]
    assert not re.search(r"\bFloat(?:16|32|64|Literal)?\b", src)
    assert not re.search(r"(?<![\w.])\d+\.\d", src)


def test_regime_correspondence_binds_the_catalogue_symbols():
    spec = tomllib.loads(text(ROOT / "schemas/regime_correspondences.toml"))
    entry = next(c for c in spec["correspondence"] if c["id"] == "misiurewicz-exact-type")
    assert "parameter location" in entry["does_not_inherit"]
    assert "fibre triviality" in entry["does_not_inherit"]
    for symbol in entry["symbols"]:
        path, name = symbol.split("::")
        assert path == "kernel/mojo/certificates/misiurewicz_catalogue.mojo" and f"def {name}(" in text(SRC)
    assert text(SRC).count("# Regime correspondence: misiurewicz-exact-type") == len(entry["symbols"])


# --- the reference model --------------------------------------------------------


def test_the_smoke_checks_the_type_against_iterating_the_doubling_map():
    """The independent check: Mojo reads the type off the 2-adic valuation and
    the multiplicative order of 2; the smoke recomputes it from the orbit itself
    for every address with denominator below 120."""
    src = text(SRC)
    assert "def type_agrees_with_doubling(max_den: Int) -> Bool:" in src
    assert "if not type_agrees_with_doubling(120):" in src[src.index("def misiurewicz_catalogue_smoke"):]


def test_the_catalogue_denominator_is_the_vendored_type_count():
    """`2^l (2^k - 1)` is the vendored angle_doubling `type_count`."""
    src = text(SRC)
    assert "from angle_doubling.angle import type_count" in src
    assert "var den = Int(type_count(preperiod, period))" in src
    angle = text(ROOT / "vendor/mojo/angle_doubling/angle.mojo")
    assert "def type_count(l: Int, k: Int) -> Int64:" in angle
    assert "return (Int64(1) << Int64(l)) * ((Int64(1) << Int64(k)) - 1)" in angle


def test_the_type_and_the_count_are_the_vendored_uncapped_ones():
    """The type is the vendored rational_dynamics `exact_type` and the count its
    `exact_type_count`, both exact over BigZ with no cap on the order (the
    fixed-width angle_doubling refuses periods past 64, while `exact_type`
    reads every period up to its denominator bound: the smoke's `1/107`, of
    period 106, among them). Only the two bounds, this repository's data
    policy, and the conversion back to machine `Int` stay local."""
    src = text(SRC)
    assert "from rational_dynamics.doubling import exact_type as doubling_type" in src
    assert "from rational_dynamics.doubling import exact_type_count" in src
    assert "from rational_dynamics.integers import bigz_to_int" in src
    assert "from rational_dynamics.moebius import moebius" in src
    assert "def moebius(" not in src and "gcd_int" not in src
    doubling = text(ROOT / "vendor/mojo/rational_dynamics/doubling.mojo")
    order = text(ROOT / "vendor/mojo/rational_dynamics/multiplicative_order.mojo")
    assert "def order_of_two(modulus: BigZ) -> BigZResult:" in order
    assert "def exact_type_count(l: Int, k: Int) -> BigZResult:" in doubling
    assert "order_limit" not in doubling + order


def test_the_mojo_catalogue_case_passes(mojo_smoke):
    """The Mojo catalogue is checked by running it, not by reading its source.

    `misiurewicz_catalogue_smoke` pins the four catalogues, the counting
    identity against the enumeration, the type against brute-force doubling,
    the two bounds, and the non-claims."""
    assert mojo_smoke.returncode == 0, mojo_smoke.output
    assert mojo_smoke.case_passed("Misiurewicz exact-type catalogue")
    assert not mojo_smoke.failed, mojo_smoke.failed


def test_the_smoke_suite_names_every_case_it_runs(mojo_smoke):
    """A bare FAIL would not say which contract broke, so the suite names each
    case and keeps going after one fails."""
    assert mojo_smoke.total >= 50
    assert len(set(mojo_smoke.passed)) == len(mojo_smoke.passed)
    assert f"{mojo_smoke.total} cases, all passed." in mojo_smoke.output
