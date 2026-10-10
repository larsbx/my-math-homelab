# P1-B — sidewise finite-cokernel diagnostic

**Status:** exact finite diagnostic for the open G1b-2 renewal-finiteness gate. This note records falsification evidence and does **not** prove G1b-2, finite BPA, a complete Rauzy address, or a complete non-Archimedean state.

## 1. Motivation

The bounded joint-local projection at source radius `2` and digit window `1` leaves `12,466` collision pairs through substitution depth `7` for the canonical determinant-two Pisot substitution

```text
0 -> 1
1 -> 021
2 -> 001
```

and the single strict first-return seed

```text
(01,10).
```

Every count in this note is restricted to that substitution, that seed, and the stated finite depth/bounds unless explicitly said otherwise.

Observed synchronous symbolic recurrence components account for `946` of those pairs, leaving `11,520` residual pairs. Refining only the scaled defect `M^d delta` by powers of two separates many cross-level pairs but plateaus at `4,652` survivors and cannot distinguish same-depth pairs that already have identical scaled defect.

This motivates keeping the **individual side translations**, not merely their difference.

## 2. Exact sidewise prefix translations

For a certified renewal address, the top and bottom substitution-digit paths determine exact prefix translations

```text
p_top, p_bottom in Z^3.
```

They are reconstructed directly from the ordered substitution path. The implementation checks

```text
p_top - p_bottom = correction,
```

where `correction` is the existing integer certificate term in

```text
M^d delta + correction = 0.
```

Thus the new diagnostic refines an already-certified address rather than introducing an independent coordinate convention.

## 3. Finite cokernel comparison

For fixed `k >= 1`, compare each side in

```text
Z^3 / M^k Z^3.
```

Because `det M != 0`, this is a finite abelian group. For the canonical example `|det M|=2`, so its order is `2^k`.

Equality modulo `M^k Z^3` is checked exactly. If `c0,c1,c2` are the columns of `M^k`, then `v` lies in `M^k Z^3` precisely when the three Cramer numerators

```text
det(v,c1,c2),
det(c0,v,c2),
det(c0,c1,v)
```

are divisible by `det(M^k)`. No floating inverse, Euclidean stable-space lattice, or unimodularity assumption is used.

## 4. Canonical bounded-corpus result

For the substitution and seed `(01,10)` above, the exact corpus through depth `7` contains:

- `601` certified observations;
- `12,466` bounded-projection collision pairs;
- `946` pairs inside observed synchronous symbolic components;
- `11,520` residual pairs after that symbolic quotient;
- `4,645` of those residual pairs at equal substitution depth.

The canonical Mojo survivor staircase is:

| `k` | cokernel order | all residual survivors | same-depth survivors | separated |
|---:|---:|---:|---:|---:|
| 1 | 2 | 11,520 | 4,645 | 0 |
| 2 | 4 | 10,828 | 4,353 | 692 |
| 3 | 8 | 6,897 | 2,773 | 4,623 |
| 4 | 16 | 3,538 | 1,453 | 7,982 |
| 5 | 32 | 1,540 | 674 | 9,980 |
| 6 | 64 | 500 | 262 | 11,020 |
| 7 | 128 | 83 | 82 | 11,437 |
| 8 | 256 | 56 | 55 | 11,464 |
| 9 | 512 | 26 | 25 | 11,494 |
| 10 | 1,024 | 1 | 0 | 11,519 |

These are finite-corpus facts only. The values at levels `6` through `10` were calibrated and then pinned from the canonical Mojo implementation; an earlier extrapolation was rejected by CI and is not part of the result.

## 5. Hard counter-calibration for the tested abelian sidewise coordinates

Exactly one residual collision pair in this corpus already has **equal exact sidewise prefix translations**, not merely equal finite-cokernel classes:

```text
depth 7, cut 14
versus
depth 5, cut 14.
```

For both observations,

```text
p_top    = (5,6,3)
p_bottom = (5,6,3).
```

They also have the same bounded joint-local projection. By cokernel level `10`, this is the only residual pair left. Consequently, no deeper quotient built solely from these **same two abelian sidewise prefix translations** can separate this pair: exact equality has already occurred before quotienting.

This does **not** disprove G1b-2. It falsifies only the candidate completeness claim

```text
bounded joint-local type
+ these sidewise abelian prefix translation data
=> complete renewal state.
```

It does not rule out every other finite commutative refinement, nor does it prove that order-sensitive or noncommutative data are necessary.

## 6. Next candidate to test

The depth-7 and depth-5 observations have the same cut, the same bounded local projection, and the same exact tested sidewise abelian translations, while their symbolic substitution histories have different lengths. This makes an order-sensitive ancestry invariant a natural **next candidate to test**, because it retains information erased by the present Parikh-based coordinates. It is not established here as the only possible adequate refinement.

One concrete next experiment is an exact prefix-suffix affine trace. For a paired top/bottom edge at ancestry level `t`, let `q_t` be the difference of the proper-prefix Parikh vectors and evolve

```text
x_0 = delta,
x_{t+1} = M x_t + q_t.
```

A candidate state is

```text
(top_current_letter, bottom_current_letter, x_t).
```

Repeated exact states can then be tested as certified symbolic pump cycles. This remains only a candidate normalization mechanism: deleting repeated affine-state cycles would establish a symbolic path quotient, not renewal finiteness by itself.

Any future positive result must still bridge from such a finite executable state to a **uniform** theorem over all realizable bounded-discrepancy first returns. Finite separation on this single-seed corpus is not that theorem. G1b-2 remains open.
