"""The finite three-letter lemma behind Theorem R.

Theorem R (docs/p1b-periodic-pair-fibre-literature-gate-2026-10-02.md, §5):
the return module of a primitive substitution whose frequency vector has
Q-independent coordinates is all of Z^A; in particular `Lambda_1 = Z^3` for
every PIP substitution on three letters. The return module is `Lambda_1` of
`psc.return_lattice`, computed there exactly as the cycle lattice of the
two-letter (order-1 Rauzy) graph; this module does not recompute it.

What lives here is the second proof's finite lemma: on three vertices the
cycle lattice of any digraph (spanned by the letter-count vectors of its
simple cycles: loops, two-cycles and the two oriented triangles) has rank
below 3 or is all of Z^3. Irreducibility of the incidence matrix gives rank 3
(the return module is M-invariant), so the lemma gives index 1.
"""

from psc.return_lattice import TriangularLattice, return_lattice
from psc.words import ALPHABET


def cycle_vectors(edge: List[List[Bool]]) -> List[List[Int]]:
    """Letter-count vectors of the simple cycles of a digraph on {0,1,2}."""
    var out = List[List[Int]]()
    for a in range(3):
        if edge[a][a]:
            var v: List[Int] = [0, 0, 0]
            v[a] = 1
            out.append(v^)
    for a in range(3):
        for c in range(a + 1, 3):
            if edge[a][c] and edge[c][a]:
                var v: List[Int] = [0, 0, 0]
                v[a] = 1
                v[c] = 1
                out.append(v^)
    if (edge[0][1] and edge[1][2] and edge[2][0]) or (edge[0][2] and edge[2][1] and edge[1][0]):
        out.append([1, 1, 1])
    return out^


def lattice_index(vectors: List[List[Int]]) raises -> Int:
    """Index in Z^3 of the span of `vectors`, 0 when the span has rank below 3."""
    var lattice = TriangularLattice(ALPHABET)
    for v in range(len(vectors)):
        lattice.insert(vectors[v])
    if lattice.rank() < 3:
        return 0
    return lattice.index()


def return_module_index(sigma: List[List[Int]]) raises -> Int:
    """`[Z^3 : Lambda_1]` for primitive `sigma`, 0 when `Lambda_1` has rank below 3."""
    var lattice = return_lattice(sigma, 1)
    if lattice.rank() < 3:
        return 0
    return lattice.index()
