# Tier 2: Growth Bridge research programme

## Status and purpose

**PSC is open.** On the repository's shortest sufficiency route
(`README.md`, `docs/research-roadmap-2026-09-21.md`) the one open premise is
seedwise overlap productivity `OP_seed` (Open Problem 5.35, issue #84), split
into the aligned branch #138 and the strict-zipper branch #139
(`AdelicPeriodicOffsetHitting`). An earlier draft of this file rested on the
premise that PSC is closed; that premise is withdrawn, since it contradicts
`docs/claim-status-and-source-map-2026-09-13.md`, which forbids describing PSC
as proved.

Tier 2 develops the Growth Bridge of `docs/tier2-bridge-salvage-2026-09-23.md`:
a proof template in which recurrent noncoincident packet dynamics are allowed
and the obstruction is arithmetic/spectral rather than termination. It is
therefore a candidate *mechanism toward* #84 (most relevant to #139), plus a
family of finite invariants. It is not built on PSC and proves no part of it.

Every Tier 2 statement falls into one of three classes:

- **Unconditional.** The finite algebra (loop gains, generated modules, index
  computations, the Penrose `H_tail` arithmetic); the imported criteria of the
  literature gate (Solomyak's eigenvalue criterion, Kenyon's realization,
  Pisot-trace sufficiency), whose hypotheses are primitivity, finite local
  complexity and self-similarity, not pure discrete spectrum; and the Penrose
  calibration, since Penrose PDS is Robinson's theorem, independent of PSC.
- **Open.** Any Growth Bridge theorem concluding PDS for the standing ternary
  primitive irreducible Pisot regime. Such a theorem would be a route to #84;
  none is claimed.
- **Firewall.** No Tier 2 argument aimed at #84, #138 or #139 may take as input
  PDS, `OP_seed`, `OP_all`, or any consequence of them (for example that
  eigenfunctions span `L^2`). Doing so would be circular.

This scaffold does not rewrite claim ledgers or generated status surfaces, and
moves no theorem status.

## Literature gate

The stop/go review is `docs/tier2-loop-gain-literature-gate-2026-09-27.md`.
Decision: **redirect, then proceed narrowed.** Obligation 3 below is
Solomyak's return-vector eigenvalue criterion (import, do not reprove);
obligation 5 is automatic in its asymptotic form and degenerate in the exact
form stated here; the mod-11 residual resonance of obligation 6 is stopped
and replaced by Pisot trace integrality over the full return module. The
surviving target is *recurrent visibility*: whether the recurrent loop gains
generate the same `Z[lambda]`-module as the return set. `affine_forcing`
loop invariants are `beta`-twisted sums, not plain sums.

## Main route

The active Tier 2 route is the Growth Bridge:

```text
finite exact overlap universe
-> finite packet factorization
-> bounded-time packet entry
-> eventual packet confinement
-> recurrent finite packet quotient
-> lifted exact-prefix additive cocycle
-> recurrent loop-gain subgroup
-> arithmetic resonance / kernel test
-> structural spectral consequences
```

The Descent Bridge remains a secondary route for settings with a genuine well-founded noncoincident rank. It is not the Penrose mechanism.

## Existing PSC machinery to reuse

Do not build another graph engine. The current repository already contains the relevant substrate:

- `kernel/psc/overlap_seed_patch.mojo`: exact overlap states with displacement in `Z[beta]`;
- `kernel/psc/overlap_zipper.mojo`: ordered child occurrences, preserving repeated occurrences and prefix positions;
- `kernel/psc/overlap_recurrence.mojo`: recurrent SCC extraction;
- `kernel/psc/overlap_affine_pump.mojo`: occurrence-labelled cycles obeying `w' = beta*w + q - p`;
- `kernel/psc/affine_ancestry_trace.mojo`: additive affine ancestry recurrence;
- `kernel/psc/overlap_contracting.mojo`: exact `Q(beta)` arithmetic, norms, conjugate-root sign tests, and contracting-place calculations.

Tier 2 should generalize these objects into packet/cocycle language rather than duplicate them.

## Core mathematical objects

### Packet quotient

A finite recurrent quotient `Q` of controlled exact-overlap states after bounded-time entry and confinement.

### Lifted exact-prefix state

A state `e in E` lying over `q in Q` that retains the exact ordered prefix/occurrence data forgotten by the finite quotient.

### Additive cocycle

An exact edge labelling

```text
DeltaPhi : Edge(E) -> Gamma
```

where `Gamma` is an arithmetic module attached to the expansion, initially a finitely generated subgroup of `Q(lambda)`.

### Gain-channel discipline

Every executable fixture names its gain channel explicitly. The first PSC adapter exports `affine_forcing`, the exact `q-p` term in the existing overlap affine recurrence. It is reusable arithmetic substrate, but it is **not identified with the Penrose exact-prefix `Phi` cocycle**. A Penrose `Phi` fixture must use a distinct channel and carry its own interpretation proof.

### Loop gain

For a closed lifted loop `ell`,

```text
gain(ell) = sum DeltaPhi(edge)
```

with exact arithmetic only. This is the `additive` loop composition. A
channel whose labels are forcing terms of an affine recurrence composes
`beta_twisted` instead: for `w' = beta*w + d`, a loop `d_0, ..., d_{k-1}`
translates by `sum_i beta^(k-1-i) d_i`, and the plain sum is not a loop
invariant. `affine_forcing` is such a channel. Every fixture declares its
`loop_composition`, and the schema pins `affine_forcing` to `beta_twisted`
(`docs/tier2-loop-gain-literature-gate-2026-09-27.md`, Finding 5).

### Recurrent loop-gain subgroup

For recurrent packet state `q`,

```text
G_q = subgroup generated by gains of closed lifted loops over q.
```

This is the first new Tier 2 finite invariant.

## First theorem programme

The immediate theorem work is deliberately split into independently auditable obligations.

Obligations 3, 5 and 6 below are restated per the literature gate; the earlier
formulations (exact annihilation, a separate inflation-closure lemma, a mod-11
residual resonance) are withdrawn.

1. **Arithmetic realization.** Prove that the lifted cocycle lands in an explicitly described finitely generated arithmetic module. For return vectors this is Kenyon's `Z[theta]`-lattice theorem; the obligation is its specialization to the lifted cocycle.
2. **Loop-gain invariance.** Prove that `G_q` is independent of cycle-basis choice and stable under the allowed packet normalizations.
3. **Eigenvalue bridge (imported).** Solomyak's criterion: `alpha` is an eigenvalue (measurable = continuous) iff `exp(2 pi i <phi^n z, alpha>) -> 1` for every return vector `z`, plus the period condition. Cite it; do not reprove it. The constraint is asymptotic, not exact annihilation.
4. **Spectral-character restriction.** Define precisely the image of measurable translation eigenvalues inside the character group of the arithmetic gain module. The target is this restricted class, not all additive characters of the ambient module.
5. **Recurrent visibility.** The set of `z` satisfying the criterion is already a `Z[lambda]`-module, so no inflation-closure lemma is needed. The obligation is instead to prove, or refute with a finite certificate, that the `Z[lambda]`-module generated by the recurrent loop gains equals the one generated by the full return set. The defect module, if nonzero, is the new finite invariant.
6. **Pisot trace test.** Decide eigenvalues on the full return module by eventual trace integrality (`dist(theta^n x, Z) -> 0` for Pisot `theta`). An index computed from one recurrent component cannot decide it: see control C2 in the gate note.
7. **Penrose witness.** Compute the source-grounded Penrose gain and the exact arithmetic closure, keeping finite algebra separate from the spectral implication.
8. **Class promotion.** Only after the preceding obligations are closed should a general Growth Bridge theorem be promoted.

## Penrose first witness

The Penrose line supplies the intended calibration:

- finite packet family `{A_same, A_opp}`;
- bounded-time entry;
- absorbed recurrent tail represented by `H_tail`;
- lifted exact-prefix invariant `Phi`;
- strict positive step increment `DeltaPhi >= 2 - phi`.

The first executable Tier 2 task is therefore not another Penrose proof. It is to export the recurrent lifted loops and compute the exact subgroup generated by their `Phi` gains.

## Cross-repository ownership

### This repository

Owns all domain meaning and theorem status:

- packet definitions;
- Penrose and substitution-specific adapters;
- the exact mapping from existing overlap machinery to the Growth Bridge;
- spectral statements and their hypotheses;
- claim ledger entries and proof records;
- canonical Mojo integration tests.

### finite-math-kernels

Owns only reusable finite algebra:

- finite directed weighted graphs;
- additive edge cocycles;
- cycle-basis extraction;
- exact generated subgroup/module calculations.

It must not know about PSC, Penrose, pure discrete spectrum, or eigenvalues.

### julia-oracle-lab

Provides independent, non-authoritative differential evidence for:

- cycle-basis enumeration;
- loop-gain generation;
- Hermite/Smith normal-form comparisons when applicable;
- replay of canonical fixtures emitted by PSC.

### semantic-categorical-oracle

May own explicitly registered semantic contracts such as:

- cycle-basis independence of the presented subgroup;
- preservation under graph normalization/quotient maps;
- composition laws for cocycle transport.

It does not decide mathematical proof or spectral truth.

## Initial executable interface

The first canonical PSC-side record should be conceptually equivalent to:

```text
LoopGainFixture {
  packet_component_id
  vertices
  occurrence_labelled_edges
  edge_gain_coordinates
  loop_composition
  arithmetic_basis
  expected_generated_module
}
```

The serialization must be deterministic and replayable. Caps or incomplete graph extraction are inconclusive.

## Acceptance boundary for the scaffold phase

This phase is complete when:

- the four repository contracts agree on ownership;
- the PSC issue names the first theorem and executable obligations;
- the generic kernel issue is opened upstream;
- any oracle contract states its inputs, conformance checks and non-authoritative role;
- no new scaffold text claims that a finite computation proves a class theorem.

The next implementation pass begins with the domain-neutral cycle/gain kernel upstream and the PSC adapter that converts `AffinePumpCertificate` data into exact loop gains.


## Penrose arithmetic refinement: rank one first, index eleven after inflation closure

The source-grounded H_tail increment cocycle has recurrent period gain

```text
g = 4 - phi = (4,-1) in Z[phi].
```

As a plain additive loop subgroup this gives only

```text
Z * g,
```

which has rank one inside `Z[phi] ~= Z^2`. Therefore it is contained in the
kernel of many nontrivial ambient additive characters. Any theorem statement
requiring escape from **every** nontrivial character of `Z[phi]` is too strong
for the Penrose witness.

There is, however, a sharper arithmetic possibility. Multiplication by the
expansion gives

```text
phi * g = -1 + 3 phi = (-1,3).
```

The two coordinate vectors

```text
(4,-1), (-1,3)
```

have determinant `11`. Hence the principal `Z[phi]`-submodule generated by
`g` has index 11 in the ambient rank-two module. Under the row-HNF convention
used by finite-math-kernels its integer lattice has canonical basis

```text
(1,8), (0,11).
```

Equivalently, the quotient is detected by

```text
r(a,b) = 3a + b mod 11,
```

and is cyclic of order 11.

This finite arithmetic stands, but it carries no eigenvalue constraint. A
nonzero real eigenvalue never annihilates the rank-two module `Z[phi] g`: the
kernel of `t -> exp(2 pi i t alpha)` on a subgroup of `R` has rank at most one.
Conversely, `alpha = 1/g` annihilates `Z g` exactly but is not an eigenvalue
(control C2). The Inflation-Closure Lemma and the order-11 residual resonance
problem proposed here are therefore **withdrawn**; see obligations 5 and 6
above and `docs/tier2-loop-gain-literature-gate-2026-09-27.md`.
