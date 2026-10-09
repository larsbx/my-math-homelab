# Independent audit of the operator-quotiented H3 experiment

**Status: bounded experiment audit; no proof or claim-status promotion.**

Date: 2026-10-05. Original PR #25 head:
`db7265587c8fb32df6e37333cce66e70c291420b`. Reconciliation base:
`main@3c6071823f6de4507bb199936eb6f280b6b4125c` (merged PRs #26 and #27).
During the audit, another contributor published the reconciliation at
`d037b3c3452622ee6bc37c8403b1a0cf639df848`; the final audit additions build
on that commit and preserve it.

## Finding

No blocking error was found in the quotient weighting, representative
policies, matched-control counts, permutation expectation, or the
combination of certificate replay and complete regeneration. The experiment
supports the finite descriptive statements in its protocol, with the
limitations below. It does not settle H3 or review the separate G2 proof.

The statistical implementation, every summary row/control and the compressed
certificate bytes remain unchanged from the original audited head. The
concurrent reconciliation changes only the emitted status text and the
corresponding source digest in the summary. It preserves the new base's
policy, Lean and TLC jobs, regenerates the ledger surfaces, and adds
certificate replay to the base's common Python gate runner. Three new
regression oracles record the independent counting checks.

## Quotient and representative audit

The unit is the exact `(left-comb value, integer L-product)` class. Every
class contributes one unit, and a value fibre containing `r` distinct
operators contributes `choose(r,2)` pairs. Alias counts enter only the raw
diagnostics. Full regeneration reproduces 1,154,412 reduced words and
182,960 quotient collision pairs.

`tests/test_h3_conditioned_audit.py` traverses all `14^4` index tuples in the
unit calibration, filters the adjacent conjugate indices, and evaluates
each of the resulting 30,758 words independently of the driver's prefix
enumerator. It reconstructs all 114 quotient classes, every alias count,
both extremal words and labels, and every ambiguity flag. Directly counting
the 114 choose 2 class pairs reproduces its 350 value-only collisions.
Unequal artificial alias weights change its raw diagnostics but leave the
quotient pairs and every first/last policy statistic unchanged.

The first/last check is sensitivity evidence, not invariance under every
choice of representative. The committed output correctly reports differences:

| Exploratory panel | First matched collision pairs | Last matched collision pairs | First same-extra pairs | Last same-extra pairs |
| --- | ---: | ---: | ---: | ---: |
| Unit calibration | 144 | 144 | 104 | 104 |
| Coordinate 1234 | 1,343 | 1,352 | 1,019 | 1,018 |
| Coordinate 1247 | 2,192 | 2,200 | 2,192 | 2,200 |
| Cycle 12347 | 1,407 | 1,411 | 775 | 781 |

## Matched controls and exact null

A block matches the full ordered Gram label and `2*value[0]`. For each
block let `N` be its units, `T=choose(N,2)` all edges, `C` equal-value
edges, `S` equal-extra-label edges, and `J` edges matching both value and
extra label. The code's different-value controls have `T-C` edges and
`S-J` equal-extra edges. The observed shares are `J/C` and
`(S-J)/(T-C)`, with unsupported denominators reported as null.

Under a uniform permutation of the extra labels within that block, any
fixed edge agrees with probability `S/T`. Linearity of expectation gives
exact expected agreement `C*S/T`; the code sums this rational quantity
over blocks. This remains valid for dependent edges. The new oracle
enumerates all `3! * 4! = 144` permutations in two separate blocks and
reproduces expectation `1/2`, supplementing the original five-unit oracle.
Direct edge enumeration of the unit calibration reproduces the moments,
matched collision/control counts, and both complete policy summaries.

The enrichment ratio is a pooled descriptive comparison across matched
blocks, not a standardized causal effect, permutation p-value or independent
Bernoulli trial estimate. It need not weight blocks like the permutation
expectation. The protocol claims none of those stronger interpretations.
The coordinate-1247 panel has constant labels within every matched block:
its ratio is exactly one and it has zero informative blocks, despite
perfect form agreement among its matched collisions.

## Certificate scope and completeness

The summary digest binds the decompressed certificate JSON. `--replay`
checks summary/bundle row coverage and pair totals, decodes valid reduced
word IDs, evaluates first and last words as full integer values and
matrices, requires equality within each recorded class, and requires
distinct operators within each collision fibre. It also rechecks the
operator-alias, different-value, length-three and single-form controls.
All 182,960 recorded quotient collision pairs replay successfully.

Replay alone is a witness check: positive multiplicities, claimed
first/last extremality and omitted fibres cannot be certified without
enumeration. The protocol explicitly assigns those properties to
`--check`, which reenumerates every word and compares the full summary
and decompressed bundle byte for byte. That complete check passed on the
original head. Original mutation tests reject invalid values, operators,
duplicate operator classes, out-of-range words and zero multiplicities.
No completeness conclusion is inferred solely from the replay count.

## Sampling and status boundaries

The four prespecified sampled configurations retain 4,240 raw value-only
pairs, 98 quotient pairs and zero Gram-matched collision support under
both policies. All five later panels remain explicitly exploratory,
including the norm-one calibration and the zero-support axis panel.
The three norm-three panels contribute 182,512 quotient pairs; their
panel-dependent sharing ratios are descriptive, not confirmation of H3.

The original October 4 summary at `db726558` records `Conjecture 3.32
experimental`. The concurrent reconciliation updates the current summary
to `bounded experiment; H3 open`, without changing any statistical evidence
or certificate. PR #27 separately supplied a
written proof, called Theorem 3.32 in the manuscript and recorded as
`WordDefectG2Determined`, still pending independent review. This audit
does not adjudicate that proof, set a review flag, promote the record or
roll back that separate contribution. `DefectStratifiedCollisions` remains
`pending_dependency`; `H3ConditionedIntegral` and `WordDefectG2Data` remain
`bounded_experiment` records.

## Validation

- Original-head GitHub workflows `verify` (37188413214) and `lean-oracle`
  (37188413301) succeeded.
- Original complete `h3_conditioned.py --check` passed, and `--replay`
  reported all 182,960 pairs.
- All 13 focused H3 tests passed, including the three independent oracles.
- The final additions on `d037b3c` also pass all 13 focused tests, fast gates,
  complete H3 regeneration and replay of all 182,960 pairs. Only status
  metadata/source hashes changed in the concurrent reconciliation; all
  statistical rows and controls compare equal to the original evidence.
- All 170 unit and regression tests passed on the preliminary local
  reconciliation (`9ac227fe2b7214ad954979298e773f8d7e702ea1`).
- That preliminary tree's `scripts/verify_all.sh fast` passed.
- That preliminary tree's `scripts/verify_all.sh python` passed every selected gate:
  all tests, every census regeneration, certificate replay, provenance,
  registry, vendoring, estate pins, generated ledger, governance/coverage
  and generated paper tables.
- Lean and TLC were explicitly reported as local skips: `lake` and the
  TLC jar were unavailable. Their current-head CI jobs must pass before
  merge. A skip is not a successful check.

The new tests repair coverage of an existing experiment contract and add no
universal invariant or theorem-facing diagnostic. They need no new
literature stop/go decision under `AGENTS.md`.
