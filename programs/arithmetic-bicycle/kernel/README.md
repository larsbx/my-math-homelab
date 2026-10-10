# Kernel

`graph_bicycle.py` implements candidate exact graph maps, normalized-potential
enumeration, and critical-group coordinates using integer arithmetic and
`fractions.Fraction`. Its graph inputs are finite connected undirected
multigraphs; its modulus inputs are arbitrary integers at least two.

The integral theorem in `proof/graph-modular-bicycle.md` supplies proof
authority. Python remains a candidate language without acceptance authority
under `ESTATE.toml`; executable results are checked against the independent
oracle and source-pinned conformance receipts.

`regular_bicycle.py` implements candidate maps for a fixed full-row-rank
TU matrix. It verifies every square minor, constructs an integral right
inverse from a unit column basis, and uses exact rational Gram coordinates.
It handles rank zero, loops, and arbitrary composite moduli. The separate
integral proof in `proof/regular-modular-bicycle.md` supplies authority.
TU recognition and enumeration are intended for small fixtures.

Canonical general module algorithms, scalable SNF, general regular-matroid
representation independence, and arithmetic realization comparison
remain future work.
