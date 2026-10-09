"""Rebuild source-pinned fixed-TU evidence and arithmetic boundary controls."""

import argparse
from collections import Counter
import hashlib
import json
from math import gcd, prod
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from kernel.regular_bicycle import TURepresentation
from oracles.graph_snf import edge_order, torsion_order_profile
from oracles.regular_snf import (
    cycle_bicycles, gram_matrix, is_totally_unimodular, literal_bicycles,
    quotient_key, quotient_representatives, smith_invariants,
)

FIXTURES = "conformance/fixtures/regular-modular-bicycle-v1.json"
RECEIPT = "conformance/receipts/regular-modular-bicycle-v1.json"
SOURCES = (
    FIXTURES,
    "kernel/regular_bicycle.py",
    "kernel/graph_bicycle.py",
    "oracles/regular_snf.py",
    "oracles/graph_snf.py",
    "conformance/fixtures/graph-modular-bicycle-v1.json",
    "conformance/test_regular_modular_bicycle.py",
    "conformance/replay_regular_modular_bicycle.py",
    "proof/regular-modular-bicycle.md",
    "proof/arithmetic-torsion-model-obstruction.md",
)


def canonical(value):
    return json.dumps(value, indent=2, sort_keys=True) + "\n"


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def edge_hash(bicycles):
    return hashlib.sha256(canonical(sorted(bicycles)).encode()).hexdigest()


def evidence():
    data = json.loads((ROOT / FIXTURES).read_text())
    require(data["schema"] == 1, "unsupported fixture schema")
    ids, cases, tower_checks, controls = set(), [], [], []
    for f in data["fixtures"]:
        require(f["id"] not in ids, "duplicate fixture id")
        ids.add(f["id"])
        a = TURepresentation(f["matrix"], f["columns"])
        require(is_totally_unimodular(a.rows, a.columns), "independent TU check failed")
        gram = gram_matrix(a.rows, a.columns)
        require(a.gram == gram, "Gram disagreement")
        smith = smith_invariants(gram)
        require(smith == tuple(f["smith"]), f"Smith mismatch: {f['id']}")
        classes = quotient_representatives(gram)
        require(len(classes) == prod(smith), "quotient order mismatch")
        bicycles, divisors = {}, {}
        for n in f["moduli"]:
            label = f"{f['id']} mod {n}"
            candidate = a.bicycles(n)
            oracle = cycle_bicycles(a.rows, n, a.columns)
            require(set(candidate) == oracle, f"edge-set disagreement: {label}")
            factors = tuple(gcd(s, n) for s in smith)
            require(len(candidate) == prod(factors), f"torsion count mismatch: {label}")
            orders = dict(Counter(edge_order(b, n) for b in candidate))
            require(orders == torsion_order_profile(smith, n), f"order profile mismatch: {label}")
            expected = {key: d for key, d in classes.items() if all((n * x) % 1 == 0 for x in key)}
            mapped = {}
            images = set()
            for b, y in candidate.items():
                d = a.bicycle_to_divisor(b, n, y)
                mapped[b] = d
                key = quotient_key(gram, d)
                require(key in expected, f"image is not torsion: {label}")
                require(a.divisor_to_bicycle(d, n) == b, f"left inverse failed: {label}")
                require(a.class_key(d) == key, f"class-coordinate disagreement: {label}")
                images.add(key)
            require(images == set(expected) and len(images) == len(candidate),
                    f"bijection failure: {label}")
            inverse_set = set()
            for key, d in expected.items():
                b = a.divisor_to_bicycle(d, n)
                require(quotient_key(gram, a.bicycle_to_divisor(b, n)) == key,
                        f"right inverse failed: {label}")
                inverse_set.add(b)
            require(inverse_set == oracle, f"inverse edge-set disagreement: {label}")
            bicycles[n], divisors[n] = candidate, mapped
            cases.append({
                "fixture": f["id"], "modulus": n, "smith": list(smith),
                "torsion_factors": list(factors), "bicycles": len(candidate),
                "distinct_mapped_classes": len(images),
                "independently_enumerated_torsion_classes": len(expected),
                "orders": {str(k): v for k, v in sorted(orders.items())},
                "edge_set_sha256": edge_hash(oracle),
            })
        for n in bicycles:
            for m in bicycles:
                if m <= n or m % n:
                    continue
                k = m // n
                for b, d in divisors[m].items():
                    reduced = a.reduce_bicycle(b, m, n)
                    require(reduced in bicycles[n], "reduction left bicycle module")
                    require(quotient_key(gram, divisors[n][reduced]) ==
                            quotient_key(gram, tuple(k * x for x in d)), "reduction square failed")
                    require(a.inflate_bicycle(reduced, n, m) == tuple(k * x % m for x in b),
                            "inflation/reduction composite failed")
                inflated = set()
                for b, d in divisors[n].items():
                    value = a.inflate_bicycle(b, n, m)
                    require(value in bicycles[m], "inflation left bicycle module")
                    require(quotient_key(gram, divisors[m][value]) == quotient_key(gram, d),
                            "inflation square failed")
                    require(a.reduce_bicycle(value, m, n) == tuple(k * x % n for x in b),
                            "reduction/inflation composite failed")
                    inflated.add(value)
                require(len(inflated) == len(bicycles[n]), "inflation is not injective")
                tower_checks.append({"fixture": f["id"], "n": n, "m": m,
                                     "reduction_checks": len(bicycles[m]),
                                     "inflation_checks": len(bicycles[n])})

    control_ids = set()
    for f in data["controls"]:
        require(f["id"] not in ids | control_ids, "duplicate control id")
        control_ids.add(f["id"])
        require(not is_totally_unimodular(f["matrix"], f["columns"]), "control unexpectedly TU")
        try:
            TURepresentation(f["matrix"], f["columns"])
        except ValueError:
            pass
        else:
            raise RuntimeError("candidate accepted a non-TU control")
        gram = gram_matrix(f["matrix"], f["columns"])
        smith = smith_invariants(gram)
        for n in f["moduli"]:
            bikes = literal_bicycles(f["matrix"], n, f["columns"])
            if f["id"] == "nonprimitive-scalar-two":
                require(f["matrix"] == [[2]], "unexpected nonprimitive control")
                require(len(bikes) == gcd(n, 4) // gcd(n, 2), "scalar-two count mismatch")
                # y -> 2y can have the same modular edge vector but different Gram classes.
                potential_images = {}
                for y in range(n):
                    if 4 * y % n == 0:
                        potential_images.setdefault((2 * y % n,), set()).add(
                            quotient_key(gram, (4 * y // n,)))
                ambiguous = sum(len(values) > 1 for values in potential_images.values())
                interpretation = "no integral splitting; proposed map may be ambiguous"
            elif f["id"] == "primitive-non-tu":
                require(f["matrix"] == [[1, 2]], "unexpected primitive control")
                require(bikes == cycle_bicycles(f["matrix"], n), "primitive control edge-set disagreement")
                expected = {key for key in quotient_representatives(gram)
                            if all((n * x) % 1 == 0 for x in key)}
                images = {quotient_key(gram, (5 * b[0] // n,)) for b in bikes}
                require(images == expected and len(images) == len(bikes), "split non-TU control failed")
                ambiguous = 0
                interpretation = "integral splitting; TU is sufficient but not necessary"
            else:
                raise RuntimeError("unclassified arithmetic boundary control")
            controls.append({
                "fixture": f["id"], "modulus": n, "gram_smith": list(smith),
                "bicycles": len(bikes), "gram_group_torsion": prod(gcd(s, n) for s in smith),
                "ambiguous_bicycles": ambiguous, "interpretation": interpretation,
                "edge_set_sha256": edge_hash(bikes),
            })
    require(control_ids == {"nonprimitive-scalar-two", "primitive-non-tu"}, "missing boundary control")
    require(literal_bicycles(((2,),), 2) == {(0,)} and
            literal_bicycles(((2,),), 4) == {(0,), (2,)}, "group-model obstruction changed")
    return {
        "schema": 1, "claim": "ABC-REGULAR-MODULAR-BICYCLE",
        "scope": "finite evidence for the separate fixed-TU integral proof; labeled non-TU controls",
        "arithmetic": "Python integers and fractions.Fraction; no external dependencies",
        "sources_sha256": {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest() for path in SOURCES},
        "fixture_count": len(ids), "case_count": len(cases), "cases": cases,
        "tower_pair_count": len(tower_checks), "tower_checks": tower_checks,
        "control_count": len(control_ids), "control_case_count": len(controls), "controls": controls,
        "universal_torsion_model_obstruction": {
            "claim": "ABC-UNIVERSAL-TORSION-MODEL", "matrix": [[2]],
            "arithmetic_multiplicities": {"empty": 1, "ground_set": 2},
            "mod_2_bicycles": [[0]], "mod_4_bicycles": [[0], [2]],
            "conclusion": "H[2]=0 implies H[4]=0 for every abelian group; this tower has no such model",
            "realization_invariance": "not decided by this one-realization example",
        },
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--write", action="store_true", help="replace the derived receipt")
    mode.add_argument("--check", action="store_true", help="check receipt bytes (default)")
    args = parser.parse_args()
    rebuilt = canonical(evidence())
    destination = ROOT / RECEIPT
    if args.write:
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(rebuilt)
    else:
        require(destination.exists() and destination.read_text() == rebuilt,
                "receipt drift; investigate, then use --write to regenerate intentionally")
    counts = json.loads(rebuilt)
    print(f"PASS: {counts['fixture_count']} TU fixtures, {counts['case_count']} modulus cases, "
          f"{counts['tower_pair_count']} tower pairs, {counts['control_case_count']} non-TU controls")


if __name__ == "__main__":
    main()
