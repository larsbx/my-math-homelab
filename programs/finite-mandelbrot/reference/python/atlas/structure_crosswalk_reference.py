#!/usr/bin/env python3
"""Checks and graph for the structure crosswalk, `schemas/structure_crosswalk.toml`.

The atlas (`schemas/structure_names.toml`) keys each named structure of the
Mandelbrot set to exact data. The crosswalk records where the estate's code and
data hold the same datum: an `[[occurrence]]` names a repository, a file, a
literal anchor in that file, the atlas ids it meets, and the datum it shares.

Checks, all exact:

- every datum field is an atlas field (or `center`, a rational centre), and
  agrees with the atlas entry: rationals compared as `Fraction`, a list of
  angles as a subset of the atlas list, a `center` as a root of the entry's
  centre polynomial inside its isolating interval;
- every anchor occurs verbatim in the named file, for this repository always
  and for a sibling repository when its checkout sits beside this one;
- relations, planes and exactness classes are the declared vocabulary.

`build` joins the atlas and the crosswalk into one typed graph whose
vocabulary it declares itself, and adds the atlas's own structure as edges
(satellite of, Julia set of, in the limb of, ...), so a consumer draws it
without deriving anything. A shared datum is an identification of symbols;
that a ray pair lands where a picture shows a component is the imported
landing theorem, here as everywhere in the atlas.
"""

from __future__ import annotations

import json
import os
import sys
import tomllib
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT))

from reference.python.atlas import structure_names_reference as sn  # noqa: E402

TABLE = ROOT / "schemas" / "structure_crosswalk.toml"
SURFACE = Path("docs") / "structure_crosswalk.json"
REPOSITORY = "larsbx/finite-mandelbrot-research"
FORMAT = "structure crosswalk 1"
TABLE_FORMAT = "finite-mandelbrot-structure-crosswalk-v1"

#: Fields compared as sets of rationals: an occurrence may hold some of the atlas angles.
ANGLE_SETS = ("root_angles", "angles", "landing_cycle", "convergents")
#: Fields compared as single rationals.
RATIONALS = ("root_parameter", "rotation", "limb")
#: Fields compared for equality as written (integers, nested lists).
LITERALS = ("period", "internal_address", "center_polynomial", "angle_type", "critical_orbit_type")
DATUM_FIELDS = ANGLE_SETS + RATIONALS + LITERALS + ("parameter", "levels", "center", "accumulation")

#: Edges from an occurrence to the atlas, and what each one asserts.
OCCURRENCE_RELATIONS = {
    "same-datum": "holds the atlas datum itself, as a fixture or constant",
    "computes": "computes the atlas datum from other data",
    "contains": "a set, catalogue or sweep with the atlas datum among its members",
    "certifies": "issues a finite certificate (box, interval, enclosure) for the structure",
    "attaches": "attaches an invariant the atlas does not carry (an index, a multiplier, a kneading word)",
    "names": "names the structure without carrying its datum",
}
#: Relations that assert a shared datum, so an occurrence of one must state it.
DATUM_RELATIONS = ("same-datum", "computes", "contains")
#: Edges inside the atlas, read off its own fields.
ATLAS_RELATIONS = {
    "satellite-of": "a hyperbolic component is the `rotation`-satellite of its `parent`",
    "generated-by": "a cascade is iterated tuning by its `generator`",
    "julia-set-of": "a named Julia set belongs to the parameter or component `parameter_of`",
    "region-at": "a valley lies at the seam of the components in `between`",
    "in-limb-of": "a Misiurewicz parameter lies in the `limb` of the main cardioid",
    "boundary-of": "a boundary parameter lies on its `parent`",
    "conjugate-of": "the complex conjugate of `conjugate_of`: angles negated, real data equal",
    "tuning-image-of": "a region is the image of `tuning_of.image_of` under tuning by `tuning_of.by`",
}
PLANES = {
    "kernel": "canonical executable code (Mojo)",
    "reference": "non-authoritative reference implementation",
    "oracle": "independent oracle",
    "schema": "declared contract or table",
    "data": "committed machine-readable data or certificates",
    "test": "conformance test or fixture",
    "doc": "exposition",
    "experiment": "non-authoritative experiment",
    "view": "a visualization surface that draws or names the structure",
}
EXACTNESS = ("exact", "ball", "float", "name-only")


def load(path: Path = TABLE) -> dict:
    return tomllib.loads(path.read_text(encoding="utf-8"))


def atlas_by_id() -> dict[str, dict]:
    return {e["id"]: e for e in sn.load()}


def checkout(repo: str) -> Path | None:
    """This repository, or a sibling checkout named after `repo` under
    `$CROSSWALK_SOURCES` (default: this repository's parent directory)."""
    if repo == REPOSITORY:
        return ROOT
    base = Path(os.environ.get("CROSSWALK_SOURCES", ROOT.parent))
    candidate = base / repo.split("/", 1)[1]
    return candidate if candidate.is_dir() else None


# --- checks -----------------------------------------------------------------

def _rationals(values) -> set[Fraction]:
    return {Fraction(v) for v in values}


def _gaussian(value) -> tuple[Fraction, Fraction]:
    return tuple(Fraction(x) for x in value)


def _center_errors(value: str, entry: dict) -> list[str]:
    c = Fraction(value)
    coeffs = entry.get("center_polynomial")
    if coeffs is None:
        return ["the atlas entry has no centre polynomial"]
    if sn.evaluate(sn.poly(*coeffs), c) != 0:
        return [f"{value} is not a root of the centre polynomial"]
    lo, hi = (Fraction(x) for x in entry.get("center_interval", (c, c)))
    return [] if lo <= c <= hi else [f"{value} is outside the centre interval"]


def field_errors(name: str, value, entry: dict) -> list[str]:
    if name == "center":
        return _center_errors(value, entry)
    if name not in entry:
        return [f"{name}: the atlas entry has no such field"]
    atlas = entry[name]
    if name in ANGLE_SETS:
        ok = bool(value) and _rationals(value) <= _rationals(atlas)
    elif name in RATIONALS:
        ok = Fraction(value) == Fraction(atlas)
    elif name == "accumulation":
        ok = value["parent"] == atlas["parent"] and Fraction(value["rotation"]) == Fraction(atlas["rotation"])
    elif name == "parameter":
        ok = _gaussian(value) == _gaussian(atlas)
    elif name == "levels":
        ok = len(value) <= len(atlas) and all(bool(v) and _rationals(v) <= _rationals(a) for v, a in zip(value, atlas))
    else:
        ok = value == atlas
    return [] if ok else [f"{name}: {value!r} disagrees with the atlas {atlas!r}"]


def owner(atlas_id: str, atlas: dict[str, dict]) -> dict:
    """The entry that carries the data: a named Julia set's datum is its parameter's."""
    entry = atlas[atlas_id]
    return atlas[entry["parameter_of"]] if entry["kind"] == "julia-set" else entry


def datum_errors(occ: dict, atlas: dict[str, dict]) -> list[str]:
    """Every datum field agrees with every atlas entry the occurrence names (a
    named Julia set answering for its parameter)."""
    unknown = [a for a in occ["atlas"] if a not in atlas]
    if unknown or not occ["atlas"]:
        return [f"{occ['id']}: unknown atlas ids {unknown}"]
    datum = occ.get("datum", {})
    if occ["relation"] in DATUM_RELATIONS and not datum:
        return [f"{occ['id']}: a {occ['relation']} occurrence states its datum"]
    errors = [f"{occ['id']}: {k}: not a datum field" for k in datum if k not in DATUM_FIELDS]
    return errors + [
        f"{occ['id']} -> {a}: {m}"
        for a in occ["atlas"]
        for k, v in datum.items() if k in DATUM_FIELDS
        for m in field_errors(k, v, owner(a, atlas))
    ]


def _json_row_found(text: str, locator: dict) -> bool:
    rows = json.loads(text).get(locator["array"], [])
    return any(all(row.get(k) == v for k, v in locator["match"].items()) for row in rows)


def anchor_errors(occ: dict, root: Path) -> list[str]:
    """The literal `anchor` occurs in the file, and a `json_row` locator
    (`array` of the top-level object, fields to `match`) finds its row."""
    path, where = root / occ["path"], f"{occ['repo']}:{occ['path']}"
    if not path.is_file():
        return [f"{occ['id']}: {where} is not a file"]
    text = path.read_text(encoding="utf-8")
    errors = [f"{occ['id']}: anchor {occ['anchor']!r} not in {where}"] if "anchor" in occ and occ["anchor"] not in text else []
    if "json_row" in occ and not _json_row_found(text, occ["json_row"]):
        errors.append(f"{occ['id']}: no row {occ['json_row']['match']} in {occ['json_row']['array']} of {where}")
    return errors


def _q(pair) -> Fraction:
    return Fraction(pair[0], pair[1])


def _datum_rationals(datum: dict) -> set[Fraction]:
    values = [v for k in ANGLE_SETS + ("root_parameter",) if k in datum for v in (datum[k] if isinstance(datum[k], list) else [datum[k]])]
    values += [v for level in datum.get("levels", []) for v in level]
    return {Fraction(v) for v in values}


def _tunings(rows: list, datum: dict) -> bool:
    seen = {_q(r[f]) for r in rows for f in ("lo", "hi", "theta", "tuned") if r.get(f)}
    pairs = {(_q(r["lo"]), _q(r["hi"])) for r in rows}
    root = datum.get("root_angles")
    return _datum_rationals(datum) <= seen and (root is None or tuple(sorted(Fraction(a) for a in root)) in pairs)


def _kneading(rows: list, datum: dict) -> bool:
    return all(
        any(_q(r["theta"]) == Fraction(a) and r["address"] == datum.get("internal_address", r["address"])
            and r["period"] == datum.get("period", r["period"]) for r in rows)
        for a in datum.get("root_angles", [])
    ) and bool(datum.get("root_angles"))


def _catalogues(rows: list, datum: dict) -> bool:
    l, k = datum["angle_type"]
    found = {Fraction(a, r["den"]) for r in rows if (r["l"], r["k"]) == (l, k) for a in r["addresses"]}
    return any((r["l"], r["k"]) == (l, k) for r in rows) and {Fraction(a) for a in datum.get("angles", [])} <= found


def _incidence(rows: list, datum: dict) -> bool:
    types = {(r["ray_preperiod"], r["ray_period"]) for r in rows}
    return bool(datum.get("angles")) and all(sn.exact_type(Fraction(a)) in types for a in datum["angles"])


def _valleys(rows: list, datum: dict, atlas_ids: list[str]) -> bool:
    acc = datum["accumulation"]
    return any(r["id"] in atlas_ids and r["parent"] == acc["parent"] and _q(r["rotation"]) == Fraction(acc["rotation"]) for r in rows)


def _convergents(rows: list, datum: dict) -> bool:
    limbs = {_q(t["limb"]) for r in rows for t in r["terms"]}
    return {Fraction(c) for c in datum["convergents"]} <= limbs


EMITTED = {
    "atlas-dataset:tunings": lambda rows, o: _tunings(rows, o.get("datum", {})),
    "atlas-dataset:kneading": lambda rows, o: _kneading(rows, o.get("datum", {})),
    "atlas-dataset:catalogues": lambda rows, o: _catalogues(rows, o.get("datum", {})),
    "atlas-dataset:incidence": lambda rows, o: _incidence(rows, o.get("datum", {})),
    "structure-streams:valleys": lambda rows, o: _valleys(rows, o.get("datum", {}), o["atlas"]),
    "structure-streams:convergents": lambda rows, o: _convergents(rows, o.get("datum", {})),
}


def emitted_errors(occ: dict, outputs: dict[str, dict]) -> list[str]:
    """An occurrence that `emits` into an emitter section must find its datum in that section of the
    emitter's actual output: the anchor names the code, the output is what the code says."""
    if "emits" not in occ:
        return []
    emitter, section = occ["emits"].split(":", 1)
    check = EMITTED.get(occ["emits"])
    if check is None or emitter not in outputs or section not in outputs[emitter]:
        return [f"{occ['id']}: no output section {occ['emits']}"]
    return [] if check(outputs[emitter][section], occ) else [f"{occ['id']}: datum not in the emitted {occ['emits']}"]


def table_errors(table: dict, atlas: dict[str, dict]) -> list[str]:
    errors = [] if table.get("format") == TABLE_FORMAT else [f"format is {table.get('format')!r}"]
    ids = [o["id"] for o in table["occurrence"]]
    errors += [f"duplicate occurrence id {i}" for i in sorted({i for i in ids if ids.count(i) > 1})]
    errors += [f"occurrence id {i} collides with an atlas id" for i in ids if i in atlas]
    errors += [f"{o['id']}: emits {o['emits']!r} is not a checked section" for o in table["occurrence"]
               if "emits" in o and o["emits"] not in EMITTED]
    for o in table["occurrence"]:
        errors += [f"{o['id']}: {f} {o[f]!r} is not declared" for f, allowed in
                   (("relation", OCCURRENCE_RELATIONS), ("plane", PLANES), ("exactness", EXACTNESS))
                   if o.get(f) not in allowed]
        errors += [f"{o['id']}: missing {f}" for f in ("repo", "path", "atlas", "label") if not o.get(f)]
        errors += [] if o.get("anchor") or o.get("json_row") else [f"{o['id']}: needs an anchor or a json_row"]
    return errors


# --- the graph --------------------------------------------------------------

def _in_limb_target(limb: str, atlas: dict[str, dict]) -> str | None:
    r = Fraction(limb)
    return next((e["id"] for e in atlas.values() if e.get("parent") == "main-cardioid"
                 and Fraction(e.get("rotation", -1)) == r), None)


def atlas_edges(atlas: dict[str, dict]) -> list[dict]:
    pairs = []
    for e in atlas.values():
        if "parent" in e:
            pairs.append((e["id"], "boundary-of" if e["kind"] == "boundary-parameter" else "satellite-of", e["parent"]))
        pairs += [(e["id"], "generated-by", e["generator"])] if "generator" in e else []
        pairs += [(e["id"], "julia-set-of", e["parameter_of"])] if "parameter_of" in e else []
        pairs += [(e["id"], "region-at", t) for t in e.get("between", ())]
        pairs += [(e["id"], "conjugate-of", e["conjugate_of"])] if "conjugate_of" in e else []
        pairs += [(e["id"], "tuning-image-of", e["tuning_of"]["image_of"])] if "tuning_of" in e else []
        if "limb" in e and (t := _in_limb_target(e["limb"], atlas)):
            pairs.append((e["id"], "in-limb-of", t))
    return [{"source": s, "relation": r, "target": t} for s, r, t in pairs]


def _atlas_node(e: dict) -> dict:
    key = {k: e[k] for k in DATUM_FIELDS + ("center_interval", "conjugate_of", "tuning_of") if k in e}
    return {"id": e["id"], "class": f"atlas/{e['kind']}", "label": e["names"][0], "names": e["names"],
            "name_status": e["name_status"], **({"key": key} if key else {})}


def _occurrence_node(o: dict) -> dict:
    fields = ("repo", "path", "anchor", "json_row", "exactness", "emits", "datum", "note")
    return {"id": o["id"], "class": o["plane"], "label": o["label"], "relation": o["relation"],
            **{f: o[f] for f in fields if f in o}}


def build(table: dict, atlas: dict[str, dict]) -> dict:
    kinds = sorted({e["kind"] for e in atlas.values()})
    return {
        "format": FORMAT,
        "generated": "Generated by tools/make_structure_crosswalk.py from the two sources; do not edit.",
        "repository": REPOSITORY,
        "sources": ["schemas/structure_names.toml", "schemas/structure_crosswalk.toml"],
        "caveat": "A shared datum identifies symbols. Positions are not carried; that a ray pair "
                  "lands at a component is the imported landing theorem.",
        "classes": [{"id": f"atlas/{k}", "name": f"atlas: {k}"} for k in kinds]
                   + [{"id": p, "name": d} for p, d in PLANES.items()],
        "relations": [{"id": r, "name": d} for r, d in {**OCCURRENCE_RELATIONS, **ATLAS_RELATIONS}.items()],
        "nodes": [_atlas_node(e) for e in atlas.values()] + [_occurrence_node(o) for o in table["occurrence"]],
        "edges": atlas_edges(atlas) + [
            {"source": o["id"], "relation": o["relation"], "target": a} for o in table["occurrence"] for a in o["atlas"]
        ],
    }


def render(graph: dict) -> str:
    return json.dumps(graph, indent=2, ensure_ascii=False) + "\n"


def main() -> int:
    table, atlas = load(), atlas_by_id()
    errors = table_errors(table, atlas) + [m for o in table["occurrence"] for m in datum_errors(o, atlas)]
    unchecked = []
    for o in table["occurrence"]:
        root = checkout(o["repo"])
        if root is None:
            unchecked.append(o["id"])
        else:
            errors += anchor_errors(o, root)
    for m in errors:
        print(f"FAIL {m}")
    if unchecked:
        print(f"note: {len(unchecked)} anchors not checked (no sibling checkout): {', '.join(unchecked)}")
    if not errors:
        print(f"OK: {len(table['occurrence'])} occurrences agree with the atlas and their files.")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
