"""Alphabet-3 view of `substitution_dynamics.return_lattice`.

For a primitive `sigma` on `{0,1,2}`, the return lattice `Lambda_n` is the
subgroup of `Z^3` spanned by the Parikh vectors of the returns of length-`n`
factors. Through the Perron tile lengths `ell` it is the module of return
vectors in `Z<ell> = Z ell_0 + Z ell_1 + Z ell_2`, so `[Z^3 : Lambda_n]`
measures how far the return vectors of radius-`n` patches fall short of
spanning `Z<ell>` (`docs/return-lattice-literature-gate-2026-10-02.md`).

The exact Rauzy-graph route, the independent sampled route and the profile
verifier are the package's, over an explicit alphabet; substitutions enter as
image lists and are validated by `psc.bpa.sigma3`. A `TriangularLattice` is
the package type, constructed with its dimension (`TriangularLattice(3)`).
Integer arithmetic is checked, and a rank-deficient lattice raises rather
than reporting index `0`.
"""

from substitution_dynamics import return_lattice as sd
from substitution_dynamics.return_lattice import TriangularLattice
from psc.bpa import sigma3


def factor_set(sigma: List[List[Int]], m: Int) raises -> List[List[Int]]:
    """Every length-`m` factor of the language of the primitive `sigma`."""
    return sd.factor_set(sigma3(sigma), m)


def return_lattice(sigma: List[List[Int]], n: Int) raises -> TriangularLattice:
    """`Lambda_n`, exactly, in Hermite normal form."""
    return sd.return_lattice(sigma3(sigma), n)


def return_index_profile(sigma: List[List[Int]], max_n: Int) raises -> List[Int]:
    """`[Z^3 : Lambda_n]` for `n = 1..max_n`, at index `n - 1`."""
    return sd.return_index_profile(sigma3(sigma), max_n)


def sampled_return_index(sigma: List[List[Int]], n: Int, min_length: Int) raises -> Int:
    """The index of the lattice spanned by the returns seen in a prefix of
    `sigma^k(0)`: a multiple of the exact index, and an independent route."""
    return sd.sampled_return_index(sigma3(sigma), n, min_length)


def verify_index_profile(sigma: List[List[Int]], det: Int, profile: List[Int]) raises:
    """Refuse an index profile that breaks the divisibility chain or the
    covering bound; either failure is a defect, never a census result."""
    sd.verify_index_profile(sigma3(sigma), det, profile)


def covering_level(sigma: List[List[Int]], n: Int) -> Int:
    """The least `K` with `|sigma^K(a)| >= n` for every letter `a`."""
    return sd.covering_level(sigma3(sigma), n)
