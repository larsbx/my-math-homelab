"""Export exact Python-side data as Lean literals: proof/langlands/LanglandsOracles/Data.lean and DataModL{l}.lean.

Lean re-derives the arithmetic side (class numbers, Eichler's formula, zeta) and certifies
the exported spectral data (Brandt matrices, L-series coefficient vectors) against it.
Deterministic: the test suite regenerates the file and requires it to be unchanged.
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "kernel"))

from langlands.brandt import SupersingularLocus  # noqa: E402
from langlands.gl1 import all_characters, closed_points, l_series  # noqa: E402
from langlands.newforms import newforms_of_level  # noqa: E402
from langlands.ec_function_field import FunctionFieldCurve, monic_irreducibles  # noqa: E402

BRANDT_PRIMES = (11, 13, 17, 19, 23, 29, 31, 37)
BRANDT_ELLS = (2, 3, 5, 7)
GL1_PRIMES = (5, 7)


def lean_list(xs) -> str:
    return "[" + ", ".join(str(x) for x in xs) + "]"


def lean_matrix(M) -> str:
    return "[" + ", ".join(lean_list(M.row(i)) for i in range(M.rows)) + "]"


def brandt_block() -> list[str]:
    out = ["/-- (p, |Aut E_i|, [(ell, B(ell))]) for supersingular loci; B(2), B(3) by Phi_ell, B(5), B(7) by Vélu. -/",
           "def brandtData : List (Nat × List Nat × List (Nat × IMat)) := ["]
    for p in BRANDT_PRIMES:
        L = SupersingularLocus.of(p)
        mats = ", ".join(f"({ell}, {lean_matrix(L.brandt_matrix(ell))})" for ell in BRANDT_ELLS if ell != p)
        out.append(f"  ({p}, {lean_list(L.aut_orders)}, [{mats}]),")
    out[-1] = out[-1].rstrip(",")
    out.append("]")
    return out


def gl1_block() -> list[str]:
    E37 = newforms_of_level(37)[0]
    out = ["/-- (p, a_p, N, [(trivial?, coefficients c_0..c_D of L(chi, T) in Z[Z/N])]) for 37a1 mod p. -/",
           "def lSeriesData : List (Nat × Int × Nat × List (Bool × List (List Int))) := ["]
    for p in GL1_PRIMES:
        E = E37.reduction(p)
        order = 4 if p == 5 else 3
        pts = closed_points(E, order)
        chars = []
        for chi in all_characters(E.structure):
            L = l_series(E, chi, order, pts)
            chars.append(f"({'true' if chi.is_trivial else 'false'}, {lean_list(lean_list(c) for c in L)})")
        out.append(f"  ({p}, {E.trace_of_frobenius}, {E.structure.exponent}, [{', '.join(chars)}]),")
    out[-1] = out[-1].rstrip(",")
    out.append("]")
    return out


FUNCTION_FIELD_CURVES = (
    ("E_t3", FunctionFieldCurve(2, ((0, 1), (), (), (1,), ())), 5),
    ("E_t4", FunctionFieldCurve(2, ((0, 1), (), (0, 0, 1), (1,), (0, 1, 1, 1))), 5),
    ("E3_A", FunctionFieldCurve(3, ((), (0, 0, 1), (), (0, 1), (1,))), 4),
    ("E3_B", FunctionFieldCurve(3, ((), (0, 0, 1), (), (0, 2), (1,))), 4),
)


def function_field_block() -> list[str]:
    """(q, order, [(degree, kind, a)]) per curve: kind 0 good, 1 multiplicative, 2 additive (oo included)."""
    kinds = {"good": 0, "split": 1, "nonsplit": 1, "additive": 2}
    out = ["/-- Local data of elliptic curves over F_q(t): (q, order, [(deg v, kind, a_v)]) for all places of degree <= order. -/",
           "def functionFieldLocalData : List (Nat × Nat × List (Nat × Nat × Int)) := ["]
    for _, E, order in FUNCTION_FIELD_CURVES:
        places = [(f, len(f) - 1) for f in monic_irreducibles(E.p, order)] + [(None, 1)]
        rows = ", ".join(f"({d}, {kinds[E.reduction_type(f)]}, {E.trace_at(f)})" for f, d in places)
        out.append(f"  ({E.p}, {order}, [{rows}]),")
    out[-1] = out[-1].rstrip(",")
    out.append("]")
    return out


def brandt_eigenvector_block() -> list[str]:
    L = SupersingularLocus.of(37)
    v = L.common_eigenvector({2: -2, 3: -3, 5: -2, 7: -1})
    ints = [int(x) for x in v]
    return ["/-- A joint eigenvector of B(2), B(3), B(5), B(7) at p = 37 with eigenvalues (-2, -3, -2, -1): the form 37a. -/",
            f"def brandt37Eigenvector : List Int := {lean_list(ints)}"]


def galois_mod3_block() -> list[str]:
    """rho_3(Frob_p) on 37a1[3] as (a, b, c, d) in GL_2(F_3), for the good primes of ExcursionInstance.lean."""
    from langlands.galois_rep import frobenius_matrix
    E37 = newforms_of_level(37)[0]
    rows = []
    for p in (5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 43, 47, 53, 59, 61):
        M = frobenius_matrix(E37.reduction(p), 3)
        rows.append(f"({p}, {lean_list(M.matrix)})")
    return ["/-- (p, [a, b, c, d]) with rho_3(Frob_p) = [[a, b], [c, d]] on a basis of 37a1[3] over F_{p^k}: computed by Python. -/",
            "def galoisMod3Data : List (Nat × List Nat) := [" + ", ".join(rows) + "]"]


def galois_mod2_block() -> list[str]:
    """Per Cremona curve: (label, [a1,a2,a3,a4,a6], type, rational roots of psi_2 as (num, den), Frobenius
    witnesses (p, [a,b,c,d]) for rho_2(Frob_p) on a computed basis of E[2]); type 0 = S_3, 1 = C_2."""
    from langlands.mod2_image import mod2_image
    from langlands.newforms import CREMONA_PRIME_LEVEL
    rows = []
    for f in CREMONA_PRIME_LEVEL:
        im = mod2_image(f)
        typ = {"S3": 0, "C2": 1}[im.group]
        roots = lean_list(f"({r.numerator}, {r.denominator})" for r in im.rational_roots)
        wits = lean_list(f"({p}, {lean_list(M)})" for cls, (p, M) in sorted(im.witnesses.items()) if cls != "id")
        rows.append(f'("{f.label}", {lean_list(f.a_invariants)}, {typ}, {roots}, {wits})')
    return ["/-- (label, a-invariants, image type (0 = S_3, 1 = C_2), rational roots of psi_2 as (num, den), Frobenius",
            "    witnesses (p, [a, b, c, d]) with rho_2(Frob_p) = [[a, b], [c, d]] on a basis of E[2] over F_{p^k}): Python. -/",
            "def galoisMod2Data : List (String × List Int × Nat × List (Int × Int) × List (Nat × List Nat)) := [",
            "  " + ",\n  ".join(rows) + "]"]


def mod_ell_cert_block(ell: int, zeta: int, bound: int = 60) -> list[str]:
    """Word certificates for ImageModL.lean: S = {E12(1), E21(1), diag(1, zeta)} generates GL_2(F_ell) (a theorem,
    given that zeta generates F_ell^x); a greedy
    cover of the curves by class pairs (A, B) such that every (g, h) in A x B generates (candidate pairs tested
    lazily, most-covering first); for each pair the conjugators of class A onto its first representative and,
    for each h in B, words in {gRep, h} for S, both listed in the lexicographic order of the class (the order of
    Lean's `classMats`), which the kernel walks pointwise."""
    import numpy as np
    from langlands.mod_ell_image import GL2, frobenius_charpolys
    from langlands.newforms import CREMONA_PRIME_LEVEL
    G = GL2(ell)
    full = frozenset(range(G.n))
    S = [G.index[(1, 1, 0, 1)], G.index[(1, 0, 1, 1)], G.index[(1, 0, 0, zeta)]]
    assert G.generated(frozenset(S)) == full
    code = lambda i: (lambda m: m[0] + ell * (m[1] + ell * (m[2] + ell * m[3])))(G.elements[i])
    primes = [p for p in range(2, bound + 1) if all(p % d for d in range(2, int(p**0.5) + 1))]
    curves = {}
    for f in CREMONA_PRIME_LEVEL:
        ps = [p for p in primes if p not in (ell, f.conductor)]
        first = {}
        for p, chi in zip(ps, frobenius_charpolys(f, ell, bound)):
            first.setdefault(chi, p)
        curves[f.label] = (f, first)
    good = sorted({c for _, fr in curves.values() for c in fr if (c[0] ** 2 - 4 * c[1]) % ell})
    classes = {chi: G.with_charpoly(chi) for chi in good}
    words: dict[tuple, dict] = {}  # (A, B) -> {h: words for S in {gRep, h}}, exactly what the kernel checks

    def certified(A, B):
        if (A, B) not in words:
            gA = classes[A][0]
            hs = classes[B]
            found = {}
            for h in [*hs[::max(1, len(hs) // 4)], *hs]:  # a cheap rejection on a sample first, then the whole class
                if h not in found:
                    found[h] = ws = G.words_to([gA, h], S)
                    if not all(ws[s] for s in S):
                        break
            words[(A, B)] = found if len(found) == len(hs) and all(all(ws[s] for s in S) for ws in found.values()) else None
        return words[(A, B)] is not None

    need = set(curves)
    chosen = []
    while need:
        cands = sorted(((A, B) for A in good for B in good if A != B),
                       key=lambda AB: (-len([l for l in need if AB[0] in curves[l][1] and AB[1] in curves[l][1]]), AB))
        best = next(((A, B) for (A, B) in cands
                     if any(A in curves[l][1] and B in curves[l][1] for l in need) and certified(A, B)), None)
        if best is None:
            break  # the remaining curves have no certified pair among their observed classes (e.g. 11a1 mod 5)
        cov = {l for l in need if best[0] in curves[l][1] and best[1] in curves[l][1]}
        chosen.append((best, cov))
        need -= cov
    pair_defs = []
    for k, ((A, B), _) in enumerate(chosen):
        cA, cB = classes[A], classes[B]
        gA = cA[0]
        conj = G.conjugator_map(gA)
        inv = G.inv_all.tolist()
        wit = [f"({code(g)}, {code(conj[g])}, {code(inv[conj[g]])})" for g in cA]
        pack = lambda w: int("1" + "".join(str(i) for i in w), 2)  # leading 1, then the letters; the kernel unpacks it
        rows = [f"({code(h)}, " + lean_list(f"({code(s)}, {pack(ws[s])})" for s in S) + ")"
                for h, ws in ((h, words[(A, B)][h]) for h in cB)]
        pair_defs += ["set_option maxRecDepth 16384 in",
                      f"/-- Mod-{ell} certified class pair {k}: A = (tr {A[0]}, det {A[1]}), B = (tr {B[0]}, det {B[1]}); one declaration per pair so",
                      "    that the kernel checks (and frees) them one at a time. -/",
                      f"noncomputable def mod{ell}Pair{k} : PairCert :=",
                      f"  {{ tA := {A[0]}, dA := {A[1]}, tB := {B[0]}, dB := {B[1]}, gRep := {code(gA)},",
                      f"    witnessesA := {lean_list(wit)},",
                      f"    wordsB := {lean_list(rows)} }}", ""]
    curve_rows = []
    for lab, (f, fr) in curves.items():
        for k, ((A, B), cov) in enumerate(chosen):
            if lab in cov:
                curve_rows.append(f'      {{ label := "{lab}", ainvs := {lean_list(f.a_invariants)}, pair := {k}, p1 := {fr[A]}, p2 := {fr[B]} }}')
                break
    return pair_defs + [
            f"/-- The certified class pairs mod {ell}. -/",
            f"noncomputable def mod{ell}Pairs : List PairCert := {lean_list(f'mod{ell}Pair{k}' for k in range(len(chosen)))}",
            "",
            "set_option maxRecDepth 16384 in",
            f"/-- Mod-{ell} image certificates: S, {len(chosen)} certified class pairs, and the {len(curve_rows)} curves they cover",
            f"    (curves with a rational {ell}-torsion point or an {ell}-isogeny are absent: their image is not full). -/",
            f"noncomputable def mod{ell}Cert : ModLData :=",
            f"  {{ ell := {ell}, zeta := {zeta}, S := {lean_list(code(s) for s in S)}, pairs := mod{ell}Pairs,",
            "    curves := [\n" + ",\n".join(curve_rows) + "] }"]


def trace_block() -> list[str]:
    """(N, k, n, tr T_n on cuspidal weight-k Manin symbols) for gcd(n, N) = 1: weight 2 for N <= 20,
    weights 4 and 6 for N <= 6, weight 12 at level 1."""
    from math import gcd
    from langlands.modular_symbols import ManinSymbolsK
    rows = []
    grid = [(N, 2, 7) for N in range(2, 21)] + [(N, k, 5) for N in range(1, 7) for k in (4, 6)] + [(1, 12, 6)]
    for N, k, nmax in grid:
        M = ManinSymbolsK(N, k)
        for n in range(1, nmax + 1):
            if gcd(n, N) != 1:
                continue
            tr = M.cuspidal_hecke_matrix(n).trace() if M.cuspidal_basis.cols else 0
            assert tr == int(tr)
            rows.append(f"({N}, {k}, {n}, {int(tr)})")
    return ["/-- (N, k, n, tr T_n on cuspidal weight-k Manin symbols): computed by Python (modular_symbols.py). -/",
            "def traceData : List (Nat × Nat × Nat × Int) := [" + ", ".join(rows) + "]"]


MOD_ELL = [(5, 2), (7, 3), (11, 2), (13, 2), (17, 3), (19, 2), (23, 5), (29, 2), (31, 3)]

HEADER = ["-- GENERATED by tools/export_lean_data.py; do not edit.", "import LanglandsOracles.Matrix", "import LanglandsOracles.CertTypes", "", "namespace Oracles", ""]


def render() -> str:
    lines = HEADER + brandt_block() + [""] + brandt_eigenvector_block() + [""] + gl1_block() + [""] + function_field_block() + [""] + galois_mod3_block() + [""] + galois_mod2_block() + [""] + trace_block() + ["", "end Oracles", ""]
    return "\n".join(lines)


def render_mod_ell(ell: int, zeta: int) -> str:
    """The mod-ell certificate in its own module (DataModL{ell}.lean): elaborating one 0.6 MB structure literal
    takes gigabytes, and separate modules elaborate separately and in parallel."""
    return "\n".join(HEADER + mod_ell_cert_block(ell, zeta) + ["", "end Oracles", ""])


def outputs() -> dict:
    base = ROOT / "proof" / "langlands" / "LanglandsOracles"
    out = {base / "Data.lean": render()}
    for ell, zeta in MOD_ELL:
        out[base / f"DataModL{ell}.lean"] = render_mod_ell(ell, zeta)
    return out


if __name__ == "__main__":
    files = outputs()
    if "--check" in sys.argv:
        sys.exit(0 if all(t.exists() and t.read_text() == text for t, text in files.items()) else 1)
    for target, text in files.items():
        target.write_text(text)
        print(f"wrote {target}")
