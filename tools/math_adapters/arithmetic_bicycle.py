"""Source-pinned, independently checked finite arithmetic-bicycle research.

This is *not* a proof of a general arithmetic-matroid conjecture. The
original realization-invariance conjecture was refuted; we replay the
six registered finite counterexample/control families, including
composite moduli, with two DIFFERENT exact mathematical procedures.

Candidate: enumerate potentials y and compute image(A^T) intersect ker A.
Checker: enumerate edge vectors x satisfying Ax=0 and test image(A^T)
membership by gcd of maximal minors of [A^T | nI], comparing its lattice
index with that after adding x. This uses neither potential enumeration
nor field-rank assumptions in the independent checker.
"""
from __future__ import annotations

from hashlib import sha256
from itertools import combinations, product
from math import gcd
import json


def require(flag, reason):
    if not flag:
        raise ValueError(reason)


def determinant(square):
    """Exact determinant for matrices of arbitrary small dimension."""
    n = len(square)
    if not n:
        return 1
    if n == 1:
        return square[0][0]
    return sum(
        (-1 if j & 1 else 1) * square[0][j] *
        determinant([row[:j] + row[j + 1:] for row in square[1:]])
        for j in range(n)
    )


def lattice_index(generators, dimension):
    """Index of full-rank sublattice in Z^dimension via maximal minors."""
    if dimension == 0:
        return 1
    index = 0
    for subset in combinations(generators, dimension):
        index = gcd(index, abs(determinant([
            [column[row] for column in subset]
            for row in range(dimension)
        ])))
    require(index > 0, "modulus lattice must have full rank")
    return index


def candidate_hull(rows, width, modulus):
    """Construction using only modular potentials and cycle equations."""
    cuts = set()
    for potential in product(range(modulus), repeat=len(rows)):
        edge = tuple(sum(row[j] * coefficient
                         for row, coefficient in zip(rows, potential)) % modulus
                     for j in range(width))
        cuts.add(edge)
    return frozenset(
        edge for edge in cuts
        if all(sum(a * x for a, x in zip(row, edge)) % modulus == 0
               for row in rows)
    )


def checked_hull(rows, width, modulus):
    """Independent edge/lattice-index checker; no candidate cut enumeration."""
    generators = [tuple(row[j] for j in range(width)) for row in rows]
    generators += [tuple(modulus if j == k else 0 for j in range(width))
                   for k in range(width)]
    base_index = lattice_index(generators, width)
    return frozenset(
        edge for edge in product(range(modulus), repeat=width)
        if all(sum(a * x for a, x in zip(row, edge)) % modulus == 0
               for row in rows)
        and lattice_index([*generators, edge], width) == base_index
    )


def canonical_digest(obj):
    return sha256(json.dumps(obj, sort_keys=True,
                             separators=(",", ":")).encode()).hexdigest()


def annihilator(group, modulus):
    """Module-relevant information: sizes of d-torsion subgroups."""
    return {str(divisor): sum(
        all((divisor * x) % modulus == 0 for x in edge)
        for edge in group
    ) for divisor in range(1, modulus + 1) if modulus % divisor == 0}


def arithmetic_signature_2x2(matrix):
    """Labeled primitive-column multiplicities for the specific rank-two pair."""
    require(len(matrix) == 2 and all(len(row) == 2 for row in matrix),
            "counterexample signature restricted to 2x2 matrices")
    col_gcd = (gcd(abs(matrix[0][0]), abs(matrix[1][0])),
               gcd(abs(matrix[0][1]), abs(matrix[1][1])))
    return [1, *col_gcd, abs(determinant(matrix))]


def verify_fixture(fixture, *, source_commit, source_sha256):
    require(fixture.get("schema") == 1 and isinstance(fixture.get("cases"), list),
            "fixture schema/cases invalid")
    require(isinstance(source_commit, str) and len(source_commit) == 40
            and all(v in "0123456789abcdef" for v in source_commit),
            "source exact SHA missing")
    cases = fixture["cases"]
    require(len(cases) == 6, "expected six source-owned registered specimens")
    records = []
    seen = set()
    result_sets = {}
    for case in cases:
        label = case["id"]
        require(isinstance(label, str) and label not in seen,
                "duplicate or invalid case identifier")
        seen.add(label)
        rows = case["matrix"]
        width = case["columns"]
        require(type(width) is int and 1 <= width <= 3,
                "specimen exceeds independently reviewed dimension")
        require(isinstance(rows, list) and len(rows) <= 2
                and all(isinstance(row, list) and len(row) == width
                        and all(type(x) is int for x in row) for row in rows),
                "invalid bounded integer matrix")
        modulus_list = case["moduli"]
        require(modulus_list == sorted(set(modulus_list))
                and all(type(n) is int and 2 <= n <= 26 for n in modulus_list),
                "modulus cap/uniqueness invalid")
        require(set(case["expected_orders"]) == {str(n) for n in modulus_list},
                "fixture expected-order coverage changed")
        expected_index = str(lattice_index([
            tuple(row[j] for row in rows) for j in range(width)],
            width)) if len(rows) >= width else None
        # For non-full-rank rows, use full-row Smith data only if
        # provided; this adapter checks the explicit finite modular hulls.
        if expected_index is not None:
            require(expected_index == case["ambient_index"],
                    "full-rank ambient index disagrees")
        per_modulus = []
        groups = {}
        for modulus in modulus_list:
            candidate = candidate_hull(rows, width, modulus)
            independent = checked_hull(rows, width, modulus)
            require(candidate == independent,
                    f"independent lattice-index mismatch: {label}/{modulus}")
            require(len(candidate) == case["expected_orders"][str(modulus)],
                    f"source expected order rejected: {label}/{modulus}")
            vectors = [list(edge) for edge in sorted(candidate)]
            groups[modulus] = candidate
            per_modulus.append({
                "modulus": modulus, "order": len(candidate),
                "group_sha256": canonical_digest(vectors),
                "annihilator_profile": annihilator(candidate, modulus),
            })
        result_sets[label] = groups
        records.append({"id": label, "matrix": rows, "columns": width,
                        "checks": per_modulus})
    require({"index5-a1", "index5-a2", "scalar2", "surjective-c13",
             "surjective-c49", "rankzero"} == seen,
            "source-controlled fixture IDs changed")
    by_id = {row["id"]: row for row in records}
    a = by_id["index5-a1"]["matrix"]
    b = by_id["index5-a2"]["matrix"]
    require(arithmetic_signature_2x2(a) ==
            arithmetic_signature_2x2(b) == [1, 1, 1, 5],
            "rank-two arithmetic-matroid data mismatch")
    negative = {}
    for modulus in (5, 10):
        p, q = result_sets["index5-a1"][modulus], result_sets["index5-a2"][modulus]
        require(len(p) == 1 and len(q) == 5,
                f"refuted realization invariance control changed at {modulus}")
        negative[str(modulus)] = {
            "a": [list(v) for v in sorted(p)],
            "a_prime": [list(v) for v in sorted(q)],
        }
    require(len(result_sets["index5-a1"][25]) ==
            len(result_sets["index5-a2"][25]) == 5,
            "prime-power control mismatch at 25")
    return {
        "schema": "HOMELAB-AB-INDEPENDENT-FINITE-REPLAY-1",
        "source_commit": source_commit,
        "source_fixture_sha256": source_sha256,
        "specimens_checked": len(records),
        "finite_modulus_cases": sum(len(row["checks"]) for row in records),
        "checker_methods": [
            "candidate_modular_potential_and_cycles",
            "independent_integer_lattice_index_maximal_minors",
        ],
        "counterexample_to_general_realization_invariance_at_5_and_10":
            negative,
        "records": records,
        "verdict": "finite_specimens_verified",
        "scope": ("six explicit registered finite specimens; original general "
                  "arithmetic realization invariance remains REFUTED"),
        "universal_claim_accepted": False,
        "next_research_obligation": (
            "Investigate proposed surjective essential realizations with m(E)=1; "
            "a finite specimen cannot prove their universal realization invariance."
        ),
    }
