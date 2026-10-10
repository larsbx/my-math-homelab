"""Independent Python oracle for the exact seed-patch overlap graph over Q(beta).

States are oriented overlaps (top, bottom, t): the top tile [0, l_top) and the
bottom tile [t, t + l_bottom) with nonempty interior intersection, t in Q(beta).
Inflation sends (i, j, t) to the overlapping pairs of children with shifts
beta*t + q - p (q, p the prefix translations of the chosen children).  A
coincidence is (i, i, 0) and is terminal.  Every sign is decided exactly:
elements of Q(beta) are polynomials modulo the irreducible characteristic
cubic, and a sign is certified by refining a rational enclosure of beta until
the interval image excludes zero (which terminates for every nonzero element).

Finiteness of the reachable graph is a theorem (bounded discrepancy); the cap
here is only a fail-closed guard.  Canonical implementation:
kernel/psc/overlap_seed_patch.mojo.

This module is deliberately retained as a separately written oracle. It is
not an alternative production implementation and must not be cited as the
executable source of truth. The implementation-role constants below are
checked against ``docs/catalogues/mathematical_objects.toml``.
"""
from __future__ import annotations

from collections import deque
from fractions import Fraction
from typing import Mapping, Sequence

IMPLEMENTATION_ROLE = "independent-oracle"
CANONICAL_IMPLEMENTATION = "kernel/psc/overlap_seed_patch.mojo"
CATALOGUE_OBJECT_ID = "seed-patch-overlap-automaton"

Letter = int
Substitution = Mapping[Letter, Sequence[Letter]]
Elt = tuple[Fraction, Fraction, Fraction]  # a0 + a1 b + a2 b^2


def charpoly(sigma: Substitution) -> tuple[int, int, int]:
    """(T, U, D) with chi(x) = x^3 - T x^2 + U x - D for the incidence matrix."""
    d = len(sigma)
    if d != 3:
        raise ValueError("overlap graph oracle supports three letters")
    M = [[sum(1 for x in sigma[j + 1] if x == i + 1) for j in range(3)] for i in range(3)]
    T = M[0][0] + M[1][1] + M[2][2]
    U = (M[0][0] * M[1][1] - M[0][1] * M[1][0]) + (M[0][0] * M[2][2] - M[0][2] * M[2][0]) + (M[1][1] * M[2][2] - M[1][2] * M[2][1])
    D = (M[0][0] * (M[1][1] * M[2][2] - M[1][2] * M[2][1]) - M[0][1] * (M[1][0] * M[2][2] - M[1][2] * M[2][0]) + M[0][2] * (M[1][0] * M[2][1] - M[1][1] * M[2][0]))
    return T, U, D


class Field:
    """Q(beta) for a monic irreducible cubic x^3 - T x^2 + U x - D."""

    def __init__(self, T: int, U: int, D: int):
        self.T, self.U, self.D = T, U, D
        f = lambda x: x ** 3 - T * x ** 2 + U * x - D
        lo, hi = Fraction(1), Fraction(2 + max(abs(T), abs(U), abs(D)))
        if not (f(lo) <= 0 < f(hi)):
            # Perron root of a primitive matrix exceeds 1; bracket from 0 if needed
            lo = Fraction(0)
        assert f(lo) < 0 < f(hi), "no sign change bracket for the Perron root"
        self.lo, self.hi, self.f = lo, hi, f

    zero: Elt = (Fraction(0), Fraction(0), Fraction(0))
    one: Elt = (Fraction(1), Fraction(0), Fraction(0))
    beta: Elt = (Fraction(0), Fraction(1), Fraction(0))

    def add(self, x: Elt, y: Elt) -> Elt:
        return (x[0] + y[0], x[1] + y[1], x[2] + y[2])

    def sub(self, x: Elt, y: Elt) -> Elt:
        return (x[0] - y[0], x[1] - y[1], x[2] - y[2])

    def mul(self, x: Elt, y: Elt) -> Elt:
        # Optimization: unroll the loops to avoid list allocations and overhead
        x0, x1, x2 = x
        y0, y1, y2 = y
        c0 = x0 * y0
        c1 = x0 * y1 + x1 * y0
        c2 = x0 * y2 + x1 * y1 + x2 * y0
        c3 = x1 * y2 + x2 * y1
        c4 = x2 * y2

        # reduce b^4 then b^3 using b^3 = T b^2 - U b + D
        if c4:
            c3 += self.T * c4
            c2 -= self.U * c4
            c1 += self.D * c4

        if c3:
            c2 += self.T * c3
            c1 -= self.U * c3
            c0 += self.D * c3

        return (c0, c1, c2)

    def inv(self, x: Elt) -> Elt:
        """Solve mult-by-x (a Q-linear map) = 1 by Gaussian elimination."""
        cols = [self.mul(x, e) for e in (self.one, self.beta, (Fraction(0), Fraction(0), Fraction(1)))]
        A = [[cols[j][i] for j in range(3)] + [Fraction(1 if i == 0 else 0)] for i in range(3)]
        for c in range(3):
            p = next(r for r in range(c, 3) if A[r][c] != 0)
            A[c], A[p] = A[p], A[c]
            piv = A[c][c]
            A[c] = [v / piv for v in A[c]]
            for r in range(3):
                if r != c and A[r][c]:
                    fac = A[r][c]
                    A[r] = [a - fac * b for a, b in zip(A[r], A[c])]
        return (A[0][3], A[1][3], A[2][3])

    def sign(self, x: Elt) -> int:
        if not any(x):
            return 0
        while True:
            lo, hi = self.lo, self.hi
            # bound the polynomial on [lo,hi]: monotone pieces suffice after refinement,
            # so use the crude interval extension and refine until it excludes zero
            a1 = x[1]; a2 = x[2]
            m1 = min(a1 * lo, a1 * hi); M1 = max(a1 * lo, a1 * hi)
            sq = sorted((lo * lo, hi * hi))
            m2 = min(a2 * sq[0], a2 * sq[1]); M2 = max(a2 * sq[0], a2 * sq[1])
            low = x[0] + m1 + m2; high = x[0] + M1 + M2
            if low > 0:
                return 1
            if high < 0:
                return -1
            mid = (lo + hi) / 2
            if self.f(mid) < 0:
                self.lo = mid
            else:
                self.hi = mid

    def eq(self, x: Elt, y: Elt) -> bool:
        return x == y


def left_perron_lengths(sigma: Substitution, F: Field) -> list[Elt]:
    """A positive left Perron eigenvector l (l^T M = beta l^T) over Q(beta), l_1 = 1."""
    M = [[sum(1 for x in sigma[j + 1] if x == i + 1) for j in range(3)] for i in range(3)]
    # unknowns l0,l1,l2 with sum_i l_i M[i][j] = beta l_j; set l0 = 1, solve 2 equations
    b = F.beta
    q = lambda n: (Fraction(n), Fraction(0), Fraction(0))
    # equations for j=0,1: sum_i l_i M[i][j] - beta l_j = 0
    rows = []
    for j in range(2):
        coef = [q(M[i][j]) for i in range(3)]
        coef[j] = F.sub(coef[j], b)
        rows.append(coef)
    # solve for l1,l2 given l0=1: rows: c0*1 + c1 l1 + c2 l2 = 0
    a11, a12, r1 = rows[0][1], rows[0][2], F.sub(F.zero, rows[0][0])
    a21, a22, r2 = rows[1][1], rows[1][2], F.sub(F.zero, rows[1][0])
    det = F.sub(F.mul(a11, a22), F.mul(a12, a21))
    inv = F.inv(det)
    l1 = F.mul(inv, F.sub(F.mul(r1, a22), F.mul(a12, r2)))
    l2 = F.mul(inv, F.sub(F.mul(a11, r2), F.mul(r1, a21)))
    lengths = [F.one, l1, l2]
    # verify all three eigen-equations and positivity
    for j in range(3):
        lhs = F.zero
        for i in range(3):
            lhs = F.add(lhs, F.mul(q(M[i][j]), lengths[i]))
        assert lhs == F.mul(b, lengths[j]), "left eigenvector check failed"
    assert all(F.sign(l) > 0 for l in lengths), "left eigenvector not positive"
    return lengths


class OverlapGraph:
    def __init__(self, sigma: Substitution, max_states: int = 20000):
        self.sigma = {a: tuple(sigma[a]) for a in sigma}
        self.F = Field(*charpoly(sigma))
        self.l = left_perron_lengths(sigma, self.F)
        F = self.F
        self.prefix = {}
        for a in (1, 2, 3):
            cur = F.zero
            for idx, c in enumerate(self.sigma[a]):
                self.prefix[(a, idx)] = cur
                cur = F.add(cur, self.l[c - 1])
            assert cur == F.mul(F.beta, self.l[a - 1])
        self.max_states = max_states
        self.states: list[tuple[int, int, Elt]] = []
        self.index: dict[tuple[int, int, Elt], int] = {}
        self.adj: list[list[int]] = []
        self.capped = False
        self._build()

    def overlaps(self, s: tuple[int, int, Elt]) -> bool:
        top, bot, t = s
        F = self.F
        return F.sign(F.add(t, self.l[bot - 1])) > 0 and F.sign(F.sub(t, self.l[top - 1])) < 0

    def children(self, s: tuple[int, int, Elt]) -> list[tuple[int, int, Elt]]:
        top, bot, t = s
        F = self.F
        bt = F.mul(F.beta, t)
        out = []
        for i, ct in enumerate(self.sigma[top]):
            p = self.prefix[(top, i)]
            for j, cb in enumerate(self.sigma[bot]):
                q = self.prefix[(bot, j)]
                child = (ct, cb, F.sub(F.add(bt, q), p))
                if self.overlaps(child):
                    out.append(child)
        return out

    def seeds(self) -> list[tuple[int, int, Elt]]:
        F = self.F
        out = []
        for a in (1, 2, 3):
            for b in range(a + 1, 4):
                tops = [(a, F.zero), (b, self.l[a - 1])]
                bots = [(b, F.zero), (a, self.l[b - 1])]
                for ta, xa in tops:
                    for tb, xb in bots:
                        s = (ta, tb, F.sub(xb, xa))
                        if self.overlaps(s):
                            out.append(s)
        return out

    @staticmethod
    def is_coincidence(s: tuple[int, int, Elt]) -> bool:
        return s[0] == s[1] and not any(s[2])

    def _build(self) -> None:
        queue = deque(self.seeds())
        while queue:
            s = queue.popleft()
            if s in self.index:
                continue
            if len(self.states) >= self.max_states:
                self.capped = True
                return
            self.index[s] = len(self.states)
            self.states.append(s)
            self.adj.append([])
            if self.is_coincidence(s):
                continue
            queue.extend(self.children(s))
        for k, s in enumerate(self.states):
            if self.is_coincidence(s):
                continue
            self.adj[k] = [self.index[c] for c in self.children(s)]

    def nonproductive(self) -> list[int]:
        if self.capped:
            raise RuntimeError("productivity undefined on a capped graph")
        good = [self.is_coincidence(s) for s in self.states]
        changed = True
        while changed:
            changed = False
            for k in range(len(self.states)):
                if not good[k] and any(good[c] for c in self.adj[k]):
                    good[k] = True
                    changed = True
        return [k for k in range(len(self.states)) if not good[k]]


def first_depths(g: "OverlapGraph", is_target) -> list[int]:
    """Shortest number of inflations from each vertex to a target vertex (-1 if none).

    Fails closed on a capped partial graph, like the canonical Mojo kernel."""
    from collections import deque as _dq

    if g.capped:
        raise RuntimeError("first-target depths are undefined on a capped graph")
    n = len(g.states)
    dist = [-1] * n
    parents: list[list[int]] = [[] for _ in range(n)]
    for k in range(n):
        for c in g.adj[k]:
            parents[c].append(k)
    q = _dq()
    for k, s in enumerate(g.states):
        if is_target(s):
            dist[k] = 0
            q.append(k)
    while q:
        k = q.popleft()
        for p in parents[k]:
            if dist[p] < 0:
                dist[p] = dist[k] + 1
                q.append(p)
    return dist


def first_coincidence_depths(g: "OverlapGraph") -> list[int]:
    """Shortest number of inflations from each vertex to a coincidence (-1 if none)."""
    return first_depths(g, g.is_coincidence)


def is_left_aligned(s: tuple[int, int, Elt]) -> bool:
    """Offset zero: the two tiles share their left endpoint (coincidences included)."""
    return not any(s[2])


def is_right_aligned(g: "OverlapGraph", s: tuple[int, int, Elt]) -> bool:
    """The two tiles share their right endpoint: t = l_i - l_j (coincidences included)."""
    return g.F.eq(s[2], g.F.sub(g.l[s[0] - 1], g.l[s[1] - 1]))


def first_left_aligned_depths(g: "OverlapGraph") -> list[int]:
    """Least m such that a vertex has a level-m descendant of offset zero.

    By the boundary-coincidence criterion this is the least m at which a
    sub-tile of the inflated top tile and a sub-tile of the inflated bottom
    tile have the same left endpoint."""
    return first_depths(g, is_left_aligned)


def strong_coincidence_depths(
    g: "OverlapGraph", suffix: bool = False, depths: list[int] | None = None
) -> dict[tuple[int, int], int]:
    """First-coincidence depth of every endpoint-aligned non-coincidence vertex.

    Left-aligned vertices (i, j, 0) are productive iff the pair {i, j} is
    eventually coincident (prefix strong coincidence); right-aligned ones iff
    it is eventually coincident for the reversed substitution.  The graph is
    seeded with one orientation per unordered pair, and exchanging the two
    tilings preserves depths, so each pair is reported in whichever
    orientation occurs.  -1 if never.  `depths`, if given, must be
    `first_coincidence_depths(g)` (fails closed on a capped graph either way)."""
    depth = first_coincidence_depths(g) if depths is None else depths
    if g.capped or len(depth) != len(g.states):
        raise RuntimeError("strong-coincidence depths need the full coincidence depth vector")
    aligned = (lambda s: is_right_aligned(g, s)) if suffix else is_left_aligned
    return {(s[0], s[1]): depth[k] for k, s in enumerate(g.states)
            if aligned(s) and not g.is_coincidence(s)}
