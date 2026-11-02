"""Pinned arithmetic-bicycle finite replay; executable only through local allowlist."""
from __future__ import annotations

from hashlib import sha1, sha256
from itertools import combinations
import json
from pathlib import Path
import sys
import tomllib

# Python -I deliberately removes cwd/import environment; use only our own tools.
TOOLS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOLS))
from experiments.ab_enumeration import enumerate_bicycles
from experiments.ab_gram import arithmetic_signature, determinant, gram_quotient, verify_witnesses

SNAPSHOTS = (
    "conformance/fixtures/arithmetic-matroid-v1.json",
    "conformance/fixtures/surjective-representation-v1.json",
    "conformance/fixtures/realization-dependence-v1.json",
    "proof/claims.toml", "proof/arithmetic-realization-counterexample.md",
    "proof/surjective-realization-invariance.md", "proof/code-hull-tower.md",
)
RETRACTED = ("ABC-MAIN", "ABC-REALIZATION-INVARIANCE", "ABC-UNIVERSAL-TORSION-MODEL")


class Inconclusive(Exception):
    """A declared resource budget cannot cover the ENTIRE selected scope."""


def require(condition, reason):
    if not condition:
        raise ValueError(reason)


def digest(raw):
    return sha256(raw).hexdigest()


def canonical(value):
    return json.dumps(value, indent=2, sort_keys=True) + "\n"


def load_inputs(spec, root):
    path = root / spec["manifest"]
    raw = path.read_bytes()
    if len(raw) > spec["max_input_bytes"]:
        raise Inconclusive("manifest input byte budget exceeded")
    require(digest(raw) == spec["manifest_sha256"], "manifest SHA-256 mismatch")
    manifest = json.loads(raw)
    require(manifest["schema"] == "HOMELAB-AB-FIXTURES-1", "fixture schema mismatch")
    require(manifest["source_repository"] == spec["source_repository"] and
            manifest["source_revision"] == spec["source_revision"], "source pin mismatch")
    require(len(manifest["snapshots"]) == len(SNAPSHOTS) and
            {s["path"] for s in manifest["snapshots"]} == set(SNAPSHOTS),
            "source snapshot inventory changed")
    data, total = {}, len(raw)
    for s in manifest["snapshots"]:
        raw = (path.parent / "source" / s["path"]).read_bytes()
        total += len(raw)
        if total > spec["max_input_bytes"]:
            raise Inconclusive("source input byte budget exceeded")
        require(digest(raw) == s["sha256"], "source snapshot SHA-256 mismatch: " + s["path"])
        blob = sha1(b"blob " + str(len(raw)).encode("ascii") + b"\0" + raw).hexdigest()
        require(blob == s["git_blob_sha1"], "source snapshot Git blob mismatch")
        data[s["path"]] = raw.decode("utf-8")
    return manifest, data


def preflight(cases, spec):
    total = 0
    for c in cases:
        rows, width = c["matrix"], c["columns"]
        require(type(width) is int and width >= 0 and isinstance(rows, list), "invalid matrix shape")
        require(all(isinstance(row, list) and len(row) == width for row in rows), "ragged matrix")
        require(all(type(x) is int for row in rows for x in row), "entries must be exact integers")
        if len(rows) > spec["max_rows"] or width > spec["max_columns"]:
            raise Inconclusive("matrix dimension budget exceeded")
        if any(abs(x) > spec["max_entry_abs"] for row in rows for x in row):
            raise Inconclusive("integer magnitude budget exceeded")
        require(c["moduli"] and len(set(c["moduli"])) == len(c["moduli"]), "empty/duplicate moduli")
        for n in c["moduli"]:
            require(type(n) is int and n >= 2, "invalid modulus")
            if n > spec["max_modulus"]:
                raise Inconclusive("modulus budget exceeded")
            vectors = n ** len(rows) + n ** width
            if vectors > spec["max_vectors_per_case"]:
                raise Inconclusive("finite-module enumeration case budget exceeded")
            total += vectors
    if total > spec["max_vectors_total"]:
        raise Inconclusive("finite-module enumeration total budget exceeded")
    return total


def evaluate(spec, root):
    manifest, data = load_inputs(spec, root)
    claims = {c["id"]: c["status"] for c in tomllib.loads(data["proof/claims.toml"])["claim"]}
    require(all(claims.get(c) == "retracted" for c in RETRACTED), "retracted claim status changed")
    require(claims.get("ABC-SURJECTIVE-REALIZATION-INVARIANCE") == "proved", "source theorem status drift")
    require(claims.get("ABC-CODE-HULL-TOWER") == "proved", "source quotient interface missing")
    real_path = "conformance/fixtures/realization-dependence-v1.json"
    pair_path = "conformance/fixtures/surjective-representation-v1.json"
    real = {c["id"]: c for c in json.loads(data[real_path])["cases"]}
    pairs = {c["id"]: c for c in json.loads(data[pair_path])["pairs"]}
    cases, comparisons = [], []
    # Never infer a fixture selection from executable source code.
    require(set(manifest["realization_cases"]) == {"index5-a1", "index5-a2", "scalar2", "rankzero"},
            "required refutation/obstruction controls missing")
    require(set(manifest["surjective_pairs"]) == {"rank-one-no-unit-basis", "rank-two-no-unit-basis",
            "primitive-non-tu", "noncyclic-three-torsion"}, "required surjective controls missing")
    for id_, moduli in sorted(manifest["realization_cases"].items()):
        source = real[id_]
        require(set(moduli) <= set(source["moduli"]), "moduli absent from pinned source")
        cases.append({"id": id_, "matrix": source["matrix"], "columns": source["columns"],
                      "moduli": moduli, "expected": source["expected_orders"],
                      "expected_index": int(source["ambient_index"]),
                      "origin": {"path": real_path, "fixture_id": id_}})
    for id_, moduli in sorted(manifest["surjective_pairs"].items()):
        source = pairs[id_]
        require(set(moduli) <= set(source["moduli"]), "moduli absent from pinned pair")
        for side in ("source", "target"):
            cases.append({"id": id_ + "/" + side, "matrix": source[side], "columns": source["columns"],
                          "moduli": moduli, "expected_index": 1,
                          "origin": {"path": pair_path, "fixture_id": id_, "side": side}})
        comparisons.append((id_, source))
    # Inspect the entire requested scope BEFORE doing exponential enumeration.
    vector_count = preflight(cases, spec)
    results, by_id = [], {}
    for c in cases:
        rows, width = c["matrix"], c["columns"]
        signature = arithmetic_signature(rows, width)
        essential = signature[-1][0] == len(rows)
        require(essential, "fixture is not essential in its declared ambient lattice")
        require(signature[-1][1] == c["expected_index"], "ambient lattice index changed")
        surjective = essential and signature[-1][1] == 1
        unit_basis = any(
            abs(determinant(
                [[row[j] for j in ci] for row in rows])) == 1
            for ci in combinations(range(width), len(rows)))
        moduli = []
        for n in c["moduli"]:
            witnesses = [list(x) for x in enumerate_bicycles(rows, width, n)]
            check = gram_quotient(rows, width, n)
            verify_witnesses(rows, width, n, witnesses, check["bicycle_order"])
            if "expected" in c:
                require(len(witnesses) == c["expected"][str(n)], "pinned expected order mismatch")
            if surjective:
                require(check["transpose_kernel_order"] == 1, "surjective Gram injection failed")
            moduli.append({"modulus": n, "enumerated_order": len(witnesses),
                           "independent": check, "witnesses": witnesses,
                           "witness_sha256": digest(canonical(witnesses).encode()),
                           "complete_lattice_witness_check": True})
        result = {"id": c["id"], "matrix": rows, "columns": width, "origin": c["origin"],
                  "arithmetic_signature": signature, "essential": essential,
                  "ambient_index": signature[-1][1], "corrected_surjective_domain": surjective,
                  "has_unit_maximal_minor": unit_basis, "moduli": moduli}
        results.append(result); by_id[c["id"]] = result
    a, b = by_id["index5-a1"], by_id["index5-a2"]
    arithmetic = json.loads(data["conformance/fixtures/arithmetic-matroid-v1.json"])
    af = {c["id"]: c for c in arithmetic["fixtures"]}
    for c, name in ((a, "counterexample-a"), (b, "counterexample-b")):
        require(c["matrix"] == af[name]["matrix"] and c["arithmetic_signature"] == af[name]["signature"],
                "counterexample arithmetic data mismatch")
        require(not c["corrected_surjective_domain"], "counterexample incorrectly admitted to corrected domain")
    require(a["arithmetic_signature"] == b["arithmetic_signature"], "counterexample signatures differ")
    for n in (5, 10):
        ar = next((m for m in a["moduli"] if m["modulus"] == n), None)
        br = next((m for m in b["moduli"] if m["modulus"] == n), None)
        require(ar is not None and br is not None, "mandatory counterexample modulus omitted")
        require((ar["enumerated_order"], br["enumerated_order"]) == (1, 5), "counterexample lost")
    pair_results = []
    for id_, source in comparisons:
        left, right = by_id[id_+"/source"], by_id[id_+"/target"]
        permuted = [[row[j] for j in source["permutation"]] for row in source["source"]]
        require(arithmetic_signature(permuted, source["columns"]) == right["arithmetic_signature"],
                "surjective pair arithmetic signatures differ under source label map")
        require([m["enumerated_order"] for m in left["moduli"]] ==
                [m["enumerated_order"] for m in right["moduli"]], "bounded surjective pair disagreement")
        require(all(m["independent"]["gram_smith_factors"] == source["gram_smith"]
                    for c in (left, right) for m in c["moduli"]), "source Gram factors disagree")
        if source["no_unit_basis"]:
            require(not left["has_unit_maximal_minor"] and not right["has_unit_maximal_minor"],
                    "no-unit-basis control was weakened")
        pair_results.append({"id": id_, "permutation": source["permutation"],
                             "same_complete_arithmetic_data": True, "finite_orders_agree": True,
                             "general_theorem_verified_by_adapter": False})
    return {"state": "verified_finite", "scope_complete": True,
            "enumerated_vector_states": vector_count, "matrix_count": len(results),
            "modulus_case_count": sum(len(c["moduli"]) for c in results),
            "source_snapshots": manifest["snapshots"],
            "source_claim_statuses": {c: claims[c] for c in (*RETRACTED,
                 "ABC-SURJECTIVE-REALIZATION-INVARIANCE", "ABC-CODE-HULL-TOWER")},
            "counterexample_preserved": True, "corrected_domain_distinguished": True,
            "surjective_pair_checks": pair_results, "cases": results,
            "next_mathematical_obligation": manifest["next_mathematical_obligation"]}


def main():
    from math_experiments import ROOT, load_adapters, implementation_hashes
    spec, = load_adapters()
    import resource
    resource.setrlimit(resource.RLIMIT_CPU, (spec["cpu_seconds"], spec["cpu_seconds"]))
    memory = spec["memory_mb"] * 1024 * 1024
    resource.setrlimit(resource.RLIMIT_AS, (memory, memory))
    resource.setrlimit(resource.RLIMIT_FSIZE, (spec["output_bytes"], spec["output_bytes"]))
    resource.setrlimit(resource.RLIMIT_NOFILE, (32, 32))
    record = {"schema": "HOMELAB-MATH-EXPERIMENT-1", "adapter": spec["id"],
              "source_repository": spec["source_repository"], "source_revision": spec["source_revision"],
              "input_sha256": spec["manifest_sha256"], "implementation_sha256": implementation_hashes(),
              "automatic_claim_promotion": False, "mathematical_theorems_promoted": 0,
              "independent_mathematical_claim_verified": False, "source_authority": "retained"}
    try:
        record.update(evaluate(spec, ROOT))
    except Exception as exc:
        record.update(state="inconclusive" if isinstance(exc, (Inconclusive, MemoryError)) else "failure",
                      scope_complete=False, error=f"{type(exc).__name__}: {exc}",
                      next_mathematical_obligation="Diagnose retained failure; no finite acceptance or theorem promotion.")
    print(canonical(record), end="")
    return 0 if record["state"] == "verified_finite" else 2 if record["state"] == "inconclusive" else 1


if __name__ == "__main__":
    raise SystemExit(main())
