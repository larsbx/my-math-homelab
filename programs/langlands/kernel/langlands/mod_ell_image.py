"""Forcing the image of rho_ell from Frobenius characteristic polynomials alone.

For a good prime p, rho_ell(Frob_p) in GL_2(F_ell) has characteristic polynomial
x^2 - a_p x + p (mod ell), with a_p from a point count; its conjugacy class is determined up to
the scalar/non-scalar ambiguity for repeated roots.  So the image H is a subgroup meeting, for each
observed polynomial chi, the set C_chi of elements with characteristic polynomial chi.

`forced_full(ell, polys)` decides rigorously whether every subgroup meeting all C_chi is GL_2(F_ell),
by a recursion that needs no classification of maximal subgroups: H contains some x_1 in C_1, hence
<x_1>; branching over x_2 in C_2 it contains <x_1, x_2>; and so on.  H is forced to be everything
iff along every branch the generated subgroup reaches GL_2(F_ell) (branches whose subgroup is
already all of G stop; a branch that exhausts the classes without reaching G is a counterexample:
a proper subgroup meeting every observed class, which the image might be).  The first element may
be taken up to conjugacy (the property is conjugation-invariant); subsequent ones range over the
whole class.  Elements are indices into a multiplication table.
"""
from __future__ import annotations

from functools import lru_cache

import numpy as np

from .newforms import RationalNewform

Mat = tuple[int, int, int, int]


class GL2:
    """GL_2(F_ell) on indices, with vectorised (numpy) products: entries as arrays, products by fancy
    indexing through the base-ell code of a matrix.  A full multiplication table (as nested lists) is kept
    for small ell only; everything else works from per-generator product columns."""

    def __init__(self, ell: int, table: bool | None = None) -> None:
        self.ell = p = ell
        # lexicographic (a, b, c, d) order, d fastest: the order of Lean's `gl n`
        grid = np.indices((p, p, p, p)).reshape(4, -1)
        a, b, c, d = (grid[i].astype(np.int64) for i in range(4))
        codes = a + p * (b + p * (c + p * d))
        keep = (a * d - b * c) % p != 0
        self.A, self.B, self.C, self.D = a[keep], b[keep], c[keep], d[keep]
        self.codes = codes[keep]
        self.n = int(keep.sum())
        self.code2idx = np.full(p**4, -1, dtype=np.int64)
        self.code2idx[self.codes] = np.arange(self.n)
        self.elements: list[Mat] = list(zip(self.A.tolist(), self.B.tolist(), self.C.tolist(), self.D.tolist()))
        self.index = {m: i for i, m in enumerate(self.elements)}
        self.one = self.index[(1, 0, 0, 1)]
        self.table = ([self.row(i).tolist() for i in range(self.n)]
                      if (table if table is not None else self.n <= 2016) else None)
        # inverses of every element: adjugate over det^-1 (Fermat: det^(p-2))
        det = (self.A * self.D - self.B * self.C) % p
        u = np.array([pow(int(x), p - 2, p) for x in range(p)])[det]
        self.inv_all = self._idx((u * self.D) % p, (u * (p - self.B)) % p, (u * (p - self.C)) % p, (u * self.A) % p)

    # ---- elementwise products on index arrays ----
    def _idx(self, a, b, c, d) -> np.ndarray:
        return self.code2idx[a + self.ell * (b + self.ell * (c + self.ell * d))]

    def mul_vec(self, X, Y) -> np.ndarray:
        """index of X[k] * Y[k] for all k (X, Y index arrays, broadcastable)."""
        p = self.ell
        a, b, c, d = self.A[X], self.B[X], self.C[X], self.D[X]
        e, f, g, h = self.A[Y], self.B[Y], self.C[Y], self.D[Y]
        return self._idx((a * e + b * g) % p, (a * f + b * h) % p, (c * e + d * g) % p, (c * f + d * h) % p)

    def _mul(self, x: Mat, y: Mat) -> Mat:
        p = self.ell
        return ((x[0] * y[0] + x[1] * y[2]) % p, (x[0] * y[1] + x[1] * y[3]) % p,
                (x[2] * y[0] + x[3] * y[2]) % p, (x[2] * y[1] + x[3] * y[3]) % p)

    def _inv(self, m: Mat) -> Mat:
        u = pow((m[0] * m[3] - m[1] * m[2]) % self.ell, -1, self.ell)
        return tuple((u * e) % self.ell for e in (m[3], -m[1], -m[2], m[0]))

    def mul(self, i: int, j: int) -> int:
        return self.table[i][j] if self.table is not None else int(self.mul_vec(np.int64(i), np.int64(j)))

    def column(self, g: int) -> np.ndarray:
        """[index of x*g for every x] (the kernel's `column`)."""
        return self.mul_vec(np.arange(self.n), np.int64(g))

    def row(self, g: int) -> np.ndarray:
        """[index of g*x for every x]."""
        return self.mul_vec(np.int64(g), np.arange(self.n))

    # ---- invariants and classes ----
    def charpoly(self, i: int) -> tuple[int, int]:
        a, b, c, d = self.elements[i]
        return ((a + d) % self.ell, (a * d - b * c) % self.ell)  # (trace, det): x^2 - t x + d

    def with_charpoly(self, chi: tuple[int, int]) -> tuple[int, ...]:
        t, d = chi
        mask = ((self.A + self.D) % self.ell == t) & ((self.A * self.D - self.B * self.C) % self.ell == d)
        return tuple(np.flatnonzero(mask).tolist())

    def conjugates(self, x: int) -> frozenset[int]:
        c = np.arange(self.n)
        return frozenset(np.unique(self.mul_vec(self.mul_vec(c, np.int64(x)), self.inv_all)).tolist())

    def conjugator_map(self, x: int) -> dict[int, int]:
        """{c x c^-1 : c} with one conjugator per conjugate (the first in index order)."""
        c = np.arange(self.n)
        g = self.mul_vec(self.mul_vec(c, np.int64(x)), self.inv_all)
        u, first = np.unique(g, return_index=True)
        return dict(zip(u.tolist(), c[first].tolist()))

    def conjugacy_class_representatives(self, elements: tuple[int, ...]) -> list[int]:
        seen, reps = set(), []
        for x in elements:
            if x in seen:
                continue
            reps.append(x)
            seen.update(self.conjugates(x))
        return reps

    def is_conjugation_invariant(self, elements: tuple[int, ...]) -> bool:
        S = frozenset(elements)
        return all(self.conjugates(x) <= S for x in S)

    # ---- closures ----
    def closure_mask(self, cols: list[np.ndarray], start: list[int]) -> np.ndarray:
        """Boolean mask of the closure of `start` under right multiplication by the generators of `cols`."""
        seen = np.zeros(self.n, dtype=bool)
        frontier = np.unique(np.array(start, dtype=np.int64))
        seen[frontier] = True
        while frontier.size and cols:  # no generators: the closure is the start set itself
            cand = np.unique(np.concatenate([col[frontier] for col in cols]))
            cand = cand[~seen[cand]]
            seen[cand] = True
            frontier = cand
        return seen

    def generated(self, gens: frozenset[int]) -> frozenset[int]:
        if self.table is None:
            mask = self.closure_mask([self.column(g) for g in gens], [self.one, *gens])
            return frozenset(np.flatnonzero(mask).tolist())
        seen = {self.one, *gens}
        frontier, gl = list(seen), list(gens)
        while frontier:
            new = [z for x in frontier for g in gl if (z := self.table[x][g]) not in seen]
            seen.update(new)
            frontier = new
        return frozenset(seen)

    def generates_full(self, cols: list[np.ndarray], start: list[int]) -> bool:
        return bool(self.closure_mask(cols, start).all())

    def words_to(self, gens: list[int], targets: list[int]) -> dict[int, list[int]]:
        """Shortest nonempty words (letters = generator positions, read left to right) in the given generators
        reaching each target, or an empty list if unreachable; the kernel evaluates them with `evalWord`.
        Bidirectional breadth-first search: forward from the generators (the words of length 1), backward from
        each target through the inverse generators, always expanding the smaller frontier, so a word of length
        L costs about 2·2^(L/2) visits instead of 2^L ≈ |G|, and every layer costs its own size, not |G|."""
        if not gens:
            return {t: [] for t in targets}
        n = self.n
        gs = [np.int64(g) for g in gens]
        igs = [np.int64(self.inv_all[g]) for g in gens]

        def expand(front, cs, seen, parent, letter):  # work proportional to the frontier, never to |G|
            cand = np.concatenate([self.mul_vec(front, g) for g in cs])
            src = np.concatenate([front] * len(cs))
            let = np.repeat(np.arange(len(cs)), front.size)
            fresh = ~seen[cand]
            new, first = np.unique(cand[fresh], return_index=True)
            parent[new] = src[fresh][first]
            letter[new] = let[fresh][first]
            seen[new] = True
            return new

        fparent, fletter = np.full(n, -1, dtype=np.int64), np.full(n, -1, dtype=np.int64)
        fseen = np.zeros(n, dtype=bool)
        ffront = np.unique(np.array(gens, dtype=np.int64))
        fseen[ffront] = True
        for i, g in enumerate(gens):
            fletter[g] = i
        out = {}
        for t in targets:
            # The shared forward search is a complete BFS ball. Expanding whole layers until
            # the first intersection preserves shortest length even when that ball is reused.
            bparent, bletter = np.full(n, -1, dtype=np.int64), np.full(n, -1, dtype=np.int64)
            bseen = np.zeros(n, dtype=bool)
            bseen[t] = True
            bfront = np.array([t], dtype=np.int64)
            meet = t if fseen[t] else -1
            while meet < 0 and (ffront.size or bfront.size):
                if bfront.size == 0 or (ffront.size and ffront.size <= bfront.size):
                    ffront = expand(ffront, gs, fseen, fparent, fletter)
                    hits = ffront[bseen[ffront]]
                else:
                    bfront = expand(bfront, igs, bseen, bparent, bletter)
                    hits = bfront[fseen[bfront]]
                if hits.size:
                    meet = int(hits[0])
            if meet < 0:
                out[t] = []
                continue
            head, x = [], meet
            while x != -1:  # back to a generator: the forward half, reversed
                head.append(int(fletter[x]))
                x = int(fparent[x])
            tail, x = [], meet
            while x != t:  # x · g_letter = bparent[x]: the backward half, in reading order
                tail.append(int(bletter[x]))
                x = int(bparent[x])
            out[t] = head[::-1] + tail
        return out


def forced_full_classes(G: GL2, classes: list[tuple[int, ...]]) -> bool:
    """True iff every subgroup of G meeting each of the given element sets is G.  Branches carry the
    small list of generators chosen so far; the subgroup they generate is the state.

    The first set is reduced to conjugacy-class representatives only when *every* set is closed under
    conjugation (then "H meets all sets" is invariant under H -> cHc^-1); otherwise every element of the
    first set is tried, which is always sound."""
    full = frozenset(range(G.n))

    @lru_cache(maxsize=None)
    def forced(H: frozenset[int], gens: tuple[int, ...], k: int) -> bool:
        if H == full:
            return True
        if k == len(classes):
            return False
        # distinct next states only: many x give the same subgroup
        nxt = {}
        for x in classes[k]:
            if x in H:
                nxt.setdefault(H, gens)
            else:
                nxt.setdefault(G.generated(frozenset(gens + (x,))), gens + (x,))
        return all(forced(H2, g2, k + 1) for H2, g2 in nxt.items())

    if not classes:
        return False
    firsts = (G.conjugacy_class_representatives(classes[0]) if all(G.is_conjugation_invariant(c) for c in classes)
              else list(classes[0]))
    return all(forced(G.generated(frozenset({x})), (x,), 1) for x in firsts)


def forced_full(ell: int, polys: tuple[tuple[int, int], ...]) -> bool:
    """True iff every subgroup of GL_2(F_ell) meeting each class {charpoly = chi}, chi in polys, is GL_2(F_ell).
    Classes are visited in decreasing order of the element order (large cyclic subgroups first): the
    answer does not depend on the order, the running time does."""
    G = GL2(ell)
    classes = [G.with_charpoly(chi) for chi in dict.fromkeys(polys)]
    classes.sort(key=lambda c: -len(G.generated(frozenset({c[0]}))))
    return forced_full_classes(G, classes)


def frobenius_charpolys(f: RationalNewform, ell: int, bound: int) -> tuple[tuple[int, int], ...]:
    """(a_p mod ell, p mod ell) for the good primes p <= bound, p != ell."""
    primes = [p for p in range(2, bound + 1) if all(p % d for d in range(2, int(p**0.5) + 1))]
    return tuple((f.a(p) % ell, p % ell) for p in primes if p not in (ell, f.conductor))
