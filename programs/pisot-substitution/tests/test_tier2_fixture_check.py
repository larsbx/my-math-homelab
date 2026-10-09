"""Dimension semantics of Tier 2 loop-gain fixtures (tools/check_tier2_fixture.py)."""

import copy
import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))

from check_tier2_fixture import CHANNELS, SCHEMA, dimension_errors, main  # noqa: E402

CUBIC = {
    "schema_version": "tier2-loop-gain-v1",
    "component_id": "c0",
    "gain_channel": "affine_forcing",
    "loop_composition": "beta_twisted",
    "vertices": ["s0", "s1"],
    "edges": [
        {"edge_id": "e0", "source": "s0", "target": "s1", "occurrence_ordinal": 0, "gain_coordinates": [1, 0, -1]},
        {"edge_id": "e1", "source": "s1", "target": "s0", "occurrence_ordinal": 0, "gain_coordinates": [0, 2, 0]},
    ],
    "arithmetic_basis": {
        "kind": "integer_power_basis",
        "labels": ["1", "beta", "beta^2"],
        "minimal_polynomial": [-1, -1, 0, 1],
    },
    "generated_module_generators": [[1, 2, -1]],
}

PENROSE = {
    "schema_version": "tier2-loop-gain-v1",
    "component_id": "H_tail/EQ",
    "gain_channel": "penrose_phi_increment",
    "loop_composition": "additive",
    "vertices": ["E_short", "E_minus", "E_plus"],
    "edges": [
        {"edge_id": "e0", "source": "E_short", "target": "E_minus", "occurrence_ordinal": 0, "gain_coordinates": [1, 0]},
        {"edge_id": "e1", "source": "E_minus", "target": "E_plus", "occurrence_ordinal": 0, "gain_coordinates": [1, 0]},
        {"edge_id": "e2", "source": "E_plus", "target": "E_short", "occurrence_ordinal": 0, "gain_coordinates": [2, -1]},
    ],
    "arithmetic_basis": {"kind": "integer_lattice_basis", "labels": ["1", "phi"]},
}


def mutated(doc, edit):
    out = copy.deepcopy(doc)
    edit(out)
    return out


@pytest.mark.parametrize("doc", [CUBIC, PENROSE])
def test_well_formed_fixtures_pass(doc):
    assert dimension_errors(doc) == ()


@pytest.mark.parametrize(
    "doc",
    [
        # an empty component is invalid evidence, not a trivial module
        mutated(CUBIC, lambda d: d.update(edges=[])),
        mutated(PENROSE, lambda d: d.update(vertices=[], edges=[])),
        # the review's counterexample: cubic basis, one coordinate
        mutated(CUBIC, lambda d: d["edges"][0].update(gain_coordinates=[1])),
        mutated(CUBIC, lambda d: d["generated_module_generators"].append([1, 2])),
        mutated(PENROSE, lambda d: d["edges"][2].update(gain_coordinates=[4, -1, 0])),
        # affine_forcing is pinned to the three-element power basis
        mutated(CUBIC, lambda d: d["arithmetic_basis"].update(labels=["1", "beta"])),
        mutated(CUBIC, lambda d: d["arithmetic_basis"].update(kind="integer_lattice_basis")),
        # power basis rank must equal the degree of a monic minimal polynomial
        mutated(CUBIC, lambda d: d["arithmetic_basis"].pop("minimal_polynomial")),
        mutated(CUBIC, lambda d: d["arithmetic_basis"].update(minimal_polynomial=[-1, 1, 1])),
        mutated(CUBIC, lambda d: d["arithmetic_basis"].update(minimal_polynomial=[-1, -1, 0, 2])),
        mutated(PENROSE, lambda d: d["arithmetic_basis"].update(labels=["1", "1"])),
        # affine_forcing composes affinely; a plain-sum reading is refused
        mutated(CUBIC, lambda d: d.update(loop_composition="additive")),
        # a twist is multiplication by the generator, so it needs a power basis
        mutated(PENROSE, lambda d: d.update(loop_composition="beta_twisted")),
    ],
)
def test_dimension_mismatches_fail_closed(doc):
    assert dimension_errors(doc) != ()


def test_schema_rejects_an_empty_component():
    props = json.loads(Path(SCHEMA).read_text())["properties"]
    assert props["vertices"]["minItems"] == props["edges"]["minItems"] == 1


def test_schema_pins_the_same_channel_ranks():
    schema = json.loads(Path(SCHEMA).read_text())
    pinned = {
        rule["if"]["properties"]["gain_channel"]["const"]: rule["then"]
        for rule in schema["allOf"]
    }
    assert set(pinned) == set(CHANNELS)
    for channel, (rank, composition) in CHANNELS.items():
        then = pinned[channel]["properties"]
        assert then["loop_composition"]["const"] == composition
        basis = then["arithmetic_basis"]["properties"]
        coords = then["edges"]["items"]["properties"]["gain_coordinates"]
        gens = then["generated_module_generators"]["items"]
        assert basis["kind"]["const"] == "integer_power_basis"
        assert basis["labels"]["minItems"] == basis["labels"]["maxItems"] == rank
        assert basis["minimal_polynomial"]["minItems"] == basis["minimal_polynomial"]["maxItems"] == rank + 1
        assert coords["minItems"] == coords["maxItems"] == rank
        assert gens["minItems"] == gens["maxItems"] == rank


def test_checker_refuses_an_empty_invocation():
    assert main([]) == 2
