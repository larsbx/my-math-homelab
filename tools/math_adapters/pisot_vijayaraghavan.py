"""Independent finite integer Hankel-rank calibration for the PV research programme.

Extracts only literal recurrence specimens from the source's test_hankel.py
AST (never imports or executes source code) and inspects the source claim
ledger at a single immutable source SHA.

Two exact methods:
  1. Direct linear-recurrence construction vs companion-matrix state updates;
  2. Leibniz-permutation determinant vs fraction-free Bareiss elimination.
An exact rational Gaussian solver independently recovers recurrence coefficients
from nonsingular Hankel windows.

All findings are finite checks of the seven declared seed sequences; they are
NOT proofs of PV algebraicity, a general Hankel-rank theorem, or a resolution
of the open coprime-tail branch.
"""
from __future__ import annotations

import ast
from fractions import Fraction
from itertools import permutations
import re
import tomllib


def require(ok, why):
    if not ok:
        raise ValueError(why)


def input_specimens(test_source):
    """AST literal extraction; no arbitrary source code execution."""
    tree = ast.parse(test_source)
    selected = None
    for node in tree.body:
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and (
                node.name == "test_overlap_coefficients_are_stable_and_det_ratio_matches"):
            for d in node.decorator_list:
                if isinstance(d, ast.Call) and len(d.args) >= 2 and (
                        getattr(d.func, "attr", None) == "parametrize"):
                    selected = ast.literal_eval(d.args[1])
    require(isinstance(selected, list) and len(selected) == 7,
            "expected seven explicit finite test cases")
    examples = []
    seen = set()
    for initial, coefficients in selected:
        require(isinstance(initial, list) and isinstance(coefficients, list)
                and len(initial) == len(coefficients)
                and 1 <= len(initial) <= 4
                and all(type(v) is int for v in initial+coefficients),
                "invalid integer recurrence specimen")
        k = (tuple(initial), tuple(coefficients))
        require(k not in seen, "duplicate recurrence specimen")
        seen.add(k)
        examples.append(k)
    require(((2, 1), (1, 1)) in seen and
            ((3, 3, 9), (1, 0, 3)) in seen,
            "missing Lucas/cubic Hankel negative controls")
    return examples


def recurrence_sequence(initial, coefficients, length):
    r = len(coefficients)
    require(len(initial) == r and length >= r and length <= 50, "invalid finite cap")
    seq = list(initial)
    while len(seq) < length:
        seq.append(sum(coefficients[j] * seq[len(seq)-r+j]
                       for j in range(r)))
    return seq


def companion_sequence(initial, coefficients, length):
    r = len(coefficients)
    state = list(initial)
    seq = list(initial)
    while len(seq) < length:
        shifted = state[1:] + [sum(c*x for c,x in zip(coefficients,state))]
        state = shifted
        seq.append(state[-1])
    return seq


def hankel(seq, n, r):
    require(type(r) is int and r >= 1 and n >= 0
            and n+2*r-2 < len(seq), "Hankel window outside exact finite data")
    return [[seq[n+i+j] for j in range(r)] for i in range(r)]


def leibniz_det(matrix):
    n = len(matrix)
    require(all(len(row) == n for row in matrix), "nonsquare matrix")
    if not n:
        return 1
    s = 0
    for p in permutations(range(n)):
        inversions = sum(p[i] > p[j] for i in range(n) for j in range(i+1,n))
        v = 1
        for i,j in enumerate(p):
            v *= matrix[i][j]
        s += -v if inversions % 2 else v
    return s


def bareiss_det(matrix):
    n = len(matrix)
    require(all(len(row) == n for row in matrix), "nonsquare matrix")
    if n <= 1:
        return matrix[0][0] if n else 1
    a = [list(row) for row in matrix]
    old = 1
    parity = 1
    for k in range(n-1):
        pivot = next((i for i in range(k,n) if a[i][k]),None)
        if pivot is None:
            return 0
        if pivot != k:
            a[k],a[pivot] = a[pivot],a[k]
            parity = -parity
        q = a[k][k]
        for i in range(k+1,n):
            for j in range(k+1,n):
                numerator = a[i][j]*q - a[i][k]*a[k][j]
                require(numerator % old == 0, "nonintegral Bareiss quotient")
                a[i][j] = numerator//old
            a[i][k] = 0
        old = q
    return parity*a[-1][-1]


def recover_coefficients(seq, shift, order):
    """Independent exact rational elimination of Hankel recurrence."""
    A = [[Fraction(seq[shift+i+j]) for j in range(order)]
         + [Fraction(seq[shift+i+order])] for i in range(order)]
    for j in range(order):
        pivot = next((i for i in range(j,order) if A[i][j]),None)
        require(pivot is not None, "singular Hankel pivot")
        A[j],A[pivot] = A[pivot],A[j]
        scale = A[j][j]
        A[j] = [v/scale for v in A[j]]
        for i in range(order):
            if i != j:
                factor = A[i][j]
                A[i] = [a-factor*b for a,b in zip(A[i],A[j])]
    return tuple(row[-1] for row in A)


def verify_pv_finite(test_source, claims_source, *,
                     source_commit, source_sha256):
    require(re.fullmatch(r"[0-9a-f]{40}", source_commit or "") is not None,
            "source SHA invalid")
    require(set(source_sha256) == {"test_hankel", "claims"}
            and all(re.fullmatch(r"[0-9a-f]{64}", v or "")
                    for v in source_sha256.values()), "source blob digests missing")
    claims = tomllib.loads(claims_source)
    status = {c["id"]:c["status"] for c in claims["claim"]}
    require(status["PV-HANKEL-RANK-BRIDGE"] == "PROVED"
            and status["PV-COPRIME-TAIL"] == "OPEN"
            and status["PV-THREE-STATE-MINIMAL"] == "WITHDRAWN",
            "source mathematical claim boundary drift")
    records = []
    for initial,coeffs in input_specimens(test_source):
        r = len(coeffs)
        terms = recurrence_sequence(initial,coeffs,36)
        require(terms == companion_sequence(initial,coeffs,36),
                "independent sequence construction mismatch")
        first = None
        for n in range(20):
            low = hankel(terms,n,r)
            upper = hankel(terms,n,r+1)
            d1 = leibniz_det(low)
            d2 = bareiss_det(low)
            e1 = leibniz_det(upper)
            e2 = bareiss_det(upper)
            require(d1 == d2 and e1 == e2, "independent determinant disagreement")
            require(d1 != 0 and e1 == 0,
                    "finite Hankel rank profile invalid")
            if first is None:
                first = d1
            if n < 19:
                require(bareiss_det(hankel(terms,n+1,r)) ==
                        (-1)**(r-1)*coeffs[0]*d1,
                        "finite determinant transport discrepancy")
        for n in (0,5,10):
            require(recover_coefficients(terms,n,r) ==
                    tuple(map(Fraction,coeffs)),
                    "independent Hankel recurrence reconstruction mismatch")
        if initial == (2,1):
            require(all(bareiss_det(hankel(terms,n,2)) ==
                        5*(-1)**n for n in range(20)),
                    "Lucas signed nonvanishing fixture mismatch")
        if initial == (3,3,9):
            require(all(bareiss_det(hankel(terms,n,3)) == -135
                        for n in range(20)), "cubic Hankel identity mismatch")
        records.append({"order":r,"initial":list(initial),
                        "coefficients":list(coeffs),
                        "first_nonzero_hankel":first,
                        "verified_shifts":20,
                        "recurrence_recovered_shifts":[0,5,10]})
    return {
        "schema":"HOMELAB-PV-INDEPENDENT-FINITE-HANKEL-1",
        "source_revision":source_commit,
        "source_sha256":source_sha256,
        "specimens":len(records),
        "verified_hankel_windows":len(records)*20,
        "methods":[
            "exact_leibniz_permutation_determinants",
            "independent_fraction_free_bareiss_determinants",
            "independent_companion_state_and_fractional_gaussian_reconstruction",
        ],
        "records":records,
        "verdict":"finite_pv_hankel_specimens_replayed",
        "general_pv_problem_proved":False,
        "coprime_tail_problem_solved":False,
        "claim_status_changes":[],
        "next_research_obligation":
            "Study bounded-gcd AABB transient patterns and the coprime-tail "
            "mesoscopic branch without turning finite Hankel window checks "
            "into the general PV theorem.",
    }
