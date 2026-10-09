# C4 degree-2 three-state trace/factorization diagnostic

**Status:** exact necessary-condition identities proved; exhaustive 4,554-PIP finite-corpus calibration complete. These conditions are useful filters but are **not** a three-state exclusion theorem.

## 1. Setup

Let `C` be a hypothetical strict closed nonproductive degree-2 SCC with exactly three states. The proved intertwiners give

`N_C ~ M_sigma`,

`S_C ~ Lambda^2 M_sigma`,

because both the Parikh matrix `P_C` and the degree-2 defect matrix `Q_2` are invertible over `Q`.

Write

`N=A+B`, `S=A-B`, `A,B>=0`,

for positive/negative orientation occurrence matrices.

## 2. Power-trace necessary conditions

For every `k>=1`,

`tr(N^k)-tr(S^k) = 2 sum tr(W) >= 0`,

where the sum ranges over length-`k` noncommutative words in `A,B` containing an odd number of `B` factors. Every product is nonnegative entrywise.

Therefore

> `tr(M^k) >= tr((Lambda^2 M)^k)` for every `k>=1`.

If

`chi_M(t)=t^3-T t^2+U t-d`,

then at `k=1`,

`T-U=2 tr(B)>=0`,

and at `k=2`,

`tr(M^2)-tr((Lambda^2 M)^2)=4 tr(AB)`,

so the difference is nonnegative and divisible by four.

For `d=1`, the `k=2` difference simplifies to

`(T-U)(T+U+2)`,

which explains why the `k=2` test adds no power beyond parity on most unimodular specimens.

## 3. Exact arithmetic and endpoint filtering

Over the established 4,554 alphabet-3 PIP substitutions with image lengths `<=3`:

- three-state mod-2 parity survivors: `1716`;
- parity survivors whose **both** endpoint maps are nonsynchronizing: `570`;
- survive trace conditions through `k=3`: `1662`;
- survive through `k=6`: `1662`;
- survive through `k=12`: `1554`;
- survive parity + both nonsynchronizing endpoints + traces through `k=12`: `546`.

Trace failures first occur at:

- `k=3`: `54` specimens;
- `k=7`: `108` specimens.

Thus neither power traces nor endpoint types close the three-state case. An explicit combined survivor has characteristic data

`(T,U,d)=(1,-1,1)`

and endpoint types `G/F`.

## 4. Actual BPA factorization is the decisive finite filter

The census then builds the exact BPA for all `546` combined survivors.

Results:

- capped BPA builds: `0`;
- specimens with a recurrent noncoincident SCC of size `3`: `0`;
- specimens with a noncoincident sink SCC of size `3`: `0`;
- minimum recurrent noncoincident SCC size among the combined survivors: `4`;
- minimum noncoincident sink-SCC size among the combined survivors: `4`.

So in this finite corpus the arithmetic and endpoint constraints permit hundreds of hypothetical three-state templates, but **actual zero-return factorization realizes none of them**.

This is finite evidence, not a theorem. It identifies the missing information much more sharply.

## 5. Consequence for the proof program

The remaining three-state theorem is not spectral, parity, trace, or endpoint-map classification alone. It must use that the ordered signed child word is obtained specifically by

`decompose_pair(sigma(u_T), sigma(v_T))`

for actual irreducible balanced states `T` under one actual substitution `sigma`.

In other words, the load-bearing constraint is:

> **factorization compatibility:** simultaneous compatibility of substitution-image ordering, zero-return prefix-difference evolution, irreducible balanced blocks, orientation signs, and endpoint quotient phases.

The companion synthetic-realizability artifact makes this distinction explicit by satisfying all preceding algebraic/per-state/endpoint constraints while deliberately failing actual zero-return child factorization.

## 6. Guardrails

- The 4,554 census is finite evidence only.
- Trace positivity is proved as a necessary condition, not sufficient.
- Absence of actual size-3 SCCs in the corpus is not a general theorem.
- No claim of C4, C1, G1, or PSC is made.
