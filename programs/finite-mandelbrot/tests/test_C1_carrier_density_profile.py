"""Conformance of the carrier density profile with docs/C1_separated_pair_density.md.

Round-two item R3: a density per level of a carrier's catalogue prefix, the
measure each refinement step decided, and the residue recorded as
non-increasing along the carrier order. The Mojo module is canonical and its
smoke case carries the arithmetic, including both identities on every prefix of
the sweep corpus; this suite asserts the constants it pins and the discipline
the module must keep -- above all that a level's separator is declared, never
derived from the level's own address.
"""

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))


DOC = ROOT / "docs" / "C1_separated_pair_density.md"
SRC = ROOT / "kernel/mojo/c1/carrier/carrier_density_profile.mojo"
DENSITY_SRC = ROOT / "kernel/mojo/c1/separator/separated_density.mojo"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


# --- the Mojo smoke case ---------------------------------------------------------


def test_the_mojo_case_passes(mojo_smoke):
    assert mojo_smoke.case_passed("carrier density profile")


def test_both_identities_are_checked_on_every_sweep_prefix():
    """carrier_density_profile refuses a profile whose residue rises or whose
    increments miss the density, so the smoke requiring every sweep prefix to be
    accepted checks both identities on the real kernel."""
    src = text(SRC)
    assert "def sweep_profiles_accepted() -> Bool:" in src
    smoke = src[src.index("def carrier_density_profile_smoke"):]
    assert "if not sweep_profiles_accepted():" in smoke


# --- what the module may not do -------------------------------------------------


def test_the_separator_of_a_level_is_declared_not_derived():
    """The correction to N3: a separator needs a declared co-landing pair, so
    the module takes one per level and never builds one from the address."""
    src = text(SRC)
    start = src.index("def carrier_density_profile(")
    signature = src[start:src.index(") -> CarrierDensityProfile:", start)]
    for argument in ("level_nums", "level_dens", "lefts_n", "lefts_d", "rights_n", "rights_d",
                     "tags", "co_landings"):
        assert argument in signature
    assert "separator declared for each level is a separate input" in src
    assert "vacuous construction" in src
    assert "docs/C1_admissible_separator_codes.md" in src


def test_the_declared_separator_must_also_be_admissible():
    """Declaring a pair is not enough: two arbitrary rational angles are a cut,
    and measuring one would report an unproved separation as a decided one."""
    src = text(SRC)
    gate = src[src.index("def admissible_separator("):src.index("def _prefix(")]
    assert "if not co_landing:" in gate
    for tag in ("LANDING_RATIONAL_RAY", "LANDING_PARABOLIC", "LANDING_HYPERBOLIC_BOUNDARY"):
        assert tag in gate
    assert "return ln * rd != rn * ld" in gate
    body = src[src.index("def carrier_density_profile("):src.index("# --- non-claims")]
    assert "if not admissible_separator(" in body


def test_the_admissibility_codes_are_the_spec_codes():
    for name, code in (("LANDING_RATIONAL_RAY", 1), ("LANDING_PARABOLIC", 2),
                       ("LANDING_HYPERBOLIC_BOUNDARY", 3)):
        assert f"comptime {name}: Int64 = {code}" in text(SRC)


def test_the_mojo_smoke_exercises_the_gate_in_both_directions():
    """A gate that refused everything would pass every rejection case above."""
    src = text(SRC)
    assert "var generic: List[Int64] = [0]" in src and "var mlc: List[Int64] = [4]" in src
    assert "var undeclared: List[Bool] = [False]" in src
    assert "_is(admitted.levels[0].density, 4, 9)" in src


def test_non_claims_return_false_in_mojo():
    src = text(SRC)
    for name in ("profile_decides_carrier_membership", "residue_zero_at_some_level_is_reachable",
                 "density_increment_measures_carrier_progress"):
        block = src[src.index(f"def {name}() -> Bool:"):]
        assert "return False" in block.split("\n\n")[0]


def test_exact_arithmetic_only():
    src = text(SRC)
    assert "from finite_exact.rat_q import Q" in src
    assert not re.search(r"\bFloat(?:16|32|64|Literal)?\b", src)
    assert not re.search(r"(?<![\w.])\d+\.\d", src)
    assert "docs/rational-interval-arithmetic-spec.md" in src


def test_the_module_fails_closed_rather_than_returning_an_empty_profile():
    src = text(SRC)
    assert src.count("return rejected_profile()") >= 8
    assert "def rejected_profile()" in src
    body = src[src.index("def carrier_density_profile("):src.index("# --- non-claims")]
    for guard in ("if not here.accepted():", "decided.lt(Q.zero())", "previous_residue.lt(here.residue)",
                  "not total_decided.eq(previous_density)"):
        assert guard in body


def test_the_kernel_is_the_one_the_density_note_governs():
    assert "from c1.separator.separated_density import" in text(SRC)
    assert "separated_pair_density" in text(SRC) and "def separated_pair_density(" in text(DENSITY_SRC)


# --- governance -----------------------------------------------------------------


def test_the_regime_correspondence_binds_the_profile_symbol():
    spec = tomllib.loads(text(ROOT / "schemas/regime_correspondences.toml"))
    entry = next(c for c in spec["correspondence"] if c["id"] == "separated-pair-density")
    assert "kernel/mojo/c1/carrier/carrier_density_profile.mojo::carrier_density_profile" in entry["symbols"]
    assert "any verdict on the carrier whose levels order the prefix" in entry["does_not_inherit"]
    assert text(SRC).count("# Regime correspondence: separated-pair-density") == 1


def test_the_note_records_the_step_as_taken():
    body = text(DOC)
    assert "kernel/mojo/c1/carrier/carrier_density_profile.mojo" in body
    assert "Next step" in body


def test_mojo_smoke_pins_the_same_constants():
    src = text(SRC)
    for fragment in ("_is(basilica.levels[0].density, 4, 9)", "_is(refined.levels[1].density, 262, 441)",
                     "_is(refined.levels[1].decided, 22, 147)", "_is(deeper.levels[2].decided, 8, 147)",
                     "refined.residue_non_increasing"):
        assert fragment in src
    assert "carrier_density_profile_smoke" in text(ROOT / "kernel/mojo/smoke/smoke_tests.mojo")
