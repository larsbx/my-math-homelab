"""The Mojo dataset emitter, checked object by object against the oracles.

`kernel/mojo/entrypoints/atlas_dataset.mojo` is the one place the exact objects leave this
repository: the counts and catalogues, the kneading sequences and internal
addresses, the tuned angles, the obstruction extractions with their pairs, the
decided measures, and the finite incidence packages. Mojo computes them; the
Python references here are independent implementations, so agreeing with them
is evidence rather than an echo.

Positions in the parameter plane are deliberately absent. They are floating
point, and nothing in `kernel/` may produce one.
"""

from __future__ import annotations

import json
import subprocess
import sys
from fractions import Fraction
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from mojo_include import mojo_run  # noqa: E402

from reference.python.c1 import kneading_reference as kr  # noqa: E402
from reference.python.c1 import misiurewicz_catalogue_reference as mc  # noqa: E402
from reference.python.c1 import misiurewicz_prefix_graph_reference as pg  # noqa: E402

SRC = ROOT / "kernel/mojo/entrypoints/atlas_dataset.mojo"


@pytest.fixture(scope="module")
def dataset() -> dict:
    result = subprocess.run(mojo_run(str(SRC.relative_to(ROOT))), cwd=ROOT, capture_output=True, text=True, check=False)
    assert result.returncode == 0, result.stdout + result.stderr
    return json.loads(result.stdout)


def test_the_emitter_prints_every_section(dataset):
    assert set(dataset) == {"counts", "catalogues", "kneading", "tunings",
                            "graphs", "density", "incidence"}
    assert all(dataset[section] for section in dataset)


def test_no_section_carries_a_floating_point_number(dataset):
    """The exact half of the atlas is exact. A float in the output would be a
    leak, and it is the output that decides it: whether the source mentions
    floats is the business of the arithmetic audit, not of this test."""
    def scan(node, where):
        if isinstance(node, float):
            raise AssertionError(f"a float reached the dataset at {where}: {node}")
        if isinstance(node, dict):
            for key, value in node.items():
                scan(value, f"{where}.{key}")
        if isinstance(node, list):
            for i, value in enumerate(node):
                scan(value, f"{where}[{i}]")
    scan(dataset, "dataset")


def test_counts_are_the_identity_and_the_enumeration(dataset):
    for row in dataset["counts"]:
        l, k = row["l"], row["k"]
        assert row["den"] == mc.catalogue_denominator(l, k)
        assert row["count"] == mc.catalogue_count(l, k)
        assert row["enumerated"] == len(mc.catalogue(l, k)) == row["count"]


def test_catalogue_addresses_are_the_reference_addresses(dataset):
    for row in dataset["catalogues"]:
        assert row["addresses"] == mc.catalogue(row["l"], row["k"])


def test_kneading_sequences_and_internal_addresses(dataset):
    for row in dataset["kneading"]:
        theta = Fraction(*row["theta"])
        nu = kr.kneading_prefix(theta)
        assert "".join(map(str, nu)) + "*" == row["nu"]
        last = kr.continuation_last_letter(nu)
        assert row["twist"] == (None if last is None else last == 0)
        address = kr.internal_address(nu + [last]) if last is not None else kr.internal_address(nu)
        assert row["address"] == address
        assert row["block"] == kr.binary_block(theta, len(row["block"]))
    named = {tuple(r["theta"]): (r["nu"], tuple(r["address"])) for r in dataset["kneading"]}
    assert named[(1, 3)] == ("1*", (1, 2))        # basilica
    assert named[(1, 7)] == ("11*", (1, 3))       # rabbit
    assert named[(3, 7)] == ("10*", (1, 2, 3))    # airplane


def test_tuned_angles_match_the_exact_oracle(dataset):
    for row in dataset["tunings"]:
        tuned = kr.tune_angle(Fraction(*row["lo"]), Fraction(*row["hi"]), Fraction(*row["theta"]))
        assert row["tuned"] == [tuned.numerator, tuned.denominator]
        assert row["period"] == kr.period(tuned)


def test_extractions_agree_down_to_the_individual_pairs(dataset):
    for row in dataset["graphs"]:
        den, l, k = row["den"], row["l"], row["k"]
        prefix = pg.period_pair_prefix(row["prefix_period"], den)
        assert [list(s[:2]) for s in prefix] == row["separators"]
        found = pg.extract_catalogue(l, k, prefix)
        assert (found.vertices, found.undecided, found.nonproductive, found.merging,
                len(found.boundary), len(found.interior)) == (
            row["n_vertices"], row["undecided"], row["nonproductive"], row["merging"],
            row["boundary"], row["interior"])
        assert row["obstruction_free"] is found.obstruction_free
        vertices = pg.forward_closure(mc.catalogue(l, k), den)
        assert row["vertices"] == vertices
        assert sorted(map(tuple, row["nonproductive_pairs"])) == sorted(
            pg.nonproductive(vertices, prefix, den))
        assert sorted(map(tuple, row["cycle_pairs"])) == sorted(
            pair for cycle in found.boundary + found.interior for pair in cycle)


def test_the_pinned_extraction_is_still_the_pinned_one(dataset):
    row = next(r for r in dataset["graphs"] if (r["l"], r["k"]) == (1, 3))
    assert (row["den"], row["n_vertices"], row["undecided"], row["nonproductive"]) == (14, 12, 37, 20)
    assert (row["merging"], row["boundary"], row["interior"]) == (2, 2, 0)
    assert row["obstruction_free"] is False


def test_densities_are_the_exact_rationals(dataset):
    """The five prefixes the emitter prints, with the densities, residues and
    class counts the separated-density smoke case pins: basilica alone, two
    disjoint separators (5/8, not the flattened 3/4), the nested rabbit pair, a
    refinement of the basilica, and a repeated separator that refines nothing."""
    rows = [(r["density"], r["residue"], r["classes"], r["atoms"]) for r in dataset["density"]]
    assert rows == [("4/9", "5/9", 2, 2), ("5/8", "3/8", 3, 4), ("4/7", "3/7", 3, 3),
                    ("2/3", "1/3", 3, 3), ("4/9", "5/9", 2, 2)]


def test_incidence_packages_a_point_as_three_vertices(dataset):
    wide = next(r for r in dataset["incidence"] if r["half_width_den_power"] == 0)
    narrow = [r for r in dataset["incidence"] if r["half_width_den_power"] > 0]
    for row in narrow:
        assert row["krawczyk"] is True
        assert row["excluded"] == row["required"] == 5
        assert row["finite_replay"] is True and row["packaged"] is True
        assert [m["role"] for m in row["carrier"]] == ["RootHandle", "RayAddressSet", "RationalBox"]
        assert row["carrier_size"] == 3 and row["incidence_only"] is True and row["vertex_valid"] is True
        assert row["ell"] == row["ray_preperiod"] + row["preperiod_offset"] == 2
        assert row["period"] == row["ray_period"] == 1
    # Too wide a box decides nothing, and says so rather than packaging anyway.
    assert wide["krawczyk"] is False and wide["excluded"] < wide["required"]
    assert wide["ambiguous"] is True and wide["packaged"] is False


def test_the_non_claims_survive_the_emitter(dataset):
    """A valid incidence package is not an accepted certificate, and neither is
    a proof of C1. The dataset must carry those refusals, not hide them."""
    for row in dataset["incidence"]:
        assert row["certificate_emitted"] is False
        assert row["theorem_import"] is False
        assert row["proves_c1"] is False
