"""Independent check of Theorem E's proof skeleton (docs/p1a-a1-prime-2026-10-05.md §3b).

Prototype oracle (Python, exact integers only), kept as provenance; the
canonical regression is kernel/tests/test_a1_normal_form.mojo. It checks the
*explicit* witness positions the three lemmas name -- it does not search -- so
it tests the proofs, not just the conclusion.

1. Lemmas L_BC, L_D (level 2) and L_A (level 3): at every |det M| = 2 point of
   their regions, PIP or not, the named position is a shared tile.
2. The two Pisot necessary conditions f(1) < 0 and f(-1) < 0, with f the
   characteristic polynomial, are affine in (p, q, r), and every PIP point
   satisfies them.
3. The PIP points outside the lemma regions are exactly the 27 listed.
"""
import itertools
import sys

sys.path.insert(0, "reference")
from psc_research.pip_screen import mat, charpoly, primitive, irreducible, pisot

X, C, Y = 1, 2, 3  # pip_screen letters are 1-based
NAME = {X: "x", C: "c", Y: "y"}


def sigma_of(p, q, r, sx, sc, t, sy):
    return {X: (X,) + (Y,) * p + (sx,), C: (C,) + (Y,) * q + (sc,), Y: (t,) + (Y,) * r + (sy,)}


def apply(sig, w):
    return tuple(a for b in w for a in sig[b])


def level(sig, n, letter):
    w = (letter,)
    for _ in range(n):
        w = apply(sig, w)
    return w


def parikh(w):
    v = [0, 0, 0]
    for a in w:
        v[a - 1] += 1
    return tuple(v)


def shared_tile_at(sig, n, s):
    """Is position s of sigma^n(x) and sigma^n(c) a shared tile?"""
    u, w = level(sig, n, X), level(sig, n, C)
    return s < len(u) and s < len(w) and parikh(u[:s]) == parikh(w[:s]) and u[s] == w[s]


def det3(M):
    return (M[0][0] * (M[1][1] * M[2][2] - M[1][2] * M[2][1])
            - M[0][1] * (M[1][0] * M[2][2] - M[1][2] * M[2][0])
            + M[0][2] * (M[1][0] * M[2][1] - M[1][1] * M[2][0]))


def f_at(M, t):
    return det3([[(t if i == j else 0) - M[i][j] for j in range(3)] for i in range(3)])


def is_pip(M):
    T, U, D = charpoly(M)
    return primitive(M) and irreducible(T, U, D) and pisot(T, U, D)


# The four classes, one of each mirror pair under x <-> c.
CLASSES = {
    "A": (X, X, X, C),  # sigma(y) = x y^r c
    "B": (X, X, C, X),  # sigma(y) = c y^r x
    "C": (X, X, C, C),  # sigma(y) = c y^r c
    "D": (C, X, C, C),  # sigma(x) = x y^p c
}


def lemma_position(cls, p, q, r):
    """(level, position) of the lemma's named witness, or None outside its region."""
    if cls in ("B", "C"):
        sy = CLASSES[cls][3]
        if p > q and ((r >= 1 and q >= 1) or (r == 0 and q == 0 and sy == X)):
            return 2, (p + 2) + q * (r + 2) + 1
        return None
    if cls == "D":
        if abs(p - q) == 1 and min(p, q) >= 1 and r >= 2:
            return 2, (p + 3) if p == q + 1 else (p + 4)
        return None
    if cls == "A":
        if not (p > q and abs(r - q) == 1):
            return None
        if r == q + 1:
            if p == q + 1 and q == 0:
                return None
            return 3, p + q + 6 + q * (r + 2)
        if p > q + 1 and q in (1, 2):
            return None
        return 3, p + q + 5 + q * (r + 2)
    raise ValueError(cls)


RESIDUAL = {
    "A": [(1, 0, 1), (4, 2, 1), (5, 2, 1)],
    "B": [(n, 0, 1) for n in range(1, 12)] + [(2, 1, 0)],
    "C": [(1, 0, 0), (3, 1, 0), (5, 2, 0), (7, 3, 0)],
    "D": [(1, 0, 0), (1, 0, 1), (1, 0, 2), (2, 1, 0), (2, 1, 1), (3, 2, 0), (3, 2, 1), (4, 3, 1)],
}


def main(bound):
    total_lemma = 0
    total_pip = 0
    for cls, e in CLASSES.items():
        lemma_ok = lemma_bad = 0
        residual = []
        for p, q, r in itertools.product(range(bound + 1), repeat=3):
            sig = sigma_of(p, q, r, *e)
            M = mat(sig)
            if abs(det3(M)) != 2:
                continue
            pip = is_pip(M)
            if pip:
                total_pip += 1
                # Pisot necessary conditions
                assert f_at(M, 1) < 0 and f_at(M, -1) < 0, (cls, p, q, r)
            pos = lemma_position(cls, p, q, r)
            if pos is not None:
                if shared_tile_at(sig, *pos):
                    lemma_ok += 1
                else:
                    lemma_bad += 1
                    print("   LEMMA FAILS", cls, (p, q, r), pos)
            elif pip:
                residual.append((p, q, r))
        total_lemma += lemma_ok
        exp = sorted(x for x in RESIDUAL[cls] if max(x) <= bound)
        print(f"class {cls}: lemma witnesses verified {lemma_ok}, failed {lemma_bad};"
              f" PIP residual {len(residual)} {'== predicted' if sorted(residual) == exp else '!= predicted ' + str(sorted(residual))}")
    print(f"all classes: {total_lemma} explicit lemma witnesses checked, {total_pip} PIP points satisfy f(1)<0 and f(-1)<0")


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 24)
