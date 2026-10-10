# Target-aware BPA diagnostic: literature stop/go — 2026-10-02

**Decision: proceed with a finite diagnostic.** Part (b), C4, G1 and PSC keep
their existing status. This implements the experiment in
[issue #9's October 2 audit](https://github.com/larsbx/pisot-substitution-conjecture-research/issues/9#issuecomment-5953270122),
not a new coincidence or termination theorem.

## Experiment and baseline

Follow actual occurrences through substitution and ordered zero-return
factorization. Retain normalized BPA integer IDs, physical side orientation,
both occurrence addresses, target labels, prefix Parikh residuals and the
incoming factorization edge. Delete certified successful interior target
packets before computing recurrent SCCs. Report exact affine cycle receipts,
shortest existential target depth, and counterexamples to proposed potentials.

| Primary source inspected | Relevant baseline | Boundary |
| --- | --- | --- |
| Martensen, *A Generalized Balanced Pair Algorithm*, §§2–3.1, [arXiv math/0309194](https://arxiv.org/pdf/math/0309194) | Population-vector equality, substitution incidence, successive reduction of actual inflated pairs into irreducible balanced pairs | Reducible and non-Perron length variants change the algorithm; they do not justify a six-letter-pair quotient |
| Sirvent–Solomyak, *Pure Discrete Spectrum for One-dimensional Substitution Systems of Pisot Type*, Canad. Math. Bull. 45 (2002), 697–710, [publisher abstract](https://www.cambridge.org/core/journals/canadian-mathematical-bulletin/issue/865E7DC3E1BF4F54E741206BA66E50BE), DOI 10.4153/CMB-2002-062-3 | Balanced-pair and overlap algorithms are established constructions | Abstract inspected; no new theorem from the full text is imported here |
| Hollander–Solomyak, *Two-symbol Pisot substitutions have pure discrete spectrum*, ETDS 23 (2003), 533–540, [publisher abstract](https://www.cambridge.org/core/journals/ergodic-theory-and-dynamical-systems/article/abs/twosymbol-pisot-substitutions-have-pure-discrete-spectrum/602A997C102D38DB5F9C3B84B6CACB59) | The two-symbol case has a balanced-pair proof | It supplies no alphabet-three interior-depth bound |

The existing [BPA literature bridge](bpa-literature-bridge.md) remains the
repository's more extensive theorem baseline. No source inspected here supplies
the missing exclusion of realizable target-free recurrent packet SCCs. The
specialization being implemented is occurrence-sensitive instrumentation of
the established algorithm, with replayable evidence, not a novelty claim about
BPA itself.

## Hypotheses and negative controls

The executable accepts a complete, budget-bounded alphabet-three BPA seed
closure. Completion is checked; it is not assumed universally. Integer-state
normalization must retain the +/-1 physical side orientation. No unimodularity,
real secondary eigenvalue or floating projection is used to decide success.

Second-letter and depth-one seeding are overstrong proposals. Unequal image
lengths invalidate naive six-state letter-pair inflation. The strong G/F
synthetic template must pass its existing algebraic/endpoint tests and fail
only when its claimed ordered children are compared with actual factorization.
A zero residual at an exterior boundary, at a wrong target, or with inconsistent
occurrence addresses is not a successful interior seed.

## Stop/go result

Proceed only with the realizable occurrence/factorization graph. A target-free
cycle can coexist with an exit to a target: existential shortest depth and
universal avoidance are different questions. Split descendants and exhausted
budgets must be reported explicitly. These diagnostics neither discharge issue
#9 nor connect its route to issue #84 automatically.
