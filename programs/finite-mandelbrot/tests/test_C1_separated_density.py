"""Conformance of the separated-pair density with docs/C1_separated_pair_density.md."""

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))


DOC = ROOT / "docs" / "C1_separated_pair_density.md"
SRC = ROOT / "kernel/mojo/c1/separator/separated_density.mojo"
LEDGER_DOC = ROOT / "docs" / "C1_theorem_tag_import_ledger.md"
LEDGER_SRC = ROOT / "kernel/mojo/c1/theorem_tags/theorem_tag_import_ledger.mojo"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


# --- documentation and governance ----------------------------------------------


def test_density_term_is_declared_with_genealogy_and_leaks():
    body = text(DOC)
    assert body.splitlines()[2].startswith("Status:")
    assert "Terminology declaration: separated-pair density" in body
    for field in ("Genealogy:", "Bridge claim:", "Known leaks:", "Use discipline:"):
        assert field in body
    assert "definition-only" in body
    assert "separated-pair density" in text(ROOT / "docs" / "terminology-registry.md")


def test_non_claims_return_false_in_mojo():
    src = text(SRC)
    for name in ("density_one_implies_every_pair_separated", "finite_prefix_density_decides_persistent_non_separation",
                 "density_is_harmonic_measure_of_the_boundary"):
        block = src[src.index(f"def {name}() -> Bool:"):]
        assert "return False" in block.split("\n\n")[0]
    # Exact arithmetic only: the unbounded rational type, no float type or literal.
    assert "from finite_exact.rat_q import Q" in src
    assert not re.search(r"\bFloat(?:16|32|64|Literal)?\b", src)
    assert not re.search(r"(?<![\w.])\d+\.\d", src)
    assert "docs/rational-interval-arithmetic-spec.md" in src


def test_harmonic_measure_tag_is_class_specific_scaffolded_and_cannot_discharge_a_pair():
    src = text(LEDGER_SRC)
    block = src[src.index("def harmonic_measure_fibre_triviality_tag_ready"):src.index("def generic_mlc_import_admissible")]
    assert "ImportConclusionKind.harmonic_measure_fibre_triviality()" in block
    assert "ImportStrengthClass.classical_class_specific()" in block and "ImportStatus.scaffolded()" in block
    assert "def harmonic_measure_tag_discharges_a_named_pair() -> Bool:" in src
    assert "return False" in block[block.index("def harmonic_measure_tag_discharges_a_named_pair"):]
    doc = text(LEDGER_DOC)
    section = doc[doc.index("### Harmonic-measure-almost-every fibre triviality"):doc.index("## Forbidden imports")]
    for field in ("theorem_source", "measure_declared", "exceptional_set_is_null_not_empty",
                  "parameter_not_selected_from_the_exceptional_set", "adapter_domain_matches", "conclusion_scope"):
        assert field in section
    assert "may not discharge" in section and "not a residual exit" in section
    assert "Graczyk" in section and "Smirnov" in section


def test_regime_correspondence_binds_the_density_symbol():
    spec = tomllib.loads(text(ROOT / "schemas/regime_correspondences.toml"))
    entry = next(c for c in spec["correspondence"] if c["id"] == "separated-pair-density")
    assert "harmonic measure on the boundary" in entry["does_not_inherit"]
    assert "separation of a named pair" in entry["does_not_inherit"]
    # The kernel and the carrier profile of docs/C1_separated_pair_density.md
    # share this correspondence; each symbol is tagged in its own file.
    assert "kernel/mojo/c1/separator/separated_density.mojo::separated_pair_density" in entry["symbols"]
    for symbol in entry["symbols"]:
        path, name = symbol.split("::")
        source = text(ROOT / path)
        assert f"def {name}(" in source
        assert source.count("# Regime correspondence: separated-pair-density") == sum(
            s.startswith(path + "::") for s in entry["symbols"])


# --- the Mojo smoke case ----------------------------------------------------------


def test_the_mojo_case_passes(mojo_smoke):
    assert mojo_smoke.case_passed("separated density")


def test_the_refinement_laws_run_on_the_kernel():
    """density = 1 - residue, 0 <= density <= 1 - 1/classes, and refinement never
    lowers the density, on every prefix of up to three eighth-separators."""
    src = text(SRC)
    assert "def refinement_laws_hold() -> Bool:" in src
    assert "if not refinement_laws_hold():" in src[src.index("def separated_density_smoke"):]


def test_mojo_smoke_pins_the_same_instances():
    src = text(SRC)
    for fragment in ('_is(single, 4, 9)', '_is(disjoint, 5, 8)', '_is(nested, 4, 7)', '_is(refined, 2, 3)',
                     'disjoint.atoms == 4 and disjoint.classes == 3', 'disjoint.density.lt(Q(3, 4))'):
        assert fragment in src
    assert "separated_density_smoke" in text(ROOT / "kernel/mojo/smoke/smoke_tests.mojo")
