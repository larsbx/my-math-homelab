"""Rebuild deterministic, source-pinned exact evidence; check fails on drift."""

import argparse
from collections import Counter
import hashlib
import json
from math import prod
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from kernel.graph_bicycle import Graph
from oracles.graph_snf import (
    critical_key, critical_representatives, edge_order, reduced_laplacian,
    smith_invariants, torsion_factors, torsion_order_profile, tree_bicycles,
)

FIXTURES = "conformance/fixtures/graph-modular-bicycle-v1.json"
RECEIPT = "conformance/receipts/graph-modular-bicycle-v1.json"
SOURCES = (
    FIXTURES,
    "kernel/graph_bicycle.py",
    "oracles/graph_snf.py",
    "conformance/test_graph_modular_bicycle.py",
    "conformance/replay_graph_modular_bicycle.py",
    "proof/graph-modular-bicycle.md",
)


def canonical(value):
    return json.dumps(value, indent=2, sort_keys=True) + "\n"


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def class_key(g, d):
    return critical_key(g.vertices, g.edges, d)


def evidence():
    data = json.loads((ROOT / FIXTURES).read_text())
    require(data["schema"] == 1, "unsupported fixture schema")
    ids, cases, tower_checks = set(), [], []
    for f in data["fixtures"]:
        require(f["id"] not in ids, "duplicate fixture id")
        ids.add(f["id"])
        g = Graph(f["vertices"], f["edges"])
        smith = smith_invariants(reduced_laplacian(g.vertices, g.edges))
        require(smith == tuple(f["smith"]), f"SNF mismatch: {f['id']}")
        classes = critical_representatives(g.vertices, g.edges)
        require(len(classes) == prod(smith), "critical quotient size mismatch")
        bicycles = {}
        for n in f["moduli"]:
            label = f"{f['id']} mod {n}"
            candidate = g.bicycles(n)
            bicycles[n] = candidate
            oracle = set(tree_bicycles(g.vertices, g.edges, n))
            require(set(candidate) == oracle, f"bicycle-set disagreement: {label}")
            factors = torsion_factors(smith, n)
            require(len(candidate) == prod(factors), f"torsion count mismatch: {label}")
            order_counts = dict(Counter(edge_order(b, n) for b in candidate))
            require(order_counts == torsion_order_profile(smith, n), f"order mismatch: {label}")
            images, torsion_inverse = set(), set()
            for b, y in candidate.items():
                d = g.bicycle_to_divisor(b, n, y)
                key = class_key(g, d)
                require(all(x == 0 for x in class_key(g, tuple(n * x for x in d))),
                        f"image is not n-torsion: {label}")
                require(g.divisor_to_bicycle(d, n) == b, f"inverse failure: {label}")
                images.add(key)
            require(len(images) == len(candidate), f"noninjective map: {label}")
            for key, d in classes.items():
                if all((n * x) % 1 == 0 for x in key):
                    b = g.divisor_to_bicycle(d, n)
                    require(class_key(g, g.bicycle_to_divisor(b, n)) == key,
                            f"inverse on quotient failed: {label}")
                    torsion_inverse.add(b)
            require(torsion_inverse == oracle, f"nonsurjective inverse: {label}")
            cases.append({
                "fixture": f["id"], "modulus": n, "smith": list(smith),
                "torsion_factors": list(factors), "bicycles": len(candidate),
                "distinct_mapped_classes": len(images),
                "independently_enumerated_torsion_classes": len(torsion_inverse),
                "orders": {str(k): v for k, v in sorted(order_counts.items())},
                "edge_set_sha256": hashlib.sha256(canonical(sorted(oracle)).encode()).hexdigest(),
            })
        for n in bicycles:
            for m in bicycles:
                if m <= n or m % n:
                    continue
                k = m // n
                for b in bicycles[m]:
                    reduced = g.reduce_bicycle(b, m, n)
                    require(class_key(g, g.bicycle_to_divisor(reduced, n)) ==
                            class_key(g, tuple(k * x for x in g.bicycle_to_divisor(b, m))),
                            "reduction square failed")
                for b in bicycles[n]:
                    inflated = g.inflate_bicycle(b, n, m)
                    require(class_key(g, g.bicycle_to_divisor(inflated, m)) ==
                            class_key(g, g.bicycle_to_divisor(b, n)), "inflation square failed")
                tower_checks.append({"fixture": f["id"], "n": n, "m": m,
                                     "reduction_checks": len(bicycles[m]),
                                     "inflation_checks": len(bicycles[n])})
    return {
        "schema": 1,
        "claim": "ABC-GRAPH-MODULAR-BICYCLE",
        "scope": "finite evidence for the separate arbitrary-n integral proof",
        "arithmetic": "Python integers and fractions.Fraction; no external dependencies",
        "sources_sha256": {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
                           for path in SOURCES},
        "fixture_count": len(ids), "case_count": len(cases),
        "cases": cases, "tower_pair_count": len(tower_checks), "tower_checks": tower_checks,
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
    print(f"PASS: {counts['fixture_count']} fixtures, {counts['case_count']} modulus cases, "
          f"{counts['tower_pair_count']} tower pairs; exact independent agreement")


if __name__ == "__main__":
    main()
