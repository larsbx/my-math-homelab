"""
bd_exact.py — EXACT Barge–Diamond transition complex G0^ER per BBJS/BD3 convention.

Convention (Barge–Bruin–Jones–Sadun, Israel J. Math. 188 (2012), §2, read at source
2026-06-12): G has letter edges e_i and transition edges v_ij (one per legal 2-word
a_i a_j); the END of e_i is identified with the BEGINNING of v_ij, and the END of
v_ij with the BEGINNING of e_j.  G0 = the v-edges alone, hence a BIPARTITE graph:
v_ij runs out_i -> in_j, and out_i, in_i are DISTINCT vertices (e_i is not in G0).
Substitution: v_ij -> v_kl with k = last(sigma(i)), l = first(sigma(j)).
G0^ER = eventual range (substitution permutes its edges).  Exact sequence
0 -> H~0(G0^ER) -> lim A^T -> H^1(Omega) -> H^1(G0^ER) -> 0, image of H~0 in the
+1 eigenspace of A^T.  For IRREDUCIBLE Pisot, 1 is not an eigenvalue of A, so
G0^ER must be CONNECTED and dim H^1(Omega) = d + b1(G0^ER); homological Pisot
iff b1 = 0 ("no asymptotic cycles").

Pure functions, exact integer/set arithmetic throughout; no floats.
"""
from __future__ import annotations

import sys
from typing import Iterable

sys.path.insert(0, "/mnt/project")
from psc_core import Substitution  # noqa: E402

Pair = tuple[int, int]


def legal_two_words(s: Substitution) -> frozenset[Pair]:
    """All legal 2-words of L(sigma): closure of internal image pairs under the
    crossing map (a,b) -> (last sigma(a), first sigma(b))."""
    internal = {
        (img[t], img[t + 1])
        for img in s.images
        for t in range(len(img) - 1)
    }
    cross = lambda p: (s.images[p[0]][-1], s.images[p[1]][0])
    S = set(internal)
    while True:
        new = {cross(p) for p in S} - S
        if not new:
            return frozenset(S)
        S |= new


def eventual_range(s: Substitution, edges: frozenset[Pair]) -> frozenset[Pair]:
    """Eventual range of v_ab -> v_{last sigma(a), first sigma(b)}; images are
    nested decreasing, stabilize at the ER where the map is a permutation."""
    cross = lambda p: (s.images[p[0]][-1], s.images[p[1]][0])
    E = edges
    while True:
        nxt = frozenset(cross(p) for p in E)
        if nxt == E:
            return E
        E = nxt


def complex_invariants(er: Iterable[Pair]) -> tuple[int, int, int, int]:
    """(E, V, C, b1) of the bipartite 1-complex: edge (a,b): out_a -- in_b.
    Vertices counted only when incident.  b1 = E - V + C."""
    er = list(er)
    verts = {("out", a) for a, _ in er} | {("in", b) for _, b in er}
    # union-find over incident vertices
    parent = {v: v for v in verts}

    def find(v):
        while parent[v] != v:
            parent[v] = parent[parent[v]]
            v = parent[v]
        return v

    for a, b in er:
        ra, rb = find(("out", a)), find(("in", b))
        if ra != rb:
            parent[ra] = rb
    comps = {find(v) for v in verts}
    E, V, C = len(er), len(verts), len(comps)
    return E, V, C, E - V + C


def er_cycle_lengths(s: Substitution, er: frozenset[Pair]) -> tuple[int, ...]:
    """Cycle type of the substitution permutation on ER edges."""
    cross = lambda p: (s.images[p[0]][-1], s.images[p[1]][0])
    seen, cycles = set(), []
    for p in sorted(er):
        if p in seen:
            continue
        q, n = p, 0
        while q not in seen:
            seen.add(q)
            q, n = cross(q), n + 1
        cycles.append(n)
    return tuple(sorted(cycles))


def bd_profile(s: Substitution) -> dict:
    L2 = legal_two_words(s)
    er = eventual_range(s, L2)
    E, V, C, b1 = complex_invariants(er)
    return {
        "n_two_words": len(L2),
        "er_edges": E,
        "er_vertices": V,
        "components": C,
        "b1": b1,
        "perm_cycles": er_cycle_lengths(s, er),
    }


# ----------------------------------------------------------------------------
# Validation gates (must all pass before corpus use)
# ----------------------------------------------------------------------------

def _gate() -> None:
    # 1. Fibonacci 0->01, 1->0 : irreducible Pisot, PDS; expect C=1, b1=0.
    fib = Substitution(((0, 1), (0,)))
    p = bd_profile(fib)
    assert p["components"] == 1 and p["b1"] == 0, ("fib", p)

    # 2. BBJS asymptotic-cycle example 1->21112, 2->121 (0-indexed):
    #    irreducible degree-2 Pisot, dim H^1 = 3, so b1 = 1, C = 1.
    bbjs_ac = Substitution(((1, 0, 0, 0, 1), (0, 1, 0)))
    p = bd_profile(bbjs_ac)
    assert p["components"] == 1 and p["b1"] == 1, ("bbjs_ac", p)

    # 3. Tribonacci 0->01, 1->02, 2->0 : expect C=1, b1=0.
    trib = Substitution(((0, 1), (0, 2), (0,)))
    p = bd_profile(trib)
    assert p["components"] == 1 and p["b1"] == 0, ("trib", p)

    # 4. BBJS Example 1 (phi_2, 6 letters, cr=3, reducible homological Pisot):
    #    paper states ER has 3 components, each contractible: C=3, b1=0.
    #    a1,a2,a3,b1,b2,b3 -> 0..5.
    phi2 = Substitution((
        (0, 4, 1, 3, 2, 0, 2, 5, 0),
        (1, 3, 2, 5, 0, 2, 0, 4, 1),
        (2, 5, 0, 4, 1, 1, 1, 3, 2),
        (3, 2, 0, 2, 5, 0, 2, 5, 0),
        (4, 1, 1, 1, 3, 2, 0, 4, 1),
        (5, 0, 2, 0, 4, 1, 1, 3, 2),
    ))
    p = bd_profile(phi2)
    assert p["components"] == 3 and p["b1"] == 0, ("bbjs_phi2", p)

    print("GATE PASSED: 4/4 (fib, bbjs_asym_cycle, tribonacci, bbjs_phi2_cr3)")
    for name, sub in (("fib", fib), ("bbjs_ac", bbjs_ac), ("trib", trib), ("phi2", phi2)):
        print(f"  {name}: {bd_profile(sub)}")


if __name__ == "__main__":
    _gate()
