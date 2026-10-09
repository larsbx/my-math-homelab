"""The structure crosswalk: where the estate's code and data coincide with the atlas.

`schemas/structure_crosswalk.toml` names, for each atlas structure, the places
in this repository and its sibling repositories where the same exact datum
appears: a root angle pair in a fixture, a centre in a certificate, a
catalogue type that contains a Misiurewicz angle. Each claimed datum is checked
against the atlas entry, and each anchor against the file it names (sibling
files only where a checkout of that repository sits beside this one).
`docs/structure_crosswalk.json` is the generated surface a consumer such as
`larsbx/math-vizops` reads; it must be current and float-free.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from reference.python.atlas import structure_crosswalk_reference as cw  # noqa: E402

ATLAS = cw.atlas_by_id()
TABLE = cw.load()
OCCURRENCES = TABLE["occurrence"]


@pytest.mark.parametrize("occ", OCCURRENCES, ids=[o["id"] for o in OCCURRENCES])
def test_occurrence_datum_agrees_with_the_atlas(occ: dict) -> None:
    assert cw.datum_errors(occ, ATLAS) == []


@pytest.mark.parametrize("occ", [o for o in OCCURRENCES if o["repo"] == cw.REPOSITORY], ids=lambda o: o["id"])
def test_local_anchor_is_in_the_named_file(occ: dict) -> None:
    assert cw.anchor_errors(occ, cw.checkout(occ["repo"])) == []


@pytest.mark.parametrize("occ", [o for o in OCCURRENCES if o["repo"] != cw.REPOSITORY], ids=lambda o: o["id"])
def test_sibling_anchor_is_in_the_named_file(occ: dict) -> None:
    root = cw.checkout(occ["repo"])
    if root is None:
        pytest.skip(f"no checkout of {occ['repo']} beside this repository")
    assert cw.anchor_errors(occ, root) == []


def test_vocabulary_is_declared_and_used_as_declared() -> None:
    assert cw.table_errors(TABLE, ATLAS) == []


def test_every_atlas_instance_has_a_node_and_ids_never_collide() -> None:
    graph = cw.build(TABLE, ATLAS)
    ids = [n["id"] for n in graph["nodes"]]
    assert len(ids) == len(set(ids))
    assert set(ATLAS) <= set(ids)


def test_derived_atlas_edges() -> None:
    edges = {(e["source"], e["relation"], e["target"]) for e in cw.build(TABLE, ATLAS)["edges"]}
    assert ("bulb-1/3", "satellite-of", "main-cardioid") in edges
    assert ("bulb-1/2.1/2", "satellite-of", "bulb-1/2") in edges
    assert ("douady-rabbit", "julia-set-of", "bulb-1/3") in edges
    assert ("feigenbaum-cascade", "generated-by", "bulb-1/2") in edges
    assert ("seahorse-valley", "region-at", "bulb-1/2") in edges
    assert ("c-i", "in-limb-of", "bulb-1/3") in edges
    assert ("golden-mean-siegel", "boundary-of", "main-cardioid") in edges
    assert ("bulb-2/3", "conjugate-of", "bulb-1/3") in edges
    assert ("co-rabbit", "conjugate-of", "douady-rabbit") in edges
    assert ("scepter-valley", "tuning-image-of", "seahorse-valley") in edges
    assert ("double-spiral-valley", "tuning-image-of", "elephant-valley") in edges


def test_every_atlas_instance_meets_the_code() -> None:
    """Each named structure other than a class name has at least one occurrence."""
    met = {a for o in OCCURRENCES for a in o["atlas"]}
    assert {i for i, e in ATLAS.items() if e["kind"] != "class"} <= met


def test_accumulation_datum_is_compared_exactly() -> None:
    occ = _occ(atlas=["scepter-valley"], datum={"accumulation": {"parent": "bulb-1/2", "rotation": "2/4"}})
    assert cw.datum_errors(occ, ATLAS) == []
    assert cw.datum_errors({**occ, "datum": {"accumulation": {"parent": "main-cardioid", "rotation": "1/2"}}}, ATLAS) != []


# Negative controls: the checks must refuse what is wrong.

def _occ(**fields) -> dict:
    base = {"id": "probe", "atlas": ["bulb-1/3"], "repo": cw.REPOSITORY, "path": "schemas/structure_names.toml",
            "anchor": 'root_angles = ["1/7", "2/7"]', "relation": "same-datum", "plane": "schema",
            "exactness": "exact", "datum": {"root_angles": ["1/7", "2/7"]}}
    return {**base, **fields}


def test_controls_accept_the_probe() -> None:
    assert cw.datum_errors(_occ(), ATLAS) == []
    assert cw.anchor_errors(_occ(), ROOT) == []


@pytest.mark.parametrize(
    "fields",
    [
        {"datum": {"root_angles": ["1/7", "3/7"]}},
        {"datum": {"root_angles": ["2/14", "4/14", "5/7"]}},
        {"datum": {"root_parameter": "-3/4"}},
        {"datum": {"center": "-1"}},
        {"datum": {"no_such_field": "1"}},
        {"atlas": ["no-such-structure"]},
    ],
)
def test_wrong_datum_is_refused(fields: dict) -> None:
    assert cw.datum_errors(_occ(**fields), ATLAS) != []


def test_rational_forms_are_normalized_and_centres_are_checked_on_their_polynomial() -> None:
    assert cw.datum_errors(_occ(datum={"root_angles": ["2/14"]}), ATLAS) == []
    assert cw.datum_errors(_occ(atlas=["bulb-1/2"], datum={"center": "-1", "root_parameter": "-6/8"}), ATLAS) == []
    assert cw.datum_errors(_occ(atlas=["airplane-component"], datum={"center": "-7/4"}), ATLAS) != []


@pytest.mark.parametrize("fields", [{"anchor": "no such text anywhere"}, {"path": "no/such/file.toml"}])
def test_missing_anchor_is_refused(fields: dict) -> None:
    assert cw.anchor_errors(_occ(**fields), ROOT) != []


def test_unknown_relation_plane_or_exactness_is_refused() -> None:
    for field, value in (("relation", "resembles"), ("plane", "folklore"), ("exactness", "approximate")):
        assert cw.table_errors({**TABLE, "occurrence": [_occ(**{field: value})]}, ATLAS) != []


# The generated surface.

def test_generated_surface_is_current() -> None:
    result = subprocess.run([sys.executable, "tools/make_structure_crosswalk.py", "--check"],
                            cwd=ROOT, capture_output=True, text=True, check=False)
    assert result.returncode == 0, result.stdout + result.stderr


def test_surface_declares_its_vocabulary_and_carries_no_float() -> None:
    surface = json.loads((ROOT / cw.SURFACE).read_text(encoding="utf-8"), parse_float=lambda s: pytest.fail(s))
    assert surface["format"] == cw.FORMAT
    classes = {c["id"] for c in surface["classes"]}
    relations = {r["id"] for r in surface["relations"]}
    assert {n["class"] for n in surface["nodes"]} <= classes
    assert {e["relation"] for e in surface["edges"]} <= relations
    nodes = {n["id"] for n in surface["nodes"]}
    assert all(e["source"] in nodes and e["target"] in nodes for e in surface["edges"])


# Emitted sections: the datum must be in what the emitter actually prints.

EMITTERS = {
    "atlas-dataset": "kernel/mojo/entrypoints/atlas_dataset.mojo",
    "structure-streams": "kernel/mojo/entrypoints/structure_streams.mojo",
}
EMITTING = [o for o in OCCURRENCES if "emits" in o]


@pytest.fixture(scope="module")
def outputs() -> dict:
    sys.path.insert(0, str(ROOT / "tools"))
    from mojo_include import mojo_run

    found = {}
    for name, entry in EMITTERS.items():
        result = subprocess.run(mojo_run(entry), cwd=ROOT, capture_output=True, text=True, check=False)
        assert result.returncode == 0, result.stdout + result.stderr
        found[name] = json.loads(result.stdout)
    return found


@pytest.mark.parametrize("occ", EMITTING, ids=lambda o: o["id"])
def test_emitted_datum_is_in_the_emitter_output(outputs: dict, occ: dict) -> None:
    assert cw.emitted_errors(occ, outputs) == []


def test_every_emitted_section_is_checked() -> None:
    assert EMITTING and all(o["emits"] in cw.EMITTED for o in EMITTING)


@pytest.mark.parametrize(
    "occ_id, datum",
    [
        ("fmr-emitter-tuning-rabbit", {"root_angles": ["1/7", "3/7"]}),
        ("fmr-emitter-kneading-bulb-1/3", {"root_angles": ["1/7", "2/7"], "internal_address": [1, 4]}),
        ("fmr-emitter-catalogue-m41", {"angles": ["9/56", "1/6"], "angle_type": [3, 3]}),
        ("fmr-streams-scepter-valley", {"accumulation": {"parent": "main-cardioid", "rotation": "1/2"}}),
        ("fmr-streams-golden-mean", {"convergents": ["1/2", "3/4"]}),
    ],
)
def test_emitted_check_refuses_a_datum_the_output_does_not_carry(outputs: dict, occ_id: str, datum: dict) -> None:
    occ = {**next(o for o in OCCURRENCES if o["id"] == occ_id), "datum": datum}
    assert cw.emitted_errors(occ, outputs) != []


def test_generator_refuses_a_local_anchor_that_is_gone(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    occ = next(o for o in OCCURRENCES if o["repo"] == cw.REPOSITORY and "anchor" in o)
    broken = {**TABLE, "occurrence": [{**occ, "anchor": "this text is in no file"}]}
    monkeypatch.setattr(cw, "load", lambda path=cw.TABLE: broken)
    sys.path.insert(0, str(ROOT / "tools"))
    import make_structure_crosswalk

    assert make_structure_crosswalk.main(["--check"]) == 1
