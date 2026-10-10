# Level 3 recurrent-trim / geometric Lyapunov program — 2026-09-25

**Status:** research branch note. This is **not** a canonical theorem-status surface and does not supersede `docs/proof-ladder.md`, `docs/research-roadmap-2026-09-21.md`, or issue #84.

## 1. Scope

This note records a stronger parallel Level-3 route that acts on a **finite recurrent balanced-pair carrier**. It therefore belongs to the finite-BPA / recurrent-SCC program unless and until a separate bridge removes the G1-style finiteness dependency.

For an irreducible noncoincidence balanced-pair state (T=(u,v)), let

[
L(T) := g(u)=g(v)=\langle \ell,\pi(u)\rangle
]

be its geometric defect span. Under one inflate-cut-reduce step, for a chosen noncoincidence child (T'),

[
L(T') = \beta L(T)-\tau(T\to T'),
]

where (\tau) is the total geometric material removed by coincidence cuts before the child is retained.

The proposed recurrent trim inequality is

[
\boxed{\tau(T\to T') < (\beta-1)L(T)}
]

on every recurrent-to-recurrent noncoincidence edge. It implies

[
L(T')>L(T).
]

On a finite recurrent noncoincidence graph, strict increase of (L) rules out directed cycles.

## 2. Distinction from the retired Parikh-difference contraction route

This scalar does not use the Parikh **difference** (pi(u)-pi(v)), which vanishes on balanced pairs. It uses the common Parikh mass

[
L(T)=\langle \ell,\pi(u)\rangle=\langle \ell,\pi(v)\rangle.
]

Thus the existing no-go observation for difference/eigenspace invariants does not apply to (L).

## 3. Working proof chain

The current working reduction is:

1. **Irreducible-child lemma.** A child produced by inflate-cut-reduce has no proper interior balanced split that should already have been cut.
2. **Suffix forcing.** In a reduced recurrent nc state, a same-tile Parikh-balanced position must be a right-boundary/common-suffix position, not a genuine interior coincidence.
3. **No genuine interior coincidences on reduced recurrent edges.** Hence trim on such an edge is determined by boundary coincidence data.
4. **Boundary trim bound.** Let (C_{mathrm{rec}}(sigma)) be the maximum legal boundary trim over recurrent endpoint tile-pairs. Then
   [
   \tau\le C_{\mathrm{rec}}(\sigma).
   ]
5. **Reduced recurrent size lemma.** It remains to prove
   [
   L(T)>\frac{C_{mathrm{rec}}(sigma)}{\beta-1}
   ]
   uniformly on reduced recurrent nc states.
6. **Unreduced case.** A first-mismatch/minimal-compensation normal form appears to give a separate finite local estimate; this branch is not currently the main difficulty.

Once Steps 4–5 are rigorous, the recurrent trim inequality follows.

## 4. Finite evidence from the working session

The current external working stack reports:

- 42/42 recurrent nc edges across four explicit specimens satisfy
  [
  \tau<(\beta-1)L;
  ]
- the minimum observed growth ratio (L(T')/L(T)) is (1.528);
- 39/39 reduced recurrent edges showed no genuine interior coincidence cuts;
- in the unreduced recurrent sample, a single local compensation type occurred with a large margin.

These are **finite specimen checks only** until reconstructed in the repository's canonical Mojo layer with replayable fixtures and completeness labels.

## 5. Hypothesis firewall

Any general theorem on this branch must preserve the repository standing regime.

In particular:

- do not assume finite BPA unless the theorem is explicitly conditional on it;
- do not add tile-length (mathbb Q/mathbb Z)-independence as an independent hypothesis where irreducibility is intended to supply the needed independence;
- do not add unimodularity;
- do not promote the four-specimen computation to a universal result;
- do not infer a theorem on the seed-patch overlap graph without a separate ordered-chain bridge.

## 6. Immediate proof tasks

1. State the irreducible-child lemma in the exact `balanced_pairs.decompose` / zero-return language used by the canonical implementation.
2. Prove suffix forcing without invoking the desired monotonicity.
3. Define (C_{mathrm{rec}}(sigma)) in terms of legal recurrent endpoint data.
4. Prove the reduced recurrent size lemma.
5. Reconstruct the 42-edge finite check in Mojo and retain the four specimen substitutions as regression fixtures.
6. Keep this route labelled **parallel stronger structural route** until the bridge in `docs/p1-overlap-trim-bridge-2026-09-25.md` is proved.

## 7. Relationship to the live PSC route

The live shortest route on `main` is seedwise overlap productivity (#84), which does not assume finite BPA. A strict Lyapunov function on a finite recurrent balanced-pair component therefore does not by itself close #84.

The value of this branch is twofold:

- it may close Level 3 on the finite-BPA/SCC route;
- its geometric mass identity may admit a lift to the already-finite seed-patch overlap graph, which is investigated separately.
