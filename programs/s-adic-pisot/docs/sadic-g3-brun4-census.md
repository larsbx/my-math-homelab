# G3 calibration: Brun d = 4 periodic points

**Status:** two finite-domain theorems (§1, §2) that rest on the imported
BST23 balanced-pair criterion, plus recorded evidence (§3). This adds no
almost-everywhere result: BST23 Theorem 6.7 already proves a.e. pure discrete
spectrum for Brun `d = 4`. The purpose is to calibrate the G3 pipeline on a
cell whose answer is known, before it is pointed at an open one
(`docs/literature-gate-2026-10-09.md` §5).

Pipeline (`kernel/sadic/periodic.mojo`, `periodic_verdict`): for a Lyndon
word `w` with `w^∞` admissible under BST23 (6.10), decide in order
1. primitivity of `M_w` (Wielandt);
2. irreducibility of `χ_w` (certificate or refutation);
3. the Pisot property (Schur–Cohn with Lemma R);
4. the balanced pair algorithm on the composite `σ_w`, with budgets of
   200,000 states and length 20,000.

The first failing stage is reported. Brun matrices are unimodular, so a
composite that passes stages 1–3 is a unimodular Pisot irreducible
substitution, and **BST23 Proposition 6.1** (imported, verified) turns
termination of the balanced pair algorithm into pure discrete spectrum.

## 1. Replication of BST23 §6.5

`τ = β₁₂∘β₂₃∘β₃₄∘β₄₁` (labels `0, 4, 8, 9`) has images `12341, 12, 123, 1234`,
exactly as printed in BST23. The kernel certifies:
- `M_τ² > 0`;
- `χ_τ = z⁴ − 5z³ + 6z² − 4z + 1` is irreducible, certified mod 2;
- `χ_τ` is Pisot (three zeros in the disc, none on the circle);
- the balanced pair algorithm **terminates**.

So the finite input of BST23 Theorem 6.7 is reproduced independently, in Mojo
and in the Python oracle. Guarded by `kernel/tests/test_sadic_spectrum.mojo`
(`BrunFourPeriodicPointBPA`).

## 2. Census through period 8

Every primitive periodic point of the unordered Brun shift, `d = 4`, up to
rotation. Guarded by `kernel/tests/test_brun4_census.mojo`
(`BrunFourPeriodicCensus`); driver: `pixi run brun-census 4 8`.

| period | words | not primitive | reducible `χ` | not Pisot | BPA terminates | open |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 12 | 12 | 0 | 0 | 0 | 0 |
| 2 | 6 | 6 | 0 | 0 | 0 | 0 |
| 3 | 20 | 20 | 0 | 0 | 0 | 0 |
| 4 | 60 | 54 | 0 | 0 | 6 | 0 |
| 5 | 204 | 156 | 0 | 0 | 48 | 0 |
| 6 | 670 | 410 | 12 | 0 | 248 | 0 |
| 7 | 2,340 | 1,140 | 48 | 0 | 1,152 | 0 |
| 8 | 8,160 | 3,060 | 144 | 24 | 4,932 | 0 |
| **total** | **11,472** | **4,858** | **204** | **24** | **6,386** | **0** |

"Open" counts inconclusive verdicts, BPA failures, capped runs and
overflows: there are none.

**Finite-domain theorem.** Every primitive irreducible Pisot periodic point of
the `d = 4` unordered Brun shift with period at most 8 has a composite with
pure discrete spectrum. There are 6,386 of them up to rotation. Each one is a valid periodic Pisot
point for BST23 Theorem 3.1, since every point of the Brun algorithm has
positive range (BST23 §6.5).

The 24 non-Pisot points at period 8 all share
`χ = z⁴ − 20z³ + 30z² − 11z + 1`. The exact verdict is two zeros in the disc,
none on the circle; numerically the roots are `18.40, 1.104, 0.356, 0.138`,
given for illustration only. So periodic Brun `d = 4` points can fail the
Pisot property, which fits a Pisot condition that holds almost everywhere
rather than everywhere. One representative is
`(β₁₂, β₂₁, β₁₂, β₂₁, β₁₃, β₃₄, β₄₃, β₃₁)`, labels `0,3,0,3,1,8,11,6` in the
0-based pair order.

## 3. Evidence: period 9

Recorded with `mojo run -I . brun_census.mojo 4 9 2000000 200000`, which runs
the balanced pair algorithm with budgets of 2,000,000 states and length
200,000. The CI job `brun4-census-period-9` repeats the run and checks its
summary line.

| period | words | not primitive | reducible `χ` | not Pisot | BPA terminates | open |
|---:|---:|---:|---:|---:|---:|---:|
| 9 | 29,120 | 8,400 | 312 | 168 | 20,240 | 0 |

At the default budgets (200,000 states, length 20,000), 60 of the 20,240
composites are capped. All 60 terminate at the larger budgets. A first kernel
version overflowed on 48 non-primitive words, which led to the zero-pattern
primitivity test (`docs/sadic-kernel-g2-spectrum.md` §3).

Through period 9 the totals are 26,626 PIP composites, all terminating, and
192 certified non-Pisot points.

## 4. What this calibrates, and what it does not

- The G3 pipeline reproduces the one published finite certificate of this
  kind (BST23 §6.5) and finds no balanced-pair failure among the 6,386
  composites.
- Every composite certified here is a PSC instance. The census therefore also
  adds 6,386 four-letter substitutions to the PSC programme's
  pure-discrete-spectrum evidence, outside its three-letter corpus.
- Pointing the pipeline at an open cell needs a realization and a certified
  Pisot input (gate §5). For Brun `5 ≤ d ≤ 10` the realization exists, so the
  same census runs unchanged and gives evidence there.
