# Roadmap

## Phase 0 — governed bootstrap

- [x] Declare ABC precisely.
- [x] Add authority planes and conservative claim registry.
- [x] Preserve thread state as non-authoritative audit provenance.
- [x] Add CI after the first executable conformance fixture exists.

## Phase 1 — graph modular bicycle theorem

Goal:
\[
K(G)[n]\cong \operatorname{Bic}_n(G)
\]
for every connected graph and \(n\ge2\).

Completed in the 2026-10-08 graph contribution:

- [x] Exact statement with graph naturality, reduction, and inflation maps.
- [x] Integral proof record, including representative independence and both inverse identities.
- [x] Examples for prime, prime-power, and composite moduli.
- [x] Independent exact SNF and critical-group oracle checks.
- [x] Negative tests for incorrect representative/lift constructions.

Promotion:

- `ABC-GRAPH-MODULAR-BICYCLE`: `working` -> `proved`, supported by
  `proof/graph-modular-bicycle.md`, the dated proof audit, and source-pinned
  conformance receipts.

The graph theorem and its independent audit remain separate from the
fixed-TU and representation-independence obligations below.

## Phase 2 — fixed TU regular matroids

Completed in this contribution: replace graph connectedness with an
integral right inverse of a full-row-rank TU matrix A. The proof covers
every integer modulus, both representatives and inverse identities,
specified coordinate equivariance, and compatible modulus maps.
Independent evidence includes graphic and cographic fixtures, all-minor
Smith factors, separate cycle completion and quotient enumeration, and
non-TU controls that distinguish loss of splitting from loss of TU.

Promotion:
- `ABC-REGULAR-MODULAR-BICYCLE`: `working` -> `proved`, supported by
  `proof/regular-modular-bicycle.md`, its dated proof audit, and the TU
  source-pinned receipt.

Next blocking target: Phase 3. Specified coordinate equivariance does not
discharge the theorem relating arbitrary TU realizations of one matroid.

## Phase 3 — regular representation independence

Pin down the exact theorem relating TU representations of the same regular matroid and prove the modular tower is representation-independent.

The October 9 acceptance review located Backman–Baker–Yuen, Section 2.1,
Lemma 2.1.1, as the coordinate-equivalence reference. Next audit its labeled
hypotheses and write the repository proof record applying the fixed-TU
coordinate maps to the full tower. This phase is not promoted by the
fixed-representation theorem.

## Phase 4 — arithmetic-matroid equality and fixtures

Define fail-closed equality for representable arithmetic matroids using lattice-index multiplicities / module data.

Retain realization invariance as the principal conjecture. The bootstrap's
unconditional finite-group strengthening is false: A=[2] is torsion-free
but has Bic_2=0 and Bic_4=Z/2. Its separate counterexample record retracts
that strengthening. Any torsion-group extension needs additional
hypotheses or a different representing object; Phase 4 must not assume
it is equivalent to realization invariance.

## Phase 5 — bounded counterexample search

Enumerate small non-TU integer matrices, bucket by arithmetic matroid, and compare bicycle modules for:
- primes,
- prime powers,
- mixed composite moduli.

A mismatch is a valid ABC counterexample/refinement signal.

## Phase 6 — structural attack

If bounded searches survive, seek an intrinsic construction of the bicycle tower from arithmetic-matroid data.

## Phase 7 — projective shadow

Formalize Grassmannian/determinantal interpretations only after the integral kernels are stable.
