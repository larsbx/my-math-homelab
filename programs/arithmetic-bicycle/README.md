# Arithmetic Bicycle Conjecture Research Program

Research workspace for the **Arithmetic Bicycle Conjecture (ABC)**: whether the full modular bicycle tower attached to an integral realization of a torsion-free representable arithmetic matroid is determined by the arithmetic matroid itself.

## Principal conjecture

Let \(\mathcal M=(M,m)\) be a torsion-free representable arithmetic matroid with integral realization
\[
A\in\mathbb Z^{r\times E}.
\]
For \(n\ge2\), define
\[
C_n(A)=\operatorname{im}(A^\top\bmod n),\qquad
Z_n(A)=\ker(A\bmod n),
\]
and
\[
\operatorname{Bic}_n(A):=C_n(A)\cap Z_n(A)\subseteq (\mathbb Z/n)^E.
\]

> **Arithmetic Bicycle Conjecture.** The compatible tower
> \[
> \{\operatorname{Bic}_n(A)\}_{n\ge2}
> \]
> depends only on \(\mathcal M\), not on the chosen integral realization \(A\).

The bootstrap's asserted equivalent finite-group formulation is withdrawn.
For the torsion-free arithmetic matroid realized by A=[2] in Z,
Bic_2(A)=0 and Bic_4(A)=Z/2. Every abelian group with zero 2-torsion
also has zero 4-torsion, so no single group represents that tower.
See the [counterexample proof](proof/arithmetic-torsion-model-obstruction.md).
Realization invariance remains a separate open conjecture. The finite-group
model is proved for graph and fixed full-row-rank TU representations.

## Baseline theorem ladder

The program is deliberately staged:

```text
G0  graphs: K(G)[n] ≅ Bic_n(G)
 ↓
R0  fixed TU representation of a regular matroid
 ↓
R1  regular-matroid representation independence
 ↓
A0  arithmetic-matroid realization equivalence
 ↓
A1  bounded counterexample search
 ↓
ABC realization-invariance theorem or minimal counterexample/refinement
```

Thread-derived arguments begin as `working` until they are reproduced by repository proof records or executable evidence.

## Authority planes

- `proof/` — theorem statements, proof records, claim states.
- `kernel/` — candidate exact graph and fixed-TU maps; future canonical module algorithms.
- `oracles/` — independent, non-authoritative cross-checks.
- `experiments/` — exploratory searches only.
- `conformance/` — replayable fixtures and receipts.
- `sources/` — literature/source provenance.
- `docs/` — research status, audits, roadmaps.
- `paper/` — publication surface consuming accepted claims.

Projective / Grassmannian geometry is a **derived field-valued shadow** of the integral theory, not acceptance authority for lattice/SNF/torsion claims.

## Current status

The graph modular-bicycle theorem is `proved` for every integer modulus
at least two. Its integral proof supplies representative independence,
both inverse directions, graph naturality, and compatible reduction and
inflation maps. Independent exact Smith-factor and critical-group checks
support it with composite-modulus fixtures and source-pinned receipts.

The fixed-TU regular-matroid theorem is also `proved` for every modulus.
Its integral right inverse makes the representative arguments work over
composite rings. Independent Smith factors, cycle completion, and quotient
enumeration support it, including a cographic K3,3 fixture and labeled
non-TU controls.

Regular-matroid representation independence is the next blocking target.
ABC and arithmetic-matroid realization invariance remain `open`. The
unconditional finite-group strengthening is `retracted`.

Start with:

1. [Graph proof](proof/graph-modular-bicycle.md)
2. [Fixed-TU proof](proof/regular-modular-bicycle.md)
3. [Current status](docs/research/status-2026-10-09.md)
4. [Roadmap](docs/research/roadmap.md)
5. [Claim registry](proof/claims.toml)
6. [Exact replay commands](conformance/README.md)
7. [Independent graph audit](docs/audits/graph-modular-bicycle-2026-10-09.md)
8. [Fixed-TU contribution audit](docs/audits/regular-modular-bicycle-2026-10-09.md)
9. [Independent fixed-TU acceptance audit](docs/audits/regular-modular-bicycle-independent-2026-10-09.md)
